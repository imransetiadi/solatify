import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart';
import 'package:solatify/features/dhikr/presentation/screens/dhikr_screen.dart';
import 'package:solatify/features/duas/presentation/screens/duas_screen.dart';
import 'package:solatify/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:solatify/features/islamic_content/presentation/screens/islamic_content_screen.dart';
import 'package:solatify/features/islamic_tips/presentation/screens/islamic_tips_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('islamic_content_smoke_test');
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

  testWidgets('Asmaul Husna screen renders and search works', (tester) async {
    await tester.pumpWidget(wrap(const AsmaulHusnaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Asmaul Husna'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Allah');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Duas screen renders', (tester) async {
    await tester.pumpWidget(wrap(const DuasScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Doa'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Content menu cards do not overflow on compact Android width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(const IslamicContentScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Doa Harian'), findsOneWidget);
    expect(find.text('Kalender Hijriah'), findsOneWidget);
    expect(find.text('Tips Islami'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hijri calendar screen renders', (tester) async {
    await tester.pumpWidget(wrap(const HijriCalendarScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hijriah'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Islamic tips screen renders', (tester) async {
    await tester.pumpWidget(wrap(const IslamicTipsScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tips'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dhikr screen renders and tabs switch', (tester) async {
    await tester.pumpWidget(wrap(const DhikrScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Dzikir Pagi & Petang'), findsOneWidget);
    await tester.tap(find.text('Dzikir Petang'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('content sub screens show explicit back button', (tester) async {
    for (final screen in const [
      AsmaulHusnaScreen(),
      DuasScreen(),
      HijriCalendarScreen(),
      IslamicTipsScreen(),
      DhikrScreen(),
    ]) {
      await tester.pumpWidget(wrap(screen));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
