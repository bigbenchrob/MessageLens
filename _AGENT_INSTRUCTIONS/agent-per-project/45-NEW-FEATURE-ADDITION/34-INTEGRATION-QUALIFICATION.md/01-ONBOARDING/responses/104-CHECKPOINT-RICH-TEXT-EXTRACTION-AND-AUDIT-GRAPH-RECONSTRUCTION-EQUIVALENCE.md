# MessageLens — Feature 34
## Response 104 — Checkpoint Rich-Text Extraction and Audit Conversation Graph Reconstruction Equivalence

**Date:** 2026-10-14
**Mode:** Read-only source-grounded architecture and evidence audit
**Result:** The existing production graph writers can be composed against disposable databases, but current evidence does not establish populated reconstruction equivalence. The next narrow milestone should be a disposable production-writer replay feasibility harness, not another pure extraction.

## 1. Verified baseline and prior checkpoint

- Repository: `/Users/rob/Development/FlutterProjects/remember_every_text`
- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `585385d49cda1a77e10652f69d0ce3f79ef073d5`
- Upstream: `origin/fix/onboarding-import-stuck-state`
- Upstream relationship at preflight: `0 ahead / 0 behind`
- Tracked worktree: clean
- Index: clean
- Shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- Pre-existing untracked inventory: 49 entries captured outside the repository at `/private/tmp/messagelens_prompt104_untracked_before.txt`; SHA-256 `a7be4e2a28cd61e90f0534d3eadc831bec507846295cd36f832a62b735d1ac2c`.
- Registered worktrees: four total; exactly one worktree owns `fix/onboarding-import-stuck-state`, at the repository above.

All eight source-projection implementation checkpoints are ancestors of HEAD:

- contacts: `a36feac8`
- messages: `d77d08c6`
- handles: `ae6aa649`
- chats: `10732e29`
- attachments: `417a7ef1`
- chat-message: `59f86153`
- chat-handle: `32b18a6a`
- message-attachment: `b788c07e`

The rich-text semantic projection implementation commit `e340bdca0c6b8af9d40ab312a7f455d2fd9910db` is also an ancestor. Prompt 103 and Response 103 were already committed and pushed together at the current HEAD, `585385d49cda1a77e10652f69d0ce3f79ef073d5` (`docs(appczar): record rich-text semantic projection`). No duplicate documentation checkpoint was created.

No build, app launch, test suite, admitted database, archive, attachment payload, TCC/FDA state, or installed-app state was used in this audit. Source and existing committed test evidence were inspected; tests were not re-run merely to repeat prior evidence.

## 2. Complete Conversation Graph schema and material inventory

Authoritative schema: `lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart`.

Schema version is **3**. No additional current graph tables were found beyond the following material tables and FTS virtual table. The schema declares no SQL foreign keys; relationship validity is therefore a writer/comparison responsibility.

### `messages`

- Columns: `ss_id INTEGER PRIMARY KEY`, `guid TEXT`, `sender_handle_ss_id INTEGER`, `is_from_me INTEGER NOT NULL CHECK 0/1`, `date_utc TEXT`, `text TEXT`, `associated_message_ss_id INTEGER`, `sender_canonical_handle_ss_id INTEGER`, `semantic_kind TEXT`, `item_kind TEXT`, `is_system_message INTEGER NOT NULL DEFAULT 0 CHECK 0/1`, `is_sparse_artifact INTEGER NOT NULL DEFAULT 0 CHECK 0/1`, `has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK 0/1`, `has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK 0/1`, `has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK 0/1`, and `error_code INTEGER`.
- Material key: source-scoped packed `ss_id`.
- Material includes the rich-text result, classifications, source flags, associated-message reference, raw sender reference, and canonical sender reference.
- Migration compatibility also calls `_addColumnIfMissing('messages', 'text TEXT')`.

### `message_text_fts`

