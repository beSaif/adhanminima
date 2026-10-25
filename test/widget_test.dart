import 'package:adhan/adhan.dart';
import 'package:adhanminima/app.dart';
import 'package:adhanminima/prayer/prayer_schedule.dart';
import 'package:adhanminima/state/app_state.dart';
import 'package:adhanminima/state/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const geneva = SavedPlace(
  latitude: 46.2044,
  longitude: 6.1432,
  label: 'Geneva, CH',
);

/// A state for Geneva whose clock sits one minute after Dhuhr.
Future<AppState> genevaAfterDhuhr() async {
  final probe = AppState(store: MemorySettingsStore());
  await probe.setPlace(geneva);
  final dhuhr = prayersOn(DateTime(2026, 10, 25), probe.inputs!)[2].time;
  final state = AppState(
    store: MemorySettingsStore(),
    clock: () => dhuhr.add(const Duration(minutes: 1)),
  );
  await state.setPlace(geneva);
  return state;
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('first run asks for a location', (tester) async {
    final state = AppState(store: MemorySettingsStore());
    await tester.pumpWidget(AdhaanApp(state: state));
    expect(find.text('Prayer times begin with where you are.'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);
    expect(find.text('Choose a city instead'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('Today counts down to Asr after Dhuhr', (tester) async {
    final state = await genevaAfterDhuhr();
    await tester.pumpWidget(AdhaanApp(state: state));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Geneva, CH'), findsOneWidget);
    expect(find.text('Asr in'), findsOneWidget);
    for (final p in dailyPrayers) {
      expect(find.text(p.label), findsOneWidget);
    }
    await unmount(tester);
  });

  testWidgets('tabs switch to Settings and back', (tester) async {
    final state = await genevaAfterDhuhr();
    await tester.pumpWidget(AdhaanApp(state: state));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Method'), findsOneWidget);
    expect(find.text('Karachi'), findsOneWidget);

    // Nudging an offset updates the persisted state.
    await tester.tap(find.bySemanticsLabel('Maghrib one minute later'));
    await tester.pump();
    expect(state.offsets[Prayer.maghrib], 1);

    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Asr in'), findsOneWidget);
    await unmount(tester);
  });
}
