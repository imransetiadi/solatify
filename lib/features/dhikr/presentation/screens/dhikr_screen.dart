import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/dhikr/presentation/providers/dhikr_provider.dart';

class DhikrScreen extends ConsumerWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final primaryColor = isDark
        ? const Color(0xFFC78A4C)
        : const Color(0xFF0E4D31);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Dzikir Pagi & Petang',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: textColor.withValues(alpha: 0.6),
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: 'Dzikir Pagi'),
              Tab(text: 'Dzikir Petang'),
            ],
          ),
        ),
        extendBodyBehindAppBar: true,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final redAccent = theme.colorScheme.tertiary;
    final textColor = theme.colorScheme.onSurface;
    final secondaryText = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFF6A5B51);

    return ResponsiveCenter(
      child: ListView.builder(
        padding: ResponsiveLayout.pagePadding(context).copyWith(
          top: kToolbarHeight + MediaQuery.paddingOf(context).top + 48,
          bottom: 96,
        ),
        itemCount: dhikrList.length,
        itemBuilder: (context, index) {
          final dhikr = dhikrList[index];
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            borderRadius: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dhikr.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (dhikr.count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Dibaca ${dhikr.count}x',
                            style: TextStyle(
                              color: redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dhikr.arabicText,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.8,
                      fontFamily: 'Kufi',
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dhikr.latinText,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        dhikr.note,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
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
