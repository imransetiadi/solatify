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
import 'package:solatify/features/islamic_tips/domain/entities/islamic_tip.dart';
import 'package:solatify/features/islamic_tips/presentation/providers/tips_provider.dart';

class IslamicTipsScreen extends ConsumerStatefulWidget {
  const IslamicTipsScreen({super.key});

  @override
  ConsumerState<IslamicTipsScreen> createState() => _IslamicTipsScreenState();
}

class _IslamicTipsScreenState extends ConsumerState<IslamicTipsScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tipsAsync = ref.watch(tipsProvider);
    final pagePadding = ResponsiveLayout.pagePadding(context);

    return SolatifyScreenScaffold(
      title: l.isEnglish ? 'Daily Islamic Tips' : 'Tips Islami Harian',
      backRoute: AppRoutes.islamicContent,
      padding: const EdgeInsets.only(top: 12),
      child: tipsAsync.when(
        data: (tips) {
          if (tips.isEmpty) {
            return Padding(
              padding: pagePadding,
              child: SolatifyStateView.empty(
                title: l.isEnglish ? 'No tips yet' : 'Belum ada tips',
                description: l.isEnglish
                    ? 'Islamic tips will appear again once data is available.'
                    : 'Tips islami akan tampil kembali saat data tersedia.',
                icon: Icons.lightbulb_outline,
              ),
            );
          }
          final categories = <String>[
            for (final tip in tips)
              if (tip.category.isNotEmpty) tip.category,
          ].toSet().toList(growable: false);
          final visible = _selectedCategory == null
              ? tips
              : tips
                    .where((tip) => tip.category == _selectedCategory)
                    .toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (categories.length > 1)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: pagePadding.left),
                    children: [
                      _FilterChip(
                        label: l.isEnglish ? 'All' : 'Semua',
                        selected: _selectedCategory == null,
                        onSelected: () => _select(null),
                      ),
                      for (final category in categories)
                        _FilterChip(
                          label: l.tr(category),
                          selected: _selectedCategory == category,
                          onSelected: () => _select(
                            _selectedCategory == category ? null : category,
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: pagePadding.copyWith(
                    top: 8,
                    bottom: ResponsiveLayout.bottomSafeGap,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      _TipCard(tip: visible[index]),
                ),
              ),
            ],
          );
        },
        loading: () => Padding(
          padding: pagePadding,
          child: SolatifyStateView.loading(
            title: l.isEnglish ? 'Loading Islamic tips' : 'Memuat tips islami',
            description: l.isEnglish
                ? 'Preparing inspiration for today\'s worship.'
                : 'Menyiapkan inspirasi ibadah hari ini.',
          ),
        ),
        error: (error, stackTrace) {
          debugPrint('Islamic tips failed to load: $error');
          return Padding(
            padding: pagePadding,
            child: SolatifyStateView.error(
              title: l.tr('Gagal memuat tips islami.'),
              description: l.isEnglish
                  ? 'Please try again.'
                  : 'Silakan coba lagi.',
              actionLabel: l.isEnglish ? 'Try again' : 'Coba lagi',
              onAction: () => ref.invalidate(tipsProvider),
            ),
          );
        },
      ),
    );
  }

  void _select(String? category) {
    SolatifyHaptics.selection();
    setState(() => _selectedCategory = category);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final IslamicTip tip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);

    return GlassContainer(
      margin: const EdgeInsets.symmetric(vertical: 6),
      borderRadius: SolatifyRadius.lg,
      padding: SolatifySpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SolatifyIconSize.cardBox,
                height: SolatifyIconSize.cardBox,
                decoration: BoxDecoration(
                  color: SolatifyColors.accentSoft(context),
                  borderRadius: SolatifyRadius.icon,
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: accent,
                  size: SolatifyIconSize.cardIcon,
                ),
              ),
              const SizedBox(width: SolatifySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tip.category.isNotEmpty)
                      Text(
                        l.tr(tip.category).toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: SolatifyType.eyebrow,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Semantics(
                      header: true,
                      child: Text(
                        l.tr(tip.title),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SolatifyType.sectionTitle,
                          color: AppTheme.readableAccent(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Text(
            l.tr(tip.content),
            style: TextStyle(
              fontSize: 15,
              color: SolatifyColors.text(context),
              height: 1.55,
            ),
          ),
          if (tip.reference.isNotEmpty) ...[
            const SizedBox(height: SolatifySpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    size: SolatifyIconSize.inline,
                    color: muted,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tip.reference,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: muted,
                      fontSize: SolatifyType.caption,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
