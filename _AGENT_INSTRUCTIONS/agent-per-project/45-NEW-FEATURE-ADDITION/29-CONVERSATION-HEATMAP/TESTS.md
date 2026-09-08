---
tier: project
scope: test-plan
owner: agent-per-project
last_reviewed: 2026-09-08
source_of_truth: draft
status: planning
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
tests:
  - test/features/conversations/presentation/widgets/conversation_signature_card_test.dart
  - test/features/conversations/presentation/view/conversation_messages_view_test.dart
  - test/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view_test.dart
  - test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart
  - test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart
---

# Conversation Heatmap Validation Plan

## Test Strategy

Tests should prove composition of existing authorities rather than validate a
new subsystem. The highest-value chain is:

```text
selected card month tap
  -> existing skeleton indexForMonth()
  -> first matching message ID
  -> branch-correct exact-message anchor
  -> existing indexed timeline jump
```

Avoid tests that accidentally legitimize duplicated month resolution, copied
heatmap rendering, or eager message hydration.

## Pure Adapter Tests

Add focused tests for the thin Conversation activity adapter:

- returns no heatmap data when no valid dated activity exists;
- produces one `YearRow` per inclusive calendar year;
- produces January through December in every row;
- marks months before the first Conversation month as `notYetStarted`;
- marks zero-count months after the start as `empty`;
- preserves sparse-dot and count-bin semantics through
  `MonthIntensity.fromMessageCount()`;
- preserves per-month counts, total count, first/last dates, and maximum count;
- handles a Conversation beginning late in a year and ending early in another;
- does not extend past the Conversation's last dated year;
- handles a one-month Conversation;
- handles malformed optional date metadata without inventing activity.

## Conversation Card Widget Tests

Extend
`test/features/conversations/presentation/widgets/conversation_signature_card_test.dart`:

- unselected card still renders `_ConversationMonthGlyph` behavior;
- selected card renders exactly one `CalendarHeatmapTimelineWidget`;
- selected card does not render the compact glyph simultaneously;
- full grid uses the supplied existing activity color scale;
- card selection background encloses title, metadata, and grid;
- populated month tap reports Conversation ID, year, month, and count to the
  caller-owned action boundary;
- empty and pre-start month cells do not invoke navigation;
- tooltip/semantics include month, year, and count;
- selecting a different card collapses the prior card in a list harness;
- title, optional chat hook, trailing actions, summary, and tags remain visible
  in expanded state;
- expanded natural height is stable at canonical width.

Retain all existing compact-card layout and metric tests.

## Month Lookup Tests

Extend tests around `MessageEvidenceTimelineSkeleton` or the new narrow action
boundary:

- January-December lookup returns the first matching entry in ascending order;
- several messages in one month still select the earliest entry;
- exact year is respected when month numbers repeat;
- a missing month does not dispatch an anchor;
- a positive but stale heatmap cell whose skeleton no longer contains the
  month does not fall back to latest;
- null-dated skeleton entries do not become month targets;
- the existing `indexForMonth()` implementation is called/reused rather than
  duplicated by a second resolver.

## Navigation Action And Flow Tests

Extend:

- `test/features/conversations/application/sidebar_cassette_spec/resolver_tools/conversation_navigation_actions_provider_test.dart`
- `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart`
- `test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart`

Cover:

- main Conversations month selection preserves the Conversations branch;
- Contact -> Conversations month selection preserves contact ID and
  Conversation projection;
- both paths set the resolved `selectedConversationAnchorMessageId`;
- changing only the anchor for the same Conversation updates the projected
  `ConversationsSpec`;
- selecting another Conversation clears the previous anchor unless the new
  action explicitly supplies one;
- no month-only filter state is introduced;
- incompatible right-panel behavior remains governed by existing
  reconciliation.

## Message Timeline Tests

Extend:

- `test/features/conversations/presentation/view/conversation_messages_view_test.dart`
- `test/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view_test.dart`

Cover:

- resolved month anchor reaches `ConversationMessagesView` as an exact message
  anchor;
