import 'package:solatify/features/prayer_guide/domain/models/prayer_guide_step.dart';

class PrayerGuideLocalDataSource {
  const PrayerGuideLocalDataSource();

  List<PrayerGuideSummary> getSummaries() => _summaryItems;

  List<PrayerGuideStep> getPrayerSteps() => _prayerSteps;

  List<PostPrayerDhikr> getPostPrayerDhikr() => _postPrayerDhikr;
}

const _summaryItems = [
  PrayerGuideSummary(
    title: 'Syarat Singkat',
    items: [
      'Suci dari hadas dan najis.',
      'Menutup aurat.',
      'Menghadap kiblat.',
      'Masuk waktu salat.',
    ],
  ),
  PrayerGuideSummary(
    title: 'Rukun Utama',
    items: [
      'Niat, berdiri bagi yang mampu, takbiratul ihram.',
      'Membaca Al-Fatihah, ruku, i’tidal, sujud, duduk, dan salam.',
      'Tertib mengikuti urutan rukun.',
    ],
  ),
  PrayerGuideSummary(
    title: 'Yang Membatalkan',
    items: [
      'Berbicara sengaja di luar bacaan salat.',
      'Makan atau minum dengan sengaja.',
      'Bergerak banyak tanpa kebutuhan.',
      'Batal wudhu saat salat.',
    ],
  ),
];

