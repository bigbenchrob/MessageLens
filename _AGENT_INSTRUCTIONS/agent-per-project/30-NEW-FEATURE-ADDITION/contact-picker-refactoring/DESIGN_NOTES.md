---
tier: project
scope: feature-design
owner: agent-per-project
last_reviewed: 2025-11-11
source_of_truth: doc
status: in_progress
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
tests: []
---

# Design Notes: Smart Pinned Contact Picker

## UX Overview

The macOS sidebar should present a **single, coherent contact-selection surface** that scales from tens to hundreds of contacts while preserving context as the user scrolls.

Core ideas:

- The *grouped contact picker* is the only place where contacts are chosen.
- The picker always remains visible in some form:
  - Full picker at the top of the list.
  - Compact lozenge pinned at the top when scrolled.
- No additional "Contacts" headers, dropdowns, or redundant controls.

The user’s interaction vocabulary is intentionally simple:

- Scroll the picker / chat list.
- Click contacts in the picker.
- (Optionally) click the lozenge to re-open the picker.

There is no disclosure triangle for the picker itself; the "open vs compact" behavior is driven by scroll context and a single lozenge tap affordance.

## Visual Structure

### When at the top (full picker state)

- Top bar: `Show messages from: [Contacts]` — unchanged.
- Below that, the list background is slightly lighter than the top bar.
- First element in the list: full contact picker card:
  - Header text: **"Select a contact"** (always, even after selection).
  - Grouped sections by first letter (A, C, D, ...):
    - Section headers with letter and optional count badge.
    - Contacts listed under each letter, with highlight for the selected contact.
  - Integrated jump bar on the **right edge** of the picker:
    - Dark gray vertical strip.
    - White uppercase letters.
    - Only includes letters that exist in the current group set.
    - Active letter may be highlighted in the system accent color.

The grouped picker opens at full size on first load and is the only visible element until a contact is chosen (no chats yet).

### After contact selection

- Contact row is highlighted in the picker.
- Below the picker:
  - The contact’s "All Messages" card (first).
  - Below that, individual chat cards for the contact.
- The picker header still shows "Select a contact" — the highlight communicates the active contact.

### When scrolling down (lozenge state)

As the user scrolls the main content:

- The full picker scrolls up with the content until its top edge reaches the top of the viewport.
- At that point, the picker "docks" and transitions into a **lozenge**:
  - Horizontal card pinned at the very top of the scrollable area.
  - Background slightly darker than the list surface.
  - Rounded corners and a soft shadow to show that content scrolls underneath.
  - Shows:
    - The active contact’s name.
    - Optional future metadata (not required in this feature).
- All other list items (All Messages card, chat cards, etc.) scroll beneath the lozenge.

The lozenge remains visible as long as the user is scrolled away from the top.

### Returning to full picker

There are two paths back to the full picker:

1. **Scroll to top**  
   When the user scrolls back to the very top of the list, the header’s collapse offset reaches zero. The lozenge expands back into the full picker, preserving the current selection.

2. **Click the lozenge**  
   Clicking the lozenge triggers a programmatic scroll-to-top and expands the picker. This is a shortcut that avoids manual scrolling and does not change the selected contact.

## Layout & Architecture

### Widgets

- `FullContactPicker`
  - Accepts the contact list, selected contact, and selection callback.
  - Renders header, grouped list, and jump bar.
- `ContactLozenge`
  - Accepts the selected contact (and later optional metadata).
  - Renders a compact, clickable card.
- `SmartContactPickerHeader`
  - Accepts a boolean `isCollapsed` and the selected contact.
  - Renders either `FullContactPicker` (expanded) or `ContactLozenge` (collapsed).
  - Uses `AnimatedSwitcher` for transitions.

### Scroll Integration

The sidebar content should be represented as a `CustomScrollView` (or `NestedScrollView`) with:

- A `SliverPersistentHeader` wrapping `SmartContactPickerHeader`:
  - `pinned: true`.
  - `maxExtent`: height of the full picker.
  - `minExtent`: height of the lozenge.
  - `build` method computes `isCollapsed` from `shrinkOffset`.
- A `SliverList` for the "All Messages" card and chat cards.

The same scroll controller is used:

- By the `CustomScrollView`.
- By the lozenge tap handler, which scrolls to offset 0.

### State

Relevant state includes:

- Selected contact (already present in the app).
- The list of grouped contacts (already present).
- No new global state is required for `isCollapsed`; it is derived from `shrinkOffset` inside the header delegate.

## Behavior Details

- The full picker scrolls normally while within the viewport.
- Once the header hits its minimum extent, the picker is considered collapsed.
- `SmartContactPickerHeader` should avoid re-triggering heavy builds on every small scroll tick; keep the build logic lean.
- Transitions should be quick (~150–200 ms) to keep the UI feeling responsive.

## Future Extensions

The design intentionally leaves room for:

- Contact-level metadata in the lozenge (message counts, last active date, etc.).
- Feature flags or user preferences to disable or alter the collapsing behavior.
- Alternative groupings (favorites/recents) rendered above or within the picker.

For now, this feature focuses only on the **structural refactor and behavior change** needed for the smart pinned picker.
