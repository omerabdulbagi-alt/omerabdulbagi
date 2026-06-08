import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/channel_editor_dialog.dart';
import '../widgets/channel_icon.dart';
import '../widgets/page_header.dart';

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
            title: 'Channels',
            subtitle: 'Manage platforms, colors, and channel identity',
            action: FilledButton.icon(
              onPressed: () => showChannelEditor(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add Channel'),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                              backgroundColor: Color(channel.colorValue),
                              child: Icon(
                                channelIcon(channel.iconKey),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    channel.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(channel.platform),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) =>
                                  _handleAction(context, channel, value),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Text(
                                    channel.archived ? 'Restore' : 'Archive',
                                  ),
                                ),
                                if (!channel.isDefault)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
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
          title: const Text('Delete channel'),
          content: Text(
            'Delete "${channel.name}"? A channel with linked records will be archived instead.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) await controller.deleteCustomChannel(channel);
    }
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
