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

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});
  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const _labels = [
    'Home',
    'Content',
    'Workflow',
    'Calendar',
    'Today Tasks',
    'Channels',
    'Settings',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.video_library_outlined,
    Icons.view_kanban_outlined,
    Icons.calendar_month_outlined,
    Icons.task_alt_outlined,
    Icons.hub_outlined,
    Icons.settings_outlined,
  ];

  static const _destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.video_library_outlined),
      selectedIcon: Icon(Icons.video_library),
      label: Text('Content'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.view_kanban_outlined),
      selectedIcon: Icon(Icons.view_kanban),
      label: Text('Workflow'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: Text('Calendar'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.task_alt_outlined),
      selectedIcon: Icon(Icons.task_alt),
      label: Text('Today Tasks'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.hub_outlined),
      selectedIcon: Icon(Icons.hub),
      label: Text('Channels'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
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
                  title: Text(_labels[_selectedIndex]),
                  centerTitle: false,
                ),
                drawer: Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome_mosaic, size: 30),
                              SizedBox(width: 12),
                              Text(
                                'My Tasks',
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
                            itemCount: _labels.length,
                            itemBuilder: (context, index) => ListTile(
                              selected: index == _selectedIndex,
                              leading: Icon(_icons[index]),
                              title: Text(_labels[index]),
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
                  onPressed: () => showQuickCreate(context, widget.controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Content'),
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _mobileIndex(_selectedIndex),
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = _screenIndex(index)),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.task_alt_outlined),
                      label: 'Tasks',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.video_library_outlined),
                      label: 'Content',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.hub_outlined),
                      label: 'Channels',
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
                    destinations: _destinations,
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
