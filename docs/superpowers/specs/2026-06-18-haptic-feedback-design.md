# Haptic Feedback Design

## Goal
Make Solatify feel more native by adding subtle haptic feedback to high-intent interactions without making the app noisy.

## Scope
Phase 6 adds a small core haptics helper and applies it to priority interactions: app navigation, Islamic Content taps, tracker toggles, Quran bookmarks/last-read/reader switches, and selected Settings taps.

## User Experience
- Navigation/menu/tab changes use light selection feedback.
- Toggles, bookmarks, and checklist actions use light impact feedback.
- More meaningful save actions use success feedback.
- Feedback stays subtle and does not run on passive loading or scroll.

## Architecture
- Add `SolatifyHaptics` under `lib/core/services` as a tiny wrapper around Flutter `HapticFeedback`.
- Keep calls at interaction boundaries, near existing `onTap`/`onPressed` handlers.
- Avoid dependencies and avoid asynchronous state coupling.

## Validation
- Add source tests for helper existence and priority screen usage.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- User setting to disable haptics.
- Full app-wide coverage for every button.
- Platform-specific haptic intensity tuning.
