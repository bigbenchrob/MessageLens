# Import Rationalization Plan

**Branch**: `Ftr.import-fix` (created from `main`)  
**Goal**: Reorganize `db_importers` and `db_migrate` folders to proper DDD structure and add real progress reporting

---

## 1. Current State Analysis

### 1.1 db_importers Structure

```
db_importers/
├── application/
│   ├── orchestrator/
│   │   └── import_orchestrator.dart          ✅ Correct location
│   ├── services/
│   │   ├── base_table_importer.dart          ❌ Should be domain
│   │   └── orchestrated_ledger_import_service.dart
│   └── monitor/
├── domain/
│   ├── entities/
│   ├── i_importers.dart/
│   │   └── table_importer.dart               ✅ Interface contract
│   ├── ports/
│   ├── states/
│   │   └── table_import_progress.dart        ✅ Progress events
│   └── value_objects/
├── infrastructure/
│   └── sqlite/
│       ├── import_context_sqlite.dart
│       └── importers/                         ❌ Should be application
│           ├── attachments_importer.dart
│           ├── chats_importer.dart
│           ├── contacts_content_importer.dart
│           ├── contacts_importer.dart
│           ├── handle_to_participant_importer.dart
│           ├── handles_importer.dart
│           ├── import_ledger_row_importers.dart
│           ├── messages_importer.dart
│           ├── message_attachment_importer.dart
│           ├── message_to_handle_importer.dart
│           └── chat_to_handle_importer.dart
└── presentation/
```

### 1.2 db_migrate Structure

```
db_migrate/
├── application/
│   ├── orchestrator/
│   │   ├── migration_orchestrator.dart       ✅ Correct location
│   │   └── handles_migration_service.dart
│   ├── services/
│   │   └── base_table_migrator.dart          ❌ Should be domain
│   └── migration/
├── domain/
│   ├── entities/
│   ├── i_migrators.dart/
│   │   └── table_migrator.dart               ✅ Interface contract
│   ├── states/
│   │   └── table_migration_progress.dart     ✅ Progress events
│   └── value_objects/
├── infrastructure/
│   └── sqlite/
│       ├── migration_context_sqlite.dart
│       └── migrators/                         ❌ Should be application
│           ├── attachments_migrator.dart
│           ├── chats_migrator.dart
│           ├── handles_migrator.dart
│           ├── messages_migrator.dart
│           └── ... (15 total migrators)
└── presentation/
```

---

## 2. Problems Identified

### 2.1 DDD Layer Violations

| File/Folder | Current Location | Should Be | Rationale |
|-------------|------------------|-----------|-----------|
| `base_table_importer.dart` | application/services | domain/ | Abstract base class with business invariants belongs in domain |
| `base_table_migrator.dart` | application/services | domain/ | Same as above |
| `importers/*.dart` | infrastructure/sqlite | application/services | These are use-case orchestrations, not infrastructure adapters |
| `migrators/*.dart` | infrastructure/sqlite | application/services | Same as above |

### 2.2 No Row-Level Progress Reporting

Current progress flow:
```
Orchestrator → (phase status only) → TableImportProgressEvent
```

**Limitation**: The `copy()` method in each importer/migrator does not emit row-by-row progress. The orchestrator only knows when phases start/finish, not progress during execution.

Example from `MessagesImporter.copy()`:
```dart
for (final row in rows) {
  // Process row...
  if (processed % 500 == 0) {
    ctx.info('...processed $processed/${rows.length}...');  // LOG ONLY
  }
}
```

The progress is logged but NOT emitted to the callback system.

### 2.3 Duplicate Code

Both `BaseTableImporter` and `BaseTableMigrator` have nearly identical:
- `count()` method
- `expectZeroOrThrow()` method  
- `expectTrueOrThrow()` method
- `displayName` getter
- `targetTables` getter
- `_humanizeName()` function

---

## 3. Target State

### 3.1 Reorganized db_importers Structure

