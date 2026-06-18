# Broaden Compact Scaffold Design

## Goal
Perluas penggunaan `SolatifyScreenScaffold` ke layar konten/detail yang memiliki pola visual sama: AppBar, tombol kembali ke Konten Islami, Islamic background, responsive center, dan padding compact.

## Scope
- Migrasi layar konten/detail yang aman dan tidak punya chrome khusus kompleks:
  - `AsmaulHusnaScreen`
  - `HijriCalendarScreen`
  - `PrayerGuideScreen`
  - `NotificationHealthScreen`
- Pertahankan `Home`, `Schedule`, `QuranHome`, `SurahDetail`, `Settings`, `Qibla`, `Mosque`, dan `Tracker` untuk phase terpisah karena punya state chrome, sensor, map/search, bottom sheet, atau layout khusus.
- Rapikan route constants untuk back navigation yang masih hardcoded jika ada.

## UX Rules
- Tampilan tidak berubah secara fungsional.
- Title, back action, background, responsive center, dan padding tetap konsisten.
- Tidak mengubah data provider, domain logic, ataupun native notification flow.

## Validation
- `flutter analyze` harus no issues.
- `flutter test` harus full pass.
- Smoke/source tests memastikan layar target memakai `SolatifyScreenScaffold` dan route constants.
