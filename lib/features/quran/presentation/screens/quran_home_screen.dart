import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import '../../domain/models/quran_models.dart';
import '../quran_provider.dart';

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  Color get _textColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF241A12);
  Color get _textSecondary => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFB8A898)
      : const Color(0xFFAFA19A);
  Color get _textHint => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8E837D)
      : const Color(0xFFAFA19A);
  Color get _cardBorderColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.08);
  Color get _accentColor => AppTheme.readableAccent(context);
  Color get _tileAccentBg => Theme.of(context).brightness == Brightness.dark
      ? AppTheme.redAccentDark.withValues(alpha: 0.14)
      : AppTheme.redAccent.withValues(alpha: 0.10);
  Color get _tileAccentBorder => Theme.of(context).brightness == Brightness.dark
      ? AppTheme.redAccentDark.withValues(alpha: 0.30)
      : AppTheme.redAccent.withValues(alpha: 0.22);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          'Al-Qur\'an',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                          GlassContainer(
                            borderRadius: SolatifyRadius.lg,
                            borderColor: _accentColor.withValues(alpha: 0.12),
                            padding: SolatifySpacing.compactCard,
                            child: Row(
                              children: [
                                Container(
                                  width: SolatifyIconSize.cardBox,
                                  height: SolatifyIconSize.cardBox,
                                  decoration: BoxDecoration(
                                    borderRadius: SolatifyRadius.icon,
                                    color: _accentColor,
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    color: Colors.white,
                                    size: SolatifyIconSize.heroIcon,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'AL-QUR\'AN',
                                        style: TextStyle(
                                          color: _accentColor,
                                          fontSize: SolatifyType.eyebrow,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Baca Al-Qur\'an',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _textColor,
                                          fontSize: SolatifyType.pageTitle,
                                          height: 1.12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: ResponsiveLayout.itemGap),

                          // Floating Search Bar
                          GlassContainer(
                            borderRadius: SolatifyRadius.md,
                            padding: EdgeInsets.zero,
                            borderColor: _accentColor.withValues(alpha: 0.12),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: _textColor),
                              decoration: InputDecoration(
                                hintText:
                                    'Cari nama Surah, arti, atau nomor...',
                                hintStyle: TextStyle(
                                  color: _textHint,
                                  fontSize: SolatifyType.body,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: _accentColor,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: _textSecondary,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          ref
                                                  .read(
                                                    surahSearchQueryProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              '';
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF2A1B12)
                                    : Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _cardBorderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _accentColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              onChanged: (val) {
                                ref
                                        .read(surahSearchQueryProvider.notifier)
                                        .state =
                                    val;
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Bookmark shortcut last read card
                          if (bookmarksState.lastReadSurah != null)
                            _buildLastReadCard(bookmarksState),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabHeaderDelegate(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveLayout.pagePadding(context).horizontal /
                              2,
                          vertical: 4,
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: Theme.of(
                            context,
                          ).colorScheme.tertiary,
                          labelColor: _textColor,
                          unselectedLabelColor: _textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: SolatifyType.body,
                          ),
                          tabs: const [
                            Tab(text: 'Daftar Surah'),
                            Tab(text: 'Tandai & Simpan'),
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

  Widget _buildLastReadCard(QuranBookmarksState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          context.push(
            '/quran/surah/${state.lastReadSurah}?scroll_to=${state.lastReadVerse}',
          );
        },
        child: GlassContainer(
          opacity: 0.04,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.bookmark_added, color: _textColor, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terakhir Dibaca',
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: SolatifyType.caption,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Surah ${state.lastReadSurahName}',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: SolatifyType.cardTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ayat ${state.lastReadVerse}',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: SolatifyType.caption,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _textSecondary.withValues(alpha: 0.5),
                size: SolatifyIconSize.inline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahListTab(AsyncValue<List<Surah>> searchListAsync) {
    return searchListAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: _accentColor)),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_outlined, color: _textColor, size: 64),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Al-Qur\'an',
                style: TextStyle(
                  color: _textColor,
                  fontSize: SolatifyType.sectionTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString().replaceAll('Exception:', ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: SolatifyType.body,
                ),
              ),
              const SizedBox(height: ResponsiveLayout.sectionGap),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => ref.refresh(surahListProvider),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'Surah tidak ditemukan.',
              style: TextStyle(
                color: _textSecondary,
                fontSize: SolatifyType.body,
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: ResponsiveLayout.pagePadding(
            context,
          ).copyWith(top: 12, bottom: 80),
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
      loading: () =>
          Center(child: CircularProgressIndicator(color: _accentColor)),
      error: (err, stack) => Center(
        child: Text(
          'Terjadi kesalahan: $err',
          style: TextStyle(color: _textColor),
        ),
      ),
      data: (allSurahs) {
        final bookmarkedKeys = bookmarksState.bookmarkedKeys.toList();
        if (bookmarkedKeys.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline, color: _textHint, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Penanda',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: SolatifyType.cardTitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ayat yang Anda tandai atau simpan akan muncul di tab ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Parse + filter valid bookmark keys (skip malformed/legacy keys to
        // avoid a crash on int.parse). Centralized + unit-tested helper.
        final parsedBookmarks = QuranBookmarksNotifier.parseSortedBookmarkKeys(
          bookmarkedKeys,
        );

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: ResponsiveLayout.pagePadding(
            context,
          ).copyWith(top: 12, bottom: 96),
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

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                opacity: 0.02,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _tileAccentBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _tileAccentBorder, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          surah.number.toString(),
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: SolatifyType.caption,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah.name,
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: SolatifyType.body,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ayat $verseNum',
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: SolatifyType.caption,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.bookmark_remove,
                            color: _textColor,
                            size: SolatifyIconSize.cardIcon,
                          ),
                          onPressed: () {
                            ref
                                .read(quranBookmarksProvider.notifier)
                                .toggleBookmark(surahNum, verseNum);
                          },
                        ),
                        IconButton(
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _tileAccentBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _tileAccentBorder,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: _accentColor,
                              size: SolatifyIconSize.cardIcon,
                            ),
                          ),
                          onPressed: () {
                            context.push(
                              '/quran/surah/$surahNum?scroll_to=$verseNum',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSurahCard(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          context.push('/quran/surah/${surah.number}');
        },
        child: GlassContainer(
          opacity: 0.92,
          borderRadius: SolatifyRadius.md,
          padding: ResponsiveLayout.listCardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _tileAccentBg,
                  borderRadius: SolatifyRadius.icon,
                  border: Border.all(color: _tileAccentBorder, width: 1),
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

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
                    const SizedBox(height: 4),
                    Text(
                      surah.translation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: SolatifyType.caption,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          surah.revelation.toUpperCase(),
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: SolatifyType.eyebrow,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.fiber_manual_record,
                          size: 5,
                          color: _textHint.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${surah.numberOfVerses} AYAT',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: SolatifyType.eyebrow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _tileAccentBg,
                  borderRadius: SolatifyRadius.icon,
                  border: Border.all(color: _tileAccentBorder, width: 1),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: _accentColor,
                  size: SolatifyIconSize.cardIcon,
                ),
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
