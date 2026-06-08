import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/page_header.dart';
import '../widgets/task_editor_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _status;

  @override
  Widget build(BuildContext context) {
    final tasks = widget.controller.tasks
        .where((task) => _status == null || task.status == _status)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'المهام',
            subtitle: 'أنشئ مهامك ونظّمها يدوياً',
            action: FilledButton.icon(
              onPressed: () => showTaskEditor(context, widget.controller),
              icon: const Icon(Icons.add),
              label: const Text('مهمة جديدة'),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 210,
              child: DropdownButtonFormField<TaskStatus?>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'تصفية بالحالة'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('كل الحالات'),
                  ),
                  ...TaskStatus.values.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _status = value),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: tasks.isEmpty
                  ? const Center(child: Text('لا توجد مهام بعد'))
                  : ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final channel = widget.controller.channelFor(
                          task.channelId,
                        );
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _priorityColor(task.priority),
                            child: const Icon(Icons.task_alt),
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            '${channel.taskLabel} · ${task.type.label} · '
                            '${task.status.label} · ${task.priority.label}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('yyyy/MM/dd').format(task.dueDate),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'تعديل',
                                onPressed: () => showTaskEditor(
                                  context,
                                  widget.controller,
                                  task: task,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: () => _confirmDelete(task),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          onTap: () => showTaskEditor(
                            context,
                            widget.controller,
                            task: task,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => Colors.blueGrey,
      TaskPriority.medium => Colors.blue,
      TaskPriority.high => Colors.orange,
      TaskPriority.urgent => Colors.red,
    };
  }

  Future<void> _confirmDelete(ManualTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: Text('هل تريد حذف "${task.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && task.id != null) {
      await widget.controller.deleteTask(task.id!);
    }
  }
}
