import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/dhikr/presentation/providers/dhikr_provider.dart';

class DhikrScreen extends ConsumerWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final primaryColor = isDark
        ? const Color(0xFFC78A4C)
        : const Color(0xFF0E4D31);
    final appBarColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: isDark ? 0.96 : 0.94);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: textColor,
            onPressed: () => context.go('/islamic-content'),
          ),
          title: Text(
            l.morningEveningDhikr,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: textColor.withValues(alpha: 0.6),
            indicatorColor: primaryColor,
            tabs: [
              Tab(text: l.morningDhikr),
              Tab(text: l.eveningDhikr),
            ],
          ),
        ),
        body: const IslamicBackground(
          child: TabBarView(
            children: <Widget>[
              _DhikrListView(isMorning: true),
              _DhikrListView(isMorning: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _DhikrListView extends ConsumerWidget {
  const _DhikrListView({required this.isMorning});
  final bool isMorning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhikrList = ref.watch(
      isMorning ? morningDhikrProvider : eveningDhikrProvider,
    );
    final theme = Theme.of(context);
    final primaryColor = AppTheme.readableAccent(context);
    final textColor = theme.colorScheme.onSurface;
    final secondaryText = theme.brightness == Brightness.dark
        ? AppTheme.darkModeTextSecondary
        : AppTheme.lightModeTextSecondary;
    final surfaceTint = theme.colorScheme.surfaceContainerHighest;

    return ResponsiveCenter(
      child: ListView.builder(
        padding: ResponsiveLayout.pagePadding(
          context,
        ).copyWith(top: 16, bottom: 96),
        itemCount: dhikrList.length,
        itemBuilder: (context, index) {
          final dhikr = dhikrList[index];
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 14),
            borderRadius: 16,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        dhikr.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.25,
                          color: textColor,
                        ),
                      ),
                      if (dhikr.count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Dibaca ${dhikr.count}x',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    key: const Key('dhikr_arabic_text_block'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      dhikr.arabicText,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      softWrap: true,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 23,
                        height: 1.9,
                        fontFamily: 'Kufi',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    dhikr.latinText,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: secondaryText,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dhikr.meaning,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (dhikr.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceTint.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        dhikr.note,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
