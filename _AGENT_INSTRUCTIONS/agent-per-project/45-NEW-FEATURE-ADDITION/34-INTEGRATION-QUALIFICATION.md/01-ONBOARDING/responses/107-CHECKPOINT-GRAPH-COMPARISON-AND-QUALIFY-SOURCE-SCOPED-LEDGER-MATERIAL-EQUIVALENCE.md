# MessageLens — Feature 34
## Response 107 — Graph Comparison Checkpointed and Source-Scoped Import-Ledger Material Equivalence Qualified

Date: 2026-10-14

## Outcome

Prompt 107 is complete. The already-qualified graph replay/comparison work was
left unchanged, and a new disposable, test-only source-scoped import-ledger
material comparator now proves bidirectional anti-differences across the entire
production ImportDatabase schema.

This milestone did not implement a populated reconstruction witness. It did not
authorize destructive Start Fresh, change any AppCzar jurisdiction, or activate
AppCzar in production.

## Baseline and checkpoints

Pre-edit repository state was verified as follows:

- branch: `fix/onboarding-import-stuck-state`;
- baseline HEAD: `9bc7d32466e3d0364bd68b87e16ceb80c87c705c`;
- upstream: synchronized, `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one worktree used this branch;
- 49 pre-existing unrelated untracked paths were recorded externally and
  preserved;
- Prompt 107 itself was one of those untracked paths; and
- source/test baseline manifests were captured under `/private/tmp`, outside
  the repository.

Prompt 106 and Response 106 were already checkpointed and pushed. Their latest
documentation checkpoint was:

`9bc7d32466e3d0364bd68b87e16ceb80c87c705c` —
`docs(feature34): correct graph comparison checkpoint hashes`

No duplicate Prompt 106 checkpoint was created.

The relevant implementation ancestry was verified:

```text
a36feac8a48d1702aad5830076157830d6efb975  Contacts projection
d77d08c6c55e18ade47983fb959b8023c893283c  Messages projection
ae6aa6496e9dd98378c61be1aa7d7984d7207f4c  Handles projection
10732e2986c5e40f7d097f35e2d12daff663fc4f  Chats projection
417a7ef1b24b12991649edc978bd3d0326a6720a  Attachments projection
59f86153eaeb67cf89e73c8380d38722fcf09d92  Chat–Message relationship projection
32b18a6add2e0280f089f21db0af48a4aaebcc12  Chat–Handle relationship projection
b788c07e0bfead2e67f47027ff43fdf50423f494  Message–Attachment relationship projection
e340bdca0c6b8af9d40ab312a7f455d2fd9910db  Rich-text semantic projection
d364df01374abad9e1f8832fa04d70ed237715ff  Production graph replay feasibility
1c1f8f62b1af73991b2317aac869dbc411557594  Graph material comparison
```

The Prompt 107 implementation checkpoint is:

`f477f6858a62ab8849c9e0f254c9312cebea391a` —
`test(import): qualify ledger material equivalence`

It contains exactly the two new test-only files described below and was pushed
before this response was written.

## Actual schema and identity inventory

The comparator derives its contract from the actual production
`ImportDatabase` schema and mechanically checks that contract with SQLite
`PRAGMA table_info`, `PRAGMA index_list`/`index_info`, and
`PRAGMA foreign_key_list`. The actual schema version is **10**. All 11 persisted
tables are covered.

### 1. `source_registry`

- Columns: `source_id INTEGER PRIMARY KEY`, `source_key TEXT NOT NULL`,
  `source_kind TEXT NOT NULL`, `source_label TEXT`,
  `created_at_utc TEXT NOT NULL`.
- Identity: `source_id`.
- Additional uniqueness: `source_key` through its automatic unique index.
- Foreign keys: none.
- Classification: source ID, key, kind, and label are material. The creation
  timestamp is operational UTC provenance and is validated coherently rather
  than required to be byte-identical between independent reconstructions.

### 2. `import_batches`

- Columns: `batch_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `started_at_utc TEXT NOT NULL`, `finished_at_utc TEXT`, `notes TEXT`.
- Identity: `batch_id`.
- Foreign key: `source_id` to `source_registry.source_id`.
- Classification: batch identity, source membership, and notes are material.
  Start/finish timestamps are operational UTC provenance. Their required/null
  state and coherent UTC form are compared without pretending independently
  executed imports have identical wall-clock values.

