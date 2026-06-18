# Unified State Views Design

## Goal
Standardize loading, empty, error, and permission-denied states across key Solatify screens with one reusable visual pattern.

## Scope
Phase 5 introduces a shared `SolatifyStateView` component and applies it to high-visibility screens first: Islamic Content, Asmaul Husna, Islamic Tips, Hijri Calendar, Tracker, and Surah Detail.

## User Experience
- Loading states show a Glass card, icon/progress, title, and supporting description.
- Empty states show a calm icon, title, and helpful next step.
- Error states show a warning icon, clear title, description, and optional retry button.
- Permission-style states can reuse the same component with an action button.
- Visual treatment respects theme tokens, compact widths, and existing Islamic background/cards.

## Architecture
- Add `SolatifyStateView` under `lib/core/widgets` to keep feature screens lean.
- The widget is presentation-only and does not own async logic.
- Apply incrementally to the selected screens without refactoring providers or routes.

## Validation
- Add widget/source smoke tests for the shared component and screen adoption.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Full app-wide replacement in every remaining edge state.
- Skeleton loading shimmer.
- Centralized localization keys for every state copy.
