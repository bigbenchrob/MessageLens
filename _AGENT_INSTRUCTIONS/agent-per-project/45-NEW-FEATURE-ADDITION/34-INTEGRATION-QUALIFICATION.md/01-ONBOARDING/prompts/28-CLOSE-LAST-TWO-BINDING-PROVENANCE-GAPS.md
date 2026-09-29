# MessageLens Feature 34 / Feature 35
## 28 — Close the Last Two Binding-Provenance Gaps

Prompt 27 completed the promised binding-authenticity micro-review.

The runtime implementation remains sound and unchanged.

The proof-callback binding group is now mechanically closed.

Exactly two architecture-enforcement SHOULD FIX findings remain:

1. command value / mutation-target provenance can still be forged because
   `_bindingExpressionKey` falls back from resolved declaration identity to the
   identifier's source spelling, and some provider/report provenance checks test
   only whether an initializer *contains* a canonical reference rather than
   proving the resulting value came from it;
2. the critical feedback chain can still be disconnected because the recorder
   write checks the spelling `next` instead of the listener callback formal's
   resolved element, and a critical fixture local can be accepted when its
   initializer merely contains a real `_JourneyFixture.create` call whose result
   is discarded.

This task closes **only those two concrete gaps**.

This is the end of architecture-enforcement hardening for this correction.

Do NOT invent a new review category.
Do NOT reopen runtime design.
Do NOT reopen Journey authority.
Do NOT reopen Feature 35.
Do NOT revisit evidence coherence or protected-I/O placement.
Do NOT modify production code.
Do NOT modify behavioral tests.
Do NOT modify runtime helpers.
Do NOT change presentation, persistence, schema, archive policy, resource
actions, native authority, generated source, or dependencies.
Do NOT perform optional cleanup.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `27-FINAL-ONBOARDING-BINDING-AUTHENTICITY-MICRO-REVIEW.md`
- `26-CLOSE-FINAL-BINDING-IDENTITY-ENFORCEMENT-GAPS.md`
- current `test/architecture/onboarding_journey_authority_architecture_test.dart`

Governing rule:

> **For safety-critical provenance, an unresolved semantic role must fail closed.
> Source spelling may locate canonical declarations, but it may not substitute
> for declaration identity or value provenance.**

---

# 1. Baseline and preservation gate

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD:
  `276fa1b820b07bf14f41fe216192456b5415e290`
- index:
  empty
- accumulated tracked delta:
  55 modified / 2 deleted
- shared submodule:
  clean at `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check` passes.

Verify Prompt 26 baseline:

`/private/tmp/messagelens-onboarding-prompt26-baseline.OckfNG/MANIFEST.json`

SHA-256:

`1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`

and all earlier preservation manifests remain unchanged.

Create a fresh Prompt 28 baseline manifest outside the repository before edits.

If any production/runtime or behavioral-test byte changed since Prompt 27,
STOP AND REPORT.

---

# 2. Strict scope

## Expected MUST-change file

- `test/architecture/onboarding_journey_authority_architecture_test.dart`

## MAY change

Nothing else unless a pre-existing shared architecture helper already contains
the exact resolved-binding utility needed. Prefer keeping the change in the
Onboarding architecture test.

## MUST NOT change

- all production source;
- all behavioral tests;
- Feature 35 runtime/tests;
- Journey implementation;
- Environment implementation;
- failure storage;
- attachment location;
- presentation;
- persistence/schema;
- generated source;
- dependencies.

If production changes appear necessary, STOP AND REPORT.

---

# 3. Close gap 1A — remove source-name fallback for unresolved semantic roles

Prompt 27 identified:

```dart
return element == null ? unwrapped.name : roles[element] ?? unwrapped.name;
```

or its exact equivalent.

That fallback is unsafe for safety-critical provenance.

Replace the safety-critical role resolution rule with fail-closed semantics:

```text
resolved element maps to an approved semantic role
    -> use that role

resolved element is absent from approved role map
    -> provenance mismatch / architecture violation
```

Do not fall back to the identifier spelling.

If some reviewed expression is not a simple identifier, handle only the exact
approved resolved shape.

Do not add a generalized name-based escape hatch.

---

# 4. Add the exact same-spelling/different-declaration mutation

Using the same resolved command policy as repository source, reject:

```dart
final token = unrelatedTokenValue;
...
if (!_commandAndActionAreCurrent(
      token: token,
      ...
    )) {
  return;
}
```

