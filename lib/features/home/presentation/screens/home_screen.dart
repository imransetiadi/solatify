import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';
import '../../../prayer_schedule/presentation/widgets/manual_location_dialog.dart';
import '../providers/countdown_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final countdown = ref.watch(countdownProvider);
    final prayerList = ref.watch(prayerListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.secondary;
    final redLine = Theme.of(context).colorScheme.tertiary;
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final mutedColor = isDark
        ? const Color(0xFFE0D4C4)
        : const Color(0xFF5D4E47);
    final todayStr = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());
    final brightGreen = isDark
        ? const Color(0xFF4CAF50)
        : const Color(0xFF0E4D31);

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
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/masjid_nabawi.svg',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assalamu’alaikum',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Solatify',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    '${location.city}, ${location.country}',
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () => showManualLocationDialog(
                                      context: context,
                                      ref: ref,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        'Ubah',
                                        style: TextStyle(
                                          color: brightGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                      borderColor: redLine.withValues(alpha: 0.30),
                      borderRadius: 24,
                      padding: EdgeInsets.all(
                        MediaQuery.sizeOf(context).width < 360 ? 18 : 24,
                      ),
                      child: Column(
                        children: [
                          Text(
                            todayStr,
                            style: TextStyle(color: mutedColor, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Menuju ${countdown.nextPrayerName}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            countdown.formattedTime,
                            maxLines: 1,
                            style: TextStyle(
                              color: textColor,
                              fontSize: MediaQuery.sizeOf(context).width < 360
                                  ? 42
                                  : 54,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              'Waktu Aktif: ${countdown.activePrayerName}',
                              style: TextStyle(
                                color: brightGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 8, bottom: 8),
                    child: Text(
                      'Jadwal Waktu Sholat',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        ResponsiveLayout.pagePadding(context).horizontal / 2,
                  ),
                  sliver: prayerList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = prayerList[index];
                            final isNext = countdown.nextPrayerKey == item.key;
                            final isActive =
                                countdown.activePrayerName == item.name;
                            final formattedTime = DateFormat(
                              'HH:mm',
                            ).format(item.time);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                blur: 15,
                                opacity: isActive ? 0.08 : 0.03,
                                borderColor: isActive || isNext
                                    ? redLine.withValues(
                                        alpha: isActive ? 0.8 : 0.45,
                                      )
                                    : redLine.withValues(
                                        alpha: isDark ? 0.30 : 0.22,
                                      ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.circle
                                          : (isNext
                                                ? Icons.circle_outlined
                                                : Icons.circle_outlined),
                                      color: isActive || isNext
                                          ? redLine
                                          : mutedColor.withValues(alpha: 0.35),
                                      size: 10,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isActive
                                                  ? redLine
                                                  : textColor,
                                              fontSize: 16,
                                              fontWeight: isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: prayerList.length),
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
}
