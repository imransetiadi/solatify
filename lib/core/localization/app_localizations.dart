import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('id'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('id'));
  }

  bool get isEnglish => locale.languageCode == 'en';

  String get appTitle => 'Solatify';

  String get navHome => isEnglish ? 'Home' : 'Beranda';
  String get navSchedule => isEnglish ? 'Schedule' : 'Jadwal';
  String get navQuran => isEnglish ? 'Qur\'an' : 'Qur\'an';
  String get navContent => isEnglish ? 'Content' : 'Konten';
  String get navQibla => isEnglish ? 'Qibla' : 'Kiblat';
  String get navJournal => isEnglish ? 'Journal' : 'Jurnal';
  String get navMosque => isEnglish ? 'Mosques' : 'Masjid';
  String get navSettings => isEnglish ? 'Settings' : 'Pengaturan';
  String get navMore => isEnglish ? 'More' : 'Lainnya';

  String get settingsTitle => isEnglish ? 'Settings' : 'Pengaturan';
  String get reminderAndAdhan =>
      isEnglish ? 'Notifications & Adhan' : 'Notifikasi & Adzan';
  String get prayerReminder =>
      isEnglish ? 'Prayer Reminder' : 'Pengingat Salat';
  String get prayerReminderSubtitle => isEnglish
      ? 'Enable notifications when prayer time begins'
      : 'Aktifkan pengingat notifikasi masuk waktu salat';
  String get adhanSound => isEnglish ? 'Adhan Sound' : 'Suara Adzan';
  String get adhanSoundDialogTitle =>
      isEnglish ? 'Adhan Reminder Sound' : 'Suara Pengingat Adzan';
  String get calculationSchedule =>
      isEnglish ? 'Schedule Calculation' : 'Kalkulasi Jadwal';
  String get calculationMethod =>
      isEnglish ? 'Calculation Method' : 'Metode Perhitungan';
  String get prayerTimeOffsets =>
      isEnglish ? 'Prayer Time Offsets' : 'Ofset Waktu Salat';
  String get displayAndLanguage =>
      isEnglish ? 'Display & Language' : 'Tampilan & Bahasa';
  String get language => isEnglish ? 'Language' : 'Bahasa';
  String get chooseLanguage => isEnglish ? 'Choose Language' : 'Pilih Bahasa';
  String get theme => isEnglish ? 'Theme' : 'Tema';
  String get appTheme => isEnglish ? 'App Theme' : 'Tema Aplikasi';
  String get lightTheme => isEnglish ? 'Light' : 'Terang';
  String get darkTheme => isEnglish ? 'Dark' : 'Gelap';
  String get systemTheme => isEnglish ? 'System' : 'Sistem';
  String get aboutApp => isEnglish ? 'About App' : 'Tentang Aplikasi';
  String get appVersion => isEnglish ? 'Version 1.0.0' : 'Versi 1.0.0';
  String get cancel => isEnglish ? 'Cancel' : 'Batal';
  String get save => isEnglish ? 'Save' : 'Simpan';
  String get minutes => isEnglish ? 'minutes' : 'menit';
  String get adjustOffsetHint => isEnglish
      ? 'Add or subtract minutes from the standard time.'
      : 'Tambahkan atau kurangi menit dari waktu standar.';
  String setPrayerOffset(String prayerName) => isEnglish
      ? 'Set $prayerName Time Offset'
      : 'Atur Ofset Waktu $prayerName';

  String get defaultBeep =>
      isEnglish ? 'Standard Beep / Default' : 'Bip Standar / Default';
  String get adhanMakkah => isEnglish ? 'Makkah Adhan' : 'Adzan Makkah';
  String get adhanMadinah => isEnglish ? 'Madinah Adhan' : 'Adzan Madinah';
  String get silent => isEnglish ? 'Silent' : 'Hening / Silent';

  String get indonesiaLanguage => 'Bahasa Indonesia';
  String get englishLanguage => 'English';

  String calculationMethodLabel(String value) {
    switch (value) {
      case 'Kemenag':
        return isEnglish ? 'Kemenag RI (Indonesia)' : 'Kemenag RI (Indonesia)';
      case 'MuslimWorldLeague':
        return 'Muslim World League (MWL)';
      case 'Egypt':
        return isEnglish ? 'Egyptian General Authority' : 'Otoritas Umum Mesir';
      case 'Karachi':
        return isEnglish
            ? 'University of Islamic Sciences, Karachi'
            : 'Universitas Ilmu Islam, Karachi';
      case 'UmmAlQura':
        return isEnglish
            ? 'Umm Al-Qura University, Makkah'
            : 'Universitas Umm Al-Qura, Makkah';
      case 'NorthAmerica':
        return isEnglish ? 'ISNA (North America)' : 'ISNA (Amerika Utara)';
      default:
        return value;
    }
  }

  String adhanSoundLabel(String value) {
    switch (value) {
      case 'adhan_makkah':
        return adhanMakkah;
      case 'adhan_madinah':
        return adhanMadinah;
      case 'silent':
        return silent;
      default:
        return defaultBeep;
    }
  }

  String languageLabel(String value) =>
      value == 'en' ? englishLanguage : indonesiaLanguage;

  String themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return systemTheme;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final languageCode = locale.languageCode == 'en' ? 'en' : 'id';
    return AppLocalizations(Locale(languageCode));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
