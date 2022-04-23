import 'package:adhanminima/screens/home/components/homeWidget.dart';
import 'package:adhanminima/screens/home/components/panelWidget.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:restart_app/restart_app.dart';
import 'package:lottie/lottie.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final panelController = PanelController();

  void openLocationSetting() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

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
                        Container(
                          height: 40,
                          width: double.infinity,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.blue),
                              onPressed: () async {
                                openLocationSetting();
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Turn on location service')),
                        ),
                        TextButton(
                          onPressed: () {
                            SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                          },
                          child: const Text('Not Now'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
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
    return await Geolocator.getCurrentPosition();
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
          future: _determinePosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> position) {
            if (!position.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return SlidingUpPanel(
              controller: panelController,
              parallaxEnabled: true,
              parallaxOffset: .6,
              color: Colors.transparent,
              body: HomeWidget(position: position),
              panelBuilder: (controller) => PanelWidget(
                position: position,
                controller: controller,
                panelController: panelController,
              ),
            );
          }),
    ));
  }
}
