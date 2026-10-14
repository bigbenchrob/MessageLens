# MessageLens — Feature 34
## Response 103 — Reconstruction-Gap Audit Checkpoint and Canonical Rich-Text Semantic Projection

Date: 2026-10-14

## Outcome

Prompt 103 completed. The production `MessageRichTextEnricher` was first
characterized unchanged, then its deterministic per-record normalization
decision was extracted to one synchronous, typed, dependency-free sibling
projection. The existing enricher remains the only production consumer and
retains every stateful and operational responsibility.

No populated reconstruction witness, graph/FTS refactor, destructive Start
Fresh behavior, AppCzar jurisdiction change, production AppCzar activation,
build, app launch, or live-data qualification was performed.

## Preflight and prior checkpoint

- Repository: `/Users/rob/Development/FlutterProjects/remember_every_text`
- Branch: `fix/onboarding-import-stuck-state`
- Starting HEAD: `cd2cdff92169683cc991cc5b7c22653e83b1dd3f`
- Starting upstream relation: synchronized, `0/0`
- Starting tracked worktree and index: clean
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- This branch was checked out in exactly one worktree.
- Required ancestry checkpoints were present:
  - `b788c07e0bfead2e67f47027ff43fdf50423f494`
  - `540a52c908724629cefbb7ee4db113509a9edd99`
- Prompt 102 and Response 102 were already committed and pushed together at
  starting HEAD, subject `docs(appczar): audit populated reconstruction gaps`;
  no duplicate checkpoint was created.
- All unrelated untracked files were preserved.

The external pre-edit source manifest contained 3,945 files under `lib/`,
`rust/`, and `test/` (excluding Finder `.DS_Store` metadata):

- file: `/private/tmp/messagelens_prompt103_source_manifest_before.txt`
- SHA-256:
  `8dc42b981e146f07057e52bd0717b0d9b5e800ede15a5d1e2081500221879e57`

## Instructions and evidence reviewed

The work was reviewed against:

- global agent guardrails and the project documentation index;
- shared Dart, Flutter widget, and Riverpod rules;
- `10-DATABASES/00-all-databases-accessed.md`;
- `10-DATABASES/01-db-import.md`;
- `10-DATABASES/10-group-import-working.md`;
- `10-DATABASES/13-apple-timestamp-conversion.md`;
- `10-DATABASES/INVIOLATE_RULES.md`;
- `01-PROJECT/02-architecture-overview.md`;
- `25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md`;
- `25-ONBOARDING-AND-ARCHIVE/60-reimport-and-ongoing-sync.md`;
- the canonical MessageLens Project Conformance Audit Standard;
- Responses 92, 94, and 102 and the source-projection checkpoints leading to
  Prompt 103;
- the actual enricher, ledger APIs and SQLite implementation, message
  extractor port, Flutter Rust Bridge boundary, Rust attributed-string
  decoder, schema, and existing synthetic tests.

## Actual production call graph before editing

The observed flow was:

```text
MessageRichTextEnricher.enrichMissingText()
  -> ImportLedger.messageTextEnrichmentWindow()
  -> MessageExtractorPort.isBlobExtractionAvailable()
  -> ImportLedger.readMessageTextEnrichmentPage()
  -> _partitionCandidatesByBlobBytes()
  -> ImportLedger.readMessageTextEnrichmentBlobs()
  -> MessageExtractorPort.extractMessageTextsFromBlobs()
       -> existing Flutter/Rust bridge
       -> existing Rust typedstream decoder
  -> ImportLedger.writeTransaction()
       -> trim decoded text in Dart
       -> conditional UPDATE messages.text
          WHERE ss_id = ? AND text IS NULL
  -> progress, anomaly, and page-metric publication
```

The only persisted field this stage can change is `messages.text`.

### Candidate and resource contract

- Existing non-null `messages.text` rows are not candidates.
- A candidate requires an attributed-body blob and lies inside the supplied
  source occurrence and frozen high-water window.
- Candidate query pages remain bounded at 500 rows.
- Decoder batches retain the approximate 8 MiB page byte target.
- An individual attributed body remains bounded at exactly 8 MiB; one byte
  over is excluded before materialization/decoder invocation.
- Rows stay ordered by source-scoped `ss_id`.
- Loaded blob length must exactly match the ledger-reported expected length
  before the blob reaches the decoder.
- Candidate count and high-water are frozen before work. A non-empty window
  without a high-water identity, overrun, or final processed-count mismatch
  remains a systemic fail-closed error.

### Decoder and error contract

- Decoder availability is a run-level/systemic prerequisite.
- Rust retains typedstream parsing and its existing accepted-output rules.
- Rust/bridge per-record error or panic conversion is represented to Dart by
  absence of an extracted value for that work ID.
