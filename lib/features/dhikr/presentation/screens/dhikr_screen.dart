import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/islamic/islamic_decorations.dart';
import '../providers/dhikr_provider.dart';

class DhikrScreen extends ConsumerWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6),
          title: Text('Dzikir Pagi & Petang', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
        body: Stack(
          children: [
            Positioned.fill(child: IslamicGeometricPattern(opacity: 0.03, color: primaryColor)),
            const TabBarView(
              children: [
                _DhikrListView(isMorning: true),
                _DhikrListView(isMorning: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DhikrListView extends ConsumerWidget {
  final bool isMorning;
  const _DhikrListView({required this.isMorning});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dhikrList = ref.watch(isMorning ? morningDhikrProvider : eveningDhikrProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final redAccent = Theme.of(context).colorScheme.tertiary;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    return ResponsiveCenter(
      child: ListView.builder(
        padding: ResponsiveLayout.pagePadding(context).copyWith(bottom: 96),
        itemCount: dhikrList.length,
        itemBuilder: (context, index) {
          final dhikr = dhikrList[index];
          return Card(
            color: cardBg,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: redAccent.withValues(alpha: 0.30), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dhikr.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                        ),
                      ),
                      if (dhikr.count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Dibaca ${dhikr.count}x',
                            style: TextStyle(color: redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dhikr.arabicText,
                    style: const TextStyle(fontSize: 24, height: 1.8, fontFamily: 'Kufi'),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dhikr.latinText,
                    style: TextStyle(fontStyle: FontStyle.italic, color: textColor.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dhikr.meaning,
                    style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
                  ),
                  if (dhikr.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        dhikr.note,
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
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
