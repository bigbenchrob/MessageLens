---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2025-11-06
links:
  - ../../50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md
  - ../../40-FEATURES/chat-handles/CHARTER.md
tests: []
feature: manual-handle-to-contact-linking
status: proposed
created: 2025-11-01
---

# Feature Proposal: Manual Handle-to-Contact Linking

## Overview

Enable users to manually link unmatched chat handles (phone numbers/emails) to any contact in their AddressBook, including contacts that have no automatically-matched handles. This solves two problems:
1. Contact phone numbers change over time, causing historical chats to appear as "unmatched" 
2. Contacts without current matching handles are unavailable for manual linking

## User Value

**Problem**: User (Rob) removed old phone numbers from AddressBook for Rusung, keeping only current numbers. This caused:
- Historical chats with old numbers became "unmatched"
- Rusung's contact didn't appear in the working database at all (since no handles matched)
- No way to manually link old chats back to Rusung

**Solution**: 
1. Import ALL AddressBook contacts into working database (not just those with matching handles)
2. Store manual handle-to-participant links in overlay database
3. Merge overlay links with automatic links when displaying contacts

**Benefits**:
- Complete message history for contacts across phone number changes
- Access to entire AddressBook for manual linking (not just matched contacts)
- Simple overlay table with stable IDs (handle_id and participant_id are already preserved from source)
- Manual links persist across migrations via overlay database

## Scope

### In Scope

**Phase 1: Migration & Database Changes**
- Modify `ParticipantsMigrator` to import ALL AddressBook contacts (not filtered by handle matches)
- Create simple overlay database table: `handle_to_participant_overrides` with handle_id + participant_id
- No handle normalization needed (IDs are already stable from source chat.db)
- No reconciliation service needed (IDs preserved through migration)

**Phase 2: Provider Architecture**
- Implement provider for overlay database links
- Create merged provider combining working DB + overlay DB links
- Two contact menu providers:
  - Menu A: Contacts with at least one linked handle (auto OR manual)
  - Menu B: All contacts (entire AddressBook)

**Phase 3: UI for Manual Linking**
- Context menu on unmatched handles: "Assign to contact..."
- Contact picker dialog showing ALL contacts (Menu B)
- Immediate UI update after assignment
- Reindex contact messages after link creation

**Phase 4: Link Management**
- Settings panel showing all manual links
- Delete/modify manual links
- Visual indicator for manual vs automatic links

### Out of Scope (Future Enhancements)
- Bulk assignment of multiple handles at once
- AI-suggested matches based on message content
- Auto-detection of number changes
- Import/export of manual link mappings
- Undo/redo for link operations

## Dependencies

### Technical Dependencies
- ✅ Existing overlay database (`user_overlays.db`)
- ✅ `handle_to_participant` table in working database
- ✅ `contact_message_index` rebuild capability (schema v15)
- ✅ Unmatched handles provider (`unmatchedHandlesProvider`)
- ✅ Source IDs preserved: handle.id, participant.id, chat.id maintained from chat.db through import
- ✅ `ParticipantsMigrator` SQL ready to import all contacts (see participants_migrator.dart)

### Domain Dependencies
- `WorkingDatabase` schema (handles_canonical, handles_canonical_to_alias, participants, handle_to_participant)
  - Note: Handles from `handle_to_participant` must be resolved through `handles_canonical_to_alias` because only `handles_canonical_to_alias.canonical_handle_id` values link to chats in `chat_to_handle` (multiple alias handles link to a single canonical handle; only the canonical handle links to chats). See Section 4 in `contact-to-chat-linking.md`.
- `OverlayDatabase` schema (needs new table: `handle_to_participant_overrides`)
- Migration system must merge overlay links with automatic links during re-import
- Index rebuild must reflect manual links from overlay database

### Architectural Dependencies
- Overlay database pattern: Manual links follow existing pattern (participant_overrides, chat_overrides)
- Provider architecture: Merge working DB + overlay DB links (see provider_strategy_contact_menus.md)
- Navigation: Context menu support on chat cards
- State management: Riverpod providers for overlay CRUD operations

## Success Criteria

- [x] **Functional**: User can assign unmatched handle to existing contact
- [x] **Functional**: Manual link persists after app restart
- [x] **Functional**: Manual link survives database re-import
- [x] **Functional**: Contact's "All Messages" view includes messages from manually linked handle
- [x] **Functional**: Contact's chat list includes chats with manually linked handle
- [x] **Quality**: No performance degradation on existing queries
- [x] **Quality**: `contact_message_index` rebuild completes in reasonable time (<30s for 100K messages)
- [x] **Quality**: All linting passes, test coverage >80% for new code
- [ ] **UX**: Manual link indicator visible in UI (shows user which links are automatic vs manual)

