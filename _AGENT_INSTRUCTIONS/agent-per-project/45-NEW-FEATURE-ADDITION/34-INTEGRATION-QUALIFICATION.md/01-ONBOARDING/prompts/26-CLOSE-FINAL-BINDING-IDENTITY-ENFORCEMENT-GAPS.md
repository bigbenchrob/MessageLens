# MessageLens Feature 34 / Feature 35
## 26 — Close the Final Binding-Identity Enforcement Gaps

Prompt 25 completed the final targeted Onboarding architecture review.

The current runtime implementation remains sound.

There are:

- BLOCKER: 0
- SHOULD FIX: 3

All three remaining findings are **architecture-enforcement binding-identity gaps**, not runtime defects:

1. the protected-I/O checkpoint rule proves callback spelling and dominance, but not that the invocation resolves to the caller-supplied proof callback or that the admitted caller propagated a non-null callback;
2. the command-boundary rule proves Boolean shape and polarity, but not that the calls/identifiers resolve to the reviewed command-currentness, report, binding, and mutation declarations;
3. the critical real-feedback recorder rule proves a connected named chain, but not that the `container` and `onboardingEnvironmentReportProvider` identifiers resolve to the real ProviderContainer and real global provider.

This task closes **only those three binding-authenticity gaps**.

Do NOT modify production code.
Do NOT modify behavioral tests.
Do NOT modify runtime helpers.
Do NOT redesign Onboarding.
Do NOT redesign Feature 35.
Do NOT change presentation, persistence, schema, restart semantics, archive policy, resource actions, native authority, or generated source.
Do NOT perform optional cleanup.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `25-FINAL-TARGETED-ONBOARDING-ARCHITECTURAL-REVIEW.md`
- `24-CLOSE-FINAL-ONBOARDING-ARCHITECTURE-ENFORCEMENT-GAPS.md`
- the current `test/architecture/onboarding_journey_authority_architecture_test.dart`
- current production/test source only as needed to establish declaration origins.

Governing principle:

> **Architecture enforcement must bind safety-critical uses to the intended declarations, not merely to identifiers with the same spelling.**

---

# 1. Baseline and preservation gate

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`
- index: empty
- accumulated tracked delta: 55 modified / 2 deleted
- shared submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check` passes.

Verify the Prompt 24 baseline manifest:

`/private/tmp/messagelens-onboarding-prompt24-baseline.v1bQ6f/MANIFEST.json`

SHA-256:

`062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`

and all earlier preservation manifests remain unchanged.

Create a fresh Prompt 26 baseline manifest outside the repository before edits.

If any runtime production or behavioral-test byte changed since Prompt 25, STOP AND REPORT.

---

# 2. Strict change scope

## Expected MUST-change file

- `test/architecture/onboarding_journey_authority_architecture_test.dart`

## MAY change only if the binding-resolution helper already belongs there

- a shared architecture-test helper file, but only if repository conventions clearly place analyzer resolution utilities there.

## MUST NOT change

- all production source;
- all behavioral runtime tests;
- Feature 35 runtime/tests;
- Onboarding Journey implementation;
- Environment implementation;
- failure storage;
- attachment location;
- presentation;
- persistence/schema;
- generated files.

If the three binding rules cannot be implemented without changing production source, STOP AND REPORT.

---

# 3. Choose the smallest binding-aware analyzer mechanism

The current architecture test uses parse-only AST in several places.

For the three safety-critical checks in this prompt, use analyzer resolution only as narrowly as necessary to establish declaration identity.

Prefer an existing test-time analyzer mechanism already available in the repository, for example:

- resolved compilation units;
- `AnalysisContextCollection`;
- library/session element resolution;
- resolved AST nodes whose identifiers/invocations expose referenced elements.

Do not add a runtime dependency.
Do not change `pubspec.yaml` unless analyzer is genuinely unavailable—which is not expected given the existing architecture tests.

Do not convert the entire architecture suite to a full semantic analyzer if three narrowly resolved source groups are sufficient.

Record exactly what analyzer API/mechanism is used.

---

# 4. SHOULD FIX 1A — bind the protected-I/O checkpoint to the formal callback

For each audited specialist/root that accepts:

`requirePersistentArchiveStoreAdmission`

the architecture policy must prove that the invocation immediately governing a protected read/write resolves to the **formal callback parameter declaration** for that audited method/function.

The rule must not accept merely:

```text
identifier spelling ==
"requirePersistentArchiveStoreAdmission"
```

Required semantic identity:

```text
invocation target element
    ==
formal parameter element for the approved proof callback
```

or the exact analyzer-equivalent relationship.

This must work for both accepted production forms:

```dart
requirePersistentArchiveStoreAdmission();
```

and, where valid and intended:

```dart
requirePersistentArchiveStoreAdmission?.call();
```

But nullable invocation is accepted only where the admitted caller is mechanically proven to propagate a non-null callback on the reviewed admitted path.

