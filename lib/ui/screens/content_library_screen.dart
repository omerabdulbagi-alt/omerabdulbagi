import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/content_editor_dialog.dart';
import '../widgets/page_header.dart';

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  String _query = '';
  WorkflowStatus? _status;

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.items.where((item) {
      final matchesText =
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.description.toLowerCase().contains(_query.toLowerCase());
      return matchesText && (_status == null || item.status == _status);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'مكتبة المحتوى',
            subtitle: 'جميع الأفكار والمنشورات في مكان واحد',
            action: FilledButton.icon(
              onPressed: () => showContentEditor(context, widget.controller),
              icon: const Icon(Icons.add),
              label: const Text('إضافة محتوى'),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ابحث بالعنوان أو الوصف',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<WorkflowStatus?>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...WorkflowStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: items.isEmpty
                  ? const Center(child: Text('لا يوجد محتوى مطابق'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final channel = widget.controller.channelFor(
                          item.channelId,
                        );
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Color(channel.colorValue),
                            child: const Icon(Icons.play_arrow),
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${channel.name} · ${item.type} · ${item.status.label}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.scheduledDate != null)
                                Text(
                                  DateFormat(
                                    'yyyy/MM/dd',
                                  ).format(item.scheduledDate!),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'تعديل',
                                onPressed: () => showContentEditor(
                                  context,
                                  widget.controller,
                                  item: item,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: () => _confirmDelete(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          onTap: () => showContentEditor(
                            context,
                            widget.controller,
                            item: item,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ContentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحتوى'),
        content: Text('هل تريد حذف "${item.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && item.id != null) {
      await widget.controller.deleteContent(item.id!);
    }
  }
}
