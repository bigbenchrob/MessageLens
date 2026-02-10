---
tier: project
scope: proposal
owner: agent-per-project
last_reviewed: 2025-12-24
source_of_truth: doc
links:
  - ../../40-FEATURES/messages/message-display-flow-walkthrough.md
  - ../ordinal-index-all-messages/PROPOSAL.md
  - ../ordinal-index-all-messages/DESIGN_NOTES.md
tests: []
---

# Feature Proposal: Global Messages Timeline (All Messages)

## Summary
Add a **Global Messages** experience: “every message I have ever sent to or received from anyone”, browsable as a single chronological timeline with:
- **Search-first** workflows (most important)
- **Heatmap/month jump** (second)
- **Smooth browsing** via ordinal-skeleton + hydration (same core architecture as contact messages)

This feature reuses the existing index strategy (global `message_index`) so the UI can scale to very large datasets without loading full message payloads upfront.

## User Motivation / Use Cases

### Search across unknown senders
- “Find the Instant Pot receipt” without knowing the phone/email; search text + jump to Aug 2023.
- “Jerry’s Tiki Hut” — recall a person/event by phrase.

### Time-window browsing
- “Jump to July 2020 and browse around.”

### Drill-down (future)
- From an interesting message: “show this thread/chat” or “show surrounding context”.

## Goals (v1)

### Must-have
- Global timeline reachable via ViewSpec navigation.
- Ordinal-skeleton list + per-row hydration (same mental model as contact messages).
- Search results view with good context:
  - correspondent display name + handle
  - timestamp
  - snippet/highlight
  - action: “jump to this in timeline”
- Heatmap/month jump to reposition the timeline.
- UI stability for large data: no scroll jitter during hydration.

### Should-have (still v1, if inexpensive)
- “Peek context” for a message: show ±N messages around a selected message.
- Lightweight filters:
  - has attachments
  - from me / from others
  - unknown senders only

## Non-Goals (v1)
- Full chat thread view restoration (chat UI remains intentionally removed for now).
- Building a complete faceted search UI with many chips/fields; keep constraints minimal.
- Any changes to import/migration pipelines unless required by missing index data.

## Proposed UX / Presentation

### Timeline rows
Same message bubble/attachment cards as contact messages, plus a **prominent correspondent label**:
- Display name (best available)
- Handle (phone/email) when ambiguous

### Modes
- **Browse mode:** scrollable ordinal timeline.
- **Search mode:** list of matches with context + jump.

## Architecture (matches the “VM + helpers” pattern)

We will replicate the same folder semantics as contact messages:
- `presentation/view/` — dumb global timeline view
- `presentation/view_model/global_messages/`
  - `global_messages_view_model.dart` — coordinator/facade
  - `jump/` — ordinal state + jump helpers
  - `hydration/` — ordinal → hydrated list item

Key constraint: **the view depends on the view model**, not on scattered providers.

## Data & Indexing

Expected backing index:
- `working.db: message_index` (global ordering)

We already have:
- `lib/features/messages/infrastructure/data_sources/message_index_data_source.dart`

Open questions:
- Confirm whether we should use `message_index.monthKey` for global month jump or compute month keys on the fly.

## Risks
- Performance at scale: global dataset could be 10x contact scope.
- Ambiguity: same person across multiple handles; correspondent display must be clear.
- Search result explosion: must not block UI; need sensible limits + paging.

## Scope Decisions Needed (sign-off)
Pick the v1 scope:
1) **A — Minimal v1:** search + browse + heatmap month jump (no extra filters).
2) **B — Practical v1:** A + 2–3 quick filters (attachments / from-me / unknown senders).
3) **C — Power v1:** B + “peek context” around a message.

## Acceptance Criteria
- Global timeline loads and scrolls smoothly on large datasets.
- Search can find messages from unknown senders and navigate to the right timeframe.
- Month jump reliably repositions without jitter.
- Lint clean; provider + DB access rules respected.
