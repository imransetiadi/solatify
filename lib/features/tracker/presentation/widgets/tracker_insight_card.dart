import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/entities/weekly_stats_entity.dart';
import 'package:solatify/features/tracker/domain/services/tracker_share_service.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

/// Weekly summary: one hero metric (streak), supporting stats, a per-prayer
/// completion chart, status legend and the share action.
class TrackerInsightCard extends StatelessWidget {
  const TrackerInsightCard({super.key, required this.weeklyStatsAsync});

  final AsyncValue<WeeklyStatsEntity> weeklyStatsAsync;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);

    return GlassContainer(
      padding: ResponsiveLayout.cardPadding,
      child: weeklyStatsAsync.when(
        data: (stats) => _InsightContent(stats: stats),
        loading: () => _InsightContent(
          stats: WeeklyStatsEntity(
            completionRates: const {},
            totalDone: 0,
            bestDayLabel: isEnglish ? 'Loading' : 'Memuat',
            strongestItemLabel: isEnglish ? 'Loading' : 'Memuat',
            weakestItemLabel: isEnglish ? 'Loading' : 'Memuat',
            smartInsightMessage: isEnglish
                ? 'Calculating this week\'s worship summary.'
                : 'Menghitung ringkasan ibadah minggu ini.',
            smartInsightAction: isEnglish
                ? 'One moment, your insight is being prepared.'
                : 'Sebentar ya, insight sedang disiapkan.',
          ),
          isLoading: true,
        ),
        error: (_, _) => _InsightContent(
          stats: WeeklyStatsEntity(
            completionRates: const {},
            totalDone: 0,
            bestDayLabel: isEnglish ? 'Unavailable' : 'Belum tersedia',
            strongestItemLabel: isEnglish ? 'Unavailable' : 'Belum tersedia',
            weakestItemLabel: isEnglish ? 'Try again' : 'Coba lagi',
            smartInsightMessage: isEnglish
                ? 'Insights could not be loaded, but today\'s checklist still works.'
                : 'Insight belum bisa dimuat, tapi checklist hari ini tetap bisa digunakan.',
            smartInsightAction: isEnglish
                ? 'Try reopening the tracker in a moment.'
                : 'Coba buka ulang halaman tracker setelah beberapa saat.',
          ),
          isError: true,
        ),
      ),
    );
  }
}

class _InsightContent extends StatelessWidget {
  const _InsightContent({
    required this.stats,
    this.isLoading = false,
    this.isError = false,
  });

  final WeeklyStatsEntity stats;
  final bool isLoading;
  final bool isError;

  bool get _hasData => !isLoading && !isError;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);
    final average = (stats.totalDone / 7).toStringAsFixed(1);
    final lastSevenDays = stats.heatmap.take(7).toList();
    final activeDays = lastSevenDays.where((day) => day.progress > 0).length;
    final isEmpty = _hasData && stats.totalDone == 0 && activeDays == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrackerCardHeader(
          icon: Icons.insights_outlined,
          title: isEnglish ? '7-Day Insight' : 'Insight 7 Hari',
        ),
        const SizedBox(height: SolatifySpacing.md),
        _StreakHero(
          streakDays: stats.currentStreakDays,
          activeDays: activeDays,
          totalDays: lastSevenDays.isEmpty ? 7 : lastSevenDays.length,
          isPlaceholder: !_hasData,
        ),
        const SizedBox(height: SolatifySpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = SolatifySpacing.xs + 2;
            final pillWidth = constraints.maxWidth >= 480
                ? (constraints.maxWidth - spacing * 2) / 3
                : (constraints.maxWidth - spacing) / 2;
            Widget pill(String label, String value, IconData icon) => SizedBox(
              width: pillWidth,
              child: _InsightPill(label: label, value: value, icon: icon),
            );
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                pill(
                  'Total',
                  isEnglish
                      ? '${stats.totalDone} prayers'
                      : '${stats.totalDone} salat',
                  Icons.done_all_rounded,
                ),
                pill(
                  isEnglish ? 'Average' : 'Rata-rata',
                  isEnglish ? '$average/day' : '$average/hari',
                  Icons.show_chart_rounded,
                ),
                pill(
                  isEnglish ? 'Best day' : 'Hari terbaik',
                  stats.bestDayLabel,
                  Icons.emoji_events_outlined,
                ),
                pill(
                  isEnglish ? 'Strongest' : 'Terkuat',
                  stats.strongestItemLabel,
                  Icons.trending_up_rounded,
                ),
                pill(
                  isEnglish ? 'Needs focus' : 'Perlu fokus',
                  stats.weakestItemLabel,
                  Icons.center_focus_strong_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: SolatifySpacing.md),
        if (isEmpty)
          _EmptyInsightHint(isEnglish: isEnglish)
        else if (_hasData && stats.completionRates.isNotEmpty) ...[
          _PrayerRateChart(rates: stats.completionRates),
          const SizedBox(height: SolatifySpacing.md),
          _StatusLegend(statusCounts: stats.statusCounts),
        ],
        const SizedBox(height: SolatifySpacing.md),
        Text(
          stats.smartInsightMessage,
          style: TextStyle(
            color: textColor,
            fontSize: SolatifyType.caption + 1,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: SolatifySpacing.xs),
        Text(
          stats.smartInsightAction,
          style: TextStyle(
            color: mutedColor,
            fontSize: SolatifyType.caption + 1,
            height: 1.4,
          ),
        ),
        const SizedBox(height: SolatifySpacing.md),
        _ShareProgressButton(summary: _hasData ? stats.shareSummaryText : ''),
      ],
    );
  }
}

