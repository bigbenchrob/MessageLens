---
tier: project
scope: feature-checklist
owner: agent-per-project
last_reviewed: 2025-11-11
source_of_truth: doc
status: in_progress
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Contact Picker Refactor Checklist

## Phase 0 – Preconditions

- [ ] Confirm that the flat **Contacts dropdown** is no longer required in any view.
- [ ] Confirm that the grouped contact picker is working and wired to load chats correctly.

## Phase 1 – UI Cleanup (no layout changes)

**Objective:** Remove redundant UI and make the grouped picker the only selector.

- [ ] Keep the top control: `Show messages from: [Contacts]`.
- [ ] Remove the "Contacts" header under this control.
- [ ] Remove the "Contacts:" label + flat dropdown.
- [ ] Ensure the first element below the "Show messages from" menu is the grouped contact picker card.
- [ ] Verify behavior:
  - [ ] App builds and runs.
  - [ ] Grouped picker still selects contacts and loads chats.
  - [ ] No flat Contacts dropdown appears anywhere.

## Phase 2 – Extract picker / lozenge components (no slivers yet)

**Objective:** Create reusable widgets for the two visual states.

- [ ] Extract **FullContactPicker**:
  - [ ] Contains "Select a contact" header.
  - [ ] Contains grouped A–Z contact list.
  - [ ] Contains the integrated jump bar.
- [ ] Create **ContactLozenge**:
  - [ ] Compact row with selected contact name.
  - [ ] Styled as a small card / lozenge.
- [ ] Create **SmartContactPickerHeader**:
  - [ ] Accepts `isCollapsed` boolean.
  - [ ] If `false` → shows `FullContactPicker`.
  - [ ] If `true` → shows `ContactLozenge`.
  - [ ] Uses `AnimatedSwitcher` (or similar) for a short transition.
- [ ] Temporarily hard-code `isCollapsed = false`.
- [ ] Wire `SmartContactPickerHeader` where the grouped picker currently lives.
- [ ] Verify behavior:
  - [ ] App builds and runs.
  - [ ] UI looks identical to Phase 1 (full picker only).
  - [ ] No flat Contacts dropdown.

## Phase 3 – Convert to sliver layout with pinned header (always expanded)

**Objective:** Move to `CustomScrollView` / slivers, but keep header always expanded.

- [ ] Replace the current chats list layout with a sliver-based scroll:
  - [ ] Use `CustomScrollView` or `NestedScrollView`.
  - [ ] Add a `SliverPersistentHeader` at the top for `SmartContactPickerHeader`.
  - [ ] Add a `SliverList` for chat cards below.
- [ ] In the `SliverPersistentHeaderDelegate`:
  - [ ] Set `minExtent == maxExtent` to the full picker height.
  - [ ] Header is `pinned: true`.
  - [ ] Still pass `isCollapsed = false` to `SmartContactPickerHeader`.
- [ ] Verify behavior:
  - [ ] Picker stays pinned at top while chats scroll underneath.
  - [ ] No shrinking / lozenge yet.
  - [ ] Contact selection still works and loads chats.

## Phase 4 – Implement collapse into lozenge + tap to expand

**Objective:** Make the header "smart" based on scroll, and support lozenge re-expansion.

- [ ] Update `SliverPersistentHeaderDelegate`:
  - [ ] `maxExtent` = full picker height.
  - [ ] `minExtent` = lozenge height.
  - [ ] Compute `isCollapsed` from `shrinkOffset`:
    - [ ] `isCollapsed = false` when `shrinkOffset == 0`.
    - [ ] `isCollapsed = true` once the header has fully shrunk.
  - [ ] Pass `isCollapsed` into `SmartContactPickerHeader`.
- [ ] In `SmartContactPickerHeader`:
  - [ ] When `isCollapsed == false` → show `FullContactPicker`.
  - [ ] When `isCollapsed == true` → show `ContactLozenge`.
  - [ ] Ensure `AnimatedSwitcher` provides a smooth transition.
- [ ] In `ContactLozenge`:
  - [ ] On tap, scroll the list back to the top via the same scroll controller.
  - [ ] Verify that this sets `shrinkOffset` back to 0 → `isCollapsed = false`.
  - [ ] Full picker reappears with current contact still selected.
- [ ] Verify behavior:
  - [ ] On initial load: full picker at top, no lozenge.
  - [ ] After selecting a contact: chats appear below, picker remains visible.
  - [ ] Scrolling down: picker shrinks into pinned lozenge; chats scroll underneath.
  - [ ] Clicking the lozenge: scrolls back to top and expands the picker.
  - [ ] Scrolling to top manually has the same effect as clicking the lozenge.
  - [ ] Flat Contacts dropdown is gone in all views.

## Phase 5 – Visual polish

**Objective:** Refine look & feel.

- [ ] Lozenge:
  - [ ] Slightly darker background than list.
  - [ ] Rounded corners.
  - [ ] Subtle shadow under lozenge so list clearly scrolls beneath it.
- [ ] Jump bar:
  - [ ] Dark gray background.
  - [ ] White letters.
  - [ ] Blue highlight for active letter.
- [ ] Spacing:
  - [ ] No extra blank space above the picker.
  - [ ] Small gap between header text ("Select a contact") and first contact section.
  - [ ] Jump bar aligned flush with right padding of picker card.

## Notes for Agents

- Do not reintroduce the flat Contacts dropdown in any view.
- Preserve existing data flow: contact selection should still drive chat loading exactly as before.
- Whenever possible, refactor incrementally from one phase to the next, and keep the app compiling and visually coherent after each phase.
