import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/page_header.dart';
import '../widgets/task_editor_dialog.dart';
import '../app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    final firstWeekday = _month.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final cellCount = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;

    return Padding(
      padding: EdgeInsets.all(isPhone ? 12 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: context.tr('Calendar', 'التقويم'),
            subtitle: context.tr(
              'Tasks organized by date',
              'المهام مرتبة حسب التاريخ',
            ),
            action: Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_right),
                ),
                SizedBox(
                  width: 150,
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy').format(_month),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_left),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final calendarWidth = math.max(constraints.maxWidth, 760.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: calendarWidth,
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            _Weekday('Sun'),
                            _Weekday('Mon'),
                            _Weekday('Tue'),
                            _Weekday('Wed'),
                            _Weekday('Thu'),
                            _Weekday('Fri'),
                            _Weekday('Sat'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1.1,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                ),
                            itemCount: cellCount,
                            itemBuilder: (context, index) {
                              final day = index - firstWeekday + 1;
                              if (day < 1 || day > daysInMonth) {
                                return const SizedBox.shrink();
                              }
                              final date = DateTime(
                                _month.year,
                                _month.month,
                                day,
                              );
                              final tasks = widget.controller.tasks
                                  .where((task) => _sameDay(task.dueDate, date))
                                  .toList();
                              return _CalendarDay(
                                date: date,
                                tasks: tasks,
                                onOpen: (task) => showTaskEditor(
                                  context,
                                  widget.controller,
                                  task: task,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  void _changeMonth(int offset) {
    setState(() {
      _month = DateTime(_month.year, _month.month + offset);
    });
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.tasks,
    required this.onOpen,
  });

  final DateTime date;
  final List<ManualTask> tasks;
  final ValueChanged<ManualTask> onOpen;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    return Card(
      color: isToday
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                children: tasks
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: InkWell(
                          onTap: () => onOpen(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
