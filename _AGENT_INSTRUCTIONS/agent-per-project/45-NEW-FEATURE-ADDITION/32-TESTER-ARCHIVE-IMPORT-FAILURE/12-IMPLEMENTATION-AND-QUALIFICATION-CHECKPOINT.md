# Tester Archive Import Memory Remediation — Implementation and Qualification Checkpoint

Date: 2026-09-13

Status: Phases 0–2 implemented; mandatory Phase 3 investigation and hardening
completed. Work is stopped before Phase 4 and release packaging as directed.

## Executive conclusion

The core defect identified in
`00-REPORTED-EPISODE-EVIDENCE-AND-DIAGNOSIS.md` has been remediated in the
source-message and attributed-body paths. Both now bound their live working
sets by explicit units of work rather than the total archive size.

The production-scale synthetic measurement demonstrates the required memory
plateau. With the same 256-byte base-blob policy, increasing the fixture from
25,000 to 150,000 candidates increased peak RSS by only 13,712 KiB in the
remediated path, compared with 165,024 KiB in the legacy path. At 150,000
candidates, peak RSS fell from 379,072 KiB to 186,256 KiB.

The evidence still does not prove that MessageLens was the sole or largest
memory consumer when macOS displayed the tester's system-wide warning. It
does prove that the photographed operation was in rich-text enrichment and
that the former implementation had archive-proportional working-set behavior.

Phase 3 source inspection found genuine one-record risks in the native parser:
recursive parsing paths and an object-property walk without explicit cycle,
depth, or node limits. Explicit input and structural limits were therefore
required and have been added. The final external robustness probe completed
all cases with a peak RSS of 11,108,352 bytes; its slowest individual case was
the 8 MiB input at 8,916 microseconds.

This checkpoint is not release sign-off. A numerical ceiling on a low-memory
target Mac, real application/process-stop rehearsal, Phase 4 diagnostics,
release metadata, production signing/notarization, and tester confirmation
remain outstanding.

## 1. Branch and starting HEAD

- Isolated worktree: `/private/tmp/messagelens-tester-import-memory-remediation`
- Branch: `codex/tester-archive-import-memory-remediation`
- Starting HEAD: `c2f546dc99eb50c66233ef94ddb0e70c7d77990e`
- Starting subject: `feat(startup): add validation telemetry and support artifact`
- The user's existing dirty worktree and its
  `feature/attachment-archive-relocation` branch were not modified.

## 2. Commits made

1. `adea9531` — `docs(import): record archive memory remediation`
2. `2296b68c` — `test(import): add archive memory qualification harness`
3. `41758a25` — `fix(import): bound source message ingestion`
4. `babde52c` — `fix(import): checkpoint bounded rich text pages`
5. `2820aa51` — `fix(import): contain single-record rich text decoding`
6. `bdd96bf0` — `fix(import): preserve page failure stack traces`
7. `d82cbc4b` — `test(import): satisfy remediation analyzer gate`
8. `21a1b172` — `docs(import): record remediation checkpoint`

The documentation, measurement harness, source-message architecture,
rich-text architecture, one-record hardening, and gate corrections remain
separately reviewable. Nothing was pushed.

## 3. Exact production architecture changes

### Source-message ingestion

- `ReadOnlySourceDatabase` now owns semantic window, page, and association
  lookup operations instead of exposing an unbounded application-layer query.
- The source database freezes `COUNT(*)` plus `MAX(message.ROWID)` for a run.
- `MessageImporter` reads keyset pages with a default, injectable size of 500.
- The source query selects only the required columns. `m.*` is gone.
- Optional columns from newer Messages schemas are projected as `NULL` or
  zero-valued presence evidence when absent, preserving compatibility with
  older archives.
- Attributed-body and other large source payloads are represented by only the
  evidence the import ledger requires.
- Association GUID lookups and working collections are page-local.
- Each page is written in its own ledger transaction.
- Anomaly totals, result totals, progress, and page diagnostics remain
  cumulative across pages.

### Rich-text enrichment

