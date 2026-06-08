import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/page_header.dart';
import '../widgets/task_editor_dialog.dart';

class WorkflowScreen extends StatelessWidget {
  const WorkflowScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'سير عمل المهام',
            subtitle: 'تابع المهام من التخطيط حتى النشر',
            action: FilledButton.icon(
              onPressed: () => showTaskEditor(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('مهمة جديدة'),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: TaskStatus.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final status = TaskStatus.values[index];
                final tasks = controller.tasks
                    .where((task) => task.status == status)
                    .toList();
                return SizedBox(
                  width: 290,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  status.label,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Chip(label: Text('${tasks.length}')),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              itemCount: tasks.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, taskIndex) {
                                final task = tasks[taskIndex];
                                final channel = controller.channelFor(
                                  task.channelId,
                                );
                                return Material(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    title: Text(task.title),
                                    subtitle: Text(
                                      '${channel.taskLabel}\n'
                                      '${task.type.label} · ${task.priority.label}',
                                    ),
                                    isThreeLine: true,
                                    onTap: () => showTaskEditor(
                                      context,
                                      controller,
                                      task: task,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
