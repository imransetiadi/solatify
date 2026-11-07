import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/features/quran/data/quran_repository.dart';
import 'package:solatify/features/quran/domain/models/quran_models.dart';

const double quranReaderMinArabicFontSize = 24;
const double quranReaderMaxArabicFontSize = 40;
const double quranReaderDefaultArabicFontSize = 30;
const String _quranReaderPreferencesKey = 'quran_reader_preferences';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

/// Fetches the index of all 114 Surahs.
final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getSurahList();
});

/// Holds the current search query text.
final surahSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filters the Surah list dynamically based on user search input.
final filteredSurahListProvider = Provider<AsyncValue<List<Surah>>>((ref) {
  final listAsync = ref.watch(surahListProvider);
  final query = ref.watch(surahSearchQueryProvider).trim().toLowerCase();

  return listAsync.whenData((list) {
    if (query.isEmpty) return list;
    return list.where((surah) {
      final nameMatches = surah.name.toLowerCase().contains(query);
      final translationMatches = surah.translation.toLowerCase().contains(
        query,
      );
      final numberMatches = surah.number.toString() == query;
      return nameMatches || translationMatches || numberMatches;
    }).toList();
  });
});

/// Fetches the details (verses) of a specific Surah.
final surahDetailProvider = FutureProvider.family<Surah, int>((
  ref,
  number,
) async {
  final repo = ref.watch(quranRepositoryProvider);
  return await repo.getSurahDetail(number);
});

class QuranReaderPreferences {
  const QuranReaderPreferences({
    this.arabicFontSize = quranReaderDefaultArabicFontSize,
    this.showTransliteration = true,
    this.showTranslation = true,
    this.focusMode = false,
  });

  factory QuranReaderPreferences.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return const QuranReaderPreferences();
    return QuranReaderPreferences(
      arabicFontSize: clampQuranArabicFontSize(
        (json['arabicFontSize'] as num?)?.toDouble() ??
            quranReaderDefaultArabicFontSize,
      ),
      showTransliteration: json['showTransliteration'] != false,
      showTranslation: json['showTranslation'] != false,
      focusMode: json['focusMode'] == true,
    );
  }

  final double arabicFontSize;
  final bool showTransliteration;
  final bool showTranslation;
  final bool focusMode;

  QuranReaderPreferences copyWith({
    double? arabicFontSize,
    bool? showTransliteration,
    bool? showTranslation,
    bool? focusMode,
  }) {
    return QuranReaderPreferences(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      focusMode: focusMode ?? this.focusMode,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'arabicFontSize': arabicFontSize,
      'showTransliteration': showTransliteration,
      'showTranslation': showTranslation,
      'focusMode': focusMode,
    };
  }
}

double clampQuranArabicFontSize(double value) {
  return value
      .clamp(quranReaderMinArabicFontSize, quranReaderMaxArabicFontSize)
      .toDouble();
}

class QuranReaderPreferencesNotifier
    extends StateNotifier<QuranReaderPreferences> {
  QuranReaderPreferencesNotifier() : super(_loadInitialState());

  static QuranReaderPreferences _loadInitialState() {
    try {
      final raw = HiveService.getSetting(_quranReaderPreferencesKey);
      if (raw is Map) return QuranReaderPreferences.fromJson(raw);
    } catch (_) {
      return const QuranReaderPreferences();
    }
    return const QuranReaderPreferences();
  }

  Future<void> updateArabicFontSize(double value) async {
    await _save(
      state.copyWith(arabicFontSize: clampQuranArabicFontSize(value)),
    );
  }

  Future<void> updateShowTransliteration(bool value) async {
    await _save(state.copyWith(showTransliteration: value));
  }

  Future<void> updateShowTranslation(bool value) async {
    await _save(state.copyWith(showTranslation: value));
  }

  Future<void> updateFocusMode(bool value) async {
    await _save(state.copyWith(focusMode: value));
  }

  Future<void> _save(QuranReaderPreferences next) async {
    state = next;
    await HiveService.saveSetting(_quranReaderPreferencesKey, next.toJson());
  }
}