- FTS5 external-content virtual table with one indexed column, `text`.
- `content='messages'`; `content_rowid='ss_id'`.
- Tokenizer: `unicode61 remove_diacritics 2`.
- Prefix indexes: `2 3 4`.
- Triggers:
  - `message_text_fts_after_insert`: inserts `new.ss_id/new.text`.
  - `message_text_fts_after_delete`: emits the FTS delete command for `old.ss_id/old.text`.
  - `message_text_fts_after_text_update`: deletes old indexed text and inserts new indexed text.
- Migration from schema versions below 3 issues the FTS `rebuild` command after schema creation. Ordinary projection relies on the triggers; no ordinary graph build invokes a global FTS rebuild.

### Handle topology

- `handles`: `ss_id INTEGER PRIMARY KEY`, `id TEXT NOT NULL`, `service TEXT`, `is_me INTEGER NOT NULL DEFAULT 0 CHECK 0/1`; index `idx_working_handles_id(id)`.
- `canonical_handles`: `canonical_handle_ss_id INTEGER PRIMARY KEY`, `display_handle TEXT NOT NULL`, `normalized_identifier TEXT NOT NULL`, `service TEXT`, `alias_count INTEGER NOT NULL`; index `idx_canonical_handles_normalized(normalized_identifier)`.
- `handle_aliases`: `handle_ss_id INTEGER PRIMARY KEY`, `canonical_handle_ss_id INTEGER NOT NULL`, `raw_identifier TEXT NOT NULL`, `normalized_identifier TEXT NOT NULL`, `alias_kind TEXT NOT NULL`; indexes `idx_handle_aliases_canonical(canonical_handle_ss_id)` and `idx_handle_aliases_normalized(normalized_identifier)`.

### Chat topology

- `chats`: `ss_id INTEGER PRIMARY KEY`, `guid TEXT`, `service TEXT`, `is_group INTEGER NOT NULL CHECK 0/1`, `last_read_message_at_utc TEXT`.
- `chat_to_message`: `chat_ss_id INTEGER NOT NULL`, `message_ss_id INTEGER NOT NULL`, composite primary key `(chat_ss_id, message_ss_id)`.
- `chat_to_handle`: `chat_ss_id INTEGER NOT NULL`, `handle_ss_id INTEGER NOT NULL`, unique pair `(chat_ss_id, handle_ss_id)`.

### Contact topology

- `contacts`: `contact_id INTEGER PRIMARY KEY`, `display_name TEXT NOT NULL`, `given_name TEXT`, `family_name TEXT`, `organization TEXT`; index `idx_working_contacts_display_name(display_name)`.
- `contact_to_handle`: `contact_id INTEGER NOT NULL`, `handle_ss_id INTEGER NOT NULL`, `handle_value TEXT NOT NULL`, unique pair `(contact_id, handle_ss_id)`; indexes `idx_contact_to_handle_handle(handle_ss_id)` and `idx_contact_to_handle_contact(contact_id)`.

### Attachment topology

- `attachments`: `ss_id INTEGER PRIMARY KEY`, `guid TEXT`, `filename TEXT`, `transfer_name TEXT`, `uti TEXT`, `mime_type TEXT`, `total_bytes INTEGER`, `created_at_utc TEXT`; index `idx_working_attachments_guid(guid)`.
- `message_to_attachment`: `message_ss_id INTEGER NOT NULL`, `attachment_ss_id INTEGER NOT NULL`, unique pair `(message_ss_id, attachment_ss_id)`; indexes `idx_working_message_to_attachment_message(message_ss_id)` and `idx_working_message_to_attachment_attachment(attachment_ss_id)`.

`clearProjectionRows()` owns the one graph-wide clearing transaction. It deletes relationship, alias, and material rows in dependency order. This reset facility is not itself evidence that a subsequent multi-stage rebuild is atomic.

The source import ledger is schema version 10 and owns `source_registry`, `import_batches`, `messages`, `handles`, `chats`, `contacts`, `contact_channels`, `attachments`, `chat_to_message`, `chat_to_handle`, and `message_to_attachment`. Its source-occurrence rows and source registry are authoritative projection inputs. Batch records and timestamps are operational evidence; graph tables contain material browsing state and no build timestamps.

## 3. Real production call graphs, ordering, and transaction boundaries

### Full/live graph build

