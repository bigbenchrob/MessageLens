# Response 101 — Message–Attachment Relationship Source-Projection Extraction

## Scope and result

Prompt 101 completed the third narrow source-scoped relationship extraction.
The production `MessageAttachmentJoinImporter` was characterized against the
actual disposable `ImportDatabase` before production edits. Its deterministic,
admitted endpoint-to-ledger mapping now has one typed, synchronous, pure owner,
and the unchanged production importer consumes that projection exactly once.

The importer still owns source SQL, raw join ROWID validation, endpoint
existence proof, incomplete-row omission, batch creation, source opening and
closing, transaction scope, `insertIgnore`, counters, progress, rollback, and
errors. No attachment payload, archive, graph, FTS, schema, migration,
AppCzar, Start Fresh, provider, generated, dependency, packaging, release, or
build file changed. No application was built or launched, and no real
Messages, Contacts, MessageLens database, archive, installed application, or
external-drive data was accessed.

## 1. Git baseline, ancestry, and Prompt 100 checkpoint

The verified source-edit baseline was:

```text
Repository: /Users/rob/Development/FlutterProjects/remember_every_text
Branch: fix/onboarding-import-stuck-state
HEAD: b629f853d6c96496c0f70779f7e33a7c469fd6ac
Upstream: origin/fix/onboarding-import-stuck-state
Divergence: 0 ahead / 0 behind
Tracked worktree: clean
Index: clean
Shared-instructions submodule:
  95326f515ef4719f155ce6e223990398daad6311
  clean, heads/main
Feature 34 worktrees on this branch: exactly one
```

The required relationship extraction ancestry was present:

```text
59f86153                                     Chat–Message relationship
32b18a6add2e0280f089f21db0af48a4aaebcc12  Chat–Handle relationship
```

Prompt 100 and Response 100 were already checkpointed and pushed at the exact
baseline HEAD:

```text
b629f853d6c96496c0f70779f7e33a7c469fd6ac
docs(appczar): record Chat-Handle relationship source projection extraction
```

No duplicate documentation checkpoint was created. A source-only baseline
manifest was written outside the repository at
`/private/tmp/messagelens_prompt101_source_baseline.sha256`. It contained
1,477 `lib/` entries and had SHA-256
`076f74c22d2f5e42c3bce4f135ea1d8ff2337844b6b9632924aac4bb482a8c3e`.

The post-edit manifest at
`/private/tmp/messagelens_prompt101_source_current.sha256` contained 1,478
entries and had SHA-256
`7f7f28015969ae746ea2c3e16110aee19bfc26ed7c29c3d0500acf17c859d7e1`.
It differed only at the authorized importer and the new pure projection:

```text
message_attachment_join_importer.dart
  before: fbe239ef5f300c03a5c2e5dd2dd07898771fe9db954314d1ab5bef87ee19d10a
  after:  9b842f40171196d61d3b31a459f0d858b2d9dca8304186ba6ae08532810a4528

message_attachment_relationship_source_projection.dart
  new:    39b22a488c8ab08c4dcf1114f155925944953e8cf87a450f7dbd792c302a3ead
```

There were 49 untracked files when enumerated with
`--untracked-files=all`: Prompt 101 and 48 unrelated files. All unrelated
files were left untouched.

## 2. Actual writer traced before production edits

The verified production call graph was:

```text
importJoins()
  -> openReadOnly(chatDbPath)
  -> one fully materialized ordered source query
  -> if no selected rows: return without creating a batch
  -> insertImportBatch(sourceId, current UTC timestamp)
  -> initial progress observation
  -> one ledger write transaction
  -> per row:
       validate raw source join ROWID
       coerce raw Message and Attachment endpoint IDs
       prove both joined endpoints exist
       omit incomplete relationship, or form and insertIgnore admitted row
       publish progress using the raw join ROWID
  -> typed result counters
  -> source close in finally
```

The full source query remains exactly:

```sql
SELECT maj.ROWID AS source_rowid,
       maj.message_id,
       maj.attachment_id,
       m.ROWID AS existing_message_rowid,
       a.ROWID AS existing_attachment_rowid
FROM message_attachment_join maj
LEFT JOIN message m ON m.ROWID = maj.message_id
LEFT JOIN attachment a ON a.ROWID = maj.attachment_id
ORDER BY message_id ASC, attachment_id ASC
```

