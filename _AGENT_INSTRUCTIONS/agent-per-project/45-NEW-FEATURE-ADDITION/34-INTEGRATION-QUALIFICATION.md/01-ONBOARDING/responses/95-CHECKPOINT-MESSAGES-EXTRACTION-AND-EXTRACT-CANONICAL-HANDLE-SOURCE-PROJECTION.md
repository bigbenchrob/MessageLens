# Response 95 — Canonical Handle Source Projection

## Scope and baseline

This response records the third narrow shared-transformation extraction
authorized by Prompt 95. It checkpoints the already-qualified Messages
extraction and extracts only the deterministic Handle source-row-to-ledger
transformation. It does not implement graph canonical-handle grouping, alias
rebuilding, Contacts linkage, a reconstruction witness, destructive Start
Fresh, or production AppCzar activation.

The verified pre-edit baseline was:

- branch `fix/onboarding-import-stuck-state`;
- HEAD `7c4af5b3f3eef96449fd3347af50afb049e82509`;
- upstream `origin/fix/onboarding-import-stuck-state`, synchronized `0/0`;
- clean tracked worktree and index;
- shared-instructions submodule at
  `95326f515ef4719f155ce6e223990398daad6311`, clean;
- all registered Feature 34 worktrees present in their expected locations; and
- the pre-existing 49 untracked artifacts, including Prompt 95, preserved
  untouched before implementation.

The required ancestry was present:

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts projection implementation
d77d08c6c55e18ade47983fb959b8023c893283c  Messages projection implementation
7c4af5b3f3eef96449fd3347af50afb049e82509  Prompt/Response 94 documentation
```

The fresh source-only baseline manifest was written outside the repository at
`/private/tmp/messagelens_prompt95_handle_source_projection_baseline.md`.
No real Messages, Contacts, MessageLens database, attachment archive, installed
application data, or external drive was accessed.

## Pre-edit production writer characterization

The unchanged production `HandleImporter` was characterized before any
production edit. The test uses a synthetic `ReadOnlySourceDatabase` and the
actual disposable source-scoped `ImportDatabase`; it does not reproduce the
writer in a test-only approximation.

The importer call sequence remained:

```text
ordered source handle query
  -> read supported local-account evidence
  -> resolve each source row's current is_me input
  -> import-ledger write transaction
  -> insertIgnore('handles', persisted row map)
  -> unchanged progress/account reconciliation
```

The current importer performs one full ordered handle query rather than
keyset/page iteration. The characterization therefore could not exercise more
than one source page without changing production behavior. It instead freezes
the complete seven-row ordered query, incremental rerun, transaction, progress,
duplicate, refusal, and reconciliation behavior. The synthetic source port
explicitly rejects unrelated message-page access, proving that no hidden paging
path was substituted.

The exact `handles` schema column inventory is:

```text
ss_id, source_id, source_rowid, id, service, is_me, batch_id
```

The existing field semantics remain:

- `ss_id`: deterministically derived by packing `source_id` and
  `source_rowid` through `SourceScopedRowKey`;
- `source_id`: operational source-registry identity supplied by the importer;
- `source_rowid`: copied/coerced from the raw source row using the existing
  numeric behavior;
- `id`: required raw source identifier, including whitespace, Unicode, and
  malformed-but-nonempty values;
- `service`: raw source value when nonempty, otherwise `null`; whitespace-only
  values remain material and are not trimmed;
- `is_me`: `0` or `1` from evidence resolved by the importer before pure row
  formation; and
- `batch_id`: operational import-batch identity allocated by the importer.

The pre-edit characterization passed four tests. It freezes complete persisted
row maps in stable order, packed identities, lineage, Unicode/whitespace and
malformed identifiers, null/empty/whitespace services, typed normalization
failure, systemic error propagation, duplicate insert-ignore behavior,
incremental reruns, batch identity, progress/anomaly observations, transaction
rollback, source close/error behavior, and account evidence with zero, one,
multiple, and repeated candidates.

The proof also covers stateful `is_me` behavior: message-derived fallback,
sticky prior-ledger identity, and repeated reconciliation. Those decisions were
not classified as pure source-row projection.

## Canonical pure projection

`handle_source_projection.dart` now supplies the one concrete deterministic
row-formation path:

```text
HandleSourceProjectionInput
  + importer-resolved sourceId, batchId, and isMe
  -> projectSourceHandle(...)
  -> immutable ProjectedSourceHandle ledger values
