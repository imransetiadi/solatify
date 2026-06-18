# Release Readiness Evidence Design

## Goal
Mengumpulkan evidence release readiness terbaru setelah Phase 1-15 tanpa mengklaim device QA yang belum dijalankan.

## Scope
- Jalankan automated gates: `flutter analyze`, `flutter test`, device listing, Android debug build, dan iOS no-codesign build bila toolchain tersedia.
- Update `docs/qa/release-signoff.md` dengan commit/branch/test count/build evidence terbaru.
- Tandai real iOS/Android permission delivery, exact alarm, map route, dan profile-mode evidence sebagai pending manual device evidence jika tidak dijalankan di perangkat.
- Update README bila test/build evidence berubah.

## Non-Goals
- Tidak mengunggah build ke store.
- Tidak membuat signing certificate/provisioning profile.
- Tidak mengklaim real notification delivery tanpa device evidence.

## Validation
- Command output terbaru dibaca sebelum status ditulis.
- `git diff --check` clean.
- Commit dan push hanya dokumen/spec yang relevan.
