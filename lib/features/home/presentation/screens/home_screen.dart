import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/widgets/manual_location_dialog.dart';
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
        : const Color(0xFFAFA19A);

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
                                      child: Icon(
                                        Icons.edit_location_alt_outlined,
                                        size: 14,
                                        color: primary,
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
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 24, bottom: 12),
                    child: Text(
                      'Jadwal Salat',
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
                    horizontal: ResponsiveLayout.pagePadding(context).left,
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
                                          : Icons.circle_outlined,
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
