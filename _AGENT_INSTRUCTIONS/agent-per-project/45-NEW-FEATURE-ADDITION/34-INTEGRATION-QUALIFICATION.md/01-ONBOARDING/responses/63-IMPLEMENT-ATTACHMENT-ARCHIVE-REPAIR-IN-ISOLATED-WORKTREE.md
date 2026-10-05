# MessageLens Feature 34
## Response 63 — Implement Attachment Archive Repair in an Isolated Worktree

Date: 2026-10-04

Prompt 63 is implemented in the isolated repair worktree and remains entirely
unstaged. The development artifact was built but was not launched. No real
MessageLens database or attachment archive was read, written, repaired, or
otherwise modified during this implementation and validation.

### 1. Primary-worktree baseline and integrity verification

Before repair implementation, the primary worktree was verified and recorded
outside either worktree at:

`/private/tmp/messagelens-prompt63-primary-baseline-20261004T171749Z.md`

The captured state was:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream: `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- ahead/behind: `0/0`;
- index: empty;
- tracked Prompt 60 diff SHA-256:
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- tracked Stage Two modified paths: 18;
- new Stage Two source/generated/test paths: 14;
- complete porcelain entries: 82;
- complete porcelain SHA-256:
  `56cb2f53ea424c1e982504d6e32d22da67258f1c27c6d7a8cc2245157ec1d2ec`;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.

The external manifest contains an individual SHA-256 for each of the 18
tracked and 14 new Prompt 60 files. The primary tree was then treated as
read-only for the whole task.

### 2. Repair worktree creation, path, branch, and base

Repair work occurred only in:

`/private/tmp/messagelens-appczar-attachment-archive-repair`

- branch: `feature/appczar-attachment-archive-repair`;
- starting and current commit:
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- shared-instructions submodule pointer and checkout:
  `95326f515ef4719f155ce6e223990398daad6311`;
- submodule worktree: clean.

No existing unrelated worktree was reused or changed.

### 3. Exact repair execution predicate

`shouldExecuteAppCzarAttachmentArchiveRepair` admits repair only when one
current assessment proves all of the following:

1. `virtualCoordinator == attachmentArchiveRepair`;
2. diagnosis kind is `attachmentArchiveCoverageIncomplete`;
3. the unique `attachmentCoverageComplete` fact is `FALSE`;
4. the unique `attachmentArchiveAvailable` fact is `TRUE`;
5. current coverage, archive scope identity, archive generation, and canonical
   resolved path are present and mutually coherent; and
6. the assessment generation is current for the occurrence.

Duplicate or missing facts, archive unavailability, coverage `UNKNOWN`, stale
generation, blank identity/path, incoherent coverage binding, and unsupported
diagnoses all fail closed.

### 4. AppCzar top-level execution census

Development AppCzar now has exactly these live top-level categories:

- Data Update — executable coordinator;
- Source Access Repair — executable coordinator;
- Attachment Archive Repair — executable coordinator;
- Operating Session — executable admitted session.

Onboarding, Local Data Repair, and Diagnostic Review remain virtual. The host
has explicit branches; no generic enum dispatcher or coordinator-to-coordinator
handoff was added. Production startup behavior remains unchanged.

### 5. Shared key-level evidence-reader design

`RequiredAttachmentEvidenceReader` is the singular typed read-only boundary
for the required attachment universe and its durable coverage evidence.
`SqliteRequiredAttachmentEvidenceReader` owns the SQL, decoding, archive-record
inspection, path safety checks, and payload classification.

The exact compatibility identity is:

`(message GUID, original live attachment ROWID)`

Item evidence is classified as:

- covered and valid;
- no durable record;
- record payload absent;
- record wrong size;
- unsafe or unverifiable path;
- conflicting durable evidence; or
- ambiguous required identity.

The returned material fingerprint is privacy-safe and detects evidence changes
without exposing source filenames or archive-relative paths.

### 6. One shared required-set definition

The exact required-set SQL now exists only in
`SqliteRequiredAttachmentEvidenceReader`. It requires:

- a live-source message endpoint;
- a live-source attachment endpoint;
- nonblank message GUID;
- nonblank filename/path; and
- nonblank MIME type.

The startup coverage probe is now an adapter over that reader rather than an
owner of a second query. Repair consumes the same reader and classifications.
Tests and architecture tripwires prove the startup adapter owns no required-set
SQL and that the shared reader is the sole owner of the marker and semantics.

### 7. Pagination and batching design

Required evidence uses deterministic composite keyset ordering by message GUID
then original live attachment ROWID. The normal page size is 75 and the typed
reader rejects sizes outside 1–100. Aggregate coverage is accumulated in
constant memory; the complete required universe is never retained.

The current-source reader accepts at most 100 exact keys per read and performs
payload metadata/readability checks sequentially. Mutation batches are bounded
to one 75-item repair page, and only one payload is streamed and installed at a
time.

### 8. Authoritative current-source evidence

`CurrentMessagesAttachmentSourceReader` and
`SourceDatabaseCurrentMessagesAttachmentSourceReader` prove both halves of the
exact key against a fresh read-only `chat.db` query. They then inspect the path,
regular-file type, safe representable extension, readability, size, and
modification timestamp from that current row.

The retained imported path is not consulted and cannot override current source
metadata. Evidence distinguishes available, absent, unreadable, globally
unavailable, globally inconclusive, and item-level unknown conditions.

### 9. No-record automatic repair classification

Only this class is automatically eligible:

```text
no durable record
+ exact current GUID/ROWID identity
+ current source payload available and readable
+ coherent current archive binding
```

The writer re-observes source material immediately before installation and
again after installation. A changed source, newly appeared record, unsupported
path/extension, lost access, or inconclusive evidence prevents a false-positive
commit.

### 10. Record-backed defect handling

Record-backed absent/wrong-size payloads are reported as
`recordBackedRecoveryCount` and remain bounded manual/recovery work. This task
does not overwrite an existing record or weaken the ordinary no-overwrite
invariant. If a record appears during a no-record attempt, the writer returns
`recordAppeared` without committing replacement metadata.

Automatic record-backed repair was deliberately not introduced because the
existing safe no-record writer does not prove an atomic payload-and-metadata
replacement contract for defective records. The real audited population for
this class remains zero.

### 11. Callback-local writer seam

`AdmittedAttachmentArchiveRepairWriter.preserveNoRecord` accepts the exact
`ArchiveMutationCapability` and `AttachmentArchiveWritableRootLease` as method
arguments. It cannot acquire mutation authority itself and retains neither
proof after the callback returns. Wrong-operation, expired, and invalidated
proofs fail closed.

### 12. Mutation-tenure path

The sole production mutation edge is:

```text
Attachment Archive Repair bounded batch
-> ArchiveMutationCoordinator.runWithCapability(
     attachmentReconciliation)
