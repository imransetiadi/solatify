import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:solatify/features/mosque/presentation/screens/nearby_mosque_screen.dart';
import 'package:solatify/features/prayer_guide/presentation/screens/prayer_guide_screen.dart';
import 'package:solatify/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:solatify/features/settings/presentation/screens/notification_health_screen.dart';
import 'package:solatify/features/settings/presentation/screens/settings_screen.dart';
import 'package:solatify/features/tracker/presentation/screens/tracker_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('routed_screen_smoke_test');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
    await Hive.openBox<dynamic>(HiveService.settingsBoxName);
    await Hive.openBox<dynamic>(HiveService.trackerBoxName);
    await Hive.openBox<dynamic>(HiveService.locationBoxName);
    await Hive.openBox<dynamic>(HiveService.scheduleBoxName);
    await Hive.openBox<dynamic>(HiveService.quranIndexBoxName);
    await Hive.openBox<dynamic>(HiveService.quranDetailBoxName);
    await Hive.openBox<dynamic>(HiveService.quranBookmarksBoxName);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget wrap(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  Widget wrapDark(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: child,
      ),
    );
  }

  testWidgets('Qibla screen renders', (tester) async {
    await tester.pumpWidget(wrap(const QiblaScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Arah Kiblat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dark mode key routed screens render without contrast errors', (
    tester,
  ) async {
    for (final screen in const [QiblaScreen(), SettingsScreen()]) {
      await tester.pumpWidget(wrapDark(screen));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });

  test('Home screen source no longer renders tracker checklist', () {
    final source = File(
      'lib/features/home/presentation/screens/home_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('Ceklis Ibadah Hari Ini')));
    expect(source, isNot(contains('trackerProvider')));
  });

  test('Home screen source renders prayer countdown card', () {
    final source = File(
      'lib/features/home/presentation/screens/home_screen.dart',
    ).readAsStringSync();

    expect(source, contains('_PrayerCountdownCard'));
    expect(source, contains('remainingTime'));
    expect(source, contains('headingToPrayer'));
  });

  testWidgets('Tracker screen renders worship checklist', (tester) async {
    await tester.pumpWidget(wrap(const TrackerScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Tracker Ibadah'), findsOneWidget);
    expect(find.text('Ceklis Ibadah Hari Ini'), findsOneWidget);
    expect(find.text('Progress Hari Ini'), findsOneWidget);
    expect(find.text('Insight 7 Hari'), findsOneWidget);
    expect(find.textContaining('/5 salat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mosque screen renders', (tester) async {
    await tester.pumpWidget(wrap(const NearbyMosqueScreen()));

    await tester.pump();

    expect(find.textContaining('Masjid'), findsWidgets);
    expect(find.text('Peta Area'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings screen renders', (tester) async {
    await tester.pumpWidget(wrap(const SettingsScreen()));

    await tester.pumpAndSettle();

    expect(find.textContaining('Pengaturan'), findsWidgets);
    expect(find.text('NOTIFIKASI'), findsNothing);
    expect(find.text('Kirim Test Notifikasi'), findsOneWidget);
    expect(find.text('Pusat Kesehatan Notifikasi'), findsNothing);
    expect(find.text('Kirim notifikasi uji'), findsNothing);
    expect(find.text('Jadwalkan tes 2 menit'), findsNothing);
    expect(find.textContaining('Pending:'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('Settings source exposes Notification v2 controls', () {
    final source = File(
      'lib/features/settings/presentation/screens/settings_screen.dart',
    ).readAsStringSync();

    expect(source, contains('notificationPerPrayerTitle'));
    expect(source, contains('preNotificationReminder'));
    expect(source, contains('notificationSoundMode'));
    expect(source, contains('updateEnabledPrayerNotification'));
    expect(source, contains('updatePreNotificationMinutes'));
    expect(source, contains('updateNotificationSoundMode'));
    expect(source, contains('refreshSchedules(force: true)'));
    expect(source, contains('sendTestNotificationTitle'));
    expect(source, contains('_sendTestNotification'));
    expect(source, contains('showTestNotification'));
    expect(source, isNot(contains('notificationHealthEntryTitle')));
    expect(source, isNot(contains('AppRoutes.notificationHealth')));
    expect(source, contains('WidgetsBindingObserver'));
    expect(source, contains('WidgetsBinding.instance.addObserver(this)'));
    expect(source, contains('WidgetsBinding.instance.removeObserver(this)'));
    expect(source, contains('AppLifecycleState.resumed'));
    expect(source, contains('_verifyNotificationPermissionAfterReturn'));
    expect(source, contains('syncAdhanNotificationsWithPermission(false)'));
  });

  test('Settings copy avoids repeated settings wording', () {
    final localizationSource = File(
      'lib/core/localization/app_localizations.dart',
    ).readAsStringSync();

    expect(localizationSource, contains("isEnglish ? 'GENERAL' : 'UMUM'"));
    expect(localizationSource, isNot(contains('PENGATURAN UMUM')));
    expect(localizationSource, isNot(contains('GENERAL SETTINGS')));
  });

  test('AppRoutes exposes typed static and dynamic routes', () {
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.schedule, '/schedule');
    expect(AppRoutes.notificationHealth, '/settings/notification-health');
    expect(AppRoutes.quranSurah(2), '/quran/surah/2');
    expect(
      AppRoutes.quranSurah(2, scrollTo: 255),
      '/quran/surah/2?scroll_to=255',
    );
  });

  test('Priority navigation uses AppRoutes instead of raw internal paths', () {
    final sourcePaths = [
      'lib/features/onboarding/presentation/screens/splash_screen.dart',
      'lib/features/onboarding/presentation/screens/get_started_screen.dart',
      'lib/features/onboarding/presentation/screens/onboarding_screen.dart',
      'lib/features/settings/presentation/screens/settings_screen.dart',
      'lib/features/islamic_content/presentation/screens/islamic_content_screen.dart',
      'lib/features/quran/presentation/screens/quran_home_screen.dart',
      'lib/features/notifications/data/services/notification_service.dart',
    ];
    final rawNavigationPatterns = [
      "context.go('/",
      'context.go("/',
      "context.push('/",
      'context.push("/',
      "context.replace('/",
      'context.replace("/',
      "goRouter.go('/",
      'goRouter.go("/',
    ];

    for (final path in sourcePaths) {
      final source = File(path).readAsStringSync();
      for (final pattern in rawNavigationPatterns) {
        expect(source, isNot(contains(pattern)), reason: path);
      }
    }
  });

  test('Priority content and detail screens use compact scaffold', () {
    final scaffoldSource = File(
      'lib/core/widgets/solatify_screen_scaffold.dart',
    ).readAsStringSync();
    final screenSources = [
      'lib/features/duas/presentation/screens/duas_screen.dart',
      'lib/features/dhikr/presentation/screens/dhikr_screen.dart',
      'lib/features/islamic_tips/presentation/screens/islamic_tips_screen.dart',
      'lib/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart',
      'lib/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart',
      'lib/features/prayer_guide/presentation/screens/prayer_guide_screen.dart',
    ].map((path) => File(path).readAsStringSync());
    final notificationHealthSource = File(
      'lib/features/settings/presentation/screens/notification_health_screen.dart',
    ).readAsStringSync();

    expect(scaffoldSource, contains('SolatifyScreenScaffold'));
    expect(scaffoldSource, contains('ResponsiveCenter'));
    for (final source in screenSources) {
      expect(source, contains('SolatifyScreenScaffold'));
      expect(source, contains('AppRoutes.islamicContent'));
    }
    expect(notificationHealthSource, contains('SolatifyScreenScaffold'));
    expect(notificationHealthSource, contains('AppRoutes.settings'));
  });

  test('Content detail screens keep symmetric responsive page padding', () {
    final screenSources = [
      'lib/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart',
      'lib/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart',
      'lib/features/islamic_tips/presentation/screens/islamic_tips_screen.dart',
    ].map((path) => File(path).readAsStringSync());

    for (final source in screenSources) {
      expect(source, contains('ResponsiveLayout.pagePadding(context)'));
      expect(source, isNot(contains('EdgeInsets.fromLTRB(0, 16, 0, 0)')));
    }
  });

  test('Notification Health Center source exposes diagnostics and actions', () {
    final source = File(
      'lib/features/settings/presentation/screens/notification_health_screen.dart',
    ).readAsStringSync();

    expect(source, contains('NotificationHealthScreen'));
    expect(source, contains('getReadinessStatus'));
    expect(source, contains('getPendingNotificationIds'));
    expect(source, contains('getNotificationHistory'));
    expect(source, contains('showTestNotification'));
    expect(source, contains('openPlatformNotificationSettings'));
    expect(source, contains('refreshSchedules(force: true)'));
    expect(source, contains('WidgetsBindingObserver'));
    expect(source, contains('WidgetsBinding.instance.addObserver(this)'));
    expect(source, contains('WidgetsBinding.instance.removeObserver(this)'));
    expect(source, contains('AppLifecycleState.resumed'));
  });

  test('Surah Detail source exposes Quran reading mode controls', () {
    final source = File(
      'lib/features/quran/presentation/screens/surah_detail_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Tampilan Baca Qur'));
    expect(source, contains('Ukuran Arab'));
    expect(source, contains('Tampilkan transliterasi'));
    expect(source, contains('Tampilkan terjemahan'));
    expect(source, contains('Mode fokus'));
    expect(source, contains('Progress Surah'));
    expect(source, contains(r'Ayat $currentVerse / $totalVerses'));
  });

  test('Islamic Content source exposes global search controls', () {
    final source = File(
      'lib/features/islamic_content/presentation/screens/islamic_content_screen.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/features/islamic_content/presentation/providers/islamic_content_search_provider.dart',
    ).readAsStringSync();

    expect(source, contains('Cari doa, dzikir, Asmaul Husna'));
    expect(source, contains('Hasil Pencarian Konten Islami'));
    expect(source, contains('Belum ada konten yang cocok'));
    expect(source, contains('context.push(item.route)'));
    expect(providerSource, contains('IslamicContentSearchItem'));
    expect(providerSource, contains('searchIslamicContentItems'));
  });

  test('Priority screens use shared Solatify state view', () {
    final stateViewSource = File(
      'lib/core/widgets/solatify_state_view.dart',
    ).readAsStringSync();
    final screenSources = [
      'lib/features/islamic_content/presentation/screens/islamic_content_screen.dart',
      'lib/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart',
      'lib/features/islamic_tips/presentation/screens/islamic_tips_screen.dart',
      'lib/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart',
      'lib/features/tracker/presentation/screens/tracker_screen.dart',
      'lib/features/quran/presentation/screens/surah_detail_screen.dart',
    ].map((path) => File(path).readAsStringSync());

    expect(stateViewSource, contains('SolatifyStateVariant'));
    expect(stateViewSource, contains('SolatifyStateView.loading'));
    expect(stateViewSource, contains('SolatifyStateView.empty'));
    expect(stateViewSource, contains('SolatifyStateView.error'));
    for (final source in screenSources) {
      expect(source, contains('SolatifyStateView'));
    }
  });

  test('Priority interactions use Solatify haptic helper', () {
    final helperSource = File(
      'lib/core/services/solatify_haptics.dart',
    ).readAsStringSync();
    final targetSources = [
      'lib/core/navigation/router.dart',
      'lib/features/tracker/presentation/screens/tracker_screen.dart',
      'lib/features/quran/presentation/screens/surah_detail_screen.dart',
      'lib/features/quran/presentation/screens/quran_home_screen.dart',
      'lib/features/islamic_content/presentation/screens/islamic_content_screen.dart',
      'lib/features/settings/presentation/screens/settings_screen.dart',
    ].map((path) => File(path).readAsStringSync());

    expect(helperSource, contains('class SolatifyHaptics'));
    expect(helperSource, contains('HapticFeedback.selectionClick'));
    expect(helperSource, contains('HapticFeedback.lightImpact'));
    expect(helperSource, contains('HapticFeedback.mediumImpact'));
    for (final source in targetSources) {
      expect(source, contains('SolatifyHaptics'));
    }
  });

  testWidgets('Notification Health Center screen renders shell', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const NotificationHealthScreen()));

    await tester.pump();

    expect(find.text('Pusat Kesehatan Notifikasi'), findsOneWidget);
    expect(find.text('Status Saat Ini'), findsOneWidget);
    expect(find.text('Riwayat Jadwal'), findsOneWidget);
    expect(find.text('Aksi Pemulihan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hijri calendar screen renders', (tester) async {
    await tester.pumpWidget(wrap(const HijriCalendarScreen()));

    await tester.pumpAndSettle();

    expect(find.textContaining('Hijriah'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Prayer guide screen renders', (tester) async {
    await tester.pumpWidget(wrap(const PrayerGuideScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tuntunan Salat'), findsOneWidget);
    expect(find.textContaining('Takbiratul Ihram'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
