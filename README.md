# Solatify

Solatify adalah aplikasi pendamping ibadah harian berbasis Flutter. Aplikasi ini dirancang untuk membantu pengguna memantau waktu salat, membaca Al-Qur'an, mencatat ibadah harian, mencari arah kiblat, menemukan masjid terdekat, dan mengakses konten Islami ringan dalam satu pengalaman yang rapi dan responsif.

Core experience aplikasi dibuat offline-first untuk data dan preferensi utama, dengan dukungan lokasi, notifikasi, peta, dan sensor perangkat untuk fitur yang membutuhkan kemampuan native.

## Tampilan UI

Solatify memakai desain bernuansa Islami modern dengan fokus pada keterbacaan dan penggunaan harian.

- Visual utama memakai aksen hijau, warna hangat, efek glass container, dan dekorasi Islamic background.
- Navigasi utama memakai bottom navigation di mobile dan layout responsif untuk layar yang lebih lebar.
- Dashboard menampilkan salam, lokasi aktif, tanggal, countdown salat berikutnya, dan status salat hari ini.
- Setiap layar dibuat sebagai workflow langsung, bukan landing page, sehingga pengguna bisa langsung mencatat, membaca, mencari, atau mengatur preferensi.
- Aplikasi mendukung light theme, dark theme, dan system theme.
- Text scale dibatasi agar layout tetap stabil ketika ukuran teks sistem berubah.

## Fitur Utama

### Jadwal Salat

- Perhitungan waktu salat berdasarkan lokasi pengguna.
- Dukungan lokasi otomatis via GPS dan pilihan kota manual.
- Metode kalkulasi dapat diatur dari pengaturan.
- Offset waktu salat untuk Subuh, Dzuhur, Ashar, Magrib, dan Isya.
- Cache jadwal harian agar data tetap tersedia saat offline.

### Dashboard Harian

- Countdown menuju salat berikutnya.
- Informasi waktu salat aktif.
- Ringkasan jadwal salat hari ini.
- Tombol cepat untuk mencatat status salat.

### Jurnal Salat

- Catat status salat harian.
- Status yang tersedia: tepat waktu, terlambat/masbuq, terlewat, dan reset.
- Riwayat disimpan lokal dengan Hive.

### Pengingat dan Adzan

- Pengingat waktu salat menggunakan `flutter_local_notifications`.
- Pengaturan aktif/nonaktif notifikasi.
- Dukungan pilihan suara adzan atau mode silent.
- Service notifikasi dibuat lazy dan aman untuk cold start iOS.

### Al-Qur'an

- Daftar surah.
- Halaman detail surah.
- Bookmark ayat.
- Last read verse.
- Pencarian surah.
- Cache data index dan detail surah.

### Kiblat

- Arah kiblat berbasis sensor kompas perangkat.
- Cocok diuji di physical device karena simulator tidak memiliki sensor kompas nyata.

### Masjid Terdekat

- Integrasi Google Maps untuk tampilan peta.
- Dirancang untuk eksplorasi lokasi masjid di sekitar pengguna.

### Konten Islami

- Asmaul Husna.
- Doa harian.
- Kalender Hijriah dan event Islami.
- Tips Islami.
- Dzikir harian.

### Onboarding dan Pengaturan

- Splash screen dan onboarding flow.
- Pengaturan tema.
- Pengaturan bahasa.
- Pengaturan metode kalkulasi.
- Pengaturan notifikasi dan suara adzan.
- Pengaturan offset waktu salat.

## Tech Stack

- Flutter dan Dart.
- Riverpod untuk state management.
- GoRouter untuk navigasi.
- Hive dan SharedPreferences untuk penyimpanan lokal.
- `adhan` untuk kalkulasi waktu salat.
- Geolocator dan Geocoding untuk lokasi.
- Flutter Compass untuk arah kiblat.
- Google Maps Flutter untuk peta.
- Flutter Local Notifications untuk pengingat.
- Workmanager untuk dukungan background task.
- HTTP untuk akses data remote saat diperlukan.

## Struktur Proyek

```text
lib/
+-- core/
|   +-- database/          # Hive service dan helper storage lokal
|   +-- navigation/        # Router dan layout navigasi utama
|   +-- theme/             # Theme light/dark aplikasi
|   +-- utils/             # Location service dan utilitas umum
|   +-- widgets/           # Widget reusable dan dekorasi UI
+-- features/
    +-- asmaul_husna/      # 99 nama Allah
    +-- dhikr/             # Dzikir harian
    +-- duas/              # Doa harian
    +-- hijri_calendar/    # Kalender Hijriah
    +-- home/              # Dashboard dan countdown salat
    +-- islamic_content/   # Hub konten Islami
    +-- islamic_tips/      # Tips Islami
    +-- mosque/            # Masjid terdekat dan peta
    +-- onboarding/        # Splash, get started, onboarding
    +-- prayer_schedule/   # Jadwal dan kalkulasi waktu salat
    +-- qibla/             # Kompas kiblat
    +-- quran/             # Quran repository, model, dan UI
    +-- reminder/          # Notification service
    +-- settings/          # Preferensi pengguna
    +-- tracker/           # Jurnal salat
```

