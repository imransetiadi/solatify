import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/features/home/presentation/providers/countdown_provider.dart';
import 'package:solatify/features/notifications/domain/services/prayer_notification_planner.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_timezone_service.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_widget/domain/android_prayer_widget_service.dart';
import 'package:solatify/features/prayer_widget/domain/ios_prayer_widget_service.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

final androidPrayerWidgetServiceProvider = Provider<AndroidPrayerWidgetService>(
  (ref) => AndroidPrayerWidgetService(),
);

final iosPrayerWidgetServiceProvider = Provider<IosPrayerWidgetService>(
  (ref) => IosPrayerWidgetService(),
);

/// Widget payload. Only changes when the next prayer, the schedule or the
/// location changes — not on every countdown tick — so the native widget is
/// written a few times a day instead of every second. The native widgets run
/// the live countdown themselves from [PrayerWidgetPayload.schedule].
final prayerWidgetPayloadProvider = Provider.autoDispose<PrayerWidgetPayload>((
  ref,
) {
  // Rebuild when the next prayer changes (e.g. Ashar -> Magrib) so the
  // fallback labels move on; the countdown ticks themselves are ignored.
  ref.watch(countdownProvider.select((state) => state.nextPrayerKey));
  final timesState = ref.watch(prayerTimesProvider);
  final location = ref.watch(locationProvider);
  final settings = ref.watch(settingsProvider);

  // Several days ahead (as far as notifications are scheduled), so the
  // widgets keep moving on when the app is not opened for a while instead
  // of freezing after tomorrow's Subuh.
  final laterDays = <Map<String, DateTime?>>[];
  try {
    final timezoneName = PrayerTimezoneService.inferTimezoneName(
      latitude: location.latitude,
      longitude: location.longitude,
      country: location.country,
    );
    final now = DateTime.now();
    for (var day = 2; day < prayerNotificationHorizonDays; day++) {
      laterDays.add(
        PrayerCalculationService.calculatePrayerTimes(
          latitude: location.latitude,
          longitude: location.longitude,
          date: PrayerCalculationService.cityNoon(timezoneName, now, day),
          method: settings.calculationMethod,
          timezoneName: timezoneName,
          offsets: settings.prayerOffsets,
        ),
      );
    }
  } catch (e) {
    debugPrint('Widget schedule beyond tomorrow unavailable: $e');
  }

  final slots = buildPrayerWidgetSlots(
    todayTimes: timesState.todayTimes,
    tomorrowTimes: timesState.tomorrowTimes,
    laterDays: laterDays,
    isEnglish: settings.language == 'en',
  );
  final next = nextPrayerWidgetSlot(slots, DateTime.now());
  final locationLabel = location.city.trim().isEmpty
      ? location.country
      : '${location.city}, ${location.country}';

  return PrayerWidgetPayload(
    nextPrayerName: next?.name ?? '-',
    nextPrayerTimeLabel: next?.timeLabel ?? '--:--',
    // Fallback text for widgets that cannot run a live countdown.
    countdownLabel: next?.timeLabel ?? '--:--',
    locationLabel: locationLabel,
    hijriLabel: settings.language == 'en'
        ? "Today's prayer times"
        : 'Jadwal salat hari ini',
    schedule: encodePrayerWidgetSchedule(slots),
  );
});

@immutable
class PrayerWidgetSlot {
  const PrayerWidgetSlot({
    required this.name,
    required this.time,
    required this.timeLabel,
  });

  final String name;
  final DateTime time;

  /// Clock time in the prayer location's timezone (not the device's).
  final String timeLabel;
}

const _slotConfig = [
  ('Subuh', 'Fajr', 'subuh'),
  ('Dzuhur', 'Dhuhr', 'dzuhur'),
  ('Ashar', 'Asr', 'ashar'),
  ('Magrib', 'Maghrib', 'magrib'),
  ('Isya', 'Isha', 'isya'),
];

/// Today's and tomorrow's prayers, plus [laterDays], in chronological order.
List<PrayerWidgetSlot> buildPrayerWidgetSlots({
  required Map<String, DateTime> todayTimes,
  required Map<String, DateTime> tomorrowTimes,
  List<Map<String, DateTime?>> laterDays = const [],
  bool isEnglish = false,
}) {
  final timeFormat = DateFormat.Hm();
  final slots = <PrayerWidgetSlot>[
    for (final day in <Map<String, DateTime?>>[
      todayTimes,
      tomorrowTimes,
      ...laterDays,
    ])
      for (final (idName, enName, key) in _slotConfig)
        if (day[key] case final time?)
          PrayerWidgetSlot(
            name: isEnglish ? enName : idName,
            time: time,
            timeLabel: timeFormat.format(time),
          ),
  ];
  slots.sort((a, b) => a.time.compareTo(b.time));
  return slots;
}

/// The first prayer after [now]. After Isya this is tomorrow's Subuh, not
/// today's (which has already passed).
PrayerWidgetSlot? nextPrayerWidgetSlot(
  List<PrayerWidgetSlot> slots,
  DateTime now,
) {
  for (final slot in slots) {
    if (slot.time.isAfter(now)) return slot;
  }
  return null;
}

String encodePrayerWidgetSchedule(List<PrayerWidgetSlot> slots) {
  return slots
      .map(
        (slot) =>
            '${slot.name}|${slot.time.millisecondsSinceEpoch}|${slot.timeLabel}',
      )
      .join(';');
}
