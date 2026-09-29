# MessageLens Feature 34 / Feature 35
## 22 — Correct Inner Protected-I/O Boundaries and Mixed-Revision Evidence

Prompt 21 repeated the Onboarding tenure-correction human review.

The runtime command/Journey design remains sound, but checkpoint is still blocked by two deeper currentness defects:

1. the admitted reader brackets composite Futures whose **internal** implementations can suspend and later perform protected overlay reads/writes without renewed capability/resource proof;
2. persisted source/graph failure evidence is captured early and retained across later async evidence acquisition, so the final report can mix evidence from different revisions.

Prompt 21 also found four architecture-enforcement gaps:

- admitted-await enforcement stops at the outer helper and does not reach actual protected I/O implementations;
- command-boundary enforcement is not control-flow strong enough;
- critical-test realism enforcement does not inspect the fixture helper that can reintroduce overrides;
- the real semantic/evidence traversal has a `stopAt` root hole, especially for `shellPath`.

This task corrects exactly those findings.

Do NOT redesign Journey authority.
Do NOT redesign Feature 35.
Do NOT create another owner model.
Do NOT add a caller-relative global Environment cache.
Do NOT persist or publish capability/tenure.
Do NOT change presentation.
Do NOT change database or snapshot schemas.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real Messages/Contacts databases or real attachment archives.

Read in full:

- `20-CORRECT-ONBOARDING-TENURE-REVIEW-FINDINGS.md`
- `21-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-ONBOARDING-TENURE-CORRECTION.md`
- `19-HUMAN-ARCHITECTURAL-REVIEW-ONBOARDING-TENURE-CORRECTION.md`
- `18-IMPLEMENT-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- `17-DESIGN-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- current source for onboarding Environment reporting, `OverlayOnboardingFailureStorage`, attachment archive location provider/controller, Journey coordinator, architecture tests, and critical Journey fixtures.

Governing rules:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current owner may do while holding that Ball. Diagnostics prove neither.**

> **No protected I/O may start after authority/resource admission has become stale.**

> **A report used at a side-effect boundary must not combine mutable evidence from incompatible revisions.**

---

# 1. Baseline and preservation gate

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index empty;
- accumulated tracked delta: 48 modified / 2 deleted;
- shared submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Verify unchanged:

- Prompt 20 baseline manifest:
  `/private/tmp/messagelens-onboarding-prompt20-baseline.Mipyuy/MANIFEST.json`
  SHA-256 `6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`;
- Prompt 18 baseline manifest;
- reconstruction manifest;
- pre-merge manifest;
- Feature 35 collision backup.

Create a fresh Prompt 22 baseline manifest outside the repository before editing.

If any unrelated implementation byte changed since Prompt 21, STOP AND REPORT.

---

# 2. First decide the protected-I/O boundary strategy

Prompt 21 proved that outer-Future bracketing is insufficient because the supplied Future can itself suspend and then perform protected work.

Before editing, inspect each concrete path:

## Failure storage

- `OverlayOnboardingFailureStorage.loadSourceImportFailureEntry`
- `OverlayOnboardingFailureStorage.loadGraphProjectionFailureEntry`
- `_loadGraphProjectionFailureFromKey`
- underlying overlay DB acquisition;
- `readOverlaySetting`;
- any historical-key fallback;
- any save/clear helper relevant to admitted evidence.

## Attachment location

- `AttachmentArchiveLocation.build`
- `AttachmentArchiveLocationController.load`
- `_resolveCustom`
- `_availableCustomState`
- settings-store acquisition;
- overlay setting read;
- bookmark resolution;
- refreshed-bookmark overlay write.

Determine the smallest architecture that can enforce:

```text
before every protected read/write:
    exact admitted capability still current
    exact required resource admission still current
```

Do not assume the generic outer helper can provide this.

---

# 3. Prefer a bounded proof-checkpoint interface, not authority duplication

The expected correction is to provide **checkpoint callbacks** to the concrete evidence paths that perform protected follow-up work.

A suitable pattern may be:

