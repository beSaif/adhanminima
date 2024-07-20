import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';

class NotificationApi {
  var notificationList = [];
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: "Your description",
            importance: Importance.max));
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@drawable/ic_stat_ramadan');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings, onSelectNotification: ((payload) {
      onNotifications.add(payload);
    }));

    if (initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    DateTime? times,
    required DateTime scheduleDate,
  }) async {
    _notifications.zonedSchedule(id, title, body,
        _scheduleDaily(times!, payload!), await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);

    //print("$id $title Added");
  }

  Future<int> listOfNotifications() async {
    final List pendingNotificationRequest =
        await FlutterLocalNotificationsPlugin().pendingNotificationRequests();

    // for (int i = 0; i < pendingNotificationRequest.length; i++) {
    //   print("$i : ${pendingNotificationRequest[i].title![9]}");
    // }
    // print(pendingNotificationRequest[id].title![9]);
    // print("Notification exists");
    return pendingNotificationRequest.length;
  }

  static tz.TZDateTime _scheduleDaily(DateTime time, String payload) {
    final now = tz.TZDateTime.now(
      tz.local,
    );

    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);

    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  static void deleteNotification(int id) {
    _notifications.cancel(id);
    //_notifications.cancelAll();
    //print("notifcation deleetd $id");
  }

  static void deleteAll() {
    //_notifications.cancel(id);
    _notifications.cancelAll();
    //print("Deleted All Notifications");
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(id, title, body, await _notificationDetails(),
          payload: payload);
}
