---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./11-rust-message-extractor.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../10-DATABASES/INVIOLATE_RULES.md
  - ../25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md
  - ../25-ONBOARDING-AND-ARCHIVE/60-reimport-and-ongoing-sync.md
  - ../45-NEW-FEATURE-ADDITION/32-TESTER-ARCHIVE-IMPORT-FAILURE/12-IMPLEMENTATION-AND-QUALIFICATION-CHECKPOINT.md
tests:
  - ../../../test/essentials/source_scoped_import/application/messages/message_importer_test.dart
  - ../../../test/essentials/source_scoped_import/application/messages/message_rich_text_enricher_test.dart
  - ../../../test/qualification/archive_import_memory_worker_test.dart
---

# Bounded Message Import and Rich-Text Enrichment

This is the canonical current architecture for source-scoped message ingestion
and attributed-body enrichment. It applies to initial setup, reimport, ordinary
live synchronization, and Historical Archives Mac Messages ingestion.

The production path does not materialize an eligible message corpus or rich-text
corpus as one Dart collection. Row, byte, native-parser, and transaction bounds
are explicit and independent of the total archive size.

## Ownership and Callers

```text
read-only chat.db source
    -> MessageImporter
    -> macos_import_ss.db messages
    -> MessageRichTextEnricher
    -> Conversation Graph projection
    -> working_ss.db
```

- `ConversationGraphBuildOrchestrator` owns the ordered live/initial/reimport
  graph build and its progress observations.
- `SourceScopedArchiveImportService` reuses the same message importer and
  rich-text enricher for one registered historical source. Its subsequent
  graph projection is owned by the graph-layer archive service.
- `ChatDbChangeMonitor` detects source growth and invokes the graph build
  lifecycle; it does not implement a separate import algorithm.
- Onboarding observes typed progress and persists operation truth. It does not
  query or mutate import internals to calculate progress.

## Source-Message Window and Pages

For one source, `MessageImporter.importNewMessages()`:

1. Reads the greatest already imported `source_rowid` for that `source_id`.
2. Opens the selected `chat.db` read-only and freezes the eligible
   `COUNT(*)` and `MAX(message.ROWID)`.
3. Reads keyset pages with the default, injectable size of 500:

   ```sql
   WHERE m.ROWID > :cursor
     AND m.ROWID <= :run_high_water
   ORDER BY m.ROWID ASC
   LIMIT :page_size
   ```

4. Selects only fields required by the import ledger. It must not regress to
   `m.*`; optional newer-schema columns are represented truthfully when absent.
5. Resolves association-target GUID evidence with page-local collections.
6. Writes the page in one import-ledger transaction.
7. Advances the in-memory cursor only after that transaction commits.

Rows added above the frozen source high-water are intentionally deferred to the
next ordinary incremental run. If the frozen count and pages cannot reconcile,
the run fails with a typed systemic error instead of silently declaring success.

The durable continuation frontier is the ledger's greatest committed
`source_rowid` for that source. Earlier committed pages survive a later page
failure; the uncommitted page is the largest unit replayed after retry.

## Rich-Text Candidate Window and Byte Pages

Rich-text enrichment remains a separate derivation stage. It never overwrites
existing plain text and never removes a message because its attributed body is
unusable.

`MessageRichTextEnricher`:

1. Freezes the eligible candidate count and maximum eligible `messages.ss_id`
   for rows where `text IS NULL AND attributed_body_blob IS NOT NULL`.
2. Reads keyset metadata pages, default 500 records, by
   `ss_id > cursor AND ss_id <= high_water ORDER BY ss_id LIMIT ?`.
3. Reads only `ss_id`, `source_rowid`, and
   `length(attributed_body_blob)` in that metadata step. The BLOB is not part
   of the candidate page.
4. Partitions each candidate page into decoder sub-pages targeting at most
   8 MiB of cumulative attributed-body bytes.
5. Excludes records above the 8 MiB per-record ceiling before BLOB
   materialization. The payload query itself uses a capped `substr` of maximum
   plus one byte so a changed or unexpectedly large record cannot cause an
   unbounded Dart allocation.
6. Decodes only that bounded map and persists successful non-empty results for
   the sub-page in one transaction using
   `WHERE ss_id = ? AND text IS NULL`.
7. Releases page-local collections, yields to the event loop, and continues.

The count/row and byte bounds serve different purposes. A 500-record metadata
page can be split into several decoder calls when its aggregate payload is
large. Neither value is an archive-wide extraction limit, and the removed
`extractionLimit` argument must not be reintroduced as a no-op safety claim.

