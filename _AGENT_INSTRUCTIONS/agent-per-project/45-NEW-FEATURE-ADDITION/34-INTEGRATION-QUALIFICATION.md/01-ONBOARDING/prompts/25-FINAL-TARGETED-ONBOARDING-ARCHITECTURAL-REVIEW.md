# MessageLens Feature 34 / Feature 35
## 25 — Final Targeted Onboarding Architectural Review

Prompt 24 reports that the final three Onboarding architecture-enforcement gaps
are closed without changing runtime production code or behavioral tests.

The current runtime implementation has already passed repeated architectural
review. This task is deliberately **targeted**.

Do NOT repeat the full Onboarding architecture review unless the source disproves
the premise that Prompt 24 changed architecture enforcement only.

The question is:

> **Do the Prompt 24 AST policies now mechanically reject the three exact
> regressions identified by Prompt 23, while preserving the already-reviewed
> runtime architecture unchanged?**

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `23-REPEAT-HUMAN-ARCHITECTURAL-REVIEW-AFTER-PROMPT-22.md`
- `24-CLOSE-FINAL-ONBOARDING-ARCHITECTURE-ENFORCEMENT-GAPS.md`
- current `test/architecture/onboarding_journey_authority_architecture_test.dart`
- current production source only as needed to validate what the architecture
  rules are protecting.

The already-accepted runtime invariants remain:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

> **No protected I/O may start after capability/resource authority becomes stale.**

> **A side-effect decision must use coherent current evidence and the exact
> command-specific rejecting guard.**

---

# 1. Baseline and preservation gate

Verify:

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

Verify Prompt 24 changed only:

1. `test/architecture/onboarding_journey_authority_architecture_test.dart`
2. Response 24

and that all runtime production and behavioral-test files remain byte-identical
to the Prompt 24 baseline.

Recheck Prompt 24 baseline:

`/private/tmp/messagelens-onboarding-prompt24-baseline.v1bQ6f/MANIFEST.json`

SHA-256:

`062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`

Also recheck the earlier preservation-manifest hashes.

If any runtime/test byte changed after Prompt 24, STOP AND REPORT.

---

# 2. Targeted review A — concrete bookmark settings-write enforcement

Prompt 23 found that the old architecture rule stopped at
`_persistConfigurationUnchecked(...)` rather than inspecting the real
`_settingsStore.writeSetting(...)`.

Inspect the Prompt 24 AST policy and prove that it now audits the concrete write
inside `_persistConfigurationUnchecked`.

Required property:

```text
most recent relevant await
-> approved persistent-store proof callback
-> concrete _settingsStore.writeSetting(...)
```

If an inner await appears after the inherited caller proof, the inherited proof
must no longer satisfy the write boundary.

Confirm the policy would reject:

```dart
Future<void> _persistConfigurationUnchecked(...) async {
  await someAsyncBoundary();
  await _settingsStore.writeSetting(...);
}
```

without a renewed checkpoint.

---

# 3. Review the bookmark-wrapper mutation test

Inspect the negative mutation.

Confirm:

- the mutation uses the same protected-I/O policy as the real repository audit;
- it adds an inner await in the persistence helper;
- it leaves the actual write present;
- it omits the renewed checkpoint;
- the architecture test fails for the missing dominating proof at the concrete
  write, not for unrelated syntax.

Also inspect the positive renewed-checkpoint variant and confirm it passes for
the intended reason.

---

# 4. Targeted review B — approved checkpoint identity and dominance

Prompt 23 found the prior matcher could be fooled by a same-named call that did
not actually dominate the protected operation.

Inspect the new structural rule.

Confirm an accepted checkpoint must be:

- the exact caller-supplied
  `requirePersistentArchiveStoreAdmission` callback or exact approved binding;
- invoked directly/unconditionally;
- on the fall-through path to the protected operation;
- after the most recent relevant await;
- immediately governing the protected read/write under the reviewed production
  shape.

Verify that the rule does **not** accept:

- a same-named method on another receiver;
- a conditional callback;
- a callback only in a branch that returns;
- a callback before another await;
- a dead/unreachable callback.

If callback identity is still based only on method spelling rather than parameter
origin/binding, classify that as SHOULD FIX.

---

# 5. Review checkpoint-dominance mutations

Inspect the required mutations and confirm the common policy rejects:

1. conditional checkpoint;
2. wrong receiver;
3. wrong branch;
4. await after valid checkpoint without renewed proof;
5. bookmark wrapper inner await without renewed proof.

Confirm current production paths still pass.

Look for any legal AST/control-flow equivalent that defeats the new matcher
without changing the protected operation itself.

Report a concrete counterexample if one exists.

---

# 6. Targeted review C — exact command-guard Boolean semantics

Prompt 23 found the prior command audit only required expected token fragments.

Inspect the Prompt 24 `_CommandGuardSpec` / equivalent structural model for all
five side-effect boundaries:

