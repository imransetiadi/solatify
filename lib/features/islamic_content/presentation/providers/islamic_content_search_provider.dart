import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/features/asmaul_husna/presentation/providers/asmaul_husna_provider.dart';
import 'package:solatify/features/dhikr/presentation/providers/dhikr_provider.dart';
import 'package:solatify/features/duas/presentation/providers/duas_provider.dart';
import 'package:solatify/features/islamic_tips/presentation/providers/tips_provider.dart';
import 'package:solatify/features/prayer_guide/presentation/providers/prayer_guide_provider.dart';

class IslamicContentSearchItem {
  const IslamicContentSearchItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    this.keywords = const [],
  });

  final String category;
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final List<String> keywords;

  String get searchableText =>
      [category, title, subtitle, ...keywords].join(' ');
}

final islamicContentSearchQueryProvider = StateProvider<String>((ref) => '');

final islamicContentSearchIndexProvider =
    FutureProvider<List<IslamicContentSearchItem>>((ref) async {
      final duas = await ref.watch(duasProvider.future);
      final tips = await ref.watch(tipsProvider.future);
      final asmaulHusna = await ref.watch(asmaulHusnaProvider.future);
      final morningDhikr = ref.watch(morningDhikrProvider);
      final eveningDhikr = ref.watch(eveningDhikrProvider);
      final prayerSummaries = ref.watch(prayerGuideSummariesProvider);
      final prayerSteps = ref.watch(prayerGuideStepsProvider);
      final postPrayerDhikr = ref.watch(postPrayerDhikrProvider);

      final items = <IslamicContentSearchItem>[
        for (final dua in duas)
          IslamicContentSearchItem(
            category: 'Doa Harian',
            title: dua.title,
            subtitle: dua.meaning,
            route: AppRoutes.duas,
            icon: Icons.volunteer_activism_outlined,
            keywords: [dua.category, dua.latinText, dua.source],
          ),
        for (final dhikr in morningDhikr)
          IslamicContentSearchItem(
            category: 'Dzikir Pagi',
            title: dhikr.title,
            subtitle: dhikr.meaning,
            route: AppRoutes.dhikr,
            icon: Icons.wb_twilight_outlined,
            keywords: [dhikr.latinText, dhikr.note, 'dzikir pagi'],
          ),
        for (final dhikr in eveningDhikr)
          IslamicContentSearchItem(
            category: 'Dzikir Petang',
            title: dhikr.title,
            subtitle: dhikr.meaning,
            route: AppRoutes.dhikr,
            icon: Icons.nightlight_round,
            keywords: [dhikr.latinText, dhikr.note, 'dzikir petang'],
          ),
        for (final name in asmaulHusna)
          IslamicContentSearchItem(
            category: 'Asmaul Husna',
            title: name.latinName,
            subtitle: name.meaning,
            route: AppRoutes.asmaulHusna,
            icon: Icons.font_download_outlined,
            keywords: [name.arabicName, name.description],
          ),
        for (final tip in tips)
          IslamicContentSearchItem(
            category: 'Tips Islami',
            title: tip.title,
            subtitle: tip.content,
            route: AppRoutes.islamicTips,
            icon: Icons.lightbulb_outline,
            keywords: [tip.category, tip.reference],
          ),
        for (final summary in prayerSummaries)
          IslamicContentSearchItem(
            category: 'Tuntunan Salat',
            title: summary.title,
            subtitle: summary.items.join(' • '),
            route: AppRoutes.prayerGuide,
            icon: Icons.menu_book_outlined,
            keywords: ['panduan salat', 'tata cara salat'],
          ),
        for (final step in prayerSteps)
          IslamicContentSearchItem(
            category: 'Tuntunan Salat',
            title: step.title,
            subtitle: step.description,
            route: AppRoutes.prayerGuide,
            icon: Icons.menu_book_outlined,
            keywords: [step.latinText, step.meaning, step.note],
          ),
        for (final dhikr in postPrayerDhikr)
          IslamicContentSearchItem(
            category: 'Dzikir Setelah Salat',
            title: dhikr.title,
            subtitle: dhikr.meaning,
            route: AppRoutes.prayerGuide,
            icon: Icons.menu_book_outlined,
            keywords: [dhikr.latinText, 'dzikir setelah salat'],
          ),
      ];

      return items;
    });

final islamicContentSearchResultsProvider =
    Provider<AsyncValue<List<IslamicContentSearchItem>>>((ref) {
      final query = ref.watch(islamicContentSearchQueryProvider);
      final index = ref.watch(islamicContentSearchIndexProvider);

      return index.whenData((items) => searchIslamicContentItems(items, query));
    });

List<IslamicContentSearchItem> searchIslamicContentItems(
  List<IslamicContentSearchItem> items,
  String query,
) {
  final normalizedQuery = normalizeIslamicContentSearchText(query);
  if (normalizedQuery.isEmpty) return const [];

  return items
      .where((item) {
        final normalizedText = normalizeIslamicContentSearchText(
          item.searchableText,
        );
        return normalizedQuery
            .split(' ')
            .where((part) => part.isNotEmpty)
            .every(normalizedText.contains);
      })
      .toList(growable: false);
}

String normalizeIslamicContentSearchText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), ' ')
      .trim();
}
