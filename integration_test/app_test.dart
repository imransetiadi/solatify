import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solatify/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Solatify End-to-End Audit Test', () {
    testWidgets(
      'App launches, bypasses onboarding, and navigates all primary menus without crashing',
      (tester) async {
        app.main();

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final getStartedButton = find.textContaining('Mulai');
        if (getStartedButton.evaluate().isNotEmpty) {
          debugPrint('Onboarding found. Bypassing...');
          await tester.tap(getStartedButton.first);
          await tester.pumpAndSettle();
        }

        expect(find.text('Solatify'), findsWidgets);

        Future<void> tapLabel(String label) async {
          final target = find.text(label);
          expect(target, findsWidgets);
          await tester.tap(target.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        await tapLabel('Beranda');
        expect(find.text('Solatify'), findsWidgets);

        await tapLabel('Jadwal');
        expect(find.textContaining('Waktu salat'), findsWidgets);

        await tapLabel('Qur\'an');
        expect(find.textContaining('Al-Qur'), findsWidgets);
        final firstSurahCard = find.text('Al-Fatihah');
        if (firstSurahCard.evaluate().isNotEmpty) {
          await tester.tap(firstSurahCard.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          expect(find.textContaining('Al-Fatihah'), findsWidgets);
          await tester.pageBack();
          await tester.pumpAndSettle(const Duration(seconds: 1));
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
          final card = find.text(title);
          expect(card, findsWidgets);
          await tester.tap(card.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          expect(find.textContaining(title), findsWidgets);
          await tester.pageBack();
          await tester.pumpAndSettle(const Duration(seconds: 1));
          await tapLabel('Konten');
        }

        await tapLabel('Lainnya');
        await tester.pumpAndSettle();

        for (final label in ['Kiblat', 'Masjid', 'Pengaturan']) {
          final menuItem = find.text(label);
          expect(menuItem, findsWidgets);
          await tester.tap(menuItem.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          expect(find.text(label), findsWidgets);
          await tester.pageBack();
          await tester.pumpAndSettle(const Duration(seconds: 1));
          await tapLabel('Lainnya');
        }

        debugPrint('Audit completed successfully.');
      },
    );

    testWidgets(
      'Tablet layout shows navigation rail and remains interactive',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;

        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final getStartedButton = find.textContaining('Mulai');
        if (getStartedButton.evaluate().isNotEmpty) {
          await tester.tap(getStartedButton.first);
          await tester.pumpAndSettle();
        }

        expect(find.byType(NavigationRail), findsOneWidget);
        await tester.tap(find.text('Jadwal').first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.textContaining('Waktu salat'), findsWidgets);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
