---
tier: project
scope: feature-testing
owner: agent-per-project
last_reviewed: 2025-11-11
source_of_truth: doc
status: in_progress
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
tests: []
---

# Testing Plan: Smart Pinned Contact Picker

This document outlines the testing strategy for the contact picker refactor, covering unit tests, widget tests, and integration tests.

## Unit Tests

### Header Delegate Behavior

- [ ] **`isCollapsed` derivation**
  - Given `shrinkOffset == 0`, `isCollapsed` should be `false`.
  - Given `shrinkOffset >= maxExtent - minExtent`, `isCollapsed` should be `true`.
  - Intermediate values should smoothly transition without throwing.

- [ ] **Extent invariants**
  - `minExtent` must always be ≤ `maxExtent`.
  - Changing configuration (e.g., picker height) should not violate extent assumptions.

### Picker Components

- [ ] **FullContactPicker**
  - Renders section headers and contacts for a given grouped list.
  - Highlights the selected contact.
  - Calls the selection callback when a contact is tapped.

- [ ] **ContactLozenge**
  - Displays the selected contact’s name.
  - Falls back to a neutral label (e.g., "Select a contact") when no contact is selected.
  - Invokes its callback when tapped.

- [ ] **SmartContactPickerHeader**
  - Renders `FullContactPicker` when `isCollapsed == false`.
  - Renders `ContactLozenge` when `isCollapsed == true`.
  - Uses `AnimatedSwitcher` or equivalent to handle cross-fades without exceptions.

## Widget Tests

### Static Layout

- [ ] **Initial render (top of list)**
  - When the list is at offset 0:
    - The full contact picker is visible.
    - The lozenge is not visible.
    - No chats are rendered until a contact is selected.

- [ ] **After selecting a contact**
  - Tap a contact in `FullContactPicker`:
    - The contact becomes highlighted.
    - The "All Messages" card for that contact appears.
    - Per-chat cards appear below the "All Messages" card.

### Scroll-Driven Behavior

- [ ] **Collapse on scroll**
  - With a selected contact:
    - Scroll the `CustomScrollView` until the header reaches its minimum extent.
    - Expect the full picker to transition into `ContactLozenge`.
    - Expect the lozenge to remain pinned at the top while chat cards scroll underneath.

- [ ] **Expand on scroll-to-top**
  - From the collapsed state:
    - Scroll back to offset 0.
    - Expect `ContactLozenge` to be replaced by the full picker.
    - Expect the same contact to remain selected.

- [ ] **Lozenge tap to expand**
  - From the collapsed state:
    - Tap the lozenge.
    - Expect the list to scroll back to the top programmatically.
    - Expect the full picker to reappear with the selected contact intact.

### Jump Bar Behavior

- [ ] **Letters match groups**
  - For a grouped list with letters A, C, D:
    - Jump bar only shows A, C, D (no B, E, etc.).

- [ ] **Click-to-jump**
  - Tap a letter in the jump bar:
    - The list scrolls to the section header for that letter.
    - The appropriate letter section is aligned into view.

## Integration Tests

These tests should simulate realistic usage scenarios in the macOS UI.

- [ ] **Basic navigation flow**
  - Open the app.
  - Confirm the grouped picker is visible at the top, with no flat Contacts dropdown.
  - Select a contact.
  - Scroll through chats, verifying the lozenge remains visible.

- [ ] **Switching contacts**
  - From the expanded picker, select contact A.
  - Scroll to collapse into the lozenge.
  - Click the lozenge to re-expand.
  - Select contact B.
  - Verify that the lozenge now shows contact B and that the chat cards are updated accordingly.

- [ ] **No-regression checks**
  - Ensure that:
    - Navigation to other panels still works.
    - Existing message loading and pagination logic is not affected.
    - No new exceptions are thrown during deep scrolling.

## Non-Goals for this Feature

- We do not need exhaustive visual "pixel-perfect" snapshot tests in this feature.
- We do not need to test new grouping strategies or favorites/recents here.
- Platform-specific behavior outside macOS is out of scope.

This testing plan should give good coverage of the new header behavior, the refactored layout, and the user’s mental model of the smart pinned contact picker.
