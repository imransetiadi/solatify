import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/islamic_content/presentation/providers/islamic_content_search_provider.dart';
import 'package:solatify/features/islamic_tips/presentation/providers/tips_provider.dart';

class IslamicContentScreen extends ConsumerStatefulWidget {
  const IslamicContentScreen({super.key});

  @override
  ConsumerState<IslamicContentScreen> createState() =>
      _IslamicContentScreenState();
}

class _IslamicContentScreenState extends ConsumerState<IslamicContentScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(islamicContentSearchQueryProvider.notifier).state =
          _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _menuItems = [
    _ContentMenuItem(
      title: 'Asmaul Husna',
      icon: Icons.font_download_outlined,
      path: AppRoutes.asmaulHusna,
    ),
    _ContentMenuItem(
      title: 'Doa Harian',
      icon: Icons.volunteer_activism_outlined,
      path: AppRoutes.duas,
    ),
    _ContentMenuItem(
      title: 'Kalender Hijriah',
      icon: Icons.calendar_month_outlined,
      path: AppRoutes.hijriCalendar,
    ),
    _ContentMenuItem(
      title: 'Dzikir',
      icon: Icons.wb_twilight_outlined,
      path: AppRoutes.dhikr,
    ),
    _ContentMenuItem(
      title: 'Tuntunan Salat',
      icon: Icons.menu_book_outlined,
      path: AppRoutes.prayerGuide,
    ),
    _ContentMenuItem(
      title: 'Tips Islami',
      icon: Icons.lightbulb_outline,
      path: AppRoutes.islamicTips,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFF6A5B51);
    final redAccent = theme.colorScheme.tertiary;
    final surfaceColor = theme.colorScheme.surface;
    final appBarColor = surfaceColor.withValues(alpha: isDark ? 0.96 : 0.94);
    final randomTip = ref.watch(randomTipProvider);
    final searchQuery = ref.watch(islamicContentSearchQueryProvider).trim();
    final searchResults = ref.watch(islamicContentSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Text(
          l.islamicContent,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: ListView(
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              top: ResponsiveLayout.pageTopGap,
              bottom: ResponsiveLayout.bottomSafeGap,
            ),
            children: [
              _GlobalSearchField(
                controller: _searchController,
                primaryColor: redAccent,
                surfaceColor: surfaceColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              const SizedBox(height: ResponsiveLayout.itemGap),
              if (searchQuery.isNotEmpty) ...[
                _SectionTitle(
                  icon: Icons.search,
                  title: 'Hasil Pencarian Konten Islami',
                  color: redAccent,
                ),
                const SizedBox(height: ResponsiveLayout.itemGap),
                searchResults.when(
                  data: (results) => _SearchResultsList(
                    results: results,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    primaryColor: redAccent,
                  ),
                  loading: () => const SolatifyStateView.loading(
                    title: 'Mencari konten',
                    description:
                        'Menelusuri doa, dzikir, tips, dan tuntunan salat.',
                    compact: true,
                  ),
                  error: (error, _) => const SolatifyStateView.error(
                    title: 'Gagal mencari konten',
                    description: 'Silakan hapus kata kunci lalu coba lagi.',
                    compact: true,
                  ),
                ),
                const SizedBox(height: ResponsiveLayout.sectionGap),
              ],
              randomTip.when(
                data: (tip) => _DailyTipCard(
                  seeAllLabel: l.seeAllTips,
                  title: tip.title,
                  content: tip.content,
                  reference: tip.reference,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: redAccent,
                  onTap: () => context.go(AppRoutes.islamicTips),
                ),
                loading: () => const SolatifyStateView.loading(
                  title: 'Memuat tips harian',
                  description: 'Menyiapkan inspirasi singkat untuk hari ini.',
                  compact: true,
                ),
                error: (e, _) => SolatifyStateView.error(
                  title: l.failedToLoadTip,
                  description:
                      'Silakan coba lagi nanti dari halaman Konten Islami.',
                  compact: true,
                ),
              ),
              const SizedBox(height: ResponsiveLayout.sectionGap),
              _SectionTitle(
                icon: Icons.apps_rounded,
                title: l.contentMenu,
                color: redAccent,
              ),
              const SizedBox(height: ResponsiveLayout.itemGap),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Keep the grid evenly spaced with fixed columns on all widths.
                  final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
                  const spacing = 14.0;
                  final cardWidth =
                      (constraints.maxWidth -
                          (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: spacing,
                    runSpacing: spacing,
                    children: _localizedMenuItems(l).map((item) {
                      return SizedBox(
                        width: cardWidth,
                        child: SizedBox(
                          height: 104,
                          child: _ContentMenuCard(
                            item: item,
                            surfaceColor: surfaceColor,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            primaryColor: redAccent,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: ResponsiveLayout.sectionGap),
            ],
          ),
        ),
      ),
    );
  }

  static List<_ContentMenuItem> _localizedMenuItems(AppLocalizations l) {
    if (!l.isEnglish) return _menuItems;
    return const [
      _ContentMenuItem(
        title: 'Asmaul Husna',
        icon: Icons.font_download_outlined,
        path: AppRoutes.asmaulHusna,
      ),
      _ContentMenuItem(
        title: 'Daily Duas',
        icon: Icons.volunteer_activism_outlined,
        path: AppRoutes.duas,
      ),
      _ContentMenuItem(
        title: 'Hijri Calendar',
        icon: Icons.calendar_month_outlined,
        path: AppRoutes.hijriCalendar,
      ),
      _ContentMenuItem(
        title: 'Dhikr',
        icon: Icons.wb_twilight_outlined,
        path: AppRoutes.dhikr,
      ),
      _ContentMenuItem(
        title: 'Prayer Guide',
        icon: Icons.menu_book_outlined,
        path: AppRoutes.prayerGuide,
      ),
      _ContentMenuItem(
        title: 'Islamic Tips',
        icon: Icons.lightbulb_outline,
        path: AppRoutes.islamicTips,
      ),
    ];
  }
}

class _GlobalSearchField extends StatelessWidget {
  const _GlobalSearchField({
    required this.controller,
    required this.primaryColor,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
  });

  final TextEditingController controller;
  final Color primaryColor;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      borderColor: primaryColor.withValues(alpha: 0.10),
      fillColor: surfaceColor.withValues(alpha: 0.96),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor, fontSize: SolatifyType.body),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: primaryColor),
          hintText: 'Cari doa, dzikir, Asmaul Husna...',
          hintStyle: TextStyle(color: mutedColor),
          border: InputBorder.none,
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Bersihkan pencarian',
                  icon: Icon(Icons.close, color: mutedColor),
                  onPressed: controller.clear,
                ),
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.results,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
  });

  final List<IslamicContentSearchItem> results;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SolatifyStateView.empty(
        title: 'Belum ada konten yang cocok',
        description:
            'Coba kata lain seperti qunut, dzikir, rahman, atau dhuha.',
        compact: true,
      );
    }

    return Column(
      children: results
          .take(12)
          .map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                borderRadius: SolatifyRadius.md,
                borderColor: primaryColor.withValues(alpha: 0.10),
                fillColor: surfaceColor.withValues(alpha: 0.96),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Container(
                    width: SolatifyIconSize.cardBox,
                    height: SolatifyIconSize.cardBox,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.14),
                      borderRadius: SolatifyRadius.icon,
                    ),
                    child: Icon(
                      item.icon,
                      color: primaryColor,
                      size: SolatifyIconSize.cardIcon,
                    ),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: SolatifyType.eyebrow,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: SolatifyType.caption,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right, color: mutedColor),
                  onTap: () {
                    SolatifyHaptics.selection();
                    context.push(item.route);
                  },
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: SolatifyIconSize.cardIcon),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: SolatifyType.sectionTitle,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({
    required this.seeAllLabel,
    required this.title,
    required this.content,
    required this.reference,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.onTap,
  });

  final String seeAllLabel;
  final String title;
  final String content;
  final String reference;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      borderColor: primaryColor.withValues(alpha: 0.10),
      fillColor: surfaceColor.withValues(alpha: 0.96),
      padding: ResponsiveLayout.listCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: SolatifyType.cardTitle,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: SolatifyType.body,
              height: 1.45,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.arrow_forward,
                size: SolatifyIconSize.inline,
              ),
              label: Text(seeAllLabel),
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentMenuCard extends StatelessWidget {
  const _ContentMenuCard({
    required this.item,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
  });

  final _ContentMenuItem item;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      borderColor: primaryColor.withValues(alpha: 0.10),
      fillColor: surfaceColor.withValues(alpha: 0.96),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: SolatifyRadius.compactCard,
        onTap: () {
          SolatifyHaptics.selection();
          context.go(item.path);
        },
        child: Padding(
          padding: ResponsiveLayout.listCardPadding,
          child: Row(
            children: [
              Container(
                width: SolatifyIconSize.cardBox,
                height: SolatifyIconSize.cardBox,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: SolatifyRadius.icon,
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: SolatifyIconSize.cardIcon,
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SolatifyType.body,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentMenuItem {
  const _ContentMenuItem({
    required this.title,
    required this.icon,
    required this.path,
  });

  final String title;
  final IconData icon;
  final String path;
}
