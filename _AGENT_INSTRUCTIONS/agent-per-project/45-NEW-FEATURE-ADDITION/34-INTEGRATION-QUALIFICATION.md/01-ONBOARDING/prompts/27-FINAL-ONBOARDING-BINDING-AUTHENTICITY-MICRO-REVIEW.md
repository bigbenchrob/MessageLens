# MessageLens Feature 34 / Feature 35
## 27 — Final Onboarding Binding-Authenticity Micro-Review

Prompt 26 reports that the final three binding-identity enforcement gaps are closed using analyzer-resolved declaration identity, with no production, runtime, behavioral-test, dependency, generated-source, or shared-helper changes.

This task is the promised **final micro-review**.

It is intentionally narrow.

Do NOT repeat the runtime architectural review.
Do NOT reopen Journey design.
Do NOT reopen Feature 35 design.
Do NOT revisit evidence coherence, protected-I/O placement, or restart semantics unless Prompt 26 unexpectedly changed production/runtime bytes.

The only question is:

> **Do the three safety-critical architecture policies now bind to the intended declarations rather than merely to same-spelled identifiers, while preserving the already-approved structural/control-flow rules?**

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `25-FINAL-TARGETED-ONBOARDING-ARCHITECTURAL-REVIEW.md`
- `26-CLOSE-FINAL-BINDING-IDENTITY-ENFORCEMENT-GAPS.md`
- current `test/architecture/onboarding_journey_authority_architecture_test.dart`

Inspect production/test source only as needed to verify the declaration identities the architecture policy resolves.

---

# 1. Baseline and preservation gate

Verify:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`
- index: empty
- accumulated tracked delta: 55 modified / 2 deleted
- shared submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check` passes.

Verify Prompt 26 changed only:

1. `test/architecture/onboarding_journey_authority_architecture_test.dart`
2. Response 26

and that all production/runtime and behavioral-test files remain byte-identical to the Prompt 26 baseline.

Recheck the fresh Prompt 26 baseline manifest:

`/private/tmp/messagelens-onboarding-prompt26-baseline.OckfNG/MANIFEST.json`

SHA-256:

`1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`

Also verify all prior preservation-manifest hashes remain unchanged.

If any runtime/behavioral-test byte changed, STOP AND REPORT.

---

# 2. Review the analyzer-resolution mechanism

Inspect the exact analyzer APIs used.

Confirm:

- resolved units are actually used for the three reviewed policies;
- referenced/declared elements are compared, not just source strings;
- `nonSynthetic2` or equivalent normalization is appropriate for the declaration comparisons being made;
- temporary mutation fixtures are resolved in a way that preserves the semantic bindings the tests claim to exercise;
- the explicit Flutter-bundled Dart SDK path does not silently resolve against a different source universe than the repository source under test.

This review does not require converting unrelated parse-only architecture rules.

---

# 3. Micro-review A — proof-callback declaration authenticity

Inspect the protected-I/O callback rule.

Confirm that the checkpoint governing a protected read/write resolves to the formal parameter declaration for the reviewed `requirePersistentArchiveStoreAdmission` callback.

Verify both accepted forms:

```dart
requirePersistentArchiveStoreAdmission();
```

and the intended nullable form:

```dart
requirePersistentArchiveStoreAdmission?.call();
```

resolve to the same formal callback element where applicable.

Confirm a same-spelled local declaration or alias resolves differently and is rejected.

The architecture rule must no longer derive authority from identifier spelling.

---

# 4. Micro-review B — admitted non-null callback propagation

Trace the resolved admitted attachment/custom chain:

```text
readAttachmentArchiveLocationEvidenceWithAdmission
-> controller.load
-> _resolveCustom
-> _availableCustomState
-> protected-I/O checkpoint invocation
```

Confirm at each admitted call site:

- the named argument resolves to the caller's exact proof callback declaration;
- `null` is rejected on the admitted path;
- an unrelated alias/callable is rejected;
- the callee formal parameter is the same binding ultimately invoked before the protected operation.

