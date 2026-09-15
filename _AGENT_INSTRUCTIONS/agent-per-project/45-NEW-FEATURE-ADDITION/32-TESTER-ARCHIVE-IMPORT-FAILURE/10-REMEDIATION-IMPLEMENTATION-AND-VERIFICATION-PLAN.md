---
tier: project
scope: tester-archive-import-failure
owner: agent-per-project
last_reviewed: 2026-09-13
source_of_truth: implementation-plan
links:
  - ./00-REPORTED-EPISODE-EVIDENCE-AND-DIAGNOSIS.md
  - ../../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
  - ../../20-DATA-IMPORT-MIGRATION/11-rust-message-extractor.md
  - ../../25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md
  - ../../25-ONBOARDING-AND-ARCHIVE/60-reimport-and-ongoing-sync.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../10-DATABASES/INVIOLATE_RULES.md
  - ../../10-DATABASES/07-overlay-database-independence.md
  - ../../10-DATABASES/13-apple-timestamp-conversion.md
  - ../../55-READERS-INTEGRATORS-ORCHESTRATORS/30-INVARIANTS.md
---

# Tester Import Failure: Remediation, Implementation, and Verification Plan

## Status

Planning complete; implementation not started by this document. This plan is
based on the evidence and diagnosis in
[`00-REPORTED-EPISODE-EVIDENCE-AND-DIAGNOSIS.md`](./00-REPORTED-EPISODE-EVIDENCE-AND-DIAGNOSIS.md).

The release-blocking objective is:

> A first-run or historical-source import must process a corpus larger than the
> tester's 123,561 rich-text candidates with a bounded MessageLens working set,
> durable page-level progress, source-scoped identity, faithful anomaly
> preservation, and deterministic recovery after interruption.

This is a production-worthy, tester-visible correction. Implementation must
occur on a dedicated feature branch, include a `pubspec.yaml` version bump and
`CHANGELOG.md` entry, pass the specified gates, and preserve release bundle ID
and signing so existing Full Disk Access grants remain valid.

## 1. Non-negotiable invariants

The remediation must satisfy all of the following:

1. Import every source record. A missing, empty, large, or undecodable
   attributed body is an anomaly to preserve and report, never a reason to
   omit the message.
2. Keep rich-text enrichment as a distinct pipeline stage. Do not hide it
   inside `MessageImporter` or graph projection.
3. Use `DateConverter` for every Apple timestamp. Paging must not introduce
   alternate timestamp logic.
4. Preserve source occurrence identity with `ss_id`. Never use bare source row
   ID as a globally unique work key across multiple sources.
5. Write source facts only to the source-scoped import database and projected
   graph facts only to the graph database. Do not consult or write overlay
   intent during import or projection.
6. Do not add a long-lived database instance or bypass the existing central
   providers and semantic ports.
7. Never delete, move, recreate, or mutate `attachment_archive/` during retry,
   reset, recovery, migration, or testing.
8. Never delete a broad MessageLens data root as incident recovery.
9. Preserve idempotence: retrying a completed page must not duplicate source
   facts, topology, graph records, or user intent.
10. Keep ongoing live synchronization incremental. New messages must not cause
    rescanning or re-decoding of the full historical corpus.
11. Use only privacy-safe diagnostics. Do not log or export message text, blob
    bytes, contact values, attachment paths, or source paths.
12. All automated fixtures must use temporary or in-memory databases and
    synthetic, content-free records. Tester data must never enter the repo or
    test suite.

## 2. Scope decision

### Required for the corrective release

- Bound the source-message import query and transaction.
- Select only the exact source columns required by the importer.
- Bound rich-text candidate reads, decoder inputs, decoded-result retention,
  and persistence transactions.
- Persist each successful rich-text page before loading the next page.
- Make all-sources enrichment identity-safe.
- Preserve accurate cumulative progress and anomaly counts across pages.
- Add privacy-safe resource and stage diagnostics.
- Prove interruption recovery and a memory plateau with a production-scale
  synthetic fixture.

### Required if investigation demonstrates a single-record hazard

