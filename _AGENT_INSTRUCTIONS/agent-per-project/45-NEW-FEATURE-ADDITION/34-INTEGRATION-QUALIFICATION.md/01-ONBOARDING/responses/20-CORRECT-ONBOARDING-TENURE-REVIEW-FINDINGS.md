# MessageLens Feature 34 / Feature 35
## Response 20 — Correct Admitted-Evidence Currentness and Prove the Real Self-Maintenance Loop

## Outcome

The two Prompt 19 blockers and both architecture SHOULD FIX findings are
resolved within the exact Prompt 20 scope.

- The admitted Environment read now re-proves the exact archive capability and
  both required resource admissions before and after every material async
  evidence read. Loss of either proof stops the read before the next protected
  read or database probe.
- Mutable provider prerequisites are read again after the last material await.
  Contacts and attachment-location async values are taken from their current
  settled provider state, while FDA, paths, data root, maintenance, dev
  overrides, graph state, live-update state, and the probe reader are all read
  at that final boundary.
- The ordinary global report and the admitted report continue to share one
  input model and one synchronous readiness/reset evaluator. No owner-relative
  global cache or second policy evaluator was introduced.
- The critical Journey tests now exercise the real production feedback loop:
  archive Ball acquisition publishes `isLocked`, the real global Environment
  provider publishes `maintenanceInProgress`, Journey observes it, and the
  callback-local admitted read supplies complete current evidence to the exact
  command predicate.
- Architecture enforcement now uses analyzer AST structure for the material
  await/proof boundaries, command capability use, semantic-check adjacency,
  and critical-test realism. The semantic census now includes
  `OnboardingStatus`-only consumers and raw conversation-graph controller/barrel
  evidence.

No Journey production semantics, Feature 35 runtime, archive coordinator,
presentation, persistence, database schema, or archive policy changed.

## 1. Baseline and preservation gate

PASS.

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`
- Index: empty
- Accumulated tracked delta remains: 48 modified / 2 deleted
- Shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check`: PASS
- Prompt 18 baseline manifest SHA-256:
  `0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`
  — verified unchanged
- Fresh Prompt 20 baseline:
  `/private/tmp/messagelens-onboarding-prompt20-baseline.Mipyuy/MANIFEST.json`
- Fresh Prompt 20 baseline SHA-256:
  `6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`

All three reconstruction/preservation manifests and the Prompt 18 baseline
manifest still match their recorded hashes:

- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`
- Feature 35 collision backup:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`

## 2. Implementation

### Admitted Environment evidence

`onboarding_environment_report_provider.dart` now separates async evidence
acquisition from synchronous evaluation:

1. `_readMaterialOnboardingEvidence` performs the supplied admission check,
   starts one material read, awaits it, and immediately performs the same check
   again.
2. `_readPersistedFailureEvidence` routes both failure-store reads through that
   helper.
3. Attachment-location and Contacts resolution use the same helper.
4. Only after all four material awaits are settled does the admitted path read
   the current mutable prerequisite values and construct
   `_OnboardingEnvironmentInputs`.
5. A final exact admission check occurs immediately before the shared
   synchronous evaluator is invoked.

The admission callback independently proves:

- `ArchiveMutationCapability.requireOperation(expectedOperation)`;
- current-caller permission to open the conversation graph connection; and
- current-caller permission to open the persistent archive store.

Thus the current owner may ignore only its own coarse aggregate lock. A stronger
resource policy still fails closed.

The ordinary global provider uses the same acquisition/evaluation pipeline
without callback-local owner semantics and continues to classify aggregate
archive locking as maintenance.

### Environment tests

The admitted-reader tests now use deterministic barriers and recording fakes.
They prove:

- capability loss during the first failure-store await rejects before the
  graph-failure read and before every protected probe;
- stronger resource denial during that await does the same;
- Contacts changed during the await is reflected in the returned report;
- FDA changed during the await is reflected in the returned report; and
- a retained Ball 1 Zone cannot read admitted evidence while Ball 2 is live,
  performs zero protected probes, and cannot change Ball 2 identity, hold count,
  or operation.

### Real Journey feedback loop

The critical fixture has a production-realistic mode which does not override
`onboardingEnvironmentReportProvider`. It overrides only underlying
prerequisites with deterministic fakes and records the real provider's emitted
states.

The four positive command tests each prove an actual
`maintenanceInProgress` emission while their real Ball is live and then prove
the command reaches its exact side-effect boundary:

