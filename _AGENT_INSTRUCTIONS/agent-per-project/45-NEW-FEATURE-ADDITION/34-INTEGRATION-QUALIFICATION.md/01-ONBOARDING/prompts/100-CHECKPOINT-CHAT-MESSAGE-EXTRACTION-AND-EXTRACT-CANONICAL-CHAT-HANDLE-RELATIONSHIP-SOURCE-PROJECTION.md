# MessageLens — Feature 34
## Prompt 100 — Checkpoint Chat–Message Extraction and Extract Canonical Chat–Handle Relationship Source Projection

**Milestone:** Second narrow source-scoped relationship extraction, following Response 98's audit and Response 99's qualified Chat–Message extraction.

**Governing limits:** The populated reconstruction-equivalence witness does not exist. Destructive Operating Start Fresh/Stage 2C remains blocked; production AppCzar activation remains off. Do not change these statuses.

> Characterize the actual production `ChatHandleJoinImporter` before modifying it. Extract only its existing deterministic admitted-row-to-ledger mapping into one pure, typed, synchronous function. Preserve every observable writer, endpoint, transaction, batch, error, progress, and lifecycle behavior.

## 1. Preflight and checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`.

Require synchronized upstream (0/0), clean tracked worktree and index, clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`, exactly one Feature 34 worktree, and preservation of unrelated untracked files. Verify the five scalar extraction commits and Chat–Message implementation `59f86153` in ancestry. Verify whether Prompt 99/Response 99 have already been checkpointed and pushed; if not, checkpoint *only those two documents* and push before source edits. Never duplicate a checkpoint.

Read current global project instructions, canonical Project Conformance rules, Responses 92–99, and the actual importer, source port, ledger schema, identity utilities, and existing tests. Create a source-only baseline manifest outside the repository. Do not inspect real data.

Stop if any material preflight requirement fails.

## 2. Exact scope

Permitted production changes only:

- `lib/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart` (verify actual path)
- a single new sibling `chat_handle_relationship_source_projection.dart`

Permitted tests only:

- a new actual-writer characterization test in the matching `test/essentials/source_scoped_import/application/chat_handle_joins/` directory
- a new direct pure-projection test beside it
- a new narrow AST/dependency architecture test under `test/architecture/`

If current source uses different paths, verify and document them before editing; do not infer a new importer. Existing regression tests must retain their meaning and should not be edited. No schema, migration, source SQL, graph, FTS, rich-text, Contacts, Messages, Handles, Chats, Attachments, other join importer, archive, AppCzar, Start Fresh, release, packaging, or generated-file changes.

No app build or launch; no real Apple Messages/Contacts, MessageLens database, WD/Toshiba archive, or other live data access.

## 3. Source-trace actual writer

Before writing production code, enumerate the exact `ChatHandleJoinImporter` call graph and schema. Response 98 found:

```sql
SELECT chj.ROWID AS source_rowid,
       chj.chat_id,
       chj.handle_id,
       c.ROWID AS existing_chat_rowid,
       h.ROWID AS existing_handle_rowid
FROM chat_handle_join chj
LEFT JOIN chat c ON c.ROWID = chj.chat_id
LEFT JOIN handle h ON h.ROWID = chj.handle_id
ORDER BY chj.ROWID ASC
```

Verify this against current source, not prose. The scan is full and materialized, not incremental/paged. **Do not change it.**

Response 98 records the `chat_to_handle` ledger columns:

```text
source_id
source_chat_rowid
source_handle_rowid
chat_ss_id
handle_ss_id
batch_id
```

Verify exact actual column inventory, constraints, and insertion order. The raw join ROWID is used for progress/error context but **not persisted**. Identity is the source-plus-endpoint tuple, so duplicate raw join rows with identical endpoints collapse under `insertIgnore`.

Critically, the importer allocates a timestamped batch **before opening the source**; it survives open/query/transaction failures. Preserve that exact sequence, including empty input, progress, errors, rollback, and source closure. Source `LEFT JOIN` endpoint existence and incomplete-row omission remain importer-owned. The pure projection must not see or decide endpoint-existence evidence.

## 4. Characterize unchanged production writer before edits

Using a synthetic `ReadOnlySourceDatabase` and the actual disposable `ImportDatabase`, create a frozen characterization exercising the unchanged production importer. Record baseline SHA-256 of importer and characterization file, and run the characterization successfully **before production edits**.

Freeze exact persisted row maps and ordering, source ID and packed endpoint identities, live and non-live source IDs, int/rounded-double coercion, invalid/missing raw join ROWID, missing Chat and missing Handle independently, duplicate raw joins with same endpoints, same Chat with different Handles, `insertIgnore` rerun, empty source, batch ID/time semantic contract, batch surviving failures, every progress/anomaly/result event, transaction rollback after an earlier admitted row, source open/query/write/progress failures, and source closure on all post-open paths. Distinguish deterministic material equality from genuinely variable batch timestamps without fabricating a fixed clock.

If existing ports cannot characterize the actual writer without changing its behavior, **STOP**. Do not characterize a handwritten surrogate.

## 5. Extract one pure admitted-row projection

Use repository conventions for typed immutable input/output. Conceptually:

```text
ChatHandleRelationshipSourceProjectionInput
  raw sourceChatRowId
  raw sourceHandleRowId
  (only other raw admitted facts actually required)

