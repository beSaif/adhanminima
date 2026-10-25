import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'state/settings_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter Tight',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });

  final notifications = NotificationService();
  PrayerAlerts? alerts = notifications;
  try {
    await notifications.init();
  } catch (e) {
    // The app still works without alerts, e.g. on unsupported platforms.
    debugPrint('Notifications unavailable: $e');
    alerts = null;
  }

  final state = AppState(store: PrefsSettingsStore(), alerts: alerts);
  await state.load();
  runApp(AdhaanApp(state: state));
}
