import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dhikr_model.dart';

final morningDhikrProvider = Provider<List<Dhikr>>((ref) => _morningDhikr);
final eveningDhikrProvider = Provider<List<Dhikr>>((ref) => _eveningDhikr);

final List<Dhikr> _morningDhikr = [
  Dhikr(
    id: 1, 
    title: 'Ayat Kursi', 
    arabicText: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...', 
    latinText: 'Allahu la ilaha illa Huwa, Al-Hayyul-Qayyum...', 
    meaning: 'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, Yang terus menerus mengurus (makhluk-Nya)...', 
    count: 1,
    note: 'Barangsiapa membacanya di pagi hari, maka ia akan dilindungi dari jin hingga petang.'
  ),
  Dhikr(
    id: 2, 
    title: 'Al-Ikhlas, Al-Falaq, An-Nas', 
    arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ... \n\n قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... \n\n قُلْ أَعُوذُ بِرَبِّ النَّاسِ...', 
    latinText: 'Qul Huwallahu Ahad... \n Qul a\'udzu birabbil falaq... \n Qul a\'udzu birabbin-nas...', 
    meaning: 'Katakanlah: Dialah Allah, Yang Maha Esa... \n Katakanlah: Aku berlindung kepada Tuhan yang menguasai subuh... \n Katakanlah: Aku berlindung kepada Tuhan manusia...', 
    count: 3,
    note: 'Membaca ketiga surah ini masing-masing tiga kali.'
  ),
  Dhikr(
    id: 3, 
    title: 'Sayyidul Istighfar', 
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ...', 
    latinText: 'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduka...', 
    meaning: 'Ya Allah, Engkau adalah Tuhanku, tidak ada tuhan selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu...', 
    count: 1,
    note: 'Pemimpin istighfar.'
  ),
  Dhikr(
    id: 4, 
    title: 'Memohon Ilmu, Rezeki & Amal', 
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا', 
    latinText: 'Allahumma inni as-aluka \'ilman nafi\'an, wa rizqan tayyiban, wa \'amalan mutaqabbalan', 
    meaning: 'Ya Allah, sungguh aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amal yang diterima.', 
    count: 1
  ),
  Dhikr(
    id: 5, 
    title: 'Dzikir Tahlil Pendek', 
    arabicText: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', 
    latinText: 'La ilaha illallah wahdahu la syarika lah, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli syai-in qadir', 
    meaning: 'Tidak ada tuhan selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan pujian. Dan Dia Maha Kuasa atas segala sesuatu.', 
    count: 10,
    note: 'Bisa juga dibaca 100x'
  ),
];

final List<Dhikr> _eveningDhikr = [
  Dhikr(
    id: 1, 
    title: 'Ayat Kursi', 
    arabicText: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...', 
    latinText: 'Allahu la ilaha illa Huwa, Al-Hayyul-Qayyum...', 
    meaning: 'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, Yang terus menerus mengurus (makhluk-Nya)...', 
    count: 1,
    note: 'Barangsiapa membacanya di petang hari, maka ia akan dilindungi dari jin hingga pagi.'
  ),
  Dhikr(
    id: 2, 
    title: 'Al-Ikhlas, Al-Falaq, An-Nas', 
    arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ... \n\n قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... \n\n قُلْ أَعُوذُ بِرَبِّ النَّاسِ...', 
    latinText: 'Qul Huwallahu Ahad... \n Qul a\'udzu birabbil falaq... \n Qul a\'udzu birabbin-nas...', 
    meaning: 'Katakanlah: Dialah Allah, Yang Maha Esa... \n Katakanlah: Aku berlindung kepada Tuhan yang menguasai subuh... \n Katakanlah: Aku berlindung kepada Tuhan manusia...', 
    count: 3
  ),
  Dhikr(
    id: 3, 
    title: 'Sayyidul Istighfar', 
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ...', 
    latinText: 'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduka...', 
    meaning: 'Ya Allah, Engkau adalah Tuhanku, tidak ada tuhan selain Engkau. Engkau telah menciptakanku dan aku adalah hamba-Mu...', 
    count: 1
  ),
  Dhikr(
    id: 4, 
    title: 'Memohon Perlindungan Diri', 
    arabicText: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ', 
    latinText: 'Bismillahil-ladzi la yadhurru ma\'asmihi syai-un fil-ardhi wa la fis-sama-i wa huwas-sami\'ul-\'alim', 
    meaning: 'Dengan nama Allah yang bila disebut, segala sesuatu di bumi dan langit tidak akan berbahaya, Dia-lah Yang Maha Mendengar lagi Maha Mengetahui.', 
    count: 3
  ),
  Dhikr(
    id: 5, 
    title: 'Dzikir Tahlil Pendek', 
    arabicText: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', 
    latinText: 'La ilaha illallah wahdahu la syarika lah, lahul-mulku wa lahul-hamdu wa huwa \'ala kulli syai-in qadir', 
    meaning: 'Tidak ada tuhan selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya. Milik-Nya kerajaan dan pujian. Dan Dia Maha Kuasa atas segala sesuatu.', 
    count: 10
  ),
];
