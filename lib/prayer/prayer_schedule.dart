import 'package:adhan/adhan.dart';

/// The six daily times the app shows, in order.
const dailyPrayers = [
  Prayer.fajr,
  Prayer.sunrise,
  Prayer.dhuhr,
  Prayer.asr,
  Prayer.maghrib,
  Prayer.isha,
];

extension PrayerLabel on Prayer {
  String get label => switch (this) {
    Prayer.fajr => 'Fajr',
    Prayer.sunrise => 'Sunrise',
    Prayer.dhuhr => 'Dhuhr',
    Prayer.asr => 'Asr',
    Prayer.maghrib => 'Maghrib',
    Prayer.isha => 'Isha',
    Prayer.none => '',
  };
}

class PrayerTime {
  const PrayerTime(this.prayer, this.time);

  final Prayer prayer;
  final DateTime time;
}

/// What the calculation depends on, besides the date.
class ScheduleInputs {
  const ScheduleInputs({
    required this.coordinates,
    required this.method,
    required this.madhab,
    required this.offsets,
  });

  final Coordinates coordinates;
  final CalculationMethod method;
  final Madhab madhab;

  /// Minutes added to each prayer after calculation.
  final Map<Prayer, int> offsets;

  CalculationParameters get parameters =>
      method.getParameters()..madhab = madhab;
}

/// The six times for the calendar day of [day], offsets applied.
List<PrayerTime> prayersOn(DateTime day, ScheduleInputs inputs) {
  final times = PrayerTimes(
    inputs.coordinates,
    DateComponents(day.year, day.month, day.day),
    inputs.parameters,
  );
  return [
    for (final prayer in dailyPrayers)
      PrayerTime(
        prayer,
        times
            .timeForPrayer(prayer)!
            .add(Duration(minutes: inputs.offsets[prayer] ?? 0)),
      ),
  ];
}

/// The day the app should be showing at [now]: today, or tomorrow once
/// Isha has passed, so there is always an upcoming time.
class DaySnapshot {
  DaySnapshot._(this.prayers, this.next);

  factory DaySnapshot.at(DateTime now, ScheduleInputs inputs) {
    final today = prayersOn(now, inputs);
    for (final p in today) {
      if (p.time.isAfter(now)) return DaySnapshot._(today, p);
    }
    final tomorrow = prayersOn(
      DateTime(now.year, now.month, now.day + 1),
      inputs,
    );
    return DaySnapshot._(tomorrow, tomorrow.first);
  }

  final List<PrayerTime> prayers;
  final PrayerTime next;

  /// Whether these are the next calendar day's times relative to [now].
  bool isTomorrowFor(DateTime now) => prayers.first.time.day != now.day;
}

/// Every alert-worthy time (sunrise excluded) after [now] for [days] days.
List<PrayerTime> upcomingAlerts(
  DateTime now,
  ScheduleInputs inputs, {
  int days = 7,
}) {
  return [
    for (var i = 0; i < days; i++)
      ...prayersOn(
        DateTime(now.year, now.month, now.day + i),
        inputs,
      ).where((p) => p.prayer != Prayer.sunrise && p.time.isAfter(now)),
  ];
}

/// 1:37:42 style countdown.
String formatCountdown(Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// 24-hour clock time, e.g. 05:41.
String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