-> current writable-root admission and generation-bound lease
-> callback-local AdmittedAttachmentArchiveRepairWriter
-> verified archive file-store primitive
```

There is one Ball tenure per admitted bounded mutation batch. There is no
nested Ball and no direct coordinator filesystem write. A runtime test using
the real mutation coordinator proves the Ball remains held while the writer is
blocked, drain remains pending, and authority is released before drain
completes and can be reacquired afterward.

### 13. Payload/object-record crash-safe ordering

Each eligible object follows this order:

1. prove current source identity/material evidence;
2. revalidate callback capability and writable lease;
3. stream source into the established temporary-file path;
4. flush and verify size/hash;
5. atomically install without overwriting an existing final object;
6. re-observe unchanged source material;
7. revalidate mutation authority before metadata commit;
8. write the durable object record; and
9. re-read and verify record, payload existence, size, hash, status, and
   location generation.

Installation, metadata, revalidation, and post-commit failures remain factual
failures and never manufacture coverage. Durable payload installation precedes
the object-record commit.

### 14. Coordinator jurisdiction

The generation-bound coordinator may freshly recompute coverage, page and
classify uncovered objects, preserve currently proven no-record payloads after
explicit confirmation, verify fresh coverage, publish privacy-safe aggregates,
remain visible for human-action classes, and request restart after drained
terminal work.

It does not use the historical 13,841 count, invoke Data Update or Source
Access Repair, admit Operating, write a Journey cursor, persist a global repair
result, or manufacture attachment identity.

### 15. Internal sub-operations

The implementation retains one top-level coordinator with internal typed work
equivalent to:

- recompute coverage;
- classify uncovered evidence;
- preserve current available no-record payloads;
- verify current coverage; and
- report remaining manual requirements.

These are ordinary bounded operations, not additional AppCzar coordinators.

### 16. Automatic batch behavior

An explicit preservation request is single-flight. It begins from a fresh
stable inspection, captures only the currently authorized available count,
walks deterministic 75-key pages, and admits sequential bounded mutation
batches while the same occurrence and archive binding remain current. Stop
blocks new item admission synchronously. There is no hidden queued batch after
stop and no restart after each page.

### 17. Natural interruption and resume semantics

No repair cursor or historical operation result is persisted. Interruption
stops admission, drains source/writer work, releases Ball/lease authority, and
exits. A later process or explicit check recomputes from the current graph,
source, object records, and archive payloads. Successfully committed records
naturally leave the uncovered set on that fresh scan.

### 18. Manual, source-absent, and unknown behavior

- Current source absence remains uncovered and is reported as a current manual
  condition; it is not called permanent loss.
- Unreadable or item-inconclusive source evidence is counted as source evidence
  unavailable rather than absent.
- Record-backed and unsafe/conflicting cases remain separate aggregate manual
  classes.
- Global source loss terminates through drain/restart.
- Globally inconclusive source evidence or incoherent coverage becomes
  coverage `UNKNOWN`, not incomplete.

No Ignore, Mark Repaired, Exempt, or Assume Lost action exists.

### 19. No-restart-loop behavior

If fresh coverage remains `FALSE` and no automatic work is currently possible,
the coordinator stays on `waitingForHuman`. It does not restart into the same
conclusive deficit. A regression proves the manual-only surface remains visible
with zero restarter calls.

### 20. Check Again behavior

`Check Again` is explicit and single-flight. It drains the prior executor and
creates a fresh one-use occurrence only while the same current assessment and
binding still select this jurisdiction. It rereads required evidence and the
current source; it does not reuse a repair cursor or classification. If the
current assessment/binding has changed, it drains and requests a real restart
instead of re-admitting in-process.

### 21. Coverage TRUE terminal behavior

Fresh `coverageComplete` evidence triggers stop/drain, then a real process
restart and fresh AppCzar assessment. Repair never declares or directly admits
Operating.

### 22. Coverage FALSE terminal behavior

Fresh coherent incomplete coverage publishes only current aggregate facts.
Automatic work requires explicit human confirmation; manual-only work stays on
the repair surface. `FALSE` never declares success.

### 23. Coverage UNKNOWN terminal behavior

Coverage `UNKNOWN` stops and drains the occurrence, then requests a real
process restart so fresh AppCzar can select Diagnostic Review. It is never
relabelled incomplete.

### 24. Source-access-loss behavior

Global current-source loss stops new work, drains the executor/writer and
Ball/lease boundary, and requests a real restart. Source Access Repair is not
called in-process. Fresh AppCzar alone selects the next jurisdiction.

### 25. Archive identity and generation behavior

Every occurrence is bound to:

- assessment generation;
- unique occurrence ID;
- archive scope/instance identity;
- archive location generation;
- canonical resolved archive path; and
- callback-local writable lease generation at mutation time.

Context and lease are revalidated before each batch and protected writer
boundary. Executor-reported or provider-observed scope/generation/path change
blocks admission, drains active work, retains the old occurrence only for safe
shutdown, and requests a real restart. The regression exercises a binding
change while inspection is blocked and proves one executor creation, one
restart, and no stale publication or in-process replacement occurrence.

### 26. Repair `stopAndDrain()` lifecycle

The controller and executor stop new admission synchronously and await the
active source observation, mutation writer, post-install object-record terminal
boundary, and Ball/lease release. Occurrence/binding checks suppress stale
completion. Normal repair-requested restarts pass through the same drain
boundary. Tests cover pending inspection, pending writer, stale evidence,
binding change, source-access loss, terminal coverage, and Ball release.

### 27. Progress and UI semantics

Presentation exposes only current factual phases and aggregate counts:

- required payloads;
- covered;
- need attention;
- available from Messages;
- source currently absent;
- source evidence unavailable;
- record-backed recovery needed;
- unsafe or conflicting evidence; and
- confirmed preservation progress `X / Y`.

The initial surface states that nothing is preserved without confirmation.
Busy, manual, retry-restart, and explicit Check Again states are typed.

### 28. Privacy boundaries

The repair UI receives aggregate snapshots only. It does not render message
text, contact names, source filenames, archive-relative paths, compatibility
keys, or resolved archive roots. Widget and architecture tests assert those
private values do not cross into presentation.

### 29. Focused shared-reader tests

PASS — 20/20 shared required-evidence/current-source reader tests. They cover
the sole SQL owner, exact required filters, deterministic bounded pagination,
all durable classifications, same-path conflicts, symbolic-link safety, exact
GUID/ROWID lookup, fresh path authority, absent/unreadable/unknown distinction,
global source failures, safe extension eligibility, and the 100-key bound.

### 30. Repair controller tests

PASS — 14/14 controller tests. They cover the exact predicate, false/unknown
and stale rejection, explicit preservation, manual-only stability, canonical
path equivalence, active stale-binding drain/restart, one-use retries, terminal
restart classes, occurrence mismatch, and pending stop/drain.

### 31. Writer and mutation tests

PASS — 23/23 new writer/executor/scope tests. They cover capability/lease
requirements, no nested tenure, current-source reproving, no overwrite,
payload-before-record ordering, commit/post-commit failures, material changes,
bounded batches, natural recomputation, terminal classifications, canonical
scope identity, and real Ball/writer drainage. The broader 198-test focused
matrix also passed existing file-store, archive-service, writable-lease,
mutation-authority, and archive-mutation-coordinator regressions.

### 32. Drain and lifecycle tests

PASS — covered within the 14 controller and 23 writer/executor tests, including
blocked source inspection, blocked real writer, synchronous stop, no hidden
batch, stale callback suppression, binding-generation churn, source loss,
coverage terminal states, Ball release before drain completion, and successful
post-drain authority reacquisition.

### 33. Prompt 59 coverage regressions

PASS — 13/13 coverage-probe tests. The Prompt 59 required universe and
truth-table behavior remain intact while the adapter now consumes the shared
reader. Stable matching observations reconstruct incomplete coverage and
changing material evidence fails to `UNKNOWN`.

### 34. Data Update regressions

PASS — 11/11 Data Update controller, executor-provider, process-restarter, and
screen tests. Its typed tenure and real restart behavior are unchanged.

### 35. Source Access Repair regressions

PASS — 7/7 Source Access Repair controller/screen tests. Its fresh Fair-Witness
retest and `UNKNOWN` exit remain unchanged.

### 36. Stage One Operating regressions

PASS — 7/7 Operating Session controller/application tests. Neutral-shell
admission and the singular top-level router remain intact.

### 37. Architecture result

PASS — complete `test/architecture` run: 587 passed, 0 skipped, 0 failed.
The independently repeated conformance subset also passed 419/419. New
tripwires enforce the singular required-set reader, callback-local writer,
no direct coordinator filesystem access, no nested Ball, privacy boundary, and
exact four-category AppCzar census.

### 38. Analyzer result

`flutter analyze` found no repair-code error or warning. It exited 1 only for
the same two pre-existing informational diagnostics in vendored code:

- `packages/macos_ui_patched/lib/macos_ui.dart:15:9` —
  `unnecessary_library_name`;
- `packages/macos_ui_patched/lib/src/layout/tab_view/tab_view.dart:29:5` —
  `unintended_html_in_doc_comment`.

### 39. Full Flutter-suite result

PASS — final-source deterministic suite: 2,946 passed, 1 intentionally skipped,
0 failed; exit status 0. The skip is the existing synthetic archive-import
memory worker that directs use of its separate harness.

### 40. Diff, format, and generated hygiene

- `git diff --check`: clean;
- Dart formatting: 36 affected files checked, 0 changes;
- final `build_runner`: successful, 0 outputs written;
- generated Riverpod files are present and consistent;
- no unexpected generated tracked changes appeared;
- index: empty.

Release metadata is included at version `0.2.135+153` with the corresponding
`CHANGELOG.md` entry.

### 41. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The repeated complete audit was performed after the provider-driven binding
change lifecycle correction and found the required one-way authority,
preservation ordering, currentness, lifecycle, privacy, and worktree-isolation
contracts satisfied.

### 42. BLOCKER findings

`BLOCKER: 0`

The one earlier stale-binding restart-boundary finding was corrected and closed
by the repeated audit.

### 43. SHOULD FIX findings

`SHOULD FIX: 0`

### 44. Exact repair build identity, path, and hashes

The successfully built, unlaunched artifact is:

`/private/tmp/messagelens-appczar-attachment-archive-repair/build/macos/Build/Products/Debug/MessageLens Development.app`

- product: `MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- version/build: `0.2.135 (153)`;
- configuration: macOS Debug;
- bundle signature: ad hoc, no TeamIdentifier;
- executable SHA-256:
  `18d20324ef35fdc345d607654355cf777325fcc645575d120fcf09e7e1de5a7a`;
