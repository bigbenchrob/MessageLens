---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: both
status: implemented
links:
  - ./seed.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
  - ./TESTS.md
  - ../24-HEATMAP-COLOR-REVISION/README.md
  - ../../40-FEATURES/conversations/README.md
  - ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
  - ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/40-feature-responsibilities.md
tests: []
---

# Conversation Heatmap Proposal

## Problem Statement

Long Conversations currently rely too heavily on ordinary scrolling. The
compact month glyph on each Conversation Card communicates temporal activity,
but it does not let the user navigate that activity. This is a notable gap
beside the existing Contact / All Messages year-by-month heatmap, which already
supports coarse navigation into a long message history.

The selected Conversation also needs a durable visual treatment in the list.
The main Conversations list already knows and styles its selected card, but its
glyph remains compact. Contact -> Conversations uses the same card without
propagating the selected state, so the row driving the center message pane is
not visually persistent there.

## Goal

Turn the selected Conversation Card into a temporal navigator without creating
a second visualization or navigation system:

- unselected cards keep the current compact glyph;
- the selected card replaces that glyph with the existing full year x month
  heatmap presentation;
- the card's existing selected background encompasses title, metadata, and the
  expanded heatmap;
- clicking a populated month jumps to the first message in that Conversation
  during that month;
- selecting another Conversation immediately collapses the previous card and
  expands the new one.

This behavior should be consistent in the main Conversations list and Contact
-> Conversations mode unless implementation evidence reveals a real
surface-specific constraint.

## Product Navigation Model

The feature preserves distinct navigation scales:

```text
heatmap              coarse temporal navigation to a month
scrolling            local movement around nearby messages
search               semantic navigation by message content
Show in conversation precise navigation to one known message
```

Month navigation must not change the Conversation's membership, filter the
Conversation, or create a month-only message scope. It changes only the initial
position in the existing complete Conversation stream.

## Current Architecture Summary

`ConversationSignatureCard` is the shared Conversation-owned card used by both
target list contexts. `ConversationSignatureDisplayModel.activityMonths` is
populated from graph-derived `ConversationSignatureMonth` values. The activity
reader already returns a continuous monthly series from the Conversation's
first dated month through its last dated month, including zero-count months.

The existing full heatmap is rendered by `CalendarHeatmapTimelineWidget`. It
already owns the twelve fixed month columns, year rows, sparse-dot and activity
fill grammar, empty-month presentation, pointer cursor, optional tooltip, and
caller-owned month callback. `MessageHeatmapContent` is a Messages sidebar
composition wrapper containing summary, legend, and hint content; that entire
wrapper does not need to appear inside a Conversation Card.

Conversation message presentation already uses a two-stage evidence spine:

1. `messageEvidenceTimelineSkeletonProvider` materializes lightweight ordered
   entries containing message ID, date, and month key for the Conversation.
2. `MessageEvidenceTimelineView` renders with `ScrollablePositionedList` and
   hydrates only visible message rows through `messageEvidenceRowProvider`.

The skeleton is ordered oldest to newest. Its existing `indexForMonth()` lookup
returns the first entry matching a month key, which is exactly the required
month-jump semantic. The timeline already accepts an exact `anchorMessageId`,
maps it to an index, and performs an indexed jump.

## Recommended Implementation Direction

### 1. Reuse the existing full renderer

Do not create a second full Conversation heatmap renderer.

Render `CalendarHeatmapTimelineWidget` directly in the selected
`ConversationSignatureCard`, or place only the thinnest Conversation-owned
adapter around it. Adapt `ConversationSignatureMonth` and existing signature
metadata into `CalendarHeatmapTimelineData` at the presentation boundary.

Prefer this adapter over extracting or sharing domain types. A shared
extraction is justified only if dependency direction makes direct reuse through
an approved public seam genuinely inappropriate. Even then, extract the
render-only primitive and its presentation contract, not Conversation or
Messages domain ownership.

### 2. Reuse the existing month lookup

Do not create a second month-to-message resolver.

`MessageEvidenceTimelineSkeleton.indexForMonth()` already identifies the first
message in the target month. The smallest suitable boundary should expose or
request that existing lookup result for the active Conversation rather than
re-querying month boundaries under a parallel semantic implementation.

The intended path is:

```text
populated month click
  -> existing Conversation evidence skeleton
  -> MessageEvidenceTimelineSkeleton.indexForMonth(month)
  -> message ID at that index
  -> existing Conversation exact-message anchor action
  -> existing ScrollablePositionedList indexed jump
```

A separate month-navigation state machine, repository query, paged loader, or
scroll-offset estimator requires explicit justification and user approval.

### 3. Preserve branch-aware anchor navigation

