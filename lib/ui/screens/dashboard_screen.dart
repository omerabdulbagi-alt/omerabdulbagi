import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/page_header.dart';
import '../widgets/task_editor_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  final AppController controller;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final todayTasks = controller.tasks
        .where((task) => DateUtils.isSameDay(task.dueDate, today))
        .toList();
    final upcoming = controller.tasks
        .where(
          (task) =>
              task.status != TaskStatus.published &&
              !DateUtils.dateOnly(task.dueDate).isBefore(today),
        )
        .take(6)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'مرحباً بك',
            subtitle: 'نظرة سريعة على مهام المحتوى',
            action: FilledButton.icon(
              onPressed: () => showTaskEditor(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('مهمة جديدة'),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                label: 'كل المهام',
                value: '${controller.tasks.length}',
                icon: Icons.task_alt,
              ),
              _StatCard(
                label: 'قيد التنفيذ',
                value:
                    '${controller.tasks.where((task) => task.status == TaskStatus.inProgress).length}',
                icon: Icons.pending_actions,
              ),
              _StatCard(
                label: 'مهام اليوم',
                value: '${todayTasks.length}',
                icon: Icons.today,
              ),
              _StatCard(
                label: 'جاهزة',
                value:
                    '${controller.tasks.where((task) => task.status == TaskStatus.ready).length}',
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('المهام القادمة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: upcoming.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: Text('لا توجد مهام قادمة')),
                  )
                : Column(
                    children: upcoming
                        .map(
                          (task) => ListTile(
                            leading: const Icon(Icons.event_outlined),
                            title: Text(task.title),
                            subtitle: Text(
                              '${controller.channelFor(task.channelId).taskLabel} · '
                              '${task.status.label} · ${task.priority.label}',
                            ),
                            trailing: Text(
                              DateFormat('yyyy/MM/dd').format(task.dueDate),
                            ),
                            onTap: () =>
                                showTaskEditor(context, controller, task: task),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onNavigate(4),
              icon: const Icon(Icons.arrow_back),
              label: const Text('عرض كل المهام'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                  Text(label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
