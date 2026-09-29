# MessageLens Feature 34 / Feature 35
## 24 — Close the Final Onboarding Architecture-Enforcement Gaps

Prompt 23 repeated the human architectural review after the inner-I/O and evidence-coherence correction.

The current **runtime implementation is sound**:

- BLOCKER: 0;
- protected I/O is fail-closed at the concrete boundaries;
- material evidence coherence is bounded and current;
- the real self-maintenance feedback loop is exercised;
- Journey command semantics remain correct;
- persistence/restart semantics remain unchanged.

Checkpoint is still blocked by exactly three **architecture-enforcement** SHOULD FIX findings:

1. the protected-I/O AST audit stops at a persistence wrapper and does not reach the concrete `_settingsStore.writeSetting` call, while its checkpoint matcher does not prove unconditional/dominating invocation of the approved callback;
2. the command-boundary AST audit checks predicate tokens but not the rejecting polarity / Boolean structure of the actual final guard;
3. the critical-test realism audit does not structurally connect the real global Environment provider's observation recorder to the maintenance wait asserted by the four critical tests.

This task corrects **only those three enforcement defects**.

Do NOT change runtime production semantics.
Do NOT change Journey command implementation.
Do NOT change Environment evidence behavior.
Do NOT change failure-storage or attachment-location runtime behavior.
Do NOT redesign Feature 35.
Do NOT change presentation, persistence, schema, restart semantics, archive policy, native authority, or resource actions.
Do NOT perform optional cleanup.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `23-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-22.md`
- `22-CORRECT-INNER-IO-AND-EVIDENCE-COHERENCE.md`
- the current `test/architecture/onboarding_journey_authority_architecture_test.dart`
- current production source only as needed to anchor the architecture rules.

Governing principle:

> **The architecture test must reject the semantic regression, not merely notice today's spelling.**

---

# 1. Baseline and preservation gate

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked delta: 55 modified / 2 deleted;
- shared submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Verify the Prompt 22 baseline manifest:

`/private/tmp/messagelens-onboarding-prompt22-baseline.ETdg87/MANIFEST.json`

SHA-256:

`e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`

and all earlier preservation manifests remain unchanged.

Create a fresh Prompt 24 baseline manifest outside the repository before edits.

If any unrelated runtime/test byte changed since Prompt 23, STOP AND REPORT.

---

# 2. Strict scope

## Expected MUST-change file

- `test/architecture/onboarding_journey_authority_architecture_test.dart`

## MAY change only if the shared AST/dependency-policy helper actually lives there

- `test/architecture/forbidden_imports_test.dart`

## Production files MUST NOT change

At minimum:

- `onboarding_environment_report_provider.dart`
- `onboarding_journey_coordinator_provider.dart`
- `onboarding_failure_store.dart`
- `overlay_onboarding_failure_storage.dart`
- `attachment_archive_location_provider.dart`
- `attachment_archive_location_controller.dart`
- any Feature 35 runtime file
- any presentation/persistence/schema/native/archive-policy file

Behavioral runtime tests should remain byte-identical unless the architecture framework requires a dedicated fixture source.

If any production-code change appears necessary, STOP AND REPORT before making it.

---

# 3. SHOULD FIX 1A — reach the actual bookmark settings write

The current protected-I/O audit treats `_persistConfigurationUnchecked(...)` as though it were the protected operation.

The actual protected operation is `_settingsStore.writeSetting(...)` inside that helper.

Correct the architecture audit so it reaches the **concrete settings write**.

Required mechanical property:

```text
await bookmark resolution
-> approved persistent-store proof checkpoint
-> concrete _settingsStore.writeSetting(...)
```

Reject:

```text
await bookmark resolution
-> _persistConfigurationUnchecked(...)
   -> await somethingElse
   -> _settingsStore.writeSetting(...)
```

unless another approved proof checkpoint occurs after that inner await and before the write.

Do not stop analysis at the wrapper call.

Use AST/dependency traversal to inspect the actual helper implementation or explicitly treat the helper as an audited protected-I/O root.

---

# 4. Add the exact bookmark-wrapper evasion mutation

Create a virtual/synthetic mutation using the same architecture-policy helper as the real repository audit:

