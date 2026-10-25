import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../prayer/prayer_schedule.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'fill_scroll.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final snapshot = state.snapshot();
    final place = state.place;
    if (snapshot == null || place == null) return const SizedBox.shrink();
    final now = state.clock();
    final next = snapshot.next;
    final hijri = HijriCalendar.fromDate(now);

    return FillScroll(
      padding: screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.text,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  place.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Text(
                shortDate(now),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const Spacer(flex: 3),
          Text(
            '${next.prayer.label} in',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.secondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: 'Time until ${next.prayer.label}',
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatCountdown(next.time.difference(now)),
                style: const TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2.3,
                  height: 1,
                  fontFeatures: tabularFigures,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Dot(),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${snapshot.isTomorrowFor(now) ? 'tomorrow at' : 'at'} '
                  '${formatClock(next.time)} · '
                  '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(flex: 3),
          for (final (i, p) in snapshot.prayers.indexed)
            _PrayerRow(
              prayer: p,
              status: p.prayer == next.prayer && p.time == next.time
                  ? _Status.next
                  : p.time.isAfter(now)
                  ? _Status.later
                  : _Status.past,
              divider: i < snapshot.prayers.length - 1,
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

enum _Status { past, next, later }

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.status,
    required this.divider,
  });

  final PrayerTime prayer;
  final _Status status;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 19,
      fontWeight: status == _Status.next ? FontWeight.w600 : FontWeight.w300,
      color: switch (status) {
        _Status.past => AppColors.past,
        _Status.next => Colors.white,
        _Status.later => AppColors.upcoming,
      },
      fontFeatures: tabularFigures,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppColors.divider))
            : null,
      ),
      child: Row(
        children: [
          if (status == _Status.next) ...[
            const _Dot(),
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(prayer.prayer.label, style: style)),
          Text(formatClock(prayer.time), style: style),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// e.g. "Sun 25 Oct".
String shortDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
