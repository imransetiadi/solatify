# Solatify Roadmap

Roadmap ini mencatat fokus teknis setelah `v1.0.0-rc1`. Prioritas utama tetap menjaga fitur inti Solatify stabil: jadwal salat, adzan/notifikasi, qibla, Quran, konten islami, tracker, dan widget.

## Current Release Candidate

- Current RC: `v1.0.0-rc1`
- Release: https://github.com/imransetiadi/solatify/releases/tag/v1.0.0-rc1
- Tester guide: `RELEASE_TESTING.md`
- Tester message template: `TESTER_MESSAGE.md`

## Near-Term Priorities

### 1. RC1 Feedback Triage

Goal: kumpulkan feedback tester dan tentukan apakah perlu `v1.0.0-rc2`.

Checklist:

- Kumpulkan laporan bug dari tester.
- Kelompokkan berdasarkan fitur: startup, jadwal salat, notifikasi, qibla, Quran, tracker, widget.
- Prioritaskan crash, notification failure, salah jadwal, dan permission issue.
- Fix bug critical/high sebelum lanjut upgrade besar.
- Buat RC baru hanya jika ada perubahan app binary.

### 2. Riverpod 3 Spike

Goal: evaluasi effort upgrade `flutter_riverpod` dari v2 ke v3 tanpa mengganggu stabilitas release.

Why:

- `flutter_riverpod` v2 masih berjalan stabil, tapi v3 sudah resolvable.
- Upgrade state management bisa berdampak luas ke provider, tests, dan lifecycle.

Plan:

- Kerjakan di branch terpisah.
- Upgrade `flutter_riverpod` dan dependency terkait.
- Jalankan `flutter analyze --no-pub` untuk melihat breakage API.
- Fix provider/test secara bertahap, mulai dari compile errors.
- Jalankan focused tests untuk fitur provider-heavy:
  - prayer schedule
  - notifications
  - settings
  - tracker
  - quran
- Jalankan full `flutter test --no-pub`.
- Build debug APK dan lakukan smoke test di Android device.

Exit criteria:

- Analyzer clean.
- Full tests pass.
- Debug build pass.
- Tidak ada regression di jadwal salat, notification scheduling, settings persistence, dan home countdown.

Risk:

- Medium/high karena menyentuh state management utama.
- Jangan digabung dengan perubahan fitur lain.

### 3. Qibla Plugin Replacement Spike

Goal: cari alternatif untuk `flutter_compass_v2` agar mengurangi future build warning dan risiko maintenance.

Why:

- `flutter_compass_v2` masih memunculkan warning Swift Package Manager di iOS.
- Plugin juga termasuk daftar warning Kotlin Gradle Plugin di Android build.
- Qibla adalah fitur sensor-based, jadi perlu validasi device nyata.

Plan:

- Audit penggunaan `flutter_compass_v2` saat ini di fitur qibla.
- Cari kandidat pengganti yang aktif maintained dan mendukung Android/iOS.
- Buat adapter/domain wrapper agar UI qibla tidak bergantung langsung ke plugin.
- Implement spike di branch terpisah.
- Test fallback saat sensor tidak tersedia.
- Smoke test di Android device dengan rotasi fisik.
- Jika memungkinkan, test juga di iOS device.

Exit criteria:

- Qibla screen tetap render tanpa crash.
- Sensor heading bergerak di Android real device.
- Fallback tetap tampil saat sensor unavailable.
- Warning build berkurang atau dependency lebih maintainable.

Risk:

- Medium karena sensor behavior berbeda antar device.
- Wajib real-device QA, bukan hanya widget test.

### 4. Kotlin Gradle Plugin Warning Cleanup

Goal: mengurangi atau menghilangkan warning future Flutter build terkait plugin yang masih apply Kotlin Gradle Plugin.

Current warning plugins:

- `audio_session`
- `flutter_compass_v2`
- `package_info_plus`
- `share_plus`

Current status:

- Build APK/AAB masih sukses.
- Warning belum fixable lewat safe dependency upgrade saat audit `v1.0.0-rc1`.
- Beberapa plugin adalah transitive dependency, jadi perlu lihat parent dependency juga.

Plan:

- Re-run `flutter pub outdated` secara berkala.
- Upgrade safe patch/minor versions saat tersedia.
- Untuk transitive plugin, cek dependency parent:
  - `audio_session` biasanya datang dari audio/adzan playback dependency.
  - `package_info_plus` bisa datang dari plugin plus ecosystem atau Flutter tool registration.
- Jika warning tetap ada, buka issue upstream atau tunggu plugin migration ke Built-in Kotlin.
- Hindari fork plugin kecuali build benar-benar mulai gagal.

Exit criteria:

- Build warning berkurang atau hilang.
- APK/AAB release tetap sukses.
- Tidak ada regression di audio adzan, share tracker, package info, dan qibla.

Risk:

- Low/medium untuk patch upgrade.
- Medium/high jika harus mengganti plugin atau fork.

## Suggested Order

1. Finish RC1 tester feedback cycle.
2. Fix critical/high bugs and cut `v1.0.0-rc2` if needed.
3. Spike qibla plugin replacement because it targets both Qibla behavior and warning cleanup.
4. Spike Riverpod 3 separately.
5. Revisit KGP warnings after upstream package updates.

## Release Rules

- Do not mix large dependency upgrades with feature work.
- Do not cut a new RC for docs-only changes.
- Cut a new RC when app binary changes after tester feedback or dependency changes.
- Always verify with:

```bash
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --release --no-pub
flutter build appbundle --release --no-pub
```

- For notification/qibla/widget changes, always run Android real-device smoke test.