const _prayerSteps = [
  PrayerGuideStep(
    number: 1,
    title: 'Niat',
    description: 'Niatkan salat di dalam hati sesuai salat yang dikerjakan.',
    arabicText: 'أُصَلِّي فَرْضَ الصَّلَاةِ لِلّٰهِ تَعَالَى',
    latinText: 'Ushalli fardhash-shalati lillahi ta’ala.',
    meaning: 'Aku berniat mengerjakan salat fardu karena Allah Ta’ala.',
    note:
        'Lafaz niat dapat disesuaikan dengan salat yang dikerjakan. Inti niat berada di dalam hati.',
  ),
  PrayerGuideStep(
    number: 2,
    title: 'Takbiratul Ihram',
    description:
        'Angkat kedua tangan sejajar telinga atau bahu lalu ucapkan takbir pembuka salat.',
    arabicText: 'اَللّٰهُ أَكْبَرُ',
    latinText: 'Allahu akbar.',
    meaning: 'Allah Maha Besar.',
  ),
  PrayerGuideStep(
    number: 3,
    title: 'Doa Iftitah',
    description:
        'Baca doa pembuka setelah takbiratul ihram sebelum Al-Fatihah.',
    arabicText:
        'اَللّٰهُمَّ بَاعِدْ بَيْنِيْ وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ، اَللّٰهُمَّ نَقِّنِيْ مِنَ الْخَطَايَا كَمَا يُنَقَّى الثَّوْبُ الْأَبْيَضُ مِنَ الدَّنَسِ، اَللّٰهُمَّ اغْسِلْ خَطَايَايَ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ',
    latinText:
        'Allahumma ba’id baini wa baina khathayaya kama ba’adta bainal-masyriqi wal-maghrib. Allahumma naqqini minal-khathaya kama yunaqqats-tsaubul-abyadhu minad-danas. Allahummaghsil khathayaya bil-ma’i wats-tsalji wal-barad.',
    meaning:
        'Ya Allah, jauhkanlah aku dari kesalahan-kesalahanku sebagaimana Engkau menjauhkan antara timur dan barat. Ya Allah, bersihkanlah aku dari kesalahan sebagaimana kain putih dibersihkan dari kotoran. Ya Allah, cucilah kesalahanku dengan air, salju, dan embun.',
    note:
        'Doa iftitah memiliki beberapa riwayat bacaan yang sah. Bila belum hafal, salat tetap sah dengan langsung membaca Al-Fatihah.',
  ),
  PrayerGuideStep(
    number: 4,
    title: 'Al-Fatihah dan Surat Pendek',
    description:
        'Baca Al-Fatihah lengkap pada setiap rakaat, lalu surat pendek atau ayat Al-Qur’an yang mudah pada rakaat awal.',
    arabicText:
        'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nاَلْحَمْدُ لِلّٰهِ رَبِّ الْعَالَمِيْنَ\nالرَّحْمٰنِ الرَّحِيْمِ\nمَالِكِ يَوْمِ الدِّيْنِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِيْنُ\nاِهْدِنَا الصِّرَاطَ الْمُسْتَقِيْمَ\nصِرَاطَ الَّذِيْنَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوْبِ عَلَيْهِمْ وَلَا الضَّالِّيْنَ',
    latinText:
        'Bismillahirrahmanirrahim. Alhamdu lillahi rabbil-’alamin. Ar-rahmanir-rahim. Maliki yaumid-din. Iyyaka na’budu wa iyyaka nasta’in. Ihdinash-shirathal-mustaqim. Shirathalladzina an’amta ’alaihim ghairil-maghdhubi ’alaihim wa ladh-dhallin.',
    meaning:
        'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang. Segala puji bagi Allah, Tuhan seluruh alam. Yang Maha Pengasih, Maha Penyayang. Pemilik hari pembalasan. Hanya kepada-Mu kami menyembah dan hanya kepada-Mu kami memohon pertolongan. Tunjukilah kami jalan yang lurus, yaitu jalan orang-orang yang telah Engkau beri nikmat, bukan jalan mereka yang dimurkai dan bukan pula jalan mereka yang sesat.',
    note:
        'Setelah Al-Fatihah, baca surat pendek sesuai kemampuan, misalnya Al-Ikhlas: Qul huwallahu ahad, Allahush-shamad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad.',
  ),
  PrayerGuideStep(
    number: 5,
    title: 'Ruku',
    description:
        'Bungkukkan badan dengan punggung rata dan tenang, lalu baca tasbih ruku.',
    arabicText: 'سُبْحَانَ رَبِّيَ الْعَظِيْمِ وَبِحَمْدِهِ',
    latinText: 'Subhana rabbiyal-’azhimi wa bihamdih.',
    meaning: 'Maha Suci Tuhanku Yang Maha Agung dan segala puji bagi-Nya.',
    note:
        'Umumnya dibaca tiga kali atau lebih dengan tetap menjaga tuma’ninah.',
  ),
  PrayerGuideStep(
    number: 6,
    title: 'I’tidal',
    description: 'Bangkit dari ruku hingga berdiri tegak dan tenang.',
    arabicText:
        'سَمِعَ اللّٰهُ لِمَنْ حَمِدَهُ\nرَبَّنَا لَكَ الْحَمْدُ مِلْءَ السَّمٰوَاتِ وَمِلْءَ الْأَرْضِ وَمِلْءَ مَا شِئْتَ مِنْ شَيْءٍ بَعْدُ',
    latinText:
        'Sami’allahu liman hamidah. Rabbana lakal-hamdu mil’as-samawati wa mil’al-ardhi wa mil’a ma syi’ta min syai’in ba’du.',
    meaning:
        'Allah mendengar orang yang memuji-Nya. Ya Tuhan kami, bagi-Mu segala puji sepenuh langit, sepenuh bumi, dan sepenuh apa pun yang Engkau kehendaki setelah itu.',
  ),
  PrayerGuideStep(
    number: 7,
    title: 'Doa Qunut Subuh',
    description:
        'Baca doa qunut pada rakaat kedua salat Subuh setelah i’tidal bagi yang mengamalkannya.',
    arabicText:
        'اَللّٰهُمَّ اهْدِنِيْ فِيْمَنْ هَدَيْتَ، وَعَافِنِيْ فِيْمَنْ عَافَيْتَ، وَتَوَلَّنِيْ فِيْمَنْ تَوَلَّيْتَ، وَبَارِكْ لِيْ فِيْمَا أَعْطَيْتَ، وَقِنِيْ شَرَّ مَا قَضَيْتَ، فَإِنَّكَ تَقْضِيْ وَلَا يُقْضَى عَلَيْكَ، إِنَّهُ لَا يَذِلُّ مَنْ وَالَيْتَ، وَلَا يَعِزُّ مَنْ عَادَيْتَ، تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ',
    latinText:
        'Allahummahdini fiman hadait, wa ’afini fiman ’afait, wa tawallani fiman tawallait, wa barik li fima a’thait, wa qini syarra ma qadhait. Fa innaka taqdhi wa la yuqdha ’alaik. Innahu la yadzillu man walait, wa la ya’izzu man ’adait. Tabarakta rabbana wa ta’alait.',
    meaning:
        'Ya Allah, berilah aku petunjuk bersama orang yang Engkau beri petunjuk. Berilah aku kesehatan bersama orang yang Engkau beri kesehatan. Peliharalah aku bersama orang yang Engkau pelihara. Berkahilah apa yang Engkau berikan kepadaku. Lindungilah aku dari keburukan yang Engkau tetapkan. Sesungguhnya Engkau yang menetapkan dan tidak ada yang menetapkan atas-Mu. Tidak akan hina orang yang Engkau lindungi, dan tidak akan mulia orang yang Engkau musuhi. Maha Berkah Engkau wahai Tuhan kami dan Maha Tinggi Engkau.',
    note:
        'Qunut Subuh adalah amalan yang dipakai dalam sebagian mazhab, termasuk praktik yang umum di Indonesia. Jika tidak mengamalkannya, lanjutkan ke sujud setelah i’tidal.',
  ),
  PrayerGuideStep(
    number: 8,
    title: 'Sujud',
    description:
        'Sujud dengan tujuh anggota sujud dan tenang, lalu baca tasbih sujud.',
    arabicText: 'سُبْحَانَ رَبِّيَ الْأَعْلَى وَبِحَمْدِهِ',
    latinText: 'Subhana rabbiyal-a’la wa bihamdih.',
    meaning: 'Maha Suci Tuhanku Yang Maha Tinggi dan segala puji bagi-Nya.',
    note:
        'Umumnya dibaca tiga kali atau lebih. Perbanyak doa saat sujud bila memungkinkan.',
  ),
  PrayerGuideStep(
    number: 9,
    title: 'Duduk Antara Dua Sujud',
    description: 'Duduk dengan tenang di antara dua sujud.',
    arabicText:
        'رَبِّ اغْفِرْ لِيْ وَارْحَمْنِيْ وَاجْبُرْنِيْ وَارْفَعْنِيْ وَارْزُقْنِيْ وَاهْدِنِيْ وَعَافِنِيْ وَاعْفُ عَنِّيْ',
    latinText:
        'Rabbighfirli warhamni wajburni warfa’ni warzuqni wahdini wa’afini wa’fu ’anni.',
    meaning:
        'Ya Tuhanku, ampunilah aku, rahmatilah aku, cukupkanlah aku, angkatlah derajatku, berilah aku rezeki, petunjuk, kesehatan, dan maafkanlah aku.',
  ),
  PrayerGuideStep(
    number: 10,
    title: 'Tahiyat Awal',
    description:
        'Duduk tasyahud awal pada salat yang memiliki lebih dari dua rakaat.',
    arabicText:
        'اَلتَّحِيَّاتُ الْمُبَارَكَاتُ الصَّلَوَاتُ الطَّيِّبَاتُ لِلّٰهِ، اَلسَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللّٰهِ وَبَرَكَاتُهُ، اَلسَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللّٰهِ الصَّالِحِيْنَ، أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُوْلُ اللّٰهِ',
    latinText:
        'At-tahiyyatul mubarakatush-shalawatuth-thayyibatu lillah. Assalamu ’alaika ayyuhan-nabiyyu wa rahmatullahi wa barakatuh. Assalamu ’alaina wa ’ala ’ibadillahish-shalihin. Asyhadu an la ilaha illallah, wa asyhadu anna Muhammadan rasulullah.',
    meaning:
        'Segala penghormatan, keberkahan, salawat, dan kebaikan adalah milik Allah. Semoga keselamatan, rahmat Allah, dan berkah-Nya tercurah kepadamu wahai Nabi. Semoga keselamatan tercurah kepada kami dan hamba-hamba Allah yang saleh. Aku bersaksi bahwa tidak ada tuhan selain Allah, dan aku bersaksi bahwa Muhammad adalah utusan Allah.',
  ),
  PrayerGuideStep(
    number: 11,
    title: 'Tahiyat Akhir',
    description:
        'Duduk tasyahud akhir sebelum salam, lalu baca tasyahud dan salawat.',
    arabicText:
        'اَلتَّحِيَّاتُ الْمُبَارَكَاتُ الصَّلَوَاتُ الطَّيِّبَاتُ لِلّٰهِ، اَلسَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللّٰهِ وَبَرَكَاتُهُ، اَلسَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللّٰهِ الصَّالِحِيْنَ، أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُوْلُ اللّٰهِ\nاَللّٰهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيْمَ وَعَلَى آلِ إِبْرَاهِيْمَ، وَبَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيْمَ وَعَلَى آلِ إِبْرَاهِيْمَ فِي الْعَالَمِيْنَ إِنَّكَ حَمِيْدٌ مَجِيْدٌ',
    latinText:
        'At-tahiyyatul mubarakatush-shalawatuth-thayyibatu lillah. Assalamu ’alaika ayyuhan-nabiyyu wa rahmatullahi wa barakatuh. Assalamu ’alaina wa ’ala ’ibadillahish-shalihin. Asyhadu an la ilaha illallah, wa asyhadu anna Muhammadan rasulullah. Allahumma shalli ’ala Muhammad wa ’ala ali Muhammad, kama shallaita ’ala Ibrahim wa ’ala ali Ibrahim. Wa barik ’ala Muhammad wa ’ala ali Muhammad, kama barakta ’ala Ibrahim wa ’ala ali Ibrahim fil-’alamin, innaka hamidum majid.',
    meaning:
        'Segala penghormatan, keberkahan, salawat, dan kebaikan adalah milik Allah. Semoga keselamatan, rahmat Allah, dan berkah-Nya tercurah kepada Nabi. Semoga keselamatan tercurah kepada kami dan hamba-hamba Allah yang saleh. Aku bersaksi bahwa tidak ada tuhan selain Allah, dan aku bersaksi bahwa Muhammad adalah utusan Allah. Ya Allah, limpahkanlah salawat dan keberkahan kepada Nabi Muhammad dan keluarga Nabi Muhammad sebagaimana Engkau melimpahkannya kepada Nabi Ibrahim dan keluarga Nabi Ibrahim. Sesungguhnya Engkau Maha Terpuji lagi Maha Mulia.',
    note:
        'Setelah tahiyat akhir, boleh membaca doa perlindungan sebelum salam sesuai hafalan.',
  ),
  PrayerGuideStep(
    number: 12,
    title: 'Salam',
    description: 'Akhiri salat dengan salam ke kanan dan ke kiri.',
    arabicText: 'اَلسَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللّٰهِ',
    latinText: 'Assalamu’alaikum wa rahmatullah.',
    meaning: 'Semoga keselamatan dan rahmat Allah tercurah kepada kalian.',
  ),
];

const _postPrayerDhikr = [
  PostPrayerDhikr(
    title: 'Istighfar',
    arabicText: 'أَسْتَغْفِرُ اللّٰهَ',
    latinText: 'Astaghfirullah.',
    meaning: 'Aku memohon ampun kepada Allah.',
    count: 3,
  ),
  PostPrayerDhikr(
    title: 'Tasbih',
    arabicText: 'سُبْحَانَ اللّٰهِ',
    latinText: 'Subhanallah.',
    meaning: 'Maha Suci Allah.',
    count: 33,
  ),
  PostPrayerDhikr(
    title: 'Tahmid',
    arabicText: 'اَلْحَمْدُ لِلّٰهِ',
    latinText: 'Alhamdulillah.',
    meaning: 'Segala puji bagi Allah.',
    count: 33,
  ),
  PostPrayerDhikr(
    title: 'Takbir',
    arabicText: 'اَللّٰهُ أَكْبَرُ',
    latinText: 'Allahu akbar.',
    meaning: 'Allah Maha Besar.',
    count: 33,
  ),
];
