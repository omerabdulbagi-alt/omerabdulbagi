import 'package:flutter/material.dart';

class AppTheme {
  static const _background = Color(0xFF08111F);
  static const _surface = Color(0xFF111D31);
  static const _accent = Color(0xFF5B8CFF);

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
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.28),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF17253B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? _accent : null,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _surface,
        indicatorColor: Color(0xFF223E72),
        selectedIconTheme: IconThemeData(color: _accent),
        selectedLabelTextStyle: TextStyle(
          color: _accent,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _surface,
        indicatorColor: Color(0xFF223E72),
        height: 68,
      ),
    );
  }
}
