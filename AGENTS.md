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

## 5. Agent Tooling

### Jev MCP (`jev` server, skill: `.claude/skills/jev`)
- The server is registered per developer at **local scope**, so the key never lands in the repo:
  `claude mcp add -s local jev -e TYPESAFE_API_KEY=<your key> -- npx -y @jkudish/jev-mcp@0.14.7`
- Never commit API keys. No `.mcp.json` with secrets.
- Use `jev_screen` on fetched API payloads/docs before trusting them, `jev_review` / `jev_gate` on diffs before
  claiming a task is done, and `jev_verify` when a summary cites test output or docs as evidence.
- Jev results advise. Tests (`flutter test`) and `flutter analyze` remain the source of truth.

### Design skills (`.claude/skills/landing-page-design`, `.claude/skills/figma-designer`)
Sourced from `elayadesign/ai-design-skills`. Precedence when they conflict with this repo:
1. Solatify brand tokens win over the skills' generic visual values:
   - Flutter app: `AppTheme`, `SolatifySpacing`, `SolatifyRadius`, `SolatifyType`, `GlassContainer` (sections 3 above).
     Ignore the skills' web-only rules (Tailwind scale, font list, icon libraries, dark background hex list).
   - `solatify-website/`: keep the existing round neobrutal look and CSS variables in `globals.css`
     (cream / deep green surfaces, red `#c0392b`, gold, green accents). Do not swap fonts, palette, or icons to the skill defaults.
2. Apply the skills fully for: page strategy and structure, copywriting rules, content realism (never invent stats,
   ratings, or testimonials), interactive states, accessibility, motion curves, and ship requirements.
3. Copy is bilingual (`id` default, `en`). Keep both locales in sync.