---

# 5. SHOULD FIX 1B — prove non-null callback propagation into admitted helpers

Prompt 25 identified this concrete invisible regression:

```dart
await _availableCustomState(
  ...,
  requirePersistentArchiveStoreAdmission: null,
);
```

while the callee still contains a null-aware callback invocation.

Close it.

For every admitted helper whose proof parameter is nullable because ordinary non-admitted consumers exist, the architecture policy must prove that the **admitted call site** supplies the exact caller proof callback and never passes `null`.

At minimum inspect the admitted attachment/custom path.

Required property:

```text
admitted caller proof parameter element
-> exact argument at admitted helper call
-> exact callee formal parameter element
-> exact callback invocation at protected I/O boundary
```

The ordinary non-admitted path may still legitimately pass/receive `null`.

Do not make the public/runtime API non-null merely to simplify the test.

---

# 6. Add protected-callback binding mutation cases

Using the same binding-aware policy as the repository audit, reject:

## Null propagation

```dart
_availableCustomState(
  ...,
  requirePersistentArchiveStoreAdmission: null,
);
```

on the admitted path.

## Local shadow

Inside an audited helper:

```dart
void requirePersistentArchiveStoreAdmission() {}
...
requirePersistentArchiveStoreAdmission();
await _settingsStore.writeSetting(...);
```

where the local declaration shadows the formal callback.

## Same-named unrelated callable

```dart
final requirePersistentArchiveStoreAdmission = fakeProof;
requirePersistentArchiveStoreAdmission();
await _settingsStore.writeSetting(...);
```

if the binding is not the audited formal parameter.

## Receiver lookalike

Retain rejection of:

```dart
fake.requirePersistentArchiveStoreAdmission();
```

The valid production callback binding must pass.

Mutation failures must be specifically attributable to declaration identity, not unrelated syntax or dominance rules.

---

# 7. SHOULD FIX 2 — bind command-guard calls and values to reviewed declarations

Prompt 25 found that the Boolean structure is now correct, but same-spelled local helpers can shadow the real authority helpers.

For each of the five command mutation boundaries, resolve the relevant calls and operands to their declaration origins.

At minimum bind:

- `_commandAndActionAreCurrent`
- `_reportAllowsCommand`
- each supplied command-specific predicate:
  - `_reportAllowsInitialImport`
  - `_reportAllowsReimport`
  - continuation predicate/helper
  - `_reportAllowsAutomaticRecovery`
- capability `requireOperation` call;
- command token/context/binding/operation/controller variables where the rule depends on exact provenance;
- mutation target method/receiver:
  - `begin`
  - `resume`
  - `resetDerivedData`

The architecture rule should care that the expression references the **reviewed declaration/value**, not that the local variable happens to be named `token`, `context`, `binding`, `controller`, or `admittedReport`.

---

# 8. Preserve strict Boolean/control-flow enforcement while removing spelling overfit

Keep Prompt 24's already-correct enforcement of:

- rejecting disjunction;
- unary negation / inequality polarity;
- required conjunct set;
- terminal return;
- fall-through valid branch;
- no await after final guard;
- permitted synchronous assignment only where reviewed.

But replace literal local-variable-name dependencies with element/binding identity where practical.

A harmless rename such as:

```text
token -> commandToken
context -> actionContext
binding -> retainedBinding
```

must not fail solely because spelling changed, if resolved provenance and Boolean semantics are identical.

Conversely, a same-spelled shadow declaration must fail.

---

# 9. Add command-binding mutation cases

Using the same resolved policy, reject:

## Shadowed currentness helper

```dart
bool _commandAndActionAreCurrent(...) => true;
```

declared locally or otherwise shadowing the reviewed helper.

## Shadowed report helper

A local `_reportAllowsCommand` that always returns true.

## Shadowed command-specific predicate

A same-named local `_reportAllowsInitialImport` or equivalent command predicate with permissive semantics.

## Lookalike mutation target

A local/fake controller exposing `begin`/`resume` with the right spelling but not the reviewed controller binding.

Also add at least one **positive harmless rename** fixture proving that local identifier renaming does not fail when binding provenance and semantics remain the same.

Do not loosen the safety rule merely to permit arbitrary refactors.

---

# 10. SHOULD FIX 3 — bind the critical feedback chain to the real container/provider

Prompt 25 found that this named chain can still be faked:

```text
container.listen(onboardingEnvironmentReportProvider, ...)
-> recorder
-> returned fixture
-> maintenance wait
```

because `container` and provider identity are not resolved.

The architecture rule must prove:

1. the `container` used for the listener is the actual `ProviderContainer` constructed/owned by `_JourneyFixture.create`;
2. the listened provider resolves to the real top-level `onboardingEnvironmentReportProvider`;
3. the listener callback writes into the exact recorder returned by the fixture;
4. the critical tests obtain that exact returned recorder and call `waitFor` against it;
5. no fake/shadow provider or fake/shadow container can satisfy the rule.

