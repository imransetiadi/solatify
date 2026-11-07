import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dhikr_model.dart';

final morningDhikrProvider = Provider<List<Dhikr>>((ref) => _morningDhikr);
final eveningDhikrProvider = Provider<List<Dhikr>>((ref) => _eveningDhikr);

final List<Dhikr> _morningDhikr = [
  Dhikr(
    id: 1,
    title: 'Ayat Kursi',
    // QS. Al-Baqarah 2:255, from the same API as the Quran reader.
    arabicText:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    latinText:
        'Allahu laaa ilaaha illaa Huwal Haiyul Qaiyoom; laa taakhuzuhoo sinatunw wa laa nawm; lahoo maa fissamaawaati wa maa fil ard; man zal lazee yashfa\'u indahooo illaa bi-iznih; ya\'lamu maa baina aydeehim wa mww khalfahum wa laa yuheetoona bishai\'im min \'ilmihee illaa bimaa shaaa\'; wasi\'a Kursiyyuhus samaawaati wal arda wa laa ya\'ooduho hifzuhumaa; wa Huwal Aliyyul \'Azeem',
    meaning:
        'Allah, tidak ada tuhan selain Dia. Yang Mahahidup, Yang terus menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu apa pun tentang ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dan Dia tidak merasa berat memelihara keduanya, dan Dia Mahatinggi, Mahabesar.',
    count: 1,
    note:
        'Barangsiapa membacanya di pagi hari, maka ia akan dilindungi dari jin hingga petang.',
  ),
  Dhikr(
    id: 2,
    title: 'Al-Ikhlas, Al-Falaq, An-Nas',
    // QS. Al-Ikhlas, Al-Falaq and An-Nas in full, from the Quran reader API.
    arabicText:
        'قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ\n\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِن شَرِّ مَا خَلَقَ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَٰهِ النَّاسِ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ مِنَ الْجِنَّةِ وَالنَّاسِ',
    latinText:
        'Qul huwal laahu ahad Allah hus-samad Lam yalid wa lam yoolad Wa lam yakul-lahu kufuwan ahad\n\nQul a\'uzoo bi rabbil-falaq Min sharri ma khalaq Wa min sharri ghasiqin iza waqab Wa min sharrin-naffaa-thaati fil \'uqad Wa min shar ri haasidin iza hasad\n\nQul a\'uzu birabbin naas Malikin naas Ilaahin naas Min sharril was waasil khannaas Al lazee yuwas wisu fee sudoorin naas Minal jinnati wan naas',
    meaning:
        'Katakanlah (Muhammad), “Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. (Allah) tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu yang setara dengan Dia.”\n\nKatakanlah, “Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan (perempuan-perempuan) penyihir yang meniup pada buhul-buhul (talinya), dan dari kejahatan orang yang dengki apabila dia dengki.”\n\nKatakanlah, “Aku berlindung kepada Tuhannya manusia, Raja manusia, sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia.”',
    count: 3,
    note: 'Membaca ketiga surah ini masing-masing tiga kali.',
  ),
  Dhikr(
    id: 3,
    title: 'Sayyidul Istighfar',
    // HR. Bukhari no. 6306.
    arabicText:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latinText:
        'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastatha\'tu, a\'udzu bika min syarri ma shana\'tu, abu-u laka bini\'matika \'alayya, wa abu-u laka bidzanbi faghfirli, fa innahu la yaghfirudz-dzunuba illa anta',
    meaning:
        'Ya Allah, Engkau adalah Tuhanku, tidak ada tuhan selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu. Aku berada di atas perjanjian dan janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan perbuatanku. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, maka ampunilah aku. Sesungguhnya tidak ada yang mengampuni dosa selain Engkau.',
    count: 1,
    note: 'Pemimpin istighfar.',
  ),
  Dhikr(
    id: 4,
    title: 'Memohon Ilmu, Rezeki & Amal',
    arabicText:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
    latinText:
        'Allahumma inni as-aluka \'ilman nafi\'an, wa rizqan tayyiban, wa \'amalan mutaqabbalan',
    meaning:
        'Ya Allah, sungguh aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amal yang diterima.',
    count: 1,
  ),
  Dhikr(
    id: 5,
    title: 'Dzikir Tahlil Pendek',
    arabicText:
        'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    latinText:
        'La ilaha illallah wahdahu la syarika lah, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli syai-in qadir',
    meaning:
        'Tidak ada tuhan selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan pujian. Dan Dia Maha Kuasa atas segala sesuatu.',
    count: 10,
    note: 'Bisa juga dibaca 100x',
  ),
];