Confirm the ordinary non-admitted nullable path is still allowed and is not mistaken for an admitted call.

---

# 5. Review proof-callback binding mutations

Inspect the actual resolved mutation fixtures.

Confirm the common policy rejects specifically because of binding identity:

1. admitted `null`;
2. same-named nested local function;
3. same-named unrelated callable alias;
4. wrong receiver lookalike.

Also confirm the earlier dominance/await mutations remain active.

Look for any obvious way to shadow or alias the callback while preserving the resolved element expected by the rule. If one exists, report it.

---

# 6. Micro-review C — command-helper and predicate authenticity

For all five protected command mutation boundaries, inspect how the architecture policy resolves:

- `_commandAndActionAreCurrent`;
- `_commandRetainsBinding`;
- `_commandOwnsBoundOperation`;
- `_reportAllowsCommand`;
- each command-specific predicate;
- continuation predicate/lambda where applicable;
- `ArchiveMutationCapability.requireOperation`;
- controller/reset service provenance;
- command token/context/binding/report/operation values where provenance matters.

Confirm that a same-spelled local helper resolves to a different declaration and therefore fails.

Confirm the rule is no longer dependent on local variable spellings such as `token`, `context`, `binding`, `controller`, or `admittedReport` when resolved provenance is equivalent.

---

# 7. Micro-review D — mutation-target provenance

Confirm:

- `begin` resolves to `OnboardingOperationSnapshotController.begin`;
- `resume` resolves to `OnboardingOperationSnapshotController.resume`;
- `resetDerivedData` resolves to `MessageDataResetService.resetDerivedData`;
- controller/service values originate from the reviewed providers.

A fake object exposing a same-spelled method must not satisfy the rule.

Also confirm this provenance enforcement works together with, rather than replacing, the already-approved Boolean/control-flow guard enforcement.

---

# 8. Review harmless-rename tolerance

Inspect the positive resolved mutation fixture.

Confirm it renames local values such as token, action context, controller, admitted report, and capability while preserving declaration provenance and exact Boolean semantics.

It should pass because binding identity is unchanged.

This is important evidence that the architecture policy now distinguishes:

```text
same declaration / harmless local rename
```

from:

```text
same spelling / different declaration
```

---

# 9. Review command-binding mutations

Inspect the negative fixtures for:

- shadowed `_commandAndActionAreCurrent`;
- shadowed `_reportAllowsCommand`;
- shadowed command-specific predicate;
- unrelated token/value;
- lookalike controller.

Confirm each fails because of resolved declaration/provenance mismatch.

Also spot-check that Prompt 24's structural mutations remain rejected:

- wrong polarity;
- wrong Boolean operator;
- missing conjunct;
- missing negation;
- stale guard before await.

---

# 10. Micro-review E — real ProviderContainer authenticity

Inspect the critical-feedback fixture policy.

Confirm the `listen` invocation resolves to Riverpod's actual `ProviderContainer.listen`.

Confirm its receiver resolves to the exact local `ProviderContainer` instance constructed by `_JourneyFixture.create`.

Confirm the same container element is carried by the returned fixture where the policy requires that identity.

Reject fake local objects with `listen`, different ProviderContainer instances used only for observation, and same-spelled locals with unrelated provenance.

---

# 11. Micro-review F — real global Environment provider authenticity

Confirm the listened provider resolves to the canonical top-level `onboardingEnvironmentReportProvider` declaration from the expected library.

A local variable/getter/function with the same spelling must resolve to a different element and fail.

Verify the canonical provider/library is located by a stable repository identity and then checked by resolved declaration element—not accepted merely because of the canonical spelling.

---

# 12. Micro-review G — recorder/wait binding chain

Inspect the full resolved chain:

```text
actual ProviderContainer.listen(actual onboardingEnvironmentReportProvider)
-> exact recorder local
-> listener callback records `next`
-> exact recorder returned in _JourneyFixture
-> exact fixture field obtained by critical test
-> exact waitFor declaration called on that field
-> maintenanceInProgress assertion
```