```

The module is synchronous and has no SQL, DAO, SQLite, Riverpod, Flutter,
filesystem, clock, I/O, `Future`, `Stream`, global state, progress, mutation
capability, or UI dependency. It reuses `SourceScopedRowKey` and the established
pure handle-identifier interpretation utility. Only the existing typed
`HandleIdentifierNormalizationException` is converted to the existing
preserved-raw fallback; other errors continue to propagate.

`HandleImporter` still owns the source SQL and ordering, source registration,
batch allocation, transactions, insert-ignore write, progress, error handling,
account/message evidence reads, prior-ledger lookup, `is_me` resolution, and
post-insert local-account reconciliation at the same execution points. It calls
`projectSourceHandle` once for every source-row insertion path. The former
duplicated row-map and identifier-interpretation logic was removed.

The graph handle projector and its canonical-handle/alias semantics were not
modified. No second reader, policy evaluator, injectable projection strategy,
or mutation authority was introduced.

## Parity and validation evidence

The identical frozen actual-writer characterization was rerun after extraction
without changing its expected rows, omissions, reconciliation, anomalies,
ordering, progress, or errors. It again passed all four tests.

Direct projection tests cover every persisted field; packed identity and
source/batch lineage; raw null, blank, whitespace, Unicode, malformed, and
empty identifier/service cases under the actual contracts; typed-only
normalization fallback; invalid source identity; numeric source-row coercion;
explicit `isMe`; material versus irrelevant input changes; and immutable
output.

Mechanical architecture tests prove that the projection has only approved pure
dependencies, that the production importer has exactly one concrete projection
call, and that SQL, transactions, writes, progress, account reconciliation, and
graph semantics remain outside the pure boundary. The existing handle identity
boundary assertion was updated only to recognize `SourceScopedRowKey.pack` at
its new canonical source-projection owner rather than its removed importer-local
location.

Completed validation on the final implementation state:

- focused Handle importer/projection/architecture selection: `14` passing
  tests;
- corrected attachment/historical-source supplement: `157` passing tests;
- full architecture/forbidden-import suite: `623` passing tests;
- `flutter analyze`: `No issues found!`;
- complete deterministic `flutter test`: `3,217` passing tests and one existing
  skipped test (`~1`);
- Dart formatting: six changed Dart files checked, `0` changed;
- generated consistency: no `.g.dart` or `.freezed.dart` differences and no
  generator-triggering annotation was introduced; and
- `git diff --check` and `git diff --cached --check`: clean.

One broad intermediate regression invocation named a nonexistent historical
test path and therefore exited nonzero after `1,173` otherwise passing tests.
That is a command-inventory error, not a passing validation claim. The real
historical targets were then run successfully, and the complete deterministic
suite subsequently passed on the final code state.

## Architecture and Project Conformance audit

The canonical Project Conformance review found:

- **BLOCKER: 0** — no duplicate source of truth, invalid dependency direction,
  stateful reconciliation move, mutation expansion, unsafe unbounded work, or
  behavioral parity failure;
- **SHOULD FIX: 0** — the new pure module is the narrow justified owner of the
  already-existing deterministic row formation and reuses established identity
  utilities; and
- **OPTIONAL: 0** — no adjacent cleanup is required for this extraction.

The implementation checkpoint contains exactly these six files:

```text
lib/essentials/source_scoped_import/application/handles/handle_importer.dart
lib/essentials/source_scoped_import/application/handles/handle_source_projection.dart
test/architecture/handle_identity_normalization_boundary_test.dart
test/architecture/handle_source_projection_authority_test.dart
test/essentials/source_scoped_import/application/handles/handle_importer_test.dart
test/essentials/source_scoped_import/application/handles/handle_source_projection_test.dart
```

It was committed and pushed as:

```text
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c
refactor(import): extract canonical Handles source projection
```

This response and Prompt 95 form the separate documentation-only checkpoint.
Its resulting commit hash and the final pushed recovery anchor are necessarily
reported in the final handoff because this file cannot contain its own commit
hash.

## Boundaries that remain blocked

This narrow extraction is not a populated reconstruction-equivalence witness.
It does not authorize destructive Operating Start Fresh, Stage 2C, production
AppCzar activation, or cutover. Chats, Attachments, joins, rich-text, graph,
FTS, and any future shared-transformation extraction remain separate work that
must begin from their own characterization and authorization.

`MESSAGES EXTRACTION CHECKPOINTED: YES`

`ACTUAL HANDLES IMPORTER CHARACTERIZED BEFORE EDITS: YES`

`CANONICAL HANDLES SOURCE PROJECTION IS PURE AND SHARED: YES`

`PRODUCTION HANDLES IMPORTER HAS ONE CANONICAL SOURCE-ROW TRANSFORMATION PATH: YES`

`HANDLE ROWS, RECONCILIATION, OMISSIONS, AND PROGRESS PARITY: PASS`

`STATEFUL LOCAL-ACCOUNT RECONCILIATION REMAINS IMPORTER-OWNED: YES`

`GRAPH CANONICAL-HANDLE AND ALIAS SEMANTICS UNCHANGED: YES`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES`

`PROJECT CONFORMANCE: PASS`

`READY FOR NEXT NARROW SHARED-TRANSFORMATION EXTRACTION: YES`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
