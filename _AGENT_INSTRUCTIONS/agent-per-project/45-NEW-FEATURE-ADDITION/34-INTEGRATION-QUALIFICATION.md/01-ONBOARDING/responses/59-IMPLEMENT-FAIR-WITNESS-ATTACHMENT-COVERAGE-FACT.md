# MessageLens Feature 34
## Response 59 — Fair-Witness Attachment Coverage Fact

Date: 2026-10-03

Prompt 59 is implemented and validated. A fresh AppCzar can now reconstruct
whether the currently admitted local graph's required conventional attachment
payloads have complete durable archive coverage. Availability and coverage are
separate facts. Coverage is derived only from current graph relationships,
current durable object records, the current archive scope, and bounded file
metadata; no remembered operation result participates.

The implementation is unstaged. No app was launched. No production or real
development source, database, archive, archive configuration, or attachment
payload was accessed or modified. All destructive/failure scenarios used
isolated temporary fixtures.

## 1. Baseline verification

The external baseline manifest is:

`/private/tmp/messagelens-prompt59-baseline-20261003.md`

It records the exact pre-implementation state:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- physical untracked files: 47, comprising the 44 known unrelated files plus
  Prompt 58, Response 58, and Prompt 59;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- tracked binary-diff SHA-256:
  `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
- complete porcelain SHA-256:
  `f8a1e99f3697902033c06116e9b24114f6c0f419f84ae911b127841674d7289c`;
- both Git diff checks: pass.

## 2. Exact existing attachment preservation contract

When attachment preservation is enabled, the automatic live archive contract
preserves conventional live-source graph attachments that have:

- a live `chat.db` source-scoped message endpoint;
- a live `chat.db` source-scoped attachment endpoint;
- a nonblank message GUID;
- a nonblank attachment filename/path;
- a nonblank MIME type.

The durable compatibility identity is the message GUID plus the original live
attachment ROWID. The archived object record stores that identity, an
archive-relative path, byte size, and optional SHA-256.

The existing writer copies to a temporary file, flushes it, verifies the
temporary payload's size and SHA-256, and atomically installs the final file.
Only after the file install succeeds does the service cross the
`beforeMetadataCommit` mutation boundary and insert the durable archive record.
The coverage change does not alter this contract or mutation ordering.

When the durable `attachment_archive_enabled` preference is exactly `false`,
the current service deliberately performs no automatic preservation. The
required universe for that policy is therefore empty; this is explicitly
tested rather than inferred from a prior operation.

## 3. Exact required attachment universe

The current required universe is the distinct set of:

```text
(message GUID, original live attachment ROWID)
```

derived from the whole currently admitted live conversation graph, not from a
previous update range. The query joins `messages`, `message_to_attachment`, and
`attachments`; requires both packed endpoints to belong to
`liveChatDbSourceId`; and requires nonblank filename and MIME values.

Historical-source graph rows, blank paths, blank/NULL MIME values, and
non-live endpoints are outside the established conventional automatic
preservation contract. They are not silently treated as missing coverage.

## 4. Existing durable attachment evidence

The existing `archived_attachments` overlay table is sufficient. For each
required compatibility key, it provides:

- `message_guid`;
- `import_attachment_id` (the original live attachment ROWID);
- `archive_relative_path`;
- `file_size_bytes`;
- optional `content_hash`.

The probe verifies the object record against the currently resolved archive
root. It requires a normalized safe relative path, no symlink at the root or
any traversed component, a regular final file, and exact current size. A hash,
when present, must be structurally valid, but startup does not reread and hash
payload bytes because current preservation durability is established by the
writer before metadata commit.

## 5. `skipped` / `deferred` / `failed` semantic audit

The operation aggregate is deliberately not used as coverage evidence:

- an already archived item returns `alreadyArchived` and is aggregated as a
  skip/not-newly-archived outcome;
- missing compatibility metadata or path is aggregated as skipped;
- a currently missing source payload is aggregated as skipped;
- a typed ingestion failure can also return a not-archived outcome that the
  row loop aggregates as skipped, while thrown exceptions increment `failed`;
- authority/location deferral is reported separately through `deferred` and a
  typed reason, and may represent the remaining unprocessed rows.

Those counters describe one worker occurrence. They do not answer current
coverage after restart and cannot authorize AppCzar. The new fact ignores all
of them.

## 6. Chosen current coverage proof

For each bounded read, the probe:

1. reads the current preservation policy;
2. derives the exact required compatibility-key set from the current graph;
3. reads matching durable archive records in bounded batches of 400 keys;
4. verifies safe path shape and current file type/size metadata;
5. repeats the complete material sample;
6. publishes only when the two fingerprints and material classifications
   agree.

Known missing records/files/size matches produce `FALSE`. Ambiguous identities,
record shapes, paths, hashes, conflicts, or changing evidence produce
`UNKNOWN`. Complete matching evidence produces `TRUE`.

## 7. New factual index or manifest

No new index, manifest, database table, or global status row was required.
The existing graph, overlay object records, and archive files are sufficient.

## 8. Object-level fact schema

No persistent object schema was introduced. The new in-memory observation is:

```text
condition: complete | incomplete | unknown
requiredCount
coveredCount
missingCount
unverifiableCount
archiveScopeIdentity
archiveGeneration
bounded issue
```

The enclosing archive observation carries the independently observed current
scope/generation. Non-UNKNOWN coverage can authorize a fact only when the
nested and enclosing bindings agree and its material counts reconcile.

## 9. Crash-safe write ordering

Existing preservation ordering is payload-first:

```text
temporary copy
-> flush
-> size/hash verification
-> atomic final install
-> mutation revalidation
-> durable metadata insert
```

Therefore metadata cannot be published before payload durability through the
supported writer. A crash after payload install but before metadata insert
leaves an extra unreferenced file, which the coverage probe still classifies as
missing coverage. A record without its payload, wrong-size payload, or symlink
is also incomplete. Fixture tests cover all of these states.

## 10. Read-only coverage probe design

`ReadOnlyAppCzarAttachmentCoverageProbe` runs its inspection in an isolate,
opens SQLite databases read-only with `PRAGMA query_only = ON`, guards every
query through the read-only SQL boundary, performs only filesystem metadata
reads, and reads no message/contact content or payload bytes. It creates,
updates, deletes, copies, moves, or hashes nothing.

The outer `ReadOnlyAppCzarAttachmentArchiveProbe` composes availability and
coverage, then rereads configuration and resolves the root again. A location
change during inspection fails closed to `UNKNOWN`.

## 11. Coverage-probe performance and complexity

The final implementation is:

```text
O(R + M + P * D)
```

where `R` is required graph relationships, `M` is matching durable metadata,
`P` is covered paths, and `D` is bounded path depth. Metadata queries are
batched at 400 compatibility keys. Payload-byte work is `O(1)` because no
startup hashing occurs.

A temporary synthetic fixture with 1,000 required relationships, 1,000 matching
records, and 1,000 one-byte payload files completed both bounded samples in
**99 ms** on this development machine. The benchmark fixture was removed after
measurement and never touched real data.

## 12. Complete / incomplete / UNKNOWN semantics

- `TRUE`: required set is known, all counts reconcile, every required key has
  one usable durable record, and every referenced current-root file is a
  non-symlink regular file of the recorded size.
- `FALSE`: required set is known and at least one required record or payload is
  provably absent or wrong-sized.
- `UNKNOWN`: the required set or evidence cannot be interpreted safely, a
  conflict exists, material samples disagree, or current scope cannot be kept
  stable.

UNKNOWN is never promoted by archive availability.

## 13. Archive identity and generation scoping

The current startup scope identity is SHA-256 over:

- admitted archive-instance UUID;
- complete persisted location configuration;
- normalized resolved archive root.

The startup observation also binds the current fresh-process location
generation (`initialGeneration`, 0). The outer and nested observations must
match exactly. Stale/mismatched scope or generation evidence becomes an
UNKNOWN fact and cannot admit Operating. Configuration and resolved-root
stability are rechecked after coverage inspection.

## 14. AppCzar fact-DAG integration

AppCzar now publishes the distinct tri-state fact
`attachmentCoverageComplete`. `attachmentArchiveAvailable` remains unchanged
and separate. Coverage is evaluated only after root, local-store, archive,
source, stability, and local-dataset prerequisites, so virgin/incomplete local
data still selects the existing Onboarding path.

Selection is:

```text
coverage FALSE   -> virtual Attachment Archive Repair
coverage UNKNOWN -> Diagnostic Review
coverage TRUE    -> continue downstream currentness evaluation
```

## 15. Exact Operating admission change

Both the AppCzar evaluator and `AppCzarOperatingSessionController` require the
evaluated `attachmentCoverageComplete` fact to be exactly TRUE. Equal
source/import/graph counts, equal high-waters, and an available archive root
cannot bypass it.

## 16. Attachment Archive Repair behavior

Known incomplete coverage selects the existing
`attachmentArchiveRepair` virtual disposition with literal diagnosis copy.
Unavailable archive selection remains distinct. No repair executor, mutation
path, generalized dispatcher, or fourth executable coordinator was added.

## 17. Critical graph-current/archive-incomplete fresh-process test

The governing regression now uses durable temporary source, import, graph,
overlay, and archive stores through production-shaped readers:

1. a fresh `SqliteAppCzarObservationReader`, archive probe, coverage probe,
   and provider container observe healthy state and select Operating;
2. the temp source advances and matching import/graph mutation commits,
   including a required attachment relation, while archive evidence remains
   absent;
3. the first container is destroyed;
4. a completely new reader/probe/container reconstructs source/import/graph as
   current, archive as available, coverage as FALSE, and selects virtual
   Attachment Archive Repair—not Operating.

No previous-operation value is injected. The test passes both alone and in the
focused file.

## 18. Reciprocal self-healing restoration test

The same fixture then installs the temp payload first and inserts its durable
object record second. A third completely fresh production-shaped
reader/probe/container reconstructs coverage TRUE and selects Operating. No
failure flag is cleared because none exists.

## 19. Zero-required-item result

The established result is:

```text
requiredCount = 0
coveredCount = 0
missingCount = 0
unverifiableCount = 0
coverage = TRUE
```

This applies both to an enabled archive with no conventional live required
relationships and to the current explicitly disabled preservation policy.

## 20. Healthy coverage presentation

The AppCzar assessment adds a literal Attachment coverage row. Complete
coverage presents:

`Complete — N of N required payloads covered`

The displayed condition/significance comes from the evaluated AppCzar fact,
not directly from a raw observation.

## 21. Incomplete coverage presentation

Known missing coverage presents:

`Incomplete — N required payload(s) are not covered`

with repair attention significance and the virtual archive-repair diagnosis.

## 22. UNKNOWN coverage presentation

Inconclusive evidence presents:

`Could not be established`

and includes the bounded factual reason. A raw COMPLETE observation with stale
scope/generation or incoherent counts is rendered as UNKNOWN because the
evaluator rejected its authenticity.

## 23. Proof that no historical operation flag is used

No success, failure, ready, current, needs-repair, last-update, or
preservation-complete field was added. Coverage production has no dependency
on Data Update results, `AttachmentArchiveResult`, onboarding snapshots, or
operation history. Architecture tests reject historical semantic status in
the coverage path, and the restart test supplies only durable/current files.

## 24. Proof that coverage acquires no Ball

The probe has no import of Exclusive Authority, archive mutation coordinator,
capability, writable lease, or Ball APIs. It contains no mutation SQL and calls
no mutation provider. The AppCzar architecture tripwire explicitly enforces
this observation-only boundary.

## 25. Preservation-side mutation authority result

No preservation mutation authority changed. Existing attachment writes still
require the typed archive mutation capability plus generation-bound writable
root lease at the established checkpoints. The new probe observes only the
durable result after those boundaries.

## 26. Archive adoption and relocation compatibility

Default-internal, custom-external, available, and read-only roots all retain
their existing availability meanings. Adoption/relocation changes serialized
configuration and/or normalized root, producing a different scope identity.
Evidence observed across a change is UNKNOWN; stale bound evidence cannot be
reused. Read-only roots can still prove coverage because proof requires reads,
not write eligibility.

## 27. Data Update regression result

All Data Update controller/presentation tests passed within the **205/205**
impacted regression matrix. Its execution authority and post-failure screen
behavior are unchanged.

## 28. Stage One Operating regression result

All Stage One Operating controller and startup-harness tests passed in the same
**205/205** matrix. Operating admission now additionally proves coverage TRUE;
neutral-shell ownership and the three execution predicates remain unchanged.

## 29. Source Access Repair regression result

All Source Access Repair controller/presentation tests passed in the same
**205/205** matrix. FALSE still selects Source Access Repair, UNKNOWN still
selects diagnostics, and coverage does not preempt source jurisdiction.

## 30. Exactly three executable dispositions

The original wording in this section was a documentation census error. The
source-grounded audit confirms exactly these executable predicates:

1. Data Update — executable top-level coordinator;
2. Source Access Repair — executable top-level coordinator;
3. Operating Session — executable admitted session.

Onboarding, Attachment Archive Repair, Local Data Repair, and Diagnostic Review
remain virtual only. Production startup composition remains unchanged.

## 31. Focused coverage results

`read_only_app_czar_attachment_coverage_probe_test.dart`: **10/10 passed**.

The cases cover exact required-set filtering, deterministic/read-only behavior,
zero and disabled policy, missing record/payload crash states, malformed and
conflicting evidence, unsafe paths, symlinks, wrong size, read-only payloads,
scope/generation, and the production-shaped restart/self-healing sequence.

## 32. Architecture result

Complete `test/architecture`: **576/576 passed**.

This includes no mutation/Ball, separate availability/coverage facts,
authentic binding, no historical status, exactly three execution predicates,
virtual repair, and all existing project architecture tripwires.

## 33. Analyzer result

`flutter analyze`: **No issues found**.

## 34. Full Flutter-suite result

Complete deterministic Flutter suite: **2,872 passed, 1 intentional
qualification-harness skip, 0 failed**.

## 35. Diff, format, and generated hygiene

- bounded format verification: 30 Dart files, 0 changed;
- build_runner: completed successfully;
- generated change: only the intended Riverpod hash update in
  `archive_settings_provider.g.dart`;
- `git diff --check`: pass;
- `git diff --cached --check`: pass;
- index: empty;
- implementation: entirely unstaged.

## 36. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

Reviewed against the global guardrails, project README, Dart/Flutter/Riverpod
rules, database and architecture rules, attachment-preservation invariant,
Feature 34 conformance standard, and Prompt 59. Current coverage is factual,
read-only, scope-bound, independently reconstructible, and non-semantic.

## 37. BLOCKER findings

`BLOCKER: 0`

The only final-audit gap was an initially stubbed reconstruction test. It was
replaced with the production-shaped durable-store/fresh-reader regression in
Sections 17–18 and independently re-audited. No blocker remains.

## 38. SHOULD FIX findings

`SHOULD FIX: 0`

No deferred correctness, architecture, testing, or documentation finding
remains within Prompt 59 scope.

## 39. Exact build identity, path, and hashes

Debug development build: succeeded without launching.

- bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.134 (152)`
- executable SHA-256:
  `57dcb70dfa3ec7f2aaf7ffd7c04554005283777d54f65ee73a320b7c8ff53f27`
