import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({this.localeCode = 'en', this.themeMode = ThemeMode.light});

  final String localeCode;
  final ThemeMode themeMode;

  Locale get locale => Locale(localeCode);

  AppSettings copyWith({String? localeCode, ThemeMode? themeMode}) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