```text
Future<T> readX({
    required FutureOr<void> Function() requireCurrentAdmission,
})
```

or a narrower internal equivalent.

The callback must:

- remain owned by the admitted Environment read;
- prove exact `ArchiveMutationCapability.requireOperation(expectedOperation)`;
- prove the relevant current-caller resource admission;
- be called immediately before each protected overlay/database read or write that may occur after an await.

The storage/location specialists must **not** become authority owners.

They may only invoke a supplied proof checkpoint before protected I/O.

Do not:

- pass raw `ExclusiveAuthorityTenure`;
- expose a public ambient current Ball;
- store capability in singleton/provider state;
- teach failure storage or attachment location about Journey semantics;
- turn generic data specialists into archive authority objects.

If a proof-aware callback cannot be added without public API leakage, use an internal/private interface or wrapper.

---

# 4. Scope the proof checkpoint by resource

Do not use one vague “still allowed” callback if the concrete operation needs a specific archive resource action.

For each protected follow-up operation identify which admission must be current, for example:

- conversation graph connection;
- persistent archive store;
- overlay setting read/write if governed by a specific existing resource action;
- any attachment-location setting/bookmark persistence boundary.

Reuse existing `ArchiveMutationResourceAction` semantics.

Do not invent a duplicate resource enum.

If source inspection reveals that an overlay/settings operation is currently not represented by an existing archive resource action, STOP AND REPORT before inventing one.

---

# 5. Failure-storage correction

Make every protected follow-up inside admitted failure-evidence acquisition fail closed.

At minimum require:

## Source failure

```text
admission current
-> await overlay DB/store acquisition
-> admission current
-> protected readOverlaySetting
```

## Graph failure

For each key:

```text
admission current
-> await overlay DB/store acquisition
-> admission current
-> protected readOverlaySetting
```

If primary key is absent and historical key fallback occurs:

```text
primary read completes
-> admission current
-> before historical-key acquisition/read
-> admission current again at its protected read boundary
```

No historical fallback may begin protected work under stale proof.

If reads involve further internal awaits before the protected call, bracket those exact points as well.

---

# 6. Attachment-location correction

Trace all async subpaths and protect every follow-up overlay/settings operation.

At minimum:

```text
admission current
-> await settings-store/controller acquisition
-> admission current
-> protected setting read
```

For custom bookmark resolution:

```text
admission current
-> await bookmark resolution
-> admission current
-> if refreshed metadata must be persisted:
       admission current
       -> protected overlay/settings write
```

If event-subscription synchronization or another await occurs before a protected read/write, require a checkpoint after that await and before the protected operation.

Do not suppress legitimate bookmark refresh behavior; only make it fail closed if authority/resource policy is no longer current.

---

# 7. Correct BLOCKER 2 with a coherent evidence snapshot/revision protocol

Prompt 21 found that persisted failure evidence is read first and retained across later attachment/Contacts awaits.

A valid report must not mix:

```text
failure evidence at revision A
+
attachment/Contacts/current facts at revision B
```

without proving consistency.

Choose the smallest coherent strategy.

Acceptable options include:

## Option A — read failure evidence last

If moving source/graph failure acquisition to the final async position makes all other command-relevant evidence either synchronous/current after it or separately revision-proven, then acquire failure evidence last, re-read current mutable prerequisites afterward, and evaluate immediately.

This is acceptable only if moving failure evidence last does not make an earlier async value stale by the same logic.

## Option B — bounded revision/retry

Capture a revision/fingerprint for mutable evidence, perform async reads, then recheck revisions and retry the admitted evidence read if anything changed.

This must be bounded and deterministic—no unbounded spin.

## Option C — coherent double-read

Read mutable async evidence set A, acquire the rest, then reread A and require equality/current revision before evaluating.

If mismatch, retry once or fail closed.

Select the smallest option supported by current abstractions.

Do NOT retain a global cache.

Do NOT add persistence.

---

# 8. Define the exact coherence boundary

The response must state which pieces of evidence can change independently and how coherence is proven at return.

