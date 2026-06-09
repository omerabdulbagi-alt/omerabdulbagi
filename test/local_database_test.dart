import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_content_manager/core/local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('fresh database starts without channels, tasks, or content', () async {
    sqfliteFfiInit();
    final temp = await Directory.systemTemp.createTemp('contentflow_test_');
    await databaseFactoryFfi.setDatabasesPath(temp.path);
    final localDatabase = LocalDatabase(factory: databaseFactoryFfi);

    final db = await localDatabase.database;

    expect(await db.query('channels'), isEmpty);
    expect(await db.query('daily_tasks'), isEmpty);
    expect(await db.query('content_items'), isEmpty);

    await localDatabase.close();
    await temp.delete(recursive: true);
  });
}
