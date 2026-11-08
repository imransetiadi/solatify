import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/localization/islamic_content_localizer.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/islamic_content/presentation/providers/islamic_content_search_provider.dart';
import 'package:solatify/features/islamic_tips/presentation/providers/tips_provider.dart';

/// Maximum number of search hits rendered inline in the hub.
const int _maxVisibleResults = 12;

class IslamicContentScreen extends ConsumerStatefulWidget {
  const IslamicContentScreen({super.key});

  @override
  ConsumerState<IslamicContentScreen> createState() =>
      _IslamicContentScreenState();
}

class _IslamicContentScreenState extends ConsumerState<IslamicContentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // The query provider outlives this screen; seed the field from it so a
    // query from an earlier visit is visible (and clearable) instead of
    // filtering results behind an empty search box.
    _searchController.text = ref.read(islamicContentSearchQueryProvider);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref.read(islamicContentSearchQueryProvider.notifier).state =
        _searchController.text;
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final randomTip = ref.watch(randomTipProvider);
    final searchQuery = ref.watch(islamicContentSearchQueryProvider).trim();
    final searchResults = ref.watch(islamicContentSearchResultsProvider);
    final motion = SolatifyMotion.of(context, SolatifyMotion.medium);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: SolatifyColors.text(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Semantics(
          header: true,
          child: Text(
            l.islamicContent,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              top: ResponsiveLayout.pageTopGap,
              bottom: ResponsiveLayout.bottomSafeGap,
            ),
            children: [
              _GlobalSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onClear: _clearSearch,
              ),
              const SizedBox(height: ResponsiveLayout.itemGap),
              AnimatedSize(
                duration: motion,
                curve: SolatifyMotion.curve,
                alignment: Alignment.topCenter,
                child: searchQuery.isEmpty
                    ? const SizedBox(width: double.infinity)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle(
                            icon: Icons.search,
                            title: l.isEnglish
                                ? 'Islamic Content Search Results'
                                : 'Hasil Pencarian Konten Islami',
                            trailing: searchResults.maybeWhen(
                              data: (results) => results.isEmpty
                                  ? null
                                  : l.isEnglish
                                  ? '${results.length} found'
                                  : '${results.length} hasil',
                              orElse: () => null,
                            ),
                          ),
                          const SizedBox(height: ResponsiveLayout.itemGap),
                          searchResults.when(
                            data: (results) => _SearchResultsList(
                              results: results,
                              onClear: _clearSearch,
                            ),
                            loading: () => SolatifyStateView.loading(
                              title: l.isEnglish
                                  ? 'Searching content'
                                  : 'Mencari konten',
                              description: l.isEnglish
                                  ? 'Looking through duas, dhikr, tips and the prayer guide.'
                                  : 'Menelusuri doa, dzikir, tips, dan tuntunan salat.',
                              compact: true,
                            ),
                            error: (error, _) {
                              debugPrint(
                                'Islamic content search failed: $error',
                              );
                              return SolatifyStateView.error(
                                title: l.isEnglish
                                    ? 'Search failed'
                                    : 'Gagal mencari konten',
                                description: l.isEnglish
                                    ? 'Clear the keyword and try again.'
                                    : 'Silakan hapus kata kunci lalu coba lagi.',
                                actionLabel: l.isEnglish
                                    ? 'Clear search'
                                    : 'Hapus pencarian',
                                actionIcon: Icons.close_rounded,
                                onAction: _clearSearch,
                                compact: true,
                              );
                            },
                          ),
                          const SizedBox(height: ResponsiveLayout.sectionGap),
                        ],
                      ),
              ),
              randomTip.when(
                data: (tip) => _DailyTipCard(
                  eyebrow: l.dailyTip,
                  seeAllLabel: l.seeAllTips,
                  title: l.tr(tip.title),
                  content: l.tr(tip.content),
                  reference: tip.reference,
                  onTap: () {
                    SolatifyHaptics.selection();
                    context.go(AppRoutes.islamicTips);
                  },
                ),
                loading: () => SolatifyStateView.loading(
                  title: l.isEnglish
                      ? 'Loading daily tip'
                      : 'Memuat tips harian',
                  description: l.isEnglish
                      ? 'Preparing a short inspiration for today.'
                      : 'Menyiapkan inspirasi singkat untuk hari ini.',
                  compact: true,
                ),
                error: (error, _) {
                  debugPrint('Daily tip failed to load: $error');
                  return SolatifyStateView.error(
                    title: l.failedToLoadTip,
                    description: l.isEnglish
                        ? 'Please try again later.'
                        : 'Silakan coba lagi nanti dari halaman Konten Islami.',
                    actionLabel: l.isEnglish ? 'Try again' : 'Coba lagi',
                    onAction: () => ref.invalidate(tipsProvider),
                    compact: true,
                  );
                },
              ),
              const SizedBox(height: ResponsiveLayout.sectionGap),
              _SectionTitle(icon: Icons.apps_rounded, title: l.contentMenu),
              const SizedBox(height: ResponsiveLayout.itemGap),
              _ContentMenuGrid(items: _menuItems(l)),
              const SizedBox(height: ResponsiveLayout.sectionGap),
            ],
          ),
        ),
      ),
    );
  }

  static List<_ContentMenuItem> _menuItems(AppLocalizations l) {
    final en = l.isEnglish;
    return [
      _ContentMenuItem(
        title: 'Asmaul Husna',
        description: en ? '99 beautiful names of Allah' : '99 nama indah Allah',
        icon: Icons.font_download_outlined,
        path: AppRoutes.asmaulHusna,
      ),
      _ContentMenuItem(
        title: en ? 'Daily Duas' : 'Doa Harian',
        description: en
            ? 'A collection of daily supplications'
            : 'Kumpulan doa sehari-hari',
        icon: Icons.volunteer_activism_outlined,
        path: AppRoutes.duas,
      ),
      _ContentMenuItem(
        title: en ? 'Hijri Calendar' : 'Kalender Hijriah',
        description: en
            ? 'Islamic dates and events'
            : 'Tanggal dan peristiwa Islam',
        icon: Icons.calendar_month_outlined,
        path: AppRoutes.hijriCalendar,
      ),
      _ContentMenuItem(
        title: en ? 'Dhikr' : 'Dzikir',
        description: en
            ? 'Morning and evening dhikr with counter'
            : 'Dzikir pagi & petang dengan penghitung',
        icon: Icons.wb_twilight_outlined,
        path: AppRoutes.dhikr,
      ),
      _ContentMenuItem(
        title: en ? 'Prayer Guide' : 'Tuntunan Salat',
        description: en
            ? 'Prayer steps and recitations'
            : 'Tata cara dan bacaan salat',
        icon: Icons.menu_book_outlined,
        path: AppRoutes.prayerGuide,
      ),
      _ContentMenuItem(
        title: en ? 'Islamic Tips' : 'Tips Islami',
        description: en
            ? 'Advice and light daily deeds'
            : 'Nasihat dan amalan ringan',
        icon: Icons.lightbulb_outline,
        path: AppRoutes.islamicTips,
      ),
    ];
  }
}

