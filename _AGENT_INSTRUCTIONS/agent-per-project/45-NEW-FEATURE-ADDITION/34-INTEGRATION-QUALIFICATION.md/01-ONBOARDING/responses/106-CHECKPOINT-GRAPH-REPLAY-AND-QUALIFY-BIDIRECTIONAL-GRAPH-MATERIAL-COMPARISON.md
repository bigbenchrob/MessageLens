# MessageLens — Feature 34
## Response 106 — Checkpoint Graph Replay and Qualify Bidirectional Graph Material Comparison

**Date:** 2026-10-14

## 1. Outcome

Prompt 106 is complete. The disposable production graph replay harness now owns
an explicit, schema-checked inventory of every persisted material graph column
and compares expected replay material to observed graph material in both
directions. The focused disposable tests prove that missing rows, extra rows,
changed values, null/absent distinctions, identity changes, alias changes,
classification changes, and relationship changes remain visible as bounded,
deterministic mismatches.

This remains test evidence only. It is not a populated reconstruction witness,
does not authorize destructive replacement, does not qualify exhaustive FTS
internal equivalence, and does not activate production AppCzar.

## 2. Verified baseline and prior checkpoint

Pre-edit state was verified as:

- repository: `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch: `fix/onboarding-import-stuck-state`
- baseline HEAD: `eb2f2c8a02513afa8f9dcd4cc5de15a9dff74192`
- upstream: `origin/fix/onboarding-import-stuck-state`, synchronized
  `0 ahead / 0 behind`
- tracked worktree and index: clean
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- worktrees on this branch: exactly one
- source-only baseline SHA-256:
  `8c6c7e24bb7c20d17e997c5afa0ad0b7f7660c7b63e2af0da7474ce06c4a9a14`
- untracked inventory: 49 entries, including Prompt 106; all unrelated entries
  were preserved

Prompt 105 and Response 105 were already checkpointed and pushed at:

`eb2f2c8a02513afa8f9dcd4cc5de15a9dff74192` —
`docs(feature34): record graph replay feasibility`

The Prompt 105 implementation checkpoint was already in ancestry at:

`d364df01374abad9e1f8832fa04d70ed237715ff` —
`test(graph): characterize production replay feasibility`

No duplicate Prompt/Response 105 checkpoint was created.

## 3. Pre-edit comparator characterization

Before changing the comparator, three temporary characterization tests were run
against the existing implementation. They established:

1. independently allocated but equal rows compared equal;
2. missing and extra rows were reported directionally using the current string
   representation;
3. a changed value was reported only as an expected/actual whole-row change.

All 3 characterization tests passed. This confirmed that the old comparator
could notice coarse map inequality, but had no declared schema boundary, no
field-specific diagnostic, no explicit null-versus-absent semantics, and no
bounded diagnostic contract. The temporary characterization group was then
replaced by the final schema and comparator qualification tests.

The initial bare `flutter` command returned exit 127 because Flutter was not on
that non-interactive shell's `PATH`. No test result was inferred. The same
tests were rerun with the verified binary at
`/Users/rob/Development/flutter/bin/flutter`; the attributed run passed 3/3.

## 4. Authorized implementation checkpoint

The implementation checkpoint is:

`1c1f8f627e89c4a36a59fd9e0313b7657068e701` —
`test(graph): qualify material replay comparison`

It contains only:

- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_harness.dart`
- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart`

It was pushed before this response was written. Prompt 106 and this response
form the separate documentation checkpoint containing this record; its exact
resulting hash is reported in the final handoff because a commit cannot contain
its own hash.

No `lib/`, macOS, Rust, generated, dependency, release-metadata, schema,
migration, provider, AppCzar, archive, or Start Fresh file changed.

## 5. Complete persisted material schema inventory

The test-only `graphMaterialTableSpecs` manifest declares all 11 current
persisted material graph tables, their complete column lists, SQLite types,
`PRAGMA table_info` nullability, primary-key positions, material identity, and
whether that identity is enforced by a primary-key or unique constraint.

The exact inventory is:

1. `messages` — identity `ss_id` (primary key); columns `ss_id`, `guid`,
   `sender_handle_ss_id`, `is_from_me`, `date_utc`, `text`,
   `associated_message_ss_id`, `sender_canonical_handle_ss_id`,
   `semantic_kind`, `item_kind`, `is_system_message`, `is_sparse_artifact`,
   `has_attributed_body_source`, `has_message_summary_info`,
   `has_payload_data_source`, `error_code`.
2. `handles` — identity `ss_id` (primary key); columns `ss_id`, `id`,
   `service`, `is_me`.
3. `canonical_handles` — identity `canonical_handle_ss_id` (primary key);
   columns `canonical_handle_ss_id`, `display_handle`,
   `normalized_identifier`, `service`, `alias_count`.
4. `handle_aliases` — identity `handle_ss_id` (primary key); columns
   `handle_ss_id`, `canonical_handle_ss_id`, `raw_identifier`,
   `normalized_identifier`, `alias_kind`.
5. `chats` — identity `ss_id` (primary key); columns `ss_id`, `guid`,
   `service`, `is_group`, `last_read_message_at_utc`.
6. `chat_to_message` — identity (`chat_ss_id`, `message_ss_id`) (composite
   primary key); those are its complete columns.
7. `chat_to_handle` — identity (`chat_ss_id`, `handle_ss_id`) (unique);
   those are its complete columns.
8. `contacts` — identity `contact_id` (primary key); columns `contact_id`,
   `display_name`, `given_name`, `family_name`, `organization`.
9. `contact_to_handle` — identity (`contact_id`, `handle_ss_id`) (unique);
   columns `contact_id`, `handle_ss_id`, `handle_value`.
10. `attachments` — identity `ss_id` (primary key); columns `ss_id`, `guid`,
    `filename`, `transfer_name`, `uti`, `mime_type`, `total_bytes`,
    `created_at_utc`.
11. `message_to_attachment` — identity (`message_ss_id`,
    `attachment_ss_id`) (unique); those are its complete columns.

The schema test independently reads SQLite `PRAGMA table_info`,
`PRAGMA index_list`, and `PRAGMA index_info` from a disposable production-schema
graph and requires exact table/column/type/nullability/primary-key agreement
plus the declared unique identities. An added or changed persisted material
column therefore fails the test until it is deliberately classified.

All persisted columns in these 11 tables are material. There is no omitted
operational-only graph column. `message_text_fts` is deliberately outside this
material manifest and is tested through a separate FTS boundary.

## 6. Final comparison algorithm

The comparator accepts distinct `expected` and `observed` snapshots and walks
the fixed manifest order. For each material table it:

1. indexes rows by the declared material identity;
2. reports duplicate expected or observed identities if supplied by an
   in-memory snapshot;
3. sorts the union of expected and observed identities;
4. reports an expected row missing from observed;
5. reports an unexpected observed row;
6. compares every declared material field in manifest order;
7. distinguishes an absent map field from a present SQL `NULL` and from a
   non-null value;
8. counts every difference while retaining only a bounded diagnostic prefix.

Diagnostics use stable table, identity, field, expected, and observed labels.
Values are JSON encoded, long values are truncated deterministically, and the
default retained diagnostic limit is 64. If further differences exist, the
description reports the exact omitted count. A non-positive limit fails
immediately. Missing rows, extra rows, duplicate evidence, and changed fields
cannot be converted to equality by exhausting the diagnostic budget.

Snapshot queries select the explicit manifest columns and order by the
material identity. No `SELECT *`, implementation-dependent map ordering, or
unbounded dump is used.

## 7. Bidirectional anti-difference test matrix

The final focused suite passed 17/17 tests and qualifies:

- independent disposable replays with equal material;
- missing expected versus extra observed rows in the required direction;
- field-specific changed-value diagnostics;
- SQL `NULL` versus absent-field versus non-null-value distinctions;
- deterministic ordering and bounded diagnostic truncation;
- every persisted `messages` field, including GUID, sender references,
  `is_from_me`, date, text, associated-message identity, canonical sender,
  semantic/item classifications, system/sparse flags, rich-text/summary/payload
  source flags, and error code;
- packed source identity through the existing fixed source-registry identity
  variant;
- handle identity/value/service/`is_me`;
- canonical-handle display, normalization, service, and alias count;
- alias-to-canonical mapping, raw/normalized alias values, and alias kind;
- chat GUID/service/group classification/read timestamp;
- contact display, given/family name, and organization;
- contact-to-handle value and both relationship endpoints;
- attachment GUID, names, UTI, MIME type, byte count, and creation timestamp;
- missing and extra rows for `chat_to_message`, `chat_to_handle`,
  `contact_to_handle`, and `message_to_attachment`;
- repeated replay equality;
- stale populated contact, chat classification, chat-message edge, and
  message-attachment edge remaining visible as mismatches.

Persistent duplicate identities cannot be inserted into the actual production
schema because the declared primary-key/unique constraints reject them. The
comparator still reports duplicate identities if malformed in-memory evidence
is supplied; the schema qualification proves why the disposable database does
not admit such duplicate persisted rows.

## 8. Known stale-populated nonconvergence

The stale-populated test first captures a clean expected replay, then changes
an existing contact display value and chat `is_group` value and adds extra
chat-message and message-attachment relationships. Expected-to-observed
comparison reports each mismatch. Replaying the unchanged source again remains
equal to the stale populated graph rather than converging it back to the clean
expected graph.

This preserves the production writer fact characterized in Prompt 105:
insert-ignore/additive behavior does not provide general populated
reconstruction convergence. No assertion was weakened and no mismatch was
suppressed.

## 9. FTS boundary and limitation

`message_text_fts` is not treated as ordinary material-table evidence. The
material snapshot explicitly excludes it. A separate query-level test verifies
the production triggers and representative case folding, diacritics, quoted
punctuation, 2/3/4-character prefixes, Unicode text, updates, and null text.

The raw unquoted query `co-op` continues to fail because SQLite FTS parses the
hyphen as query syntax; the quoted phrase `"co-op"` succeeds. This limitation
is retained literally. The finite query corpus does not prove internal FTS
shadow-table equivalence, exhaustive tokenizer behavior, or all production
search semantics.

## 10. Isolation, boundedness, and authority

The Prompt 105 disposable harness isolation remains unchanged. It creates only
unique temporary ledger and graph files beneath its guarded temporary root,
uses production-schema database classes and existing production repository
writers, closes handles, and removes the temporary root in `finally`.

The Prompt 106 work introduces no production path, provider, authority,
coordinator, policy, mutation capability, or live source. No Messages,
Contacts, Application Support, admitted MessageLens root, external drive,
archive, overlay, or real user database was accessed. The app was neither
built nor launched.

All corpus sizes, snapshots, schema reads, and diagnostics are bounded. The
comparison is test-only and downstream of two independently replayed
disposable graphs. It cannot authorize replacement or publish AppCzar facts.

## 11. Validation and retry provenance

Final-state validation attributable to implementation commit
`1c1f8f627e89c4a36a59fd9e0313b7657068e701`:

- pre-edit comparator characterization: **PASS**, 3/3 tests using the verified
  absolute Flutter binary
- final focused comparator/replay suite: **PASS**, 17/17 tests
- architecture enforcement: **PASS**, 640/640 tests
- `flutter analyze`: **PASS**, no issues, 6.7 seconds
- `dart format --output=none --set-exit-if-changed`: **PASS**, 2 files checked,
  0 changed
- working and cached diff whitespace checks: **PASS**
- production/generated/release consistency: **PASS**; no `lib/`, macOS, Rust,
  generated Dart, dependency, release metadata, or schema diff
- staged implementation inventory: **PASS**; exactly the two authorized test
  files
- complete Flutter suite: **NOT RUN** because the canonical Project Conformance
  standard does not require it for this bounded test-only milestone and Prompt
  106 requires it only if governing instructions do

Retry provenance is explicit:

- the initial bare `flutter` characterization invocation failed with exit 127
  due to shell `PATH`; it was rerun with the verified absolute binary and
  passed 3/3;
- the first expanded schema/comparator run passed 16 tests and failed one
  test-only nested-list matcher despite correct observed unique-index evidence;
  the matcher was corrected from identity matching to structural equality and
  the suite passed 17/17;
- after direct alias-mapping and remaining message-field coverage was added,
  the complete focused suite was rerun and again passed 17/17;
- the first architecture run's output was truncated and its completed result
  could not be recovered, so no result was inferred; one compact rerun completed
  successfully at 640/640;
- the first staging attempt was denied before index mutation because the
  sandbox could not create `.git/index.lock`; the identical exact-file staging
  operation was rerun with the authorized Git permission and succeeded.

No application failure, source mismatch, nondeterminism, live-data dependency,
or safety stop gate was hidden by any retry.

## 12. Canonical Project Conformance

The complete Prompt 106 diff was reviewed against the global guardrails,
project README, canonical Project Conformance standard, database and identity
rules, Responses 102–105, current graph schema, Prompt 106, and the existing
replay harness contract.

Findings:

- **BLOCKER:** 0
- **SHOULD FIX:** 0
- **OPTIONAL:** 0

The change remains wholly test-owned, uses the existing production-schema
database classes and writer repositories, declares rather than invents graph
identity, adds no production semantic path, preserves every observed mismatch,
and keeps FTS outside the material-table claim. Overlay and archive boundaries,
the seven AppCzar jurisdictions, and production activation are unchanged.

**PROJECT CONFORMANCE: PASS**

## 13. Remaining reconstruction proof obligations

Prompt 106 does not establish:

- equivalence between an arbitrary populated production graph and fresh replay;
- a complete populated reconstruction witness;
- a proof that all existing populated states converge under current writers;
- protected overlay/direct-reference compatibility or anti-join safety;
- exhaustive FTS internal equivalence;
- coherent source/ledger/graph observation across a real reconstruction;
- production-corpus time, memory, cancellation, or restart bounds;
- authorization to replace, delete, or rebuild a real graph;
- destructive Operating Start Fresh readiness;
- production AppCzar cutover readiness.

Those remain separate UNKNOWN evidence milestones. Known stale-populated
nonconvergence remains an explicit mismatch, not an exemption.

## 14. Git and preservation state

The implementation checkpoint was pushed before documentation. At that
boundary HEAD and upstream were synchronized at
`1c1f8f627e89c4a36a59fd9e0313b7657068e701`, the tracked worktree and index
were clean, and the shared-instructions submodule remained clean at
`95326f515ef4719f155ce6e223990398daad6311`.

The same 49 pre-existing untracked entries remained at that boundary, including
Prompt 106. No unrelated untracked file was modified, staged, removed, or
renamed. The documentation checkpoint stages only Prompt 106 and this response;
the other 48 entries remain untouched.

No build, application launch, live database/archive access, populated witness,
protected-reference checker, graph repair, destructive reset, Stage 2C
resumption, new AppCzar jurisdiction, or production cutover was begun.

GRAPH REPLAY CHECKPOINTED: YES

ALL MATERIAL GRAPH TABLES AND COLUMNS INVENTORIED: YES

BIDIRECTIONAL MATERIAL GRAPH ANTI-DIFFERENCES QUALIFIED IN DISPOSABLE TESTS: YES

KNOWN STALE-POPULATED NONCONVERGENCE PRESERVED AS MISMATCH: YES

FTS INTERNAL EQUIVALENCE FULLY QUALIFIED: NO

COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS

READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
