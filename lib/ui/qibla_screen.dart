import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../prayer/qibla.dart';
import '../services/compass_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'fill_scroll.dart';

/// Within this many degrees the phone counts as facing the Qibla.
const alignmentTolerance = 3.0;

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key, required this.active, this.compass});

  /// Whether the tab is on screen; the compass only runs while it is.
  final bool active;
  final CompassService? compass;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late final CompassService _compass = widget.compass ?? CompassService();
  StreamSubscription<CompassReading>? _sub;
  CompassReading _reading = CompassWaiting();
  SavedPlace? _listeningFor;
  bool _wasAligned = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSubscription();
  }

  @override
  void didUpdateWidget(QiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSubscription();
  }

  void _syncSubscription() {
    final place = AppScope.of(context).place;
    if (!widget.active || place == null) {
      _sub?.cancel();
      _sub = null;
      _listeningFor = null;
      return;
    }
    if (_sub != null && identical(place, _listeningFor)) return;
    _sub?.cancel();
    _listeningFor = place;
    final bearing = qiblaBearing(place.coordinates);
    _sub = _compass.readings(place.latitude, place.longitude).listen((r) {
      final aligned =
          r is CompassHeading &&
          turnBetween(r.heading.degrees, bearing).abs() <= alignmentTolerance;
      if (aligned && !_wasAligned) HapticFeedback.mediumImpact();
      _wasAligned = aligned;
      setState(() => _reading = r);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = AppScope.of(context).place;
    if (place == null) return const SizedBox.shrink();
    final bearing = qiblaBearing(place.coordinates);
    final city = place.label.split(',').first;

    final reading = _reading;
    final turn = reading is CompassHeading
        ? turnBetween(reading.heading.degrees, bearing)
        : null;
    final aligned = turn != null && turn.abs() <= alignmentTolerance;

    return FillScroll(
      padding: screenPadding,
      child: Column(
        children: [
          Row(
            children: [
              const Text('Qibla', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${bearing.round()}° ${compassPoint(bearing)} from $city',
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
          if (reading is CompassUnavailable)
            _NoCompass(bearing: bearing, city: city)
          else ...[
            Builder(
              builder: (context) {
                final size = math.min(
                  300.0,
                  MediaQuery.sizeOf(context).width - screenPadding.horizontal,
                );
                return Semantics(
                  label: turn == null
                      ? 'Compass waiting for a reading'
                      : aligned
                      ? 'Facing the Qibla'
                      : 'Qibla is ${turn.abs().round()} degrees to the '
                            '${turn > 0 ? 'right' : 'left'}',
                  child: SizedBox.square(
                    dimension: size,
                    child: CustomPaint(
                      painter: _DialPainter(turn: turn, aligned: aligned),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ExcludeSemantics(
              child: Text(
                turn == null ? '—' : '${turn.abs().round()}°',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -1.3,
                  height: 1,
                  color: aligned ? AppColors.accent : AppColors.text,
                  fontFeatures: tabularFigures,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              switch (turn) {
                null => 'Waiting for the compass…',
                _ when aligned => 'You are facing the Qibla',
                final t when t > 0 => 'Turn slowly to the right',
                _ => 'Turn slowly to the left',
              },
              style: TextStyle(
                fontSize: 15,
                color: aligned ? AppColors.accent : AppColors.tertiary,
              ),
            ),
          ],
          const Spacer(),
          if (reading is! CompassUnavailable)
            OutlinedButton.icon(
              onPressed: () => _showCalibration(context),
              icon: const Icon(Icons.screen_rotation_alt_rounded, size: 16),
              label: Text(
                reading is CompassHeading && reading.heading.needsCalibration
                    ? 'Low accuracy · Calibrate'
                    : 'Calibrate compass',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.tertiary,
                side: const BorderSide(color: AppColors.outline),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: 'InterTight',
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCalibration(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(28, 4, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calibrate the compass',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 12),
            Text(
              'Wave your phone in a slow figure-8 a few times, tilting it as '
              'you go. Keep away from metal, magnets and other electronics, '
              'then hold the phone flat.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCompass extends StatelessWidget {
  const _NoCompass({required this.bearing, required this.city});

  final double bearing;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${bearing.round()}°',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            height: 1,
            fontFeatures: tabularFigures,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This device has no compass. From $city, the Qibla is '
          '${bearing.round()}° ${compassPoint(bearing)}, measured clockwise '
          'from true north.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.tertiary,
          ),
        ),
      ],
    );
  }
}

/// Fixed arrow for the phone's direction and a marker on the ring for the
/// Qibla, [turn] degrees clockwise from the arrow.
class _DialPainter extends CustomPainter {
  _DialPainter({required this.turn, required this.aligned});

  final double? turn;
  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    final c = size.center(Offset.zero);
    final r = 140 * s;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.outline,
    );
    final tick = Paint()..color = AppColors.tick;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final dir = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(c + dir * r, c + dir * (r - 12 * s), tick);
    }

    final arrow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = aligned ? AppColors.accent : AppColors.text;
    final tip = c + Offset(0, -80 * s);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy + 64 * s)
        ..lineTo(tip.dx, tip.dy)
        ..moveTo(tip.dx - 24 * s, tip.dy + 28 * s)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + 24 * s, tip.dy + 28 * s),
      arrow,
    );

    final t = turn;
    if (t == null) return;
    final a = t * math.pi / 180;
    final marker = c + Offset(math.sin(a), -math.cos(a)) * (r - 3 * s);
    canvas.drawCircle(marker, 9 * s, Paint()..color = AppColors.background);
    canvas.drawCircle(
      marker,
      9 * s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s
        ..color = AppColors.accent,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.turn != turn || old.aligned != aligned;
}
