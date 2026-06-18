import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/islamic_content/presentation/screens/islamic_content_screen.dart';
import 'package:solatify/features/prayer_schedule/presentation/screens/prayer_schedule_screen.dart';
import 'package:solatify/features/quran/presentation/screens/quran_home_screen.dart';
import 'package:solatify/features/settings/presentation/screens/settings_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('compact_width_smoke_test');
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

  Future<void> pumpCompact(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: child,
        ),
      ),
    );
    await tester.pump();
  }

  test('Home keeps compact responsive layout anchors', () {
    final source = File(
      'lib/features/home/presentation/screens/home_screen.dart',
    ).readAsStringSync();

    expect(source, contains('ResponsiveCenter'));
    expect(source, contains('ResponsiveLayout.pagePadding'));
    expect(source, contains('CustomScrollView'));
    expect(source, contains('Solatify'));
  });

  testWidgets('Schedule renders on compact width', (tester) async {
    await pumpCompact(tester, const PrayerScheduleScreen());

    expect(find.text('Jadwal Salat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quran renders on compact width', (tester) async {
    await pumpCompact(tester, const QuranHomeScreen());

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings renders on compact width', (tester) async {
    await pumpCompact(tester, const SettingsScreen());

    expect(find.textContaining('Pengaturan'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Islamic Content renders on compact width', (tester) async {
    await pumpCompact(tester, const IslamicContentScreen());

    expect(find.text('Konten Islami'), findsOneWidget);
    expect(find.textContaining('Cari doa'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
