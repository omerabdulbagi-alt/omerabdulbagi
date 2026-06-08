import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/app_controller.dart';
import 'core/content_repository.dart';
import 'core/local_database.dart';
import 'ui/app_theme.dart';
import 'ui/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final controller = AppController(ContentRepository(LocalDatabase()));
  await controller.initialize();
  runApp(MyContentManagerApp(controller: controller));
}

class MyContentManagerApp extends StatelessWidget {
  const MyContentManagerApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدير المحتوى',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.dark,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MainShell(controller: controller),
      ),
    );
  }
}
