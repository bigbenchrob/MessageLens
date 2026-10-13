# MessageLens — Feature 34
## Prompt 99 — Checkpoint Relationship Audit and Extract Canonical Chat–Message Relationship Source Projection

**Milestone:** First narrow source-scoped relationship transformation extraction, following Response 98's read-only audit.

**Governing status:** Contacts, Messages, Handles, Chats, and Attachments source projections have been characterized and extracted. The populated reconstruction-equivalence witness does **not** exist. Destructive Operating Start Fresh and Stage 2C remain **BLOCKED**; production AppCzar activation remains **OFF**. Nothing in this prompt lifts these restrictions.

> Characterize the actual production `ChatMessageJoinImporter` before editing it. Extract only the deterministic admitted source relationship-to-ledger row formation into one typed pure function consumed by the same importer. Preserve every persisted row, omission, duplicate, progress event, error, transaction, and source lifecycle observation exactly.

## 1. Baseline and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`.

Require clean tracked working tree and index; synchronized upstream (`0/0`); shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`; exactly one Feature 34 worktree; unrelated untracked paths untouched. Verify the five prior projection commits in ancestry:

- Contacts `a36feac8a48d1702aad5830076157830d6efb975`
- Messages `d77d08c6c55e18ade47983fb959b8023c893283c`
- Handles `ae6aa6496e9dd98378c61be1aa7d7984d7207f4c`
- Chats `10732e2986c5e40f7d097f35e2d12daff663fc4f`
- Attachments `417a7ef1b24b12991649edc978bd3d0326a6720a`

Verify Prompt 97/Response 97 documentation checkpoint `30bc9ea79846ee7ecc2730710998bc5801b42499` in ancestry. Read **Response 98 in full** and the canonical Project Conformance standard and applicable agent instructions. Response 98 is the controlling source-grounded design, not a license to expand its scope.

Prompt 98 and Response 98 are presently untracked according to Response 98. If still untracked, checkpoint **only those two documents** and push normally before source edits. If already committed, verify the checkpoint without duplicating it. Record actual HEAD and upstream afterward. Preserve all other untracked files.

Capture a fresh source-only baseline manifest outside the repository. Do not access real Messages/Contacts, MessageLens databases, archives, external-drive data, or installed applications.

## 2. Exact permitted scope

**Production files only:**

- `lib/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart`
- `lib/essentials/source_scoped_import/application/chat_message_joins/chat_message_relationship_source_projection.dart` (new)

**Test files only:**

- `test/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer_characterization_test.dart` (new)
- `test/essentials/source_scoped_import/application/chat_message_joins/chat_message_relationship_source_projection_test.dart` (new)
- `test/architecture/chat_message_relationship_source_projection_authority_test.dart` (new)

No other production, schema, migration, provider, graph, FTS, rich-text, attachment, archive, AppCzar, Start Fresh, build, packaging, or release file may change. Existing regression files stay unchanged. If the design cannot be implemented within this scope, STOP and report rather than expanding it.

No app build, installation, launch, or real-data qualification.

## 3. Trace the unchanged production writer

Before adding production code, source-trace `ChatMessageJoinImporter` including both full and incremental paths. Confirm Response 98's inventory against current source, and STOP on material disagreement.

Full source query:

```sql
SELECT cmj.ROWID AS source_rowid,
       cmj.chat_id,
       cmj.message_id,
       c.ROWID AS existing_chat_rowid,
       m.ROWID AS existing_message_rowid
