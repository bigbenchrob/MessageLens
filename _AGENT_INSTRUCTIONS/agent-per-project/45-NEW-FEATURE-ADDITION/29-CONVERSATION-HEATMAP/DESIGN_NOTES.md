---
tier: project
scope: architecture-audit
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: draft
status: planning
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./TESTS.md
  - ../24-HEATMAP-COLOR-REVISION/README.md
  - ../../40-FEATURES/conversations/README.md
  - ../../08-SIDEBAR-LAYOUTS/00-sidebar-cassettes-controls-and-info-cards.md
tests: []
---

# Conversation Heatmap Architecture And UX Audit

## Audit Outcome

The feature can be implemented by composing existing mechanisms. The visual
renderer, monthly Conversation counts, complete lightweight message skeleton,
first-entry month lookup, exact-message anchor, and indexed list jump all exist.

The missing work is coordination:

- render the full heatmap only in the selected shared Conversation Card;
- adapt existing Conversation activity data to the existing heatmap input;
- resolve the clicked month against the already-authoritative Conversation
  evidence skeleton;
- pass the resulting message ID through branch-aware anchor navigation; and
- propagate selected state in Contact -> Conversations.

## Source Inventory

### Compact Conversation glyph

- `lib/features/conversations/presentation/widgets/conversation_signature_card.dart`
  - `ConversationSignatureCard`
  - `_ConversationMonthGlyph`
  - `_MonthGlyphDot`
  - `ConversationSignatureCardPresentationMetrics`
- `lib/features/conversations/presentation/widgets/conversation_signature_card_presentation.dart`
  - `conversationSignatureCardDataFromDisplay()`
  - `conversationSignatureCardStyle()`
  - `conversationSignatureMonthColorForMessageCount()`
- `lib/features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart`
  - `ConversationSignatureDisplayModel.activityMonths`
- `lib/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart`
  - `ConversationSignatureMonth`
- `lib/essentials/conversation_graph/application/conversation_signatures/conversation_signature_reader.dart`
  - adapts graph activity traces to Conversation signature months
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`
  - `readActivityTraces()` returns month counts, including zero-count months
    between the first and last dated activity months
- `lib/config/theme/widgets/heatmap/activity_heatmap_color_scale.dart`
  - shared count-to-color authority

### Full Contact / All Messages heatmap

- `lib/features/messages/presentation/widgets/calendar_heatmap_timeline_widget.dart`
  - `CalendarHeatmapTimelineWidget`
  - fixed year rows and January-December columns
  - sparse dots, empty cells, activity fills, selected outline, pointer cursor,
    optional tooltip, and caller-owned tap callback
- `lib/features/messages/domain/calendar_heatmap_timeline_data.dart`
  - `CalendarHeatmapTimelineData`, `YearRow`, `MonthData`, and `MonthIntensity`
- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart`
  - `MessageHeatmapContent` composes the renderer with summary, legend, and
    instructional hint
  - Contact and global callers translate month taps into semantic actions
- `lib/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_timeline_provider.dart`
  - builds full calendar data from Contact activity
- `lib/features/messages/application/message_evidence/current_visible_month_provider.dart`
  - optional coordination state for currently visible month

`CalendarHeatmapTimelineWidget` is already a reusable render edge: it receives
fully decided display data and a caller-owned tap callback. Its current source
location and data-type ownership are the only reuse questions. The selected
Conversation Card should reuse this widget, not duplicate `_SingleYearRow`,
`_MonthCell`, sparse-dot rendering, or activity-fill logic.

`MessageHeatmapContent` is not the preferred unit of reuse inside a card. Its
summary, legend, hint, and 252-pixel rail belong to the Messages cassette. The
Conversation Card already renders title and summary metadata and needs only the
calendar renderer plus an appropriate tooltip.

### Conversation list contexts and selection

Main Conversations:

- `lib/features/conversations/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart`
  - watches `sidebarFlowProvider.selectedConversationId`
  - passes `isSelected` to `ConversationSignatureCard`
  - uses `ConversationNavigationActions.selectConversation()`

Contact -> Conversations:

- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart`
  - chooses Contact `allMessages` or `conversations` projection
  - embeds `ContactGraphConversationSection`
- `lib/features/conversations/presentation/widgets/contact_conversations/contact_graph_conversation_section.dart`
  - uses the same `ConversationSignatureCard`
  - currently does not watch `selectedConversationId`
  - currently does not pass `isSelected`
  - uses `ContactConversationNavigationActions.selectContactConversation()`

Durable flow and center projection:

- `lib/essentials/sidebar/application/sidebar_flow_state_provider.dart`
  - owns `selectedConversationId`, optional exact-message anchor, and search
    query
  - projects both branches into `ConversationsSpec.conversationMessages`
- `lib/essentials/sidebar/domain/sidebar_action_intent.dart`
  - `ConversationSelected` already carries an optional message anchor
  - `ContactConversationSelected` currently carries only contact and
    Conversation IDs
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
  - maps semantic actions into branch-correct flow transitions

There is only one selected Conversation ID in an active list context. When it
changes, normal rebuilds can collapse the previous card and expand the new
card immediately. No local expansion registry is needed.

### Message loading and positioning

- `lib/features/conversations/presentation/view/conversation_messages_view.dart`
  - creates `ConversationEvidenceScope`
  - watches the complete Conversation skeleton
  - accepts `anchorMessageId`
  - does not currently accept a month anchor
- `lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart`
  - `_conversationTimelineSkeleton()` reads the full lightweight timeline
  - `messageEvidenceRowProvider` hydrates a row by ID when rendered
- `lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository.dart`
  - `readMessageTimeline()` selects message ID, normalized date, and month key
  - ordering is ascending by date and then message ID
- `lib/features/messages/domain/message_evidence/message_evidence_skeleton.dart`
  - `indexForMonth()` returns the first matching entry
  - `indexForMessageId()` supports exact-message positioning
- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view.dart`
  - uses `ScrollablePositionedList.builder`
  - computes an initial/updated target index
  - jumps directly through `ItemScrollController.jumpTo(index: ...)`
  - hydrates only rows requested by the builder

The timeline is virtualized at the full-row level, not at the skeleton level.
A 27,000-message Conversation holds 27,000 small identity/date/month entries,
but it does not build or hydrate 27,000 message widgets. An arbitrary
historical position is already supported without pixel-offset estimation.

## Required Month-Jump Semantics

For a populated `(conversationId, year, month)` selection:

1. Obtain the active `MessageEvidenceTimelineSkeleton` for
   `ConversationEvidenceScope(conversationId)` through an appropriate
   application boundary.
2. Call `indexForMonth(DateTime(year, month))`.
3. Read the `messageId` at that index.
4. Dispatch the existing branch-correct Conversation selection with that
   `anchorMessageId`.
5. Let `ConversationMessagesView` pass the anchor to
   `MessageEvidenceTimelineView`.
6. Let the existing `indexForMessageId()` and `ScrollablePositionedList`
   machinery perform the jump.

This deliberately reuses both lookup and positioning authorities. Do not add a
SQL month-boundary query, a binary search with different fallback semantics, a
pixel scroll loop, or a second navigation state model.

### Defensive no-match handling

The heatmap callback should only be enabled for positive-count months. If a
positive cell nevertheless has no matching skeleton entry because data changed
between reads, the action should remain inert and report diagnostic context. It
must not fall back to the latest message: `indexForMonth()` currently returns
the latest index when no match exists, so a caller that needs to distinguish
"not found" must validate that the returned entry's month key matches the
requested month before dispatching the anchor.

That validation is not a second resolver. It prevents the existing fallback
behavior from producing a misleading jump when independently refreshed
heatmap and skeleton data briefly disagree.

## Heatmap Data Adapter

The Conversation signature already provides:

- Conversation ID;
- first and last dated-message strings;
- total message count;
- a continuous list of `ConversationSignatureMonth` counts.

A thin pure adapter can:

1. parse the first and last dates already normalized in graph storage;
2. group `ConversationSignatureMonth` values by year;
3. emit twelve `MonthData` values per `YearRow`;
4. mark months before the first activity month as `notYetStarted`;
5. map other zero counts to `empty`;
6. call `MonthIntensity.fromMessageCount()` for populated months; and
7. retain the Conversation ID as the renderer's navigation context value.

No new query/provider is required for month counts. Do not extract shared
domain types merely to remove this small presentation conversion.

If Conversations cannot legally import the renderer and its input contract
through the Messages public seam, first consider a narrow public export. Only
if that creates an inappropriate feature dependency should the render-only
calendar widget and presentation DTOs move to a neutral shared heatmap package.
Such a move must leave Messages-specific composition and navigation in
Messages, and Conversation-specific adaptation/navigation in Conversations.

## UX Behavior

### Unselected card

- Preserve the current title, optional chat hook, actions, compact activity
  glyph, summary, tags, hover behavior, dimensions, and click target.
- The compact glyph remains informational and does not gain month-level click
  targets.

### Selected card

