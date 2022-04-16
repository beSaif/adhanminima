// ignore_for_file: file_names

import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;

  const PanelWidget(
      {Key? key, required this.controller, required this.panelController})
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
    return Column(
      children: [
        buildDragHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 45, 45, 25),
          child: Column(
            children: [
              //
              prayerTime(true, 'Fajr', '5:30', "AM"),
              verticalBox(2),
              const Divider(
                color: Colors.white,
              ),
              verticalBox(10),
              //
              prayerTime(false, 'Sunrise', '7:19', "AM"),
              verticalBox(2),
              const Divider(
                color: Colors.white,
              ),
              verticalBox(10),
              //
              prayerTime(false, 'Duhr', '5:30', "AM"),
              verticalBox(2),
              const Divider(
                color: Colors.white,
              ),
              verticalBox(10),
              //
              prayerTime(false, 'Asr', '5:30', "AM"),
              verticalBox(2),
              const Divider(
                color: Colors.white,
              ),
              verticalBox(10),

              //
              prayerTime(false, 'Maghrib', '5:30', "AM"),
              verticalBox(2),
              const Divider(
                color: Colors.white,
              ),
              verticalBox(10),
              //
              prayerTime(false, 'Isha', '5:30', "AM"),
              verticalBox(2),
              const Divider(
                color: Colors.white,
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildDragHandle() => GestureDetector(
        onTap: () => setState(() {
          togglePanel();
        }),
        child: Center(
          child: Icon(
            dragIcon,
            color: Colors.white,
            size: 55,
          ),
        ),
      );

  Widget prayerTime(alarm, prayer, time, timing) {
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
            Text(timing, style: cusTextStyle(24, FontWeight.w300))
          ],
        )
      ],
    );
  }
}
