import 'package:adhanminima/Utils/sizedbox.dart';
import 'package:adhanminima/Utils/theme.dart';
import 'package:flutter/material.dart';

Widget loadingIndicator() {
  String delayMessage = "Restart the app if it's taking too long...";
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircularProgressIndicator(),
      verticalBox(20),
      Text(
        delayMessage,
        textAlign: TextAlign.center,
        style: cusTextStyle(16, FontWeight.w400),
      )
    ],
  ));
}
