import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

/// Hero metric for the selected day: how many of the five prayers are logged.
class TrackerProgressCard extends StatelessWidget {
  const TrackerProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.isToday,
  });

  final int completedCount;
  final int totalCount;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final percentage = (progress * 100).round();
    final isComplete = totalCount > 0 && completedCount == totalCount;
    final success = SolatifyColors.success(context);
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);

    final message = isComplete
        ? (isEnglish
              ? 'MasyaAllah, may Allah keep you steadfast.'
              : 'MasyaAllah, semoga Allah mudahkan untuk terus istiqamah.')
        : (isEnglish
              ? 'Start with one check today. May Allah ease your steps.'
              : 'Mulai dari satu tanda hari ini. Semoga Allah mudahkan langkahmu.');

    return Semantics(
      container: true,
      liveRegion: true,
      label: isEnglish
          ? '${isToday ? 'Today' : 'Selected day'}: $completedCount of '
                '$totalCount prayers logged, $percentage percent'
          : '${isToday ? 'Hari ini' : 'Tanggal terpilih'}: $completedCount '
                'dari $totalCount salat tertandai, $percentage persen',
      excludeSemantics: true,
      child: GlassContainer(
        padding: ResponsiveLayout.cardPadding,
        borderColor: isComplete ? success.withValues(alpha: 0.5) : null,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 84,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: SolatifyMotion.of(context, SolatifyMotion.slow),
                curve: SolatifyMotion.curve,
                builder: (context, value, _) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: SolatifyColors.raisedSurface(context),
                        valueColor: AlwaysStoppedAnimation<Color>(success),
                      ),
                      Center(
                        child: isComplete
                            ? Icon(
                                Icons.check_rounded,
                                size: 34,
                                color: success,
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    '$percentage%',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: SolatifySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? 'Today\'s Progress' : 'Progress Hari Ini',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: SolatifyType.caption + 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnglish
                        ? '$completedCount/$totalCount prayers logged'
                        : '$completedCount/$totalCount salat tertandai',
                    style: TextStyle(
                      color: textColor,
                      fontSize: SolatifyType.heroTitle,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: SolatifySpacing.xs),
                  Text(
                    message,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: SolatifyType.caption + 1,
                      height: 1.4,
                    ),
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
