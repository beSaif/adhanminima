import 'package:adhanminima/api/notification_api.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;

  PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(45, 10, 45, 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                buildDragHandle(),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 370,
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return prayerTime();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'developed by ',
                  style: cusTextStyle(12, FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () async {
                    //print("Launching @be.saif insta");
                    const String url = 'https://www.instagram.com/be.saif/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  child:
                      Text('be.Saif', style: cusTextStyle(15, FontWeight.w700)),
                ),
              ],
            )
          ],
        ));
  }

  Widget buildDragHandle() => GestureDetector(
        onTap: () => setState(() {
          togglePanel();
          //setNotification(prayerTimes);
        }),
        child: Center(
          child: Icon(
            dragIcon,
            color: Colors.white,
            size: 55,
          ),
        ),
      );

  Widget prayerTime() {
    //print("prayer: $prayer, nextPrayer: $nextPrayer");
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_sharp,
                  color: Colors.white70,
                ),
                horizontalBox(20),
                Text("prayer",
                    style: TextStyle(
                        fontFamily: 'Halenoir',
                        color: (() {
                          // if (nextPrayer[0] == prayer[0]) {
                          //   return Colors.white;
                          // }
                          return Colors.white70;
                        }()),
                        fontSize: 24,
                        fontWeight: (() {
                          // if (nextPrayer[0] == prayer[0]) {
                          //   return FontWeight.w900;
                          // }
                          return FontWeight.w400;
                        }()))),
              ],
            ),
            Row(
              children: [
                Text("time", style: cusTextStyle(24, FontWeight.w300)),
                horizontalBox(10),
              ],
            )
          ],
        ),
        verticalBox(2),
        const Divider(
          color: Colors.white,
        ),
        verticalBox(20),
      ],
    );
  }
}
