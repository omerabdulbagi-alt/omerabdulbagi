import 'package:flutter/foundation.dart';

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

  Future<void> initialize() async {
    await _notifications.initialize();
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
    final id = await _repository.saveTask(task);
    await _notifications.syncTask(task.copyWith(id: id));
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

  Future<void> deleteCustomChannel(Channel channel) async {
    if (channel.id == null || channel.isDefault) return;
    await _repository.deleteCustomChannel(channel.id!);
    await refresh();
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

  List<DashboardSuggestion> get todaySuggestions {
    final today = DateTime.now();
    final dayIndex = today.difference(DateTime(2026, 1, 1)).inDays;
    final candidates = <DashboardSuggestion>[
      const DashboardSuggestion(
        key: 'madih_daily',
        title: 'Madih daily content',
        channelName: 'Madih',
        type: TaskType.audio,
        reason: 'Daily schedule',
      ),
      if (dayIndex % 3 == 0)
        const DashboardSuggestion(
          key: 'zooli_arabic_rotation',
          title: 'Zooli Arabic video',
          channelName: 'Zooli Arabic',
          type: TaskType.video,
          reason: 'Every 3 days',
        ),
      if (dayIndex % 3 == 1)
        const DashboardSuggestion(
          key: 'zooli_english_rotation',
          title: 'Zooli English video',
          channelName: 'Zooli English',
          type: TaskType.video,
          reason: 'Alternating 3-day schedule',
        ),
      if (dayIndex % 3 == 2)
        const DashboardSuggestion(
          key: 'zooli_tiktok_rotation',
          title: 'Zooli Arabic TikTok short',
          channelName: 'Zooli Arabic TikTok',
          type: TaskType.short,
          reason: 'Every 3 days',
        ),
      if (<int>{1, 3, 6}.contains(today.weekday))
        const DashboardSuggestion(
          key: 'balad360_weekly',
          title: 'Balad360 post',
          channelName: 'Balad360',
          type: TaskType.post,
          reason: '3 posts per week',
        ),
    ];
    return candidates
        .where(
          (item) =>
              !dismissedSuggestionKeys.contains(item.key) &&
              channelNamed(item.channelName)?.archived != true,
        )
        .toList();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
