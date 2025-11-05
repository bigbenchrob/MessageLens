---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-01-30
source_of_truth: This file
links:
  - ../00-project/aggregate-boundaries.md
  - ./README.md
tests:
  - test/features/_import_and_dbs/test_import_application_service.dart
---

# CRITICAL: AddressBook Path Resolution Architecture

## ⚠️ IMPORTANT ARCHITECTURAL DECISION ⚠️

**ALL import services and tests MUST use `getFolderAggregateEitherProvider` to resolve AddressBook database paths.**

## The Problem

Apple's AddressBook directory structure contains multiple database files that appear functional but are NOT the active database:

```
/Users/rob/Library/Application Support/AddressBook/
├── AddressBook-v22.abcddb                    ❌ ONLY 2 contacts (outdated/inactive)
└── Sources/
    └── 9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/
        └── AddressBook-v22.abcddb            ✅ 109 contacts (ACTIVE DATABASE)
```

## The Solution

We have a carefully designed provider chain that scans directories and returns the correct active AddressBook:

1. **`getFolderAggregateEitherProvider`** - The authoritative source for AddressBook path resolution
2. **`AddressBookFolderPathsFinder`** - Scans `/Library/Application Support/AddressBook/Sources/` subdirectories
3. **`AddressBookFolderAggregate`** - Contains validated database paths with contact counts and modification dates

### AddressBook Domain Architecture

#### AddressBookFolderEntity
Represents a single AddressBook database folder with metadata:

```dart
class AddressBookFolderEntity {
  final FolderPathValueObject path;              // Full database path
  final AddressBookFolderShortPath shortPath;    // UUID folder name
  final FolderCreationDate lastCreationDate;     // When folder was created
  final FolderModificationDate lastModificationDate; // Last modified date
  final NonZeroInt recordCount;                   // Number of contacts in database
}
```

#### AddressBookFolderAggregate  
**CRITICAL**: Takes a `List<AddressBookFolderEntity>`, NOT strings:

```dart
// ✅ CORRECT - Pass AddressBookFolderEntity objects
final mockFolder = AddressBookFolderEntity(
  path: FolderPathValueObject(hardCodedPath),
  shortPath: AddressBookFolderShortPath('9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40'),
  lastCreationDate: FolderCreationDate(DateTime.now().subtract(Duration(days: 30))),
  lastModificationDate: FolderModificationDate(DateTime.now()),
  recordCount: NonZeroInt(109),
);
final aggregate = AddressBookFolderAggregate([mockFolder]);

// ❌ WRONG - Cannot pass strings directly
final aggregate = AddressBookFolderAggregate(["/some/path"]); // Compile error!
```

The aggregate automatically:
- Sorts folders by modification date (most recent first)
- Provides `mostRecentFolderPath` getter for the active database
- Handles filtering of bad/invalid folders

### Flutter Provider Chain Architecture

**Normal Operation (Non-test environments):**

```
PathsHelper ──→ AddressBookFolderPathsFinder ──→ AddressBookFolderRepository ──→ getFolderAggregateEitherProvider
     ↓                        ↓                              ↓                              ↓
path_provider          Scans Sources/*           Validates databases            Returns Either<Failure, Aggregate>
```

1. **`PathsHelper`** - Uses `path_provider` to get system directories
2. **`AddressBookFolderPathsFinder`** - Scans `Library/Application Support/AddressBook/Sources/` 
3. **`AddressBookFolderRepository`** - Validates each found database (queries ZABCDRECORD table)
4. **`getFolderAggregateEitherProvider`** - Returns `Either<FolderRetrievalFailure, AddressBookFolderAggregate>`

**The provider chain fails in Flutter test environments because:**
- `path_provider` doesn't work in Flutter tests
- `PathsHelper` depends on `path_provider` 
- This breaks the entire chain from the foundation up

## ⚠️ CRITICAL TEST ENVIRONMENT ISSUE ⚠️

**The provider system fails in Flutter test environments due to `PathsHelper` initialization:**

```
🔍 DEBUG: Exception getting AddressBook path: PathsHelper initialization error, 
getPathProviderDirectoryPath(): unspecified error with key 'appDocs'
```

### Root Cause
- `path_provider` package doesn't work properly in Flutter test environments
- `PathsHelper` depends on `path_provider` for app document directories  
- This causes the entire `getFolderAggregateEitherProvider` chain to fail during tests

### Test Environment Workaround

**Multiple issues prevent standard Flutter testing:**

