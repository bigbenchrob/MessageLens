# Response 100 — Chat–Handle Relationship Source-Projection Extraction

## Scope and result

Prompt 100 completed the second narrow source-scoped relationship extraction.
The production `ChatHandleJoinImporter` was characterized against the actual
disposable `ImportDatabase` before production edits. Its deterministic,
admitted endpoint-to-ledger mapping now has one typed, synchronous, pure owner,
and the unchanged production importer consumes that projection exactly once.

The importer still owns source SQL, raw join ROWID validation, endpoint
existence proof, incomplete-row omission, batch creation, source opening and
closing, transaction scope, `insertIgnore`, counters, progress, rollback, and
errors. No graph, FTS, schema, migration, archive, AppCzar, Start Fresh,
provider, generated, dependency, packaging, release, or build file changed.
No application was built or launched, and no real Messages, Contacts,
MessageLens database, archive, installed application, or external-drive data
was accessed.

## 1. Git baseline, ancestry, and Prompt 99 checkpoint

The verified source-edit baseline was:

```text
Repository: /Users/rob/Development/FlutterProjects/remember_every_text
Branch: fix/onboarding-import-stuck-state
HEAD: d526762e5f3dc3363c163025723f70c1953e3218
Upstream: origin/fix/onboarding-import-stuck-state
Divergence: 0 ahead / 0 behind
Tracked worktree: clean
Index: clean
Shared-instructions submodule:
  95326f515ef4719f155ce6e223990398daad6311
  clean, heads/main
Feature 34 worktrees on this branch: exactly one
```

The required scalar and first relationship extraction commits were all
ancestors (each ancestry query returned zero):

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts
d77d08c6c55e18ade47983fb959b8023c893283c  Messages
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c  Handles
10732e2986c5e40f7d097f35e2d12daff663fc4f  Chats
417a7ef1b24b12991649edc978bd3d0326a6720a  Attachments
59f86153                                     Chat–Message relationship
```

Prompt 99 and Response 99 were already checkpointed and pushed at the exact
baseline HEAD:

```text
d526762e5f3dc3363c163025723f70c1953e3218
docs(appczar): record Chat-Message relationship source projection extraction
```

No duplicate documentation checkpoint was created. A source-only baseline
manifest was written outside the repository at
`/private/tmp/messagelens_prompt100_source_baseline.sha256`. It contained 1,476
`lib/` entries and had SHA-256
`f58b0ef248f9500506b25798cf63cb858ba48f3b8dd2f719a6055a13837ddb72`.
The post-edit manifest contained 1,477 entries and differed only at the
authorized importer and the new pure projection.

There were 49 untracked files at preflight: Prompt 100 and 48 unrelated files.
All unrelated files were left untouched.

## 2. Actual writer traced before production edits

The verified production call graph was:

```text
importJoins()
  -> insertImportBatch(sourceId, current UTC timestamp)
  -> openReadOnly(chatDbPath)
  -> one fully materialized ordered source query
  -> initial progress observation
  -> one ledger write transaction
  -> per row:
       validate raw source join ROWID
       coerce raw Chat and Handle endpoint IDs
       prove both joined endpoints exist
       omit incomplete relationship, or form and insertIgnore admitted row
       publish progress using the raw join ROWID
  -> typed result counters
  -> source close in finally
