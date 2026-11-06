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
import 'package:solatify/features/quran/domain/models/quran_models.dart';
import 'package:solatify/features/quran/presentation/quran_provider.dart';

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Color get _textColor => SolatifyColors.text(context);
  Color get _textSecondary => SolatifyColors.muted(context);
  Color get _accentColor => SolatifyColors.accent(context);
  Color get _tileAccentBg => SolatifyColors.accentSoft(context);
  Color get _tileAccentBorder => _accentColor.withValues(
    alpha: Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.22,
  );

  AppLocalizations get _l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Keep the field in sync with a query that survived navigation.
    final existingQuery = ref.read(surahSearchQueryProvider);
    if (existingQuery.isNotEmpty) {
      _searchController.text = existingQuery;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateQuery(String value) {
    ref.read(surahSearchQueryProvider.notifier).state = value;
    setState(() {});
  }

  void _clearSearch() {
    SolatifyHaptics.selection();
    _searchController.clear();
    _updateQuery('');
  }

  void _openSurah(int surahNumber, {int? scrollTo}) {
    SolatifyHaptics.selection();
    _searchFocusNode.unfocus();
    context.push(AppRoutes.quranSurah(surahNumber, scrollTo: scrollTo));
  }

  @override
  Widget build(BuildContext context) {
    final searchListAsync = ref.watch(filteredSurahListProvider);
    final bookmarksState = ref.watch(quranBookmarksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: isDark ? 0.96 : 0.94);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Semantics(
          header: true,
          child: const Text(
            'Al-Qur\'an',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveLayout.pagePadding(context).copyWith(
                        top: ResponsiveLayout.pageTopGap,
                        bottom: ResponsiveLayout.itemGap,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchField(),
                          const SizedBox(height: SolatifySpacing.lg),

                          // Continue reading shortcut
                          AnimatedSwitcher(
                            duration: SolatifyMotion.of(
                              context,
                              SolatifyMotion.medium,
                            ),
                            switchInCurve: SolatifyMotion.curve,
                            child: bookmarksState.lastReadSurah != null
                                ? _buildLastReadCard(bookmarksState)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabHeaderDelegate(
                      child: Container(
                        color: SolatifyColors.background(context),
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveLayout.pagePadding(context).horizontal /
                              2,
                          vertical: 4,
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: _accentColor,
                          labelColor: _textColor,
                          unselectedLabelColor: _textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SolatifyType.body,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SolatifyType.body,
                          ),
                          onTap: (_) => SolatifyHaptics.selection(),
                          tabs: [
                            Tab(
                              text: _l.isEnglish
                                  ? 'Surah List'
                                  : 'Daftar Surah',
                            ),
                            Tab(
                              text: _l.isEnglish
                                  ? 'Saved Verses'
                                  : 'Tandai & Simpan',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Surah list
                  _buildSurahListTab(searchListAsync),

                  // Tab 2: Bookmarks tab
                  _buildBookmarksTab(bookmarksState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final hasQuery = _searchController.text.isNotEmpty;
    final radius = BorderRadius.circular(SolatifyRadius.md);

    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: _textColor, fontSize: SolatifyType.body),
      onTapOutside: (_) => _searchFocusNode.unfocus(),
      decoration: InputDecoration(
        hintText: _l.isEnglish
            ? 'Search surah name, meaning, or number...'
            : 'Cari nama Surah, arti, atau nomor...',
        hintMaxLines: 1,
        hintStyle: TextStyle(
          color: SolatifyColors.subtle(context),
          fontSize: SolatifyType.body,
        ),
        prefixIcon: Icon(Icons.search, color: _accentColor),
        suffixIcon: hasQuery
            ? IconButton(
                icon: Icon(Icons.clear, color: _textSecondary),
                tooltip: _l.isEnglish ? 'Clear search' : 'Hapus pencarian',
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: SolatifyColors.softSurface(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SolatifySpacing.lg,
          vertical: SolatifySpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SolatifyColors.border(context)),
          borderRadius: radius,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _accentColor, width: 1.5),
          borderRadius: radius,
        ),
      ),
      onChanged: _updateQuery,
      onSubmitted: (_) => _searchFocusNode.unfocus(),
    );
  }

  Widget _buildLastReadCard(QuranBookmarksState state) {
    final surahName = state.lastReadSurahName ?? 'Surah ${state.lastReadSurah}';
    final verse = state.lastReadVerse;
    final title = _l.isEnglish ? 'Continue reading' : 'Terakhir Dibaca';
    final verseLabel = verse == null
        ? null
        : (_l.isEnglish ? 'Verse $verse' : 'Ayat $verse');

    return Padding(
      key: const ValueKey('quran-last-read-card'),
      padding: const EdgeInsets.only(bottom: SolatifySpacing.sm),
      child: GlassContainer(
        borderRadius: SolatifyRadius.md,
        padding: SolatifySpacing.compactCard,
        borderColor: _tileAccentBorder,
        semanticLabel:
            '$title: Surah $surahName${verseLabel == null ? '' : ', $verseLabel'}',
        onTap: () => _openSurah(state.lastReadSurah!, scrollTo: verse),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Container(
                width: SolatifyIconSize.heroBox,
                height: SolatifyIconSize.heroBox,
                decoration: BoxDecoration(
                  color: _tileAccentBg,
                  borderRadius: SolatifyRadius.icon,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: _accentColor,
                  size: SolatifyIconSize.heroIcon,
                ),
              ),
              const SizedBox(width: SolatifySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: SolatifyType.eyebrow,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Surah $surahName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: SolatifyType.cardTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (verseLabel != null)
                      Text(
                        verseLabel,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: SolatifyType.caption,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _textSecondary,
                size: SolatifyIconSize.inline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps a state view so it stays centered but can scroll on short
  /// viewports or large text scales instead of overflowing.
  Widget _scrollableState(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: ResponsiveLayout.pagePadding(
          context,
        ).copyWith(top: SolatifySpacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - SolatifySpacing.bottomNav)
                .clamp(0, double.infinity)
                .toDouble(),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildSurahListTab(AsyncValue<List<Surah>> searchListAsync) {
    return searchListAsync.when(
      loading: () => _scrollableState(
        SolatifyStateView.loading(
          title: _l.isEnglish ? 'Loading surahs' : 'Memuat daftar Surah',
          description: _l.isEnglish
              ? 'Preparing the list of 114 surahs.'
              : 'Menyiapkan daftar 114 Surah.',
        ),
      ),
      error: (err, stack) => _scrollableState(
        SolatifyStateView.error(
          title: _l.isEnglish
              ? 'Failed to load the Qur\'an'
              : 'Gagal Memuat Al-Qur\'an',
          description: err.toString().replaceAll('Exception:', '').trim(),
          actionLabel: _l.isEnglish ? 'Try again' : 'Coba Lagi',
          onAction: () {
            SolatifyHaptics.light();
            ref.invalidate(surahListProvider);
          },
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          final query = _searchController.text.trim();
          return _scrollableState(
            SolatifyStateView.empty(
              icon: Icons.search_off_rounded,
              title: _l.isEnglish ? 'No surah found' : 'Surah tidak ditemukan.',
              description: query.isEmpty
                  ? (_l.isEnglish
                        ? 'The surah list is empty right now.'
                        : 'Daftar Surah sedang kosong.')
                  : (_l.isEnglish
                        ? 'Nothing matches "$query". Try a surah name, meaning, or number 1–114.'
                        : 'Tidak ada yang cocok dengan "$query". Coba nama Surah, arti, atau nomor 1–114.'),
              actionLabel: query.isEmpty
                  ? null
                  : (_l.isEnglish ? 'Clear search' : 'Hapus pencarian'),
              actionIcon: Icons.close_rounded,
              onAction: query.isEmpty ? null : _clearSearch,
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: ResponsiveLayout.pagePadding(
            context,
          ).copyWith(top: SolatifySpacing.md, bottom: 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final surah = list[index];
            return _buildSurahCard(surah);
          },
        );
      },
    );
  }

  Widget _buildBookmarksTab(QuranBookmarksState bookmarksState) {
    final listAsync = ref.watch(surahListProvider);

    return listAsync.when(
      loading: () => _scrollableState(
        SolatifyStateView.loading(
          title: _l.isEnglish ? 'Loading bookmarks' : 'Memuat penanda',
          description: _l.isEnglish
              ? 'Preparing your saved verses.'
              : 'Menyiapkan ayat yang Anda simpan.',
        ),
      ),
      error: (err, stack) => _scrollableState(
        SolatifyStateView.error(
          title: _l.isEnglish ? 'Something went wrong' : 'Terjadi kesalahan',
          description: err.toString().replaceAll('Exception:', '').trim(),
          actionLabel: _l.isEnglish ? 'Try again' : 'Coba Lagi',
          onAction: () {
            SolatifyHaptics.light();
            ref.invalidate(surahListProvider);
          },
        ),
      ),
      data: (allSurahs) {
        final bookmarkedKeys = bookmarksState.bookmarkedKeys.toList();
        // Parse + filter valid bookmark keys (skip malformed/legacy keys to
        // avoid a crash on int.parse). Centralized + unit-tested helper.
        final parsedBookmarks = QuranBookmarksNotifier.parseSortedBookmarkKeys(
          bookmarkedKeys,
        );

        if (parsedBookmarks.isEmpty) {
          return _scrollableState(
            SolatifyStateView.empty(
              icon: Icons.bookmark_outline_rounded,
              title: _l.isEnglish ? 'No saved verses yet' : 'Belum Ada Penanda',
              description: _l.isEnglish
                  ? 'Tap the star on any verse to save it here.'
                  : 'Ayat yang Anda tandai atau simpan akan muncul di tab ini.',
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: ResponsiveLayout.pagePadding(
            context,
          ).copyWith(top: SolatifySpacing.md, bottom: 96),
          itemCount: parsedBookmarks.length,
          itemBuilder: (context, index) {
            final surahNum = parsedBookmarks[index][0];
            final verseNum = parsedBookmarks[index][1];

            final surah = allSurahs.firstWhere(
              (s) => s.number == surahNum,
              orElse: () => Surah(
                number: surahNum,
                name: 'Surah',
                translation: '',
                numberOfVerses: 0,
                revelation: '',
              ),
            );
            return _buildBookmarkCard(surah, surahNum, verseNum);
          },
        );
      },
    );
  }

  Widget _buildBookmarkCard(Surah surah, int surahNum, int verseNum) {
    final verseLabel = _l.isEnglish ? 'Verse $verseNum' : 'Ayat $verseNum';

    return Padding(
      key: ValueKey('quran-bookmark-$surahNum:$verseNum'),
      padding: const EdgeInsets.only(bottom: SolatifySpacing.sm),
      child: GlassContainer(
        borderRadius: SolatifyRadius.md,
        padding: const EdgeInsets.fromLTRB(
          SolatifySpacing.md,
          SolatifySpacing.xs,
          SolatifySpacing.xs,
          SolatifySpacing.xs,
        ),
        semanticLabel: _l.isEnglish
            ? 'Open Surah ${surah.name}, $verseLabel'
            : 'Buka Surah ${surah.name}, $verseLabel',
        onTap: () => _openSurah(surahNum, scrollTo: verseNum),
        child: Row(
          children: [
            ExcludeSemantics(child: _numberBadge(surah.number)),
            const SizedBox(width: SolatifySpacing.md),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: SolatifyType.cardTitle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verseLabel,
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: SolatifyType.caption,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: _l.isEnglish
                  ? 'Remove saved verse'
                  : 'Hapus dari simpanan',
              constraints: const BoxConstraints(
                minWidth: SolatifyTapTarget.min,
                minHeight: SolatifyTapTarget.min,
              ),
              icon: Icon(
                Icons.bookmark_remove_outlined,
                color: _textSecondary,
                size: SolatifyIconSize.cardIcon + 2,
              ),
              onPressed: () {
                SolatifyHaptics.light();
                ref
                    .read(quranBookmarksProvider.notifier)
                    .toggleBookmark(surahNum, verseNum);
              },
            ),
            ExcludeSemantics(
              child: Icon(
                Icons.chevron_right_rounded,
                color: _accentColor,
                size: SolatifyIconSize.heroIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberBadge(int number) {
    return Container(
      width: SolatifyIconSize.cardBox + 4,
      height: SolatifyIconSize.cardBox + 4,
      decoration: BoxDecoration(
        color: _tileAccentBg,
        borderRadius: SolatifyRadius.icon,
        border: Border.all(color: _tileAccentBorder),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            number.toString(),
            style: TextStyle(
              color: _accentColor,
              fontWeight: FontWeight.w800,
              fontSize: SolatifyType.body,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(Surah surah) {
    final versesLabel = _l.isEnglish
        ? '${surah.numberOfVerses} verses'
        : '${surah.numberOfVerses} ayat';
    final semanticParts = <String>[
      'Surah ${surah.name}',
      if (surah.translation.isNotEmpty) surah.translation,
      versesLabel,
      if (surah.revelation.isNotEmpty) surah.revelation,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: SolatifySpacing.sm),
      child: GlassContainer(
        opacity: 0.92,
        borderRadius: SolatifyRadius.md,
        padding: ResponsiveLayout.listCardPadding,
        semanticLabel: '${surah.number}. ${semanticParts.join(', ')}',
        onTap: () => _openSurah(surah.number),
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _numberBadge(surah.number),
              const SizedBox(width: SolatifySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      surah.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: SolatifyType.cardTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (surah.translation.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        surah.translation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: SolatifyType.caption,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: SolatifySpacing.xs),
                    Wrap(
                      spacing: SolatifySpacing.xs,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (surah.revelation.isNotEmpty) ...[
                          Text(
                            surah.revelation.toUpperCase(),
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: SolatifyType.eyebrow,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Icon(
                            Icons.fiber_manual_record,
                            size: 4,
                            color: SolatifyColors.subtle(context),
                          ),
                        ],
                        Text(
                          versesLabel.toUpperCase(),
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: SolatifyType.eyebrow,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: _accentColor,
                size: SolatifyIconSize.heroIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 50.0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverTabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
