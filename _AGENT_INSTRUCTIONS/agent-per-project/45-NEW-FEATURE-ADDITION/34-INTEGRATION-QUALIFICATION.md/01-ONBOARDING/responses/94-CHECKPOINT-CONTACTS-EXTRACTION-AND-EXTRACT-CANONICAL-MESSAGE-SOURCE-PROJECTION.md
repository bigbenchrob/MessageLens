# Response 94 — Canonical Messages Source Projection

## Scope and baseline

This response records the narrow Messages source-row transformation extraction
authorized by Prompt 94. It does not implement a reconstruction witness,
destructive Operating Start Fresh, rich-text enrichment, graph projection, FTS,
or production AppCzar activation.

The verified pre-edit baseline was:

- branch `fix/onboarding-import-stuck-state`;
- HEAD `ee5425dd06d3a2a07cea6f22faaba6e1bc17515f`;
- upstream `origin/fix/onboarding-import-stuck-state`, synchronized `0/0`;
- clean tracked worktree and index;
- shared-instructions submodule at
  `95326f515ef4719f155ce6e223990398daad6311`, clean; and
- the pre-existing 49 untracked artifacts, including Prompt 94, preserved
  untouched.

Prompt 93 and Response 93 were already recorded by the exact documentation
checkpoint `ee5425dd06d3a2a07cea6f22faaba6e1bc17515f`
(`docs(appczar): record Contacts projection extraction`). No duplicate recovery
checkpoint was made.

## Pre-edit production writer characterization

`MessageImporter.importNewMessages` was characterized against a synthetic
Messages source and the actual source-scoped import ledger before changing the
writer. The fixture and its baseline result are recorded at:

`/private/tmp/messagelens-prompt94-pre-edit-manifest-20261012T174829Z.md`.

The immutable raw input is one source-row map from the existing bounded
Messages query. The writer's pre-edit call graph was:

```text
readMessageImportPage
  -> association-target lookup for the current page
  -> importLedger.writeTransaction
  -> insertIgnore('messages', persisted row map)
  -> page metric, boundary, progress, and anomaly observations
```

The source query, source-row ordering, page size, high-water bounds, batch
assignment, transaction boundary, duplicate handling, progress events, and
association lookup order were retained unchanged. Paging stays owned by the
source database port; persistence stays owned by the import ledger transaction.

The `messages` persisted column inventory remains exactly:

```text
ss_id, source_id, source_rowid, guid, sender_handle_ss_id, is_from_me,
date_utc, date_read_utc, date_delivered_utc, text, attributed_body_blob,
associated_message_guid, raw_item_type, raw_associated_message_type,
thread_originator_guid, error_code, is_system_message,
has_attributed_body_source, has_message_summary_info,
has_payload_data_source, batch_id
```

Stateful ownership remains in `MessageImporter`: it performs the page-scoped
existing-associated-target lookup before entering the existing write
transaction. The canonical projection receives only raw source facts plus the
already-selected `sourceId` and `batchId`; it performs no lookup.

Raw nullable, empty, whitespace, and Unicode text remain source data. Raw
attributed-body blobs remain bytes. No rich-text decoding, enrichment,
classification, graph, FTS, or attachment work moved into the projection.

The actual-writer characterization included a linked normal row and an unusual
unlinked reaction-style row across two one-row pages. It asserted the complete
persisted row maps, packed source identities, Apple date conversion, blob
values, associations, page metrics, page-boundary observations, progress,
timestamp-unavailable/recovered-unlinked/unresolved-reaction anomaly counts,
and a zero-insert incremental rerun. The unmodified baseline focused test
completed with `15` passing tests.

## Canonical pure projection

`message_source_projection.dart` supplies the only canonical row
transformation path:

```text
MessageSourceProjectionInput (raw source query fields)
  -> projectSourceMessage(sourceId, batchId)
  -> ProjectedSourceMessage (immutable ledger values and contextual facts)
```

The pure input explicitly preserves every raw Messages-query field consumed by
the importer. The output contains the immutable ledger map and the existing
contextual values needed by the importer for its unchanged metrics and anomaly
decisions. It has no database, filesystem, provider, archive, clock, worker,
process, UI, or mutation authority dependency.

The extraction reuses the established `DateConverter` for Apple timestamps and
`SourceScopedRowKey` for packed source identities. It moves the existing
validation and conversion helpers rather than copying them into a second
implementation. `MessageImporter` now constructs projection inputs once per
page and calls `projectSourceMessage` once per source row; its former local
row-mapping helpers were removed.

No source SQL, page boundary, transaction boundary, source lineage, batch
selection, deduplication, progress behavior, sender/association lookup order,
or error policy changed.

