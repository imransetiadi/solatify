import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
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
    expect(source, contains('notificationHealthEntryTitle'));
    expect(source, contains('/settings/notification-health'));
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
