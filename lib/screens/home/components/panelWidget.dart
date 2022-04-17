// ignore_for_file: file_names, must_be_immutable
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelWidget extends StatefulWidget {
  AsyncSnapshot<Position> position;
  final ScrollController controller;
  final PanelController panelController;

  PanelWidget(
      {Key? key,
      required this.position,
      required this.controller,
      required this.panelController})
      : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  var dragIcon = Icons.keyboard_arrow_up_outlined;

  void togglePanel() {
    if (widget.panelController.panelPosition < 0.5) {
      widget.panelController.open();
      dragIcon = Icons.keyboard_arrow_down_outlined;
    } else {
      widget.panelController.close();
      dragIcon = Icons.keyboard_arrow_up_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    var lat = widget.position.data?.latitude;
    var long = widget.position.data?.longitude;
    //print('Panel Widget\n\tlat: $lat long: $long');
    final myCoordinates =
        Coordinates(lat!, long!); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);
    String nextPrayer = prayerTimes.nextPrayer().name[0].toUpperCase() +
        prayerTimes.nextPrayer().name.substring(1);
    return Column(
      children: [
        buildDragHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 45, 45, 25),
          child: (() {
            // ignore: unnecessary_null_comparison
            if (prayerTimes == null) {
              return const CircularProgressIndicator();
            }
            return Column(
              children: [
                //
                prayerTime(false, 'Fajr',
                    DateFormat.jm().format(prayerTimes.fajr), nextPrayer),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(false, 'Sunrise',
                    DateFormat.jm().format(prayerTimes.sunrise), nextPrayer),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(false, 'Duhr',
                    DateFormat.jm().format(prayerTimes.dhuhr), nextPrayer),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(false, 'Asr',
                    DateFormat.jm().format(prayerTimes.asr), nextPrayer),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),

                //
                prayerTime(false, 'Maghrib',
                    DateFormat.jm().format(prayerTimes.maghrib), nextPrayer),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(false, 'Isha',
                    DateFormat.jm().format(prayerTimes.isha), nextPrayer),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                )
              ],
            );
          }()),
        )
      ],
    );
  }

  Widget buildDragHandle() => GestureDetector(
        onTap: () => setState(() {
          togglePanel();
          //prayerTimesMethod();
        }),
        child: Center(
          child: Icon(
            dragIcon,
            color: Colors.white,
            size: 55,
          ),
        ),
      );

  Widget prayerTime(alarm, prayer, time, nextPrayer) {
    //print("prayer: $prayer, nextPrayer: $nextPrayer");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_none,
              color: (() {
                if (alarm) {
                  return Colors.white;
                } else {
                  return Colors.grey;
                }
              }()),
            ),
            horizontalBox(20),
            Text(prayer,
                style: TextStyle(
                    fontFamily: 'Halenoir',
                    color: (() {
                      if (nextPrayer[0] == prayer[0]) {
                        return Colors.white;
                      }
                      return Colors.white70;
                    }()),
                    fontSize: 24,
                    fontWeight: (() {
                      if (nextPrayer[0] == prayer[0]) {
                        return FontWeight.w900;
                      }
                      return FontWeight.w400;
                    }()))),
          ],
        ),
        Row(
          children: [
            Text(time, style: cusTextStyle(24, FontWeight.w300)),
            horizontalBox(10),
          ],
        )
      ],
    );
  }
}
