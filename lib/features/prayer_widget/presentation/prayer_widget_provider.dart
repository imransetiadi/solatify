import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/features/home/presentation/providers/countdown_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_widget/domain/android_prayer_widget_service.dart';
import 'package:solatify/features/prayer_widget/domain/ios_prayer_widget_service.dart';

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

  final slots = buildPrayerWidgetSlots(
    todayTimes: timesState.todayTimes,
    tomorrowTimes: timesState.tomorrowTimes,
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
    hijriLabel: 'Jadwal salat hari ini',
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
  ('Subuh', 'subuh'),
  ('Dzuhur', 'dzuhur'),
  ('Ashar', 'ashar'),
  ('Magrib', 'magrib'),
  ('Isya', 'isya'),
];

/// Today's five prayers plus tomorrow's Subuh, in chronological order.
List<PrayerWidgetSlot> buildPrayerWidgetSlots({
  required Map<String, DateTime> todayTimes,
  required Map<String, DateTime> tomorrowTimes,
}) {
  final timeFormat = DateFormat.Hm();
  final slots = <PrayerWidgetSlot>[
    for (final (name, key) in _slotConfig)
      if (todayTimes[key] case final time?)
        PrayerWidgetSlot(
          name: name,
          time: time,
          timeLabel: timeFormat.format(time),
        ),
    if (tomorrowTimes['subuh'] case final time?)
      PrayerWidgetSlot(
        name: 'Subuh',
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