The incremental form retains the same select, joins, and ordering and adds:

```sql
WHERE maj.message_id > ?
ORDER BY message_id ASC, attachment_id ASC
```

The cursor is the source Message endpoint identity, not the raw join ROWID.
The query remains fully materialized; no paging or new query was introduced.
The exact production SQL string, including its existing whitespace, arguments,
ordering, and source-port behavior is unchanged.

## 3. Seven-column ledger, constraints, and relationship identity

Every admitted source relationship still writes exactly these columns, in
this order:

```text
message_source_id
attachment_source_id
source_message_rowid
source_attachment_rowid
message_ss_id
attachment_ss_id
batch_id
```

Canonical duplicate identity remains the four-endpoint tuple:

```text
(message_source_id,
 attachment_source_id,
 source_message_rowid,
 source_attachment_rowid)
```

The raw `message_attachment_join.ROWID` is validated and retained only for
progress and error context; it is not persisted. Duplicate raw join rows with
the same endpoint tuple collapse under `insertIgnore`. A changed Message or
Attachment endpoint remains a distinct relationship.

Both endpoints continue to use the same source identity supplied by the
importer:

```text
message_source_id    = sourceId
attachment_source_id = sourceId

message_ss_id = SourceScopedRowKey.pack(
  sourceId: sourceId,
  sourceRowId: source_message_rowid,
)

attachment_ss_id = SourceScopedRowKey.pack(
  sourceId: sourceId,
  sourceRowId: source_attachment_rowid,
)
```

No second packed-key implementation or relationship identity interpretation
was added.

## 4. Query-before-batch and endpoint admission

The importer still opens and queries the source before allocating a batch. An
empty selection returns zero counters without a batch, transaction, ledger
write, or progress event. A nonempty selection creates its batch only after
the source query succeeds. Once created, that batch survives later progress,
transaction, row, or observer failure at the established boundary, while
ledger writes within a failed transaction roll back.

The source `LEFT JOIN` results remain stateful evidence owned exclusively by
the importer. A relationship is admitted only after both raw endpoint IDs
coerce successfully and both `existing_message_rowid` and
`existing_attachment_rowid` prove endpoint existence. Missing or malformed
endpoints increment the established typed omission count and retain the raw
join ROWID as progress context. The pure projection neither receives nor
interprets endpoint-existence evidence.

## 5. Pre-edit actual-writer characterization

The actual unchanged production importer was exercised with a synthetic
`ReadOnlySourceDatabase` and the actual disposable `ImportDatabase`. The
characterization freezes:

- exact full and incremental queries, arguments, ordering, and cursor;
- exact seven-column maps and insertion order;
- same-source Message and Attachment lineage and packed endpoints;
- integer and rounded-double coercion;
- malformed raw join ROWID failure;
- independent missing Message and missing Attachment omission;
- duplicate endpoint tuple collapse and distinct endpoint identity;
- repeat-import `insertIgnore` behavior;
- empty-selection no-batch behavior and nonempty query-before-batch timing;
- initial and terminal progress, typed anomaly count, and result counters;
- batch creation, source-open, query, write, and progress-observer failures;
- transaction rollback after an earlier admitted row;
- post-query batch survival after later failure; and
- source closure on every post-open success and failure path.

The pre-edit production importer SHA-256 was
`fbe239ef5f300c03a5c2e5dd2dd07898771fe9db954314d1ab5bef87ee19d10a`.
The frozen characterization file SHA-256 was
`29afece883d181cd3028ceb573d322a558f38fdfb1c9619ac8e2b5320578e18b`.

The first pre-edit test invocation passed 10 tests and had one fixture-only
expectation failure. The fixture expected one space before `ORDER BY`, while
the actual unchanged production SQL string has its existing two spaces at
that interpolation boundary. No production file had been edited. Only the
fixture's expected string was corrected, after which all 11 characterization
tests passed against unchanged production code.

## 6. Pure typed canonical projection

The new `message_attachment_relationship_source_projection.dart` contains:

- immutable `MessageAttachmentRelationshipSourceProjectionInput`, holding
  only the two raw endpoint identities and offering `fromSourceRow`;
