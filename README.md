# Solatify

<p align="center">
  <img src="assets/images/masjid_nabawi.svg" width="120" alt="Solatify Logo">
</p>
<p align="center">
  <b>Pendamping Ibadah Harian Muslim yang modern, presisi, ringan, dan responsif.</b>
</p>

---

**Solatify** adalah aplikasi Flutter untuk membantu aktivitas ibadah harian: jadwal salat, alarm adzan, Al-Qur'an, tuntunan salat, kiblat, masjid terdekat, konten islami, tracker ibadah, dan pengaturan personal. Aplikasi dibangun dengan pola **Clean Architecture feature-first**, state management Riverpod, penyimpanan lokal Hive, dan fokus pada pengalaman yang stabil di Android maupun iOS.

## ✨ Fitur Utama

- 🕋 **Jadwal Salat Akurat** — Kalkulasi waktu salat berbasis `adhan` dan `timezone`, mendukung metode Kemenag dan metode internasional lain, termasuk koreksi manual per waktu salat.
- 🔔 **Alarm Adzan Otomatis** — Notifikasi lokal waktu salat berjalan offline dengan toggle per waktu salat, pengingat sebelum salat, pilihan mode suara adzan/beep/silent, riwayat status scheduling, timezone lokasi salat, dan diff-based scheduling untuk sisa salat hari ini plus Subuh besok.
- 📖 **Al-Qur'an & Konten Islami** — Surah Al-Qur'an, reading mode dengan kontrol ukuran font Arab, toggle transliterasi/terjemahan, progress surah, global search konten islami untuk doa/dzikir/Asmaul Husna/tips/tuntunan salat, bookmark/terakhir dibaca, kalender Hijriah, dan tuntunan salat lengkap.
- 🤲 **Tuntunan Salat Offline** — Urutan salat praktis dengan bacaan Arab, latin, arti Indonesia, catatan ringkas, doa qunut Subuh opsional, serta dzikir setelah salat.
- 🧭 **Arah Kiblat** — Kompas kiblat berbasis sensor perangkat, dengan fallback UI ketika sensor tidak tersedia.
- 🕌 **Masjid Terdekat** — Pencarian masjid sekitar, tombol lihat peta, dan rute melalui aplikasi peta/browser perangkat.
- 📈 **Tracker Ibadah** — Checklist ibadah harian dan statistik mingguan untuk membantu konsistensi ibadah.
- 🌙 **Tema Responsif** — Light/dark mode, layout adaptif phone/tablet, serta komponen visual yang dioptimalkan agar tetap ringan saat scroll dan navigasi.

## 🛠 Arsitektur & Teknologi

- **Flutter + Dart** untuk aplikasi lintas platform Android dan iOS.
- **Riverpod** untuk state management yang eksplisit dan testable.
- **Hive** untuk cache lokal jadwal, pengaturan, tracker, dan data Al-Qur'an.
- **GoRouter** untuk navigasi deklaratif.
- **Typed route constants** di `AppRoutes` agar path internal seperti jadwal, Qur'an, konten islami, dan Settings tidak tersebar sebagai string literal.
- **Clean Architecture** per fitur: `data`, `domain`, dan `presentation`.
- **Notification domain planner** memisahkan perencanaan jadwal adzan/reminder dari provider UI agar flow notifikasi lebih testable.
- **flutter_local_notifications** untuk notifikasi salat lokal dan alarm adzan.
- **Static local data source** untuk konten islami offline seperti dzikir dan tuntunan salat.

## ⚡ Performa & Responsiveness

Solatify menggunakan beberapa tuning agar aplikasi tetap ringan:

