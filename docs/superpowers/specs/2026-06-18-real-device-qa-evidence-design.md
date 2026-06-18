# Real Device QA Evidence Design

## Goal
Mengumpulkan evidence device/integration terbaru untuk Solatify setelah automated readiness Phase 16.

## Scope
- Jalankan integration test pada Android physical `2602BPC18G` dan iOS wireless `Satelit88` jika toolchain/perangkat stabil.
- Catat hasil pass/fail/blocked secara jujur di release signoff.
- Jalankan profile/devices command yang aman untuk mendukung performance evidence awal tanpa mengklaim observasi visual yang tidak dilakukan.
- Update `docs/qa/release-signoff.md` dan `docs/qa/performance-baseline-template.md`.

## Non-Goals
- Tidak mengklaim notification delivery terlihat jika tidak diamati fisik.
- Tidak mengunggah ke Play Console/App Store.
- Tidak membuat signed release artifact.

## Validation
- Semua command evidence dibaca sebelum dicatat.
- Jika command gagal karena device/tooling, status ditulis sebagai blocked dengan output ringkas.
