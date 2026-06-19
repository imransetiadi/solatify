# Qibla Heading Adapter Design

## Goal

Decouple the Qibla screen from `flutter_compass_v2` by introducing an internal heading adapter/provider. This is the first safe step before any future plugin replacement.

## Current Problem

`lib/features/qibla/presentation/screens/qibla_screen.dart` imports `flutter_compass_v2` directly and reads `FlutterCompass.events` inside the widget. This makes the Qibla UI tightly coupled to one plugin and makes future replacement harder.

## Chosen Approach

Use a small adapter layer while keeping `flutter_compass_v2` underneath for now.

### New Abstraction

Add a Qibla heading source in the Qibla feature:

- `lib/features/qibla/domain/entities/qibla_heading.dart`
- `lib/features/qibla/domain/repositories/qibla_heading_repository.dart`
- `lib/features/qibla/data/repositories/flutter_compass_qibla_heading_repository.dart`
- `lib/features/qibla/presentation/providers/qibla_heading_provider.dart`

The UI should depend on the provider/repository abstraction, not on `FlutterCompass.events` directly.

### UI Behavior

`QiblaScreen` keeps existing behavior:

- Use sensor heading when available.
- Fall back to `_simulatedHeading` when sensor heading is unavailable.
- Keep haptic feedback when aligned.
- Keep current visuals and copy unchanged.

### Testing

Add source-level regression coverage to ensure:

- `QiblaScreen` no longer imports `flutter_compass_v2`.
- Qibla data layer owns the `flutter_compass_v2` import.
- Qibla screen uses `qiblaHeadingProvider`.

This keeps the spike low-risk and avoids requiring sensor mocking in widget tests.

## Non-Goals

- Do not remove `flutter_compass_v2` yet.
- Do not add `sensors_plus` yet.
- Do not change Qibla UI/UX.
- Do not change qibla direction math from `adhan`.
- Do not attempt to fix KGP/SPM warning in this step.

## Verification

Run:

```bash
flutter analyze --no-pub
flutter test --no-pub test/routed_screen_smoke_test.dart --plain-name "Qibla heading source is isolated behind adapter"
flutter test --no-pub
flutter build apk --debug --no-pub
```

If available, run Android real-device smoke test for Qibla after implementation.

## Risks

- Provider/refactor could accidentally change fallback behavior.
- Stream value type may need simple null handling to preserve existing no-sensor fallback.

## Exit Criteria

- Qibla UI compiles and renders.
- Existing Qibla smoke test still passes.
- New adapter regression test passes.
- Full tests pass.
- Debug APK build passes.