where this new `token` declaration is **not** the reviewed command token even
though it has the canonical spelling.

The mutation must fail because its resolved element is not mapped to the token
role.

Retain the existing harmless-rename positive case.

Required result:

```text
renamed authentic token       -> PASS
same-spelled unrelated token  -> FAIL
```

---

# 5. Close gap 1B — prove value-producing initializer provenance

Prompt 27 found that some roles are assigned when an initializer merely
**contains** a canonical provider/report-reader reference.

That is insufficient.

For each safety-critical value whose provenance matters, prove that the
initializer's resulting value comes from the reviewed source.

At minimum inspect:

- operation controller;
- admitted report;
- reset report;
- reset service target;
- any other value currently assigned a semantic role by a
  “contains canonical invocation/reference” rule.

Accept only narrow reviewed forms such as:

```dart
final controller =
    await ref.read(onboardingOperationControllerProvider.future);
```

or the exact current production equivalent, with:

- the provider resolving to the canonical provider declaration;
- the `ref.read` / relevant Riverpod access resolving to the intended API where
  that matters;
- the initializer expression itself producing the assigned value.

Do not accept:

```dart
final controller = condition
    ? await ref.read(onboardingOperationControllerProvider.future)
    : unrelatedController;
```

merely because the canonical provider appears in one branch.

Do not accept a wrapper expression that evaluates/discards the canonical read
and returns another same-typed value.

---

# 6. Bind the reset-service accessor to the real provider-read path

Prompt 27 specifically found that the reset mutation target can pass when a
same-typed fake accessor receives:

`messageDataResetServiceProvider`

but returns another service.

Strengthen provenance so the receiver of `resetDerivedData()` is proven to be
the value produced by the exact reviewed Riverpod provider-read path.

Where possible prove:

```text
canonical messageDataResetServiceProvider element
-> actual reviewed Ref.read/provider access
-> resulting MessageDataResetService value
-> resetDerivedData invocation receiver
```

A same-named/same-typed fake accessor must fail.

Do not rely solely on:

- method name;
- provider argument spelling;
- interface type.

---

# 7. Add value-provenance mutation cases

Using the common resolved policy, reject at minimum:

## Conditional controller provenance

```dart
final controller = condition
    ? await ref.read(onboardingOperationControllerProvider.future)
    : unrelatedController;
```

when the mutation path may use the unrelated value.

## Canonical read discarded by wrapper

A helper/closure invokes the canonical provider/report reader but returns an
unrelated same-typed object.

## Report-reader containment only

An admitted/reset report initializer mentions the canonical reader in a branch
or subexpression but returns unrelated evidence.

## Fake reset accessor

A same-typed fake accessor accepts `messageDataResetServiceProvider` but returns
another reset service.

The valid production forms must pass.

---

# 8. Preserve command Boolean/control-flow enforcement

Do not weaken Prompt 24/26 rules:

- exact helper/predicate declaration identity;
- rejecting Boolean structure;
- polarity;
- required atoms;
- terminal return;
- mutation on valid fall-through path;
- no await after final guard;
- real mutation method provenance.

This task changes only value provenance feeding those authentic calls.

---

# 9. Close gap 2A — bind recorder payload to the listener callback formal

Prompt 27 found the recorder write still accepts source spelling:

```dart
globalEnvironmentReports.record(next)
```

without proving that `next` is the exact listener callback formal.

Resolve the listener callback's `next` formal parameter declaration.

Require the argument passed to the authenticated recorder's `record(...)` call
to resolve to that exact formal element.

Reject a same-named nested/local `next`.

Do not use `toSource() == 'next'` as safety proof.

---

# 10. Add the shadowed-listener-payload mutation

Using the same real-feedback policy, reject a fixture equivalent to:

```dart
container.listen(
  onboardingEnvironmentReportProvider,
  (previous, next) {
    final next = fakeEnvironmentReport;
    globalEnvironmentReports.record(next);
  },
);
```

or a legal equivalent demonstrating same-spelled shadowing.

The failure must be because the `record` argument does not resolve to the
listener callback's report formal.

The valid current listener must pass.

---

# 11. Close gap 2B — bind the critical fixture local directly to create result

Prompt 27 found that a critical-test local can be accepted when its initializer
merely contains one authentic `_JourneyFixture.create(...)` call.

Require direct result provenance.

Accept the exact reviewed production form, for example:

```dart
final fixture = await _JourneyFixture.create(...);
```

