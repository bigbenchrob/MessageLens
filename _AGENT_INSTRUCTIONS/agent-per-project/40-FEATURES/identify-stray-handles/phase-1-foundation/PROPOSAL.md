# Phase 1 — Foundation: Overlay Schema + Virtual Participants

> **Status:** Not started
> **Depends on:** None (first phase)
> **Blocks:** Phase 2

## Objective

Establish the overlay-DB schema for virtual participants and handle overrides, then wire merged providers so virtual participants are indistinguishable from real contacts throughout the app.

## Scope

### 1. Overlay Schema Bump

Bump overlay DB schema version. Add two new tables:

#### `virtual_participants`
```sql
CREATE TABLE virtual_participants (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  display_name     TEXT    NOT NULL,
  created_at       TEXT    NOT NULL,  -- ISO 8601
  updated_at       TEXT
);
```

#### `handle_to_participant_overrides`
```sql
CREATE TABLE handle_to_participant_overrides (
  handle_id                INTEGER PRIMARY KEY,  -- FK to working-DB handle
  participant_id           INTEGER,               -- FK to working-DB participant (real contact)
  virtual_participant_id   INTEGER,               -- FK to virtual_participants.id
  reviewed_at              TEXT,
  CHECK (
    (participant_id IS NOT NULL AND virtual_participant_id IS NULL)
    OR
    (participant_id IS NULL AND virtual_participant_id IS NOT NULL)
    OR
    (participant_id IS NULL AND virtual_participant_id IS NULL)  -- reviewed but unlinked
  )
);
```

The CHECK constraint ensures at most one link target. A row with both NULL means "reviewed but not linked" (the dismiss case).

### 2. Drift Table Definitions

Create Drift table classes in the overlay database layer:
- `VirtualParticipantsTable`
- `HandleToParticipantOverridesTable`

Add them to the overlay database class and run code generation.

### 3. Repository Layer

- `VirtualParticipantRepository` — CRUD for virtual participants in overlay DB.
- `HandleOverrideRepository` — CRUD for handle-to-participant overrides in overlay DB.

### 4. Merged Provider: `allParticipantsProvider`

A provider that unions:
- Working-DB participants (from address book import)
- Overlay-DB virtual participants

Returns a unified list. Overlay wins on conflict (per inviolable rule). All downstream consumers (picker, hero card, heatmap, message views) watch this provider instead of the working-DB-only version.

### 5. Stray Handles Provider: `strayHandlesProvider`

Returns handles from working DB that have:
- No participant link in the working-DB `handle_to_participant` table, AND
- No override row in overlay-DB `handle_to_participant_overrides`

This list drives the Phase 2 sidebar.

### 6. Prerequisite Cleanup

- **Audit `ManualHandleLinkService`:** Currently dual-writes to overlay AND working DB. Refactor to overlay-only writes via `handle_to_participant_overrides`.
- **Audit `is_blacklisted` writes:** Ensure none target working DB.

## Out of Scope

- Sidebar UI for browsing stray handles (Phase 2)
- Handle Lens center panel (Phase 2)
- Bulk operations (Phase 3)
- Wiring `is_ignored`, `is_blacklisted`, `is_visible` — left inert

## Key Risks

| Risk | Mitigation |
|---|---|
| allParticipantsProvider breaks existing contact flows | Incremental: first add the merge provider, then migrate consumers one at a time with tests |
| ManualHandleLinkService refactor disrupts existing manual links | Write a one-time migration that copies existing working-DB manual links into overlay overrides |
| Schema bump breaks existing overlay DBs | Standard Drift migration with version check |

## Exit Criteria

- [ ] Overlay DB schema includes both new tables
- [ ] Drift code generation passes
- [ ] VirtualParticipantRepository can create, read, update, delete virtual participants
- [ ] HandleOverrideRepository can create, read, delete overrides
- [ ] allParticipantsProvider returns merged list (working + overlay)
- [ ] A virtual participant appears in the contact picker
- [ ] Selecting a virtual participant in the picker shows messages from linked handles in the heatmap
- [ ] strayHandlesProvider returns correct unlinked handles
- [ ] ManualHandleLinkService writes only to overlay DB
- [ ] All existing tests pass
- [ ] flutter analyze clean
