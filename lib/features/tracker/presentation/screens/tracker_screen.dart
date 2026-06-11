import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/hive_service.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../tracker_provider.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  static String _getFormatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(trackerProvider);
    final stats = tracker.weeklyStats;

    // Calculate total logged in last 7 days (7 days * 5 prayers = 35 total)
    final completed = stats['completed'] ?? 0;
    final delayed = stats['delayed'] ?? 0;
    final missed = stats['missed'] ?? 0;
    final totalLogged = completed + delayed + missed;

    final successCount = completed + delayed;
    final double completionRate = totalLogged > 0 ? (successCount / 35.0) : 0.0;
    final formattedRate = (completionRate * 100).toStringAsFixed(0);

    // List of last 7 days for the grid
    final today = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (index) {
      return today.subtract(Duration(days: index));
    }).reversed.toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);
    final textHint = isDark ? Colors.white38 : const Color(0xFF7A6A5D);
    final unmarkedColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(title: const Text('Jurnal Ibadah')),
      body: SafeArea(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveLayout.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Streak & Circular Stats Overview Card
                GlassContainer(
                  blur: 20,
                  opacity: isDark ? 0.04 : 0.02,
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 360;
                      final progress = Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              value: completionRate,
                              strokeWidth: 8,
                              backgroundColor: unmarkedColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$formattedRate%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Pekan Ini',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                      final details = Column(
                        crossAxisAlignment: isNarrow
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isNarrow
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: textColor,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${tracker.currentStreak} Hari Beruntun',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC78A4C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pertahankan konsistensi ibadah Anda untuk menjaga rantai streak tetap menyala.',
                            textAlign: isNarrow
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            progress,
                            const SizedBox(height: 16),
                            details,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          progress,
                          const SizedBox(width: 24),
                          Expanded(child: details),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Weekly Grid Visualizer (7x5 compliance matrix)
                Text(
                  'Kepatuhan Salat (7 Hari Terakhir)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 320),
                    child: GlassContainer(
                      blur: 15,
                      opacity: isDark ? 0.03 : 0.015,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 60),
                              ...last7Days.map((date) {
                                final label = DateFormat(
                                  'E',
                                  'id_ID',
                                ).format(date);
                                return SizedBox(
                                  width: 34,
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textHint,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildGridRow(
                            context,
                            ref,
                            'Subuh',
                            'subuh',
                            last7Days,
                          ),
                          const SizedBox(height: 12),
                          _buildGridRow(
                            context,
                            ref,
                            'Dzuhur',
                            'dzuhur',
                            last7Days,
                          ),
                          const SizedBox(height: 12),
                          _buildGridRow(
                            context,
                            ref,
                            'Ashar',
                            'ashar',
                            last7Days,
                          ),
                          const SizedBox(height: 12),
                          _buildGridRow(
                            context,
                            ref,
                            'Magrib',
                            'magrib',
                            last7Days,
                          ),
                          const SizedBox(height: 12),
                          _buildGridRow(
                            context,
                            ref,
                            'Isya',
                            'isya',
                            last7Days,
                          ),

                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 14,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildLegendItem(
                                context,
                                'Tepat',
                                Theme.of(context).colorScheme.secondary,
                              ),
                              _buildLegendItem(
                                context,
                                'Terlambat',
                                const Color(0xFFC78A4C),
                              ),
                              _buildLegendItem(
                                context,
                                'Terlewat',
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF241A12),
                              ),
                              _buildLegendItem(
                                context,
                                'Kosong',
                                unmarkedColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Weekly Summary Counter Lists
                Text(
                  'Rincian Pekan Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 380) {
                      return Column(
                        children: [
                          _buildStatCard(
                            context,
                            'Tepat Waktu',
                            completed,
                            Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            context,
                            'Masbuq',
                            delayed,
                            const Color(0xFFC78A4C),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            context,
                            'Terlewat',
                            missed,
                            textColor,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Tepat Waktu',
                            completed,
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Masbuq',
                            delayed,
                            const Color(0xFFC78A4C),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Terlewat',
                            missed,
                            textColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridRow(
    BuildContext context,
    WidgetRef ref,
    String label,
    String prayerKey,
    List<DateTime> dates,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? Colors.white70 : const Color(0xFF6E5B4B);
    final unmarkedColor = isDark ? Colors.white12 : Colors.black12;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...dates.map((date) {
          final dateKey = _getFormatDate(date);
          final entry = HiveService.getTrackerEntry('${dateKey}_$prayerKey');
          final status = entry?['status'] as String? ?? 'unmarked';

          Color dotColor;
          switch (status) {
            case 'completed':
              dotColor = Theme.of(context).colorScheme.secondary;
              break;
            case 'delayed':
              dotColor = const Color(0xFFC78A4C);
              break;
            case 'missed':
              dotColor = isDark ? Colors.white70 : const Color(0xFF241A12);
              break;
            case 'unmarked':
            default:
              dotColor = unmarkedColor;
          }

          return SizedBox(
            width: 34,
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: status != 'unmarked'
                      ? [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    int count,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);
    return GlassContainer(
      blur: 10,
      opacity: isDark ? 0.02 : 0.01,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