- the target row is the first row from the selected month;
- the timeline jumps directly to the target index;
- a target row not initially hydrated is loaded through the normal row
  provider once visible;
- no preceding intermediate message rows need to hydrate;
- the full Conversation skeleton remains present after the jump;
- ordinary local scrolling works before and after a month jump;
- an exact Show in conversation anchor continues to pulse/highlight as before;
- changing anchors within the same Conversation schedules a new jump.

## Existing Heatmap Regression Tests

Retain and run:

- `test/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget_test.dart`
- `test/features/messages/application/sidebar_cassette_spec/resolver_tools/global_messages_heatmap_provider_test.dart`
- `test/features/messages/application/sidebar_cassette_spec/resolver_tools/message_heatmap_navigation_actions_provider_test.dart`
- `test/config/theme/widgets/heatmap/activity_heatmap_color_scale_test.dart`

These should continue to prove:

- the existing activity palette and bins remain authoritative;
- selected outlines do not replace activity fills;
- global and Contact heatmap navigation remains unchanged;
- renderer reuse does not alter the current Messages cassette composition.

## Architecture Tests

Run `test/architecture/forbidden_imports_test.dart` after deciding the renderer
dependency seam. It must prove:

- no internal cross-feature import is introduced;
- no feature imports its own public barrel;
- navigation actions remain in approved files;
- no raw color literal or framework theme access is introduced;
- no new widget leaks into coordinator/resolver layers.

## Accessibility Validation

Automated/widget checks:

- populated cells expose button/action semantics;
- semantic labels identify full month name, year, message count, and action;
- empty/pre-start cells are not actionable;
- an expanded grid has a deterministic traversal order: year, then January
  through December;
- a larger hit region does not overlap adjacent month actions.

Manual checks:

- pointer target feels usable at normal macOS display scaling;
- tooltip appears without obscuring the surrounding year/month context;
- keyboard focus, activation, and focus indication are understandable;
- VoiceOver announcements distinguish populated and empty months.

## Layout And Visual Validation

Validate both light and dark modes:

- selected background remains visible in grayscale/luminance terms;
- primary title remains readable and does not rely on accent hue;
- heatmap colors preserve the established two-regime magnitude grammar;
- the card fits the canonical 296-pixel width;
- twelve month columns remain aligned for every year;
- long titles, chat hooks, tags, and trailing actions do not collide;
- selection changes do not leave multiple expanded rows;
- main Conversations list scrolling remains stable;
- Contact -> Conversations remains usable within its 360-pixel list viewport;
- year ranges of 1, 5, 10, and 15+ years remain legible.

## Large-Conversation Validation

Use a representative Conversation near 27,000 messages and record:

- skeleton load time and memory remain consistent with existing behavior;
- selected-card expansion performs no full-message hydration;
- a jump from the latest month to an early historical month is direct;
- only visible/near-visible message rows hydrate at the destination;
- repeated jumps do not accumulate row widgets or stale anchor state;
- switching Conversations during an in-flight lookup cannot navigate the newly
  selected Conversation using the old Conversation's result.

This is a behavioral/performance observation, not authorization to redesign
the evidence spine or introduce pagination.

## Manual Regression Checklist

- Main Conversations Browse selection.
- Main Conversations Favourites selection.
- Contact -> Conversations selection.
- Contact All Messages heatmap navigation.
- Global All Messages heatmap navigation.
- Search within a Conversation.
- Show in conversation exact-message navigation.
- Search result Conversation excerpt behavior.
- Recovered-message month navigation.
- Favourite and Tag controls on compact and expanded cards.
- New-message arrival while viewing an older month.

## Required Commands For The Later Implementation Phase

```bash
flutter test test/features/conversations/presentation/widgets/conversation_signature_card_test.dart
flutter test test/features/conversations/presentation/view/conversation_messages_view_test.dart
flutter test test/features/messages/presentation/widgets/message_evidence/message_evidence_timeline_view_test.dart
flutter test test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart
flutter test test/essentials/sidebar/application/sidebar_flow_state_provider_test.dart
flutter test test/architecture/forbidden_imports_test.dart
flutter analyze
```
