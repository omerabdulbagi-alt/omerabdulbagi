import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/page_header.dart';
import '../widgets/task_editor_dialog.dart';
import '../app_localizations.dart';

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
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    final tasks = widget.controller.tasks
        .where((task) => _status == null || task.status == _status)
        .toList();

    return Padding(
      padding: EdgeInsets.all(isPhone ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: context.tr('Today Tasks', 'مهام اليوم'),
            subtitle: context.tr(
              'Create, prioritize, and complete your tasks',
              'أنشئ مهامك وحدد أولوياتها وأكملها',
            ),
            action: FilledButton.icon(
              onPressed: () => showTaskEditor(context, widget.controller),
              icon: const Icon(Icons.add),
              label: Text(context.tr('Add Task', 'إضافة مهمة')),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 210,
              child: DropdownButtonFormField<TaskStatus?>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: context.tr('Filter by status', 'تصفية حسب الحالة'),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(context.tr('All statuses', 'كل الحالات')),
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
                  ? Center(
                      child: Text(
                        context.tr('No tasks yet', 'لا توجد مهام بعد'),
                      ),
                    )
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
                          leading: Checkbox(
                            value: task.completed,
                            onChanged: (value) => widget.controller
                                .setTaskCompleted(task, value ?? false),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.completed
                                  ? Theme.of(context).colorScheme.outline
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${channel.taskLabel} · ${task.type.label}\n'
                            '${task.completed ? 'Completed' : 'Pending'} · '
                            '${task.status.label} · ${task.priority.label} · '
                            '${DateFormat('yyyy/MM/dd').format(task.dueDate)}',
                          ),
                          isThreeLine: true,
                          trailing: isPhone
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showTaskEditor(
                                        context,
                                        widget.controller,
                                        task: task,
                                      );
                                    } else {
                                      _confirmDelete(task);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        context.tr('Edit Task', 'تعديل المهمة'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(context.tr('Delete', 'حذف')),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'yyyy/MM/dd',
                                      ).format(task.dueDate),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: context.tr(
                                        'Edit Task',
                                        'تعديل المهمة',
                                      ),
                                      onPressed: () => showTaskEditor(
                                        context,
                                        widget.controller,
                                        task: task,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: context.tr('Delete', 'حذف'),
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

  Future<void> _confirmDelete(ManualTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Delete task', 'حذف المهمة')),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('Delete', 'حذف')),
          ),
        ],
      ),
    );
    if (confirmed == true && task.id != null) {
      await widget.controller.deleteTask(task.id!);
    }
  }
}
