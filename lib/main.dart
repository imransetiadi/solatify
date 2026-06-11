import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/navigation/router.dart';
import 'core/theme/theme.dart';

import 'core/database/hive_service.dart';
import 'features/reminder/data/services/notification_service.dart';
import 'features/settings/presentation/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await HiveService.init();
  await NotificationService.init();

  // Basic setup completed, run the App wrapped in a ProviderScope
  runApp(const ProviderScope(child: SolatifyApp()));
}

class SolatifyApp extends ConsumerWidget {
  const SolatifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Solatify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
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
