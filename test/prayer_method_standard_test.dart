import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';

/// Kemenag RI published schedules (Bimas Islam data via api.myquran.com,
/// fetched 2026-11-08): Subuh, Dzuhur, Ashar, Magrib, Isya.
const _kemenag = <String, List<String>>{
  'jakarta|2026/01/15': ['04:27', '12:05', '15:30', '18:18', '19:33'],
  'jakarta|2026/04/15': ['04:38', '11:56', '15:14', '17:55', '19:04'],
  'jakarta|2026/07/15': ['04:45', '12:02', '15:23', '17:56', '19:09'],
  'jakarta|2026/11/08': ['04:07', '11:40', '14:58', '17:51', '19:03'],
  'surabaya|2026/01/15': ['04:02', '11:42', '15:06', '17:57', '19:11'],
  'surabaya|2026/04/15': ['04:15', '11:33', '14:51', '17:31', '18:40'],
  'surabaya|2026/07/15': ['04:23', '11:39', '14:59', '17:30', '18:44'],
  'surabaya|2026/11/08': ['03:42', '11:16', '14:34', '17:28', '18:41'],
  'makassar|2026/01/15': ['04:39', '12:15', '15:39', '18:26', '19:40'],
  'makassar|2026/04/15': ['04:47', '12:06', '15:23', '18:05', '19:14'],
  'makassar|2026/07/15': ['04:53', '12:12', '15:34', '18:07', '19:20'],
  'makassar|2026/11/08': ['04:18', '11:50', '15:08', '17:59', '19:11'],
  'medan|2026/01/15': ['05:17', '12:38', '16:01', '18:36', '19:49'],
  'medan|2026/04/15': ['05:04', '12:29', '15:39', '18:34', '19:44'],
  'medan|2026/07/15': ['05:01', '12:35', '15:59', '18:44', '19:57'],
  'medan|2026/11/08': ['04:52', '12:12', '15:33', '18:11', '19:22'],
  'jayapura|2026/01/15': ['04:18', '11:50', '15:14', '17:57', '19:11'],
  'jayapura|2026/04/15': ['04:20', '11:41', '14:57', '17:42', '18:51'],
  'jayapura|2026/07/15': ['04:24', '11:47', '15:10', '17:46', '18:59'],
  'jayapura|2026/11/08': ['03:57', '11:24', '14:44', '17:31', '18:42'],
  'denpasar|2026/01/15': ['04:49', '12:32', '15:55', '18:49', '20:04'],
  'denpasar|2026/04/15': ['05:06', '12:23', '15:42', '18:20', '19:29'],
  'denpasar|2026/07/15': ['05:15', '12:29', '15:48', '18:18', '19:32'],
  'denpasar|2026/11/08': ['04:30', '12:06', '15:23', '18:20', '19:33'],
  'bandaaceh|2026/01/15': ['05:33', '12:52', '16:13', '18:46', '19:59'],
  'bandaaceh|2026/04/15': ['05:16', '12:42', '15:50', '18:49', '19:59'],
  'bandaaceh|2026/07/15': ['05:11', '12:48', '16:13', '19:00', '20:15'],
  'bandaaceh|2026/11/08': ['05:08', '12:26', '15:47', '18:22', '19:34'],
};

const _cities = <String, (double, double, String)>{
  'jakarta': (-6.2088, 106.8456, 'Asia/Jakarta'),
  'surabaya': (-7.2575, 112.7521, 'Asia/Jakarta'),
  'makassar': (-5.1477, 119.4327, 'Asia/Makassar'),
  'medan': (3.5952, 98.6722, 'Asia/Jakarta'),
  'jayapura': (-2.5916, 140.6690, 'Asia/Jayapura'),
  'denpasar': (-8.6705, 115.2126, 'Asia/Makassar'),
  'bandaaceh': (5.5483, 95.3238, 'Asia/Jakarta'),
};

const _keys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];

int _minuteOfDay(String hhmm) {
  final parts = hhmm.split(':').map(int.parse).toList();
  return parts[0] * 60 + parts[1];
}

Map<String, DateTime> _calc(
  String city,
  String date, {
  String method = 'Kemenag',
  Map<String, int>? offsets,
}) {
  final (lat, lng, zone) = _cities[city]!;
  final p = date.split('/').map(int.parse).toList();
  return PrayerCalculationService.calculatePrayerTimes(
    latitude: lat,
    longitude: lng,
    date: DateTime.utc(p[0], p[1], p[2], 5),
    method: method,
    timezoneName: zone,
    offsets: offsets,
  );
}