- immutable `ProjectedSourceMessageAttachmentRelationship`, holding the two
  coerced endpoint identities and an unmodifiable complete seven-column ledger
  map; and
- synchronous `projectSourceMessageAttachmentRelationship(input, sourceId,
  batchId)`.

The function preserves the former integer/rounded-double coercion and exact
`StateError('message_attachment_join.<field> is required')` failures. It
reuses `SourceScopedRowKey.pack` and preserves source and batch lineage.

Its sole import is the shared source-scoped row-key utility. It has no SQL,
source port, ledger, database, graph, provider, filesystem, clock, attachment
payload, archive, AppCzar, transaction, progress, callback, `Future`, `Stream`,
I/O, global state, or mutation authority.

## 7. Production consumer edge and exact parity

The importer validates the raw join ROWID at its original execution point,
constructs the typed raw endpoint input, and performs its existing endpoint
admission. Only an admitted row reaches exactly one concrete call to
`projectSourceMessageAttachmentRelationship`. The importer passes the
returned immutable seven-column map to its unchanged `insertIgnore` call.

The former inline packed-key and row-map construction was removed. The frozen
characterization file was not changed after the extraction and all 11 tests
passed. Persisted values, order, source identity, duplicate collapse,
omissions, counters, progress, errors, rollback, batch survival, source-query
ordering, and source lifecycle are unchanged.

Final file SHA-256 values were:

```text
9b842f40171196d61d3b31a459f0d858b2d9dca8304186ba6ae08532810a4528
  message_attachment_join_importer.dart
39b22a488c8ab08c4dcf1114f155925944953e8cf87a450f7dbd792c302a3ead
  message_attachment_relationship_source_projection.dart
29afece883d181cd3028ceb573d322a558f38fdfb1c9619ac8e2b5320578e18b
  message_attachment_join_importer_characterization_test.dart
a13d6b204d171e3dbb9108a5fa47cccef1931a536d3bccc323cca79993640280
  message_attachment_relationship_source_projection_test.dart
730bf5ffc8eeecb61174168a6f0a3a2df507306131d9ca136b55acff54ef4bd7
  message_attachment_relationship_source_projection_authority_test.dart
```

## 8. Direct and architecture enforcement

Direct projection tests cover:

- exact immutable seven-column output;
- same-source Message and Attachment lineage;
- valid packed-key bounds and invalid source/endpoint bounds;
- integer and rounded-double coercion and exact required-field errors;
- duplicate endpoint material equality; and
- irrelevant context changes versus material Message, Attachment, source, and
  batch changes.

The AST/dependency suite proves:

- the pure module has one permitted dependency and no async/I/O/authority;
- the production importer has exactly one projection call;
- the former local packing and row-map path is absent;
- raw join identity and endpoint evidence are excluded from the projection;
- endpoint admission occurs before projection; and
- SQL, query-before-batch, transaction, `insertIgnore`, progress, and source
  closure remain importer-owned.

The final focused group passed 25 tests: 11 frozen characterization tests,
7 direct projection tests, 3 new architecture tests, and 4 existing importer
tests.

## 9. Dependency-ordered regression validation

All final results below are attributable to the five-file implementation
state committed at `b788c07e0bfead2e67f47027ff43fdf50423f494`:

```text
Focused characterization/direct/AST/existing importer: 25 passed
Complete source-scoped import suite:                   211 passed
Graph and attachment regression group:                434 passed
Cross-domain archive/AppCzar/onboarding group:         659 passed
Complete architecture suite:                          638 passed
Complete deterministic serial repository suite:       3,307 passed
                                                       1 existing skip
flutter analyze:                                      No issues found
```

The existing skip is the archive-import memory worker test, whose instruction
is to use the separate memory harness.

Intermediate validation evidence was reported literally. The first graph and
attachment test process was interrupted from tool control and later returned
`Unknown process ID`; no complete attributable result existed. It was not
treated as a pass or failure. The exact group was rerun and returned
`GRAPH_ATTACHMENT_STATUS:0`, 434 passed, and `All tests passed!` in
`/private/tmp/messagelens_prompt101_graph_attachment.log`.

The other attributable logs were:

