import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geomag/geomag.dart';

/// One compass reading, in degrees clockwise from true north.
class Heading {
  const Heading(this.degrees, {this.accuracy});

  final double degrees;

  /// Estimated error in degrees, when the platform reports it.
  final double? accuracy;

  /// Android only reports coarse buckets (15/30/45), iOS reports degrees.
  bool get needsCalibration => (accuracy ?? 0) >= 45;
}

sealed class CompassReading {}

class CompassWaiting extends CompassReading {}

class CompassUnavailable extends CompassReading {}

class CompassHeading extends CompassReading {
  CompassHeading(this.heading);

  final Heading heading;
}

class CompassService {
  /// Readings for a phone at ([latitude], [longitude]).
  ///
  /// iOS already reports true north; Android reports magnetic north, so the
  /// local declination from the World Magnetic Model is added there.
  Stream<CompassReading> readings(double latitude, double longitude) async* {
    final events = FlutterCompass.events;
    if (events == null) {
      yield CompassUnavailable();
      return;
    }
    yield CompassWaiting();
    final declination = defaultTargetPlatform == TargetPlatform.android
        ? GeoMag().calculate(latitude, longitude, 0, DateTime.now()).dec
        : 0.0;
    try {
      await for (final e in events) {
        final heading = e.heading;
        if (heading == null) {
          yield CompassUnavailable();
        } else if (heading >= 0 ||
            defaultTargetPlatform == TargetPlatform.android) {
          // iOS sends a negative true heading until it has a location fix.
          yield CompassHeading(
            Heading(
              (heading + declination) % 360,
              accuracy: (e.accuracy ?? -1) < 0 ? null : e.accuracy,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Compass unavailable: $e');
      yield CompassUnavailable();
    }
  }
}
