---
tier: project
scope: implementation-checklist
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: both
status: implemented
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Conversation Heatmap Checklist

This checklist is the implementation source of truth for Feature 29. Production
work was explicitly authorized by `prompts/01-IMPLEMENT-FIRST-SLICE.md`; the
first implementation slice is complete, with remaining live-data checks called
out below.

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
- [x] Obtain approval for production implementation.

## Phase 1: Prove The Reuse Boundary

- [ ] Add a pure Conversation activity -> `CalendarHeatmapTimelineData`
  adapter test before changing card rendering. The test now exists and passes,
  but it was added after the first composition edit rather than test-first.
- [x] Confirm the adapter emits exactly twelve cells per year.
- [x] Confirm pre-start, empty, sparse, and populated month semantics match the
  existing renderer contract.
- [x] Confirm exact total and per-month counts are preserved.
- [x] Attempt direct renderer reuse through the smallest approved public seam.
- [x] Confirm dependency direction does not block that seam; no render-only
  shared extraction is needed.
- [x] Do not extract shared Conversation/Messages domain types for convenience.
- [x] Do not copy the existing year-row or month-cell renderer.

## Phase 2: Selected Card Presentation

- [x] Add an explicit selected expanded-heatmap presentation path to
  `ConversationSignatureCard`.
- [x] Preserve the existing compact glyph path byte-for-byte where practical
  for unselected cards.
- [x] Keep title, metadata, actions, summary, and tags within the same selected
  background.
- [x] Add month/year/count tooltip text.
- [x] Add or verify semantic labels for populated months.
- [x] Ensure empty and pre-start cells are inert and not presented as actions.
- [x] Evaluate a larger transparent hit target without changing the visual grid.
- [x] Update natural-height metrics only where an existing caller requires an
  explicit dimensional claim.

## Phase 3: Existing Skeleton Lookup Boundary

- [x] Provide the active Conversation skeleton to the month-click action
  through the smallest appropriate application boundary.
- [x] Call `MessageEvidenceTimelineSkeleton.indexForMonth()`; do not implement
  another month resolver.
- [x] Validate the returned entry actually matches the requested month before
  reading its message ID.
- [x] Treat a stale positive heatmap cell with no skeleton match as inert and
  diagnostically visible.
- [x] Do not add a month-range database query or a second loader.

## Phase 4: Branch-Aware Exact-Message Navigation

- [x] Main Conversations: dispatch the resolved ID through the existing
  `ConversationSelected.anchorMessageId` path.
- [x] Contact -> Conversations: minimally extend the existing Contact
  Conversation selection intent/action to carry the resolved anchor.
- [x] Preserve the active top-level branch after each month click.
- [x] Preserve the full unfiltered Conversation evidence scope.
- [x] Verify `ConversationMessagesView` receives the anchor.
- [x] Verify `MessageEvidenceTimelineView` reuses `indexForMessageId()` and the
  existing `ScrollablePositionedList` jump.
- [x] Do not add a parallel month-navigation state machine.

## Phase 5: Align Both List Contexts

- [x] Make `ContactGraphConversationSection` derive selected state from the
  same flow-owned selected Conversation ID.
- [x] Pass `isSelected` to the shared card.
- [x] Verify selecting another card collapses the previous card immediately.
- [x] Verify the main Conversations list retains current selection behavior.
- [x] Verify Favourites and Browse manifestations behave consistently.

## Phase 6: Verification

- [x] Run focused adapter and Conversation Card tests.
- [x] Run focused navigation-action and sidebar-flow tests.
- [x] Run focused Conversation message-view and timeline-view tests.
- [x] Run existing heatmap tests to prove renderer and color stability.
- [x] Run the architecture import test.
- [x] Run `flutter analyze`.
- [x] Manually validate light and dark mode.
- [x] Manually validate the main Conversations list.
- [x] Manually validate Contact -> Conversations.
- [x] Manually validate a Conversation spanning many years.
- [x] Manually validate a roughly 27,000-message Conversation.
- [x] Confirm row hydration remains bounded near the visible target.
- [x] Confirm Search, Show in conversation, and recovered-message flows remain
  unchanged.

## Later Enhancements Requiring Separate Approval

- [ ] Synchronize a visible-month outline with Conversation message scrolling.
- [ ] Add keyboard month-grid navigation beyond baseline activation semantics.
- [ ] Add explicit expanded-row keep-visible scrolling after selection if
  manual testing proves it necessary.
- [ ] Introduce a shared render-only heatmap package if the direct reuse seam is
  proven architecturally invalid.

## Completion Criteria

- [x] Only the selected Conversation Card renders the full heatmap.
- [x] Both target list contexts share the same card implementation and behavior.
- [x] Populated month taps land on the first message in that month.
- [x] Empty month taps perform no navigation.
- [x] Month taps preserve Conversation membership and current branch.
- [x] The existing full heatmap renderer remains the sole renderer.
- [x] The existing skeleton month lookup remains the sole resolver.
- [x] The existing exact-message anchor remains the positioning primitive.
- [x] Large Conversations do not hydrate all message rows.
- [x] Focused tests, architecture checks, and analysis pass.
- [x] Release metadata is updated for the release-worthy user-facing slice as
  version `0.2.105+123` with a matching changelog entry.
