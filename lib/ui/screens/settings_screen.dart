import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../widgets/page_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    return ListView(
      padding: EdgeInsets.all(isPhone ? 16 : 28),
      children: [
        const PageHeader(
          title: 'Settings',
          subtitle: 'Notifications and app tools',
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.notifications_active_outlined),
            ),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a local Android test notification'),
            trailing: FilledButton(
              onPressed: () async {
                final sent = await controller.testNotification();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sent
                          ? 'Test notification sent.'
                          : 'Notifications are available on Android only.',
                    ),
                  ),
                );
              },
              child: const Text('Test'),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Icon(Icons.info_outline)),
                    SizedBox(width: 12),
                    Text(
                      'About My Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                _AboutRow(label: 'Version', value: '2.0.0 (Build 200)'),
                SizedBox(height: 10),
                _AboutRow(
                  label: 'Release',
                  value: 'Phase 2 - Smart Dashboard',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.backup_outlined)),
            title: Text('Backup and Export'),
            subtitle: Text('Placeholder for a future update'),
            trailing: Icon(Icons.lock_clock_outlined),
          ),
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