## Main Screens

- `Home`: salam, lokasi, tanggal, countdown salat, jadwal hari ini, dan catatan salat.
- `Jadwal`: jadwal salat lengkap dan pengaturan lokasi.
- `Qur'an`: daftar surah, pencarian, bookmark, dan halaman baca.
- `Konten`: pintu masuk ke Asmaul Husna, doa, kalender Hijriah, dzikir, dan tips.
- `Kiblat`: arah kiblat berbasis kompas.
- `Jurnal`: riwayat dan status ibadah salat.
- `Masjid`: peta dan lokasi masjid terdekat.
- `Pengaturan`: tema, metode kalkulasi, notifikasi, adzan, dan offset waktu salat.

## Requirements

- Flutter SDK dengan Dart `^3.12.1`.
- Xcode untuk build iOS.
- Android Studio untuk build Android.
- Physical device direkomendasikan untuk fitur lokasi, kompas, notifikasi, dan peta.

## Kompatibilitas Platform

- iOS minimum: `13.0`.
- iPhone dan iPad didukung selama menjalankan iOS/iPadOS 13.0 atau lebih baru.
- Fitur kompas kiblat membutuhkan perangkat fisik dengan sensor kompas.
- Fitur lokasi, notifikasi, dan peta membutuhkan permission platform terkait.

Cek environment lokal:

```bash
flutter doctor
```

## Cara Menjalankan

Clone repository:

```bash
git clone https://github.com/imransetiadi/solatify.git
cd solatify
```

Install dependency:

```bash
flutter pub get
```

Run ke device aktif:

```bash
flutter run
```

Run ke device tertentu:

```bash
flutter devices
flutter run -d <DEVICE_ID>
```

## Build

Android:

```bash
flutter build apk --release
```

iOS physical device:

```bash
flutter build ios --release
flutter install --release -d <DEVICE_ID>
```

iOS simulator:

```bash
flutter build ios --simulator
flutter run -d <SIMULATOR_ID>
```

## Google Maps dan Places API

Fitur `Masjid Terdekat` memakai GPS perangkat dan Google Places Nearby Search dengan filter `type=mosque`. Data yang tampil bukan dummy: hasil dipilih dari tempat yang memiliki tipe `mosque` dan status `OPERATIONAL` dari Google Places.

API yang perlu diaktifkan di Google Cloud Console:

- Maps SDK for Android.
- Maps SDK for iOS.
- Places API.

Jalankan aplikasi dengan API key untuk query Places:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=API_KEY_ANDA
```

Android akan memakai nilai `GOOGLE_MAPS_API_KEY` dari `--dart-define` untuk Maps SDK dan Places API.

Untuk iOS, buat file lokal dari template berikut sebelum build:

```bash
cp ios/Flutter/MapsKey.xcconfig.example ios/Flutter/MapsKey.xcconfig
```

Lalu isi `ios/Flutter/MapsKey.xcconfig`:

```xcconfig
GOOGLE_MAPS_API_KEY=API_KEY_ANDA
```

File `ios/Flutter/MapsKey.xcconfig` sudah di-ignore oleh git. Jangan commit API key asli ke repository. Gunakan API restriction di Google Cloud sesuai bundle ID/package name aplikasi.

## Catatan iOS

- App sudah diuji pada physical iPhone untuk skenario open, force-close dari app switcher, lalu open ulang.
- Notification service dijalankan secara lazy agar startup iOS tetap stabil.
- Bundle ID utama: `com.solatify.app.solatify`.
- Deployment target iOS: `13.0`, sehingga versi iOS minimum yang disupport adalah iOS 13.0.
- Beberapa plugin masih menampilkan warning Swift Package Manager atau lifecycle lama. Saat ini warning tersebut tidak menghentikan build.

Plugin yang dapat memunculkan warning di Flutter versi terbaru:

- `workmanager_apple`
- `google_maps_flutter_ios`
- `flutter_compass`

## Testing dan Quality Check

Jalankan analyzer:

```bash
flutter analyze
```

Jalankan test:

```bash
flutter test
```

Area yang sudah memiliki test mencakup:

- Kalkulasi waktu salat.
- Arah kiblat.
- Render screen jadwal salat.
- Perubahan kota manual.
- Data dan model Quran.
- Render awal aplikasi.

## Permission yang Digunakan

- Location: menghitung waktu salat berdasarkan lokasi dan masjid terdekat.
- Notification: pengingat waktu salat.
- Compass/sensor: arah kiblat.
- Maps/network: peta dan data remote yang diperlukan.

## Repository

GitHub: [imransetiadi/solatify](https://github.com/imransetiadi/solatify)

## License

Belum ada license file di repository ini.