### 3. `messages`

- Columns: `ss_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `source_rowid INTEGER NOT NULL`, `guid TEXT NOT NULL`,
  `sender_handle_ss_id INTEGER`, `is_from_me INTEGER NOT NULL`,
  `date_utc TEXT`, `date_read_utc TEXT`, `date_delivered_utc TEXT`, `text TEXT`,
  `attributed_body_blob BLOB`, `associated_message_guid TEXT`,
  `raw_item_type INTEGER`, `raw_associated_message_type INTEGER`,
  `thread_originator_guid TEXT`, `error_code INTEGER`,
  `is_system_message INTEGER NOT NULL DEFAULT 0`,
  `has_attributed_body_source INTEGER NOT NULL DEFAULT 0`,
  `has_message_summary_info INTEGER NOT NULL DEFAULT 0`,
  `has_payload_data_source INTEGER NOT NULL DEFAULT 0`,
  `batch_id INTEGER NOT NULL`.
- Identity: packed `ss_id`; source occurrence uniqueness is
  `(source_id, source_rowid)`.
- Indexes: unique source occurrence, source cursor, and GUID.
- Foreign keys: source registry and import batch.
- Classification: every listed column is material and value-exact, including
  nullable versus empty text, raw rich-text bytes, anomaly flags, sender
  identity, and batch membership.

### 4. `handles`

- Columns: `ss_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `source_rowid INTEGER NOT NULL`, `id TEXT NOT NULL`, `service TEXT`,
  `is_me INTEGER NOT NULL DEFAULT 0`, `batch_id INTEGER NOT NULL`.
- Identity: packed `ss_id`; unique `(source_id, source_rowid)`.
- Indexes: unique source occurrence, source cursor, and handle ID.
- Foreign keys: source registry and import batch.
- Classification: all fields are material and value-exact.

### 5. `chats`

- Columns: `ss_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `source_rowid INTEGER NOT NULL`, `guid TEXT NOT NULL`, `service TEXT`,
  `group_id TEXT`, `original_group_id TEXT`,
  `last_read_message_at_utc TEXT`, `batch_id INTEGER NOT NULL`.
- Identity: packed `ss_id`; unique `(source_id, source_rowid)`.
- Indexes: unique source occurrence, source cursor, and GUID.
- Foreign keys: source registry and import batch.
- Classification: all fields are material and value-exact.

### 6. `chat_to_message`

- Columns: `ss_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `source_rowid INTEGER NOT NULL`, `source_chat_rowid INTEGER NOT NULL`,
  `source_message_rowid INTEGER NOT NULL`, `chat_ss_id INTEGER NOT NULL`,
  `message_ss_id INTEGER NOT NULL`.
- Identity: raw packed `ss_id`; unique `(source_id, source_rowid)`.
- Indexes: unique raw source occurrence, chat endpoint, message endpoint, and
  source/message cursor.
- Declared foreign keys: none.
- Classification: raw join ROWID identity, both raw endpoints, and both packed
  endpoints are material and value-exact. Endpoint equality alone is not
  substituted for the preserved raw relationship identity.

### 7. `chat_to_handle`

- Columns: `source_id INTEGER NOT NULL`,
  `source_chat_rowid INTEGER NOT NULL`,
  `source_handle_rowid INTEGER NOT NULL`, `chat_ss_id INTEGER NOT NULL`,
  `handle_ss_id INTEGER NOT NULL`, `batch_id INTEGER NOT NULL`.
- Composite identity and uniqueness:
  `(source_id, source_chat_rowid, source_handle_rowid)`.
