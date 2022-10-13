import 'package:adhan/adhan.dart';
import 'package:adhanminima/API/notification_api.dart';
import 'package:adhanminima/GetX/prayerdata.dart';
import 'package:adhanminima/Model/all_data.dart';
import 'package:adhanminima/Screens/home/Components/locationDialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class APIServices {
  static Future<Position> determinePosition(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //print("Location disabled");
      showDialog(
          context: context,
          builder: (context) {
            return locationDialogue(context);
          });
      //openLocationSetting();

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    //print(Geolocator.getCurrentPosition());

    //getCords();
    return await Geolocator.getCurrentPosition();
  }

  static Future<List<Placemark>> getPlacemark(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    return placemarks;
  }

  static Future<PrayerTimes> getPrayerTime(Position position) async {
    final myCoordinates = Coordinates(position.latitude, position.longitude);

    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.shafi;
    PrayerTimes prayerTimes = PrayerTimes.today(myCoordinates, params);
    if (prayerTimes.nextPrayer().name == "none") {
      final now = DateTime.now();
      final tomorrow =
          DateComponents.from(DateTime(now.year, now.month, now.day + 1));
      //print(tomorrow);
      prayerTimes = PrayerTimes(myCoordinates, tomorrow, params);
    }
    return prayerTimes;
  }

  static Future<AllData> fetchAllData(context) async {
    final PrayerDataController prayerDataController =
        Get.put(PrayerDataController(), permanent: false);
    Position position = await determinePosition(context);

    List<Placemark> placemarks = await getPlacemark(position);

    PrayerTimes prayerTimes = await getPrayerTime(position);

    AllData allData = AllData(
        position: position, placemarks: placemarks, prayerTimes: prayerTimes);

    prayerDataController.updateAllData(allData);

    LocalNotificationService().setScheduledNotifications();

    return allData;
  }
}