FROM chat_message_join cmj
LEFT JOIN chat c ON c.ROWID = cmj.chat_id
LEFT JOIN message m ON m.ROWID = cmj.message_id
ORDER BY cmj.ROWID ASC
```

Incremental import adds `WHERE cmj.message_id > ?` before ordering, with the orchestrator-supplied starting source Message ROWID. The result is fully materialized, without paging. **Do not change SQL, ordering, cursor, materialization, or work bounds.**

The ledger table `chat_to_message` contains exactly:

```text
ss_id
source_id
source_rowid
source_chat_rowid
source_message_rowid
chat_ss_id
message_ss_id
```

`ss_id = SourceScopedRowKey.pack(sourceId, raw join ROWID)`; endpoints are independently packed using the same source ID. Distinct join ROWIDs with identical endpoints remain distinct ledger rows. There is no import batch for this relationship family. The importer owns `insertIgnore`, one write transaction, full/incremental selection, source closure, progress and omissions.

Crucially, the `LEFT JOIN` endpoint-existence evidence and decision to omit an incomplete relationship **remain importer-owned**. Do not move that decision into the projection.

## 4. Freeze actual-writer behavior BEFORE editing production

Add only the characterization test, using a synthetic `ReadOnlySourceDatabase` and the **actual disposable source-scoped `ImportDatabase` and production importer**, not a test-only approximation of its row mapping.

Freeze and assert:

1. Exact seven-column persisted row maps and ordering.
2. Live and non-live source IDs, packed relationship identity, packed endpoints, and raw lineage.
3. Integer and rounded-double identities and existing malformed identity errors.
4. Two source joins with the same endpoint pair but different join ROWIDs, both retained.
5. Duplicate `insertIgnore` and repeat-import idempotence, including examined versus inserted counts.
6. Missing Chat and missing Message source endpoints, each omitted alone with the exact typed omission count.
7. Complete initial/per-row progress sequence, last completed raw join ROWID, and result counters.
8. Empty source selection.
9. Incremental boundary selection using the existing Message ROWID cursor.
10. Transaction rollback after an earlier admitted row when a later operation fails.
11. Query, source-open, row, write, and progress-observer failure behavior as supported by existing ports.
12. Source closure after every successful open, on both success and failure.

Use the real disposable ledger for persisted-row evidence. Introduce doubles only where needed for controlled lifecycle or injected failure paths that cannot safely be produced using the actual ledger. No real user data or message text. Run this suite against **unchanged production code**, record passing results and a fixture/baseline fingerprint, then and only then edit production.

If a faithful deterministic characterization cannot be made without changing the source query or semantics, STOP, leave no exploratory production diff, and report.

## 5. Extract the canonical pure row projection

Create the narrow typed synchronous module described by Response 98, conceptually:

```text
ChatMessageRelationshipSourceProjectionInput
  raw sourceRelationshipRowId
  raw sourceChatRowId
  raw sourceMessageRowId
  factory fromSourceRow(...)

projectSourceChatMessageRelationship(input, sourceId)
  -> ProjectedSourceChatMessageRelationship
       sourceRelationshipRowId
       immutable complete ledgerValues
