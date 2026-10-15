# MessageLens — Feature 34
## Prompt 108 — Checkpoint Ledger Comparison and Audit Coherent Populated Reconstruction-Witness Architecture

**Milestone:** Read-only architectural design audit after Response 107. **No witness implementation or destructive authority.**

### Governing principle

> A comparison is not reconstruction proof unless expected and observed material, source occurrences, protected references, and runtime semantics belong to one coherent, stable, explicitly bound observation. UNKNOWN never becomes TRUE by omission.

Responses 93–103 qualified eight source-scoped transformations and rich-text semantic normalization. Responses 105–107 qualified disposable production graph replay, schema-wide graph material comparison, and schema-wide import-ledger comparison. None establishes populated reconstructibility or authorizes Operating-owned Start Fresh. Production AppCzar activation remains OFF; seven jurisdictions remain unchanged.

## 1. Preflight and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`.

Verify actual HEAD, upstream synchronization (0/0), clean tracked tree and index, one Feature 34 branch worktree, shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`, and exact pre-existing untracked inventory. Verify ancestry of all nine shared transformations and Responses 105–107 implementation checkpoints, particularly `f477f6858a62ab8849c9e0f254c9312cebea391a`.

Determine whether Prompt 107 and Response 107 were already committed and pushed together. If yes, record exact documentation checkpoint and do not duplicate. If not, checkpoint and push **only** Prompt 107/Response 107 before proceeding. Preserve all unrelated untracked files. If preflight materially contradicts the expected state, STOP AND REPORT.

Read global agent instructions, canonical Project Conformance standard, Responses 91–107 as relevant, and actual current source and test implementations. Source code is authoritative for present behavior. This is a source/test inspection audit; do not rerun entire suites merely to repeat prior evidence.

## 2. Inventory existing reusable evidence seams

Source-trace and document precise interfaces, dependencies, capabilities, and limitations for:

- Eight canonical source-scoped projection functions and rich-text semantic projection;
- production source readers, source registry/occurrence identity, import batching and stateful admission/omission decisions;
- disposable production-schema ledger and its qualified material comparator (11 tables, operational UTC provenance checks, identity and FK/endpoint checks, bounded row reads);
- disposable production graph replay harness and qualified material comparator (11 material tables, all columns, known nonconvergence);
- production FTS schema, triggers, search query paths, SQLite/FTS runtime and existing tests;
- overlay, historical/non-live, Presence, archive identity/generation and operation evidence.

For each seam specify whether it is test-only or production, whether it can be reused by a future read-only witness without a mutation capability, and whether its current size/streaming assumptions are suitable for a populated installation. **Do not confuse 10,000-row disposable comparison limits with production-scale support.**

## 3. Coherent cross-store observation contract

Design, without implementing, an evidence-generation protocol binding:

1. admitted archive UUID, canonical root, generation, attachment location and marker identity;
2. each live/historical/non-live physical source occurrence, schema, source key and registry allocation;
3. import-ledger and graph database identity, schema, SQLite journal/WAL snapshot semantics and read-only opening;
4. overlay, Presence, journals, receipts, and protected-reference generation;
5. implementation identity (build, canonical projection, rich-text decoder, graph writer, FTS/SQLite runtime);
6. observation start/end material fingerprints and exact bounded retry/failure semantics.

Explain whether independent read transactions across files can provide a coherent point-in-time view; do not claim atomicity across independent SQLite databases without proof. Analyze message arrival, import updates, archive repair, source replacement at same path, process restart, and mid-scan changes. Define when TRUE, FALSE, and UNKNOWN are justified, including precedence of known material contradiction over incomplete observation.

Design bounded pagination/streaming, byte/time/memory limits, cancellation, cleanup, and race-safe snapshot ownership. State precisely which existing readers can be reused and which would need separately authorized read-only seams. No global mutation Ball, coordinator chaining, new AppCzar evaluator, or production reset policy.

## 4. FTS proof boundary

Audit FTS5 external-content index behavior and current search implementation. Explicitly distinguish:

- graph `messages` row/text equality;
- apparent `SELECT` results from external-content FTS versus internal index integrity;
- bounded query-corpus equivalence versus exhaustive search/index equivalence;
- production SQLite/FTS/tokenizer version and query parsing compatibility.

Identify whether a **strictly read-only** internal index integrity or structural comparison is supported on the observed graph, and what disposable diagnostics can establish. If exhaustive equivalence cannot be established with current APIs, retain UNKNOWN; do not assert that a finite query corpus proves all possible searches. Do not run rebuild/optimize/repair on a live index.

## 5. Protected references and historical evidence

Inventory actual overlay tables and columns referencing graph IDs, source row IDs, GUIDs, canonical handles, contact/channel identities, or archived attachment tuples. Include compatibility bridges, uniqueness assumptions, and direct versus fallback references. Distinguish user-authored intent from rebuildable graph data.

Specify exact read-only anti-join/uniqueness proofs against both observed and expected identities, including duplicate GUIDs, changed canonical representatives, missing historical sources, source registry reallocation, dangling references, and archive-generation changes. Account for Presence and operation journals without inventing graph dependencies. Classify each known loss as FALSE, unreadable or ambiguous evidence as UNKNOWN. Payload coverage does not prove relationship provenance.

## 6. Expected ledger and graph material construction

Determine how a future witness could derive **expected** source-scoped ledger material from stable source observations using actual canonical transformations and importer-owned admission rules, without running mutating production importers on live data or writing to live stores. Evaluate whether a disposable actual-writer replay is necessary to preserve stateful import semantics, operational batch lineage, and historical provenance.

Determine how the production graph replay harness can consume that bound expected ledger and produce expected graph material. Explicitly preserve the documented stale-populated nonconvergence: a clean expected replay and an observed populated graph may differ even when another additive replay on the observed graph succeeds. No automatic waiver, repair, or reset eligibility may be inferred.

Separate material fields from operational timestamps only where Response 107's explicit contract permits; preserve referential coherence and all other exact material differences.

## 7. Evidence and stop-gate matrix

For each domain (source occurrence, source registry/batches, eight ledger families, rich text, graph, FTS, overlay/protected references, historical sources, archive identity, Presence/operations, resources/lifecycle), provide:

- authoritative input and currently qualified evidence;
- exact unproven requirement;
- TRUE/FALSE/UNKNOWN counterexamples;
- smallest synthetic/disposable qualification;
- performance envelope and failure/cleanup rules;
- architecture enforcement and prohibited authority crossover.

Call out any feasibility blocker where current test-only comparator or full-table materialization cannot scale safely. Do not silently treat missing source rows as zero or absence of errors as completeness.

## 8. Select exactly one Prompt 109 milestone

Recommend **one** smallest safe next step, not a combined witness implementation. Choose based on dependency order and evidence, not a predetermined preference. Candidates include a bounded coherent-observation seam, protected-reference inventory/anti-join qualification, or a narrowly defined FTS read-only proof. Explain the choice against alternatives.

Specify proposed exact permitted files, read-only/test-only boundary, characterization before edits, synthetic adversarial cases, full validation requirements, Project Conformance gates, performance limits, Git checkpoints, and stop conditions. Do not implement Prompt 109 or pre-authorize its design.

## 9. Hard exclusions

This task is **audit/design only**. Apart from a conditional narrow Prompt 107/Response 107 checkpoint and creation of untracked Response 108, do not modify tracked files. Do not edit source/tests/schema/generated files, build or launch MessageLens, read real Messages/Contacts/MessageLens databases, scan WD/Toshiba archives, access real attachment payloads, change FDA/TCC/bookmarks/environment/S3, mutate any archive, repair graph/FTS, invoke destructive reset, or activate production AppCzar. Do not stage Prompt 108 or Response 108. Stop on any requirement for forbidden actions.

## 10. Required Response 108

Create `108-CHECKPOINT-LEDGER-COMPARISON-AND-AUDIT-COHERENT-POPULATED-RECONSTRUCTION-WITNESS.md` in Feature 34 `01-ONBOARDING/responses/`, untracked for review.

Include: exact Git baseline and prior documentation checkpoint; reusable evidence-seam inventory; complete coherence/occurrence/snapshot model; SQLite/WAL and concurrency limitations; FTS proof limits; protected-reference and historical anti-join inventory; expected ledger and disposable graph construction feasibility; typed TRUE/FALSE/UNKNOWN decision matrix; boundedness/cancellation/cleanup; remaining blockers and SHOULD FIX findings; precisely one Prompt 109 recommendation; final Git/untracked preservation; explicit production/reset prohibitions.

Conclude exactly:

`LEDGER COMPARISON CHECKPOINTED: YES / NO`

`COHERENT SOURCE/LEDGER/GRAPH OBSERVATION CONTRACT DEFINED: YES / NO`

`FTS PROOF LIMITS EXPLICIT: YES / NO`

`PROTECTED/HISTORICAL REFERENCE REQUIREMENTS INVENTORIED: YES / NO`

`BOUNDEDNESS AND CANCELLATION GAPS IDENTIFIED: YES / NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE (AUDIT/DESIGN): PASS / FAIL`

`READY FOR NARROW PROMPT 109: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**.
