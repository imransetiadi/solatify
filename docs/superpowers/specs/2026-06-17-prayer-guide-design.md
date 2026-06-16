# Tuntunan Salat Lengkap Design

## Goal

Add a new `Tuntunan Salat` menu inside `Konten Islami` that provides an offline, mobile-friendly prayer guide with complete readings for the common Indonesian/Syafi’i flow.

## Scope

The first version focuses on a structured written guide, not audio or video. It covers the practical salat sequence and supporting notes:

- Entry card in the existing `Konten Islami` grid.
- Dedicated screen at `/islamic-content/prayer-guide`.
- Offline local content with Arabic text, latin transliteration, Indonesian meaning, and short notes.
- Sections for summary guidance, ordered salat steps, and concise post-prayer dzikir.
- Responsive layout for compact Android/iOS widths and readable light/dark mode.

## Content Standard

Use the common Indonesian/Syafi’i-friendly presentation for v1. The guide includes:

- Niat salat, presented as practical guidance rather than exhaustive every-prayer variants.
- Takbiratul ihram.
- Doa iftitah.
- Al-Fatihah guidance.
- Surat pendek guidance.
- Ruku, i’tidal, sujud, and duduk antara dua sujud readings.
- Tahiyat awal and tahiyat akhir.
- Salam.
- Short dzikir after salat.

The content should avoid claiming exclusivity where valid variations exist. Notes can say that some readings have accepted variations.

## UX Design

Use the approved hybrid structure:

1. **Menu card** in `Konten Islami` with title `Tuntunan Salat`, subtitle `Tata cara dan bacaan salat`, and an appropriate salat/mosque icon.
2. **Hero section** on the guide screen with a short explanation that the guide is ordered from niat to salam.
3. **Summary section** with compact cards for `Syarat`, `Rukun`, and `Yang Membatalkan`.
4. **Step list** where each card contains the step number, title, description, Arabic reading, latin transliteration, Indonesian meaning, and optional note.
5. **Post-prayer section** with concise dzikir after salat.

The screen must include an explicit back button to `/islamic-content`, match existing Islamic background styling, use `ResponsiveCenter`, and avoid overflow on compact widths.

## Architecture

Create a focused feature folder under `lib/features/prayer_guide` following the existing feature-first structure:

- `domain/models/prayer_guide_step.dart` for immutable data models.
- `presentation/providers/prayer_guide_provider.dart` for local static guide data exposed via Riverpod providers.
- `presentation/screens/prayer_guide_screen.dart` for the UI.

This keeps the content testable and avoids adding unnecessary repository/data layers for static v1 content. If remote or editable content is added later, the static provider can be replaced by a repository without changing the screen contract.

## Data Flow

`IslamicContentScreen` routes users to `/islamic-content/prayer-guide`. `PrayerGuideScreen` reads local providers for summary items, salat steps, and post-prayer dzikir. The screen renders those lists as static cards; no network, storage, or permissions are required.

## Error Handling

Because v1 content is bundled locally, runtime error handling is minimal. The provider should return non-empty lists. Tests should catch accidental empty content or missing route/menu integration.

## Testing

Add or extend widget tests to verify:

- `Konten Islami` renders the `Tuntunan Salat` menu card.
- `PrayerGuideScreen` renders the title, at least one salat step, Arabic text block, latin text, and meaning.
- The screen renders without overflow on compact Android width.
- Routed smoke tests include the new screen.

Run:

- `flutter test --no-pub test/islamic_content_smoke_test.dart test/routed_screen_smoke_test.dart`
- `flutter test --no-pub`
- `flutter analyze --no-pub`

## Out of Scope

- Audio playback for each reading.
- Video/tutorial animations.
- Per-prayer niat variant picker.
- Multiple mazhab comparison UI.
- Remote CMS or downloadable content.