At minimum address:

- source failure entry;
- graph failure entry;
- attachment location;
- Contacts aggregate evidence;
- FDA;
- source path/data root;
- graph build state;
- live update state;
- maintenance;
- dev overrides;
- reset-driving facts.

A report may be returned only when its command-relevant facts are either:

- all read after the final material await; or
- proven unchanged/current by revision/fingerprint check.

If a fact can change without a revision source, prefer a final reread rather than assuming stability.

---

# 9. Keep the evaluator synchronous and singular

After coherent evidence acquisition, `_OnboardingEnvironmentEvaluator` must remain synchronous.

There should still be exactly one evaluator/policy for ordinary and admitted paths.

Do not move authority checks into Journey predicates.

Do not fork readiness/reset logic.

---

# 10. Build production-shaped I/O fakes at the actual protected boundary

The current `_GatedFailureStore` is too high-level.

Add deterministic test doubles that mimic the production internal structure:

```text
await database/store acquisition
-> protected setting read
```

and:

```text
await bookmark resolution
-> protected refreshed-metadata write
```

Record exact call counts for the protected operation itself.

Tests must be able to:

1. suspend immediately before the protected follow-up;
2. revoke capability or impose stronger resource policy;
3. release the suspension;
4. assert the protected read/write count remains zero.

The fake must model the unsafe production shape, not merely the outer method Future.

Where practical, test the real storage/controller with injected deterministic dependencies rather than inventing a parallel fake.

---

# 11. Required protected-I/O fail-closed tests

At minimum prove:

1. source failure: authority withdrawn during overlay DB acquisition -> `readOverlaySetting` never runs;
2. source failure: stronger resource policy during DB acquisition -> protected setting read never runs;
3. graph primary key: same two cases;
4. graph historical fallback: withdrawal between primary null result and historical protected read -> historical read never runs;
5. attachment location: withdrawal during settings/controller acquisition -> protected setting read never runs;
6. bookmark refresh path: withdrawal during bookmark resolution -> refreshed metadata write never runs;
7. resource-policy strengthening during bookmark resolution -> write never runs.

If some production path cannot occur under the admitted operations, document and test the nearest actual path rather than fabricating an impossible one.

---

# 12. Required mixed-revision tests

Add deterministic tests that mutate failure evidence while a later material await is suspended.

At minimum:

1. source failure entry changes while attachment or Contacts resolution is blocked;
2. graph failure entry changes while a later material await is blocked;
3. failure entry is cleared during the await;
4. reset-driving recorded failure becomes newly present during the await.

For each:

- the admitted report must reflect the new evidence; or
- the read must retry/fail closed according to the selected coherence protocol.

It must never return the old failure/reset facts.

Also retain the existing FDA/Contacts freshness tests.

---

# 13. Preserve the real self-maintenance feedback tests

Do not weaken the Prompt 20 fixture.

Critical positive Journey tests must still use:

- real registry;
- real archive coordinator;
- real global Environment provider;
- real maintenance emission and Journey ingestion;
- admitted fresh evidence for the final predicate.

Do not override `onboardingEnvironmentReportProvider` in those tests.

All four positive commands must continue proving real self-maintenance feedback.

---

# 14. Preserve negative command semantics

Retain the exact hostile-race matrix for:

- foreign Ball;
- FDA withdrawal;
- Contacts withdrawal;
- command semantic supersession;
- continuation supersession;
- reset requirement withdrawal before begin;
- reset requirement withdrawal before reset;
- wrong/stale capability;
- Ball 1 under Ball 2.

The inner-I/O fix must not alter command semantics.

`onboarding_journey_coordinator_provider.dart` should remain unchanged unless source inspection reveals a new production defect. If so, STOP AND REPORT.

---

# 15. Strengthen architecture SHOULD FIX 1 — prove actual protected-I/O checkpoints

The architecture test must no longer stop at `_readMaterialOnboardingEvidence`.

Use analyzer AST / dependency traversal to enforce one of these mechanically:

