import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import 'channel_icon.dart';
import 'task_editor_dialog.dart';
import '../app_localizations.dart';

Future<void> showQuickCreate(
  BuildContext context,
  AppController controller,
) async {
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
              context.tr('Create Content', 'إنشاء محتوى'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...controller.activeChannels.map((channel) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(channel.colorValue),
                  child: Icon(
                    channelIcon(channel.iconKey),
                    color: Colors.white,
                  ),
                ),
                title: Text(channel.name),
                subtitle: Text(channel.platform),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await controller.saveTask(
                    ManualTask(
                      title: context.tr(
                        'New ${channel.name} task',
                        'مهمة جديدة لقناة ${channel.name}',
                      ),
                      channelId: channel.id!,
                      type: TaskType.task,
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
              title: Text(context.tr('Custom Task', 'مهمة مخصصة')),
              subtitle: Text(
                context.tr(
                  'Choose all details manually',
                  'اختر جميع التفاصيل يدوياً',
                ),
              ),
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
