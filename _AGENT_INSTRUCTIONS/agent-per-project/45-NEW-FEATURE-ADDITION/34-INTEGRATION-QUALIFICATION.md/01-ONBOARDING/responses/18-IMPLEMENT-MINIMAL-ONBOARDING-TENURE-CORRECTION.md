# MessageLens Feature 34 / Feature 35
## 18 — Implement Minimal Onboarding Tenure Correction

Date: 2026-09-27

## 1. Baseline and preservation verification

Implementation began from the required frozen baseline:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked delta: 47 modified and 2 deleted paths;
- physical untracked-file count: 81;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: clean.

A fresh external baseline was captured at:

`/private/tmp/messagelens-onboarding-prompt18-baseline.yd0I9Y/MANIFEST.json`

Its SHA-256 is:

`0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`

The manifest records types, modes, sizes, and hashes for all 49 tracked-delta
entries and all 81 physical untracked files.

## 2. Admitted Environment evidence implementation

`onboarding_environment_report_provider.dart` now contains one plain,
non-provider, one-shot admitted evidence reader. It requires both:

- an exact `ArchiveMutationCapability`;
- a typed expected `ArchiveMutationOperation`.

The global provider and admitted reader share the same input construction and
the same `_OnboardingEnvironmentEvaluator`. No second readiness evaluator,
policy, cache, or provider was introduced.

The admitted reader recomputes current FDA, Messages, Contacts, attachment,
import-ledger, graph, failure, reset, and lifecycle facts. It excludes only the
exact owner's non-blocking aggregate archive lock; it continues to honor the
stronger database-reopen policy.

## 3. Proof and resource revalidation behavior

The admitted reader fails closed unless all of the following remain current:

- capability operation identity;
- capability Zone/scope/tenure;
- conversation-graph connection admission;
- persistent archive-store admission.

Those checks occur before work, after attachment-location resolution, after
Contacts resolution, and after evaluator completion. Tests prove wrong
operation, outside-Zone, released/stale proof, pre-probe resource denial,
post-await capability revocation, and post-await stronger resource policy all
fail closed.

No ambient current-Ball lookup was added, and no diagnostic field, label,
occurrence, or `.isLocked` value is used as ownership proof.

## 4. Global Environment semantics

The ordinary `onboardingEnvironmentReportProvider` remains aggregate and
owner-agnostic. During any admitted archive mutation it still reports
`maintenanceInProgress` to unrelated observers and suppresses protected
derived-store reads.

The owner-relative report is neither assigned to `_latestReport`, published by
the global provider, exported from the public Onboarding barrel, nor exposed to
presentation. A focused test reads the global report again after an admitted
`ready` result and verifies that the global report remains aggregate
maintenance evidence.

## 5. Initial-import correction

Initial import now:

1. validates the exact action/token and complete global initial-import
   predicate immediately before admission;
2. enters `runWithCapability` for `onboardingImport`;
3. acquires the durable operation controller;
4. obtains fresh admitted Environment evidence;
5. revalidates capability, action/token, and the unchanged initial-import
   predicate;
6. invokes `controller.begin` with no intervening await.

FDA loss, Contacts/source loss, semantic transition to `ready`, foreign tenure,
and stale action all prevent `begin` and do not mint an operation UUID.

## 6. Reimport correction

Reimport uses the same exact capability sequence with the unchanged reimport
predicate. A self-owned valid `ready` installation begins exactly one reimport;
`readyToImport`, prerequisite regression, or foreign authority prevents
`begin` and reset work.

## 7. Continuation correction

Continue Setup retains its positive pre-admission resumability check. Inside
the capability it revalidates:

- action/token;
- exact retained binding;
- operation UUID;
- process session;
- interrupted status;
- fresh admitted Environment evidence;
- unchanged reconciliation/resumability semantics.

`controller.resume` follows the final predicate without an intervening await.
Successful continuation retains the same UUID and resumes once. Superseding
`ready` evidence, a Contacts blocker, a stale action, or mismatched evidence
prevents resume. Ordinary interrupted imports remain explicit Continue Setup;
no automatic resume was introduced.

## 8. Automatic-recovery correction

Automatic recovery now uses `runWithCapability` for
`ArchiveMutationOperation.automaticRecovery` and performs fresh admitted reads
at both required boundaries:

- after controller acquisition, immediately before `begin`;
- after reset-stage progress persistence, immediately before
  `resetDerivedData`.

The second check independently requires that reset is still necessary. Losing
the reset predicate before `begin` creates no UUID; losing it after progress
creates no reset side effect. Valid current evidence resets exactly once.

