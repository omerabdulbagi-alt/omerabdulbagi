import 'package:flutter/foundation.dart';

import 'content_repository.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);
  final ContentRepository _repository;

  List<Channel> channels = [];
  List<ContentItem> items = [];
  List<ManualTask> tasks = [];
  bool isLoading = true;

  Future<void> initialize() async => refresh();

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
    await _repository.saveTask(task);
    await refresh();
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await refresh();
  }

  Channel channelFor(int id) => channels.firstWhere((item) => item.id == id);
}