## Complexity Estimate

**Rating**: Medium

**Justification**:
1. **Migration Changes** (Low):
   - Remove `WHERE` filter in ParticipantsMigrator SQL (already written, just needs uncommenting)
   - All contacts imported instead of only matched ones
   - IDs are already stable (preserved from chat.db), no normalization needed

2. **Database Layer** (Low):
   - Simple overlay table: `handle_to_participant_overrides` with two integer columns
   - No complex natural keys or reconciliation logic required
   - Standard Drift table definition and CRUD operations

3. **Provider Layer** (Medium):
   - Repository helpers for overlay database queries
   - Merged provider combining working + overlay links (see provider_strategy_contact_menus.md)
   - Two menu providers: linked contacts (Menu A) and all contacts (Menu B)
   - Cache invalidation after link operations

4. **UI Layer** (Medium):
   - Context menu system for chat cards (may not exist yet)
   - Contact picker dialog showing all contacts
   - Settings panel for link management
   - Visual indicators for manual vs automatic links

5. **Integration** (Low):
   - Index rebuild after link creation (existing capability)
   - Provider invalidation (standard Riverpod pattern)
   - No migration preservation needed (overlay DB separate from working DB)

**Estimated Effort**: 2-3 days

**Breakdown**:
- Day 1: Migration changes + overlay database table + CRUD providers
- Day 2: Merged provider architecture + UI components (context menu, picker)
- Day 3: Settings panel + testing + polish

## Risks & Mitigation

### Risk 1: Migration Changes Breaking Existing Logic
**Likelihood**: Low
**Impact**: Medium (participants without handles may break assumptions)
**Mitigation Strategy**: 
- Thoroughly test queries that assume all participants have handles
- Add `is_linked` flag to distinguish linked vs floating contacts
- Filter queries appropriately (chat sidebar shows only linked, picker shows all)
- Comprehensive integration tests

### Risk 2: Index Rebuild Performance
**Likelihood**: Low
**Impact**: Medium (UI freeze during rebuild)
**Mitigation Strategy**:
- Rebuild only affected contact's index (not full table)
- Use existing optimized rebuild capability
- Show progress indicator during rebuild
- Test with large datasets (100K+ messages)

### Risk 3: Orphaned Links
**Likelihood**: Low
**Impact**: Low (manual link to deleted contact)
**Mitigation Strategy**:
- Foreign key constraints in overlay database
- Settings panel shows validation status for each link
- Graceful handling: show handle value if contact missing

### Risk 4: Conflicting Links
**Likelihood**: Medium
**Impact**: Low (same handle linked automatically and manually)
**Mitigation Strategy**:
- Unique constraint on handle_id in overlay table
- UI prevents assigning already-linked handle
- Manual link overrides automatic (overlay takes precedence)
- Clear visual indicator showing link source

## Architecture Impact

### Affected Components
- **ParticipantsMigrator**: Remove filter to import ALL contacts (see participants_migrator.dart)
- **Overlay Database**: New table `handle_to_participant_overrides` (simple: handle_id + participant_id)
- **Provider Layer**: Merged providers combining working + overlay links (see provider_strategy_contact_menus.md)
- **Index Rebuild**: `contact_message_index` rebuild reflects manual links
- **UI**: Context menus, contact picker, settings panel

### New Components Required

**1. Overlay Database Schema** (`lib/essentials/db/infrastructure/data_sources/local/overlay/`)
```dart
class HandleToParticipantOverrides extends Table {
  IntColumn get handleId => integer()();  // Stable ID from chat.db
  IntColumn get participantId => integer()();  // Stable ID (Z_PK) from AddressBook
  TextColumn get source => text().withDefault(const Constant('user_manual'))();
  TextColumn get createdAtUtc => text()();
  TextColumn get updatedAtUtc => text()();
  
  @override
  Set<Column> get primaryKey => {handleId};  // One handle → one participant
}
```

**Key Insight**: No normalization needed! IDs are already stable:
- `handle.id` preserved from chat.db through import and migration
- `participant.id` equals AddressBook Z_PK (already stable and preserved)
- No reconciliation service needed - IDs don't change on re-import

**2. Repository Layer** (`lib/features/contacts/application/`)
```dart
// Working DB links
class HandleLinksRepository {
  Future<Set<int>> getParticipantIdsWithLinks() async {
    // Query working.handle_to_participant
  }
}

// Overlay DB links
class OverlayHandleLinksRepository {
  Future<Set<int>> getParticipantIdsWithOverrides() async {
    // Query user_overlays.handle_to_participant_overrides
  }
}
```