## Parity and validation evidence

The identical actual-writer characterization was rerun after extraction with
its unchanged expected row maps and observations. The before/after material
output, anomalous row treatment, counts, ordering, and progress were equal.

Direct pure-projection tests cover every persisted field; source lineage and
packed identity; current `DateConverter` conversion; null, empty, whitespace,
and Unicode text; byte blobs; direction, system, reaction, service/error, and
source flags; missing associated targets; invalid required values; immutable
output; source-row non-mutation; and an irrelevant contextual change versus a
material source-fact change.

Completed validation on the final code state:

- focused projection/importer/architecture regression: `29` passing tests;
- source-scoped import, DateConverter, Contacts projection, and identity
  regressions: `137` passing tests;
- graph message/classification/handle regressions: `162` passing tests;
- Onboarding, Data Update, Local Data Repair, Operating currentness, and
  AppCzar regressions: `684` passing tests;
- attachment/archive/historical-source regressions: `609` passing tests;
- complete architecture/forbidden-import suite: `620` passing tests;
- `flutter analyze`: `No issues found!`; and
- complete deterministic `flutter test`: `3,204` passing tests and one
  existing skipped test (`~1`).

The full suite covers FTS and the other unchanged import consumers. No rich-text
enricher, graph writer, FTS writer, Contacts importer, source registry, batch
policy, AppCzar evaluator, archive authority, adoption gate, Start Fresh, Local
Data Repair eligibility, or currentness worker was modified. The seven
AppCzar-jurisdiction architecture remains unchanged and production composition
activation remains disabled.

Formatting was applied to the changed Dart files. No generated source applies
to this plain Dart extraction. `git diff --check` and the staged diff check
were clean.

## Architecture and Project Conformance audit

The architecture test proves the pure projection's exact narrow import set and
its lack of asynchronous, I/O, persistence, or authority calls. It also proves
that production `MessageImporter` calls the concrete canonical projection while
retaining source read, association lookup, transaction, and insert ownership.
The existing source-anomaly policy test was updated only to point at the
relocated canonical validation/date boundary.

The canonical Project Conformance audit found:

- **BLOCKER: 0** — no duplicate source of truth, invalid dependency direction,
  unbounded work, unsafe mutation, or semantic parity failure;
- **SHOULD FIX: 0** — the projection is the justified, narrowly owned pure
  boundary and uses established identity/timestamp authorities; and
- **OPTIONAL: 0** — no additive cleanup is needed for this bounded extraction.

The implementation checkpoint contains exactly six files:

```text
lib/essentials/source_scoped_import/application/messages/message_importer.dart
lib/essentials/source_scoped_import/application/messages/message_source_projection.dart
test/architecture/dependency_aware_source_anomaly_policy_test.dart
test/architecture/message_source_projection_authority_test.dart
test/essentials/source_scoped_import/application/messages/message_importer_test.dart
test/essentials/source_scoped_import/application/messages/message_source_projection_test.dart
```

It was committed and pushed as:

```text
d77d08c6c55e18ade47983fb959b8023c893283c
refactor(import): extract canonical Messages source projection
```

This response and Prompt 94 are the separate documentation-only checkpoint;
the resulting documentation hash and final pushed recovery anchor are reported
in the final handoff because this file cannot contain its own resulting hash.

## Boundaries that remain blocked

This extraction is not a full populated reconstruction-equivalence witness.
It does not authorize destructive Operating Start Fresh or Stage 2C, Stage 2D,
staged rehearsal, or production AppCzar activation. Those remain separate,
unimplemented work requiring their own evidence and authorization.

The next safe work item is a separate, similarly narrow shared-transformation
extraction. It must begin with its own characterization and must not infer
reconstruction equivalence from this Messages-source slice.

`CONTACTS EXTRACTION CHECKPOINTED: YES`

`ACTUAL MESSAGES IMPORTER CHARACTERIZED BEFORE EDITS: YES`

`CANONICAL MESSAGES SOURCE PROJECTION IS PURE AND SHARED: YES`

`PRODUCTION MESSAGES IMPORTER HAS ONE CANONICAL ROW-TRANSFORMATION PATH: YES`

`MESSAGES PERSISTED OUTPUT, ANOMALIES, AND PROGRESS PARITY: PASS`

`NO RICH-TEXT, GRAPH, FTS, OR OTHER IMPORTER BEHAVIOR CHANGED: YES`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES`

`PROJECT CONFORMANCE: PASS`

`READY FOR NEXT NARROW SHARED-TRANSFORMATION EXTRACTION: YES`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`
