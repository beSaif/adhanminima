// ignore_for_file: file_names

import 'dart:async';
import 'dart:math' show pi;

import 'package:adhanminima/utils/sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

class QiblahCompass extends StatefulWidget {
  const QiblahCompass({Key? key}) : super(key: key);

  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass>
    with AutomaticKeepAliveClientMixin<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure this is called to keep the state
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<LocationStatus>(
        stream: _locationStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SpinningNeedle();
          }

          final locationStatus = snapshot.data;

          if (locationStatus == null || !locationStatus.enabled) {
            return LocationErrorWidget(
              error: "Please enable Location service",
              callback: _checkLocationStatus,
            );
          }

          switch (locationStatus.status) {
            case LocationPermission.always:
            case LocationPermission.whileInUse:
              return const QiblahCompassWidget();
            case LocationPermission.denied:
              return LocationErrorWidget(
                error: "Location service permission denied",
                callback: _checkLocationStatus,
              );
            case LocationPermission.deniedForever:
              return LocationErrorWidget(
                error: "Location service denied forever!",
                callback: _checkLocationStatus,
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    debugPrint("Loc: Location status: ${locationStatus.status}");
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      debugPrint("Loc: Location permission denied");
      await FlutterQiblah.requestPermissions();
    }
    _locationStreamController.sink
        .add(await FlutterQiblah.checkLocationStatus());
  }
}

class QiblahCompassWidget extends StatelessWidget {
  const QiblahCompassWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SpinningNeedle();
        }

        final qiblahDirection = snapshot.data;

        if (qiblahDirection == null) {
          return const SizedBox();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -qiblahDirection.direction * (pi / 180),
                  child: SvgPicture.asset(
                    'assets/compass.svg',
                    height: 250,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -qiblahDirection.qiblah * (pi / 180),
                  child: SvgPicture.asset(
                    'assets/needle.svg',
                    height: 240,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ],
            ),
            verticalBox(25),
            Text("${qiblahDirection.offset.toStringAsFixed(3)}°",
                style: const TextStyle(color: Colors.white, fontSize: 24)),
          ],
        );
      },
    );
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
                  child: SvgPicture.asset(
                    'assets/compass.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    height: 250,
                  ),
                ),
                Transform.rotate(
                  angle: _controller.value * 2.0 * pi,
                  child: SvgPicture.asset(
                    'assets/needle.svg',
                    height: 240,
                  ),
                ),
              ],
            ),
            verticalBox(50),
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
