---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./03-db-address-book.md
  - ../00-PROJECT/01-aggregate-boundaries.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests:
  - test/features/_import_and_dbs/test_import_application_service.dart
---

# AddressBook Path Resolution Architecture

## 🚨 CRITICAL ARCHITECTURAL DECISION 🚨

**All import services and tests MUST use `getFolderAggregateEitherProvider` to resolve AddressBook database paths.**

Hardcoding `/Library/Application Support/AddressBook/AddressBook-v22.abcddb` will silently load archived databases with a handful of contacts. Only the provider chain guarantees that we target the active bundle inside `Sources/<UUID>/`.

## Why the Provider Chain Exists

Apple ships multiple AddressBook directories:

```
/Users/<user>/Library/Application Support/AddressBook/
├── AddressBook-v22.abcddb                    ❌ stale backup (2 contacts)
└── Sources/
    └── 9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/
        └── AddressBook-v22.abcddb            ✅ active database (109 contacts)
```

Only the active bundle should feed `db-import`. The provider chain discovers this bundle dynamically and exposes it through a strongly typed aggregate.

## Provider Chain Overview

1. **`getFolderAggregateEitherProvider`** (feature-level Riverpod provider)
2. **`AddressBookFolderRepository`** (validates sqlite files and produces domain entities)
3. **`AddressBookFolderPathsFinder`** (scans `/Sources/<UUID>/` subdirectories)
4. **`PathsHelper`** (wraps `path_provider` lookups for app directories)

```
PathsHelper ──→ AddressBookFolderPathsFinder ──→ AddressBookFolderRepository ──→ getFolderAggregateEitherProvider
     ↓                        ↓                              ↓                              ↓
system dirs            Sources subfolders           Validated databases         Either<Failure, Aggregate>
```

The aggregate (`AddressBookFolderAggregate`) exposes convenience helpers like `mostRecentFolderPath` and guardrails (record counts, modification timestamps) so importers never attach stale bundles.

## Domain Entities

```dart
class AddressBookFolderEntity {
  final FolderPathValueObject path;              // Full sqlite path
  final AddressBookFolderShortPath shortPath;    // Sources/<UUID>
  final FolderCreationDate createdAt;
  final FolderModificationDate modifiedAt;
  final NonZeroInt recordCount;                  // Contact count validation
}

class AddressBookFolderAggregate {
  const AddressBookFolderAggregate(List<AddressBookFolderEntity> folders);

  FolderPathValueObject get mostRecentFolderPath; // Sorted by modifiedAt
  List<AddressBookFolderEntity> get allFolders;
}
```

Construct these entities—never raw strings—so validation stays centralized.

## Usage Pattern

```dart
final aggregateEither = await ref.read(
  getFolderAggregateEitherProvider.future,
);

final aggregate = aggregateEither.getOrElse(
  (failure) => throw Exception('AddressBook folder resolution failed: ${failure.message}'),
);

final activeDbPath = aggregate.mostRecentFolderPath.value;
```

- Validate `recordCount` before using the path.
- Pass the validated path into import services that populate `db-import` (`03-db-address-book.md`).

## Test Environment Guidance

`path_provider` does not function in Flutter test contexts, so `getFolderAggregateEitherProvider` fails by default. Tests **must** override the provider and supply deterministic aggregates.

```dart
final container = ProviderContainer(
  overrides: [
    getFolderAggregateEitherProvider.overrideWith(
      (ref) async => right(
        AddressBookFolderAggregate([
          AddressBookFolderEntity(
            path: FolderPathValueObject(testPath),
            shortPath: AddressBookFolderShortPath('TEST-SOURCES-UUID'),
            createdAt: FolderCreationDate(DateTime(2025, 01, 01)),
            modifiedAt: FolderModificationDate(DateTime.now()),
            recordCount: NonZeroInt(109),
          ),
        ]),
      ),
    ),
  ],
);
```

Avoid replicating the provider chain in tests. Override once, supply fixture data, and focus on import logic.

## Validation Rules

1. **Contact Count Threshold**: Abort if the candidate database contains <10 contacts—assume it is stale.
2. **Most Recent Wins**: Always choose the bundle with the latest modification date.
3. **Full Disk Access Required**: Import services should surface actionable errors if permissions are missing.
4. **No Direct Paths**: Any code that instantiates `AddressBookFolderAggregate` from raw strings is a code review blocker.

## Debugging Checklist

1. Confirm `getFolderAggregateEitherProvider` resolves successfully.
2. Inspect `aggregate.allFolders` to verify record counts and modification dates.
3. If contact counts look wrong, check macOS Privacy & Security settings for Full Disk Access.
4. Ensure the import service uses the aggregate path and not a cached string.

## Related Documentation

- `03-db-address-book.md` — Source database overview.
- `01-db-import.md` — Ledger staging after AddressBook data is copied.
- `10-group-import-working.md` — Guarantees that `Z_PK` identifiers propagate into `db-working`.
