# MessageLens Feature 34
## Response 67 — Bound Attachment Archive Repair Human Authorization

Date: 2026-10-05

Prompt 67 is complete. Attachment Archive Repair now presents one exact,
memory-only repair plan of at most 75 attachment identities. One click can
admit only that displayed plan, and a fresh assessment plus a new click is
required before any later batch. Automated validation passed. Human live
qualification remains pending because Prompt 66 correctly stopped before
launch or mutation.

No MessageLens app was launched. Neither real attachment archive nor any real
database was accessed or modified.

## 1. Baseline verification

- Primary worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`
- Branch: `fix/onboarding-import-stuck-state`
- Starting HEAD/upstream:
  `90457abeacf8c1083a255a3ec9935972f30983b3`
- Starting ahead/behind: `0/0`
- Tracked worktree and index: clean
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- Feature 34 worktrees: exactly one; the Feature 35, `main`, and Gradle
  worktrees were unrelated and untouched.
- Starting untracked state: 28 collapsed entries / 47 individual files,
  consisting of the prior 25 known unrelated entries plus Prompt 66,
  Response 66, and Prompt 67.
- External baseline manifest:
  `/private/tmp/messagelens-prompt67-baseline-20261005T135934Z.txt`
- Manifest SHA-256:
  `ff90225c600d0f7a8d7309ad5de87278a36b3ed77019f965e9256e5f70a39275`

## 2. Exact old authorization-flow audit

1. The executor classified the complete fresh required-attachment partition;
   `availableFromMessagesCount` flowed through its snapshot, controller, and
   screen.
2. The old zero-argument `startPreservation()` captured the active occurrence
   binding but no displayed exact-key set, then called `preserveAvailable()`.
3. `preserveAvailable()` performed another inspection and treated the entire
   current source-available population as authorized.
4. `authorizedTotal` was
   `initial.snapshot!.availableFromMessagesCount`.
5. A nullable required-evidence cursor began at `null`; each page was bounded
   to 75 and advanced through `page.nextCursor`.
6. The `while (!_stopRequested && processed < authorizedTotal)` loop admitted
   each later page and writer tenure after the preceding page settled, without
   another human action.
7. Before confirmation, current source observations already provided the
   exact `(message GUID, live attachment ROWID)` compatibility key, source
   path, MIME type, current regular-file/readability result, byte size, and
   modification time. Required evidence also supplied its material
   fingerprint. The old flow discarded the exact proposed set and did not
   aggregate its bytes for presentation.
8. The first 75 source-available identities could therefore be fully and
   deterministically enumerated before the user clicked.

## 3. Chosen RepairBatchPlan model

The feature-private `_AttachmentArchiveRepairBatchPlan` is immutable,
memory-only, and owned by one executor occurrence. It binds the occurrence and
assessment generation, archive scope/generation/resolved-path binding, full
required-evidence fingerprint, exact ordered required/source evidence, and a
privacy-safe visible authorization handle. The handle contains only a unique
plan identity, item count, and exact aggregate bytes; it is not mutation
authority and exposes no attachment key or path.

The screen passes the exact authorization handle it rendered. The controller
requires that handle to be identical to its current handle, and the executor
requires it to be identical to the one unconsumed pending plan. This closes the
stale-widget interval in which a control displaying plan A could otherwise
have asked the controller to authorize a newer plan B.

## 4. Exact item cap

`appCzarAttachmentArchiveRepairMaximumAuthorizedItems` is 75. Plan derivation
retains only the first 75 source-available items in deterministic evidence
order. A smaller population produces a smaller plan. Item 76 is never included
under the first confirmation.

## 5. Byte-scope evidence and design

Every available source observation carries the freshly observed regular-file
size. The plan sums those exact sizes and displays both a human-readable value
and the raw byte count. If any planned item lacks a trustworthy non-negative
size, the UI literally displays `Total size could not be established` and
`hasAutomaticWork` fails closed, so no mutation action is exposed. No byte
total is fabricated.

## 6. Deterministic exact-key selection

The required-evidence reader's stable page/cursor order is retained across the
complete partition. The plan takes the first 75 observations whose exact
required identity is `noDurableRecord` and whose current source condition is
`available`. Their order and keys are stored unmodifiable and are the only
sources passed to the mutation batch executor.

## 7. Stale-plan invalidation rules

Before mutation, the displayed plan is synchronously consumed and a fresh
partition is derived. Mutation is refused unless the fresh plan has the same
occurrence/archive binding, full required-evidence fingerprint, ordered exact
keys and required-item material fingerprints, source paths, MIME types, sizes,
and modification times. Archive generation/path change, changed required
membership, changed source material, UNKNOWN/unreadable evidence, a newly
arrived required item, a stale UI handle, or any other mismatch publishes
fresh evidence without mutation and requires new consent.

## 8. Exact executor-loop change

The old `authorizedTotal`, preservation cursor, and
`processed < authorizedTotal` page loop were deleted. One accepted
authorization now performs one fresh revalidation and exactly one call to
`preserveNoRecordBatch()` with the already fixed `authorizedPlan.sources`.
After that one batch settles, the executor stops mutation and performs a fresh
inspection.

## 9. Proof that refill or substitution is impossible

The writer receives only the unmodifiable sources from the consumed plan.
Revalidation compares the whole required universe plus every planned item's
material evidence. It does not take `up to 75` from a newly queried population.
No code path can append a new key, replace a stale key with item 76, or acquire
a second page after the mutation call. Architecture tripwires reject the old
method, total/cursor loop, durable plan state, multiple mutation calls, and
missing exact-plan enforcement.

## 10. UI copy and action change

The repair surface now shows `Next repair batch`, the exact attachment count,
and either exact aggregate source bytes or the literal unknown-size message.
The action reads `Preserve these N attachment(s)`; the ambiguous
`Preserve Available Attachments` wording is gone. Copy explicitly says one
confirmation applies only to the displayed batch and does not promise repair
completion.

## 11. First-batch behavior

One click synchronously claims single-flight and the exact rendered handle.
For 151 available items, only exact items 1–75 are admitted by the first click.
Progress is bounded to that plan's count, and item 76 remains untouched.

## 12. Fresh second-plan behavior

After the first batch settles, fresh coverage, required evidence, and source
evidence derive a new plan. Committed records naturally remove successful
items from the uncovered set. The second plan has a distinct in-memory
identity and cannot run until the user clicks its newly rendered action.

## 13. Coverage FALSE post-batch behavior

FALSE with further source-available items remains on Attachment Archive Repair
and exposes the new explicit batch plan. FALSE without automatically
repairable items remains on the factual human-action surface. Neither case
restarts or chains a coordinator.

## 14. Coverage TRUE behavior

TRUE drains the repair executor and uses the existing real process restarter
so a fresh AppCzar assessment decides the next surface.

## 15. Coverage UNKNOWN behavior

UNKNOWN drains and restarts for fresh Diagnostic Review. It is not relabeled
as FALSE and does not continue mutation in-process.

## 16. Source/archive change behavior

Any plan-defining source or archive change invalidates the plan before writer
admission. The current observation is published, no replacement item enters
the old authorization, and any new valid plan requires another click.

## 17. `stopAndDrain()` preservation

`stopAndDrain()` synchronously refuses further admission and clears the
pending in-memory plan, then awaits the active admitted batch. Existing
writer/Ball drain behavior is unchanged. No consent survives executor or
process replacement, and stale completion still cannot publish into a
replacement occurrence.

## 18. Mutation-authority preservation

The authority chain remains:

```text
Attachment Archive Repair
-> exact confirmed in-memory plan
-> existing ArchiveMutationCoordinator
-> exact repair operation
-> callback-local capability
-> generation-bound writable-root lease
-> admitted writer
```

No controller/UI filesystem write, nested Ball, retained capability, or broad
archive authority was added. Payload-before-record durability is unchanged.

## 19. Focused batch-plan tests

PASS. The executor-focused suite passed 17 tests covering 151 items as three
separate confirmations (`75 + 75 + 1`), fewer-than-cap behavior, exact order,
item 76 isolation, fresh partitions, stale source evidence, new required
items, changed archive generation, no refill, unknown byte scope, stopped
execution, and terminal observation mappings.

## 20. Repair controller/executor/writer tests

PASS. The consolidated post-correction repair executor, controller, admitted
writer, presentation, and repair-architecture run passed 59 tests. Controller
coverage includes exact authorization forwarding, old-plan rejection after a
new plan is published, unknown-byte refusal, single-flight duplicate clicks,
fresh next-plan consent, and TRUE/UNKNOWN restart behavior. Writer tests retain
exact capability, lease, post-commit verification, and drain assertions.

## 21. Presentation tests

PASS. Widget tests prove exact count and byte rendering, singular/plural action
copy, literal unknown size with no mutation action, exact rendered-handle
forwarding, and non-disclosure of private keys, paths, message identifiers, or
contact data.

## 22. Lifecycle and drain tests

PASS. Focused and shared lifecycle tests prove one-use admission,
double-click exclusion, pending-plan destruction, admitted writer/Ball drain,
lease release, and no consent across executor replacement or restart.

## 23. Shared evidence and coverage regressions

PASS. The combined shared evidence-reader, Prompt 59 coverage,
mutation-authority/lease, and startup regressions passed 71 tests. The singular
required-attachment evidence definition and coverage semantics are unchanged.

## 24. Operating Stage Two regression result

PASS. The Operating regression directory passed as part of the 65-test
combined Operating, Data Update, and Source Access Repair run and again in the
post-correction full suite. Operating remains an admitted neutral session and
retains its drain model.

## 25. Data Update regression result

PASS. Data Update passed in the same 65-test regression run and the full suite.
Its coordinator ownership, restart boundary, and currentness semantics are
unchanged.

## 26. Source Access Repair regression result

PASS. Source Access Repair passed in the same 65-test regression run and the
full suite. TRUE/FALSE/UNKNOWN Fair-Witness routing remains unchanged.

## 27. Architecture result

PASS. The dedicated architecture suite passed 367 tests. The repair-specific
architecture suite was then rerun after the final displayed-plan race fix
inside the 59-test focused run, and all architecture tests passed again in the
post-fix full suite. The execution census remains Data Update, Source Access
Repair, Attachment Archive Repair, and the admitted Operating session.

## 28. Analyzer result

PASS. `flutter analyze` reported `No issues found!` after the final production,
test, and generated-code changes.

## 29. Full Flutter-suite result

PASS. The complete deterministic suite was run again after the final
displayed-authorization correction: 3,004 tests passed, one existing test was
skipped, and there were no failures.

## 30. Diff, format, and generated hygiene

PASS. `dart format` changed none of the ten touched Dart source/test files.
`build_runner build --delete-conflicting-outputs` completed successfully and
regenerated only the expected controller provider hash. `git diff --check` and
`git diff --cached --check` were clean. The implementation checkpoint contains
exactly 13 production/generated/test/release files with 1,287 insertions and
195 deletions; its pre-stage diff SHA-256 was
`a7a629af7272e90d6e380a020d588931b2d9c2a9312eb573b722b12e45cf6a97`.

## 31. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The independent audit covered the exact tracked delta against the canonical
guardrails, Project Conformance standard, architecture constitution, database
rules, Riverpod/generated-code rules, release metadata, tests, and attachment
archive preservation invariant.

## 32. BLOCKER findings

`BLOCKER: 0`

One pre-checkpoint review initially found the stale-rendered-button consent
race. It was corrected before the final audit by passing the rendered handle
through the UI/controller boundary and requiring identity with current state;
the final audit has no blocker finding.

## 33. SHOULD FIX findings

`SHOULD FIX: 0`

The final audit also reported `OPTIONAL: 0`.

## 34. Implementation checkpoint commit

`0356c59f03625c73875ed0a1b1e5f16a43723078`

Subject: `fix(attachments): bound repair authorization to one batch`

## 35. Documentation checkpoint commit

The documentation checkpoint is the commit containing this Response 67 plus
Prompt 66, Response 66, and Prompt 67. A Git commit cannot embed its own hash
without changing that hash; the exact resulting SHA is therefore reported in
the final task handoff.

## 36. Pushed recovery anchor

The recovery anchor is the documentation checkpoint containing this response,
pushed normally to `origin/fix/onboarding-import-stuck-state`. Its exact SHA
and final `0/0` relationship are reported in the final task handoff after the
push completes.

## 37. Exact build identity, path, and hashes

The requested debug development artifact was built and was not launched.

- Bundle path:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- Product/display name: `MessageLens Development`
- Bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- Version/build: `0.2.137 (155)`
- Executable: `MessageLens Development`
- Executable SHA-256:
  `131eca2de56810191d5ae8fc98c6417a52ba284ed5ff72547f6b3329c676eda8`
- `App.framework/App` SHA-256:
  `0dfd24d6e7d5bf352982b3c609d543f073274d1d42ca7be5f33605c090b6ca2f`

The successful build emitted only existing dependency/Xcode warnings (the
`file_selector_macos` deprecated API, pod macro redefinitions, and an
unprocessed `volume_controller` privacy manifest). It produced the requested
bundle and did not launch it.

## 38. Final Git/worktree/index/submodule state

The implementation commit is clean. The only subsequent tracked delta is the
four intended Feature 34 records for the documentation checkpoint. After that
checkpoint and normal push, the expected final state is a clean tracked
worktree and index, clean shared submodule at
`95326f515ef4719f155ce6e223990398daad6311`, branch/upstream `0/0`, one Feature
34 worktree, and only the prior 25 known unrelated untracked entries (44
individual files). The final handoff records the post-push verification.

## 39. Readiness to rerun Prompt 66

YES. The exact blocker discovered by Response 66 is removed and automated
validation is complete. Prompt 66 may now perform the separately authorized
human live qualification against the bounded control.

## 40. Readiness to rerun Prompt 61

NO / NOT YET. Operating Stage Two should wait until Prompt 66 performs the
bounded live repair qualification and establishes the current real archive
coverage outcome.

ONE HUMAN CONFIRMATION AUTHORIZES AT MOST ONE BOUNDED REPAIR BATCH: YES

AUTHORIZED REPAIR BATCH CONTAINS AN EXACT FIXED KEY SET: YES

EXECUTOR CAN AUTO-CHAIN A SECOND BATCH WITHOUT NEW CONSENT: NO

STALE CONSENT CAN SUBSTITUTE NEWLY DISCOVERED ITEMS: NO

ATTACHMENT ARCHIVE REPAIR AUTOMATED VALIDATION: PASS

ATTACHMENT ARCHIVE REPAIR HUMAN LIVE QUALIFICATION: PENDING

READY TO RERUN BOUNDED REAL REPAIR PROMPT 66: YES
