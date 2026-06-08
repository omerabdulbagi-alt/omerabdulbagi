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

  Channel channelFor(int id) => channels.firstWhere((item) => item.id == id);
}
