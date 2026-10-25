import 'dart:async';

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
  CompassService({
    this.events,
    this.firstReadingTimeout = const Duration(seconds: 5),
  });

  /// Compass events to read instead of the platform's, e.g. in tests.
  final Stream<CompassEvent>? events;

  /// How long to wait for the first usable heading before treating the
  /// device as having no compass. iOS simulators never send one.
  final Duration firstReadingTimeout;

  /// Readings for a phone at ([latitude], [longitude]).
  ///
  /// iOS already reports true north; Android reports magnetic north, so the
  /// local declination from the World Magnetic Model is added there.
  Stream<CompassReading> readings(double latitude, double longitude) async* {
    final source = events ?? FlutterCompass.events;
    if (source == null) {
      yield CompassUnavailable();
      return;
    }
    yield CompassWaiting();
    final declination = defaultTargetPlatform == TargetPlatform.android
        ? GeoMag().calculate(latitude, longitude, 0, DateTime.now()).dec
        : 0.0;
    // Only the first heading is time-limited: a phone lying still can go
    // quiet for a long time once it has reported.
    var heard = false;
    final guarded = source.timeout(
      firstReadingTimeout,
      onTimeout: (sink) {
        if (!heard) {
          sink.addError(TimeoutException('No compass heading'));
        }
      },
    );
    try {
      await for (final e in guarded) {
        final heading = e.heading;
        if (heading == null) {
          yield CompassUnavailable();
        } else if (heading >= 0 ||
            defaultTargetPlatform == TargetPlatform.android) {
          // iOS sends a negative true heading until it has a location fix.
          heard = true;
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
