# Phase 2 — Stray Handle Review: Sidebar List + Handle Lens

> **Status:** Not started
> **Depends on:** Phase 1 (schema, providers, virtual participants working)
> **Blocks:** Phase 3

## Objective

Give users a way to browse unlinked handles, peek at their messages for identification, and take action: link to a new virtual participant, link to an existing contact, or dismiss.

## Scope

### 1. Sidebar — StrayHandlesSpec Cassette

- New `StrayHandlesSpec` added to sidebar cassette system.
- Flat list sourced from `strayHandlesProvider` (Phase 1).
- **Row contents:** Formatted handle value, message count, most recent message date.
- **Sort order:** Message count descending (most messages first), with ties broken by recency.
- Tapping a row opens the Handle Lens in the center panel.
- Reviewed-but-unlinked handles (`reviewed_at` set, no link): visually muted but still present.

### 2. Handle Lens — Center Panel ViewSpec

New `HandleLensSpec` ViewSpec for the center panel.

#### Layout
- **Header:** Formatted handle value (phone number or email).
- **Action bar:** Three buttons (see below).
- **Message list:** Scrollable, bare-minimum rendering.

#### Message List
- Timestamp + text body per message, newest first.
- No avatars, no chat bubbles, no heatmap, no search.
- Pagination or lazy loading for handles with many messages.
- Purpose: give the user just enough context to identify the sender.

#### Action Buttons

**"Create Contact"**
1. Opens an inline mini-form: single text field for display name.
2. On submit: creates `virtual_participant` in overlay DB, writes `handle_to_participant_overrides` row linking handle → virtual participant.
3. Navigates to the new virtual participant's standard contact view (heatmap, etc.).
4. `strayHandlesProvider` invalidates automatically.

**"Link to Existing Contact"**
1. Opens the standard contact picker.
2. On selection: writes `handle_to_participant_overrides` row linking handle → selected participant.
3. Navigates to that contact's standard view.
4. `strayHandlesProvider` invalidates automatically.

**"Dismiss / Skip"**
1. Sets `reviewed_at` on the handle's override row (creates one if needed, with both participant IDs null).
2. Returns focus to the sidebar stray handle list.
3. The handle remains in the list but is visually muted.

### 3. Navigation Wiring

- `StrayHandlesSpec` cassette registered in sidebar navigation.
- `HandleLensSpec` ViewSpec registered for center panel.
- Coordinator routes between sidebar selection and center panel display.

## Out of Scope

- Rich message rendering (bubbles, avatars, reactions) — "link it or forget it"
- Message search within Handle Lens
- Heatmap for unlinked handles
- Bulk operations (Phase 3)
- Stray handle count badge on cassette (Phase 3)
- Suggested matches / fuzzy matching (Phase 3)

## Key Risks

| Risk | Mitigation |
|---|---|
| Message list performance for high-volume handles | Lazy loading / pagination; cap initial display at ~50 messages |
| Picker reuse complexity | Leverage existing picker with standard selection callback |
| Navigation state on link/dismiss | Clear center panel and return to sidebar list on action completion |

## Exit Criteria

- [ ] StrayHandlesSpec cassette appears in sidebar
- [ ] Sidebar list shows unlinked handles with message count and recency
- [ ] Tapping a handle opens Handle Lens in center panel
- [ ] Handle Lens shows message previews (timestamp + body)
- [ ] "Create Contact" creates virtual participant and links handle
- [ ] "Link to Existing Contact" opens picker and links handle
- [ ] "Dismiss" sets reviewed_at and mutes the handle in the list
- [ ] After link, user navigates to contact's standard view
- [ ] After link, handle disappears from stray list
- [ ] All Phase 1 tests still pass
- [ ] `flutter analyze` clean
