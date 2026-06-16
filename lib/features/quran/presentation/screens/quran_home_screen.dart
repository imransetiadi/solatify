import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
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

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
        child: ResponsiveCenter(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header title
                        Row(
                          children: [
                            Icon(Icons.menu_book, color: _textColor, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Al-Qur\'an',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _textColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Baca dan renungkan firman Allah SWT',
                          style: TextStyle(color: _textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 20),

                        // Floating Search Bar
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0.3
                                      : 0.05,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: _textColor),
                            decoration: InputDecoration(
                              hintText: 'Cari nama Surah, arti, atau nomor...',
                              hintStyle: TextStyle(
                                color: _textHint,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF0E4D31),
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
                                borderSide: BorderSide(color: _cardBorderColor),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF0E4D31),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
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
                        indicatorColor: Theme.of(context).colorScheme.tertiary,
                        labelColor: _textColor,
                        unselectedLabelColor: _textSecondary,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
    ),);
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
          blur: 10,
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
                    const Text(
                      'Terakhir Dibaca',
                      style: TextStyle(
                        color: Color(0xFF0E4D31),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Surah ${state.lastReadSurahName}',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ayat ${state.lastReadVerse}',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: _textSecondary.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahListTab(AsyncValue<List<Surah>> searchListAsync) {
    return searchListAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0E4D31)),
      ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString().replaceAll('Exception:', ''),
                textAlign: TextAlign.center,
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E4D31),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
              style: TextStyle(color: _textSecondary, fontSize: 15),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: ResponsiveLayout.pagePadding(context).copyWith(
            top: 12,
            bottom: 80,
          ),
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
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0E4D31)),
      ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ayat yang Anda tandai atau simpan akan muncul di tab ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _textSecondary, fontSize: 14),
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
          padding: ResponsiveLayout.pagePadding(context).copyWith(
            top: 12,
            bottom: 96,
          ),
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
                blur: 10,
                opacity: 0.02,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF241A12).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF241A12).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          surah.number.toString(),
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ayat $verseNum',
                            style: const TextStyle(
                              color: Color(0xFF0E4D31),
                              fontSize: 12,
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
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(quranBookmarksProvider.notifier)
                                .toggleBookmark(surahNum, verseNum);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: _textSecondary.withValues(alpha: 0.5),
                            size: 14,
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
          blur: 10,
          opacity: 0.92,
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F5E9),
                  border: Border.all(color: const Color(0xFFCFE7D5), width: 1),
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: const TextStyle(
                      color: Color(0xFF0E4D31),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Outfit',
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surah.translation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F5E9),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF0E4D31),
                  size: 20,
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
