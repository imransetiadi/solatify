import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

import '../models/hijri_event_dto.dart';

abstract class HijriCalendarLocalDataSource {
  /// Events for the Hijri year containing [today] and the following year,
  /// with Gregorian dates computed from the Umm al-Qura calendar.
  Future<List<HijriEventDto>> getHijriEvents({DateTime? today});
}

class HijriCalendarLocalDataSourceImpl implements HijriCalendarLocalDataSource {
  const HijriCalendarLocalDataSourceImpl();

  @override
  Future<List<HijriEventDto>> getHijriEvents({DateTime? today}) async {
    return buildHijriEvents(today ?? DateTime.now());
  }
}

/// A recurring event identified by its Hijri month/day. Gregorian dates are
/// computed per year instead of being hard-coded, so they stay correct and
/// the list never runs out.
class _HijriEventTemplate {
  const _HijriEventTemplate({
    required this.id,
    required this.nameAr,
    required this.nameId,
    required this.hijriMonth,
    required this.hijriDay,
    required this.description,
  });

  final int id;
  final String nameAr;
  final String nameId;
  final int hijriMonth;
  final int hijriDay;
  final String description;
}

const List<_HijriEventTemplate> _templates = [
  _HijriEventTemplate(
    id: 1,
    nameAr: 'عاشوراء',
    nameId: 'Asyura (10 Muharram)',
    hijriMonth: 1,
    hijriDay: 10,
    description:
        'Hari ke-10 Muharram adalah hari bersejarah dalam Islam. Musa as. dan pengikutnya diselamatkan dari Firaun pada hari ini.',
  ),
  _HijriEventTemplate(
    id: 2,
    nameAr: 'مولد النبي',
    nameId: 'Maulid Nabi Muhammad (12 Rabiul Awal)',
    hijriMonth: 3,
    hijriDay: 12,
    description:
        'Perayaan kelahiran Nabi Muhammad SAW, didahului dengan ceramah-ceramah Islami dan sholawat.',
  ),
  _HijriEventTemplate(
    id: 3,
    nameAr: 'رمضان',
    nameId: 'Bulan Ramadhan',
    hijriMonth: 9,
    hijriDay: 1,
    description:
        'Bulan suci Ramadhan, bulan puasa dan ibadah yang sangat utama dalam Islam.',
  ),
  _HijriEventTemplate(
    id: 4,
    nameAr: 'عيد الفطر',
    nameId: 'Hari Raya Idul Fitri',
    hijriMonth: 10,
    hijriDay: 1,
    description:
        'Perayaan akhir bulan Ramadhan dengan sholat Id dan berkumpul bersama keluarga.',
  ),
  _HijriEventTemplate(
    id: 5,
    nameAr: 'عيد الأضحى',
    nameId: 'Hari Raya Idul Adha',
    hijriMonth: 12,
    hijriDay: 10,
    description:
        'Hari pesta korban untuk memperingati kesediaan Nabi Ibrahim menyembelih anaknya.',
  ),
  _HijriEventTemplate(
    id: 6,
    nameAr: 'السنة الهجرية الجديدة',
    nameId: 'Tahun Baru Hijriah (1 Muharram)',
    hijriMonth: 1,
    hijriDay: 1,
    description:
        'Pergantian tahun Hijriah, peringatan dari hijrah Nabi Muhammad dari Makkah ke Madinah.',
  ),
  _HijriEventTemplate(
    id: 7,
    nameAr: 'الإسراء والمعراج',
    nameId: 'Isra dan Miraj (27 Rajab)',
    hijriMonth: 7,
    hijriDay: 27,
    description:
        'Peristiwa perjalanan malam Nabi Muhammad dari Masjidil Haram ke Masjidil Aqsa dan naik ke langit.',
  ),
  _HijriEventTemplate(
    id: 8,
    nameAr: 'ليلة القدر',
    nameId: 'Lailatul Qadr (27 Ramadhan)',
    hijriMonth: 9,
    hijriDay: 27,
    description:
        'Malam yang mulia ketika Al-Quran pertama kali diturunkan kepada Nabi Muhammad SAW.',
  ),
];

/// Builds events for the Hijri year of [today] and the next one.
///
/// Dates follow the Umm al-Qura calendar. Indonesia's official dates (sidang
/// isbat) can differ by a day, so they are presented as estimates.
@visibleForTesting
List<HijriEventDto> buildHijriEvents(DateTime today) {
  final currentHijriYear = HijriCalendar.fromDate(today).hYear;
  final converter = HijriCalendar();
  final events = <HijriEventDto>[];

  for (final hijriYear in [currentHijriYear, currentHijriYear + 1]) {
    for (final template in _templates) {
      try {
        final gregorian = converter.hijriToGregorian(
          hijriYear,
          template.hijriMonth,
          template.hijriDay,
        );
        events.add(
          HijriEventDto(
            // Unique per occurrence: the same event recurs every year.
            id: hijriYear * 100 + template.id,
            nameAr: template.nameAr,
            nameId: template.nameId,
            gregorianDate: DateTime(
              gregorian.year,
              gregorian.month,
              gregorian.day,
            ),
            hijriYear: hijriYear,
            hijriMonth: template.hijriMonth,
            hijriDay: template.hijriDay,
            description: template.description,
            isImportant: true,
          ),
        );
      } catch (error) {
        // Outside the Umm al-Qura table range; skip rather than crash.
        debugPrint('Could not convert Hijri event ${template.id}: $error');
      }
    }
  }

  events.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
  return events;
}
