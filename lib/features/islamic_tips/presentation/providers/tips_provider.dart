import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tip_model.dart';

final tipsProvider = Provider<List<IslamicTip>>((ref) => _tipsData);

final randomTipProvider = Provider<IslamicTip>((ref) {
  final tips = ref.watch(tipsProvider);
  final random = Random(DateTime.now().day);
  return tips[random.nextInt(tips.length)];
});

final List<IslamicTip> _tipsData = [
  IslamicTip(id: 1, title: "Keutamaan Shalat Dhuha", content: "Shalat Dhuha adalah sedekah bagi setiap persendian tubuh manusia.", reference: "HR. Muslim", category: "Ibadah"),
  IslamicTip(id: 2, title: "Adab Berdoa", content: "Mulailah doa dengan memuji Allah dan bersholawat kepada Nabi Muhammad SAW.", reference: "HR. At-Tirmidzi", category: "Doa"),
  IslamicTip(id: 3, title: "Menahan Amarah", content: "Orang kuat adalah orang yang mampu mengendalikan dirinya ketika marah.", reference: "HR. Bukhari", category: "Akhlaq"),
  IslamicTip(id: 4, title: "Keutamaan Tersenyum", content: "Senyummu di hadapan saudaramu adalah sedekah.", reference: "HR. At-Tirmidzi", category: "Akhlaq"),
  IslamicTip(id: 5, title: "Sedekah Tersembunyi", content: "Sedekah tersembunyi menjaga keikhlasan dan menguatkan hubungan dengan Allah.", reference: "HR. Bukhari & Muslim", category: "Amal"),
  IslamicTip(id: 6, title: "Pentingnya Shalat Malam", content: "Shalat malam adalah kebiasaan orang saleh dan sarana mendekat kepada Allah.", reference: "HR. Muslim", category: "Ibadah"),
  IslamicTip(id: 7, title: "Membaca Al-Quran", content: "Setiap huruf Al-Quran bernilai kebaikan yang dilipatgandakan.", reference: "HR. At-Tirmidzi", category: "Al-Quran"),
  IslamicTip(id: 8, title: "Puasa Sunnah", content: "Puasa sunnah melatih kesabaran, keikhlasan, dan pengendalian diri.", reference: "HR. Muslim", category: "Ibadah"),
  IslamicTip(id: 9, title: "Adab Berbicara", content: "Ucapkan perkataan baik atau pilih diam bila tidak membawa manfaat.", reference: "HR. Bukhari & Muslim", category: "Akhlaq"),
  IslamicTip(id: 10, title: "Pentingnya Sedekah", content: "Sedekah tidak mengurangi harta, justru membuka pintu keberkahan.", reference: "HR. Muslim", category: "Amal"),
  IslamicTip(id: 11, title: "Menjaga Pandangan", content: "Menjaga pandangan membantu menjaga hati dari hal yang melemahkan iman.", reference: "HR. Ahmad", category: "Akhlaq"),
  IslamicTip(id: 12, title: "Keutamaan Dzikir", content: "Dengan mengingat Allah, hati menjadi tenang.", reference: "QS. Ar-Ra'd: 28", category: "Dzikir"),
  IslamicTip(id: 13, title: "Waktu Mustajab", content: "Berdoalah pada sepertiga malam terakhir, saat hujan, dan antara adzan-iqamah.", reference: "HR. At-Tirmidzi", category: "Doa"),
  IslamicTip(id: 14, title: "Berbakti Orang Tua", content: "Berbakti kepada orang tua termasuk amalan paling dicintai Allah.", reference: "HR. Bukhari", category: "Akhlaq"),
  IslamicTip(id: 15, title: "Sabar Dalam Cobaan", content: "Bersama kesulitan ada kemudahan, dan Allah tidak membebani di luar kemampuan.", reference: "QS. Al-Insyirah: 5-6", category: "Akhlaq"),
  IslamicTip(id: 16, title: "Shalat Berjamaah", content: "Shalat berjamaah lebih utama daripada shalat sendiri.", reference: "HR. Bukhari & Muslim", category: "Ibadah"),
  IslamicTip(id: 17, title: "Menjaga Kebersihan", content: "Kebersihan diri dan lingkungan adalah bagian penting dari akhlaq seorang Muslim.", reference: "HR. Muslim", category: "Akhlaq"),
  IslamicTip(id: 18, title: "Istighfar", content: "Perbanyak istighfar untuk membersihkan hati dan membuka pintu rezeki.", reference: "HR. Abu Dawud", category: "Dzikir"),
  IslamicTip(id: 19, title: "Husnuzan", content: "Berprasangka baik kepada Allah membuat hati lebih tenang dalam ujian.", reference: "QS. Al-Hujurat: 12", category: "Akhlaq"),
  IslamicTip(id: 20, title: "Menjaga Lisan", content: "Lisan yang terjaga menyelamatkan banyak hubungan dan amal.", reference: "HR. Bukhari", category: "Akhlaq"),
  IslamicTip(id: 21, title: "Menuntut Ilmu", content: "Ilmu agama menuntun ibadah agar benar dan bermakna.", reference: "HR. Ibnu Majah", category: "Edukasi"),
  IslamicTip(id: 22, title: "Bersyukur", content: "Syukur membuat nikmat terasa cukup dan mengundang tambahan kebaikan.", reference: "QS. Ibrahim: 7", category: "Akhlaq"),
  IslamicTip(id: 23, title: "Memuliakan Tamu", content: "Memuliakan tamu adalah tanda keimanan dan kemuliaan akhlaq.", reference: "HR. Bukhari & Muslim", category: "Akhlaq"),
  IslamicTip(id: 24, title: "Silaturahim", content: "Silaturahim menguatkan keluarga, melapangkan rezeki, dan mempererat umat.", reference: "HR. Bukhari & Muslim", category: "Amal"),
  IslamicTip(id: 25, title: "Surat Al-Kahfi", content: "Bacalah Al-Kahfi pada hari Jumat sebagai pengingat dan cahaya kebaikan.", reference: "HR. Al-Hakim", category: "Al-Quran"),
  IslamicTip(id: 26, title: "Wudhu Sebelum Tidur", content: "Tidur dalam keadaan suci membantu menutup hari dengan dzikir dan ketenangan.", reference: "HR. Ibnu Hibban", category: "Ibadah"),
  IslamicTip(id: 27, title: "Puasa Arafah", content: "Puasa Arafah adalah kesempatan besar untuk meraih ampunan Allah.", reference: "HR. Muslim", category: "Ibadah"),
  IslamicTip(id: 28, title: "Memaafkan", content: "Memaafkan bukan tanda lemah, tetapi tanda luasnya hati dan iman.", reference: "QS. Asy-Syura: 40", category: "Akhlaq"),
  IslamicTip(id: 29, title: "Amanah", content: "Tunaikan amanah sekecil apa pun karena amanah adalah bagian dari iman.", reference: "HR. Ahmad", category: "Akhlaq"),
  IslamicTip(id: 30, title: "Niat Ikhlas", content: "Perbaiki niat sebelum beramal agar usaha kecil bernilai besar di sisi Allah.", reference: "HR. Bukhari & Muslim", category: "Amal"),
];
