import 'package:adhan/adhan.dart';

/// Bearing from [coordinates] to the Kaaba, degrees clockwise from true north.
double qiblaBearing(Coordinates coordinates) => Qibla(coordinates).direction;

const _points = [
  'N',
  'NNE',
  'NE',
  'ENE',
  'E',
  'ESE',
  'SE',
  'SSE',
  'S',
  'SSW',
  'SW',
  'WSW',
  'W',
  'WNW',
  'NW',
  'NNW',
];

/// 16-point compass name for [degrees], e.g. 121 -> ESE.
String compassPoint(double degrees) =>
    _points[((degrees % 360) / 22.5).round() % 16];

/// Signed turn in (-180, 180] from [heading] to [target]; positive = right.
double turnBetween(double heading, double target) {
  final d = (target - heading) % 360;
  return d > 180 ? d - 360 : d;
}
