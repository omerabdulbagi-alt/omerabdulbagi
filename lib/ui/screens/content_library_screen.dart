import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_controller.dart';
import '../../core/models.dart';
import '../widgets/content_editor_dialog.dart';
import '../widgets/page_header.dart';
import '../app_localizations.dart';

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
    final isPhone = MediaQuery.sizeOf(context).width < 700;
    final items = widget.controller.items.where((item) {
      final matchesText =
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.description.toLowerCase().contains(_query.toLowerCase());
      return matchesText && (_status == null || item.status == _status);
    }).toList();

    return Padding(
      padding: EdgeInsets.all(isPhone ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: context.tr('Content', 'المحتوى'),
            subtitle: context.tr(
              'Ideas, scripts, posts, and videos in one place',
              'الأفكار والنصوص والمنشورات والفيديوهات في مكان واحد',
            ),
            action: FilledButton.icon(
              onPressed: () => showContentEditor(context, widget.controller),
              icon: const Icon(Icons.add),
              label: Text(context.tr('Add Content', 'إضافة محتوى')),
            ),
          ),
          const SizedBox(height: 22),
          if (isPhone)
            Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.tr(
                      'Search title or description',
                      'ابحث في العنوان أو الوصف',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<WorkflowStatus?>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: context.tr('Status', 'الحالة'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.tr('All', 'الكل')),
                    ),
                    ...WorkflowStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: context.tr(
                        'Search title or description',
                        'ابحث في العنوان أو الوصف',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<WorkflowStatus?>(
                    initialValue: _status,
                    decoration: InputDecoration(
                      labelText: context.tr('Status', 'الحالة'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(context.tr('All', 'الكل')),
                      ),
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
                  ? Center(
                      child: Text(
                        context.tr(
                          'No matching content',
                          'لا يوجد محتوى مطابق',
                        ),
                      ),
                    )
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
                          trailing: isPhone
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showContentEditor(
                                        context,
                                        widget.controller,
                                        item: item,
                                      );
                                    } else {
                                      _confirmDelete(item);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(context.tr('Edit', 'تعديل')),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(context.tr('Delete', 'حذف')),
                                    ),
                                  ],
                                )
                              : Row(
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
                                      tooltip: context.tr('Edit', 'تعديل'),
                                      onPressed: () => showContentEditor(
                                        context,
                                        widget.controller,
                                        item: item,
                                      ),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: context.tr('Delete', 'حذف'),
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
        title: Text(context.tr('Delete content', 'حذف المحتوى')),
        content: Text('Delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('Delete', 'حذف')),
          ),
        ],
      ),
    );
    if (confirmed == true && item.id != null) {
      await widget.controller.deleteContent(item.id!);
    }
  }
}
