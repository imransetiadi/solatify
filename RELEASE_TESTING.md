# Solatify Release Testing Guide

Panduan ini dipakai untuk internal testing Solatify tanpa Google Play Store. Tester cukup mengunduh APK dari GitHub Release, install manual di Android, lalu menjalankan checklist fitur utama.

## Download APK

Release candidate terbaru:

- GitHub Release: https://github.com/imransetiadi/solatify/releases/tag/v1.0.0-rc5
- File yang dipakai tester Android: `solatify-1.0.0.apk`

Checksum SHA-256 APK tercantum di halaman GitHub Release di atas.

Sudah memasang rc3 atau rc4? APK rc5 bisa langsung dipasang di atasnya tanpa uninstall, dan data aplikasi tetap tersimpan.

## Cara Install Android

1. Buka link GitHub Release dari HP Android.
2. Download `solatify-1.0.0.apk`.
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

### Jadwal Salat Kemenag dan Koreksi Waktu

- Dengan metode Kemenag, bandingkan jadwal hari ini dengan jadwal resmi Kemenag untuk kotamu (misalnya di bimasislam.kemenag.go.id). Selisihnya paling banyak 1 menit.
- Di layar Jadwal ada catatan "Metode Kemenag, sudah termasuk ihtiyat resmi."
- Buka Pengaturan > Koreksi Waktu Salat, ubah salah satu waktu: dialog menampilkan jam standar dan jam hasil koreksi.
- Coba memajukan Magrib (nilai minus): muncul peringatan soal waktu berbuka puasa.
- Kembalikan semua koreksi ke 0 lewat tombol "Kembalikan semua koreksi".

### Masjid Terdekat

- Buka menu Masjid Terdekat dengan GPS dan internet aktif.
- Daftar masjid muncul dalam beberapa detik, urut dari yang terdekat, lengkap dengan alamat.
- Tidak ada gereja, pura, vihara, atau tempat ibadah lain di daftar.
- Tombol peta dan rute membuka aplikasi peta.
- Matikan internet lalu buka lagi: hasil terakhir tetap tampil dengan pesan yang jelas.

### Android Widget

- Tambahkan widget Solatify ke home screen Android.
- Pastikan waktu salat tampil.
- Buka app, tunggu jadwal tersinkron, lalu cek widget lagi.

## Format Laporan Bug

Kirim laporan dengan format berikut:

```text
Device:
Android version:
Solatify version: v1.0.0-rc5
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
Solatify version: v1.0.0-rc5
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
- APK ditandatangani dengan debug key untuk uji coba. Versi Play Store nanti memakai kunci rilis dan perlu uninstall versi uji coba terlebih dahulu.
- Jika notifikasi tidak muncul, cek izin notifikasi Android dan pengaturan battery optimization device.
