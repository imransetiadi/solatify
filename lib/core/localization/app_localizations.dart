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
  String get navMosque => isEnglish ? 'Mosques' : 'Masjid';
  String get navSettings => isEnglish ? 'Settings' : 'Pengaturan';
  String get navMore => isEnglish ? 'More' : 'Lainnya';

  String get settingsTitle => isEnglish ? 'Settings' : 'Pengaturan';
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
  String get offsetNegativeHint => isEnglish
      ? 'Use negative values to make it earlier.'
      : 'Gunakan nilai minus untuk memajukan waktu.';
  String get prayerOffsetLimitHint => isEnglish
      ? 'Allowed range: -60 to +60 minutes.'
      : 'Batas input: -60 sampai +60 menit.';
  String get generalSettings =>
      isEnglish ? 'GENERAL SETTINGS' : 'PENGATURAN UMUM';
  String get prayerTimeCorrection =>
      isEnglish ? 'PRAYER TIME CORRECTION' : 'KOREKSI WAKTU SALAT';
  String get changeLocation => isEnglish ? 'Change Location' : 'Ubah Lokasi';
  String get searchCity => isEnglish ? 'Search City...' : 'Cari Kota...';
  String get prayerSchedule => isEnglish ? 'Prayer Schedule' : 'Jadwal Salat';
  String get greeting => isEnglish ? 'Peace be upon you' : 'Assalamu’alaikum';
  String get preparingPrayerSchedule =>
      isEnglish ? 'Preparing prayer schedule' : 'Menyiapkan jadwal salat';
  String headingToPrayer(String prayerName) =>
      isEnglish ? 'Heading to $prayerName' : 'Menuju $prayerName';
  String get countdownWaiting => isEnglish
      ? 'Countdown will appear after the schedule is ready'
      : 'Countdown akan muncul setelah jadwal siap';
  String currentPrayerTime(String prayerName) => isEnglish
      ? 'Current prayer time: $prayerName'
      : 'Saat ini waktu $prayerName';
  String get remainingTime => isEnglish ? 'Remaining time' : 'Sisa waktu';
  String prayerTimeLabel(String prayerName) =>
      isEnglish ? '$prayerName time' : 'Waktu $prayerName';
  String activePrayerInProgress(String prayerName) => isEnglish
      ? '$prayerName prayer is in progress'
      : 'Salat $prayerName sedang berlangsung';
  String get islamicContent => isEnglish ? 'Islamic Content' : 'Konten Islami';
  String get spiritualExplore =>
      isEnglish ? 'Explore Spirituality' : 'Jelajahi Spiritual';
  String get spiritualExploreSubtitle => isEnglish
      ? 'Knowledge, duas, dhikr, and daily deeds'
      : 'Ilmu, doa, dzikir, dan amalan harian';
  String get dailyTip => isEnglish ? 'Daily Tip' : 'Tip Harian';
  String get contentMenu => isEnglish ? 'Content Menu' : 'Menu Konten';
  String get failedToLoadTip =>
      isEnglish ? 'Failed to load tip' : 'Gagal memuat tip';
  String get seeAllTips => isEnglish ? 'See All Tips' : 'Lihat Semua Tips';
  String get morningEveningDhikr =>
      isEnglish ? 'Morning & Evening Dhikr' : 'Dzikir Pagi & Petang';
  String get morningDhikr => isEnglish ? 'Morning Dhikr' : 'Dzikir Pagi';
  String get eveningDhikr => isEnglish ? 'Evening Dhikr' : 'Dzikir Petang';
  String get appErrorTitle =>
      isEnglish ? 'Something went wrong' : 'Terjadi sedikit kendala';
  String get appErrorMessage => isEnglish
      ? 'Please try again or reopen the app.'
      : 'Silakan coba lagi atau buka ulang aplikasi.';
  String get exactAlarmTitle =>
      isEnglish ? 'Enable Exact Alarms' : 'Aktifkan Alarm Tepat Waktu';
  String get exactAlarmMessage => isEnglish
      ? 'To show prayer notifications exactly on time, enable Alarms & reminders / Exact alarms for Solatify.'
      : 'Agar notifikasi waktu salat muncul tepat saat masuk waktu, aktifkan izin Alarms & reminders / Alarm tepat waktu untuk Solatify.';
  String get later => isEnglish ? 'Later' : 'Nanti';
  String get enable => isEnglish ? 'Enable' : 'Aktifkan';
  String get backgroundPermissionTitle => isEnglish
      ? 'Allow Background Running'
      : 'Izinkan Berjalan di Latar Belakang';
  String get backgroundPermissionMessage => isEnglish
      ? 'So adhan can still appear when the app is closed, set Solatify battery usage to Unrestricted.'
      : 'Agar adzan tetap muncul saat aplikasi ditutup, atur battery usage Solatify ke Unrestricted / Tidak dibatasi.';
  String get openSettings => isEnglish ? 'Open Settings' : 'Buka Pengaturan';
  String get automaticAdhanNotifications =>
      isEnglish ? 'Automatic adhan notifications' : 'Notifikasi adzan otomatis';
  String get automaticAdhanNotificationsDescription => isEnglish
      ? 'Play adhan automatically at prayer time.'
      : 'Putar adzan otomatis saat masuk waktu salat.';
  String get notificationPermissionError => isEnglish
      ? 'Notification permission could not be opened.'
      : 'Izin notifikasi belum bisa dibuka.';
  String get notificationPermissionSettingsHint => isEnglish
      ? 'Adjust Solatify notification permission from this Android settings page.'
      : 'Atur izin notifikasi Solatify dari halaman pengaturan Android ini.';
  String get notificationReliability =>
      isEnglish ? 'NOTIFICATION RELIABILITY' : 'KEANDALAN NOTIFIKASI';
  String get forceStopWarningTitle =>
      isEnglish ? 'Force stop limitation' : 'Batasan paksa berhenti';
  String get forceStopWarningMessage => isEnglish
      ? 'Android blocks all alarms after Force Stop. Reopen Solatify once to schedule prayer notifications again.'
      : 'Android memblokir semua alarm setelah aplikasi di-Paksa Berhenti. Buka Solatify sekali lagi untuk menjadwalkan notifikasi salat.';
  String get iosNotificationReliabilityMessage => isEnglish
      ? 'iOS can deliver scheduled prayer notifications when permission is enabled. If notifications stop appearing, reopen Solatify and check iOS notification settings.'
      : 'iOS dapat mengirim notifikasi salat terjadwal saat izin aktif. Jika notifikasi berhenti muncul, buka Solatify lagi dan cek pengaturan notifikasi iOS.';
  String get openNotificationPermission =>
      isEnglish ? 'Notification permission' : 'Izin notifikasi';
  String get openExactAlarmPermission =>
      isEnglish ? 'Exact alarm permission' : 'Izin alarm tepat waktu';
  String get openBatterySettings =>
      isEnglish ? 'Battery unrestricted' : 'Baterai tidak dibatasi';
  String setPrayerOffset(String prayerName) => isEnglish
      ? 'Set $prayerName Time Offset'
      : 'Atur Ofset Waktu $prayerName';

  String prayerName(String keyOrName) {
    switch (keyOrName.toLowerCase()) {
      case 'subuh':
        return isEnglish ? 'Fajr' : 'Subuh';
      case 'dzuhur':
      case 'dhuhr':
        return isEnglish ? 'Dhuhr' : 'Dzuhur';
      case 'ashar':
      case 'asr':
        return isEnglish ? 'Asr' : 'Ashar';
      case 'magrib':
      case 'maghrib':
        return isEnglish ? 'Maghrib' : 'Magrib';
      case 'isya':
      case 'isha':
        return isEnglish ? 'Isha' : 'Isya';
      default:
        return keyOrName;
    }
  }

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
