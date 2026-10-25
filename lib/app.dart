import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'theme.dart';
import 'ui/home_shell.dart';
import 'ui/onboarding_screen.dart';

class AdhaanApp extends StatelessWidget {
  const AdhaanApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Adhaan',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final hasPlace = AppScope.of(context).place != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: hasPlace
          ? const HomeShell(key: ValueKey('home'))
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}