- Indexes: unique source tuple, chat endpoint, and handle endpoint.
- Foreign keys: source registry and import batch.
- Classification: source tuple, packed endpoints, and batch membership are
  material and value-exact.

### 8. `contacts`

- Columns: `ss_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `source_rowid INTEGER NOT NULL`, `display_name TEXT NOT NULL`,
  `first_name TEXT`, `last_name TEXT`, `organization TEXT`,
  `created_at_utc TEXT`, `batch_id INTEGER NOT NULL`.
- Identity: packed `ss_id`; unique `(source_id, source_rowid)`.
- Indexes: unique source occurrence, source cursor, and display name.
- Foreign keys: source registry and import batch.
- Classification: all fields, including the source-projected creation value,
  are material and value-exact.

### 9. `contact_channels`

- Columns: `source_id INTEGER NOT NULL`,
  `source_contact_rowid INTEGER NOT NULL`, `contact_ss_id INTEGER NOT NULL`,
  `kind TEXT NOT NULL`, `value TEXT NOT NULL`, `label TEXT`,
  `batch_id INTEGER NOT NULL`.
- Composite identity and uniqueness:
  `(source_id, source_contact_rowid, kind, value)`.
- Indexes: unique source tuple, contact endpoint, and channel value.
- Foreign keys: source registry and import batch.
- Classification: every field is material and value-exact.

### 10. `attachments`

- Columns: `ss_id INTEGER PRIMARY KEY`, `source_id INTEGER NOT NULL`,
  `source_rowid INTEGER NOT NULL`, `guid TEXT`, `filename TEXT`,
  `transfer_name TEXT`, `uti TEXT`, `mime_type TEXT`, `total_bytes INTEGER`,
  `created_at_utc TEXT`, `batch_id INTEGER NOT NULL`.
- Identity: packed `ss_id`; unique `(source_id, source_rowid)`.
- Indexes: unique source occurrence, source cursor, and GUID.
- Foreign keys: source registry and import batch.
- Classification: all fields are material and value-exact. The projected
  attachment creation value is source material, not an operational import
  timestamp.

### 11. `message_to_attachment`

- Columns: `message_source_id INTEGER NOT NULL`,
  `source_message_rowid INTEGER NOT NULL`,
  `attachment_source_id INTEGER NOT NULL`,
  `source_attachment_rowid INTEGER NOT NULL`,
  `message_ss_id INTEGER NOT NULL`, `attachment_ss_id INTEGER NOT NULL`,
  `batch_id INTEGER NOT NULL`.
- Composite identity and uniqueness:
  `(message_source_id, source_message_rowid, attachment_source_id,
  source_attachment_rowid)`.
- Indexes: unique source tuple, message endpoint, attachment endpoint, and
  source-message cursor.
- Foreign keys: both source IDs to the source registry and batch ID to the
  import batch.
- Classification: cross-source occurrence identity, packed endpoints, and
  batch membership are material and value-exact.

No persisted field is silently omitted. There is no ephemeral persisted column
in this schema. Only the three wall-clock batch/registry provenance fields are
classified as operational, and that classification still enforces presence,
nullability, valid UTC shape, and coherent lifecycle ordering.

## Pre-edit actual comparator characterization

Before adding the ledger comparator, a temporary disposable test characterized
the existing graph material comparator. It established that:

- independent equal snapshots compare equal;
- row identity produces deterministic ordering;
- one changed, one missing, and one extra row produce three stable diagnostic
  categories;
- the graph manifest intentionally excludes source registry and batch rows;
  and
- Chat–Message graph identity is endpoint-based and therefore cannot stand in
  for the import ledger's preserved raw join ROWID.

That characterization passed once and was removed before the final checkpoint.
It demonstrated that the graph comparator design could be reused safely, but
the graph comparator itself could not answer ledger identity or provenance
questions. No production change was required.

## Ledger comparison algorithm

The new comparator is deliberately test-only and schema-specific.

1. It opens only caller-supplied disposable `ImportDatabase` instances.
2. It verifies the live production schema against the complete declared
   manifest before reading material.
3. It reads at most 10,000 rows per table by default. Exceeding that bound is
   incomplete evidence and fails closed; it is not truncated into equality.
4. It validates every row's field set, SQLite value type, required/null state,
   declared identity, packed source-scoped identity, source registry reference,
   batch reference, and relationship endpoint evidence.
5. It sorts by each table's declared identity and detects duplicate or invalid
   in-memory identity evidence even where SQLite would reject a persisted
   duplicate.
6. It performs bidirectional anti-differences: expected rows missing from the
   observation, unexpected observed rows, and same-identity changed fields.
7. It distinguishes absent map fields from fields present with SQL `NULL`.
8. It compares BLOB values deeply, not by object identity.
9. It returns deterministic evidence only. Diagnostics have bounded count and
   value length while separately retaining total mismatch counts, so diagnostic
   presentation cannot conceal the extent of a mismatch.
10. It never returns reset authority, mutation capability, an AppCzar fact, or
    coordinator selection.

The implementation reuses production `ImportDatabase` schema construction and
`SourceScopedRowKey` semantics. It does not parse Messages, allocate a source,
run an importer, or create a second semantic projection authority.

## Synthetic qualification matrix

The 11 focused Prompt 107 tests cover:

- exact `PRAGMA` parity for all tables, columns, indexes, and foreign keys;
- independently populated equal ledgers;
- material value changes and operational timestamp equivalence constraints;
- missing, extra, and changed rows in every one of the 11 persisted families;
- raw Chat–Message join ROWID identity versus endpoint-tuple identity in the
  other two relationship tables;
- source ID, source kind/key/label, source occurrence, and batch changes;
- identical visible content carrying different packed identities;
- missing/stale source or batch references and inconsistent batch ownership;
- cross-source Message–Attachment identity and both source references;
- null, empty, whitespace, and Unicode text;
- raw attributed-body bytes and enriched-text distinctions;
- anomaly-preserving message flags and nullable metadata;
- schema-enforced source occurrence uniqueness plus in-memory duplicate
  evidence;
- missing relationship endpoints;
- historical/non-live source material and protected provenance that cannot be
  inferred from a current live source;
- absent field versus SQL `NULL`;
- stable diagnostic ordering, diagnostic count bounding, value truncation, and
  total mismatch preservation; and
- schema drift tripwires.

All fixture IDs, source rows, batches, timestamps, text, and binary data are
fixed synthetic values. No real source database, admitted root, application
archive, or user content was accessed or logged.

## Validation evidence

### Focused comparator

```text
/Users/rob/Development/flutter/bin/flutter test \
  test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparison_test.dart \
  --reporter expanded