- Harden the Rust typedstream decoder against a single malformed record that
  can request disproportionate memory or CPU.
- If the parser cannot enforce a safe per-record resource boundary in-process,
  isolate decoding behind a bounded worker process and convert worker failure
  to an explicit row-local anomaly. The source message must still be retained.

### Valuable follow-ups, not substitutes for the memory fix

- Report the actual stopped substage (`richTextExtraction` or
  `richTextPersistence`) instead of reducing every incomplete build to
  `graphProjectionFailed`.
- Correct support-bundle build metadata so checked-in fallback values cannot
  masquerade as the installed version.
- Add aggregate pending-enrichment count and attributed-body size statistics
  to health output after a privacy review.

No graph schema, overlay schema, or UI redesign is required for the core fix.
A source-import schema change is also unnecessary unless investigation chooses
to persist a durable “decode attempted but unavailable” marker. That marker is
not part of the minimum safe correction.

## 3. Target processing model

### 3.1 Stable source-message run boundary

At the beginning of `MessageImporter.importNewMessages()`:

1. Read the ledger's existing per-source maximum row ID as today.
2. Read a source `MAX(message.ROWID)` and freeze it as this run's high-water
   mark.
3. Count rows in the inclusive run interval for a stable progress denominator.
4. Read the interval with keyset pages:

```sql
WHERE m.ROWID > :pageCursor
  AND m.ROWID <= :runHighWater
ORDER BY m.ROWID ASC
LIMIT :pageSize
```

Messages arriving above the frozen high-water mark remain for the next normal
incremental run. This prevents a moving target while guaranteeing eventual
import without suppressing records.

Use an initial internal page policy of 500 message rows. Keep the value named
and injectable in tests. Production-scale profiling may justify a different
number before release, but “all rows” and the current effective 200,000 limit
are forbidden defaults.

### 3.2 Exact source projection

Replace `m.*` with the exact columns consumed by `MessageImporter`. Preserve
`attributedBody`, because it is source evidence used by the later enrichment
stage. Return boolean presence expressions for `message_summary_info` and
`payload_data` rather than returning those blob bodies when the importer needs
only presence flags.

For each source page:

- resolve referenced association GUIDs for that page using the existing
  chunked lookup behavior;
- transform every row through the current fidelity and anomaly rules;
- commit one bounded ledger transaction;
- release the source rows and association sets; and
- publish cumulative progress before loading the next page.

If the process stops after a page commit, the existing ledger cursor makes the
next run begin after the last durable source row. If it stops within a page,
`insertIgnore` and source-scoped identity make replay safe.

### 3.3 Keyset-paged rich-text candidates

Extend the `ImportLedger` semantic port with operations that:

- count candidates under the current optional source and
  `startedAfterSourceRowId` filters; and
- read one keyset page ordered by `ss_id`, with `ss_id > :pageCursor` and an
  explicit limit.

Do not use `OFFSET`: writing decoded text removes rows from the candidate
predicate and would cause later offsets to skip candidates.

Use `ss_id` as the durable candidate cursor and extraction identity, or
introduce a typed work key containing `ss_id`, `sourceId`, and `sourceRowId`.
Retain source row ID separately for user-facing progress and privacy-safe
diagnostics. The implementation must not collapse two sources that share the
same source row ID.

### 3.4 Bounded decode and persistence cycle

For each candidate page:

1. Fetch at most 500 candidates.
2. Partition decoder calls further when cumulative blob payload exceeds an
   internal 8 MiB target. A single record is never dropped to satisfy the
   target; it is processed alone and covered by the single-record safeguards.
3. Pass only that sub-page to the extractor.
4. Retain decoded strings only for that sub-page.
5. Persist successful non-empty decoded text in a bounded transaction using
   `ss_id` and `text IS NULL`.
6. Account for every unsuccessful decode as a row-local anomaly without
   removing or hiding its source message.
7. Commit, publish cumulative extraction and persistence progress, yield to
   the event loop, and discard all page collections before continuing.

The candidate total is captured once at the start of the stage. Cumulative
progress is derived from pages completed in the current run, not from each
page's local zero-based counter. Extraction and persistence must both finish
at the same original total even when some blobs yield no text.

