# Solatify Tester Message Template

Template ini bisa di-copy ke WhatsApp, Telegram, atau chat internal untuk membagikan APK release candidate ke tester.

## Versi Singkat

```text
Assalamu'alaikum 👋

Aku lagi testing Solatify v1.0.0-rc1. Kalau berkenan, tolong bantu coba APK ini ya.

Download APK:
https://github.com/imransetiadi/solatify/releases/tag/v1.0.0-rc1

Pilih file: app-release.apk

Yang dicek cepat:
1. App bisa dibuka tanpa crash
2. Lokasi dan jadwal salat muncul benar
3. Countdown salat jalan
4. Test notification di Settings muncul
5. Qibla/kompas jalan atau fallback aman
6. Android widget tampil di home screen

Kalau ada bug, kirim:
- Device + Android version
- Fitur yang bermasalah
- Langkah reproduksi
- Screenshot/video kalau ada

Makasih banyak 🙏
```

## Versi Lengkap

```text
Assalamu'alaikum 👋

Aku lagi testing Solatify v1.0.0-rc1 sebelum rilis lebih luas. Untuk sekarang belum lewat Play Store, jadi install manual dari APK GitHub Release.

Download:
https://github.com/imransetiadi/solatify/releases/tag/v1.0.0-rc1

File yang di-download:
app-release.apk

Cara install:
1. Buka link dari HP Android
2. Download app-release.apk
3. Kalau Android minta izin install dari browser/file manager, izinkan dulu
4. Install APK
5. Buka Solatify dari launcher
6. Izinkan lokasi dan notifikasi kalau diminta

Checklist yang perlu dites:
- App bisa dibuka tanpa crash
- Home menampilkan lokasi, jadwal salat, dan countdown
- Halaman jadwal salat tampil normal
- Settings > test notification berhasil muncul
- Toggle adzan/reminder bisa diubah dan tersimpan setelah app restart
- Qibla/kompas bergerak saat HP diputar, atau fallback tampil aman
- Quran/konten islami bisa dibuka tanpa crash
- Tracker bisa dicentang
- Android widget bisa ditambahkan ke home screen dan menampilkan waktu salat

Format laporan bug:
Device:
Android version:
Solatify version: v1.0.0-rc1
Fitur yang dites:
Langkah reproduksi:
Hasil yang terjadi:
Hasil yang diharapkan:
Screenshot/video:
Catatan tambahan:

Contoh:
Device: Redmi Note 13
Android version: Android 14
Solatify version: v1.0.0-rc1
Fitur yang dites: Settings > Test notification
Langkah reproduksi: Tap Settings, lalu tap Test Notification
Hasil yang terjadi: Notifikasi tidak muncul
Hasil yang diharapkan: Notifikasi test Solatify muncul
Screenshot/video: terlampir
Catatan tambahan: Izin notifikasi sudah aktif

Makasih banyak sudah bantu test 🙏
```

## Link Pendukung

- Release: https://github.com/imransetiadi/solatify/releases/tag/v1.0.0-rc1
- Panduan tester lengkap: `RELEASE_TESTING.md`
