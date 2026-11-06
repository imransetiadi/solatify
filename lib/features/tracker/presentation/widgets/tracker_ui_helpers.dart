import 'package:flutter/material.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';

/// Prayer keys (stored in Hive) mapped to their display labels.
const trackerPrayerLabels = {
  'subuh': 'Subuh',
  'dzuhur': 'Dzuhur',
  'ashar': 'Ashar',
  'magrib': 'Magrib',
  'isya': 'Isya',
};

bool trackerIsEnglish(BuildContext context) =>
    AppLocalizations.of(context).isEnglish;

/// Picks the Indonesian or English copy for the current locale.
String trackerText(BuildContext context, String id, String en) =>
    trackerIsEnglish(context) ? en : id;

DateTime trackerDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool trackerIsSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String trackerHistoryLabel(
  DateTime date,
  DateTime today, {
  bool isEnglish = false,
}) {
  if (trackerIsSameDay(date, today)) return isEnglish ? 'Today' : 'Hari ini';
  if (trackerIsSameDay(date, today.subtract(const Duration(days: 1)))) {
    return isEnglish ? 'Yesterday' : 'Kemarin';
  }
  return '${date.day}/${date.month}';
}

String trackerWeekdayShort(DateTime date, {bool isEnglish = false}) {
  const id = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return (isEnglish ? en : id)[date.weekday - 1];
}

String trackerWeekdayLong(DateTime date, {bool isEnglish = false}) {
  const id = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Ahad'];
  const en = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return (isEnglish ? en : id)[date.weekday - 1];
}

String trackerStatusTitle(PrayerStatus status, {bool isEnglish = false}) {
  return switch (status) {
    PrayerStatus.onTime => isEnglish ? 'On time' : 'Tepat Waktu',
    PrayerStatus.late => isEnglish ? 'Late' : 'Terlambat',
    PrayerStatus.qadha => 'Qadha',
  };
}

String trackerStatusDescription(PrayerStatus status, {bool isEnglish = false}) {
  return switch (status) {
    PrayerStatus.onTime =>
      isEnglish
          ? 'Performed early or within the prayer window.'
          : 'Ditunaikan di awal atau dalam rentang waktu salat.',
    PrayerStatus.late =>
      isEnglish
          ? 'Performed within its time, but not at the start.'
          : 'Ditunaikan masih dalam waktunya, tetapi tidak di awal.',
    PrayerStatus.qadha =>
      isEnglish
          ? 'Made up after its time had passed.'
          : 'Ditunaikan sebagai pengganti setelah waktunya lewat.',
  };
}

IconData trackerStatusIcon(PrayerStatus status) {
  return switch (status) {
    PrayerStatus.onTime => Icons.check_circle_rounded,
    PrayerStatus.late => Icons.schedule_rounded,
    PrayerStatus.qadha => Icons.history_rounded,
  };
}

Color trackerStatusColor(BuildContext context, PrayerStatus status) {
  return switch (status) {
    PrayerStatus.onTime => SolatifyColors.success(context),
    PrayerStatus.late => SolatifyColors.warning(context),
    PrayerStatus.qadha => SolatifyColors.muted(context),
  };
}

/// Title + optional subtitle used at the top of every tracker card.
class TrackerCardHeader extends StatelessWidget {
  const TrackerCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: SolatifyIconSize.cardBox,
            height: SolatifyIconSize.cardBox,
            decoration: BoxDecoration(
              color: SolatifyColors.accentSoft(context),
              borderRadius: SolatifyRadius.icon,
            ),
            child: ExcludeSemantics(
              child: Icon(
                icon,
                size: SolatifyIconSize.cardIcon,
                color: SolatifyColors.accent(context),
              ),
            ),
          ),
          const SizedBox(width: SolatifySpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: SolatifyType.sectionTitle + 1,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: SolatifyType.caption + 1,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: SolatifySpacing.xs),
          trailing!,
        ],
      ],
    );
  }
}

/// Shared layout for tracker bottom sheets: safe area, keyboard inset,
/// scrollable body (so large text scales never overflow) and a title row.
class TrackerSheetFrame extends StatelessWidget {
  const TrackerSheetFrame({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.showCloseButton = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SolatifySpacing.xl - 2,
          4,
          SolatifySpacing.xl - 2,
          MediaQuery.viewInsetsOf(context).bottom + SolatifySpacing.xl - 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SolatifySpacing.xs + 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SolatifyColors.muted(context),
                ),
              ),
            ],
            const SizedBox(height: SolatifySpacing.sm + 2),
            ...children,
          ],
        ),
      ),
    );
  }
}
