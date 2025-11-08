---
tier: feature
scope: test-plan
owner: agent-per-project
last_reviewed: 2025-11-07
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
feature: virtual-overlay-contacts
status: planning
created: 2025-11-07
last_updated: 2025-11-07
---

# Test Plan: Virtual Overlay Contacts

## Automated Coverage

### Overlay Database
- [ ] `virtual_participants` CRUD (create/get/delete) using in-memory overlay DB.
- [ ] ID band enforcement (`>= 1_000_000_000`) verified across multiple inserts.
- [ ] Short-name derivation edge cases (single token, multi token, emoji-only names).
- [ ] Foreign key cascade: deleting virtual participant removes linked overrides.

### Service Layer
- [ ] `ManualHandleLinkService.createVirtualParticipant` success path returns overlay ID and invalidates providers.
- [ ] Duplicate/blank name validation errors surface as `Failure`.
- [ ] Linking handles to virtual IDs stores mapping in overlay overrides only.
- [ ] Deleting virtual participant re-queues handles into unmatched provider output.

### Provider Layer
- [ ] `virtualParticipantsProvider` emits overlay rows sorted alphabetically.
- [ ] Participant merge providers include virtual entries with `origin == overlayVirtual`.
- [ ] Search filtering returns virtual contacts for matching queries.
- [ ] Regression: placeholder contacts remain filtered even with virtual participants present.

### UI Widgets
- [ ] Contact picker renders "New Contact…" option and triggers creation flow scaffold in widget test.
- [ ] `VirtualContactDialog` validates empty input and accepts valid names.
- [ ] Picker auto-selects newly created virtual contact (widget test with fake services).
- [ ] Golden test for virtual badge styling in picker and sidebar tiles.

### Integration
- [ ] End-to-end flow: create virtual contact → link handle → verify count in participant provider → delete virtual contact → ensure handle returns to unmatched list.
- [ ] Performance smoke: seed 200 virtual contacts, ensure merge provider resolves within expected threshold (mock clock or benchmark assertion).

## Manual QA Checklist

1. **Create Virtual Contact**
   - Open unmatched handle menu, pick "Assign to contact…".
   - Choose "New Contact…", enter name, confirm.
   - Verify picker now highlights new contact and assignment completes.

2. **Link Multiple Handles**
   - Create virtual contact, link two different handles.
   - Confirm both chats show updated contact name.

3. **Delete Virtual Contact**
   - Use settings overlay management UI to remove virtual contact.
   - Ensure linked handles return to unmatched list and chats fall back to raw handle display.

4. **Persistence Across Restart**
   - Create virtual contact and link handle.
   - Restart app (or re-run projection pipeline) and confirm virtual contact still present and linked handle resolved.

5. **Search & Picker Behaviour**
   - Search for virtual contact by name in picker and sidebar; ensure results show badge.
   - Confirm virtual contacts appear after real contacts in list ordering.

6. **Error Handling**
   - Attempt to create virtual contact with blank name; verify validation message.
   - Simulate overlay DB failure (override provider to throw) and confirm user sees error toast without crash.

## Tooling Commands

- `dart run build_runner build --delete-conflicting-outputs`
- `flutter test --plain-name "virtual contact"`
- `flutter test test/features/contacts/integration/virtual_contact_linking_test.dart`
- `flutter test --golden` (after updating golden references)
- `flutter analyze`

## Reporting

- Log automated test results in CI summary once implemented.
- Capture manual QA outcomes in `STATUS.md` before release, including any deviations or known issues.
