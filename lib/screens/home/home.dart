import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:adhanminima/screens/home/components/homeWidget.dart';
import 'package:adhanminima/screens/home/components/locationDialog.dart';
import 'package:adhanminima/screens/home/components/panelWidget.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:async/async.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final panelController = PanelController();
  var formattedDiff = "0";
  var lat = 0.0;
  var long = 0.0;
  late Placemark place;
  late PrayerTimes prayerTimes;
  Coordinates myCoordinates = Coordinates(0, 0);

  Future<Position> _determinePosition() async {
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

  Future<Placemark> convertLoc(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    Placemark _place = placemarks[0];
    //print("Place: ${place}");
    return _place;
  }

  Future<PrayerTimes> getCords() async {
    var cords = await _determinePosition();
    lat = cords.latitude;
    long = cords.longitude;
    place = await convertLoc(lat, long);
    //print(place.country);

    //print(cords);
    myCoordinates =
        Coordinates(lat, long); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.shafi;
    prayerTimes = PrayerTimes.today(myCoordinates, params);

    if (prayerTimes.nextPrayer().name == "none") {
      final now = DateTime.now();
      final tomorrow =
          DateComponents.from(DateTime(now.year, now.month, now.day + 1));
      //print(tomorrow);
      prayerTimes = PrayerTimes(myCoordinates, tomorrow, params);
    }

    return prayerTimes;
  }

  AsyncMemoizer _memoizer = AsyncMemoizer();

  _fetchData() {
    return _memoizer.runOnce(() async {
      await Future.delayed(const Duration(seconds: 2));
      return getCords();
    });
  }

  @override
  void initState() {
    super.initState();
    _memoizer = AsyncMemoizer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: double.infinity,
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: const AssetImage("assets/bg.jpg"),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35), BlendMode.dstATop),
            fit: BoxFit.cover,
          )),
      child: FutureBuilder(
          future: _fetchData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            String delayMessage = "Restart the app if it's taking too long...";
            if (!snapshot.hasData) {
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
            return SlidingUpPanel(
              controller: panelController,
              parallaxEnabled: true,
              parallaxOffset: .6,
              color: Colors.transparent,
              body: HomeWidget(
                prayerTimes: snapshot.data,
                place: place,
              ),
              panelBuilder: (controller) => PanelWidget(
                prayerTimes: prayerTimes,
                controller: controller,
                panelController: panelController,
              ),
            );
          }),
    ));
  }
}
