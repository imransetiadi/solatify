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
- 🔔 **Alarm Adzan Otomatis** — Notifikasi lokal waktu salat berjalan offline menggunakan `flutter_local_notifications`, channel Android khusus adzan, timezone lokasi salat, dan scheduling untuk sisa salat hari ini plus Subuh besok.
- 📖 **Al-Qur'an & Konten Islami** — Surah Al-Qur'an, bookmark/terakhir dibaca, Asmaul Husna, doa harian, dzikir pagi-petang, kalender Hijriah, tips islami, dan tuntunan salat lengkap.
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
- **Clean Architecture** per fitur: `data`, `domain`, dan `presentation`.
- **flutter_local_notifications** untuk notifikasi salat lokal dan alarm adzan.
- **Static local data source** untuk konten islami offline seperti dzikir dan tuntunan salat.

## ⚡ Performa & Responsiveness

Solatify menggunakan beberapa tuning agar aplikasi tetap ringan:

- Konfigurasi performa terpusat di `lib/core/performance/performance_tuning.dart`.
- Efek `GlassContainer` dibatasi agar visual tetap konsisten tanpa blur berlebihan.
- Countdown waktu salat memakai tick 1 detik, bukan sub-second rebuild.
- Audit ulang scheduler notifikasi dibuat lebih hemat, sementara perubahan lokasi/jadwal tetap memicu reschedule langsung.
- List panjang memakai builder/lazy rendering pada fitur konten utama.
- Header dan spacing layar konten islami disetel agar tetap nyaman saat scroll di layar compact.

## 🔔 Catatan Notifikasi Android

Untuk Android, notifikasi salat memakai channel `Prayer Times Adhan` versi baru (`prayer_times_adhan_channel_v2`) agar perangkat tidak terjebak konfigurasi channel lama. Agar alarm adzan muncul di system tray:

1. Install build terbaru dan buka aplikasi minimal sekali.
2. Berikan izin notifikasi (`POST_NOTIFICATIONS`) pada Android 13+.
3. Aktifkan izin exact alarm jika Android menampilkan pengaturan tersebut.
4. Pastikan channel `Prayer Times Adhan` aktif di system notification settings.
5. Tunggu waktu salat berikutnya untuk memverifikasi notifikasi real prayer-time.

## ✅ QA & Kesiapan Build

Status branch terbaru sudah diverifikasi dengan:

- `flutter analyze --no-pub` — no issues.
- `flutter test --no-pub` — 71/71 tests passed.
- `flutter build apk --debug --no-pub` — Android debug APK berhasil dibuat.
- `flutter build ios --no-codesign` — iOS app berhasil dibuat tanpa codesign.

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
