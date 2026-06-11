import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/features/quran/domain/models/quran_models.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('quran_test_dir');
    Hive.init(tempDir.path);
    await initializeDateFormatting('id_ID', null);
    await Hive.openBox('quran_bookmarks');
    await Hive.openBox('quran_index');
    await Hive.openBox('quran_surah_details');
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
            'audioUrl': 'https://example.com/audio1.mp3'
          }
        ]
      };

      final surah = Surah.fromJson(json);

      expect(surah.number, 1);
      expect(surah.name, 'Al-Fatihah');
      expect(surah.revelation, 'Mekah');
      expect(surah.verses?.length, 1);
      expect(surah.verses?.first.arabic, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
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
            'audioUrl': 'https://example.com/audio1.mp3'
          }
        }
      };

      final surah = Surah.fromJson(json);

      expect(surah.number, 1);
      expect(surah.verses?.length, 1);
      expect(surah.verses?.first.arabic, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
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
          )
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
      expect(container.read(quranBookmarksProvider).bookmarkedKeys.contains('1:1'), false);

      // Toggle bookmark for Al-Fatihah verse 1
      await bookmarksNotifier.toggleBookmark(1, 1);
      expect(container.read(quranBookmarksProvider).bookmarkedKeys.contains('1:1'), true);

      // Toggle bookmark again to remove it
      await bookmarksNotifier.toggleBookmark(1, 1);
      expect(container.read(quranBookmarksProvider).bookmarkedKeys.contains('1:1'), false);
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

  group('Quran Search Filtering Tests', () {
    test('Should filter surahs by query', () {
      final container = ProviderContainer(
        overrides: [
          // Override the full surah list with test data
          surahListProvider.overrideWith((ref) => [
            Surah(number: 1, name: 'Al-Fatihah', translation: 'Pembukaan', numberOfVerses: 7, revelation: 'Mekah'),
            Surah(number: 2, name: 'Al-Baqarah', translation: 'Sapi Betina', numberOfVerses: 286, revelation: 'Madinah'),
            Surah(number: 18, name: 'Al-Kahf', translation: 'Penghuni Gua', numberOfVerses: 110, revelation: 'Mekah'),
          ]),
        ],
      );
      addTearDown(container.dispose);

      // Verify initial empty query (returns all surahs)
      var filteredState = container.read(filteredSurahListProvider);
      expect(filteredState.value?.length, 3);

      // Filter by name query 'baqarah'
      container.read(surahSearchQueryProvider.notifier).state = 'baqarah';
      filteredState = container.read(filteredSurahListProvider);
      expect(filteredState.value?.length, 1);
      expect(filteredState.value?.first.name, 'Al-Baqarah');

      // Filter by translation query 'gua'
      container.read(surahSearchQueryProvider.notifier).state = 'gua';
      filteredState = container.read(filteredSurahListProvider);
      expect(filteredState.value?.length, 1);
      expect(filteredState.value?.first.name, 'Al-Kahf');

      // Filter by number query '18'
      container.read(surahSearchQueryProvider.notifier).state = '18';
      filteredState = container.read(filteredSurahListProvider);
      expect(filteredState.value?.length, 1);
      expect(filteredState.value?.first.name, 'Al-Kahf');
    });
  });
}
