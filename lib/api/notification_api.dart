import 'package:adhan/adhan.dart';
import 'package:adhanminima/GetX/prayerdata.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final _localNotificationService = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> intialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_stat_ramadan');

    IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotificationService.initialize(
      settings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            channelDescription: 'description',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true);

    const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails();

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details);
  }

  Future<void> showScheduledNotification(
      {required int id,
      required String title,
      required String body,
      required DateTime time}) async {
    final details = await _notificationDetails();
    await _localNotificationService.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        time,
        tz.local,
      ),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showNotificationWithPayload(
      {required int id,
      required String title,
      required String body,
      required String payload}) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details,
        payload: payload);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void onSelectNotification(String? payload) {
    print('payload $payload');
    if (payload != null && payload.isNotEmpty) {
      onNotificationClick.add(payload);
    }
  }

  void setScheduledNotifications() async {
    final PrayerDataController prayerDataController =
        Get.put(PrayerDataController(), permanent: false);
    PrayerTimes? prayerTimes = prayerDataController.allData.prayerTimes;

    List prayerDetails = [
      {'Fajr': prayerTimes.fajr},
      {'Sunrise': prayerTimes.sunrise},
      {'Duhr': prayerTimes.dhuhr},
      {'Asr': prayerTimes.asr},
      {'Maghrib': prayerTimes.maghrib},
      {'Isha': prayerTimes.isha},
    ];
    final LocalNotificationService service = LocalNotificationService();
    for (int i = 0; i < prayerDetails.length; i++) {
      String prayer = prayerDetails[i]
          .keys
          .toString()
          .substring(1, prayerDetails[i].keys.toString().length - 1);
      String time = prayerDetails[i]
          .values
          .toString()
          .substring(1, prayerDetails[i].values.toString().length - 1);

      String timeFormat = DateFormat.jm().format(DateTime.parse(time));

      service.showScheduledNotification(
          id: i,
          title: "Time for $prayer",
          body: "$prayer at $timeFormat",
          time: prayerDetails[i].values.first);
    }
  }
}
