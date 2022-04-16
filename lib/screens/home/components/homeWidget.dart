// ignore_for_file: file_names
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeWidget extends StatelessWidget {
  AsyncSnapshot<Position> position;
  HomeWidget({required this.position, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lat = position.data?.latitude;
    var long = position.data?.longitude;
    Future<Placemark> convertLoc() async {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat!, long!);
      Placemark place = placemarks[0];
      print("Place: ${place}");
      return place;
    }

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