```dart
Future<void> _persistConfigurationUnchecked(...) async {
  await someAsyncBoundary();
  await _settingsStore.writeSetting(...);
}
```

with no renewed proof checkpoint between the await and the write.

The architecture audit must fail specifically because the concrete protected write is no longer dominated by the approved checkpoint.

Also include a positive case where a renewed approved checkpoint after the await permits the write, if that shape is otherwise consistent with the policy.

---

# 5. SHOULD FIX 1B — checkpoint matcher must prove the approved callback dominates

The current matcher can accept any nearby invocation named `requirePersistentArchiveStoreAdmission`, even if it is conditional, non-dominating, on an unrelated receiver, or in a branch that does not execute on the protected-I/O path.

Replace this with a structural check.

Required property:

- the checkpoint is the approved caller-supplied proof callback / exact audited proof helper;
- it executes unconditionally on every path to the protected operation after the most recent relevant await;
- it is not merely an invocation with a matching method name.

Where practical, identify the callback by parameter/local binding origin rather than token spelling.

If the production structure has one exact accepted shape, prefer a narrow AST allowlist over a broad pseudo-CFG.

---

# 6. Add checkpoint-dominance mutation cases

Using the real architecture helper, reject at least:

## Conditional checkpoint

```dart
if (someCondition) {
  requirePersistentArchiveStoreAdmission();
}
await _settingsStore.writeSetting(...);
```

## Wrong receiver / unrelated method

```dart
fake.requirePersistentArchiveStoreAdmission();
await _settingsStore.writeSetting(...);
```

## Wrong branch

```dart
if (denyPath) {
  requirePersistentArchiveStoreAdmission();
  return;
}
await _settingsStore.writeSetting(...);
```

## Await after valid checkpoint

```dart
requirePersistentArchiveStoreAdmission();
await anotherAsyncBoundary();
await _settingsStore.writeSetting(...);
```

unless a second valid checkpoint occurs after the await.

The current valid production path must continue to pass.

---

# 7. SHOULD FIX 2 — validate the actual rejecting guard expression

The command-boundary audit currently accepts guards based on token membership.

This is insufficient.

For each protected mutation, the architecture policy must recognize the actual **rejecting** guard structure.

This invalid shape must fail:

```dart
if (_commandAndActionAreCurrent(...) &&
    _reportAllowsCommand(...predicate: _reportAllowsInitialImport)) {
  return;
}
controller.begin(...);
```

It contains the expected fragments but rejects the valid branch and permits the unsafe branch.

Likewise reject semantic changes caused by `||`, removed negation, or inverted binding/currentness terms.

---

# 8. Define the exact accepted guard shapes

Inspect current production AST and encode narrow structural predicates for:

1. `begin(initialImport)`
2. `begin(reimport)`
3. `resume(operationId)`
4. `begin(automaticRecovery)`
5. `resetDerivedData()`

For each, prove:

- exact capability/current-operation proof required by that boundary;
- exact command/action/binding terms required by that boundary;
- exact command-specific report predicate;
- guard rejects when **any required conjunct is false**;
- guard terminates the unsafe path with `return` or exact current equivalent;
- mutation lies in the fall-through valid path;
- no await occurs after the guard and before mutation.

Prefer Boolean AST operators, unary negation, and call identity over source-string fragments.

Do not generalize farther than the five reviewed production shapes.

---

# 9. Add command-guard semantic mutation cases

Use the same command-boundary policy as the repository audit.

At minimum reject:

1. inverted guard polarity;
2. `&&` changed to unsafe `||`;
3. one required conjunct removed;
4. a required currentness negation removed/inverted;
5. real guard moved before an await with a harmless correct-looking dummy guard left beside the mutation.

Each mutation should fail for the intended control-flow rule.

The valid production shapes must pass.

---

# 10. SHOULD FIX 3 — structurally connect real Environment observation to critical tests

The current fixture-realism check can be satisfied by an unused recorder name and a maintenance wait on an unrelated fake.

Correct the rule so the real-feedback fixture's data flow is structurally connected.

When `useRealGlobalEnvironmentFeedback == true`:

1. `_JourneyFixture.create` does not override:
   - `onboardingEnvironmentReportProvider`;
   - `archiveMutationCoordinatorProvider`;
   - `exclusiveAuthorityRegistryProvider`;