- Dart retains the final `trim()` required by the existing extractor-port
  contract and supported fake seams.
- Missing, empty, whitespace-only, oversized, length-mismatched, and
  per-record decoder-omitted results count as missing extraction and as
  `richTextDecodeUnavailableCount` anomalies.
- Systemic decoder unavailability still throws
  `typedstream_decoder_unavailable`; it is not converted to a per-record
  result.

### Persistence and lifecycle contract

- Persistence remains within the existing per-page transaction.
- The update remains conditional on `text IS NULL`.
- A concurrent winner that makes text non-null is not overwritten; the
  resulting zero-row update is neither enriched nor missing.
- Only a successful conditional update increments the enriched count.
- Page commits, exceptions, rollback boundaries, cursor progression,
  cancellation checks, progress totals, anomaly totals, metrics, and source
  lifecycle remain owned by the enricher and ledger.

## Pre-edit actual-writer characterization

Before any production edit, the existing actual-enricher test was extended
only through supported synthetic in-memory ledger and fake decoder seams.
The pre-edit test file hash was:

`57a63faa3d3f66d67924d7e78931814a22a6ddeaac835470123650609da06a78`

The unchanged production enricher passed 22 tests. The characterization
covered:

- existing non-null text exclusion;
- valid decoded output and exact persisted normalization;
- empty and whitespace-only decoder output;
- exact 8 MiB admission and one-byte-over exclusion;
- loaded-length mismatch without decoder invocation;
- per-record decoder/error omission;
- systemic decoder unavailability;
- conditional update and concurrent-write zero-update behavior;
- null high-water and frozen-count mismatch failures;
- multiple pages, page-byte partitioning, retry/rollback evidence;
- ascending update order;
- cumulative progress, anomaly totals, and page metrics.

One test-helper compile failure occurred while first expressing a nullable
callback pattern. It was corrected in test scaffolding before the valid
22-test pre-edit baseline was accepted; no behavior expectation was changed.

## Extracted canonical semantic projection

Created:

`lib/essentials/source_scoped_import/application/messages/message_rich_text_semantic_projection.dart`

The immutable input carries source-scoped identity, raw expected/loaded/limit
facts, and exactly one typed decoder fact:

- `MessageRichTextDecoderResult(text)`; or
- `MessageRichTextDecoderFailure(kind)` with typed kinds for over-limit input,
  loaded-length mismatch, or absent decoder text.

The synchronous pure function `projectMessageRichTextSemantics()` returns one
typed outcome:

- `PersistMessageRichText(normalizedText)`;
- `EmptyMessageRichText`; or
- `FailedMessageRichText(failureKind)`.

It has no imports, I/O, database, filesystem, decoder invocation, Riverpod,
Flutter, clock, future, stream, global state, or mutation capability. It trims
only a supplied decoder result and classifies it as persistable or empty; it
preserves supplied typed failures.

The sole production consumer edge is:

```text
MessageRichTextEnricher
  -> projectMessageRichTextSemantics()
```

The enricher invokes it exactly once per candidate on the existing path. The
superseded importer-local `extracted[id]?.trim()` decision was removed.

## Unchanged ownership and parity

The following remain unchanged in production ownership and behavior:

- source query and candidate eligibility;
- frozen high-water/count identity;
- 500-row query paging;
- 8 MiB page target and individual blob ceiling;
- blob reads and expected-length admission;
- Rust and Flutter Rust Bridge source and generation;
- typedstream parser/dependencies and accepted native output;
- systemic decoder availability and failure;
- page transaction and rollback behavior;
- `ss_id` ordering and cursor movement;
- conditional `messages.text IS NULL` update;
- zero-update race accounting;
- progress, anomaly, metric, cancellation, exception, and lifecycle behavior;
- schemas, migrations, graph/FTS, archive/payload behavior, AppCzar, and UI.

The unchanged actual-enricher characterization passed after extraction with
the same deterministic persisted text, non-updates, failures, ordering,
progress, anomaly, rollback, and lifecycle expectations.

## Tests and mechanical enforcement

Added direct pure-projection coverage for normalized persistence, empty and
whitespace outputs, identity preservation, and every typed failure kind.

Added one focused AST/import-boundary test that enforces:

- no imports in the projection;
- synchronous/non-generator implementation;
- no await, decoder, ledger read, transaction, or update operations;
- exactly one production import consumer;
- exactly one projection invocation in the enricher;
- trimming absent from the enricher;
- decoder invocation, blob reads, transaction, and update authority retained
  by the enricher.

## Validation evidence

All final results are attributable to implementation commit content:

