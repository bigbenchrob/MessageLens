---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2025-12-27
source_of_truth: doc
links:
      - ./01-overview.md
      - ./20-migration-orchestrator.md
      - ../10-DATABASES/10-group-import-working.md
tests: []
---

# Incremental Mode Flag

This document explains the `incrementalMode` flag introduced to the migration system to solve performance bottlenecks when re-running migrations on databases with existing data.

## Problem Statement

### Original Behavior (Full Migration Mode)
The migration system was originally designed for **full re-projection**:

1. **DELETE all rows** from working.db tables (in reverse dependency order)
2. **INSERT OR REPLACE** all rows from import.db (in dependency order)
3. Validate that row counts match exactly

This works perfectly for:
- Initial imports (empty working.db)
- Complete data refreshes
- Development/testing scenarios

### Performance Issue with Existing Data
When re-running migration on a working.db with **100K+ existing rows**, the DELETE phase becomes catastrophically slow:

```sql
-- This hangs for minutes with 102,595 messages:
DELETE FROM messages;

-- Why? Foreign key cascades check:
-- - 102,595 messages reference 215 chats
-- - Each message has potential FK to handles, attachments, reactions
-- - SQLite must verify/cascade all constraints
-- - With indexes, this becomes O(N²) complexity
```

**Real-world impact:**
- Migration hung indefinitely at "Clearing working projections" stage
- User unable to see new messages even after import succeeded
- App appeared frozen with no progress updates

### Secondary Issue: INSERT OR REPLACE Overhead
Even after fixing the DELETE bottleneck, `INSERT OR REPLACE` on existing rows was slow:

```sql
-- Replacing 215 existing chats:
INSERT OR REPLACE INTO chats (...) SELECT ...;

-- What SQLite does:
-- 1. Check if row exists (PK lookup)
-- 2. DELETE existing row (triggers FK cascade checks on 102,595 messages!)
-- 3. INSERT new row (triggers FK validation again)
-- 4. Update all indexes
```

This caused the Chats migrator to stall even after DELETE was skipped.

## Solution: Incremental Mode

### Design Goals
1. **Skip DELETE operations** when working.db already has data
2. **Use INSERT OR IGNORE** to skip existing rows and only add new ones
3. **Preserve existing data** instead of clearing and rebuilding
4. **Adjust validation logic** to accept `working_count >= import_count` instead of exact match

### Implementation Architecture

#### 1. Flag Propagation Chain

```
User clicks "Start Migration"
    ↓
DbImportControlViewModel.startMigration()
    ↓ checks working.db message count
    ↓
HandlesMigrationService.run(incrementalMode: true/false)
    ↓
MigrationContext(incrementalMode: ...)
    ↓
passed to all migrators via context
```

#### 2. Files Modified

**Core Infrastructure:**
- `lib/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart`
  - Added `incrementalMode` boolean field (defaults `false`)
  - Available to all migrators via `ctx.incrementalMode`

- `lib/essentials/db_migrate/application/orchestrator/migration_orchestrator.dart`
  - `_prepareWorking()`: Skip DELETE operations when `ctx.incrementalMode == true`
  - Logs: "Incremental mode: skipping table truncation."

- `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart`
  - Added `incrementalMode` parameter to `run()` method
  - Passes flag to `MigrationContext` constructor
  - Updates progress message: "Preparing incremental migration" vs "Clearing identity/message projections"

**UI Layer:**
- `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart`
  - `startMigration()`: Checks `_hasExistingMessages()` before closing DB connections
  - Stores result in `useIncrementalMode` variable
  - Passes `incrementalMode: useIncrementalMode` to migration service
  - Helper method `_hasExistingMessages()`: Queries `SELECT COUNT(*) FROM messages`

**Automatic Detection:**
- `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart`
  - `_runMigration()`: Queries message count before auto-triggered migration
  - Uses `incrementalMode: true` when `count > 0`
  - Logs: "Running INCREMENTAL migration (existing messages: X)"

#### 3. Migrator Changes

All table migrators modified to respect incremental mode:

**Pattern Applied to All Migrators:**

```dart
// In copy() method:
final insertClause = ctx.incrementalMode
    ? 'INSERT OR IGNORE'  // Skip existing rows
    : 'INSERT OR REPLACE'; // Update existing rows

await ctx.workingDb.customStatement('''
  $insertClause INTO table_name (...)
  SELECT ...
''');

// In postValidate() method:
if (ctx.incrementalMode) {
  // Working DB can have MORE rows than import (existing + new)
  await expectTrueOrThrow(
    ok: projected >= expected,
    errorCode: 'TABLE_INCREMENTAL_UNDERCOUNT',
    message: 'working has $projected but expected >= $expected',
  );
} else {
  // Full mode requires exact match
  await expectTrueOrThrow(
    ok: projected == expected,
    errorCode: 'TABLE_ROW_MISMATCH',
    message: 'working has $projected but expected $expected',
  );
}
```

**Modified Migrators:**