```

Final result: **11/11 passed**.

An intermediate run passed 9 and failed 2 because two test expectations selected
the wrong synthetic relationship occurrence and expected endpoint keys where
the ledger correctly reported raw relationship keys. The fixture assertions
were corrected; the comparison policy was not weakened. The final rerun passed.

### Relevant source/graph regressions

```text
/Users/rob/Development/flutter/bin/flutter test \
  test/essentials/source_scoped_import \
  test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart \
  --reporter compact
```

Result: **254/254 passed**.

### Complete architecture suite

```text
/Users/rob/Development/flutter/bin/flutter test test/architecture \
  --reporter compact
```

Result: **640/640 passed**, exit status 0. The first architecture invocation
was interrupted without a recoverable completion record. A sandboxed retry then
failed before running tests because Flutter could not update its SDK cache. That
was not counted as a test failure. The command was rerun with the required file
access and produced the complete attributable result above.

### Static analysis and formatting

```text
/Users/rob/Development/flutter/bin/dart analyze \
  test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparator.dart \
  test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparison_test.dart
```

Result: no issues, exit status 0.

```text
/Users/rob/Development/flutter/bin/flutter analyze
```

Result: no issues, exit status 0.

```text
/Users/rob/Development/flutter/bin/dart format \
  test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparator.dart \
  test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparison_test.dart
