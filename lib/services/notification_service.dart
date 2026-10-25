import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../prayer/prayer_schedule.dart';
import '../state/app_state.dart';

/// Prayer-time alerts through the platform notification system.
class NotificationService implements PrayerAlerts {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'prayer_times',
      'Prayer times',
      channelDescription: 'An alert when each prayer time begins',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      debugPrint('Could not resolve the local time zone: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_ramadan'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> schedule(List<PrayerTime> prayers, String placeLabel) async {
    await _plugin.cancelAll();
    // iOS keeps at most 64 pending notifications.
    for (final (i, p) in prayers.take(60).indexed) {
      await _plugin.zonedSchedule(
        id: i,
        title: p.prayer.label,
        body:
            'It is time for ${p.prayer.label} · ${formatClock(p.time)} in $placeLabel',
        scheduledDate: tz.TZDateTime.from(p.time, tz.local),
        notificationDetails: _details,
        // Exact alarms need a permission users must grant by hand on
        // Android 14+; inexact delivery is close enough for an alert.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