1. **chats_migrator.dart**
   - `copy()`: Uses `INSERT OR IGNORE` in incremental mode
   - `postValidate()`: Accepts `dst >= src` in incremental mode
   - Reason: 102,595 messages reference these chats via FK

2. **messages_migrator.dart**
   - `copy()`: Uses `INSERT OR IGNORE` in incremental mode
   - `postValidate()`: Accepts `projected >= expected` in incremental mode
   - Reason: Largest table (100K+ rows), FK to chats and handles

3. **participants_migrator.dart**
   - `copy()`: Uses `INSERT OR IGNORE` in incremental mode
   - `postValidate()`: Accepts `projected >= expected` in incremental mode
   - Reason: Avoid re-inserting contact records unnecessarily

4. **reactions_migrator.dart**
   - `copy()`: Uses `INSERT OR IGNORE` in incremental mode
   - `postValidate()`: Accepts `projected >= expected` in incremental mode
   - Reason: FK dependencies on messages and handles

5. **reaction_counts_migrator.dart**
   - `copy()`: Skips `DELETE FROM reaction_counts` in incremental mode
   - Still uses `INSERT OR REPLACE` (needed for aggregation recalculation)
   - Reason: Counts must be recomputed based on all reactions

**🔥 CRITICAL FIX - chat_db_change_monitor_provider.dart:**
- **Problem**: `ref.invalidate(driftWorkingDatabaseProvider)` after migration closed the database connection
- **Impact**: UI components with in-flight queries would crash with "connection was closed" errors
- **Solution**: Only invalidate database provider in **full mode**, not incremental mode
- **Reason**: In incremental mode, data was added to the same database instance, UI picks it up naturally
- **Code**:
  ```dart
  // In incremental mode, don't invalidate the database connection
  // Data was added to the same instance, UI will pick it up naturally
  // Invalidating would close the connection and break in-flight queries
  if (!useIncremental) {
    ref.invalidate(driftWorkingDatabaseProvider);
  }
  ```

**Migrators NOT Modified (no INSERT OR REPLACE):**
- `handles_migrator.dart` - Uses canonical ID mapping, not simple INSERT
- `chat_to_handle_migrator.dart` - Junction table, specific logic
- `handle_to_participant_migrator.dart` - Junction table, specific logic
- `attachments_migrator.dart` - Check if uses INSERT OR REPLACE
- `message_read_marks_migrator.dart` - Check if uses INSERT OR REPLACE
- `read_state_migrator.dart` - Check if uses INSERT OR REPLACE

## Operational Behavior

### When Incremental Mode Activates

**Automatic (File Watcher):**
```dart
// ChatDbChangeMonitor detects chat.db changes
final count = await workingDb.customSelect('SELECT COUNT(*) FROM messages').getSingle();
if (count > 0) {
  // Incremental mode enabled automatically
  await handlesMigrationServiceProvider.run(incrementalMode: true);
}
```

**Manual (User Clicks "Start Migration"):**
```dart
// Check working.db state before migration
final useIncrementalMode = await _hasExistingMessages(); // true if count > 0

// Pass to migration service
await handlesMigrationServiceProvider.run(
  incrementalMode: useIncrementalMode,
);
```

### Performance Impact

**Before (Full Mode on Existing Data):**
- DELETE phase: Hangs indefinitely (FK cascade checks)
- INSERT OR REPLACE: Slow (delete + insert per row)
- Total time: Minutes to never complete

**After (Incremental Mode):**
- DELETE phase: Skipped entirely
- INSERT OR IGNORE: Fast (PK lookup, skip if exists)
- Total time: Seconds

**Benchmark Example:**
- Database: 102,595 messages, 215 chats
- Full mode: Hung at "Clearing working projections" for 5+ minutes
- Incremental mode: Completed in <10 seconds

## Validation Strategy

### Full Mode Validation
```dart
// Exact row count match required
expectedCount == projectedCount

// Rationale: Working DB was cleared, so all rows came from import
// Any mismatch indicates a bug in the migrator
```

### Incremental Mode Validation
```dart
// Projected count must be >= expected from import
projectedCount >= expectedCount

// Rationale:
// - projectedCount includes rows from previous imports
// - expectedCount is only what's in current import.db
// - New imports should ADD rows, never lose rows
// - Example: working has 102,595, import has 102,596 → PASS
```

### Edge Cases

**Case 1: Import has fewer rows than working**
```
import.db: 100 messages
working.db: 150 messages (from previous imports)
Result: PASS (150 >= 100)
Reason: Working DB preserves old messages not in current import
```

**Case 2: Data corruption detected**
```
import.db: 200 messages
working.db: 150 messages
Result: FAIL (150 < 200)
Action: Clear working.db and run full migration
```

**Case 3: First migration after fresh import**
```
import.db: 200 messages
working.db: 0 messages (empty)
Mode: Full mode (count == 0)
Result: Working ends with exactly 200 messages
```

## Troubleshooting

### Symptoms: Migration Still Slow in Incremental Mode

