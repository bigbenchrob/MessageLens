# MessageLens Feature 34 / Feature 35
## 19 — Human Architectural Review of Minimal Onboarding Tenure Correction

Date: 2026-09-27

## Executive verdict

Prompt 18 correctly changed the four protected Journey commands to typed
capability admission, preserved their distinct semantic predicates, kept the
owner-scoped Environment result out of global state, and stopped aggregate
maintenance from manufacturing Normal Application.

The implementation is not yet safe to checkpoint. Source inspection found two
checkpoint-blocking proof gaps:

1. The admitted Environment reader revalidates authority around its two outer
   dependency awaits, but its shared evaluator then performs two additional
   awaited failure-store reads. If capability or resource policy changes during
   the first of those awaits, the evaluator proceeds into its second read and
   all synchronous database probes before the final check discovers the loss of
   authority. The same input object also retains prerequisite values captured
   before those awaits. This is not a fail-closed boundary around each material
   await and does not prove that the returned facts are current at return.
2. The critical Journey fixture uses the real registry and archive coordinator,
   but overrides `onboardingEnvironmentReportProvider` with a mutable report
   source that does not watch the real coordinator lock. It therefore removes
   the production path
   `isLocked -> maintenanceInProgress -> _latestReport` that caused the defect.
   The positive command tests would not fail against the pre-Prompt-18 command
   implementation, so they do not prove the claimed self-maintenance correction
   end to end.

The architecture tripwires also remain source-string/order checks rather than
mechanical control-flow/type enforcement. They currently miss both blockers,
and the two semantic-census gaps recorded by the Prompt 13 review remain in the
accumulated architecture test.

No implementation or test file was modified by this review.

## 1. Baseline and preservation verdict — NO ISSUE

The required baseline is intact:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked delta: 48 modified and 2 deleted paths;
- Prompt 18 production/test changes: exactly the four authorized tracked paths
  plus the already-untracked authorized Journey architecture test;
- `git diff --check`: passes;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.

The Prompt 18 external baseline remains at:

`/private/tmp/messagelens-onboarding-prompt18-baseline.yd0I9Y/MANIFEST.json`

with SHA-256:

`0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`

The baseline audit found no changed or missing unrelated pre-existing untracked
file. Its only post-baseline repository additions before this response were the
expected Prompt 19 record and Prompt 18 response.

All three reconstruction/preservation audits still pass with their exact
manifest hashes:

- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`;
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`;
- Feature 35 collision backup:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`.

No unrelated byte changed after Prompt 18.

## 2. Admitted Environment evidence verdict — BLOCKER

The seam has the correct high-level shape:

- it is a plain one-shot function, not a provider-held cache;
- it accepts an exact `ArchiveMutationCapability` and typed expected
  `ArchiveMutationOperation`;
- it cannot write Journey state;
- it does not assign or publish the global Environment report;
- it is absent from the public Onboarding barrel;
- only `OnboardingJourneyCoordinator` calls it in production;
- it shares `_readOnboardingEnvironmentInputs` and
  `_OnboardingEnvironmentEvaluator` with the ordinary global provider.

However, `readAdmittedOnboardingEnvironmentEvidence` calls
`requireCurrentAdmission()` before and after attachment-location resolution,
before and after Contacts resolution, and after the evaluator returns. The
evaluator itself then awaits:

1. `loadSourceImportFailureEntry()`; and
2. `loadGraphProjectionFailureEntry()`.

There is no capability/resource revalidation between those awaits and no
revalidation before the subsequent import-ledger/graph/overlay probes.

A deterministic unsafe sequence therefore exists:

```text
current capability and resource policy pass
-> evaluator awaits source-import failure evidence
-> tenure is released, or a nested stronger archive scope denies resources
-> first await completes
-> evaluator starts the graph-failure read
-> evaluator opens/probes protected derived-store paths
-> only after all evaluation finishes does requireCurrentAdmission fail
```

The caller does not receive the report, but protected reads have already
occurred after proof became invalid. That is not fail closed.

The evaluator input object also snapshots provider facts before its internal
awaits, including FDA, Contacts aggregate evidence, attachment location,
maintenance, dev overrides, and lifecycle state. The final admission check
proves capability/resource currentness; it does not prove those input facts did
not change while the evaluator was suspended. The implementation therefore
does not establish the required complete-current-facts contract at return.

No readiness policy was duplicated into Journey, but the shared evaluator needs
an admitted-read boundary that revalidates before each later protected access
and ensures prerequisite inputs are current after its final await.

## 3. Capability/resource-proof verdict — BLOCKER

The design correctly treats capability proof and resource admission as two
conjuncts. `capability.requireOperation(expectedOperation)` is independent from
both current-caller resource checks. No `.isLocked`, owner label, occurrence,
registry diagnostic, or `unrestricted` Boolean is used as ownership proof.

The defect is temporal rather than conceptual: those two conjuncts are not
re-established after each internal evaluator await before the next protected
operation. A valid check before evaluator entry plus a valid/failed check after
evaluator exit does not authorize the operations that occurred between them.

## 4. Global Environment semantics verdict — NO ISSUE

The ordinary `onboardingEnvironmentReportProvider` remains owner-agnostic. It
continues to combine `dbMaintenanceLockProvider` with aggregate archive
coordinator `isLocked`, suppress protected derived-store inspection during
aggregate maintenance, and publish `maintenanceInProgress` for unrelated
observers.

The owner-scoped result is not assigned to `_latestReport`, written into another
provider, or cached for presentation. The global evidence revision/currentness
flow remains separate.

## 5. Initial-import verdict — NO ISSUE, conditional on BLOCKER 1

The production ordering is correct:

```text
action/token current
-> direct FDA safety check
-> exact positive global initial-import predicate
-> no intervening await
-> runWithCapability(onboardingImport)
-> controller acquisition
-> admitted Environment read
-> capability + action/token + exact initial predicate
-> immediate controller.begin(initialImport)
```

`ready`, FDA/Contacts/source withdrawal, stale action, and foreign Ball all
reject. Rejection before `begin` mints no operation UUID. The remaining defect
is the admitted reader used at the late boundary, not the initial-import
predicate or placement.

## 6. Reimport verdict — NO ISSUE, conditional on BLOCKER 1

Reimport retains its distinct requirement for complete current `ready`
evidence, with no reset requirement or external blocker. It uses
`runWithCapability(onboardingImport)` and places the exact predicate directly
before `controller.begin(reimport)`.

No generic self-maintenance Boolean replaced reimport semantics. A valid path
begins one reimport; `readyToImport` or a current blocker prevents it. The
admitted-reader proof/currentness blocker still applies.

## 7. Continuation verdict — NO ISSUE, conditional on BLOCKER 1

Continue Setup preserves and revalidates:

- action context and active command token;
- exact retained binding;
- exact operation UUID;
- prior process session;
- interrupted status;
- exact `onboardingImport` capability;
- admitted Environment evidence; and
- reconciliation/resumability semantics.

`controller.resume(operationId)` immediately follows the final conjunction.
The same UUID resumes, `ready` supersession blocks resume, and ordinary
interrupted import remains an explicit human action. No automatic resume path
was introduced.

## 8. Automatic-recovery verdict — NO ISSUE, conditional on BLOCKER 1

Both side-effect boundaries are present:

- admitted report plus exact reset-required predicate immediately before
  `begin(automaticRecovery)`;
- a second admitted report plus current binding/capability and the same exact
  reset-required predicate immediately before `resetDerivedData()`.

Starting recovery does not freeze reset need. If reset need disappears after
progress persistence, reset is skipped and the blocked operation evidence is
retained. The admitted-reader defect affects both reads but no additional
automatic-recovery policy defect was found.

## 9. Maintenance-to-Journey mapping verdict — NO ISSUE

`_journeyFromEnvironment` now maps only complete `ready` evidence to
`OnboardingNormalApplication`; maintenance falls through to Checking on cold
reconstruction. `_ingestEnvironmentReport` retains an established semantic
Episode for maintenance-only evidence and preserves the active command Episode
until its late command check resolves.

Hard external blockers are classified ahead of maintenance and the late
admitted command predicate publishes the blocker before a denied side effect.
No Maintenance Episode or presentation-side maintenance interpretation was
introduced.

## 10. Command-predicate semantic-identity verdict — NO ISSUE

The four predicates remain distinct:

- initial import requires `readyToImport`, or the explicitly accepted sparse
  local-history case;
- reimport requires `ready`;
- continuation delegates to reconciliation for the exact interrupted snapshot;
- automatic recovery requires the reset predicate.

The shared `_reportAllowsCommand` only applies a supplied predicate and maps a
rejection through Journey. It does not collapse the four policies.

## 11. Journey/presentation authority verdict — NO ISSUE

Production onboarding and Environment Readiness presentation consume Journey
state or its immutable operation projection. The operation snapshot, raw graph
state, Environment report, capability, tenure, and maintenance diagnostics do
not independently choose production Onboarding meaning.

The existing development panel remains the explicit diagnostic-only exception.
No Prompt 18 change created a new presentation side door.

## 12. Capability-lifetime verdict — NO ISSUE

Prompt 18 keeps each capability callback-local. No capability or generic tenure
is stored in Journey state, action context, operation projection, operation
snapshot, persistence, provider state, or presentation. No serialized or
unbounded retained reference was introduced.

## 13. Real-authority test-harness verdict — BLOCKER

The fixture does use the real `ExclusiveAuthorityRegistry`, real
`ArchiveMutationCoordinator`, real private Zone/capability behavior, and
Completer-controlled controller/persistence boundaries. It does not override
or subclass those authorities.

But `_JourneyFixture.create` overrides
`onboardingEnvironmentReportProvider` with:

```text
(ref) async => reports.read()
```

That override does not watch `archiveMutationCoordinatorProvider.isLocked` and
therefore cannot publish aggregate `maintenanceInProgress` when the real
coordinator acquires its Ball. The fixture exercises the capability-gated
admitted reader, but not the complete production feedback loop that Prompt 18
exists to correct.

Consequently, the positive initial-import, reimport, continuation, and
automatic-recovery tests would still pass against the pre-Prompt-18 command
implementation: its final `_latestReport` would remain the mutable fixture
report instead of becoming self-induced maintenance. The test harness does not
prove that the prior defect was removed.

## 14. Hostile-race test-quality verdict — BLOCKER

The controller-acquisition and progress-persistence races are deterministic and
do prove command-specific semantic withdrawal after those barriers. Foreign
authority denial is also exercised through the real registry.

The following claimed mechanisms are not adequately proven:

- self-owned maintenance success is not tested through the real global
  lock-to-maintenance-to-`_latestReport` path;
- the Prompt 18 Onboarding/Environment tests do not exercise retained Ball 1
  proof while Ball 2 is live through the admitted reader (Feature 35 proves the
  generic primitive, but not this integration seam);
- the reader-await tests assert only the eventual exception and do not assert
  that no later protected probe ran after capability/resource withdrawal.

Several individual assertions are useful, but the suite does not isolate all
of the exact conjuncts it claims to cover.

## 15. Environment-reader test-quality verdict — BLOCKER

The tests correctly cover:

- aggregate maintenance versus admitted complete evidence;
- no global publication of the admitted result;
- no cached pre-maintenance report reuse;
- wrong operation and outside-Zone capability;
- pre-probe resource denial; and
- eventual post-await denial.

The two post-await tests are insufficient. `_GatedFailureStore` suspends the
first failure read, then the test releases authority or installs a stronger
resource policy. It expects the returned Future to throw, but its recording
probe is not used/asserted to prove zero protected reads after withdrawal. The
current production evaluator does perform later reads/probes before throwing,
so those tests pass while the intended fail-closed invariant is false.

There is also no test changing Contacts or another snapshotted prerequisite
inside the evaluator's internal await and proving the returned report reflects
the post-await value.

## 16. Architecture-tripwire verdict — SHOULD FIX

The Prompt 18 additions are source substring/count checks, not AST/control-flow
enforcement:

- four literal `.runWithCapability<void>(` spellings are counted;
- four literal `requireCurrentAdmission();` spellings are counted without
  proving which awaits they bracket;
- semantic predicates are only required to appear textually before mutation
  calls, not with no intervening await;
- the real-authority check only prohibits an archive-coordinator override and
  therefore misses the global Environment override that removes the production
  feedback loop;
- only current exact symbol spellings are censused for the admitted seam.

These checks are materially evadable and already permit the two blockers above
while the architecture suite remains green.

The earlier accumulated semantic-census gaps also remain:

1. `_sourceConsumesJourneySemantics` does not classify an
   `OnboardingStatus`-only production consumer as a semantic root.
2. The primary `evidenceImplementationPaths` set omits the raw conversation
   graph controller/barrel even though the narrower intent-adapter evidence set
   includes them.

Those are the same concrete future-side-door SHOULD FIX findings recorded in
the Prompt 13 human review.

## 17. Accumulated-delta/reuse/dead-code verdict — SHOULD FIX

No second Journey writer, duplicate readiness evaluator, caller-relative global
cache, copied reset policy, or obsolete reconciliation provider reference was
found. The two old reconciliation provider files are deleted, and the retained
pure reconciliation specialist is used by Journey.

The accumulated architecture-test gaps in section 16 are unresolved and are
part of the checkpoint delta, so this category remains SHOULD FIX.

Optional cleanup remains outside the required correction:

- `onboardingJourneyAllowsCommandedTransition` remains unused;
- `_runAutomaticRecovery` retains an unused `report` parameter;
- previously recorded canonical Environment Readiness wording still describes
  the old operation-snapshot presentation relationship.

None is an independent current authority defect.

## 18. Persistence/migration/restart verdict — NO ISSUE

- schema migration: none;
- persisted snapshot format: still version 1;
- persisted capability/tenure: none;
- existing operation records: remain readable;
- startup reconciliation: retains its explicit one-shot adoption semantics;
- ordinary interrupted import: remains explicit Continue Setup;
- automatic resume: not introduced.

## 19. Concrete BLOCKER findings

### BLOCKER 1 — The admitted reader performs protected work after proof may be stale

- **Files/symbols:**
  `onboarding_environment_report_provider.dart`;
  `readAdmittedOnboardingEnvironmentEvidence` and
  `_OnboardingEnvironmentEvaluator.evaluate`.
- **Cause:** the evaluator contains additional awaits after the last
  intermediate `requireCurrentAdmission`, with no revalidation before its next
  failure-store access and derived-store probes.
- **Impact:** stale/released capability or newly denied resource policy can be
  detected only after unauthorized reads have already occurred; snapshotted
  prerequisite inputs can also be stale at return.
- **Required correction:** bracket every material evaluator await so no later
  protected read occurs without renewed capability/resource admission, and
  refresh or revision-check prerequisite inputs after the final await before
  returning complete evidence.
- **Required proof:** barriers must withdraw capability/resource policy and
  external prerequisite facts during evaluator-internal awaits, assert zero
  post-withdrawal protected probes, and assert the final report reflects the
  post-await prerequisite state.

### BLOCKER 2 — Journey tests remove the production self-maintenance feedback loop

- **Files/symbols:**
  `onboarding_journey_coordinator_provider_test.dart`;
  `_JourneyFixture.create` and its
  `onboardingEnvironmentReportProvider.overrideWith`.
- **Cause:** the mutable global report override ignores the real archive
  coordinator lock.
- **Impact:** the tests use real tenure/capability but do not reproduce the
  original defect, and their positive self-owned command paths would not fail
  on the pre-Prompt-18 implementation.
- **Required correction:** add a deterministic fixture/path in which the real
  coordinator lock drives the real aggregate Environment provider to
  `maintenanceInProgress` while the same command obtains admitted evidence.
- **Required proof:** each protected command must demonstrate the production
  lock-to-maintenance transition and still reach or reject its exact boundary
  solely according to fresh command prerequisites.

## 20. Concrete SHOULD FIX findings

### SHOULD FIX 1 — Prompt 18 architecture enforcement is text-order brittle

Replace or supplement literal source counts/order checks with analyzer-AST and
control-flow-aware enforcement where practical. At minimum, prove the admitted
checks bracket each actual await/probe, prove no await lies between each final
semantic conjunction and begin/resume/reset invocation, and make the test
harness rule reject a global-provider override that hides real lock
publication.

### SHOULD FIX 2 — Accumulated semantic-census underreach remains

Include `OnboardingStatus`-only user-visible consumers in semantic-root
discovery and include raw conversation-graph evidence in the main side-door
set. Add virtual cases for both dependency paths.

## 21. OPTIONAL findings

- Remove or justify the unused
  `onboardingJourneyAllowsCommandedTransition` helper in a later cleanup.
- Remove the unused `_runAutomaticRecovery` report parameter when implementation
  next touches that method.
- Correct the previously recorded stale canonical Environment Readiness wording
  in the later documentation tranche.

## 22. Narrow tests rerun

None.

No unresolved runtime question required a test rerun. The evaluator await graph,
the order of protected probes, the post-only assertion in the existing tests,
and the Journey fixture's global-provider override establish the findings
directly from source. Re-running the same green tests would not add evidence.

Prompt 18's prior validation results remain recorded, but they do not disprove
these source-level gaps.

## 23. Exact current Git status

After adding this required response only:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- tracked worktree: 48 modified and 2 deleted paths;
- index: empty;
- staged files: 0;
- commits created: 0;
- pushes: 0;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- physical untracked files: 84, consisting of the prior 83 plus this response.

No production or test file changed during this review.

## 24. Preservation-artifact verification

The Prompt 18 audit reports:

- authorized Prompt 18 implementation paths only: yes;
- unrelated baseline untracked files unchanged: yes;
- missing baseline untracked files: none;
- Prompt 18 baseline manifest hash unchanged: yes;
- all three preservation manifests and all artifacts they enumerate: valid;
- shared submodule unchanged: yes.

The preservation artifacts remain outside the repository and untouched.

## 25. Checkpoint recommendation

Do not checkpoint the Onboarding tenure correction yet.

Correct BLOCKER 1 without duplicating Environment policy or creating a retained
owner-relative cache. Correct BLOCKER 2 with a production-realistic,
deterministic lock/report harness. Close the architecture SHOULD FIX findings,
then repeat this human architectural review before checkpoint.

`ONBOARDING TENURE CORRECTION HUMAN ARCHITECTURAL REVIEW: FAIL`
