// ignore_for_file: file_names, import_of_legacy_library_into_null_safe, must_be_immutable
import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeWidget extends StatefulWidget {
  AsyncSnapshot<Position> position;
  HomeWidget({required this.position, Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  var formattedDiff = "0";
  var lat = 0.0;
  var long = 0.0;
  PrayerTimes? prayerTimes;
  Coordinates myCoordinates = Coordinates(0, 0);

  Future<Placemark> convertLoc() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    Placemark place = placemarks[0];
    //print("Place: ${place}");
    return place;
  }

  getCords() async {
    myCoordinates =
        Coordinates(lat, long); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.shafi;
    prayerTimes = PrayerTimes.today(myCoordinates, params);
    if (prayerTimes!.nextPrayer().name == "none") {
      final now = DateTime.now();
      final tomorrow =
          DateComponents.from(DateTime(now.year, now.month, now.day + 1));
      //print(tomorrow);
      prayerTimes = PrayerTimes(myCoordinates, tomorrow, params);
    }
  }

  void timeLeft(prayerTimes) async {
    Timer.periodic(const Duration(seconds: 1), ((timer) {
      setState(() {
        DateTime current = DateTime.now();

        DateTime next = prayerTimes.timeForPrayer(prayerTimes.nextPrayer());
        Duration diff = current.difference(next).abs();
        //print("currentTime: $current next: $next diff: $diff");
        formattedDiff = diff.toString().substring(0, 7);
        //print("formattedDiff= $formattedDiff");
        //print(formattedDiff);
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      lat = widget.position.data!.latitude;
      long = widget.position.data!.longitude;
      getCords();
      timeLeft(prayerTimes);
      convertLoc();
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        verticalBox(0),
        Column(
          children: [
            Text(
              formattedDiff,
              style: cusTextStyle(55, FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "left until ",
                  style: cusTextStyle(24, FontWeight.w300),
                ),
                Row(
                  children: [
                    Text(
                      prayerTimes!.nextPrayer().name[0].toUpperCase(),
                      style: cusTextStyle(24, FontWeight.w400),
                    ),
                    Text(
                      prayerTimes!.nextPrayer().name.substring(1),
                      style: cusTextStyle(24, FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
            verticalBox(40),
            FutureBuilder(
                future: convertLoc(),
                builder: (context, AsyncSnapshot<Placemark> location) {
                  //print("Location: $location");
                  if (!location.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                      horizontalBox(7),
                      Row(
                        children: [
                          Text(
                            location.data!.locality.toString(),
                            style: cusTextStyle(18, FontWeight.w200),
                          ),
                          Text(
                            ", ${location.data!.isoCountryCode.toString()}",
                            style: cusTextStyle(18, FontWeight.w200),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
          ],
        ),
      ],
    );
  }
}