- `App.framework` executable SHA-256:
  `6992b3c10fa4b5f8e2ca701438f3918a135f2922e4393711747b31247a95b970`
- signing: ad hoc development debug; production identity was not built or
  launched.

The build emitted the existing `volume_controller` PrivacyInfo processing
warning and Xcode empty-device-build-number warning; neither failed the build.

## 40. Exact Git, worktree, index, and submodule state

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`;
- upstream: `origin/fix/onboarding-import-stuck-state` at the same commit;
- ahead/behind: `0/0`;
- index: empty;
- tracked Prompt 59 modifications: 23 files;
- new Prompt 59 production/test/response files: 3;
- physical untracked files: 50, consisting of the baseline 47 plus the new
  coverage probe, coverage test, and this response;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.

No staging, commit, push, merge, or rebase occurred. Known unrelated untracked
files were untouched.

## 41. Readiness to resume Operating-owned live currentness

The Prompt 58 stop gate is now closed at the required fact boundary. A fresh
process can distinguish graph-current/archive-incomplete from healthy coverage,
Operating cannot admit incomplete or UNKNOWN coverage, and restoration is
recognized from reality without clearing state. Prompt 59 intentionally stops
before implementing Operating-owned live currentness.

ATTACHMENT COVERAGE IS INDEPENDENTLY RECONSTRUCTIBLE: YES

FRESH APPCZAR BLOCKS OPERATING WHEN REQUIRED COVERAGE IS INCOMPLETE: YES

ATTACHMENT COVERAGE USES HISTORICAL OPERATION SUCCESS/FAILURE STATE: NO

GRAPH-CURRENT/ARCHIVE-INCOMPLETE STATE IS NOW CLASSIFIABLE AFTER RESTART: YES

READY TO RESUME OPERATING-OWNED LIVE CURRENTNESS: YES