**3. Provider Layer** (see provider_strategy_contact_menus.md for full details)
```dart
@riverpod
Future<List<Participant>> contactsMenuA(ContactsMenuARef ref) async {
  // Linked contacts (working + overlay)
  // Returns: Contacts with at least one handle link (auto OR manual)
}

@riverpod
Future<List<Participant>> contactsMenuB(ContactsMenuBRef ref) async {
  // All contacts (entire AddressBook)
  // Returns: Every participant regardless of handle links
}
```

**4. UI Components** (`lib/features/contacts/presentation/`)
- `ContactPickerDialog` - Search/select from ALL contacts (Menu B)
- Context menu for unmatched handles: "Assign to contact..."
- Settings panel section for manual link management

### Database Changes

**ParticipantsMigrator SQL Change**:
```sql
-- Current (filters to only matched contacts):
WHERE c.is_ignored = 0 AND c.Z_PK IS NOT NULL
  AND EXISTS (SELECT 1 FROM contact_to_handle WHERE contact_z_pk = c.Z_PK);

-- New (imports ALL contacts):
WHERE c.is_ignored = 0 AND c.Z_PK IS NOT NULL;
```

**Overlay Database Schema Version 3**:
```sql
CREATE TABLE handle_to_participant_overrides (
  handle_id INTEGER PRIMARY KEY,  -- Stable from chat.db
  participant_id INTEGER NOT NULL,  -- Stable Z_PK from AddressBook
  source TEXT NOT NULL DEFAULT 'user_manual',
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL
);
```

**No Working Database Changes**: Overlay links queried at runtime and merged with automatic links via providers

**Migration Requirements**:
- Overlay database v2 → v3: Add `handle_to_participant_overrides` table
- ParticipantsMigrator: Remove `EXISTS` filter (one-line change)
- No data migration needed (overlay table starts empty)

## UI/UX Considerations

### User Journey: Discovery → Assignment

**Step 1: Discovery**
- User navigates to "Unmatched Phone Numbers" or "Unmatched Emails" in sidebar
- Sees list of chat cards with unmatched handles
- Each card shows:
  - Formatted phone/email
  - Message count
  - Date range
  - Preview of recent message

**Step 2: Identification**
- User reads messages and recognizes the contact (e.g., "This is Rusung's old number")
- Right-clicks (or long-press) chat card

**Step 3: Assignment**
- Context menu appears: "Assign to contact..."
- Dialog opens with participant picker:
  - Search field (filter by name)
  - Scrollable list of all participants
  - Shows participant name + phone/email count
  - Cancel / Confirm buttons

**Step 4: Confirmation**
- User selects contact (e.g., "Rusung Tan")
- Clicks "Confirm"
- Link created in overlay database
- Provider invalidation triggers UI updates
- Progress indicator: "Reindexing messages..."
- Success message: "Handle linked to Rusung Tan"

**Step 5: Verification**
- Handle disappears from "Unmatched" list
- Navigate to Rusung's "All Messages" view
- Messages from old number now appear
- Manual link badge/icon visible (shows this is user-created link)

### Accessibility
- Keyboard navigation for context menus
- Screen reader support for link indicators
- Clear focus states for dialogs
- Undo capability (via Settings panel)

### Platform-Specific (macOS)
- Use MacosContextMenu or PopupMenuButton
- macOS-style dialog for contact picker
- Consider using MacosSheet for modal picker

## Testing Strategy

### Unit Testing
- Overlay database CRUD operations
- Merge logic (working + overlay links via providers)
- Contact menu providers (Menu A: linked, Menu B: all)
- Index rebuild for specific participant

### Integration Testing
- Full workflow: assign handle → verify messages appear
- Migration imports all contacts (not just matched)
- Provider invalidation after link creation
- Query performance with overlay + working DB merge

### UI/Widget Testing
- Context menu appears on unmatched handle
- Contact picker shows ALL contacts (Menu B)
- Search/filter in contact picker
- Settings panel shows manual links

### Performance Testing
- Benchmark: reindex 10K/100K/500K messages
- Provider merge performance (working + overlay)
- UI responsiveness during operations

### Edge Cases
- Assign handle already linked (automatic)
- Delete participant with manual links
- Re-import database (manual links persist in overlay)
- Contact picker with 1000+ contacts

## Documentation Requirements

