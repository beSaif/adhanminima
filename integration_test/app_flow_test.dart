import 'dart:io';

import 'package:adhanminima/main.dart' as app;
import 'package:adhanminima/services/compass_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Walks the main flows on a real simulator or emulator and saves a
/// screenshot of each screen. Run it with tool/screenshots.sh.
///
/// Pick a city in the machine's own time zone: prayer times are shown in
/// device time. Override with --dart-define=SCREENSHOT_CITY=...
const city = String.fromEnvironment('SCREENSHOT_CITY', defaultValue: 'Geneva');

/// Start with Geneva already saved and skip onboarding, for emulators whose
/// platform geocoder doesn't work (--dart-define=SEED_PLACE=true).
const seedPlace = bool.fromEnvironment('SEED_PLACE');

/// iOS simulators have no compass, so they get a steady heading a little to
/// the left of the Qibla from Geneva (121°). The no-compass fallback is
/// covered by test/compass_service_test.dart.
CompassService? screenshotCompass() => Platform.isIOS
    ? CompassService(
        events: Stream.periodic(
          const Duration(milliseconds: 250),
          (_) => CompassEvent.fromList([111, 111, 5]),
        ),
      )
    : null;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        fail('Timed out waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    // Let page transitions and the keyboard finish before capturing.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await binding.takeScreenshot(name);
  }

  Future<void> chooseCity(WidgetTester tester) async {
    await pumpUntil(tester, find.text('Choose a city instead'));
    await shoot(tester, '04_onboarding');
    await tester.tap(find.text('Choose a city instead'));
    await pumpUntil(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), city);
    final result = find.ancestor(
      of: find.textContaining(city),
      matching: find.byType(InkWell),
    );
    // The platform geocoders are rate-limited and occasionally fail; the app
    // shows an error and lets the user search again, so the test does too.
    for (var attempt = 1; ; attempt++) {
      await tester.testTextInput.receiveAction(TextInputAction.search);
      try {
        await pumpUntil(tester, result, timeout: const Duration(seconds: 10));
        break;
      } on TestFailure {
        if (attempt == 4) rethrow;
        debugPrint('SEARCH: attempt $attempt failed, retrying');
        await Future<void>.delayed(Duration(seconds: 5 * attempt));
      }
    }
    await tester.tap(result.first);
  }

  testWidgets('onboarding, Today, Qibla and Settings', (tester) async {
    // The same store the app uses (DataStore on Android, not the legacy one).
    final prefs = SharedPreferencesAsync();
    await prefs.clear();
    if (seedPlace) {
      await prefs.setDouble('place.latitude', 46.2044);
      await prefs.setDouble('place.longitude', 6.1432);
      await prefs.setString('place.label', 'Geneva, CH');
    }
    app.start(compass: screenshotCompass());
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    if (seedPlace) {
      debugPrint('ONBOARDING: skipped, place seeded');
    } else {
      await chooseCity(tester);
    }

    // Today: the countdown and all five prayers.
    await pumpUntil(tester, find.text('Fajr'));
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data?.endsWith(' in') ?? false),
      ),
      findsOneWidget,
      reason: 'countdown to the next prayer',
    );
    for (final name in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      expect(find.text(name), findsWidgets, reason: '$name row on Today');
    }
    await shoot(tester, '01_today');

    // Qibla: a heading or the no-compass fallback, never a stuck spinner.
    await tester.tap(find.text('Qibla'));
    await pumpUntil(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            const [
              'This device has no compass',
              'Turn slowly',
              'You are facing the Qibla',
            ].any((s) => w.data?.startsWith(s) ?? false),
      ),
      timeout: const Duration(seconds: 12),
    );
    expect(find.text('Waiting for the compass…'), findsNothing);
    final fallback = find.textContaining('This device has no compass');
    debugPrint(
      fallback.evaluate().isEmpty
          ? 'QIBLA: live compass heading'
          : 'QIBLA: no-compass fallback shown',
    );
    await shoot(tester, '02_qibla');

    // Settings: alerts, then method and offsets.
    await tester.tap(find.text('Settings'));
    await pumpUntil(tester, find.text('Method'));
    if (Platform.isAndroid) {
      // POST_NOTIFICATIONS is granted ahead of time by tool/screenshots.sh;
      // the iOS permission prompt can't be answered from a test.
      // The row text and the switch share this label; the switch is last.
      // On short screens it sits below the fold, so scroll to it first.
      final toggle = find.bySemanticsLabel('Alert at each prayer').last;
      await tester.ensureVisible(toggle);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(toggle);
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Notifications are blocked'), findsNothing);
      expect(tester.getSemantics(toggle), isSemantics(isToggled: true));
      debugPrint('ALERTS: enabled');
    }
    await shoot(tester, '03_settings');

    await tester.tap(find.text('Method'));
    await pumpUntil(tester, find.text('Calculation method'));
    expect(find.text('Muslim World League'), findsWidgets);
    await tester.tap(find.text('Muslim World League').last);
    // Wait for the sheet to close fully so its barrier can't swallow taps.
    final sheetEnd = DateTime.now().add(const Duration(seconds: 5));
    while (find.text('Calculation method').evaluate().isNotEmpty &&
        DateTime.now().isBefore(sheetEnd)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Calculation method'), findsNothing);
    expect(find.text('Muslim World League'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Maghrib one minute later'));
    await tester.pump();
    expect(find.text('+1'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Maghrib one minute earlier'));
    await tester.pump();
    expect(find.text('+1'), findsNothing);
    debugPrint('SETTINGS: method and offsets OK');
  });
}
