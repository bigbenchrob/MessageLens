---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./02-db-working.md
  - ./05-db-overlay.md
  - ./10-group-import-working.md
tests: []
---

# Overlay Database Independence Rule

## 🚨 INVIOLABLE ARCHITECTURAL PRINCIPLE 🚨

**`db-overlay` (`user_overlays.db`) and `db-working` (`working.db`) are completely independent.**

1. **No synchronization** — The databases never copy data to each other.
2. **No cross-writing** — Code that writes to overlay never writes to working, and vice versa. **No dual-writes.**
3. **No shared migrations** — Migration tasks for one database must not read or mutate the other. Migration NEVER consults overlay.
4. **Provider-level merging only** — Combine data in Riverpod providers or services, not in SQL.
5. **Overlay wins on conflict** — When a provider merges working + overlay data for the same entity, the overlay value ALWAYS takes precedence.

Breaking these rules jeopardizes user data persistence and invalidates the import/migration contract. **This principle is inviolable and must be heeded by all agents.**

## Separation of Concerns

| Concern | Writes to | Reads from | Survives migration |
|---|---|---|---|
| **Source data** (import/migration) | Working DB only | Source DBs only | Rebuilt from scratch |
| **User intent** (overlay) | Overlay DB only | — | Always persists |
| **Providers** (read path) | — | Working ∪ Overlay, overlay wins | N/A |

Migration is a **pure function** of source data → working DB. It never reads overlay.
User actions are **pure writes** to overlay. They never write to working.
Providers are the **sole merge point** where both databases are read and combined.

## Architectural Model

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  (Riverpod providers – THIS IS WHERE MERGING HAPPENS)        │
│                                                             │
│  Example: chatsForParticipantProvider                       │
│    1. Read automatic links from working.handle_to_participant│
│    2. Read manual links from overlay.handle_to_participant   │
│    3. Merge/override results                                 │
│    4. Return unified view to the UI                          │
└───────────────────────┬────────────────────┬─────────────────┘
                        │                    │
                        │                    │
                   READ ONLY            READ ONLY
                        │                    │
                        ▼                    ▼
          ┌─────────────────────┐  ┌─────────────────────┐
          │   working.db         │  │  user_overlays.db   │
          │  (db-working)        │  │  (db-overlay)       │
          │                     │  │                     │
          │ • Rebuilt per migration │ • Persists forever │
          │ • Automatic matches  │  │ • Manual overrides │
          │ • Messages, chats    │  │ • Preferences      │
          │ • Never touched by   │  │ • Never touched by │
          │   user actions       │  │   migrations       │
          └─────────────────────┘  └─────────────────────┘
                 ▲                           ▲
                 │                           │
            WRITE ONLY                  WRITE ONLY
                 │                           │
          ┌──────┴────────┐         ┌───────┴────────┐
          │  Migration    │         │  User Actions  │
          │  Orchestrator │         │  (via Services)│
          └───────────────┘         └────────────────┘
