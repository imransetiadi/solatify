import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/domain/entities/weekly_stats_entity.dart';
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  static const _prayerLabels = {
    'subuh': 'Subuh',
    'dzuhur': 'Dzuhur',
    'ashar': 'Ashar',
    'magrib': 'Magrib',
    'isya': 'Isya',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerAsync = ref.watch(trackerProvider);
    final weeklyStatsAsync = ref.watch(trackerWeeklyStatsProvider);
    final selectedDate = ref.watch(trackerSelectedDateProvider);
    final customHabits = ref.watch(customHabitProvider);
    final customHabitTargets = ref.watch(customHabitTargetProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;
    final accentColor = AppTheme.readableAccent(context);
    final appBarColor = colorScheme.surface.withValues(alpha: 0.94);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: const Text(
          'Tracker Ibadah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveLayout.pagePadding(
              context,
            ).copyWith(top: 16, bottom: 96),
            child: trackerAsync.when(
              data: (log) => _TrackerContent(
                log: log,
                selectedDate: selectedDate,
                customHabits: customHabits,
                customHabitTargets: customHabitTargets,
                weeklyStatsAsync: weeklyStatsAsync,
                accentColor: accentColor,
                textColor: textColor,
                mutedColor: mutedColor,
                onTogglePrayer: (prayer) {
                  SolatifyHaptics.light();
                  ref.read(trackerProvider.notifier).togglePrayer(prayer);
                  ref.invalidate(trackerWeeklyStatsProvider);
                },
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
              loading: () => const SolatifyStateView.loading(
                title: 'Memuat tracker ibadah',
                description: 'Menyiapkan checklist ibadah hari ini.',
                compact: true,
              ),
              error: (_, _) => const SolatifyStateView.error(
                title: 'Tracker belum dapat dimuat',
                description: 'Silakan buka ulang halaman tracker.',
                compact: true,
              ),
            ),
          ),
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
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
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
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<String> onTogglePrayer;
  final void Function(String prayer, PrayerStatus status) onUpdateStatus;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<String> onToggleHabit;
  final void Function(String habitName, int? target, String unit) onAddHabit;
  final void Function(String oldName, String newName) onRenameHabit;
  final ValueChanged<String> onDeleteHabit;
  final void Function(String habitKey, int progress) onUpdateHabitProgress;

  @override
  Widget build(BuildContext context) {
    final completedCount = log.prayers.values.where((isDone) => isDone).length;
    final totalCount = TrackerScreen._prayerLabels.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HistorySelector(
          selectedDate: selectedDate,
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
          onSelectDate: onSelectDate,
        ),
        const SizedBox(height: 14),
        _ConsistencyHeatmapCard(
          weeklyStatsAsync: weeklyStatsAsync,
          selectedDate: selectedDate,
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
          onSelectDate: onSelectDate,
        ),
        const SizedBox(height: 14),
        _ProgressCard(
          completedCount: completedCount,
          totalCount: totalCount,
          progress: progress,
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
        const SizedBox(height: 14),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ceklis Ibadah Hari Ini',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tandai salat yang sudah ditunaikan hari ini. Pelan-pelan, yang penting istiqamah.',
                style: TextStyle(color: mutedColor, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Status otomatis: Tepat Waktu',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: TrackerScreen._prayerLabels.entries.map((entry) {
                  final isDone = log.prayers[entry.key] ?? false;
                  final status = log.getPrayerStatus(entry.key);
                  return _PrayerChip(
                    label: entry.value,
                    isDone: isDone,
                    status: status,
                    accentColor: accentColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    onTap: () => onTogglePrayer(entry.key),
                    onStatusTap: isDone
                        ? () => _showStatusSheet(context, entry.key, status)
                        : null,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _HabitSection(
          habits: log.habits,
          habitProgress: log.habitProgress,
          customHabits: customHabits,
          customHabitTargets: customHabitTargets,
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
          onToggleHabit: onToggleHabit,
          onAddHabit: onAddHabit,
          onRenameHabit: onRenameHabit,
          onDeleteHabit: onDeleteHabit,
          onUpdateHabitProgress: onUpdateHabitProgress,
        ),
        const SizedBox(height: 14),
        _WeeklyInsightCard(
          weeklyStatsAsync: weeklyStatsAsync,
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
      ],
    );
  }

  void _showStatusSheet(
    BuildContext context,
    String prayer,
    PrayerStatus? currentStatus,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Status Salat',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status otomatis saat dicentang adalah Tepat Waktu. Kamu bisa koreksi jika perlu.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: mutedColor),
                ),
                const SizedBox(height: 12),
                for (final status in PrayerStatus.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      status == (currentStatus ?? PrayerStatus.onTime)
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: accentColor,
                    ),
                    title: Text(_statusTitle(status)),
                    subtitle: Text(_statusDescription(status)),
                    onTap: () {
                      Navigator.of(context).pop();
                      onUpdateStatus(prayer, status);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _statusTitle(PrayerStatus status) {
  return switch (status) {
    PrayerStatus.onTime => 'Tepat Waktu',
    PrayerStatus.late => 'Terlambat',
    PrayerStatus.qadha => 'Qadha',
  };
}

String _statusDescription(PrayerStatus status) {
  return switch (status) {
    PrayerStatus.onTime => 'Ditunaikan di awal atau dalam rentang waktu salat.',
    PrayerStatus.late =>
      'Ditunaikan masih dalam waktunya, tetapi tidak di awal.',
    PrayerStatus.qadha =>
      'Ditunaikan sebagai pengganti setelah waktunya lewat.',
  };
}

class _HistorySelector extends StatelessWidget {
  const _HistorySelector({
    required this.selectedDate,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: index)),
    );

    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Tracker',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih tanggal untuk koreksi salat dan status yang sudah lewat.',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: days.map((date) {
                final isSelected = _isSameDay(selectedDate, date);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(_historyLabel(date, today)),
                    onSelected: (_) => onSelectDate(date),
                    selectedColor: accentColor.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: isSelected ? accentColor : textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? accentColor
                          : mutedColor.withValues(alpha: 0.22),
                    ),
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

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _historyLabel(DateTime date, DateTime today) {
  if (_isSameDay(date, today)) return 'Hari ini';
  if (_isSameDay(date, today.subtract(const Duration(days: 1)))) {
    return 'Kemarin';
  }
  return '${date.day}/${date.month}';
}

class _ConsistencyHeatmapCard extends StatelessWidget {
  const _ConsistencyHeatmapCard({
    required this.weeklyStatsAsync,
    required this.selectedDate,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onSelectDate,
  });

  final AsyncValue<WeeklyStatsEntity> weeklyStatsAsync;
  final DateTime selectedDate;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kalender Konsistensi',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '14 hari terakhir',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
          const SizedBox(height: 14),
          weeklyStatsAsync.when(
            data: (stats) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.heatmap.map((day) {
                final isSelected = _isSameDay(day.date, selectedDate);
                final opacity = 0.08 + (day.progress.clamp(0, 1) * 0.5);
                return InkWell(
                  onTap: () => onSelectDate(day.date),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 42,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : accentColor.withValues(alpha: 0.12),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${day.date.day}',
                          style: TextStyle(
                            color: isSelected ? accentColor : textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(day.progress * 100).round()}%',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => Text(
              'Menghitung konsistensi...',
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
            error: (_, _) => Text(
              'Kalender konsistensi belum dapat dimuat.',
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  final int completedCount;
  final int totalCount;
  final double progress;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return GlassContainer(
      opacity: 0.07,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: mutedColor.withValues(alpha: 0.16),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Hari Ini',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedCount/$totalCount salat tertandai',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  completedCount == totalCount
                      ? 'MasyaAllah, semoga Allah mudahkan untuk terus istiqamah.'
                      : 'Mulai dari satu tanda hari ini. Semoga Allah mudahkan langkahmu.',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.4,
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

class _PrayerChip extends StatelessWidget {
  const _PrayerChip({
    required this.label,
    required this.isDone,
    required this.status,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
    required this.onStatusTap,
  });

  final String label;
  final bool isDone;
  final PrayerStatus? status;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDone
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone ? accentColor : mutedColor.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  size: 17,
                  color: isDone ? accentColor : mutedColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isDone ? accentColor : textColor,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (isDone) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onStatusTap,
                child: Text(
                  'Status otomatis: ${_statusTitle(status ?? PrayerStatus.onTime)}',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HabitSection extends StatelessWidget {
  const _HabitSection({
    required this.habits,
    required this.habitProgress,
    required this.customHabits,
    required this.customHabitTargets,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onToggleHabit,
    required this.onAddHabit,
    required this.onRenameHabit,
    required this.onDeleteHabit,
    required this.onUpdateHabitProgress,
  });

  static const habitLabels = {
    'tahajud': 'Tahajud',
    'dhuha': 'Dhuha',
    'shalawat': 'Shalawat',
    'sedekah': 'Sedekah',
    'puasa_sunnah': 'Puasa Sunnah',
    'murojaah': 'Murojaah',
  };

  final Map<String, bool> habits;
  final Map<String, int> habitProgress;
  final List<String> customHabits;
  final Map<String, CustomHabitTarget> customHabitTargets;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<String> onToggleHabit;
  final void Function(String habitName, int? target, String unit) onAddHabit;
  final void Function(String oldName, String newName) onRenameHabit;
  final ValueChanged<String> onDeleteHabit;
  final void Function(String habitKey, int progress) onUpdateHabitProgress;

  @override
  Widget build(BuildContext context) {
    final allHabits = <String, String>{
      ...habitLabels,
      for (final habit in customHabits) 'custom:$habit': habit,
    };
    final completedCount = allHabits.keys
        .where((key) => habits[key] ?? false)
        .length;

    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Habit Sunnah',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddHabitSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Habit'),
              ),
              TextButton.icon(
                onPressed: customHabits.isEmpty
                    ? null
                    : () => _showManageHabitSheet(context),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Kelola'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$completedCount/${allHabits.length} habit selesai untuk tanggal ini.',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
          if (customHabits.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Habit custom muncul di semua tanggal, statusnya tetap per tanggal.',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: allHabits.entries.map((entry) {
              final isDone = habits[entry.key] ?? false;
              final habitName = entry.key.startsWith('custom:')
                  ? entry.key.substring('custom:'.length)
                  : null;
              final target = habitName == null
                  ? null
                  : customHabitTargets[habitName];
              if (target != null) {
                final progress = habitProgress[entry.key] ?? 0;
                return _TargetHabitChip(
                  label: entry.value,
                  progress: progress,
                  target: target,
                  accentColor: accentColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  onDecrease: () =>
                      onUpdateHabitProgress(entry.key, progress - 1),
                  onIncrease: () =>
                      onUpdateHabitProgress(entry.key, progress + 1),
                );
              }
              return _HabitChip(
                label: entry.value,
                isDone: isDone,
                accentColor: accentColor,
                textColor: textColor,
                mutedColor: mutedColor,
                onTap: () => onToggleHabit(entry.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context) {
    final controller = TextEditingController();
    final targetController = TextEditingController();
    final unitController = TextEditingController(text: 'kali');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Habit Custom',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama habit',
                    hintText: 'Contoh: Baca Al-Kahfi',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitHabit(
                    context,
                    controller,
                    targetController,
                    unitController,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target opsional',
                    hintText: 'Contoh: 100',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Satuan',
                    hintText: 'kali, halaman, menit',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitHabit(
                    context,
                    controller,
                    targetController,
                    unitController,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _submitHabit(
                      context,
                      controller,
                      targetController,
                      unitController,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Simpan Habit'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      controller.dispose();
      targetController.dispose();
      unitController.dispose();
    });
  }

  void _submitHabit(
    BuildContext context,
    TextEditingController controller,
    TextEditingController targetController,
    TextEditingController unitController,
  ) {
    final habitName = controller.text.trim();
    if (habitName.isEmpty) return;
    final target = int.tryParse(targetController.text.trim());
    final unit = unitController.text.trim().isEmpty
        ? 'kali'
        : unitController.text.trim();
    Navigator.of(context).pop();
    onAddHabit(habitName, target != null && target > 0 ? target : null, unit);
  }

  void _showManageHabitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Habit Custom',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ubah nama atau hapus habit custom yang sudah kamu buat.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: mutedColor),
                ),
                const SizedBox(height: 12),
                for (final habit in customHabits)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(habit),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Rename',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showRenameHabitSheet(context, habit);
                          },
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDeleteHabit(habit);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenameHabitSheet(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rename Habit',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama habit',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) =>
                      _submitRenameHabit(context, oldName, controller),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        _submitRenameHabit(context, oldName, controller),
                    icon: const Icon(Icons.check),
                    label: const Text('Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _submitRenameHabit(
    BuildContext context,
    String oldName,
    TextEditingController controller,
  ) {
    final newName = controller.text.trim();
    if (newName.isEmpty) return;
    Navigator.of(context).pop();
    onRenameHabit(oldName, newName);
  }
}

class _HabitChip extends StatelessWidget {
  const _HabitChip({
    required this.label,
    required this.isDone,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
  });

  final String label;
  final bool isDone;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDone
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone ? accentColor : mutedColor.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.add_circle_outline,
              size: 17,
              color: isDone ? accentColor : mutedColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDone ? accentColor : textColor,
                fontWeight: isDone ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetHabitChip extends StatelessWidget {
  const _TargetHabitChip({
    required this.label,
    required this.progress,
    required this.target,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int progress;
  final CustomHabitTarget target;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final isDone = progress >= target.target;
    final currentProgress = progress.clamp(0, target.target);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDone
            ? accentColor.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? accentColor : mutedColor.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.track_changes_outlined,
            size: 17,
            color: isDone ? accentColor : mutedColor,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDone ? accentColor : textColor,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentProgress/${target.target} ${target.unit}',
                style: TextStyle(
                  color: isDone ? accentColor : mutedColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _HabitStepButton(
            icon: Icons.remove,
            onPressed: progress <= 0 ? null : onDecrease,
          ),
          const SizedBox(width: 4),
          _HabitStepButton(icon: Icons.add, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _HabitStepButton extends StatelessWidget {
  const _HabitStepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 28,
      child: IconButton.filledTonal(
        padding: EdgeInsets.zero,
        iconSize: 15,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _WeeklyInsightCard extends StatelessWidget {
  const _WeeklyInsightCard({
    required this.weeklyStatsAsync,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  final AsyncValue<WeeklyStatsEntity> weeklyStatsAsync;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(18),
      child: weeklyStatsAsync.when(
        data: (stats) {
          final average = (stats.totalDone / 7).toStringAsFixed(1);
          return _InsightContent(
            totalDone: stats.totalDone,
            average: average,
            statusCounts: stats.statusCounts,
            streakDays: stats.currentStreakDays,
            strongestLabel: stats.strongestItemLabel,
            weakestLabel: stats.weakestItemLabel,
            bestDayLabel: stats.bestDayLabel,
            smartMessage: stats.smartInsightMessage,
            smartAction: stats.smartInsightAction,
            accentColor: accentColor,
            textColor: textColor,
            mutedColor: mutedColor,
          );
        },
        loading: () => _InsightContent(
          totalDone: 0,
          average: '0.0',
          statusCounts: const {},
          streakDays: 0,
          strongestLabel: 'Memuat',
          weakestLabel: 'Memuat',
          bestDayLabel: 'Memuat',
          smartMessage: 'Menghitung ringkasan ibadah minggu ini.',
          smartAction: 'Sebentar ya, insight sedang disiapkan.',
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
          isLoading: true,
        ),
        error: (_, _) => _InsightContent(
          totalDone: 0,
          average: '0.0',
          statusCounts: const {},
          streakDays: 0,
          strongestLabel: 'Belum tersedia',
          weakestLabel: 'Coba lagi',
          bestDayLabel: 'Belum tersedia',
          smartMessage:
              'Insight belum bisa dimuat, tapi checklist hari ini tetap bisa digunakan.',
          smartAction: 'Coba buka ulang halaman tracker setelah beberapa saat.',
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
          isError: true,
        ),
      ),
    );
  }
}

class _InsightContent extends StatelessWidget {
  const _InsightContent({
    required this.totalDone,
    required this.average,
    required this.statusCounts,
    required this.streakDays,
    required this.strongestLabel,
    required this.weakestLabel,
    required this.bestDayLabel,
    required this.smartMessage,
    required this.smartAction,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    this.isLoading = false,
    this.isError = false,
  });

  final int totalDone;
  final String average;
  final Map<PrayerStatus, int> statusCounts;
  final int streakDays;
  final String strongestLabel;
  final String weakestLabel;
  final String bestDayLabel;
  final String smartMessage;
  final String smartAction;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final bool isLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insight 7 Hari',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InsightPill(
              label: 'Total',
              value: '$totalDone salat',
              accentColor: accentColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(width: 10),
            _InsightPill(
              label: 'Rata-rata',
              value: '$average/hari',
              accentColor: accentColor,
              mutedColor: mutedColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InsightPill(
              label: 'Streak',
              value: '$streakDays hari',
              accentColor: accentColor,
              mutedColor: mutedColor,
              expanded: false,
            ),
            _InsightPill(
              label: 'Hari terbaik',
              value: bestDayLabel,
              accentColor: accentColor,
              mutedColor: mutedColor,
              expanded: false,
            ),
            _InsightPill(
              label: 'Terkuat',
              value: strongestLabel,
              accentColor: accentColor,
              mutedColor: mutedColor,
              expanded: false,
            ),
            _InsightPill(
              label: 'Perlu fokus',
              value: weakestLabel,
              accentColor: accentColor,
              mutedColor: mutedColor,
              expanded: false,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PrayerStatus.values.map((status) {
            return _StatusCountPill(
              label: _statusTitle(status),
              value: statusCounts[status] ?? 0,
              accentColor: accentColor,
              mutedColor: mutedColor,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          smartMessage,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          smartAction,
          style: TextStyle(color: mutedColor, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

class _StatusCountPill extends StatelessWidget {
  const _StatusCountPill({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.mutedColor,
  });

  final String label;
  final int value;
  final Color accentColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: mutedColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.mutedColor,
    this.expanded = true,
  });

  final String label;
  final String value;
  final Color accentColor;
  final Color mutedColor;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: mutedColor, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return expanded ? Expanded(child: pill) : pill;
  }
}