or its exact semantic equivalent where analyzer resolution proves the assigned
value is the create call result.

Do not accept:

```dart
final fixture = await (() async {
  await _JourneyFixture.create(...); // discarded
  return fakeFixture;
})();
```

Do not accept conditionals/wrappers where the actual returned value can come
from another fixture.

The local used for:

`fixture.globalEnvironmentReports.waitFor(...)`

must derive directly from the reviewed create invocation.

---

# 12. Add discarded-create / fake-fixture mutations

Reject:

## Real create discarded

The initializer invokes the real `_JourneyFixture.create` but returns another
fixture.

## Conditional fixture source

One branch uses real create and another returns fake/unrelated fixture.

## Wrapper returns fake

A wrapper calls real create for side effect then returns fake.

Retain Prompt 24/26 mutations for:

- dead real recorder;
- fake wait recorder;
- fake returned recorder;
- unrelated recorder writer;
- fake provider;
- fake/alternate container;
- ignored feedback flag;
- authority overrides.

The valid direct create result must pass.

---

# 13. Preserve the already-closed proof-callback group

Prompt 27 found this group mechanically closed.

Do not redesign it.

Spot-check only:

- formal callback declaration identity;
- non-null admitted propagation;
- shadow/alias rejection;
- post-await dominance.

No new proof-callback work is required.

---

# 14. Remaining source-spelling dependencies

After this correction, safety-critical local provenance must not fall back to
spelling.

Acceptable name use remains limited to locating canonical declarations and API
contract members before element comparison.

Explicitly report every remaining safety-critical use of:

- `.name`;
- `toSource()`;
- string containment;
- source-text matching.

For each, classify it as:

- harmless locator/presentation/testing utility; or
- semantic provenance.

Any remaining semantic-provenance use of source spelling is SHOULD FIX.

Do not audit unrelated architecture rules outside the three binding groups.

---

# 15. Validation

Run:

1. focused Onboarding Journey authority architecture test;
2. related Onboarding/Feature 35 architecture tests;
3. complete architecture suite;
4. `flutter analyze --no-pub`;
5. `git diff --check`;
6. formatting check on changed architecture file.

Do not rerun the full Flutter behavioral suite.

Runtime and behavioral-test files must remain byte-identical.

---

# 16. Final bounded conformance decision

This correction is complete when the two Prompt 27 SHOULD FIX findings are
mechanically closed:

1. authentic value/mutation-target provenance;
2. authentic listener-payload and fixture-create-result provenance.

Do not create another category of architecture-test perfection work.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

within this bounded scope.

---

# 17. Preserve scope

Compare against the fresh Prompt 28 baseline manifest.

Expected changed repository files:

1. `test/architecture/onboarding_journey_authority_architecture_test.dart`
2. Prompt 28 response record

All production, generated, behavioral-test, prior-response, and unrelated
architecture files must remain byte-identical.

Preservation artifacts and shared submodule must remain unchanged.

---

# 18. Leave unstaged and uncommitted

Even after green validation:

- do not stage;
- do not commit;
- do not push.

The response should include enough direct evidence to make the next action a
checkpoint decision, not another broad architectural audit.

---

# 19. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. baseline/preservation verification;
2. removal of source-name role fallback;
3. same-spelling/unrelated-value mutation result;
4. controller provenance enforcement;
5. report provenance enforcement;
6. reset-service provenance enforcement;
7. value-provenance mutation results;
8. preserved command control-flow rules;
9. listener-payload binding enforcement;
10. shadowed-`next` mutation result;
11. fixture-create-result provenance enforcement;
12. discarded-create/fake-fixture mutation results;
13. preserved proof-callback group;
14. remaining safety-critical spelling-dependency audit;
15. runtime/test byte-identity verification;
16. focused architecture result;
17. related architecture result;
18. complete architecture result;
19. analyzer result;
20. diff/format hygiene;
21. Project Conformance verdict;
22. BLOCKER findings;
23. SHOULD FIX findings;
24. exact Prompt 28 changed-file census;
25. baseline-manifest comparison;
26. preservation-artifact verification;
27. exact Git status;
28. stop gates encountered;
29. checkpoint readiness.

Conclude exactly:

`LAST ONBOARDING BINDING-PROVENANCE GAPS CLOSED: YES / NO`

If YES, also conclude:

`READY TO CHECKPOINT ACCUMULATED ONBOARDING CORRECTION: YES / NO`

Then STOP.
