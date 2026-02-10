---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2025-11-07
links:
  - ./PROPOSAL.md
  - ../../10-DATABASES/05-db-overlay.md
  - ../../50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md
feature: virtual-overlay-contacts
status: planning
created: 2025-11-07
last_updated: 2025-11-07
---

# Development Checklist: Virtual Overlay Contacts

**Feature Status**: 🔴 Not Started

**Progress**: 18/41 tasks complete (44%)

---

## Phase 1: Overlay Schema & Drift Plumbing

### 1.1 Schema Definition
- [x] **Task**: Add `VirtualParticipants` table to overlay database schema
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**:
    - Columns: `id` (INTEGER PRIMARY KEY), `display_name`, `short_name`, `created_at_utc`, `updated_at_utc`, `notes` (nullable)
    - Apply CHECK to require `id >= 1000000000` (dedicated overlay ID band)
    - Configure `id` to auto-generate via `VirtualParticipantIdGenerator` helper (see Task 1.2)
  - **Acceptance**: Table compiles and appears in generated `.g.dart`

- [x] **Task**: Introduce `VirtualParticipantIdGenerator`
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**:
    - Create helper ensuring first auto-generated ID seeds to `1_000_000_000`
    - Wrap in transaction-safe method invoked before first insert
  - **Acceptance**: Unit test confirms ID range starts at `>= 1_000_000_000`

- [x] **Task**: Bump overlay database `schemaVersion`
  - **File**: Same as above
  - **Details**: Increment schema version and add migration guard clause
  - **Acceptance**: Migration strategy handles upgrade

### 1.2 Drift Helpers
- [x] **Task**: Add DAO method `createVirtualParticipant`
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**:
    - Accepts `displayName` and optional `notes`
    - Generates `short_name` via shared helper (initials fallback)
    - Returns inserted row as Drift data class
  - **Acceptance**: Method compiles and returns data class

- [x] **Task**: Add DAO method `getVirtualParticipants`
  - **Details**: Fetch all rows ordered by `display_name`
  - **Acceptance**: Returns empty list when none exist

- [x] **Task**: Add DAO method `deleteVirtualParticipant(int id)`
  - **Details**: Remove row and cascade deletes in dependent tables (see Task 5.2)
  - **Acceptance**: Returns count of deleted rows

### 1.3 Tests
- [x] **Task**: Create overlay virtual participants test suite
  - **File**: `test/essentials/db/infrastructure/data_sources/local/overlay/virtual_participants_dao_test.dart`
  - **Details**: In-memory overlay DB, covers CRUD operations
  - **Acceptance**: Test suite passes

- [x] **Task**: Test ID band enforcement
  - **Details**: Insert multiple participants, ensure IDs monotonically increase and stay `>= 1_000_000_000`
  - **Acceptance**: Assertions verified

- [x] **Task**: Test short name generation
  - **Details**: Validate initials/fallback logic for single-word and multi-word names
  - **Acceptance**: Returns expected short names

---

## Phase 2: Application Services & Providers

### 2.1 Service Layer
- [x] **Task**: Extend `ManualHandleLinkService` with virtual participant creation API
  - **File**: `lib/features/contacts/application/manual_handle_link_service.dart`
  - **Details**:
    - Add method `Future<int> createVirtualParticipant({required String displayName, String? notes})`
    - Method writes to overlay DB and returns new virtual participant ID
  - **Acceptance**: Method covered by tests and returns overlay ID

- [x] **Task**: Add error handling for duplicate names
  - **Details**: Allow duplicates but log warning; return failure if normalized name empty
  - **Acceptance**: Service returns `Failure` when validation fails

- [x] **Task**: Introduce `virtualParticipantsProvider`
  - **File**: `lib/features/contacts/application/virtual_participants_provider.dart`
  - **Details**: `@riverpod` async provider fetching overlay virtual participants list
  - **Acceptance**: Provider compiles and covered by tests

### 2.2 Tests
- [x] **Task**: Add service unit tests for virtual participant creation/deletion
  - **File**: `test/features/contacts/application/manual_handle_link_service_virtual_participants_test.dart`
  - **Acceptance**: Tests pass, verifying happy path and validation failures

