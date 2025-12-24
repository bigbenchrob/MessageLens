---
tier: project
scope: phases
owner: agent-per-project
last_reviewed: 2025-12-24
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ../ordinal-index-all-messages/PHASES.md
tests: []
---

# Global Messages Timeline — Phase Plan

This plan intentionally mirrors the contact-messages architecture and reuses the existing global ordinal index work.

## Phase 0: Scope Confirmation
- Decide v1 scope: **A / B / C** (defined in `PROPOSAL.md`).
- Confirm the desired entry point in navigation (toolbar button, sidebar, menu, etc.).
- Confirm whether “unknown senders” needs the concept of contact linkage now or later.

## Phase 1: Data Contracts Verification
- Confirm `message_index` supports:
  - total count
  - ordinal → messageId
  - monthKey → firstOrdinal (if using month jump)
  - messageId → ordinal (for “jump to search hit”)
- Confirm corresponding message projection supports correspondent labeling:
  - “best display name” for sender/other party
  - handle/email/phone as fallback

## Phase 2: Providers (Jump + Hydration)
- Create `global_messages` view-model module:
  - `globalMessagesViewModelProvider`
  - `globalMessagesOrdinalProvider`
  - `messageByGlobalOrdinalProvider`
- Ensure `dbMaintenanceLockProvider` short-circuits global ordinal provider similarly to contact messages.

## Phase 3: Search Integration
- Add global search provider:
  - `globalMessageSearchResultsProvider(query, optional filters)`
- Ensure search results carry:
  - messageId
  - timestamp
  - correspondent label
  - snippet
  - ordinal (or enough to jump reliably)

## Phase 4: Dumb View Implementation
- Implement `MessagesGlobalTimelineView` (name TBD):
  - browse mode: `ScrollablePositionedList` backed by global ordinal state
  - search mode: list with “jump to” action
  - header indicates context (“All Messages”) + optional filter chips

## Phase 5: Navigation Wiring
- Add a ViewSpec entry for global timeline:
  - `MessagesSpec.globalTimeline(...)` (naming TBD)
- Wire into coordinator/view builder and add a reachable UI entry point.

## Phase 6: Stability + Performance Pass
- Ensure placeholders have fixed height.
- Ensure hydration doesn’t introduce scroll jitter.
- Tune hydration/subscription patterns to avoid rebuilding the whole list.

## Phase 7: Tests & Verification
- Provider tests:
  - ordinal provider boundary conditions
  - jump to month and jump to ordinal
  - db maintenance lock short-circuit
- Widget smoke tests (minimal):
  - renders empty
  - renders list
  - switches to search mode

## Phase 8: Documentation & Handoff
- Add `40-FEATURES/messages/` docs update (or new subfolder if needed) after shipping.
- Include a human-readable walkthrough for global messages (same pattern as contact messages).
