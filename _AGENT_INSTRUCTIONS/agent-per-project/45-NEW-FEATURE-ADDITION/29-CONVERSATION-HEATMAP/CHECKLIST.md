---
tier: project
scope: implementation-checklist
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: draft
status: planning
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Conversation Heatmap Checklist

This checklist is the implementation source of truth for Feature 29. Production
work remains unapproved until the proposal is reviewed and implementation is
explicitly authorized.

## Phase 0: Planning Package

- [x] Preserve the opening seed.
- [x] Audit both Conversation-list contexts.
- [x] Identify the compact glyph renderer and data source.
- [x] Identify the existing full heatmap renderer and input contract.
- [x] Trace Conversation selection and branch-specific navigation.
- [x] Trace timeline loading, ordering, virtualization, and row hydration.
- [x] Verify existing first-message-in-month semantics.
- [x] Verify existing exact-message indexed jump behavior.
- [x] Define assumptions, invariants, risks, scope, and non-goals.
- [x] Define the test plan.
- [ ] Obtain approval for production implementation.

## Phase 1: Prove The Reuse Boundary

- [ ] Add a pure Conversation activity -> `CalendarHeatmapTimelineData`
  adapter test before changing card rendering.
- [ ] Confirm the adapter emits exactly twelve cells per year.
- [ ] Confirm pre-start, empty, sparse, and populated month semantics match the
  existing renderer contract.
- [ ] Confirm exact total and per-month counts are preserved.
- [ ] Attempt direct renderer reuse through the smallest approved public seam.
- [ ] If dependency direction blocks that seam, document the evidence before
  proposing a render-only shared extraction.
- [ ] Do not extract shared Conversation/Messages domain types for convenience.
- [ ] Do not copy the existing year-row or month-cell renderer.

## Phase 2: Selected Card Presentation

- [ ] Add an explicit selected expanded-heatmap presentation path to
  `ConversationSignatureCard`.
- [ ] Preserve the existing compact glyph path byte-for-byte where practical
  for unselected cards.
- [ ] Keep title, metadata, actions, summary, and tags within the same selected
  background.
- [ ] Add month/year/count tooltip text.
- [ ] Add or verify semantic labels for populated months.
- [ ] Ensure empty and pre-start cells are inert and not presented as actions.
- [ ] Evaluate a larger transparent hit target without changing the visual grid.
- [ ] Update natural-height metrics only where an existing caller requires an
  explicit dimensional claim.

## Phase 3: Existing Skeleton Lookup Boundary

- [ ] Provide the active Conversation skeleton to the month-click action
  through the smallest appropriate application boundary.
- [ ] Call `MessageEvidenceTimelineSkeleton.indexForMonth()`; do not implement
  another month resolver.
- [ ] Validate the returned entry actually matches the requested month before
  reading its message ID.
- [ ] Treat a stale positive heatmap cell with no skeleton match as inert and
  diagnostically visible.
- [ ] Do not add a month-range database query or a second loader.

## Phase 4: Branch-Aware Exact-Message Navigation

- [ ] Main Conversations: dispatch the resolved ID through the existing
  `ConversationSelected.anchorMessageId` path.
- [ ] Contact -> Conversations: minimally extend the existing Contact
  Conversation selection intent/action to carry the resolved anchor.
- [ ] Preserve the active top-level branch after each month click.
- [ ] Preserve the full unfiltered Conversation evidence scope.
- [ ] Verify `ConversationMessagesView` receives the anchor.
- [ ] Verify `MessageEvidenceTimelineView` reuses `indexForMessageId()` and the
  existing `ScrollablePositionedList` jump.
- [ ] Do not add a parallel month-navigation state machine.

## Phase 5: Align Both List Contexts

- [ ] Make `ContactGraphConversationSection` derive selected state from the
  same flow-owned selected Conversation ID.
- [ ] Pass `isSelected` to the shared card.
- [ ] Verify selecting another card collapses the previous card immediately.
- [ ] Verify the main Conversations list retains current selection behavior.
- [ ] Verify Favourites and Browse manifestations behave consistently.

## Phase 6: Verification

- [ ] Run focused adapter and Conversation Card tests.
- [ ] Run focused navigation-action and sidebar-flow tests.
- [ ] Run focused Conversation message-view and timeline-view tests.
- [ ] Run existing heatmap tests to prove renderer and color stability.
- [ ] Run the architecture import test.
- [ ] Run `flutter analyze`.
- [ ] Manually validate light and dark mode.
- [ ] Manually validate the main Conversations list.
- [ ] Manually validate Contact -> Conversations.
- [ ] Manually validate a Conversation spanning many years.
- [ ] Manually validate a roughly 27,000-message Conversation.
- [ ] Confirm row hydration remains bounded near the visible target.
- [ ] Confirm Search, Show in conversation, and recovered-message flows remain
  unchanged.

## Later Enhancements Requiring Separate Approval

- [ ] Synchronize a visible-month outline with Conversation message scrolling.
- [ ] Add keyboard month-grid navigation beyond baseline activation semantics.
- [ ] Add explicit expanded-row keep-visible scrolling after selection if
  manual testing proves it necessary.
- [ ] Introduce a shared render-only heatmap package if the direct reuse seam is
  proven architecturally invalid.

## Completion Criteria

- [ ] Only the selected Conversation Card renders the full heatmap.
- [ ] Both target list contexts share the same card implementation and behavior.
- [ ] Populated month taps land on the first message in that month.
- [ ] Empty month taps perform no navigation.
- [ ] Month taps preserve Conversation membership and current branch.
- [ ] The existing full heatmap renderer remains the sole renderer.
- [ ] The existing skeleton month lookup remains the sole resolver.
- [ ] The existing exact-message anchor remains the positioning primitive.
- [ ] Large Conversations do not hydrate all message rows.
- [ ] Focused tests, architecture checks, and analysis pass.
- [ ] Release metadata is updated only in the later production phase, if that
  approved change is judged user-facing and release-worthy.