Successful page writes are the checkpoint. After a process interruption, a
fresh candidate query naturally excludes already enriched rows and repeats at
most the uncommitted page. Already undecodable rows remain candidates on a
future run under the minimum design; within one run the advancing `ss_id`
cursor prevents an infinite retry loop.

### 3.5 Single-record decoder safety

Row-count and byte-target pages eliminate corpus-sized retention but cannot
bound a single malicious or corrupt typedstream object. Before release:

- test truncated, malformed-length, deeply nested, random, empty, and large
  synthetic blobs against the Rust API;
- record wall time and peak resident memory outside the production app;
- inspect `crabstep` deserialization and property resolution for attacker-
  controlled allocations or recursion; and
- add explicit parser limits or worker isolation if one record can violate the
  release resource budget.

An over-limit or failed record must produce an explicit decode-unavailable
anomaly. Its ledger row, attributed-body evidence, relationships, graph
projection, and visible UI representation must remain intact.

## 4. Expected implementation surfaces

Core production changes should remain localized to:

- `lib/essentials/source_scoped_import/application/messages/message_importer.dart`;
- `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart`;
- `lib/essentials/source_scoped_import/domain/ports/import_ledger_port.dart`;
- `lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart`;
- `lib/essentials/source_scoped_import/domain/ports/message_extractor_port.dart`
  only if a typed source-scoped work key is required; and
- `lib/essentials/source_scoped_import/infrastructure/extraction/rust_message_extractor.dart`
  for page-local progress, privacy-safe metrics, or decoder hardening.

Focused tests belong in:

- `test/essentials/source_scoped_import/application/messages/message_importer_test.dart`;
- `test/essentials/source_scoped_import/application/messages/message_rich_text_enricher_test.dart`;
- an infrastructure test for paged ledger candidate queries; and
- `rust/rust/attributed-string-decoder/` tests if decoder safeguards change.

The recovery-state and build-metadata follow-ups must be separate commits from
the bounded-memory core so they cannot obscure its review or rollback.

## 5. Implementation sequence

### Phase 0 — Baseline and instrumentation

1. Create a dedicated `codex/` feature branch from the intended release base.
2. Record current focused-test, full-test, analyzer, and Rust-test baselines.
3. Add a content-free synthetic corpus generator capable of at least 150,000
   candidates, sparse row IDs, multiple sources, and configurable blob sizes.
4. Add privacy-safe stage metrics:
   page ordinal, page row count, cumulative completed count, cumulative
   candidate count, total blob bytes for the page, maximum blob bytes in the
   page, elapsed time, and outcome. Do not log content or paths.
5. Capture baseline peak resident memory and completion behavior for the
   existing implementation. The baseline may be run in a disposable harness
   if running the old whole-corpus path inside the app is unsafe.

Exit criterion: a reproducible measurement distinguishes corpus growth from a
single-record spike without exposing user data.

### Phase 1 — Bound source-message import

1. Add stable high-water/count queries.
2. Replace `m.*` with the exact projection.
3. Process keyset pages and page-local association sets.
4. Commit one ledger transaction per page.
5. Preserve current anomaly aggregation, result semantics, and cumulative
   progress.

Exit criterion: a corpus larger than one page imports every eligible source
row exactly once, a mid-page replay is idempotent, and no source read or write
transaction contains more than the configured page.

### Phase 2 — Bound and checkpoint rich-text enrichment

1. Replace the unbounded ledger method with count plus keyset-page semantics.
2. Remove or rename the unused `extractionLimit`; no misleading no-op limit may
   remain.
3. Decode and persist one bounded page/sub-page at a time.
4. Make keys source-scoped and progress cumulative.
5. Release page collections before the next read.

Exit criterion: the extractor never receives more than the configured page or
byte target, successful pages remain enriched after an injected interruption,
and retry processes only remaining candidates plus at most the interrupted
page.

### Phase 3 — Investigate and, if necessary, harden one-record decoding