```text
/private/tmp/messagelens_prompt101_cross_domain.log
  CROSS_DOMAIN_STATUS:0; 659 passed

/private/tmp/messagelens_prompt101_architecture.log
  ARCHITECTURE_STATUS:0; 638 passed

/private/tmp/messagelens_prompt101_analyze.log
  ANALYZE_STATUS:0; No issues found; 6.0 seconds

/private/tmp/messagelens_prompt101_full.log
  FULL_STATUS:0; 3,307 passed; 1 existing skip; All tests passed!; 5m53s
```

## 10. Analyzer and mechanical validation

```text
dart format, exact five files: 0 changed
Generated-source diff: none
Dependency/pubspec diff: none
Source-only manifest differences: exact two authorized production files
git diff --check: passed
git diff --cached --check: passed
Implementation staged scope: exactly five authorized files
Implementation diff: 1,429 insertions, 24 deletions
```

No code generation was applicable. No provider annotation, generated output,
dependency, version, changelog, release metadata, or build artifact changed.

## 11. Project Conformance

The complete five-file diff was audited against:

- the global agent guardrails and Dart rules;
- the project README and architecture overview;
- the database access, overlay independence, record-fidelity, and canonical
  timestamp rules;
- the source-scoped import and bounded table-importer rules;
- the canonical Project Conformance Audit Standard;
- Prompt 101 and Responses 91–100, especially Response 98's relationship
  audit and Response 100's pre-edit parity method.

The audit found:

- **Reuse and single source of truth:** shared packed-key authority is reused;
  one pure seven-column row-formation owner replaces the inline map.
- **Layering and dependency direction:** the projection points only to
  source-scoped identity; all I/O, admission, transaction, and lifecycle
  authority remains in the importer.
- **Database, overlay, graph, and archive invariants:** no schema, provider,
  overlay, graph, archive payload, or real-data change occurred.
- **Record fidelity:** the existing explicit endpoint omission policy is
  unchanged; every admitted relationship retains exact material identity.
- **Errors and transactions:** failures propagate, ledger rows roll back,
  batches survive only at the established post-query boundary, and source
  closure is frozen.
- **Performance:** no additional query, scan, paging, materialization, or async
  boundary was added; one synchronous projection replaces inline mapping.
- **Privacy and security:** tests contain synthetic identifiers only; no real
  source, database, archive, installed app, or external drive was accessed.
- **Generated, dependency, and release hygiene:** no generated, package,
  build, packaging, release, or metadata change occurred.
- **Tests:** actual-writer behavior, pure mapping, ownership, forbidden
  authority, and broad regressions are all protected.

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
b788c07e0bfead2e67f47027ff43fdf50423f494
refactor(import): extract canonical Message-Attachment relationship source projection
5 files changed, 1,429 insertions(+), 24 deletions(-)
```

Prompt 101 and this response are the separate documentation-only checkpoint.
Its resulting commit hash is intentionally reported in the final handoff
rather than self-referenced inside this response, as Prompt 101 requires.

## 13. Final boundaries and next work

The populated reconstruction-equivalence witness still does not exist.
Destructive Operating Start Fresh/Stage 2C remains blocked. All seven AppCzar
jurisdictions and production activation status are unchanged. No rich-text
enrichment, graph projection, FTS, reconstruction witness, destructive reset,
or production cutover began.

The next permitted work is only a separate audit of the remaining populated
reconstruction-equivalence gaps. It requires its own prompt and authority.

```text
CHAT-HANDLE EXTRACTION CHECKPOINTED: YES
ACTUAL MESSAGE-ATTACHMENT JOIN IMPORTER CHARACTERIZED BEFORE EDITS: YES
CANONICAL MESSAGE-ATTACHMENT RELATIONSHIP PROJECTION IS PURE AND SHARED: YES
SOURCE ENDPOINT-EXISTENCE AND OMISSION AUTHORITY REMAINS IMPORTER-OWNED: YES
EMPTY SELECTION AND BATCH-AFTER-QUERY SEMANTICS UNCHANGED: YES
MESSAGE-ATTACHMENT LEDGER ROWS, DUPLICATES, PROGRESS, ERROR, AND LIFECYCLE PARITY: PASS
ATTACHMENT PAYLOAD/ARCHIVE AND GRAPH AUTHORITY UNCHANGED: YES
FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES
PROJECT CONFORMANCE: PASS
READY FOR SEPARATE RECONSTRUCTION-GAP AUDIT: YES
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```
