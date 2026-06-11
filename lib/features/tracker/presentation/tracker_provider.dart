import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';

class TrackerState {
  final Map<String, String> todayStatus; // Map of 'subuh' -> 'completed', etc.
  final int currentStreak;
  final Map<String, int> weeklyStats; // Map of 'completed' -> count, etc.

  TrackerState({
    required this.todayStatus,
    required this.currentStreak,
    required this.weeklyStats,
  });

  TrackerState copyWith({
    Map<String, String>? todayStatus,
    int? currentStreak,
    Map<String, int>? weeklyStats,
  }) {
    return TrackerState(
      todayStatus: todayStatus ?? this.todayStatus,
      currentStreak: currentStreak ?? this.currentStreak,
      weeklyStats: weeklyStats ?? this.weeklyStats,
    );
  }
}

class TrackerNotifier extends StateNotifier<TrackerState> {
  TrackerNotifier() : super(_initialState());

  static TrackerState _initialState() {
    try {
      final todayStr = _getFormatDate(DateTime.now());
      final todayStatus = <String, String>{};

      for (var key in ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya']) {
        final entry = HiveService.getTrackerEntry('${todayStr}_$key');
        todayStatus[key] = entry?['status'] as String? ?? 'unmarked';
      }

      final streak = _calculateStreakOffline();
      final stats = _calculateWeeklyStatsOffline();

      return TrackerState(
        todayStatus: todayStatus,
        currentStreak: streak,
        weeklyStats: stats,
      );
    } catch (e) {
      // Safe defaults if Hive isn't ready or data is corrupt.
      return TrackerState(
        todayStatus: {
          'subuh': 'unmarked',
          'dzuhur': 'unmarked',
          'ashar': 'unmarked',
          'magrib': 'unmarked',
          'isya': 'unmarked',
        },
        currentStreak: 0,
        weeklyStats: {
          'completed': 0,
          'delayed': 0,
          'missed': 0,
          'unmarked': 0,
        },
      );
    }
  }

  static String _getFormatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> updatePrayerStatus(String prayerKey, String status) async {
    final todayStr = _getFormatDate(DateTime.now());
    final dbKey = '${todayStr}_$prayerKey';

    if (status == 'unmarked') {
      final box = HiveService.tryGetBox(HiveService.trackerBoxName);
      if (box != null) {
        await box.delete(dbKey);
      }
    } else {
      await HiveService.saveTrackerEntry(dbKey, status);
    }

    // Recalculate
    final updatedToday = Map<String, String>.from(state.todayStatus);
    updatedToday[prayerKey] = status;

    final streak = _calculateStreakOffline();
    final stats = _calculateWeeklyStatsOffline();

    state = TrackerState(
      todayStatus: updatedToday,
      currentStreak: streak,
      weeklyStats: stats,
    );
  }

  static int _calculateStreakOffline() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    // Check if today is fully completed or yesterday was (so active streak continues)
    bool checkToday = _isDayFullyCompleted(_getFormatDate(checkDate));
    bool checkYesterday = _isDayFullyCompleted(
      _getFormatDate(checkDate.subtract(const Duration(days: 1))),
    );

    if (!checkToday && !checkYesterday) {
      return 0; // Streak broken if neither today nor yesterday is complete
    }

    // Start checking backward
    if (checkToday) {
      streak = 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateKey = _getFormatDate(checkDate);
      if (_isDayFullyCompleted(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static bool _isDayFullyCompleted(String dateKey) {
    for (var key in ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya']) {
      final entry = HiveService.getTrackerEntry('${dateKey}_$key');
      final status = entry?['status'] as String? ?? 'unmarked';
      if (status != 'completed' && status != 'delayed') {
        return false; // Requires all 5 prayers to be either completed or delayed
      }
    }
    return true;
  }

  static Map<String, int> _calculateWeeklyStatsOffline() {
    final stats = {'completed': 0, 'delayed': 0, 'missed': 0, 'unmarked': 0};
    final now = DateTime.now();

    // Walk back 7 days
    for (int i = 0; i < 7; i++) {
      final dateStr = _getFormatDate(now.subtract(Duration(days: i)));
      for (var key in ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya']) {
        final entry = HiveService.getTrackerEntry('${dateStr}_$key');
        final status = entry?['status'] as String? ?? 'unmarked';
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }
    return stats;
  }
}

final trackerProvider = StateNotifierProvider<TrackerNotifier, TrackerState>((
  ref,
) {
  return TrackerNotifier();
});
