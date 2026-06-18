# Full Typed Navigation Cleanup Design

## Goal
Bersihkan sisa navigasi internal hardcoded agar route aplikasi memakai `AppRoutes` secara konsisten.

## Scope
- Migrasi `context.go`, `context.push`, dan direct internal route references yang masih memakai string literal.
- Pertahankan literal route di `AppRoutes` sebagai single source of truth.
- Pertahankan URL/path eksternal seperti Google Maps karena bukan route aplikasi.
- Update source smoke test untuk mencegah regresi pada hardcoded route internal.

## Non-Goals
- Tidak mengubah struktur GoRouter atau shell navigation.
- Tidak mengubah behavior UI, notification, Quran reading mode, atau search.
- Tidak menambah typed route generator/dependency baru.

## Validation
- `flutter analyze` no issues.
- `flutter test` full pass.
- Source test memastikan file prioritas memakai `AppRoutes` untuk route internal.