## 9. Maintenance-to-Journey mapping correction

Aggregate `maintenanceInProgress` no longer constructs
`OnboardingNormalApplication`.

- Cold reconstruction with maintenance-only evidence remains Checking.
- An active command retains its already-authorized operation Episode.
- An established Normal, Ready to Import, failure, or interrupted semantic
  state is retained under maintenance-only evidence.
- Hard prerequisite blockers still outrank maintenance-only retention.
- A complete post-release report transitions Journey normally.

No Maintenance Episode or presentation-side maintenance interpretation was
added.

## 10. Journey state, action-context, and persistence non-changes

Prompt 18 made no changes to:

- `OnboardingJourneyState` or action-context structure;
- operation projection or operation snapshot model;
- snapshot controller, codec, schema, or migration;
- reconciliation semantics;
- presentation code;
- Feature 35 registry, tenure, key, coordinator, or capability types;
- archive policy, native code, application configuration, release metadata,
  `pubspec.yaml`, or `CHANGELOG.md`.

No capability or tenure was stored, serialized, projected, or exposed through
Journey state.

## 11. Hostile-race test harness

The Journey test fixture no longer overrides or subclasses
`ArchiveMutationCoordinator`. Critical tests now use:

- the real `ExclusiveAuthorityRegistry`;
- the real `ArchiveMutationCoordinator`;
- real lock publication;
- real private Zone context;
- real opaque capability issuance and revocation.

External contention is created by holding the production registry's typed
archive authority. Await boundaries use deterministic `Completer` barriers;
no timing sleeps were introduced.

## 12. Hostile-race results

The required matrix is covered and passing:

1. self-owned initial import with unchanged prerequisites begins once;
2. foreign authority prevents callback/begin;
3. stale/released proof fails closed;
4. FDA withdrawal after admission prevents begin;
5. Contacts withdrawal prevents begin/resume;
6. initial import superseded by `ready` does not begin;
7. reimport superseded by `readyToImport` does not begin;
8. continuation superseded by `ready` does not resume;
9. automatic recovery losing reset need before begin creates no UUID;
10. automatic recovery losing reset need after progress performs no reset;
11. wrong-operation capability is denied;
12. retained Ball 1 proof cannot act while Ball 2 is live;
13. valid self-owned reimport begins once;
14. valid continuation resumes the same UUID once;
15. valid automatic recovery resets once;
16. capability/resource changes during evidence awaits fail closed;
17. hostile raw maintenance/graph/snapshot noise cannot displace the bound
    Journey Episode;
18. restart of an ordinary interrupted import remains explicit Continue
    Setup.

Focused late-bound race run: **10 passed, 0 failed, 0 skipped**.

## 13. Environment-report test results

Focused admitted-evidence run: **7 passed, 0 failed, 0 skipped**.

Complete environment-report file: **19 passed, 0 failed, 0 skipped**.

This includes aggregate maintenance, fresh admitted readiness, no cached
snapshot reuse, changed external evidence, current reset facts, wrong/stale/
outside-Zone capability, pre-probe resource denial, both post-await checks, and
non-publication through the global provider.

## 14. Journey coordinator test result

Complete Journey coordinator file: **56 passed, 0 failed, 0 skipped**.

The result includes the maintenance truth table, positive command paths,
post-await prerequisite withdrawal, UUID/session binding, restart behavior,
failure publication ordering, and hostile asynchronous evidence.

## 15. Archive and Feature 35 regression results

- archive mutation coordinator: **17 passed, 0 failed, 0 skipped**;
- generic Feature 35 registry: **23 passed, 0 failed, 0 skipped**;
- Feature 35 architecture enforcement: **42 passed, 0 failed, 0 skipped**.

No Feature 35 production or test file changed in Prompt 18.

## 16. Architecture-tripwire implementation

The Journey authority architecture test now enforces all Prompt 18 boundary
classes:

- exactly four protected `runWithCapability` command admissions and no
  capability-free protected `.run` path;
- typed capability/operation requirements;
- pre/post capability and two-resource checks;
- sole Journey consumption of the admitted seam;
- aggregate global-provider semantics;
- no public-barrel export;
- no presentation, Journey value, action-context, projection, or snapshot
  tenure proof;
- no ambient or diagnostic authorization proof;
- maintenance cannot manufacture Normal Application;
- command-specific late predicates remain adjacent to begin/resume/reset;
- critical tests cannot replace the real Feature 35 authorities with fakes.

