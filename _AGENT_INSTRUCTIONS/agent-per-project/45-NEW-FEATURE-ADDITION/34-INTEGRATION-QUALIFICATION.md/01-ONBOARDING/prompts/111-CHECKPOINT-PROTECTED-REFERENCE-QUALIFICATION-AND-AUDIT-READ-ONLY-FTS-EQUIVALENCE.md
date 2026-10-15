# MessageLens — Feature 34
## Prompt 111 — Checkpoint Protected-Reference Qualification and Audit Read-Only FTS Equivalence

**Milestone:** Read-only source-grounded audit/design of the remaining Conversation Graph FTS5 reconstruction-equivalence proof boundary.

**Governing status:** Response 110 qualified a bounded, test-only protected-reference comparator, not a populated reconstruction witness. The eight canonical source-scoped projections, canonical rich-text semantic projection, source-ledger/graph material comparators, production-writer graph replay harness, bounded coherent-observation envelope, and protected-reference comparison remain separate pieces of evidence. **Destructive Operating-owned Start Fresh / Stage 2C is BLOCKED. Production AppCzar activation remains OFF.** This prompt must not change either result.

### 1. Preflight, provenance, and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`.

- Verify actual HEAD, `HEAD` versus upstream `0/0`, clean tracked worktree/index, exactly one Feature 34 branch worktree, and the clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`.
- Inventory all existing untracked files and preserve them; do not assume a particular count.
- Verify Response 110's implementation checkpoint `89aa7317b52f704689cdcecc36f81f0f31e46554` in ancestry, along with the graph replay/comparison, ledger comparator, and observation-envelope checkpoints. Determine the actual Prompt 110/Response 110 documentation checkpoint from Git and the latest handoff. Do not infer the commit hash from the contents of Response 110.
- If Prompt 110 and Response 110 have already been committed and pushed together, record the checkpoint; do not duplicate it. Otherwise checkpoint **only those two exact records** and push normally before auditing. Never stage unrelated paths.
- Read applicable global project guardrails, canonical Project Conformance standard, Responses 102–110, the current FTS schema and triggers, production graph projectors, search implementation, migration/FTS repair paths, and existing disposable test harness. Current source is the authority for actual behavior.
- Stop on a material baseline contradiction. A source/Git-only manifest outside the repository is allowed, with no real data access.

### 2. Question this audit must answer

**What precisely can a strictly read-only observer prove about the semantic equivalence of an already-populated external-content FTS5 index to the index produced by MessageLens's actual production writers?**

A graph `messages` row comparison and a query corpus are not by themselves exhaustive FTS equivalence. Likewise `SELECT rowid, text FROM message_text_fts` may return external content-table values without proving the internal token/posting index is correct. Do not represent a SQLite integrity check as exhaustive evidence without auditing its precise semantics and write/read effects under the actual SQLite runtime.

### 3. Exact production FTS source and runtime census

Trace from source and existing tests:

1. Graph schema version and `message_text_fts` DDL, content table/rowid, tokenizer, diacritic and prefix settings.
2. Trigger DDL, update/delete/insert semantics, schema migrations, rebuilding and optimization paths.
3. SQLite engine/provider/runtime path and FTS compile options, query grammar, matching/case/Unicode/diacritic behavior.
4. The production search provider/repository and its complete `MATCH` queries, result joins, filters, ordering, limits, and overlay-dependent post-processing.
5. The actual graph writers and rich-text materialization path on which the indexed text depends.
6. Boundaries between data integrity, content-table equality, index internal integrity, and user-visible search behavior.
7. Any existing strictly read-only FTS integrity or introspection interface; establish read-only safety based on the actual SQL and SQLite behavior, not command names.

List every relevant production file, method, or test and note exact evidence limitations.

### 4. Define distinct proof levels

Propose typed, noninterchangeable FTS evidence levels, e.g.:

- **Schema/runtime compatible:** declared FTS/trigger/runtime identity supports comparison.
- **Content equivalent:** indexed source `(ss_id, text)` material agrees across graph snapshots.
- **Bounded search corpus equivalent:** named production `MATCH` requests agree, including stable result ordering and applicable filters.
- **Internal-index evidence qualified:** only if a read-only method is found and independently validated for the exact FTS5/runtime combination.
- **Exhaustive equivalence:** only if a supported and complete sound proof actually exists; otherwise it is explicitly UNKNOWN.

No partial/finite result may be promoted to exhaustive TRUE. A reproducible search mismatch in a stable accepted observation is FALSE for that named proof level; unqualified runtime, incomplete scan, unsupported internal inspection, or observation drift is UNKNOWN. Preserve the distinction between a known contradiction and an incomplete proof.

### 5. Read-only inspection alternatives and safety

Audit candidate approaches, their capabilities, limits, and risks:

- Production graph material plus exact DDL and runtime identity.
- Read-only production-query corpus versus a disposable graph built by the actual writers.
- Documented FTS5 diagnostic/integrity mechanisms, with explicit analysis of whether their invocation can write even when presented as a query.
- Read-only examination of FTS5 shadow/index structures only if SQLite exposes a supported stable semantic contract; never invent undocumented decoding logic as an authority.
- Disposable-only mutation/integrity-control experiments to establish what a particular check detects, including stale postings, deleted/updated text, orphaned tokens, diacritics/prefixes, and tokenization changes.

If none provides complete strictly read-only index equivalence, say so. Propose the strongest *honest* lower-level evidence and state why it cannot authorize the full populated Start Fresh reconstruction claim.

### 6. False/unknown and protected data cases

Inventory concrete disposable counterexamples:

- Index stale while external content-table text appears correct.
- Missing internal token/posting; orphaned/deleted posting; repeated update/delete trigger behavior.
- Null/empty/whitespace/unicode/rich-text-derived text.
- Case, diacritics, punctuation parser rules, Unicode normalization, phrase and prefix 2/3/4 queries, and unsupported query syntax.
- Differences in `MATCH` results caused by scope filters, tags, or ordering, not FTS index bytes.
- SQLite library, compile-option, tokenizer, or implementation identity drift.
- Query/read failure, index corruption, unavailable FTS5, or stable evidence from mismatched source/graph fingerprints.
- Protected overlay references that remain stable while search indices differ; user-authored data must not be touched.

For each identify which proof level can report coherent FALSE and which must report UNKNOWN. Keep payload/archive and historical-source preservation distinct from text indexing.

### 7. Feasibility, boundedness, and lifecycle

Evaluate how a future FTS verifier can use only stable read-only observed graph access and isolated disposable expected graph writers while remaining bounded in time, memory, disk, query count, diagnostics, and open handles. Account for cancellation, one-attempt snapshot identity, resource failures, and the separate two-attempt coherence envelope from Response 109. Do not claim cross-file atomicity.

The current test-only graph and ledger comparators fully materialize small corpora; do not assume they are production-scale. Do not attach real databases across SQLite connections or build an observed FTS index in place.

### 8. Choose precisely one Prompt 112 milestone

Based on audited feasibility, choose one small, separately reviewable next step. Prefer a **test-only FTS proof-level classification and adversarial disposable qualification** if the actual FTS semantics support that; otherwise recommend a narrower preliminary characterization or report a stop.

Supply its exact allowed file list, characterization-before-edit requirements, deterministic synthetic corpus, expected TRUE/FALSE/UNKNOWN proof levels, resource/cleanup assertions, architecture tripwires, focused validation, conformance checks, stop gates, and documentation checkpoint sequence. Do not assume that an FTS proof level can be exhausted if the source/runtime does not support it.

Do not implement Prompt 112 during this audit.

### 9. Hard exclusions

This is **audit/design only**. Other than a conditional Prompt 110/Response 110 documentation-only checkpoint and creating an untracked Response 111, do not change repository source, tests, generated output, schemas, migrations, dependencies, release metadata, or app configuration. Do not run tests, analyzer, build, app launch, real-source/database reads, WD/Toshiba archive scans, payload operations, TCC/FDA/bookmark or environment changes, live FTS repair/rebuild/optimize, destructive Start Fresh, mutation Ball, new AppCzar jurisdiction, production activation, or cutover.

No `git clean`, force push, rebase, squash, or unrelated staging.

### 10. Required Response 111

Create `111-CHECKPOINT-PROTECTED-REFERENCE-QUALIFICATION-AND-AUDIT-READ-ONLY-FTS-EQUIVALENCE.md` in Feature 34 `01-ONBOARDING/responses/` and leave it untracked for review.

Include:

1. Exact Git baseline, checkpoint, submodule, worktree, and untracked preservation.
2. Response 110's actual qualification boundaries and remaining payload-coverage UNKNOWN.
3. Production FTS DDL/schema/trigger/runtime identity and all relevant file/method call edges.
4. Production search query, filtering, ordering, and overlay interactions.
5. Exact read-only versus mutating FTS diagnostic mechanisms and their source evidence.
6. Separate evidence levels and truthful tri-state semantics.
7. Concrete index-staleness, corruption, parser, runtime-drift, and source-instability counterexamples.
8. Disposable-only feasible characterization and full coverage limitations.
9. Performance, resource, cancellation, cleanup and privacy risks.
10. Recommendation for one exact Prompt 112 milestone and why it is bounded.
11. Canonical Project Conformance audit/design verdict; in-scope versus later destructive-readiness blockers.
12. Final unchanged repository state and prohibited actions.

Conclude exactly:

`PROTECTED-REFERENCE QUALIFICATION CHECKPOINTED: YES / NO`

`FTS SCHEMA, TRIGGERS, RUNTIME, AND SEARCH CALL GRAPH INVENTORIED: YES / NO`

`CONTENT, BOUNDED SEARCH, AND INTERNAL FTS PROOF LEVELS DISTINGUISHED: YES / NO`

`STRICTLY READ-ONLY EXHAUSTIVE FTS EQUIVALENCE SUPPORTED BY CURRENT EVIDENCE: YES / NO / UNKNOWN`

`DISPOSABLE FTS ADVERSARIAL QUALIFICATION PLAN GROUNDED: YES / NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE (AUDIT/DESIGN): PASS / FAIL`

`READY FOR NARROW PROMPT 112: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not begin Prompt 112 or any FTS code change.
