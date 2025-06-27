import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationController extends GetxController {
  // Reactive variables
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final Rx<Position?> _lastKnownPosition = Rx<Position?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final Rx<Placemark?> _currentPlacemark = Rx<Placemark?>(null);
  final RxBool _hasLocationPermission = false.obs;

  // Cache management
  DateTime? _lastFetchTime;
  DateTime? _lastPlacemarkFetchTime;
  static const Duration _locationCacheValidDuration = Duration(minutes: 10);
  static const Duration _placemarkCacheValidDuration = Duration(hours: 1);
  static const double _significantDistanceThreshold = 100.0; // meters

  // SharedPreferences keys
  static const String _lastPositionLatKey = 'last_position_lat';
  static const String _lastPositionLngKey = 'last_position_lng';
  static const String _lastPositionTimeKey = 'last_position_time';
  static const String _lastPlacemarkKey = 'last_placemark';
  static const String _lastPlacemarkTimeKey = 'last_placemark_time';

  // Getters for reactive access
  Position? get currentPosition => _currentPosition.value;
  Position? get lastKnownPosition => _lastKnownPosition.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  Placemark? get currentPlacemark => _currentPlacemark.value;
  bool get hasLocationPermission => _hasLocationPermission.value;

  // Reactive getters for UI binding
  Rx<Position?> get currentPositionRx => _currentPosition;
  Rx<Position?> get lastKnownPositionRx => _lastKnownPosition;
  RxBool get isLoadingRx => _isLoading;
  RxString get errorRx => _error;
  Rx<Placemark?> get currentPlacemarkRx => _currentPlacemark;

  @override
  void onInit() {
    super.onInit();
    _initializeFromCache();
  }

  /// Initialize location data from cache on app startup
  Future<void> _initializeFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore last known position from cache
      final lat = prefs.getDouble(_lastPositionLatKey);
      final lng = prefs.getDouble(_lastPositionLngKey);
      final timeStamp = prefs.getString(_lastPositionTimeKey);

      if (lat != null && lng != null && timeStamp != null) {
        final cachedTime = DateTime.parse(timeStamp);
        final cachedPosition = Position(
          latitude: lat,
          longitude: lng,
          timestamp: cachedTime,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        _lastKnownPosition.value = cachedPosition;
        _currentPosition.value = cachedPosition;
        _lastFetchTime = cachedTime;

        debugPrint('LocationController: Restored cached position: $lat, $lng');
      }

      // Restore placemark from cache
      final cachedPlacemark = prefs.getString(_lastPlacemarkKey);
      final placemarkTime = prefs.getString(_lastPlacemarkTimeKey);

      if (cachedPlacemark != null && placemarkTime != null) {
        _lastPlacemarkFetchTime = DateTime.parse(placemarkTime);
        // Note: We'd need to implement Placemark serialization for full restoration
        // For now, we'll fetch fresh placemark data when needed
      }
    } catch (e) {
      debugPrint('LocationController: Error initializing from cache: $e');
    }
  }

  /// Get current location with smart caching and fallback strategies
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // Check permissions first
      if (!await _checkAndRequestPermissions()) {
        return null;
      }

      // If we have a valid cached position and no force refresh, use it
      if (!forceRefresh &&
          _isLocationCacheValid() &&
          _currentPosition.value != null) {
        debugPrint('LocationController: Using cached position');
        _isLoading.value = false;
        return _currentPosition.value;
      }

      // Try to get last known position first for instant response
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _lastKnownPosition.value = lastKnown;

        // If we don't have current position or it's significantly different, update
        if (_currentPosition.value == null ||
            _hasMovedSignificantly(_currentPosition.value!, lastKnown)) {
          _currentPosition.value = lastKnown;
          _lastFetchTime = DateTime.now();
          await _savePositionToCache(lastKnown);
          debugPrint('LocationController: Updated with last known position');
        }
      }

      // Get fresh position in background if cache is stale or we want accuracy
      if (forceRefresh ||
          _isLocationCacheStale() ||
          _currentPosition.value == null) {
        _fetchFreshLocationInBackground();
      }

      _isLoading.value = false;
      return _currentPosition.value;
    } catch (e) {
      _handleLocationError(e);
      _isLoading.value = false;
      // Return last known position even if fresh fetch failed
      return _lastKnownPosition.value ?? _currentPosition.value;
    }
  }

  /// Fetch fresh location in background without blocking UI
  void _fetchFreshLocationInBackground() async {
    try {
      debugPrint(
          'LocationController: Fetching fresh location in background...');

      final fresh = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Only update if significantly moved or more accurate
      if (_currentPosition.value == null ||
          _hasMovedSignificantly(_currentPosition.value!, fresh) ||
          (fresh.accuracy <
              (_currentPosition.value?.accuracy ?? double.infinity))) {
        _currentPosition.value = fresh;
        _lastFetchTime = DateTime.now();
        await _savePositionToCache(fresh);

        debugPrint(
            'LocationController: Updated with fresh position: ${fresh.latitude}, ${fresh.longitude}');
      }
    } catch (e) {
      debugPrint('LocationController: Background location fetch failed: $e');
      // Don't update error state for background failures
    }
  }

  /// Check and request location permissions
  Future<bool> _checkAndRequestPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error.value = 'Location services are disabled.';
        _hasLocationPermission.value = false;
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error.value = 'Location permissions are denied';
          _hasLocationPermission.value = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error.value =
            'Location permissions are permanently denied, we cannot request permissions.';
        _hasLocationPermission.value = false;
        return false;
      }

      _hasLocationPermission.value = true;
      return true;
    } catch (e) {
      _error.value = 'Error checking location permissions: $e';
      _hasLocationPermission.value = false;
      return false;
    }
  }

  /// Get placemark (address) for current location with caching
  Future<Placemark?> getPlacemark({bool useCache = true}) async {
    try {
      final position = _currentPosition.value;
      if (position == null) {
        await getCurrentLocation();
        if (_currentPosition.value == null) return null;
      }

      // Check if cached placemark is still valid
      if (useCache &&
          _isPlacemarkCacheValid() &&
          _currentPlacemark.value != null) {
        debugPrint('LocationController: Using cached placemark');
        return _currentPlacemark.value;
      }

      debugPrint('LocationController: Fetching fresh placemark...');
      final placemarks = await placemarkFromCoordinates(
        _currentPosition.value!.latitude,
        _currentPosition.value!.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentPlacemark.value = placemarks.first;
        _lastPlacemarkFetchTime = DateTime.now();
        await _savePlacemarkToCache(placemarks.first);
        return _currentPlacemark.value;
      }

      return null;
    } catch (e) {
      debugPrint('LocationController: Error getting placemark: $e');
      return _currentPlacemark.value; // Return cached if available
    }
  }

  /// Refresh location data (force fresh fetch)
  Future<void> refreshLocation() async {
    await getCurrentLocation(forceRefresh: true);
    await getPlacemark(useCache: false);
  }

  /// Check if location cache is valid (not expired)
  bool _isLocationCacheValid() {
    return _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            _locationCacheValidDuration;
  }

  /// Check if location cache is stale (older than threshold but not expired)
  bool _isLocationCacheStale() {
    return _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > const Duration(minutes: 5);
  }

  /// Check if placemark cache is valid
  bool _isPlacemarkCacheValid() {
    return _lastPlacemarkFetchTime != null &&
        DateTime.now().difference(_lastPlacemarkFetchTime!) <
            _placemarkCacheValidDuration;
  }

  /// Check if user has moved significantly from last position
  bool _hasMovedSignificantly(Position oldPos, Position newPos) {
    final distance = Geolocator.distanceBetween(
      oldPos.latitude,
      oldPos.longitude,
      newPos.latitude,
      newPos.longitude,
    );
    return distance > _significantDistanceThreshold;
  }

  /// Calculate distance from current location to given coordinates
  double? calculateDistanceFrom(double lat, double lng) {
    final position = _currentPosition.value;
    if (position == null) return null;

    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      lat,
      lng,
    );
  }

  /// Check if current location is within radius of given coordinates
  bool isWithinRadius(double lat, double lng, double radiusKm) {
    final distance = calculateDistanceFrom(lat, lng);
    if (distance == null) return false;
    return distance <= (radiusKm * 1000); // Convert km to meters
  }

  /// Get the best available position (current or last known)
  Position? getBestAvailablePosition() {
    return _currentPosition.value ?? _lastKnownPosition.value;
  }

  /// Save position to cache
  Future<void> _savePositionToCache(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_lastPositionLatKey, position.latitude);
      await prefs.setDouble(_lastPositionLngKey, position.longitude);
      await prefs.setString(
          _lastPositionTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('LocationController: Error saving position to cache: $e');
    }
  }

  /// Save placemark to cache
  Future<void> _savePlacemarkToCache(Placemark placemark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simple cache - in production, you might want to serialize full placemark
      await prefs.setString(_lastPlacemarkKey, placemark.name ?? '');
      await prefs.setString(
          _lastPlacemarkTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('LocationController: Error saving placemark to cache: $e');
    }
  }

  /// Handle location errors with user-friendly messages
  void _handleLocationError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('Location services are disabled')) {
      _error.value =
          'Location services are turned off. Please enable them in your device settings.';
    } else if (errorStr.contains('Location permissions are denied')) {
      _error.value =
          'Location permission denied. Please allow location access for this app.';
    } else if (errorStr.contains('permanently denied')) {
      _error.value =
          'Location permission permanently denied. Please enable it from your device settings.';
    } else if (errorStr.contains('PlatformException') &&
        errorStr.contains('UNAVAILABLE')) {
      _error.value =
          'Location service is currently unavailable. Please try again later.';
    } else {
      _error.value = 'An unexpected error occurred while getting location.';
    }
    debugPrint('LocationController: Error: $error');
  }

  /// Clear all cached data
  void clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastPositionLatKey);
      await prefs.remove(_lastPositionLngKey);
      await prefs.remove(_lastPositionTimeKey);
      await prefs.remove(_lastPlacemarkKey);
      await prefs.remove(_lastPlacemarkTimeKey);

      _currentPosition.value = null;
      _lastKnownPosition.value = null;
      _currentPlacemark.value = null;
      _lastFetchTime = null;
      _lastPlacemarkFetchTime = null;

      debugPrint('LocationController: Cache cleared');
    } catch (e) {
      debugPrint('LocationController: Error clearing cache: $e');
    }
  }

  /// Force initialize location (useful for retry scenarios)
  Future<void> initializeLocation() async {
    _error.value = '';
    await getCurrentLocation(forceRefresh: true);
  }

  /// Listen to location changes reactively for real-time updates
  void startLocationUpdates() {
    // This could be used for real-time location tracking if needed
    // For now, we rely on the smart caching system
    Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isLocationCacheStale()) {
        _fetchFreshLocationInBackground();
      }
    });
  }

  /// Stop any ongoing location updates
  void stopLocationUpdates() {
    // Implementation for stopping periodic updates if needed
  }

  /// Get Qibla bearing for current location
  double? getQiblaBearing() {
    final position = getBestAvailablePosition();
    if (position == null) return null;

    // Kaaba coordinates
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;

    // Calculate bearing to Kaaba
    final double deltaLon = (kaabaLon - position.longitude) * (pi / 180);
    final double lat1 = position.latitude * (pi / 180);
    const double lat2 = kaabaLat * (pi / 180);

    final double y = sin(deltaLon) * cos(lat2);
    final double x =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);

    double bearing = atan2(y, x) * (180 / pi);
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
  }
}
