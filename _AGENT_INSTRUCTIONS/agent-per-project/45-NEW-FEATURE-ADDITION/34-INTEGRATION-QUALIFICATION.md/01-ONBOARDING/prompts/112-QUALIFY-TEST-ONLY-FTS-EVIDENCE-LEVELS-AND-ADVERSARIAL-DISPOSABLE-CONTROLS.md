# MessageLens — Feature 34
## Prompt 112 — Qualify Test-Only FTS Evidence Levels and Adversarial Disposable Controls

**Scope:** one bounded, test-only FTS evidence milestone, following Response 111's read-only audit. **Do not** implement a populated reconstruction witness, modify an observed/live FTS index, authorize Start Fresh, or activate production AppCzar.

### Governing result

Response 111 established a crucial distinction among (1) graph message content equality, (2) finite raw MATCH-query equality, (3) finite full production-search equality, and (4) internal/exhaustive index equality. The first three are potentially demonstrable within an explicitly named runtime and bounded corpus. A finite set of queries **cannot** establish exhaustive FTS equivalence. A successful external-content `SELECT rowid,text` does not prove the internal postings agree. The strictly read-only exhaustive FTS proof remains **UNKNOWN**.

The test-only implementation must retain separately typed evidence for each level. It cannot manufacture a single `ftsEquivalent` boolean or provide any reset/mutation authorization.

## 1. Baseline and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`.

