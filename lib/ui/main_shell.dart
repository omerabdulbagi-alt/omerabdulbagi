import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import 'screens/calendar_screen.dart';
import 'screens/channels_screen.dart';
import 'screens/content_library_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/workflow_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/quick_create_sheet.dart';
import 'app_localizations.dart';
import 'widgets/channel_editor_dialog.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});
  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.video_library_outlined,
    Icons.view_kanban_outlined,
    Icons.calendar_month_outlined,
    Icons.task_alt_outlined,
    Icons.hub_outlined,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final labels = [
          context.tr('Home', 'الرئيسية'),
          context.tr('Content', 'المحتوى'),
          context.tr('Workflow', 'سير العمل'),
          context.tr('Calendar', 'التقويم'),
          context.tr('Today Tasks', 'مهام اليوم'),
          context.tr('Channels', 'القنوات'),
          context.tr('Settings', 'الإعدادات'),
        ];
        final destinations = List.generate(
          labels.length,
          (index) => NavigationRailDestination(
            icon: Icon(_icons[index]),
            selectedIcon: Icon(_icons[index]),
            label: Text(labels[index]),
          ),
        );
        final screens = [
          DashboardScreen(
            controller: widget.controller,
            onNavigate: (index) => setState(() => _selectedIndex = index),
          ),
          ContentLibraryScreen(controller: widget.controller),
          WorkflowScreen(controller: widget.controller),
          CalendarScreen(controller: widget.controller),
          TasksScreen(controller: widget.controller),
          ChannelsScreen(controller: widget.controller),
          SettingsScreen(controller: widget.controller),
        ];
        final content = widget.controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : screens[_selectedIndex];
        return LayoutBuilder(
          builder: (context, constraints) {
            final isPhone = constraints.maxWidth < 700;
            if (isPhone) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(labels[_selectedIndex]),
                  centerTitle: false,
                ),
                drawer: Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome_mosaic, size: 30),
                              const SizedBox(width: 12),
                              const Text(
                                'ContentFlow',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: labels.length,
                            itemBuilder: (context, index) => ListTile(
                              selected: index == _selectedIndex,
                              leading: Icon(_icons[index]),
                              title: Text(labels[index]),
                              onTap: () {
                                setState(() => _selectedIndex = index);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: SafeArea(child: content),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => widget.controller.activeChannels.isEmpty
                      ? showChannelEditor(context, widget.controller)
                      : showQuickCreate(context, widget.controller),
                  icon: const Icon(Icons.add),
                  label: Text(
                    widget.controller.activeChannels.isEmpty
                        ? context.tr('Create First Channel', 'إنشاء أول قناة')
                        : context.tr('Create', 'إنشاء'),
                  ),
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _mobileIndex(_selectedIndex),
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = _screenIndex(index)),
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: context.tr('Home', 'الرئيسية'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.task_alt_outlined),
                      label: context.tr('Tasks', 'المهام'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.video_library_outlined),
                      label: context.tr('Content', 'المحتوى'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: context.tr('Calendar', 'التقويم'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.hub_outlined),
                      label: context.tr('Channels', 'القنوات'),
                    ),
                  ],
                ),
              );
            }
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    extended: constraints.maxWidth >= 1120,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _selectedIndex = index),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Icon(Icons.auto_awesome_mosaic, size: 32),
                    ),
                    destinations: destinations,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _mobileIndex(int screenIndex) {
    const mapping = {0: 0, 4: 1, 1: 2, 3: 3, 5: 4};
    return mapping[screenIndex] ?? 0;
  }

  int _screenIndex(int mobileIndex) {
    const mapping = [0, 4, 1, 3, 5];
    return mapping[mobileIndex];
  }
}
