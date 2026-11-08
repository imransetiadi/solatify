import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_offsets.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';
import 'package:solatify/features/settings/presentation/widgets/prayer_offset_dialog.dart';

final _standard = {
  'subuh': DateTime(2026, 11, 8, 4, 7),
  'dzuhur': DateTime(2026, 11, 8, 11, 40),
  'ashar': DateTime(2026, 11, 8, 14, 58),
  'magrib': DateTime(2026, 11, 8, 17, 51),
  'isya': DateTime(2026, 11, 8, 19, 3),
};

void main() {
  group('sanitizePrayerOffsets', () {
    test('fills missing keys, clamps, and drops junk', () {
      expect(
        sanitizePrayerOffsets({
          'subuh': 2,
          'dzuhur': 2.6,
          'ashar': '-4',
          'magrib': 999,
          'isya': double.nan,
          'imsak': 5,
        }),
        {'subuh': 2, 'dzuhur': 3, 'ashar': -4, 'magrib': 60, 'isya': 0},
      );
      expect(sanitizePrayerOffsets(null), {
        for (final key in prayerOffsetKeys) key: 0,
      });
    });
  });

  group('checkPrayerOffset', () {
    test('previews the corrected time', () {
      final check = checkPrayerOffset(
        prayerKey: 'subuh',
        minutes: 3,
        standardTimes: _standard,
        offsets: const {},
      );
      expect(check.correctedTime, DateTime(2026, 11, 8, 4, 10));
      expect(check.keepsPrayerOrder, isTrue);
      expect(check.earlierThanStandardOnSensitivePrayer, isFalse);
    });

    test('rejects a correction that moves a prayer past its neighbour', () {
      // Isya 19:03 - 60 = 18:03 is still after Magrib 17:51, but not once
      // Magrib itself is corrected by +15 (18:06).
      final check = checkPrayerOffset(
        prayerKey: 'isya',
        minutes: -60,
        standardTimes: _standard,
        offsets: const {'magrib': 15},
      );
      expect(check.mustStayAfter, 'magrib');
      expect(check.keepsPrayerOrder, isFalse);

      // Magrib 17:51 + 60 = 18:51 is after Isya once Isya is 19:03 - 15.
      final magrib = checkPrayerOffset(
        prayerKey: 'magrib',
        minutes: 60,
        standardTimes: _standard,
        offsets: const {'isya': -15},
      );
      expect(magrib.mustStayBefore, 'isya');
    });

    test('flags Subuh and Magrib moved earlier than standard', () {
      for (final key in ['subuh', 'magrib']) {
        expect(
          checkPrayerOffset(
            prayerKey: key,
            minutes: -1,
            standardTimes: _standard,
            offsets: const {},
          ).earlierThanStandardOnSensitivePrayer,
          isTrue,
          reason: key,
        );
      }
      expect(
        checkPrayerOffset(
          prayerKey: 'dzuhur',
          minutes: -5,
          standardTimes: _standard,
          offsets: const {},
        ).earlierThanStandardOnSensitivePrayer,
        isFalse,
      );
    });
  });

  group('settings provider', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('prayer_offset_rules');
      Hive.init(tempDir.path);
      await Hive.openBox<dynamic>('settings');
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('clamps saved corrections and resets them all', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updatePrayerOffsets('isya', 500);
      expect(container.read(settingsProvider).prayerOffsets['isya'], 60);

      await notifier.updatePrayerOffsets('subuh', -2);
      await notifier.resetPrayerOffsets();
      expect(
        hasActivePrayerOffsets(container.read(settingsProvider).prayerOffsets),
        isFalse,
      );
    });

    test('rejects unknown prayer keys', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        () => container
            .read(settingsProvider.notifier)
            .updatePrayerOffsets('imsak', 5),
        throwsArgumentError,
      );
    });

    test('remembers that the ihtiyat notice was dismissed', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(settingsProvider).ihtiyatNoticeDismissed, isFalse);
      await container.read(settingsProvider.notifier).dismissIhtiyatNotice();

      final reloaded = ProviderContainer();
      addTearDown(reloaded.dispose);
      expect(reloaded.read(settingsProvider).ihtiyatNoticeDismissed, isTrue);
    });
  });

  group('PrayerOffsetDialog', () {
    Future<void> pumpDialog(
      WidgetTester tester, {
      required String prayerKey,
      int initialOffset = 0,
      Map<String, int> offsets = const {},
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: PrayerOffsetDialog(
              title: 'Atur koreksi',
              prayerKey: prayerKey,
              initialOffset: initialOffset,
              standardTimes: _standard,
              offsets: offsets,
            ),
          ),
        ),
      );
      // Localizations load asynchronously.
      await tester.pumpAndSettle();
    }

    testWidgets('previews the resulting time', (tester) async {
      await pumpDialog(tester, prayerKey: 'subuh', initialOffset: 2);
      expect(find.textContaining('standar 04:07, menjadi 04:09'), findsOne);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(find.textContaining('menjadi 04:10'), findsOne);
    });

    testWidgets('warns when Magrib moves earlier than standard', (
      tester,
    ) async {
      await pumpDialog(tester, prayerKey: 'magrib');
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.warning_amber_rounded), findsOne);
      expect(find.textContaining('berbuka puasa'), findsOne);
    });

    testWidgets('disables saving a value that breaks prayer order', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        prayerKey: 'isya',
        initialOffset: -60,
        offsets: const {'magrib': 15},
      );
      expect(find.textContaining('jatuh sebelum'), findsOne);
      final save = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(save.onPressed, isNull);
    });
  });
}
