# Response 96 — Canonical Chat Source Projection

## Scope and baseline

This response records the fourth narrow shared-transformation extraction
authorized by Prompt 96. It verifies the already-checkpointed Handles
extraction and extracts only the deterministic Chat source-row-to-ledger
transformation from the existing production `ChatImporter`. It does not change
graph chat/group semantics, implement a reconstruction witness, enable
destructive Start Fresh, or activate production AppCzar.

The verified pre-edit baseline was:

- branch `fix/onboarding-import-stuck-state`;
- HEAD `e6bf408f2ae9bf32b2ccde37ac9ca13461f1e339`;
- upstream `origin/fix/onboarding-import-stuck-state`, synchronized `0/0`;
- clean tracked worktree and index;
- shared-instructions submodule at
  `95326f515ef4719f155ce6e223990398daad6311`, clean;
- all registered worktrees present in their expected locations; and
- 49 pre-existing untracked artifacts, including Prompt 96, preserved before
  implementation.

The required implementation ancestry was present:

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts projection
d77d08c6c55e18ade47983fb959b8023c893283c  Messages projection
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c  Handles projection
e6bf408f2ae9bf32b2ccde37ac9ca13461f1e339  Prompt/Response 95 documentation
```

Prompt 95 and Response 95 were therefore already checkpointed and pushed; no
duplicate checkpoint was created.

The fresh source-only baseline manifest was written outside the repository at
`/private/tmp/messagelens_prompt96_chat_source_projection_baseline.md`. No real
Messages or Contacts source, MessageLens database, attachment archive,
installed application data, or external drive was accessed.

## Pre-edit production writer characterization

The unchanged production `ChatImporter` was characterized before any
production edit. The test uses a synthetic `ReadOnlySourceDatabase` and the
actual disposable source-scoped `ImportDatabase`, so the proof exercises the
production writer rather than a test-only reproduction.

The exact source SQL is:

```sql
SELECT ROWID AS source_rowid, * FROM chat ORDER BY ROWID ASC
```

The importer performs one complete ordered query and does not page. Its actual
call sequence remained:

```text
open source read-only
  -> execute the ordered Chat query
  -> allocate one import batch
  -> publish initial bounded progress
  -> one import-ledger write transaction
       -> form one complete ledger row per source row
       -> insertIgnore('chats', ledger row)
       -> publish bounded completed-row progress
  -> close the source in finally
```

The complete persisted `chats` column inventory is:

```text
ss_id
source_id
source_rowid
guid
service
group_id
original_group_id
last_read_message_at_utc
batch_id
```

The pre-edit field and writer semantics were frozen as follows:

- `ss_id` is `SourceScopedRowKey.pack(sourceId, sourceRowId)`;
- `source_id` and `batch_id` are importer-owned operational lineage inputs;
- `source_rowid` accepts `int` or rounded `double` values and otherwise fails;
- `guid` must be a nonempty `String`; whitespace-only and Unicode values are
  preserved without trimming;
- `service` uses the first nonempty `String` from `service_name`, then
  `service`, and otherwise stores `null`; whitespace remains material;
- `group_id` and `original_group_id` preserve nonempty strings byte-for-byte,
  while empty or non-string values become `null`;
- `last_read_message_at_utc` is produced solely through
  `DateConverter.appleToIsoString(last_read_message_timestamp)`; and
- graph-only fields such as `is_group` and `display_name` are neither inferred
  nor persisted by this importer.

`insertIgnore` continues to apply the ledger's unique source identity.
Repeated source identities are examined but not inserted, while duplicate
GUIDs on distinct source rows remain separate persisted records. A rerun
allocates a new batch, examines every source row, inserts zero existing rows,
and preserves the original persisted batch references.

The importer publishes initial progress before the transaction and bounded
completed-row progress through the established progress authority. Insert
conflicts still count as completed work. Empty input produces one batch and a
single `0/0` progress observation. A row-level `StateError` is wrapped as a
`SourceImportRecordException` with the Chats work unit and the known source row
identity; the transaction rolls back while the previously created batch
remains. A malformed source identity retains null error context. Systemic
source-query failures propagate before batch creation. The source handle closes
after every success or failure.

The production importer SHA-256 before extraction was:

```text
4a42ccaa2acf39072e9172b1ab671601bcb13115c877ee8a62131d33126afd58
```

The unchanged characterization test SHA-256 was:

```text
606bfddfc55dc11cc7f2cc90c306f177d0abdd96b64d9e7cd2c362d4f020e417
```

The pre-edit characterization passed five tests. It froze complete persisted
row maps and order, packed identities and lineage, `int`/`double` source-row
identity, null/blank/whitespace/Unicode and anomalous fields, Apple seconds and
nanoseconds, null dates, duplicate GUID and source identity behavior,
incremental reruns, empty input, progress, transaction rollback, wrapped row
failures, systemic query failures, batch behavior, and source closure.

## Canonical pure projection

`chat_source_projection.dart` now supplies the one concrete deterministic
row-formation path:

```text
ChatSourceProjectionInput
  + importer-owned sourceId and batchId
  -> projectSourceChat(...)
  -> immutable ProjectedSourceChat ledger values
