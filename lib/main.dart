import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/localization/app_localizations.dart';
import 'core/navigation/router.dart';
import 'core/theme/theme.dart';

import 'core/database/hive_service.dart';
import 'features/settings/presentation/settings_provider.dart';

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
    return Material(
      color: AppTheme.lightBg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, color: AppTheme.redAccent, size: 48),
              SizedBox(height: 16),
              Text(
                'Terjadi sedikit kendala',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Silakan coba lagi atau buka ulang aplikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
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
