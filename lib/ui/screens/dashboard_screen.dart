import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/channel_icon.dart';
import '../widgets/content_editor_dialog.dart';
import '../widgets/task_editor_dialog.dart';
import '../widgets/channel_editor_dialog.dart';
import '../app_localizations.dart';

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
    if (controller.channels.isEmpty) {
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
                  Icon(
                    Icons.auto_awesome_mosaic,
                    size: 68,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
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
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final todayTasks = controller.tasks
        .where((task) => DateUtils.isSameDay(task.dueDate, today))
        .toList();
    final weekTasks = controller.tasks
        .where(
          (task) =>
              !task.dueDate.isBefore(weekStart) &&
              task.dueDate.isBefore(weekEnd),
        )
        .toList();
    final pending = todayTasks.where((task) => !task.completed).toList();
    final completed = todayTasks.where((task) => task.completed).toList();
    final todayRate = todayTasks.isEmpty
        ? 0.0
        : completed.length / todayTasks.length;
    final weekCompleted = weekTasks.where((task) => task.completed).length;
    final weekRate = weekTasks.isEmpty ? 0.0 : weekCompleted / weekTasks.length;
    final score = ((todayRate + weekRate) / 2 * 100).round();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _HeroCard(
              greeting: _greeting(context, now.hour),
              completed: completed.length,
              total: todayTasks.length,
              pending: pending.length,
              score: score,
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
                    label: context.tr('Add Today Task', 'إضافة مهمة اليوم'),
                    color: const Color(0xFF5B8CFF),
                    onTap: () =>
                        showTaskEditor(context, controller, initialDate: today),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.video_library_outlined,
                    label: context.tr('Add Content', 'إضافة محتوى'),
                    color: const Color(0xFF49C98A),
                    onTap: () => showContentEditor(context, controller),
                  ),
                ),
              ],
            ),
          ),
        ),
        _WeeklyProgress(controller: controller, weekTasks: weekTasks),
        _ChannelOverview(
          controller: controller,
          weekStart: weekStart,
          weekEnd: weekEnd,
        ),
        if (controller.todaySuggestions.isNotEmpty)
          _Suggestions(controller: controller, today: today),
        _TaskSection(
          title: context.tr('Pending Today', 'قيد الانتظار اليوم'),
          icon: Icons.pending_actions,
          color: const Color(0xFF5B8CFF),
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
          color: const Color(0xFF49C98A),
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

  String _greeting(BuildContext context, int hour) {
    if (hour < 12) return context.tr('Good Morning', 'صباح الخير');
    if (hour < 17) return context.tr('Good Afternoon', 'مساء الخير');
    return context.tr('Good Evening', 'مساء الخير');
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.greeting,
    required this.completed,
    required this.total,
    required this.pending,
    required this.score,
  });
  final String greeting;
  final int completed;
  final int total;
  final int pending;
  final int score;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF274A86), Color(0xFF132641)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Today Progress', 'تقدم اليوم')),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.white12,
                      color: const Color(0xFF49C98A),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(
                        '$completed / $total completed · $pending pending',
                        '$completed / $total مكتمل · $pending معلق',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFFFFA94D),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score%',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          context.tr('Score', 'النتيجة'),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({required this.controller, required this.weekTasks});
  final AppController controller;
  final List<ManualTask> weekTasks;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
    sliver: SliverToBoxAdapter(
      child: _SectionCard(
        title: context.tr('Weekly Progress', 'التقدم الأسبوعي'),
        icon: Icons.insights_outlined,
        child: Column(
          children: controller.activeChannels.map((channel) {
            final channelTasks = weekTasks
                .where((task) => task.channelId == channel.id)
                .toList();
            final completed = channelTasks
                .where((task) => task.completed)
                .length;
            final denominator = channelTasks.isEmpty ? 1 : channelTasks.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: Text(channel.name)),
                  SizedBox(
                    width: 110,
                    child: LinearProgressIndicator(
                      value: (completed / denominator).clamp(0, 1),
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$completed/${channelTasks.length}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}

class _ChannelOverview extends StatelessWidget {
  const _ChannelOverview({
    required this.controller,
    required this.weekStart,
    required this.weekEnd,
  });
  final AppController controller;
  final DateTime weekStart;
  final DateTime weekEnd;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(
            icon: Icons.hub_outlined,
            title: context.tr('Channel Overview', 'نظرة عامة على القنوات'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.activeChannels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final channel = controller.activeChannels[index];
                final tasks = controller.tasks
                    .where((task) => task.channelId == channel.id)
                    .toList();
                final completedWeek = tasks
                    .where(
                      (task) =>
                          task.completed &&
                          !task.dueDate.isBefore(weekStart) &&
                          task.dueDate.isBefore(weekEnd),
                    )
                    .length;
                final dates =
                    controller.items
                        .where(
                          (item) =>
                              item.channelId == channel.id &&
                              item.scheduledDate != null,
                        )
                        .map((item) => item.scheduledDate!)
                        .toList()
                      ..sort();
                return SizedBox(
                  width: 245,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(channel.colorValue),
                                child: Icon(
                                  channelIcon(channel.iconKey),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      channel.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(channel.platform),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            context.tr(
                              '${tasks.where((task) => !task.completed).length} pending',
                              '${tasks.where((task) => !task.completed).length} معلقة',
                            ),
                          ),
                          Text(
                            context.tr(
                              '$completedWeek completed this week',
                              '$completedWeek مكتملة هذا الأسبوع',
                            ),
                          ),
                          Text(
                            dates.isEmpty
                                ? context.tr(
                                    'No content date',
                                    'لا يوجد تاريخ محتوى',
                                  )
                                : context.tr(
                                    'Last content ${DateFormat('MMM d').format(dates.last)}',
                                    'آخر محتوى ${DateFormat('MMM d', 'ar').format(dates.last)}',
                                  ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonalIcon(
                              onPressed: () => showTaskEditor(
                                context,
                                controller,
                                initialDate: DateUtils.dateOnly(DateTime.now()),
                                initialChannelId: channel.id,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(context.tr('Add Task', 'إضافة مهمة')),
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
    ),
  );
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.controller, required this.today});
  final AppController controller;
  final DateTime today;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
    sliver: SliverToBoxAdapter(
      child: _SectionCard(
        title: 'Suggested for Today',
        icon: Icons.auto_awesome_outlined,
        child: Column(
          children: controller.todaySuggestions.map((suggestion) {
            final channel = controller.channelNamed(suggestion.channelName)!;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(channel.colorValue),
                child: Icon(channelIcon(channel.iconKey), color: Colors.white),
              ),
              title: Text(suggestion.title),
              subtitle: Text(suggestion.reason),
              trailing: Wrap(
                spacing: 2,
                children: [
                  IconButton(
                    tooltip: 'Dismiss',
                    onPressed: () =>
                        controller.dismissSuggestion(suggestion.key),
                    icon: const Icon(Icons.close),
                  ),
                  IconButton.filled(
                    tooltip: 'Add to Today',
                    onPressed: () async {
                      await controller.saveTask(
                        ManualTask(
                          title: suggestion.title,
                          channelId: channel.id!,
                          type: suggestion.type,
                          dueDate: today,
                          priority: TaskPriority.medium,
                          status: TaskStatus.planned,
                        ),
                      );
                      await controller.dismissSuggestion(suggestion.key);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(icon: icon, title: title),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
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
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 7),
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
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
    sliver: SliverList(
      delegate: SliverChildListDelegate([
        _Title(icon: icon, title: title),
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
                    Text(
                      '${channel.name} · ${task.type.label} · ${task.priority.label}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
