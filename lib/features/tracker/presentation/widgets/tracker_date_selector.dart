import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

/// Lets the user pick one of the last 7 days to log or correct prayers.
class TrackerDateSelector extends StatelessWidget {
  const TrackerDateSelector({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final today = trackerDateOnly(DateTime.now());
    final isToday = trackerIsSameDay(selectedDate, today);
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: index)),
    );
    final selectedLabel =
        '${trackerWeekdayLong(selectedDate, isEnglish: isEnglish)}, '
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return GlassContainer(
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackerCardHeader(
            icon: Icons.event_note_outlined,
            title: isEnglish ? 'Tracker History' : 'Riwayat Tracker',
            subtitle: isEnglish
                ? 'Pick a date to log or correct past prayers.'
                : 'Pilih tanggal untuk koreksi salat dan status yang sudah lewat.',
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SolatifySpacing.xs,
            runSpacing: 2,
            children: [
              _SelectedDateBadge(label: selectedLabel, isToday: isToday),
              if (!isToday)
                Tooltip(
                  message: isEnglish
                      ? 'Jump back to today'
                      : 'Kembali ke tanggal hari ini',
                  child: TextButton.icon(
                    onPressed: () => onSelectDate(today),
                    icon: const Icon(
                      Icons.today_outlined,
                      size: SolatifyIconSize.inline,
                    ),
                    label: Text(isEnglish ? 'Back to today' : 'Ke hari ini'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: days.map((date) {
                final isSelected = trackerIsSameDay(selectedDate, date);
                final isDateToday = trackerIsSameDay(date, today);
                final relative = trackerHistoryLabel(
                  date,
                  today,
                  isEnglish: isEnglish,
                );
                final label = relative.contains('/')
                    ? '${trackerWeekdayShort(date, isEnglish: isEnglish)} '
                          '$relative'
                    : relative;
                return Padding(
                  padding: const EdgeInsets.only(right: SolatifySpacing.xs + 2),
                  child: _DayChip(
                    label: label,
                    isSelected: isSelected,
                    isToday: isDateToday,
                    semanticsLabel:
                        '${trackerWeekdayLong(date, isEnglish: isEnglish)} '
                        '${date.day}/${date.month}',
                    onSelected: () => onSelectDate(date),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDateBadge extends StatelessWidget {
  const _SelectedDateBadge({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final color = isToday
        ? SolatifyColors.success(context)
        : SolatifyColors.warning(context);

    return Semantics(
      liveRegion: true,
      label: isEnglish
          ? 'Showing $label${isToday ? ', today' : ', past date'}'
          : 'Menampilkan $label${isToday ? ', hari ini' : ', tanggal lampau'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SolatifySpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isToday ? Icons.today_rounded : Icons.history_rounded,
              size: SolatifyIconSize.inline,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: SolatifyColors.text(context),
                  fontSize: SolatifyType.caption + 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.isToday,
    required this.semanticsLabel,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final bool isToday;
  final String semanticsLabel;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final accent = SolatifyColors.accent(context);
    final textColor = SolatifyColors.text(context);

    return Semantics(
      label: semanticsLabel,
      child: ChoiceChip(
        selected: isSelected,
        showCheckmark: isSelected,
        avatar: isToday && !isSelected
            ? Icon(
                Icons.today_rounded,
                size: SolatifyIconSize.inline,
                color: SolatifyColors.success(context),
              )
            : null,
        label: Text(label),
        onSelected: (_) => onSelected(),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        selectedColor: SolatifyColors.accentSoft(context),
        checkmarkColor: accent,
        labelStyle: TextStyle(
          color: isSelected ? accent : textColor,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
          color: isSelected
              ? SolatifyColors.borderStrong(context)
              : isToday
              ? SolatifyColors.success(context).withValues(alpha: 0.6)
              : SolatifyColors.border(context),
          width: isSelected || isToday ? 1.5 : 1,
        ),
      ),
    );
  }
}
