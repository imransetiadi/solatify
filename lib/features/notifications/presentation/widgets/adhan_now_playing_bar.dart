import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/notifications/presentation/providers/adhan_playback_provider.dart';

/// Shown above the bottom navigation while the full adhan plays (iOS), so
/// the user can stop it. Collapses to nothing otherwise.
class AdhanNowPlayingBar extends ConsumerWidget {
  const AdhanNowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(adhanPlaybackProvider);
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: playback.isPlaying
          ? _AdhanCard(prayerKey: playback.prayerKey)
          : const SizedBox(width: double.infinity),
    );
  }
}

class _AdhanCard extends ConsumerWidget {
  const _AdhanCard({required this.prayerKey});

  final String? prayerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.tertiary;
    final key = prayerKey;
    final title = l.adhanPlayingTitle(key == null ? '' : l.prayerName(key));

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
              child: Icon(Icons.mosque_rounded, color: accent),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: SolatifyType.cardTitle,
                      fontWeight: FontWeight.w700,
                      color: SolatifyColors.text(context),
                    ),
                  ),
                  Text(
                    l.adhanPlayingStatus,
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
            IconButton(
              tooltip: l.stopAdhan,
              icon: Icon(Icons.stop_circle_rounded, color: accent, size: 34),
              onPressed: () {
                SolatifyHaptics.selection();
                ref.read(adhanPlaybackProvider.notifier).stop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
