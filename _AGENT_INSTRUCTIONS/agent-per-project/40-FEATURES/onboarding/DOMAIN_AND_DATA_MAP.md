# Onboarding — Domain & Data Map

## Domain Concepts

### OnboardingStatus (enum)
The single state token that drives the entire overlay lifecycle:

| Value | Meaning |
|-------|---------|
| `notNeeded` | Both DBs exist and contain data — skip overlay entirely |
| `awaitingUserAction` | First-run detected — show welcome panel with "Import" button |
| `importing` | Import orchestrator running — show import stage progress |
| `migrating` | Migration orchestrator running — show migration stage progress |
| `complete` | Both pipelines succeeded — show summary with "Get Started" button |

### Database Existence Check
Pure infrastructure concern — given a directory path, determine whether `macos_import.db` and `working.db` both exist and are non-empty (have rows in their key tables).

**Key tables to check:**
- `macos_import.db` → `import_batches` (if any batch exists, import has been done)
- `working.db` → `messages` (if any messages exist, migration has been done)

## Data Sources

| Source | How Accessed | Purpose |
|--------|-------------|---------|
| File system | `dart:io` `File.existsSync()` | Check if DB files exist at `_databaseDirectoryPath` |
| `macos_import.db` | `sqfliteImportDatabaseProvider` | Check if import has ever completed (row count) |
| `working.db` | `driftWorkingDatabaseProvider` | Check if migration has ever completed (row count) |
| `user_overlays.db` | **NEVER ACCESSED** | Explicitly excluded from onboarding |

## Data Flow

```
App launch
  → OnboardingGateProvider.build()
    → DatabaseExistenceChecker.check(databaseDirectoryPath)
      → File('macos_import.db').existsSync()  →  false?  →  OnboardingStatus.awaitingUserAction
      → File('working.db').existsSync()       →  false?  →  OnboardingStatus.awaitingUserAction
      → (if both exist) query row counts       →  zero?   →  OnboardingStatus.awaitingUserAction
    → OnboardingStatus.notNeeded (both exist with data)

User taps "Import My Messages"
  → OnboardingGateProvider.startImportAndMigration()
    → state = OnboardingStatus.importing
    → calls DbImportControlProvider.runImportAndMigration()
    → listens to stage progress via DbImportControlProvider state
    → on import complete → state = OnboardingStatus.migrating
    → on migration complete → state = OnboardingStatus.complete

User taps "Get Started"
  → state = OnboardingStatus.notNeeded
  → overlay removed, app is fully usable
```

## Entities & Value Objects

No new domain entities. Onboarding consumes existing:
- `UiStageProgress` (from `db_importers` presentation)
- `DbImportResult` (from `db_importers` domain)
- `DbMigrationResult` (from `db_migrate` domain)

The only new domain type is the `OnboardingStatus` enum above.

## Tables / Storage

_To be defined during planning._

## External Systems

- macOS Full Disk Access permissions
- Import orchestrator (`essentials/db_importers/`)
- Migration orchestrator (`essentials/db_migrate/`)