`ConversationGraphBuildController` single-flights in memory, enters the existing archive mutation operation for graph build, calls the build service/orchestrator, and bumps the data version only after success. `ConversationGraphBuildOrchestrator.runOnce` performs the following actual order:

1. Import chats into the source-scoped ledger.
2. Import handles.
3. Import contacts/channels.
4. Import messages.
5. Enrich missing message text through the extracted rich-text semantic projection.
6. Import attachments.
7. Import chat-message relationships.
8. Import chat-handle relationships.
9. Import message-attachment relationships.
10. Project handles, then rebuild canonical handles/aliases and sender/contact references.
11. Project contacts.
12. Project chat-handle edges.
13. Project chats.
14. Project messages.
15. Project attachments.
16. Project chat-message edges.
17. Project message-attachment edges.

Each importer/repository owns its own transaction or bounded transaction. There is no transaction spanning the ledger, graph, rich-text pages, archive work, or all projection stages. A failure rolls back the current local transaction/page, not previously completed stages.

The message importer freezes a read-only source high-water and count, records a batch outside its page transactions, reads pages of 500, applies the extracted source-message projection, commits each page, and validates the completed count. Existing source occurrences are insert-ignored; a source mutation below the cursor is not refreshed by the incremental importer. `SourceScopedRowKey` packs `source_id` with the raw source row ID, so registry identity is material.

### Full versus incremental projection

When no message rows were newly inserted, the orchestrator still performs a full missing-rich-text scan, broad relationship imports, full message and attachment projection, and full relationship projection. When messages were inserted, rich text, message projection, chat-message import/projection, and message-attachment import/projection are bounded after the message cursor for live source 1. Attachment import/projection uses its own attachment cursor and runs incrementally only when new attachments were observed. Handles, chats, contacts, and chat-handle work remain broad.

Data Update observes current source and ledger high-waters/counts, calls this same graph-build controller when newer data exists, then performs attachment preservation. It has no transaction that rolls back the completed graph build if later attachment work fails.

### Historical source import

`SourceScopedArchiveImportService` registers the historical source and imports, in order: handles, chats, messages, attachments, chat-handle, chat-message, message-attachment, and rich text. Historical archives do not supply contacts.

`SourceScopedArchiveGraphImportService` then invokes the production projectors in this order: handles, chat-handle, chats, messages, attachments, chat-message, message-attachment. It neither resets the graph nor projects contacts. Message projection is broad after rich-text completion. Stages remain separately transactional.

### Historical source removal/rebuild

`SourceScopedArchiveGraphRemovalService` identifies the source, deletes that source's ledger facts in one import-ledger transaction while retaining its registry identity, clears the graph in one graph transaction, and reprojects handles, contacts, chat-handle, chats, messages, attachments, chat-message, and message-attachment. The post-clear stages are not enclosed in one transaction, so interruption can leave a partial graph.

## 4. Transformation, ownership, and reconstructibility classification

The classifications below mean: **A** deterministic and already shared; **B** stateful but replayable through the actual writer when all inputs and the starting state are explicit; **C** deterministic logic that still must be extracted before a witness; **D** presently unsupported or unprovable.

### Source-to-ledger and rich text — A

The eight source projections established in Responses 93–101 and the rich-text semantic projection established in Response 103 are shared pure boundaries with parity characterization. Apple timestamp conversion remains centralized in `DateConverter`. These facts establish narrow transformation parity only; they do not establish ledger completeness or graph equivalence.

### Handles, aliases, and canonical sender rewrites — B, with D edges

The production handle repository reads all ledger handles, inserts missing graph handles, updates `is_me` on existing rows, then completely rebuilds canonical handles and aliases from graph handles. The alias interpreter drops no raw handle row, but handles that cannot be normalized receive no alias. Preference scoring chooses a representative deterministically from the available ordered rows: exact normalized email, digit/end match, plus form, non-colon form, then lowest `ss_id`. It rewrites every message's canonical sender reference and deletes contact edges to canonical handles that no longer exist.

