---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2025-12-24
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ../../40-FEATURES/messages/message-display-flow-walkthrough.md
tests: []
---

# Design Notes — Global Messages Timeline

## Core Principle
Preserve the now-proven message-display structure:
- **Dumb view**
- **Single view model facade**
- `jump/` and `hydration/` helpers behind the facade

This keeps mental-model complexity bounded even as we add global-specific capabilities (filters, context peeks).

## Provider Responsibilities (intended)

### View model
- Owns search controller + debounce.
- Exposes:
  - ordinal state
  - search results
  - jump helpers (`jumpToLatest`, `jumpToMonthKey`, `jumpToMessageId`, etc.)

### Jump/ordinal provider
- Computes `totalCount` for all messages.
- Owns list scroll controller/listener.
- Implements:
  - month jump (monthKey)
  - jump to latest
  - jump to an ordinal

### Hydration provider
- `ordinal → messageId → message joins → GlobalMessageListItem`

Unlike contact messages, the hydrated row must include **correspondent labeling**:
- name (best available)
- handle/email/phone fallback


## Search: global-first
Global search should be treated as a first-class browsing mode.

Pragmatic v1 approach:
- Use the existing `SearchService` as the main entry point.
- Add a global search method that returns a compact result DTO which includes:
  - messageId
  - timestamp
  - correspondent label
  - a snippet/highlight (if available)
  - ordinal (or a reliable mapping method to reach the message in the global timeline)

## “Jump to search hit”
We should ensure a global search result can reliably move the timeline.
Options:
- Best: search returns `messageId`, then we map `messageId → ordinal` using the index.
- If `messageId → ordinal` is too slow, consider returning ordinal directly from search query.

## Filters (optional v1)
High-value, low-complexity filters:
- has attachments
- from me / from others
- unknown senders only

Represent filters as a small immutable object passed through the view model.
Keep the view simple: filter chips can come later.

## UI stability
Global view is especially sensitive to scroll jitter.
Rule:
- placeholders and hydrated tiles must keep height stable.

## Navigation / Future drill-down
We will add optional actions later:
- “peek context” (±N messages)
- “show chat thread” (requires reintroducing chat view or a thread-focused view)

These should remain downstream of the global timeline.
