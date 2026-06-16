import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/tracker/presentation/providers/tracker_provider.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerAsync = ref.watch(trackerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final mutedColor = isDark
        ? const Color(0xFFE0D4C4)
        : const Color(0xFFAFA19A);
    final brightGreen = isDark
        ? const Color(0xFF4CAF50)
        : const Color(0xFF0E4D31);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Tracker Ibadah',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveLayout.pagePadding(
                context,
              ).copyWith(top: 24, bottom: 96),
              child: trackerAsync.when(
                data: (log) => GlassContainer(
                  blur: 15,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ceklis Ibadah Hari Ini',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tandai salat yang sudah ditunaikan hari ini.',
                        style: TextStyle(color: mutedColor, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: log.prayers.keys.map((prayer) {
                          final isDone = log.prayers[prayer] ?? false;
                          return InkWell(
                            onTap: () => ref
                                .read(trackerProvider.notifier)
                                .togglePrayer(prayer),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? brightGreen.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDone
                                      ? brightGreen
                                      : mutedColor.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 16,
                                    color: isDone ? brightGreen : mutedColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    prayer[0].toUpperCase() +
                                        prayer.substring(1),
                                    style: TextStyle(
                                      color: isDone ? brightGreen : textColor,
                                      fontWeight: isDone
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => GlassContainer(
                  blur: 15,
                  opacity: 0.05,
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Tracker ibadah belum dapat dimuat.',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