The writer is reusable and stateful (**B**) when the ledger, starting graph, local-account result, and order are explicit. Local-account reconciliation can depend on current source/account evidence outside the graph replay input; without an injected or recorded value that part is **D**. Stable results also require the same `source_registry` IDs.

### Contacts — B for literal replay; populated equivalence presently FALSE

The contact repository reads ledger contacts/channels and current graph aliases. Contacts without a meaningful name or organization become the deterministic `Unknown Contact` result per the extracted source projection. The graph writer uses `INSERT OR IGNORE` for contacts and for the first eligible channel-to-canonical-handle association. It does not update an existing contact row and does not generally remove stale contact-to-handle pairs.

The actual writer can be replayed (**B**) against an explicit starting graph, but empty replay and projection over a stale populated graph are not guaranteed to converge. Competing contacts, channel order, ambiguous aliases, and pre-existing stale material require characterization. No remaining pure extraction is proven necessary (**C: none established**).

### Chats and participant-derived group state — B; populated equivalence presently FALSE

The chat repository derives `is_group` from the participant edges already present in `chat_to_handle`, then uses `INSERT OR IGNORE`. Existing chat material, including group state, is not refreshed. Correct order is therefore material: chat-handle edges must precede chat projection. Literal replay is **B** with explicit starting state and ordering; convergence from arbitrary populated state is not established.

### Messages — B

The message repository resolves associated-message GUIDs only within the same ledger source, resolves canonical senders through current aliases, copies rich-text-enriched ledger text, applies deterministic semantic/item/system/sparse classification, and updates all projected message columns after insert-or-ignore. FTS triggers run as `text` changes. Using the actual repository makes these private deterministic helpers part of the production replay; a new handwritten equivalent or extraction is not required for feasibility. Replay is **B** provided the ledger, aliases, runtime, and ordering are explicit.

### Attachments — B

The attachment repository projects all or cursor-bounded ledger attachments and inserts then updates every material field. It is **B** with explicit ledger/cursor input.

### Relationships — B for reduction; D for discarded provenance

The three relationship writers reduce ledger occurrences to unique graph endpoint pairs with `INSERT OR IGNORE`. They do not delete graph pairs absent from a later input. Duplicate raw join occurrences therefore collapse, and raw join identity/provenance is not stored in the graph. Replaying the reduction is **B**; reconstructing raw joins from the graph is **D** and must never be inferred.

### Source identities — D unless registry continuity is established

Graph IDs are packed from ledger `source_id` plus source row ID. Recreating logically identical source facts with a different registry allocation yields different graph identities. The original `source_registry`, source keys, and packed-ID contract must be part of witness evidence. Human-visible equality is not protected-reference equality.

## 5. Provenance retained and discarded

Retained in the ledger: source registry identity, source occurrence IDs, raw source row IDs, raw relationship endpoints, batches, and rich source message material. Retained in the graph: packed endpoint IDs and reduced material/relationship state needed for browsing.

Discarded by graph projection includes raw duplicate join identities, relationship occurrence ordering, batch identity, raw contact-channel occurrence identity, and enough information to reverse the reduced graph into a source archive. Associated-message projection retains the resolved graph endpoint, not every failed or ambiguous resolution attempt. Canonical alias tables retain the selected grouping/result, not an independent proof that the original source/account evidence was complete.

## 6. Disposable actual-writer replay feasibility

The production repositories accept explicit `ImportDatabase` and `ConversationGraphDatabase` dependencies. Both databases can be opened at disposable paths, and the graph schema, triggers, and repositories can therefore be exercised without an admitted live root. The viable seam is below source import: seed or clone a wholly disposable ledger with fixed source-registry identities, then invoke the real graph repositories in production order against a wholly disposable graph.

The feasibility harness must not use provider compositions that resolve the admitted data root, native Messages/Contacts paths, archive bookmarks, or live local-account readers. Source readers and native services are not needed to characterize graph-writer replay once explicit ledger input is supplied. Clocks affect ledger registry/batch evidence but not current graph rows; fixtures must nonetheless fix registry and batch identities to prevent incidental differences.