- `Contents/Frameworks/App.framework/App` SHA-256:
  `19111b3f22e10a222ff7f32f82a0843d1e0610fe880eedc5bb07b2296f2f6eb6`.

The build completed successfully with existing dependency/Xcode warnings. The
bundle was not opened or executed.

### 45. Repair-worktree Git, index, and submodule state

- worktree:
  `/private/tmp/messagelens-appczar-attachment-archive-repair`;
- branch: `feature/appczar-attachment-archive-repair`;
- HEAD: `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- tracked modified paths: 12;
- untracked implementation/test/generated paths before this response: 26;
- Response 63 adds one intended untracked documentation path;
- staged paths: 0;
- no commit, push, merge, rebase, or stash was performed;
- shared submodule pointer/HEAD:
  `95326f515ef4719f155ce6e223990398daad6311`;
- shared submodule worktree: clean.

All repair implementation, tests, generated files, metadata, and this response
remain unstaged for human review.

### 46. Primary Prompt 60 final integrity proof

The primary tree was independently rechecked after implementation, full tests,
and the repair build:

- branch remains `fix/onboarding-import-stuck-state`;
- HEAD/upstream remain
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- ahead/behind remains `0/0`;
- index remains empty;
- tracked modified paths remain exactly 18;
- tracked binary diff SHA-256 remains
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- all 18 tracked Prompt 60 file hashes match the external manifest;
- all 14 new Stage Two file hashes match the external manifest;
- complete porcelain remains 82 entries with SHA-256
  `56cb2f53ea424c1e982504d6e32d22da67258f1c27c6d7a8cc2245157ec1d2ec`;
- shared submodule pointer/HEAD remain
  `95326f515ef4719f155ce6e223990398daad6311` and its worktree is clean.

The primary Operating Stage Two worktree therefore remains byte-for-byte
identical to the Prompt 63 baseline.

### 47. Readiness for human Attachment Archive Repair qualification

The exact fingerprinted development artifact is ready for a separate human
qualification prompt. That future step must explicitly authorize real archive
mutation and should first observe the freshly recomputed repair partition and
current source-available count. Prompt 63 itself did not launch the app, access
either real archive, access a real MessageLens database, or authorize/preserve
any item from the real deficit.

ATTACHMENT ARCHIVE REPAIR IMPLEMENTED: YES

REPAIR USES ONE SHARED REQUIRED-ATTACHMENT DEFINITION: YES

REPAIR AUTOMATICALLY MUTATES ONLY CURRENTLY PROVEN SOURCE-AVAILABLE ITEMS: YES

REPAIR USES HISTORICAL OPERATION SUCCESS/FAILURE STATE: NO

PRIMARY OPERATING-STAGE-TWO WORKTREE REMAINS BYTE-FOR-BYTE INTACT: YES

READY FOR HUMAN ATTACHMENT ARCHIVE REPAIR QUALIFICATION: YES
