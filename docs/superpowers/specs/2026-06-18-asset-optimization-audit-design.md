# Asset Optimization Audit Design

## Goal
Membuat audit asset dan guardrails ukuran file agar performa startup/scroll tidak regress karena asset membengkak.

## Scope
- Audit ukuran dan penggunaan asset di `assets/`.
- Tambah test budget untuk asset runtime dan launcher/source asset.
- Dokumentasikan asset yang terpakai runtime, asset generator launcher, dan kandidat cleanup.
- Tidak mengubah pixel/image asset pada fase ini agar kualitas logo/icon tetap aman.

## Findings
- `assets/images/masjid_nabawi.svg` dipakai runtime oleh Home, Splash, dan Onboarding; ukuran sekitar 2 KB.
- `assets/icon.jpg` terdaftar di `pubspec.yaml`; ukuran sekitar 26 KB.
- `assets/best_logo.png` dipakai `flutter_launcher_icons`; ukuran sekitar 7 KB.
- `assets/icon_white.png` ukuran sekitar 153 KB dan belum ditemukan referensi runtime/pubspec; kandidat review manual sebelum remove.

## Validation
- `flutter analyze` no issues.
- `flutter test` full pass.
- Asset budget tests pass.
