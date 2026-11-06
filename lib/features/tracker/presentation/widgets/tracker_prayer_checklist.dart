import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/tracker/domain/entities/prayer_log_entity.dart';
import 'package:solatify/features/tracker/presentation/widgets/tracker_ui_helpers.dart';

/// Card with one large, tappable row per obligatory prayer.
class TrackerPrayerChecklist extends StatelessWidget {
  const TrackerPrayerChecklist({
    super.key,
    required this.log,
    required this.onTogglePrayer,
    required this.onUpdateStatus,
  });

  final PrayerLogEntity log;
  final ValueChanged<String> onTogglePrayer;
  final void Function(String prayer, PrayerStatus status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);

    return GlassContainer(
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackerCardHeader(
            icon: Icons.checklist_rounded,
            title: isEnglish
                ? 'Today\'s Worship Checklist'
                : 'Ceklis Ibadah Hari Ini',
            subtitle: isEnglish
                ? 'Tap a prayer once it is done. Slowly, consistency is what matters.'
                : 'Tandai salat yang sudah ditunaikan hari ini. Pelan-pelan, yang penting istiqamah.',
          ),
          const SizedBox(height: SolatifySpacing.xs),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: SolatifyIconSize.inline,
                color: SolatifyColors.muted(context),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEnglish
                      ? 'Auto status: On time'
                      : 'Status otomatis: Tepat Waktu',
                  style: TextStyle(
                    color: SolatifyColors.muted(context),
                    fontSize: SolatifyType.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.md),
          for (final entry in trackerPrayerLabels.entries) ...[
            _PrayerRow(
              label: entry.value,
              isDone: log.prayers[entry.key] ?? false,
              status: log.getPrayerStatus(entry.key),
              onToggle: () => onTogglePrayer(entry.key),
              onEditStatus: () => _showStatusSheet(
                context,
                entry.key,
                entry.value,
                log.getPrayerStatus(entry.key),
              ),
            ),
            if (entry.key != trackerPrayerLabels.keys.last)
              const SizedBox(height: SolatifySpacing.xs + 2),
          ],
        ],
      ),
    );
  }

  void _showStatusSheet(
    BuildContext context,
    String prayer,
    String prayerLabel,
    PrayerStatus? currentStatus,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final isEnglish = trackerIsEnglish(context);
        final selected = currentStatus ?? PrayerStatus.onTime;
        return TrackerSheetFrame(
          title: isEnglish
              ? 'Change $prayerLabel Status'
              : 'Ubah Status Salat $prayerLabel',
          subtitle: isEnglish
              ? 'Checked prayers are marked On time automatically. You can correct it here.'
              : 'Status otomatis saat dicentang adalah Tepat Waktu. Kamu bisa koreksi jika perlu.',
          children: [
            for (final status in PrayerStatus.values)
              Semantics(
                selected: status == selected,
                inMutuallyExclusiveGroup: true,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    status == selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: status == selected
                        ? SolatifyColors.accent(context)
                        : SolatifyColors.muted(context),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        trackerStatusIcon(status),
                        size: SolatifyIconSize.inline,
                        color: trackerStatusColor(context, status),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          trackerStatusTitle(status, isEnglish: isEnglish),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    trackerStatusDescription(status, isEnglish: isEnglish),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (status != selected) onUpdateStatus(prayer, status);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.label,
    required this.isDone,
    required this.status,
    required this.onToggle,
    required this.onEditStatus,
  });

  final String label;
  final bool isDone;
  final PrayerStatus? status;
  final VoidCallback onToggle;
  final VoidCallback onEditStatus;

  @override
  Widget build(BuildContext context) {
    final isEnglish = trackerIsEnglish(context);
    final success = SolatifyColors.success(context);
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);
    final effectiveStatus = status ?? PrayerStatus.onTime;
    final statusTitle = trackerStatusTitle(
      effectiveStatus,
      isEnglish: isEnglish,
    );
    final stateText = isDone
        ? '${isEnglish ? 'Done' : 'Selesai'} · $statusTitle'
        : (isEnglish ? 'Not yet — tap to check' : 'Belum — ketuk untuk tandai');
    final radius = BorderRadius.circular(SolatifyRadius.sm);
    final duration = SolatifyMotion.of(context, SolatifyMotion.fast);

    return AnimatedContainer(
      duration: duration,
      curve: SolatifyMotion.curve,
      decoration: BoxDecoration(
        color: isDone
            ? success.withValues(alpha: 0.10)
            : SolatifyColors.raisedSurface(context),
        borderRadius: radius,
        border: Border.all(
          color: isDone
              ? success.withValues(alpha: 0.55)
              : SolatifyColors.border(context),
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                checked: isDone,
                label: label,
                value: isDone
                    ? '${isEnglish ? 'Done' : 'Selesai'}, $statusTitle'
                    : (isEnglish ? 'Not yet' : 'Belum'),
                hint: isDone
                    ? (isEnglish ? 'Tap to uncheck' : 'Ketuk untuk membatalkan')
                    : (isEnglish ? 'Tap to check' : 'Ketuk untuk menandai'),
                onTap: onToggle,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: radius,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SolatifySpacing.md,
                        vertical: SolatifySpacing.sm,
                      ),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: duration,
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              key: ValueKey<bool>(isDone),
                              size: 26,
                              color: isDone ? success : mutedColor,
                            ),
                          ),
                          const SizedBox(width: SolatifySpacing.sm + 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: SolatifyType.cardTitle + 1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stateText,
                                  style: TextStyle(
                                    color: isDone ? success : mutedColor,
                                    fontSize: SolatifyType.caption,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isDone)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  tooltip: isEnglish
                      ? 'Change $label status ($statusTitle)'
                      : 'Ubah status $label ($statusTitle)',
                  constraints: const BoxConstraints(
                    minWidth: SolatifyTapTarget.min,
                    minHeight: SolatifyTapTarget.min,
                  ),
                  onPressed: onEditStatus,
                  icon: Icon(
                    trackerStatusIcon(effectiveStatus),
                    color: trackerStatusColor(context, effectiveStatus),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
