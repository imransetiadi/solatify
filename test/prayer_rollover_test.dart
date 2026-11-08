import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_widget/presentation/prayer_widget_provider.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location jakarta;
  late tz.Location jayapura;

  setUpAll(() {
    tzdata.initializeTimeZones();
    jakarta = tz.getLocation('Asia/Jakarta');
    jayapura = tz.getLocation('Asia/Jayapura');
  });

  Map<String, DateTime> day(tz.Location loc, int y, int m, int d) => {
    'subuh': tz.TZDateTime(loc, y, m, d, 4, 30),
    'dzuhur': tz.TZDateTime(loc, y, m, d, 11, 50),
    'ashar': tz.TZDateTime(loc, y, m, d, 15, 10),
    'magrib': tz.TZDateTime(loc, y, m, d, 17, 55),
    'isya': tz.TZDateTime(loc, y, m, d, 19, 5),
  };

  group('prayer schedule staleness', () {
    test('a schedule for today is fresh', () {
      final today = day(jakarta, 2026, 11, 7);
      final now = tz.TZDateTime(jakarta, 2026, 11, 7, 22, 0);
      expect(isPrayerScheduleStale(today, now), isFalse);
    });

    test('yesterday\'s schedule is stale after midnight', () {
      final yesterday = day(jakarta, 2026, 11, 7);
      final now = tz.TZDateTime(jakarta, 2026, 11, 8, 6, 0);
      expect(isPrayerScheduleStale(yesterday, now), isTrue);
    });

    test('an empty schedule is stale', () {
      expect(isPrayerScheduleStale({}, DateTime(2026, 11, 7)), isTrue);
    });

    test('staleness uses the location day, not the device day', () {
      // 23:30 in Jakarta is already 01:30 the next day in Jayapura.
      final jayapuraToday = day(jayapura, 2026, 11, 7);
      final now = tz.TZDateTime(jakarta, 2026, 11, 7, 23, 30);
      expect(isPrayerScheduleStale(jayapuraToday, now), isTrue);
    });

    test('rollover is scheduled at the location\'s midnight', () {
      final jayapuraToday = day(jayapura, 2026, 11, 7);
      final refresh = nextScheduleRefresh(jayapuraToday, DateTime(2026));
      expect(
        refresh.isAtSameMomentAs(tz.TZDateTime(jayapura, 2026, 11, 8, 0, 1)),
        isTrue,
      );
    });
  });

  group('prayer widget schedule', () {
    final slots = () => buildPrayerWidgetSlots(
      todayTimes: day(jakarta, 2026, 11, 7),
      tomorrowTimes: day(jakarta, 2026, 11, 8),
    );

    test('contains today\'s and tomorrow\'s five prayers', () {
      final names = slots().map((s) => s.name).toList();
      const day = ['Subuh', 'Dzuhur', 'Ashar', 'Magrib', 'Isya'];
      expect(names, [...day, ...day]);
    });

    test('later days keep the widget going while the app is closed', () {
      final withLater = buildPrayerWidgetSlots(
        todayTimes: day(jakarta, 2026, 11, 7),
        tomorrowTimes: day(jakarta, 2026, 11, 8),
        laterDays: [day(jakarta, 2026, 11, 9), day(jakarta, 2026, 11, 10)],
      );
      expect(withLater, hasLength(20));
      // Two days after tomorrow's Subuh there is still a next prayer.
      final next = nextPrayerWidgetSlot(
        withLater,
        tz.TZDateTime(jakarta, 2026, 11, 9, 13),
      )!;
      expect((next.name, next.time.day), ('Ashar', 9));
    });

    test('after Isya the next prayer is tomorrow\'s Subuh', () {
      final now = tz.TZDateTime(jakarta, 2026, 11, 7, 21, 0);
      final next = nextPrayerWidgetSlot(slots(), now)!;
      expect(next.name, 'Subuh');
      expect(next.time.day, 8);
    });

    test('time labels use the prayer location clock', () {
      final next = nextPrayerWidgetSlot(
        slots(),
        tz.TZDateTime(jakarta, 2026, 11, 7, 12, 0),
      )!;
      expect(next.name, 'Ashar');
      expect(next.timeLabel, '15:10');
    });

    test('schedule encodes name, epoch millis and label', () {
      final encoded = encodePrayerWidgetSchedule(slots().take(1).toList());
      final millis = tz.TZDateTime(
        jakarta,
        2026,
        11,
        7,
        4,
        30,
      ).millisecondsSinceEpoch;
      expect(encoded, 'Subuh|$millis|04:30');
    });
  });
}
