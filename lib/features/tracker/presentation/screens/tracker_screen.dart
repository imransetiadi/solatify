import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/entities/weekly_stats_entity.dart';
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_date_selector.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_habit_section.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_habit_sheets.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_heatmap_card.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_insight_card.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_prayer_checklist.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_progress_card.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnglish = trackerIsEnglish(context);
    final trackerAsync = ref.watch(trackerProvider);
    final weeklyStatsAsync = ref.watch(trackerWeeklyStatsProvider);
    final selectedDate = ref.watch(trackerSelectedDateProvider);
    final customHabits = ref.watch(customHabitProvider);
    final customHabitTargets = ref.watch(customHabitTargetProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.94),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Text(
          isEnglish ? 'Worship Tracker' : 'Tracker Ibadah',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              top: SolatifySpacing.lg,
              bottom: SolatifySpacing.bottomNav,
            ),
            child: trackerAsync.when(
              data: (log) => _TrackerContent(
                log: log,
                selectedDate: selectedDate,
                customHabits: customHabits,
                customHabitTargets: customHabitTargets,
                weeklyStatsAsync: weeklyStatsAsync,
                onTogglePrayer: (prayer) =>
                    _togglePrayer(context, ref, log, prayer),
                onUpdateStatus: (prayer, status) {
                  SolatifyHaptics.selection();
                  ref
                      .read(trackerProvider.notifier)
                      .updatePrayerStatusDetail(prayer, status);
                  ref.invalidate(trackerWeeklyStatsProvider);
                },
                onSelectDate: (date) {
                  SolatifyHaptics.selection();
                  ref.read(trackerSelectedDateProvider.notifier).state = date;
                  ref.read(trackerProvider.notifier).loadLogForDate(date);
                },
                onToggleHabit: (habit) {
                  SolatifyHaptics.light();
                  ref.read(trackerProvider.notifier).toggleHabit(habit);
                },
                onAddHabit: (habitName, target, unit) {
                  SolatifyHaptics.selection();
                  ref.read(customHabitProvider.notifier).addHabit(habitName);
                  if (target != null) {
                    ref
                        .read(customHabitTargetProvider.notifier)
                        .setTarget(habitName, target: target, unit: unit);
                  }
                },
                onRenameHabit: (oldName, newName) {
                  SolatifyHaptics.selection();
                  ref
                      .read(customHabitProvider.notifier)
                      .renameHabit(oldName, newName);
                  ref
                      .read(customHabitTargetProvider.notifier)
                      .renameHabit(oldName, newName);
                },
                onDeleteHabit: (habitName) {
                  SolatifyHaptics.selection();
                  ref.read(customHabitProvider.notifier).deleteHabit(habitName);
                  ref
                      .read(customHabitTargetProvider.notifier)
                      .deleteHabit(habitName);
                },
                onUpdateHabitProgress: (habit, progress) {
                  SolatifyHaptics.selection();
                  ref
                      .read(trackerProvider.notifier)
                      .updateHabitProgress(habit, progress);
                },
              ),
              loading: () => SolatifyStateView.loading(
                title: isEnglish
                    ? 'Loading worship tracker'
                    : 'Memuat tracker ibadah',
                description: isEnglish
                    ? 'Preparing today\'s worship checklist.'
                    : 'Menyiapkan checklist ibadah hari ini.',
                compact: true,
              ),
              error: (_, _) => SolatifyStateView.error(
                title: isEnglish
                    ? 'Tracker could not be loaded'
                    : 'Tracker belum dapat dimuat',
                description: isEnglish
                    ? 'Tap retry to load this date again.'
                    : 'Ketuk coba lagi untuk memuat ulang tanggal ini.',
                actionLabel: isEnglish ? 'Retry' : 'Coba lagi',
                onAction: () => ref
                    .read(trackerProvider.notifier)
                    .loadLogForDate(selectedDate),
                compact: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Toggles a prayer, gives haptic feedback and offers an undo SnackBar.
  ///
  /// Undo re-toggles the same prayer on the same date and, when the prayer
  /// had a non-default status (late/qadha), restores that status too.
  void _togglePrayer(
    BuildContext context,
    WidgetRef ref,
    PrayerLogEntity log,
    String prayer,
  ) {
    final isEnglish = trackerIsEnglish(context);
    final wasDone = log.isPrayerDone(prayer);
    final previousStatus = log.getPrayerStatus(prayer);
    final logDate = log.date;
    final label = trackerPrayerLabels[prayer] ?? prayer;

    if (wasDone) {
      SolatifyHaptics.light();
    } else {
      SolatifyHaptics.success();
    }
    ref.read(trackerProvider.notifier).togglePrayer(prayer);
    ref.invalidate(trackerWeeklyStatsProvider);

    final message = wasDone
        ? (isEnglish ? '$label unchecked' : '$label batal ditandai')
        : (isEnglish ? '$label marked done' : '$label ditandai selesai');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          // A SnackBar with an action persists by default (Flutter 3.29+);
          // the undo offer should go away on its own.
          persist: false,
          action: SnackBarAction(
            label: isEnglish ? 'Undo' : 'Urungkan',
            onPressed: () async {
              if (!context.mounted) return;
              try {
                final notifier = ref.read(trackerProvider.notifier);
                final current = ref.read(trackerProvider).value;
                // Only undo if the user is still looking at the same date and
                // the prayer is still in the state we left it in.
                if (current == null ||
                    !trackerIsSameDay(current.date, logDate) ||
                    current.isPrayerDone(prayer) == wasDone) {
                  return;
                }
                await notifier.togglePrayer(prayer);
                if (wasDone &&
                    previousStatus != null &&
                    previousStatus != PrayerStatus.onTime) {
                  await notifier.updatePrayerStatusDetail(
                    prayer,
                    previousStatus,
                  );
                }
                ref.invalidate(trackerWeeklyStatsProvider);
                SolatifyHaptics.selection();
              } catch (error) {
                debugPrint('Tracker undo skipped: $error');
              }
            },
          ),
        ),
      );
  }
}

