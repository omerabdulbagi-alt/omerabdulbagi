import 'package:flutter/material.dart';

extension LocalizedBuildContext on BuildContext {
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  String tr(String english, String arabic) => isArabic ? arabic : english;
}

String localizedEnum(
  BuildContext context,
  String value,
  Map<String, String> arabic,
) {
  return context.isArabic ? arabic[value] ?? value : value;
}