final quranReaderPreferencesProvider =
    StateNotifierProvider<
      QuranReaderPreferencesNotifier,
      QuranReaderPreferences
    >((ref) {
      return QuranReaderPreferencesNotifier();
    });

// BOOKMARK STATES
class QuranBookmarksState {
  // Format: "surah:verse"

  QuranBookmarksState({
    this.lastReadSurah,
    this.lastReadVerse,
    this.lastReadSurahName,
    required this.bookmarkedKeys,
  });
  final int? lastReadSurah;
  final int? lastReadVerse;
  final String? lastReadSurahName;
  final Set<String> bookmarkedKeys;

  QuranBookmarksState copyWith({
    int? lastReadSurah,
    int? lastReadVerse,
    String? lastReadSurahName,
    Set<String>? bookmarkedKeys,
  }) {
    return QuranBookmarksState(
      lastReadSurah: lastReadSurah ?? this.lastReadSurah,
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
      lastReadSurahName: lastReadSurahName ?? this.lastReadSurahName,
      bookmarkedKeys: bookmarkedKeys ?? this.bookmarkedKeys,
    );
  }
}

class QuranBookmarksNotifier extends StateNotifier<QuranBookmarksState> {
  QuranBookmarksNotifier() : super(_loadInitialState());

  static QuranBookmarksState _loadInitialState() {
    try {
      final box = HiveService.tryGetBox(HiveService.quranBookmarksBoxName);
      if (box == null) {
        return QuranBookmarksState(bookmarkedKeys: {});
      }

      // Load last read
      final lastReadMap = box.get('last_read');
      int? lastSurah;
      int? lastVerse;
      String? lastSurahName;
      if (lastReadMap != null && lastReadMap is Map) {
        lastSurah = lastReadMap['surah'] as int?;
        lastVerse = lastReadMap['verse'] as int?;
        lastSurahName = lastReadMap['surahName'] as String?;
      }

      // Load bookmarks
      final rawList = box.get('list', defaultValue: <dynamic>[]);
      final Set<String> bookmarkedKeys = {};
      if (rawList is List) {
        bookmarkedKeys.addAll(rawList.map((e) => e.toString()));
      } else if (rawList is Map) {
        bookmarkedKeys.addAll(rawList.keys.map((e) => e.toString()));
      }

      return QuranBookmarksState(
        lastReadSurah: lastSurah,
        lastReadVerse: lastVerse,
        lastReadSurahName: lastSurahName,
        bookmarkedKeys: bookmarkedKeys,
      );
    } catch (e) {
      // If Hive box is corrupted or not open, return empty state
      return QuranBookmarksState(bookmarkedKeys: {});
    }
  }

  Future<void> setLastRead(
    int surahNumber,
    int verseNumber,
    String surahName,
  ) async {
    final box = HiveService.tryGetBox(HiveService.quranBookmarksBoxName);
    if (box == null) return;

    final data = {
      'surah': surahNumber,
      'verse': verseNumber,
      'surahName': surahName,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.put('last_read', data);
    state = state.copyWith(
      lastReadSurah: surahNumber,
      lastReadVerse: verseNumber,
      lastReadSurahName: surahName,
    );
  }

  Future<void> toggleBookmark(int surahNumber, int verseNumber) async {
    final box = HiveService.tryGetBox(HiveService.quranBookmarksBoxName);
    if (box == null) return;

    final key = '$surahNumber:$verseNumber';
    final updatedKeys = Set<String>.from(state.bookmarkedKeys);

    if (updatedKeys.contains(key)) {
      updatedKeys.remove(key);
    } else {
      updatedKeys.add(key);
    }

    await box.put('list', updatedKeys.toList());
    state = state.copyWith(bookmarkedKeys: updatedKeys);
  }

  bool isBookmarked(int surahNumber, int verseNumber) {
    return state.bookmarkedKeys.contains('$surahNumber:$verseNumber');
  }

  /// Parses raw "surah:verse" bookmark keys into sorted [surah, verse] pairs,
  /// safely skipping malformed/legacy keys (prevents crashes on int.parse).
  static List<List<int>> parseSortedBookmarkKeys(Iterable<String> keys) {
    final parsed = <List<int>>[];
    for (final key in keys) {
      final parts = key.split(':');
      if (parts.length != 2) continue;
      final s = int.tryParse(parts[0].trim());
      final v = int.tryParse(parts[1].trim());
      if (s == null || v == null) continue;
      parsed.add([s, v]);
    }
    parsed.sort(
      (a, b) => a[0] != b[0] ? a[0].compareTo(b[0]) : a[1].compareTo(b[1]),
    );
    return parsed;
  }
}

final quranBookmarksProvider =
    StateNotifierProvider<QuranBookmarksNotifier, QuranBookmarksState>((ref) {
      return QuranBookmarksNotifier();
    });

// AUDIO STATES
class QuranAudioState {
  QuranAudioState({
    this.playingSurah,
    this.playingSurahName,
    this.playingVerse,
    this.isPlaying = false,
    this.isLoading = false,
    this.progress = Duration.zero,
    this.totalDuration = Duration.zero,
    this.failureCount = 0,
  });
  final int? playingSurah;

