import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/quran/domain/models/quran_models.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';
import 'package:solatify/features/quran/presentation/screens/quran_home_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('quran_test_dir');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await Hive.openBox<dynamic>('settings');
    await Hive.openBox<dynamic>('quran_bookmarks');
    await Hive.openBox<dynamic>('quran_index');
    await Hive.openBox<dynamic>('quran_surah_details');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Quran Model Tests', () {
    test('Should parse Surah from JSON correctly', () {
      final json = {
        'number': 1,
        'name': 'Al-Fatihah',
        'translation': 'Pembukaan',
        'numberOfVerses': 7,
        'revelation': 'Mekah',
        'verses': [
          {
            'number': 1,
            'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            'translation': 'Dengan menyebut nama Allah...',
            'audioUrl': 'https://example.com/audio1.mp3',
          },
        ],
      };

      final surah = Surah.fromJson(json);

      expect(surah.number, 1);
      expect(surah.name, 'Al-Fatihah');
      expect(surah.revelation, 'Mekah');
      expect(surah.verses?.length, 1);
      expect(
        surah.verses?.first.arabic,
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      );
    });

    test('Should parse Surah with Map verses correctly', () {
      final json = {
        'number': 1,
        'name': 'Al-Fatihah',
        'translation': 'Pembukaan',
        'numberOfVerses': 7,
        'revelation': 'Mekah',
        'verses': {
          '1': {
            'number': 1,
            'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            'translation': 'Dengan menyebut nama Allah...',
            'audioUrl': 'https://example.com/audio1.mp3',
          },
        },
      };

      final surah = Surah.fromJson(json);

      expect(surah.number, 1);
      expect(surah.verses?.length, 1);
      expect(
        surah.verses?.first.arabic,
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      );
    });

    test('Should serialize Surah back to JSON correctly', () {
      final surah = Surah(
        number: 2,
        name: 'Al-Baqarah',
        translation: 'Sapi Betina',
        numberOfVerses: 286,
        revelation: 'Madinah',
        verses: [
          Verse(
            number: 1,
            arabic: 'الٓمٓ',
            latin: 'Alif Lam Mim',
            translation: 'Alif Lam Mim',
            audioUrl: 'https://audio.mp3',
          ),
        ],
      );

      final json = surah.toJson();

      expect(json['number'], 2);
      expect(json['revelation'], 'Madinah');
      expect(json['verses'][0]['arabic'], 'الٓمٓ');
    });
  });

  group('Quran Bookmarks Provider Tests', () {
    test('Should toggle bookmark keys correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final bookmarksNotifier = container.read(quranBookmarksProvider.notifier);

      // Initially empty
      expect(
        container.read(quranBookmarksProvider).bookmarkedKeys.contains('1:1'),
        false,
      );

      // Toggle bookmark for Al-Fatihah verse 1
      await bookmarksNotifier.toggleBookmark(1, 1);
      expect(
        container.read(quranBookmarksProvider).bookmarkedKeys.contains('1:1'),
        true,
      );

      // Toggle bookmark again to remove it
      await bookmarksNotifier.toggleBookmark(1, 1);
      expect(
        container.read(quranBookmarksProvider).bookmarkedKeys.contains('1:1'),
        false,
      );
    });

    test('Should update last read verse correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final bookmarksNotifier = container.read(quranBookmarksProvider.notifier);

      expect(container.read(quranBookmarksProvider).lastReadSurah, null);

      // Set last read to Al-Kahf verse 10
      await bookmarksNotifier.setLastRead(18, 10, 'Al-Kahf');

      final state = container.read(quranBookmarksProvider);
      expect(state.lastReadSurah, 18);
      expect(state.lastReadVerse, 10);
      expect(state.lastReadSurahName, 'Al-Kahf');
    });
  });

  group('Quran Bookmark Key Parsing (crash-safety) Tests', () {
    test('parses and sorts valid keys', () {
      final result = QuranBookmarksNotifier.parseSortedBookmarkKeys([
        '18:10',
        '1:5',
        '1:2',
        '2:255',
      ]);
      expect(result, [
        [1, 2],
        [1, 5],
        [2, 255],
        [18, 10],
      ]);
    });

    test('skips malformed / legacy keys without crashing', () {
      final result = QuranBookmarksNotifier.parseSortedBookmarkKeys([
        '1:1',
        'garbage',
        '2:', // missing verse
        ':3', // missing surah
        'a:b', // non-numeric
        '3:4:5', // too many parts
        '2:7',
      ]);
      expect(result, [
        [1, 1],
        [2, 7],
      ]);
    });

    test('returns empty list for empty input', () {
      expect(QuranBookmarksNotifier.parseSortedBookmarkKeys([]), isEmpty);
    });

    test('tolerates whitespace around numbers', () {
      final result = QuranBookmarksNotifier.parseSortedBookmarkKeys([
        ' 5 : 9 ',
      ]);
      expect(result, [
        [5, 9],
      ]);
    });
  });

  group('Quran Reader Preferences Tests', () {
    test('uses readable defaults', () {
      const preferences = QuranReaderPreferences();

      expect(preferences.arabicFontSize, quranReaderDefaultArabicFontSize);
      expect(preferences.showTransliteration, isTrue);
      expect(preferences.showTranslation, isTrue);
      expect(preferences.focusMode, isFalse);
    });

    test('clamps Arabic font size to safe bounds', () {
      expect(clampQuranArabicFontSize(12), quranReaderMinArabicFontSize);
      expect(clampQuranArabicFontSize(60), quranReaderMaxArabicFontSize);
    });

    test('notifier updates reader controls', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(quranReaderPreferencesProvider.notifier);

      await notifier.updateArabicFontSize(36);
      await notifier.updateShowTransliteration(false);
      await notifier.updateShowTranslation(false);
      await notifier.updateFocusMode(true);

      final state = container.read(quranReaderPreferencesProvider);
      expect(state.arabicFontSize, 36);
      expect(state.showTransliteration, isFalse);
      expect(state.showTranslation, isFalse);
      expect(state.focusMode, isTrue);
    });
  });

  testWidgets('Quran home dark mode search accent is readable', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const QuranHomeScreen(),
        ),
      ),
    );

    await tester.pump();

    final searchIcon = tester.widget<Icon>(find.byIcon(Icons.search));
    expect(searchIcon.color, AppTheme.redAccentDark);
    expect(tester.takeException(), isNull);
  });
}