- every approved admitted evidence implementation that can perform protected I/O accepts the approved proof-checkpoint callback and invokes it at the required boundary; or
- all admitted protected I/O is routed through an approved proof-aware internal interface whose implementations are allowlisted and audited.

The rule must cover the actual production methods in:

- failure storage;
- attachment location provider/controller;
- any other admitted evidence specialist with protected follow-up work.

A new inner await + protected call without checkpoint must fail architecture validation.

Do not require checks inside code paths never reachable from admitted evidence.

---

# 16. Strengthen command-boundary control-flow enforcement

Prompt 21 found the current AST rule can be fooled by a harmless nearby predicate-bearing `if`.

Strengthen the rule to prove the final guard actually **dominates** the mutation boundary.

At minimum for each command:

- identify the side-effect invocation:
  - `begin(initialImport)`
  - `begin(reimport)`
  - `resume(operationId)`
  - `begin(automaticRecovery)`
  - `resetDerivedData()`
- identify the enclosing control-flow block;
- prove the required semantic predicate, capability/currentness checks, and binding checks are on every path to that invocation;
- prove no await occurs after the final required guard and before the mutation.

Use AST control-flow structure where practical.

If full CFG support is available from analyzer without major infrastructure, use it. Otherwise encode a narrow structural rule around the current functions that cannot be satisfied by a dead/harmless nearby `if`.

Add virtual mutation cases that move the real guard before an await while leaving a dummy predicate `if` near the mutation; the rule must fail.

---

# 17. Strengthen critical-test realism enforcement

Inspect `_JourneyFixture.create`, not only the test bodies.

Architecture enforcement must prove that when `useRealGlobalEnvironmentFeedback == true`:

- `onboardingEnvironmentReportProvider` is not overridden;
- `archiveMutationCoordinatorProvider` is not overridden/replaced;
- `exclusiveAuthorityRegistryProvider` is not overridden/replaced;
- the fixture still records/asserts real aggregate maintenance observations.

Add a mutation fixture where the helper ignores the flag and overrides the global Environment provider; architecture must fail.

Add another where the helper replaces the registry/coordinator provider; architecture must fail.

Do not prohibit unrelated lightweight fixtures used outside the critical group.

---

# 18. Fix the real semantic/evidence traversal `stopAt` hole

Prompt 21 found `shellPath` is both a semantic root and a trusted-boundary stop node.

That prevents traversing its dependencies in the real repository audit.

Correct the traversal semantics so the root itself is always inspected/traversed before `stopAt` applies to descendants, or remove roots from the stop set by construction.

The same helper/configuration must be used by real repository audit and virtual mutation tests.

Add a mutation:

```text
shell
-> wrapper
-> raw conversation-graph barrel/controller
```

using the exact real trusted-boundary configuration.

It must fail.

Do not weaken legitimate coordinator boundary stopping.

---

# 19. Recheck `OnboardingStatus` semantic-root census

Prompt 21 passed this correction.

Do not redesign it.

Retain:

- `OnboardingStatus` as a semantic consumption marker;
- the virtual status-only consumer case;
- the same real helper for repository and mutation audit.

---

# 20. Expected implementation scope

Because BLOCKER 1 reaches concrete protected I/O specialists, Prompt 22 may legitimately expand beyond Prompt 20's four-file scope.

## Expected production files that MAY/MUST change