  /// Shown by the mini-player and on the lock screen.
  final String? playingSurahName;
  final int? playingVerse;
  final bool isPlaying;
  final bool isLoading;
  final Duration progress;
  final Duration totalDuration;

  /// Increments every time audio fails to load, so the UI can react to each
  /// failure (e.g. show a snackbar) even when two failures happen in a row.
  final int failureCount;

  /// True while something is loaded (playing or paused).
  bool get isActive => playingSurah != null;

  QuranAudioState copyWith({
    int? playingSurah,
    String? playingSurahName,
    int? playingVerse,
    bool? isPlaying,
    bool? isLoading,
    Duration? progress,
    Duration? totalDuration,
    int? failureCount,
  }) {
    return QuranAudioState(
      playingSurah: playingSurah ?? this.playingSurah,
      playingSurahName: playingSurahName ?? this.playingSurahName,
      playingVerse: playingVerse ?? this.playingVerse,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      totalDuration: totalDuration ?? this.totalDuration,
      failureCount: failureCount ?? this.failureCount,
    );
  }
}

/// Plays Quran recitation, also in the background.
///
/// A whole surah is handed to the native player as one playlist, so verses
/// keep advancing while the app is in the background and the lock-screen /
/// notification controls (via just_audio_background) can skip verses. Each
/// request gets a generation number so an "interrupted" error from a load
/// that was superseded (e.g. tapping another verse while one is loading) is
/// ignored instead of stopping the new request.
class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  QuranAudioNotifier() : super(QuranAudioState()) {
    _listenToPlayer();
  }

  /// For widget tests: holds [initial] without creating a platform player or
  /// listening to it.
  @visibleForTesting
  QuranAudioNotifier.withoutPlayer(super.initial);

