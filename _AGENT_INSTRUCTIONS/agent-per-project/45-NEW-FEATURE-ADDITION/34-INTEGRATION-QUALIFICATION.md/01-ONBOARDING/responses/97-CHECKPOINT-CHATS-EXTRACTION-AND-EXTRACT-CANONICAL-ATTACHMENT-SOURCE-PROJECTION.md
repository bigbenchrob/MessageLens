# Response 97 — Canonical Attachment Source Projection

## Scope and baseline

This response records the fifth narrow shared-transformation extraction
authorized by Prompt 97. It verifies the already-checkpointed Chats extraction
and extracts only the deterministic attachment source-row-to-ledger
transformation from the existing production `AttachmentImporter`. It does not
read, copy, preserve, delete, relocate, or otherwise mutate attachment payloads
or archives. It does not implement a reconstruction witness, enable destructive
Start Fresh, or activate production AppCzar.

The verified pre-edit baseline was:

- branch `fix/onboarding-import-stuck-state`;
- HEAD `242b517c96ae45201c9a67e0e1e012203ad36735`;
- upstream `origin/fix/onboarding-import-stuck-state`, synchronized `0/0`;
- clean tracked worktree and index;
- shared-instructions submodule at
  `95326f515ef4719f155ce6e223990398daad6311`, clean; and
- 49 pre-existing untracked artifacts, including Prompt 97, preserved before
  implementation.

The required extraction ancestry was present:

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts projection
d77d08c6c55e18ade47983fb959b8023c893283c  Messages projection
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c  Handles projection
10732e2986c5e40f7d097f35e2d12daff663fc4f  Chats projection
242b517c96ae45201c9a67e0e1e012203ad36735  Prompt/Response 96 documentation
```

Prompt 96 and Response 96 were therefore already checkpointed and pushed; no
duplicate checkpoint was created.

The fresh source-only baseline manifest was written outside the repository at
`/private/tmp/messagelens_prompt97_attachment_source_projection_baseline.md`.
No real Messages or Contacts source, MessageLens database, attachment archive,
installed application data, or external drive was accessed.

## Pre-edit production writer characterization

The unchanged production `AttachmentImporter` was characterized before any
production edit. The characterization uses a synthetic
`ReadOnlySourceDatabase` and the actual disposable source-scoped
`ImportDatabase`, so it exercises the real writer rather than a test-only
reproduction.

The importer first obtains the ledger cursor from
`maxAttachmentSourceRowIdForSource(sourceId)`, defaulting to zero, and then
executes exactly:

```sql
SELECT ROWID AS source_rowid, *
FROM attachment
WHERE ROWID > ?
ORDER BY ROWID ASC
```

The query is one complete ordered incremental slice; it does not page. The
actual call sequence remained:

```text
read the current ledger cursor
  -> open source read-only
  -> execute the ordered incremental Attachment query
  -> if nonempty, allocate one import batch
  -> publish initial bounded progress
  -> one import-ledger write transaction
       -> form one complete ledger row per source row
       -> insertIgnore('attachments', ledger row)
       -> publish bounded completed-row progress
  -> close the source in finally
