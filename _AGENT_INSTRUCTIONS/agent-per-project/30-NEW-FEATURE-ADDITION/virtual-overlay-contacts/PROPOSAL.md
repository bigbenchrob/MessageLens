---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2025-11-07
links:
  - ../../50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md
  - ../../10-DATABASES/05-db-overlay.md
  - ../../40-FEATURES/chat-handles/CHARTER.md
feature: virtual-overlay-contacts
status: proposed
created: 2025-11-07
---

# Feature Proposal: Virtual Overlay Contacts

## Overview

Introduce "virtual contacts" that live entirely inside `user_overlays.db` so users can link unmatched handles to meaningful identities even when no macOS AddressBook card exists. The feature extends the existing manual handle linking workflow by allowing the picker dialog to create a new overlay participant ("<New Contact…>") before applying the standard handle → participant assignment.

## Goals

- Provide a frictionless way to label unmatched handles without touching the system AddressBook.
- Keep virtual contacts scoped to Remember Every Text, stored in overlay data that survives migrations.
- Ensure virtual contacts behave like regular participants everywhere the UI expects contact metadata.

## Non-Goals

- Sync virtual contacts back to macOS AddressBook.
- Support rich contact fields (avatars, notes, multi-field editing) in v1. Name + stable ID is sufficient.
- Replace the existing manual handle linking flow; this augments it.

## High-Level Flow

1. User selects "Assign to contact…" on an unmatched handle.
2. Picker shows existing participants plus a trailing option "Create new contact".
3. Choosing the new-contact option opens a lightweight dialog: name input + confirm.
4. System creates a virtual participant row inside overlay DB, generates a stable overlay participant ID, and reopens/continues the picker preselecting that contact.
5. Existing linking logic assigns the handle to the newly created participant, performs partial index rebuild, invalidates providers.

## Architecture Plan

-### Data Layer

- **Overlay Schema Update**: Introduce dedicated `virtual_participants` table inside `user_overlays.db` storing:
  - `id` (primary key within overlay namespace)
  - `display_name`, `short_name`, optional `notes`, timestamp columns
  - metadata required for provider merges (no working DB linkage)
- **Working Projection**: We do **not** mutate `working.participants`. Instead, we surface virtual contacts via merged providers and dynamic view models.
- **Identifier Strategy**:
  - Allocate integer IDs from reserved overlay band (`>= 1_000_000_000`) so they never collide with AddressBook Z_PK values (positive but below band).
  - Extend merged provider to map overlay participant IDs to virtual contact POJOs consumed by UI.

### Provider Layer

- Add `overlayVirtualParticipantsProvider` returning overlay-defined participants.
- Update any provider that presents contact lists (sidebar contacts, picker, manual link UI) to merge:
  1. `working.participants` (real contacts)
  2. overlay overrides for real contacts (existing)
  3. overlay virtual contacts (new namespace)
- Shared view model should expose flags (`isVirtual`, `source`) so UI can decorate entries.
- Ensure manual link service resolves participant references correctly regardless of origin.

### Application / Services

- Extend `ManualHandleLinkService` (or dedicated service) with:
  - `Future<int> createVirtualParticipant({required String displayName})`
  - Derived short name generation (initials, trimmed string).
- After creation, service updates overlay DB, invalidates participant providers, and returns overlay participant ID for immediate linking.

### UI / UX

- **Picker Menu**: Insert `---` separator and "New Contact…" action at bottom of list.
- **New Contact Dialog**: Minimal form (name + optional label). Validate non-empty input.
- **Indicators**: Show badge/icon for virtual contacts in picker and contact list (e.g., "Overlay" tag).
- **Management UI**: Reuse existing overlay management page to list/delete virtual contacts (v1 optional but desirable for cleanup).

### Index & Linking

- Virtual contact IDs never appear in `working.contact_message_index`. Instead, when linking a handle to a virtual contact we:
  - Store the association in overlay linking table with the virtual participant ID.
  - Create synthetic projections when fetching messages (providers combine handle → participant mapping; virtual participants resolved during merge).
  - Extend partial index rebuild to treat virtual participant IDs by writing overlay-backed rows into a lightweight secondary table or by retrieving handle IDs dynamically during query (decision below).

## Key Decisions & Open Questions

| Topic | Decision | Notes |
| --- | --- | --- |
| Virtual participant storage | ✅ Dedicated `virtual_participants` table in overlay DB | Keeps overrides table focused on augmenting real participants. |
| ID namespace | ✅ Integer band `>= 1_000_000_000` generated via overlay helper | Matches provider expectations for `int` IDs while avoiding collisions. |
| Contact picker ordering | Place virtual contacts after real contacts with visual divider | Maintains primary focus on real AddressBook entries. |
| Index strategy | Option A: extend providers to map virtual participant IDs at query time (no schema changes). Option B: maintain overlay `virtual_contact_message_index` for fast lookup. | Need spike to estimate performance impact before committing. |
| Delete handling | Removing virtual contact should cascade to manual handle links | Enforce via overlay DB foreign keys & service logic. |
| Search | Picker search should include virtual contacts (case insensitive) | Implement within merged provider. |

## Dependencies & Impacted Areas

- `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
- `lib/features/contacts/application/manual_handle_link_service.dart`
- `lib/features/contacts/application/participants_for_picker_provider.dart`
- `lib/features/contacts/presentation/contact_picker_dialog.dart`
- `lib/features/unmatched/application/*` for provider invalidation
- `_AGENT_INSTRUCTIONS/agent-per-project/05-databases/05-db-overlay.md` (documentation update)

## Risks

- **Data Integrity**: overlay participant IDs must remain stable; mitigation via migrations + test coverage.
- **Provider Complexity**: merging three participant sources could degrade performance; mitigate with caching layers and targeted invalidation.
- **UX Confusion**: virtual contacts might be indistinguishable from real contacts; plan for clear labeling.

## Next Steps

1. Draft checklist (CHECKLIST.md) covering migrations, providers, UI updates, tests, docs.
2. Create design notes detailing provider merging and index handling.
3. Validate approach with a small spike: create virtual contact, link handle, verify provider outputs.

Once the proposal is approved, we will produce the full checklist and supporting docs per the 30-NEW-FEATURE-ADDITION workflow.
