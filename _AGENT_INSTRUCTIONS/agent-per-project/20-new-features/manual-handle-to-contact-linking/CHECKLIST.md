---
feature: manual-handle-to-contact-linking
status: in-development
created: 2025-11-01
last_updated: 2025-11-01
---

# Development Checklist: Manual Handle-to-Contact Linking

**Feature Status**: 🔴 Not Started

**Progress**: 0/47 tasks complete (0%)

---

## Phase 1: Database Layer (Day 1)

### 1.1 Overlay Database Schema
- [ ] **Task**: Add `HandleToParticipantOverrides` table to overlay database schema
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**: 
    - Add table definition with columns: `handle_id` (PK), `participant_id`, `source`, `confidence`, `created_at_utc`, `updated_at_utc`
    - Set primary key on `handle_id`
    - Add defaults: `source='user_manual'`, `confidence=1.0`
  - **Acceptance**: Table defined, compiles without errors

- [ ] **Task**: Increment overlay database schema version (2 → 3)
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**: Update `schemaVersion` getter
  - **Acceptance**: Schema version is 3

- [ ] **Task**: Add migration logic for schema v2 → v3
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**: Update `onUpgrade` to create `handle_to_participant_overrides` table when migrating from v2
  - **Acceptance**: Migration creates table, no errors on upgrade

- [ ] **Task**: Run build_runner to generate Drift code
  - **Command**: `dart run build_runner build --delete-conflicting-outputs`
  - **Acceptance**: Generated `.g.dart` file includes new table, 0 errors

- [ ] **Task**: Test overlay database migration manually
  - **Details**: Delete `user_overlays.db`, restart app, verify v3 schema
  - **Acceptance**: Database created with v3 schema, table exists

### 1.2 Overlay Database CRUD Operations
- [ ] **Task**: Add helper method `getHandleOverride(int handleId)`
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**: Query by primary key, return `HandleToParticipantOverride?`
  - **Acceptance**: Method compiles, returns null for non-existent keys

- [ ] **Task**: Add helper method `getAllHandleOverrides()`
  - **File**: Same as above
  - **Details**: Return `List<HandleToParticipantOverride>`, ordered by `created_at_utc`
  - **Acceptance**: Returns empty list when no overrides exist

- [ ] **Task**: Add helper method `setHandleOverride(int handleId, int participantId)`
  - **File**: Same as above
  - **Details**: 
    - Use `insertOnConflictUpdate` pattern (like `setParticipantShortName`)
    - Set timestamps automatically
    - Set `source='user_manual'`, `confidence=1.0`
  - **Acceptance**: Creates new override or updates existing, timestamps correct

- [ ] **Task**: Add helper method `deleteHandleOverride(int handleId)`
  - **File**: Same as above
  - **Details**: Delete by primary key
  - **Acceptance**: Removes override, returns gracefully if not exists

- [ ] **Task**: Add helper method `getOverridesForParticipant(int participantId)`
  - **File**: Same as above
  - **Details**: Query all overrides where `participant_id` matches
  - **Acceptance**: Returns list of overrides for given participant

### 1.3 Unit Tests - Database Layer
- [ ] **Task**: Create test file for overlay database CRUD
  - **File**: `test/essentials/db/infrastructure/data_sources/local/overlay/overlay_database_test.dart`
  - **Details**: Set up in-memory database for testing
  - **Acceptance**: Test suite runs, setUp/tearDown correct

- [ ] **Task**: Test: Create handle override
  - **Details**: Call `setHandleOverride`, verify via `getHandleOverride`
  - **Acceptance**: Override persists with correct values

- [ ] **Task**: Test: Update existing handle override
  - **Details**: Create override, update to different participant, verify
  - **Acceptance**: Participant ID updated, timestamps updated

- [ ] **Task**: Test: Delete handle override
  - **Details**: Create override, delete, verify null return
  - **Acceptance**: Override removed from database

- [ ] **Task**: Test: Get all overrides for participant
  - **Details**: Create multiple overrides for same participant, query
  - **Acceptance**: Returns all matching overrides

- [ ] **Task**: Test: Handle override persistence
  - **Details**: Create override, close/reopen database, verify exists
  - **Acceptance**: Override survives database restart

**Phase 1 Complete When**: All database layer tests pass, schema v3 working

---

## Phase 2: Migration Integration (Day 2)

### 2.1 Migration Service Updates
- [ ] **Task**: Read overlay database in `HandlesMigrationService`
  - **File**: `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart`
  - **Details**: 
    - Add overlay database as dependency (inject via constructor or ref)
    - Read all handle overrides AFTER AddressBook import
  - **Acceptance**: Overlay database accessible in migration service