Confirm the listener subscription retained by the fixture is the one returned by that exact listener.

The policy must reject a real provider feeding one recorder while the tests wait on another.

---

# 13. Review feedback-origin mutations

Inspect the binding-aware mutations for:

- shadowed/fake provider;
- fake local container;
- alternate real ProviderContainer;
- recorder fed by fake provider.

Confirm Prompt 24's disconnected-recorder mutations remain active:

- dead real recorder;
- fake wait recorder;
- fake returned recorder;
- unrelated writer;
- ignored real-feedback flag;
- authority override.

The fully connected positive fixture must pass.

---

# 14. Review remaining intentional name dependencies

Prompt 26 states the only intentional name dependencies are used to **locate** canonical declarations/API members before comparing resolved element identity.

Inspect this claim.

Acceptable examples:

- canonical library/path;
- class/method/API member name used to locate the declaration;
- enum/named-argument name used as part of a reviewed API contract.

Not acceptable:

- local variable spelling standing in for provenance;
- helper spelling standing in for declaration identity;
- provider spelling standing in for real provider origin.

Report any remaining safety-critical source-spelling dependency.

---

# 15. Regression spot-check only

Do not reopen these designs.

Spot-check that the resolved-policy changes did not weaken:

- concrete bookmark settings-write audit;
- checkpoint dominance after latest await;
- command Boolean polarity/conjunction;
- terminal return/fall-through;
- no await after final guard;
- root-aware traversal;
- `OnboardingStatus` semantic-root census;
- raw graph evidence census;
- real-feedback override restrictions.

---

# 16. Runtime/test byte-identity sanity

Confirm every production file and behavioral test remains byte-identical to the Prompt 26 baseline.

If true, preserve all previously accepted runtime conclusions without repeating their architectural review.

If false, STOP AND REPORT.

---

# 17. Validation evidence

Prompt 26 reports:

- focused Onboarding authority architecture: 25 passed;
- related architecture: 66 passed;
- complete architecture: 554 passed;
- analyzer: clean;
- `git diff --check`: PASS;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0;
- runtime changes: 0;
- behavioral-test changes: 0.

Do not rerun the full Flutter behavioral suite.

Run only the focused architecture test if source inspection exposes one concrete ambiguity that execution can resolve.

---

# 18. Final checkpoint decision rule

This micro-review should PASS only if all three binding-authenticity groups are mechanically closed:

1. proof callback and admitted non-null propagation;
2. command helper/predicate/value/mutation provenance;
3. real ProviderContainer/provider/recorder/wait provenance.

Do not invent a new review category beyond those three.

A new finding is checkpoint-blocking only if it demonstrates a concrete way the architecture policy can accept a safety regression while the reviewed runtime shape remains apparently compliant.

Do not continue an open-ended search for increasingly hypothetical test-of-test concerns.

---

# 19. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline/preservation verdict;
2. analyzer-resolution verdict;
3. proof-callback declaration verdict;
4. admitted non-null propagation verdict;
5. proof-callback mutation verdict;
6. command-helper/predicate binding verdict;
7. mutation-target provenance verdict;
8. harmless-rename verdict;
9. command-binding mutation verdict;
10. ProviderContainer authenticity verdict;
11. global Environment provider authenticity verdict;
12. recorder/wait binding verdict;
13. feedback-origin mutation verdict;
14. remaining intentional-name-dependency verdict;
15. prior-policy regression verdict;
16. runtime/test byte-identity verdict;
17. concrete BLOCKER findings;
18. concrete SHOULD FIX findings;
19. OPTIONAL findings;
20. narrow tests rerun, if any;
21. exact Git status;
22. preservation-artifact verification;
23. final checkpoint recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`FINAL ONBOARDING BINDING-AUTHENTICITY MICRO-REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT ACCUMULATED ONBOARDING CORRECTION: YES / NO`

Then STOP.
