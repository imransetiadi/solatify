import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_habit_sheets.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

class TrackerHabitSection extends StatelessWidget {
  const TrackerHabitSection({
    super.key,
    required this.habits,
    required this.habitProgress,
    required this.customHabits,
    required this.customHabitTargets,
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
  final ValueChanged<String> onToggleHabit;
  final TrackerAddHabit onAddHabit;
  final void Function(String oldName, String newName) onRenameHabit;
  final ValueChanged<String> onDeleteHabit;
  final void Function(String habitKey, int progress) onUpdateHabitProgress;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final mutedColor = SolatifyColors.muted(context);
    final allHabits = <String, String>{
      ...habitLabels,
      for (final habit in customHabits) 'custom:$habit': habit,
    };
    final completedCount = allHabits.keys
        .where((key) => habits[key] ?? false)
        .length;

    return GlassContainer(
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackerCardHeader(
            icon: Icons.spa_outlined,
            title: isEnglish ? 'Sunnah Habits' : 'Habit Sunnah',
            subtitle: isEnglish
                ? '$completedCount/${allHabits.length} habits done for this date.'
                : '$completedCount/${allHabits.length} habit selesai untuk tanggal ini.',
          ),
          if (customHabits.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              isEnglish
                  ? 'Custom habits appear on every date; status is saved per date.'
                  : 'Habit custom muncul di semua tanggal, statusnya tetap per tanggal.',
              style: TextStyle(
                color: mutedColor,
                fontSize: SolatifyType.caption,
              ),
            ),
          ],
          const SizedBox(height: SolatifySpacing.xs),
          Wrap(
            spacing: SolatifySpacing.xs,
            children: [
              Tooltip(
                message: isEnglish
                    ? 'Create your own habit'
                    : 'Buat habit custom sendiri',
                child: TextButton.icon(
                  onPressed: () => showTrackerAddHabitSheet(
                    context,
                    customHabits: customHabits,
                    onAddHabit: onAddHabit,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(isEnglish ? 'Add Habit' : 'Tambah Habit'),
                ),
              ),
              Tooltip(
                message: customHabits.isEmpty
                    ? (isEnglish
                          ? 'Add a custom habit first'
                          : 'Tambahkan habit custom dulu')
                    : (isEnglish
                          ? 'Rename or delete custom habits'
                          : 'Ubah nama atau hapus habit custom'),
                child: TextButton.icon(
                  onPressed: customHabits.isEmpty
                      ? null
                      : () => showTrackerManageHabitSheet(
                          context,
                          customHabits: customHabits,
                          onRenameHabit: onRenameHabit,
                          onDeleteHabit: onDeleteHabit,
                        ),
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(isEnglish ? 'Manage' : 'Kelola'),
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Wrap(
            spacing: SolatifySpacing.xs + 2,
            runSpacing: SolatifySpacing.sm,
            children: allHabits.entries.map((entry) {
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
                  onDecrease: () =>
                      onUpdateHabitProgress(entry.key, progress - 1),
                  onIncrease: () =>
                      onUpdateHabitProgress(entry.key, progress + 1),
                );
              }
              return _HabitChip(
                label: entry.value,
                isDone: habits[entry.key] ?? false,
                onTap: () => onToggleHabit(entry.key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _habitDecoration(BuildContext context, bool isDone) {
  final success = SolatifyColors.success(context);
  return BoxDecoration(
    color: isDone ? success.withValues(alpha: 0.12) : Colors.transparent,
    borderRadius: BorderRadius.circular(SolatifyRadius.md),
    border: Border.all(
      color: isDone
          ? success.withValues(alpha: 0.6)
          : SolatifyColors.border(context),
      width: 1.5,
    ),
  );
}

class _HabitChip extends StatelessWidget {
  const _HabitChip({
    required this.label,
    required this.isDone,
    required this.onTap,
  });

  final String label;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final success = SolatifyColors.success(context);
    final mutedColor = SolatifyColors.muted(context);
    final duration = SolatifyMotion.of(context, SolatifyMotion.fast);

    return Semantics(
      button: true,
      checked: isDone,
      label: label,
      value: isDone
          ? (isEnglish ? 'Done' : 'Selesai')
          : (isEnglish ? 'Not yet' : 'Belum'),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SolatifyRadius.md),
          child: AnimatedContainer(
            duration: duration,
            curve: SolatifyMotion.curve,
            constraints: const BoxConstraints(minHeight: SolatifyTapTarget.min),
            padding: const EdgeInsets.symmetric(
              horizontal: SolatifySpacing.md,
              vertical: SolatifySpacing.xs,
            ),
            decoration: _habitDecoration(context, isDone),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: duration,
                  child: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline,
                    key: ValueKey<bool>(isDone),
                    size: 18,
                    color: isDone ? success : mutedColor,
                  ),
                ),
                const SizedBox(width: SolatifySpacing.xs + 2),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: SolatifyColors.text(context),
                      fontWeight: isDone ? FontWeight.w800 : FontWeight.w600,
                      fontSize: SolatifyType.caption + 1,
                    ),
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

class _TargetHabitChip extends StatelessWidget {
  const _TargetHabitChip({
    required this.label,
    required this.progress,
    required this.target,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int progress;
  final CustomHabitTarget target;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final isDone = progress >= target.target;
    final currentProgress = progress.clamp(0, target.target);
    final success = SolatifyColors.success(context);
    final mutedColor = SolatifyColors.muted(context);

    return AnimatedContainer(
      duration: SolatifyMotion.of(context, SolatifyMotion.fast),
      curve: SolatifyMotion.curve,
      padding: const EdgeInsets.fromLTRB(SolatifySpacing.sm + 2, 4, 4, 4),
      decoration: _habitDecoration(context, isDone),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.track_changes_outlined,
            size: 18,
            color: isDone ? success : mutedColor,
          ),
          const SizedBox(width: SolatifySpacing.xs + 2),
          Flexible(
            child: Semantics(
              label: isEnglish
                  ? '$label, $currentProgress of ${target.target} '
                        '${target.unit}${isDone ? ', done' : ''}'
                  : '$label, $currentProgress dari ${target.target} '
                        '${target.unit}${isDone ? ', selesai' : ''}',
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: SolatifyColors.text(context),
                      fontWeight: isDone ? FontWeight.w800 : FontWeight.w600,
                      fontSize: SolatifyType.caption + 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currentProgress/${target.target} ${target.unit}',
                    style: TextStyle(
                      color: isDone ? success : mutedColor,
                      fontSize: SolatifyType.caption - 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          _HabitStepButton(
            icon: Icons.remove,
            tooltip: isEnglish ? 'Decrease $label' : 'Kurangi $label',
            onPressed: progress <= 0 ? null : onDecrease,
          ),
          _HabitStepButton(
            icon: Icons.add,
            tooltip: isEnglish ? 'Increase $label' : 'Tambah $label',
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _HabitStepButton extends StatelessWidget {
  const _HabitStepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: SolatifyTapTarget.min,
      child: IconButton.filledTonal(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 18,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