- Konfigurasi performa terpusat di `lib/core/performance/performance_tuning.dart`.
- Budget cold start, warm resume, frame build/raster, dan compact smoke target dijaga lewat test agar baseline performa tidak drift diam-diam.
- Asset runtime dan launcher source dijaga lewat budget test agar gambar/SVG tidak membengkak tanpa audit.
- Efek `GlassContainer` dibatasi agar visual tetap konsisten tanpa blur berlebihan.
- Transisi antar menu memakai fade, slide mikro, dan scale ringan agar perpindahan fitur terasa seamless tanpa animasi berat.
- Empty, loading, error, dan permission states memakai pola visual `SolatifyStateView` agar feedback lintas fitur lebih konsisten.
- Compact-width widget smoke tests menjaga Home, Jadwal, Qur'an, Settings, dan Konten Islami tetap aman di lebar ponsel kecil.
- Haptic feedback ringan ditambahkan pada navigasi, toggle tracker/settings, bookmark Qur'an, dan aksi menu agar interaksi terasa lebih native.
- Countdown waktu salat memakai tick 1 detik, bukan sub-second rebuild.
- Scheduler notifikasi memakai sync plan, filter per waktu salat, dan post-permission refresh agar hanya membatalkan/menjadwalkan ulang alarm yang berubah, sementara perubahan lokasi/jadwal/izin tetap memicu reschedule langsung.
- List panjang memakai builder/lazy rendering pada fitur konten utama.
- Header, kartu menu, dan spacing layar fitur diringkas agar tidak ada teks berulang dan tetap nyaman di layar compact.
- Layar konten/detail prioritas memakai `SolatifyScreenScaffold` untuk pola AppBar, background islami, responsive center, dan padding yang konsisten.

## 🔔 Catatan Notifikasi

Notifikasi salat mendukung kontrol yang lebih granular di Settings:

- Toggle per waktu salat untuk mengaktifkan hanya Subuh, Magrib, atau kombinasi lain.
- Pengingat sebelum salat, termasuk opsi 10 menit sebelum waktu salat.
- Mode suara `adhan`, `beep`, atau `silent notification` sesuai preferensi pengguna.
- Verifikasi izin setelah kembali dari Settings dan reschedule otomatis saat izin berubah.
- Settings dan Notification Health Center memverifikasi ulang izin saat app kembali aktif dari system settings, lalu reschedule atau cancel otomatis sesuai status terbaru.
- Riwayat notifikasi menyimpan status terakhir terjadwal/gagal untuk debugging dan transparansi.
- Notification Health Center di Settings membantu cek izin, pending schedule, riwayat terakhir, kirim test notifikasi, dan reschedule manual.

Untuk Android, notifikasi salat memakai channel `Prayer Times Adhan` (`prayer_times_adhan_channel`), `Prayer Times Beep` (`prayer_times_beep_channel`), dan `Prayer Times Silent` (`prayer_times_silent_channel`) dengan native alarm fallback yang ikut menghormati mode `adhan`, `beep`, `silent`, dan reminder agar alarm muncul di system tray secara lebih andal:

1. Install build terbaru dan buka aplikasi minimal sekali.
2. Berikan izin notifikasi (`POST_NOTIFICATIONS`) pada Android 13+.
3. Aktifkan izin exact alarm jika Android menampilkan pengaturan tersebut.
4. Pastikan channel notifikasi yang dipilih aktif di system notification settings.
5. Tunggu waktu salat berikutnya untuk memverifikasi notifikasi real prayer-time.

## ✅ QA & Kesiapan Build

Status branch terbaru sudah diverifikasi dengan:

- `flutter test` — 138/138 tests passed.
- `flutter analyze` — no issues.
- `flutter test -d emulator-5554 integration_test/app_test.dart` — 2/2 integration tests passed di Android emulator.
- `flutter test -d 00008140-000518E42EB8401C integration_test/app_test.dart` — 2/2 integration tests passed di iPhone `Satelit88`.
- `flutter build apk --debug` — Android debug APK berhasil dibuat di `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter build ios --no-codesign` — iOS app berhasil dibuat di `build/ios/iphoneos/Runner.app`.

Dokumen QA tambahan tersedia di `docs/qa/`, termasuk runbook, checklist Android/iOS, performance checklist, dan release signoff.

## 💻 Memulai

1. **Clone repository**
   ```bash
   git clone https://github.com/imransetiadi/solatify.git
   cd solatify
   ```

2. **Install dependensi**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 🧪 Testing

Jalankan test utama:

```bash
flutter test --no-pub
```

Jalankan analyzer:

```bash
flutter analyze --no-pub
```

Build Android debug APK:

```bash
flutter build apk --debug
```

Build iOS tanpa codesign:

```bash
flutter build ios --no-codesign
```

## 📜 Lisensi

Proyek ini bersifat tertutup (Proprietary). Hak cipta dilindungi.