1. initial-import `begin`
2. reimport `begin`
3. continuation `resume`
4. automatic-recovery `begin`
5. `resetDerivedData`

Confirm architecture validation proves the actual **rejecting** semantics, not
just presence of terms.

For each boundary verify:

- required capability/current-operation proof;
- exact currentness/binding/status terms;
- exact command-specific report predicate;
- required logical operators;
- required negation/inequality polarity;
- terminating `return` on the unsafe branch;
- mutation on the valid fall-through path;
- no await between final guard and mutation.

---

# 7. Review command-guard mutation cases

Inspect the mutation suite and ensure it rejects, using the same policy:

- accepting/inverted polarity;
- unsafe `&&` / `||` substitution;
- removed semantic/report conjunct;
- removed/inverted currentness negation;
- real guard moved before an await while a harmless dummy guard remains near the
  mutation.

Confirm each fails for the expected guard-structure reason.

Try to identify one semantically unsafe Boolean rewrite that preserves the
currently inspected AST shape. If you find one, report it and FAIL.

---

# 8. Targeted review D — real-feedback recorder data flow

Prompt 23 found the fixture-realism rule did not prove that the maintenance wait
used the recorder fed by the real Environment provider.

Inspect the Prompt 24 data-flow rule.

Confirm it mechanically traces:

```text
onboardingEnvironmentReportProvider
-> real container.listen
-> callback records `next`
-> exact recorder object
-> recorder returned in _JourneyFixture
-> critical test obtains that returned recorder
-> waitFor(maintenanceInProgress) on that exact recorder
```

The architecture rule must reject a fixture where the real recorder is dead and
a fake recorder drives the wait.

---

# 9. Review disconnected-recorder mutations

Inspect the mutation cases and confirm they reject:

1. dead real recorder + fake wait source;
2. real and fake recorder both exposed, critical wait uses fake;
3. real-mode flag leaves provider unoverridden but returned handle comes from
   fake source;
4. unrelated fake source writes into the otherwise-real recorder;
5. ignored real-feedback flag;
6. authority-provider replacement.

Confirm the fully connected positive fixture passes.

Look for any way a test could satisfy the recorder/provider symbol requirements
while the asserted wait still comes from unrelated evidence.

If one exists, report it as SHOULD FIX.

---

# 10. Regression spot-check — traversal and semantic census

Do not redesign these already-passed rules.

Spot-check that Prompt 24 did not weaken:

- root-aware `_transitiveLocalDependencies`;
- root traversal before `stopAt`;
- `shellPath` traversal;
- semantic roots excluded from trusted-stop roots;
- `OnboardingStatus` semantic consumer discovery;
- raw conversation-graph controller/barrel evidence census.

The same real configuration must still be used by virtual mutation tests.

---

# 11. Runtime byte-identity sanity

Confirm Prompt 24 made no production or behavioral-test changes.

The following runtime conclusions remain accepted and should not be re-litigated
unless byte identity fails:

- concrete protected-I/O proof checkpoints are correct;
- double-sample material evidence is coherent;
- synchronous facts are read after final material await;
- four real self-maintenance loops are proven;
- command semantics are correct;
- Journey remains sole semantic authority;
- persistence/restart unchanged.

---

# 12. Architecture-test overfitting review

Check the three strengthened rules for both underreach and overfitting.

The architecture policy should reject semantic regressions while tolerating
harmless changes such as:

- formatting;
- local variable renaming where binding identity remains equivalent;
- comments;
- unrelated private helper refactors that preserve the protected operation and
  proof/control-flow structure.

Do not require broad refactor tolerance if it would weaken the safety boundary,
but report any obviously source-spelling-dependent rule that still claims
semantic enforcement.

---

# 13. Validation evidence

Prompt 24 reports:

- focused Onboarding authority architecture: 25 passed;
- related architecture: 66 passed;
- complete architecture: 554 passed;
- analyzer: clean;
- `git diff --check`: PASS;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0;
- production/runtime changes: 0;
- behavioral-test changes: 0.

Do not rerun the full Flutter suite.

Run only the focused architecture test if a source-inspection ambiguity requires
confirmation.

---

# 14. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. baseline/preservation verdict;
2. concrete bookmark-write enforcement verdict;
3. bookmark-wrapper mutation verdict;
4. checkpoint identity/dominance verdict;
5. checkpoint mutation verdict;
6. command-guard structural verdict;
7. command-guard mutation verdict;
8. real-feedback recorder-flow verdict;
9. disconnected-recorder mutation verdict;
10. traversal/census regression verdict;
11. runtime byte-identity verdict;
12. architecture overfitting/underreach verdict;
13. concrete BLOCKER findings;
14. concrete SHOULD FIX findings;
15. OPTIONAL findings;
16. narrow tests rerun, if any;
17. exact Git status;
18. preservation-artifact verification;
19. final checkpoint recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`FINAL TARGETED ONBOARDING ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT ACCUMULATED ONBOARDING CORRECTION: YES / NO`

Then STOP.
