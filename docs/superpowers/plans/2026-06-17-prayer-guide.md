# Tuntunan Salat Lengkap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an offline `Tuntunan Salat` feature in `Konten Islami` with ordered prayer steps, Arabic readings, latin transliteration, Indonesian meaning, and concise supporting notes.

**Architecture:** Create a focused `prayer_guide` feature with immutable local models and Riverpod providers for static v1 content. Add a new screen and route, then integrate the menu card into the existing `IslamicContentScreen` without changing unrelated content features.

**Tech Stack:** Flutter, Riverpod, GoRouter, widget tests, existing `IslamicBackground`, `ResponsiveCenter`, `ResponsiveLayout`, and `AppTheme` tokens.

---

### Task 1: Failing Integration Tests

**Files:**
- Modify: `test/islamic_content_smoke_test.dart`
- Modify: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add content menu and screen tests**

In `test/islamic_content_smoke_test.dart`, add imports once the screen exists during implementation:

```dart
import 'package:solatify/features/prayer_guide/presentation/screens/prayer_guide_screen.dart';
```

Add these tests near the existing content smoke tests:

```dart
testWidgets('Content menu renders prayer guide card', (tester) async {
  await tester.pumpWidget(wrap(const IslamicContentScreen()));
  await tester.pumpAndSettle();

  expect(find.text('Tuntunan Salat'), findsOneWidget);
  expect(find.text('Tata cara dan bacaan salat'), findsOneWidget);
  expect(tester.takeException(), isNull);
});

testWidgets('Prayer guide screen renders complete reading sections', (
  tester,
) async {
  await tester.pumpWidget(wrap(const PrayerGuideScreen()));
  await tester.pumpAndSettle();

  expect(find.text('Tuntunan Salat Lengkap'), findsOneWidget);
  expect(find.text('Niat'), findsWidgets);
  expect(find.byKey(const Key('prayer_guide_arabic_text')), findsWidgets);
  expect(find.textContaining('Allahu akbar'), findsWidgets);
  expect(find.textContaining('Allah Maha Besar'), findsWidgets);
  expect(tester.takeException(), isNull);
});

testWidgets('Prayer guide screen does not overflow on compact Android width', (
  tester,
) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(wrap(const PrayerGuideScreen()));
  await tester.pumpAndSettle();

  await tester.fling(find.byType(ListView), const Offset(0, -700), 1000);
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('prayer_guide_arabic_text')), findsWidgets);
  expect(tester.takeException(), isNull);
});
```

- [ ] **Step 2: Add routed smoke test expectation**

In `test/routed_screen_smoke_test.dart`, import the new screen during implementation:

```dart
import 'package:solatify/features/prayer_guide/presentation/screens/prayer_guide_screen.dart';
```

Add this test near the other routed screen tests:

```dart
testWidgets('Prayer guide screen renders', (tester) async {
  await tester.pumpWidget(wrap(const PrayerGuideScreen()));
  await tester.pumpAndSettle();

  expect(find.text('Tuntunan Salat Lengkap'), findsOneWidget);
  expect(find.textContaining('Takbiratul Ihram'), findsWidgets);
  expect(tester.takeException(), isNull);
});
```

- [ ] **Step 3: Run tests and confirm RED**

Run:

```bash
flutter test --no-pub test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart
```

Expected: tests fail because `PrayerGuideScreen` and the route/menu integration do not exist yet.

### Task 2: Local Prayer Guide Model and Providers

**Files:**
- Create: `lib/features/prayer_guide/domain/models/prayer_guide_step.dart`
- Create: `lib/features/prayer_guide/presentation/providers/prayer_guide_provider.dart`

- [ ] **Step 1: Create local immutable models**

Create `lib/features/prayer_guide/domain/models/prayer_guide_step.dart`:

```dart
class PrayerGuideSummary {
  const PrayerGuideSummary({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}

class PrayerGuideStep {
  const PrayerGuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.arabicText,
    required this.latinText,
    required this.meaning,
    this.note = '',
  });

  final int number;
  final String title;
  final String description;
  final String arabicText;
  final String latinText;
  final String meaning;
  final String note;
}

class PostPrayerDhikr {
  const PostPrayerDhikr({
    required this.title,
    required this.arabicText,
    required this.latinText,
    required this.meaning,
    required this.count,
  });

  final String title;
  final String arabicText;
  final String latinText;
  final String meaning;
  final int count;
}
```