```

The source query remains exactly:

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

The scan remains full and materialized. SQL text, ordering, and source-port
behavior are unchanged.

## 3. Six-column ledger, constraints, and relationship identity

Every admitted source relationship still writes exactly these columns, in
this order:

```text
source_id
source_chat_rowid
source_handle_rowid
chat_ss_id
handle_ss_id
batch_id
```

All six columns are `INTEGER NOT NULL`. The table retains:

```text
UNIQUE(source_id, source_chat_rowid, source_handle_rowid)
FOREIGN KEY (source_id) REFERENCES source_registry(source_id)
FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
INDEX chat_ss_id
INDEX handle_ss_id
```

The raw `chat_handle_join.ROWID` is validated and retained only for progress
and error context; it is not persisted. Canonical relationship identity is the
source-plus-endpoint tuple. Therefore duplicate raw join rows having identical
Chat and Handle endpoints collapse under `insertIgnore`, while the same Chat
paired with a different Handle remains a distinct relationship.

Endpoint packing remains:

```text
chat_ss_id   = SourceScopedRowKey.pack(sourceId, source_chat_rowid)
handle_ss_id = SourceScopedRowKey.pack(sourceId, source_handle_rowid)
```

No second packed-key implementation or identity interpretation was added.

## 4. Batch-before-source-open and endpoint admission

The importer still allocates a timestamped batch before attempting to open the
source database. Empty input creates a batch. A created batch survives source
open, query, progress, transaction, or row failures exactly as before, while
ledger writes within a failed transaction roll back.

The source `LEFT JOIN` results remain stateful evidence owned exclusively by
the importer. A relationship is admitted only after both raw endpoint IDs
coerce successfully and both `existing_chat_rowid` and
`existing_handle_rowid` prove endpoint existence. Missing or malformed
endpoints increment the established typed omission count and retain the raw
join ROWID as progress context. The pure projection neither receives nor
interprets endpoint-existence evidence.

## 5. Pre-edit actual-writer characterization

The actual unchanged production importer was exercised with a synthetic
`ReadOnlySourceDatabase` and the actual disposable `ImportDatabase`. The
characterization freezes:

- the exact query and full ordered materialization;
- exact six-column maps and insertion order;
- live and non-live source identities and packed endpoints;
- integer and rounded-double coercion;
- malformed raw join ROWID failure;
- independent missing Chat and missing Handle omission;
- duplicate endpoint tuple collapse and same-Chat/different-Handle identity;
- repeat-import `insertIgnore` behavior;
- empty input and batch timestamp semantic bounds;
- initial and terminal progress, typed anomaly count, and result counters;
- batch creation failure, source-open failure, query failure, write failure,
  and progress-observer failure;
- transaction rollback after an earlier admitted row; and
- source closure on every post-open success and failure path.

The pre-edit importer SHA-256 was
`7d9bbb2187b6f54b4757230577721149a69a3e15d80bc247040a785908a38029`.
The successful pre-edit characterization file SHA-256 was
`1d1c2994ce63faf172554a9f86164e57338eefb6bbb129e695591500b861b977`.

The first pre-edit test attempt had one test-fixture assertion error:
`Bad state: Too many elements`. The fixture incorrectly used
`storedRows.single` while deliberately expecting three stored relationships.
The other nine characterization tests passed. No production source had been
edited. Only that assertion was corrected to inspect `storedRows.first`; the
unchanged production importer then passed all 10 characterization tests.

## 6. Pure typed canonical projection

The new `chat_handle_relationship_source_projection.dart` contains:

- immutable `ChatHandleRelationshipSourceProjectionInput`, holding only the
  two raw endpoint identities and offering `fromSourceRow`;
- immutable `ProjectedSourceChatHandleRelationship`, holding the two coerced
  endpoint identities and an unmodifiable complete six-column ledger map; and
- synchronous `projectSourceChatHandleRelationship(input, sourceId, batchId)`.

The function preserves the former integer/rounded-double coercion and exact
`StateError('chat_handle_join.<field> is required')` failures. It reuses
`SourceScopedRowKey.pack` and preserves source and batch lineage.

Its sole import is the shared source-scoped row-key utility. It has no SQL,
source port, ledger, database, graph, provider, filesystem, clock, archive,
AppCzar, transaction, progress, callback, `Future`, `Stream`, I/O, global
state, or mutation authority.

## 7. Production consumer edge and exact parity

The importer validates the raw join ROWID at its original execution point,
constructs the typed raw endpoint input, and performs its existing endpoint
admission. Only an admitted row reaches exactly one concrete call to
`projectSourceChatHandleRelationship`. The importer passes the returned
immutable six-column map to its unchanged `insertIgnore` call.

The former inline packed-key and row-map construction was removed. The frozen
characterization was not changed for production behavior and passed after the
extraction. Persisted values, order, source identity, duplicate collapse,
omissions, counters, progress, errors, rollback, batch survival, source-open
ordering, and source lifecycle are unchanged.

The characterization fixture's only post-extraction edit was adding
`@immutable` and the `meta` import to its equality value object in response to
two analyzer info findings. It did not change a behavioral expectation. The
final characterization file SHA-256 is
`367a0db39ff6a47396cb68d3dc13935e1e33bf32a6fa421fb2ca7b862412dd6a`.

## 8. Direct and architecture enforcement

Direct projection tests cover:

- exact immutable six-column output;
- source and batch lineage for live and non-live sources;
- valid lower and upper packed-key bounds and invalid source/endpoint bounds;
- integer and rounded-double coercion and exact required-field errors;
- duplicate endpoint material equality; and
- irrelevant context changes versus material Chat, Handle, and batch changes.

The AST/dependency suite proves:

- the pure module has one permitted dependency and no async/I/O/authority;
- the production importer has exactly one projection call;
- the former local packing and row-map path is absent;
- raw join identity and endpoint evidence are excluded from the projection;
- endpoint admission occurs before projection; and
- SQL, batch-before-open, transaction, `insertIgnore`, progress, and source
  closure remain importer-owned.

The final focused group passed 20 tests: 10 frozen characterization tests,
7 direct projection tests, and 3 architecture tests.

## 9. Dependency-ordered regression validation

All final results below are attributable to the five-file implementation
state committed at `32b18a6a`:

```text
Focused characterization/projection/AST:                     20 passed
Source-scoped relationship and ledger suite:                 193 passed
Conversation Graph canonical handle/chat/alias suite:        143 passed
Historical/archive/attachment/AppCzar/Onboarding/Operating: 1,477 passed
Complete architecture/forbidden-import suite:                635 passed
Complete deterministic serial Flutter suite:               3,286 passed
Existing complete-suite skips:                                 1
```

The existing skip is the archive-import memory worker test, whose instruction
is to use the separate memory harness.

Intermediate validation evidence was reported literally:

1. An early source-scoped suite invocation was interrupted/truncated and
   yielded no attributable complete result. It was rerun completely and
   passed 193 tests.
2. The first cross-domain file selection accidentally included
   `test/test_support/test_archive_fixture.dart`, a helper without `main`, and
   therefore produced one harness-selection failure after 1,477 passing tests.
   The corrected selection excluded `test/test_support/`; it passed 1,477
   tests with the one existing skip.
3. The first analyzer run reported two info findings because the
   characterization-only `_ObservedQuery` value object overrode equality and
   hash code without an immutability annotation. The narrow test-only
   annotation/import correction was formatted, the focused 20 tests were
   rerun successfully, and the analyzer then passed with no issues.
4. The serial complete suite was still running when tool output was
   interrupted. Its original process and growing external log were recovered,
   left undisturbed, and later returned `FULL_SERIAL_STATUS:0` with 3,286
   passed, one existing skip, and `All tests passed!`; it was not guessed or
   unnecessarily duplicated.

No Prompt 99 concurrency-sensitive attachment-provider failure recurred in
the deterministic serial run. This does not claim that the previously
reported infrastructure issue was fixed.

## 10. Analyzer and mechanical validation

```text
flutter analyze: No issues found (5.1 seconds)
dart format, exact five files: 0 changed
Generated-source diff: none
Dependency/pubspec diff: none
Source-only manifest differences: exact two authorized production files
git diff --check: passed
git diff --cached --check: passed
Implementation staged scope: exactly five authorized files
Implementation diff: 1,339 insertions, 23 deletions
```

No code generation was applicable. No provider annotation, generated output,
dependency, version, changelog, release metadata, or build artifact changed.

## 11. Project Conformance

The canonical Project Conformance standard and all applicable project
instructions were applied to the complete five-file diff.

- **Behavior preservation:** the actual writer was frozen before production
  editing; the unchanged characterization and full deterministic suite pass.
- **Reuse and single source of truth:** shared packed-key authority is reused;
  one pure six-column row-formation owner replaces the inline duplicate.
- **Layering:** the projection points only to source-scoped identity; all I/O,
  admission, transaction, and lifecycle authority remains in the importer.
- **Database/overlay/archive invariants:** no schema, provider, overlay, graph,
  archive, or real-data change occurred.
- **Record fidelity:** the existing explicit endpoint omission policy is
  unchanged; every admitted relationship retains exact material identity.
- **Errors and transactions:** failures propagate, rows roll back, batches
  survive at the established boundary, and source closure is frozen.
- **Performance:** no additional query, scan, materialization, or async
  boundary was added; one synchronous projection replaces inline mapping.
- **Privacy/security:** tests contain synthetic identifiers only; no real
  source, database, archive, installed app, or external drive was accessed.
- **Generated/dependency/release hygiene:** no generated, package, build,
  packaging, release, or metadata change occurred.

```text
BLOCKER: 0
SHOULD FIX: 0
OPTIONAL: 0
PROJECT CONFORMANCE: PASS
```

## 12. Implementation and documentation checkpoints

Exactly the five authorized implementation/test files were committed and
pushed normally as:

```text
32b18a6add2e0280f089f21db0af48a4aaebcc12
refactor(import): extract canonical Chat-Handle relationship source projection
5 files changed, 1,339 insertions(+), 23 deletions(-)
```

Prompt 100 and this response are the separate documentation-only checkpoint.
Its resulting commit hash is intentionally reported in the final handoff
rather than self-referenced inside this response, as Prompt 100 requires.

## 13. Final boundaries and next work

The populated reconstruction-equivalence witness still does not exist.
Destructive Operating Start Fresh/Stage 2C remains blocked. All seven AppCzar
jurisdictions and production activation status are unchanged. No
Message–Attachment extraction, graph projection, FTS, reconstruction witness,
destructive reset, or production cutover began.

The next permitted work is only the next separately authorized narrow
relationship extraction. It requires its own prompt, pre-edit actual-writer
characterization, parity gates, conformance audit, and checkpoint.

```text
CHAT-MESSAGE EXTRACTION CHECKPOINTED: YES
ACTUAL CHAT-HANDLE JOIN IMPORTER CHARACTERIZED BEFORE EDITS: YES
CANONICAL CHAT-HANDLE RELATIONSHIP PROJECTION IS PURE AND SHARED: YES
SOURCE ENDPOINT-EXISTENCE AND OMISSION AUTHORITY REMAINS IMPORTER-OWNED: YES
BATCH-BEFORE-SOURCE-OPEN SEMANTICS UNCHANGED: YES
CHAT-HANDLE LEDGER ROWS, DUPLICATES, PROGRESS, ERROR, AND LIFECYCLE PARITY: PASS
GRAPH CANONICAL-HANDLE AND ALIAS SEMANTICS UNCHANGED: YES
FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES
PROJECT CONFORMANCE: PASS
READY FOR NEXT NARROW RELATIONSHIP EXTRACTION: YES
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```