Safe replay is therefore feasible in principle, but not yet proven. Hidden/global risks requiring executable characterization are local-account reconciliation, any provider that substitutes live source dependencies, SQLite/FTS runtime variation, memory/time behavior on bounded fixtures, and cancellation/failure between separately committed writer stages.

## 7. Existing production-writer tests and exact gaps

Existing tests inspect or invoke the actual production repositories for handle topology, contacts, chats, messages, attachments, all three relationship reductions, historical archive graph import/removal, FTS triggers/migration, orchestrator ordering, controller single-flight, and rich-text full versus bounded selection. Evidence includes idempotence, source-scoped identity, aliases, sender rewrite, group classification, incremental boundaries, duplicate edge collapse, FTS insert/update/delete behavior, historical removal/reprojection, and retry after interruption before the first graph projection.

They do **not** currently provide one bidirectional material comparison across every graph table after replay. Missing characterization includes:

- Empty expected graph versus deliberately stale/extra populated graph.
- Existing contact/chat rows that `INSERT OR IGNORE` does not refresh.
- Extra relationship rows that additive writers do not remove.
- Fixed source-registry identity versus reallocated source IDs.
- Ambiguous competing contacts and aliases under explicit deterministic ordering.
- Duplicate GUID and missing associated-message cases across sources.
- A single actual-writer fixture covering rich-text outcomes and graph classification together.
- Cross-mode equivalence among full, incremental, repeated, historical import, and historical removal.
- Failure/cancellation at every writer boundary and resource-bounded execution.
- Complete protected-reference anti-joins.
- Complete FTS index equivalence, as distinct from message-row text equality.

No test result is claimed from this audit; these conclusions come from source and committed test inspection.

## 8. FTS comparison boundary

A witness must distinguish three questions:

1. **Content-row equivalence:** bidirectionally compare `messages.ss_id` and exact nullable `messages.text` plus every other material message column.
2. **Indexed-row/text evidence:** verify disposable FTS trigger/rebuild behavior under the production schema. Reading `SELECT rowid, text FROM message_text_fts` alone is insufficient because external-content FTS can expose content-table values even if the internal index is stale.
3. **Search equivalence:** execute a fixed, bounded corpus through the production search query against both read-only existing and disposable expected graphs, comparing ordered result IDs. The corpus must cover case folding, diacritics, punctuation, prefixes 2/3/4, empty/null text, and representative non-Latin text.

The disposable graph may use FTS5 integrity/rebuild diagnostics because it is isolated. The existing graph must remain read-only; no `rebuild`, optimize, repair, or auxiliary-table creation may occur there. The witness must record the SQLite version, FTS5 availability/compile behavior, tokenizer configuration, and application runtime. Matching material rows plus a bounded query corpus is strong evidence, but it is not a mathematical proof for every possible FTS query or runtime. That residual must remain UNKNOWN unless a safe internal-index comparison is established.

## 9. Protected references and historical evidence

The overlay database is independent preservation data. Direct graph-keyed references include participant/contact IDs, favorite contacts, manual handle-to-participant associations, handle visibility, chat overrides, graph-native message intent/tag rows, and conversation tags. Compatibility rows also use message GUIDs, normalized handles, legacy/live message row IDs, and archived-attachment tuples keyed by message GUID plus an unscoped live attachment row ID.

The overlay-to-graph compatibility bridge explicitly permits live graph endpoints only and accepts a GUID fallback only when it resolves uniquely. A replay with different packed IDs, duplicate GUID ambiguity, missing reduced edges, or different canonical-handle representatives can therefore leave direct references dangling or change compatibility interpretation even if visible message text is identical.

Presence schema version 9 contains onboarding/journey scheduling and trace state; no graph-ID reference was found in the inspected schema. It remains independent protected state and must not be mutated by a graph witness. Archive instance/root/checkpoint/adoption evidence is also independent of graph reconstruction, while archive-coverage classification consumes graph and overlay evidence and can change if endpoints differ. Historical donor files and ledger source-registry rows are preservation/provenance evidence and must remain intact.

