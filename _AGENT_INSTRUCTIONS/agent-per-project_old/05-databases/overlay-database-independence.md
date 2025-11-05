# Overlay Database Independence Rule

## 🚨 CRITICAL ARCHITECTURAL PRINCIPLE 🚨

**The overlay database (`user_overlays.db`) and working database (`working.db`) are COMPLETELY INDEPENDENT.**

### Independence Rules (READ THIS FIRST)

1. **NO SYNCHRONIZATION**: The databases do NOT sync with each other. Ever.
2. **NO CROSS-WRITING**: Code that writes to overlay DB never writes to working DB, and vice versa.
3. **NO AWARENESS**: Neither database knows about or depends on the other's existence.
4. **NO MIGRATION COUPLING**: Working DB migrations do NOT read from or write to overlay DB.
5. **PROVIDER-LEVEL MERGING ONLY**: Data is merged at the **application provider layer**, never at the database layer.

### Why This Architecture Exists

1. **Working DB is Ephemeral**: `working.db` is rebuilt from scratch on every migration. User data must never be stored there.
2. **Overlay DB is Persistent**: `user_overlays.db` survives migrations and contains all user customizations.
3. **Clean Separation**: User preferences live separate from imported data, enabling safe re-imports without losing user work.
4. **Provider Flexibility**: Application providers can merge/override/combine data from both sources as needed.

---

## How Data Flows (The Correct Mental Model)

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  (Riverpod Providers - THIS IS WHERE MERGING HAPPENS)       │
│                                                              │
│  Example: chatsForParticipantProvider                        │
│    1. Read automatic links from working.handle_to_participant│
│    2. Read manual links from overlay.handle_to_participant   │
│    3. Merge/combine/override as needed                       │
│    4. Return unified result to UI                            │
└───────────────────────┬────────────────────┬─────────────────┘
                        │                    │
                        │                    │
                   READ ONLY            READ ONLY
                        │                    │
                        ▼                    ▼
          ┌─────────────────────┐  ┌─────────────────────┐
          │   working.db         │  │  user_overlays.db   │
          │                      │  │                      │
          │ • Rebuilt on every   │  │ • Persists forever  │
          │   migration          │  │ • User preferences  │
          │ • Automatic matches  │  │ • Manual overrides  │
          │ • Messages, chats    │  │ • Short names       │
          │ • Never touched by   │  │ • Never touched by  │
          │   user actions       │  │   migrations        │
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

---

## Examples of CORRECT Usage

### ✅ Reading Manual Links (Provider Layer)

```dart
@riverpod
Future<List<Chat>> chatsForParticipant(Ref ref, int participantId) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  
  // Get automatic links from working DB
  final autoLinks = await workingDb.getHandlesForParticipant(participantId);
  
  // Get manual links from overlay DB
  final manualOverrides = await overlayDb.getOverridesForParticipant(participantId);
  
  // MERGE at provider level
  final allHandleIds = {...autoLinks, ...manualOverrides.map((o) => o.handleId)};
  
  // Use merged handle IDs to fetch chats
  return fetchChatsForHandles(allHandleIds);
}
```

### ✅ Creating Manual Link (Service Layer)

```dart
Future<void> linkHandleToParticipant(int handleId, int participantId) async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  
  // ONLY write to overlay DB
  await overlayDb.setHandleOverride(handleId, participantId);
  
  // Invalidate providers so they re-merge the data
  ref.invalidate(chatsForParticipantProvider);
}
```

### ❌ WRONG: Writing to Both Databases

```dart
// ❌ NEVER DO THIS
Future<void> linkHandleToParticipant(int handleId, int participantId) async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
  
  // ❌ BAD: Writing to overlay DB
  await overlayDb.setHandleOverride(handleId, participantId);
  
  // ❌ BAD: Also writing to working DB - THIS IS WRONG!
  await workingDb.insertHandleToParticipant(handleId, participantId);
}
```

### ❌ WRONG: Synchronizing Databases

```dart
// ❌ NEVER DO THIS
Future<void> syncOverlayToWorking() async {
  final overlayDb = await ref.read(overlayDatabaseProvider.future);
  final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
  
  // ❌ BAD: Trying to sync overlay → working
  final overrides = await overlayDb.getAllHandleOverrides();
  for (final override in overrides) {
    await workingDb.insertHandleToParticipant(...);
  }
}
```

---

## What Lives Where

### Working Database (`working.db`)

**Purpose**: Projection of imported Messages/AddressBook data

**Contents**:
- Messages, chats, handles (from Messages app)
- Participants (from AddressBook)
- Automatic handle→participant links (from matching algorithm)
- Message indexes, aggregations

**Lifecycle**: 
- Rebuilt from scratch on every migration
- Never contains user customizations
- Safe to delete and rebuild

**Write Sources**: 
- ONLY migration orchestrator
- NEVER user actions
- NEVER manual overrides

### Overlay Database (`user_overlays.db`)

**Purpose**: User preferences and manual customizations

**Contents**:
- Manual handle→participant links
- Participant short names
- Chat custom names/colors
- Message annotations (future)
- Reading state (future)

**Lifecycle**:
- Persists forever
- Never rebuilt or cleared
- Survives migrations

**Write Sources**:
- ONLY user actions (via services)
- NEVER migration orchestrator
- NEVER automatic processes

---

## Common Mistakes to Avoid

### ❌ Mistake 1: "The overlay link isn't showing up, let me update working DB"

**Wrong**: Modifying working DB to add the overlay link

**Right**: Check the provider - it should merge data from both DBs

### ❌ Mistake 2: "Migration should restore overlay links to working DB"

**Wrong**: Migration reading overlay DB and writing to working DB

**Right**: Providers read from both DBs and merge at runtime

### ❌ Mistake 3: "The working DB needs to know about manual overrides"

**Wrong**: Adding overlay awareness to working DB

**Right**: Working DB remains ignorant; providers handle the merging

### ❌ Mistake 4: "After creating an overlay link, rebuild the index in working DB"

**Wrong**: Writing to or modifying working DB after overlay changes

**Right**: Invalidate providers; they re-query both DBs and merge fresh data

---

## Debugging Checklist

If manual links aren't showing up in the UI:

1. ✅ Verify overlay DB has the link: `SELECT * FROM handle_to_participant_overrides WHERE handle_id = ?`
2. ✅ Check the provider reads from overlay DB (not just working DB)
3. ✅ Verify the provider merges data from both sources
4. ✅ Confirm provider invalidation happens after overlay changes
5. ❌ Do NOT check if working DB has the link (it shouldn't)
6. ❌ Do NOT try to sync the databases
7. ❌ Do NOT rebuild working DB indexes

---

## Related Documentation

- [Database Access Guide](README.md) - Connection patterns for both databases
- [Overlay Database Extensions](overlay-database-extensions.md) - Future overlay features
- [Manual Handle Linking Feature](../20-new-features/manual-handle-to-contact-linking/CHECKLIST.md) - Implementation details

---

**Last Updated**: 2025-11-04  
**Status**: Canonical reference - DO NOT IGNORE THIS FILE