- [ ] **Step 2: Create static providers and content**

Create `lib/features/prayer_guide/presentation/providers/prayer_guide_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/prayer_guide/domain/models/prayer_guide_step.dart';

final prayerGuideSummariesProvider = Provider<List<PrayerGuideSummary>>((ref) {
  return _summaryItems;
});

final prayerGuideStepsProvider = Provider<List<PrayerGuideStep>>((ref) {
  return _prayerSteps;
});

final postPrayerDhikrProvider = Provider<List<PostPrayerDhikr>>((ref) {
  return _postPrayerDhikr;
});

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
    note: 'Lafaz niat dapat disesuaikan dengan salat yang dikerjakan. Inti niat berada di dalam hati.',
  ),
  PrayerGuideStep(
    number: 2,
    title: 'Takbiratul Ihram',
    description: 'Angkat kedua tangan lalu ucapkan takbir pembuka salat.',
    arabicText: 'اَللّٰهُ أَكْبَرُ',
    latinText: 'Allahu akbar.',
    meaning: 'Allah Maha Besar.',
  ),
  PrayerGuideStep(
    number: 3,
    title: 'Doa Iftitah',
    description: 'Baca doa pembuka setelah takbiratul ihram.',
    arabicText: 'اَللّٰهُمَّ بَاعِدْ بَيْنِيْ وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
    latinText: 'Allahumma ba’id baini wa baina khathayaya kama ba’adta bainal-masyriqi wal-maghrib.',
    meaning: 'Ya Allah, jauhkanlah aku dari kesalahan-kesalahanku sebagaimana Engkau menjauhkan antara timur dan barat.',
    note: 'Doa iftitah memiliki beberapa riwayat bacaan yang sah.',
  ),
  PrayerGuideStep(
    number: 4,
    title: 'Al-Fatihah dan Surat Pendek',
    description: 'Baca Al-Fatihah, lalu surat atau ayat Al-Qur’an yang mudah.',
    arabicText: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
    latinText: 'Bismillahirrahmanirrahim.',
    meaning: 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
    note: 'Al-Fatihah dibaca pada setiap rakaat. Setelah itu baca surat pendek pada rakaat awal sesuai kemampuan.',
  ),
  PrayerGuideStep(
    number: 5,
    title: 'Ruku',
    description: 'Bungkukkan badan dengan tenang, lalu baca tasbih ruku.',
    arabicText: 'سُبْحَانَ رَبِّيَ الْعَظِيْمِ وَبِحَمْدِهِ',
    latinText: 'Subhana rabbiyal-’azhimi wa bihamdih.',
    meaning: 'Maha Suci Tuhanku Yang Maha Agung dan segala puji bagi-Nya.',
  ),
  PrayerGuideStep(
    number: 6,
    title: 'I’tidal',
    description: 'Bangkit dari ruku hingga berdiri tegak.',
    arabicText: 'سَمِعَ اللّٰهُ لِمَنْ حَمِدَهُ رَبَّنَا لَكَ الْحَمْدُ',
    latinText: 'Sami’allahu liman hamidah. Rabbana lakal-hamd.',
    meaning: 'Allah mendengar orang yang memuji-Nya. Ya Tuhan kami, bagi-Mu segala puji.',
  ),
  PrayerGuideStep(
    number: 7,
    title: 'Sujud',
    description: 'Sujud dengan tenang, lalu baca tasbih sujud.',
    arabicText: 'سُبْحَانَ رَبِّيَ الْأَعْلَى وَبِحَمْدِهِ',
    latinText: 'Subhana rabbiyal-a’la wa bihamdih.',
    meaning: 'Maha Suci Tuhanku Yang Maha Tinggi dan segala puji bagi-Nya.',
  ),
  PrayerGuideStep(
    number: 8,
    title: 'Duduk Antara Dua Sujud',
    description: 'Duduk dengan tenang di antara dua sujud.',
    arabicText: 'رَبِّ اغْفِرْ لِيْ وَارْحَمْنِيْ وَاجْبُرْنِيْ وَارْفَعْنِيْ وَارْزُقْنِيْ وَاهْدِنِيْ وَعَافِنِيْ وَاعْفُ عَنِّيْ',
    latinText: 'Rabbighfirli warhamni wajburni warfa’ni warzuqni wahdini wa’afini wa’fu ’anni.',
    meaning: 'Ya Tuhanku, ampunilah aku, rahmatilah aku, cukupkanlah aku, angkatlah derajatku, berilah aku rezeki, petunjuk, kesehatan, dan maafkanlah aku.',
  ),
  PrayerGuideStep(
    number: 9,
    title: 'Tahiyat Awal',
    description: 'Duduk tasyahud awal pada salat yang memiliki lebih dari dua rakaat.',
    arabicText: 'اَلتَّحِيَّاتُ الْمُبَارَكَاتُ الصَّلَوَاتُ الطَّيِّبَاتُ لِلّٰهِ',
    latinText: 'At-tahiyyatul mubarakatush shalawatuth thayyibatu lillah.',
    meaning: 'Segala penghormatan, keberkahan, salawat, dan kebaikan adalah milik Allah.',
  ),
  PrayerGuideStep(
    number: 10,
    title: 'Tahiyat Akhir',
    description: 'Duduk tasyahud akhir sebelum salam.',
    arabicText: 'اَللّٰهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
    latinText: 'Allahumma shalli ’ala Muhammad wa ’ala ali Muhammad.',
    meaning: 'Ya Allah, limpahkanlah salawat kepada Nabi Muhammad dan keluarga Nabi Muhammad.',
    note: 'Bacaan tahiyat akhir dilanjutkan dengan salawat dan doa sebelum salam.',
  ),
  PrayerGuideStep(
    number: 11,
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
```

