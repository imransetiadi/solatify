# Quran Reading Mode Design

## Goal
Improve Surah Detail reading comfort with a focused Quran reading mode, Arabic font controls, translation/transliteration toggles, and visible surah progress.

## Scope
Phase 3 focuses only on the Quran Surah Detail reader. It does not replace the Quran repository, audio player, bookmarks, or global navigation shell.

## User Experience
- Surah Detail shows a compact `Aa` control for reading preferences.
- The `Aa` control opens a bottom sheet with Arabic font size, transliteration visibility, translation visibility, and focus mode.
- Preferences persist locally so returning to a surah keeps the reader comfortable.
- Focus mode reduces internal visual clutter in Surah Detail while keeping app navigation stable.
- Progress copy shows the current reading position as `Ayat X / total`.

## Architecture
- Store reader preferences in the Quran presentation layer using a small Riverpod notifier and Hive setting keys.
- Keep UI changes inside `SurahDetailScreen` and small private widgets/helpers.
- Avoid broad router or shell refactors in this phase; full bottom-nav hiding can be revisited with a typed route/scaffold phase.

## Validation
- Add unit/source smoke tests for preference defaults, persistence API, `Aa` controls, toggles, and progress labels.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Full immersive shell-level bottom navigation hiding.
- Per-surah reading progress persistence based on scroll listener.
- Advanced Arabic font family selection.
