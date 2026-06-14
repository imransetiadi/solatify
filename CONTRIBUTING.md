# 🤝 Panduan Kontribusi Solatify

Terima kasih telah tertarik untuk berkontribusi pada Solatify! Dokumen ini menjelaskan cara berkontribusi dengan baik.

---

## 📋 Kode Etik

- Hormati semua kontributor
- Tidak ada diskriminasi atau pelecehan
- Fokus pada ide, bukan pada individu
- Beri masukan yang konstruktif

---

## 🚀 Cara Mulai Berkontribusi

### 1. Fork Repository
```bash
# Fork di GitHub UI terlebih dahulu
git clone https://github.com/[username]/solatify.git
cd solatify
```

### 2. Buat Branch Baru
```bash
# Dari main branch
git checkout -b feature/nama-fitur
# atau
git checkout -b bugfix/nama-bug
```

### 3. Ikuti Code Style

**Naming Conventions**:
- Files: `snake_case` (contoh: `prayer_times_provider.dart`)
- Classes: `PascalCase` (contoh: `PrayerTimesProvider`)
- Functions: `camelCase` (contoh: `getPrayerTimes()`)
- Constants: `UPPER_SNAKE_CASE` (contoh: `MAX_TIMEOUT`)

**Code Format**:
```bash
# Format code
dart format lib/

# Analyze code
dart analyze lib/
```

### 4. Commit dengan Pesan Jelas

```bash
# Format: [type]: [description]
# Types: feat, fix, docs, refactor, test, chore

git commit -m "feat: tambah notifikasi waktu salat"
git commit -m "fix: perbaiki kalkulasi waktu ashar"
git commit -m "docs: update README dengan instruksi build"
```

### 5. Push dan Buat Pull Request

```bash
git push origin feature/nama-fitur
```

Kemudian buat Pull Request di GitHub dengan:
- Judul deskriptif
- Deskripsi perubahan yang jelas
- Reference issues jika ada

---

## 📁 Struktur File untuk Fitur Baru

```
lib/features/[nama_fitur]/
├── data/
│   ├── models/
│   │   └── [nama]_model.dart
│   ├── repositories/
│   │   └── [nama]_repository.dart
│   └── services/
│       └── [nama]_service.dart
├── domain/
│   └── models/
│       └── [nama]_entity.dart
└── presentation/
    ├── screens/
    │   └── [nama]_screen.dart
    ├── widgets/
    │   └── [nama]_widget.dart
    └── providers/
        └── [nama]_provider.dart
```

---

## ✅ Checklist Sebelum Submit PR

- [ ] Code ter-format dengan `dart format`
- [ ] Tidak ada warnings dari `dart analyze`
- [ ] Sudah di-test di Android dan iOS
- [ ] Dokumentasi sudah diupdate
- [ ] Commit messages jelas dan deskriptif
- [ ] Branch ter-update dari main

---

## 🧪 Testing

### Unit Tests
```bash
flutter test test/

# Coverage
flutter test --coverage
```

### Build Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## 📚 Dokumentasi

Update dokumentasi untuk:
- README.md (jika ada fitur baru)
- Inline code comments
- ARCHITECTURE.md (jika ada perubahan arsitektur)

---

## 🐛 Laporan Bug

Gunakan GitHub Issues dengan template:

```markdown
## Deskripsi
[Jelaskan bug secara ringkas]

## Cara Reproduce
1. ...
2. ...
3. ...

## Expected Behavior
[Apa yang seharusnya terjadi]

## Actual Behavior
[Apa yang benar-benar terjadi]

## Screenshots
[Jika ada]

## Environment
- Flutter version: [output dari `flutter --version`]
- Device: [contoh: iPhone 14 Pro]
- OS: [iOS 16.0]
```

---

## ✨ Tipe Kontribusi yang Diterima

✅ **Bug Fixes** - Perbaikan bug
✅ **Feature Requests** - Fitur baru
✅ **Documentation** - Dokumentasi
✅ **Performance** - Optimisasi performa
✅ **Refactoring** - Perbaikan kode
✅ **Translations** - Dukungan bahasa baru

❌ **Tidak diterima**:
- Fitur dengan scope terlalu besar tanpa diskusi
- Perubahan style/format tanpa purpose
- Dependency major updates tanpa diskusi

---

## 📞 Hubungi Tim

Untuk diskusi besar atau fitur major:
- Buka GitHub Discussion
- Atau hubungi maintainer langsung

---

**Terima kasih atas kontribusi Anda! 💚**