- [x] **Task**: Add provider tests
  - **File**: `test/features/contacts/application/virtual_participants_provider_test.dart`
  - **Acceptance**: Provider emits expected data after inserts/deletes

---

## Phase 3: Participant Merge & Query Layer

### 3.1 Shared View Models
- [x] **Task**: Update `participants_for_picker_provider.dart`
  - **File**: `lib/features/contacts/application/participants_for_picker_provider.dart`
  - **Details**:
    - Merge working participants, overlay overrides, and new virtual participants
    - Extend DTO with `isVirtual` flag and `source` enum (`working`, `overlay_override`, `overlay_virtual`)
    - Preserve sorting (virtual contacts grouped beneath real participants)
  - **Acceptance**: Provider returns combined list with new metadata

- [ ] **Task**: Update contact list providers (sidebar, search) to include virtual participants
  - **Files**: `lib/features/contacts/application/participants_for_sidebar_provider.dart`, `lib/features/contacts/application/participants_search_provider.dart`
  - **Details**: Ensure each merged provider handles virtual entries and respects origin flag
  - **Acceptance**: UI consumers receive merged data without regressions

### 3.2 Query Utilities
- [x] **Task**: Introduce `ParticipantOrigin` enum in shared location
  - **File**: `lib/features/contacts/domain/participant_origin.dart`
  - **Details**: Values `working`, `overlayOverride`, `overlayVirtual`
  - **Acceptance**: Enum reused across DTOs/providers

- [x] **Task**: Add mapping helpers in overlay repository layer
  - **File**: `lib/features/contacts/infrastructure/repositories/overlay_participants_repository.dart`
  - **Details**: Provide typed conversion from Drift row to domain DTO
  - **Acceptance**: Helpers reused by all providers

### 3.3 Tests
- [x] **Task**: Provider merge tests
  - **File**: `test/features/contacts/application/participants_merge_test.dart`
  - **Details**: Validate ordering, deduplication, virtual flag propagation
  - **Acceptance**: Tests pass

- [ ] **Task**: Regression test for placeholder contacts filtering
  - **Details**: Ensure virtual participants do not regress manual migrator filtering
  - **Acceptance**: Test passes, referencing participant migrator cases

---

## Phase 4: UI & UX Flow

### 4.1 Contact Picker
- [ ] **Task**: Add "New Contact…" option to contact picker list
  - **File**: `lib/features/contacts/presentation/widgets/contact_picker_dialog.dart`
  - **Details**:
    - Insert separator and trailing action row
    - Trigger dedicated creation flow when selected
  - **Acceptance**: Option appears and reacts to selection

- [ ] **Task**: Create `VirtualContactDialog`
  - **File**: `lib/features/contacts/presentation/widgets/virtual_contact_dialog.dart`
  - **Details**:
    - Form with `displayName` field, optional notes
    - Validation: non-empty trimmed name, 64 char limit
    - Returns confirmed name or null
  - **Acceptance**: Dialog reusable and tested

- [ ] **Task**: Integrate creation flow with picker
  - **Details**:
    - When user confirms new name, call service to create virtual participant
    - Refresh picker list, auto-select new contact, keep dialog open for assignment
  - **Acceptance**: End-to-end flow completes without closing picker prematurely

### 4.2 Visual Treatment
- [ ] **Task**: Add virtual badge to contact list entries
  - **Files**: `lib/features/contacts/presentation/widgets/contact_picker_tile.dart`, `lib/features/contacts/presentation/view/contacts_sidebar_view.dart`
  - **Details**: Display subtle "Overlay" tag or icon for virtual contacts
  - **Acceptance**: Badge renders with macOS-friendly styling

- [ ] **Task**: Provide delete affordance in overlay management UI
  - **File**: `lib/features/settings/presentation/view/overlay_contacts_section.dart`
  - **Details**: List virtual contacts with delete button (trash)
  - **Acceptance**: Deletion updates UI and data store

### 4.3 UI Tests
- [ ] **Task**: Widget test for new contact creation flow
  - **File**: `test/features/contacts/presentation/widgets/contact_picker_dialog_virtual_contact_test.dart`
  - **Acceptance**: Test covers creation, selection, cancellation

