import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../islamic_tips/presentation/providers/tips_provider.dart';

class IslamicContentScreen extends ConsumerWidget {
  const IslamicContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    final randomTip = ref.watch(randomTipProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6),
        foregroundColor: textColor,
        elevation: 0,
        title: Text('Konten Islami', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IslamicGeometricPattern(
              color: primaryColor,
              opacity: isDark ? 0.03 : 0.05,
            ),
          ),
          ResponsiveCenter(
            child: Padding(
              padding: ResponsiveLayout.pagePadding(context),
              child: ListView(
                children: [
                  const IslamicHeaderDecoration(
                    title: 'Jelajahi Spiritual',
                    subtitle: 'Ilmu, doa, dan amalan harian',
                  ),
                  // Random Daily Tip Section
                  ...[
                    Text(
                      '✨ Tip Harian',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 12),
                Card(
                  color: cardBg,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          randomTip.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip.content,
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ref: ${randomTip.reference}',
                          style: TextStyle(fontStyle: FontStyle.italic, color: textColor, fontSize: 12),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () => context.go('/islamic-content/tips'),
                            child: Text('Lihat Semua Tips', style: TextStyle(color: primaryColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

                  // Navigation to other Islamic Content Features
                  Text(
                    '📚 Eksplorasi Lainnya',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  _buildContentTile(
                    context, 'Asmaul Husna', Icons.font_download_outlined, '/islamic-content/asmaul-husna', cardBg, textColor, primaryColor,
                  ),
                  _buildContentTile(
                    context, 'Doa-Doa Harian', Icons.menu_book_outlined, '/islamic-content/duas', cardBg, textColor, primaryColor,
                  ),
              _buildContentTile(
                context, 'Kalender Hijriah', Icons.calendar_month_outlined, '/islamic-content/hijri-calendar', cardBg, textColor, primaryColor,
              ),
              _buildContentTile(
                context, 'Dzikir Pagi & Petang', Icons.wb_twilight, '/islamic-content/dhikr', cardBg, textColor, primaryColor,
              ),
            ],
          ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTile(
    BuildContext context, String title, IconData icon, String path,
    Color cardBg, Color textColor, Color primaryColor,
  ) {
    return Card(
      color: cardBg,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
        onTap: () => context.go(path),
      ),
    );
  }
}
