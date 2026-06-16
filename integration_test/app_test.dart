import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Solatify End-to-End Audit Test', () {
    Future<void> waitForUi(WidgetTester tester, [int seconds = 1]) async {
      for (var tick = 0; tick < seconds * 2; tick++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    Future<void> bypassOnboardingIfNeeded(WidgetTester tester) async {
      for (var attempt = 0; attempt < 8; attempt++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('Solatify').evaluate().isNotEmpty &&
            find.text('Beranda').evaluate().isNotEmpty) {
          return;
        }

        final nextButton = find.textContaining('LANJUT');
        final startButton = find.textContaining('Mulai');
        final enterHomeButton = find.textContaining('Masuk ke Beranda');
        final candidate = enterHomeButton.evaluate().isNotEmpty
            ? enterHomeButton
            : startButton.evaluate().isNotEmpty
            ? startButton
            : nextButton;

        if (candidate.evaluate().isEmpty) return;
        await tester.tap(candidate.first);
        await waitForUi(tester);
      }
    }

    Future<void> launchAppWithCompletedOnboarding(WidgetTester tester) async {
      await HiveService.init();
      await HiveService.saveSetting('onboarding_completed', true);
      app.main();
      await waitForUi(tester, 5);
      await bypassOnboardingIfNeeded(tester);
    }

    Future<void> goBack(WidgetTester tester) async {
      await tester.binding.handlePopRoute();
      await waitForUi(tester);
    }

    testWidgets(
      'App launches, bypasses onboarding, and navigates all primary menus without crashing',
      (tester) async {
        await launchAppWithCompletedOnboarding(tester);

        expect(find.text('Solatify'), findsWidgets);

        Future<void> tapLabel(String label) async {
          debugPrint('Opening $label');
          final target = find.text(label);
          expect(target, findsWidgets);
          await tester.tap(target.first);
          await waitForUi(tester, 2);
        }

        await tapLabel('Beranda');
        expect(find.text('Solatify'), findsWidgets);

        await tapLabel('Jadwal');
        expect(find.textContaining('Jadwal Salat'), findsWidgets);

        await tapLabel('Qur\'an');
        expect(find.textContaining('Al-Qur'), findsWidgets);
        final firstSurahCard = find.text('Al-Fatihah');
        if (firstSurahCard.evaluate().isNotEmpty) {
          debugPrint('Opening Al-Fatihah detail');
          await tester.tap(firstSurahCard.first);
          await waitForUi(tester, 2);
          expect(find.textContaining('Al-Fatihah'), findsWidgets);
          await goBack(tester);
        }

        await tapLabel('Konten');
        expect(find.textContaining('Konten Islami'), findsWidgets);

        for (final title in [
          'Asmaul Husna',
          'Doa Harian',
          'Kalender Hijriah',
          'Dzikir',
          'Tips Islami',
        ]) {
          expect(find.text(title), findsWidgets);
        }

        await tapLabel('Lainnya');
        await waitForUi(tester);

        const moreMenuExpectedTitles = {
          'Pengaturan': 'Pengaturan',
          'Masjid': 'Masjid',
          'Kiblat': 'Arah Kiblat',
        };

        final moreMenuEntries = moreMenuExpectedTitles.entries.toList();
        for (var index = 0; index < moreMenuEntries.length; index++) {
          final entry = moreMenuEntries[index];
          final label = entry.key;
          final menuItem = find.text(label);
          expect(menuItem, findsWidgets);
          debugPrint('Opening more menu $label');
          await tester.tap(menuItem.first);
          await waitForUi(tester, 2);
          expect(find.textContaining(entry.value), findsWidgets);
          if (index == moreMenuEntries.length - 1) break;
          await tapLabel('Lainnya');
        }

        debugPrint('Audit completed successfully.');
      },
    );

    testWidgets('Tablet layout shows navigation rail and remains interactive', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;

      await launchAppWithCompletedOnboarding(tester);

      expect(find.byType(NavigationRail), findsOneWidget);
      await tester.tap(find.text('Jadwal').first);
      await waitForUi(tester, 2);
      expect(find.textContaining('Jadwal Salat'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