**Check:**
1. Is `incrementalMode` actually true?
   - Look for log: "Incremental mode: skipping table truncation."
   - If not present, flag isn't being passed correctly

2. Are migrators using INSERT OR IGNORE?
   - Check specific migrator's `copy()` method
   - Should see: `final insertClause = ctx.incrementalMode ? 'INSERT OR IGNORE' : 'INSERT OR REPLACE'`

3. Are there leftover ATTACH DATABASE locks?
   - Check: `PRAGMA database_list` for lingering attachments
   - Solution: Restart app to clear all connections

### Symptoms: Validation Failing with "INCREMENTAL_UNDERCOUNT"

**Meaning:** Working DB has fewer rows than import DB, which shouldn't happen.

**Causes:**
1. Corruption: Some rows were deleted from working.db
2. Import regression: Import has more rows than last time but some are missing from working
3. Migrator bug: INSERT OR IGNORE is skipping rows it shouldn't

**Resolution:**
```dart
// Force full migration to rebuild
await handlesMigrationServiceProvider.run(incrementalMode: false);

// Or clear working.db:
await workingDb.customStatement('DELETE FROM messages');
await handlesMigrationServiceProvider.run(incrementalMode: false);
```

### Symptoms: New Messages Not Appearing

**Check:**
1. Did import run before migration?
   - Look at `macos_import.db` max `source_rowid`
   - Compare to macOS `chat.db` max `ROWID`

2. Is `startMigration()` checking for unimported data?
   - Should see: "Found X unimported messages. Running import first..."
   - If not, import status check is failing

3. Are there FK constraint violations preventing INSERT?
   - Check migrator logs for "missing handles" or "missing chats"

### Symptoms: "connection was closed!" Error Loop

**Error Pattern:**
```
flutter: Error fetching month for contact 56 ordinal 8599: Bad state: 
Tried to send Request (id = 4931): StatementMethod.select: SELECT * FROM 
"contact_message_index" WHERE "contact_id" = ? AND "ordinal" = ?; 
with [56, 8599] over isolate channel, but the connection was closed!
```

**Root Cause:** Database connection invalidated while UI still has active queries

**Locations to Check:**
1. `chat_db_change_monitor_provider.dart` - Should NOT invalidate in incremental mode
2. `db_import_control_provider.dart` - Should only invalidate specific providers, not database
3. Any migration completion handler that calls `ref.invalidate(driftWorkingDatabaseProvider)`

**Solution:**
```dart
// WRONG - closes connection during active queries:
ref.invalidate(driftWorkingDatabaseProvider);

// RIGHT - only invalidate in full mode:
if (!incrementalMode) {
  ref.invalidate(driftWorkingDatabaseProvider);
}

// BETTER - invalidate data providers, not database:
ref.invalidate(recentChatsProvider);
ref.invalidate(globalMessagesProvider);
```

**Why This Happens:**
- Incremental migration runs while UI is active
- Migration completes, triggers `ref.invalidate(driftWorkingDatabaseProvider)`
- Database connection closes immediately
- UI components still trying to query message indexes
- Drift isolate channel is closed, queries fail repeatedly

**Fix Applied:**
- `chat_db_change_monitor_provider.dart` now checks `useIncremental` before invalidating
- In incremental mode, data was added to same DB instance, UI picks it up naturally
- Only full mode needs to invalidate because it's rebuilding from scratch

## Future Enhancements

### Potential Optimizations

1. **Smart Incremental INSERT**
   ```sql
   -- Only select rows newer than max existing ID
   INSERT OR IGNORE INTO messages (...)
   SELECT ...
   FROM import_messages.messages m
   WHERE m.id > (SELECT COALESCE(MAX(id), 0) FROM messages);
   ```

2. **Differential Validation**
   ```dart
   // Instead of counting all rows, check only the delta
   final newRowsInImport = await countNewRows(ctx);
   final newRowsInWorking = await countRecentlyInserted(ctx);
   expectTrueOrThrow(ok: newRowsInWorking >= newRowsInImport);
   ```

3. **Partial Table Refresh**
   ```dart
   // Allow clearing specific date ranges instead of all-or-nothing
   if (ctx.incrementalMode && ctx.refreshDateRange != null) {
     await ctx.workingDb.customStatement('''
       DELETE FROM messages
       WHERE sent_at_utc BETWEEN ? AND ?
     ''', [ctx.refreshDateRange.start, ctx.refreshDateRange.end]);
   }
   ```

### Documentation Updates Needed

When modifying migration behavior:

1. **Update this document** with new migrators or flag behavior
2. **Update `01-overview.md`** if orchestrator sequence changes
3. **Update `20-migration-orchestrator.md`** with new validation rules
4. **Add runbook entry** in `01-overview.md` for common operations

## Related Reading

- `./01-overview.md` - High-level import/migration pipeline
- `./20-migration-orchestrator.md` - Migrator dependency ordering
- `../10-DATABASES/10-group-import-working.md` - Schema contracts between import and working DBs
- `../00-PROJECT/architecture-overview.md` - Overall system architecture
