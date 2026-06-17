import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/islamic_tips/presentation/providers/tips_provider.dart';

class IslamicContentScreen extends ConsumerWidget {
  const IslamicContentScreen({super.key});

  static const _menuItems = [
    _ContentMenuItem(
      title: 'Asmaul Husna',
      subtitle: '99 nama indah Allah',
      icon: Icons.font_download_outlined,
      path: '/islamic-content/asmaul-husna',
    ),
    _ContentMenuItem(
      title: 'Doa Harian',
      subtitle: 'Kumpulan doa sehari-hari',
      icon: Icons.volunteer_activism_outlined,
      path: '/islamic-content/duas',
    ),
    _ContentMenuItem(
      title: 'Kalender Hijriah',
      subtitle: 'Tanggal dan peristiwa Islam',
      icon: Icons.calendar_month_outlined,
      path: '/islamic-content/hijri-calendar',
    ),
    _ContentMenuItem(
      title: 'Dzikir',
      subtitle: 'Dzikir pagi dan petang',
      icon: Icons.wb_twilight_outlined,
      path: '/islamic-content/dhikr',
    ),
    _ContentMenuItem(
      title: 'Tuntunan Salat',
      subtitle: 'Tata cara dan bacaan salat',
      icon: Icons.menu_book_outlined,
      path: '/islamic-content/prayer-guide',
    ),
    _ContentMenuItem(
      title: 'Tips Islami',
      subtitle: 'Nasihat dan amalan ringan',
      icon: Icons.lightbulb_outline,
      path: '/islamic-content/tips',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        title: Text(
          l.islamicContent,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: ListView(
            padding: ResponsiveLayout.pagePadding(
              context,
            ).copyWith(top: 16, bottom: 96),
            children: [
              IslamicHeaderDecoration(
                title: l.spiritualExplore,
                subtitle: l.spiritualExploreSubtitle,
              ),
              const SizedBox(height: 12),
              _SectionTitle(
                icon: Icons.auto_awesome,
                title: l.dailyTip,
                color: redAccent,
              ),
              const SizedBox(height: 12),
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
                  onTap: () => context.go('/islamic-content/tips'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('${l.failedToLoadTip}: $e'),
              ),
              const SizedBox(height: 20),
              _SectionTitle(
                icon: Icons.grid_view_rounded,
                title: l.contentMenu,
                color: redAccent,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Keep the grid evenly spaced with fixed columns on all widths.
                  final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
                  final spacing = 12.0;
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
                          height: 148,
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
        subtitle: '99 beautiful names of Allah',
        icon: Icons.font_download_outlined,
        path: '/islamic-content/asmaul-husna',
      ),
      _ContentMenuItem(
        title: 'Daily Duas',
        subtitle: 'A collection of daily duas',
        icon: Icons.volunteer_activism_outlined,
        path: '/islamic-content/duas',
      ),
      _ContentMenuItem(
        title: 'Hijri Calendar',
        subtitle: 'Islamic dates and events',
        icon: Icons.calendar_month_outlined,
        path: '/islamic-content/hijri-calendar',
      ),
      _ContentMenuItem(
        title: 'Dhikr',
        subtitle: 'Morning and evening dhikr',
        icon: Icons.wb_twilight_outlined,
        path: '/islamic-content/dhikr',
      ),
      _ContentMenuItem(
        title: 'Prayer Guide',
        subtitle: 'Prayer steps and recitations',
        icon: Icons.menu_book_outlined,
        path: '/islamic-content/prayer-guide',
      ),
      _ContentMenuItem(
        title: 'Islamic Tips',
        subtitle: 'Advice and light daily deeds',
        icon: Icons.lightbulb_outline,
        path: '/islamic-content/tips',
      ),
    ];
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
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
    return Card(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(fontSize: 14, height: 1.45, color: mutedColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Ref: $reference',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: mutedColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(seeAllLabel),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ),
          ],
        ),
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
    return Material(
      color: surfaceColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.30), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(item.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: primaryColor, size: 20),
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, height: 1.25, color: mutedColor),
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
    required this.subtitle,
    required this.icon,
    required this.path,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;
}
