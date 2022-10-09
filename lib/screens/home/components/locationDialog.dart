// ignore_for_file: file_names
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

Widget locationDialog(dialogContext) {
  void openLocationSetting() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

  return AlertDialog(
    title: const Center(
        child: Text('Enable Location',
            style: TextStyle(
                fontFamily: 'Halenoir',
                color: Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.w600))),
    actions: <Widget>[
      Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/location-animation.json'),
              const Text(
                  "We need to know your location in order to calculate the prayer timings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Halenoir',
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              verticalBox(15),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white, backgroundColor: Colors.blue),
                    onPressed: () async {
                      openLocationSetting();
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Turn on location service')),
              ),
              TextButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: const Text('Not Now'),
              )
            ],
          ),
        ),
      ),
    ],
  );
}