1. Verify actual HEAD, upstream `0/0`, clean tracked worktree/index, exactly one Feature 34 branch worktree, and clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`.
2. Preserve all unrelated untracked files and existing worktrees. Record Git/source-only baseline and path/hashes for the two proposed test files before editing.
3. Verify Response 110's implementation `89aa7317b52f704689cdcecc36f81f0f31e46554` and documentation commit `5897918692f6f2614dc9189328d1309c31019e4c` in ancestry, plus all qualified ledger/graph/observation evidence components.
4. Check whether Prompt 111 and Response 111 are already committed and pushed. If not, checkpoint **only those two exact files** and push normally before implementation. Do not duplicate a pre-existing checkpoint. Record the actual resulting HEAD.
5. Read canonical global/project guardrails, Project Conformance Audit Standard, Prompt 112, Response 111 in full, Responses 105–110 as needed, current graph FTS/schema, production search parser/repository/service, disposable production graph replay harness, and current source/identity modules.
6. STOP if the baseline or permitted scope differs materially from the recorded state.

## 2. Exact implementation scope

The **only authorized implementation files** are:

- `test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence.dart` (new)
- `test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence_test.dart` (new)

Reuse, do not edit, existing graph replay, material comparators, production search modules, graph schemas, source projections, observation envelope, and protected-reference comparator. Prompt 112 and Response 112 form a separate documentation-only checkpoint after implementation.

No `lib/`, Rust, macOS/native, schema/migration, generated, dependency, `pubspec`, `CHANGELOG`, release, provider, archive, AppCzar policy/coordinator, Start Fresh, or production activation changes. If a new helper or changed production file is necessary, **STOP** and report rather than expanding the allowlist.

All databases, injected faults, index mutations, and test data must be **synthetic and disposable**. No actual Messages, Contacts, installed MessageLens database, overlay, archive, WD/Toshiba drive, real source identity, attachment payload, or admitted root may be read, opened, migrated, repaired, rebuilt, or changed. No app build/install/launch. No changes to TCC/FDA, bookmarks, S3, or environment.

## 3. Characterize existing behavior before creating evidence classification

First create focused characterization tests that exercise **current unchanged production code**, recording:

- Exact graph v3 FTS5 external-content DDL, `messages.ss_id` row identity, tokenizer `unicode61 remove_diacritics 2`, prefix `2 3 4`, and exact insert/delete/text-update trigger SQL.
- The actual `NativeDatabase`/Drift SQLite connection's `sqlite_version()`, `sqlite_source_id()`, sorted `PRAGMA compile_options`, and FTS5 availability. Do not infer loaded library identity from `pubspec.lock`, system `sqlite3` binary, source tree, or another process.
- Two independently allocated production-schema disposable graphs replayed from the same fixture with identical fixed source-registry IDs. Confirm literal repeat, update, delete, text→NULL→empty→text, same-text update, and baseline raw MATCH and production-search results before classification logic.
- The existing production query parser and `SqliteGraphSearchRepository` query semantics: exact token vs unfinished prefix, quote escaping, AND/OR, global/conversation/handle/contact scopes, tag and saved overlays, final date/ID ordering, limit semantics, and errors. Do not copy the query or tokenizer interpretation into the helper.
- A controlled stale-posting case where underlying `messages.text` and the trigger definitions agree with clean replay, but raw MATCH results differ. This must be deliberately created **only in a writable disposable control**, never on an observed real index.
- A missing text hit masked by an equal overlay tag in the full production search. Raw MATCH must still report the contradiction.

Record the pre-comparison characterized outputs/identities and pass results. If the actual code or runtime contradicts Response 111's source audit, stop rather than changing expectations or FTS production semantics to conform.

## 4. Strict read-only observed-graph seam

After constructing and closing all setup writers, independently reopen the **observed disposable** graph and overlay through SQLite read-only/query-only connections and migration-disabled Drift wrappers suitable for calling the real `SqliteGraphSearchRepository`. Never use the ordinary admitted provider graph; its graph database opener may permit writes/migrations.

Require proof that:

- The observed handles cannot write via ordinary DML, special FTS INSERT commands (`integrity-check`, rank 1, rebuild, optimize), trigger edits, virtual-table creation, or schema repair.
- No `ATTACH`, temp virtual-table DDL, migration, or automatic repair is performed on the observed handle.
- The read-only observer is **SELECT-only** for actual comparison; `PRAGMA` inspection is restricted to an exact allowlist of known read-only statements. Do not treat `assertReadOnlySql` or `sqlite3_stmt_readonly` as a complete safety guarantee.
- Any `fts5vocab` experimentation occurs, if at all, on a separately writable **disposable control**, never on the observed handle. A corpus comparison does not constitute exhaustive index proof.
- Before/after file and schema evidence (including WAL/SHM and unexpected temporary paths) establishes no observed-file mutation. File hash sameness is supporting evidence, **not** authorization to run write-command interfaces.

If the production search repository cannot be exercised using migration-disabled read-only wrappers, report the inability and STOP. Do not change production code or relax the read-only requirement.

## 5. Typed evidence contract

In the authorized test-only helper, implement typed independent dimensions, each with TRUE/FALSE/UNKNOWN, assessed/unassessed status, classified reason, bound runtime/schema/corpus/observation identity, and bounded redacted diagnostics:

1. `schemaRuntimeCompatibility`
2. `contentMaterialEquivalence`
3. `boundedRawMatchCorpusEquivalence`
4. `boundedProductionSearchCorpusEquivalence`
5. `qualifiedInternalIndexEvidence`
6. `exhaustiveFtsSemanticEquivalence`

The exact names may follow the repository style, but these **six distinct claims must never collapse**. `qualifiedInternalIndexEvidence` and `exhaustiveFtsSemanticEquivalence` default to explicit **UNKNOWN/unassessed** unless separately qualified inspection contracts genuinely exist; Prompt 112 does not authorize inventing those contracts.

- A stable named mismatch in the corresponding qualified dimension is FALSE.
- An unsupported/missing runtime identity, unexecutable named request, read/parse error, binding drift, schema incompatibility, timeout, cancellation, or budget exhaustion makes the affected claim FALSE only for a known coherent contradiction; otherwise UNKNOWN. Never turn an exception into an empty result.
- Tag/saved/scope differences belong to the production-search dimension, not raw FTS internal integrity.
- Text equality cannot imply index equality. Matching finite search results cannot imply exhaustive equality. A known raw mismatch cannot be hidden by matching production results due to overlay tags, scope joins, or limits.
- Evidence from a discarded/unstable observation must not be promoted to a coherent FALSE or TRUE.
- No property, callback, provider, or type in this helper may authorize a reset, acquire a Ball, dispatch a coordinator, or publish AppCzar disposition.

## 6. Adversarial disposable corpus

Reuse the existing six-message replay fixture with fixed source IDs; add **no more than 18** deterministic messages through supported disposable production-schema ledger and actual production message-projector APIs. Cover nullable and empty text, whitespace, punctuation, quoted phrases, diacritics and decomposed Unicode, Greek/Cyrillic, emoji, prefixes 2/3/4, duplicate words and identifiers, associated/missing references, and synthetic rich-text persist/empty/failure outcomes. Do not invoke a native decoder or copy real text.

Representative synthetic strings from Response 111: `oldword`, `newword`, `ghostword`, `CAFÉ`, decomposed `café`, `co-op`, `don't`, `post postmaster`, `under_score`, `Привет мир`, `Καλημέρα`, `👩‍💻post`, `alpha beta alpha`, NULL, empty, whitespace, and embedded quotes. Fix ISO dates, with date ties and one NULL. At most two synthetic tags and two saved flags, plus a duplicate GUID control.

