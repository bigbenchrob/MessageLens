---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: code
links:
  - ./01-overview.md
  - ./11-rust-message-extractor.md
  - ./12-bounded-message-import-and-rich-text-enrichment.md
  - ../25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md
  - ../25-ONBOARDING-AND-ARCHIVE/60-reimport-and-ongoing-sync.md
tests:
  - ../../../test/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator_test.dart
  - ../../../test/essentials/source_scoped_import/application/messages/message_importer_test.dart
  - ../../../test/essentials/source_scoped_import/application/messages/message_rich_text_enricher_test.dart
---

# Source-Scoped Import and Graph-Build Orchestration

This document describes the current production orchestration path. The deleted
legacy `ImportOrchestrator` that populated `macos_import.db` is not a runtime
architecture and must not be used as the model for new work.

## Production Ownership

| Responsibility | Owner |
| --- | --- |
| Import source facts into `macos_import_ss.db` | `essentials/source_scoped_import` importers |
| Decode and persist missing attributed-body text | `MessageRichTextEnricher` plus Rust FFI decoder |
| Sequence live/initial/reimport source import and graph projection | `ConversationGraphBuildOrchestrator` |
| Import one registered historical Messages source | `SourceScopedArchiveImportService` |
| Project historical source facts | graph-layer archive import service |
| Detect live source growth | `ChatDbChangeMonitor` |
| Admit mutation and prevent overlap | `ArchiveMutationCoordinator` and graph maintenance execution authority |
| Persist setup/reimport operation status | Onboarding operation snapshot controller |

The Conversation Graph orchestrator composes individual source-scoped
importers at one approved application boundary. Feature code and widgets must
not acquire importers directly or reproduce their ordering.

## Ordered Graph Build

The live, first-run, and reimport graph lifecycle runs:

```text
chats
-> handles
-> contacts and contact channels
-> messages
-> rich-text extraction and persistence
-> attachments
-> chat/message relationships
-> chat/handle relationships
-> message/attachment relationships
-> graph nodes and topology projection
```

Each source-import work unit emits typed progress. Rich-text extraction and
rich-text persistence are distinct observable substages even though one
enricher coordinates them. Graph projection remains downstream of source fact
preservation.

The message and rich-text stages are bounded by the canonical contract in
[`12-bounded-message-import-and-rich-text-enrichment.md`](12-bounded-message-import-and-rich-text-enrichment.md).
The orchestrator must not turn those page-local operations back into a
whole-corpus collection.

## Live Synchronization

`ChatDbChangeMonitor` is activated during application startup and:

1. primes from current source/import evidence;
2. performs an immediate catch-up probe;
3. polls `MAX(message.ROWID)` in live `chat.db` every 15 seconds;
4. coalesces growth with a 350 ms debounce and an in-flight guard;
5. invokes the same source-scoped graph build lifecycle;
6. archives the newly imported graph source range; and
7. bumps graph/message data-version signals after success.

The monitor also schedules the separate periodic graph attachment sweep. It
does not open a second import path, invalidate live database connections, or
compose importer/projector internals itself.

Rows above a message import run's frozen high-water are deferred to the next
monitor cycle. That is normal incremental behavior, not lost work.

## Historical Archives

`SourceScopedArchiveImportService` registers or reuses one canonical historical
source ID, then runs source-scoped handles, chats, messages, attachments,
relationships, and source-limited rich-text enrichment. Decoder and persistence
identity is the canonical `ss_id`; a source-local Apple `ROWID` cannot collide
with the same ROWID from another source.

The graph layer projects the imported source afterward. Archive import never
consults overlay intent and does not reset the attachment archive.

## Progress and Recovery

The graph build publishes transitions and exact row-oriented progress. The
Onboarding layer maps them to durable operation substages such as
`importingMessages`, `extractingRichText`, `persistingRichText`, and the
individual projection phases.

If the process ends:

- committed message pages remain in the source-scoped ledger and establish the
  next source-row continuation frontier;
- committed rich-text pages no longer match the missing-text predicate;
- an uncommitted bounded page is replayed;
- relationship import and graph projection converge idempotently on relaunch;
  and
- the persisted operation snapshot remains exact recovery evidence even when
  an older environment classifier can report the coarse
  `graphProjectionFailed` state.

Onboarding presents the safe continuation action. It must not calculate a
cursor by querying importer tables from presentation code.

## Failure Rules

- A source identity failure, required source-field failure, source database
  failure, unavailable run-wide decoder, or changed frozen window is systemic
  and stops the run with typed context.
- Optional interpretation failures are counted only where the domain has a
  truthful degraded representation.
- A malformed/oversized/undecodable attributed body remains a visible source
  message and contributes to the decode-unavailable anomaly count.
- Page failures preserve their original stack traces.
- No failure grants authority to delete overlay state or
  `attachment_archive/`.

## Retired Pipeline Boundary

The former `ImportOrchestrator`, `ImportContext`, table-importer registry,
`import_log`, and `macos_import.db` ledger mechanics survive only in historical
documents, old logs, or retired files. They are not an alternative production
path. `15-table-importers.md` and `02-import-migration-schema-reference.md`
remain explicitly historical references for interpreting that material.

Do not add a new legacy importer, rerun a deleted retired orchestrator, or
route current failure handling through retired import/migration logs.
