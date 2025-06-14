import 'dart:math';

/// Returns the initial bearing (forward azimuth) in degrees from (lat1, lon1) to (lat2, lon2).
double calculateQiblaBearing(
    double lat1, double lon1, double lat2, double lon2) {
  final double phi1 = lat1 * pi / 180.0;
  final double phi2 = lat2 * pi / 180.0;
  final double deltaLon = (lon2 - lon1) * pi / 180.0;

  final double y = sin(deltaLon) * cos(phi2);
  final double x =
      cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLon);
  final double bearing = atan2(y, x) * 180.0 / pi;
  return (bearing + 360.0) % 360.0;
}
