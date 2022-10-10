import 'package:adhanminima/API/api_services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class PrayerDataController extends GetxController {
  Position position = const Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: null,
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  List<Placemark> placemarks = [];

  void updatePosition(Position currentPosition) async {
    position = currentPosition;
    var getPlacemark = await APIServices.getPlacemark(position);
    placemarks = getPlacemark;
    update();
  }

  void updatePlacemark(List<Placemark> currentPlacemark) {
    placemarks = currentPlacemark;
    update();
  }
}