projectSourceChatHandleRelationship(input, sourceId, batchId)
  -> ProjectedSourceChatHandleRelationship
     immutable complete ledgerValues
```

Reuse `SourceScopedRowKey.pack`; never reproduce its bit layout. The output must preserve all six persisted columns, null/error/coercion behavior, source identity, batch lineage, and the exact existing row map. No SQL, DAO, source port, ledger, graph, provider, filesystem, clock, I/O, `Future`, `Stream`, callback, progress, transaction, or mutation authority in the pure module.

Keep raw join ROWID validation and progress context in the importer at the original execution point. Keep `existing_chat_rowid` / `existing_handle_rowid` interpretation, endpoint omission, source opening/closing, query, batch creation, transaction, `insertIgnore`, counters, progress, error handling, and rollback in the importer. Invoke the concrete projection exactly once on the admitted-row formation path; remove the former duplicate inline mapping.

If purity requires moving endpoint proof, batch allocation, SQL, or lifecycle timing, STOP rather than broadening scope.

## 6. Exact post-edit parity and direct tests

Rerun the **unchanged frozen characterization** after extraction. Require exact parity of persisted values, order, identity, duplicates, omissions, progress, errors, rollback, batch semantics, and source lifecycle.

Direct projection tests must cover all six columns, immutable output, source/batch lineage, valid and invalid packed-key bounds, numeric coercion and required-field errors, whitespace/irrelevant source context where applicable, duplicate endpoint facts, and material versus irrelevant input changes.

Add AST/dependency enforcement proving the pure module's restricted imports, no async/I/O/authority, one concrete production call, absence of a duplicate row-formation path, and continued importer ownership of SQL, endpoint admission, batch-before-open, transactions, `insertIgnore`, progress, and source closure.

## 7. Validation

Run in dependency order:

1. frozen pre-edit characterization (before any production edit);
2. unchanged post-edit characterization, direct projection tests, AST tests;
3. source-scoped relationship and ledger regressions;
4. Conversation Graph handle/chat topology and canonical alias regressions;
5. historical-source, attachment/archive, AppCzar/Onboarding/Operating regressions;
6. complete architecture/forbidden-import suite;
7. `flutter analyze`;
8. complete deterministic `flutter test` suite;
9. Dart formatting, generated consistency, `git diff --check`, `git diff --cached --check`;
10. canonical Project Conformance audit requiring BLOCKER 0, SHOULD FIX 0.

Report actual unique full-suite count, not sum of overlapping selections. Response 99 recorded a concurrency-sensitive attachment-provider test failure followed by a successful serial rerun. Do not treat that issue as fixed; if it recurs, report each attempt literally, distinguish unrelated infrastructure instability from behavioral parity, and follow the applicable validation stop gate.

## 8. Stop gates

STOP and leave no exploratory source diff if: baseline writer cannot be characterized; pre/post material behavior differs; endpoint proof moves; batch-before-open or batch-survival semantics change; duplicate/omission policy changes; source SQL/ordering, transaction, progress, error, or closure changes; a second identity interpretation is introduced; graph or other excluded source must change; conformance or required tests fail; or unrelated tracked/submodule changes appear. A safe stop is an acceptable result, not an implementation PASS.

## 9. Checkpoints

If and only if all gates pass, stage only the permitted source/test/architecture files; commit a narrow implementation (`refactor(import): extract canonical Chat-Handle relationship source projection`) and push normally. Then write Response 100 and checkpoint Prompt 100/Response 100 in a separate documentation-only commit; push normally. Do not rebase, squash, force push, or stage unrelated files. Report actual final documentation hash in the handoff, not inside its own response.

## 10. Required Response 100

Record: exact baseline and Prompt 99 documentation checkpoint; source query and call graph; six-column schema and uniqueness; raw join identity versus endpoint identity; batch-before-open behavior; stateful endpoint admission; pre-edit actual-writer fixture and test result; typed pure contract; importer call edge; unchanged characterization parity; direct and AST tests; regression and complete-suite results; any intermediate failures; analyzer, formatting, generated and diff hygiene; conformance; exact implementation/documentation commits; final Git/submodule/untracked state; and next narrowly authorized extraction.

Conclude exactly:

```text
CHAT-MESSAGE EXTRACTION CHECKPOINTED: YES / NO
ACTUAL CHAT-HANDLE JOIN IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO
CANONICAL CHAT-HANDLE RELATIONSHIP PROJECTION IS PURE AND SHARED: YES / NO
SOURCE ENDPOINT-EXISTENCE AND OMISSION AUTHORITY REMAINS IMPORTER-OWNED: YES / NO
BATCH-BEFORE-SOURCE-OPEN SEMANTICS UNCHANGED: YES / NO
CHAT-HANDLE LEDGER ROWS, DUPLICATES, PROGRESS, ERROR, AND LIFECYCLE PARITY: PASS / FAIL / NOT REACHED
GRAPH CANONICAL-HANDLE AND ALIAS SEMANTICS UNCHANGED: YES / NO
FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR NEXT NARROW RELATIONSHIP EXTRACTION: YES / NO
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```

Then **STOP**. Do not begin Message–Attachment extraction, graph projection, a reconstruction witness, destructive Start Fresh, or production cutover in this task.
