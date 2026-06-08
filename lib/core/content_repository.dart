import 'package:sqflite_common/sqlite_api.dart';

import 'local_database.dart';
import 'models.dart';

class ContentRepository {
  ContentRepository(this._localDatabase);
  final LocalDatabase _localDatabase;

  Future<List<Channel>> getChannels() async {
    final db = await _localDatabase.database;
    return (await db.query(
      'channels',
      orderBy: '''
        CASE name
          WHEN 'Zooli Arabic' THEN 1
          WHEN 'Zooli English' THEN 2
          WHEN 'Zooli Arabic TikTok' THEN 3
          WHEN 'Balad360' THEN 4
          WHEN 'Quran' THEN 5
          WHEN 'Madih' THEN 6
          ELSE 99
        END
      ''',
    )).map(Channel.fromMap).toList();
  }

  Future<int> saveChannel(Channel channel) async {
    final db = await _localDatabase.database;
    final values = channel.toMap()..remove('id');
    if (channel.id == null) return db.insert('channels', values);
    await db.update(
      'channels',
      values,
      where: 'id = ?',
      whereArgs: [channel.id],
    );
    return channel.id!;
  }

  Future<void> archiveChannel(int id, bool archived) async {
    final db = await _localDatabase.database;
    await db.update(
      'channels',
      {'archived': archived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCustomChannel(int id) async {
    final db = await _localDatabase.database;
    final taskRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM daily_tasks WHERE channel_id = ?',
      [id],
    );
    final contentRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM content_items WHERE channel_id = ?',
      [id],
    );
    final taskCount = taskRows.first['count'] as int? ?? 0;
    final contentCount = contentRows.first['count'] as int? ?? 0;
    if (taskCount + contentCount > 0) {
      await archiveChannel(id, true);
    } else {
      await db.delete('channels', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<Set<String>> getDismissedSuggestions(String date) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'dismissed_suggestions',
      columns: ['suggestion_key'],
      where: 'suggestion_date = ?',
      whereArgs: [date],
    );
    return rows.map((row) => row['suggestion_key'] as String).toSet();
  }

  Future<void> dismissSuggestion(String key, String date) async {
    final db = await _localDatabase.database;
    await db.insert(
      'dismissed_suggestions',
      {'suggestion_key': key, 'suggestion_date': date},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<ContentItem>> getContentItems() async {
    final db = await _localDatabase.database;
    return (await db.query(
      'content_items',
      orderBy: 'scheduled_date IS NULL, scheduled_date, updated_at DESC',
    )).map(ContentItem.fromMap).toList();
  }

  Future<void> saveContent(ContentItem item) async {
    final db = await _localDatabase.database;
    final values = item.toMap()..remove('id');
    if (item.id == null) {
      await db.insert('content_items', values);
    } else {
      await db.update(
        'content_items',
        values,
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<void> deleteContent(int id) async {
    final db = await _localDatabase.database;
    await db.delete('content_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ManualTask>> getTasks() async {
    final db = await _localDatabase.database;
    return (await db.query(
      'daily_tasks',
      orderBy: 'due_date, priority DESC',
    )).map(ManualTask.fromMap).toList();
  }

  Future<int> saveTask(ManualTask task) async {
    final db = await _localDatabase.database;
    final values = task.toMap()..remove('id');
    if (task.id == null) {
      return db.insert('daily_tasks', values);
    } else {
      await db.update(
        'daily_tasks',
        values,
        where: 'id = ?',
        whereArgs: [task.id],
      );
      return task.id!;
    }
  }

  Future<void> deleteTask(int id) async {
    final db = await _localDatabase.database;
    await db.delete('daily_tasks', where: 'id = ?', whereArgs: [id]);
  }
}