```

Empty input publishes `0/0`, allocates no batch, and returns a null last source
row. The complete persisted `attachments` column inventory is:

```text
ss_id
source_id
source_rowid
guid
filename
transfer_name
uti
mime_type
total_bytes
created_at_utc
batch_id
```

The pre-edit field and writer semantics were frozen as follows:

- `ss_id` is `SourceScopedRowKey.pack(sourceId, sourceRowId)`;
- `source_id` and `batch_id` are importer-owned operational lineage inputs;
- `source_rowid` accepts `int` or rounded `double`, otherwise fails with the
  established direct `StateError`;
- `guid`, `filename`, `transfer_name`, `uti`, and `mime_type` accept nonempty
  strings without trimming, preserving whitespace and Unicode; empty or
  non-string values become `null`;
- `total_bytes` accepts `int`, rounded `double`, or `null`;
- `created_at_utc` uses `created_date` when present, otherwise `created_at`, and
  delegates Apple timestamp conversion exclusively to `DateConverter`;
- metadata is degraded only when all five textual metadata fields are null;
  and
- every source row is still represented; anomalous metadata is reported, not
  filtered.

`insertIgnore` continues to enforce the ledger's unique
`source_id`/`source_rowid` identity. Examined, inserted, degraded-metadata, and
last-source-row results remain importer-owned. Progress is published at the
same initial, stride, and final boundaries. Row-shape failures propagate
directly, the transaction rolls back, and the already-created batch remains.
Systemic query failures propagate before batch creation. The source closes in
`finally` on every completed or failed path.

The importer performs no payload read, copy, filesystem operation, archive
mutation, or preservation decision. It imports source metadata only.

The production importer SHA-256 before extraction was:

```text
720340ffb8e16018074e898a3ec3f502cfd3cff4080b0f4dadf6be4ee8946d72
```

The pre-edit characterization file SHA-256 was:

```text
14ea34e4082cda7ba3bb2e5d52d3e3d86918a559399a6cc90e17c5cd84a895c0
```

The pre-edit characterization passed nine tests. It froze complete persisted
row maps and order, packed identities and lineage, incremental cursor behavior,
integer/double source identities and sizes, null/blank/whitespace/Unicode
metadata, Apple timestamp precedence and fallback, insert-ignore behavior,
empty input, progress, degraded-metadata counts, transaction rollback, batch
behavior, direct errors, and source closure.

## Canonical pure projection

`attachment_source_projection.dart` now supplies the one concrete
deterministic row-formation path:

```text
AttachmentSourceProjectionInput
  + importer-owned sourceId and batchId
  -> projectSourceAttachment(...)
  -> immutable ProjectedSourceAttachment ledger values
