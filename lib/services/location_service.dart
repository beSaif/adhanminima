import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../state/app_state.dart';

/// Why the device location could not be read, in words for the user.
class LocationFailure implements Exception {
  const LocationFailure(this.message, {this.canOpenSettings = false});

  final String message;

  /// True when the fix is in system settings (permission or GPS off).
  final bool canOpenSettings;
}

class LocationService {
  Geocoding? _geocoding;
  Geocoding get _geocoder => _geocoding ??= Geocoding();

  /// The device's position, named after the nearest locality.
  Future<SavedPlace> currentPlace() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(
        'Location is turned off. Turn it on in system settings, or choose a city.',
        canOpenSettings: true,
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        'Location permission was denied. You can choose a city instead.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Location access is blocked for Adhaan. Allow it in system settings, or choose a city.',
        canOpenSettings: true,
      );
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) {
        throw const LocationFailure(
          'Could not get a location fix. Try again outdoors, or choose a city.',
        );
      }
      position = last;
    }
    return SavedPlace(
      latitude: position.latitude,
      longitude: position.longitude,
      label: await _labelFor(position.latitude, position.longitude),
    );
  }

  /// Places matching a city or address typed by the user.
  Future<List<SavedPlace>> search(String query) async {
    final List<Location> locations;
    try {
      locations = await _geocoder.locationFromAddress(query);
    } on PlatformException catch (e) {
      // iOS reports "no result" as an error; Android returns an empty list.
      debugPrint('Geocoding "$query" failed: $e');
      return const [];
    }
    final results = <SavedPlace>[];
    final seen = <String>{};
    for (final l in locations.take(5)) {
      final label = await _labelFor(l.latitude, l.longitude);
      if (seen.add(label)) {
        results.add(
          SavedPlace(
            latitude: l.latitude,
            longitude: l.longitude,
            label: label,
          ),
        );
      }
    }
    return results;
  }

  Future<String> _labelFor(double lat, double lng) async {
    try {
      final marks = await _geocoder.placemarkFromCoordinates(lat, lng);
      if (marks.isNotEmpty) {
        final label = placeLabel(marks.first);
        if (label != null) return label;
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
    return '${lat.toStringAsFixed(2)}°, ${lng.toStringAsFixed(2)}°';
  }
}

/// "Geneva, CH" from a placemark, or null if it has no usable name.
@visibleForTesting
String? placeLabel(Placemark p) {
  final city = [
    p.locality,
    p.subAdministrativeArea,
    p.administrativeArea,
    p.name,
  ].firstWhere((s) => s != null && s.trim().isNotEmpty, orElse: () => null);
  if (city == null) return null;
  final country = p.isoCountryCode;
  return country == null || country.isEmpty ? city : '$city, $country';
}
