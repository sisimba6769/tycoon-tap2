import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Light theme was removed by request — the app is always dark.
final themeProvider = StateProvider<bool>((ref) => true);

class AppColors {
  /// Global theme flag. Updated from the root widget on every rebuild so that
  /// the adaptive getters below return the right colors for the active theme.
  static bool isDark = true;

  // --- Theme-adaptive colors (getters, so they follow [isDark]) ---
  static Color get background =>
      isDark ? const Color(0xFF0A0A0F) : const Color(0xFFEEF1F7);
  static Color get textColor =>
      isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A1A2E);
  // In light mode cards are near-opaque white (clean cards), in dark mode a
  // subtle translucent white (frosted glass).
  static Color get glass =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0xF2FFFFFF);
  static Color get glassBorder =>
      isDark ? const Color(0x33FFFFFF) : const Color(0x14000000);
  // Secondary / muted text that adapts to the theme.
  static Color get subtleText =>
      isDark ? const Color(0xFFB0B0C0) : const Color(0xFF6B6B80);
  // Shadow used by cards; much lighter in light mode.
  static Color get cardShadow =>
      isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06);

  // --- Fixed accent colors (same in both themes) ---
  static const accent = Color(0xFF1D9E75);
  static const accentLight = Color(0xFF2FCF99);
  static const purple = Color(0xFF7F77DD);
  static const cardBg = Color(0x1A1D9E75);
  static const negative = Color(0xFFE74C3C);
  static const warning = Color(0xFFF39C12);

  // Light theme reference colors
  static const lightBackground = Color(0xFFF0F0F5);
  static const lightText = Color(0xFF1A1A2E);
  static const lightGlass = Color(0xF2FFFFFF);
  static const lightGlassBorder = Color(0x14000000);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.purple,
          surface: Color(0xFF0F0F1A),
          background: Color(0xFF0A0A0F),
          onPrimary: Colors.white,
          onSurface: Color(0xFFF0F0F0),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFFF0F0F0), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFF0F0F0)),
          bodyMedium: TextStyle(color: Color(0xFFB0B0C0)),
        ),
        cardTheme: CardTheme(
          color: const Color(0x1AFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected) ? AppColors.accent : Colors.grey),
          trackColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected) ? AppColors.accent.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.purple,
          surface: Color(0xFFFFFFFF),
          background: AppColors.lightBackground,
          onPrimary: Colors.white,
          onSurface: AppColors.lightText,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.lightText),
          bodyMedium: TextStyle(color: Color(0xFF555566)),
        ),
        cardTheme: CardTheme(
          color: Colors.white.withOpacity(0.8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected) ? AppColors.accent : Colors.grey),
          trackColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected) ? AppColors.accent.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
        ),
      );
}
