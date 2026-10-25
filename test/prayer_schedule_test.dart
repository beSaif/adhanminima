import 'package:adhan/adhan.dart';
import 'package:adhanminima/prayer/prayer_schedule.dart';
import 'package:adhanminima/prayer/qibla.dart';
import 'package:flutter_test/flutter_test.dart';

final geneva = Coordinates(46.2044, 6.1432);

ScheduleInputs inputs({Map<Prayer, int> offsets = const {}}) => ScheduleInputs(
  coordinates: geneva,
  method: CalculationMethod.karachi,
  madhab: Madhab.shafi,
  offsets: offsets,
);

void main() {
  final day = DateTime(2026, 10, 25, 9);

  test('six times in order, Dhuhr near solar noon in Geneva', () {
    final times = prayersOn(day, inputs());
    expect(times.map((p) => p.prayer), dailyPrayers);
    for (var i = 1; i < times.length; i++) {
      expect(times[i].time.isAfter(times[i - 1].time), isTrue);
    }
    // Solar noon in Geneva on 25 Oct is about 11:19 UTC; Karachi adds 1 min.
    final dhuhr = times[2].time.toUtc();
    expect(dhuhr.hour, 11);
    expect(dhuhr.minute, inInclusiveRange(17, 23));
  });

  test('offsets shift each time by whole minutes', () {
    final base = prayersOn(day, inputs());
    final shifted = prayersOn(
      day,
      inputs(offsets: {Prayer.maghrib: 3, Prayer.fajr: -2}),
    );
    expect(
      shifted[4].time.difference(base[4].time),
      const Duration(minutes: 3),
    );
    expect(
      shifted[0].time.difference(base[0].time),
      const Duration(minutes: -2),
    );
    expect(shifted[3].time, base[3].time);
  });

  test('next prayer is the first one still ahead', () {
    final today = prayersOn(day, inputs());
    final afterDhuhr = today[2].time.add(const Duration(minutes: 1));
    final snap = DaySnapshot.at(afterDhuhr, inputs());
    expect(snap.next.prayer, Prayer.asr);
    expect(snap.isTomorrowFor(afterDhuhr), isFalse);
  });

  test('after Isha the next prayer is tomorrow’s Fajr', () {
    final today = prayersOn(day, inputs());
    final late = today.last.time.add(const Duration(minutes: 5));
    final snap = DaySnapshot.at(late, inputs());
    expect(snap.next.prayer, Prayer.fajr);
    expect(snap.next.time.day, 26);
    expect(snap.isTomorrowFor(late), isTrue);
  });

  test('alerts skip sunrise and past times, and cover several days', () {
    final today = prayersOn(day, inputs());
    final now = today[3].time; // exactly Asr: Asr itself is not upcoming
    final alerts = upcomingAlerts(now, inputs(), days: 2);
    expect(alerts.any((p) => p.prayer == Prayer.sunrise), isFalse);
    expect(alerts.every((p) => p.time.isAfter(now)), isTrue);
    expect(alerts.map((p) => p.prayer).take(2), [Prayer.maghrib, Prayer.isha]);
    expect(alerts, hasLength(2 + 5));
  });

  test('countdown and clock formatting', () {
    expect(
      formatCountdown(const Duration(hours: 1, minutes: 37, seconds: 42)),
      '1:37:42',
    );
    expect(formatCountdown(const Duration(seconds: -5)), '0:00:00');
    expect(formatClock(DateTime(2026, 1, 1, 5, 7)), '05:07');
  });

  group('qibla', () {
    test('bearing from Geneva is about 121° ESE', () {
      final b = qiblaBearing(geneva);
      expect(b, closeTo(120.7, 1));
      expect(compassPoint(b), 'ESE');
    });

    test('turn direction wraps around north', () {
      expect(turnBetween(109, 121), closeTo(12, 1e-9));
      expect(turnBetween(350, 10), closeTo(20, 1e-9));
      expect(turnBetween(10, 350), closeTo(-20, 1e-9));
      expect(turnBetween(0, 180), 180);
    });
  });
}
