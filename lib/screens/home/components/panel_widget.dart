import 'package:adhan/adhan.dart';
import 'package:adhanminima/GetX/prayerdata.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;

  const PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  final PrayerDataController prayerDataController =
      Get.put(PrayerDataController(), permanent: false);

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
    PrayerTimes prayerTimes = prayerDataController.allData.prayerTimes;
    List prayerDetails = [
      {'Fajr': prayerTimes.fajr},
      {'Sunrise': prayerTimes.sunrise},
      {'Duhr': prayerTimes.dhuhr},
      {'Asr': prayerTimes.asr},
      {'Maghrib': prayerTimes.maghrib},
      {'Isha': prayerTimes.isha},
    ];
    return Padding(
        padding: const EdgeInsets.fromLTRB(45, 10, 45, 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                buildDragHandle(),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 41.56.h,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return prayerTime(prayerDetails[index]);
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

  Widget prayerTime(prayerDetails) {
    final PrayerDataController prayerDataController =
        Get.put(PrayerDataController(), permanent: false);
    // Removing unwanted brackets from key
    String prayer = prayerDetails.keys
        .toString()
        .substring(1, prayerDetails.keys.toString().length - 1);

    String nextPrayer =
        prayerDataController.allData.prayerTimes.nextPrayer().name.toString();

    String time = DateFormat.jm().format(prayerDetails[prayer]);
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
                Text(prayer,
                    style: TextStyle(
                        fontFamily: 'Halenoir',
                        color: prayer[0] == nextPrayer[0].toUpperCase()
                            ? Colors.white
                            : Colors.white70,
                        fontSize: 24,
                        fontWeight: prayer[0] == nextPrayer[0].toUpperCase()
                            ? FontWeight.w900
                            : FontWeight.w400)),
              ],
            ),
            Row(
              children: [
                Text(time, style: cusTextStyle(24, FontWeight.w300)),
                horizontalBox(10),
              ],
            )
          ],
        ),
        verticalBox(2),
        const Divider(
          color: Colors.white,
        ),
        verticalBox(10),
      ],
    );
  }
}
