// ignore_for_file: file_names, must_be_immutable
import 'package:adhan/adhan.dart';
import 'package:adhanminima/api/notification_api.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;
  PrayerTimes prayerTimes;

  PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
    required this.prayerTimes,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late PrayerTimes prayerTimes = widget.prayerTimes;
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

    NotificationApi.init(initScheduled: true);
    listenNotifications();
    //setNotification(prayerTimes);
  }

  void listenNotifications() {
    void onClickedNotification(String? payload) => {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => const Main()));
          //print("Notification clicked")
        };

    NotificationApi.onNotifications.stream.listen(onClickedNotification);
  }

  void setNotificationMethod(
    int id,
    String prayerName,
    String prayerTime,
  ) {
    NotificationApi.showScheduledNotification(
        id: id,
        title: 'Time for $prayerName',
        body:
            "$prayerName at ${DateFormat.jm().format(DateTime.parse(prayerTime))}",
        payload: prayerName,
        times: DateTime.parse(prayerTime),
        scheduleDate: DateTime.now());
  }

  Future<void> setNotification(prayerTimes) async {
    int notificationLength = await NotificationApi().listOfNotifications();
    if (notificationLength != 6) {
      setNotificationMethod(0, 'Farj', prayerTimes.fajr.toString());
      setNotificationMethod(1, 'Sunrise', prayerTimes.sunrise.toString());
      setNotificationMethod(2, 'Duhr', prayerTimes.dhuhr.toString());
      setNotificationMethod(3, 'Asr', prayerTimes.asr.toString());
      setNotificationMethod(4, 'Maghrib', prayerTimes.maghrib.toString());
      setNotificationMethod(5, 'Isha', prayerTimes.isha.toString());
      //print("Added all notification");
    } else {
      //print("notificaiton exists");
    }
  }

  @override
  Widget build(BuildContext context) {
    String nextPrayer = prayerTimes.nextPrayer().name[0].toUpperCase() +
        prayerTimes.nextPrayer().name.substring(1);

    return Column(
      children: [
        buildDragHandle(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(45, 45, 45, 25),
              child: (() {
                return Column(
                  children: [
                    prayerTime(false, 'Fajr',
                        DateFormat.jm().format(prayerTimes.fajr), nextPrayer),
                    verticalBox(2),
                    const Divider(
                      color: Colors.white,
                    ),
                    verticalBox(10),
                    //
                    prayerTime(
                        false,
                        'Sunrise',
                        DateFormat.jm().format(prayerTimes.sunrise),
                        nextPrayer),
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
                    prayerTime(
                        false,
                        'Maghrib',
                        DateFormat.jm().format(prayerTimes.maghrib),
                        nextPrayer),
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
                    ),
                    verticalBox(10),
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
                            const String urlString =
                                'https://www.instagram.com/be.saif/';
                            Uri url = Uri.parse(urlString);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          child: Text('be.Saif',
                              style: cusTextStyle(15, FontWeight.w700)),
                        ),
                      ],
                    )
                  ],
                );
              }()),
            ),
          ),
        )
      ],
    );
  }

  Widget buildDragHandle() => GestureDetector(
        onTap: () => setState(() {
          togglePanel();
          setNotification(prayerTimes);
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
            const Icon(
              Icons.notifications_sharp,
              color: Colors.white70,
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
