---
feature: manual-handle-to-contact-linking
status: proposed
created: 2025-11-01
owner: agent
---

# Feature Proposal: Manual Handle-to-Contact Linking

## Overview

Enable users to manually link unmatched chat handles (phone numbers/emails) to known contacts when automatic AddressBook matching fails. This solves the problem where contact phone numbers change over time, causing historical chats to appear as "unmatched" even though they belong to known people.

## User Value

**Problem**: User (Rob) removed old phone numbers from AddressBook for Rusung, keeping only current numbers. This caused historical chats with old numbers to become unmatched, making Rusung's aggregated contact messages incomplete.

**Solution**: Allow manual assignment of unmatched handles to participants. This creates a permanent override in the overlay database that survives re-imports.

**Benefits**:
- Complete message history for contacts across phone number changes
- Recovery of "lost" conversations without re-adding old numbers to AddressBook
- User has control over identity resolution beyond what AddressBook provides
- Overlay database ensures manual links persist across migrations

## Scope

### In Scope

**Phase 1: Basic Manual Linking**
- UI for assigning unmatched handles to contacts via menu
- Overlay database table for handle-to-participant overrides
- Reindexing system to update `contact_message_index` after manual links
- Display in "All Messages" view reflects new links
- Display in contact's chat list reflects new links

**Phase 2: Discovery & Assignment Workflow**
- Filter sidebar by "unmatched phone or email"
- Chat cards showing unmatched handles with message counts
- Context menu: "Assign to contact..."
- Contact picker dialog (search existing participants)
- Immediate UI update after assignment

**Phase 3: Management**
- View existing manual links (Settings panel)
- Delete/modify manual links
- Visual indicator showing manual vs automatic links

### Out of Scope (Future Enhancements)
- Bulk assignment of multiple handles at once
- AI-suggested matches based on message content
- Auto-detection of number changes (e.g., same name, different number)
- Import/export of manual link mappings
- Conflict resolution UI (when handle already linked automatically)
- Undo/redo for link operations

## Dependencies

### Technical Dependencies
- Existing overlay database (`user_overlays.db`) - ✅ Available
- `handle_to_participant` table in working database - ✅ Available
- `contact_message_index` rebuild capability - ✅ Available (schema v15)
- Unmatched handles provider - ✅ Available (`unmatchedHandlesProvider`)
- Contact list provider - ✅ Available (`contactsListProvider`)

### Domain Dependencies
- `WorkingDatabase` schema (handles, participants, handle_to_participant)
- `OverlayDatabase` schema (needs new table: `HandleToParticipantOverrides`)
- Migration system must respect overlay links during re-import
- Index rebuild must query overlay database for manual links

### Architectural Dependencies
- Overlay database pattern: Manual links follow existing pattern (ParticipantOverrides, ChatOverrides) as user preferences augmenting read-only imported data
- Navigation: Need context menu support on chat cards
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

**Rating**: High

**Justification**:
1. **Database Layer** (Medium-High):
   - New overlay table with schema migration
   - Modify `HandleToParticipantMigrator` to merge overlay + AddressBook links
   - Update index rebuild logic to query overlay database
   - Ensure proper UNIQUE constraint handling (overlay wins over automatic)

2. **Application Layer** (Medium):
   - CRUD providers for manual link management
   - Reindex trigger after link creation/deletion
   - Merge logic (overlay links override AddressBook links)

3. **UI Layer** (High):
   - Context menu system for chat cards (may not exist)
   - Contact picker dialog component
   - Visual indicators for manual vs automatic links
   - Settings panel for link management

4. **Integration/Migration** (High Risk):
   - Must test migration service preserves manual links
   - Index rebuild must happen atomically with link creation
   - Cache invalidation for affected providers
   - Edge case: handle already linked to different participant

**Estimated Effort**: 3-5 days

**Breakdown**:
- Day 1: Overlay database table, migration, CRUD operations
- Day 2: Integration with working database queries, merge logic
- Day 3: UI components (context menu, contact picker)
- Day 4: Reindexing integration, testing
- Day 5: Settings panel, polish, comprehensive testing

## Risks & Mitigation

### Risk 1: Migration Overwrite
**Likelihood**: High (without mitigation)
**Impact**: High (user loses manual links)
**Mitigation Strategy**: 
- Store manual links in overlay database (separate from working.db)
- Migration service reads overlay links AFTER importing AddressBook
- Manual links written to `working.handle_to_participant` with `source='user_manual'`
- Overlay links have priority: if conflict, overlay wins

