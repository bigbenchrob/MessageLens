# MessageLens — Feature 34
## Prompt 104 — Checkpoint Rich-Text Extraction and Audit Conversation Graph Reconstruction Equivalence

**Mode:** Read-only source-grounded architecture and evidence audit. **No implementation or live-data access.**

### Governing question

Can a future read-only reconstruction witness establish material equivalence of a **populated** Conversation Graph by faithfully replaying the existing production graph writers into a disposable store, or must particular deterministic transformations first be extracted into shared pure boundaries?

The eight source-scoped projection extractions (Responses 93–101) and the rich-text semantic extraction (Response 103) establish narrow behavioral parity. **They do not prove full populated reconstruction equivalence.** Destructive Operating-owned Start Fresh / Stage 2C remains blocked, and production AppCzar activation remains disabled. Preserve all seven AppCzar jurisdictions.

### 1. Exact preflight and prior checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text`.

1. Verify actual branch `fix/onboarding-import-stuck-state`, current HEAD, upstream relationship `0 ahead / 0 behind`, clean tracked worktree/index, and clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`.
2. Enumerate registered worktrees, verify exactly one Feature 34 worktree on this branch, and preserve the complete pre-existing untracked inventory.
3. Verify all eight source-projection implementation checkpoints and rich-text implementation commit `e340bdca0c6b8af9d40ab312a7f455d2fd9910db` in ancestry.
4. Verify whether Prompt 103 and Response 103 are already committed and pushed together. If so, record the exact documentation checkpoint; do not duplicate it. If not, checkpoint and push **only** those two records before the audit. Do not stage unrelated files.
5. Read the applicable global agent instructions, canonical Project Conformance Audit Standard, Responses 91, 92, 102, 103, and the current graph implementation and tests. Current code is authoritative for actual behavior; prior reports provide context and hypotheses to verify.
6. If any preflight requirement materially fails, **STOP AND REPORT**. A source-only baseline manifest outside the repository is allowed.

### 2. Exact graph footprint and ownership inventory

Inventory the current Conversation Graph schema version and every material table, column, primary/unique key, index, trigger, migration, and relationship. At minimum inspect `messages`, `handles`, `canonical_handles`, `handle_aliases`, `chats`, `chat_to_message`, `chat_to_handle`, `contacts`, `contact_to_handle`, `attachments`, `message_to_attachment`, and `message_text_fts`; identify any additional current graph tables rather than assuming this list is exhaustive.

For each domain identify its authoritative source-ledger inputs, graph writer/repository, persisted material, provenance retained or discarded, dependencies on pre-existing graph state, update/upsert/ignore semantics, and material versus operational fields. Do not infer reconstructibility from row counts or schema names.

### 3. Trace the real production graph pipeline

Source-trace the full graph build, incremental Data Update/Operating update, historical-source import/removal, and any repair/rebuild paths. Record the actual call graph, transaction ownership, ordering, source occurrence binding, cursor/high-water behavior, batching, and error/rollback semantics.

Determine whether full replay from an empty graph and incremental projection over a populated graph produce the same material state for the same admitted source evidence. Identify every case where previous graph state or operation order changes the result. Do not change any of these paths.

### 4. Audit consequential graph transformations

Specifically investigate:

- Message materialization, associated-message GUID resolution, sender canonical-handle references, semantic/item classification, system/sparse/error flags, and rich-text dependency.
- Handle normalization, canonical-handle grouping, alias preference and rebuild, local-account reconciliation, and rewrites of existing sender/contact references.
- Contacts and contact-channel matching to graph aliases, first-eligible contact-to-handle association, and historical/cross-source cases.
- Chats, participant-edge counts, group classification, existing-row behavior, and order dependence.
- Attachment materialization and all three source-ledger-to-graph relationship reductions, including duplicate collapse and lost raw join identity.
- Cross-source provenance, source registry IDs, and stability of source-scoped identities used by overlays or other protected data.

For each transformation classify it as **(A)** deterministic and already shared, **(B)** stateful but faithfully replayable through existing production writer with complete explicit inputs, **(C)** a deterministic boundary requiring narrow extraction before a witness, or **(D)** presently unprovable/unsupported. Explain classification with actual source and test evidence. Do not extract code in this audit.

### 5. Disposable replay feasibility

Determine whether existing production graph writers can be run against a wholly disposable synthetic import ledger and graph, using their real schema and ordering, without opening or mutating the admitted live root. Identify exact dependency seams and any hidden global providers, native services, clocks, paths, or source readers that prevent safe replay.

Define the smallest meaningful synthetic fixture and characterization that covers:

- Multiple source occurrences and identity collisions;
- canonical aliases and competing normalization preferences;
- contact matching, ambiguous handles, and local-account state;
- group chat and participant order;
- associated-message GUIDs and missing references;
- duplicate source relationships versus collapsed graph edges;
- rich-text success/failure and message classification;
- pre-existing graph state versus empty full replay;
- incremental cursor boundary, repeated import, and historical-source removal;
- errors, rollback, cancellation, and bounded-resource failures.

Identify whether existing tests exercise the **actual production writer**, not a handwritten approximation. State exact gaps without claiming a test was run if only inspected.

### 6. FTS dependency and comparison boundary

Inventory `message_text_fts` configuration, external content table, triggers, tokenizer, prefix settings, and production index maintenance/rebuild behavior. Determine whether FTS equivalence can be checked using a disposable production-schema graph and bounded query corpus while keeping the live FTS read-only. Distinguish indexed text/row equivalence from search-query equivalence and identify runtime/SQLite compatibility risks. No live rebuild or index mutation.

### 7. Protected-reference and historical evidence

Trace graph identities referenced by user overlays (notes, favourites, tags, suppression, manual associations), Presence, archive metadata, historical/non-live sources, and other protected state. Identify which references would survive a disposable replay identically, which would become dangling, and which cannot currently be classified. The graph must not be used as evidence that raw historical join-row provenance can be reconstructed.

Provide concrete known **FALSE** and **UNKNOWN** counterexamples. `TRUE` requires complete, stable, bidirectional material equivalence and valid protected references; absence of observed errors is insufficient. No missing evidence may be interpreted as zero.

### 8. Read-only witness composition options

Compare at least these two architectures against actual code:

1. Reuse the existing production graph repositories/writers to construct an isolated disposable expected graph, then read-only compare all material tables and FTS with the existing graph.
2. Extract additional pure graph transformations only where actual stateful dependencies make the replay strategy unsafe or non-equivalent.

Assess authority duplication, schema fidelity, source-occurrence binding, deterministic ordering, material/operational field classification, bidirectional missing/extra/value anti-diffs, runtime/resource budgets, cancellation, observation stability, and failure classification. No new evaluator, coordinator, mutation Ball, or destructive eligibility output.

A disposable writer may mutate **only its isolated fixture**; the audit itself must not run such a writer or access real data.

### 9. Recommended next milestone

Recommend exactly one narrow Prompt 105 task. State whether it should be (a) pre-edit characterization of a selected graph writer, (b) a narrow pure extraction, or (c) a disposable replay feasibility harness. Provide source-grounded reasons, exact permitted files and boundaries, pre-change characterization requirements, expected tests, architecture tripwires, performance budget, validation matrix, stop gates, and checkpoint sequencing.

Do not assume that another pure extraction is necessary merely because earlier extractions succeeded. Include a dependency-ordered plan for later ledger anti-diffs, graph/FTS equivalence, protected-reference checks, coherent source observations, fresh pre-mutation revalidation, and eventual Stage 2C qualification, **without authorizing any of them**.

### 10. Hard exclusions

Except for a narrowly required Prompt 103/Response 103 documentation checkpoint and creation of an untracked Response 104, make **no repository changes**. Do not modify source, tests, schema, migrations, generated code, dependencies, release metadata, or configuration. Do not build, install, launch, or run the app; do not run full Flutter/analyzer suites solely to repeat prior evidence. Do not access real Messages/Contacts databases, MessageLens import/graph/overlay/Presence databases, WD/Toshiba archives, attachment payloads, TCC/FDA, bookmarks, S3, or installed app state. Do not perform a reset, graph rebuild, FTS rebuild, mutation, production activation, or worktree merge/rebase.

### 11. Required Response 104

Create `104-CHECKPOINT-RICH-TEXT-EXTRACTION-AND-AUDIT-GRAPH-RECONSTRUCTION-EQUIVALENCE.md` under Feature 34 `01-ONBOARDING/responses/`, leaving it untracked for review.

Report: (1) exact Git baseline and prior documentation checkpoint; (2) complete graph schema/material inventory; (3) real full/incremental/historical call graphs and ordering; (4) per-domain transformation and ownership classification; (5) source provenance loss and relationship semantics; (6) actual-writer disposable replay feasibility and blockers; (7) existing tests versus missing characterization; (8) FTS comparison design; (9) protected overlay/historical reference risks; (10) known FALSE/UNKNOWN counterexamples; (11) witness architecture options with trade-offs; (12) precise Prompt 105 recommendation; (13) Project Conformance audit/design verdict, BLOCKER and SHOULD FIX counts; (14) final Git/untracked preservation; and (15) all continuing prohibitions.

Conclude exactly:

`RICH-TEXT EXTRACTION CHECKPOINTED: YES / NO`

`COMPLETE GRAPH MATERIAL AND WRITER INVENTORY: YES / NO`

`FULL AND INCREMENTAL GRAPH SEMANTICS DISTINGUISHED: YES / NO`

`DISPOSABLE PRODUCTION-WRITER REPLAY FEASIBILITY ASSESSED: YES / NO`

`GRAPH/FTS AND PROTECTED-REFERENCE GAPS IDENTIFIED: YES / NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE (AUDIT/DESIGN): PASS / FAIL`

`READY FOR NARROW PROMPT 105: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not implement Prompt 105 or any reconstruction witness during this task.
