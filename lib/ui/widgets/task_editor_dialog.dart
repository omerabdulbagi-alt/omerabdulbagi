import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../app_localizations.dart';
import 'channel_editor_dialog.dart';

Future<void> showTaskEditor(
  BuildContext context,
  AppController controller, {
  ManualTask? task,
  DateTime? initialDate,
  int? initialChannelId,
  TaskType? initialType,
  String? initialTitle,
}) async {
  if (controller.activeChannels.isEmpty) {
    await showChannelEditor(context, controller);
    if (controller.activeChannels.isEmpty || !context.mounted) return;
  }
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => TaskEditorDialog(
      controller: controller,
      task: task,
      initialDate: initialDate,
      initialChannelId: initialChannelId,
      initialType: initialType,
      initialTitle: initialTitle,
    ),
  );
}

class TaskEditorDialog extends StatefulWidget {
  const TaskEditorDialog({
    super.key,
    required this.controller,
    this.task,
    this.initialDate,
    this.initialChannelId,
    this.initialType,
    this.initialTitle,
  });

  final AppController controller;
  final ManualTask? task;
  final DateTime? initialDate;
  final int? initialChannelId;
  final TaskType? initialType;
  final String? initialTitle;

  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late int _channelId;
  late TaskType _type;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  late bool _completed;
  DateTime? _reminderAt;
  late RecurrenceType _recurrenceType;
  late int _recurrenceInterval;
  late Set<int> _recurrenceWeekdays;
  int? _recurrenceMonthDay;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? widget.initialTitle);
    _notes = TextEditingController(text: task?.notes);
    _channelId =
        task?.channelId ??
        widget.initialChannelId ??
        widget.controller.activeChannels.first.id!;
    _type = task?.type ?? widget.initialType ?? TaskType.task;
    _dueDate = task?.dueDate ?? widget.initialDate ?? DateTime.now();
    _priority = task?.priority ?? TaskPriority.medium;
    _status = task?.status ?? TaskStatus.planned;
    _completed = task?.completed ?? false;
    _reminderAt = task?.reminderAt;
    _recurrenceType = task?.recurrenceType ?? RecurrenceType.none;
    _recurrenceInterval = task?.recurrenceInterval ?? 1;
    _recurrenceWeekdays = (task?.recurrenceWeekdays ?? const <int>[]).toSet();
    _recurrenceMonthDay = task?.recurrenceMonthDay;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.task == null
            ? context.tr('Add Task', 'إضافة مهمة')
            : context.tr('Edit Task', 'تعديل المهمة'),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: context.tr('Task title', 'عنوان المهمة'),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task title'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _channelId,
                  decoration: InputDecoration(
                    labelText: context.tr('Channel', 'القناة'),
                  ),
                  items: widget.controller.channels
                      .where(
                        (channel) =>
                            !channel.archived || channel.id == _channelId,
                      )
                      .map(
                        (channel) => DropdownMenuItem(
                          value: channel.id!,
                          child: Text(channel.taskLabel),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _channelId = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskType>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: context.tr('Task type', 'نوع المهمة'),
                  ),
                  items: TaskType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                const SizedBox(height: 12),
                if (isPhone) ...[
                  _dateField(),
                  const SizedBox(height: 12),
                  _priorityField(),
                ] else
                  Row(
                    children: [
                      Expanded(child: _dateField()),
                      const SizedBox(width: 12),
                      Expanded(child: _priorityField()),
                    ],
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: context.tr('Status', 'الحالة'),
                  ),
                  items: TaskStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _status = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RecurrenceType>(
                  initialValue: _recurrenceType,
                  decoration: InputDecoration(
                    labelText: context.tr('Repeat Task', 'تكرار المهمة'),
                  ),
                  items: RecurrenceType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_recurrenceLabel(context, type)),
                        ),
                      )
                      .toList(),
                  onChanged: widget.task == null
                      ? (value) => setState(() => _recurrenceType = value!)
                      : null,
                ),
                if (_recurrenceType == RecurrenceType.custom) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _recurrenceInterval,
                    decoration: InputDecoration(
                      labelText: context.tr('Repeat every', 'التكرار كل'),
                    ),
                    items: List.generate(
                      30,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _recurrenceInterval = value!),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.tr(
                        'Days of week (leave empty for every N days)',
                        'أيام الأسبوع (اتركها فارغة للتكرار كل عدد من الأيام)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      final labels = context.isArabic
                          ? const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
                          : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return FilterChip(
                        label: Text(labels[index]),
                        selected: _recurrenceWeekdays.contains(weekday),
                        onSelected: (selected) => setState(() {
                          selected
                              ? _recurrenceWeekdays.add(weekday)
                              : _recurrenceWeekdays.remove(weekday);
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.tr(
                        'Use first day of each month',
                        'استخدم اليوم الأول من كل شهر',
                      ),
                    ),
                    value: _recurrenceMonthDay == 1,
                    onChanged: (value) => setState(
                      () => _recurrenceMonthDay = value == true ? 1 : null,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Completed', 'مكتملة')),
                  subtitle: Text(
                    context.tr(
                      'Mark this task as finished',
                      'تحديد المهمة كمكتملة',
                    ),
                  ),
                  value: _completed,
                  onChanged: (value) => setState(() => _completed = value),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickReminder,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.tr(
                              'Reminder (optional)',
                              'التذكير (اختياري)',
                            ),
                            prefixIcon: const Icon(
                              Icons.notifications_outlined,
                            ),
                          ),
                          child: Text(
                            _reminderAt == null
                                ? context.tr('No reminder', 'بدون تذكير')
                                : DateFormat(
                                    'MMM d, yyyy · h:mm a',
                                  ).format(_reminderAt!),
                          ),
                        ),
                      ),
                    ),
                    if (_reminderAt != null)
                      IconButton(
                        tooltip: context.tr('Clear reminder', 'مسح التذكير'),
                        onPressed: () => setState(() => _reminderAt = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: context.tr('Notes', 'ملاحظات'),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(context.tr('Cancel', 'إلغاء')),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            _saving
                ? context.tr('Saving...', 'جارٍ الحفظ...')
                : context.tr('Save', 'حفظ'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Widget _dateField() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(labelText: context.tr('Date', 'التاريخ')),
        child: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
      ),
    );
  }

  Widget _priorityField() {
    return DropdownButtonFormField<TaskPriority>(
      initialValue: _priority,
      decoration: InputDecoration(
        labelText: context.tr('Priority', 'الأولوية'),
      ),
      items: TaskPriority.values
          .map(
            (priority) =>
                DropdownMenuItem(value: priority, child: Text(priority.label)),
          )
          .toList(),
      onChanged: (value) => setState(() => _priority = value!),
    );
  }

  Future<void> _pickReminder() async {
    final initial = _reminderAt ?? DateTime.now().add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    setState(() {
      _reminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.controller.saveTask(
      ManualTask(
        id: widget.task?.id,
        title: _title.text.trim(),
        channelId: _channelId,
        type: _type,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        notes: _notes.text.trim(),
        completed: _completed,
        reminderAt: _reminderAt,
        recurrenceType: _recurrenceType,
        recurrenceInterval: _recurrenceType == RecurrenceType.daily
            ? 1
            : _recurrenceType == RecurrenceType.weekly ||
                  _recurrenceType == RecurrenceType.monthly
            ? 1
            : _recurrenceInterval,
        recurrenceWeekdays:
            _recurrenceType == RecurrenceType.weekly
                  ? [_dueDate.weekday]
                  : _recurrenceWeekdays.toList()
              ..sort(),
        recurrenceMonthDay: _recurrenceType == RecurrenceType.monthly
            ? _dueDate.day
            : _recurrenceMonthDay,
        recurrenceGroup: widget.task?.recurrenceGroup,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  String _recurrenceLabel(BuildContext context, RecurrenceType type) {
    return switch (type) {
      RecurrenceType.none => context.tr('No Repeat', 'بدون تكرار'),
      RecurrenceType.daily => context.tr('Daily', 'يومياً'),
      RecurrenceType.weekly => context.tr('Weekly', 'أسبوعياً'),
      RecurrenceType.monthly => context.tr('Monthly', 'شهرياً'),
      RecurrenceType.custom => context.tr('Custom', 'مخصص'),
    };
  }
}
