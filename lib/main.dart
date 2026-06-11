import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/localization/app_localizations.dart';
import 'core/navigation/router.dart';
import 'core/theme/theme.dart';

import 'core/database/hive_service.dart';
import 'features/settings/presentation/settings_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Start loading dependencies in parallel
    await Future.wait([
      initializeDateFormatting('id_ID', null),
      initializeDateFormatting('en_US', null),
      HiveService.init(),
    ]);

    runApp(const ProviderScope(child: SolatifyApp()));
  } catch (e) {
    debugPrint('Critical startup error: $e');
    // Fallback run to avoid black screen
    runApp(const ProviderScope(child: SolatifyApp()));
  }
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