Run the malformed/large corpus. If any one record causes disproportionate
allocation, unbounded recursion, excessive CPU, panic, or process death,
implement parser limits or process isolation and add the corresponding Rust
and Dart boundary tests.

Exit criterion: every tested hostile blob terminates within the defined budget
and becomes either decoded text or a visible, counted row-local anomaly.

### Phase 4 — Improve recovery and support evidence

In separate commits:

1. persist or derive the actual incomplete substage so onboarding can say that
   rich-text extraction was interrupted rather than reporting a generic graph
   projection failure;
2. include remaining candidate count and privacy-safe size aggregates in the
   support bundle if approved by privacy review; and
3. obtain installed version/build metadata from an authoritative runtime or
   build source instead of stale checked-in fallbacks.

Exit criterion: a support bundle after an injected interruption identifies the
stage, durable counts, and real build without content disclosure.

### Phase 5 — Release qualification

1. Complete the automated matrix below.
2. Perform the macOS production-shaped rehearsals.
3. Add the release note and version bump.
4. Build through the distribution path while preserving
   `com.bigbenchsoftware.MessageLens`, release signing, and notarization.
5. Have the original tester retry without deleting the broad Application
   Support root. Preserve any attachment archive and collect a post-run support
   bundle.

Exit criterion: every release gate and acceptance criterion is satisfied.

## 6. Required automated test matrix

### Message importer

- Zero-row run reports 0/0 progress and performs no batch transaction.
- One page and page-plus-one corpora import all records.
- A many-page corpus preserves ordering, exact counts, and the final row ID.
- Sparse/non-contiguous source row IDs do not skip records.
- Rows added above the frozen high-water mark wait for the next incremental
  run and are then imported.
- A simulated interruption between and within pages resumes idempotently.
- Association targets before, within, and after a page are resolved correctly.
- Missing timestamps, unlinked messages, unresolved reaction targets, null
  text, and unusual item types remain imported and counted.
- Returned source columns exclude unused payload bodies while presence flags
  remain correct.
- The Apple timestamp cases continue to pass through `DateConverter`.

### Rich-text enrichment

- Candidate count and keyset pages honor source filters and
  `startedAfterSourceRowId`.
- Page-plus-one and many-page corpora enrich every decodable candidate.
- No extractor call exceeds the configured row bound; byte partitioning is
  also asserted.
- Progress is monotonic and cumulative across pages for both extraction and
  persistence, including missing decodes.
- Existing plain text is never overwritten.
- An undecodable row remains present, is counted once in that run, and does not
  prevent later rows from enriching.
- A failure before a page transaction mutates no row in that page.
- A failure after a page commit preserves the page, and retry skips it.
- Two sources with the same source row ID do not collide or receive each
  other's decoded text.
- New candidates that arrive after the stage's initial count do not corrupt
  the denominator and are handled by the next normal run.
- Extractor unavailability remains a systemic failure with no partial
  mutation of the current page.
- Empty, whitespace-only, large, malformed, and unexpected blobs preserve
  their message rows and produce the specified result/anomaly.

### Architecture and regression

- Existing idempotence, fidelity, source-scoping, and graph-build service tests
  remain green.
- A guard test prevents a return to unbounded enrichment reads.
- A query-shape test prevents a return to `m.*` for message import.
- Forbidden-import and central-provider architecture tests pass.
- No test opens the user's Messages database or production MessageLens stores.

## 7. Resource and recovery qualification

### Synthetic scale fixture

Use at least 150,000 rich-text candidates—larger than the photographed
123,561—with deterministic synthetic blobs. Include:

- normal small blobs;
- a long-tail size distribution;
- a bounded set of large blobs;
- undecodable blobs interspersed throughout;
- duplicate source row IDs across distinct sources; and
- source rows arriving beyond the frozen high-water mark.

Run the importer and enricher in a separate process so peak resident memory can
be sampled independently. The required shape is a bounded sawtooth/plateau by
page, not monotonic growth proportional to candidate count. The numerical
release ceiling must be set from the baseline machine and a low-memory target
Mac before implementation is signed off; it must include sufficient headroom
to avoid macOS application-memory pressure under an ordinary concurrent-app
load.

### Interruption matrix