### Risk 2: Index Rebuild Performance
**Likelihood**: Medium
**Impact**: Medium (UI freeze during rebuild)
**Mitigation Strategy**:
- Rebuild only affected contact's index (not full table)
- Use background isolate for heavy computation
- Show progress indicator during rebuild
- Test with large datasets (100K+ messages)

### Risk 3: Orphaned Links
**Likelihood**: Low
**Impact**: Low (confusing UI state)
**Mitigation Strategy**:
- Cascade delete: when participant deleted, remove overlay links
- Foreign key constraints in overlay database
- Settings panel shows all manual links with validation check

### Risk 4: Conflicting Links
**Likelihood**: Medium
**Impact**: Medium (same handle linked to 2 participants)
**Mitigation Strategy**:
- Unique constraint: (handle_id) in overlay table
- UI prevents assigning already-linked handle
- If automatic link exists, warn user before manual override
- Manual link replaces automatic (source='user_manual' takes priority)

### Risk 5: UI Complexity
**Likelihood**: Medium
**Impact**: Medium (poor UX if cluttered)
**Mitigation Strategy**:
- Phased rollout: basic linking first, management UI later
- Context menu only on unmatched handles
- Contact picker with search/filter
- Clear visual distinction (icon/badge for manual links)

## Architecture Impact

### Affected Components
- **Overlay Database**: New table `HandleToParticipantOverrides`
- **Working Database Queries**: All queries joining `handle_to_participant` must include overlay links
- **Migration Service**: `HandlesMigrationService.run()` must merge overlay + AddressBook links
- **Index Rebuild**: `contact_message_index` rebuild must reflect manual links
- **UI**: Context menus, contact picker, settings panel

### New Components Required

**1. Overlay Database Schema** (`lib/essentials/db/infrastructure/data_sources/local/overlay/`)
```dart
class HandleToParticipantOverrides extends Table {
  IntColumn get handleId => integer()();  // FK to working.handles.id
  IntColumn get participantId => integer()();  // FK to working.participants.id
  TextColumn get source => text().withDefault(const Constant('user_manual'))();
  RealColumn get confidence => real().withDefault(const Constant(1.0))();
  TextColumn get createdAtUtc => text()();
  TextColumn get updatedAtUtc => text()();
  
  @override
  Set<Column> get primaryKey => {handleId};  // One handle → one participant
}
```

**2. Application Layer Providers** (`lib/features/contacts/application/`)
- `manual_handle_link_service.dart` - CRUD operations
- `manual_links_list_provider.dart` - Fetch all manual links for UI
- `link_handle_to_participant_provider.dart` - Performs link + reindex

**3. UI Components** (`lib/features/contacts/presentation/`)
- `ContactPickerDialog` - Search/select participant
- Context menu for chat cards (may require new macos_ui component)
- Settings panel section for link management

**4. Domain Entities** (`lib/features/contacts/domain/`)
```dart
class ManualHandleLink {
  final int handleId;
  final String handleIdentifier;  // For display
  final int participantId;
  final String participantName;  // For display
  final DateTime createdAt;
}
```

### Database Changes

**Overlay Database Schema Version 3**:
```sql
CREATE TABLE handle_to_participant_overrides (
  handle_id INTEGER PRIMARY KEY,  -- FK to working.handles.id
  participant_id INTEGER NOT NULL,  -- FK to working.participants.id
  source TEXT NOT NULL DEFAULT 'user_manual',
  confidence REAL NOT NULL DEFAULT 1.0,
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL
);
```

**Working Database Query Updates**:
All queries joining `handle_to_participant` must LEFT JOIN overlay table:
```sql
-- Before
SELECT * FROM handles h
LEFT JOIN handle_to_participant htp ON h.id = htp.handle_id

-- After (conceptual - actual implementation via Drift)
SELECT * FROM handles h
LEFT JOIN handle_to_participant htp ON h.id = htp.handle_id
LEFT JOIN overlay.handle_to_participant_overrides htpo ON h.id = htpo.handle_id
WHERE htpo.handle_id IS NOT NULL OR htp.handle_id IS NOT NULL
-- Prioritize overlay link if both exist
```

**Migration Requirements**:
- Overlay database v2 → v3: Add `handle_to_participant_overrides` table
- No working database changes (reads overlay at runtime)
- Migration service updated to merge overlay links into `working.handle_to_participant`

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
- Progress indicator: "Reindexing messages..."
- Success message: "Handle linked to Rusung Tan"