- [ ] **Task**: Golden test for virtual badge styling
  - **File**: `test/features/contacts/presentation/golden/virtual_contact_badge_test.dart`
  - **Acceptance**: Golden updated and committed

---

## Phase 5: Linking & Index Integration

### 5.1 Handle Linking
- [ ] **Task**: Update `ManualHandleLinkService.linkHandleToParticipant`
  - **File**: `lib/features/contacts/application/manual_handle_link_service.dart`
  - **Details**:
    - Accept overlay virtual IDs (>= 1_000_000_000)
    - Skip working DB foreign key enforcement by persisting mapping solely in overlay table when origin is virtual
    - Ensure participant origin travels through result DTO for UI refresh
  - **Acceptance**: Linking succeeds for virtual contacts, existing flow unchanged

- [ ] **Task**: Mirror overlay-only mapping in working projections
  - **File**: `lib/features/contacts/application/contact_messages_projection_provider.dart`
  - **Details**: When retrieving messages for virtual contact, hydrate via overlay mapping without writing to working DB
  - **Acceptance**: Messages appear in virtual contact view

### 5.2 Cascading Deletes
- [ ] **Task**: Implement cascade removal when virtual contact deleted
  - **File**: `lib/features/contacts/application/manual_handle_link_service.dart`
  - **Details**: Remove handle links, invalidate indices/providers, update unmatched lists
  - **Acceptance**: Deleting virtual contact reverts linked handles to unmatched state

- [ ] **Task**: Update overlay schema to enforce cascades
  - **File**: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
  - **Details**: Add foreign key constraints between `virtual_participants` and handle linking tables
  - **Acceptance**: Drift migration enforces cascades; tests confirm behavior

### 5.3 Tests
- [ ] **Task**: Integration test for virtual contact linking
  - **File**: `test/features/contacts/integration/virtual_contact_linking_test.dart`
  - **Acceptance**: Flow: create virtual contact → link handle → verify projection → delete contact → verify unlink

- [ ] **Task**: Performance smoke test
  - **Details**: Bulk-create 200 virtual contacts, ensure provider performance acceptable (<100ms query)
  - **Acceptance**: Test or benchmark logged with results

---

## Phase 6: Documentation, QA, and Wrap-up

### 6.1 Documentation
- [ ] **Task**: Update overlay database doc with `virtual_participants` table
  - **File**: `_AGENT_INSTRUCTIONS/agent-per-project/10-DATABASES/05-db-overlay.md`
  - **Acceptance**: Table documented with usage rules

- [ ] **Task**: Add feature design notes
  - **File**: `./DESIGN_NOTES.md`
  - **Details**: Document provider merge strategy, ID namespace decision
  - **Acceptance**: Notes committed alongside code

- [ ] **Task**: Draft test plan
  - **File**: `./TESTS.md`
  - **Details**: Outline automated + manual validation steps
  - **Acceptance**: Test plan ready before implementation starts

- [ ] **Task**: Update manual linking use-case doc
  - **File**: `_AGENT_INSTRUCTIONS/agent-per-project/50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md`
  - **Details**: Describe virtual contact branch in workflow
  - **Acceptance**: Doc reflects new UX

### 6.2 QA & Verification
- [ ] **Task**: Run `dart run build_runner build --delete-conflicting-outputs`
  - **Acceptance**: Generated files up-to-date

- [ ] **Task**: Run `flutter analyze`
  - **Acceptance**: 0 warnings/errors

- [ ] **Task**: Execute targeted test suite (`flutter test --plain-name "virtual contact"`)
  - **Acceptance**: All relevant tests pass

- [ ] **Task**: Manual QA script
  - **Details**: Validate creation, linking, deletion, and persistence across app restart
  - **Acceptance**: Log results in `./STATUS.md` when ready

- [ ] **Task**: Record known limitations in STATUS.md
  - **Details**: Capture any deferred work or UX debt
  - **Acceptance**: STATUS.md prepared before shipping

---

## Definition of Done

Feature is complete when:
- [ ] All checklist items marked complete (41/41)
- [ ] Automated tests added and passing
- [ ] Documentation updated (overlay DB, use-case walkthrough)
- [ ] Manual QA scenarios captured in STATUS.md
- [ ] Code merged to `main` with review approval

---

*Next update due after Phase 1 tasks begin.*
