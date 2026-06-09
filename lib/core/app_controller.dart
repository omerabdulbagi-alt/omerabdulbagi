import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'content_repository.dart';
import 'models.dart';
import 'notification_service.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository, this._notifications);
  final ContentRepository _repository;
  final NotificationService _notifications;

  List<Channel> channels = [];
  List<ContentItem> items = [];
  List<ManualTask> tasks = [];
  Set<String> dismissedSuggestionKeys = {};
  bool isLoading = true;
  AppSettings settings = const AppSettings();

  Future<void> initialize() async {
    await _notifications.initialize();
    settings = await _repository.getSettings();
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();
    channels = await _repository.getChannels();
    items = await _repository.getContentItems();
    tasks = await _repository.getTasks();
    dismissedSuggestionKeys = await _repository.getDismissedSuggestions(
      _dateKey(DateTime.now()),
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveContent(ContentItem item) async {
    await _repository.saveContent(item);
    await refresh();
  }

  Future<void> deleteContent(int id) async {
    await _repository.deleteContent(id);
    await refresh();
  }

  Future<void> saveTask(ManualTask task) async {
    if (task.id == null && task.recurrenceType != RecurrenceType.none) {
      for (final occurrence in _generateOccurrences(task)) {
        final id = await _repository.saveTask(occurrence);
        await _notifications.syncTask(occurrence.copyWith(id: id));
      }
    } else {
      final id = await _repository.saveTask(task);
      await _notifications.syncTask(task.copyWith(id: id));
    }
    await refresh();
  }

  Future<void> deleteTask(int id) async {
    await _notifications.cancelTask(id);
    await _repository.deleteTask(id);
    await refresh();
  }

  Future<void> setTaskCompleted(ManualTask task, bool completed) async {
    await saveTask(task.copyWith(completed: completed));
  }

  Future<void> saveChannel(Channel channel) async {
    await _repository.saveChannel(channel);
    await refresh();
  }

  Future<void> setChannelArchived(Channel channel, bool archived) async {
    if (channel.id == null) return;
    await _repository.archiveChannel(channel.id!, archived);
    await refresh();
  }

  Future<void> deleteChannel(Channel channel) async {
    if (channel.id == null) return;
    await _repository.deleteChannel(channel.id!);
    await refresh();
  }

  Future<void> setLocale(String localeCode) async {
    settings = settings.copyWith(localeCode: localeCode);
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    settings = settings.copyWith(themeMode: themeMode);
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  Future<void> dismissSuggestion(String key) async {
    await _repository.dismissSuggestion(key, _dateKey(DateTime.now()));
    dismissedSuggestionKeys.add(key);
    notifyListeners();
  }

  Future<bool> testNotification() => _notifications.showTestNotification();

  List<Channel> get activeChannels =>
      channels.where((channel) => !channel.archived).toList();

  Channel channelFor(int id) => channels.firstWhere(
    (item) => item.id == id,
    orElse: () => Channel(
      id: id,
      name: 'Archived channel',
      platform: 'Unknown',
      colorValue: 0xFF64748B,
      archived: true,
    ),
  );

  Channel? channelNamed(String name) {
    for (final channel in channels) {
      if (channel.name == name) return channel;
    }
    return null;
  }

  List<DashboardSuggestion> get todaySuggestions => const [];

  List<ManualTask> _generateOccurrences(ManualTask task) {
    final dates = <DateTime>[DateUtils.dateOnly(task.dueDate)];
    final end = task.dueDate.add(const Duration(days: 366));
    final group = DateTime.now().microsecondsSinceEpoch.toString();
    var cursor = DateUtils.dateOnly(task.dueDate);

    if (task.recurrenceType == RecurrenceType.daily ||
        (task.recurrenceType == RecurrenceType.custom &&
            task.recurrenceWeekdays.isEmpty &&
            task.recurrenceMonthDay == null)) {
      while (true) {
        cursor = cursor.add(Duration(days: task.recurrenceInterval));
        if (cursor.isAfter(end)) break;
        dates.add(cursor);
      }
    } else if (task.recurrenceType == RecurrenceType.weekly ||
        (task.recurrenceType == RecurrenceType.custom &&
            task.recurrenceWeekdays.isNotEmpty)) {
      final weekdays = task.recurrenceWeekdays.isEmpty
          ? <int>{task.dueDate.weekday}
          : task.recurrenceWeekdays.toSet();
      for (
        var date = cursor.add(const Duration(days: 1));
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))
      ) {
        final weeks = date.difference(cursor).inDays ~/ 7;
        if (weekdays.contains(date.weekday) &&
            weeks % task.recurrenceInterval == 0) {
          dates.add(date);
        }
      }
    } else {
      final day = task.recurrenceMonthDay ?? task.dueDate.day;
      for (var month = 1; month <= 12; month += task.recurrenceInterval) {
        final targetMonth = task.dueDate.month + month;
        final lastDay = DateUtils.getDaysInMonth(
          task.dueDate.year + (targetMonth - 1) ~/ 12,
          (targetMonth - 1) % 12 + 1,
        );
        dates.add(
          DateTime(
            task.dueDate.year + (targetMonth - 1) ~/ 12,
            (targetMonth - 1) % 12 + 1,
            day.clamp(1, lastDay),
          ),
        );
      }
    }

    return dates
        .map(
          (date) => task.copyWith(
            dueDate: date,
            completed: false,
            recurrenceGroup: group,
          ),
        )
        .toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
