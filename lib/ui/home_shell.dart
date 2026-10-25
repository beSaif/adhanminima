import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'pill_nav.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  static const _items = [
    PillNavItem('Today', Icons.schedule_rounded),
    PillNavItem('Qibla', Icons.explore_outlined),
    PillNavItem('Settings', Icons.tune_rounded),
  ];

  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A day may have passed while the app was in the background.
    if (state == AppLifecycleState.resumed) AppScope.read(context).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            const TodayScreen(),
            // Only listen to the compass while the tab is visible.
            QiblaScreen(active: _tab == 1),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(44, 8, 44, 8),
          child: PillNav(
            items: _items,
            selected: _tab,
            onSelected: (i) => setState(() => _tab = i),
          ),
        ),
      ),
    );
  }
}
