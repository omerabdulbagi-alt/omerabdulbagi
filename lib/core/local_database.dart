import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory.dart';

class LocalDatabase {
  LocalDatabase({DatabaseFactory? factory})
    : _databaseFactory = factory ?? createDatabaseFactory();

  final DatabaseFactory _databaseFactory;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final basePath = await _databaseFactory.getDatabasesPath();
    _database = await _databaseFactory.openDatabase(
      p.join(basePath, 'my_content_manager.db'),
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE channels (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              platform TEXT NOT NULL,
              color_value INTEGER NOT NULL,
              icon_key TEXT NOT NULL DEFAULT 'video',
              is_default INTEGER NOT NULL DEFAULT 0,
              archived INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE content_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              channel_id INTEGER NOT NULL,
              type TEXT NOT NULL,
              status TEXT NOT NULL,
              description TEXT NOT NULL DEFAULT '',
              notes TEXT NOT NULL DEFAULT '',
              scheduled_date TEXT,
              published_url TEXT NOT NULL DEFAULT '',
              updated_at TEXT NOT NULL,
              FOREIGN KEY(channel_id) REFERENCES channels(id)
            )
          ''');
          await _createManualTasksTable(db);
          await _createMetadataTable(db);
          await _createDismissedSuggestionsTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createMetadataTable(db);
          }
          if (oldVersion < 3) {
            await _migrateToManualTasks(db);
          }
          if (oldVersion < 4) {
            await db.delete('daily_tasks');
          }
          if (oldVersion < 5) {
            await _upgradeToEnglishChannelsAndTaskState(db);
          }
          if (oldVersion < 6) {
            await _upgradeToChannelManagement(db);
          }
          if (oldVersion < 7) {
            await _upgradeToContentFlow(db);
          }
        },
      ),
    );
    return _database!;
  }

  Future<void> _upgradeToChannelManagement(Database db) async {
    await db.execute(
      "ALTER TABLE channels ADD COLUMN icon_key TEXT NOT NULL DEFAULT 'video'",
    );
    await db.execute(
      'ALTER TABLE channels ADD COLUMN is_default INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE channels ADD COLUMN archived INTEGER NOT NULL DEFAULT 0',
    );
    await _createDismissedSuggestionsTable(db);

    await db.execute("""
      UPDATE daily_tasks
      SET task_type = CASE task_type
        WHEN 'fullYouTubeVideo' THEN 'video'
        WHEN 'youtubeShort' THEN 'short'
        WHEN 'tiktokVideo' THEN 'short'
        WHEN 'facebookPost' THEN 'post'
        WHEN 'madihContent' THEN 'audio'
        WHEN 'other' THEN 'task'
        ELSE task_type
      END
    """);
  }

  Future<void> _createMetadataTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDismissedSuggestionsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dismissed_suggestions (
        suggestion_key TEXT NOT NULL,
        suggestion_date TEXT NOT NULL,
        PRIMARY KEY (suggestion_key, suggestion_date)
      )
    ''');
  }

  Future<void> _createManualTasksTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE daily_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        channel_id INTEGER NOT NULL,
        task_type TEXT NOT NULL,
        due_date TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        completed INTEGER NOT NULL DEFAULT 0,
        reminder_at TEXT,
        recurrence_type TEXT NOT NULL DEFAULT 'none',
        recurrence_interval INTEGER NOT NULL DEFAULT 1,
        recurrence_weekdays TEXT NOT NULL DEFAULT '',
        recurrence_month_day INTEGER,
        recurrence_group TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(channel_id) REFERENCES channels(id)
      )
    ''');
  }

  Future<void> _upgradeToContentFlow(Database db) async {
    await db.execute(
      "ALTER TABLE daily_tasks ADD COLUMN recurrence_type TEXT NOT NULL DEFAULT 'none'",
    );
    await db.execute(
      'ALTER TABLE daily_tasks ADD COLUMN recurrence_interval INTEGER NOT NULL DEFAULT 1',
    );
    await db.execute(
      "ALTER TABLE daily_tasks ADD COLUMN recurrence_weekdays TEXT NOT NULL DEFAULT ''",
    );
    await db.execute(
      'ALTER TABLE daily_tasks ADD COLUMN recurrence_month_day INTEGER',
    );
    await db.execute(
      'ALTER TABLE daily_tasks ADD COLUMN recurrence_group TEXT',
    );
    await db.update('channels', {'is_default': 0});
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert('app_metadata', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _upgradeToEnglishChannelsAndTaskState(Database db) async {
    await db.execute(
      "ALTER TABLE daily_tasks ADD COLUMN completed INTEGER NOT NULL DEFAULT 0",
    );
    await db.execute('ALTER TABLE daily_tasks ADD COLUMN reminder_at TEXT');

    await db.update('channels', {
      'name': 'Zooli Arabic',
    }, where: "name = 'زولي عربي' AND platform = 'YouTube'");
    await db.update('channels', {
      'name': 'Zooli Arabic TikTok',
    }, where: "name = 'زولي عربي' AND platform = 'TikTok'");
    await db.update('channels', {
      'name': 'Balad360',
    }, where: "name = 'بلد 360'");
    await db.execute("""
      UPDATE content_items
      SET type = CASE type
        WHEN 'فيديو طويل' THEN 'Full Video'
        WHEN 'فيديو قصير' THEN 'Short Video'
        WHEN 'منشور' THEN 'Post'
        WHEN 'بث مباشر' THEN 'Live Stream'
        ELSE type
      END
    """);

    final combined = await db.query(
      'channels',
      columns: ['id'],
      where: "name = 'القرآن والمديح'",
      limit: 1,
    );
    if (combined.isNotEmpty) {
      final quranId = combined.first['id'] as int;
      await db.update(
        'channels',
        {'name': 'Quran', 'color_value': 0xFF66BB6A},
        where: 'id = ?',
        whereArgs: [quranId],
      );
      final madihId = await db.insert('channels', {
        'name': 'Madih',
        'platform': 'YouTube',
        'color_value': 0xFFFFB74D,
      });
      await db.update(
        'content_items',
        {'channel_id': madihId},
        where:
            "channel_id = ? AND (title LIKE '%مديح%' OR description LIKE '%مديح%')",
        whereArgs: [quranId],
      );
      await db.update(
        'daily_tasks',
        {'channel_id': madihId},
        where: "channel_id = ? AND task_type = 'madihContent'",
        whereArgs: [quranId],
      );
    } else {
      final madih = await db.query(
        'channels',
        where: "name = 'Madih'",
        limit: 1,
      );
      if (madih.isEmpty) {
        await db.insert('channels', {
          'name': 'Madih',
          'platform': 'YouTube',
          'color_value': 0xFFFFB74D,
        });
      }
    }
  }

  Future<void> _migrateToManualTasks(Database db) async {
    await db.execute('ALTER TABLE daily_tasks RENAME TO generated_tasks');
    await _createManualTasksTable(db);
    await db.execute('''
      INSERT INTO daily_tasks (
        title, channel_id, task_type, due_date,
        priority, status, notes, created_at
      )
      SELECT
        generated_tasks.title,
        content_items.channel_id,
        CASE
          WHEN content_items.type = 'فيديو طويل' THEN 'fullYouTubeVideo'
          WHEN channels.platform = 'TikTok' THEN 'tiktokVideo'
          WHEN channels.platform = 'Facebook' THEN 'facebookPost'
          WHEN channels.name = 'القرآن والمديح' THEN 'madihContent'
          WHEN content_items.type = 'فيديو قصير' THEN 'youtubeShort'
          ELSE 'other'
        END,
        generated_tasks.due_date,
        'medium',
        CASE
          WHEN generated_tasks.completed = 1 THEN 'published'
          WHEN content_items.status IN ('editing', 'recording', 'scripting')
            THEN 'inProgress'
          WHEN content_items.status = 'ready' THEN 'ready'
          WHEN content_items.status = 'published' THEN 'published'
          ELSE 'planned'
        END,
        content_items.notes,
        content_items.updated_at
      FROM generated_tasks
      JOIN content_items ON content_items.id = generated_tasks.content_id
      JOIN channels ON channels.id = content_items.channel_id
    ''');
    await db.execute('DROP TABLE generated_tasks');
  }
}