- [ ] **Step 3: Run focused tests**

Run:

```bash
flutter test --no-pub test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart
```

Expected: tests still fail because the screen, menu, and route are not yet implemented.

### Task 3: Prayer Guide Screen UI

**Files:**
- Create: `lib/features/prayer_guide/presentation/screens/prayer_guide_screen.dart`

- [ ] **Step 1: Create screen shell and cards**

Create `lib/features/prayer_guide/presentation/screens/prayer_guide_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/prayer_guide/domain/models/prayer_guide_step.dart';
import 'package:solatify/features/prayer_guide/presentation/providers/prayer_guide_provider.dart';

class PrayerGuideScreen extends ConsumerWidget {
  const PrayerGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final primaryColor = AppTheme.readableAccent(context);
    final mutedColor = theme.brightness == Brightness.dark
        ? AppTheme.darkModeTextSecondary
        : AppTheme.lightModeTextSecondary;
    final summaries = ref.watch(prayerGuideSummariesProvider);
    final steps = ref.watch(prayerGuideStepsProvider);
    final dhikr = ref.watch(postPrayerDhikrProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/islamic-content'),
        ),
        title: Text(
          'Tuntunan Salat Lengkap',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: ListView(
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              top: kToolbarHeight + MediaQuery.paddingOf(context).top + 8,
              bottom: 96,
            ),
            children: [
              IslamicHeaderDecoration(
                title: 'Panduan Salat',
                subtitle: 'Urutan salat dari niat sampai salam',
                accentColor: primaryColor,
              ),
              const SizedBox(height: 16),
              _SectionTitle(
                icon: Icons.info_outline,
                title: 'Ringkasan Penting',
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              for (final summary in summaries) ...[
                _SummaryCard(
                  summary: summary,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              _SectionTitle(
                icon: Icons.format_list_numbered,
                title: 'Langkah dan Bacaan',
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              for (final step in steps) ...[
                _PrayerStepCard(
                  step: step,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              _SectionTitle(
                icon: Icons.favorite_outline,
                title: 'Dzikir Setelah Salat',
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              for (final item in dhikr) ...[
                _PostPrayerDhikrCard(
                  dhikr: item,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
  });

  final PrayerGuideSummary summary;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
            const SizedBox(height: 8),
            for (final item in summary.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(color: mutedColor, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PrayerStepCard extends StatelessWidget {
  const _PrayerStepCard({
    required this.step,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
  });

  final PrayerGuideStep step;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: primaryColor.withValues(alpha: 0.14),
                  child: Text(
                    '${step.number}',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  step.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(step.description, style: TextStyle(color: mutedColor, fontSize: 13, height: 1.45)),
            const SizedBox(height: 12),
            _ArabicTextBlock(text: step.arabicText, textColor: textColor, primaryColor: primaryColor),
            const SizedBox(height: 12),
            Text(
              step.latinText,
              style: TextStyle(color: mutedColor, fontSize: 14, height: 1.55, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text(step.meaning, style: TextStyle(color: textColor, fontSize: 14, height: 1.5)),
            if (step.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              _NoteBox(text: step.note, color: primaryColor, textColor: mutedColor),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostPrayerDhikrCard extends StatelessWidget {
  const _PostPrayerDhikrCard({
    required this.dhikr,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
  });

  final PostPrayerDhikr dhikr;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  dhikr.title,
                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                if (dhikr.count > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${dhikr.count}x',
                      style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _ArabicTextBlock(text: dhikr.arabicText, textColor: textColor, primaryColor: primaryColor),
            const SizedBox(height: 8),
            Text(
              dhikr.latinText,
              style: TextStyle(color: mutedColor, fontSize: 13, height: 1.45, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 6),
            Text(dhikr.meaning, style: TextStyle(color: textColor, fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _ArabicTextBlock extends StatelessWidget {
  const _ArabicTextBlock({required this.text, required this.textColor, required this.primaryColor});

  final String text;
  final Color textColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('prayer_guide_arabic_text'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        softWrap: true,
        style: TextStyle(color: textColor, fontSize: 23, height: 1.9, fontFamily: 'Kufi'),
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text, required this.color, required this.textColor});

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, height: 1.45)),
    );
  }
}
```

