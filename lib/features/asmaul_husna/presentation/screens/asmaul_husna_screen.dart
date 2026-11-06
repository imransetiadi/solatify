import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_screen_scaffold.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/asmaul_husna/presentation/providers/asmaul_husna_provider.dart';

class AsmaulHusnaScreen extends ConsumerStatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  ConsumerState<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends ConsumerState<AsmaulHusnaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

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
    final asmaulHusnaAsync = ref.watch(asmaulHusnaProvider);
    final muted = SolatifyColors.muted(context);

    return SolatifyScreenScaffold(
      title: 'Asmaul Husna',
      backRoute: AppRoutes.islamicContent,
      padding: ResponsiveLayout.pagePadding(context).copyWith(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onTapOutside: (_) => _searchFocusNode.unfocus(),
            style: TextStyle(color: SolatifyColors.text(context)),
            decoration: InputDecoration(
              hintText: l.isEnglish
                  ? 'Search names or meanings...'
                  : 'Cari nama atau makna...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l.isEnglish
                          ? 'Clear search'
                          : 'Bersihkan pencarian',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Expanded(
            child: asmaulHusnaAsync.when(
              data: (allAsmaulHusna) {
                final filteredList = allAsmaulHusna.where((name) {
                  return name.latinName.toLowerCase().contains(_searchQuery) ||
                      name.meaning.toLowerCase().contains(_searchQuery) ||
                      name.arabicName.contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty) {
                  return SolatifyStateView.empty(
                    title: l.isEnglish ? 'No results' : 'Tidak ada hasil',
                    description: l.isEnglish
                        ? 'Try another name or meaning of Asmaul Husna.'
                        : 'Coba cari nama atau makna Asmaul Husna lain.',
                    icon: Icons.search_off_rounded,
                    actionLabel: l.isEnglish
                        ? 'Clear search'
                        : 'Hapus pencarian',
                    actionIcon: Icons.close_rounded,
                    onAction: _clearSearch,
                    compact: true,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _searchQuery.isEmpty
                            ? (l.isEnglish
                                  ? '${allAsmaulHusna.length} names · tap to read the explanation'
                                  : '${allAsmaulHusna.length} nama · ketuk untuk membaca penjelasan')
                            : (l.isEnglish
                                  ? '${filteredList.length} names found'
                                  : '${filteredList.length} nama ditemukan'),
                        style: TextStyle(
                          color: muted,
                          fontSize: SolatifyType.caption,
                        ),
                      ),
                    ),
                    const SizedBox(height: SolatifySpacing.xs),
                    Expanded(
                      child: ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.only(
                          bottom: ResponsiveLayout.bottomSafeGap,
                          top: 4,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final name = filteredList[index];
                          return _AsmaulHusnaCard(
                            number: name.number,
                            latinName: name.latinName,
                            arabicName: name.arabicName,
                            meaning: name.meaning,
                            description: name.description,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => SolatifyStateView.loading(
                title: l.isEnglish
                    ? 'Loading Asmaul Husna'
                    : 'Memuat Asmaul Husna',
                description: l.isEnglish
                    ? 'Preparing the 99 beautiful names of Allah.'
                    : 'Menyiapkan 99 nama Allah yang indah.',
              ),
              error: (error, stackTrace) {
                debugPrint('Asmaul Husna failed to load: $error');
                return SolatifyStateView.error(
                  title: l.isEnglish
                      ? 'Failed to load Asmaul Husna'
                      : 'Gagal memuat Asmaul Husna',
                  description: l.isEnglish
                      ? 'Please try again.'
                      : 'Silakan coba lagi.',
                  actionLabel: l.isEnglish ? 'Try again' : 'Coba lagi',
                  onAction: () => ref.invalidate(asmaulHusnaProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AsmaulHusnaCard extends StatelessWidget {
  const _AsmaulHusnaCard({
    required this.number,
    required this.latinName,
    required this.arabicName,
    required this.meaning,
    required this.description,
  });

  final int number;
  final String latinName;
  final String arabicName;
  final String meaning;
  final String description;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.readableAccent(context);
    final textColor = SolatifyColors.text(context);
    final muted = SolatifyColors.muted(context);

    return GlassContainer(
      margin: const EdgeInsets.symmetric(vertical: 6),
      borderRadius: SolatifyRadius.lg,
      padding: EdgeInsets.zero,
      child: Theme(
        // Remove ExpansionTile's default divider lines inside the card.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: SolatifyColors.accent(context),
          collapsedIconColor: SolatifyColors.accent(context),
          tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                arabicName,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 28, height: 1.6, color: textColor),
              ),
              const SizedBox(height: 2),
              Text(
                '$number. $latinName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meaning,
                style: TextStyle(
                  color: muted,
                  fontSize: SolatifyType.body,
                  height: 1.4,
                ),
              ),
            ],
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SolatifyColors.raisedSurface(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Text(
                description,
                style: TextStyle(
                  color: textColor,
                  fontSize: SolatifyType.body,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
