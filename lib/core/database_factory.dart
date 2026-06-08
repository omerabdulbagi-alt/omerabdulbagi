import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as desktop;

DatabaseFactory createDatabaseFactory() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return mobile.databaseFactory;
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      desktop.sqfliteFfiInit();
      return desktop.databaseFactoryFfi;
    case TargetPlatform.fuchsia:
      throw UnsupportedError(
        'Local storage is not supported on this platform.',
      );
  }
}
