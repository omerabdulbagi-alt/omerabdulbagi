import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import 'channel_icon.dart';
import '../app_localizations.dart';

const _channelColors = [
  0xFF5B8CFF,
  0xFF49C98A,
  0xFFFFA94D,
  0xFFB47CFF,
  0xFFFF6B7A,
  0xFF35C6D0,
  0xFF8B9AAF,
  0xFFF06292,
];

Future<void> showChannelEditor(
  BuildContext context,
  AppController controller, {
  Channel? channel,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) =>
        ChannelEditorDialog(controller: controller, channel: channel),
  );
}

class ChannelEditorDialog extends StatefulWidget {
  const ChannelEditorDialog({
    super.key,
    required this.controller,
    this.channel,
  });

  final AppController controller;
  final Channel? channel;

  @override
  State<ChannelEditorDialog> createState() => _ChannelEditorDialogState();
}

class _ChannelEditorDialogState extends State<ChannelEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _platform;
  late int _color;
  late String _iconKey;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.channel?.name);
    _platform = widget.channel?.platform ?? 'YouTube';
    _color = widget.channel?.colorValue ?? _channelColors.first;
    _iconKey = widget.channel?.iconKey ?? 'video';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(widget.channel == null ? 'Add Channel' : 'Edit Channel'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: context.tr('Channel name', 'اسم القناة'),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a channel name'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _platform,
                  decoration: InputDecoration(
                    labelText: context.tr('Platform', 'المنصة'),
                  ),
                  items:
                      const [
                            'YouTube',
                            'Facebook',
                            'TikTok',
                            'Instagram',
                            'Website',
                            'Other',
                          ]
                          .map(
                            (platform) => DropdownMenuItem(
                              value: platform,
                              child: Text(platform),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _platform = value!),
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr('Color', 'اللون'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _channelColors
                      .map(
                        (value) => InkWell(
                          onTap: () => setState(() => _color = value),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Color(value),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _color == value
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: _color == value
                                ? const Icon(Icons.check, size: 20)
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr('Icon', 'الأيقونة'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: channelIconOptions.entries
                      .map(
                        (entry) => IconButton.filledTonal(
                          isSelected: _iconKey == entry.key,
                          onPressed: () => setState(() => _iconKey = entry.key),
                          icon: Icon(entry.value),
                        ),
                      )
                      .toList(),
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
          label: Text(context.tr('Save', 'حفظ')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.controller.saveChannel(
      Channel(
        id: widget.channel?.id,
        name: _name.text.trim(),
        platform: _platform,
        colorValue: _color,
        iconKey: _iconKey,
        isDefault: widget.channel?.isDefault ?? false,
        archived: widget.channel?.archived ?? false,
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
