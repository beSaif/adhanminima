import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/widgets.dart';

import '../prayer/prayer_schedule.dart';
import 'settings_store.dart';

/// Where prayer times are calculated for.
class SavedPlace {
  const SavedPlace({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;

  /// Short display name, e.g. "Geneva, CH".
  final String label;

  Coordinates get coordinates => Coordinates(latitude, longitude);
}

/// Schedules the system notifications for upcoming prayers.
abstract interface class PrayerAlerts {
  Future<bool> requestPermission();
  Future<void> schedule(List<PrayerTime> prayers, String placeLabel);
  Future<void> cancelAll();
}

/// Everything the user has chosen, persisted through a [SettingsStore].
class AppState extends ChangeNotifier {
  AppState({required this._store, this._alerts, DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  final SettingsStore _store;
  final PrayerAlerts? _alerts;
  final DateTime Function() clock;
  Timer? _alertSync;

  SavedPlace? _place;
  CalculationMethod _method = CalculationMethod.karachi;
  Madhab _madhab = Madhab.shafi;
  final Map<Prayer, int> _offsets = {for (final p in dailyPrayers) p: 0};
  bool _notifications = false;

  SavedPlace? get place => _place;
  CalculationMethod get method => _method;
  Madhab get madhab => _madhab;
  Map<Prayer, int> get offsets => Map.unmodifiable(_offsets);
  bool get notificationsEnabled => _notifications;

  ScheduleInputs? get inputs {
    final place = _place;
    if (place == null) return null;
    return ScheduleInputs(
      coordinates: place.coordinates,
      method: _method,
      madhab: _madhab,
      offsets: _offsets,
    );
  }

  /// Today's (or, after Isha, tomorrow's) times; null until a place is set.
  DaySnapshot? snapshot() {
    final inputs = this.inputs;
    return inputs == null ? null : DaySnapshot.at(clock(), inputs);
  }

  Future<void> load() async {
    final v = await _store.load();
    final lat = v[_Keys.lat], lng = v[_Keys.lng], label = v[_Keys.label];
    if (lat is double && lng is double && label is String) {
      _place = SavedPlace(latitude: lat, longitude: lng, label: label);
    }
    _method = CalculationMethod.values.firstWhere(
      (m) => m.name == v[_Keys.method],
      orElse: () => _method,
    );
    _madhab = Madhab.values.firstWhere(
      (m) => m.name == v[_Keys.madhab],
      orElse: () => _madhab,
    );
    for (final p in dailyPrayers) {
      final o = v[_Keys.offset(p)];
      if (o is int) _offsets[p] = o;
    }
    _notifications = v[_Keys.notifications] == true;
    notifyListeners();
    _scheduleAlertSync(immediately: true);
  }

  Future<void> setPlace(SavedPlace place) async {
    _place = place;
    notifyListeners();
    await Future.wait([
      _store.save(_Keys.lat, place.latitude),
      _store.save(_Keys.lng, place.longitude),
      _store.save(_Keys.label, place.label),
    ]);
    _scheduleAlertSync();
  }

  Future<void> setMethod(CalculationMethod method) async {
    _method = method;
    notifyListeners();
    await _store.save(_Keys.method, method.name);
    _scheduleAlertSync();
  }

  Future<void> setMadhab(Madhab madhab) async {
    _madhab = madhab;
    notifyListeners();
    await _store.save(_Keys.madhab, madhab.name);
    _scheduleAlertSync();
  }

  static const maxOffset = 30;

  Future<void> adjustOffset(Prayer prayer, int delta) async {
    final value = ((_offsets[prayer] ?? 0) + delta).clamp(
      -maxOffset,
      maxOffset,
    );
    if (value == _offsets[prayer]) return;
    _offsets[prayer] = value;
    notifyListeners();
    await _store.save(_Keys.offset(prayer), value);
    _scheduleAlertSync();
  }

  /// Turns alerts on or off; returns false if permission was refused.
  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled && !(await _alerts?.requestPermission() ?? false)) {
      return false;
    }
    _notifications = enabled;
    notifyListeners();
    await _store.save(_Keys.notifications, enabled);
    _scheduleAlertSync(immediately: true);
    return true;
  }

  /// Re-plans alerts, e.g. when the app returns to the foreground on a
  /// later day.
  void refresh() {
    notifyListeners();
    _scheduleAlertSync(immediately: true);
  }

  // Offsets are tapped in quick succession; replan once they settle.
  void _scheduleAlertSync({bool immediately = false}) {
    _alertSync?.cancel();
    _alertSync = Timer(
      immediately ? Duration.zero : const Duration(milliseconds: 800),
      _syncAlerts,
    );
  }

  Future<void> _syncAlerts() async {
    final alerts = _alerts;
    if (alerts == null) return;
    final inputs = this.inputs;
    if (!_notifications || inputs == null) {
      await alerts.cancelAll();
      return;
    }
    await alerts.schedule(upcomingAlerts(clock(), inputs), _place!.label);
  }

  @override
  void dispose() {
    _alertSync?.cancel();
    super.dispose();
  }
}

abstract final class _Keys {
  static const lat = 'place.latitude';
  static const lng = 'place.longitude';
  static const label = 'place.label';
  static const method = 'calculation.method';
  static const madhab = 'calculation.madhab';
  static const notifications = 'alerts.enabled';
  static String offset(Prayer p) => 'offset.${p.name}';
}

/// Gives widgets access to the [AppState] and rebuilds them when it changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// For callbacks: reads the state without subscribing to changes.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