```

`AttachmentSourceProjectionInput` captures only the source fields consumed by
the existing transformation. `ProjectedSourceAttachment` exposes the
normalized source row identity, the degraded-metadata fact, and an
unmodifiable complete eleven-column ledger map. The synchronous function
reuses `SourceScopedRowKey` and `DateConverter` and retains the exact source
coercion, fallback, omission, and anomaly behavior.

The pure module has no SQL, DAO, SQLite, Riverpod, Flutter, filesystem,
payload, archive, clock, I/O, `Future`, `Stream`, global mutable state,
transaction, batch allocation, persistence, progress, mutation capability,
graph, AppCzar, or alternative injected strategy.

`AttachmentImporter` still owns the source cursor and SQL, source lifecycle,
batch allocation, transaction, insert-ignore persistence, counts, progress,
error propagation, and result construction at the same execution points. It
invokes `projectSourceAttachment` exactly once on its sole production row
formation path. The former importer-local map formation and scalar conversion
helpers were removed only after pre-edit characterization passed.

Attachment payload and archive authorities, preservation workflows, joins,
rich text, graph projection, FTS, reconstruction, AppCzar, and Start Fresh were
not modified.

## Exact parity and validation

The unchanged nine-test production-writer characterization was first rerun
against the refactored importer and passed with equality of every persisted
value, row order, identity, batch reference, timestamp, fallback, omission,
anomaly count, insert count, cursor, progress event, transaction result, error,
and source lifecycle observation.

After that exact parity run, the analyzer required one explicit type guard in
the characterization harness. That correction changed no assertion, fixture,
expected output, production behavior, or semantic coverage. The complete
focused selection was rerun on the final lint-clean source and passed all 20
tests.

Direct pure-function tests cover all eleven persisted columns, immutable
output, source and batch lineage, null/blank/whitespace/Unicode metadata,
integer/double/null sizes, Apple timestamp precedence and fallback, source-row
validation, material versus irrelevant source-field changes, construction
from source rows, and the absence of payload, archive, and graph behavior.

AST architecture tests prove the pure dependency surface, synchronous
execution, absence of mutating authorities, exactly one production importer
call, and continued importer ownership of SQL, cursor, batches, transactions,
writes, progress, and source lifecycle.

Completed validation on the final implementation state:

- focused importer characterization, direct projection, and AST architecture
  selection: `20` passing tests;
- source-scoped import and conversation-graph regression selection: `303`
  passing tests;
- attachment, settings, archive, and AppCzar Attachment Archive Repair
  regression selection: `706` passing tests;
- AppCzar and Onboarding regression selection: `569` passing tests;
- complete architecture suite: `629` passing tests;
- `flutter analyze`: `No issues found!`;
- complete deterministic `flutter test`: `3,247` passing tests and one
  existing skipped qualification harness (`~1`), terminal result
  `All tests passed!`;
- Dart formatting: five implementation/test Dart files checked, `0` changed;
- generated consistency: no `.g.dart` or `.freezed.dart` difference and no
  generator-triggering annotation introduced;
- `git diff --check` and `git diff --cached --check`: clean; and
- no build, installed-app launch, or live-data qualification was performed.

The full-suite count is the single unique complete-suite result. It is not a
sum of overlapping focused and regression selections.

## Architecture and Project Conformance audit

The canonical Project Conformance review found:

- **BLOCKER: 0** — no second source of truth, dependency inversion,
  stateful-policy move, mutation expansion, unbounded-work change, archive
  authority change, or parity failure;
- **SHOULD FIX: 0** — the pure module is the narrow justified owner of the
  already-existing deterministic transformation and reuses the established
  row-key and timestamp authorities; and
- **OPTIONAL: 0** — no adjacent cleanup is required for this extraction.

The implementation checkpoint contains exactly these five files:

```text
lib/essentials/source_scoped_import/application/attachments/attachment_importer.dart
lib/essentials/source_scoped_import/application/attachments/attachment_source_projection.dart
test/architecture/attachment_source_projection_authority_test.dart
test/essentials/source_scoped_import/application/attachments/attachment_importer_test.dart
test/essentials/source_scoped_import/application/attachments/attachment_source_projection_test.dart
```

It was committed and pushed as:

```text
417a7ef1b24b12991649edc978bd3d0326a6720a
refactor(import): extract canonical Attachments source projection
```

The final implementation-file SHA-256 values were:

```text
0352f5d29607964a5c93d26657f66ef839cf75d9c87c150374c498763cd38582  attachment_importer.dart
0555c0b60c53203e85f5fb2559414b808c3662a922663c9acc245cb9fdaadeca  attachment_source_projection.dart
129a289ade731dfdd91dd5a640d49238cdad2e65e9a6e6e853c7177439e6b35b  attachment_importer_test.dart
fdfb19f8147d79a06f2086d7d575b26d6faf7e1a9bce4799e9c50471595bd889  attachment_source_projection_test.dart
ae64f8409cf73d1c92d959f587f5079cfc1fd8dc424f877fc7465fe4b09fc306  attachment_source_projection_authority_test.dart
```

Immediately before this documentation checkpoint, HEAD and upstream both
resolved to the implementation commit, divergence was `0/0`, the tracked
worktree and index were clean, the shared-instructions submodule was unchanged
and clean, and the known untracked artifacts were untouched. This response and
Prompt 97 form the separate documentation-only checkpoint. Its resulting
commit hash is reported in the final handoff because this file cannot contain
its own commit hash.

## Boundaries that remain blocked

This extraction is not a populated reconstruction-equivalence witness. It does
not authorize destructive Operating Start Fresh, Stage 2C, production AppCzar
activation, or cutover. Joins, rich text, graph projection, FTS, and any next
shared-transformation extraction remain separate work requiring their own
characterization and authorization.

`CHATS EXTRACTION CHECKPOINTED: YES`

`ACTUAL ATTACHMENTS IMPORTER CHARACTERIZED BEFORE EDITS: YES`

`CANONICAL ATTACHMENTS SOURCE PROJECTION IS PURE AND SHARED: YES`

`ATTACHMENT METADATA, OMISSIONS, PROGRESS, AND ERROR PARITY: PASS`

`ATTACHMENT PAYLOAD/ARCHIVE AUTHORITY UNCHANGED: YES`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES`

`PROJECT CONFORMANCE: PASS`

`READY FOR NEXT NARROW EXTRACTION: YES`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