class _StreakHero extends StatelessWidget {
  const _StreakHero({
    required this.streakDays,
    required this.activeDays,
    required this.totalDays,
    required this.isPlaceholder,
  });

  final int streakDays;
  final int activeDays;
  final int totalDays;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final accent = SolatifyColors.accent(context);
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);
    final activeText = isEnglish
        ? '$activeDays of $totalDays days active'
        : '$activeDays dari $totalDays hari aktif';

    return Semantics(
      container: true,
      label: isPlaceholder
          ? null
          : isEnglish
          ? 'Streak $streakDays days. $activeText this week.'
          : 'Streak $streakDays hari. $activeText minggu ini.',
      excludeSemantics: !isPlaceholder,
      child: Container(
        width: double.infinity,
        padding: SolatifySpacing.compactCard,
        decoration: BoxDecoration(
          color: SolatifyColors.accentSoft(context),
          borderRadius: SolatifyRadius.compactCard,
          border: Border.all(color: SolatifyColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: accent, size: 32),
            const SizedBox(width: SolatifySpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    isEnglish ? '$streakDays days' : '$streakDays hari',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _WeekDots(activeDays: activeDays, totalDays: totalDays),
                  const SizedBox(height: 4),
                  Text(
                    activeText,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w600,
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

/// Simple "x of 7" dot row; filled dots use an icon, not just color.
class _WeekDots extends StatelessWidget {
  const _WeekDots({required this.activeDays, required this.totalDays});

  final int activeDays;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final success = SolatifyColors.success(context);
    final muted = SolatifyColors.muted(context).withValues(alpha: 0.6);
    return ExcludeSemantics(
      child: Wrap(
        spacing: 2,
        children: List.generate(totalDays, (index) {
          final isActive = index < activeDays;
          return Icon(
            isActive
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: isActive ? success : muted,
          );
        }),
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final mutedColor = SolatifyColors.muted(context);

    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(SolatifySpacing.sm + 2),
        decoration: BoxDecoration(
          color: SolatifyColors.raisedSurface(context),
          borderRadius: BorderRadius.circular(SolatifyRadius.sm),
          border: Border.all(color: SolatifyColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: mutedColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: SolatifyColors.text(context),
                fontSize: SolatifyType.body,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerRateChart extends StatelessWidget {
  const _PrayerRateChart({required this.rates});

  /// Prayer key -> completion percentage (0..100).
  final Map<String, double> rates;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final success = SolatifyColors.success(context);
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);
    final entries = trackerPrayerLabels.entries
        .where((entry) => rates.containsKey(entry.key))
        .toList();
    final summary = entries
        .map((entry) => '${entry.value} ${(rates[entry.key] ?? 0).round()}%')
        .join(', ');

    return Semantics(
      container: true,
      label: isEnglish
          ? 'Completion per prayer this week: $summary'
          : 'Kelengkapan per salat minggu ini: $summary',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEnglish ? 'Completion per prayer' : 'Kelengkapan per salat',
            style: TextStyle(
              color: textColor,
              fontSize: SolatifyType.caption + 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: SolatifySpacing.xs + 2),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: SolatifySpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: SolatifyType.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        end: ((rates[entry.key] ?? 0) / 100).clamp(0, 1),
                      ),
                      duration: SolatifyMotion.of(context, SolatifyMotion.slow),
                      curve: SolatifyMotion.curve,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        color: success,
                        backgroundColor: SolatifyColors.raisedSurface(context),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: SolatifySpacing.xs + 2),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${(rates[entry.key] ?? 0).round()}%',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      style: TextStyle(
                        color: textColor,
                        fontSize: SolatifyType.caption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend({required this.statusCounts});

  final Map<PrayerStatus, int> statusCounts;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final mutedColor = SolatifyColors.muted(context);

    return Wrap(
      spacing: SolatifySpacing.xs + 2,
      runSpacing: SolatifySpacing.xs + 2,
      children: PrayerStatus.values.map((status) {
        final title = trackerStatusTitle(status, isEnglish: isEnglish);
        final count = statusCounts[status] ?? 0;
        return Semantics(
          label: '$title: $count',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SolatifySpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: SolatifyColors.raisedSurface(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: SolatifyColors.border(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  trackerStatusIcon(status),
                  size: 14,
                  color: trackerStatusColor(context, status),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '$title: $count',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyInsightHint extends StatelessWidget {
  const _EmptyInsightHint({required this.isEnglish});

  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final mutedColor = SolatifyColors.muted(context);
    return Container(
      width: double.infinity,
      padding: SolatifySpacing.compactCard,
      decoration: BoxDecoration(
        color: SolatifyColors.raisedSurface(context),
        borderRadius: SolatifyRadius.compactCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bar_chart_rounded, color: mutedColor),
          const SizedBox(width: SolatifySpacing.sm),
          Expanded(
            child: Text(
              isEnglish
                  ? 'No data this week yet. Per-prayer charts appear after your first check-in.'
                  : 'Belum ada data minggu ini. Grafik per salat muncul setelah tanda pertamamu.',
              style: TextStyle(
                color: mutedColor,
                fontSize: SolatifyType.caption + 1,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareProgressButton extends StatefulWidget {
  const _ShareProgressButton({required this.summary});

  final String summary;

  @override
  State<_ShareProgressButton> createState() => _ShareProgressButtonState();
}

class _ShareProgressButtonState extends State<_ShareProgressButton> {
  bool _isSharing = false;

  Future<void> _share() async {
    final isEnglish = trackerIsEnglish(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final messenger = ScaffoldMessenger.of(context);
    final service = TrackerShareService(
      shareText: (text) {
        return SharePlus.instance.share(
          ShareParams(
            text: text,
            title: 'Progress Ibadah Mingguan Solatify',
            sharePositionOrigin: origin,
          ),
        );
      },
      copyText: (text) => Clipboard.setData(ClipboardData(text: text)),
    );

    setState(() => _isSharing = true);
    SolatifyHaptics.selection();
    String message;
    try {
      final result = await service.shareProgress(widget.summary);
      message = result == TrackerShareResult.shared
          ? (isEnglish
                ? 'Progress share sheet opened.'
                : 'Share sheet progress dibuka.')
          : (isEnglish
                ? 'Sharing failed, progress summary copied.'
                : 'Share gagal, ringkasan progress disalin.');
    } catch (error) {
      debugPrint('Tracker share failed: $error');
      message = isEnglish
          ? 'Progress could not be shared. Please try again.'
          : 'Progress belum dapat dibagikan. Coba lagi.';
    }
    if (!mounted) return;
    setState(() => _isSharing = false);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final isDisabled = widget.summary.isEmpty || _isSharing;

    return Tooltip(
      message: widget.summary.isEmpty
          ? (isEnglish
                ? 'Available once the weekly summary is ready'
                : 'Tersedia setelah ringkasan mingguan siap')
          : (isEnglish
                ? 'Share this week\'s summary as text'
                : 'Bagikan ringkasan minggu ini sebagai teks'),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: isDisabled ? null : _share,
          icon: _isSharing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share_outlined, size: 18),
          label: Text(isEnglish ? 'Share Progress' : 'Bagikan Progress'),
        ),
      ),
    );
  }
}
