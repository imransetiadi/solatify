# 📢 Fitur Notifikasi Waktu Salat - Dokumentasi Lengkap

## Ringkasan Fitur

Solatify kini dilengkapi dengan sistem notifikasi cerdas untuk semua 5 waktu salat. Notifikasi dikirimkan dengan pesan yang sempurna dalam Bahasa Indonesia, terhitung akurat, dan dapat dikustomisasi sesuai kebutuhan pengguna.

---

## 📋 Pesan Notifikasi untuk Setiap Waktu Salat

### 1. 🌅 **SUBUH (Fajar)**

**Judul Notifikasi:**
```
Waktu Subuh - [Lokasi User]
```

**Pesan Notifikasi:**
```
Telah masuk waktu salat Subuh di wilayah [Lokasi] pada pukul [HH:mm]. 
Mulailah persiapan untuk menunaikan ibadah Subuh.
```

**Contoh:**
- Judul: "Waktu Subuh - Jakarta"
- Pesan: "Telah masuk waktu salat Subuh di wilayah Jakarta pada pukul 04:30. Mulailah persiapan untuk menunaikan ibadah Subuh."

**Fitur Khusus:**
- ✅ Notifikasi Subuh besok (jika Isya hari ini sudah lewat)
- ✅ Pesan: "Waktu salat Subuh besok di wilayah [Lokasi] adalah pukul [HH:mm]. Bersiaplah untuk menunaikan ibadah Subuh."

---

### 2. ☀️ **DZUHUR (Tanggal Pertama)**

**Judul Notifikasi:**
```
Waktu Dzuhur - [Lokasi User]
```

**Pesan Notifikasi:**
```
Telah masuk waktu salat Dzuhur di wilayah [Lokasi] pada pukul [HH:mm]. 
Segera menunaikan ibadah Dzuhur Anda.
```

**Contoh:**
- Judul: "Waktu Dzuhur - Bandung"
- Pesan: "Telah masuk waktu salat Dzuhur di wilayah Bandung pada pukul 12:15. Segera menunaikan ibadah Dzuhur Anda."

**Waktu Khas:**
- Biasanya pada siang hari setelah matahari tergelincir dari titik tertinggi
- Durasi: ±3-4 jam

---

### 3. 🏜️ **ASHAR (Waktu Sore)**

**Judul Notifikasi:**
```
Waktu Ashar - [Lokasi User]
```

**Pesan Notifikasi:**
```
Telah masuk waktu salat Ashar di wilayah [Lokasi] pada pukul [HH:mm]. 
Jangan lewatkan waktu salat Ashar.
```

**Contoh:**
- Judul: "Waktu Ashar - Surabaya"
- Pesan: "Telah masuk waktu salat Ashar di wilayah Surabaya pada pukul 15:45. Jangan lewatkan waktu salat Ashar."

**Catatan Penting:**
- Waktu Ashar tidak boleh disamakan dengan Dzuhur
- Dimulai ketika bayangan benda mencapai panjang tertentu
- Jangan tunda untuk bekerja atau aktivitas lainnya

---

### 4. 🌇 **MAGRIB (Waktu Senja)**

**Judul Notifikasi:**
```
Waktu Magrib - [Lokasi User]
```

**Pesan Notifikasi:**
```
Telah masuk waktu salat Magrib di wilayah [Lokasi] pada pukul [HH:mm]. 
Bukalah puasa (jika sedang berpuasa) dan segera salat Magrib.
```

**Contoh:**
- Judul: "Waktu Magrib - Medan"
- Pesan: "Telah masuk waktu salat Magrib di wilayah Medan pada pukul 18:20. Bukalah puasa (jika sedang berpuasa) dan segera salat Magrib."

**Fitur Khusus:**
- ✅ Pesan menyebutkan puasa (relevan saat Ramadhan)
- ✅ Waktu paling penting untuk tidak terlewat

---

### 5. 🌙 **ISYA (Malam)**

**Judul Notifikasi:**
```
Waktu Isya - [Lokasi User]
```

**Pesan Notifikasi:**
```
Telah masuk waktu salat Isya di wilayah [Lokasi] pada pukul [HH:mm]. 
Sempurnakannya ibadah Isya Anda sebelum tidur.
```

**Contoh:**
- Judul: "Waktu Isya - Yogyakarta"
- Pesan: "Telah masuk waktu salat Isya di wilayah Yogyakarta pada pukul 19:30. Sempurnakannya ibadah Isya Anda sebelum tidur."

**Catatan:**
- Waktu Isya paling akhir di malam hari
- Jangan tinggalkan tanpa salat sebelum tidur

---

## 🔧 Spesifikasi Teknis Notifikasi

### Kapan Notifikasi Dikirim?
- **Tepat saat waktu salat masuk** (berdasarkan kalkulasi akurat)
- Notifikasi dijadwalkan 1 hari sebelumnya
- Sistem akan re-schedule setiap hari untuk memastikan akurasi

### Karakteristik Notifikasi
- ✅ **Sound**: Menggunakan default notification sound
- ✅ **Vibration**: Enabled untuk mendapat perhatian
- ✅ **Visual**: Icon dan light notification
- ✅ **Persistensi**: Tetap di notification tray hingga dibaca
- ✅ **Payload**: Berisi informasi prayer key untuk action handling

### Platform Support
- ✅ **Android**: API 31+ (dengan AndroidScheduleMode.exactAndAllowWhileIdle)
- ✅ **iOS**: iOS 13+ (dengan requestPermissions)

---

## 📱 User Experience

### Notification Tapping
Ketika user tap notifikasi:
1. App terbuka (jika tertutup)
2. Menampilkan detail waktu salat
3. Payload: `prayerKey` untuk tracking

