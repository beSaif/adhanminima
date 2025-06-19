// ignore_for_file: file_names, must_be_immutable
import 'dart:ui';
import 'package:adhan/adhan.dart';
import 'package:adhanminima/api/notification_api.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:adhanminima/controllers/prayer_offset_controller.dart';

class PanelWidget extends StatefulWidget {
  PrayerTimes prayerTimes;
  PageController pageController;
  PanelController panelController;
  int currentPage = 0;

  PanelWidget({
    Key? key,
    required this.prayerTimes,
    required this.pageController,
    required this.currentPage,
    required this.panelController,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget>
    with SingleTickerProviderStateMixin {
  final List<String> dotIndicatorIcons = [
    'assets/prayer_time_icon.png',
    'assets/qibla_icon.png',
  ];
  late PrayerTimes prayerTimes = widget.prayerTimes;
  var dragIcon = Icons.keyboard_arrow_up_outlined;

  final PrayerOffsetController offsetController = Get.find();

  late AnimationController _iconAnimController;
  late Animation<double> _iconScale;
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _iconScale = CurvedAnimation(
      parent: _iconAnimController,
      curve: Curves.easeInOut,
    );
    // NotificationApi.init(initScheduled: true);
    // listenNotifications();
    //setNotification(prayerTimes);
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  // Helper to get offset time
  String getOffsetTime(DateTime time, Prayer prayer) {
    int offset = offsetController.prayerOffsets[prayer] ?? 0;
    return DateFormat.jm().format(time.add(Duration(minutes: offset)));
  }

  void _updateDragIcon(bool isOpen) {
    setState(() {
      dragIcon = isOpen
          ? Icons.keyboard_arrow_down_outlined
          : Icons.keyboard_arrow_up_outlined;
    });
  }

  @override
  Widget build(BuildContext context) {
    String nextPrayer = prayerTimes.nextPrayer().name[0].toUpperCase() +
        prayerTimes.nextPrayer().name.substring(1);

    return GetBuilder<PrayerOffsetController>(
      builder: (_) {
        return Column(
          children: [
            AnimatedOpacity(
              opacity: widget.panelController.isPanelOpen ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: _buildDotIndicators(),
              ),
            ),
            buildDragHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
                  child: (() {
                    return Column(
                      children: [
                        prayerTime(
                            false,
                            'Fajr',
                            DateFormat.jm().format(prayerTimes.fajr),
                            nextPrayer),
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
                        prayerTime(
                            false,
                            'Duhr',
                            DateFormat.jm().format(prayerTimes.dhuhr),
                            nextPrayer),
                        verticalBox(2),
                        const Divider(
                          color: Colors.white,
                        ),
                        verticalBox(10),
                        //
                        prayerTime(
                            false,
                            'Asr',
                            DateFormat.jm().format(prayerTimes.asr),
                            nextPrayer),
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
                        prayerTime(
                            false,
                            'Isha',
                            DateFormat.jm().format(prayerTimes.isha),
                            nextPrayer),
                        verticalBox(2),
                        const Divider(
                          color: Colors.white,
                        ),
                        verticalBox(10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            // Center the edit icon vertically with the text
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white54, size: 20),
                              tooltip: 'Offset prayer times',
                              onPressed: () => showOffsetDialogAll(),
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
      },
    );
  }

  Future<void> togglePanel() async {
    if (widget.panelController.isPanelOpen) {
      // Scroll to top (Fajr) when panel is closed
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await widget.panelController.close();
      _updateDragIcon(false);
    } else {
      await widget.panelController.open();
      _updateDragIcon(true);
    }
  }

  Widget buildDragHandle() => GestureDetector(
        onTap: () async {
          // Animation feedback
          await _iconAnimController.reverse();
          await _iconAnimController.forward();
          // Haptic feedback
          // ignore: use_build_context_synchronously
          Feedback.forTap(context);
          await togglePanel();
        },
        child: Center(
          child: ScaleTransition(
            scale: _iconScale,
            child: Icon(
              dragIcon,
              color: Colors.white,
              size: 55,
              semanticLabel: widget.panelController.isPanelOpen
                  ? 'Close panel'
                  : 'Open panel',
            ),
          ),
        ),
      );

  Widget prayerTime(alarm, String prayerName, time, nextPrayer) {
    // Map string name to Prayer enum
    final prayerEnum = _prayerNameToEnum(prayerName);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(prayerName,
                style: TextStyle(
                    fontFamily: 'Halenoir',
                    color: (() {
                      if (nextPrayer[0] == prayerName[0]) {
                        return Colors.white;
                      }
                      return Colors.white70;
                    }()),
                    fontSize: 24,
                    fontWeight: (() {
                      if (nextPrayer[0] == prayerName[0]) {
                        return FontWeight.w900;
                      }
                      return FontWeight.w400;
                    }()))),
          ],
        ),
        Row(
          children: [
            // Use offset time
            Text(getOffsetTime(_getPrayerTime(prayerName), prayerEnum),
                style: TextStyle(
                  fontFamily: 'Halenoir',
                  color: (() {
                    if (nextPrayer[0] == prayerName[0]) {
                      return Colors.white;
                    }
                    return Colors.white70;
                  }()),
                  fontSize: 24,
                  fontWeight: (() {
                    if (nextPrayer[0] == prayerName[0]) {
                      return FontWeight.w900;
                    }
                    return FontWeight.w300;
                  }()),
                )),
            horizontalBox(10),
          ],
        )
      ],
    );
  }

  // Helper to map string to Prayer enum
  Prayer _prayerNameToEnum(String name) {
    switch (name) {
      case 'Fajr':
        return Prayer.fajr;
      case 'Sunrise':
        return Prayer.sunrise;
      case 'Duhr':
        return Prayer.dhuhr;
      case 'Asr':
        return Prayer.asr;
      case 'Maghrib':
        return Prayer.maghrib;
      case 'Isha':
        return Prayer.isha;
      default:
        throw Exception('Unknown prayer name: $name');
    }
  }

  // Helper to get DateTime for a prayer name
  DateTime _getPrayerTime(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return prayerTimes.fajr;
      case 'Sunrise':
        return prayerTimes.sunrise;
      case 'Duhr':
        return prayerTimes.dhuhr;
      case 'Asr':
        return prayerTimes.asr;
      case 'Maghrib':
        return prayerTimes.maghrib;
      case 'Isha':
        return prayerTimes.isha;
      default:
        return DateTime.now();
    }
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2, // Number of pages
        (index) => GestureDetector(
          onTap: () {
            widget.pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: widget.currentPage == index ? 32 : 24,
              height: widget.currentPage == index ? 32 : 24,
              child: Image.asset(
                dotIndicatorIcons[index],
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  // Add dialog for all offsets at once
  void showOffsetDialogAll() async {
    Map<Prayer, int> tempOffsets =
        Map<Prayer, int>.from(offsetController.prayerOffsets);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // darken background
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Set Offsets',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return Column(
                            children: [
                              ...tempOffsets.keys.map((prayer) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: 70,
                                            child: Text(
                                                _prayerEnumToName(prayer),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.white70),
                                          onPressed: () {
                                            setStateDialog(() {
                                              tempOffsets[prayer] =
                                                  (tempOffsets[prayer] ?? 0) -
                                                      1;
                                            });
                                          },
                                        ),
                                        Container(
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            tempOffsets[prayer].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.white70),
                                          onPressed: () {
                                            setStateDialog(() {
                                              tempOffsets[prayer] =
                                                  (tempOffsets[prayer] ?? 0) +
                                                      1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white.withOpacity(0.8),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.18),
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              offsetController.setAllOffsets(tempOffsets);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper to map Prayer enum to display name
  String _prayerEnumToName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Duhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return prayer.name;
    }
  }
}
