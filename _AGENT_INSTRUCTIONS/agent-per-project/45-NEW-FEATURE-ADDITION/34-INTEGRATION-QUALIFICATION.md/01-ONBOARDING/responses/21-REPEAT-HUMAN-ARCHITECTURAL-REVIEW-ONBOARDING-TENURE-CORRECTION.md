# MessageLens Feature 34 / Feature 35
## Response 21 — Repeated Human Architectural Review of Onboarding Tenure Correction

Date: 2026-09-27

## Executive verdict

Prompt 20 fixed the two specific outer-level defects found by Prompt 19:

- source-failure completion is now followed by an exact capability/resource
  recheck before the graph-failure read starts; and
- the four critical Journey tests now use the real aggregate Environment
  provider and observe real `maintenanceInProgress` feedback while the Ball is
  live.

The correction is nevertheless not safe to checkpoint. The repeated source
trace found two checkpoint-blocking gaps beneath and across those corrected
outer boundaries:

1. `_readMaterialOnboardingEvidence` brackets the Future supplied to it, but
   some supplied Futures contain further awaits followed by protected overlay
   reads or writes. Authority can become stale during an inner await and the
   protected follow-up operation can start before the helper's post-Future
   check. The production failure store and attachment-location provider both
   have this shape. The new tests and AST rule inspect only the outer fake/Future
   boundary and therefore remain green while this sequence is possible.
2. persisted source/graph failure evidence is acquired first and retained
   across the later attachment-location and Contacts awaits. It is not reread
   or protected by a revision/consistency check at the final boundary, despite
   directly driving failure and reset classification. The returned report is
   therefore not mechanically proven current after the final material await.

The Journey command semantics, real feedback-loop fixture, typed Feature 35
authority conjunction, shared synchronous evaluator, and persistence/restart
behavior remain sound. No implementation or test file was modified by this
review.

## 1. Baseline/preservation verdict — NO ISSUE

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`
- Index: empty
- Accumulated tracked delta: 48 modified / 2 deleted
- Shared instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check`: PASS

The Prompt 20 baseline manifest exists at:

`/private/tmp/messagelens-onboarding-prompt20-baseline.Mipyuy/MANIFEST.json`

Its SHA-256 is exactly:

`6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`

The Prompt 20 audit found exactly the four authorized implementation/test
paths, the Prompt 20 response, and the current Prompt 21 input. It labels the
Prompt 21 input “unexpected” only because the Prompt 20 allow-list necessarily
predates this review prompt. No unrelated baseline byte changed and no baseline
untracked file is missing.

The earlier preservation hashes also still match:

- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`;
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`;
- Feature 35 collision backup:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`;
- Prompt 18 baseline:
  `0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`.

## 2. Material-await graph verdict — BLOCKER

The admitted function has four visible material evidence awaits in this order:

1. source-import failure entry;
2. graph-projection failure entry;
3. attachment-location resolution; and
4. Contacts resolution.

At this visible level Prompt 20 now has the intended sequence:

```text
admission current
-> invoke one material Future
-> await Future completion
-> revalidate admission
-> only then invoke the next visible material Future
```

The complete production await graph is deeper, however:

- `OverlayOnboardingFailureStorage.loadSourceImportFailureEntry()` awaits the
  overlay database and then awaits `readOverlaySetting`.
- each graph-failure key read has the same two-stage shape, and a null current
  key can be followed by a separately awaited historical-key read.
- `AttachmentArchiveLocation.build()` awaits the settings-store provider,
  controller loading, and event-subscription synchronization.
- `AttachmentArchiveLocationController.load()` awaits the overlay setting,
  custom bookmark resolution, and, when bookmark metadata is refreshed, an
  overlay-setting write.
- Contacts resolution is also an internally asynchronous provider operation,
  although this review did not find an equivalent protected derived-store
  follow-up in that path.

The admission callback is not available inside those implementations. A
concrete prohibited sequence is therefore possible:

```text
outer admission passes
-> failure store starts and awaits overlayDatabaseProvider/_overlayDb
-> capability is released or current resource policy becomes stronger
-> overlay database Future completes
-> readOverlaySetting starts under stale/denied authority
-> supplied Future finally returns
-> outer post-await admission rejects
```

The caller receives no report, but protected work has already occurred after
authority became stale. Attachment-location construction has the same class of
gap and can additionally perform a refreshed-bookmark settings write before
the outer recheck.

## 3. `_readMaterialOnboardingEvidence` verdict — BLOCKER

The helper itself has several correct properties:

- it calls `requireCurrentAdmission` immediately before invoking `read`;
- it calls the same admission callback immediately after the one visible
  await;
- a throwing `read` does not proceed to another outer read;
- the next outer protected read cannot start if the post-await check fails; and
- every visible admitted-path material await is routed through the helper.

The helper does not, and with its current generic Future interface cannot,
prove that the supplied operation is one indivisible protected read. It only
brackets the completion of the whole Future. Protected work performed after an
inner suspension and before that Future returns is invisible to it.

The requirement that the supplied read contain no hidden unguarded protected
follow-up work is therefore false for the current production callees. The
helper is not a complete tenure boundary.

## 4. Failure-store fail-closed verdict — BLOCKER

Prompt 19's exact outer sequence has been corrected: after the source-failure
Future returns, the helper revalidates capability and both resources, so the
graph-failure method cannot start when that revalidation fails. The graph read
is also separately wrapped.

The full failure-store sequence is still not fail closed:

- source failure can await `_overlayDb` and then begin its protected setting
  read without a renewed check;
- one graph key can do the same; and
- a null primary graph key can be followed by the historical key's overlay
  acquisition/read with no admission checkpoint between those protected
  stages.

Thus Prompt 20 prevents the next *store method* from starting, but it does not
prevent the current store method's later protected operation from starting.
That distinction is material under the governing invariant.

## 5. Prerequisite-freshness verdict — BLOCKER

Prompt 20 correctly moved the following reads after all four visible material
awaits:

- FDA;
- messages source path;
- canonical data root;
- maintenance;
- development overrides;
- graph-build state;
- live-update state; and
- probe-reader identity.

It also takes the settled Contacts and attachment-location values again when
constructing `_OnboardingEnvironmentInputs`.

Persisted source/graph failure evidence is different. It is read first, stored
in `failureEvidence`, retained across attachment and Contacts resolution, and
passed unchanged to the evaluator. Those entries drive failure state,
recorded-at facts, and `shouldResetAppDatabasesBeforeImport`. The failure-store
interface exposes ambient save/clear operations and supplies no revision token.
There is no final reread or consistency proof.

Consequently, a failure entry changed during either later material await can
produce a report whose reset-driving facts predate the last await. Exact
capability/resource revalidation does not make that retained evidence current.

## 6. Shared-evaluator verdict — NO ISSUE

There is still one `_OnboardingEnvironmentInputs` model and one
`_OnboardingEnvironmentEvaluator.evaluate()` policy for ordinary and admitted
reports. The evaluator is synchronous and contains no await. No second
readiness/reset/reconciliation policy appeared in Journey.

The blockers are in asynchronous evidence acquisition and consistency before
evaluator entry, not in evaluator duplication.

## 7. Capability/resource-proof verdict — NO ISSUE

`requireCurrentAdmission` independently proves all three required conjuncts:

- exact `ArchiveMutationCapability.requireOperation(expectedOperation)`;
- current-caller conversation-graph connection admission; and
- current-caller persistent archive-store admission.

No diagnostic Boolean substitutes for capability, no capability substitutes
for resource policy, and an `unrestricted` resource result does not substitute
for exact ownership. The defect is the placement/reach of these correct proofs,
not a collapse of proof types.

## 8. Zero-post-withdrawal-probe test verdict — BLOCKER

The two deterministic tests do prove that, after the gated source method
returns under withdrawn capability or stronger resource denial:

- the graph-failure *method* is not called; and
- the evaluator's recording database probes remain at zero.

Their `_GatedFailureStore.loadSourceImportFailureEntry()` only signals, awaits
`releaseLoad`, and returns `null`. It has no protected setting operation after
that internal await. `protectedProbeCount` records evaluator probes, not
production `OverlayOnboardingFailureStorage.readOverlaySetting` calls or
attachment-location settings reads/writes.

The assertions therefore correspond to a fake layer above the unsafe
production points. They can remain zero while production performs the hidden
post-suspension protected work described in sections 2–4. They prove eventual
rejection and outer sequencing, not zero protected work after withdrawal.

## 9. Prerequisite-change-during-await test verdict — NO ISSUE for the tested claims

The Contacts test suspends inside the failure-store Future, changes the same
mutable source used by the overridden `futureGetFolderAggregateProvider`,
invalidates that provider, then releases the barrier. The admitted reader
resolves and rereads that provider and returns the new Contacts blocker.

The FDA test changes the same mutable source read by the overridden
`onboardingFullDiskAccessProvider`, invalidates that provider during the
barrier, and receives the new permission blocker after release.

Those two tests are deterministic and do not merely change an unrelated fake.
They do not cover the stale failure-evidence gap in section 5, so their success
does not make the complete-current-facts contract pass.

## 10. Retained Ball 1 admitted-reader verdict — NO ISSUE

The integration proof captures Ball 1's callback-local capability and Zone,
releases Ball 1, acquires Ball 2, and attempts the admitted Environment read
from the retained Ball 1 context. The read fails at its first exact admission
check before the recording probe layer is reached. Ball 2 owner identity,
operation, and hold count remain unchanged.

The rejection is caused by stale Ball 1 tenure, not by an unrelated
prerequisite. This is an Onboarding-seam proof in addition to the generic
Feature 35 registry proof.

## 11. Real global-feedback fixture verdict — NO ISSUE

With `useRealGlobalEnvironmentFeedback: true`, `_JourneyFixture.create` omits
the `onboardingEnvironmentReportProvider` override. It supplies deterministic
underlying FDA/path/probe/Contacts/attachment/failure evidence, but uses the
real `ExclusiveAuthorityRegistry`, real `ArchiveMutationCoordinator`, real
aggregate Environment provider, and real Journey listener.

The resulting path is genuinely:

```text
real Ball acquisition
-> real coordinator isLocked
-> real aggregate Environment maintenanceInProgress
-> Journey listener
-> _latestReport
```

No maintenance report is injected directly into Journey in that fixture mode.

## 12. Initial-import real-loop verdict — NO ISSUE, subject to admitted-reader blockers

The test holds controller acquisition inside the capability callback, waits for
the real global maintenance report while the Ball is live, drains listener
microtasks, verifies Journey retains the authorized Episode, then releases the
controller gate. The graph build runs once only after the fresh admitted
initial-import predicate permits `begin`.

## 13. Reimport real-loop verdict — NO ISSUE, subject to admitted-reader blockers

The reimport test observes real aggregate maintenance before releasing its
controller gate. Journey retains the authorized Episode and the reset service
runs exactly once after the admitted complete-`ready` predicate permits the
reimport boundary.

## 14. Continuation real-loop verdict — NO ISSUE, subject to admitted-reader blockers

Continue Setup observes real aggregate maintenance while the Ball is live,
retains the exact interrupted Episode and UUID, and reaches `resume` only after
the admitted reconciliation predicate passes. It remains an explicit human
action; no automatic resume path was introduced.

## 15. Automatic-recovery real-loop verdict — NO ISSUE, subject to admitted-reader blockers

Automatic recovery observes real aggregate maintenance while controller
acquisition is held, then reaches its reset side effect exactly once after the
admitted reset-required predicates. The production path still performs a
second admitted read immediately before `resetDerivedData`.

## 16. Negative-race isolation verdict — NO ISSUE

The production-realistic mode is used for the reviewed hostile paths. Source
inspection confirms distinct barriers and asserted outcomes for:

- foreign Ball denial;
- FDA withdrawal;
- Contacts withdrawal;
- initial-import supersession;
- reimport supersession;
- continuation supersession;
- automatic-reset withdrawal before `begin`;
- automatic-reset withdrawal before the reset side effect;
- wrong/stale capability; and
- retained Ball 1 while Ball 2 is live.

The aggregate maintenance report is deliberately retained during an active
command and does not itself supply the negative result. The admitted report or
exact authority check supplies each intended denial.

## 17. Admitted-await architecture verdict — SHOULD FIX

The analyzer rule is AST-based, but it checks only the direct structure in
`readAdmittedOnboardingEnvironmentEvidence`,
`_readPersistedFailureEvidence`, and
`_readMaterialOnboardingEvidence`:

- three direct admitted-function awaits;
- two direct failure-helper awaits;
- one await bracketed by two admission calls in the material helper; and
- no await in the synchronous evaluator.

It does not traverse or classify the implementations invoked by the supplied
closures. In particular, it does not inspect
`OverlayOnboardingFailureStorage` or the attachment-location
provider/controller. The concrete hidden protected awaits already present in
those callees pass architecture validation.

Therefore the rule does not establish that all material async reads are
classified, and a new protected follow-up await inside a supplied Future would
not fail the architecture suite.

## 18. Command-boundary architecture verdict — SHOULD FIX

The AST test correctly proves four `runWithCapability` invocations, excludes a
direct capability-free coordinator `.run` in those methods, and currently
finds no await between each selected semantic `if` and the last named mutation.

Its adjacency helper selects the nearest preceding `IfStatement` whose source
text merely contains the predicate name. It does not prove that the condition
rejects the unsafe branch, dominates the mutation, or contains the complete
semantic/capability/binding conjunction. An earlier real check could be moved
across an await while a harmless nearby `if (_reportAllows...(...)) {}` keeps
the rule green.

Current production control flow is correct; the finding is a concrete
enforcement evasion, not a production command regression.

## 19. Test-realism architecture verdict — SHOULD FIX

The current fixture and four critical tests are production-realistic. The
architecture rule, however, only inspects the body of the named test group for:

- four fixture calls with the Boolean flag set to `true`;
- four maintenance waits;
- no local `overrideWith`; and
- no test-file class extending the two authority types.

It does not inspect `_JourneyFixture.create` to prove that the flag actually
omits the global Environment override, nor does it prohibit registry/coordinator
provider replacement in that helper. The helper could ignore the flag or add
one of those overrides and the architecture rule would remain green while the
critical tests continued to claim the real loop.

## 20. Semantic-root census verdict — NO ISSUE

`_sourceConsumesJourneySemantics` now includes `OnboardingStatus`. The virtual
`OnboardingStatus`-only production source is discovered through the same
`_productionOnboardingSemanticConsumerPaths` helper used by the repository
audit. The omission identified by Prompt 19 is mechanically closed.

## 21. Raw graph evidence census verdict — SHOULD FIX

The primary evidence set now includes both the raw conversation-graph
controller and its feature-level barrel. The virtual mutation case reaches and
detects both through the same dependency traversal primitive.

The real repository audit still has a traversal hole: `shellPath` is both an
explicit production semantic root and a member of its `trustedBoundaries` set.
`_transitiveLocalDependencies` stops before reading dependencies of any
`stopAt` node, including the root itself. Consequently the real shell audit
does not traverse a wrapper imported by the shell. The separate virtual shell
case uses a different stop set containing only the coordinator, so it does not
exercise the real policy configuration. Direct shell substring/count checks
also cannot detect a wrapper side door.

A shell-imported wrapper reaching the raw graph barrel/controller can therefore
evade the actual repository census. The new evidence paths are correct; the
real traversal boundary is not yet complete.

## 22. Prompt 18 production-semantics regression verdict — NO ISSUE

Prompt 20 did not modify
`onboarding_journey_coordinator_provider.dart`. The previously accepted command
ordering remains:

```text
exact positive global predicate
-> runWithCapability
-> fresh admitted report
-> exact late command-specific predicate and current binding/capability
-> immediate begin/resume/reset boundary with no await
```

Maintenance cannot manufacture Normal Application, active command meaning is
retained while the global aggregate sees self-maintenance, and interrupted
setup is not automatically resumed.

The four real-loop tests would catch a regression to aggregate `_latestReport`
at the late boundary: controller acquisition is held until the real maintenance
report has reached Journey and microtasks are drained. A pre-Prompt-18 final
aggregate predicate would therefore deny before the gate is released.

## 23. Accumulated-delta/reuse/dead-code verdict — NO ISSUE with OPTIONAL notes

No duplicate Journey writer, second readiness evaluator, ambient owner-relative
Environment cache, obsolete pre-Feature-35 maintenance bypass, or duplicate
reset/reconciliation policy was found. The retained reconciliation specialist
is used and the retired provider files remain deleted.

The Prompt 20 comment stating that stronger resource policy “is checked again
after evaluation” is inaccurate: the final check is immediately before the
synchronous evaluator. This does not change runtime behavior because evaluation
does not suspend; it is an OPTIONAL documentation correction.

Previously recorded non-blocking cleanup remains outside this correction:

- the unused `onboardingJourneyAllowsCommandedTransition` helper;
- the unused `_runAutomaticRecovery` `report` parameter; and
- stale canonical Environment Readiness wording concerning the former snapshot
  presentation relationship.

## 24. Persistence/migration/restart verdict — NO ISSUE

- Database schema migration: none.
- Persisted operation-snapshot migration: none.
- Snapshot format: remains version 1; existing records remain readable.
- Startup reconciliation: unchanged by Prompt 20.
- Ordinary interrupted import: remains explicit Continue Setup.
- Automatic resume: absent.
- Serialized capability/tenure: absent.
- Presentation changes in Prompt 20: none.

## 25. Concrete BLOCKER findings

### BLOCKER 1 — Outer Future bracketing permits protected work after inner suspension

**Production paths:**

- `onboarding_environment_report_provider.dart`:
  `_readMaterialOnboardingEvidence`;
- `overlay_onboarding_failure_storage.dart`:
  `loadSourceImportFailureEntry`, `loadGraphProjectionFailureEntry`, and
  `_loadGraphProjectionFailureFromKey`;
- `attachment_archive_location_provider.dart`:
  `AttachmentArchiveLocation.build`; and
- `attachment_archive_location_controller.dart`:
  `load`, `_resolveCustom`, and `_availableCustomState`.

**Cause:** the admission helper brackets a composite Future, while the Future
can suspend and later begin protected overlay reads/writes without another
capability/resource proof.

**Impact:** protected work can occur after the exact Ball is released or a
stronger current resource policy denies that work; rejection happens only when
the composite Future returns.

**Required correction:** place exact capability and resource revalidation at
each protected I/O boundary, or expose a bounded evidence operation whose
implementation accepts and applies the proof checkpoint before every protected
follow-up. Do not turn the evidence store/provider into a second authority.

**Required proof:** deterministic production-shaped fakes must suspend before
the concrete protected setting read/write, withdraw capability or impose the
stronger resource policy, and assert that the protected operation itself has a
zero call count.

### BLOCKER 2 — Reset-driving failure evidence is not current at the final boundary

**Production path:**
`readAdmittedOnboardingEnvironmentEvidence` and
`_OnboardingEnvironmentInputs.failureEvidence`.

**Cause:** source/graph failure entries are captured before later attachment and
Contacts awaits, with no revision token, retry, or final reread.

**Impact:** the admitted report can return obsolete failure/reset facts even
though capability/resource authority is current and the other prerequisite
providers were read at the final boundary.

**Required correction:** establish one mechanically coherent currentness
boundary across all mutable asynchronous evidence, including persisted failure
entries. A revision/retry protocol or equivalently bounded snapshot is needed;
merely moving one async read to the end makes the earlier async values stale by
the same reasoning.

**Required proof:** mutate source or graph failure evidence while a later
material await is suspended and prove the returned report either reflects the
new revision or rejects/retries rather than returning mixed-revision facts.

## 26. Concrete SHOULD FIX findings

1. Extend admitted-await AST enforcement through the actual supplied evidence
   implementations or enforce an approved atomic/proof-aware interface. The
   current direct-await count cannot see BLOCKER 1.
2. Make command-boundary enforcement prove a rejecting/dominating semantic
   guard and its required conjunction, not merely the nearest predicate-bearing
   `if` plus textual await adjacency.
3. Make the critical-test realism rule inspect `_JourneyFixture.create` and
   prove the real-mode branch omits global Environment and authority-provider
   overrides.
4. Remove the real-census `stopAt` root hole (especially `shellPath`) and make
   virtual mutation tests use the same trusted-boundary policy as the real
   repository audit.

## 27. OPTIONAL findings

- Correct the admitted-reader comment that says resource admission is checked
  again “after evaluation”; the check is immediately before synchronous
  evaluation.
- Retain the previously recorded optional cleanup items in section 23 for a
  later, separately scoped cleanup.

## 28. Narrow tests rerun

None.

The unresolved questions are established directly by production control flow:
the concrete inner awaits, subsequent protected setting operations, retained
failure-evidence object, and architecture visitors are visible in source. The
existing green tests use a fake above the unsafe boundary, so rerunning them
would not resolve the findings. The full suite was not rerun for ceremony.

Prompt 20's reported validation totals remain historical evidence, but they do
not disprove these source-level gaps.

## 29. Exact Git status

After adding this required response only:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- tracked worktree: 48 modified / 2 deleted;
- index: empty;
- staged paths: 0;
- commits created: 0;
- pushes: 0;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- physical untracked files: 88, consisting of the prior 87 plus this response.

No production, test, generated, persistence, or application documentation file
changed during Prompt 21.

## 30. Preservation-artifact verification

- Prompt 20 baseline manifest: present and exact hash match.
- Prompt 18 baseline manifest: present and exact hash match.
- reconstruction manifest: exact hash match.
- pre-merge manifest: exact hash match.
- Feature 35 collision-backup manifest: exact hash match.
- missing pre-existing untracked files: none.
- unrelated baseline byte changes: none.
- shared submodule changes: none.
- MessageLens Development launched: no.
- real databases or attachment archives accessed: no.

All external preservation artifacts remain untouched.

## 31. Checkpoint recommendation

Do not checkpoint the Onboarding tenure correction yet.

Close both BLOCKER findings at the concrete protected-I/O and mixed-revision
boundaries, strengthen the four mechanical enforcement gaps, and repeat this
human architectural review before checkpoint.

`REPEATED ONBOARDING TENURE CORRECTION HUMAN REVIEW: FAIL`
