import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const primary = Color(0xFF006194);
  static const secondary = Color(0xFF565E74);
  static const tertiary = Color(0xFF006947);
  static const surface = Color(0xFFF7F9FB);
  static const error = Color(0xFFBA1A1A);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, secondary: secondary, tertiary: tertiary, surface: surface, error: error);
    return _themeFrom(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark);
    return _themeFrom(colorScheme);
  }

  static ThemeData _themeFrom(ColorScheme colorScheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    final theme = base.copyWith(
      textTheme: GoogleFonts.interTextTheme() as TextTheme?,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
    return theme;
  }
}
