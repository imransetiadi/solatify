import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/islamic_tips/presentation/providers/tips_provider.dart';

class IslamicTipsScreen extends ConsumerWidget {
  const IslamicTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final redAccent = theme.colorScheme.tertiary;
    final primaryColor = isDark
        ? const Color(0xFFC78A4C)
        : const Color(0xFF0E4D31);
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    final tipsAsync = ref.watch(tipsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/islamic-content'),
        ),
        title: Text(
          'Tips Islami Harian',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: Padding(
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              top: kToolbarHeight + MediaQuery.paddingOf(context).top + 8,
            ),
            child: tipsAsync.when(
              data: (tips) {
                if (tips.isEmpty) {
                  return const Center(child: Text('Tidak ada tips saat ini.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: cardBg,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: redAccent.withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: ExpansionTile(
                        iconColor: redAccent,
                        collapsedIconColor: redAccent,
                        leading: Icon(
                          Icons.lightbulb_outline,
                          color: redAccent,
                        ),
                        tilePadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        title: Text(
                          tip.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ref: ${tip.reference}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  const Center(child: Text('Gagal memuat tips islami.')),
            ),
          ),
        ),
      ),
    );
  }
}
