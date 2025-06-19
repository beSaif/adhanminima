// ignore_for_file: file_names

import 'dart:async';
import 'dart:math' show pi, sin, cos;
import 'dart:ui';

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
  static const double alignmentThreshold = 4.0; // degrees, fixed for production
  bool wasAligned = false;
  double? qiblaBearing;
  String? locationError;
  bool _isLoading = false;
  bool _calibrationSheetShown = false;

  @override
  void initState() {
    super.initState();
    _getLocationAndQibla();
  }

  Future<void> _getLocationAndQibla() async {
    setState(() {
      _isLoading = true;
      locationError = null;
    });
    try {
      Position? pos = await Geolocator.getLastKnownPosition();
      if (pos == null) {
        debugPrint(
            'No last known position found, requesting current position...');
        pos = await Geolocator.getCurrentPosition();
      } else {
        debugPrint(
            'Using last known position: ${pos.latitude}, ${pos.longitude}');
        // Update with current position in background
        Geolocator.getCurrentPosition().then((freshPos) {
          if (mounted) {
            debugPrint(
                'Updated position in background: ${freshPos.latitude}, ${freshPos.longitude}');
            final bearing = calculateQiblaBearing(
                freshPos.latitude, freshPos.longitude, 21.4225, 39.8262);
            setState(() {
              qiblaBearing = bearing;
            });
          }
        });
      }
      // Kaaba coordinates
      const double kaabaLat = 21.4225;
      const double kaabaLon = 39.8262;
      final bearing = calculateQiblaBearing(
          pos.latitude, pos.longitude, kaabaLat, kaabaLon);
      setState(() {
        qiblaBearing = bearing;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        locationError =
            'Location unavailable. Please enable location and retry.';
        _isLoading = false;
      });
    }
  }

  void _showCalibrationSheet() {
    if (_calibrationSheetShown) return;
    _calibrationSheetShown = true;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.compass_calibration,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Compass needs calibration',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Move your phone in a figure-8 motion to calibrate the compass.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                    child: const Text(
                      "Dismiss",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _calibrationSheetShown = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _calibrationSheetShown = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always use high contrast colors
    const Color arrowGray = Colors.white;
    const Color arrowGreen = Color(0xFF21C262); // Modern emerald green
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (locationError != null) {
      return LocationErrorWidget(
        error: locationError!,
        callback: _getLocationAndQibla,
      );
    }
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
            event.accuracy != null && event.accuracy! > 30.0;
        debugPrint('Accuracy: ${event.accuracy}, '
            'needs calibration: $needsCalibration');
        if (needsCalibration && !_calibrationSheetShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showCalibrationSheet();
          });
        }
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
                        // Dot on circular path (moves according to qiblaOffset)
                        _QiblaDot(
                          qiblaOffset: qiblahOffset,
                          // 90% width of the screen
                          radius: MediaQuery.of(context).size.width * 0.45,
                          aligned: aligned,
                        ),
                        // Arrow always points up (no rotation)
                        Icon(
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
            // if (needsCalibration)
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.location_off,
                      size: 64,
                      // color: Color(0xffb00020),
                      color: Color(0xffb00020),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    error,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      foregroundColor: const Color(0xffb00020),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: callback,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