- focused actual-enricher, direct projection, and AST tests: 31 passed;
- rich-text/source-scoped import and eight-projection regressions: 252 passed;
- graph/FTS regressions: 171 passed;
- targeted AppCzar/archive/Operating regressions: 764 passed;
- full architecture suite: 640 passed;
- `flutter analyze`: no issues;
- complete deterministic Flutter suite: 3,324 passed, 1 skipped;
- formatter: 5 files inspected, 0 changed;
- `git diff --check`: clean;
- generated consistency: no generated source changed or required generation;
- staged hygiene: exactly five authorized implementation/test files;
- no build or live qualification was run.

Intermediate failures were retained literally:

1. The first sandboxed focused-test attempt stopped before executing tests
   because Flutter could not write `cache/engine.stamp` (`Operation not
   permitted`). The same command was rerun with the required filesystem
   access and passed.
2. The first analyzer run reported two info-level issues: directive ordering
   and a missing `const`. Both were corrected mechanically. Focused tests and
   analysis were rerun; the latter then reported `No issues found`.
3. A bare `dart format` invocation was unavailable from `PATH`; the pinned
   Flutter SDK Dart formatter was used and reported zero changes.
4. The initial non-escalated staging attempt could not create `.git/index.lock`.
   No index change occurred. The exact same five-file staging operation was
   rerun with Git metadata permission and succeeded.

The full-suite process was interrupted at the conversation/tool boundary after
launch, not in the test runner. On recovery its process had exited and its
attributable log ended at `+3324 ~1: All tests passed!`; the repository state
was unchanged, so the completed suite was not duplicated.

## Source-only manifest comparison

The post-edit manifest contained 3,948 files:

- file: `/private/tmp/messagelens_prompt103_source_manifest_after.txt`
- SHA-256:
  `590ad2024fa8e8087b8f176f50a2dd92b58125526c0eac9ae57fb9cc4636addc`

Its exact delta from the pre-edit manifest was limited to:

1. modified `message_rich_text_enricher.dart`;
2. new `message_rich_text_semantic_projection.dart`;
3. modified actual-enricher characterization test;
4. new direct projection test;
5. new AST architecture test.

No other source hash changed.

## Project Conformance Audit

Scope: starting HEAD plus the complete unstaged Prompt 103 implementation,
then the identical staged five-file delta. The audit explicitly inspected
reuse, layering/ownership, dependency direction, single source of truth,
project idioms, bounded work, privacy/logging, mutation authority,
state/error semantics, superseded code, tests, generated/dependency hygiene,
documentation agreement, and applicable UX impact.

Findings:

- BLOCKER: 0
- SHOULD FIX: 0
- OPTIONAL: 0
- NO ISSUE: the extraction is the smallest approved sibling seam; it does not
  duplicate decoder policy or create a second writer/reader/authority.
- NO ISSUE: bounded reads, memory ceilings, ordering, transactions, and
  conditional mutation remain with their existing owners.
- NO ISSUE: no new logging, user-content retention, dependency, generated
  output, schema, platform, UI, release, or authority surface exists.
- NO ISSUE: behavioral characterization and AST tripwires protect both output
  parity and the intended dependency boundary.

PROJECT CONFORMANCE: PASS

## Checkpoints and final Git state

Implementation checkpoint:

- `e340bdca0c6b8af9d40ab312a7f455d2fd9910db`
- `refactor(import): extract rich-text semantic projection`
- pushed normally to `origin/fix/onboarding-import-stuck-state`

The separate Prompt 103/Response 103 documentation checkpoint follows this
record. At final handoff the branch/upstream relation, exact documentation
commit, tracked worktree/index state, submodule state, and preserved unrelated
untracked inventory are reverified and reported.

## Next narrow evidence milestone

The next milestone may investigate another specifically identified
post-import deterministic transformation or may design the composition of the
already-qualified projections into a populated reconstruction witness. It may
not claim full reconstruction equivalence, activate destructive Stage 2C, or
activate production AppCzar until those separately bounded milestones are
implemented and qualified.

RECONSTRUCTION-GAP AUDIT CHECKPOINTED: YES

ACTUAL RICH-TEXT ENRICHER CHARACTERIZED BEFORE EDITS: YES

CANONICAL PER-RECORD RICH-TEXT SEMANTIC PROJECTION PURE AND SHARED: YES

RUST DECODER AND RESOURCE/ERROR POLICIES UNCHANGED: YES

RICH-TEXT PERSISTED OUTPUT, ANOMALY, PROGRESS, AND ERROR PARITY: PASS

FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT NARROW RECONSTRUCTION-EQUIVALENCE MILESTONE: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