### Notification Management
- User dapat manage notifications di system settings
- Solatify meminta permission saat pertama kali install
- User dapat meng-disable via app settings (fitur toggle)

---

## 🎯 Peningkatan dari Versi Sebelumnya

### Masalah Lama:
- ❌ Pesan: "Telah masuk waktu salat Besok_subuh untuk wilayah Anda."
- ❌ Tidak ada variasi pesan per prayer
- ❌ Grammar kurang tepat dalam Bahasa Indonesia
- ❌ Notifikasi tidak akurat atau tidak muncul

### Solusi Baru:
- ✅ Pesan spesifik untuk setiap prayer dengan grammar sempurna
- ✅ Lokasi dimasukkan ke dalam pesan
- ✅ Waktu salat ditampilkan dengan format HH:mm
- ✅ Kalkulasi timing yang akurat
- ✅ Proper title dan body formatting
- ✅ Support untuk notifikasi Subuh besok

---

## 📝 Contoh Skenario Sehari-hari

### Pukul 04:30 (Subuh)
```
📢 Judul: "Waktu Subuh - Jakarta"
📝 Pesan: "Telah masuk waktu salat Subuh di wilayah Jakarta pada pukul 04:30. 
         Mulailah persiapan untuk menunaikan ibadah Subuh."
```

### Pukul 12:15 (Dzuhur)
```
📢 Judul: "Waktu Dzuhur - Jakarta"
📝 Pesan: "Telah masuk waktu salat Dzuhur di wilayah Jakarta pada pukul 12:15. 
         Segera menunaikan ibadah Dzuhur Anda."
```

### Pukul 15:45 (Ashar)
```
📢 Judul: "Waktu Ashar - Jakarta"
📝 Pesan: "Telah masuk waktu salat Ashar di wilayah Jakarta pada pukul 15:45. 
         Jangan lewatkan waktu salat Ashar."
```

### Pukul 18:20 (Magrib - saat Ramadhan)
```
📢 Judul: "Waktu Magrib - Jakarta"
📝 Pesan: "Telah masuk waktu salat Magrib di wilayah Jakarta pada pukul 18:20. 
         Bukalah puasa dan segera salat Magrib."
```

### Pukul 19:30 (Isya)
```
📢 Judul: "Waktu Isya - Jakarta"
📝 Pesan: "Telah masuk waktu salat Isya di wilayah Jakarta pada pukul 19:30. 
         Sempurnakannya ibadah Isya Anda sebelum tidur."
```

### Malam hari (Subuh Besok)
```
📢 Judul: "Waktu Subuh Besok - Jakarta"
📝 Pesan: "Waktu salat Subuh besok di wilayah Jakarta adalah pukul 04:28. 
         Bersiaplah untuk menunaikan ibadah Subuh."
```

---

## 🔌 Integrasi dengan Sistem

### File yang Terlibat:
1. **lib/core/services/notification_service.dart** - Service utama
2. **lib/features/prayer_schedule/presentation/notification_scheduler_provider.dart** - Scheduling logic
3. **lib/main.dart** - Initialization
4. **pubspec.yaml** - Dependency management

### Dependencies:
- `flutter_local_notifications: ^17.1.0`

---

## 🛠️ Cara Menggunakan

### Menampilkan Notifikasi Manual
```dart
await NotificationService().showPrayerNotification(
  prayerKey: 'subuh',
  location: 'Jakarta',
  prayerTime: '04:30',
  notificationId: 1001,
);
```

### Menjadwalkan Notifikasi
```dart
await NotificationService().schedulePrayerNotification(
  prayerKey: 'dzuhur',
  location: 'Jakarta',
  prayerTime: '12:15',
  notificationTime: DateTime(2026, 6, 14, 12, 15),
  notificationId: 1002,
);
```

### Cancel Notifikasi
```dart
await NotificationService().cancelNotification(1001);
await NotificationService().cancelAllNotifications();
```

---

## ✨ Quality Assurance

### Testing Checklist:
- [ ] Notifikasi Subuh muncul pada waktu yang tepat
- [ ] Notifikasi Dzuhur muncul pada waktu yang tepat
- [ ] Notifikasi Ashar muncul pada waktu yang tepat
- [ ] Notifikasi Magrib muncul pada waktu yang tepat
- [ ] Notifikasi Isya muncul pada waktu yang tepat
- [ ] Pesan notifikasi grammatically correct
- [ ] Lokasi ditampilkan dengan benar
- [ ] Waktu ditampilkan dengan format HH:mm
- [ ] Notifikasi Subuh besok muncul setelah Isya
- [ ] Sound dan vibration berfungsi
- [ ] Permissions diminta saat pertama kali

---

## 📞 Support & Troubleshooting

### Notifikasi Tidak Muncul?
1. Cek apakah permission sudah diberikan di system settings
2. Cek apakah app sedang berjalan atau sudah di-kill
3. Verifikasi bahwa prayer times sudah ter-calculate dengan benar

### Pesan Notifikasi Salah?
1. Cek lokasi pengguna apakah sudah correct
2. Verifikasi waktu salat di prayer times provider
3. Check notification logs di console

---

## 🎉 Kesimpulan

Fitur notifikasi Solatify kini memberikan pengalaman terbaik dengan:
- ✅ Pesan yang sempurna dalam Bahasa Indonesia
- ✅ Akurasi timing yang tinggi
- ✅ Support untuk semua 5 waktu salat
- ✅ UX yang intuitif dan user-friendly
- ✅ Integrasi seamless dengan sistem

**Semoga membantu meningkatkan konsistensi ibadah salat! 💚**