Use declaration/element identity, not symbol spelling.

---

# 11. Add feedback-origin binding mutation cases

Reject:

## Shadowed provider

A local variable/getter/function named:

`onboardingEnvironmentReportProvider`

that resolves to a fake provider.

## Fake local container

A local object named `container` exposing a `listen` method but not the actual fixture ProviderContainer.

## Alternate ProviderContainer

The fixture creates/returns one ProviderContainer but the recorder listener is attached to another unrelated ProviderContainer.

## Recorder fed by fake provider

The returned recorder and critical waits are correctly connected, but the listener source is a fake provider.

Retain Prompt 24's disconnected/dead-recorder mutations.

Add a positive case with harmless local variable renaming if the architecture fixture supports it.

---

# 12. Keep the real-feedback-mode override restrictions

Retain and recheck:

- `onboardingEnvironmentReportProvider` not overridden in real-feedback mode;
- `archiveMutationCoordinatorProvider` not overridden;
- `exclusiveAuthorityRegistryProvider` not overridden;
- `fireImmediately: true` behavior;
- listener subscription retained for fixture lifetime;
- four critical tests use real-feedback mode and assert maintenance through the returned real recorder.

Binding-resolution changes must strengthen—not replace—these existing rules.

---

# 13. Regression spot-check of already-passed architecture policies

Do not redesign them.

Spot-check:

- concrete bookmark settings-write audit;
- checkpoint dominance after latest await;
- command Boolean polarity/conjunction;
- root-aware traversal;
- `OnboardingStatus` semantic-root census;
- raw conversation-graph evidence census.

No runtime design review is required.

---

# 14. Architecture overfitting target

The final policy should have this property:

```text
same declaration / same semantics / harmless local rename
    -> PASS

same spelling / different declaration or provider
    -> FAIL
```

Document any remaining intentional spelling dependency.

A narrow dependency on the canonical top-level provider declaration name/path is acceptable if it is additionally resolved to that declaration.

Do not claim general semantic equivalence beyond what analyzer resolution can prove.

---

# 15. Validation

Run:

1. focused Onboarding Journey authority architecture test;
2. related Onboarding/Feature 35 architecture tests;
3. complete architecture suite;
4. `flutter analyze --no-pub`;
5. `git diff --check`;
6. formatting check on changed architecture files.

Do not rerun the full Flutter behavioral suite because runtime and behavioral tests must remain byte-identical.

If any runtime/test source unexpectedly changes, STOP AND REPORT.

---

# 16. Project Conformance enforcement review

Require explicit PASS for:

- proof callback binding identity;
- non-null proof propagation on admitted path;
- command-helper/predicate binding identity;
- mutation target provenance;
- harmless rename tolerance where tested;
- real ProviderContainer identity;
- real global Environment provider identity;
- recorder/wait data-flow connection;
- previously passed control-flow and traversal rules unchanged;
- runtime production unchanged.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 17. Preserve scope

Compare against fresh Prompt 26 baseline manifest.

Expected changed repository files:

- `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Prompt 26 response record

plus one shared architecture-test helper only if truly required.

All production and behavioral-test files must remain byte-identical.

Preservation artifacts and shared submodule must remain unchanged.

---

# 18. Leave unstaged and uncommitted

Even after green validation:

- do not stage;
- do not commit;
- do not push.

Perform one final micro-review of **binding authenticity only** before checkpoint.

Do not repeat the full runtime architecture review unless production bytes unexpectedly changed.

---

# 19. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline/preservation verification;
2. analyzer binding-resolution mechanism;
3. proof-callback declaration binding enforcement;
4. admitted non-null callback propagation enforcement;
5. proof-callback mutation results;
6. command-helper/predicate binding enforcement;
7. mutation-target provenance enforcement;
8. harmless-rename result;
9. command-binding mutation results;
10. real ProviderContainer binding enforcement;
11. real global Environment provider binding enforcement;
12. recorder/wait binding enforcement;
13. feedback-origin mutation results;
14. preserved prior architecture rules;
15. runtime/test byte-identity verification;
16. focused architecture result;
17. related architecture result;
18. complete architecture result;
19. analyzer result;
20. diff/format hygiene;
21. Project Conformance verdict;
22. BLOCKER findings;
23. SHOULD FIX findings;
24. exact Prompt 26 changed-file census;
25. baseline-manifest comparison;
26. preservation-artifact verification;
27. exact Git status;
28. stop gates encountered;
29. readiness for final binding-authenticity micro-review.

Conclude exactly:

`FINAL ONBOARDING BINDING-IDENTITY GAPS CLOSED: YES / NO`

If YES, also conclude:

`READY FOR FINAL ONBOARDING BINDING-AUTHENTICITY MICRO-REVIEW: YES / NO`

Then STOP.