- The unbounded candidate-list operation has been replaced by a count/high-water
  window and a keyset-page operation.
- Candidate pages carry source-scoped identity, source row identity, and BLOB
  byte length, but not the BLOB itself.
- Payloads are fetched only after count-and-byte partitioning. The SQL payload
  projection is capped to one byte beyond the configured per-record maximum,
  allowing a race or size mismatch to become a local unavailable-decode result
  rather than an unbounded Dart allocation.
- Candidate pages default to 500 records. Decoder sub-pages default to an
  approximately 8 MiB cumulative payload target. Both are injectable.
- A separate, injectable 8 MiB per-record ceiling is applied before BLOB
  materialization and is aligned with the native limit.
- Decoder and persistence maps use `ss_id` throughout.
- Each decoder sub-page is persisted in its own transaction. Page collections
  fall out of scope before the next read, and the outer candidate list is
  explicitly cleared before the next page.
- Empty, whitespace-only, missing, changed, over-limit, malformed, or otherwise
  undecodable bodies increment the decode-unavailable anomaly count. Their
  source message and attributed-body evidence are retained.
- The old no-op `extractionLimit` parameter was removed.

### Diagnostics and regression protection

- Privacy-safe page metrics report stage, outcome, ordinal, row count,
  cumulative/total work, total page BLOB bytes, largest BLOB bytes, and elapsed
  milliseconds. They do not report content, paths, GUIDs, or source row IDs.
- Architecture tripwires reject regression to whole-corpus reads, `m.*`,
  `OFFSET`, bare source-row decoder identity, uncapped BLOB materialization, or
  the old no-op limit.

## 4. Paging, high-water, and checkpoint semantics

### Source messages

1. Read the largest already-imported source row ID for the source.
2. Freeze eligible row count and source `ROWID` high-water.
3. Read `ROWID > cursor AND ROWID <= high_water ORDER BY ROWID ASC LIMIT ?`.
4. Commit one page.
5. Advance the cursor only after the page commit succeeds.

A row arriving above the frozen high-water is deferred to the next normal
incremental run. A failed page rolls back as a unit; earlier pages remain
durable.

### Rich text

1. Freeze candidate count and maximum eligible `ss_id`.
2. Read metadata with `ss_id > cursor AND ss_id <= high_water`, ordered by
   `ss_id`, without `OFFSET`.
3. Partition by cumulative BLOB byte length.
4. Fetch only within-budget BLOBs for that sub-page.
5. Decode and persist that bounded sub-page in one transaction.
6. Advance through the frozen candidate page after its bounded sub-pages have
   completed.

Successful persistence transactions are the checkpoints. On retry, enriched
rows no longer satisfy the candidate predicate. At most the uncommitted
bounded unit is replayed. A locally unavailable decode remains eligible on a
future run, but the advancing cursor prevents an infinite retry loop within
the current run.

## 5. Source-scoped identity handling

- The rich-text work key is `messages.ss_id`, not bare `source_rowid`.
- Candidate maps, BLOB maps, native decoder callbacks, extracted-result maps,
  and persistence predicates all retain that identity.
- Persistence uses `WHERE ss_id = ? AND text IS NULL`.
- The source row ID is retained only for user-facing progress context.
- A focused test creates two sources with the same source row ID and proves
  that each receives its own decoded value.

## 6. Tests added and results

New or expanded coverage includes:

- zero, one-page, page-plus-one, sparse, many-page, and arrival-after-high-water
  source-message cases;
- exact and old-schema-aware source projections;
- association targets outside the current page;
- per-page commit, rollback, and retry behavior;
- rich-text count and keyset pages with source filters;
- count and cumulative-byte decoder bounds;
- over-limit BLOB non-materialization and local anomaly handling;
- duplicate source row IDs across sources;
- progress monotonicity across 1,001 candidates including unavailable decodes;
- failures during decode, after decode/before persistence, and immediately
  after persistence;
