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
    required this.weeklyStatsAsync,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.onTogglePrayer,
    required this.onUpdateStatus,
  });

  final PrayerLogEntity log;
  final AsyncValue<WeeklyStatsEntity> weeklyStatsAsync;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final ValueChanged<String> onTogglePrayer;
  final void Function(String prayer, PrayerStatus status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final completedCount = log.prayers.values.where((isDone) => isDone).length;
    final totalCount = TrackerScreen._prayerLabels.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            accentColor: accentColor,
            textColor: textColor,
            mutedColor: mutedColor,
          );
        },
        loading: () => _InsightContent(
          totalDone: 0,
          average: '0.0',
          statusCounts: const {},
          accentColor: accentColor,
          textColor: textColor,
          mutedColor: mutedColor,
          isLoading: true,
        ),
        error: (_, _) => _InsightContent(
          totalDone: 0,
          average: '0.0',
          statusCounts: const {},
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
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    this.isLoading = false,
    this.isError = false,
  });

  final int totalDone;
  final String average;
  final Map<PrayerStatus, int> statusCounts;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final bool isLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final description = isLoading
        ? 'Menghitung ringkasan ibadah minggu ini.'
        : isError
        ? 'Insight belum bisa dimuat, tapi checklist hari ini tetap bisa digunakan.'
        : 'Rata-rata $average salat tertandai per hari dalam 7 hari terakhir.';

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
        Text(description, style: TextStyle(color: mutedColor, fontSize: 13)),
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
  });

  final String label;
  final String value;
  final Color accentColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
      ),
    );
  }
}
