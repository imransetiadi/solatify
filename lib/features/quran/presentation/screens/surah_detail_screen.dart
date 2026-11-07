import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/quran/domain/models/quran_models.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';

/// Comfortable reading column width for verses on tablets/desktop.
const double _readingMaxWidth = 720;

/// Rough verse height used to estimate reading progress and to jump close to
/// verses that the lazy list has not built yet.
const double _estimatedVerseHeight = 260;

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
  Timer? _initialScrollTimer;
  bool _hasScrolled = false;
  bool _initialScrollScheduled = false;
  int _currentVerse = 1;
  int _totalVerses = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateReadingProgressFromScroll);
    // Cached because `ref` cannot be used in dispose().
    _audioNotifier = ref.read(quranAudioProvider.notifier);
  }

  late final QuranAudioNotifier _audioNotifier;

  Color get _textColor => SolatifyColors.text(context);
  Color get _accentColor => AppTheme.readableAccent(context);
  Color get _redAccent => SolatifyColors.accent(context);
  Color get _textSecondary => SolatifyColors.muted(context);
  Color get _dividerColor => SolatifyColors.border(context);

  /// Foreground for solid [_accentColor] fills (secondary in light mode,
  /// tertiary in dark mode — see [AppTheme.readableAccent]).
  Color get _onReadableAccent {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? scheme.onTertiary
        : scheme.onSecondary;
  }

  AppLocalizations get _l => AppLocalizations.of(context);

  @override
  void dispose() {
    // Recitation is controlled from this screen only, so stop it on leave
    // instead of letting it play on with no visible controls.
    _audioNotifier.stop();
    _initialScrollTimer?.cancel();
    _scrollController.removeListener(_updateReadingProgressFromScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateReadingProgressFromScroll() {
    if (!_scrollController.hasClients || _totalVerses <= 1) return;
    final nextVerse =
        (_scrollController.offset / _estimatedVerseHeight).floor().clamp(
          0,
          _totalVerses - 1,
        ) +
        1;
    if (nextVerse != _currentVerse && mounted) {
      setState(() => _currentVerse = nextVerse);
    }
  }

  void _scheduleInitialScroll(int verseNumber) {
    if (_initialScrollScheduled) return;
    _initialScrollScheduled = true;
    _initialScrollTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _currentVerse = verseNumber);
      _scrollToVerse(verseNumber);
    });
  }

  void _scrollToVerse(int verseNumber, {int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _verseKeys[verseNumber]?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: SolatifyMotion.of(
            context,
            const Duration(milliseconds: 600),
          ),
          curve: Curves.easeInOut,
        );
        setState(() => _hasScrolled = true);
        return;
      }

      // The list builds lazily, so far-away verses have no context yet.
      // Jump towards the verse and retry until it is built.
      if (attempt >= 40 || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final builtVerses = _verseKeys.entries
          .where((entry) => entry.value.currentContext != null)
          .map((entry) => entry.key)
          .toList();
      double target;
      if (attempt == 0 || builtVerses.isEmpty) {
        target = (verseNumber - 1) * _estimatedVerseHeight;
      } else {
        final highest = builtVerses.reduce((a, b) => a > b ? a : b);
        final step = position.viewportDimension;
        target = verseNumber > highest
            ? position.pixels + step
            : position.pixels - step;
      }
      final clamped = target.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (attempt > 0 && clamped == position.pixels) return;
      _scrollController.jumpTo(clamped);
      _scrollToVerse(verseNumber, attempt: attempt + 1);
    });
  }

  void _toggleSurahPlayback(Surah surah, QuranAudioState audioState) {
    SolatifyHaptics.selection();
    final notifier = ref.read(quranAudioProvider.notifier);
    if (audioState.playingSurah == surah.number && audioState.isPlaying) {
      notifier.pause();
    } else if (audioState.playingSurah == surah.number) {
      notifier.resume();
    } else {
      notifier.playSurahSequentially(surah);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahDetailProvider(widget.surahId));
    final audioState = ref.watch(quranAudioProvider);
    final readerPreferences = ref.watch(quranReaderPreferencesProvider);

    ref.listen<int>(quranAudioProvider.select((state) => state.failureCount), (
      previous,
      next,
    ) {
      if (previous == null || next <= previous) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _l.isEnglish
                  ? 'Audio could not be played. Check your connection and try again.'
                  : 'Audio tidak dapat diputar. Periksa koneksi lalu coba lagi.',
            ),
          ),
        );
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: readerPreferences.focusMode ? 48 : null,
        title: surahAsync.when(
          loading: () => Text(_l.isEnglish ? 'Loading...' : 'Memuat...'),
          error: (_, _) => const Text('Al-Qur\'an'),
          data: (surah) {
            final isPlayingThisSurah = audioState.playingSurah == surah.number;
            final verseNumber = audioState.playingVerse;
            final String status;
            if (audioState.isLoading) {
              status = _l.isEnglish ? 'Loading audio...' : 'Memuat audio...';
            } else if (audioState.isPlaying) {
              status = _l.isEnglish
                  ? 'Playing verse $verseNumber'
                  : 'Memutar ayat $verseNumber';
            } else {
              status = _l.isEnglish ? 'Paused' : 'Dijeda';
            }
            return Semantics(
              header: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: SolatifyType.pageTitle - 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!readerPreferences.focusMode && isPlayingThisSurah)
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SolatifyType.eyebrow,
                        color: _textSecondary,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Text(
              'Aa',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            tooltip: _l.isEnglish ? 'Reading display' : 'Tampilan baca',
            onPressed: () {
              SolatifyHaptics.selection();
              _showReaderControls(context);
            },
          ),
          surahAsync.when(
            loading: () => const SizedBox(),
            error: (_, _) => const SizedBox(),
            data: (surah) => _buildPlayAllButton(
              surah,
              audioState,
              readerPreferences.focusMode,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            surahAsync.when(
              loading: () => SolatifyStateView.loading(
                title: _l.isEnglish ? 'Loading surah' : 'Memuat Surah',
                description: _l.isEnglish
                    ? 'Preparing the verses and translation.'
                    : 'Menyiapkan ayat dan terjemahan Al-Qur\'an.',
              ),
              error: (err, stack) => Center(
                child: SingleChildScrollView(
                  padding: ResponsiveLayout.pagePadding(
                    context,
                  ).copyWith(top: SolatifySpacing.lg),
                  child: SolatifyStateView.error(
                    title: _l.isEnglish
                        ? 'Failed to load surah'
                        : 'Gagal memuat Surah',
                    description: err
                        .toString()
                        .replaceAll('Exception:', '')
                        .trim(),
                    actionLabel: _l.isEnglish ? 'Try again' : 'Coba Lagi',
                    onAction: () {
                      SolatifyHaptics.light();
                      ref.invalidate(surahDetailProvider(widget.surahId));
                    },
                  ),
                ),
              ),
              data: (surah) {
                final verses = surah.verses ?? [];
                _totalVerses = verses.isEmpty ? 1 : verses.length;
                final progressVerse = _currentVerse.clamp(
                  1,
                  verses.isEmpty ? 1 : verses.length,
                );

                // Initialize keys for scrolling
                for (var v in verses) {
                  _verseKeys.putIfAbsent(v.number, () => GlobalKey());
                }

                // Scroll to target verse once loaded
                if (widget.initialScrollVerse != null &&
                    !_hasScrolled &&
                    verses.isNotEmpty) {
                  _scheduleInitialScroll(widget.initialScrollVerse!);
                }

                if (verses.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: ResponsiveLayout.pagePadding(
                        context,
                      ).copyWith(top: SolatifySpacing.lg),
                      child: SolatifyStateView.empty(
                        icon: Icons.menu_book_outlined,
                        title: _l.isEnglish
                            ? 'No verses available'
                            : 'Ayat belum tersedia',
                        description: _l.isEnglish
                            ? 'Check your connection and try again.'
                            : 'Periksa koneksi Anda lalu coba lagi.',
                        actionLabel: _l.isEnglish ? 'Try again' : 'Coba Lagi',
                        onAction: () {
                          SolatifyHaptics.light();
                          ref.invalidate(surahDetailProvider(widget.surahId));
                        },
                      ),
                    ),
                  );
                }

                final horizontal =
                    ResponsiveLayout.pagePadding(context).horizontal / 2;

                return ResponsiveCenter(
                  maxWidth: _readingMaxWidth,
                  child: Column(
                    children: [
                      _buildReadingProgress(progressVerse, verses.length),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            horizontal,
                            readerPreferences.focusMode
                                ? SolatifySpacing.sm
                                : SolatifySpacing.lg,
                            horizontal,
                            audioState.playingSurah != null ? 170 : 80,
                          ),
                          itemCount: verses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return readerPreferences.focusMode
                                  ? const SizedBox(height: 8)
                                  : _buildSurahHeaderBanner(surah);
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
                              preferences: readerPreferences,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Floating Audio player at bottom (respects safe area)
            if (audioState.playingSurah != null)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    SolatifySpacing.lg,
                child: ResponsiveCenter(
                  maxWidth: _readingMaxWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveLayout.pagePadding(context).horizontal / 2,
                    ),
                    child: _buildAudioPlayerPanel(
                      audioState,
                      surahAsync.valueOrNull,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayAllButton(
    Surah surah,
    QuranAudioState audioState,
    bool focusMode,
  ) {
    final isThisSurah = audioState.playingSurah == surah.number;
    final isPlaying = isThisSurah && audioState.isPlaying;
    final isLoading = isThisSurah && audioState.isLoading;
    final color = focusMode ? _textSecondary : _redAccent;

    final String tooltip;
    if (isPlaying) {
      tooltip = _l.isEnglish ? 'Pause recitation' : 'Jeda murotal';
    } else if (isThisSurah) {
      tooltip = _l.isEnglish ? 'Resume recitation' : 'Lanjutkan murotal';
    } else {
      tooltip = _l.isEnglish
          ? 'Play all verses (${surah.numberOfVerses} verses)'
          : 'Putar Semua Ayat (${surah.numberOfVerses} Ayat)';
    }

    return IconButton(
      tooltip: tooltip,
      icon: AnimatedSwitcher(
        duration: SolatifyMotion.of(context, SolatifyMotion.fast),
        child: isLoading
            ? SizedBox(
                key: const ValueKey('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: color,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                key: ValueKey(isPlaying),
                color: color,
                size: 28,
              ),
      ),
      onPressed: () => _toggleSurahPlayback(surah, audioState),
    );
  }

  Widget _buildSurahHeaderBanner(Surah surah) {
    final bool showBismillah =
        surah.number != 1 &&
        surah.number != 9; // Fatihah and Tawbah exclude Bismillah on top
    final versesLabel = _l.isEnglish
        ? '${surah.numberOfVerses} VERSES'
        : '${surah.numberOfVerses} AYAT';

    return Container(
      margin: const EdgeInsets.only(bottom: SolatifySpacing.xl),
      child: GlassContainer(
        borderColor: _redAccent.withValues(alpha: 0.32),
        padding: const EdgeInsets.symmetric(
          vertical: SolatifySpacing.xl,
          horizontal: SolatifySpacing.lg,
        ),
        child: Column(
          children: [
            Semantics(
              header: true,
              child: Text(
                surah.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (surah.translation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                surah.translation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: SolatifyType.body,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: SolatifySpacing.md),
            ExcludeSemantics(
              child: Container(
                width: 80,
                height: 2,
                color: _redAccent.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: SolatifySpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: SolatifySpacing.sm,
              runSpacing: 4,
              children: [
                if (surah.revelation.isNotEmpty) ...[
                  Text(
                    surah.revelation.toUpperCase(),
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: SolatifyType.eyebrow,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Icon(
                    Icons.fiber_manual_record,
                    size: 5,
                    color: SolatifyColors.subtle(context),
                  ),
                ],
                Text(
                  versesLabel,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: SolatifyType.eyebrow,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            if (showBismillah) ...[
              const SizedBox(height: SolatifySpacing.xl),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                locale: const Locale('ar'),
                style: TextStyle(
                  color: _textColor,
                  fontSize: 26,
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadingProgress(int currentVerse, int totalVerses) {
    final fraction = totalVerses <= 0
        ? 0.0
        : (currentVerse / totalVerses).clamp(0.0, 1.0);
    final title = _l.isEnglish ? 'Surah progress' : 'Progress Surah';
    final value = _l.isEnglish
        ? 'Verse $currentVerse / $totalVerses'
        : 'Ayat $currentVerse / $totalVerses';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveLayout.pagePadding(context).horizontal / 2,
        8,
        ResponsiveLayout.pagePadding(context).horizontal / 2,
        0,
      ),
      child: Semantics(
        label: '$title, $value',
        container: true,
        child: ExcludeSemantics(
          child: GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      color: _accentColor,
                      size: SolatifyIconSize.inline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: SolatifyType.caption,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: SolatifyType.caption,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: fraction),
                    duration: SolatifyMotion.of(context, SolatifyMotion.medium),
                    curve: SolatifyMotion.curve,
                    builder: (context, animated, _) => LinearProgressIndicator(
                      value: animated,
                      minHeight: 3,
                      backgroundColor: SolatifyColors.raisedSurface(context),
                      valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPill({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseItem({
    required Surah surah,
    required Verse verse,
    required bool isBookmarked,
    required bool isCurrentlyPlaying,
    required QuranAudioState audioState,
    required QuranReaderPreferences preferences,
  }) {
    final bookmarksState = ref.watch(quranBookmarksProvider);
    final isLastRead =
        bookmarksState.lastReadSurah == surah.number &&
        bookmarksState.lastReadVerse == verse.number;
    final isVerseLoading = isCurrentlyPlaying && audioState.isLoading;
    final isVersePlaying = isCurrentlyPlaying && audioState.isPlaying;
    final verseLabel = _l.isEnglish
        ? 'Verse ${verse.number}'
        : 'Ayat ${verse.number}';

    final String playTooltip;
    if (isVersePlaying) {
      playTooltip = _l.isEnglish ? 'Pause verse' : 'Jeda ayat';
    } else if (isCurrentlyPlaying && !isVerseLoading) {
      playTooltip = _l.isEnglish ? 'Resume verse' : 'Lanjutkan ayat';
    } else {
      playTooltip = _l.isEnglish ? 'Play verse' : 'Putar Ayat';
    }

    return AnimatedContainer(
      key: _verseKeys[verse.number],
      duration: SolatifyMotion.of(context, SolatifyMotion.medium),
      curve: SolatifyMotion.curve,
      margin: const EdgeInsets.only(bottom: SolatifySpacing.lg),
      padding: const EdgeInsets.fromLTRB(
        SolatifySpacing.xs,
        SolatifySpacing.xs,
        SolatifySpacing.xs,
        0,
      ),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? SolatifyColors.accentSoft(context)
            : Colors.transparent,
        borderRadius: SolatifyRadius.compactCard,
        border: Border.all(
          color: isCurrentlyPlaying
              ? SolatifyColors.borderStrong(context)
              : Colors.transparent,
          width: isCurrentlyPlaying ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse Index Header & Buttons Row
          Container(
            padding: const EdgeInsets.fromLTRB(10, 2, 2, 2),
            decoration: BoxDecoration(
              color: isLastRead
                  ? _accentColor.withValues(alpha: 0.12)
                  : SolatifyColors.raisedSurface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLastRead
                    ? _accentColor.withValues(alpha: 0.3)
                    : SolatifyColors.border(context),
              ),
            ),
            child: Row(
              children: [
                // Verse Number Badge
                Semantics(
                  label: verseLabel,
                  child: ExcludeSemantics(
                    child: Container(
                      width: 34,
                      height: 34,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isLastRead
                            ? _accentColor
                            : _redAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLastRead
                              ? _accentColor
                              : _redAccent.withValues(alpha: 0.45),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          verse.number.toString(),
                          style: TextStyle(
                            color: isLastRead ? _onReadableAccent : _textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: SolatifyType.caption,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (isLastRead)
                        _statusPill(
                          icon: Icons.bookmark_rounded,
                          label: _l.isEnglish ? 'LAST READ' : 'TERAKHIR BACA',
                          background: _accentColor,
                          foreground: _onReadableAccent,
                        ),
                      if (isCurrentlyPlaying)
                        Semantics(
                          liveRegion: true,
                          child: _statusPill(
                            icon: isVerseLoading
                                ? Icons.hourglass_top_rounded
                                : isVersePlaying
                                ? Icons.graphic_eq_rounded
                                : Icons.pause_rounded,
                            label: isVerseLoading
                                ? (_l.isEnglish ? 'LOADING' : 'MEMUAT')
                                : isVersePlaying
                                ? (_l.isEnglish ? 'PLAYING' : 'DIPUTAR')
                                : (_l.isEnglish ? 'PAUSED' : 'DIJEDA'),
                            background: _redAccent,
                            foreground: SolatifyColors.onAccent(context),
                          ),
                        ),
                    ],
                  ),
                ),

                // Play Audio
                IconButton(
                  tooltip: playTooltip,
                  icon: isVerseLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _redAccent,
                          ),
                        )
                      : Icon(
                          isVersePlaying
                              ? Icons.pause_circle_outline
                              : Icons.play_arrow_outlined,
                          color: isCurrentlyPlaying
                              ? _redAccent
                              : _textSecondary,
                          size: 22,
                        ),
                  onPressed: verse.audioUrl.isEmpty
                      ? null
                      : () {
                          SolatifyHaptics.selection();
                          if (isVersePlaying) {
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
                  isSelected: isLastRead,
                  icon: Icon(
                    isLastRead ? Icons.bookmark : Icons.bookmark_border,
                    color: _accentColor,
                    size: 22,
                  ),
                  tooltip: _l.isEnglish
                      ? 'Mark as last read'
                      : 'Tandai Terakhir Baca',
                  onPressed: () {
                    SolatifyHaptics.success();
                    ref
                        .read(quranBookmarksProvider.notifier)
                        .setLastRead(surah.number, verse.number, surah.name);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          _l.isEnglish
                              ? 'Last read set to Surah ${surah.name}, verse ${verse.number}'
                              : 'Terakhir baca ditandai ke Surah ${surah.name} [Ayat ${verse.number}]',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // Save Bookmark
                IconButton(
                  isSelected: isBookmarked,
                  icon: Icon(
                    isBookmarked ? Icons.star : Icons.star_border,
                    color: isBookmarked ? _redAccent : _textSecondary,
                    size: 22,
                  ),
                  tooltip: isBookmarked
                      ? (_l.isEnglish
                            ? 'Remove saved verse'
                            : 'Hapus dari simpanan')
                      : (_l.isEnglish ? 'Save verse' : 'Simpan Ayat'),
                  onPressed: () {
                    SolatifyHaptics.light();
                    ref
                        .read(quranBookmarksProvider.notifier)
                        .toggleBookmark(surah.number, verse.number);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: SolatifySpacing.lg),

          // Arabic text: right-to-left, generous line height for diacritics.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              verse.arabic,
              textAlign: TextAlign.start,
              textDirection: TextDirection.rtl,
              locale: const Locale('ar'),
              style: TextStyle(
                color: _textColor,
                fontSize: preferences.arabicFontSize,
                height: 2.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: SolatifySpacing.md),

          if (preferences.showTransliteration && verse.latin.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                verse.latin,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: _accentColor,
                  fontSize: SolatifyType.body,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: SolatifySpacing.sm),
          ],

          if (preferences.showTranslation) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                verse.translation,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.88),
                  fontSize: SolatifyType.body + 1,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: SolatifySpacing.lg),
          ],
          if (!isCurrentlyPlaying) Divider(color: _dividerColor, height: 1),
          if (isCurrentlyPlaying) const SizedBox(height: SolatifySpacing.xs),
        ],
      ),
    );
  }

  void _showReaderControls(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final preferences = ref.watch(quranReaderPreferencesProvider);
            final notifier = ref.read(quranReaderPreferencesProvider.notifier);
            final isEnglish = AppLocalizations.of(context).isEnglish;
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ResponsiveCenter(
                  maxWidth: 560,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          isEnglish
                              ? 'Qur\'an Reading Display'
                              : 'Tampilan Baca Qur\'an',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: SolatifySpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isEnglish ? 'Arabic size' : 'Ukuran Arab',
                              style: TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            preferences.arabicFontSize.round().toString(),
                            style: TextStyle(color: _textSecondary),
                          ),
                        ],
                      ),
                      Slider(
                        value: preferences.arabicFontSize,
                        min: quranReaderMinArabicFontSize,
                        max: quranReaderMaxArabicFontSize,
                        divisions: 8,
                        label: preferences.arabicFontSize.round().toString(),
                        semanticFormatterCallback: (value) =>
                            '${isEnglish ? 'Arabic size' : 'Ukuran Arab'} ${value.round()}',
                        onChanged: (value) {
                          if (value.round() !=
                              preferences.arabicFontSize.round()) {
                            SolatifyHaptics.selection();
                          }
                          notifier.updateArabicFontSize(value);
                        },
                      ),
                      // Live preview of the chosen Arabic size.
                      ExcludeSemantics(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: SolatifySpacing.md,
                            vertical: SolatifySpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: SolatifyColors.raisedSurface(context),
                            borderRadius: SolatifyRadius.icon,
                          ),
                          child: Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            locale: const Locale('ar'),
                            style: TextStyle(
                              color: _textColor,
                              fontSize: preferences.arabicFontSize,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SolatifySpacing.sm),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isEnglish
                              ? 'Show transliteration'
                              : 'Tampilkan transliterasi',
                        ),
                        value: preferences.showTransliteration,
                        onChanged: (value) {
                          SolatifyHaptics.light();
                          notifier.updateShowTransliteration(value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isEnglish
                              ? 'Show translation'
                              : 'Tampilkan terjemahan',
                        ),
                        value: preferences.showTranslation,
                        onChanged: (value) {
                          SolatifyHaptics.light();
                          notifier.updateShowTranslation(value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(isEnglish ? 'Focus mode' : 'Mode fokus'),
                        subtitle: Text(
                          isEnglish
                              ? 'Compact header and reading area.'
                              : 'Ringkas header dan area baca.',
                        ),
                        value: preferences.focusMode,
                        onChanged: (value) {
                          SolatifyHaptics.light();
                          notifier.updateFocusMode(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAudioPlayerPanel(QuranAudioState state, Surah? loadedSurah) {
    final isPlaying = state.isPlaying;
    final isLoading = state.isLoading;
    final playingSurah = state.playingSurah;
    final surahLabel = loadedSurah != null && loadedSurah.number == playingSurah
        ? loadedSurah.name
        : '$playingSurah';
    final verseLabel = _l.isEnglish
        ? 'Verse ${state.playingVerse}'
        : 'Ayat ${state.playingVerse}';
    final String status;
    if (isLoading) {
      status = _l.isEnglish ? 'Loading audio' : 'Memuat audio';
    } else if (isPlaying) {
      status = _l.isEnglish ? 'Playing' : 'Memutar';
    } else {
      status = _l.isEnglish ? 'Paused' : 'Dijeda';
    }

    final progressPercent = state.totalDuration.inMilliseconds > 0
        ? (state.progress.inMilliseconds / state.totalDuration.inMilliseconds)
              .clamp(0.0, 1.0)
        : 0.0;

    return GlassContainer(
      fillColor: SolatifyColors.softSurface(context),
      borderColor: SolatifyColors.borderStrong(context),
      borderRadius: SolatifyRadius.md,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: SolatifyIconSize.cardBox,
                  height: SolatifyIconSize.cardBox,
                  decoration: BoxDecoration(
                    color: SolatifyColors.accentSoft(context),
                    borderRadius: SolatifyRadius.icon,
                  ),
                  child: Icon(
                    isPlaying ? Icons.graphic_eq_rounded : Icons.music_note,
                    color: _redAccent,
                    size: SolatifyIconSize.cardIcon,
                  ),
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surah $surahLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$status · $verseLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: SolatifyType.eyebrow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: SolatifyTapTarget.min + 4,
                  height: SolatifyTapTarget.min + 4,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _redAccent,
                        semanticsLabel: status,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  tooltip: isPlaying
                      ? (_l.isEnglish ? 'Pause' : 'Jeda')
                      : (_l.isEnglish ? 'Resume' : 'Lanjutkan'),
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _redAccent,
                    size: 24,
                  ),
                  onPressed: () {
                    SolatifyHaptics.selection();
                    if (isPlaying) {
                      ref.read(quranAudioProvider.notifier).pause();
                    } else {
                      ref.read(quranAudioProvider.notifier).resume();
                    }
                  },
                ),
              IconButton(
                tooltip: _l.isEnglish ? 'Stop' : 'Hentikan',
                icon: Icon(Icons.stop, color: _textColor, size: 24),
                onPressed: () {
                  SolatifyHaptics.light();
                  ref.read(quranAudioProvider.notifier).stop();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: isLoading ? null : progressPercent,
                minHeight: 3,
                backgroundColor: SolatifyColors.raisedSurface(context),
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
