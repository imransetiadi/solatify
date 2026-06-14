# 🕌 Solatify - Islamic Prayer Times & Daily Companion

![Solatify Banner](assets/icon.jpg)

**Solatify** adalah aplikasi Flutter komprehensif yang dirancang untuk mendukung ibadah umat Muslim sehari-hari. Mulai dari jadwal salat yang presisi hingga Qur'an digital dan doa harian, aplikasi ini dibangun dengan fokus pada performa, ketepatan, dan *User Experience* (UX) yang elegan.

**Versi**: 1.0.0+1  
**Platform**: iOS & Android  
**Framework**: Flutter 3.x  
**State Management**: Riverpod 2.x

---

## 🌟 Fitur Utama

### 🕐 Jadwal Waktu Salat Super Akurat (Lokasi & Timezone Aware)
- **Multi-Method**: Mendukung berbagai metode kalkulasi termasuk **Kemenag** (standar Indonesia: Subuh 20°, Isya 18°), MWL, Egypt, Karachi, Umm Al-Qura, dll.
- **Timezone Presisi**: Menggunakan *TZDateTime* agar jadwal salat sinkron secara spesifik dengan zona waktu kota (WIB, WITA, WIT), tanpa terdistorsi oleh zona waktu perangkat.
- **Offset Manual**: Penyesuaian kustom (-/+ menit) untuk setiap waktu salat (Subuh, Dzuhur, Ashar, Magrib, Isya).
- **Location Fallback**: Deteksi otomatis via GPS atau database offline berisi 90+ kota di seluruh Indonesia.

### 🔔 Notifikasi Salat Tepat Waktu
- Penjadwalan notifikasi lokal menggunakan `flutter_local_notifications`.
- Notifikasi 100% aman dari masalah *double notification* / duplikasi.
- Pesan notifikasi khusus berbahasa Indonesia untuk setiap waktu salat (contoh: "Telah masuk waktu salat Dzuhur di wilayah Jakarta...").

### 📖 Al-Qur'an Digital
- Tersedia lengkap 114 surah (Arab, terjemahan Indonesia).
- **Performa Tinggi**: *Lazy loading* dan model *parsing* yang efisien.
- Fitur pencarian surah (berdasarkan nama, terjemahan, atau nomor).

### 🧭 Arah Kiblat (Qibla Compass)
- Kompas interaktif *(real-time)* menunjukkan arah Ka'bah berdasarkan koordinat presisi.

### 🤲 Fitur Pendukung Ibadah Lainnya
- **Doa-doa Harian**: Doa pagi, petang, makan, tidur, dsb lengkap dengan Latin & terjemahan.
- **Asmaul Husna**: 99 Nama Allah dengan penjelasan dan pencarian instan.
- **Kalender Hijriah**: Konversi tanggal Masehi ke Hijriah beserta daftar hari penting (Ramadhan, Idul Fitri, dll).
- **Masjid Terdekat**: Navigasi dan temukan lokasi masjid terdekat menggunakan *Reverse Geocoding*.

---

## 🎨 Arsitektur & Teknologi

Aplikasi ini menggunakan pola arsitektur **Clean Architecture** yang terbagi dalam *Features*:
- **State Management**: Memanfaatkan kekuatan `flutter_riverpod` untuk menangani *reactive state* (seperti `CountdownNotifier` dan `PrayerTimesNotifier`).
- **Data Persistence**: Menggunakan `Hive` (NoSQL yang sangat cepat) untuk caching jadwal, pengaturan *user*, hingga progres *onboarding*. Tahan terhadap *crash* dan dilengkapi sistem *auto-recovery*.
- **UI/UX**: Mengusung desain berkonsep *Glassmorphism* (`GlassContainer`), *Responsive Layout* adaptif untuk *Mobile/Tablet*, serta dukungan *Dark Mode* dan *Light Mode*.
- **Performance**: Lulus seluruh target *benchmark* (*Cold Start* < 2 detik, komputasi jadwal ~2ms).

---

## 🚀 Panduan Instalasi (Development)

### Persyaratan Sistem
- Flutter SDK `^3.12.1` atau terbaru.
- Dart SDK `^3.0.0`
- Android Studio / IntelliJ / VS Code.
- Xcode 14+ (untuk build iOS).

### Langkah-langkah Menjalankan Aplikasi
1. **Kloning Repositori**
   ```bash
   git clone https://github.com/USERNAME/solatify.git
   cd solatify
   ```

2. **Unduh Dependencies**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Jalankan Aplikasi (Debug Mode)**
   ```bash
   flutter run
   ```

---

## 📦 Build untuk Produksi (Release)

### Android (APK)
```bash
flutter build apk --release
# APK dapat ditemukan di: build/app/outputs/flutter-apk/app-release.apk
```

### iOS (IPA)
Pastikan Anda menggunakan macOS dan memiliki sertifikat Xcode yang valid.
```bash
# Set up pods and minimum iOS deployment target (14.0)
cd ios
pod install
cd ..

# Build release (tanpa codesign untuk proses via Xcode kemudian)
flutter build ios --release --no-codesign
```
Buka file `ios/Runner.xcworkspace` di Xcode untuk melakukan proses *Archive* dan *Codesign*.

---

## 🧪 Pengujian (QA & Tests)

Aplikasi dilengkapi dengan tes fungsional *Unit Test* dan *Widget Test* (mencapai 58 dari 58 tes *Passed*).
Untuk menjalankan test:
```bash
flutter test
```
*Coverage meliputi: Verifikasi Timezone (Kemenag WIB/WITA/WIT), Parse Al-Qur'an (JSON Model), Responsivitas UI, dan Integritas HiveDB.*

---

## 📄 Lisensi
Hak cipta © 2026. *All Rights Reserved.*
Proyek ini bersifat tertutup (private) kecuali diinstruksikan sebaliknya.
