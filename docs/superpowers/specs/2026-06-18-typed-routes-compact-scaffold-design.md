# Typed Routes And Compact Scaffold Design

## Goal
Reduce scattered route strings and standardize repeated compact screen structure in Solatify.

## Scope
Phase 9 introduces typed route constants/helpers and a small reusable scaffold. Migration focuses on high-traffic routes and a few content sub-screens to reduce risk.

## User Experience
- No visible behavior changes are expected.
- Content sub-screens keep the same app bar/background/responsive layout, with more consistent spacing and back behavior.

## Architecture
- Add `AppRoutes` with static route constants and dynamic helpers such as `quranSurah`.
- Keep GoRouter configuration in `router.dart`, but use `AppRoutes` constants.
- Add `SolatifyScreenScaffold` as a presentation widget that composes `Scaffold`, optional `AppBar`, `IslamicBackground`, and `ResponsiveCenter`.
- Apply the scaffold to a small set of content sub-screens first.

## Validation
- Add route helper tests/source assertions.
- Run `flutter analyze` and `flutter test` before commit/push.

## Deferred
- Full app-wide scaffold migration.
- Generated typed routes.
- Deep-link route object model.
