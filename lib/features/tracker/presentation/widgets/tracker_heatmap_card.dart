import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/domain/entities/weekly_stats_entity.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

/// 14-day consistency calendar. Each cell shows the day number and the
/// percentage as text, so the intensity color is never the only signal.
class TrackerHeatmapCard extends StatelessWidget {
  const TrackerHeatmapCard({
    super.key,
    required this.weeklyStatsAsync,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final AsyncValue<WeeklyStatsEntity> weeklyStatsAsync;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final mutedColor = SolatifyColors.muted(context);
    final captionStyle = TextStyle(
      color: mutedColor,
      fontSize: SolatifyType.caption + 1,
    );

    return GlassContainer(
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackerCardHeader(
            icon: Icons.calendar_month_outlined,
            title: isEnglish ? 'Consistency Calendar' : 'Kalender Konsistensi',
            subtitle: isEnglish ? 'Last 14 days' : '14 hari terakhir',
          ),
          const SizedBox(height: SolatifySpacing.md),
          weeklyStatsAsync.when(
            data: (stats) => _HeatmapBody(
              days: stats.heatmap,
              selectedDate: selectedDate,
              onSelectDate: onSelectDate,
            ),
            loading: () => Text(
              isEnglish
                  ? 'Calculating consistency...'
                  : 'Menghitung konsistensi...',
              style: captionStyle,
            ),
            error: (_, _) => Text(
              isEnglish
                  ? 'The consistency calendar could not be loaded.'
                  : 'Kalender konsistensi belum dapat dimuat.',
              style: captionStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapBody extends StatelessWidget {
  const _HeatmapBody({
    required this.days,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final List<TrackerHeatmapDayEntity> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final mutedColor = SolatifyColors.muted(context);
    final activeDays = days.where((day) => day.progress > 0).length;
    final summary = isEnglish
        ? '$activeDays of ${days.length} days have entries'
        : '$activeDays dari ${days.length} hari ada catatan';
    final today = trackerDateOnly(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary,
          style: TextStyle(
            color: SolatifyColors.text(context),
            fontSize: SolatifyType.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (activeDays == 0) ...[
          const SizedBox(height: 4),
          Text(
            isEnglish
                ? 'No entries yet. The calendar fills in as you check off worship.'
                : 'Belum ada catatan. Kalender akan terisi saat kamu menandai ibadah.',
            style: TextStyle(
              color: mutedColor,
              fontSize: SolatifyType.caption,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: SolatifySpacing.sm),
        Wrap(
          spacing: SolatifySpacing.xs + 2,
          runSpacing: SolatifySpacing.xs + 2,
          children: days.map((day) {
            return _HeatmapCell(
              day: day,
              isSelected: trackerIsSameDay(day.date, selectedDate),
              isToday: trackerIsSameDay(day.date, today),
              onTap: () => _showDayDetail(context, day),
            );
          }).toList(),
        ),
        const SizedBox(height: SolatifySpacing.sm),
        const _HeatmapLegend(),
      ],
    );
  }

  void _showDayDetail(BuildContext context, TrackerHeatmapDayEntity day) {
    SolatifyHaptics.selection();
    final isSelected = trackerIsSameDay(day.date, selectedDate);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final isEnglish = trackerIsEnglish(context);
        final progressPercent = (day.progress * 100).round();
        final dateLabel = trackerHistoryLabel(
          day.date,
          trackerDateOnly(DateTime.now()),
          isEnglish: isEnglish,
        );

        return TrackerSheetFrame(
          title: isEnglish ? 'Day Details' : 'Detail Hari',
          showCloseButton: true,
          children: [
            Text(
              '$dateLabel · '
              '${trackerWeekdayLong(day.date, isEnglish: isEnglish)}',
              style: TextStyle(
                color: SolatifyColors.text(context),
                fontSize: SolatifyType.sectionTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: SolatifySpacing.xs),
            Text(
              isEnglish
                  ? '$progressPercent% of the daily target recorded.'
                  : '$progressPercent% target harian tercatat di kalender konsistensi.',
              style: TextStyle(
                color: SolatifyColors.muted(context),
                fontSize: SolatifyType.caption + 1,
              ),
            ),
            const SizedBox(height: SolatifySpacing.md),
            Semantics(
              label: isEnglish
                  ? '$progressPercent percent complete'
                  : '$progressPercent persen tercatat',
              excludeSemantics: true,
              child: LinearProgressIndicator(
                value: day.progress.clamp(0, 1).toDouble(),
                color: SolatifyColors.success(context),
                backgroundColor: SolatifyColors.raisedSurface(context),
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: SolatifySpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSelected
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        onSelectDate(day.date);
                      },
                icon: Icon(
                  isSelected
                      ? Icons.check_rounded
                      : Icons.event_available_outlined,
                ),
                label: Text(
                  isEnglish ? 'Select this date' : 'Pilih tanggal ini',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Fill opacity for a given completion ratio (0..1).
double _heatAlpha(double progress) =>
    0.06 + (progress.clamp(0, 1).toDouble() * 0.36);

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final TrackerHeatmapDayEntity day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final success = SolatifyColors.success(context);
    final accent = SolatifyColors.accent(context);
    final textColor = SolatifyColors.text(context);
    final percent = (day.progress * 100).round();
    final radius = BorderRadius.circular(SolatifyRadius.sm);
    final semanticsLabel = [
      '${trackerWeekdayLong(day.date, isEnglish: isEnglish)} '
          '${day.date.day}/${day.date.month}',
      if (isToday) isEnglish ? 'today' : 'hari ini',
      isEnglish ? '$percent percent recorded' : '$percent persen tercatat',
    ].join(', ');

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel,
      hint: isEnglish ? 'Open day details' : 'Buka detail hari',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: SolatifyMotion.of(context, SolatifyMotion.fast),
            curve: SolatifyMotion.curve,
            constraints: const BoxConstraints(
              minWidth: SolatifyTapTarget.min,
              minHeight: SolatifyTapTarget.min + 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
            decoration: BoxDecoration(
              color: success.withValues(alpha: _heatAlpha(day.progress)),
              borderRadius: radius,
              border: Border.all(
                color: isSelected
                    ? accent
                    : isToday
                    ? success
                    : SolatifyColors.border(context),
                width: isSelected || isToday ? 1.8 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${day.date.day}',
                  style: TextStyle(
                    color: isSelected ? accent : textColor,
                    fontSize: SolatifyType.caption + 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$percent%',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.78),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 14,
                    height: 3,
                    decoration: BoxDecoration(
                      color: success,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final mutedColor = SolatifyColors.muted(context);
    final success = SolatifyColors.success(context);
    final labelStyle = TextStyle(
      color: mutedColor,
      fontSize: SolatifyType.caption,
      fontWeight: FontWeight.w600,
    );

    Widget swatch(double progress) => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: success.withValues(alpha: _heatAlpha(progress)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: SolatifyColors.border(context)),
      ),
    );

    return Semantics(
      label: isEnglish
          ? 'Legend: lighter means fewer entries, darker means more. '
                'Underlined cell is today.'
          : 'Keterangan: warna muda berarti sedikit catatan, warna pekat '
                'berarti banyak. Sel bergaris bawah adalah hari ini.',
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: SolatifySpacing.xs,
        runSpacing: 4,
        children: [
          Text(isEnglish ? 'Less' : 'Sedikit', style: labelStyle),
          swatch(0),
          swatch(0.35),
          swatch(0.7),
          swatch(1),
          Text(isEnglish ? 'More' : 'Banyak', style: labelStyle),
          const SizedBox(width: SolatifySpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(
                  color: success,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(isEnglish ? 'Today' : 'Hari ini', style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}
