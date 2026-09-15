---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2026-09-15
links:
  - ./CHARTER.md
  - ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: domain-data-map
status: current
last_updated: 2026-09-15
---

# Domain & Data Map - Messages

This document describes the graph-era message evidence implementation. Older
contact-only and `working.db` ordinal-timeline docs were superseded by the
Message Evidence Spine.

## Core Entities

- **MessageEvidenceScope:** selects the logical message universe: global,
  contact, handle-filtered contact, conversation, handle/unfamiliar source,
  recovered/orphan, or search context.
- **Message evidence skeleton:** lightweight full-scope graph skeleton of
  `message_ss_id`, timestamps, and ordinal/month navigation facts.
- **Hydrated evidence row:** visible-window graph evidence including text,
  sender display identity, semantic badges, archive/media evidence, URL
  previews, and overlay user intent.
- **Canonical identity:** `message_ss_id` / `ss_id`, not legacy working row ids
  or GUIDs.

## Ordering Model

Timeline-like scopes still use the core invariant proven by the legacy ordinal
model:

- full lightweight skeleton first
- local hydration second
- heatmaps and jumps coordinate with the full skeleton
- row bodies/media hydrate near the viewport
- limits apply to hydration windows/previews, not selected scope size
- pagination is not timeline navigation

## Canonical Files

- Evidence spine:
  `lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart`
- Shared evidence presentation:
  `lib/features/messages/presentation/widgets/message_evidence/`
- Evidence views:
  `lib/features/messages/presentation/view/*_evidence_view.dart`
- Graph message repository:
  `lib/essentials/conversation_graph/infrastructure/repositories/message_graph_repository.dart`
- Attachment evidence boundary:
  `lib/features/attachments/application/attachment_resolver_provider.dart`

## Supporting Tables

| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `macos_import_ss.db` | `messages` | Source facts/provenance ledger. | Preserves source row id, GUID metadata, raw semantics, attributed body, and enrichment source facts. |
| `working_ss.db` | `messages` | Lean app graph message rows. | Uses `ss_id` as canonical row identity. |
| `working_ss.db` | `chat_to_message` | Canonical conversation/message edges. | Drives conversation scopes and timeline skeletons. |
| `working_ss.db` | `message_to_attachment` | Canonical message/attachment edges. | Drives attachment evidence hydration. |
| `working_ss.db` | contacts/handles/aliases | Identity graph used to resolve sender/contact labels. | User override labels merge from overlay at read time. |
| `user_overlays.db` | message annotations/saved/tag rows | Durable user intent. | Read through graph evidence/overlay repositories at read time; projection never reads overlay. |

Retired `working.db` tables may remain as historical cleanup / diagnostic
storage, but ordinary message UI must not depend on them.

## External Inputs

- Source-scoped import/project lifecycle populates `macos_import_ss.db` and
  `working_ss.db`.
- Rust attributed-body extraction enriches missing text in the import ledger
  before projection. Candidate metadata is keyset-paged by frozen `ss_id`
  high-water, payloads are byte-bounded, and successful sub-pages are durable
  checkpoints; no message evidence scope performs corpus-wide extraction.
- Overlay repositories provide saved/tag/annotation intent at read time.

## Downstream Consumers

- Message center-panel evidence views for global, contact, handle,
  conversation, recovered, and search-result contexts.
- Sidebar heatmaps, conversation signatures, recovered-message navigators, and
  unfamiliar-source views.
- Graph search under `lib/essentials/search`.

## Data Contracts

- `message_ss_id` is canonical message identity for graph-backed evidence.
- Attributed-body decoder work and text persistence use that same source-scoped
  `ss_id`; bare Apple source ROWIDs never identify work across sources.
- Timeline-like scopes preserve the full logical selected message universe
  before row hydration.
- A standalone handle/unfamiliar-source scope means messages whose canonical
  sender is that handle. Timeline enumeration, row hydration, header counts,
  and scoped search must use that same sender relationship. A
  `chat_to_handle` edge is not required because valid sender evidence can exist
  without recovered chat membership.
- Source-specific scopes are allowed; source-specific message renderers are not.
- Destructive reset/rebuild flows must not leave stale evidence scopes reading
  partially cleared databases.