Required protected-reference checks include bidirectional anti-joins for every direct graph key, unique GUID/normalized-handle resolution where a compatibility fallback is used, live-only enforcement for archived attachment compatibility, and unchanged archive/source identities. Missing evidence is UNKNOWN, never zero.

## 10. Concrete FALSE and UNKNOWN counterexamples

Known **FALSE** cases under current writer semantics:

1. A populated `contacts` row with stale names remains stale because contact projection insert-ignores the existing key; an empty replay receives current ledger names.
2. A populated `chats` row with stale `is_group` remains stale because chat projection insert-ignores it; an empty ordered replay computes current participant-derived state.
3. An extra graph relationship remains after additive relationship projection, while an empty replay contains only current ledger reductions.
4. A source mutation/deletion below an importer cursor is not refreshed by the incremental import path, so clean source import and current ledger/graph need not match.
5. Reallocating a source registry ID changes every packed identity for that source and can invalidate direct overlay references despite equivalent visible content.
6. Failure after graph clear or between writer stages can expose a committed partial graph because the rebuild is not globally transactional.
7. Matching `messages.text` and rows read through an external-content FTS table does not prove the internal FTS index is current.

Current **UNKNOWN** cases:

- Whether the admitted populated graph and ledger are materially equivalent; they were not accessed.
- Whether every current overlay direct reference resolves uniquely and identically.
- Whether the live FTS internal index is equivalent for all searches.
- Whether historical donor content, source registry, and current source evidence form one coherent observation.
- Whether local-account reconciliation can be fully reproduced without live source evidence.
- Whether ambiguous duplicate GUID/contact/normalized-handle cases are deterministic under every production input order.
- Whether a full-size disposable replay stays within an acceptable memory, time, and cancellation budget.

Consequently, populated reconstruction equivalence is neither TRUE nor safely usable as destructive eligibility.

## 11. Witness architecture options

### Option 1 — actual production-writer replay

Seed an isolated production-schema ledger with fixed source identities, invoke the existing graph writers in their actual dependency order into an isolated production-schema graph, then compare every material table bidirectionally with the read-only observed graph.

Advantages: maximum schema and behavior fidelity; no second semantic implementation; real triggers and private message classifiers execute; stateful ordering is visible. Risks: provider leakage to live paths, stateful `INSERT OR IGNORE` nonconvergence, local-account input, stage-level transactions, FTS runtime differences, and resource/cancellation behavior. These risks are testable with a small harness.

### Option 2 — additional pure extractions

Extract only a transformation demonstrated to prevent safe actual-writer replay. No such required **C** boundary was established in this audit. Extracting message classifiers, alias scoring, or contact/chat selection preemptively would add parallel APIs without proving the stateful writer semantics that actually govern populated graphs.

### Decision

Use Option 1 for the next milestone. Preserve the production writers as the sole materialization implementation. A future witness must classify material versus operational fields explicitly, compare missing/extra/value differences in both directions, pin source occurrence identity and ordering, retain failure/UNKNOWN rather than producing destructive eligibility, and observe source/ledger/graph evidence coherently before any later authorization discussion.

## 12. Exactly one recommended Prompt 105

**Recommendation: (c) implement a disposable replay feasibility harness.**

Permitted files should be limited to:

- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_harness.dart`
- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart`
- Prompt 105 and Response 105 records.

No `lib/`, schema, migration, generated, dependency, release metadata, configuration, AppCzar, Start Fresh, or activation file should change.

Pre-edit characterization must lock the current writer behavior, including the known nonconvergence cases, before any implementation. The harness should create disposable production-schema ledger/graph files, seed fixed `source_registry` IDs and a compact synthetic corpus, and call the actual repositories in production order. It must not reimplement transformations.

The smallest meaningful corpus should remain bounded (target no more than 50 messages, 12 handles, 8 contacts, 8 chats, 24 attachments, and enough duplicate relationships to exercise collapse) while covering multiple sources/collisions, alias preferences and unnormalizable handles, competing contact channels/local-account state, participant ordering/group classification, associated and missing GUIDs, rich-text success/failure, duplicate raw joins, empty versus stale populated graph, full/incremental/repeat/historical-removal boundaries, and injected stage failure/cancellation.

