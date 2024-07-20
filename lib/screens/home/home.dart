import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:adhanminima/screens/home/components/homeWidget.dart';
import 'package:adhanminima/screens/home/components/locationDialog.dart';
import 'package:adhanminima/screens/home/components/panelWidget.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final panelController = PanelController();
  String formattedDiff = "0";
  double lat = 0.0;
  double long = 0.0;
  late Placemark place;
  late PrayerTimes prayerTimes;
  Coordinates myCoordinates = Coordinates(0, 0);

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => locationDialog(context),
    );
  }

  Future<Placemark> _convertLocation(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return placemarks[0];
  }

  Future<PrayerTimes> _getCoordinates() async {
    Position position = await _determinePosition();
    lat = position.latitude;
    long = position.longitude;
    if (kDebugMode) {
      lat = 12.4996;
      long = 74.9869;
    }
    place = await _convertLocation(lat, long);
    myCoordinates = Coordinates(lat, long);
    final params = CalculationMethod.karachi.getParameters()
      ..madhab = Madhab.shafi;
    prayerTimes = PrayerTimes.today(myCoordinates, params);

    if (prayerTimes.nextPrayer().name == "none") {
      final now = DateTime.now();
      final tomorrow =
          DateComponents.from(DateTime(now.year, now.month, now.day + 1));
      prayerTimes = PrayerTimes(myCoordinates, tomorrow, params);
    }

    return prayerTimes;
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
          ),
        ),
        child: FutureBuilder(
          future: _getCoordinates(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            } else if (snapshot.hasError) {
              return _buildErrorScreen(snapshot.error);
            } else if (snapshot.hasData) {
              return SlidingUpPanel(
                controller: panelController,
                parallaxEnabled: true,
                parallaxOffset: .6,
                color: Colors.transparent,
                // body: PageView(
                //   children: [
                //     HomeWidget(
                //       prayerTimes: snapshot.data,
                //       place: place,
                //     ),
                //     Container(), // Placeholder on the left side
                //     Container(), // Placeholder on the right side
                //   ],
                // ),
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
            } else {
              return _buildErrorScreen("Unknown error");
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    const String delayMessage = "Restart the app if it's taking too long...";
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return Center(
      child: Text(
        'Error: $error',
        style: cusTextStyle(16, FontWeight.w400),
      ),
    );
  }
}
