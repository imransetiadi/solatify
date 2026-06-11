import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';
import '../../../tracker/presentation/tracker_provider.dart';
import '../countdown_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showStatusPicker(
    BuildContext context,
    WidgetRef ref,
    String prayerKey,
    String prayerName,
    String currentStatus,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final mutedColor = isDark ? const Color(0xFFC8B8A8) : const Color(0xFF6E5B4B);
    final primary = Theme.of(context).colorScheme.secondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF103B28) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Catat Jurnal Salat $prayerName',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 20),
                _StatusOption(
                  icon: Icons.check_circle,
                  label: 'Tepat Waktu',
                  selected: currentStatus == 'completed',
                  iconColor: primary,
                  textColor: textColor,
                  onTap: () {
                    ref.read(trackerProvider.notifier).updatePrayerStatus(prayerKey, 'completed');
                    Navigator.pop(context);
                  },
                ),
                _StatusOption(
                  icon: Icons.watch_later,
                  label: 'Masbuq / Terlambat',
                  selected: currentStatus == 'delayed',
                  iconColor: const Color(0xFFC78A4C),
                  textColor: textColor,
                  onTap: () {
                    ref.read(trackerProvider.notifier).updatePrayerStatus(prayerKey, 'delayed');
                    Navigator.pop(context);
                  },
                ),
                _StatusOption(
                  icon: Icons.cancel,
                  label: 'Terlewat',
                  selected: currentStatus == 'missed',
                  iconColor: Colors.redAccent,
                  textColor: textColor,
                  onTap: () {
                    ref.read(trackerProvider.notifier).updatePrayerStatus(prayerKey, 'missed');
                    Navigator.pop(context);
                  },
                ),
                _StatusOption(
                  icon: Icons.restart_alt,
                  label: 'Reset',
                  selected: currentStatus == 'unmarked',
                  iconColor: mutedColor,
                  textColor: mutedColor,
                  onTap: () {
                    ref.read(trackerProvider.notifier).updatePrayerStatus(prayerKey, 'unmarked');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final countdown = ref.watch(countdownProvider);
    final tracker = ref.watch(trackerProvider);
    final prayerList = ref.watch(prayerListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.secondary;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final mutedColor = isDark ? const Color(0xFFC8B8A8) : const Color(0xFF6E5B4B);
    final todayStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          bottom: false,
          child: ResponsiveCenter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context).copyWith(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: primary.withValues(alpha: 0.25)),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/masjid_nabawi.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Assalamu’alaikum', style: TextStyle(color: mutedColor, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Solatify', style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                              const SizedBox(height: 4),
                              Text('${location.city}, ${location.country}', style: TextStyle(color: mutedColor, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context),
                    child: GlassContainer(
                      blur: 20,
                      opacity: isDark ? 0.06 : 0.03,
                      borderColor: primary.withValues(alpha: 0.22),
                      borderRadius: 24,
                      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 360 ? 18 : 24),
                      child: Column(
                        children: [
                          Text(todayStr, style: TextStyle(color: mutedColor, fontSize: 14)),
                          const SizedBox(height: 12),
                          Text('Menuju ${countdown.nextPrayerName}', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Text(
                            countdown.formattedTime,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                              fontSize: MediaQuery.sizeOf(context).width < 360 ? 42 : 54,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: primary.withValues(alpha: 0.25)),
                            ),
                            child: Text('Waktu Aktif: ${countdown.activePrayerName}', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context).copyWith(top: 8, bottom: 8),
                    child: Text('Jadwal & Catatan Hari Ini', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.pagePadding(context).horizontal / 2),
                  sliver: prayerList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = prayerList[index];
                              final isNext = countdown.nextPrayerKey == item.key;
                              final isActive = countdown.activePrayerName == item.name;
                              final status = tracker.todayStatus[item.key] ?? 'unmarked';
                              final formattedTime = DateFormat('HH:mm').format(item.time);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: isActive ? 0.08 : 0.03,
                                  borderColor: isActive || isNext
                                      ? primary.withValues(alpha: isActive ? 0.8 : 0.35)
                                      : (isDark ? Colors.white.withValues(alpha: 0.08) : primary.withValues(alpha: 0.12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isActive ? Icons.circle : (isNext ? Icons.circle_outlined : Icons.circle_outlined),
                                        color: isActive || isNext ? primary : mutedColor.withValues(alpha: 0.35),
                                        size: 10,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isActive ? primary : textColor,
                                                fontSize: 16,
                                                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(formattedTime, style: TextStyle(color: mutedColor, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _showStatusPicker(context, ref, item.key, item.name, status),
                                        icon: Icon(_statusIcon(status), size: 18, color: _statusColor(context, status)),
                                        label: Text(_statusLabel(status), style: TextStyle(color: _statusColor(context, status), fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: prayerList.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'delayed':
        return Icons.watch_later;
      case 'missed':
        return Icons.cancel;
      default:
        return Icons.add_circle_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'delayed':
        return 'Masbuq';
      case 'missed':
        return 'Terlewat';
      default:
        return 'Catat';
    }
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'completed':
        return Theme.of(context).colorScheme.secondary;
      case 'delayed':
        return const Color(0xFFC78A4C);
      case 'missed':
        return Colors.redAccent;
      default:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.72);
    }
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor)),
      selected: selected,
      selectedTileColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