The main Conversations branch and Contact -> Conversations branch must remain
in their current contexts after a month click. Extend or reuse their semantic
Conversation selection actions so the same Conversation can be selected with
the resolved message anchor. Do not route a Contact-derived selection through
an action that silently changes the top-level branch.

### 4. Align selected-state propagation

The main Conversations list already compares each card with
`sidebarFlowProvider.selectedConversationId`. Apply the same flow-derived
selection check in `ContactGraphConversationSection` and pass `isSelected` to
the shared card. The existing selected surface tokens remain authoritative;
do not add an unrelated marker unless testing proves the selected background is
insufficient.

## Assumptions

- Conversation activity months and message skeleton month keys are derived
  from the same normalized graph dates.
- A populated heatmap month always has at least one dated skeleton entry for
  the same Conversation; a defensive no-target result should remain inert and
  diagnosable.
- Materializing a lightweight 27,000-entry skeleton is already accepted product
  behavior; this feature must not force hydration of all 27,000 message rows.
- `ScrollablePositionedList` can jump directly to the resolved index without
  estimating row heights or walking intermediate rows.
- One global selected Conversation ID per active branch is sufficient to make
  expansion mutually exclusive.
- The selected card's current semantic background and border tokens can carry
  persistent selection in both light and dark modes.

## Hard Invariants

- Unselected rows retain the existing compact Conversation glyph.
- Selected rows use the existing year x month heatmap visual language.
- Do not create a second full heatmap renderer.
- Do not create a second month-to-message resolver.
- January through December remain fixed horizontal columns; years remain
  vertical rows.
- Existing `MonthIntensity` categories and
  `activityHeatmapColorForMessageCount()` remain authoritative.
- Empty and pre-start months remain visually distinct and inert.
- A populated month targets the first message in that month in ascending
  Conversation order.
- Month selection changes position, not filtering or Conversation membership.
- Exact-message, Search, recovered-message, and Show in conversation behavior
  remain unchanged.
- Message rows remain lazily hydrated; month navigation must not load the full
  message corpus.
- Durable navigation meaning remains in the existing sidebar flow/action
  system; widgets do not create a competing navigation owner.
- No graph, overlay, import, archive, or database schema behavior changes.
- Existing unrelated worktree changes are preserved.

## Proposed Implementation Scope

- Add a selected/unselected heatmap presentation mode to the shared
  Conversation Card.
- Add a thin adapter from `ConversationSignatureCardData.activityMonths` and
  count metadata to the existing full heatmap input.
- Expose `CalendarHeatmapTimelineWidget` through the smallest architecturally
  valid dependency seam if it is not already reachable from Conversations.
- Resolve populated month taps through the active Conversation skeleton's
  existing `indexForMonth()` method.
- Feed the resolved message ID through existing branch-aware Conversation
  anchor navigation.
- Propagate selected state in Contact -> Conversations.
- Add focused unit, widget, provider/action, and navigation tests.
- Manually validate dynamic row height, pointer targets, tooltips, semantics,
  light/dark selection contrast, and very long Conversations.

## Out Of Scope

- A new heatmap visual language or palette.
- A second Conversation heatmap renderer.
- A second month lookup implemented in SQL or a new domain service.
- Month filtering or a month-only message view.
- Pagination or replacement of the existing evidence skeleton.
- Changes to Conversation membership, graph projection, or import behavior.
- Search redesign or recovered-message navigation changes.
- Changes to Show in conversation beyond reusing its anchor primitive.
- Persisting the last selected heatmap month.
- Multi-month selection, ranges, brushing, zooming, or keyboard-driven
  calendar exploration.
- An always-visible selected-month outline in the first slice. This may be
  reconsidered after the reuse path is proven.
- Broad extraction of Messages and Conversations domain types.

## Risks

- **Dependency direction:** the renderer and its presentation DTOs currently
  live inside Messages. Use an explicit public export first; propose a neutral
  render-only extraction only if architecture checks reject that direction.
- **Stale concurrent reads:** heatmap counts and the evidence skeleton may
  refresh independently. Verify the month key at the returned index before
  dispatching an anchor so `indexForMonth()`'s current latest-item fallback
  cannot cause a misleading jump.
- **Branch loss:** the main and Contact-derived lists use different semantic
  actions. A Contact month click must not switch to the main Conversations
  branch.
- **Dynamic row height:** expanding a multi-year card can move neighboring rows
  and consume much of the Contact list's constrained viewport. Test the natural
  list behavior before adding scroll correction or nested scrolling.
- **Small pointer targets:** the existing visual cells are compact. Improve hit
  testing and semantics in the reused renderer without changing its visual
  language or creating a second widget.
- **Async selection races:** a month lookup may finish after the user selects a
  different Conversation. Validate active Conversation identity before
  dispatching the resolved anchor.
