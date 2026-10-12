# MessageLens Feature 34
## 93 — Checkpoint Reconstruction Audit and Extract the Canonical Contact Source Projection

Response 92 completed the read-only audit of the missing populated-dataset reconstruction-equivalence witness. Its conclusion is binding:

```text
populated import/graph/FTS reconstruction equivalence: NOT PROVEN
Operating-owned destructive Start Fresh Stage 2C: BLOCKED
production AppCzar activation: OFF
```

Production importers and graph projectors currently own consequential transformations inside mutating repositories. A separately written reconstruction checker would be a second semantic implementation, and calling the production writers from a witness would violate the read-only proof boundary. Response 92 therefore calls for **small, behavior-preserving canonical transformation extractions**, followed much later by one bounded read-only witness that shares exactly those implementations.

This prompt implements **Milestone 1 only: Contacts source projection**. It does not implement any witness, change the graph contact projector, resume Start Fresh, or loosen an AppCzar safety predicate.

The Fair-Witness standard applies to both the software and the development report:

> The extracted contact projection must describe exactly what the existing production contact importer already does. It may not silently improve, normalize, filter, reorder, or reinterpret records. A before/after difference is a defect or a STOP condition, not a new expected result.

---

# 1. Baseline and immutable guardrails

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- `HEAD` and upstream synchronized, ahead/behind `0/0`;
- tracked worktree and index clean;
- shared instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one worktree on the Feature 34 branch;
- all known unrelated untracked files untouched;
- Response 92's reported audit HEAD `0da40b75d4f6aca972d7ac745a41079c4bc6d479` in ancestry, or stop if unexpected source evolution changes the contract.

Verify the already-checkpointed Stage 2C safety stop:

`0da40b75d4f6aca972d7ac745a41079c4bc6d479`

Read fully, before editing:

- Prompt 91 and Response 91;
- Prompt 92 and Response 92;
- the canonical Project Conformance standard and source/graph/overlay fidelity rules;
- `lib/essentials/source_scoped_import/application/contacts/contact_source_projection.dart`;
- `lib/essentials/source_scoped_import/application/contacts/contact_importer.dart`;
- current contact importer tests and their synthetic AddressBook fixtures;
- import schema/ledger/contact-channel definitions and current `SourceScopedRowKey` packing;
- `DateConverter`, canonical handle/phone helpers, and the existing contact normalization functions;
- the relevant graph contact projector **for boundary awareness only**; do not edit it;
- relevant source-scoped import architecture/forbidden-import suites.

Create a fresh **source/Git-only** baseline manifest outside the repository. Do not open a real user data source to establish baseline evidence.

---

# 2. Checkpoint Prompt 92 / Response 92 before implementation

Prompt 92 was an audit-only result and both Prompt 92 and Response 92 remain untracked pending review.

Create and normally push a narrow documentation checkpoint containing **only** those two exact files. No `git add .`, force push, rebase, squash, unrelated staging, or branch merge.

Record faithfully:

```text
Stage 2C populated reconstruction proof: ABSENT
Writers do not yet share one reusable canonical transformation authority
All consequential import/graph/FTS domains: INVENTORIED
Read-only equivalence witness: DESIGNED, NOT IMPLEMENTED
First extraction: CONTACTS SOURCE PROJECTION ONLY
Production activation: OFF
Project Conformance: PASS (AUDIT/DESIGN SCOPE)
```

Push before production source edits; report exact checkpoint hash and `0/0` recovery anchor.

---

# 3. Reconfirm source and authority boundaries

Before editing, source-trace:

```text
Apple AddressBook fixture/current source
  -> existing Contacts source reader / import paging
  -> contact_importer.dart
  -> contact_source_projection.dart (existing helpers)
  -> current source-scoped contact and channel ledger insertion
```

List every import-time decision affecting the persisted `contacts` and `contact_channels` row families:

- admissible/invalid source primary and owner identity;
- source-scoped packed identity construction;
- first/middle/last/display/organization name handling;
- null, blank, whitespace, and unknown-field handling;
- `DateConverter` creation-time conversion and fallback;
- email value normalization and label treatment;
- phone normalization, raw fallback, and labels;
- contact/channel omission reasons;
- duplicate/channel ordering and any existing uniqueness behavior;
- source ID, batch ID, source row IDs and associated ledger columns;
- anomaly/progress counting and exception behavior;
- when database constraints rather than pure mapping decide insertion.

