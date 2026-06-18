# Notification Permission Flow Tests Design

## Goal
Memperkuat flow permission notifikasi iOS/Android agar setelah user kembali dari system settings, aplikasi langsung melakukan verifikasi ulang dan recovery scheduling secara otomatis.

## Scope
- Settings screen menjadi `WidgetsBindingObserver` dan menjalankan verification saat app lifecycle kembali `resumed`.
- Jika notifikasi adzan aktif dan permission masih allowed, scheduler menjalankan `refreshSchedules(force: true)`.
- Jika permission tidak allowed, setting disinkronkan off dan semua notifikasi dibatalkan.
- Notification Health Center juga refresh diagnostics saat kembali dari system settings.
- Tambah source/widget guard tests untuk lifecycle, iOS request, Android settings shortcuts, exact alarm, dan reschedule hooks.

## Non-Goals
- Tidak memaksa OS permission prompt asli di unit/widget test.
- Tidak menambah plugin native baru.
- Tidak mengubah Android/iOS native channel behavior yang sudah berjalan.

## Validation
- `flutter analyze` no issues.
- `flutter test` full pass.
- QA docs menjelaskan device-level permission flow tetap perlu dibuktikan manual/integration di perangkat.
