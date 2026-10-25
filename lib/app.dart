import 'package:flutter/material.dart';

import 'services/compass_service.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'ui/home_shell.dart';
import 'ui/onboarding_screen.dart';

class AdhaanApp extends StatelessWidget {
  const AdhaanApp({super.key, required this.state, this.compass});

  final AppState state;

  /// Replaces the device compass, e.g. for screenshots.
  final CompassService? compass;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Adhaan',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: _Root(compass: compass),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({this.compass});

  final CompassService? compass;

  @override
  Widget build(BuildContext context) {
    final hasPlace = AppScope.of(context).place != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: hasPlace
          ? HomeShell(key: const ValueKey('home'), compass: compass)
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}
