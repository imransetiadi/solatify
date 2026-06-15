# Solatify

<p align="center">
  <img src="assets/images/masjid_nabawi.svg" width="120" alt="Solatify Logo">
</p>
<p align="center">
  <b>Pendamping Ibadah Harian Muslim yang Modern, Presisi, dan Andal</b>
</p>

---

**Solatify** adalah aplikasi Flutter berkinerja tinggi yang dirancang khusus untuk memfasilitasi aktivitas ibadah sehari-hari. Dibangun menggunakan prinsip **Clean Architecture (Feature-First)**, aplikasi ini menjamin performa, skalabilitas, dan pengalaman pengguna yang luar biasa.

## ✨ Fitur Utama

- 🕋 **Jadwal Salat Presisi Tinggi**: Menggunakan pustaka kalkulasi astronomi (`adhan` & `timezone`) dengan dukungan berbagai metode perhitungan internasional (Kemenag, MWL, dll). Waktu salat otomatis menyesuaikan dengan zona waktu lokal secara akurat.
- 📖 **Al-Qur'an Digital & Dzikir**: Tersedia 114 surah lengkap, asmaul husna, doa harian, dan dzikir pagi-petang. Dilengkapi dengan teks Arab, Latin, terjemahan bahasa Indonesia, serta fitur *Bookmark* (Penanda Terakhir Dibaca).
- 🧭 **Arah Kiblat *Real-time***: Menggunakan sensor kompas perangkat untuk menunjukkan arah kiblat secara instan dan presisi.
- 🔔 **Sistem Notifikasi Andal**: Alarm azan dan pengingat waktu salat yang beroperasi secara *offline* menggunakan `flutter_local_notifications`. Bebas duplikasi dan terintegrasi penuh dengan OS.
- 📈 **Prayer Tracker**: Fitur pencatatan ibadah harian interaktif yang dilengkapi dengan data statistik mingguan untuk membantu menjaga konsistensi ibadah.
- 🌙 **Tema & UX Harmonis**: Desain antarmuka modern yang menggunakan *Glassmorphism* serta transisi *Light/Dark Mode* yang responsif.

## 🛠 Arsitektur & Teknologi

Solatify dikembangkan dengan standar rekayasa perangkat lunak modern:

- **State Management**: [`Riverpod`](https://riverpod.dev/) — Mengelola *state* yang kompleks (termasuk *Optimistic UI Update* pada Tracker) dengan aman dan terprediksi.
- **Local Storage**: [`Hive`](https://pub.dev/packages/hive) — Database NoSQL yang sangat cepat untuk *caching* jadwal salat, pengaturan, dan rekam jejak pengguna, lengkap dengan sistem *Crash Recovery*.
- **Routing**: [`GoRouter`](https://pub.dev/packages/go_router) — Navigasi deklaratif untuk transisi halaman yang mulus dan *Deep Linking*.
- **Desain Pattern**: **Clean Architecture (Data, Domain, Presentation)** — Memisahkan logika bisnis dari antarmuka pengguna untuk mempermudah pemeliharaan (*maintenance*) dan *Test-Driven Development (TDD)*.

## 🚀 Kesiapan Distribusi

Aplikasi ini telah melewati audit komprehensif, meliputi:
- **0 Error Statis**: Mematuhi aturan linting ketat (`flutter analyze`).
- **100% Test Coverage pada Critical Paths**: Lulus 24 pengujian (Unit & Widget Tests) termasuk *Smoke Testing* dan *Crash Recovery*.
- **Platform**: Mendukung penuh kompilasi untuk **iOS** maupun **Android**.

## 💻 Memulai (Getting Started)

Jika Anda ingin menjalankan atau mengembangkan Solatify di lingkungan lokal:

1. **Clone repository ini**
   ```bash
   git clone https://github.com/imransetiadi/solatify.git
   cd solatify
   ```

2. **Unduh dependensi**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 🧪 Menjalankan Pengujian (Testing)

Untuk memastikan integritas kode dan fungsionalitas aplikasi:
```bash
flutter test
```

## 📜 Lisensi

Proyek ini bersifat tertutup (Proprietary). Hak Cipta dilindungi. 