```
db_importers/
├── application/
│   ├── orchestrator/
│   │   └── import_orchestrator.dart
│   ├── services/
│   │   └── orchestrated_ledger_import_service.dart
│   └── importers/                              ← MOVED FROM infrastructure
│       ├── attachments_importer.dart
│       ├── chats_importer.dart
│       ├── ... (all individual importers)
├── domain/
│   ├── base_table_importer.dart                ← MOVED FROM application/services
│   ├── i_importers.dart/
│   │   └── table_importer.dart
│   ├── states/
│   │   └── table_import_progress.dart
│   └── value_objects/
└── infrastructure/
    └── sqlite/
        └── import_context_sqlite.dart
```

### 3.2 Reorganized db_migrate Structure

```
db_migrate/
├── application/
│   ├── orchestrator/
│   │   ├── migration_orchestrator.dart
│   │   └── handles_migration_service.dart
│   └── migrators/                              ← MOVED FROM infrastructure
│       ├── attachments_migrator.dart
│       ├── chats_migrator.dart
│       ├── ... (all individual migrators)
├── domain/
│   ├── base_table_migrator.dart                ← MOVED FROM application/services
│   ├── i_migrators.dart/
│   │   └── table_migrator.dart
│   └── states/
└── infrastructure/
    └── sqlite/
        └── migration_context_sqlite.dart
```

---

## 4. Row-Level Progress Reporting Design

### 4.1 Progress Reporter Abstraction

Create a shared progress reporter that importers/migrators can use during `copy()`:

```dart
// In shared domain layer
typedef RowProgressCallback = void Function({
  required int processed,
  required int total,
  String? currentItem,
});

/// Mixin providing row-level progress reporting during copy operations.
mixin RowProgressReporter {
  RowProgressCallback? _progressCallback;
  
  void setProgressCallback(RowProgressCallback? callback) {
    _progressCallback = callback;
  }
  
  void reportRowProgress({
    required int processed,
    required int total,
    String? currentItem,
  }) {
    _progressCallback?.call(
      processed: processed,
      total: total,
      currentItem: currentItem,
    );
  }
}
```

### 4.2 Enhanced Progress Event

Extend `TableImportProgressEvent` with row-level data:

```dart
class TableImportProgressEvent {
  const TableImportProgressEvent({
    required this.importerName,
    required this.displayName,
    required this.phase,
    required this.status,
    this.message,
    this.stage,
    this.rowsProcessed,    // NEW
    this.totalRows,        // NEW
    this.currentItem,      // NEW
  });

  final String importerName;
  final String displayName;
  final TableImportPhase phase;
  final TableImportStatus status;
  final String? message;
  final DbImportStage? stage;
  final int? rowsProcessed;    // NEW
  final int? totalRows;        // NEW
  final String? currentItem;   // NEW
}
```

### 4.3 Integration with Orchestrator

The orchestrator passes a progress callback to each importer:

```dart
Future<void> _runPhase({
  // ... existing params
  TableImportProgressCallback? onTableProgress,
}) async {
  // Set up row-level callback if importer supports it
  if (importer is RowProgressReporter && onTableProgress != null) {
    importer.setProgressCallback(({
      required int processed,
      required int total,
      String? currentItem,
    }) {
      onTableProgress(TableImportProgressEvent(
        importerName: importer.name,
        displayName: displayName,
        phase: phase,
        status: TableImportStatus.inProgress,  // NEW STATUS
        rowsProcessed: processed,
        totalRows: total,
        currentItem: currentItem,
      ));
    });
  }
  
  // ... run action
}
```

### 4.4 Importer Implementation

Importers use the mixin and report progress:

```dart
class MessagesImporter extends BaseTableImporter with RowProgressReporter {
  @override
  Future<void> copy(ImportContext ctx) async {
    final rows = await ctx.messagesDb.query('message', ...);
    
    for (var i = 0; i < rows.length; i++) {
      // Process row...
      
      // Report progress every 100 rows or on completion
      if (i % 100 == 0 || i == rows.length - 1) {
        reportRowProgress(
          processed: i + 1,
          total: rows.length,
        );
      }
    }
  }
}
```

---

## 5. Shared Code Extraction

### 5.1 Create Shared Base in Domain

Extract common functionality to a shared location:

