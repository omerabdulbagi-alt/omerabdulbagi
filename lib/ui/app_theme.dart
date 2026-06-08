import 'package:flutter/material.dart';

class AppTheme {
  static const _background = Color(0xFF0E1117);
  static const _surface = Color(0xFF171B22);
  static const _accent = Color(0xFF36C78C);

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
      surface: _surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      cardTheme: const CardThemeData(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF20252D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _surface,
        indicatorColor: Color(0xFF245842),
        selectedIconTheme: IconThemeData(color: _accent),
        selectedLabelTextStyle: TextStyle(
          color: _accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