```

Preserve the existing `int`/rounded-`double` coercion and required-field error semantics. Use `SourceScopedRowKey.pack` directly; do not duplicate its algorithm. Output exactly the seven ledger fields, with the same values and null/error behavior as the original importer.

The projection has **no** database, SQL, DAO, Riverpod, Flutter, graph, source reader, endpoint lookup, filesystem, archive, clock, batch, progress, callback, `Future`, `Stream`, I/O, global mutable state, or mutation capability. No alternative injectable projection strategy.

The importer may construct the typed raw input where necessary to preserve the original join ROWID as progress context, but must still perform the existing `existing_chat_rowid` / `existing_message_rowid` endpoint-existence checks and omissions itself. Call the pure projection **only for admitted relationships**, exactly once per admitted row. Remove the old duplicate local row-formation path.

Do not infer an endpoint from graph topology, a missing scalar ledger record, or archived payloads. No source-scoped relationship should be converted into a graph edge by this module.

## 6. Prove exact before/after parity

Rerun the **identical frozen characterization** after extraction, without changing expected persisted rows, progress observations, anomaly counts, errors, ordering, or lifecycle assertions.

Require exact equality for all deterministic material facts and all observable execution behavior. If parity differs, correct the extraction or STOP; do not rewrite the baseline to match the refactor.

Add direct projection tests for:

- all seven persisted columns and immutable output;
- live/non-live source identities and packed endpoint lineage;
- lower/upper valid packed-key bounds and invalid bounds;
- integer/rounded-double coercion and required-field failures;
- identical endpoints with distinct relationship ROWIDs;
- irrelevant raw context having no effect and material facts affecting only their canonical outputs.

Add AST/dependency architecture enforcement proving one concrete importer call site, one canonical row-formation owner, synchronous pure dependencies, and continued importer ownership of SQL, endpoint proof, omission, transaction, `insertIgnore`, progress, results, and source closure. Explicitly exclude graph, archive, AppCzar, and mutation authority.

## 7. Regression and Project Conformance

Run in dependency order:

1. Pre-edit actual-writer characterization (recorded before production edits).
2. Unchanged characterization, direct projection, and AST tests after extraction.
3. Source-scoped relationship, identity, schema, and import-ledger regressions.
4. Conversation Graph chat/topology and incremental projection regressions.
5. Relevant historical-source, attachment/archive, AppCzar/Onboarding, Operating/currentness regressions.
6. Complete architecture/forbidden-import suite.
7. `flutter analyze`.
8. Complete deterministic `flutter test` suite, recording its unique passing count and existing skips.
9. Dart formatting, generated-source consistency where applicable, `git diff --check`, and staged diff hygiene.
10. Canonical Project Conformance audit: BLOCKER 0, SHOULD FIX 0.

No build or app launch. No test against real source or real archive data.

## 8. Stop gates

**STOP AND REPORT** if:

- baseline Git, submodule, ancestry, or tracked state materially differs;
- actual writer cannot be characterized before source edits;
- source/query/ledger behavior contradicts Response 98's audited inventory;
- the projection needs to decide source endpoint existence or query the database;
- SQL, incremental selection, ordering, materialization, transactions, progress, omissions, error handling, or source closure would change;
- raw relationship ROWID or either source endpoint identity would be lost or normalized differently;
- source identity packing is duplicated rather than reused;
- any persisted or observable pre/post behavior differs;
- an unapproved production/test/schema/graph/FTS/archive/AppCzar/Start Fresh change becomes necessary;
- a second relationship interpretation or mutation authority is introduced;
- full tests, analyzer, or Project Conformance cannot pass.

On a stop, restore any exploratory tracked source/test changes to the pre-edit baseline **without touching unrelated user changes**, write an uncommitted Response 99 with exact evidence, and do not commit a partial extraction.

## 9. Git checkpoints

Only if parity and all validation gates pass:

1. Stage exactly the five authorized implementation/test files.
2. Commit a narrow implementation, suggested subject `refactor(import): extract canonical Chat-Message relationship source projection`.
3. Push normally; no rebase, force push, squash, or unrelated staging.
4. Create `99-CHECKPOINT-RELATIONSHIP-AUDIT-AND-EXTRACT-CANONICAL-CHAT-MESSAGE-RELATIONSHIP-SOURCE-PROJECTION.md` in Feature 34 `01-ONBOARDING/responses/`.
5. Checkpoint Prompt 99 and Response 99 as a separate documentation-only commit and push normally.
6. Report exact implementation/documentation hashes and final synchronized Git state. The Response file cannot contain its own resulting documentation commit hash; include that in the final handoff.

No release metadata or build artifact is required.

## 10. Required Response 99

Report:

1. Git baseline, ancestry, Prompt/Response 98 checkpoint, submodule and untracked preservation.
2. Actual importer call graph, full/incremental SQL and endpoint-existence authority.
3. Complete seven-column ledger schema and source identity semantics.
4. Pre-edit actual-writer characterization fixture, frozen expected results, and passing baseline.
5. Pure typed projection input/output and canonical utility reuse.
6. Importer consumer call edge and removal of duplicate row mapping.
7. Exact post-edit writer parity, including duplicate raw joins, missing endpoints, incremental behavior, errors, rollback, progress, and source closure.
8. Direct projection and AST architecture test results.
9. Source-scoped/graph/attachment/AppCzar regression results.
10. Analyzer, complete Flutter suite, formatting, generated consistency, diff checks.
11. Project Conformance verdict, BLOCKER and SHOULD FIX counts.
12. Exact implementation diff and checkpoint hash; documentation checkpoint hash in final handoff.
13. Final branch, upstream, index, tracked tree, submodule and untracked state.
14. Readiness for the next separately characterized relationship family.
15. Explicit continued blocks on full reconstruction witness, destructive Stage 2C/Start Fresh, and production activation.

Conclude exactly:

```text
RELATIONSHIP AUDIT CHECKPOINTED: YES / NO
ACTUAL CHAT-MESSAGE JOIN IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO
CANONICAL CHAT-MESSAGE RELATIONSHIP PROJECTION IS PURE AND SHARED: YES / NO
SOURCE ENDPOINT-EXISTENCE AND OMISSION AUTHORITY REMAINS IMPORTER-OWNED: YES / NO
RAW RELATIONSHIP IDENTITY AND SEVEN-COLUMN LEDGER PARITY: PASS / FAIL / NOT REACHED
DUPLICATE, INCREMENTAL, PROGRESS, ERROR, AND LIFECYCLE PARITY: PASS / FAIL / NOT REACHED
GRAPH RELATIONSHIP AUTHORITY UNCHANGED: YES / NO
FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR NEXT NARROW RELATIONSHIP EXTRACTION: YES / NO
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```

Then **STOP**. Do not begin Chat–Handle, Message–Attachment, graph, FTS, rich-text, reconstruction witness, Start Fresh, or production-cutover work in this task.