```

`ChatSourceProjectionInput` captures only the seven source fields consumed by
the existing transformation. `ProjectedSourceChat` exposes the normalized
source row identity and an unmodifiable complete ledger map. The synchronous
function reuses `SourceScopedRowKey` and `DateConverter` and retains the exact
required/nullable string and numeric coercion behavior.

The pure module has no SQL, DAO, SQLite, Riverpod, Flutter, filesystem, clock,
I/O, `Future`, `Stream`, global mutable state, progress, mutation capability,
UI, graph, handle, contact, archive, AppCzar, or alternative injected strategy.

`ChatImporter` still owns the source path and ordered query, source lifecycle,
source registration, batch allocation, transaction, insert-ignore persistence,
counts, progress, exception wrapping, and duplicate policy at the same
execution points. It invokes `projectSourceChat` exactly once on its sole row
formation path. The former importer-local map formation and scalar helper
duplication were removed only after parity was established.

The existing graph chat projector, group-chat classification, canonical
identity logic, Messages/Contacts/Handles/Attachments/joins importers, rich
text, FTS, reconstruction, archive authority, AppCzar, and Start Fresh were not
modified.

## Exact parity and validation

The unchanged five-test actual-writer characterization was rerun against the
refactored importer. It passed with equality of every persisted value, row
order, identity, batch reference, fallback, anomaly, omission, insert count,
progress event, duplicate/rerun result, error, transaction result, and source
lifecycle observation.

Direct pure-function tests cover all nine persisted columns, immutable output,
source and batch lineage, service fallback, null/blank/whitespace/Unicode and
non-string inputs, seconds/nanoseconds/null/invalid Apple date inputs, source
identity and GUID validation, material versus irrelevant source-field changes,
and the absence of graph-only classification.

AST architecture tests prove the pure dependency surface, synchronous
execution, absence of mutating authorities, exactly one production importer
call, and continued importer ownership of SQL, batches, transactions, writes,
and progress. The existing source-anomaly architecture assertion was updated
only to follow required GUID and Apple timestamp handling to their new
canonical owner.

Completed validation on the final implementation state:

- focused importer, pure projection, and architecture selection: `15`
  passing tests;
- Chats/Handles/Contacts/Messages/joins/source-ledger and graph regression
  selection: `182` passing tests;
- AppCzar Onboarding, Data Update, Local Data Repair, and Operating selection:
  `272` passing tests;
- archive, historical-source, and attachment selection: `698` passing tests;
- complete architecture suite: `626` passing tests;
- `flutter analyze`: `No issues found!`;
- complete deterministic `flutter test`: `3,232` passing tests and one
  existing skipped test (`~1`), terminal result `All tests passed!`;
- Dart formatting: six implementation/test Dart files checked, `0` changed;
- generated consistency: no `.g.dart` or `.freezed.dart` difference and no
  generator-triggering annotation introduced;
- graph-module diff: empty; and
- `git diff --check` and `git diff --cached --check`: clean.

Two intermediate architecture invocations failed while migrating the existing
textual ownership assertion: the first still required the removed
importer-local GUID helper, and the second used an incorrect exact getter
string. Those assertion errors were corrected to inspect the canonical
projection owner. The focused assertion then passed, followed by the complete
626-test architecture suite and full deterministic suite on the final state.
They are not represented as passing attempts.

## Architecture and Project Conformance audit

The canonical Project Conformance review found:

- **BLOCKER: 0** — no second source of truth, dependency inversion,
  stateful-policy move, mutation expansion, unbounded-work change, or parity
  failure;
- **SHOULD FIX: 0** — the new pure module is the narrow justified owner of the
  already-existing deterministic transformation and reuses the established
  row-key and timestamp authorities; and
- **OPTIONAL: 0** — no adjacent cleanup is required for this extraction.

The implementation checkpoint contains exactly these six files:

```text
lib/essentials/source_scoped_import/application/chats/chat_importer.dart
lib/essentials/source_scoped_import/application/chats/chat_source_projection.dart
test/architecture/chat_source_projection_authority_test.dart
test/architecture/dependency_aware_source_anomaly_policy_test.dart
test/essentials/source_scoped_import/application/chats/chat_importer_test.dart
test/essentials/source_scoped_import/application/chats/chat_source_projection_test.dart
```

It was committed and pushed as:

```text
10732e2986c5e40f7d097f35e2d12daff663fc4f
refactor(import): extract canonical Chats source projection
```

Immediately before this documentation checkpoint, HEAD and upstream both
resolved to that implementation commit, divergence was `0/0`, the tracked
worktree and index were clean, the shared-instructions submodule was unchanged
and clean, and all 49 remaining untracked artifacts (Prompt 96 plus 48
unrelated artifacts) were untouched. This response and Prompt 96 form the
separate documentation-only checkpoint. Its resulting commit hash is reported
in the final handoff because this file cannot contain its own commit hash.

## Boundaries that remain blocked

This extraction is not a populated reconstruction-equivalence witness. It does
not authorize destructive Operating Start Fresh, Stage 2C, production AppCzar
activation, or cutover. Attachments, joins, rich text, graph projection, FTS,
and any next shared-transformation extraction remain separate work requiring
their own characterization and authorization.

`HANDLES EXTRACTION CHECKPOINTED: YES`

`ACTUAL CHATS IMPORTER CHARACTERIZED BEFORE EDITS: YES`

`CANONICAL CHATS SOURCE PROJECTION IS PURE AND SHARED: YES`

`PRODUCTION CHATS IMPORTER HAS ONE CANONICAL ROW-TRANSFORMATION PATH: YES`

`CHATS PERSISTED OUTPUT, OMISSIONS, AND PROGRESS PARITY: PASS`

`GRAPH CHAT/GROUP SEMANTICS UNCHANGED: YES`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES`

`PROJECT CONFORMANCE: PASS`

`READY FOR NEXT NARROW EXTRACTION: YES`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
