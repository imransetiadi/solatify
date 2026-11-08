import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/features/quran/data/quran_repository.dart';
import 'package:solatify/features/quran/domain/models/quran_models.dart';
import 'package:solatify/features/quran/presentation/quran_error_message.dart';
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

  group('Quran audio URL', () {
    test(
      'prefers a live secondary URL over the dead alquran.cloud primary',
      () {
        final verse = Verse.fromJson({
          'number': {'inSurah': 1},
          'text': {'arab': 'x'},
          'audio': {
            'primary':
                'https://cdn.alquran.cloud/media/audio/ayah/ar.alafasy/1',
            'secondary': [
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
            ],
          },
        });

        expect(
          verse.audioUrl,
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
        );
      },
    );

    test('repairs dead-host URLs read back from an older cache', () {
      final verse = Verse.fromJson({
        'number': 1,
        'arabic': 'x',
        'audioUrl': 'https://cdn.alquran.cloud/media/audio/ayah/ar.alafasy/262',
      });

      expect(
        verse.audioUrl,
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3',
      );
    });

    test('leaves other hosts untouched', () {
      const url = 'https://example.com/audio/1.mp3';
      expect(Verse.normalizeQuranAudioUrl(url), url);
    });
  });

  group('Quran languages, search and cache', () {
    Map<String, dynamic> apiVerse(int n) => {
      'number': {'inSurah': n},
      'text': {
        'arab': 'ARAB $n',
        'transliteration': {'en': 'latin $n'},
      },
      'translation': {'id': 'Terjemahan $n', 'en': 'Translation $n'},
      'audio': {'primary': 'https://cdn.islamic.network/a/$n.mp3'},
    };

    Map<String, dynamic> apiSurah(int number, {int verses = 2}) => {
      'number': number,
      'numberOfVerses': verses,
      'name': {
        'transliteration': {'id': 'Surah $number', 'en': 'Surah $number'},
        'translation': {'id': 'Arti $number', 'en': 'Meaning $number'},
      },
      'revelation': {'id': 'Makkiyah', 'en': 'Meccan'},
      'verses': [for (var v = 1; v <= verses; v++) apiVerse(v)],
    };

    test('keeps both translation languages, also through the cache', () {
      final surah = Surah.fromJson(apiSurah(112));
      final cached = Surah.fromJson(surah.toJson());

      for (final s in [surah, cached]) {
        expect(s.localizedTranslation(isEnglish: false), 'Arti 112');
        expect(s.localizedTranslation(isEnglish: true), 'Meaning 112');
        final verse = s.verses!.first;
        expect(verse.localizedTranslation(isEnglish: false), 'Terjemahan 1');
        expect(verse.localizedTranslation(isEnglish: true), 'Translation 1');
      }
    });

    test('surah search ignores hyphens, apostrophes and spaces', () {
      expect(
        normalizeSurahSearchText('Al-Baqarah'),
        normalizeSurahSearchText('al baqarah'),
      );
      expect(
        normalizeSurahSearchText(
          "Ali 'Imran",
        ).contains(normalizeSurahSearchText('ali imran')),
        isTrue,
      );
    });

    test('a partial surah index is refreshed, not trusted forever', () async {
      final index = Hive.box<dynamic>('quran_index');
      // An interrupted first fetch left only 3 of 114 surahs.
      for (var n = 1; n <= 3; n++) {
        await index.put('$n', jsonEncode(Surah.fromJson(apiSurah(n)).toJson()));
      }
      var requests = 0;
      final repository = QuranRepository(
        client: MockClient((request) async {
          requests++;
          return http.Response(
            jsonEncode({
              'data': [for (var n = 1; n <= 114; n++) apiSurah(n, verses: 0)],
            }),
            200,
          );
        }),
      );

      final list = await repository.getSurahList();

      expect(requests, 1);
      expect(list, hasLength(114));
      expect(index.length, 114);
      // Now complete and current: served from the cache.
      await repository.getSurahList();
      expect(requests, 1);
    });

    test('offline: falls back to an older cache instead of failing', () async {
      final details = Hive.box<dynamic>('quran_surah_details');
      final legacy = Surah.fromJson(apiSurah(112)).toJson();
      // A cache written before English was stored.
      for (final verse in legacy['verses'] as List) {
        (verse as Map).remove('translationEn');
      }
      await details.put('112', jsonEncode(legacy));
      final repository = QuranRepository(
        client: MockClient(
          (_) async => throw const SocketException('Failed host lookup'),
        ),
      );

      final surah = await repository.getSurahDetail(112);

      expect(surah.verses, hasLength(2));
    });

    test('errors are typed and shown in the app language', () async {
      final repository = QuranRepository(
        client: MockClient(
          (_) async => throw const SocketException('Failed host lookup'),
        ),
      );

      final error = await repository
          .getSurahDetail(1)
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<QuranLoadException>());
      expect((error! as QuranLoadException).failure, QuranLoadFailure.offline);
      final english = quranErrorMessage(error, isEnglish: true);
      expect(english, startsWith('No internet connection'));
      expect(english, isNot(contains('SocketException')));
      expect(
        quranErrorMessage(error, isEnglish: false),
        startsWith('Tidak ada koneksi internet'),
      );
    });

    test('a surah without verses is not cached', () async {
      final details = Hive.box<dynamic>('quran_surah_details');
      final repository = QuranRepository(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode({'data': apiSurah(5, verses: 0)}), 200),
        ),
      );

      await expectLater(
        repository.getSurahDetail(5),
        throwsA(isA<QuranLoadException>()),
      );
      expect(details.containsKey('5'), isFalse);
    });
  });
}
