import 'package:flutter/material.dart';

const channelIconOptions = <String, IconData>{
  'video': Icons.play_circle_outline,
  'language': Icons.language,
  'short': Icons.bolt,
  'public': Icons.public,
  'book': Icons.menu_book_outlined,
  'audio': Icons.graphic_eq,
  'article': Icons.article_outlined,
  'camera': Icons.camera_alt_outlined,
  'podcast': Icons.podcasts,
  'custom': Icons.star_outline,
};

IconData channelIcon(String key) =>
    channelIconOptions[key] ?? Icons.star_outline;
