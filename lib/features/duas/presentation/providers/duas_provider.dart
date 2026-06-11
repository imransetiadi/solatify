import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dua_model.dart';

final duasProvider = Provider<List<Dua>>((ref) => _duasData);

final duasByCategoryProvider = Provider.family<List<Dua>, String>((ref, category) {
  final allDuas = ref.watch(duasProvider);
  return allDuas.where((dua) => dua.category == category).toList();
});

final List<Dua> _duasData = [
  Dua(id: 1, title: 'Doa Pagi', category: 'pagi', arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ', latinText: 'Asbahna wa asbahul-mulku lillahi', meaning: 'Kami memasuki pagi dan segala kerajaan milik Allah.', source: 'Sunan At-Tirmidzi'),
  Dua(id: 2, title: 'Doa Malam', category: 'malam', arabicText: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ', latinText: 'Amsaina wa amsyal-mulku lillahi', meaning: 'Kami memasuki malam dan segala kerajaan milik Allah.', source: 'Sunan At-Tirmidzi'),
  Dua(id: 3, title: 'Doa Sebelum Makan', category: 'sebelum_makan', arabicText: 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ', latinText: 'Bismillahi wa ala barakatillah', meaning: 'Dengan nama Allah dan atas berkah Allah.', source: 'Hadits Riwayat Ibnu Majah'),
  Dua(id: 4, title: 'Doa Sesudah Makan', category: 'sesudah_makan', arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا', latinText: 'Alhamdu lilahi l-ladzi athaamana', meaning: 'Segala puji bagi Allah yang telah memberi kami makan.', source: 'Sunan At-Tirmidzi'),
  Dua(id: 5, title: 'Doa Sebelum Tidur', category: 'sebelum_tidur', arabicText: 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا', latinText: 'Allahumma bismika amutu wa ahya', meaning: 'Ya Allah, dengan nama-Mu aku mati dan hidup.', source: 'Sahih Al-Bukhari'),
  Dua(id: 6, title: 'Doa Bangun dari Tidur', category: 'bangun_tidur', arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا', latinText: 'Alhamdu lilahi l-ladzi ahyana', meaning: 'Segala puji bagi Allah yang telah menghidupkan kami.', source: 'HR. Al-Bukhari'),
  Dua(id: 7, title: 'Doa Masuk Kamar Mandi', category: 'kamar_mandi', arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبْثِ', latinText: 'Allahumma inni audzu bika minal-khubsi', meaning: 'Ya Allah, aku berlindung dari jin kotor.', source: 'Sunan At-Tirmidzi'),
  Dua(id: 8, title: 'Doa Keluar Kamar Mandi', category: 'kamar_mandi', arabicText: 'غُفْرَانَكَ', latinText: 'Ghufranaka', meaning: 'Aku memohon ampunan-Mu.', source: 'Sunan At-Tirmidzi'),
  Dua(id: 9, title: 'Doa Ketika Takut', category: 'ketakutan', arabicText: 'لَا إِلَهَ إِلَّا اللَّهُ', latinText: 'La ilaha illallahu', meaning: 'Tidak ada tuhan selain Allah.', source: 'HR. Abu Dawud'),
  Dua(id: 10, title: 'Doa Ketika Sakit', category: 'sakit', arabicText: 'أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ', latinText: 'Adhhib al-basa rabbi n-nasi', meaning: 'Hilangkanlah penyakit, Tuhan manusia.', source: 'Sahih Al-Bukhari'),
  Dua(id: 11, title: 'Doa Rezeki', category: 'pagi', arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى', latinText: 'Allahumma inni asaluka al-huda', meaning: 'Ya Allah, aku meminta petunjuk.', source: 'Sunan Abu Dawud'),
  Dua(id: 12, title: 'Doa Perjalanan', category: 'pagi', arabicText: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا', latinText: 'Subhana l-ladzi sakhkhara lana hadza', meaning: 'Maha Suci Dia yang menundukkan kendaraan ini.', source: 'Surah Az-Zukhruf 13'),
  Dua(id: 13, title: 'Doa Kesusahan', category: 'ketakutan', arabicText: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ', latinText: 'La ilaha illa anta subhanaka', meaning: 'Tidak ada tuhan selain Engkau, Maha Suci.', source: 'Surah Al-Anbiyaa 87'),
  Dua(id: 14, title: 'Doa Lupa', category: 'pagi', arabicText: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ', latinText: 'Ya Hayyu ya Qayyum bi rahmatika', meaning: 'Wahai Yang Hidup, dengan rahmat-Mu aku minta.', source: 'Jami At-Tirmidzi'),
  Dua(id: 15, title: 'Doa Sebelum Belajar', category: 'pagi', arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ فَهْماً', latinText: 'Allahumma inni asaluka fahman', meaning: 'Ya Allah, aku meminta pemahaman agama.', source: 'Sunan An-Nasai'),
  Dua(id: 16, title: 'Doa Mensyukuri Nikmat', category: 'sesudah_makan', arabicText: 'الْحَمْدُ لِلَّهِ حَمْداً كَثِيراً', latinText: 'Alhamdu lilahi hamdan kathira', meaning: 'Pujian bagi Allah, pujian yang banyak.', source: 'Sahih Al-Bukhari'),
  Dua(id: 17, title: 'Doa Marah', category: 'ketakutan', arabicText: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ', latinText: 'Audzu billahi min ash-shaythan', meaning: 'Aku berlindung kepada Allah dari setan.', source: 'Surah An-Nahl 98'),
  Dua(id: 18, title: 'Doa Rumah', category: 'pagi', arabicText: 'بِسْمِ اللَّهِ وَلَجْنَا', latinText: 'Bismillahi walajna', meaning: 'Dengan nama Allah kami masuk.', source: 'Sunan At-Tirmidzi'),
  Dua(id: 19, title: 'Doa Kebaikan', category: 'pagi', arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى', latinText: 'Allahumma inni asaluka al-huda', meaning: 'Ya Allah, aku meminta petunjuk dan takwa.', source: 'Sahih Muslim'),
];
