import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../../../../core/widgets/islamic/islamic_decorations.dart';
import '../providers/duas_provider.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  String _selectedCategory = 'pagi';
  final TextEditingController _searchController = TextEditingController();

  static const _categories = [
    ('pagi', 'Pagi'),
    ('malam', 'Malam'),
    ('sebelum_makan', 'Sebelum Makan'),
    ('sesudah_makan', 'Sesudah Makan'),
    ('sebelum_tidur', 'Sebelum Tidur'),
    ('bangun_tidur', 'Bangun Tidur'),
    ('kamar_mandi', 'Kamar Mandi'),
    ('ketakutan', 'Ketakutan'),
    ('sakit', 'Sakit'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final textColorMuted = isDark ? const Color(0xFFC8B8A8) : const Color(0xFF6E5B4B);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    final duasByCategory = ref.watch(duasByCategoryProvider(_selectedCategory));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text('Doa-Doa Harian', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: Padding(
          padding: ResponsiveLayout.pagePadding(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final (categoryId, categoryLabel) = _categories[index];
                    final isSelected = _selectedCategory == categoryId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(categoryLabel),
                        selected: isSelected,
                        backgroundColor: cardBg,
                        selectedColor: primaryColor.withValues(alpha: 0.3),
                        labelStyle: TextStyle(
                          color: isSelected ? primaryColor : textColorMuted,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = categoryId;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: duasByCategory.length,
                  itemBuilder: (context, index) {
                    final dua = duasByCategory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: cardBg,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        title: Text(
                          dua.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dua.arabicText,
                                  style: TextStyle(fontSize: 24, color: textColor, height: 1.8),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  dua.latinText,
                                  style: TextStyle(fontStyle: FontStyle.italic, color: textColorMuted, fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  dua.meaning,
                                  style: TextStyle(color: textColor, fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sumber: ${dua.source}',
                                  style: TextStyle(color: textColorMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),),
    );
  }
}