- topology and graph retry boundaries;
- overlay and attachment-archive sentinel preservation;
- native empty, truncated, malformed-length, deep-control, recursive-reference,
  deterministic-random, large, and over-limit inputs; and
- architecture tripwires for every bounded-memory invariant.

Gate results:

- Phase 0 baseline focused suite: 401 passed.
- Phase 0 baseline full Flutter suite: 2,255 passed.
- Phase 0 baseline Rust suite: 1 passed, with three pre-existing
  `flutter_rust_bridge` configuration warnings.
- Current focused remediation/recovery command: 56 passed.
- Full architecture suite: 386 passed.
- Final full Flutter suite: 2,278 passed and one intentionally skipped
  environment-gated memory-worker test.
- Rust suite: 8 passed.
- `cargo fmt --check`: passed.
- `cargo clippy --all-targets --all-features -- -D warnings`: passed.
- `flutter analyze`: no remediation-introduced findings; it reports only the
  same two baseline informational findings in `packages/macos_ui_patched`.

The first full-suite attempt had one unrelated timing-sensitive failure in
`attachment_archive_service_provider_test.dart`: its provider container was
disposed before an asynchronous lookup completed. The exact test passed on
immediate isolated rerun, and the complete second full-suite run passed.

No test opened the user's Messages database or production MessageLens stores.
All generated databases and files were synthetic and disposable.

## 7. Baseline versus remediated memory behavior

The parent harness runs the production rich-text coordinator and import-ledger
implementation in a separate `flutter_tester` process and samples that child
with `ps` every 50 ms. Fixture creation is performed in a separate process.
Each fixture is deleted afterward.

| Candidates | Legacy peak RSS | Remediated peak RSS | Peak reduction |
|---:|---:|---:|---:|
| 25,000 | 214,048 KiB | 172,544 KiB | 41,504 KiB (19.4%) |
| 150,000 | 379,072 KiB | 186,256 KiB | 192,816 KiB (50.9%) |

Scaling from 25,000 to 150,000 candidates:

- Legacy peak growth: 165,024 KiB, or 77.1%.
- Remediated peak growth: 13,712 KiB, or 7.9%.

The 150,000-row remediated bucket maxima were:

`[173136, 181200, 183760, 184608, 185344, 186112, 186256, 161184, 163760, 161344] KiB`

The profile rises into a narrow band, then releases memory and finishes in a
lower band. It does not track the six-fold corpus increase. This demonstrates
the requested plateau on the baseline machine.

Elapsed rich-text work time was 1,580 ms/8,541 ms for the legacy 25,000/150,000
runs and 2,531 ms/9,271 ms for the remediated runs. The core tradeoff is more
bounded database reads and transactions in exchange for sharply lower peak
memory.

A numerical release ceiling has not been set because the required low-memory
target Mac measurement remains outstanding.

## 8. Interruption and recovery results

The automated fault-injection matrix demonstrates:

- Before the first source page commit: a bad row leaves the first page empty
  in the ledger.
- After multiple source page commits: two committed two-row pages survive a
  later page rollback; retry begins after source row 4 and imports only the
  remaining rows, including the repaired bounded page.
- During a decoder page: earlier persisted pages survive a later decoder
  failure.
- After decoder output but before persistence: the current page has no text
  mutation.
- Immediately after rich-text persistence: the committed page survives, and
  retry skips it.
- Before topology relationship import: imported source facts remain durable;
  retry completes all three relationship kinds.
- Before the first graph projection commit: all imported facts/topology remain
  durable, the graph is still empty, and retry completes four graph nodes and
  three graph edges.
- Locally unavailable decode rows remain present and counted, and later rows
  continue.
- Existing onboarding classifier and reconciliation tests confirm coherent
  running/interrupted states remain resumable.
- Overlay and `attachment_archive/` sentinel bytes remain unchanged across the
  topology and graph interruption/retry tests.

These are deterministic exception/fault-boundary tests, not operating-system
termination of a packaged MessageLens process. A real process-stop/relaunch
rehearsal remains a release-qualification item.

## 9. Phase 3 decoder findings and hardening

