# Response 99 — Chat–Message Relationship Source-Projection Extraction

## Scope and result

Prompt 99 completed the first narrow source-scoped relationship extraction.
The production `ChatMessageJoinImporter` was characterized against an actual
disposable `ImportDatabase` before production edits. The deterministic
admitted source relationship-to-ledger row formation now has one typed,
synchronous, pure owner, and the unchanged production importer consumes it.

The importer still owns the source query, full versus incremental selection,
endpoint-existence proof, incomplete-row omission, transaction,
`insertIgnore`, progress, result counts, errors, and source lifetime. No graph,
archive, AppCzar, Start Fresh, schema, migration, provider, packaging, build,
or release file changed. No application was built or launched, and no real
Messages, Contacts, MessageLens database, archive, installed application, or
external-drive data was accessed.

## 1. Git baseline, ancestry, and documentation preparation

The verified source-edit baseline was:

```text
Repository: /Users/rob/Development/FlutterProjects/remember_every_text
Branch: fix/onboarding-import-stuck-state
HEAD: 857b3607a27d1b1a0e0edaf0badfcb3d06d61100
Upstream: origin/fix/onboarding-import-stuck-state
Divergence: 0 ahead / 0 behind
Tracked worktree: clean
Index: clean
Shared-instructions submodule:
  95326f515ef4719f155ce6e223990398daad6311
  clean, heads/main
Feature 34 worktrees on this branch: exactly one
```

The required prior projection commits were all ancestors:

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts
d77d08c6c55e18ade47983fb959b8023c893283c  Messages
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c  Handles
10732e2986c5e40f7d097f35e2d12daff663fc4f  Chats
417a7ef1b24b12991649edc978bd3d0326a6720a  Attachments
30bc9ea79846ee7ecc2730710998bc5801b42499  Prompt/Response 97
```

Prompt 98 and Response 98 were still untracked. They were checkpointed alone
and pushed before source edits:

```text
857b3607a27d1b1a0e0edaf0badfcb3d06d61100
docs(appczar): audit canonical relationship source projections
```

A source-only baseline manifest was written outside the repository at
`/private/tmp/messagelens_prompt99_source_baseline_857b3607.sha256`. It
contained 1,922 tracked `lib/` and `test/` entries and had SHA-256
`8cb36350b8ca2c4b8482d70890b8120787548ccbb76a6653bb59e9a113e68ff1`.
The post-edit tracked manifest differed only at the authorized existing
importer; the other four authorized implementation/test files were new.

All 48 unrelated untracked files were preserved. Prompt 99 remained untracked
until the separate documentation checkpoint.

## 2. Actual production importer traced before editing

Both public paths converge on `_importJoinsWhere`:

```text
importJoins()
  -> whereClause null, no arguments

importJoinsAfterSourceMessageRowId(startedAfterSourceRowId)
  -> WHERE cmj.message_id > ?
  -> [startedAfterSourceRowId]

_importJoinsWhere(...)
  -> openReadOnly(chatDbPath)
  -> one fully materialized ordered source query
  -> initial progress
  -> one ledger write transaction
  -> per-row source identity coercion
  -> importer-owned source endpoint proof
  -> omit incomplete row or insertIgnore admitted row
  -> per-row progress and typed omission count
  -> result counters
  -> source close in finally
```

The unchanged full query is:

```sql
SELECT cmj.ROWID AS source_rowid, cmj.chat_id, cmj.message_id,
       c.ROWID AS existing_chat_rowid,
       m.ROWID AS existing_message_rowid
