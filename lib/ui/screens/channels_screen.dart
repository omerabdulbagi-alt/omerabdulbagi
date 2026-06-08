import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
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
          const PageHeader(
            title: 'القنوات',
            subtitle: 'القنوات المستخدمة في خطة المحتوى',
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
                final count = controller.items
                    .where((item) => item.channelId == channel.id)
                    .length;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(channel.colorValue),
                              child: Icon(_platformIcon(channel.platform)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                channel.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(channel.platform),
                        Text('$count قطعة محتوى'),
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

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'Facebook':
        return Icons.facebook;
      case 'TikTok':
        return Icons.music_note;
      default:
        return Icons.play_arrow;
    }
  }
}
