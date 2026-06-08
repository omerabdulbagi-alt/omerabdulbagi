import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';

Future<void> showTaskEditor(
  BuildContext context,
  AppController controller, {
  ManualTask? task,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => TaskEditorDialog(controller: controller, task: task),
  );
}

class TaskEditorDialog extends StatefulWidget {
  const TaskEditorDialog({super.key, required this.controller, this.task});

  final AppController controller;
  final ManualTask? task;

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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title);
    _notes = TextEditingController(text: task?.notes);
    _channelId = task?.channelId ?? widget.controller.channels.first.id;
    _type = task?.type ?? TaskType.fullYouTubeVideo;
    _dueDate = task?.dueDate ?? DateTime.now();
    _priority = task?.priority ?? TaskPriority.medium;
    _status = task?.status ?? TaskStatus.planned;
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
      title: Text(widget.task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'عنوان المهمة'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'أدخل عنوان المهمة'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _channelId,
                  decoration: const InputDecoration(labelText: 'القناة'),
                  items: widget.controller.channels
                      .map(
                        (channel) => DropdownMenuItem(
                          value: channel.id,
                          child: Text(channel.taskLabel),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _channelId = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'نوع المهمة'),
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
                  decoration: const InputDecoration(labelText: 'الحالة'),
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
                TextFormField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
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
          child: const Text('إلغاء'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ'),
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
        decoration: const InputDecoration(labelText: 'تاريخ المهمة'),
        child: Text(DateFormat('yyyy/MM/dd').format(_dueDate)),
      ),
    );
  }

  Widget _priorityField() {
    return DropdownButtonFormField<TaskPriority>(
      initialValue: _priority,
      decoration: const InputDecoration(labelText: 'الأولوية'),
      items: TaskPriority.values
          .map(
            (priority) =>
                DropdownMenuItem(value: priority, child: Text(priority.label)),
          )
          .toList(),
      onChanged: (value) => setState(() => _priority = value!),
    );
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
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