final List<Dhikr> _eveningDhikr = [
  Dhikr(
    id: 1,
    title: 'Ayat Kursi',
    // QS. Al-Baqarah 2:255, from the same API as the Quran reader.
    arabicText:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    latinText:
        'Allahu laaa ilaaha illaa Huwal Haiyul Qaiyoom; laa taakhuzuhoo sinatunw wa laa nawm; lahoo maa fissamaawaati wa maa fil ard; man zal lazee yashfa\'u indahooo illaa bi-iznih; ya\'lamu maa baina aydeehim wa mww khalfahum wa laa yuheetoona bishai\'im min \'ilmihee illaa bimaa shaaa\'; wasi\'a Kursiyyuhus samaawaati wal arda wa laa ya\'ooduho hifzuhumaa; wa Huwal Aliyyul \'Azeem',
    meaning:
        'Allah, tidak ada tuhan selain Dia. Yang Mahahidup, Yang terus menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang di hadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu apa pun tentang ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dan Dia tidak merasa berat memelihara keduanya, dan Dia Mahatinggi, Mahabesar.',
    count: 1,
    note:
        'Barangsiapa membacanya di petang hari, maka ia akan dilindungi dari jin hingga pagi.',
  ),
  Dhikr(
    id: 2,
    title: 'Al-Ikhlas, Al-Falaq, An-Nas',
    // QS. Al-Ikhlas, Al-Falaq and An-Nas in full, from the Quran reader API.
    arabicText:
        'قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ\n\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِن شَرِّ مَا خَلَقَ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَٰهِ النَّاسِ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ مِنَ الْجِنَّةِ وَالنَّاسِ',
    latinText:
        'Qul huwal laahu ahad Allah hus-samad Lam yalid wa lam yoolad Wa lam yakul-lahu kufuwan ahad\n\nQul a\'uzoo bi rabbil-falaq Min sharri ma khalaq Wa min sharri ghasiqin iza waqab Wa min sharrin-naffaa-thaati fil \'uqad Wa min shar ri haasidin iza hasad\n\nQul a\'uzu birabbin naas Malikin naas Ilaahin naas Min sharril was waasil khannaas Al lazee yuwas wisu fee sudoorin naas Minal jinnati wan naas',
    meaning:
        'Katakanlah (Muhammad), “Dialah Allah, Yang Maha Esa. Allah tempat meminta segala sesuatu. (Allah) tidak beranak dan tidak pula diperanakkan. Dan tidak ada sesuatu yang setara dengan Dia.”\n\nKatakanlah, “Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan (perempuan-perempuan) penyihir yang meniup pada buhul-buhul (talinya), dan dari kejahatan orang yang dengki apabila dia dengki.”\n\nKatakanlah, “Aku berlindung kepada Tuhannya manusia, Raja manusia, sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia.”',
    count: 3,
  ),
  Dhikr(
    id: 3,
    title: 'Sayyidul Istighfar',
    // HR. Bukhari no. 6306.
    arabicText:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    latinText:
        'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastatha\'tu, a\'udzu bika min syarri ma shana\'tu, abu-u laka bini\'matika \'alayya, wa abu-u laka bidzanbi faghfirli, fa innahu la yaghfirudz-dzunuba illa anta',
    meaning:
        'Ya Allah, Engkau adalah Tuhanku, tidak ada tuhan selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu. Aku berada di atas perjanjian dan janji-Mu semampuku. Aku berlindung kepada-Mu dari keburukan perbuatanku. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku, maka ampunilah aku. Sesungguhnya tidak ada yang mengampuni dosa selain Engkau.',
    count: 1,
  ),
  Dhikr(
    id: 4,
    title: 'Memohon Perlindungan Diri',
    arabicText:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    latinText:
        'Bismillahil-ladzi la yadhurru ma\'asmihi syai-un fil-ardhi wa la fis-sama-i wa huwas-sami\'ul-\'alim',
    meaning:
        'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan langit tidak akan berbahaya, Dia-lah Yang Maha Mendengar lagi Maha Mengetahui.',
    count: 3,
  ),
  Dhikr(
    id: 5,
    title: 'Dzikir Tahlil Pendek',
    arabicText:
        'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    latinText:
        'La ilaha illallah wahdahu la syarika lah, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli syai-in qadir',
    meaning:
        'Tidak ada tuhan selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan pujian. Dan Dia Maha Kuasa atas segala sesuatu.',
    count: 10,
  ),
];
