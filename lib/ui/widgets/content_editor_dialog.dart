import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../app_localizations.dart';
import 'channel_editor_dialog.dart';

Future<void> showContentEditor(
  BuildContext context,
  AppController controller, {
  ContentItem? item,
}) async {
  if (controller.activeChannels.isEmpty) {
    await showChannelEditor(context, controller);
    if (controller.activeChannels.isEmpty || !context.mounted) return;
  }
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        ContentEditorDialog(controller: controller, item: item),
  );
}

class ContentEditorDialog extends StatefulWidget {
  const ContentEditorDialog({super.key, required this.controller, this.item});

  final AppController controller;
  final ContentItem? item;

  @override
  State<ContentEditorDialog> createState() => _ContentEditorDialogState();
}

class _ContentEditorDialogState extends State<ContentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  late final TextEditingController _url;
  late int _channelId;
  late String _type;
  late WorkflowStatus _status;
  DateTime? _scheduledDate;
  bool _saving = false;

  static const _types = ['Full Video', 'Short Video', 'Post', 'Live Stream'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _title = TextEditingController(text: item?.title);
    _description = TextEditingController(text: item?.description);
    _notes = TextEditingController(text: item?.notes);
    _url = TextEditingController(text: item?.publishedUrl);
    _channelId = item?.channelId ?? widget.controller.activeChannels.first.id!;
    _type = item?.type ?? _types.first;
    _status = item?.status ?? WorkflowStatus.idea;
    _scheduledDate = item?.scheduledDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _notes.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.item == null
            ? context.tr('Add Content', 'إضافة محتوى')
            : context.tr('Edit Content', 'تعديل المحتوى'),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: context.tr('Content title', 'عنوان المحتوى'),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a content title'
                      : null,
                ),
                const SizedBox(height: 12),
                if (isPhone) ...[
                  _channelField(),
                  const SizedBox(height: 12),
                  _typeField(),
                ] else
                  Row(
                    children: [
                      Expanded(child: _channelField()),
                      const SizedBox(width: 12),
                      Expanded(child: _typeField()),
                    ],
                  ),
                const SizedBox(height: 12),
                if (isPhone) ...[
                  _statusField(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _dateField()),
                      if (_scheduledDate != null) _clearDateButton(),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(child: _statusField()),
                      const SizedBox(width: 12),
                      Expanded(child: _dateField()),
                      if (_scheduledDate != null) _clearDateButton(),
                    ],
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      'Description or script',
                      'الوصف أو النص',
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: context.tr('Notes', 'ملاحظات'),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _url,
                  decoration: InputDecoration(
                    labelText: context.tr('Published URL', 'رابط النشر'),
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
    final result = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _scheduledDate = result);
  }

  Widget _channelField() {
    return DropdownButtonFormField<int>(
      initialValue: _channelId,
      decoration: InputDecoration(labelText: context.tr('Channel', 'القناة')),
      items: widget.controller.channels
          .where((channel) => !channel.archived || channel.id == _channelId)
          .map(
            (channel) => DropdownMenuItem(
              value: channel.id!,
              child: Text('${channel.name} · ${channel.platform}'),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _channelId = value!),
    );
  }

  Widget _typeField() {
    return DropdownButtonFormField<String>(
      initialValue: _type,
      decoration: InputDecoration(labelText: context.tr('Type', 'النوع')),
      items: _types
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _type = value!),
    );
  }

  Widget _statusField() {
    return DropdownButtonFormField<WorkflowStatus>(
      initialValue: _status,
      decoration: InputDecoration(labelText: context.tr('Status', 'الحالة')),
      items: WorkflowStatus.values
          .map(
            (status) =>
                DropdownMenuItem(value: status, child: Text(status.label)),
          )
          .toList(),
      onChanged: (value) => setState(() => _status = value!),
    );
  }

  Widget _dateField() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.tr('Publish date', 'تاريخ النشر'),
        ),
        child: Text(
          _scheduledDate == null
              ? context.tr('No date', 'بدون تاريخ')
              : DateFormat('yyyy/MM/dd').format(_scheduledDate!),
        ),
      ),
    );
  }

  Widget _clearDateButton() {
    return IconButton(
      tooltip: context.tr('Clear date', 'مسح التاريخ'),
      onPressed: () => setState(() => _scheduledDate = null),
      icon: const Icon(Icons.close),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.controller.saveContent(
      ContentItem(
        id: widget.item?.id,
        title: _title.text.trim(),
        channelId: _channelId,
        type: _type,
        status: _status,
        description: _description.text.trim(),
        notes: _notes.text.trim(),
        scheduledDate: _scheduledDate,
        publishedUrl: _url.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
