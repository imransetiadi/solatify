import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/router.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

void main() {
  // Run everything inside a guarded zone so that any uncaught async error
  // (common cause of crash-on-relaunch after force-close) is logged instead
  // of terminating the app.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Replace the default red error screen with a friendly, themed widget so
      // a single widget build error never shows a full-screen crash.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        return const _AppErrorView();
      };

      // Catch framework errors without crashing the app.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError captured: ${details.exceptionAsString()}');
      };

      // Catch errors from the platform/engine layer (Dart 3 API).
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('PlatformDispatcher error captured: $error');
        return true; // handled — do not crash
      };

      // Initialize date formatting; tolerate failures individually.
      try {
        await initializeDateFormatting('id_ID', null);
        await initializeDateFormatting('en_US', null);
      } catch (e) {
        debugPrint('Date formatting init error: $e');
      }

      // Initialize Hive with recovery for corrupt boxes after force-close.
      try {
        await HiveService.init();
      } catch (e) {
        debugPrint('Hive init error: $e. Attempting recovery...');
        await HiveService.ensureBoxesOpen();
      }

      runApp(const ProviderScope(child: SolatifyApp()));
    },
    (error, stack) {
      // Last-resort handler for anything that escaped the zone.
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}

/// Friendly themed fallback shown if a widget fails to build, instead of the
/// default grey/red crash box. Uses the app's red accent.
class _AppErrorView extends StatelessWidget {
  const _AppErrorView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: AppTheme.lightBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                l.appErrorTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.appErrorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SolatifyApp extends ConsumerStatefulWidget {
  const SolatifyApp({super.key});

  @override
  ConsumerState<SolatifyApp> createState() => _SolatifyAppState();
}

class _SolatifyAppState extends ConsumerState<SolatifyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-ensure Hive boxes are open and stable when app resumes
      _reopenHiveBoxes();
      ref
          .read(notificationSchedulerProvider.notifier)
          .refreshSchedules(force: true);
    }
  }

  Future<void> _reopenHiveBoxes() async {
    try {
      await HiveService.ensureBoxesOpen();
    } catch (e) {
      debugPrint('Error reopening Hive boxes on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    ref.watch(notificationSchedulerProvider);

    return MaterialApp.router(
      title: 'Solatify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: Locale(settings.language == 'en' ? 'en' : 'id'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: goRouter,
      scrollBehavior: const SolatifyScrollBehavior(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler
            .scale(1)
            .clamp(0.9, 1.25)
            .toDouble();

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: ExactAlarmPromptGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

class ExactAlarmPromptGate extends StatefulWidget {
  const ExactAlarmPromptGate({super.key, required this.child});

  final Widget child;

  @override
  State<ExactAlarmPromptGate> createState() => _ExactAlarmPromptGateState();
}

class _ExactAlarmPromptGateState extends State<ExactAlarmPromptGate> {
  bool _exactAlarmPromptShown = false;
  bool _batteryOptimizationPromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowExactAlarmPrompt();
    });
  }

  Future<void> _maybeShowExactAlarmPrompt() async {
    if (_exactAlarmPromptShown ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final readiness = await NotificationService().getReadinessStatus();
      if (!mounted ||
          _exactAlarmPromptShown ||
          readiness.status != NotificationReadinessStatus.inexactScheduling) {
        await _maybeShowBatteryOptimizationPrompt();
        return;
      }

      final navigatorContext = rootNavigatorKey.currentContext;
      if (navigatorContext == null) return;
      if (!navigatorContext.mounted) return;

      _exactAlarmPromptShown = true;
      await showDialog<void>(
        context: navigatorContext,
        builder: (context) {
          final l = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l.exactAlarmTitle),
            content: Text(l.exactAlarmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.later),
              ),
              FilledButton(
                onPressed: () async {
                  final container = ProviderScope.containerOf(context);
                  Navigator.of(context).pop();
                  await NotificationService().requestAndroidPermissions();
                  container
                      .read(notificationSchedulerProvider.notifier)
                      .refreshSchedules(force: true);
                },
                child: Text(l.enable),
              ),
            ],
          );
        },
      );
      await _maybeShowBatteryOptimizationPrompt();
    } catch (e) {
      debugPrint('Error showing exact alarm prompt: $e');
    }
  }

  Future<void> _maybeShowBatteryOptimizationPrompt() async {
    if (_batteryOptimizationPromptShown ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final isUnrestricted = await NotificationService()
          .isIgnoringAndroidBatteryOptimizations();
      if (!mounted || _batteryOptimizationPromptShown || isUnrestricted) {
        return;
      }

      final navigatorContext = rootNavigatorKey.currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;

      _batteryOptimizationPromptShown = true;
      await showDialog<void>(
        context: navigatorContext,
        builder: (context) {
          final l = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l.backgroundPermissionTitle),
            content: Text(l.backgroundPermissionMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.later),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await NotificationService()
                      .openAndroidBatteryOptimizationSettings();
                },
                child: Text(l.openSettings),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing battery optimization prompt: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SolatifyScrollBehavior extends MaterialScrollBehavior {
  const SolatifyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
