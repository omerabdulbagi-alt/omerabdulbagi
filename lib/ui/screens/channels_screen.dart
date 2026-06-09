import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/channel_editor_dialog.dart';
import '../widgets/channel_icon.dart';
import '../widgets/page_header.dart';
import '../app_localizations.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    return Padding(
      padding: EdgeInsets.all(isPhone ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: context.tr('Channels', 'القنوات'),
            subtitle: context.tr(
              'Manage platforms, colors, and channel identity',
              'إدارة المنصات والألوان وهوية القنوات',
            ),
            action: FilledButton.icon(
              onPressed: () => showChannelEditor(context, controller),
              icon: const Icon(Icons.add),
              label: Text(context.tr('Add Channel', 'إضافة قناة')),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: controller.channels.isEmpty
                ? _EmptyChannels(controller: controller)
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 340,
                          mainAxisExtent: 160,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: controller.channels.length,
                    itemBuilder: (context, index) {
                      final channel = controller.channels[index];
                      final contentCount = controller.items
                          .where((item) => item.channelId == channel.id)
                          .length;
                      final taskCount = controller.tasks
                          .where((task) => task.channelId == channel.id)
                          .length;
                      return Opacity(
                        opacity: channel.archived ? 0.55 : 1,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(
                                        channel.colorValue,
                                      ),
                                      child: Icon(
                                        channelIcon(channel.iconKey),
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            channel.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          Text(channel.platform),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) => _handleAction(
                                        context,
                                        channel,
                                        value,
                                      ),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text(
                                            context.tr('Edit', 'تعديل'),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'archive',
                                          child: Text(
                                            channel.archived
                                                ? 'Restore'
                                                : 'Archive',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            context.tr('Delete', 'حذف'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    _Metric(
                                      icon: Icons.task_alt,
                                      label: '$taskCount tasks',
                                    ),
                                    const SizedBox(width: 14),
                                    _Metric(
                                      icon: Icons.video_library_outlined,
                                      label: '$contentCount content',
                                    ),
                                  ],
                                ),
                                if (channel.archived) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Archived',
                                    style: TextStyle(color: Color(0xFFFFA94D)),
                                  ),
                                ],
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
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Channel channel,
    String action,
  ) async {
    if (action == 'edit') {
      await showChannelEditor(context, controller, channel: channel);
    } else if (action == 'archive') {
      await controller.setChannelArchived(channel, !channel.archived);
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.tr('Delete channel', 'حذف القناة')),
          content: Text(
            'Delete "${channel.name}"? A channel with linked records will be archived instead.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('Delete', 'حذف')),
            ),
          ],
        ),
      );
      if (confirmed == true) await controller.deleteChannel(channel);
    }
  }
}

class _EmptyChannels extends StatelessWidget {
  const _EmptyChannels({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hub_outlined,
                  size: 64,
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
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