- **Over-broad extraction:** moving shared domain models would increase the
  diff and blur ownership. Prefer a pure adapter and narrow public seam.

## Implemented Production Files

Modified:

- `lib/features/conversations/presentation/widgets/conversation_signature_card.dart`
- `lib/features/conversations/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart`
- `lib/features/conversations/presentation/widgets/contact_conversations/contact_graph_conversation_section.dart`
- `lib/features/conversations/application/sidebar_cassette_spec/resolver_tools/conversation_navigation_actions_provider.dart`
- `lib/features/conversations/application/contact_conversations/contact_conversation_navigation_actions_provider.dart`
- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart`
- `lib/features/messages/feature_level_providers.dart`
- `lib/features/messages/presentation/widgets/calendar_heatmap_timeline_widget.dart`
- `lib/essentials/sidebar/domain/sidebar_action_intent.dart`
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
- `pubspec.yaml`
- `CHANGELOG.md`

Added:

- `lib/features/conversations/presentation/widgets/conversation_signature_calendar_heatmap.dart`

`ConversationMessagesView`, `MessageEvidenceTimelineSkeleton`,
`MessageEvidenceTimelineView`, and `SidebarFlowState` required no production
changes. Their existing exact-message and indexed-positioning contracts were
reused. No generated files changed.

## Success Criteria

- Exactly one full year x month renderer remains authoritative.
- Exactly one month-to-first-message semantic remains authoritative.
- The selected Conversation is unmistakable in both target list contexts.
- A populated month click lands on that month's first Conversation message.
- A month click does not filter the message stream.
- A 27,000-message Conversation jumps without hydrating every message row or
  incrementally scrolling through the corpus.
- Empty months do not advertise or perform navigation.
- Existing Conversation selection, Search, recovered-message, and exact-message
  tests continue to pass.

## Decisions Deferred Pending Implementation Evidence

- Whether a thin public export is sufficient for direct renderer reuse or a
  render-only shared extraction is required by dependency rules.
- Whether the currently visible month should gain an outline in a later slice.
  It is not needed to deliver month navigation and would add cross-surface
  synchronization work.
- Whether an expanded card needs a maximum internal height for unusually long
  histories. Default to natural card height inside the existing list until
  manual testing demonstrates a concrete usability problem.

## First Slice Implementation Record — 2026-09-08

The approved first slice is implemented with the planned reuse-first shape:

- `ConversationSignatureCalendarHeatmap` is a thin Conversation-owned adapter
  from `ConversationSignatureMonth` values to
  `CalendarHeatmapTimelineData`.
- Conversations consumes `CalendarHeatmapTimelineWidget`, its presentation
  DTOs, and the existing Conversation evidence skeleton provider through
  explicit narrow exports from the Messages public seam. The architecture
  suite accepted this dependency direction; no shared-type extraction was
  needed.
- Both semantic action providers call
  `MessageEvidenceTimelineSkeleton.indexForMonth()`, verify the returned
  entry's exact month key, and dispatch that entry's message ID through the
  existing anchor-message selection intent. No query, second resolver, or
  month-navigation state was added.
- Contact selection is projected by the existing Messages parent and passed as
  presentation data to `ContactGraphConversationSection`. The section does not
  read or mutate global flow directly.
- Each list gives the shared stateful card a stable Conversation ID key. An
  in-flight month lookup also rechecks the current branch and selected ID so a
  stale result cannot recreate or restore a previous selection.
- The shared renderer now supports an optional transparent hit target and
  caller-supplied focus ring. Conversation cards retain 12-pixel visual cells
  inside 18-pixel targets, with month/count tooltips, isolated semantics, and
  keyboard activation. Empty and pre-start cells absorb the surrounding card
  gesture without exposing a navigation action.
- Natural variable-height list behavior was retained. The main list has no
  fixed extent, and the Contact list remains the existing scrollable
  360-pixel viewport. No internal heatmap scroller or expansion cap was added.

Implementation discoveries and deviations:

- The adapter uses `ConversationSignatureMonth` as the authoritative dated
  bounds instead of parsing optional summary date strings. This keeps invalid
  optional metadata from inventing or suppressing calendar activity.
- The architecture tripwire correctly rejected a direct `sidebarFlowProvider`
  read in the Contact presentation section. Passing the already-projected
  selected ID from `MessagesHeatmapWidget` preserved the intended boundary.
- The test-first ordering item in `CHECKLIST.md` was not met: the initial
  adapter and card composition were written before their focused tests. The
  completed automated coverage now exercises the adapter and presentation.
- Live light/dark, VoiceOver, and production-data validation of a 15+ year or
  roughly 27,000-message Conversation remains a manual follow-up. No automated
  or architectural evidence required extra scrolling machinery in this slice.
