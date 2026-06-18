# Performance Profiling Baseline Design

## Goal
Membuat baseline profiling golden path yang repeatable dan guard test deterministik agar performa Solatify tidak regress tanpa bukti.

## Scope
- Tambah konstanta budget di `PerformanceTuning` untuk cold start, warm resume, frame budget, dan compact smoke baseline.
- Tambah unit test budget agar perubahan performa penting terlihat dalam test suite.
- Update QA docs dengan matrix golden path: cold start, Home scroll, Quran list, Schedule, dan menu switching.
- Update README dengan status Phase 13 dan test count.

## Non-Goals
- Tidak mengklaim profile-mode device numbers tanpa menjalankan device profiling.
- Tidak mengubah UI runtime atau native notification behavior.
- Tidak melakukan asset optimization; itu masuk Phase 14.

## Validation
- `flutter analyze` no issues.
- `flutter test` full pass.
- QA docs menyatakan evidence profile-mode harus dikumpulkan manual/device sebelum release claim.
