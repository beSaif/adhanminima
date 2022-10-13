import 'dart:isolate';

import 'package:adhanminima/API/api_services.dart';
import 'package:adhanminima/API/notification_api.dart';
import 'package:adhanminima/screens/home/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// remove --no-sound-null-safety from Preference>Settings  Flutter run additional args

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  debugRepaintTextRainbowEnabled = false;
  runApp(const Main());

  const int notificationID = 0;
  AndroidAlarmManager.periodic(
      const Duration(days: 1), notificationID, setNotification,
      startAt: DateTime.now());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    APIServices.fetchAllData(context);

    return Sizer(
        builder: (context, orientation, deviceType) => const GetMaterialApp(
            debugShowCheckedModeBanner: false, home: Home()));
  }
}

void setNotification() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  LocalNotificationService().showNotification(
      body: "Starting work manager @ $now", title: "Work Manager", id: 8);
  //  APIServices.fetchAllData(context);
}