### User-Facing Documentation
- Help article: "Linking old phone numbers to contacts"
- Screenshot guide for context menu + picker
- FAQ: "Why are some contacts missing?" → All contacts now available

### API Documentation
- Overlay database schema documentation
- Provider architecture for merged links (see provider_strategy_contact_menus.md)
- Example: How to create manual link and trigger reindex

### Architecture Documentation
- Update `_AGENT_INSTRUCTIONS/agent-per-project/05-databases/overlay-database-extensions.md`
- Document provider merge strategy (working + overlay)
- ParticipantsMigrator documentation (imports all contacts)

### Migration Guides
- For users: Automatic (no action required)
- For developers: Overlay database migration v2 → v3

## Future Enhancements

Ideas for future iterations (out of scope for v1):

### Phase 2 Enhancements
- Bulk assignment: Select multiple handles → assign to one contact
- Suggested matches: ML model suggests likely contact based on message content
- Link history: Track changes to manual links (audit log)

### Phase 3 Enhancements
- Import/export manual links as JSON (backup/restore)
- Conflict resolution wizard (when handle linked in AddressBook and manually)
- Bulk import from CSV: `handle_identifier,participant_id,confidence`

### Advanced Features
- Auto-detect number changes: "Rusung changed from +1-XXX to +1-YYY" (pattern matching)
- Confidence scoring: Show uncertainty for automatic vs manual links
- Link suggestions in UI: "This handle looks like Rusung (90% match)"

## Approval

- [ ] User/stakeholder approved
- [ ] Technical review complete
- [ ] Ready to proceed to planning

---

## Notes

### Design Decisions

**Why Import All Contacts?**
- Enables manual linking to ANY AddressBook contact (not just those with current handles)
- Simple SQL change: remove `EXISTS` filter from ParticipantsMigrator
- No performance impact: Contact table is small (<10K rows typically)

**Why Use Stable IDs (Not Natural Keys)?**
- Source IDs already preserved: `handle.id` and `participant.id` (Z_PK) maintained from chat.db through import
- No normalization needed: IDs don't change on re-import
- Simple overlay table: Just two integer columns
- No reconciliation service: IDs are stable by design

**Why Overlay Database?**
- Manual links are user preferences, not source data
- Survives re-imports (working.db is rebuilt each migration)
- Clean separation: data layer vs user intelligence layer
- Matches existing pattern (participant_overrides, chat_overrides)

**Why Primary Key on handle_id?**
- One handle can only belong to one participant (business rule)
- Prevents ambiguity: "Who sent this message?"
- If user changes mind, they delete and re-assign (not multi-link)

**Why Two Menu Providers?**
- Menu A (linked contacts): For chat sidebar - shows only relevant contacts with messages
- Menu B (all contacts): For contact picker - entire AddressBook available for assignment
- Clear separation of concerns: display context determines filtering

**Why Provider Merge Strategy?**
- Cleaner than SQL joins across databases
- More testable (mock each DB independently)
- Explicit precedence: overlay links override automatic links
- Riverpod invalidation works naturally

### Open Questions

1. **Visual Indicator for Manual Links**
   - Should manual links have a badge/icon in UI?
   - Pros: Transparency, user knows which links are manual
   - Cons: Visual clutter, may confuse users
   - **Recommendation**: Yes, but subtle (small icon in settings panel)

2. **Conflict Handling**
   - Scenario: Handle already linked automatically to different participant
   - Option A: Block manual link (show error)
   - Option B: Allow override, show warning
   - **Recommendation**: Option B (user intent overrides automatic)

3. **Reindex Strategy**
   - Option A: Rebuild affected participant's index only (fast)
   - Option B: Rebuild entire contact_message_index (simple but slow)
   - **Recommendation**: Option A (existing capability already optimized)

### Technical Notes

**ID Stability Verification**:
- ✅ Confirmed: `handle.id` preserved from chat.db in handles_migrator.dart (line 218: `id: Value(handle.id)`)
- ✅ Confirmed: `participant.id` equals Z_PK from AddressBook (preserved through import)
- ✅ Result: No normalization or reconciliation needed - IDs are stable

**Provider Architecture** (see provider_strategy_contact_menus.md):
```dart
// Menu A: Linked contacts (working + overlay)
contactsMenuAProvider → filters to participants with links

// Menu B: All contacts (no filter)
contactsMenuBProvider → all participants from working DB
```

**Cache Invalidation**:
- After link creation: `ref.invalidate(contactsMenuAProvider)`
- After link creation: `ref.invalidate(unmatchedHandlesProvider)`
- After link creation: `ref.invalidate(contactMessagesOrdinalProvider)`
