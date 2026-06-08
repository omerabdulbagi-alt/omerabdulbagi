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
            title: 'Today Tasks',
            subtitle: 'Create, prioritize, and complete your tasks',
            action: FilledButton.icon(
              onPressed: () => showTaskEditor(context, widget.controller),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 210,
              child: DropdownButtonFormField<TaskStatus?>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Filter by status',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All statuses'),
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
                  ? const Center(child: Text('No tasks yet'))
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
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit Task'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
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
                                      tooltip: 'Edit Task',
                                      onPressed: () => showTaskEditor(
                                        context,
                                        widget.controller,
                                        task: task,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
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
        title: const Text('Delete task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && task.id != null) {
      await widget.controller.deleteTask(task.id!);
    }
  }
}