```dart
// lib/essentials/db_shared/domain/base_table_processor.dart

import 'package:sqflite/sqflite.dart';

/// Shared base functionality for table importers and migrators.
abstract class BaseTableProcessor {
  const BaseTableProcessor();

  String get name;
  String get displayName => _humanizeName(name);
  List<String> get targetTables => <String>[name];
  List<String> get dependsOn;

  Future<int> count(Object database, String table);
  
  Future<void> expectZeroOrThrow(
    int n,
    String errorCode,
    String message,
  );

  Future<void> expectTrueOrThrow({
    required bool ok,
    required String errorCode,
    required String message,
  });
}
```

### 5.2 Or Use Mixin Approach

```dart
// lib/essentials/db_shared/domain/table_processor_helpers.dart

mixin TableProcessorHelpers {
  Future<int> countRows(Object database, String table) async {
    // Common count implementation
  }
  
  Future<void> expectZeroOrThrow(int n, String errorCode, String message) async {
    if (n != 0) {
      throw ProcessorException(code: errorCode, message: message);
    }
  }
  
  Future<void> expectTrueOrThrow({
    required bool ok,
    required String errorCode,
    required String message,
  }) async {
    if (!ok) {
      throw ProcessorException(code: errorCode, message: message);
    }
  }
}

String humanizeName(String raw) {
  if (raw.isEmpty) return raw;
  return raw
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
```

---

## 6. Implementation Phases

### Phase 1: Folder Reorganization (No Logic Changes)

1. Move `base_table_importer.dart` to `db_importers/domain/`
2. Move `base_table_migrator.dart` to `db_migrate/domain/`
3. Move `importers/` folder to `db_importers/application/importers/`
4. Move `migrators/` folder to `db_migrate/application/migrators/`
5. Update all import paths
6. Run tests to verify no regressions

### Phase 2: Add Row Progress Reporting

1. Create `RowProgressReporter` mixin
2. Add `inProgress` status to progress events
3. Add row count fields to progress events
4. Update orchestrators to pass callbacks
5. Update `MessagesImporter` as proof of concept
6. Update developer control panel to show row progress
7. Run tests

### Phase 3: Apply to All Importers

1. Add `RowProgressReporter` to each importer
2. Add `reportRowProgress()` calls in each `copy()` method
3. Test each importer individually

### Phase 4: Apply to All Migrators

1. Same pattern as Phase 3 for migrators

### Phase 5: Shared Code Extraction (Optional)

1. Create `db_shared/` folder if warranted
2. Extract common mixin
3. Update both base classes to use shared code

### Phase 6: Onboarding Integration

1. Wire updated progress events to onboarding UI
2. Replace indeterminate spinners with real progress bars
3. Test full onboarding flow

---

## 7. Files to Move

### db_importers (11 files to move)

| From | To |
|------|-----|
| `application/services/base_table_importer.dart` | `domain/base_table_importer.dart` |
| `infrastructure/sqlite/importers/attachments_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/chats_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/contacts_content_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/contacts_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/handle_to_participant_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/handles_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/import_ledger_row_importers.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/messages_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/message_attachment_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/message_to_handle_importer.dart` | `application/importers/` |
| `infrastructure/sqlite/importers/chat_to_handle_importer.dart` | `application/importers/` |

### db_migrate (16 files to move)

| From | To |
|------|-----|
| `application/services/base_table_migrator.dart` | `domain/base_table_migrator.dart` |
| `infrastructure/sqlite/migrators/app_settings_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/attachments_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/chat_to_handle_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/chats_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/handle_to_participant_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/handles_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/message_read_marks_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/messages_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/participants_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/projection_state_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/reaction_counts_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/reactions_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/read_state_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/supabase_sync_logs_migrator.dart` | `application/migrators/` |
| `infrastructure/sqlite/migrators/supabase_sync_state_migrator.dart` | `application/migrators/` |

---

## 8. Testing Strategy

### Unit Tests
- Each importer/migrator continues to be tested in isolation
- Add tests for row progress callback invocation

### Integration Tests
- Developer control panel shows progress bars updating
- Onboarding flow shows real progress

### Manual Testing
- Run import with control panel open
- Verify progress bars reflect actual row counts
- Verify no performance regression from callback overhead

---

## 9. Success Criteria

- [ ] All files in DDD-compliant locations
- [ ] All import paths updated and working
- [ ] Row-level progress visible in developer control panel
- [ ] `flutter analyze` passes
- [ ] All existing tests pass
- [ ] Onboarding shows real progress (Phase 6)
