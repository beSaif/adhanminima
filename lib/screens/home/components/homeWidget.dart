// ignore_for_file: file_names
import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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
  late Timer _timer;

  Future<Placemark> convertLoc() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    Placemark place = placemarks[0];
    //print("Place: ${place}");
    return place;
  }

  getCords() async {
    final myCoordinates =
        Coordinates(lat, long); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.shafi;
    prayerTimes = PrayerTimes.today(myCoordinates, params);
  }

  void timeLeft(prayerTimes) async {
    _timer = Timer.periodic(Duration(seconds: 1), ((timer) {
      setState(() {
        DateTime current = DateTime.now();
        DateTime next = prayerTimes.timeForPrayer(prayerTimes.nextPrayer());
        Duration diff = current.difference(next).abs();
        //print("currentTime: $current next: $next diff: $diff");
        format(Duration diff) =>
            diff.toString().split('.').first.padLeft(8, "0");
        formattedDiff = diff.toString().substring(0, 7);
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
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        verticalBox(0),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                timeLeft(prayerTimes);
              },
              child: Text(
                formattedDiff,
                style: cusTextStyle(55, FontWeight.w500),
              ),
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
                  if (!location.hasData) {
                    return CircularProgressIndicator();
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