Validation should include the focused harness test, relevant architecture tests, and analyzer only. No app launch, build, live database, archive, or attachment access. Record focused-test wall time and peak-memory evidence when reliably available; design the fixture to complete within 10 seconds and approximately 64 MiB incremental RSS, but do not add a flaky wall-clock assertion.

Stop if an actual writer cannot be instantiated without an admitted/live provider, any path escapes the disposable root, a schema/production change becomes necessary, fixed inputs still produce unexplained nondeterminism, or the task turns into repairing the populated graph.

Checkpoint sequencing: verify the same clean baseline; add current-behavior characterization first; implement only the test harness; run focused/architecture/analyzer validation; inspect and checkpoint only permitted harness/record files as Prompt 105 directs; leave all unrelated untracked files untouched.

Dependency-ordered later work, not authorized here: (1) ledger/source-registry bidirectional anti-diffs; (2) every graph table/value/relationship anti-diff; (3) bounded FTS material/query evidence; (4) protected-reference anti-joins; (5) coherent two-sample source/ledger/graph observation; (6) fresh pre-mutation revalidation; (7) separate Stage 2C human qualification. None may convert UNKNOWN to TRUE by omission.

## 13. Project Conformance audit/design verdict

**Verdict: PASS for this read-only audit and the narrow Prompt 105 design.** This is not a reconstruction-readiness or destructive-authorization PASS.

**BLOCKER count: 6**

1. Populated-state nonconvergence from insert-ignore/additive writer behavior is not characterized end to end.
2. Source-registry continuity and packed identity equivalence are not proven.
3. No complete bidirectional graph-material and FTS comparator exists.
4. Protected direct graph references and compatibility keys are not validated against replay output.
5. No coherent, stable cross-store observation protocol proves that compared evidence belongs to one revision.
6. Actual-writer failure, cancellation, and bounded-resource behavior are not covered by one disposable harness.

**SHOULD FIX count: 4**

1. Encode an explicit executable manifest of material versus operational fields.
2. Characterize deterministic ordering for aliases, competing contacts, duplicate GUIDs, and relationship collapse.
3. Record SQLite/FTS runtime identity and compare a bounded semantic query corpus.
4. Cover full, incremental, repeated, historical import, and historical removal through the same production-writer fixture.

The proposed harness respects database/provider ownership, avoids a parallel evaluator or semantic writer, uses no new mutation authority, keeps overlay/archive preservation independent, and does not change the seven AppCzar jurisdictions.

## 14. Final Git and untracked preservation

This response is the sole repository write authorized by Prompt 104 and is intentionally untracked for review. Prompt 104 remains untracked. No tracked file or index entry changed, no commit or push was made, and the shared-instructions submodule remained clean at `95326f515ef4719f155ce6e223990398daad6311`. Final verification found `0 ahead / 0 behind`, clean tracked and cached diffs, and 50 untracked entries: the exact pre-existing 49-entry inventory plus this response. Excluding this response, `cmp` against the preflight manifest returned 0 and the inventory SHA-256 remained `a7be4e2a28cd61e90f0534d3eadc831bec507846295cd36f832a62b735d1ac2c`.

## 15. Continuing prohibitions

No complete reconstruction witness exists. No graph/FTS rebuild, repair, destructive Start Fresh, Stage 2C eligibility, production AppCzar activation, new evaluator/coordinator, mutation Ball, live-data access, archive mutation, or protected-state rewrite is authorized. The seven AppCzar jurisdictions remain unchanged. Prompt 105 is recommendation only and was not begun.

RICH-TEXT EXTRACTION CHECKPOINTED: YES

COMPLETE GRAPH MATERIAL AND WRITER INVENTORY: YES

FULL AND INCREMENTAL GRAPH SEMANTICS DISTINGUISHED: YES

DISPOSABLE PRODUCTION-WRITER REPLAY FEASIBILITY ASSESSED: YES

GRAPH/FTS AND PROTECTED-REFERENCE GAPS IDENTIFIED: YES

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE (AUDIT/DESIGN): PASS

READY FOR NARROW PROMPT 105: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