class _TrackerContent extends StatelessWidget {
  const _TrackerContent({
    required this.log,
    required this.selectedDate,
    required this.customHabits,
    required this.customHabitTargets,
    required this.weeklyStatsAsync,
    required this.onTogglePrayer,
    required this.onUpdateStatus,
    required this.onSelectDate,
    required this.onToggleHabit,
    required this.onAddHabit,
    required this.onRenameHabit,
    required this.onDeleteHabit,
    required this.onUpdateHabitProgress,
  });

  final PrayerLogEntity log;
  final DateTime selectedDate;
  final List<String> customHabits;
  final Map<String, CustomHabitTarget> customHabitTargets;
  final AsyncValue<WeeklyStatsEntity> weeklyStatsAsync;
  final ValueChanged<String> onTogglePrayer;
  final void Function(String prayer, PrayerStatus status) onUpdateStatus;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<String> onToggleHabit;
  final TrackerAddHabit onAddHabit;
  final void Function(String oldName, String newName) onRenameHabit;
  final ValueChanged<String> onDeleteHabit;
  final void Function(String habitKey, int progress) onUpdateHabitProgress;

  @override
  Widget build(BuildContext context) {
    final completedCount = trackerPrayerLabels.keys
        .where((key) => log.prayers[key] ?? false)
        .length;
    final gap = ResponsiveLayout.itemGapFor(context) + 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrackerDateSelector(
          selectedDate: selectedDate,
          onSelectDate: onSelectDate,
        ),
        SizedBox(height: gap),
        TrackerHeatmapCard(
          weeklyStatsAsync: weeklyStatsAsync,
          selectedDate: selectedDate,
          onSelectDate: onSelectDate,
        ),
        SizedBox(height: gap),
        TrackerProgressCard(
          completedCount: completedCount,
          totalCount: trackerPrayerLabels.length,
          isToday: trackerIsSameDay(selectedDate, DateTime.now()),
        ),
        SizedBox(height: gap),
        TrackerPrayerChecklist(
          log: log,
          onTogglePrayer: onTogglePrayer,
          onUpdateStatus: onUpdateStatus,
        ),
        SizedBox(height: gap),
        TrackerHabitSection(
          habits: log.habits,
          habitProgress: log.habitProgress,
          customHabits: customHabits,
          customHabitTargets: customHabitTargets,
          onToggleHabit: onToggleHabit,
          onAddHabit: onAddHabit,
          onRenameHabit: onRenameHabit,
          onDeleteHabit: onDeleteHabit,
          onUpdateHabitProgress: onUpdateHabitProgress,
        ),
        SizedBox(height: gap),
        TrackerInsightCard(weeklyStatsAsync: weeklyStatsAsync),
      ],
    );
  }
}
