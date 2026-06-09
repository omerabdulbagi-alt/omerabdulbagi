import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../app_localizations.dart';
import '../widgets/page_header.dart';
import '../widgets/task_editor_dialog.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    final pending = controller.tasks.where((task) => !task.completed).toList();
    final completed = controller.tasks.where((task) => task.completed).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isPhone ? 16 : 28,
            isPhone ? 16 : 28,
            isPhone ? 16 : 28,
            4,
          ),
          sliver: SliverToBoxAdapter(
            child: PageHeader(
              title: context.tr('Tasks', 'المهام'),
              subtitle: context.tr(
                'Manage pending and completed tasks',
                'إدارة المهام المعلقة والمكتملة',
              ),
              action: FilledButton.icon(
                onPressed: () => showTaskEditor(context, controller),
                icon: const Icon(Icons.add),
                label: Text(context.tr('Add Task', 'إضافة مهمة')),
              ),
            ),
          ),
        ),
        _TaskGroup(
          title: context.tr('Pending Tasks', 'المهام المعلقة'),
          icon: Icons.pending_actions,
          tasks: pending,
          controller: controller,
          emptyText: context.tr('No pending tasks.', 'لا توجد مهام معلقة.'),
        ),
        _TaskGroup(
          title: context.tr('Completed Tasks', 'المهام المكتملة'),
          icon: Icons.task_alt,
          tasks: completed,
          controller: controller,
          emptyText: context.tr(
            'Completed tasks will appear here.',
            'ستظهر المهام المكتملة هنا.',
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup({
    required this.title,
    required this.icon,
    required this.tasks,
    required this.controller,
    required this.emptyText,
  });

  final String title;
  final IconData icon;
  final List<ManualTask> tasks;
  final AppController controller;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Chip(label: Text('${tasks.length}')),
                  ],
                ),
                const SizedBox(height: 10),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    child: Center(child: Text(emptyText)),
                  )
                else
                  ...tasks.map(
                    (task) => _TaskTile(task: task, controller: controller),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.controller});

  final ManualTask task;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final channel = controller.channelFor(task.channelId);
    final locale = Localizations.localeOf(context).languageCode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Checkbox(
        value: task.completed,
        onChanged: (value) => controller.setTaskCompleted(task, value ?? false),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          decoration: task.completed ? TextDecoration.lineThrough : null,
          color: task.completed ? Theme.of(context).colorScheme.outline : null,
        ),
      ),
      subtitle: Text(
        '${channel.taskLabel} · ${DateFormat.yMMMd(locale).format(task.dueDate)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            showTaskEditor(context, controller, task: task);
          } else {
            _confirmDelete(context);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Text(context.tr('Edit Task', 'تعديل المهمة')),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text(context.tr('Delete', 'حذف')),
          ),
        ],
      ),
      onTap: () => showTaskEditor(context, controller, task: task),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Delete task', 'حذف المهمة')),
        content: Text(
          context.tr('Delete "${task.title}"?', 'هل تريد حذف "${task.title}"؟'),
        ),
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
      await controller.deleteTask(task.id!);
    }
  }
}