Confirm which choices already belong to pure helpers and which are still embedded in the importer. Document any unsupported or unclassified consequential field before changing code.

**Do not move**:

- AddressBook or SQLite opening/queries/paging;
- source/batch registration, runtime clocks, database transactions, or writes;
- import progress, telemetry, logging, retry, anomaly-policy ownership;
- graph projection, canonical-handle grouping, graph contact linkage, or FTS;
- any AppCzar fact, coordinator, Ball, archive operation, or Start Fresh authorization.

---

# 4. Characterize the existing writer BEFORE refactoring

This is the essential regression proof.

Establish deterministic synthetic fixtures against the **unmodified** current importer, capturing exact persisted contact/channel outputs and omission decisions. Prefer extending existing importer tests over adding a second fixture infrastructure.

The characterization must exercise actual importer entry points—not a handwritten simulation of their expected behavior. Use only temporary/in-memory test databases and synthetic records, never real AddressBook data.

At minimum include:

1. first/last names, optional middle name, and whitespace trimming;
2. organization-only display fallback;
3. missing/empty/null/unknown name fields and actual existing omission/fallback behavior;
4. dates requiring canonical Apple-time conversion, including nullable/edge values supported by current schema;
5. normalized email case/whitespace and actual label treatment;
6. phone normalization, punctuation, extension/invalid-value behavior, raw fallback, and actual labels;
7. multiple channels per contact and stable traversal/insertion order;
8. invalid source contact primary key and invalid channel owner;
9. an otherwise valid contact with no viable channels;
10. mixed valid/anomalous fixture rows, preserving the existing behavior rather than silently cleaning them;
11. packed source-scoped identity and source/batch lineage;
12. existing duplicate and uniqueness outcomes, including database-constraint behavior where applicable.

Capture at least one structured **pre-extraction row-map/omission characterization**. Include all consequential persisted columns, not only display strings. For fields such as autoallocated batch IDs or wall-clock operational timestamps, make synthetic fixtures deterministic if already supported. If not, document the exact fields, why their differing physical values cannot be controlled, and whether source already proves their logical comparison can be normalized. Do not silently exclude a field.

If a credible before-state writer oracle cannot be captured without introducing a new semantic transformation implementation, STOP AND REPORT before refactoring.

Keep any baseline characterization small, privacy-safe, reviewable, and based on synthetic values. Avoid snapshotting whole databases or binary files into Git.

---

# 5. Extract exactly ONE typed canonical projection boundary

Extend the existing:

`lib/essentials/source_scoped_import/application/contacts/contact_source_projection.dart`

Use naming idiomatic to the repository, conceptually:

```text
projectSourceContact(raw values, explicit context)
    -> immutable ContactSourceProjectionResult

projectSourceContactChannel(raw values, explicit owner/context)
    -> immutable ContactChannelSourceProjectionResult
```

These names are illustrative, not an instruction to manufacture an unnecessary new framework.

The boundary must be pure and deterministic:

- input is only explicit typed raw values and existing explicit identity/context;
- output is immutable typed canonical row values or an explicit typed omission decision;
- existing normalization helpers, `DateConverter`, and source-scoped identity utilities are **called**, not reimplemented;
- no wall clock, `DateTime.now`, environment, filesystem, source/database handle, Riverpod ref, logger, mutation capability, async operation, or UI dependency;
- no caching mutable values or retaining a source database object;
- no new matching/normalization policy;
- no new contact identity, graph identity, or orphan-repair policy.

Use the smallest number of new types and files. Do not create a generic transformation registry, strategy injection, alternative repository, second importer, or read-only witness.

If source-specific row formation genuinely depends on state that cannot be made explicit without changing writer semantics, keep that part in the importer, record the unresolved seam, and STOP rather than overclaiming a complete extraction.

---

# 6. Make the PRODUCTION writer consume that exact boundary

Refactor only `contact_importer.dart` so its existing source-read and mutation path consumes the typed canonical results.

The importer continues to own:

```text
source SQL/AddressBook read
-> same row order
-> shared pure contact/channel projection
-> same ledger transaction/insertion
-> same progress/anomaly/failure behavior
```

Require that the importer has **one route** to each now-extracted transformation. Remove duplicated private normalization/row-formation branches only after tests prove parity.