- Preserve the same title, metadata, actions, summary, and tags.
- Replace only the compact glyph region with the full year x month renderer.
- Keep the card's selected background and border around the entire expanded
  content.
- Populated cells are interactive; empty and pre-start cells are inert.
- Tooltip and semantics should identify month, year, and exact message count.
- Clicking a month keeps the same Conversation selected and changes only the
  center stream anchor.

### Selection changes

- Selecting a different card changes the single flow-owned selected ID.
- The previous card collapses immediately through rebuild.
- The new card expands immediately and drives the message pane.
- Do not keep multiple expanded rows.

### Visible-month outline

Defer continuous visible-month outlining in the first slice.

The shared renderer already supports `selectedMonthKey`, and Messages already
has `CurrentVisibleMonthForScope`. `ConversationMessagesView` does not publish
to that provider today, while the Conversation list would need a sanctioned
way to consume it. Adding that cross-surface coordination is separable from
the required month jump. First prove renderer reuse, branch-correct anchoring,
and dynamic layout. Add visible-month synchronization later if it materially
improves orientation.

## Accessibility And Pointer Targets

The renderer currently paints 12-14 pixel cells and attaches gestures directly
to those bounds. That is visually compact but may be too small as a comfortable
pointer target.

Implementation should preserve the visual cell grid while evaluating a larger
transparent hit region that does not disturb the fixed column layout. It should
also add semantic labels for populated cells and ensure empty cells are not
announced as actions. Suggested wording:

```text
March 2018, 246 messages. Jump to first message in this month.
```

Keyboard activation and focus traversal should be tested if the current
gesture-only implementation is extended. Do not solve accessibility by
creating a separate renderer.

## Layout Findings

The main list and Contact list both use variable-height `ListView` children;
neither declares fixed item extents. Selected-card expansion is therefore
structurally supported.

The Contact list is constrained to a 360-pixel maximum height in its current
Messages cassette use. A long year range may occupy much of that viewport, but
the list remains scrollable. Manual validation should check:

- whether the selected row can remain legible without nested internal
  scrolling;
- whether tapping a newly selected row leaves enough of it visible;
- whether switching selection causes surprising scroll displacement;
- whether action buttons remain reachable; and
- whether the full twelve-column grid fits the canonical 296-pixel card.

Do not add an internal heatmap scroller or fixed expansion cap without observed
evidence. Those mechanisms would complicate a narrow reading rail and pointer
navigation.

## Existing Tests To Extend

- `test/features/conversations/presentation/widgets/conversation_signature_card_test.dart`
- `test/features/conversations/presentation/view/conversation_messages_view_test.dart`
- `test/features/conversations/application/sidebar_cassette_spec/resolver_tools/conversation_navigation_actions_provider_test.dart`
- `test/features/conversations/application/contact_conversations/contact_conversation_signatures_provider_test.dart`
- `test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart`
- `test/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view_test.dart`
- `test/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget_test.dart`
- `test/essentials/conversation_graph/application/conversations/conversation_reader_test.dart`
- `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart`
- `test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart`

## Explicit Answers To Opening Questions

### Is the Contact heatmap reusable?

Yes. `CalendarHeatmapTimelineWidget` is already callback-driven and independent
of navigation. Reuse it directly or through a thin adapter. Do not duplicate
its renderer. `MessageHeatmapContent` is more page/cassette-specific and should
not be embedded wholesale in a Conversation Card.

### Can month navigation reuse an existing message-jump API?

Yes. Resolve the first matching skeleton entry with `indexForMonth()`, then
reuse the existing exact-message anchor carried into `ConversationMessagesView`
and consumed by `MessageEvidenceTimelineView`.

### What if the target is not currently loaded?

The lightweight skeleton is fully materialized, and the target row does not
need to be hydrated before positioning. `ScrollablePositionedList` jumps to the
skeleton index; the normal row provider then hydrates the visible message.

### Should the visible month receive an outline?

Defer it. The renderer supports one, but Conversation visible-month publishing
and list consumption are not currently wired. This is not required for the
primary navigation benefit.

### Should selecting another Conversation collapse the previous one?

Yes, immediately. Derive expansion solely from the one flow-owned selected
Conversation ID.

### Does expansion create layout or scrolling concerns?

It creates dynamic-height and viewport-displacement concerns, especially in
the constrained Contact list, but no current fixed-extent assumption blocks it.
Validate before adding complexity.

### Should the two list contexts differ?

No product reason was found. Both use `ConversationSignatureCard` and the same
activity model. Their semantic navigation actions must remain branch-aware,
but presentation and month behavior should match.
