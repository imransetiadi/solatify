import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/localization/islamic_content_localizer.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_screen_scaffold.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/duas/domain/entities/dua.dart';
import 'package:solatify/features/duas/presentation/providers/duas_provider.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final next = _searchController.text.trim().toLowerCase();
    if (next == _searchQuery) return;
    setState(() => _searchQuery = next);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _selectedCategory = null);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _matches(Dua dua, AppLocalizations l) {
    if (_selectedCategory != null && dua.category != _selectedCategory) {
      return false;
    }
    if (_searchQuery.isEmpty) return true;
    final haystack = [
      dua.title,
      l.tr(dua.title),
      dua.arabicText,
      dua.latinText,
      dua.meaning,
      l.tr(dua.meaning),
    ].join(' ').toLowerCase();
    return haystack.contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final duasAsync = ref.watch(duasProvider);
    final pagePadding = ResponsiveLayout.pagePadding(context);

    return SolatifyScreenScaffold(
      title: l.isEnglish ? 'Daily Duas' : 'Doa-Doa Harian',
      backRoute: AppRoutes.islamicContent,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pagePadding.left),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              onTapOutside: (_) => _searchFocusNode.unfocus(),
              style: TextStyle(color: SolatifyColors.text(context)),
              decoration: InputDecoration(
                hintText: l.isEnglish ? 'Search duas...' : 'Cari doa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.isEnglish
                            ? 'Clear search'
                            : 'Bersihkan pencarian',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _searchFocusNode.requestFocus();
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Expanded(
            child: duasAsync.when(
              data: (allDuas) {
                final categories = <String>[
                  for (final dua in allDuas)
                    if (dua.category.isNotEmpty) dua.category,
                ].toSet().toList(growable: false);
                final filteredList = allDuas
                    .where((dua) => _matches(dua, l))
                    .toList(growable: false);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (categories.length > 1)
                      _CategoryChips(
                        categories: categories,
                        selected: _selectedCategory,
                        horizontalPadding: pagePadding.left,
                        onSelected: (category) {
                          SolatifyHaptics.selection();
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    const SizedBox(height: SolatifySpacing.xs),
                    Expanded(
                      child: filteredList.isEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: pagePadding.left,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: SolatifyStateView.empty(
                                  title: l.isEnglish
                                      ? 'No duas found'
                                      : 'Doa tidak ditemukan',
                                  description: l.isEnglish
                                      ? 'Try another keyword or category.'
                                      : 'Coba kata kunci atau kategori lain.',
                                  icon: Icons.search_off_rounded,
                                  actionLabel: l.isEnglish
                                      ? 'Reset filters'
                                      : 'Reset filter',
                                  actionIcon: Icons.filter_alt_off_outlined,
                                  onAction: _clearFilters,
                                  compact: true,
                                ),
                              ),
                            )
                          : ListView.builder(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: filteredList.length,
                              padding: pagePadding.copyWith(
                                top: 4,
                                bottom: ResponsiveLayout.bottomSafeGap,
                              ),
                              itemBuilder: (context, index) {
                                final dua = filteredList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _DuaCard(
                                    key: ObjectKey(dua),
                                    dua: dua,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => SolatifyStateView.loading(
                title: l.isEnglish ? 'Loading duas' : 'Memuat doa',
                description: l.isEnglish
                    ? 'Preparing daily supplications.'
                    : 'Menyiapkan kumpulan doa harian.',
              ),
              error: (error, stackTrace) {
                debugPrint('Duas failed to load: $error');
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding.left),
                  child: SolatifyStateView.error(
                    title: l.tr('Gagal memuat data doa'),
                    description: l.isEnglish
                        ? 'Please try again.'
                        : 'Silakan coba lagi.',
                    actionLabel: l.isEnglish ? 'Try again' : 'Coba lagi',
                    onAction: () => ref.invalidate(duasProvider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(AppLocalizations l, String category) {
  if (l.isEnglish) return l.tr(category);
  final words = category.replaceAll('_', ' ').trim();
  if (words.isEmpty) return category;
  return words[0].toUpperCase() + words.substring(1);
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.horizontalPadding,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final double horizontalPadding;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        children: [
          _chip(
            context,
            label: l.isEnglish ? 'All' : 'Semua',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in categories)
            _chip(
              context,
              label: _categoryLabel(l, category),
              isSelected: selected == category,
              onTap: () => onSelected(selected == category ? null : category),
            ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onTap(),
        ),
      ),
    );
  }
}

class _DuaCard extends StatefulWidget {
  const _DuaCard({super.key, required this.dua});

  final Dua dua;

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = AppTheme.readableAccent(context);
    final textColor = SolatifyColors.text(context);
    final muted = SolatifyColors.muted(context);
    final dua = widget.dua;
    final title = l.tr(dua.title);

    return Semantics(
      expanded: _isExpanded,
      child: GlassContainer(
        borderRadius: SolatifyRadius.lg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        borderColor: _isExpanded ? SolatifyColors.borderStrong(context) : null,
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedSize(
          duration: SolatifyMotion.of(context, SolatifyMotion.medium),
          curve: SolatifyMotion.curve,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SolatifyTapTarget.min - 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SolatifyType.sectionTitle,
                              color: accent,
                            ),
                          ),
                          if (!_isExpanded) ...[
                            const SizedBox(height: 2),
                            Text(
                              l.tr(dua.meaning),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: muted,
                                fontSize: SolatifyType.caption,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: SolatifyMotion.of(
                        context,
                        SolatifyMotion.medium,
                      ),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: SolatifyColors.accent(context),
                        semanticLabel: _isExpanded
                            ? (l.isEnglish ? 'Collapse' : 'Tutup')
                            : (l.isEnglish ? 'Expand' : 'Buka'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SolatifyColors.accentSoft(context),
                    borderRadius: SolatifyRadius.compactCard,
                    border: Border.all(color: SolatifyColors.border(context)),
                  ),
                  child: Text(
                    dua.arabicText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 24,
                      color: textColor,
                      height: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dua.latinText,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: muted,
                    fontSize: SolatifyType.body,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.tr(dua.meaning),
                  style: TextStyle(
                    color: textColor,
                    fontSize: SolatifyType.body,
                    height: 1.6,
                  ),
                ),
                if (dua.source.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    l.isEnglish
                        ? 'Source: ${dua.source}'
                        : 'Sumber: ${dua.source}',
                    style: TextStyle(
                      color: muted,
                      fontSize: SolatifyType.caption,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
