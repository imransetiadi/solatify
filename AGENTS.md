# Solatify Development Guidelines

This repository follows a strict Clean Architecture pattern. Every coding task must respect the following rules:

## 1. Directory Structure
- **Core**: Contains shared services, utilities, themes, and global widgets (`lib/core`).
- **Features**: Modulized features, each with:
  - `data`: Repository implementations, data sources (Hive/API).
  - `domain`: Entities/Models, Domain Repository interfaces.
  - `presentation`: UI, Riverpod Providers, Screens.

## 2. Coding Standards
- **Naming**: Use `camelCase` for variables/methods, `PascalCase` for classes.
- **Imports**: Always use `package:solatify/...` for internal imports.
- **Null Safety**: Strict null safety required. Use `late` only when initialization is guaranteed.
- **Error Handling**: Never use `print`. Use `debugPrint`. Wrap async calls in `try-catch` with a clear recovery strategy.

## 3. UI/UX
- **Responsiveness**: Use `ResponsiveLayout` and `ResponsiveCenter` for all screens.
- **Consistency**: Use `GlassContainer` for card components to maintain the aesthetic.
- **Theming**: Use the `AppTheme` tokens. Do not hardcode colors in widgets.

## 4. Maintenance
- **Disposal**: Always override `dispose()` and cancel all `Timer`, `AnimationController`, and `StreamSubscription` instances.