- [ ] **Step 2: Run focused tests**

Run:

```bash
flutter test --no-pub test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart
```

Expected: tests still fail only for missing menu/route integration, not for missing `PrayerGuideScreen`.

### Task 4: Menu and Route Integration

**Files:**
- Modify: `lib/features/islamic_content/presentation/screens/islamic_content_screen.dart`
- Modify: `lib/core/navigation/router.dart`
- Test: `test/islamic_content_smoke_test.dart`
- Test: `test/routed_screen_smoke_test.dart`

- [ ] **Step 1: Add menu item**

In `IslamicContentScreen._menuItems`, add this item after `Dzikir` and before `Tips Islami`:

```dart
_ContentMenuItem(
  title: 'Tuntunan Salat',
  subtitle: 'Tata cara dan bacaan salat',
  icon: Icons.menu_book_outlined,
  path: '/islamic-content/prayer-guide',
),
```

- [ ] **Step 2: Add route import and route**

In `lib/core/navigation/router.dart`, add the import:

```dart
import '../../features/prayer_guide/presentation/screens/prayer_guide_screen.dart';
```

Add this route after `/islamic-content/dhikr`:

```dart
GoRoute(
  path: '/islamic-content/prayer-guide',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const PrayerGuideScreen(),
    transitionsBuilder:
        (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
  ),
),
```

- [ ] **Step 3: Add prayer guide to back-button screen list**

In `test/islamic_content_smoke_test.dart`, include `PrayerGuideScreen()` in the `content sub screens show explicit back button` list:

```dart
PrayerGuideScreen(),
```

- [ ] **Step 4: Run focused tests and confirm GREEN**

Run:

```bash
flutter test --no-pub test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart
```

Expected: all focused tests pass.

### Task 5: Verification and Cleanup

**Files:**
- Read: modified files and diff

- [ ] **Step 1: Format Dart files**

Run:

```bash
dart format lib/features/prayer_guide/domain/models/prayer_guide_step.dart lib/features/prayer_guide/presentation/providers/prayer_guide_provider.dart lib/features/prayer_guide/presentation/screens/prayer_guide_screen.dart lib/features/islamic_content/presentation/screens/islamic_content_screen.dart lib/core/navigation/router.dart test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart
```

Expected: formatter completes without parse errors.

- [ ] **Step 2: Run focused tests**

Run:

```bash
flutter test --no-pub test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart
```

Expected: pass.

- [ ] **Step 3: Run full tests**

Run:

```bash
flutter test --no-pub
```

Expected: pass.

- [ ] **Step 4: Run analyzer**

Run:

```bash
flutter analyze --no-pub
```

Expected: no issues.

- [ ] **Step 5: Check transient files**

Run:

```bash
git status --short
```

Expected: only intentional source, test, docs, and routing files are modified or untracked. If `ios/Podfile.lock` changed from local tooling, revert it with `git checkout -- ios/Podfile.lock` before committing implementation.

- [ ] **Step 6: Commit implementation**

Run:

```bash
git add lib/features/prayer_guide lib/features/islamic_content/presentation/screens/islamic_content_screen.dart lib/core/navigation/router.dart test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart docs/superpowers/plans/2026-06-17-prayer-guide.md
git commit -m "feat: add prayer guide content"
```
