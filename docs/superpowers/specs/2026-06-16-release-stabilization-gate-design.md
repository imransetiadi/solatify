# Release Stabilization Gate Design

## Goal
Stabilkan Solatify untuk rilis Android dan iOS tanpa menambah fitur baru atau melakukan refactor besar. Fokusnya adalah memastikan working tree jelas, analyzer dan test bersih, asset Adhan ter-bundle, serta build Android/iOS dapat divalidasi atau memiliki catatan blocker eksternal yang eksplisit.

## Scope
- Android dan iOS termasuk dalam target stabilisasi.
- Tidak menambah fitur baru.
- Tidak melakukan migrasi import massal atau theming massal.
- Perbaikan hanya dilakukan untuk masalah yang langsung memengaruhi build, test, analyzer, packaging, notifikasi Adhan, atau kesiapan rilis.
- File sementara kosong boleh dibersihkan jika terbukti tidak berisi data penting.
- Commit tidak dilakukan otomatis karena working tree sedang memiliki perubahan aktif; perubahan akan disiapkan dan dilaporkan untuk review pengguna.

## Work Units

### Release Inventory
- Cek status Git dan kategorikan perubahan lokal.
- Pastikan perubahan notifikasi, test scheduler, asset Adhan Android, asset Adhan iOS, dan Xcode resource masuk daftar rilis.
- Identifikasi file/folder tak terlacak yang aman dibersihkan, seperti folder kosong hasil workflow.

### Quality Gate
- Jalankan `flutter analyze --no-pub`.
- Jalankan `flutter test --no-pub`.
- Jika gagal, perbaiki root cause yang relevan ke rilis saja.
- Jangan memperbaiki masalah unrelated yang memperbesar diff.

### Android Gate
- Validasi `android/app/src/main/res/raw/adhan.mp3` tersedia.
- Validasi permission Android untuk notification, exact alarm, boot receiver, wake lock, dan foreground service tetap ada.
- Validasi channel notifikasi memakai `prayer_times_adhan_channel_v1` dan `RawResourceAndroidNotificationSound('adhan')`.
- Build Android artifact. Jika target final belum ditentukan, gunakan APK sebagai smoke build dan catat opsi AAB untuk Play Store.

### iOS Gate
- Validasi `ios/Runner/adhan.mp3` tersedia.
- Validasi `ios/Runner.xcodeproj/project.pbxproj` mencatat `adhan.mp3` sebagai resource Runner.
- Build iOS dengan mode tanpa codesign jika signing/provisioning tidak tersedia di environment.
- Jika signing gagal, dokumentasikan kebutuhan manual Apple Developer provisioning.

### Release Report
- Laporkan command yang dijalankan dan hasilnya.
- Laporkan artifact build yang berhasil dibuat.
- Laporkan risiko tersisa, terutama jika `adhan.mp3` masih dummy placeholder.
- Berikan langkah manual singkat untuk rilis final.

## Data Flow
- `prayerTimesProvider` menyediakan jadwal salat hari ini dan besok.
- `locationProvider` menyediakan nama lokasi untuk isi notifikasi.
- Notification scheduler membuat request untuk jadwal hari ini yang belum lewat dan `Subuh` besok.
- `NotificationService` menjadwalkan notifikasi lokal dengan channel Adhan.
- Android mengambil audio dari raw resource `adhan`.
- iOS mengambil audio dari bundle resource `adhan.mp3`.

## Error Handling
- Analyzer/test failure ditangani dengan membaca error, menemukan root cause, dan patch minimal.
- Build failure karena sandbox/cache dijalankan ulang dengan izin elevated.
- Build failure karena signing iOS dicatat sebagai blocker eksternal dan tidak dianggap bug aplikasi jika `--no-codesign` berhasil.
- File sementara hanya dihapus setelah dipastikan kosong atau tidak relevan.

## Testing Strategy
- `flutter analyze --no-pub` harus menghasilkan `No issues found`.
- `flutter test --no-pub` harus lulus penuh.
- Android build harus selesai untuk minimal satu artifact rilis/smoke.
- iOS build harus selesai dengan konfigurasi yang tersedia di environment, minimal `--no-codesign`.

## Out of Scope
- Fitur baru notifikasi.
- Refactor Clean Architecture besar untuk Mosque/Quran.
- Migrasi semua relative import.
- Migrasi semua hardcoded color ke `AppTheme`.
- Konfigurasi signing Apple Developer atau Google Play Console di luar repo.