**Step 5: Verification**
- Handle disappears from "Unmatched" list
- Navigate to Rusung's "All Messages" view
- Messages from old number now appear
- Manual link badge/icon visible (optional visual distinction)

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
- Merge logic (overlay + AddressBook links)
- Conflict resolution (duplicate handle_id)
- Index rebuild for specific participant

### Integration Testing
- Full workflow: assign handle → verify messages appear
- Migration service preserves manual links
- Query performance with overlay joins
- Cache invalidation after link creation

### UI/Widget Testing
- Context menu appears on chat card
- Contact picker dialog renders correctly
- Search/filter in contact picker
- Settings panel shows manual links

### Performance Testing
- Benchmark: reindex 10K/100K/500K messages
- Query time impact with overlay joins
- UI responsiveness during reindex

### Edge Cases
- Assign handle already linked (automatic)
- Assign handle to participant with many existing handles
- Delete participant with manual links (should cascade)
- Re-import database (manual links persist)
- Assign same handle twice (should update, not duplicate)

## Documentation Requirements

### User-Facing Documentation
- Help article: "Linking old phone numbers to contacts"
- Screenshot guide for context menu + picker
- FAQ: "Why are some messages missing?" → Manual linking solution

### API Documentation
- Overlay database schema documentation
- Provider API for manual link operations
- Example: How to trigger reindex after link

### Architecture Documentation
- Update `_AGENT_INSTRUCTIONS/agent-per-project/05-databases/overlay-database-extensions.md`
- Document merge logic in participant-handle architecture doc
- Migration service flow diagram (overlay + AddressBook)

### Migration Guides
- For users: None (automatic detection of missing messages)
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

**Why Overlay Database?**
- Manual links are user preferences, not source data
- Survives re-imports (working.db is ephemeral)
- Clean separation: data layer vs intelligence layer
- Matches existing pattern (ParticipantOverrides, ChatOverrides)

**Why Primary Key on handle_id?**
- One handle can only belong to one participant (business rule)
- Prevents ambiguity: "Who sent this message?"
- If user changes mind, they delete and re-assign (not multi-link)

**Why source='user_manual'?**
- Distinguishes from AddressBook automatic links
- Enables filtering: "Show only automatic" or "Show only manual"
- Future-proof: supports other sources (e.g., 'ai_suggested', 'csv_import')

**Why confidence=1.0 for manual links?**
- User explicitly confirmed the link (highest confidence)
- Matches AddressBook confidence (both are trusted)
- Future AI suggestions may have lower confidence

### Open Questions

1. **UI Location for Assignment**
   - Option A: Context menu on chat card (requires new component?)
   - Option B: Button in chat card footer
   - Option C: Toolbar button when chat selected
   - **Recommendation**: Option A (most discoverable, platform-native)

2. **Reindex Strategy**
   - Option A: Rebuild entire `contact_message_index` (simple, slow)
   - Option B: Rebuild only affected participant (complex, fast)
   - Option C: Incremental update (very complex, fastest)
   - **Recommendation**: Option B for v1, Option C if performance issues

3. **Conflict Handling**
   - Scenario: Handle already linked in AddressBook to different participant
   - Option A: Block manual link (show error)
   - Option B: Allow override, show warning
   - Option C: Show conflict resolution UI
   - **Recommendation**: Option B (user intent overrides automatic)

4. **Visual Indicator**
   - Should manual links have a badge/icon?
   - Pros: Transparency, user knows which links are manual
   - Cons: Visual clutter, may confuse users
   - **Recommendation**: Yes, but subtle (small icon in chat card)

### Technical Notes

**Drift ORM Complexity**:
- Overlay database queries must be async (separate connection)
- Working database queries need LEFT JOIN to overlay (adds complexity)
- Consider caching overlay links in memory for performance

**Index Rebuild Atomicity**:
- Link creation + index rebuild should be atomic (or transactional)
- If rebuild fails, should revert link? Or leave link + stale index?
- **Recommendation**: Optimistic update (show immediately, rebuild async)

**Cache Invalidation**:
- After link creation: invalidate `contactMessagesOrdinalProvider`
- After link creation: invalidate `chatsForContactProvider`
- After link creation: invalidate `unmatchedHandlesProvider`
- **Recommendation**: Use Riverpod `ref.invalidate()` for affected providers
