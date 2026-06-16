import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/models/quran_models.dart';
import '../quran_provider.dart';

class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({
    super.key,
    required this.surahId,
    this.initialScrollVerse,
  });
  final int surahId;
  final int? initialScrollVerse;

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  bool _hasScrolled = false;

  Color get _textColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF241A12);
  Color get _accentColor => AppTheme.readableAccent(context);
  Color get _redAccent => Theme.of(context).colorScheme.tertiary;
  Color get _textMuted => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFC8B8A8)
      : const Color(0xFF5D4E47);
  Color get _textSecondary => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFB8A898)
      : const Color(0xFF5D4E47);
  Color get _dividerColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.04)
      : Colors.black.withValues(alpha: 0.06);
  Color get _cardBorderColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.04)
      : Colors.black.withValues(alpha: 0.08);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerse(int verseNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _verseKeys[verseNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() {
          _hasScrolled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahDetailProvider(widget.surahId));
    final audioState = ref.watch(quranAudioProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark
        ? const Color(0xFFC8B8A8)
        : const Color(0xFF5D4E47);

    return Scaffold(
      appBar: AppBar(
        title: surahAsync.when(
          loading: () => const Text('Memuat...'),
          error: (_, _) => const Text('Al-Qur\'an'),
          data: (surah) {
            final isPlayingThisSurah = audioState.playingSurah == surah.number;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPlayingThisSurah)
                  Text(
                    audioState.isPlaying
                        ? '🔊 Memutar semua ayat...'
                        : '⏸ Dijeda',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
              ],
            );
          },
        ),
        actions: [
          surahAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (surah) => IconButton(
              icon: Icon(
                audioState.playingSurah == surah.number && audioState.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                color: _redAccent,
                size: 28,
              ),
              tooltip: 'Putar Semua Ayat (${surah.numberOfVerses} Ayat)',
              onPressed: () {
                if (audioState.playingSurah == surah.number &&
                    audioState.isPlaying) {
                  ref.read(quranAudioProvider.notifier).pause();
                } else if (audioState.playingSurah == surah.number) {
                  ref.read(quranAudioProvider.notifier).resume();
                } else {
                  ref
                      .read(quranAudioProvider.notifier)
                      .playSurahSequentially(surah);
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            surahAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: _redAccent)),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: _redAccent, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat Surah',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString().replaceAll('Exception:', ''),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                        ),
                        onPressed: () =>
                            ref.refresh(surahDetailProvider(widget.surahId)),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (surah) {
                final verses = surah.verses ?? [];

                // Initialize keys for scrolling
                for (var v in verses) {
                  _verseKeys.putIfAbsent(v.number, () => GlobalKey());
                }

                // Scroll to target verse once loaded
                if (widget.initialScrollVerse != null &&
                    !_hasScrolled &&
                    verses.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _scrollToVerse(widget.initialScrollVerse!);
                  });
                }

                return ResponsiveCenter(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveLayout.pagePadding(context).horizontal / 2,
                      16,
                      ResponsiveLayout.pagePadding(context).horizontal / 2,
                      audioState.playingSurah != null ? 140 : 80,
                    ),
                    itemCount: verses.length + 1, // +1 for the Header Banner
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSurahHeaderBanner(surah);
                      }

                      final verse = verses[index - 1];
                      final isBookmarked = ref
                          .read(quranBookmarksProvider.notifier)
                          .isBookmarked(surah.number, verse.number);
                      final isCurrentlyPlaying =
                          audioState.playingSurah == surah.number &&
                          audioState.playingVerse == verse.number;

                      return _buildVerseItem(
                        surah: surah,
                        verse: verse,
                        isBookmarked: isBookmarked,
                        isCurrentlyPlaying: isCurrentlyPlaying,
                        audioState: audioState,
                      );
                    },
                  ),
                );
              },
            ),

            // Floating Audio player at bottom (respects safe area)
            if (audioState.playingSurah != null)
              Positioned(
                left: ResponsiveLayout.pagePadding(context).left,
                right: ResponsiveLayout.pagePadding(context).right,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                child: _buildAudioPlayerPanel(audioState),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahHeaderBanner(Surah surah) {
    final bool showBismillah =
        surah.number != 1 &&
        surah.number != 9; // Fatihah and Tawbah exclude Bismillah on top

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GlassContainer(
        blur: 15,
        opacity: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.03,
        borderColor: _redAccent.withValues(alpha: 0.32),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              surah.name,
              style: TextStyle(
                color: _textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              surah.translation,
              style: TextStyle(
                color: _textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 2,
              color: _redAccent.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  surah.revelation.toUpperCase(),
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.fiber_manual_record,
                  size: 5,
                  color: _textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  '${surah.numberOfVerses} AYAT',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (showBismillah) ...[
              const SizedBox(height: 24),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 26,
                  fontFamily: 'Amiri', // clean arabic font
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerseItem({
    required Surah surah,
    required Verse verse,
    required bool isBookmarked,
    required bool isCurrentlyPlaying,
    required QuranAudioState audioState,
  }) {
    final bookmarksState = ref.watch(quranBookmarksProvider);
    final isLastRead =
        bookmarksState.lastReadSurah == surah.number &&
        bookmarksState.lastReadVerse == verse.number;

    return Container(
      key: _verseKeys[verse.number],
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse Index Header & Buttons Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isLastRead
                  ? _accentColor.withValues(alpha: 0.12)
                  : _textColor.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLastRead
                    ? _accentColor.withValues(alpha: 0.3)
                    : _cardBorderColor,
              ),
            ),
            child: Row(
              children: [
                // Verse Number Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isLastRead
                        ? _accentColor
                        : _redAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLastRead
                          ? _accentColor
                          : _redAccent.withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      verse.number.toString(),
                      style: TextStyle(
                        color: isLastRead ? Colors.white : _textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isLastRead)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TERAKHIR BACA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),

                // Play Audio
                IconButton(
                  icon: Icon(
                    isCurrentlyPlaying && audioState.isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_arrow_outlined,
                    color: isCurrentlyPlaying ? _redAccent : _textSecondary,
                    size: 20,
                  ),
                  tooltip: 'Putar Ayat',
                  onPressed: () {
                    if (isCurrentlyPlaying && audioState.isPlaying) {
                      ref.read(quranAudioProvider.notifier).pause();
                    } else if (isCurrentlyPlaying) {
                      ref.read(quranAudioProvider.notifier).resume();
                    } else {
                      ref
                          .read(quranAudioProvider.notifier)
                          .playVerse(
                            surahNumber: surah.number,
                            verseNumber: verse.number,
                            audioUrl: verse.audioUrl,
                          );
                    }
                  },
                ),

                // Last Read button
                IconButton(
                  icon: Icon(
                    isLastRead ? Icons.bookmark : Icons.bookmark_border,
                    color: _accentColor,
                    size: 20,
                  ),
                  tooltip: 'Tandai Terakhir Baca',
                  onPressed: () {
                    ref
                        .read(quranBookmarksProvider.notifier)
                        .setLastRead(surah.number, verse.number, surah.name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Terakhir baca ditandai ke Surah ${surah.name} [Ayat ${verse.number}]',
                        ),
                        backgroundColor: _accentColor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // Save Bookmark
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.star : Icons.star_border,
                    color: isBookmarked ? _redAccent : _textSecondary,
                    size: 20,
                  ),
                  tooltip: 'Simpan Ayat',
                  onPressed: () {
                    ref
                        .read(quranBookmarksProvider.notifier)
                        .toggleBookmark(surah.number, verse.number);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Arabic Text
          Text(
            verse.arabic,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _textColor,
              fontSize: 28,
              height: 2.0,
              fontFamily: 'Amiri', // beautiful standard Arabic font
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Latin Transliteration Text
          if (verse.latin.isNotEmpty) ...[
            Text(
              verse.latin,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Translation Text
          Text(
            verse.translation,
            textAlign: TextAlign.left,
            style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Divider(color: _dividerColor, height: 1),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerPanel(QuranAudioState state) {
    final isPlaying = state.isPlaying;
    final isLoading = state.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDark
        ? const Color(0xFFAFA19A)
        : const Color(0xFF5D4E47);

    final progressPercent = state.totalDuration.inMilliseconds > 0
        ? state.progress.inMilliseconds / state.totalDuration.inMilliseconds
        : 0.0;

    return GlassContainer(
      blur: 20,
      opacity: 0.08,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: _redAccent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memutar Surah ${widget.surahId}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Ayat ${state.playingVerse}',
                      style: TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFC0392B),
                    ),
                  ),
                )
              else ...[
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _redAccent,
                    size: 22,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      ref.read(quranAudioProvider.notifier).pause();
                    } else {
                      ref.read(quranAudioProvider.notifier).resume();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop, color: _textColor, size: 22),
                  onPressed: () {
                    ref.read(quranAudioProvider.notifier).stop();
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 3,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            ),
          ),
        ],
      ),
    );
  }
}