## Source-Scoped Identity

Apple `ROWID` is local to one source database. It is not a globally unique
message key.

`SourceScopedRowKey.pack(sourceId, sourceRowId)` produces the canonical
`messages.ss_id`. Rich-text candidate maps, BLOB maps, native callback work
IDs, decoded results, and persistence predicates all use `ss_id`. A bare
`source_rowid` is retained only as source provenance and bounded progress
context.

Two historical/live sources may contain the same Apple `ROWID`; they must
still decode and persist independently. Do not key decoder work or persistence
by bare source row ID.

## Failure, Retry, and Record Fidelity

Message and rich-text persistence have related but distinct checkpoints:

- Message import checkpoints a committed source page. Retry derives its
  continuation frontier from committed source-scoped ledger rows.
- Rich-text enrichment checkpoints successful text persistence. On retry,
  successfully enriched rows no longer satisfy the candidate predicate.

A failure during decoding or before persistence replays the current bounded
decoder sub-page. A failure after its transaction commits retains that work.
An oversized, empty, malformed, or otherwise undecodable record remains in the
ledger with its original attributed-body evidence and increments the fixed
decode-unavailable anomaly count. The current run advances past it; a later run
may consider it again because `text` is still null.

Unavailable run-wide decoder capability is a systemic failure. A bad single
record is a contained anomaly. Neither case authorizes record suppression.

## Native Decoder Envelope

The Flutter Rust Bridge function `decodeTypedstreamBlob` delegates to
`crabstep` only after enforcing:

| Resource | Limit |
| --- | ---: |
| Input BLOB | 8 MiB |
| Typedstream control markers | 1,024 |
| Consecutive reference-like bytes | 1,024 |
| Resolved property depth | 256 |
| Resolved property nodes | 65,536 |

The resolved property walk is iterative. Decoder panics inside the accepted
resource envelope are caught and returned as errors. The Dart adapter catches
one-record decode errors, records an unavailable result for that work item,
and continues with later records.

See [`11-rust-message-extractor.md`](11-rust-message-extractor.md) for FFI,
packaging, and the legacy helper-process boundary.

## Progress and Diagnostics

Import progress reports exact completed and total units. Privacy-safe page
metrics include stage, outcome, page ordinal, row count, cumulative and total
work, total page BLOB bytes, largest page BLOB, and elapsed time. They exclude
message content, GUIDs, paths, and source row IDs.

The persisted Onboarding operation snapshot distinguishes message import,
rich-text extraction, and rich-text persistence. Support bundles export this
bounded status in `onboarding_operation.json`. Database-health schema `1.1.0`
also reports the remaining rich-text candidate count, aggregate candidate BLOB
bytes, and maximum candidate BLOB bytes through one aggregate SQL query; it
does not materialize or export a BLOB.

## Preservation Invariants

This pipeline writes only derived source-scoped import and graph data.

- It never reads overlay intent to decide import or projection.
- It never writes overlay state.
- It never deletes, moves, recreates, or mutates `attachment_archive/`.
- It never filters an anomalous source message out of the ledger merely
  because text, time, topology, or decoding is imperfect.
- Reimport/reset may remove only the separately enumerated rebuildable stores;
  it does not broaden this importer's authority.

## Qualification Record

The architecture was introduced for `0.2.111+129` and qualified with synthetic
25,000- and 150,000-candidate runs plus packaged-process `SIGKILL`/relaunch
rehearsals. The packaged 150,000-candidate run peaked at 150,080 KiB on the
available 24 GB host, with 4.0% peak growth for a six-fold corpus increase.
That demonstrates a plateau on the measured host; it is not a universal
numerical ceiling and does not satisfy the separate low-memory target-Mac gate.

The historical failure, remediation, and full qualification evidence remains
in
[`32-TESTER-ARCHIVE-IMPORT-FAILURE`](../45-NEW-FEATURE-ADDITION/32-TESTER-ARCHIVE-IMPORT-FAILURE/).

## Anti-Regression Rules

Do not:

- replace keyset pages with `OFFSET` paging;
- read the full eligible corpus before processing;
- select `m.*` from `chat.db.message`;
- include full BLOBs in candidate metadata pages;
- key decoder work by bare `source_rowid`;
- materialize a BLOB without the per-record cap;
- advance the message cursor before page commit;
- collapse extraction and persistence into an uncheckpointed corpus-wide unit;
- describe the compatibility helper's row limit as protection for the active
  FFI enrichment path; or
- treat a locally unavailable decode as permission to discard its message.
