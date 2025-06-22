// ignore_for_file: file_names

import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:adhanminima/utils/sizedbox.dart';
import 'package:adhanminima/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:adhanminima/controllers/prayer_offset_controller.dart';

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
  String formattedDiff = "";
  int _previousDiffSeconds = 0;
  int _targetDiffSeconds = 0;

  @override
  void initState() {
    super.initState();
    prayerTimes = widget.prayerTimes;
    place = widget.place;
    _initializeFormattedDiff(); // Initialize the formattedDiff before starting the timer
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
        _initializeFormattedDiff(); // Update the formattedDiff when the widget updates
      });
    }
  }

  void _initializeFormattedDiff() {
    DateTime current = DateTime.now();
    final nextPrayerEnum = prayerTimes.nextPrayer();
    DateTime? next = prayerTimes.timeForPrayer(nextPrayerEnum);
    final PrayerOffsetController offsetController = Get.find();
    if (next != null) {
      // Apply offset from controller using enum as key
      final offset = offsetController.prayerOffsets[nextPrayerEnum] ?? 0;
      next = next.add(Duration(minutes: offset));
      Duration diff = next.difference(current);
      _previousDiffSeconds = _targetDiffSeconds;
      _targetDiffSeconds = diff.inSeconds;
      formattedDiff = _formatDuration(diff.abs());
    } else {
      formattedDiff = "N/A"; // Handle the case where next prayer time is null
      _previousDiffSeconds = _targetDiffSeconds = 0;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          DateTime current = DateTime.now();
          final nextPrayerEnum = prayerTimes.nextPrayer();
          DateTime? next = prayerTimes.timeForPrayer(nextPrayerEnum);
          final PrayerOffsetController offsetController = Get.find();
          if (next != null) {
            // Apply offset from controller using enum as key
            final offset = offsetController.prayerOffsets[nextPrayerEnum] ?? 0;
            next = next.add(Duration(minutes: offset));
            Duration diff = next.difference(current);
            _previousDiffSeconds = _targetDiffSeconds;
            _targetDiffSeconds = diff.inSeconds;
            formattedDiff = _formatDuration(diff.abs());
          } else {
            formattedDiff =
                "N/A"; // Handle the case where next prayer time is null
            _previousDiffSeconds = _targetDiffSeconds = 0;
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
    return GetBuilder<PrayerOffsetController>(
      builder: (offsetController) {
        // Recalculate on offset change
        DateTime current = DateTime.now();
        final nextPrayerEnum = prayerTimes.nextPrayer();
        DateTime? next = prayerTimes.timeForPrayer(nextPrayerEnum);
        int begin = _previousDiffSeconds;
        int end = _targetDiffSeconds;
        if (next != null) {
          final offset = offsetController.prayerOffsets[nextPrayerEnum] ?? 0;
          next = next.add(Duration(minutes: offset));
          Duration diff = next.difference(current);
          begin = _previousDiffSeconds;
          end = diff.inSeconds;
        } else {
          begin = end = 0;
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: begin, end: end),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    final duration = Duration(seconds: value.abs());
                    return Text(
                      _formatDuration(duration),
                      style: cusTextStyle(55, FontWeight.w500),
                    );
                  },
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
      },
    );
  }
}