void main() {
  group('Kemenag standard (ihtiyat, rounded up)', () {
    test('matches published Kemenag schedules to within a minute', () {
      var exact = 0;
      var total = 0;
      _kemenag.forEach((key, reference) {
        final [city, date] = key.split('|');
        final times = _calc(city, date);
        for (var i = 0; i < _keys.length; i++) {
          final got = times[_keys[i]]!;
          final diff = got.hour * 60 + got.minute - _minuteOfDay(reference[i]);
          expect(diff.abs(), lessThanOrEqualTo(1), reason: '$key ${_keys[i]}');
          if (diff == 0) exact++;
          total++;
        }
      });
      // 121 of 140 when calibrated; guard against drifting back.
      expect(exact / total, greaterThanOrEqualTo(0.85));
    });

    test('Magrib is never earlier than the published Kemenag time', () {
      _kemenag.forEach((key, reference) {
        final [city, date] = key.split('|');
        final magrib = _calc(city, date)['magrib']!;
        expect(
          magrib.hour * 60 + magrib.minute,
          greaterThanOrEqualTo(_minuteOfDay(reference[3])),
          reason: key,
        );
      });
    });

    test('user corrections add whole minutes on top of the standard', () {
      final base = _calc('jakarta', '2026/11/08', offsets: const {});
      final shifted = _calc(
        'jakarta',
        '2026/11/08',
        offsets: const {'subuh': 2, 'magrib': -1, 'isya': 5},
      );
      expect(shifted['subuh']!.difference(base['subuh']!).inMinutes, 2);
      expect(shifted['dzuhur'], base['dzuhur']);
      expect(shifted['magrib']!.difference(base['magrib']!).inMinutes, -1);
      expect(shifted['isya']!.difference(base['isya']!).inMinutes, 5);
    });

    test('out of range stored corrections are clamped, not applied raw', () {
      final base = _calc('jakarta', '2026/11/08', offsets: const {});
      final huge = _calc('jakarta', '2026/11/08', offsets: const {'isya': 600});
      expect(huge['isya']!.difference(base['isya']!).inMinutes, 60);
    });
  });

  test('Kemenag times are the astronomical instant plus ihtiyat, '
      'rounded up', () {
    // Independent check of the longitude-shift rounding: recover each raw
    // instant to the second by sweeping the longitude (1 s = 1/240 degree)
    // until adhan's nearest-minute rounding flips.
    const ihtiyat = {
      'subuh': 2,
      'dzuhur': 3,
      'ashar': 2,
      'magrib': 3,
      'isya': 2,
    };
    DateTime pick(PrayerTimes t, String key) => switch (key) {
      'subuh' => t.fajr,
      'dzuhur' => t.dhuhr,
      'ashar' => t.asr,
      'magrib' => t.maghrib,
      _ => t.isha,
    }.toUtc();

    for (final city in ['jakarta', 'jayapura', 'bandaaceh']) {
      for (final date in ['2026/01/15', '2026/07/15']) {
        final (lat, lng, _) = _cities[city]!;
        final p = date.split('/').map(int.parse).toList();
        PrayerTimes at(int seconds) => PrayerTimes(
          Coordinates(lat, lng - seconds / 240.0),
          DateComponents(p[0], p[1], p[2]),
          PrayerCalculationService.getParameters('Kemenag'),
        );
        final base = at(0);
        final times = _calc(city, date);
        for (final key in _keys) {
          final rounded = pick(base, key);
          var raw = rounded;
          for (var s = 1; s <= 60; s++) {
            if (pick(at(s), key) != rounded) {
              raw = rounded.add(Duration(seconds: 30 - s));
              break;
            }
          }
          // The sweep resolves whole seconds, so the instant lies in
          // [raw, raw + 1 s); its rounded-up minute is one of these two.
          DateTime ceilMinute(DateTime t) {
            final whole = DateTime.utc(
              t.year,
              t.month,
              t.day,
              t.hour,
              t.minute,
            );
            return t == whole ? whole : whole.add(const Duration(minutes: 1));
          }

          final withMargin = raw.add(Duration(minutes: ihtiyat[key]!));
          final candidates = {
            ceilMinute(withMargin),
            ceilMinute(withMargin.add(const Duration(milliseconds: 999))),
          };
          final got = times[key]!.toUtc();
          expect(
            candidates.map((c) => (c.hour, c.minute)),
            contains((got.hour, got.minute)),
            reason: '$city $date $key raw $raw',
          );
        }
      }
    }
  });

  test('other methods keep adhan output unchanged', () {
    final times = _calc('jakarta', '2026/11/08', method: 'MWL');
    final reference = PrayerTimes(
      Coordinates(-6.2088, 106.8456),
      DateComponents(2026, 11, 8),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    expect(times['subuh']!.toUtc(), reference.fajr.toUtc());
    expect(times['isya']!.toUtc(), reference.isha.toUtc());
  });

  test('unknown stored method falls back to the Kemenag standard', () {
    expect(
      PrayerCalculationService.standardFor('SomethingOld'),
      PrayerMethodStandard.kemenag,
    );
    expect(
      PrayerCalculationService.standardFor('MWL'),
      PrayerMethodStandard.none,
    );
  });
}
