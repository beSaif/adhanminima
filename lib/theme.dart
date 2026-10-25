import 'package:flutter/material.dart';

/// Colours from the "Minima + Sun Arc nav" design.
abstract final class AppColors {
  static const background = Color(0xFF0B0B0C);
  static const text = Color(0xFFF5F5F7);
  static const secondary = Color(0xFF9A9AA0);
  static const tertiary = Color(0xFFC7C7CC);
  static const past = Color(0xFF8E8E93);
  static const upcoming = Color(0xFFE5E5EA);
  static const divider = Color(0xFF222225);
  static const dividerFaint = Color(0xFF1C1C1F);
  static const outline = Color(0xFF2A2A2E);
  static const tick = Color(0xFF3A3A3F);
  static const navBackground = Color(0xFF1C1C1F);
  static const accent = Color(0xFF2BD17E);
}

const tabularFigures = [FontFeature.tabularFigures()];

/// Horizontal padding shared by every screen.
const screenPadding = EdgeInsets.fromLTRB(28, 24, 28, 0);

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.background,
    surface: AppColors.background,
    onSurface: AppColors.text,
    outline: AppColors.outline,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'InterTight',
    dividerColor: AppColors.divider,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF141416),
      showDragHandle: true,
      dragHandleColor: AppColors.tick,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navBackground,
      contentTextStyle: TextStyle(color: AppColors.text, fontSize: 14),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
    ),
  );
}

/// Small uppercase heading used above settings groups.
const sectionLabelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.96,
  color: AppColors.secondary,
);