2. the fixture subscribes/listens to the real `onboardingEnvironmentReportProvider`;
3. emitted reports are recorded into the exact recorder/handle returned to the test fixture;
4. the four critical tests wait/assert `maintenanceInProgress` through that exact returned recorder/handle;
5. that recorder cannot be satisfied by an unrelated fake source.

Use AST identifier/binding relationships where practical.

---

# 11. Add disconnected-recorder mutation cases

Reject synthetic fixtures where:

- the real provider is listened to but its recorder is dead/unused while tests wait on another mutable source;
- the fixture exposes a real recorder and fake recorder but the critical wait uses the fake one;
- the real-mode flag leaves the provider unoverridden but the returned observation handle is sourced elsewhere.

These mutations must fail the same realism policy used for the repository audit.

Retain the already-passing mutations for ignored flag and authority-provider replacement.

---

# 12. Preserve the passed traversal/census corrections

Do not redesign:

- root-aware `_transitiveLocalDependencies`;
- removal of semantic roots from trusted stop sets;
- `shellPath` traversal;
- `OnboardingStatus` semantic-root discovery;
- raw conversation-graph controller/barrel evidence census.

Spot-check them after edits, but no new behavior is required.

---

# 13. Preserve runtime/test evidence

Do not change the reviewed runtime behavior or behavioral tests.

The following remain accepted:

- no stale protected I/O;
- coherent double-sampled material evidence;
- current synchronous facts after the final await;
- real self-maintenance loop for all four commands;
- exact command semantics;
- persistence/restart unchanged.

This task is purely about making those invariants mechanically durable in architecture tests.

---

# 14. Validation

Run:

1. `flutter test --no-pub test/architecture/onboarding_journey_authority_architecture_test.dart --reporter expanded`
2. related Onboarding architecture tests as needed;
3. complete architecture suite;
4. `flutter analyze --no-pub`;
5. `git diff --check`;
6. formatting check on changed architecture files.

Do not rerun the full Flutter suite unless the architecture refactor unexpectedly touches shared runtime/test helpers.

If any runtime/test source unexpectedly changes, STOP AND REPORT.

---

# 15. Project Conformance enforcement review

Re-evaluate only the three Prompt 23 SHOULD FIX findings and ensure no regression in previously passed boundaries.

Require:

- concrete settings write is included in protected-I/O audit;
- approved proof callback structurally dominates protected I/O;
- command guard polarity/conjunction is mechanically enforced;
- critical real-feedback recorder is structurally tied to the real global Environment provider and asserted wait;
- root-aware semantic/evidence traversal remains correct;
- runtime production remains unchanged.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 16. Preserve scope

Compare against the fresh Prompt 24 baseline manifest.

Expected changes:

- architecture test only;
- optional shared architecture helper only if mechanically necessary;
- Prompt 24 response record.

Report any other changed path as a stop-gate violation.

Preservation artifacts and shared submodule must remain unchanged.

---

# 17. Leave unstaged and uncommitted

Even if validation passes:

- do not stage;
- do not commit;
- do not push.

Repeat one final targeted human architecture review of these three enforcement rules before checkpoint.

Do not reopen runtime design unless this correction unexpectedly alters production code.

---

# 18. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline/preservation verification;
2. concrete bookmark-write AST enforcement;
3. bookmark-wrapper mutation result;
4. checkpoint-callback identity/dominance enforcement;
5. checkpoint-dominance mutation results;
6. command-guard structural model;
7. command-guard mutation results;
8. real-feedback fixture data-flow model;
9. disconnected-recorder mutation results;
10. preserved traversal/census rules;
11. runtime/test byte-identity verification;
12. focused Onboarding architecture result;
13. related architecture result;
14. complete architecture result;
15. analyzer result;
16. diff/format hygiene;
17. Project Conformance verdict;
18. BLOCKER findings;
19. SHOULD FIX findings;
20. exact Prompt 24 changed-file census;
21. baseline-manifest comparison;
22. preservation-artifact verification;
23. exact Git status;
24. stop gates encountered;
25. readiness for final targeted architecture review.

Conclude exactly:

`FINAL ONBOARDING ARCHITECTURE-ENFORCEMENT GAPS CLOSED: YES / NO`

If YES, also conclude:

`READY FOR FINAL TARGETED ONBOARDING ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
