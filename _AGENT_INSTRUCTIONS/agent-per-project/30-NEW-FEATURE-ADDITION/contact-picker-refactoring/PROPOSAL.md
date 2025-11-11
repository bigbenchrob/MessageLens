---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2025-11-11
source_of_truth: doc
status: awaiting_approval
links:
  - ../README.md
  - ../../40-FEATURES/README.md
  - ../../60-NAVIGATION/navigation-overview.md
  - ../../../agent-instructions-shared/00-global/riverpod-rules.md
tests: []
---

# Feature Proposal: Smart Pinned Contact Picker Refactor

## Summary

Replace the old flat Contacts dropdown and static grouped picker with a **smart pinned contact picker** in the macOS sidebar that:

- Uses the grouped contact picker as the *only* way to choose a contact.
- Stays pinned at the top of the sidebar as the user scrolls.
- Expands as a full picker when at the top of the list.
- Shrinks into a compact "lozenge" showing the selected contact when the user scrolls down, with chats scrolling underneath.
- Can be re-expanded by scrolling back to the top or by clicking the lozenge.

This aligns the contact-selection UX with the rest of the app's macOS idioms and scales better for users with many contacts.

## Motivation

Current problems:

- The legacy **flat Contacts dropdown** no longer matches the richer grouped sidebar selector.
- The sidebar can feel visually noisy with redundant headers and multiple "Contacts" controls.
- When scrolling large chat lists, the user can easily lose track of which contact is currently selected.
- The grouped picker currently scrolls away with the rest of the content, so selecting another contact often requires manual scrolling back to the top.

Goals:

- Make the grouped contact picker the **single source of truth** for contact selection.
- Preserve **constant visibility of the selected contact** while the user scrolls.
- Provide an intuitive, low-friction workflow: scrolls and clicks only, no extra toggles or modes.
- Keep the implementation incremental and testable, with clear phases that Codex (or other agents) can execute safely.

## High-Level Design

The feature introduces a **two-state pinned header** at the top of the sidebar:

1. **Full Picker State (expanded)**
   - Appears when the scroll position is at the top.
   - Shows the existing grouped contact picker:
     - "Select a contact" header text.
     - Alphabetical grouped list (A, B, C…) with section headers.
     - Integrated A–Z jump bar on the right edge of the picker.
   - User can scroll within the picker, click any contact, or use the jump bar to navigate.
   - When the user selects a contact:
     - The contact is highlighted in the picker.
     - The contact's "All Messages" card and per-chat cards are loaded below.
     - The header text remains "Select a contact" (the highlight is enough context).

2. **Lozenge State (collapsed)**
   - When the user scrolls the main list:
     - The full picker scrolls up until it hits the top of the viewport.
     - At that point, it **snaps** into a compact lozenge, still pinned at the top.
   - The lozenge displays:
     - The selected contact's name (and later, optional metadata such as message count or last message date).
   - All chat cards scroll underneath the lozenge, which stays visible at all times.
   - The lozenge supports:
     - **Click to re-expand** the full picker (without changing the selected contact or reloading chats).
     - **Automatic re-expansion** when the user scrolls back to the very top of the list.

The picker never disappears; it simply changes **form** based on the scroll context.

## Scope

In scope:

- Removal of the old flat Contacts dropdown and redundant "Contacts" header.
- Introduction of a `SmartContactPickerHeader` that can render both full picker and lozenge states.
- Migration of the sidebar list to a sliver-based layout (`CustomScrollView` / `SliverPersistentHeader`).
- Wiring scroll position to the header's expanded/collapsed state.
- Basic visual polish to match macOS sidebar conventions (without pixel-perfect tuning).

Out of scope (for this feature):

- New contact grouping strategies (favorites, recents, virtual groups).
- Changes to how chats are loaded or indexed.
- Cross-platform styling adjustments outside macOS.
- User preferences / feature flags to disable the lozenge (can be added later if needed).

## Implementation Strategy (Phased)

Implementation should be incremental, with each phase compiling and remaining shippable:

1. **UI Cleanup**
   - Remove flat Contacts dropdown and redundant headers.
   - Make the grouped contact picker the first element below "Show messages from: [Contacts]".

2. **Component Extraction**
   - Extract `FullContactPicker`, `ContactLozenge`, and `SmartContactPickerHeader` widgets.
   - Hard-code the header in expanded mode initially.

3. **Sliver Conversion**
   - Convert the sidebar content to a sliver-based scroll view with a pinned `SliverPersistentHeader`.
   - Keep the header always expanded at this stage.

4. **Smart Collapsing Behavior**
   - Introduce `minExtent` / `maxExtent` in the header delegate.
   - Drive `isCollapsed` based on `shrinkOffset`.
   - Show full picker at the top; lozenge when scrolled.
   - Implement tap-to-expand behavior on the lozenge, which scrolls back to top.

5. **Visual Polish**
   - Compact, macOS-friendly lozenge styling (rounded card, subtle shadow).
   - High-contrast jump bar integrated into the picker.
   - Clean spacing and alignment.

## Risks & Mitigations

- **Risk: Layout refactor breaks existing scrolling behavior.**
  - Mitigation: Use the phased plan; introduce slivers first with a static header, then add collapsing.

- **Risk: Agents over-refactor or attempt to redesign unrelated parts of the sidebar.**
  - Mitigation: Keep this feature folder scoped narrowly to the contact picker header and its immediate layout; reference existing patterns from `contact-menu-enhancements`.

- **Risk: UX confusion if the lozenge is not discoverable.**
  - Mitigation: Ensure smooth animation between states and clear visual continuity; the lozenge looks like a compressed version of the picker, not a new control.

## Success Criteria

- The flat Contacts dropdown is removed from the app and from agent instructions.
- The grouped contact picker is the only selector and appears at the top of the sidebar.
- The contact picker remains visible in some form (full or lozenge) regardless of scroll position.
- Users can:
  - Select a contact from the full picker.
  - Scroll chat cards while seeing the current contact in the lozenge.
  - Re-open the full picker by scrolling to top or clicking the lozenge.
- All existing navigation and chat-loading logic remains intact.
