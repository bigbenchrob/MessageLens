---
feature: manual-handle-to-contact-linking
status: in-development
created: 2025-11-04
related_docs:
  - ../30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/PROPOSAL.md
  - ../30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/CHECKLIST.md
---

# Use Case: Manual Handle-to-Contact Linking

## The User Problem

**Scenario**: A user (let's call them "Rusung") changes their phone number. The old number (e.g., +1-555-0100) has thousands of historical messages, but the new number (+1-555-0199) is what's currently in their AddressBook contact card.

**Current Behavior**: The app can only automatically link handles (phone numbers/emails) to contacts if they appear in the AddressBook. When Rusung's contact is updated with only the new number, all messages from the old number become "unmatched" - they appear in an "Unknown" contact with no name or photo.

**User Impact**: Years of conversation history become disconnected from the contact. The user sees two separate "people" in their UI: one with recent messages (the new number) and one with historical messages (the old number, now unmatched).

**What Users Need**: A way to manually tell the app "this unmatched handle belongs to Rusung Tan" so all historical messages appear under Rusung's name.

## Solution Overview

Implement a **manual handle-to-contact linking system** that:
1. Allows users to right-click any unmatched handle and assign it to an existing contact
2. Stores these manual assignments in a persistent overlay database (survives re-imports)
3. Updates the message index so historical messages appear under the correct contact
4. Provides UI for viewing and managing all manual links

**Key Architecture Choice**: Use the **overlay database pattern** (not the working database) because these are user preferences that should persist across data migrations.

## System Impact Analysis

### 1. Migration Layer Changes

**Problem**: The contact picker needs to show ALL contacts, but currently the migration only imports contacts that have at least one matched handle (performance optimization).

**Change Required**: `ParticipantsMigrator` must import all AddressBook contacts, not just matched ones.
- While projecting, skip placeholder rows whose only value is "Unknown Contact" so the picker isn't flooded with unusable entries.

**Before**:
---
tier: project
scope: use-case-illustrations
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ../10-DATABASES/05-db-overlay.md
  - ../40-FEATURES/chat-handles/STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: manual-handle-to-contact-linking
status: in-development
created: 2025-11-04
related_docs:
  - ../30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/PROPOSAL.md
  - ../30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/CHECKLIST.md
- Be user-editable (add/remove links)

**New Table**: `handle_to_participant_overrides`
```sql
CREATE TABLE handle_to_participant_overrides (
  handle_id INTEGER PRIMARY KEY,        -- From working.handles
  participant_id INTEGER NOT NULL,      -- From working.participants
  source TEXT DEFAULT 'user_manual',    -- Always 'user_manual'
  confidence REAL DEFAULT 1.0,          -- Always 1.0 (user explicit)
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL
);
```

**Design Decision**: Use `handle_id` as primary key because each handle can only link to ONE participant (prevents ambiguity). A participant can have many handles (common scenario: old phone + new phone + email).

### 3. Provider Layer Merging

**Challenge**: Automatic links live in `working.handle_to_participant` (populated by migration), manual links live in `overlay.handle_to_participant_overrides`. How do we combine them?

**Solution**: Merge at the provider layer (NOT at database layer via SQL JOINs). This keeps overlay database completely independent.

**Example Provider Pattern**:
```dart
@riverpod
Future<List<ContactMessage>> contactMessagesForParticipant(
  ContactMessagesForParticipantRef ref,
  int participantId,
) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  
  // 1. Get automatic handle links from working DB
  final autoHandles = await workingDb.getHandlesForParticipant(participantId);
  
  // 2. Get manual override links from overlay DB
  final manualHandles = await overlayDb.getOverridesForParticipant(participantId);
  
  // 3. Merge: manual overrides win (higher confidence)
  final allHandleIds = {...autoHandles, ...manualHandles}.map((h) => h.id).toList();
  
  // 4. Fetch messages for all linked handles
  return workingDb.getMessagesForHandles(allHandleIds);
}
```

**Why This Works**: 
- Overlay database never touched during migration
- Provider invalidation automatically refreshes UI when links change
- Clear separation of concerns (migration = import, overlay = user prefs)

### 4. UI Flow

**Entry Point**: Right-click menu on unmatched handle cards in sidebar

**Flow**:
1. User right-clicks unmatched handle (e.g., "+1-555-0100")
2. Context menu shows "Assign to contact..."
3. Opens contact picker dialog (searchable list of ALL participants)
4. User searches "Rusung", selects "Rusung Tan"
5. Clicks "Assign"
6. System performs:
   - Write to `overlay.handle_to_participant_overrides`
  - Invalidate relevant providers so merged working + overlay reads refresh immediately
7. Success message shown
8. UI automatically updates:
   - Handle removed from "Unmatched Handles" sidebar
   - Historical messages appear in Rusung's message list
   - Timeline view updated with old messages

**Management UI**: Settings panel shows list of all manual links with ability to delete (reverses the process).

## Key Design Decisions

### Why Overlay Database (Not Working Database)?

**Alternative Considered**: Store manual links directly in `working.handle_to_participant` with a `source` column to distinguish automatic vs. manual.

**Problem**: Working database is rebuilt from scratch on every migration. Manual links would be lost unless we:
1. Export manual links before migration
2. Import AddressBook data
3. Re-apply manual links after migration
4. Handle conflicts if handles/participants changed

**Chosen Approach**: Separate overlay database that migration never touches. Simpler, cleaner separation of concerns.

### Why Not Normalize Handles?

**Alternative Considered**: Normalize phone numbers (E.164 format) and emails (lowercase) so handle matching is more robust across re-imports.

**Reality**: Handle IDs and participant IDs are already stable across migrations (preserved from `chat.db`). See `handles_migrator.dart` line 218:
```dart
// IDs preserved from source database
id: Value(row['id'] as int),
```

**Chosen Approach**: Use stable IDs directly, no normalization needed. Simpler architecture, fewer moving parts.

### Why Provider-Layer Merge?

**Alternative Considered**: Write the manual link into working-db read models so contact views update immediately.

**Problem**: That creates dual-write behavior and makes user intent vulnerable to the next migration rebuild.

**Chosen Approach**: Keep the manual link in `user_overlays.db` only, then let providers merge automatic and manual links on read. This preserves overlay independence and still updates the UI immediately after provider invalidation.

## Data Flow Example

Let's trace what happens when user assigns handle #123 to participant #456:

```
1. UI Layer (unmatched_handles_sidebar_view.dart)
   └─> User right-clicks handle
       └─> Shows context menu "Assign to contact..."
           └─> Opens ContactPickerDialog

2. UI Layer (contact_picker_dialog.dart)
   └─> User searches "Rusung"
       └─> participantsForPickerProvider filters list
           └─> User selects participant #456
               └─> Dialog returns participantId: 456

3. Application Layer (manual_handle_link_service.dart)
   └─> linkHandleToParticipant(handleId: 123, participantId: 456)
       ├─> Check for conflicts (existing manual link?)
       ├─> Write to overlay DB: handle_to_participant_overrides
  └─> Invalidate providers:
           ├─> contactMessagesOrdinalProvider
           ├─> chatsForContactProvider
           └─> unmatchedHandlesProvider

4. Database Layer
   └─> overlay_database.dart: INSERT/UPDATE override

5. Provider Layer (auto-refresh via invalidation)
   ├─> contactMessagesOrdinalProvider re-runs
   │   └─> Merges automatic + manual handle links, then includes messages from handle #123
   ├─> unmatchedHandlesProvider re-runs
   │   └─> Handle #123 no longer in list
   └─> UI automatically updates
```

## Performance Characteristics

- **Manual link creation**: <1 second (overlay write + provider invalidation)
- **Contact picker search**: <100ms (indexed query on participants table)
- **Message list refresh**: <500ms (indexed query on contact_message_index)
- **Full migration with 100 manual links**: No impact (overlay DB untouched)

## Migration Persistence

**Critical Guarantee**: Manual links survive full database re-imports.

**How It Works**:
1. User creates manual link (stored in `user_overlays.db`)
2. User triggers full migration (rebuilds `working.db` from scratch)
3. Migration process:
   - Deletes and recreates `working.db`
   - Imports all AddressBook contacts (including previously unmatched ones)
   - Rebuilds automatic handle-to-participant links
   - **Never touches `user_overlays.db`**
4. Provider layer merges:
   - Automatic links from `working.handle_to_participant`
   - Manual links from `overlay.handle_to_participant_overrides`
5. Result: Manual links still active, messages still attributed correctly

**Test Case**: See Phase 6.3 in CHECKLIST.md - "Manual test: Migration persistence"

## Cross-References

**Implementation Details**:
- [Feature Proposal](../45-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/PROPOSAL.md) - Architecture decisions, alternatives considered
- [Implementation Checklist](../45-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/CHECKLIST.md) - 47 tasks covering all layers

**Related Architecture Docs**:
- [Overlay Database Independence](../10-DATABASES/07-overlay-database-independence.md) - Inviolable overlay/working separation rules
- [Contact-to-Chat Linking](../10-DATABASES/11-contact-to-chat-linking.md) - Automatic handle matching background
- [Architecture Overview](../00-PROJECT/02-architecture-overview.md) - System layer responsibilities

**Code References**:
- `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart` - Overlay DB schema
- `lib/essentials/db_migrate/infrastructure/sqlite/migrators/participants_migrator.dart` - Migration changes
- `lib/features/contacts/application/manual_handle_link_service.dart` - Core business logic
- `lib/features/contacts/presentation/widgets/contact_picker_dialog.dart` - User-facing UI

## Future Enhancements

**Potential Extensions**:
1. **Undo Feature**: Track link history for 30 days, allow reverting recent changes
2. **Bulk Linking**: "Assign all handles from this area code to this contact"
3. **Smart Suggestions**: ML-based recommendations for likely matches
4. **Conflict Resolution UI**: Better handling when automatic and manual links disagree
5. **Export/Import**: Backup manual links separately for device migration

**Performance Optimizations**:
- Cache manual links in memory (invalidate on write)
- Batch index rebuilds if user links multiple handles rapidly
- Background index rebuild (non-blocking UI)

---

*This use case illustration demonstrates how a single user-facing feature (right-click → assign contact) requires careful coordination across five system layers: UI, providers, application services, migration, and databases. Understanding these connections is essential for maintaining and extending the codebase.*
