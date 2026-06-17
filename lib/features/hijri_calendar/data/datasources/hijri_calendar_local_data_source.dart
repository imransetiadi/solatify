import '../models/hijri_event_dto.dart';

abstract class HijriCalendarLocalDataSource {
  Future<List<HijriEventDto>> getHijriEvents();
}

class HijriCalendarLocalDataSourceImpl implements HijriCalendarLocalDataSource {
  const HijriCalendarLocalDataSourceImpl();

  @override
  Future<List<HijriEventDto>> getHijriEvents() async {
    return _hijriEventsData;
  }
}

final List<HijriEventDto> _hijriEventsData = [
  HijriEventDto(
    id: 1,
    nameAr: 'عاشوراء',
    nameId: 'Asyura (10 Muharram)',
    gregorianDate: DateTime(2026, 7, 19),
    hijriYear: 1447,
    hijriMonth: 1,
    hijriDay: 10,
    description:
        'Hari ke-10 Muharram adalah hari bersejarah dalam Islam. Musa as. dan pengikutnya diselamatkan dari Firaun pada hari ini.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 2,
    nameAr: 'مولد النبي',
    nameId: 'Maulid Nabi Muhammad (12 Rabiul Awal)',
    gregorianDate: DateTime(2026, 9, 26),
    hijriYear: 1447,
    hijriMonth: 3,
    hijriDay: 12,
    description:
        'Perayaan kelahiran Nabi Muhammad SAW, didahului dengan ceramah-ceramah Islami dan sholawat.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 3,
    nameAr: 'رمضان',
    nameId: 'Bulan Ramadhan',
    gregorianDate: DateTime(2026, 2, 20),
    hijriYear: 1447,
    hijriMonth: 9,
    hijriDay: 1,
    description:
        'Bulan suci Ramadhan, bulan puasa dan ibadah yang sangat utama dalam Islam.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 4,
    nameAr: 'عيد الفطر',
    nameId: 'Hari Raya Idul Fitri',
    gregorianDate: DateTime(2026, 3, 21),
    hijriYear: 1447,
    hijriMonth: 10,
    hijriDay: 1,
    description:
        'Perayaan akhir bulan Ramadhan dengan sholat Id dan berkumpul bersama keluarga.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 5,
    nameAr: 'عيد الأضحى',
    nameId: 'Hari Raya Idul Adha',
    gregorianDate: DateTime(2026, 6, 17),
    hijriYear: 1447,
    hijriMonth: 12,
    hijriDay: 10,
    description:
        'Hari pesta korban untuk memperingati kesediaan Nabi Ibrahim menyembelih anaknya.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 6,
    nameAr: 'السنة الهجرية الجديدة',
    nameId: 'Tahun Baru Hijriah (1 Muharram)',
    gregorianDate: DateTime(2027, 7, 9),
    hijriYear: 1448,
    hijriMonth: 1,
    hijriDay: 1,
    description:
        'Pergantian tahun Hijriah, peringatan dari hijrah Nabi Muhammad dari Makkah ke Madinah.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 7,
    nameAr: 'الإسراء والمعراج',
    nameId: 'Isra dan Miraj (27 Rajab)',
    gregorianDate: DateTime(2026, 12, 4),
    hijriYear: 1447,
    hijriMonth: 7,
    hijriDay: 27,
    description:
        'Peristiwa perjalanan malam Nabi Muhammad dari Masjidil Haram ke Masjidil Aqsa dan naik ke langit.',
    isImportant: true,
  ),
  HijriEventDto(
    id: 8,
    nameAr: 'ليلة القدر',
    nameId: 'Lailatul Qadr (27 Ramadhan)',
    gregorianDate: DateTime(2026, 3, 19),
    hijriYear: 1447,
    hijriMonth: 9,
    hijriDay: 27,
    description:
        'Malam yang mulia ketika Al-Quran pertama kali diturunkan kepada Nabi Muhammad SAW.',
    isImportant: true,
  ),
];
