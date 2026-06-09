import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../widgets/page_header.dart';
import '../app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    return ListView(
      padding: EdgeInsets.all(isPhone ? 16 : 28),
      children: [
        PageHeader(
          title: context.tr('Settings', 'الإعدادات'),
          subtitle: context.tr(
            'Language, appearance, notifications, and app details',
            'اللغة والمظهر والإشعارات وتفاصيل التطبيق',
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.language)),
                title: Text(context.tr('Language', 'اللغة')),
                subtitle: Text(
                  context.tr('Choose app language', 'اختر لغة التطبيق'),
                ),
                trailing: DropdownButton<String>(
                  value: controller.settings.localeCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setLocale(value);
                  },
                ),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                secondary: const CircleAvatar(
                  child: Icon(Icons.dark_mode_outlined),
                ),
                title: Text(context.tr('Dark theme', 'الوضع الداكن')),
                subtitle: Text(
                  context.tr(
                    'Use softer dark colors',
                    'استخدم ألواناً داكنة مريحة',
                  ),
                ),
                value: controller.settings.themeMode == ThemeMode.dark,
                onChanged: (dark) => controller.setThemeMode(
                  dark ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.notifications_active_outlined),
            ),
            title: Text(context.tr('Test Notification', 'اختبار الإشعار')),
            subtitle: Text(
              context.tr(
                'Send a local Android test notification',
                'إرسال إشعار تجريبي محلي على أندرويد',
              ),
            ),
            trailing: FilledButton(
              onPressed: () async {
                final sent = await controller.testNotification();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sent
                          ? context.tr(
                              'Test notification sent.',
                              'تم إرسال الإشعار التجريبي.',
                            )
                          : context.tr(
                              'Notifications are available on Android only.',
                              'الإشعارات متاحة على أندرويد فقط.',
                            ),
                    ),
                  ),
                );
              },
              child: Text(context.tr('Test', 'اختبار')),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(child: Icon(Icons.info_outline)),
                    SizedBox(width: 12),
                    Text(
                      'About ContentFlow',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                _AboutRow(
                  label: context.tr('Version', 'الإصدار'),
                  value: '2.0.0 (Build 200)',
                ),
                SizedBox(height: 10),
                _AboutRow(
                  label: context.tr('Tagline', 'الشعار'),
                  value: context.tr(
                    'Plan • Create • Publish',
                    'خطط • أنشئ • انشر',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.backup_outlined)),
            title: Text(
              context.tr('Backup and Export', 'النسخ الاحتياطي والتصدير'),
            ),
            subtitle: Text(
              context.tr(
                'Placeholder for a future update',
                'متاح في تحديث قادم',
              ),
            ),
            trailing: const Icon(Icons.lock_clock_outlined),
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
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
