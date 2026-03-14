---
tier: feature
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./RETROSPECTIVE.md
  - ../../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
tests: []
---

# Design Notes — Orphaned Messages / Unlinked Source Content

## Core Principle

Preserve source truth without inventing thread membership.

That means:

- import the source record
- preserve its content and attachments
- mark it as unlinked
- surface it in a dedicated path
- do **not** coerce it into the normal chat model

## Why Dedicated Tables Are Favored

### Rejected primary approach: synthetic chat assignment

Do not create:

- a fake global orphan chat
- a per-handle synthetic chat
- a nullable chat relationship shoved into existing thread-oriented providers without clear boundaries

Reason:

- this fabricates source meaning the database does not prove
- it risks contaminating existing message/chat assumptions
- it makes future debugging harder because the imported shape no longer mirrors the source anomaly

### Implemented approach: dedicated orphan/unlinked storage

Benefits:

- explicit separation from normal thread-linked messages
- safer migration and provider boundaries
- clearer audit logging
- cleaner user messaging in the UI

Status:

- **Approved** for this feature

## Suggested Data Shape

### Ledger layer

Current tables:

- `recovered_unlinked_messages`
- `recovered_unlinked_message_attachments`

Fields should preserve:

- source rowid
- guid
- sender handle linkage where available
- service
- timestamps
- plain text
- `attributedBody`
- decoded / recovered text if extracted
- item type
- association fields (`associated_message_guid`, etc.)
- batch metadata

### Working layer

Current tables:

- `recovered_unlinked_messages`
- `recovered_unlinked_attachments`

Fields support:

- browse ordering
- search
- hydration of text/media rows
- explicit separation from normal chat-linked content
- attachment hydration by recovered message GUID

## Conversation Reconstruction Heuristic

Recovered browsing now distinguishes between two classes of records:

1. **Directly attributable recovered rows**
  These still retain sender identity through surviving handle linkage or sender address.

2. **Best-guess nearby outgoing context**
  These are outgoing recovered rows that have lost handle linkage but sit near attributable recovered rows in time and service.

The current UI uses that second class only as labeled contextual reconstruction. It does not promote those rows into the normal chat model or claim that Apple proved their original chat membership.

## Suggested Feature Boundary

This should behave like a distinct feature surface rather than a side effect bolted onto the existing messages feature.

Recommended split:

- infrastructure: import and migration storage/query support
- application: browse/search/use-case orchestration for unlinked records
- presentation: dedicated list/search UI

Approved product framing:

- this is a special category outside the normal contact → handle → chat → message flow

## ViewSpec / Navigation Direction

The feature should enter through a dedicated ViewSpec declaration rather than a direct widget reference.

Likely shape:

- a new spec under the messages family, if the feature is conceptually message browsing
- or a standalone spec if the app treats it as a diagnostics/recovered-content utility

Recommendation:

- keep it conceptually close to messages, but visually separated as quarantined content

## Search Strategy

Implemented v1:

- dedicated search inside the unlinked-messages surface only

Why:

- avoids confusing main search semantics
- keeps result labeling simple
- reduces cross-feature coupling in phase 1

Future option:

- integrate into broader global search with an explicit “Unlinked” badge/filter

Status:

- dedicated recovered browsing is implemented
- broader recovered search is still a follow-up concern

## Sparse Artifact Strategy

There are roughly `434` sparse artifact rows with:

- no plain text
- no `attributedBody`
- no attachment join

These should not be dropped, but they also should not dominate the main unlinked-content experience.

Recommended v1 handling:

- preserve them in storage
- expose them behind an advanced toggle, separate tab, or secondary section

Status:

- **Approved direction**: keep sparse artifacts preserved but lower-priority / advanced for now

## Audit Logging Requirements

The logs should evolve from “dropped orphan rows” to “preserved orphan rows” diagnostics.

Recommended counters:

- total source orphan rows
- preserved orphan rows
- orphan rows with text
- orphan rows with `attributedBody`
- orphan rows with attachment joins
- sparse artifact rows

## What This Changed Conceptually

Before this work, the app behaved as though `chat_message_join` determined whether a source message was worth surfacing.

After this work, the app treats `chat_message_join` as only one visibility path through Apple's data model. When that path is gone but source content remains, the app preserves and exposes the record instead of treating it as absent.

## Implementation Sequence Recommendation

1. approve storage model
2. implement ledger preservation
3. implement working projection
4. add provider/query layer
5. add dedicated ViewSpec/UI surface
6. expand audit logs and tests

This keeps the riskiest schema decisions up front and avoids building UI on top of unstable storage assumptions.