## 17. Architecture results

- Onboarding Journey authority architecture: **22 passed, 0 failed, 0
  skipped**;
- related Onboarding snapshot/Start Fresh architecture: **18 passed, 0
  failed, 0 skipped**;
- complete architecture suite: **551 passed, 0 failed, 0 skipped**.

## 18. Analyzer result

`flutter analyze --no-pub`: **PASS — 0 issues**.

An initial informational import-order finding in the new test imports was
corrected before the final analyzer run.

## 19. Full Flutter-suite result

`flutter test --reporter compact`: **2,720 passed, 0 failed, 1 skipped**.

The one skip is the existing qualification worker that instructs the operator
to run `tool/archive_import_memory_harness.dart`; it is unrelated to Prompt 18.

## 20. Generation, formatting, and diff hygiene

- formatting check over all five authorized paths: **PASS**, 5 files checked,
  0 changed;
- `git diff --check`: **PASS**;
- no annotation or generated declaration was added;
- no build-runner invocation was required;
- both existing Onboarding generated files remain byte-identical to the
  Prompt 18 baseline;
- index remains empty.

## 21. Project Conformance verdict

The complete accumulated Onboarding correction delta was audited against the
Project Conformance Audit Standard and the Prompt 18 checklist.

`PROJECT CONFORMANCE: PASS`

The audit found:

- one sole user-visible Journey authority;
- Journey-only production presentation, retaining only the pre-existing
  bounded diagnostic development-panel exception;
- no raw-evidence semantic side door;
- exact current action/token/binding/UUID/session semantics;
- exact opaque archive capability proof, not Boolean ownership;
- one readiness evaluator and no caller-relative global cache;
- no capability escape or resource-policy bypass;
- late checks after every relevant await;
- no persistence/schema/restart drift;
- unchanged Feature 35 generic/domain boundary;
- no production-data, archive, privacy, or destructive side effect;
- no analyzer-detected dead code;
- real authority infrastructure in critical tests.

## 22. BLOCKER findings

**BLOCKER: 0**

## 23. SHOULD FIX findings

**SHOULD FIX: 0**

## 24. Exact changed-file census

Prompt 18 changed exactly these five authorized paths:

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`;
2. `lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart`;
3. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`;
4. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`;
5. `test/architecture/onboarding_journey_authority_architecture_test.dart`.

The first four are tracked files. The fifth was already an intentional
untracked file in the frozen accumulated correction and remains untracked.
This response is the sole additional repository file created by Prompt 18.

No optional file was changed.

## 25. Implementation-baseline manifest comparison

Comparison against the fresh Prompt 18 manifest reports:

- baseline tracked delta: 49 paths;
- current accumulated tracked delta: 50 paths (48 modified, 2 deleted);
- changed baseline tracked/new-delta paths: exactly the four authorized tracked
  files above;
- changed baseline untracked paths: exactly the authorized architecture test;
- unrelated pre-existing untracked files changed: **0**;
- pre-existing untracked files missing: **0**;
- unexpected new untracked implementation files: **0**;
- authorized scope comparison: **PASS**.

After adding this required response, the physical untracked-file count is 82:
the 81 baseline files plus this response. No pre-existing unrelated untracked
file was modified.

## 26. Frozen preservation-artifact verification

All three preservation manifests retain their exact hashes, and every artifact
or collision stream named by them re-hashes successfully:

- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`;
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`;
- Feature 35 collision backup:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`.

No preservation artifact was modified.

## 27. Exact Git status

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- accumulated tracked worktree: 48 modified, 2 deleted;
- index: empty;
- physical untracked files: 82 after this response;
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- staged files: 0;
- commits created: 0;
- pushes: 0.

## 28. Stop gates encountered

No implementation stop gate was encountered.

The local SDK initially required its external cache permission for redirected
validation runs; validation was rerun with the already-approved scoped Flutter
and Dart executables. No repository or product-state workaround was used.

MessageLensDevelopment was not launched. No real Messages/Contacts database,
MessageLens database, attachment archive, archive configuration, production
data, or external-drive artifact was accessed or modified.

## 29. Readiness for human architectural review

The minimal correction is implemented within the approved five-file scope,
all required validation and conformance checks pass, preservation is intact,
and the work remains unstaged and uncommitted for review.

`MINIMAL ONBOARDING TENURE CORRECTION IMPLEMENTED: YES`

`READY FOR ONBOARDING HUMAN ARCHITECTURAL REVIEW BEFORE CHECKPOINT: YES`