  void _listenToPlayer() {
    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      if (!mounted || !state.isActive) return;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        // The whole playlist (or the single verse) has finished.
        stop();
        return;
      }
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading:
            processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering,
      );
    });

    _indexSub = _audioPlayer.currentIndexStream.listen((index) {
      if (!mounted || !state.isActive) return;
      if (index == null || index >= _verseNumbers.length) return;
      state = state.copyWith(
        playingVerse: _verseNumbers[index],
        progress: Duration.zero,
      );
    });

    _positionSub = _audioPlayer.positionStream.listen((position) {
      if (!mounted || !state.isActive) return;
      state = state.copyWith(progress: position);
    });

    _durationSub = _audioPlayer.durationStream.listen((duration) {
      if (!mounted || duration == null) return;
      state = state.copyWith(totalDuration: duration);
    });

    // Errors while a later verse loads (e.g. the network drops mid-surah).
    _eventSub = _audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace _) {
        if (mounted && state.isActive) _reportFailure(error);
      },
    );
  }

  AudioPlayer? _player;
  AudioPlayer get _audioPlayer => _player ??= AudioPlayer();
  List<int> _verseNumbers = const [];
  int _generation = 0;
  bool _sessionConfigured = false;
  int _failureCount = 0;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _eventSub;

  /// Without an explicit session, iOS uses a category that is muted by the
  /// ring/silent switch, so recitation plays with no sound on silenced
  /// iPhones. The music preset uses the playback category instead.
  Future<void> _ensureAudioSession() async {
    if (_sessionConfigured) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _sessionConfigured = true;
    } catch (error) {
      // Playback can still work with the default session; retry next time.
      debugPrint('Failed to configure Quran audio session: $error');
    }
  }

  void _reportFailure(Object error) {
    debugPrint('Quran audio failed to load: $error');
    _failureCount++;
    _generation++;
    _verseNumbers = const [];
    _audioPlayer.stop().catchError((Object _) {});
    state = QuranAudioState(failureCount: _failureCount);
  }

  static AudioSource _sourceFor({
    required int surahNumber,
    required String surahName,
    required Verse verse,
  }) {
    return AudioSource.uri(
      Uri.parse(verse.audioUrl),
      tag: MediaItem(
        id: '$surahNumber:${verse.number}',
        title: 'QS. $surahName · Ayat ${verse.number}',
        album: 'Murotal Al-Qur\'an',
        artist: 'Mishary Rashid Alafasy',
      ),
    );
  }

  Future<void> _play({
    required int surahNumber,
    required String surahName,
    required List<Verse> verses,
  }) async {
    final playable = verses.where((v) => v.audioUrl.isNotEmpty).toList();
    if (playable.isEmpty || !mounted) return;

    final generation = ++_generation;
    _verseNumbers = [for (final verse in playable) verse.number];
    state = QuranAudioState(
      playingSurah: surahNumber,
      playingSurahName: surahName,
      playingVerse: playable.first.number,
      isLoading: true,
      failureCount: _failureCount,
    );

    try {
      await _ensureAudioSession();
      await _audioPlayer.setAudioSources([
        for (final verse in playable)
          _sourceFor(
            surahNumber: surahNumber,
            surahName: surahName,
            verse: verse,
          ),
      ], initialIndex: 0);
      if (!mounted || generation != _generation) return;
      // play() completes only when playback pauses or stops, so it is not
      // awaited; its errors still surface through playbackEventStream.
      unawaited(_audioPlayer.play().catchError((Object _) {}));
    } catch (error) {
      // A newer request superseded this one: its error is expected.
      if (!mounted || generation != _generation) return;
      _reportFailure(error);
    }
  }

  Future<void> playVerse({
    required int surahNumber,
    required int verseNumber,
    required String audioUrl,
    String? surahName,
  }) async {
    if (audioUrl.isEmpty) return;
    await _play(
      surahNumber: surahNumber,
      surahName: surahName ?? 'Surah $surahNumber',
      verses: [
        Verse(
          number: verseNumber,
          arabic: '',
          latin: '',
          translation: '',
          audioUrl: audioUrl,
        ),
      ],
    );
  }

  Future<void> playSurahSequentially(Surah surah) async {
    final verses = surah.verses;
    if (verses == null || verses.isEmpty) return;
    await _play(
      surahNumber: surah.number,
      surahName: surah.name,
      verses: verses,
    );
  }

  Future<void> pause() async {
    if (!mounted) return;
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    if (!mounted) return;
    await _ensureAudioSession();
    unawaited(_audioPlayer.play().catchError((Object _) {}));
  }

  Future<void> skipNext() async {
    if (!mounted || !_audioPlayer.hasNext) return;
    await _audioPlayer.seekToNext();
  }

  Future<void> skipPrevious() async {
    if (!mounted || !_audioPlayer.hasPrevious) return;
    await _audioPlayer.seekToPrevious();
  }

  bool get hasNext => _player?.hasNext ?? false;
  bool get hasPrevious => _player?.hasPrevious ?? false;

  Future<void> stop() async {
    _generation++;
    _verseNumbers = const [];
    if (mounted) state = QuranAudioState(failureCount: _failureCount);
    try {
      await _audioPlayer.stop();
    } catch (error) {
      debugPrint('Stopping Quran audio failed: $error');
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _indexSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _eventSub?.cancel();
    _player?.dispose();
    super.dispose();
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
      return QuranAudioNotifier();
    });
