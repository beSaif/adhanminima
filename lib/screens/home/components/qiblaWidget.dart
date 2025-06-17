// ignore_for_file: file_names

import 'dart:async';
import 'dart:math' show pi, sin, cos;

import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhanminima/utils/qibla_bearing.dart';

class QiblahCompass extends StatefulWidget {
  const QiblahCompass({Key? key}) : super(key: key);

  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass>
    with AutomaticKeepAliveClientMixin<QiblahCompass> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure this is called to keep the state
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: QiblahCompassWidget(),
    );
  }
}

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({Key? key}) : super(key: key);

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  static const double alignmentThreshold = 3.0; // degrees, fixed for production
  bool wasAligned = false;
  double? qiblaBearing;

  @override
  void initState() {
    super.initState();
    _getLocationAndQibla();
  }

  Future<void> _getLocationAndQibla() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      // Kaaba coordinates
      const double kaabaLat = 21.4225;
      const double kaabaLon = 39.8262;
      final bearing = calculateQiblaBearing(
          pos.latitude, pos.longitude, kaabaLat, kaabaLon);
      setState(() {
        qiblaBearing = bearing;
      });
    } catch (e) {
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always use high contrast colors
    const Color arrowGray = Colors.white;
    const Color arrowGreen = Color(0xFF21C262); // Modern emerald green
    if (qiblaBearing == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.heading == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final CompassEvent event = snapshot.data!;
        final double heading = event.heading!;
        double qiblahOffset = qiblaBearing! - heading;
        if (qiblahOffset > 180) qiblahOffset -= 360;
        if (qiblahOffset < -180) qiblahOffset += 360;
        final bool aligned = qiblahOffset.abs() <= alignmentThreshold;
        if (aligned && !wasAligned) {
          _triggerFeedback();
        }
        wasAligned = aligned;
        final bool needsCalibration =
            event.accuracy != null && event.accuracy! <= 1;
        return Stack(
          children: [
            // Main compass UI
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dot on circular path
                        _QiblaDot(
                          qiblaOffset: -qiblahOffset,
                          // 90% width of the screen
                          radius: MediaQuery.of(context).size.width * 0.45,
                          aligned: aligned,
                        ),
                        Transform.rotate(
                          angle: -qiblahOffset * (pi / 180),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            size: 160,
                            color: aligned ? arrowGreen : arrowGray,
                            shadows: aligned
                                ? [
                                    const Shadow(
                                        color: Colors.black, blurRadius: 16)
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    key: ValueKey(aligned),
                    duration: const Duration(milliseconds: 300),
                    child: aligned
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon(Icons.check_circle,
                              //     color: arrowGreen, size: 32),
                              // SizedBox(width: 8),
                              Text('Ma Sha Allah!',
                                  style: cusTextStyle(
                                    28,
                                    FontWeight.bold,
                                    arrowGreen,
                                  )),
                            ],
                          )
                        : Text(
                            '${qiblahOffset.abs().toStringAsFixed(1)}° off',
                            style: cusTextStyle(
                              28,
                              FontWeight.w500,
                              arrowGray,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Removed _buildSettings(context)
                ],
              ),
            ),
            if (needsCalibration)
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: _PulseCalibrationPrompt(),
              ),
          ],
        );
      },
    );
  }

  void _triggerFeedback() async {
    try {
      Feedback.forTap(context);
      await HapticFeedback.mediumImpact();
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}

class SpinningNeedle extends StatefulWidget {
  const SpinningNeedle({Key? key}) : super(key: key);

  @override
  _SpinningNeedleState createState() => _SpinningNeedleState();
}

class _SpinningNeedleState extends State<SpinningNeedle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -_controller.value * 2.0 * pi,
                  child: Image.asset(
                    'assets/compass.png',
                    color: Colors.white,
                    height: 250,
                  ),
                ),
                Transform.rotate(
                  angle: _controller.value * 2.0 * pi,
                  child: Image.asset(
                    'assets/needle.png',
                    height: 240,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }
}

class LocationErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? callback;

  const LocationErrorWidget({Key? key, required this.error, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xffb00020);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off,
            size: 150,
            color: errorColor,
          ),
          const SizedBox(height: 32),
          Text(
            error,
            style:
                const TextStyle(color: errorColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: const Text("Retry"),
            onPressed: callback,
          ),
        ],
      ),
    );
  }
}

class _PulseCalibrationPrompt extends StatefulWidget {
  @override
  State<_PulseCalibrationPrompt> createState() =>
      _PulseCalibrationPromptState();
}

class _PulseCalibrationPromptState extends State<_PulseCalibrationPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: false);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _visible = false;
          _controller.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double bgScale = 1.0 + 0.4 * _controller.value;
        final double bgOpacity = 1.0 - _controller.value;
        final double iconScale = 1.0 + 0.2 * _controller.value;
        final double iconOpacity = 0.7 + 0.3 * (1.0 - _controller.value);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: bgOpacity,
                    child: Transform.scale(
                      scale: bgScale,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: iconScale,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: Icon(
                        Icons.screen_rotation,
                        color: Colors.orange.shade200,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Compass accuracy is low. Please calibrate by moving your phone in a figure-8 motion.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dot widget (stateless, instant update)
class _QiblaDot extends StatelessWidget {
  final double qiblaOffset; // in degrees
  final double radius;
  final bool aligned;
  const _QiblaDot(
      {required this.qiblaOffset, required this.radius, required this.aligned});

  @override
  Widget build(BuildContext context) {
    final double angleRad = (qiblaOffset) * (pi / 180);
    final double dx = radius * -sin(angleRad);
    final double dy = radius * -cos(angleRad);
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
          border: Border.all(
            color: aligned ? const Color(0xFF21C262) : Colors.white,
            width: 3,
          ),
        ),
      ),
    );
  }
}
