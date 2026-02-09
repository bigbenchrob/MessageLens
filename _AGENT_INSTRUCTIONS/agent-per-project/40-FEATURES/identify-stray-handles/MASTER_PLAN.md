# Identify Stray Handles — Master Plan

> **Branch:** `Ftr.stray`
> **Status:** Phase 1 — in planning
> **Last updated:** 2026-02-09

## Problem

After importing macOS Messages data, many handles (phone numbers, email addresses) have no link to an AddressBook contact. These "stray handles" represent real communication partners the user knows — banks, businesses, friends with changed numbers, group-chat participants — but they are invisible in the contact-centric UI.

## Goal

Give users a way to:
1. **Browse** unlinked handles sorted by relevance (message count / recency).
2. **Identify** the sender by peeking at recent messages.
3. **Link** the handle to a new *virtual participant* or an existing contact.
4. **Dismiss** handles they don't care about.

Once linked, a virtual participant is **indistinguishable** from an AddressBook contact throughout the entire app — picker, heatmap, message views, search.

## Guiding Principles

| Principle | Detail |
|---|---|
| **Overlay / working separation** | Inviolable. Virtual participants and handle overrides live in overlay DB only. Migration never consults overlay. Providers merge both DBs; overlay wins on conflict. |
| **Virtual participant parity** | Once created, a virtual participant flows through every provider and UI surface exactly like a real contact. A subtle badge may distinguish them visually, but functionally they are peers. |
| **Handle Lens is utilitarian** | Its sole purpose is identification → action. Bare message list + action buttons. No heatmap, no search, no rich rendering. "Link it or forget it." |
| **is_ignored / is_blacklisted / is_visible** | Inert for now. Left in schema but not wired. May be used during import later, or dropped. |
| **reviewed_at** | Auto-set when the user opens a handle in the Lens. Semantics deferred to Phase 3. |

---

## Phase 1 — Foundation: Overlay Schema + Virtual Participants

**Goal:** Virtual participants exist and are indistinguishable from real contacts throughout the app.

### Overlay DB changes (schema bump)

- **`virtual_participants`** table:
  - `id INTEGER PRIMARY KEY AUTOINCREMENT`
  - `display_name TEXT NOT NULL`
  - `created_at TEXT NOT NULL` (ISO 8601)
  - `updated_at TEXT`

- **`handle_to_participant_overrides`** table:
  - `handle_id INTEGER PRIMARY KEY` (references working-DB handle)
  - `participant_id INTEGER` (references working-DB participant — for linking to real contacts)
  - `virtual_participant_id INTEGER` (references overlay virtual_participants.id)
  - `reviewed_at TEXT`
  - **Constraint:** exactly one of `participant_id` / `virtual_participant_id` is non-null.

- Existing `is_ignored`, `is_blacklisted`, `is_visible` columns: left inert, not wired.

### Provider layer

- **`allParticipantsProvider`** — unions working-DB participants + overlay-DB virtual participants into a single stream. Overlay wins on conflict (per inviolable rule).
- Contact picker, hero card, heatmap, message views all consume this merged provider. Virtual participants get the same treatment as real ones.
- **`strayHandlesProvider`** — returns handles that have no participant link in *either* DB (working join miss + no overlay override). Drives sidebar list in Phase 2.

### Prerequisite cleanup

- Audit `ManualHandleLinkService` dual-write → refactor to overlay-only writes.
- Ensure no code writes `is_blacklisted` to working DB.

### Exit criteria

A virtual participant created in the overlay DB appears in the contact picker and, when selected, shows messages from all linked handles via the standard heatmap view.

### Docs

- [Phase 1 Proposal](phase-1-foundation/PROPOSAL.md)
- [Phase 1 Checklist](phase-1-foundation/CHECKLIST.md)

---

## Phase 2 — Stray Handle Review: Sidebar List + Handle Lens

**Goal:** User can browse unlinked handles, peek at messages, and take action.

### Sidebar (CassetteSpec)

- New `StrayHandlesSpec` cassette in the sidebar.
- Flat list of handles with no participant link, sorted by message count (most messages first) or recency.
- Each row: formatted handle value, message count, most recent message date.
- Tapping a handle opens the Handle Lens in the center panel.

### Handle Lens (center panel ViewSpec)

- Utilitarian layout: handle value at top, action buttons, scrollable message list below.
- Message list: bare-minimum rendering — timestamp + text body, newest first. No avatars, no bubbles, no heatmap.
- **Action buttons:**
  - **"Create Contact"** — mini-form (name field), creates a `virtual_participant` in overlay, links handle via `handle_to_participant_overrides`. Navigates to new contact's standard view.
  - **"Link to Existing Contact"** — opens contact picker. On selection, writes `handle_to_participant_overrides` row. Navigates to that contact's view.
  - **"Dismiss / Skip"** — sets `reviewed_at`, returns to sidebar list. Handle stays in list but visually muted.
- On any action, `strayHandlesProvider` auto-invalidates (handle now has a link or reviewed_at).

### Exit criteria

User can browse stray handles, identify them via message previews, and either link to new/existing contact or dismiss. Linked handles immediately integrate into the standard contact experience.

### Docs

- [Phase 2 Proposal](phase-2-sidebar-and-lens/PROPOSAL.md)
- [Phase 2 Checklist](phase-2-sidebar-and-lens/CHECKLIST.md)

---

## Phase 3 — Polish & Bulk Operations (deferred)

**Goal:** Quality-of-life improvements once the core flow is proven.

- Bulk "dismiss all" for handles with < N messages.
- Bulk spam quarantine (if `is_blacklisted` becomes useful).
- Stray handle count badge on the sidebar cassette.
- "Suggested matches" — fuzzy matching of handle values against existing contact phone/email fields.
- Sorting / filtering options on the stray handle list.
- Refinements to `reviewed_at` semantics.

### Docs

- [Phase 3 Proposal](phase-3-polish/PROPOSAL.md)

---

## Cross-Cutting Decisions

| Decision | Resolution | Date |
|---|---|---|
| is_ignored / is_blacklisted / is_visible | Inert; not wired. May use during import later or drop. | 2026-02-09 |
| Virtual participant parity | Indistinguishable from real contacts at provider + UI level | 2026-02-09 |
| Handle Lens scope | Identification-only; bare message list + action buttons | 2026-02-09 |
| Unlinked handle display | Zero investment — "link it or forget it" | 2026-02-09 |
| reviewed_at | Auto-set on Lens open; semantics deferred | 2026-02-09 |
| Overlay / working separation | Inviolable; documented in 3 agent surfaces | 2026-02-09 |
| ManualHandleLinkService dual-write | Must refactor to overlay-only in Phase 1 | 2026-02-09 |
