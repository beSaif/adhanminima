// ignore_for_file: file_names

import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';

Widget homeWidget() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      verticalBox(0),
      Column(
        children: [
          Text(
            "15 minutes",
            style: cusTextStyle(55, FontWeight.w500),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "left until ",
                style: cusTextStyle(24, FontWeight.w300),
              ),
              Text(
                "Maghrib",
                style: cusTextStyle(24, FontWeight.w400),
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
              Text(
                "KASARAGOD, IN",
                style: cusTextStyle(18, FontWeight.w200),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