```

## Correct Usage Patterns

### ✅ Merge in Providers

```dart
@riverpod
Future<List<Chat>> chatsForParticipant(Ref ref, int participantId) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final automatic = await workingDb.chatMembershipsForParticipant(participantId);
  final manual = await overlayDb.manualMembershipsForParticipant(participantId);

  final handleIds = {...automatic, ...manual.map((override) => override.handleId)};
  return fetchChatsForHandles(handleIds);
}
```

### ✅ Persist Manual Overrides Separately

```dart
Future<void> linkHandleToParticipant({
  required Ref ref,
  required int handleId,
  required int participantId,
}) async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  await overlayDb.setHandleOverride(handleId: handleId, participantId: participantId);
  ref.invalidate(chatsForParticipantProvider);
}
```

### ❌ Anti-Pattern 1: Mirror Overlay into Working

```dart
// WRONG: Do not copy overlay rows into working.db
Future<void> syncOverlayToWorking(Ref ref) async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  final workingDb = await ref.read(driftWorkingDatabaseProvider.future);

  final overrides = await overlayDb.getAllHandleOverrides();
  for (final override in overrides) {
    await workingDb.insertHandleOverride(override); // 🚫 BLOCKER
  }
}
```

### ❌ Anti-Pattern 2: Migration Snapshot/Restore Cycle

A migration step must never read overlay data before migration and write it
back into working afterwards. This was the "Restore Overrides" anti-pattern:

```dart
// WRONG: snapshot overlay → run migration → restore into working
final overrides = await overlayDb.getAllHandleOverrides(); // 🚫 reads overlay
await migration.run();                                      // rebuilds working
for (final o in overrides) {
  await workingDb.into(workingDb.handleToParticipant).insert(
    HandleToParticipantCompanion.insert(
      handleId: o.handleId,
      participantId: o.participantId!,
      source: const Value('user_manual'),                   // 🚫 writes to working
    ),
  );
}
```

**Why it's wrong:** The snapshot/restore cycle creates a hidden dependency
between the two databases. If it's skipped (bug, crash, new code path), user
data silently disappears. The correct approach is for providers to merge
overlay and working at read time — migration never needs to know about overlay.

### ❌ Anti-Pattern 3: Dual-Write on User Action

A user action must never write the same intent to both databases:

```dart
// WRONG: writing the same link to overlay AND working
Future<void> linkHandle(int handleId, int participantId) async {
  await overlayDb.setHandleOverride(handleId, participantId);  // overlay ✅
  await (workingDb.delete(workingDb.handleToParticipant)       // working 🚫
        ..where((t) => t.handleId.equals(handleId)))
      .go();
  await workingDb.into(workingDb.handleToParticipant).insert(  // working 🚫
    HandleToParticipantCompanion.insert(
      handleId: handleId,
      participantId: participantId,
      source: const Value('user_manual'),
    ),
  );
}
```

**Why it's wrong:** The working-DB copy is wiped on migration, creating a
race between "last migration" and "last user action". User intent belongs
exclusively in overlay; providers merge it at read time.

### ❌ Anti-Pattern 4: User-Intent Columns on Working Tables

User-controlled flags like `is_blacklisted` or `is_visible` must not live as
columns on working-DB tables that get rebuilt by migration:

```dart
// WRONG: storing user's spam decision on a working-DB table
await (workingDb.update(workingDb.handlesCanonical)
      ..where((t) => t.id.equals(handleId)))
    .write(HandlesCanonicalCompanion(isBlacklisted: const Value(true))); // 🚫
```

**Correct:** Store in overlay (`HandleVisibilityOverrides` table) and merge
in providers via `overlayDb.getAllHandleVisibilities()`.

## Responsibilities by Database

| Concern | `db-working` | `db-overlay` |
| --- | --- | --- |
| Ownership | Import/migration pipeline | User-facing services |
| Lifecycle | Disposable, rebuilt often | Persistent |
| Writes | Migration orchestrator only | User actions/services only |
| Contents | Chats, messages, participants, automatic links | Manual handle links, custom names, visibility preferences, future annotations |
| Foreign Keys | Enforced by Drift schema | Enforced by Drift schema |

## Debugging Checklist

1. Is the override present in `db-overlay`? Run `SELECT * FROM handle_to_participant_overrides`. 
2. Are providers merging overlay + working data? Audit calls to both providers.
3. Were dependent providers invalidated after the override was written?
4. Does any code attempt to mutate `db-working` in response to overlay changes? Remove it.
5. Are migrations touching overlay tables? They must not.

## Resolved Violations (Historical Reference)

The following violations were fixed on the `Ftr.overlay-handle-visibility` branch:

1. **`ManualLinking.linkHandleToParticipant()`** — Was dual-writing to both overlay and working. Now writes overlay only; providers merge at read time.
2. **`ManualLinking.unlinkHandle()`** — Was deleting from working DB. Now deletes from overlay (reverts to addressbook default).
3. **`ManualLinking.createParticipantForHandle()`** — Was writing handle→participant link to working. Now writes link to overlay (participant record stays in working as the only participant table).
4. **`SpamManagement.blockHandle()`/`unblockHandle()`** — Was writing `is_blacklisted`/`is_visible` to working DB's `handles_canonical`. Now writes to overlay's `HandleVisibilityOverrides`; spam providers merge at read time.
5. **"Restore Overrides" migration step** — Snapshot/restore cycle read overlay before migration and wrote manual links back into working. Removed entirely; providers now merge overlay + working at read time.

## Related Documentation

- `02-db-working.md` — Drift projection overview.
- `05-db-overlay.md` — Overlay database schema and access patterns.
- `10-group-import-working.md` — Import ↔ working contract.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table definitions for both databases.
