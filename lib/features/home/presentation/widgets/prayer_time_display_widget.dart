import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import '../providers/improved_countdown_provider.dart';

class PrayerTimeDisplayWidget extends ConsumerWidget {
  const PrayerTimeDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(improvedCountdownProvider);
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.readableAccent(context);

    if (!countdown.isAccurate) {
      return _buildLoadingState(isDark);
    }

    return Column(
      children: [
        _buildCountdownCard(context, countdown, isDark, primary, l),
        const SizedBox(height: 12),
        _buildPrayerInfoText(countdown, l),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    CountdownState countdown,
    bool isDark,
    Color primary,
    AppLocalizations l,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            l.prayerTimeLabel(l.prayerName(countdown.nextPrayerName)),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFC8B8A8) : const Color(0xFF5D4E47),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            countdown.formattedTime,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: primary,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatNextPrayerTime(countdown.nextPrayerTime),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFFC8B8A8) : const Color(0xFF5D4E47),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerInfoText(CountdownState countdown, AppLocalizations l) {
    return Text(
      l.activePrayerInProgress(l.prayerName(countdown.activePrayerName)),
      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    );
  }

  String _formatNextPrayerTime(DateTime time) {
    return DateFormat('HH:mm', 'id_ID').format(time);
  }
}
