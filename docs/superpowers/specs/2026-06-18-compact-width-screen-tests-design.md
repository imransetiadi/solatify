# Compact Width Screen Tests Design

## Goal
Tambahkan coverage visual/layout untuk layar utama pada lebar compact agar regresi overflow dan state awal bisa terdeteksi otomatis.

## Scope
- Tambah widget smoke tests dengan `setSurfaceSize` pada ukuran compact 360x780.
- Target layar: Home, Jadwal, Quran, Settings, Konten Islami.
- Verifikasi tiap layar render tanpa Flutter exception dan title/anchor utama terlihat.
- Dokumentasikan bahwa fase ini adalah baseline compact-width smoke; golden image literal bisa ditambahkan setelah baseline asset CI stabil.

## Non-Goals
- Tidak menambahkan golden PNG besar pada fase ini.
- Tidak mengubah UI runtime.
- Tidak melakukan profiling runtime profile mode.

## Validation
- `flutter analyze` no issues.
- `flutter test` full pass.
- Test count README diperbarui.
