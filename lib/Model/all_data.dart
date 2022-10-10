import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AllData {
  Position position;
  List<Placemark> placemarks;
  PrayerTimes prayerTimes;

  AllData(
      {required this.position,
      required this.placemarks,
      required this.prayerTimes});
}
