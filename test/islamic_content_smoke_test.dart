import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart';
import 'package:solatify/features/dhikr/presentation/screens/dhikr_screen.dart';
import 'package:solatify/features/duas/presentation/screens/duas_screen.dart';
import 'package:solatify/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:solatify/features/islamic_content/presentation/screens/islamic_content_screen.dart';
import 'package:solatify/features/islamic_tips/presentation/screens/islamic_tips_screen.dart';
import 'package:solatify/features/prayer_guide/data/datasources/prayer_guide_local_data_source.dart';
import 'package:solatify/features/prayer_guide/presentation/screens/prayer_guide_screen.dart';

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

  testWidgets('Asmaul Husna dark mode latin title uses readable accent', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const AsmaulHusnaScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('1. Ar Rahman'));

    expect(title.style?.color, AppTheme.redAccentDark);
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

    expect(find.text('Konten Islami'), findsOneWidget);
    expect(find.text('Doa Harian'), findsOneWidget);
    expect(find.text('Kalender Hijriah'), findsOneWidget);
    expect(find.text('Tips Islami'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Content menu renders prayer guide card', (tester) async {
    await tester.pumpWidget(wrap(const IslamicContentScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tuntunan Salat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Prayer guide screen renders complete reading sections', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const PrayerGuideScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tuntunan Salat'), findsOneWidget);
    expect(find.text('Niat'), findsWidgets);
    expect(find.byKey(const Key('prayer_guide_arabic_text')), findsWidgets);
    expect(find.textContaining('Allahu akbar'), findsWidgets);
    expect(find.textContaining('Allah Maha Besar'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('Prayer guide content includes complete practical readings', () {
    const dataSource = PrayerGuideLocalDataSource();
    final steps = dataSource.getPrayerSteps();
    final fatihah = steps.firstWhere(
      (step) => step.title == 'Al-Fatihah dan Surat Pendek',
    );
    final tahiyatAkhir = steps.firstWhere(
      (step) => step.title == 'Tahiyat Akhir',
    );

    expect(fatihah.arabicText, contains('اَلْحَمْدُ لِلّٰهِ'));
    expect(fatihah.latinText, contains('Alhamdu lillahi'));
    expect(tahiyatAkhir.arabicText, contains('أَشْهَدُ أَنْ لَا إِلٰهَ'));
    expect(tahiyatAkhir.meaning, contains('Aku bersaksi'));
    expect(steps.any((step) => step.title == 'Doa Qunut Subuh'), isTrue);
  });

  testWidgets(
    'Prayer guide screen does not overflow on compact Android width',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(const PrayerGuideScreen()));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(ListView), const Offset(0, -700), 1000);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('prayer_guide_arabic_text')), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

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

  testWidgets('Dhikr screen does not overflow on compact Android width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(const DhikrScreen()));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dzikir Petang'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dhikr_arabic_text_block')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('content sub screens show explicit back button', (tester) async {
    for (final screen in const [
      AsmaulHusnaScreen(),
      DuasScreen(),
      HijriCalendarScreen(),
      IslamicTipsScreen(),
      DhikrScreen(),
      PrayerGuideScreen(),
    ]) {
      await tester.pumpWidget(wrap(screen));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
