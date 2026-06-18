import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/widgets/solatify_screen_scaffold.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
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
        : const Color(0xFFC94B3D);
    final textColor = isDark
        ? const Color(0xFFFFF7ED)
        : const Color(0xFF241A12);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;
    final tipsAsync = ref.watch(tipsProvider);

    return SolatifyScreenScaffold(
      title: 'Tips Islami Harian',
      backRoute: AppRoutes.islamicContent,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: tipsAsync.when(
        data: (tips) {
          if (tips.isEmpty) {
            return const SolatifyStateView.empty(
              title: 'Belum ada tips',
              description:
                  'Tips islami akan tampil kembali saat data tersedia.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: cardBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: redAccent.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: ExpansionTile(
                  iconColor: redAccent,
                  collapsedIconColor: redAccent,
                  leading: Icon(Icons.lightbulb_outline, color: redAccent),
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
        loading: () => const SolatifyStateView.loading(
          title: 'Memuat tips islami',
          description: 'Menyiapkan inspirasi ibadah hari ini.',
        ),
        error: (error, stackTrace) => const SolatifyStateView.error(
          title: 'Gagal memuat tips islami',
          description: 'Silakan coba lagi dari halaman Konten Islami.',
        ),
      ),
    );
  }
}