Inspection of locked dependency `crabstep 0.2.1` found:

- recursive `read_unsigned_int` and `read_signed_int` paths for reference-tag
  bytes;
- recursive object/type parsing through `read_types` and `read_object`; and
- property traversal that has no explicit cycle, depth, or total-node budget.

The native boundary now applies:

- maximum input: 8 MiB;
- maximum typedstream control markers: 1,024;
- maximum consecutive reference-like bytes: 1,024;
- maximum resolved property depth: 256;
- maximum resolved property nodes: 65,536; and
- panic conversion to a returned decoder error within that envelope.

The ledger boundary reads BLOB lengths before payloads and does not request a
payload above the aligned 8 MiB maximum. Thus the native input check is not the
first line of defense against a very large SQLite value.

The final release-mode robustness probe produced:

- valid 179-byte input: decoded;
- empty input: decode unavailable;
- truncated input: decode unavailable;
- malformed-length input: decode unavailable;
- deep-control-marker input: decode unavailable;
- recursive-reference-byte input: decode unavailable;
- deterministic random 1 MiB input: decode unavailable in 292 microseconds;
- large 8 MiB input: decode unavailable in 8,916 microseconds; and
- 8 MiB + 1 byte input: rejected immediately.

External process measurement reported 11,108,352 bytes maximum resident set
size for the complete probe. Worker-process isolation was not added because
the identified recursive and traversal routes are now bounded before/during
parsing and every tested input completed inside the defined resource envelope.
All failures flow through the existing row-local unavailable-decode accounting;
the message and source evidence are not deleted.

## 10. Deviations from the implementation plan

- The process-level memory test runs the production coordinator and ledger in
  `flutter_tester`, not a packaged GUI application. This isolates the memory
  behavior under test and avoids production data, but a packaged-app profile
  is still required before release.
- Interruption tests use deterministic injected exceptions at transaction and
  stage boundaries rather than killing an operating-system process. Durable
  state and retry semantics are proven; actual stop/relaunch is deferred to
  release qualification.
- The 150,000-row RSS fixture contains multiple sources, duplicate source row
  IDs, sparse identities, and a long-tail BLOB-size distribution. Unavailable
  decodes and arrivals beyond the frozen high-water are proven in focused
  tests rather than combined into that measured run, preserving direct
  comparability with the legacy baseline.
- The 500-record and approximately 8 MiB defaults were retained after the
  baseline-machine profile. They remain injectable policies rather than
  architectural constants.
- No schema migration was needed.
- No worker process was added because explicit in-process limits met the Phase
  3 measured budget. This decision should be revisited if a future corpus
  produces a parser termination outside the tested envelope.

No implementation evidence contradicted the diagnosis or the bounded-memory
design assumptions.

## 11. Remaining Phase 4 and release qualification

The following work was intentionally not started:

1. Persist or derive the actual interrupted substage instead of reducing it to
   the coarse `graphProjectionFailed` classification.
2. Correct support-bundle version/build reporting so stale checked-in fallback
   values cannot masquerade as installed metadata.
3. Consider pending-enrichment count and size aggregates only after privacy
   review.
4. Establish a numerical memory ceiling and headroom on the intended
   low-memory target Mac under ordinary concurrent-app load.
5. Run actual packaged-app process-stop/relaunch recovery at every required
   boundary.
6. Add the release version bump and `CHANGELOG.md` entry.
7. Prebuild native artifacts, run the production distribution path, preserve
   bundle ID/signing/FDA continuity, sign, notarize, and verify the candidate.
8. Have the original tester retry without deleting the broad Application
   Support root, preserve `attachment_archive/`, and collect a post-run support
   bundle.

## 12. Final git status

At the completion of the implementation and test commits, the isolated
worktree was clean on `codex/tester-archive-import-memory-remediation` at
`d82cbc4b`. The checkpoint document was then committed separately as the
eighth commit, `21a1b172907a3a263587bc21b22fbcf574c27a5b`. No branch was
pushed.