FROM chat_message_join cmj
LEFT JOIN chat c ON c.ROWID = cmj.chat_id
LEFT JOIN message m ON m.ROWID = cmj.message_id
ORDER BY cmj.ROWID ASC
```

Incremental import adds `WHERE cmj.message_id > ?` before the same ordering.
SQL text, ordering, cursor, arguments, full materialization, and work bounds
are unchanged.

`existing_chat_rowid` and `existing_message_rowid` remain evidence interpreted
only by the importer. Invalid/missing endpoint IDs or missing joined endpoint
rows increment `omittedChatMessageRelationshipCount`, publish the established
progress, and omit only that relationship. The pure projection does not see
or decide endpoint existence.

## 3. Seven-column ledger and source identity

Every admitted row still writes exactly, in this order:

```text
ss_id
source_id
source_rowid
source_chat_rowid
source_message_rowid
chat_ss_id
message_ss_id
```

Identity semantics are unchanged:

```text
ss_id         = SourceScopedRowKey.pack(sourceId, raw join ROWID)
chat_ss_id    = SourceScopedRowKey.pack(sourceId, raw chat_id)
message_ss_id = SourceScopedRowKey.pack(sourceId, raw message_id)
```

The raw join ROWID remains both `source_rowid` and the relationship's packed
identity input. Consequently, two source rows with identical Chat and Message
endpoints but different join ROWIDs remain distinct ledger rows. Live and
non-live source IDs preserve their own packed lineage.

## 4. Pre-edit actual-writer characterization

Before editing production, the new characterization suite exercised the
unchanged production importer with a synthetic `ReadOnlySourceDatabase` and
the actual disposable source-scoped `ImportDatabase`. It froze:

- exact seven-column maps and ordering;
- non-live source ID 42, raw join identity, and endpoint packing;
- integer and rounded-double coercion;
- duplicate endpoints with distinct raw relationship ROWIDs;
- independent missing-Chat, missing-Message, and malformed-endpoint omissions;
- initial and terminal progress, final raw ROWID, typed anomaly count, and
  examined/inserted/omitted results;
- repeat-import `insertIgnore` idempotence;
- empty selection and source-message incremental SQL/arguments;
- rollback after malformed later identity and injected later write failure;
- source-open, query, progress-observer, row, and write failures;
- source close after every successful open on success and failure.

The unchanged importer passed all 9 characterization tests. The pre-edit
importer SHA-256 was
`523922cae5c5b1970444301849f7b264656d5339b872c6b7fb1cfb2a451cc79e`;
the frozen pre-edit characterization fixture SHA-256 was
`961bba879ea6befd4b3ce6d1c1016e37a406b5e3c7d91146060d975d736b2a43`.

## 5. Pure typed canonical projection

The new `chat_message_relationship_source_projection.dart` contains:

- immutable `ChatMessageRelationshipSourceProjectionInput`, including
  `fromSourceRow` and the three raw source identities;
- immutable `ProjectedSourceChatMessageRelationship`, including the coerced
  raw identities and an unmodifiable complete ledger map;
- synchronous `projectSourceChatMessageRelationship(input, sourceId)`.

It preserves the former `int`/rounded-`double` conversion and exact
`StateError('chat_message_join.<field> is required')` failure semantics. It
imports and calls the existing `SourceScopedRowKey.pack` utility rather than
duplicating packed-key logic.

Its sole import is `source_scoped_row_key.dart`. It has no SQL, database,
ledger, graph, Riverpod, Flutter, filesystem, archive, AppCzar, clock, batch,
progress, callback, `Future`, `Stream`, I/O, global state, or mutation
capability.

## 6. Production consumer edge and single row-formation owner

For each source row, the importer constructs the typed raw input, reads the
raw join ROWID for progress, and performs its existing source endpoint checks.
Only an admitted relationship reaches exactly one call to
`projectSourceChatMessageRelationship`. The importer passes the returned
immutable seven-column map to its unchanged `insertIgnore` call.

The importer's former local packed-key and ledger-map construction was
removed. No alternative strategy, callback, or second relationship
interpretation authority was introduced.

## 7. Exact post-edit writer parity

The identical frozen characterization passed after extraction without changing
expected rows, SQL, progress, anomaly counts, result counters, errors,
ordering, rollback, or lifecycle assertions. The post-edit focused group
contained 19 passing tests: 9 unchanged writer-characterization tests, 7
direct projection tests, and 3 AST architecture tests.

Verified parity includes duplicate raw joins, missing endpoints, repeat
imports, incremental selection, empty input, coercion, malformed identities,
query/open/write/progress failures, transaction rollback, and source closure.

## 8. Direct and architecture enforcement

Direct projection tests prove:

- exact seven-column immutable output;
- live and non-live source identity and endpoint lineage;
- valid lower/upper packed-key bounds and invalid bounds for relationship,
  Chat, Message, and source identity;
- integer/rounded-double coercion and exact required-field errors;
- identical endpoints with distinct relationship ROWIDs;
- irrelevant source-row context has no effect, while each material fact
  changes only its canonical outputs.

AST enforcement proves the projection is synchronous and dependency-bounded,
the production importer has exactly one projection call site after
importer-owned admission, the old local packing path is absent, and SQL,
endpoint proof, omission, transaction, `insertIgnore`, progress, and source
lifetime remain importer-owned. Graph, archive, AppCzar, and mutation
authorities are excluded.

## 9. Regression validation

All results below are attributable to the final five-file implementation
state:

```text
Focused characterization/projection/AST:                    19 passed
Source-scoped import suite:                                176 passed
Conversation Graph suite:                                 143 passed
Historical/archive/attachment/AppCzar/Onboarding/Operating: 1,275 passed
Complete architecture suite:                              632 passed
```

The first complete concurrent `flutter test` run reached 3,265 passes, one
existing skip, and one failure in
`attachment_archive_service_provider_test.dart` while attachment tests were
running concurrently. The exact failing test immediately passed alone (1/1).
The complete deterministic serial rerun then passed with **3,266 tests and one
existing skip**. The skip is the archive-import memory worker test, whose
existing instruction is to run through its separate tool harness. This
evidence classifies the concurrent failure as order/concurrency-sensitive; it
does not conceal it or treat the initial run as passing.

## 10. Analyzer and mechanical validation

```text
flutter analyze: No issues found
dart format, exact five files: 0 changed
Generated-source diff: none
Dependency/pubspec diff: none
git diff --cached --check: passed
Implementation staged scope: exactly five authorized files
Implementation diff: 1,272 insertions, 35 deletions
```

No generated source was applicable to the new pure module or tests. No
build-runner annotation or provider was added.

## 11. Project Conformance

The canonical Project Conformance standard and applicable agent instructions
were applied to the complete implementation diff.

- **Behavior preservation:** actual writer frozen before edit; exact post-edit
  characterization and deterministic full suite pass.
- **Reuse and single source of truth:** existing `SourceScopedRowKey` reused;
  one canonical seven-column row-formation owner; old duplicate mapping
  removed.
- **Layering and dependencies:** pure application transformation points only
  toward the source-scoped identity domain; database and lifecycle authority
  stay in the importer.
- **Database/overlay/archive invariants:** no schema, provider, overlay, graph,
  archive, or real-data change.
- **Record fidelity:** admitted source relationships are preserved exactly;
  importer-owned omission policy is unchanged and typed.
- **Error and transaction semantics:** direct failures propagate and the
  established transaction rollback/lifetime behavior is frozen.
- **Performance:** no extra query, scan, materialization, or asynchronous
  boundary; one synchronous projection call replaces inline mapping.
- **Privacy/security:** tests use synthetic identifiers only; no message text,
  user source, database, archive, or installed application was accessed.
- **Generated/dependency/release hygiene:** no generated, package, release,
  build, packaging, or metadata change.
- **Tests and architecture enforcement:** focused, dependency-ordered,
  architecture, analyzer, and deterministic complete-suite gates pass.

```text
BLOCKER: 0
SHOULD FIX: 0
OPTIONAL: 0
PROJECT CONFORMANCE: PASS
```

## 12. Implementation checkpoint

Exactly the five authorized implementation/test files were committed as:

```text
59f86153
refactor(import): extract canonical Chat-Message relationship source projection
5 files changed, 1,272 insertions(+), 35 deletions(-)
```

The checkpoint was pushed normally to
`origin/fix/onboarding-import-stuck-state`. No rebase, squash, force push, or
unrelated staging occurred. Prompt 99 and this response are intentionally a
separate documentation-only checkpoint; its resulting hash is reported in the
final handoff rather than self-referenced here.

## 13. Final repository state after the prescribed checkpoints

After the implementation push and before the documentation-only checkpoint:

```text
Branch: fix/onboarding-import-stuck-state
Implementation HEAD: 59f86153
Upstream divergence: 0 ahead / 0 behind
Tracked worktree: clean
Index: clean
Shared-instructions submodule: clean at 95326f515ef4719f155ce6e223990398daad6311
Unrelated untracked files: 48, untouched
```

After the documentation checkpoint, Prompt 99 and Response 99 are tracked;
the same 48 unrelated untracked files remain untouched. The exact final HEAD
and synchronization are reported in the final handoff after that checkpoint
exists.

## 14. Next narrow relationship readiness

The Chat–Message relationship extraction is complete and verified. The next
relationship family may be addressed only by another separately authorized,
pre-edit-characterized extraction. This task does not begin Chat–Handle or
Message–Attachment work.

## 15. Restrictions that remain in force

No populated reconstruction-equivalence witness was implemented. Destructive
Operating Start Fresh and Stage 2C remain blocked. The seven AppCzar
jurisdictions are unchanged, and production AppCzar activation remains off.
No graph edge authority, FTS, rich-text enrichment, or production-cutover work
was changed or begun.

```text
RELATIONSHIP AUDIT CHECKPOINTED: YES
ACTUAL CHAT-MESSAGE JOIN IMPORTER CHARACTERIZED BEFORE EDITS: YES
CANONICAL CHAT-MESSAGE RELATIONSHIP PROJECTION IS PURE AND SHARED: YES
SOURCE ENDPOINT-EXISTENCE AND OMISSION AUTHORITY REMAINS IMPORTER-OWNED: YES
RAW RELATIONSHIP IDENTITY AND SEVEN-COLUMN LEDGER PARITY: PASS
DUPLICATE, INCREMENTAL, PROGRESS, ERROR, AND LIFECYCLE PARITY: PASS
GRAPH RELATIONSHIP AUTHORITY UNCHANGED: YES
FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES
PROJECT CONFORMANCE: PASS
READY FOR NEXT NARROW RELATIONSHIP EXTRACTION: YES
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```
