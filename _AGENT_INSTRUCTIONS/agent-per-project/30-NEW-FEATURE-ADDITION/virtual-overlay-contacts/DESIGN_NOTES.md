---
tier: feature
scope: design-notes
owner: agent-per-project
last_reviewed: 2025-11-07
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../../10-DATABASES/05-db-overlay.md
  - ../../50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md
feature: virtual-overlay-contacts
status: planning
created: 2025-11-07
last_updated: 2025-11-07
---

# Design Notes: Virtual Overlay Contacts

## Overlay Data Model

- Create a dedicated `virtual_participants` table inside `user_overlays.db` with columns:
  - `id INTEGER PRIMARY KEY` (overlay namespace, see ID band below)
  - `display_name TEXT NOT NULL`
  - `short_name TEXT NOT NULL`
  - `notes TEXT NULL`
  - `created_at_utc TEXT NOT NULL`
  - `updated_at_utc TEXT NOT NULL`
- Enforce `CHECK(id >= 1000000000)` so overlay IDs cannot collide with AddressBook Z_PK values.
- Add foreign key relations from `handle_to_participant_overrides` to `virtual_participants(id)` with `ON DELETE CASCADE` once linking logic is updated to store overlay origins.

## ID Generation Strategy

- Introduce `VirtualParticipantIdGenerator` helper in overlay database layer.
- On initialisation, seed a persistent counter in `app_settings` (key `virtual_participant_id_counter`).
- For each new virtual participant:
  1. Start a transaction.
  2. Read current counter (default `999999999`).
  3. Increment and persist.
  4. Use resulting value (`>= 1000000000`) as new `id`.
- This avoids gaps when transactions roll back and keeps IDs monotonic.

## Short Name Derivation

- Reuse existing name utilities (`display_name_utils.dart`) to produce initials.
- Fallback order:
  1. Initials of first two non-empty tokens.
  2. First two characters of trimmed name.
  3. Default `'?'` when name sanitises to empty.
- Store derived `short_name` with the row to keep providers simple.

## Provider Merge Model

- Introduce `ParticipantOrigin` enum (`working`, `overlayOverride`, `overlayVirtual`).
- Update participant DTO used by picker/sidebar/search to include:
  - `id`
  - `displayName`
  - `shortName`
  - `origin`
  - `handleCount`
  - `isVirtual => origin == ParticipantOrigin.overlayVirtual`
- Merge order inside providers:
  1. Working participants (sorted alphabetically).
  2. Overlay overrides applied on top of matching working participants (mutate metadata in-place).
  3. Virtual participants appended with separator styling handled at presentation layer.
- Search providers should combine sources before filtering to support virtual participants in results.

## Service Responsibilities

- `ManualHandleLinkService.createVirtualParticipant`:
  - Validate display name (`trim().isNotEmpty`, length ≤ 120 chars).
  - Insert into overlay database via new DAO.
  - Invalidate `virtualParticipantsProvider` and combined participant providers.
  - Return assigned overlay ID.
- `ManualHandleLinkService.linkHandleToParticipant`:
  - Accept overlay IDs without writing to `working.handle_to_participant`.
  - Persist mapping exclusively in overlay override table with new `origin` flag.
  - Trigger `rebuildContactMessageIndexForParticipant` only for working IDs; virtual participants rely on overlay join logic.
- `ManualHandleLinkService.deleteVirtualParticipant` (new helper):
  - Delete virtual participant row.
  - Remove associated handle overrides (cascade).
  - Invalidate unmatched handle providers so handles reappear.

## Query Layer Adjustments

- Extend overlay repository to expose virtual participants via typed converter (`OverlayVirtualParticipantDto`).
- Update message projection providers to join overlay handle overrides and resolve virtual participants at read time:
  - For working participant IDs: existing flow unchanged.
  - For virtual participant IDs: join `handle_to_participant_overrides` → `virtual_participants` → build presenter models.
- Ensure timeline queries honour virtual contacts by filtering using overlay mappings when `contactId >= 1000000000`.

## UI Integration

- Contact picker:
  - Append "New Contact…" action row with keyboard shortcut (`Command+N`).
  - On selection, open `VirtualContactDialog` without closing picker; resume with newly created contact preselected.
  - Display badge (`MacosTag`) for `isVirtual` entries.
- Contacts sidebar/search results:
  - Use same badge pattern.
  - Virtual contacts sorted after real contacts but before unmatched handle placeholders.
- Settings overlay management:
  - New section listing virtual contacts with delete action.
  - Confirmation dialog before deletion summarising linked handles.

## Index & Performance Considerations

- Avoid writing virtual contacts into `contact_message_index`; instead, resolve overlays during fetch.
- Partial index rebuild remains untouched; overlay-only mappings bypass rebuild by keeping relationships in overlay DB.
- Add cache layer for merged participant provider to prevent excessive recomputation when overlay list small but handle updates frequent.

## Telemetry & Logging

- Add lightweight analytics hook (internal logger) when users create/delete virtual contacts.
- Include overlay ID and handle count in debug logs to aid troubleshooting.

## Open Questions

1. Should we surface virtual contacts in chat participant chips immediately, or defer until after release feedback?
2. Do we require an audit log for virtual contact edits? (Current assumption: not needed for v1.)
3. Confirm max supported virtual contacts (target 500) to size provider caches appropriately.
