import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final basePath = await databaseFactory.getDatabasesPath();
    _database = await databaseFactory.openDatabase(
      p.join(basePath, 'my_content_manager.db'),
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE channels (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              platform TEXT NOT NULL,
              color_value INTEGER NOT NULL
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
          await _seedChannels(db);
          await _seedSampleContent(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createMetadataTable(db);
            await _seedSampleContent(db);
          }
          if (oldVersion < 3) {
            await _migrateToManualTasks(db);
          }
          if (oldVersion < 4) {
            await db.delete('daily_tasks');
          }
        },
      ),
    );
    return _database!;
  }

  Future<void> _seedChannels(Database db) async {
    final channels = [
      ['زولي عربي', 'YouTube', 0xFFFF5252],
      ['Zooli English', 'YouTube', 0xFF42A5F5],
      ['القرآن والمديح', 'YouTube', 0xFF66BB6A],
      ['بلد 360', 'Facebook', 0xFF5C6BC0],
      ['زولي عربي', 'TikTok', 0xFFAB47BC],
    ];
    for (final channel in channels) {
      await db.insert('channels', {
        'name': channel[0],
        'platform': channel[1],
        'color_value': channel[2],
      });
    }
  }

  Future<void> _createMetadataTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
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
        created_at TEXT NOT NULL,
        FOREIGN KEY(channel_id) REFERENCES channels(id)
      )
    ''');
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

  Future<void> _seedSampleContent(DatabaseExecutor db) async {
    const seedKey = 'realistic_sample_content_v1';
    final existingSeed = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [seedKey],
      limit: 1,
    );
    if (existingSeed.isNotEmpty) return;

    final channels = await db.query('channels');
    int channelId(String name, String platform) {
      final channel = channels.firstWhere(
        (row) => row['name'] == name && row['platform'] == platform,
      );
      return channel['id'] as int;
    }

    final now = DateTime.now();
    DateTime scheduledDay(int offset, [int hour = 10]) =>
        DateTime(now.year, now.month, now.day + offset, hour);

    final samples = [
      _SampleContent(
        title: 'كيف تخطط لأسبوع منتج بدون ضغط؟',
        channelId: channelId('زولي عربي', 'YouTube'),
        type: 'فيديو طويل',
        status: 'editing',
        description:
            'حلقة عملية عن تقسيم الأهداف الأسبوعية وبناء روتين بسيط قابل للاستمرار.',
        notes: 'إضافة أمثلة بصرية ومراجعة المقدمة قبل التصدير.',
        scheduledDate: scheduledDay(2, 18),
      ),
      _SampleContent(
        title: '5 Simple Habits for a More Focused Week',
        channelId: channelId('Zooli English', 'YouTube'),
        type: 'فيديو طويل',
        status: 'scripting',
        description:
            'A practical video about planning, focus, and building sustainable weekly habits.',
        notes: 'Finish the hook and prepare the B-roll list.',
        scheduledDate: scheduledDay(4, 17),
      ),
      _SampleContent(
        title: 'ورد اليوم: سورة الملك مع معاني مختارة',
        channelId: channelId('القرآن والمديح', 'YouTube'),
        type: 'فيديو قصير',
        status: 'ready',
        description:
            'تلاوة هادئة لآيات من سورة الملك مع معنى موجز يساعد على التدبر.',
        notes: 'الصوت والصورة جاهزان للنشر.',
        scheduledDate: scheduledDay(0, 20),
      ),
      _SampleContent(
        title: 'مديح الصباح: الصلاة على النبي ﷺ',
        channelId: channelId('القرآن والمديح', 'YouTube'),
        type: 'فيديو قصير',
        status: 'planned',
        description: 'مقطع صباحي يومي قصير من المديح والصلاة على النبي.',
        notes: 'اختيار خلفية هادئة وكتابة النص على الشاشة.',
        scheduledDate: scheduledDay(1, 8),
      ),
      _SampleContent(
        title: 'تلاوة يوم الجمعة: سورة الكهف',
        channelId: channelId('القرآن والمديح', 'YouTube'),
        type: 'فيديو طويل',
        status: 'published',
        description: 'تلاوة مختارة من سورة الكهف للنشر الأسبوعي.',
        notes: 'تم النشر ومراجعة الوصف.',
        scheduledDate: scheduledDay(-1, 12),
        publishedUrl: 'https://youtube.com/',
      ),
      _SampleContent(
        title: 'ثلاثة أماكن تستحق الزيارة في عطلة نهاية الأسبوع',
        channelId: channelId('بلد 360', 'Facebook'),
        type: 'منشور',
        status: 'planned',
        description:
            'منشور مصور يقترح ثلاث وجهات محلية مناسبة للعائلة والأصدقاء.',
        notes: 'تأكيد أوقات العمل وإضافة الموقع لكل وجهة.',
        scheduledDate: scheduledDay(3, 14),
      ),
      _SampleContent(
        title: 'صورة اليوم: حكاية من السوق القديم',
        channelId: channelId('بلد 360', 'Facebook'),
        type: 'منشور',
        status: 'published',
        description:
            'صورة أرشيفية مع قصة قصيرة عن تفاصيل الحياة في السوق القديم.',
        notes: 'تم النشر مع سؤال للجمهور في نهاية النص.',
        scheduledDate: scheduledDay(0, 11),
        publishedUrl: 'https://facebook.com/',
      ),
      _SampleContent(
        title: 'نصيحة في 30 ثانية: ابدأ بأصعب مهمة',
        channelId: channelId('زولي عربي', 'TikTok'),
        type: 'فيديو قصير',
        status: 'recording',
        description:
            'مقطع سريع يشرح لماذا يساعد بدء اليوم بالمهمة الأصعب على الإنجاز.',
        notes: 'تصوير نسختين بخطافين مختلفين.',
        scheduledDate: scheduledDay(0, 19),
      ),
    ];

    for (final sample in samples) {
      await db.insert('content_items', sample.toMap());
    }

    await db.insert('app_metadata', {'key': seedKey, 'value': 'inserted'});
  }
}

class _SampleContent {
  const _SampleContent({
    required this.title,
    required this.channelId,
    required this.type,
    required this.status,
    required this.description,
    required this.notes,
    required this.scheduledDate,
    this.publishedUrl = '',
  });

  final String title;
  final int channelId;
  final String type;
  final String status;
  final String description;
  final String notes;
  final DateTime scheduledDate;
  final String publishedUrl;

  Map<String, Object?> toMap() => {
    'title': title,
    'channel_id': channelId,
    'type': type,
    'status': status,
    'description': description,
    'notes': notes,
    'scheduled_date': scheduledDate.toIso8601String(),
    'published_url': publishedUrl,
    'updated_at': DateTime.now().toIso8601String(),
  };
}
