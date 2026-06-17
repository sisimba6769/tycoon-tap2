import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeProvider = StateProvider<bool>((ref) {
  final box = Hive.box('settings');
  return box.get('darkTheme', defaultValue: true) as bool;
});

class AppColors {
  static const background = Color(0xFF0A0A0F);
  static const accent = Color(0xFF1D9E75);
  static const accentLight = Color(0xFF2FCF99);
  static const purple = Color(0xFF7F77DD);
  static const textColor = Color(0xFFF0F0F0);
  static const glass = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const cardBg = Color(0x1A1D9E75);
  static const negative = Color(0xFFE74C3C);
  static const warning = Color(0xFFF39C12);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.purple,
          surface: Color(0xFF0F0F1A),
          background: AppColors.background,
          onPrimary: Colors.white,
          onSurface: AppColors.textColor,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.textColor),
          bodyMedium: TextStyle(color: Color(0xFFB0B0C0)),
        ),
        cardTheme: CardTheme(
          color: AppColors.glass,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.purple,
          surface: Color(0xFFF5F5F5),
          background: Color(0xFFEEEEF5),
          onPrimary: Colors.white,
          onSurface: Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFFEEEEF5),
        fontFamily: 'Roboto',
      );
}