Inject termination at these boundaries:

- before the first source page commit;
- after multiple source page commits;
- during a decoder page;
- after decoder output but before persistence;
- after rich-text page persistence;
- before relationship import; and
- before graph projection commit.

After each interruption, relaunch without deleting application data and verify:

- the environment is classified as resumable;
- durable work is retained;
- at most one bounded page is replayed;
- all source facts eventually appear;
- row-local anomalies remain visible/accounted;
- relationships and graph projection eventually complete; and
- overlay data and attachment archive payloads are unchanged.

## 8. Command gates

At minimum, run:

```bash
dart format <changed Dart files and focused tests>
flutter test test/essentials/source_scoped_import/application/messages/message_importer_test.dart
flutter test test/essentials/source_scoped_import/application/messages/message_rich_text_enricher_test.dart
flutter test test/essentials/conversation_graph/application/conversation_graph_build_service_provider_test.dart
flutter test test/architecture/forbidden_imports_test.dart
flutter analyze
flutter test
```

If Rust changes:

```bash
cd rust/rust/attributed-string-decoder
cargo fmt --check
cargo test
cargo clippy --all-targets --all-features -- -D warnings
```

Before distribution, follow the project's notarized build path and the FDA
continuity instructions. A local `flutter build macos --release` alone is not
the distribution artifact.

## 9. Release acceptance criteria

The fix is ready only when all are true:

1. No production source-message or rich-text query materializes the complete
   eligible corpus.
2. No decoder call or persistence transaction exceeds its declared bound.
3. Peak MessageLens memory plateaus in the 150,000-candidate fixture instead of
   growing with total corpus size.
4. A 123,561-or-larger candidate run completes on the low-memory target Mac
   without a macOS application-memory alert attributable to the run.
5. An injected process death loses no committed page and requires replay of no
   more than one bounded page.
6. First-run, historical-source, and ongoing incremental paths all complete
   with correct source-scoped identities.
7. Every anomalous record remains imported, projected, and renderable.
8. The graph completes with expected message/topology counts after resume.
9. Overlay data and `attachment_archive/` are byte-for-byte untouched by the
   repair and recovery paths.
10. Support output identifies the real build and, if Phase 4 ships, the actual
    interrupted substage without exporting sensitive content.
11. Focused tests, architecture tests, full Flutter tests, analyzer, and any
    applicable Rust gates pass.
12. `pubspec.yaml` and `CHANGELOG.md` describe the tester-visible correction,
    and the release preserves bundle identity, signing, and FDA continuity.

## 10. Tester verification script

The original tester should receive a build that includes the completed release
gates and these instructions:

1. Do not delete the MessageLens Application Support root or any attachment
   archive.
2. Launch the fixed build and retry from the application's offered resumable
   state. If the old partial derived databases are incompatible with the fix,
   use only the application's narrowly scoped derived-store rebuild action.
3. Keep the Mac awake and note whether progress advances beyond 24,000.
4. Confirm that message text, chats, relationships, and attachments reach the
   ready state.
5. Quit and relaunch to confirm the ready state persists.
6. Export a fresh support bundle and provide any macOS Jetsam report generated
   during the run.

Success is completion without broad data deletion, without a system memory
alert, with a populated graph, and with a support bundle whose counts reconcile
to the frozen source high-water mark plus any messages imported on the next
incremental pass.

## 11. Explicitly rejected shortcuts

- Raising the current 200,000 value or calling it a batch limit without using
  it.
- Asking users to close every other app as the product fix.
- Hiding, dropping, or permanently skipping undecodable records.
- Replacing source-scoped identity with source row ID.
- Using `OFFSET` pagination on a predicate changed by each page's writes.
- One transaction over the full archive.
- Retrying the entire rich-text corpus after every interruption.
- Folding enrichment into import or graph projection.
- Rebuilding the graph from overlay data or dual-writing user intent.
- Deleting the MessageLens data root or attachment archive to regain a clean
  state.
- Treating `graphProjectionFailed` as proof that projection caused the failure.
- Declaring success from unit tests alone without process-level memory and
  interruption qualification.
