// ignore_for_file: file_names, import_of_legacy_library_into_null_safe, must_be_immutable

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class HomeWidget extends StatefulWidget {
  PrayerTimes prayerTimes;
  Placemark place;
  HomeWidget({required this.prayerTimes, required this.place, Key? key})
      : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late PrayerTimes prayerTimes = widget.prayerTimes;
  late Placemark place = widget.place;

  var formattedDiff = "0";

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
    if (mounted) {
      // check whether the state object is in tree
      setState(() {
        timeLeft(prayerTimes);
      });
    }
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
                      prayerTimes.nextPrayer().name[0].toUpperCase(),
                      style: cusTextStyle(24, FontWeight.w400),
                    ),
                    Text(
                      prayerTimes.nextPrayer().name.substring(1),
                      style: cusTextStyle(24, FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
            verticalBox(40),
            Row(
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
                      place.locality.toString(),
                      style: cusTextStyle(18, FontWeight.w200),
                    ),
                    Text(
                      ", ${place.isoCountryCode.toString()}",
                      style: cusTextStyle(18, FontWeight.w200),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
