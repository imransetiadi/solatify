import 'package:solatify/core/localization/app_localizations.dart';

extension IslamicContentLocalizer on AppLocalizations {
  String tr(String text) {
    if (!isEnglish) return text;
    return _translations[text] ?? text;
  }

  String trCategory(String text) => tr(text);

  String versesCount(int count) => isEnglish ? '$count verses' : '$count AYAT';
  String verseLabel(int number) => isEnglish ? 'Verse $number' : 'Ayat $number';
  String readCount(int count) =>
      isEnglish ? 'Read ${count}x' : 'Dibaca ${count}x';
}

const Map<String, String> _translations = {
  // Quran
  'Baca dan renungkan firman Allah SWT':
      'Read and reflect on the words of Allah SWT',
  'Daftar Surah': 'Surah List',
  'Tandai & Simpan': 'Bookmarks & Saved',
  'Terakhir Dibaca': 'Last Read',
  'Gagal Memuat Al-Qur\'an': 'Failed to Load the Qur\'an',
  'Coba Lagi': 'Try Again',
  'Surah tidak ditemukan.': 'No surah found.',
  'Belum Ada Penanda': 'No Bookmarks Yet',
  'Ayat yang Anda tandai atau simpan akan muncul di tab ini.':
      'Verses you bookmark or save will appear in this tab.',

  // Menu/content
  '99 nama indah Allah': '99 beautiful names of Allah',
  'Doa Harian': 'Daily Duas',
  'Kumpulan doa sehari-hari': 'A collection of daily supplications',
  'Kalender Hijriah': 'Hijri Calendar',
  'Tanggal dan peristiwa Islam': 'Islamic dates and events',
  'Dzikir pagi dan petang': 'Morning and evening dhikr',
  'Tuntunan Salat': 'Prayer Guide',
  'Tata cara dan bacaan salat': 'Prayer steps and recitations',
  'Tips Islami': 'Islamic Tips',
  'Nasihat dan amalan ringan': 'Advice and light daily deeds',
  'Tidak ada tips saat ini.': 'No tips available right now.',
  'Gagal memuat tips islami.': 'Failed to load Islamic tips.',
  'Gagal memuat data doa': 'Failed to load duas',
  'Tidak ada event Hijriah mendatang.': 'No upcoming Hijri events.',
  'Gagal memuat event Hijriah': 'Failed to load Hijri events',

  // Categories
  'Ibadah': 'Worship',
  'Doa': 'Dua',
  'Akhlaq': 'Character',
  'Amal': 'Good Deeds',
  'Edukasi': 'Education',
  'Al-Quran': 'Qur\'an',
  'pagi': 'morning',
  'malam': 'night',
  'sebelum_makan': 'before eating',
  'sesudah_makan': 'after eating',
  'sebelum_tidur': 'before sleep',
  'bangun_tidur': 'after waking up',
  'kamar_mandi': 'bathroom',
  'ketakutan': 'fear',
  'sakit': 'illness',

  // Duas
  'Doa Pagi': 'Morning Dua',
  'Doa Malam': 'Evening Dua',
  'Doa Sebelum Makan': 'Dua Before Eating',
  'Doa Sesudah Makan': 'Dua After Eating',
  'Doa Sebelum Tidur': 'Dua Before Sleep',
  'Doa Bangun dari Tidur': 'Dua After Waking Up',
  'Doa Masuk Kamar Mandi': 'Dua Entering the Bathroom',
  'Doa Keluar Kamar Mandi': 'Dua Leaving the Bathroom',
  'Doa Ketika Takut': 'Dua When Afraid',
  'Doa Ketika Sakit': 'Dua When Sick',
  'Doa Rezeki': 'Dua for Sustenance',
  'Doa Perjalanan': 'Travel Dua',
  'Kami memasuki pagi dan segala kerajaan milik Allah.':
      'We enter the morning and all dominion belongs to Allah.',
  'Kami memasuki malam dan segala kerajaan milik Allah.':
      'We enter the evening and all dominion belongs to Allah.',
  'Dengan nama Allah dan atas berkah Allah.':
      'In the name of Allah and with Allah\'s blessing.',
  'Segala puji bagi Allah yang telah memberi kami makan.':
      'All praise is for Allah who has fed us.',
  'Ya Allah, dengan nama-Mu aku mati dan hidup.':
      'O Allah, in Your name I die and live.',
  'Segala puji bagi Allah yang telah menghidupkan kami.':
      'All praise is for Allah who gave us life again.',
  'Ya Allah, aku berlindung dari jin kotor.':
      'O Allah, I seek refuge in You from impure jinn.',
  'Aku memohon ampunan-Mu.': 'I seek Your forgiveness.',
  'Tidak ada tuhan selain Allah.': 'There is no god but Allah.',
  'Hilangkanlah penyakit, Tuhan manusia.':
      'Remove the illness, Lord of mankind.',
  'Ya Allah, aku meminta petunjuk.': 'O Allah, I ask You for guidance.',

  // Hijri events
  'Hari Asyura (10 Muharram)': 'Day of Ashura (10 Muharram)',
  'Maulid Nabi Muhammad (12 Rabiul Awal)':
      'Birth of Prophet Muhammad (12 Rabi al-Awwal)',
  'Bulan Ramadhan': 'Month of Ramadan',
  'Hari Raya Idul Fitri': 'Eid al-Fitr',
  'Hari Raya Idul Adha': 'Eid al-Adha',
  'Tahun Baru Hijriah (1 Muharram)': 'Hijri New Year (1 Muharram)',
  'Isra dan Miraj (27 Rajab)': 'Isra and Mi\'raj (27 Rajab)',
  'Lailatul Qadr (27 Ramadhan)': 'Laylat al-Qadr (27 Ramadan)',
  'Nabi Musa dan pengikutnya diselamatkan dari Firaun pada hari ini.':
      'Prophet Musa and his followers were saved from Pharaoh on this day.',
  'Perayaan kelahiran Nabi Muhammad SAW, didahului dengan ceramah-ceramah Islami dan sholawat.':
      'Commemoration of Prophet Muhammad\'s birth, often marked with Islamic talks and salawat.',
  'Bulan suci Ramadhan, bulan puasa dan ibadah yang sangat utama dalam Islam.':
      'The holy month of Ramadan, a month of fasting and major worship in Islam.',
  'Perayaan akhir bulan Ramadhan dengan sholat Id dan berkumpul bersama keluarga.':
      'Celebration at the end of Ramadan with Eid prayer and family gatherings.',
  'Hari pesta korban untuk memperingati kesediaan Nabi Ibrahim menyembelih anaknya.':
      'The day of sacrifice commemorating Prophet Ibrahim\'s willingness to sacrifice his son.',
  'Pergantian tahun Hijriah, peringatan dari hijrah Nabi Muhammad dari Makkah ke Madinah.':
      'The beginning of the Hijri year, remembering the Prophet\'s migration from Makkah to Madinah.',
  'Peristiwa perjalanan malam Nabi Muhammad dari Masjidil Haram ke Masjidil Aqsa dan naik ke langit.':
      'The night journey of Prophet Muhammad from Masjid al-Haram to Masjid al-Aqsa and ascension to the heavens.',
  'Malam yang mulia ketika Al-Quran pertama kali diturunkan kepada Nabi Muhammad SAW.':
      'The noble night when the Qur\'an was first revealed to Prophet Muhammad.',

  // Tips
  'Keutamaan Shalat Dhuha': 'The Virtue of Duha Prayer',
  'Shalat Dhuha adalah sedekah bagi setiap persendian tubuh manusia.':
      'Duha prayer is charity for every joint of the human body.',
  'Adab Berdoa': 'Etiquette of Dua',
  'Mulailah doa dengan memuji Allah dan bersholawat kepada Nabi Muhammad SAW.':
      'Begin dua by praising Allah and sending blessings upon Prophet Muhammad.',
  'Menahan Amarah': 'Controlling Anger',
  'Orang kuat adalah orang yang mampu mengendalikan dirinya ketika marah.':
      'The strong person is the one who controls themselves when angry.',
  'Keutamaan Tersenyum': 'The Virtue of Smiling',
  'Senyummu di hadapan saudaramu adalah sedekah.':
      'Your smile to your brother is charity.',
  'Sedekah Tersembunyi': 'Hidden Charity',
  'Sedekah tersembunyi menjaga keikhlasan dan menguatkan hubungan dengan Allah.':
      'Hidden charity protects sincerity and strengthens your relationship with Allah.',
  'Pentingnya Shalat Malam': 'The Importance of Night Prayer',
  'Shalat malam adalah kebiasaan orang saleh dan sarana mendekat kepada Allah.':
      'Night prayer is the habit of the righteous and a means of drawing closer to Allah.',
  'Membaca Al-Quran': 'Reading the Qur\'an',
  'Setiap huruf Al-Quran bernilai kebaikan yang dilipatgandakan.':
      'Every letter of the Qur\'an brings multiplied reward.',
};