class _GlobalSearchField extends StatelessWidget {
  const _GlobalSearchField({
    required this.controller,
    required this.focusNode,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(
            color: SolatifyColors.text(context),
            fontSize: SolatifyType.body,
          ),
          textInputAction: TextInputAction.search,
          onTapOutside: (_) => focusNode.unfocus(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: SolatifyColors.accent(context),
            ),
            hintText: l.isEnglish
                ? 'Search duas, dhikr, Asmaul Husna...'
                : 'Cari doa, dzikir, Asmaul Husna...',
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l.isEnglish
                        ? 'Clear search'
                        : 'Bersihkan pencarian',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClear,
                  ),
          ),
        );
      },
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.results, required this.onClear});

  final List<IslamicContentSearchItem> results;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (results.isEmpty) {
      return SolatifyStateView.empty(
        title: l.isEnglish
            ? 'No matching content yet'
            : 'Belum ada konten yang cocok',
        description: l.isEnglish
            ? 'Try another word like qunut, dhikr, rahman or dhuha.'
            : 'Coba kata lain seperti qunut, dzikir, rahman, atau dhuha.',
        icon: Icons.search_off_rounded,
        actionLabel: l.isEnglish ? 'Clear search' : 'Hapus pencarian',
        actionIcon: Icons.close_rounded,
        onAction: onClear,
        compact: true,
      );
    }

    final visible = results.take(_maxVisibleResults).toList(growable: false);
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: SolatifySpacing.sm),
            child: GlassContainer(
              borderRadius: SolatifyRadius.md,
              padding: SolatifySpacing.listTile,
              onTap: () {
                SolatifyHaptics.selection();
                context.push(item.route);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SolatifyTapTarget.min,
                ),
                child: Row(
                  children: [
                    _IconBox(icon: item.icon),
                    const SizedBox(width: SolatifySpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.tr(item.category).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              fontSize: SolatifyType.eyebrow,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: SolatifyColors.text(context),
                              fontWeight: FontWeight.w800,
                              fontSize: SolatifyType.body,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: muted,
                              fontSize: SolatifyType.caption,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: SolatifySpacing.xs),
                    ExcludeSemantics(
                      child: Icon(Icons.chevron_right_rounded, color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (results.length > visible.length)
          Padding(
            padding: const EdgeInsets.only(top: SolatifySpacing.xs),
            child: Text(
              l.isEnglish
                  ? 'Showing ${visible.length} of ${results.length}. Refine your keyword to narrow results.'
                  : 'Menampilkan ${visible.length} dari ${results.length}. Perjelas kata kunci untuk hasil lebih spesifik.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: SolatifyType.caption),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = SolatifyColors.accent(context);
    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(icon, color: accent, size: SolatifyIconSize.cardIcon),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SolatifyType.sectionTitle,
                fontWeight: FontWeight.w700,
                color: SolatifyColors.text(context),
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: TextStyle(
              fontSize: SolatifyType.caption,
              fontWeight: FontWeight.w600,
              color: SolatifyColors.muted(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({
    required this.eyebrow,
    required this.seeAllLabel,
    required this.title,
    required this.content,
    required this.reference,
    required this.onTap,
  });

  final String eyebrow;
  final String seeAllLabel;
  final String title;
  final String content;
  final String reference;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);
    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      padding: SolatifySpacing.card,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBox(icon: Icons.lightbulb_outline),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: SolatifyType.eyebrow,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: SolatifyType.cardTitle,
              color: SolatifyColors.text(context),
            ),
          ),
          const SizedBox(height: SolatifySpacing.xs),
          Text(
            content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: SolatifyType.body,
              height: 1.45,
              color: muted,
            ),
          ),
          if (reference.isNotEmpty) ...[
            const SizedBox(height: SolatifySpacing.xs),
            Text(
              reference,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SolatifyType.caption,
                fontStyle: FontStyle.italic,
                color: SolatifyColors.subtle(context),
              ),
            ),
          ],
          const SizedBox(height: SolatifySpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    seeAllLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: SolatifyIconSize.inline,
                  color: accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive grid of equal-height feature cards: 2 columns on phones,
/// 3 on wider layouts. Rows size to their tallest card so large text
/// scales never overflow.
class _ContentMenuGrid extends StatelessWidget {
  const _ContentMenuGrid({required this.items});

  final List<_ContentMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        const spacing = SolatifySpacing.md;
        final rows = <Widget>[];
        for (var start = 0; start < items.length; start += columns) {
          final rowItems = items.skip(start).take(columns).toList();
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < columns; i++) ...[
                    if (i > 0) const SizedBox(width: spacing),
                    Expanded(
                      child: i < rowItems.length
                          ? _ContentMenuCard(item: rowItems[i])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
          if (start + columns < items.length) {
            rows.add(const SizedBox(height: spacing));
          }
        }
        return Column(children: rows);
      },
    );
  }
}

class _ContentMenuCard extends StatelessWidget {
  const _ContentMenuCard({required this.item});

  final _ContentMenuItem item;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      padding: SolatifySpacing.compactCard,
      semanticLabel: '${item.title}. ${item.description}',
      onTap: () {
        SolatifyHaptics.selection();
        context.go(item.path);
      },
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: SolatifyIconSize.cardBox,
              height: SolatifyIconSize.cardBox,
              decoration: BoxDecoration(
                color: SolatifyColors.accent(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Icon(
                item.icon,
                color: SolatifyColors.onAccent(context),
                size: SolatifyIconSize.cardIcon,
              ),
            ),
            const SizedBox(height: SolatifySpacing.sm),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SolatifyType.body,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: SolatifyColors.text(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SolatifyType.caption,
                height: 1.3,
                color: SolatifyColors.muted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SolatifyIconSize.cardBox,
      height: SolatifyIconSize.cardBox,
      decoration: BoxDecoration(
        color: SolatifyColors.accentSoft(context),
        borderRadius: SolatifyRadius.icon,
      ),
      child: Icon(
        icon,
        color: SolatifyColors.accent(context),
        size: SolatifyIconSize.cardIcon,
      ),
    );
  }
}

class _ContentMenuItem {
  const _ContentMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.path,
  });

  final String title;
  final String description;
  final IconData icon;
  final String path;
}
