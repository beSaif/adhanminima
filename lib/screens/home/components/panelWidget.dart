// ignore_for_file: file_names
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
    print('lat: $lat \nlong: $long');
    final myCoordinates =
        Coordinates(lat, long); // Replace with your own location lat, lng.
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);
    return Column(
      children: [
        buildDragHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 45, 45, 25),
          child: (() {
            if (prayerTimes == null) {
              return const CircularProgressIndicator();
            }
            return Column(
              children: [
                //
                prayerTime(
                    true, 'Fajr', DateFormat.jm().format(prayerTimes.fajr)),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(false, 'Sunrise',
                    DateFormat.jm().format(prayerTimes.sunrise)),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(
                    false, 'Duhr', DateFormat.jm().format(prayerTimes.dhuhr)),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(
                    false, 'Asr', DateFormat.jm().format(prayerTimes.asr)),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),

                //
                prayerTime(false, 'Maghrib',
                    DateFormat.jm().format(prayerTimes.maghrib)),
                verticalBox(2),
                const Divider(
                  color: Colors.white,
                ),
                verticalBox(10),
                //
                prayerTime(
                    false, 'Isha', DateFormat.jm().format(prayerTimes.isha)),
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

  Widget prayerTime(alarm, prayer, time) {
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
            Text(prayer, style: cusTextStyle(24, FontWeight.w300)),
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
