import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/content_editor_dialog.dart';
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
    final pending = todayTasks.where((task) => !task.completed).toList();
    final completed = todayTasks.where((task) => task.completed).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _HeroCard(
              pendingCount: pending.length,
              completedCount: completed.length,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_task,
                    label: 'Add Today Task',
                    color: const Color(0xFF56D7A7),
                    onTap: () =>
                        showTaskEditor(context, controller, initialDate: today),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.video_library_outlined,
                    label: 'Add Content',
                    color: const Color(0xFF7C8CFF),
                    onTap: () => showContentEditor(context, controller),
                  ),
                ),
              ],
            ),
          ),
        ),
        _TaskSection(
          title: 'Pending Tasks',
          icon: Icons.pending_actions,
          color: const Color(0xFFFFB65C),
          tasks: pending,
          controller: controller,
          emptyText: 'Nothing pending today. Nice work!',
        ),
        _TaskSection(
          title: 'Completed Tasks',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF56D7A7),
          tasks: completed,
          controller: controller,
          emptyText: 'Completed tasks will appear here.',
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 28)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.pendingCount, required this.completedCount});

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF263B67), Color(0xFF18243F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            'Today Tasks',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _CountBadge(
                count: pendingCount,
                label: 'Pending',
                color: const Color(0xFFFFB65C),
              ),
              const SizedBox(width: 12),
              _CountBadge(
                count: completedCount,
                label: 'Completed',
                color: const Color(0xFF56D7A7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.tasks,
    required this.controller,
    required this.emptyText,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<ManualTask> tasks;
  final AppController controller;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                emptyText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TodayTaskCard(task: task, controller: controller),
              ),
            ),
        ]),
      ),
    );
  }
}

class _TodayTaskCard extends StatelessWidget {
  const _TodayTaskCard({required this.task, required this.controller});

  final ManualTask task;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final channel = controller.channelFor(task.channelId);
    return Card(
      child: InkWell(
        onTap: () => showTaskEditor(context, controller, task: task),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (value) =>
                    controller.setTaskCompleted(task, value ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${channel.name} · ${task.priority.label}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.reminderAt != null)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.notifications_active_outlined, size: 19),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