- `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
- concrete overlay Onboarding failure-storage implementation file(s);
- attachment archive location provider/controller file(s) that perform the admitted protected reads/writes;
- only the minimal internal interfaces/types needed to pass proof-checkpoint callbacks.

## Expected tests

- Environment report tests;
- concrete failure-storage tests;
- attachment-location provider/controller tests if needed;
- Journey coordinator tests only as required to retain/extend real feedback proof;
- Onboarding Journey authority architecture test;
- central forbidden/dependency architecture helper only if that is where the traversal policy lives.

## MUST NOT change

- Journey production command semantics unless a source-proven defect triggers a stop;
- presentation;
- Journey state/action context/projection/snapshot;
- Feature 35 generic registry;
- `ArchiveMutationCoordinator` / `ArchiveMutationCapability`;
- database schemas;
- persisted snapshot format;
- native locks;
- archive relocation/adoption behavior;
- public feature APIs unnecessarily;
- release metadata.

Before editing, enumerate the exact concrete production paths and explain why each is necessary.

---

# 21. Validation sequence

After correction run:

1. protected source-failure I/O withdrawal tests;
2. protected graph-failure I/O withdrawal tests;
3. protected attachment-location read/write withdrawal tests;
4. mixed-revision failure-evidence tests;
5. complete Environment report tests;
6. relevant concrete failure-storage tests;
7. relevant attachment-location tests;
8. focused real-global-feedback Journey tests;
9. complete Journey coordinator tests;
10. archive mutation coordinator tests;
11. generic Feature 35 registry tests;
12. Feature 35 architecture tests;
13. Onboarding Journey authority architecture tests;
14. related authority/snapshot architecture tests;
15. complete architecture suite;
16. `flutter analyze --no-pub`;
17. complete `flutter test --no-pub --reporter compact`;
18. `git diff --check`;
19. formatting/generated consistency as applicable.

Record exact counts.

Do not run GUI qualification.

---

# 22. Project Conformance audit

Audit the full accumulated Onboarding correction delta.

Require explicit PASS for:

- one Journey semantic authority;
- Journey-only presentation;
- no raw-evidence side doors;
- one shared readiness evaluator;
- admitted evidence is one-shot and non-publishing;
- exact capability + resource proof before every protected I/O boundary;
- no stale protected read/write after inner suspension;
- coherent/current mutable evidence at report return;
- real self-maintenance feedback loop proven;
- capability callback-local;
- command semantics unchanged;
- maintenance cannot manufacture Normal;
- no persistence/schema/restart drift;
- Feature 35 boundary unchanged;
- real semantic/evidence dependency census complete;
- no privacy/data-safety regression.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 23. Preserve scope and evidence

Create a fresh Prompt 22 baseline manifest before edits and compare at the end.

Report:

- every changed production file;
- every changed test/architecture file;
- why each is required;
- unrelated pre-existing untracked changes: 0;
- preservation artifact changes: 0;
- shared-submodule changes: 0.

If an unrelated path changes and is not unquestionably tool-generated churn, STOP AND REPORT.

---

# 24. Leave unstaged and uncommitted

Even after green validation:

- do not stage;
- do not commit;
- do not push.

Repeat human architectural review before checkpoint.

---

# 25. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline/preservation verification;
2. concrete protected-I/O path inventory;
3. selected proof-checkpoint interface/design;
4. failure-storage boundary correction;
5. graph historical-fallback correction;
6. attachment-location read correction;
7. bookmark-refresh write correction;
8. evidence-coherence strategy;
9. exact final coherence boundary;
10. protected-I/O withdrawal tests;
11. mixed-revision failure-evidence tests;
12. Environment test results;
13. concrete failure-storage test results;
14. attachment-location test results;
15. real-global-feedback Journey results;
16. Journey coordinator result;
17. Feature 35/archive regression results;
18. protected-I/O architecture enforcement;
19. command-boundary control-flow enforcement;
20. critical-test realism enforcement;
21. real traversal `stopAt` correction;
22. semantic-root/raw-graph census results;
23. complete architecture result;
24. analyzer result;
25. full Flutter-suite result;
26. diff/format/generated hygiene;
27. Project Conformance verdict;
28. BLOCKER findings;
29. SHOULD FIX findings;
30. exact Prompt 22 changed-file census;
31. baseline-manifest comparison;
32. preservation-artifact verification;
33. exact Git status;
34. stop gates encountered;
35. readiness for repeated human architectural review.

Conclude exactly:

`ONBOARDING INNER-IO AND EVIDENCE-COHERENCE BLOCKERS RESOLVED: YES / NO`

If YES, also conclude:

`READY TO REPEAT ONBOARDING HUMAN ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
