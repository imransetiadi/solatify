class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const getStarted = '/get-started';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const schedule = '/schedule';
  static const quran = '/quran';
  static const islamicContent = '/islamic-content';
  static const asmaulHusna = '/islamic-content/asmaul-husna';
  static const duas = '/islamic-content/duas';
  static const hijriCalendar = '/islamic-content/hijri-calendar';
  static const islamicTips = '/islamic-content/tips';
  static const dhikr = '/islamic-content/dhikr';
  static const prayerGuide = '/islamic-content/prayer-guide';
  static const qibla = '/qibla';
  static const mosque = '/mosque';
  static const tracker = '/tracker';
  static const settings = '/settings';
  static const notificationHealth = '/settings/notification-health';
  static const more = '/more';

  static String quranSurah(int surahId, {int? scrollTo}) {
    final base = '$quran/surah/$surahId';
    if (scrollTo == null) return base;
    return '$base?scroll_to=$scrollTo';
  }
}