1. **PathsHelper/path_provider fails in Flutter test environments**
2. **Flutter test naming conventions** - Flutter expects test files to be directly in `test/` directory with `_test.dart` suffix

```bash
# Current file structure (doesn't follow Flutter test conventions):
test/features/_import_and_dbs/test_import_application_service.dart
test/features/_import_and_dbs/test_step3_query_demo.dart

# Flutter expects:
test/import_application_service_test.dart
test/step3_query_demo_test.dart

# Error when running with subdirectories:
flutter test test/features/_import_and_dbs/test_import_application_service.dart
# Results in: "Test directory 'test' does not appear to contain any test files. 
#            Test files must be in that directory and end with the pattern '_test.dart'."
```

**Required Test Override Pattern:**

Since the provider chain fails in Flutter tests, use provider overrides with hard-coded paths:

```dart
// ✅ CORRECT - Override provider in tests
final container = ProviderContainer(
  overrides: [
    futureGetFolderAggregateProvider.overrideWith((ref) async {
      // Hard-code the known active AddressBook path for testing
      final hardCodedPath = '/Users/rob/Library/Application Support/AddressBook/Sources/9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/AddressBook-v22.abcddb';
      
      // Create proper AddressBookFolderEntity (NOT string!)
      final mockFolder = AddressBookFolderEntity(
        path: FolderPathValueObject(hardCodedPath),
        shortPath: AddressBookFolderShortPath('9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40'),
        lastCreationDate: FolderCreationDate(DateTime.now().subtract(const Duration(days: 30))),
        lastModificationDate: FolderModificationDate(DateTime.now()),
        recordCount: NonZeroInt(109), // Known contact count
      );
      
      final mockAggregate = AddressBookFolderAggregate([mockFolder]);
      return right(mockAggregate);
    }),
  ],
);
```

**Current workarounds:**
1. **Hard-code AddressBook path in test provider overrides** (recommended)
2. **Manual database verification** during development
3. **Rename/move test files** to follow Flutter conventions  
4. **Run as integration tests** instead of unit tests

```bash
# Manual verification approach:
cd /Users/rob/sqlite_rmc/messages
sqlite3 import.db "SELECT COUNT(*) FROM contacts;"
sqlite3 working.db "SELECT COUNT(*) FROM contacts;"
```

**This recurring pattern must be remembered:** 
- PathsHelper/path_provider consistently fails in Flutter test environments
- Flutter test discovery requires `_test.dart` files directly in `test/` directory
- AddressBookFolderAggregate requires `List<AddressBookFolderEntity>`, not strings

## Correct Usage Pattern

```dart
// ✅ CORRECT - Use the provider system
final futureResult = await _ref.read(
  futureGetFolderAggregateProvider.future,
);

final result = futureResult.fold(
  (failure) => throw Exception('AddressBook folder aggregate failed: ${failure.message}'),
  (aggregate) => aggregate.mostRecentFolderPath,
);
```

```dart
// ❌ WRONG - Direct path fallback
const directPath = '/Users/rob/Library/Application Support/AddressBook/AddressBook-v22.abcddb';
```

## Files That MUST Use This Pattern

- All import services (`ImportService` classes)
- All test files accessing AddressBook data  
- Any code that needs to read contact information

## Database Validation

**All import services now include validation to catch inactive databases:**

```dart
/// Validate that the AddressBook database contains a reasonable number of contacts
Future<int> _validateAddressBookDatabase(Database db, String path) async {
  final result = await db.query('ZABCDRECORD');
  final contactCount = result.length;
  
  if (contactCount < 10) {
    throw Exception(
      'AddressBook database validation failed: Found only $contactCount contacts. '
      'This appears to be an inactive/dummy database. Expected at least 10 contacts. '
      'Path: $path'
    );
  }
  
  return contactCount;
}
```

This validation will immediately fail if the import service mistakenly uses:
- The direct path with only 2 contacts
- Any inactive/dummy databases with 0-2 contacts

## Current Correct Path (as of January 2025)

```
/Users/rob/Library/Application Support/AddressBook/Sources/9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/AddressBook-v22.abcddb
```
- Contains: **109 contacts** (active)
- vs Direct path: **2 contacts** (inactive)

## Why This Happens Repeatedly

The direct fallback path `/AddressBook/AddressBook-v22.abcddb` exists and is readable, so it appears to work, but contains outdated data. Only the provider system finds the active database in the Sources subdirectories.

---

**⚠️ IF YOU ARE READING THIS IN THE FUTURE: Always use `getFolderAggregateEitherProvider` for AddressBook paths!**