- [ ] **Task**: Merge overlay links into `working.handle_to_participant`
  - **File**: Same as above
  - **Details**: 
    - After `HandleToParticipantMigrator` completes
    - Insert overlay links with `source='user_manual'`
    - Handle conflicts: overlay wins (DELETE automatic link if exists)
  - **Acceptance**: Manual links appear in working database after migration

- [ ] **Task**: Add logging for manual link merging
  - **Details**: Log count of manual links merged, conflicts resolved
  - **Acceptance**: Migration log shows "Merged X manual handle links"

### 2.2 Index Rebuild Integration
- [ ] **Task**: Create helper method `rebuildContactMessageIndexForParticipant(int participantId)`
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`
  - **Details**: 
    - Delete entries where `contact_id = participantId`
    - Rebuild using same SQL as full rebuild but filtered to participant
    - Drop/recreate triggers (reuse existing pattern)
  - **Acceptance**: Method rebuilds index for one participant only

- [ ] **Task**: Test partial index rebuild performance
  - **Details**: Benchmark with 1K, 10K, 100K messages
  - **Acceptance**: Completes in <5s for 100K messages

### 2.3 Integration Tests - Migration
- [ ] **Task**: Test: Manual links survive re-import
  - **File**: `test/essentials/db_migrate/handles_migration_service_test.dart`
  - **Details**: 
    - Create manual link in overlay
    - Run migration
    - Verify link exists in working database
  - **Acceptance**: Manual link preserved with `source='user_manual'`

- [ ] **Task**: Test: Manual link overrides automatic link
  - **Details**: 
    - Create automatic link (via AddressBook)
    - Create conflicting manual link
    - Run migration
    - Verify manual link wins
  - **Acceptance**: Only manual link exists, automatic link removed

- [ ] **Task**: Test: Manual links included in contact message index
  - **Details**: 
    - Create manual link
    - Run migration + index rebuild
    - Query `contact_message_index` for participant
    - Verify messages from manually linked handle appear
  - **Acceptance**: Messages indexed correctly

**Phase 2 Complete When**: Migration tests pass, manual links persist through re-import

---

## Phase 3: Application Layer (Day 2-3)

### 3.1 Domain Entities
- [ ] **Task**: Create `ManualHandleLink` entity
  - **File**: `lib/features/contacts/domain/manual_handle_link.dart`
  - **Details**: 
    - Properties: `handleId`, `handleIdentifier`, `participantId`, `participantName`, `createdAt`
    - Use Freezed for immutability
    - Add factory constructor from database row
  - **Acceptance**: Entity compiles, Freezed generation successful

### 3.2 Application Services
- [ ] **Task**: Create `ManualHandleLinkService` provider
  - **File**: `lib/features/contacts/application/manual_handle_link_service.dart`
  - **Details**: 
    - Async method: `linkHandleToParticipant(int handleId, int participantId)`
    - Steps: 1) Create overlay link, 2) Update working.handle_to_participant, 3) Trigger index rebuild, 4) Invalidate caches
    - Return `Either<Failure, Unit>` for error handling
  - **Acceptance**: Method creates link and rebuilds index

- [ ] **Task**: Add error handling for conflicts
  - **Details**: 
    - Check if handle already linked (automatic or manual)
    - If automatic link exists, warn but allow override
    - If manual link exists to different participant, return error
  - **Acceptance**: Errors returned as Failure objects

- [ ] **Task**: Create `manualLinksListProvider`
  - **File**: `lib/features/contacts/application/manual_links_list_provider.dart`
  - **Details**: 
    - Riverpod @riverpod provider
    - Fetches all manual links from overlay database
    - Joins with working database to get display names
    - Returns `List<ManualHandleLink>`
  - **Acceptance**: Provider returns enriched list

- [ ] **Task**: Add cache invalidation logic
  - **Details**: 
    - After link creation: invalidate `contactMessagesOrdinalProvider`
    - After link creation: invalidate `chatsForContactProvider`
    - After link creation: invalidate `unmatchedHandlesProvider`
  - **Acceptance**: Providers refresh after link creation

### 3.3 Unit Tests - Application Layer
- [ ] **Task**: Test: Link handle to participant success
  - **File**: `test/features/contacts/application/manual_handle_link_service_test.dart`
  - **Details**: Mock databases, verify link created
  - **Acceptance**: Link created in overlay and working databases

- [ ] **Task**: Test: Override automatic link
  - **Details**: Create automatic link, call service, verify manual wins
  - **Acceptance**: Automatic link replaced with manual

- [ ] **Task**: Test: Prevent duplicate manual link
  - **Details**: Create manual link, try to create again with different participant
  - **Acceptance**: Returns error, original link unchanged

- [ ] **Task**: Test: Cache invalidation
  - **Details**: Mock Riverpod ref, verify `invalidate()` called
  - **Acceptance**: All affected providers invalidated

**Phase 3 Complete When**: All application tests pass, service methods working

---

## Phase 4: UI Components (Day 3-4)

### 4.1 Contact Picker Dialog
- [ ] **Task**: Create `ContactPickerDialog` widget
  - **File**: `lib/features/contacts/presentation/widgets/contact_picker_dialog.dart`
  - **Details**: 
    - MacosSheet or showMacosDialog wrapper
    - Search field at top (TextEditingController)
    - Scrollable list of participants (filtered by search)
    - Each item shows participant name + handle count
    - Cancel / Confirm buttons
  - **Acceptance**: Dialog renders, search filters list

- [ ] **Task**: Add participant provider with search
  - **File**: `lib/features/contacts/application/participants_for_picker_provider.dart`
  - **Details**: 
    - Riverpod provider accepting `searchQuery` parameter
    - Query working.participants filtered by name (case-insensitive)
    - Include handle count for each participant
  - **Acceptance**: Provider returns filtered participants

- [ ] **Task**: Wire up dialog result handling
  - **Details**: 
    - Dialog returns `int?` (selected participant ID)
    - Caller handles null (cancel) vs ID (confirm)
  - **Acceptance**: Dialog returns correct participant ID on confirm

### 4.2 Context Menu Integration
- [ ] **Task**: Research macOS context menu component
  - **Details**: Check if `macos_ui` has `MacosContextMenu` or use `PopupMenuButton`
  - **Acceptance**: Component identified for use

- [ ] **Task**: Add context menu to unmatched handle cards
  - **File**: `lib/features/contacts/presentation/view/unmatched_handles_sidebar_view.dart`
  - **Details**: 
    - Wrap `_UnmatchedHandleListItem` with context menu
    - Menu item: "Assign to contact..."
    - On select: open `ContactPickerDialog`
  - **Acceptance**: Right-click shows menu, menu item clickable

- [ ] **Task**: Wire up assignment action
  - **Details**: 
    - Get participant ID from dialog
    - Call `ManualHandleLinkService.linkHandleToParticipant`
    - Show progress indicator during reindex
    - Show success/error message
    - Remove handle from unmatched list (automatic via cache invalidation)
  - **Acceptance**: Full flow works end-to-end

### 4.3 Visual Indicators
- [ ] **Task**: Add manual link badge to chat cards
  - **File**: `lib/features/chats/presentation/widgets/chat_card.dart` (or equivalent)
  - **Details**: 
    - Check if chat's handles have manual links (query overlay)
    - Show small icon/badge if manual link present
    - Tooltip: "Manually linked to contact"
  - **Acceptance**: Badge appears on manually linked chats

### 4.4 Widget Tests - UI Components
- [ ] **Task**: Test: Contact picker dialog renders
  - **File**: `test/features/contacts/presentation/widgets/contact_picker_dialog_test.dart`
  - **Details**: Render dialog, verify search field and list present
  - **Acceptance**: Widget test passes

- [ ] **Task**: Test: Contact picker search filters
  - **Details**: Enter search text, verify list filtered
  - **Acceptance**: Filtered participants shown

- [ ] **Task**: Test: Context menu appears
  - **File**: `test/features/contacts/presentation/view/unmatched_handles_sidebar_view_test.dart`
  - **Details**: Simulate right-click, verify menu shown
  - **Acceptance**: Menu appears with correct item

**Phase 4 Complete When**: UI components working, widget tests pass

---

## Phase 5: Settings Panel (Day 5)

### 5.1 Settings UI
- [ ] **Task**: Add "Manual Handle Links" section to settings panel
  - **File**: `lib/features/settings/presentation/view/settings_panel_view.dart`
  - **Details**: 
    - New expandable section
    - Header: "Manual Handle Links (X)"
    - List of all manual links
  - **Acceptance**: Section appears in settings

- [ ] **Task**: Create manual link list item widget
  - **Details**: 
    - Shows: handle identifier → participant name
    - Date created
    - Delete button (trash icon)
  - **Acceptance**: List items render correctly

- [ ] **Task**: Wire up delete action
  - **Details**: 
    - Call `ManualHandleLinkService.deleteLink(handleId)`
    - Show confirmation dialog first
    - Trigger index rebuild after deletion
    - Refresh list via provider invalidation
  - **Acceptance**: Delete removes link, UI updates

### 5.2 Integration Tests - Full Workflow
- [ ] **Task**: Test: End-to-end assignment flow
  - **File**: `test/features/contacts/integration/manual_linking_workflow_test.dart`
  - **Details**: 
    - Start with unmatched handle
    - Assign to participant via service
    - Verify appears in contact's messages
    - Verify appears in settings panel
    - Delete link
    - Verify removed from contact's messages
  - **Acceptance**: Full workflow completes successfully

- [ ] **Task**: Test: Multiple handles for one participant
  - **Details**: 
    - Create 3 manual links to same participant
    - Verify all appear in contact's messages
    - Verify all appear in settings panel
  - **Acceptance**: All links work independently

- [ ] **Task**: Test: Performance with many manual links
  - **Details**: Create 100 manual links, test UI responsiveness
  - **Acceptance**: No lag, list scrolls smoothly

**Phase 5 Complete When**: Settings panel working, integration tests pass

---

## Phase 6: Documentation & Polish (Day 5)

### 6.1 Documentation
- [ ] **Task**: Update overlay database extensions doc
  - **File**: `_AGENT_INSTRUCTIONS/agent-per-project/05-databases/overlay-database-extensions.md`
  - **Details**: Document `HandleToParticipantOverrides` table, usage, examples
  - **Acceptance**: Doc updated with new table

- [ ] **Task**: Update participant-handle architecture doc
  - **File**: `_AGENT_CONTEXT/09-participant-handle-architecture.md`
  - **Details**: Explain overlay merge logic, manual link priority
  - **Acceptance**: Architecture doc reflects new pattern

- [ ] **Task**: Create user-facing help article
  - **File**: `docs/features/manual-handle-linking.md`
  - **Details**: Screenshots, step-by-step guide, FAQ
  - **Acceptance**: Help article complete, clear instructions

### 6.2 Code Quality
- [ ] **Task**: Run `flutter analyze`
  - **Command**: `flutter analyze`
  - **Acceptance**: 0 errors, 0 warnings

- [ ] **Task**: Run `dart format`
  - **Command**: `dart format .`
  - **Acceptance**: All files formatted

- [ ] **Task**: Verify test coverage >80%
  - **Command**: `flutter test --coverage`
  - **Acceptance**: Coverage report shows >80% for new code

- [ ] **Task**: Run all tests
  - **Command**: `flutter test`
  - **Acceptance**: All tests pass

### 6.3 Final Testing
- [ ] **Task**: Manual test: Assign Rusung's old number
  - **Details**: 
    - Find old unmatched number in sidebar
    - Assign to Rusung Tan
    - Verify messages appear in "All Messages"
    - Verify timeline updated
  - **Acceptance**: Old messages now visible in Rusung's view

- [ ] **Task**: Manual test: Delete and re-assign
  - **Details**: 
    - Delete manual link from settings
    - Verify messages disappear
    - Re-assign same handle
    - Verify messages reappear
  - **Acceptance**: Delete/re-assign works correctly

- [ ] **Task**: Manual test: Migration persistence
  - **Details**: 
    - Create manual link
    - Trigger full database re-import
    - Verify manual link survives
  - **Acceptance**: Link persists after migration

**Phase 6 Complete When**: All tests pass, documentation complete, feature polished

---

## Definition of Done

**Feature is complete when**:
- [x] All checklist items marked complete (47/47)
- [x] All unit tests pass
- [x] All integration tests pass
- [x] All widget tests pass
- [x] Test coverage >80% for new code
- [x] `flutter analyze` returns 0 errors/warnings
- [x] Documentation updated (architecture docs, user guide)
- [x] Manual testing completed successfully
- [x] Feature works end-to-end with real data (Rusung test case)
- [x] Code reviewed and approved
- [x] Merged to main branch

---

## Notes & Decisions Log

**Decision Log**:
- 2025-11-01: Chose overlay database pattern (user preferences) over DDD aggregate approach
- 2025-11-01: Decided on partial index rebuild (per-participant) for performance

**Blockers**:
- None currently

**Questions**:
- Context menu component: TBD during implementation (check macos_ui capabilities)
- Badge icon design: TBD (user feedback on visual indicator preference)

---

## Progress Tracking

**Phase 1 - Database Layer**: 0/16 tasks (0%)
**Phase 2 - Migration Integration**: 0/6 tasks (0%)
**Phase 3 - Application Layer**: 0/8 tasks (0%)
**Phase 4 - UI Components**: 0/7 tasks (0%)
**Phase 5 - Settings Panel**: 0/6 tasks (0%)
**Phase 6 - Documentation & Polish**: 0/4 tasks (0%)

**Overall Progress**: 0/47 tasks (0%)

**Estimated Completion**: Day 5 (assuming 1 developer, full-time focus)

---

*Last Updated: 2025-11-01*
*Next Review: After Phase 1 completion*
