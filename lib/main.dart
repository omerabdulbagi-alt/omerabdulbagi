import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_controller.dart';
import 'core/content_repository.dart';
import 'core/local_database.dart';
import 'core/notification_service.dart';
import 'ui/app_theme.dart';
import 'ui/main_shell.dart';
import 'ui/app_localizations.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('Flutter error: ${details.exceptionAsString()}');
        debugPrintStack(stackTrace: details.stack);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Uncaught platform error: $error');
        debugPrintStack(stackTrace: stack);
        return true;
      };
      runApp(const AppBootstrap());
    },
    (error, stack) {
      debugPrint('Uncaught startup error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  final ChangeNotifier _fallbackListenable = ChangeNotifier();
  AppController? _controller;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _controller = null;
      _error = null;
      _stackTrace = null;
    });

    try {
      final controller = AppController(
        ContentRepository(LocalDatabase()),
        NotificationService(),
      );
      await controller.initialize();
      if (mounted) setState(() => _controller = controller);
    } catch (error, stackTrace) {
      debugPrint('App initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AnimatedBuilder(
      animation: controller ?? _fallbackListenable,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ContentFlow',
        locale: controller?.settings.locale ?? const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: controller?.settings.themeMode ?? ThemeMode.light,
        home: _buildHome(),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackListenable.dispose();
    super.dispose();
  }

  Widget _buildHome() {
    if (_error != null) {
      return StartupErrorScreen(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _initialize,
      );
    }
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('ContentFlow'),
              SizedBox(height: 6),
              Text('Plan • Create • Publish'),
            ],
          ),
        ),
      );
    }
    return MainShell(controller: _controller!);
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 56,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr(
                          'Unable to start the app',
                          'تعذر تشغيل التطبيق',
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr(
                          'An error occurred while initializing local storage.',
                          'حدث خطأ أثناء تهيئة التخزين المحلي.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        error.toString(),
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (kDebugMode && stackTrace != null) ...[
                        const SizedBox(height: 12),
                        ExpansionTile(
                          title: Text(
                            context.tr('Error details', 'تفاصيل الخطأ'),
                          ),
                          children: [
                            SelectableText(
                              stackTrace.toString(),
                              textDirection: TextDirection.ltr,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: Text(context.tr('Retry', 'إعادة المحاولة')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
