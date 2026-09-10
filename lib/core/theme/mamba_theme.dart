import 'package:flutter/material.dart';

class MambaTheme {
  static const Color background = Color(0xFF0A0E12);
  static const Color surface = Color(0xFF141A21);
  static const Color cardSurface = Color(0xFF1E2630);

  static const Color neonGold = Color(0xFFFFB800);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color alertRed = Color(0xFFFF5252);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BA8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonGold,
      colorScheme: const ColorScheme.dark(
        primary: neonGold,
        secondary: neonGreen,
        tertiary: neonCyan,
        surface: surface,
        error: alertRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        labelSmall: TextStyle(color: textMuted, fontSize: 12),
      ),
    );
  }
}
