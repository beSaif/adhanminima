import 'package:adhan/adhan.dart';
import 'package:adhanminima/prayer/prayer_schedule.dart';
import 'package:adhanminima/state/app_state.dart';
import 'package:adhanminima/state/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAlerts implements PrayerAlerts {
  FakeAlerts({this.granted = true});

  bool granted;
  List<PrayerTime>? scheduled;
  int cancels = 0;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<void> schedule(List<PrayerTime> prayers, String placeLabel) async =>
      scheduled = prayers;

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = null;
  }
}

const geneva = SavedPlace(
  latitude: 46.2044,
  longitude: 6.1432,
  label: 'Geneva, CH',
);

Future<void> settle() => Future<void>.delayed(const Duration(seconds: 1));

void main() {
  test('settings survive a reload', () async {
    final store = MemorySettingsStore();
    final a = AppState(store: store);
    await a.setPlace(geneva);
    await a.setMethod(CalculationMethod.muslim_world_league);
    await a.setMadhab(Madhab.hanafi);
    await a.adjustOffset(Prayer.maghrib, 3);

    final b = AppState(store: store);
    await b.load();
    expect(b.place?.label, 'Geneva, CH');
    expect(b.method, CalculationMethod.muslim_world_league);
    expect(b.madhab, Madhab.hanafi);
    expect(b.offsets[Prayer.maghrib], 3);
    expect(b.offsets[Prayer.fajr], 0);
  });

  test('no place means no schedule', () async {
    final s = AppState(store: MemorySettingsStore());
    await s.load();
    expect(s.place, isNull);
    expect(s.snapshot(), isNull);
  });

  test('offsets are clamped to ±30 minutes', () async {
    final s = AppState(store: MemorySettingsStore());
    for (var i = 0; i < 40; i++) {
      await s.adjustOffset(Prayer.isha, 1);
    }
    expect(s.offsets[Prayer.isha], AppState.maxOffset);
  });

  test('alerts are scheduled once enabled and cleared when disabled', () async {
    final alerts = FakeAlerts();
    final s = AppState(store: MemorySettingsStore(), alerts: alerts);
    await s.setPlace(geneva);
    expect(await s.setNotificationsEnabled(true), isTrue);
    await settle();
    expect(alerts.scheduled, isNotEmpty);
    expect(alerts.scheduled!.any((p) => p.prayer == Prayer.sunrise), isFalse);

    await s.setNotificationsEnabled(false);
    await settle();
    expect(alerts.scheduled, isNull);
  });

  test('refused permission leaves alerts off', () async {
    final alerts = FakeAlerts(granted: false);
    final s = AppState(store: MemorySettingsStore(), alerts: alerts);
    await s.setPlace(geneva);
    expect(await s.setNotificationsEnabled(true), isFalse);
    expect(s.notificationsEnabled, isFalse);
  });
}