```

Result: 2 files processed, 0 changed.

Bare `flutter` and `dart` invocations were not available on this shell's PATH;
those command-not-found results were not represented as validation. The exact
Flutter SDK paths above were used for all attributable results.

`git diff --cached --check` passed before the implementation commit. Source/test
manifest comparison showed only the two authorized new files. Excluding two
pre-existing ignored Finder `.DS_Store` files, the pre-edit source/test hash
manifest remained identical. No generated input/output or production file was
changed, so no generated-code rebuild was applicable to this test-only change.

The full Flutter suite was not required by the governing conformance standard
for this bounded test-only milestone and was not run.

## Exact implementation file inventory

Implementation commit `f477f6858a62ab8849c9e0f254c9312cebea391a`
contains only:

1. `test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparator.dart`
2. `test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparison_test.dart`

There are no changes to `lib/`, Rust, native projects, schema/migrations,
providers, AppCzar, archive behavior, reset behavior, generated files,
dependencies, `pubspec.yaml`, or `CHANGELOG.md`.

## Project conformance review

The implementation was reviewed against the global guardrails, project README,
canonical Project Conformance standard, Prompt 107, and the current database,
source-scoped identity, and projection rules.

- Safety/authority: PASS. The comparator emits test evidence only.
- Architecture: PASS. Production schema and canonical identity helpers are
  reused; no new production authority or source interpreter was introduced.
- Data fidelity: PASS. Nulls, anomalies, raw bytes, source occurrences,
  relationship identity, and provenance remain visible and consequential.
- Boundedness: PASS. Row reads and diagnostic presentation are explicitly
  bounded and fail closed.
- Database rules: PASS. Only disposable test databases are opened.
- Change isolation: PASS. Exactly two new test files were checkpointed.
- Validation: PASS at the focused, relevant-regression, architecture, analysis,
  formatting, and staged-diff levels required by Prompt 107.

No blocker, should-fix, or optional conformance finding remains in the Prompt
107 scope.

## What this proves—and what it does not

This milestone proves that two bounded disposable source-scoped import ledgers
can be compared across all persisted schema material, including source registry
and batch provenance, with deterministic bidirectional anti-differences.

It does **not** prove that an arbitrary installed ledger was reconstructed from
a single coherent source observation. Remaining separate gaps include:

- FTS material and any rebuild/verification needed to establish complete search
  equivalence;
- protected-reference evidence that ties preserved or non-live material to the
  reconstruction without silently discarding it;
- one coherent bounded observation spanning source projection, ledger replay,
  graph replay, overlay/resource state, and all comparators;
- resource and lifecycle proof for temporary databases, readers, and replay
  outputs under success, failure, and cancellation;
- a complete populated reconstruction witness combining the already-qualified
  pure projections, production graph replay, graph comparison, and this ledger
  comparison; and
- the still-separate policy review required before any destructive operating
  reset or production AppCzar cutover.

The next narrowly justified milestone is therefore a **separate disposable,
coherent populated reconstruction-witness design/qualification** that reuses
these existing projections and comparators and explicitly closes the FTS,
protected-reference, coherent-observation, and resource gaps. That work was not
started here.

## Repository state before the documentation checkpoint

Immediately after pushing implementation commit
`f477f6858a62ab8849c9e0f254c9312cebea391a`:

- branch and upstream were synchronized at that commit (`0/0`);
- tracked worktree and index were clean;
- shared-instructions remained clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- all 49 pre-existing unrelated untracked paths remained untouched, including
  Prompt 107 pending its required separate documentation checkpoint; and
- one worktree used the active branch.

GRAPH MATERIAL COMPARISON CHECKPOINTED: YES

LEDGER MATERIAL SCHEMA AND IDENTITIES COMPLETELY INVENTORIED: YES

BIDIRECTIONAL LEDGER MATERIAL ANTI-DIFFERENCES QUALIFIED IN DISPOSABLE TESTS: YES

SOURCE REGISTRY AND BATCH PROVENANCE PRESERVED AS CONSEQUENTIAL: YES

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO

STOP.
