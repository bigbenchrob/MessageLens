# Onboarding — State & Provider Inventory

## New Providers

### `onboardingGateProvider` (essentials/onboarding/application/)
- **Type:** `@riverpod class OnboardingGate extends _$OnboardingGate`
- **State:** `OnboardingStatus` enum
- **Build:** Checks file existence + row counts → returns `awaitingUserAction` or `notNeeded`
- **Methods:**
  - `startImportAndMigration()` → sets state to `importing`, delegates to `DbImportControlProvider`, watches for completion, transitions through `migrating` → `complete`
  - `dismiss()` → sets state to `notNeeded`
- **keepAlive:** Yes — must survive widget rebuilds during import/migration

## Existing Providers Consumed (not modified)

| Provider | From | Used For |
|----------|------|----------|
| `dbImportControlProvider` | `db_importers/presentation/` | Call `runImportAndMigration()`, watch stages/progress/results |
| `sqfliteImportDatabaseProvider` | `db/feature_level_providers.dart` | Only to check row count during gate check |
| `driftWorkingDatabaseProvider` | `db/feature_level_providers.dart` | Only to check row count during gate check |

## New Domain Types

### `OnboardingStatus` (essentials/onboarding/domain/)
```dart
enum OnboardingStatus {
  notNeeded,           // App is ready — no overlay
  awaitingUserAction,  // First run — show welcome + button
  importing,           // Import orchestrator running
  migrating,           // Migration orchestrator running
  complete,            // Success — show summary + "Get Started"
}
```

## Files to Create

| File | Layer | Purpose |
|------|-------|---------|
| `onboarding_status.dart` | domain | `OnboardingStatus` enum |
| `database_existence_checker.dart` | infrastructure | Pure check: do DBs exist with data? |
| `onboarding_gate_provider.dart` | application | Riverpod notifier driving overlay lifecycle |
| `onboarding_overlay.dart` | presentation | Top-level overlay widget with `ModalBarrier` |
| `onboarding_progress_view.dart` | presentation | Stage progress display (mirrors dev pane rendering) |

## State Objects

_To be defined during implementation._

## Invalidation Rules

_To be defined during implementation._
