import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import 'channel_icon.dart';
import 'task_editor_dialog.dart';

Future<void> showQuickCreate(
  BuildContext context,
  AppController controller,
) async {
  final options = <({String title, String channel, TaskType type})>[
    (title: 'Zooli Arabic Video', channel: 'Zooli Arabic', type: TaskType.video),
    (title: 'Zooli English Video', channel: 'Zooli English', type: TaskType.video),
    (
      title: 'Zooli Arabic TikTok Short',
      channel: 'Zooli Arabic TikTok',
      type: TaskType.short,
    ),
    (title: 'Balad360 Post', channel: 'Balad360', type: TaskType.post),
    (title: 'Quran Video', channel: 'Quran', type: TaskType.video),
    (title: 'Madih Video', channel: 'Madih', type: TaskType.video),
  ];
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Content',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((option) {
              final channel = controller.channelNamed(option.channel);
              if (channel == null || channel.archived) {
                return const SizedBox.shrink();
              }
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(channel.colorValue),
                  child: Icon(channelIcon(channel.iconKey), color: Colors.white),
                ),
                title: Text(option.title),
                subtitle: Text('${channel.platform} · ${option.type.label}'),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await controller.saveTask(
                    ManualTask(
                      title: option.title,
                      channelId: channel.id!,
                      type: option.type,
                      dueDate: DateUtils.dateOnly(DateTime.now()),
                      priority: TaskPriority.medium,
                      status: TaskStatus.planned,
                    ),
                  );
                },
              );
            }),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.add_task)),
              title: const Text('Custom Task'),
              subtitle: const Text('Choose all details manually'),
              onTap: () {
                Navigator.pop(sheetContext);
                showTaskEditor(
                  context,
                  controller,
                  initialDate: DateUtils.dateOnly(DateTime.now()),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