Test:

- Independent clean replay equality for content/raw/production finite corpora, while internal/exhaustive remain UNKNOWN.
- Trigger removal/change/restore controls that leave equal content but stale postings; missing and extra raw MATCH hits; ghost postings masked by production joins; missing hit masked by tags; false equivalence under capped result sets.
- Repeated full replay, same-text update, delete/reinsert, text→NULL→empty→text.
- Exact vs unfinished prefix and trailing whitespace; raw MATCH vs the production parser's quoted term grammar; malformed expression produces a typed error/UNKNOWN, not an empty success.
- AND/OR; all four production scopes; saved-only and combined saved/text; native and GUID-compatible tags; ambiguous GUID exclusion; tag-masked missing postings; tied dates and final limit behavior.
- Schema/tokenizer/library identity drift, overlay-only changes, source-registry identity drift, observed graph replacement, unqualified snapshot, and unsupported runtime.
- Diagnostics remain content-free even for strange Unicode text, malformed queries, and failed controls.

Clearly distinguish faults physically constructed in a disposable database from simulated read errors. Do not directly decode undocumented FTS shadow byte formats.

## 7. Bounded work, lifecycle, and cleanup

Set and enforce **before** each test observation:

- max 128 messages per world;
- max 256 KiB input message text per world;
- max 64 named requests;
- max 128 result IDs per request **before comparison** (excess -> UNKNOWN, not truncated equality);
- max 32 redacted diagnostic examples;
- max 6 simultaneously open DB handles;
- max 32 MiB owned disposable disk usage;
- one attempt, no automatic retry (Response 109's distinct envelope owns attempt retry);
- deterministic monotonic deadline/cancellation checks, without wall-clock sleeps.

Test failure/cancellation before and after each read phase and during cleanup; ensure close-once ownership and root deletion **only after** all work has quiesced and handles closed. Report cleanup failures as UNKNOWN. A Dart `Future.timeout` without native preemption does not prove active SQLite work stopped; do not delete resources beneath a running query. Record actual bounded-fixture elapsed time and memory when attributable; never confuse whole Flutter runner RSS with helper incremental RSS.

## 8. Validation and architecture gates

Run focused characterization/evidence tests; existing graph replay, graph schema/FTS runtime, message projection, production search parser/service/repository, coherent observation, and protected-reference tests; architecture forbidden-import tests; full `flutter analyze`; targeted `dart format` and Git diff checks. Full Flutter suite only if governing instructions or a concrete regression requires it. No generation expected.

Enforce within the allowed test files:

- no production import or test-helper path into AppCzar decision policy/coordinator, reset services, archive mutation, live path resolver, root lease, or provider composition;
- no new tokenizer/search translation policy; real production query parser/repository must remain the sole source of query meaning;
- no live database opener, FTS repair command on observed handles, ATTACH, or file access outside uniquely owned disposable roots;
- no content-bearing diagnostics;
- no inferred TRUE for unqualified internal/exhaustive proof.

Run canonical Project Conformance: PASS requires BLOCKER 0 and SHOULD FIX 0 **within this bounded test-only scope**. Do not confuse scope PASS with destructive readiness.

## 9. Stop gates

STOP AND REPORT without a half-qualified implementation if baseline provenance is contradictory, pre-edit characterization cannot be grounded, the observed read-only seam cannot run actual production search, the pure helper would require a production change/additional file, any required source/archive/provider access leaks outside disposable fixtures, a prohibited FTS write is necessary on observed material, a named corpus is nondeterministic, bounds or cleanup cannot be established, or tests/conformance cannot pass. Restore exploratory tracked edits if a stop gate is hit; document exact evidence. Do not weaken an assertion to force PASS.

## 10. Checkpoints and Response 112

After the Prompt 111/Response 111 documentation checkpoint and successful bounded implementation, stage/commit **only the two authorized test files**, push normally. Then write and separately checkpoint **Prompt 112 and Response 112** by exact path, push normally. No rebase, squash, force push, submodule change, or unrelated staging. Preserve all unrelated untracked material. If stopped, leave an uncommitted Response 112 describing the failure and no partial implementation checkpoint.

Create `112-QUALIFY-TEST-ONLY-FTS-EVIDENCE-LEVELS-AND-ADVERSARIAL-DISPOSABLE-CONTROLS.md` under Feature 34 `01-ONBOARDING/responses/` and report:

1. Baseline HEAD/upstream/worktrees/submodule and untracked inventory.
2. Exact Prompt/Response 111 documentation checkpoint and ancestry.
3. Pre-edit actual writer/runtime/search characterization with attributable results.
4. All FTS DDL/trigger and loaded runtime identities measured (not inferred).
5. Read-only observed graph + overlay wrapper construction and migration/write refusal evidence.
6. Six typed proof dimensions and exact TRUE/FALSE/UNKNOWN semantics.
7. Full named raw MATCH and production-search corpus and adversarial controls.
8. Stable content-equal/stale-posting proof and tag/limit masking cases.
9. Distinct content/FTS/overlay/production-search mismatches.
10. Limits, deadlines, cancellation and close/delete ordering, with caveats about native preemption.
11. Diagnostics/privacy and path isolation.
12. Focused, regression, architecture, analyzer, formatting and hygiene results; intermediate failures recorded literally.
13. Project Conformance verdict, BLOCKER and SHOULD FIX counts.
14. Exact implementation and documentation commits/pushes, final clean state.
15. What remains UNKNOWN and the next narrow evidence recommendation.

Conclude exactly:

`PROTECTED-REFERENCE QUALIFICATION CHECKPOINTED: YES / NO`

`FTS SCHEMA AND ACTUAL DISPOSABLE RUNTIME IDENTITY RECORDED: YES / NO`

`OBSERVED DISPOSABLE SEARCH CONNECTION STRICTLY READ ONLY: YES / NO`

`SIX INDEPENDENT FTS EVIDENCE DIMENSIONS IMPLEMENTED: YES / NO`

`CLEAN REPLAY CONTENT/RAW/PRODUCTION BOUNDED CORPORA: PASS / FAIL / NOT REACHED`

`STALE POSTING WITH EQUAL CONTENT DETECTED: YES / NO / NOT REACHED`

`TAG OR LIMIT MASKING CANNOT PROMOTE INDEX EVIDENCE: YES / NO / NOT REACHED`

`INTERNAL FTS INDEX EQUIVALENCE EXHAUSTIVELY PROVEN: NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not build the populated witness or implement Prompt 113.
