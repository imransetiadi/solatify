import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../../../../core/widgets/islamic/islamic_decorations.dart';
import '../providers/hijri_calendar_provider.dart';

class HijriCalendarScreen extends ConsumerWidget {
  const HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final redAccent = theme.colorScheme.tertiary;
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final textColorMuted = isDark ? const Color(0xFFC8B8A8) : const Color(0xFF5D4E47);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    final events = ref.watch(upcomingHijriEventsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text('Kalender Hijriah', style: TextStyle(fontWeight: FontWeight.bold)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, size: 20, color: redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Hari Raya & Event Islam 2026',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(event.gregorianDate);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: redAccent.withValues(alpha: 0.30), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    event.nameId,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ),
                                Text(
                                  event.nameAr,
                                  style: TextStyle(fontSize: 18, color: primaryColor, fontFamily: 'Kufi'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: redAccent),
                                const SizedBox(width: 4),
                                Text(
                                  dateStr,
                                  style: TextStyle(fontSize: 14, color: textColorMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description,
                              style: TextStyle(fontSize: 14, color: textColor, height: 1.5),
                            ),
                          ],
                        ),
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
