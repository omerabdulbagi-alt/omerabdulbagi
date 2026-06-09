enum WorkflowStatus {
  idea('Idea'),
  planned('Planned'),
  scripting('Scripting'),
  recording('Recording'),
  editing('Editing'),
  ready('Ready'),
  published('Published');

  const WorkflowStatus(this.label);
  final String label;
}

class Channel {
  const Channel({
    this.id,
    required this.name,
    required this.platform,
    required this.colorValue,
    this.iconKey = 'video',
    this.isDefault = false,
    this.archived = false,
  });

  final int? id;
  final String name;
  final String platform;
  final int colorValue;
  final String iconKey;
  final bool isDefault;
  final bool archived;

  String get taskLabel => name;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'platform': platform,
    'color_value': colorValue,
    'icon_key': iconKey,
    'is_default': isDefault ? 1 : 0,
    'archived': archived ? 1 : 0,
  };

  Channel copyWith({
    int? id,
    String? name,
    String? platform,
    int? colorValue,
    String? iconKey,
    bool? isDefault,
    bool? archived,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      colorValue: colorValue ?? this.colorValue,
      iconKey: iconKey ?? this.iconKey,
      isDefault: isDefault ?? this.isDefault,
      archived: archived ?? this.archived,
    );
  }

  factory Channel.fromMap(Map<String, Object?> map) => Channel(
    id: map['id'] as int,
    name: map['name'] as String,
    platform: map['platform'] as String,
    colorValue: map['color_value'] as int,
    iconKey: map['icon_key'] as String? ?? 'video',
    isDefault: (map['is_default'] as int? ?? 0) == 1,
    archived: (map['archived'] as int? ?? 0) == 1,
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
  video('Video'),
  short('Short'),
  post('Post'),
  article('Article'),
  audio('Audio'),
  task('Task');

  const TaskType(this.label);
  final String label;
}

enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const TaskPriority(this.label);
  final String label;
}

enum TaskStatus {
  planned('Planned'),
  inProgress('In Progress'),
  ready('Ready'),
  published('Published');

  const TaskStatus(this.label);
  final String label;
}

enum RecurrenceType {
  none('No Repeat'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  custom('Custom');

  const RecurrenceType(this.label);
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
    this.completed = false,
    this.reminderAt,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceInterval = 1,
    this.recurrenceWeekdays = const [],
    this.recurrenceMonthDay,
    this.recurrenceGroup,
  });

  final int? id;
  final String title;
  final int channelId;
  final TaskType type;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String notes;
  final bool completed;
  final DateTime? reminderAt;
  final RecurrenceType recurrenceType;
  final int recurrenceInterval;
  final List<int> recurrenceWeekdays;
  final int? recurrenceMonthDay;
  final String? recurrenceGroup;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'channel_id': channelId,
    'task_type': type.name,
    'due_date': dueDate.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
    'notes': notes,
    'completed': completed ? 1 : 0,
    'reminder_at': reminderAt?.toIso8601String(),
    'recurrence_type': recurrenceType.name,
    'recurrence_interval': recurrenceInterval,
    'recurrence_weekdays': recurrenceWeekdays.join(','),
    'recurrence_month_day': recurrenceMonthDay,
    'recurrence_group': recurrenceGroup,
    'created_at': DateTime.now().toIso8601String(),
  };

  ManualTask copyWith({
    int? id,
    String? title,
    int? channelId,
    TaskType? type,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? notes,
    bool? completed,
    DateTime? reminderAt,
    bool clearReminder = false,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    int? recurrenceMonthDay,
    String? recurrenceGroup,
  }) {
    return ManualTask(
      id: id ?? this.id,
      title: title ?? this.title,
      channelId: channelId ?? this.channelId,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      reminderAt: clearReminder ? null : reminderAt ?? this.reminderAt,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceMonthDay: recurrenceMonthDay ?? this.recurrenceMonthDay,
      recurrenceGroup: recurrenceGroup ?? this.recurrenceGroup,
    );
  }

  factory ManualTask.fromMap(Map<String, Object?> map) => ManualTask(
    id: map['id'] as int,
    title: map['title'] as String,
    channelId: map['channel_id'] as int,
    type: _taskTypeFromDatabase(map['task_type'] as String),
    dueDate: DateTime.parse(map['due_date'] as String),
    priority: TaskPriority.values.byName(map['priority'] as String),
    status: TaskStatus.values.byName(map['status'] as String),
    notes: map['notes'] as String? ?? '',
    completed: (map['completed'] as int? ?? 0) == 1,
    reminderAt: map['reminder_at'] == null
        ? null
        : DateTime.parse(map['reminder_at'] as String),
    recurrenceType: RecurrenceType.values.byName(
      map['recurrence_type'] as String? ?? 'none',
    ),
    recurrenceInterval: map['recurrence_interval'] as int? ?? 1,
    recurrenceWeekdays: (map['recurrence_weekdays'] as String? ?? '')
        .split(',')
        .where((value) => value.isNotEmpty)
        .map(int.parse)
        .toList(),
    recurrenceMonthDay: map['recurrence_month_day'] as int?,
    recurrenceGroup: map['recurrence_group'] as String?,
  );
}

TaskType _taskTypeFromDatabase(String value) {
  return switch (value) {
    'fullYouTubeVideo' => TaskType.video,
    'youtubeShort' || 'tiktokVideo' => TaskType.short,
    'facebookPost' => TaskType.post,
    'madihContent' => TaskType.audio,
    'other' => TaskType.task,
    _ => TaskType.values.byName(value),
  };
}

class DashboardSuggestion {
  const DashboardSuggestion({
    required this.key,
    required this.title,
    required this.channelName,
    required this.type,
    required this.reason,
  });

  final String key;
  final String title;
  final String channelName;
  final TaskType type;
  final String reason;
}
