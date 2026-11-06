import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/home/presentation/providers/improved_countdown_provider.dart';

class PrayerTimeDisplayWidget extends ConsumerWidget {
  const PrayerTimeDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(improvedCountdownProvider);
    final l = AppLocalizations.of(context);

    return AnimatedSwitcher(
      duration: SolatifyMotion.of(context, SolatifyMotion.medium),
      child: !countdown.isAccurate
          ? SolatifyStateView.loading(
              key: const ValueKey('prayer-display-loading'),
              compact: true,
              title: l.preparingPrayerSchedule,
              description: l.countdownWaiting,
            )
          : Column(
              key: const ValueKey('prayer-display-ready'),
              children: [
                _buildCountdownCard(context, countdown, l),
                const SizedBox(height: SolatifySpacing.sm),
                Text(
                  l.activePrayerInProgress(
                    l.prayerName(countdown.activePrayerName),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SolatifyColors.muted(context),
                    fontSize: SolatifyType.caption,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    CountdownState countdown,
    AppLocalizations l,
  ) {
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);
    final prayerName = l.prayerName(countdown.nextPrayerName);
    final nextTime = DateFormat('HH:mm').format(countdown.nextPrayerTime);

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      borderColor: SolatifyColors.borderStrong(context),
      padding: const EdgeInsets.all(SolatifySpacing.xl - 2),
      child: Column(
        children: [
          Text(
            l.prayerTimeLabel(prayerName),
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: SolatifyType.body),
          ),
          const SizedBox(height: SolatifySpacing.xs),
          Semantics(
            label: l.isEnglish
                ? 'Time remaining until $prayerName: ${countdown.formattedTime}'
                : 'Sisa waktu menuju $prayerName: ${countdown.formattedTime}',
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                countdown.formattedTime,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: SolatifySpacing.xs),
          Text(
            nextTime,
            style: TextStyle(color: muted, fontSize: SolatifyType.caption),
          ),
        ],
      ),
    );
  }
}
