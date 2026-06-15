import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../providers/asmaul_husna_provider.dart';

class AsmaulHusnaScreen extends ConsumerStatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  ConsumerState<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends ConsumerState<AsmaulHusnaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asmaulHusnaAsync = ref.watch(asmaulHusnaProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final redAccent = theme.colorScheme.tertiary;
    final primaryColor = isDark
        ? const Color(0xFFC78A4C)
        : const Color(0xFF0E4D31);
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final textColorMuted = isDark
        ? const Color(0xFFC8B8A8)
        : const Color(0xFF5D4E47);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black12;
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Asmaul Husna',
          style: TextStyle(fontWeight: FontWeight.bold),
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
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari nama Allah...',
                    hintStyle: TextStyle(color: textColorMuted),
                    prefixIcon: Icon(Icons.search, color: textColorMuted),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: cardBg,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: asmaulHusnaAsync.when(
                    data: (allAsmaulHusna) {
                      final filteredList = allAsmaulHusna.where((name) {
                        return name.latinName.toLowerCase().contains(_searchQuery) ||
                            name.meaning.toLowerCase().contains(_searchQuery) ||
                            name.arabicName.contains(_searchQuery);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada hasil ditemukan.',
                            style: TextStyle(color: textColorMuted),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final name = filteredList[index];
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
                              tilePadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              title: Text(
                                '${name.number}. ${name.latinName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                name.arabicName,
                                style: TextStyle(
                                  fontFamily: 'Kufi',
                                  fontSize: 22,
                                  color: textColor,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.meaning,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: textColorMuted,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        name.description,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
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
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Gagal memuat data Asmaul Husna',
                        style: TextStyle(color: textColorMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
