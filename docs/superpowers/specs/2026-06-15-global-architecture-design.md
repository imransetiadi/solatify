# Global Architecture Design - Solatify

**Goal:** Establish a strict Clean Architecture standard for Solatify using a feature-first structure, Riverpod for state management, and Hive for local storage.

**Architecture:** A three-layered approach (Data, Domain, Presentation) encapsulated within modular features. This ensures high testability, scalability, and clear separation of concerns.

**Tech Stack:** Flutter, Riverpod, Hive

---

## 1. Directory Structure

### Global Core (`lib/core/`)
- `config/`: Application configuration (environments, constants).
- `database/`: Persistence layer setup (Hive adapters, box initialization).
- `error/`: Failure and exception definitions.
- `network/`: Network client configuration (Dio/Http).
- `theme/`: Styling tokens (colors, typography).
- `widgets/`: Globally shared UI components (e.g., `ResponsiveLayout`).

### Features (`lib/features/`)
Each feature module contains:
- **Data Layer:**
  - `datasources/`: Local (Hive) and Remote (API) data providers.
  - `models/`: Data Transfer Objects (DTOs) with serialization.
  - `repositories/`: Implementation of domain repositories.
- **Domain Layer:**
  - `entities/`: Pure business logic models.
  - `repositories/`: Abstract repository definitions.
  - `usecases/`: Single-responsibility logic executors.
- **Presentation Layer:**
  - `providers/`: Riverpod StateNotifiers/ChangeNotifiers.
  - `screens/`: UI pages.
  - `widgets/`: Local UI components.

---

## 2. Riverpod Implementation Standard

- **Dependency Injection:** Use `Provider` to expose repositories and usecases to the rest of the application.
- **State Flow:**
  - `UI` -> `Provider (Notifier)` -> `UseCase` -> `Repository` -> `DataSource`.
  - Data flows back up as `AsyncValue` or custom State classes.
- **UI Interaction:** Widgets must be `ConsumerWidget` or `ConsumerStatefulWidget`. Use `ref.watch` for reactivity and `ref.read` for one-time actions.

---

## 3. Hive Persistence Standard

- **Storage Isolation:** Access Hive boxes only through local data sources.
- **Model Registration:** Register all Hive Adapters in `core/database/hive_service.dart`.
- **Consistency:** Use static constants for box names and keys.
- **Reactive Storage:** When data changes in Hive, repositories should notify the respective presentation providers to update the UI.

---

## 4. Success Criteria

- All new features follow the 3-layer directory structure.
- Business logic is strictly contained within UseCases and Domain entities.
- Hive implementation is interchangeable without modifying presentation logic.
- Riverpod provides a clean, reactive bridge between layers.
