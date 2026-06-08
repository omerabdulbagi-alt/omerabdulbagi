enum WorkflowStatus {
  idea('فكرة'),
  planned('مخطط'),
  scripting('كتابة'),
  recording('تسجيل'),
  editing('مونتاج'),
  ready('جاهز'),
  published('منشور');

  const WorkflowStatus(this.label);
  final String label;
}

class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.platform,
    required this.colorValue,
  });

  final int id;
  final String name;
  final String platform;
  final int colorValue;

  String get taskLabel {
    if (platform == 'TikTok') return 'Zooli Arabic TikTok';
    if (platform == 'Facebook') return 'Balad360';
    if (name == 'Zooli English') return 'Zooli English';
    if (name == 'القرآن والمديح') return 'Quran and Madih';
    return 'Zooli Arabic';
  }

  factory Channel.fromMap(Map<String, Object?> map) => Channel(
    id: map['id'] as int,
    name: map['name'] as String,
    platform: map['platform'] as String,
    colorValue: map['color_value'] as int,
  );
}

class ContentItem {
  const ContentItem({
    this.id,
    required this.title,
    required this.channelId,
    required this.type,
    required this.status,
    this.description = '',
    this.notes = '',
    this.scheduledDate,
    this.publishedUrl = '',
  });

  final int? id;
  final String title;
  final int channelId;
  final String type;
  final WorkflowStatus status;
  final String description;
  final String notes;
  final DateTime? scheduledDate;
  final String publishedUrl;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'channel_id': channelId,
    'type': type,
    'status': status.name,
    'description': description,
    'notes': notes,
    'scheduled_date': scheduledDate?.toIso8601String(),
    'published_url': publishedUrl,
    'updated_at': DateTime.now().toIso8601String(),
  };

  factory ContentItem.fromMap(Map<String, Object?> map) => ContentItem(
    id: map['id'] as int,
    title: map['title'] as String,
    channelId: map['channel_id'] as int,
    type: map['type'] as String,
    status: WorkflowStatus.values.byName(map['status'] as String),
    description: map['description'] as String? ?? '',
    notes: map['notes'] as String? ?? '',
    scheduledDate: map['scheduled_date'] == null
        ? null
        : DateTime.parse(map['scheduled_date'] as String),
    publishedUrl: map['published_url'] as String? ?? '',
  );
}

enum TaskType {
  fullYouTubeVideo('Full YouTube Video'),
  youtubeShort('YouTube Short'),
  tiktokVideo('TikTok Video'),
  facebookPost('Facebook Post'),
  madihContent('Madih Content'),
  other('Other');

  const TaskType(this.label);
  final String label;
}

enum TaskPriority {
  low('منخفضة'),
  medium('متوسطة'),
  high('عالية'),
  urgent('عاجلة');

  const TaskPriority(this.label);
  final String label;
}

enum TaskStatus {
  planned('مخطط'),
  inProgress('قيد التنفيذ'),
  ready('جاهز'),
  published('منشور');

  const TaskStatus(this.label);
  final String label;
}

class ManualTask {
  const ManualTask({
    this.id,
    required this.title,
    required this.channelId,
    required this.type,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.notes = '',
  });

  final int? id;
  final String title;
  final int channelId;
  final TaskType type;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String notes;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'channel_id': channelId,
    'task_type': type.name,
    'due_date': dueDate.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
    'notes': notes,
    'created_at': DateTime.now().toIso8601String(),
  };

  factory ManualTask.fromMap(Map<String, Object?> map) => ManualTask(
    id: map['id'] as int,
    title: map['title'] as String,
    channelId: map['channel_id'] as int,
    type: TaskType.values.byName(map['task_type'] as String),
    dueDate: DateTime.parse(map['due_date'] as String),
    priority: TaskPriority.values.byName(map['priority'] as String),
    status: TaskStatus.values.byName(map['status'] as String),
    notes: map['notes'] as String? ?? '',
  );
}
