import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class HomeWidget extends StatefulWidget {
  final PrayerTimes prayerTimes;
  final Placemark place;

  const HomeWidget({
    required this.prayerTimes,
    required this.place,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with AutomaticKeepAliveClientMixin<HomeWidget> {
  late PrayerTimes prayerTimes;
  late Placemark place;
  Timer? _timer;
  String formattedDiff = "0";

  @override
  void initState() {
    super.initState();
    prayerTimes = widget.prayerTimes;
    place = widget.place;
    _startTimer();
  }

  @override
  void didUpdateWidget(HomeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prayerTimes != oldWidget.prayerTimes ||
        widget.place != oldWidget.place) {
      setState(() {
        prayerTimes = widget.prayerTimes;
        place = widget.place;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          DateTime current = DateTime.now();
          DateTime? next = prayerTimes.timeForPrayer(prayerTimes.nextPrayer());

          if (next != null) {
            Duration diff = current.difference(next).abs();
            formattedDiff = _formatDuration(diff);
          } else {
            formattedDiff =
                "N/A"; // Handle the case where next prayer time is null
          }
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure this is called to keep the state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              formattedDiff,
              style: cusTextStyle(55, FontWeight.w500),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "left until ",
                  style: cusTextStyle(24, FontWeight.w300),
                ),
                Row(
                  children: [
                    Text(
                      prayerTimes.nextPrayer().name[0].toUpperCase(),
                      style: cusTextStyle(24, FontWeight.w400),
                    ),
                    Text(
                      prayerTimes.nextPrayer().name.substring(1),
                      style: cusTextStyle(24, FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
            verticalBox(40),
            Row(
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
                      place.locality.toString(),
                      style: cusTextStyle(18, FontWeight.w200),
                    ),
                    Text(
                      ", ${place.isoCountryCode.toString()}",
                      style: cusTextStyle(18, FontWeight.w200),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
