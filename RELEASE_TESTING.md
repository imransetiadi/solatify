# Solatify Release Testing Guide

Panduan ini dipakai untuk internal testing Solatify tanpa Google Play Store. Tester cukup mengunduh APK dari GitHub Release, install manual di Android, lalu menjalankan checklist fitur utama.

## Download APK

Release candidate terbaru:

- GitHub Release: https://github.com/imransetiadi/solatify/releases/tag/v1.0.0-rc1
- File yang dipakai tester Android: `app-release.apk`

Checksum APK v1.0.0-rc1:

```text
aa23037e82658d4b489cc43e87d90591c96929e0adc54ddc0cca10b572b22c44
```

## Cara Install Android

1. Buka link GitHub Release dari HP Android.
2. Download `app-release.apk`.
3. Jika Android menampilkan peringatan, izinkan install dari browser/file manager yang dipakai.
4. Install APK.
5. Buka Solatify dari launcher.
6. Berikan izin lokasi dan notifikasi jika diminta.

Catatan: Karena APK belum dari Play Store, Android bisa menampilkan warning install manual. Ini normal untuk internal testing.

## Checklist Smoke Test

### Startup dan Home

- App bisa dibuka dari launcher tanpa crash.
- Lokasi tampil sesuai area tester atau fallback manual terlihat jelas.
- Jadwal salat muncul dan waktunya masuk akal.
- Countdown salat berikutnya berjalan.
- App tetap aman setelah ditutup dan dibuka lagi.

### Jadwal Salat dan Notifikasi

- Buka halaman jadwal salat.
- Toggle adzan/reminder bisa diubah.
- Perubahan setting tetap tersimpan setelah app restart.
- Buka Settings lalu jalankan test notification.
- Pastikan notifikasi test muncul di device.

### Qibla

- Buka fitur kiblat.
- Kompas bergerak saat HP diputar.
- Jika sensor/izin bermasalah, fallback atau pesan error tampil jelas dan app tidak crash.

### Quran dan Konten Islami

- Buka Quran, pilih salah satu surah.
- Coba ubah ukuran font Arab jika tersedia.
- Coba search konten islami.
- Pastikan halaman tidak overflow atau crash.

### Tracker dan Settings

- Buka tracker ibadah.
- Coba centang item checklist.
- Buka Settings dan ubah salah satu setting ringan.
- Restart app dan pastikan setting masih tersimpan.

### Android Widget

- Tambahkan widget Solatify ke home screen Android.
- Pastikan waktu salat tampil.
- Buka app, tunggu jadwal tersinkron, lalu cek widget lagi.

## Format Laporan Bug

Kirim laporan dengan format berikut:

```text
Device:
Android version:
Solatify version: v1.0.0-rc1
Fitur yang dites:
Langkah reproduksi:
Hasil yang terjadi:
Hasil yang diharapkan:
Screenshot/video:
Catatan tambahan:
```

Contoh:

```text
Device: Redmi Note 13
Android version: Android 14
Solatify version: v1.0.0-rc1
Fitur yang dites: Settings > Test notification
Langkah reproduksi:
1. Buka Settings
2. Tap Test Notification
Hasil yang terjadi: Tidak muncul notifikasi
Hasil yang diharapkan: Muncul notifikasi test Solatify
Screenshot/video: terlampir
Catatan tambahan: Izin notifikasi sudah aktif
```

## Known Notes

- Distribusi saat ini menggunakan APK GitHub Release, bukan Google Play Store.
- Android mungkin menampilkan warning karena install manual dari APK.
- Build masih menampilkan warning future Kotlin Gradle Plugin dari beberapa plugin upstream, tetapi release APK/AAB berhasil dibuat.
- Jika notifikasi tidak muncul, cek izin notifikasi Android dan pengaturan battery optimization device.
