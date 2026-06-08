import 'package:flutter_test/flutter_test.dart';
import 'package:my_content_manager/core/models.dart';

void main() {
  test('content item survives database mapping', () {
    final item = ContentItem(
      id: 7,
      title: 'حلقة تجريبية',
      channelId: 2,
      type: 'فيديو طويل',
      status: WorkflowStatus.scripting,
      scheduledDate: DateTime(2026, 6, 10),
    );

    final restored = ContentItem.fromMap(item.toMap());

    expect(restored.id, 7);
    expect(restored.title, 'حلقة تجريبية');
    expect(restored.status, WorkflowStatus.scripting);
    expect(restored.scheduledDate, DateTime(2026, 6, 10));
  });

  test('workflow statuses have Arabic labels', () {
    expect(WorkflowStatus.idea.label, 'فكرة');
    expect(WorkflowStatus.published.label, 'منشور');
  });

  test('manual task survives database mapping', () {
    final task = ManualTask(
      id: 3,
      title: 'مراجعة الفيديو',
      channelId: 1,
      type: TaskType.fullYouTubeVideo,
      dueDate: DateTime(2026, 6, 12),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      notes: 'مراجعة الصوت والصورة',
    );

    final restored = ManualTask.fromMap(task.toMap());

    expect(restored.title, 'مراجعة الفيديو');
    expect(restored.type, TaskType.fullYouTubeVideo);
    expect(restored.priority, TaskPriority.high);
    expect(restored.status, TaskStatus.inProgress);
    expect(restored.notes, 'مراجعة الصوت والصورة');
  });
}
