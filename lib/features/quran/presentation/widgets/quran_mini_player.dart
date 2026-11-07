import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';

/// Compact player shown above the bottom navigation while Quran recitation is
/// loaded, so it can be controlled from any tab after leaving the surah.
/// Tapping it reopens the surah at the verse being recited.
///
/// The surah screen lives outside the navigation shell and has its own
/// controls, so this player is not shown there.
class QuranMiniPlayer extends ConsumerWidget {
  const QuranMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(
      quranAudioProvider.select(
        (s) => (
          surah: s.playingSurah,
          name: s.playingSurahName,
          verse: s.playingVerse,
          isPlaying: s.isPlaying,
          isLoading: s.isLoading,
        ),
      ),
    );

    final surah = info.surah;
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: surah == null
          ? const SizedBox(width: double.infinity)
          : _MiniPlayerCard(
              surah: surah,
              name: info.name ?? 'Surah $surah',
              verse: info.verse,
              isPlaying: info.isPlaying,
              isLoading: info.isLoading,
            ),
    );
  }
}

class _MiniPlayerCard extends ConsumerWidget {
  const _MiniPlayerCard({
    required this.surah,
    required this.name,
    required this.verse,
    required this.isPlaying,
    required this.isLoading,
  });

  final int surah;
  final String name;
  final int? verse;
  final bool isPlaying;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(quranAudioProvider.notifier);
    final accent = Theme.of(context).colorScheme.tertiary;
    final verseLabel = verse == null
        ? (l.isEnglish ? 'Recitation' : 'Murotal')
        : (l.isEnglish ? 'Verse $verse' : 'Ayat $verse');
    final status = isLoading
        ? (l.isEnglish ? 'Loading' : 'Memuat')
        : isPlaying
        ? (l.isEnglish ? 'Playing' : 'Diputar')
        : (l.isEnglish ? 'Paused' : 'Dijeda');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SolatifySpacing.md,
        SolatifySpacing.xs,
        SolatifySpacing.md,
        SolatifySpacing.xs,
      ),
      child: GlassContainer(
        borderRadius: SolatifyRadius.md,
        fillColor: SolatifyColors.raisedSurface(context),
        borderColor: SolatifyColors.border(context),
        padding: EdgeInsets.zero,
        semanticLabel: l.isEnglish
            ? 'Now playing $name, $verseLabel, $status. Opens the surah.'
            : 'Sedang diputar $name, $verseLabel, $status. Membuka surah.',
        onTap: () {
          SolatifyHaptics.selection();
          context.push(AppRoutes.quranSurah(surah, scrollTo: verse));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _VerseProgressBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SolatifySpacing.md,
                SolatifySpacing.xs,
                SolatifySpacing.xs,
                SolatifySpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: SolatifyColors.accentSoft(context),
                      borderRadius: SolatifyRadius.icon,
                    ),
                    child: Icon(Icons.menu_book_rounded, color: accent),
                  ),
                  const SizedBox(width: SolatifySpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'QS. $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SolatifyType.cardTitle,
                            fontWeight: FontWeight.w700,
                            color: SolatifyColors.text(context),
                          ),
                        ),
                        Text(
                          '$verseLabel · $status',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SolatifyType.caption,
                            color: SolatifyColors.muted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: accent,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: isPlaying
                          ? (l.isEnglish ? 'Pause' : 'Jeda')
                          : (l.isEnglish ? 'Play' : 'Putar'),
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: accent,
                        size: 34,
                      ),
                      onPressed: () {
                        SolatifyHaptics.selection();
                        isPlaying ? notifier.pause() : notifier.resume();
                      },
                    ),
                  IconButton(
                    tooltip: l.isEnglish
                        ? 'Stop recitation'
                        : 'Hentikan murotal',
                    icon: Icon(
                      Icons.close_rounded,
                      color: SolatifyColors.muted(context),
                    ),
                    onPressed: () {
                      SolatifyHaptics.selection();
                      notifier.stop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress through the current verse. Kept in its own widget so the
/// ~5 position updates per second only rebuild this thin bar.
class _VerseProgressBar extends ConsumerWidget {
  const _VerseProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fraction = ref.watch(
      quranAudioProvider.select((s) {
        final total = s.totalDuration.inMilliseconds;
        if (total <= 0) return 0.0;
        return (s.progress.inMilliseconds / total).clamp(0.0, 1.0);
      }),
    );
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(SolatifyRadius.md),
      ),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 3,
        backgroundColor: SolatifyColors.accentSoft(context),
        color: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}