Preserve exactly:

- importer API, callers, entry points, and cancellation/paging;
- source registration and batch creation;
- source-row fidelity, including anomalous records;
- original row skip/omission choices and their ordering;
- import transaction boundaries and error behavior;
- schema names, column values, types, nullability, constraints, and stable IDs;
- no additional source query or database read;
- no different contact/channel row order;
- no more or fewer anomaly/progress events;
- no new migration or version bump.

Graph contact projection is out of scope and must retain its current identity and linkage semantics.

---

# 7. Prove before/after WRITER parity independently

Run the same actual importer fixtures and assertions against the refactored production path.

For every characterization case, compare:

- exact persisted contact rows and columns;
- exact persisted contact-channel rows and columns;
- exact source identity/packed keys and batch provenance;
- row counts and order where observable and material;
- normalized values and labels;
- omission/inclusion decisions;
- unknown/anomalous/error handling;
- progress and transaction behavior where existing tests can observe it.

Do not update the expected golden merely because refactored output differs. On mismatch, identify the source-grounded original behavior and correct the extraction or restore the checkpoint and STOP.

Prefer precise fixture assertions over brittle SQL-serialization details. Byte-level SQLite page/WAL layout is not the parity target; **logical persisted row and decision equivalence is**.

Add direct pure-projection tests covering all the edge cases listed above. Explicitly test that varying irrelevant calling context does not change the canonical output while varying a material identity does.

---

# 8. Mechanical single-authority and purity tests

Architecture/forbidden-import tests must prove:

- `contact_source_projection.dart` has no DB writer, source reader, filesystem, clock, Riverpod, UI, Ball, AppCzar, Journey, Environment Readiness, reset, or archive-mutation imports;
- `contact_importer.dart` consumes the shared projection functions/results for each extracted decision;
- the former duplicated branches do not remain as alternate writer normalization paths;
- the projection does not import `contact_importer.dart` (no cycle);
- no Settings/Onboarding/Operating/production selector behavior is changed;
- the graph contact projector remains outside the source-projection change;
- `SourceScopedRowKey` and `DateConverter` remain existing canonical authorities;
- no new startup/semantic owner, worker, schedule, or mutation edge exists;
- existing exact seven-jurisdiction AppCzar census remains unchanged;
- production activation remains unconditionally disabled and official production still selects legacy `StartupApp`.

Do not make brittle tests depend on incidental source-file line ordering or comments. Test actual dependency/call boundaries and outputs.

---

# 9. Regression matrix and validation

Run the repository's established commands, recording exact exit codes/counts:

1. pre-extraction writer characterization tests against baseline;
2. new direct canonical contact/channel projection tests;
3. unchanged and augmented `contact_importer_test.dart`;
4. other contact source-projection/import fixture tests;
5. relevant source-scoped import tests, including source-key packing and `DateConverter`;
6. conversation graph contact/handle linkage regression tests, without editing those writers;
7. Onboarding and Data Update import regressions;
8. Local Data Repair safety-reader and protected-reference tests (no change expected);
9. historical-source registry/import/remove regressions;
10. Stage 2A neutral Messages source and Stage 2B support/Environment regressions;
11. archive authority and attachment-preservation regressions;
12. AppCzar evaluator/composition/Operating regressions;
13. complete architecture/forbidden-import suites;
14. `flutter analyze`;
15. full deterministic `flutter test` suite;
16. Riverpod/build-runner generated consistency if applicable;
17. `dart format` plus `git diff --check` and staged-diff checks;
18. canonical Project Conformance audit.

No real source data, WD/Toshiba archive, production database, installed app, or external donor may be used.

**Do not build, launch, install, sign, notarize, migrate, or rehearse an application** in this milestone. Existing synthetic tests are authorized; real-data tests are not.

---

# 10. Project Conformance and stop gates

Require:

```text
PROJECT CONFORMANCE: PASS
BLOCKER: 0
SHOULD FIX: 0
```

STOP AND REPORT if:

- old writer behavior cannot be characterized with synthetic fixtures;
- a changed output is accepted as a new expected result;
- any persisted contact/channel field or omission rule is left unclassified;
- importer source SQL, row ordering, transaction boundaries, progress/anomaly behavior, or batch semantics would change;
- a second contact mapping or writer path remains active;
- pure code needs SQLite/AddressBook handles, current clocks, provider refs, or mutation capabilities;
- graph/FTS/handle/chat/message projection changes become necessary;
- reconstructibility is claimed proven for populated import/graph data;
- any Reset/Start Fresh/Local Data Repair authority is changed;
- production AppCzar activation or restarter eligibility would be changed;
- source/testing scope expands into other extraction milestones;
- conformance cannot pass cleanly.

On a stop, restore exploratory source/test/generated edits as required and preserve the audit/report evidence. Do not make a permissive fallback. Do not claim success from a reverted implementation.

---

# 11. Source checkpoint and documentation

If and only if tests and conformance pass:

1. stage only the intended source/tests/generated/architecture paths;
2. create a narrowly scoped implementation commit;
3. push normally as a recovery anchor;
4. checkpoint Prompt 93/Response 93 in a separate documentation-only commit;
5. push normally and report exact terminal HEAD/upstream;
6. leave all unrelated untracked files and other worktrees untouched.

Suggested subject:

`refactor(import): extract canonical Contacts source projection`

No release metadata bump should be invented for a behavior-identical internal refactor unless the project's actual policy expressly requires it; if such a policy introduces larger out-of-scope release work, STOP and report.

---

# 12. Subsequent milestone boundary

A PASS permits proposing **the next narrow transformation extraction** for separate review. Response 92's recommended order is message source projection next, followed by other source families, rich-text contract, graph projection, identity linkage, logical FTS, and only then a read-only witness.

A PASS does **not** authorize:

- message importer extraction in the same prompt;
- graph contact projector refactor;
- a read-only reconstruction witness;
- relaxation of Local Data Repair's empty-graph requirement;
- Operating-owned Start Fresh implementation or reset;
- Stage 2D production shell construction;
- a production-identity rehearsal or actual cutover.

A failed parity proof requires source restoration and a new, narrower review before proceeding.

---

# 13. Required Response 93

Create Response 93 with:

1. baseline branch, HEAD/upstream, submodule, one-worktree and status result;
2. Prompt 92/Response 92 audit checkpoint and pushed hash;
3. pre-edit exact contact importer/projection call graph;
4. complete current contact/channel persisted-field inventory;
5. exact identity/normalization/timestamp/omission authorities;
6. synthetic fixture and writer-characterization method established **before source editing**;
7. pre-extraction row maps and omission/progress observations;
8. treatment of batch IDs, timestamps, and other potentially temporal metadata;
9. pure projection function(s) and immutable result type(s);
10. proof that production writer uses the one shared transformation path;
11. unchanged source SQL/paging, transaction, batching and exception behavior;
12. post-extraction contact/channel row maps;
13. before/after parity verdict, including omitted/anomalous cases;
14. direct projection test results;
15. source-scoped import and source-key/timestamp test results;
16. graph contact/canonical-handle and protected-reference regressions;
17. Onboarding/Data Update/Historical import regressions;
18. Stage 2A/2B and archive/adoption regressions;
19. architecture and forbidden-import results;
20. analyzer result;
21. full Flutter-suite counts including skips;
22. generated/format/diff hygiene;
23. Project Conformance result;
24. BLOCKER and SHOULD FIX findings;
25. implementation commit/push if implemented;
26. Prompt 93/Response 93 documentation checkpoint hash if completed;
27. final Git/worktree/index/submodule state;
28. readiness for next narrow extraction;
29. readiness for full populated reconstruction witness;
30. readiness to resume destructive Stage 2C;
31. readiness for Stage 2D/rehearsal/production cutover.

Conclude exactly:

`RESPONSE 92 AUDIT CHECKPOINTED: YES / NO`

`PRE-EXTRACTION WRITER OUTPUT CHARACTERIZED BEFORE EDITS: YES / NO`

`CANONICAL CONTACT/CHANNEL SOURCE PROJECTION IS PURE AND SHARED: YES / NO`

`PRODUCTION CONTACT IMPORTER USES ONE CANONICAL TRANSFORMATION PATH: YES / NO`

`CONTACT/CHANNEL PERSISTED OUTPUT AND OMISSION PARITY: PASS / FAIL / NOT IMPLEMENTED`

`CONTACT SOURCE PROJECTION EXTRACTION IMPLEMENTED: YES / NO`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT NARROW EXTRACTION: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then STOP.
