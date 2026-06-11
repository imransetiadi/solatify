import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../domain/models/dua_model.dart';
import '../providers/duas_provider.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Dua> _filteredDuas = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDuas);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDuas);
    _searchController.dispose();
    super.dispose();
  }

  void _filterDuas() {
    final query = _searchController.text.toLowerCase();
    final allDuas = ref.read(duasProvider);
    setState(() {
      _filteredDuas = allDuas.where((dua) {
        return dua.title.toLowerCase().contains(query) ||
            dua.arabicText.toLowerCase().contains(query) ||
            dua.meaning.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allDuas = ref.watch(duasProvider);

    // Initialize filtered list once after allDuas is available
    if (_filteredDuas.isEmpty && _searchController.text.isEmpty) {
      _filteredDuas = allDuas;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final textColorMuted = isDark ? const Color(0xFFC8B8A8) : const Color(0xFF6E5B4B);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black12;
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6),
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
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Cari doa...',
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
                  child: ListView.builder(
                    itemCount: _filteredDuas.length,
                    padding: ResponsiveLayout.pagePadding(context).copyWith(top: 0, bottom: 96),
                    itemBuilder: (context, index) {
                      final dua = _filteredDuas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DuaCard(
                          dua: dua,
                          surfaceColor: cardBg,
                          primaryColor: primaryColor,
                          textColor: textColor,
                          mutedColor: textColorMuted,
                        ),
                      );
                    },
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

class _DuaCard extends StatefulWidget {
  const _DuaCard({
    required this.dua,
    required this.surfaceColor,
    required this.primaryColor,
    required this.textColor,
    required this.mutedColor,
  });

  final Dua dua;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textColor;
  final Color mutedColor;

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.surfaceColor,
      elevation: 1,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.dua.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.primaryColor,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Text(
                  widget.dua.arabicText,
                  style: TextStyle(
                    fontSize: 22,
                    color: widget.textColor,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 14),
                Text(
                  widget.dua.latinText,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: widget.mutedColor,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.dua.meaning,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sumber: ${widget.dua.source}',
                  style: TextStyle(
                    color: widget.mutedColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