- initial import;
- reimport;
- Continue Setup; and
- automatic recovery.

The relevant hostile prerequisite, supersession, automatic-reset, and foreign
Ball cases also run through this real global feedback mode. Existing wrong and
stale capability coverage remains intact.

### Architecture enforcement and census

The Journey authority architecture test now parses production and test sources
with analyzer AST utilities. It enforces:

- the admitted reader's exact typed capability/operation interface;
- guarded structure around all material evidence awaits;
- prerequisite reads after the final material await;
- a synchronous shared evaluator with no hidden awaits;
- exactly four protected Journey commands using `runWithCapability`;
- no capability-free archive-coordinator `run` for those commands;
- no intervening await between each final semantic conjunction and
  `begin`, `resume`, or `resetDerivedData`;
- four real-feedback positive tests, no global Environment override in that
  critical group, and asserted aggregate maintenance observation;
- discovery of an `OnboardingStatus`-only semantic consumer; and
- discovery/rejection of a raw conversation-graph controller/barrel side door.

Virtual mutation cases exercise the same census/policy helpers as the real
repository audit.

## 3. Exact validation results

All required validation completed without launching the app or accessing real
MessageLens data.

1. Focused internal-await fail-closed Environment tests: 2 passed.
2. Focused fresh-prerequisite-across-await tests: 2 passed.
3. Retained Ball 1 admitted-reader integration test: 1 passed.
4. Complete Environment report test file: 22 passed.
5. Focused real-global-feedback Journey group: 4 passed.
6. Complete Journey coordinator test file: 60 passed.
7. Archive mutation coordinator test file: 17 passed.
8. Generic Feature 35 registry test file: 23 passed.
9. Feature 35 architecture test file: 42 passed.
10. Onboarding Journey authority architecture test file: 24 passed.
11. Related Onboarding architecture tests:
    - operation snapshot: 11 passed;
    - virgin boundary: 6 passed;
    - Start Fresh: 7 passed.
12. Complete architecture suite: 553 passed.
13. `flutter analyze --no-pub`: PASS, no issues.
14. Complete `flutter test --no-pub --reporter compact`: 2,729 passed,
    1 intentionally skipped qualification worker, 0 failed.
15. `git diff --check`: PASS.
16. `git diff --cached --check`: PASS.
17. `dart format --output=none --set-exit-if-changed` over all four Prompt 20
    implementation/test files: PASS, 0 files changed.

No provider annotation or generated interface changed, so generation was not
applicable. The Prompt 20 baseline audit confirms that no generated file changed
during this task.

## 4. Project conformance audit

`PROJECT CONFORMANCE: PASS`

- One Journey semantic authority: PASS.
- Journey-only production presentation: PASS.
- No raw-evidence side doors: PASS.
- Admitted reader remains evidence-only: PASS.
- One shared Environment evaluator/policy: PASS.
- Fail-closed proof/resource checks after every material await: PASS.
- Current prerequisite truth at admitted-read return: PASS.
- Real production self-maintenance feedback loop proven: PASS.
- No Boolean ownership regression: PASS.
- Capability remains callback-local: PASS.
- Command-specific semantics unchanged: PASS.
- Maintenance cannot manufacture Normal: PASS.
- Persistence/restart behavior unchanged: PASS.
- Feature 35 boundary unchanged: PASS.
- Semantic-root/evidence census complete for the reviewed omissions: PASS.
- No privacy/data-safety regression: PASS.

- BLOCKER: 0
- SHOULD FIX: 0

## 5. Scope and repository state

Exactly four paths changed from the fresh Prompt 20 baseline before writing
this response:

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
2. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
3. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
4. `test/architecture/onboarding_journey_authority_architecture_test.dart`

This response is the fifth authorized Prompt 20 path. Every change is
authorized. `test/architecture/forbidden_imports_test.dart` did not require a
Prompt 20 change.

- Pre-existing unrelated untracked files changed: no.
- Missing pre-existing untracked files: none.
- Preservation artifacts changed: no.
- Shared instructions submodule: clean and unchanged.
- Index: empty.
- Staged files: none.
- Commit: none.
- Push: none.
- MessageLens Development launched: no.
- Real databases or attachment archives accessed: no.

`ONBOARDING TENURE CORRECTION BLOCKERS RESOLVED: YES`

`READY TO REPEAT ONBOARDING HUMAN ARCHITECTURAL REVIEW: YES`
