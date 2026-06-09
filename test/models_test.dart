import 'package:flutter_test/flutter_test.dart';
import 'package:my_content_manager/core/models.dart';

void main() {
  test('content item survives database mapping', () {
    final item = ContentItem(
      id: 7,
      title: 'Sample episode',
      channelId: 2,
      type: 'Full Video',
      status: WorkflowStatus.scripting,
      scheduledDate: DateTime(2026, 6, 10),
    );

    final restored = ContentItem.fromMap(item.toMap());

    expect(restored.id, 7);
    expect(restored.title, 'Sample episode');
    expect(restored.status, WorkflowStatus.scripting);
    expect(restored.scheduledDate, DateTime(2026, 6, 10));
  });

  test('workflow statuses have English labels', () {
    expect(WorkflowStatus.idea.label, 'Idea');
    expect(WorkflowStatus.published.label, 'Published');
  });

  test('manual task survives database mapping', () {
    final task = ManualTask(
      id: 3,
      title: 'Review video',
      channelId: 1,
      type: TaskType.video,
      dueDate: DateTime(2026, 6, 12),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      notes: 'Review audio and video',
      completed: true,
      reminderAt: DateTime(2026, 6, 12, 9, 30),
      recurrenceType: RecurrenceType.custom,
      recurrenceInterval: 2,
      recurrenceWeekdays: const [DateTime.monday, DateTime.thursday],
      recurrenceGroup: 'series-1',
    );

    final restored = ManualTask.fromMap(task.toMap());

    expect(restored.title, 'Review video');
    expect(restored.type, TaskType.video);
    expect(restored.priority, TaskPriority.high);
    expect(restored.status, TaskStatus.inProgress);
    expect(restored.notes, 'Review audio and video');
    expect(restored.completed, isTrue);
    expect(restored.reminderAt, DateTime(2026, 6, 12, 9, 30));
    expect(restored.recurrenceType, RecurrenceType.custom);
    expect(restored.recurrenceInterval, 2);
    expect(restored.recurrenceWeekdays, [1, 4]);
    expect(restored.recurrenceGroup, 'series-1');
  });
}
