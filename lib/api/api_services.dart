import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../Screens/home/Components/LocationDialog.dart';

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
            var dialogContext = context;
            return locationDialog(dialogContext);
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
}