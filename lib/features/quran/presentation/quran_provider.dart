import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../data/quran_repository.dart';
import '../domain/models/quran_models.dart';
import '../../../core/database/hive_service.dart';

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

// BOOKMARK STATES
class QuranBookmarksState {
  final int? lastReadSurah;
  final int? lastReadVerse;
  final String? lastReadSurahName;
  final Set<String> bookmarkedKeys; // Format: "surah:verse"

  QuranBookmarksState({
    this.lastReadSurah,
    this.lastReadVerse,
    this.lastReadSurahName,
    required this.bookmarkedKeys,
  });

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
  final int? playingSurah;
  final int? playingVerse;
  final bool isPlaying;
  final bool isLoading;
  final Duration progress;
  final Duration totalDuration;

  QuranAudioState({
    this.playingSurah,
    this.playingVerse,
    this.isPlaying = false,
    this.isLoading = false,
    this.progress = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  QuranAudioState copyWith({
    int? playingSurah,
    int? playingVerse,
    bool? isPlaying,
    bool? isLoading,
    Duration? progress,
    Duration? totalDuration,
  }) {
    return QuranAudioState(
      playingSurah: playingSurah ?? this.playingSurah,
      playingVerse: playingVerse ?? this.playingVerse,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Verse> _playlist = [];
  int _playlistIndex = 0;
  int? _surahNumber;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  QuranAudioNotifier() : super(QuranAudioState()) {
    // Listen to player state changes
    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      if (!mounted) return;
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      } else {
        state = state.copyWith(
          isPlaying: isPlaying,
          isLoading:
              processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering,
        );
      }
    });

    // Listen to position stream for progress updates
    _positionSub = _audioPlayer.positionStream.listen((position) {
      if (!mounted) return;
      state = state.copyWith(progress: position);
    });

    // Listen to duration stream
    _durationSub = _audioPlayer.durationStream.listen((duration) {
      if (!mounted) return;
      if (duration != null) {
        state = state.copyWith(totalDuration: duration);
      }
    });
  }

  Future<void> playVerse({
    required int surahNumber,
    required int verseNumber,
    required String audioUrl,
  }) async {
    if (audioUrl.isEmpty) return;

    // Reset playlist sequential playback variables
    _playlist = [];
    _playlistIndex = 0;
    _surahNumber = surahNumber;

    state = state.copyWith(
      playingSurah: surahNumber,
      playingVerse: verseNumber,
      isLoading: true,
      isPlaying: false,
      progress: Duration.zero,
      totalDuration: Duration.zero,
    );

    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (_) {
      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> playSurahSequentially(Surah surah) async {
    final verses = surah.verses;
    if (verses == null || verses.isEmpty) return;

    _playlist = verses;
    _playlistIndex = 0;
    _surahNumber = surah.number;

    await _playCurrentPlaylistItem();
  }

  Future<void> _playCurrentPlaylistItem() async {
    if (_playlistIndex >= _playlist.length) {
      stop();
      return;
    }

    final verse = _playlist[_playlistIndex];
    state = state.copyWith(
      playingSurah: _surahNumber,
      playingVerse: verse.number,
      isLoading: true,
      isPlaying: false,
      progress: Duration.zero,
      totalDuration: Duration.zero,
    );

    try {
      await _audioPlayer.setUrl(verse.audioUrl);
      await _audioPlayer.play();
    } catch (_) {
      // Skip to next if this fails
      _handlePlaybackCompleted();
    }
  }

  void _handlePlaybackCompleted() {
    if (_playlist.isNotEmpty && _playlistIndex < _playlist.length - 1) {
      _playlistIndex++;
      _playCurrentPlaylistItem();
    } else {
      stop();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _playlist = [];
    _playlistIndex = 0;
    _surahNumber = null;
    state = QuranAudioState();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
      final notifier = QuranAudioNotifier();
      ref.onDispose(() {
        notifier.dispose();
      });
      return notifier;
    });
