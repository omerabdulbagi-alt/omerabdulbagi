import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../app_localizations.dart';
import '../widgets/channel_editor_dialog.dart';
import '../widgets/contentflow_brand.dart';
import '../widgets/task_editor_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.channels.isEmpty) {
      return _EmptyHome(controller: controller);
    }

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
            child: _TodayHeader(
              completed: completed.length,
              total: todayTasks.length,
              onAdd: () =>
                  showTaskEditor(context, controller, initialDate: today),
            ),
          ),
        ),
        _TaskSection(
          title: context.tr('Pending Today', 'قيد الانتظار اليوم'),
          icon: Icons.pending_actions,
          tasks: pending,
          controller: controller,
          emptyText: context.tr(
            'No pending tasks for today.',
            'لا توجد مهام معلقة اليوم.',
          ),
        ),
        _TaskSection(
          title: context.tr('Completed Today', 'المكتمل اليوم'),
          icon: Icons.check_circle_outline,
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

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ContentFlowBrand(centered: true, logoSize: 78),
                const SizedBox(height: 24),
                Text(
                  context.tr(
                    'Welcome to ContentFlow',
                    'مرحباً بك في ContentFlow',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'You have no channels yet.',
                    'ليس لديك أي قنوات بعد.',
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => showChannelEditor(context, controller),
                  icon: const Icon(Icons.add),
                  label: Text(
                    context.tr('Create First Channel', 'إنشاء أول قناة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({
    required this.completed,
    required this.total,
    required this.onAdd,
  });

  final int completed;
  final int total;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087EA4), Color(0xFF16B8A6)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087EA4).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentFlowBrand(light: true, showTagline: false, logoSize: 42),
          const SizedBox(height: 22),
          Text(
            context.tr("Today's Tasks", 'مهام اليوم'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEEE, MMMM d', locale).format(DateTime.now()),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.white24,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(
                    '$completed of $total completed',
                    'اكتملت $completed من $total',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_task),
                label: Text(context.tr('Add Task', 'إضافة مهمة')),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF087EA4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
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
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
    sliver: SliverList(
      delegate: SliverChildListDelegate([
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Chip(label: Text('${tasks.length}')),
          ],
        ),
        const SizedBox(height: 10),
        if (tasks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(emptyText),
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
        borderRadius: BorderRadius.circular(20),
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
                    Text(
                      '${channel.name} · ${task.type.label}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.recurrenceType != RecurrenceType.none)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 8),
                  child: Icon(Icons.repeat, size: 18),
                ),
              if (task.reminderAt != null)
                const Icon(Icons.notifications_active_outlined, size: 19),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
