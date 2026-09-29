# 10 — CORRECT POST-AWAIT PREREQUISITE CURRENTNESS AND SEMANTIC-CENSUS FINDINGS

You are continuing the clean-slate onboarding integration qualification.

This is a CORRECTION prompt following:

`09-REPEAT-HUMAN-ARCHITECTURAL-REVIEW.md`

That repeated architectural review returned:

**FAIL**

Do not broaden scope.

The Prompt 08 corrections remain accepted except for the specific findings below.

---

# BASELINE / REPOSITORY STATE

Preserve the reviewed baseline exactly unless this prompt explicitly requires a change.

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty
- Tracked worktree before this correction:
  - 46 modified files
  - 2 deleted files
- Intended new implementation/test files already present:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Shared-instructions submodule:
  - clean
  - `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch:
  - `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`
  - 21,137 bytes
  - SHA-256:
    `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`
  - must remain unchanged and unapplied
- No staging, commit, push, merge, database mutation, archive mutation, or application-state mutation has occurred.

The Prompt 09 review response itself is the only review artifact added after Prompt 08.

Do not touch unrelated untracked prompts, responses, `00-PREPARATION`, `.vscode/settings.json`, or other unrelated work.

---

# AUTHORITATIVE FINDINGS FROM PROMPT 09

## BLOCKER 1 — Prerequisites can regress after admitted validation and before execution

The coordinator correctly validates prerequisites before admission and inside admitted callbacks, but some command paths then perform another `await` while acquiring the operation controller.

During that await:

1. a new environment report may arrive;
2. `_latestReport` is updated;
3. because a command token is active, the visible Journey occurrence intentionally does not change;
4. command/action provenance may therefore still appear current;
5. execution can proceed even though the latest coherent prerequisite truth is now blocked.

Affected paths identified by Prompt 09:

- initial import / Retry;
- reimport / Retry;
- Continue Setup;
- automatic-recovery Retry.

The relevant mutation boundaries are:

- `begin`
- `resume`
- automatic derived-data reset / automatic recovery mutation

The architectural requirement is:

> The latest coherent prerequisite report must be revalidated after every relevant await and immediately before operational mutation.

There must be no intervening await between the final prerequisite-currentness decision and the corresponding mutation boundary.

A prerequisite regression in that window must prevent the mutation.

---

# REQUIRED BLOCKER CORRECTION

## 1. Introduce one coordinator-owned prerequisite-currentness helper

Create or consolidate one coordinator-owned helper that answers, for an intended onboarding command:

> Does the latest coherent prerequisite report still permit this exact command to execute now?

Do not create another authority.

The helper must consume the coordinator's current coherent prerequisite/environment truth.

It must preserve the established authority relationship:

`operation/environment evidence`
→ `OnboardingJourneyCoordinator`
→ `presentation`

It must not:

- create a second state machine;
- cache a competing prerequisite truth;
- make presentation authoritative;
- derive currentness from stale rendered Episode state alone;
- weaken operation identity or action-context checks.

Use the existing typed prerequisite Episode semantics.

Do not collapse FDA, Messages, history, Contacts, or other prerequisite blockers into an untyped generic error if the current architecture already provides a truthful typed Episode.

---

## 2. Apply the helper at every relevant execution boundary

For every affected command path, prerequisite validity must be checked:

1. at the existing admission point where appropriate; AND
2. after controller acquisition / any other relevant await; AND
3. immediately before operational mutation.

Specifically inspect and correct:

### Initial import / Retry

Current Prompt 09 finding:

- controller acquisition is awaited;
- only command/action provenance is then checked;
- `begin` may execute against newly blocked prerequisite truth.

Correct this.

Immediately before `begin`, require:

- command token/current command still valid;
- action context still valid;
- latest coherent prerequisites still permit initial import.

No await may occur between this final prerequisite check and `begin`.

### Reimport / Retry

Apply the equivalent correction.

Immediately before `begin`, require:

- command/action provenance current;
- latest coherent prerequisites permit reimport.

No await between final check and `begin`.

### Continue Setup

Current Prompt 09 finding:

- controller acquisition is awaited;
- command/action provenance and snapshot identity/status are checked;
- latest prerequisites are not rechecked before `resume`.

Correct this.

Immediately before `resume`, require:

- command/action current;
- exact interrupted operation identity still current;
- snapshot/session/status constraints still valid;
- latest coherent prerequisites still permit continuation.

No await between final check and `resume`.

### Automatic-recovery Retry

Inspect `_runAutomaticRecovery` and its admission/mutation sequence.

Prompt 09 found that coherent-report prerequisite currentness is not adequately checked at the final automatic-recovery mutation boundary.

Correct this using the same coordinator-owned helper.

Immediately before any automatic reset/recovery mutation:

- command/action context must still be valid;
- latest coherent prerequisites must still permit automatic recovery;
- no await may intervene between the final prerequisite check and mutation.

Do not create a special second rule for automatic recovery unless its command semantics genuinely differ. Prefer one coherent prerequisite-currentness model.

---

# 3. Behavior when the late prerequisite check fails

If prerequisites regress during controller acquisition or another relevant await:

- do NOT call `begin`;
- do NOT call `resume`;
- do NOT perform automatic derived-data reset;
- do NOT fabricate an operation UUID;
- do NOT discard retained app-owned failed/interrupted evidence;
- do NOT allow the stale Retry/Continue action to force execution.

The coordinator should either:

- publish/restore the truthful current typed prerequisite Episode when that is consistent with the existing Journey architecture; or
- no-op if current coordinator semantics require the environment listener to publish it immediately after the command token unwinds.

Choose the behavior that best preserves the existing single-authority design.

The externally visible result must truthfully reflect the current prerequisite blocker rather than the stale command.

Document why the chosen behavior is race-safe.

---

# 4. Deterministic held-await race tests — REQUIRED

Add deterministic tests that reproduce the exact race from Prompt 09.

Do NOT rely on timing sleeps.

Use a completer-controlled or otherwise explicitly held controller-provider future so the test can stop execution precisely while controller acquisition is pending.

At minimum, add the two tests explicitly required by Prompt 09:

## Retry race

Test sequence:

1. establish a Retry-capable Journey Episode with prerequisites currently satisfied;
2. invoke the actual Retry action;
3. hold `onboardingOperationControllerProvider.future` unresolved;
4. confirm the command has entered the intended acquisition window;
5. publish a prerequisite regression while the controller await remains blocked;
6. confirm `_latestReport`/coherent prerequisite truth has changed while the active command prevents stale visible action-context displacement from being relied upon;
7. release controller acquisition;
8. prove `begin` is NEVER called;
9. prove no destructive/import/reset mutation occurs;
10. prove the resulting Journey semantics truthfully reflect the prerequisite blocker or otherwise follow the explicitly documented safe no-op/publish path.

Use a real typed blocker from the current prerequisite model.

Do not merely invoke an already-stale action after waiting for the prerequisite Episode to render. That is the old test shape and does NOT exercise this race.

## Continue Setup race

Test sequence:

1. establish a valid interrupted resumable operation;
2. expose the real Continue Setup action;
3. invoke Continue Setup;
4. hold controller acquisition unresolved;
5. inject a prerequisite regression while acquisition is pending;
6. release controller acquisition;
7. prove `resume` is NEVER called;
8. prove the original interrupted operation identity remains truthful and is not silently replaced;
9. prove the visible Journey outcome reflects the current prerequisite truth safely.

Again, the blocker must arrive during the held await, not before invoking the action.

---

# 5. Cover all affected mutation classes

Prompt 09 requires deterministic held-await tests for Retry and Continue Setup.

In addition, inspect whether the test infrastructure can cheaply and clearly prove the same final-check invariant for:

- initial-import `begin`;
- reimport `begin`;
- automatic-recovery reset/mutation.

Add focused tests where they materially strengthen confidence without duplicating the exact same test mechanically.

At minimum, architecture/behavioral coverage must make it impossible for one of the four identified paths to omit the final prerequisite-currentness guard unnoticed.

Prefer a shared principle test/helper if appropriate.

Do not weaken specificity merely to reduce test count.

---

# 6. Preserve all Prompt 08 PASS findings

Do not regress:

- generated keep-alive coordinator lifetime;
- single coordinator authority;
- operation UUID identity chain;
- process-session/revision/status/stage/progress validation;
- prerequisite precedence over retained failed/interrupted work;
- bounded startup-only adoption of unbound durable evidence;
- hostile-noise rejection;
- UUID-less failure/action truthfulness;
- failure-before-secondary-side-effects ordering;
- restart/reconciliation behavior;
- explicit user continuation rather than auto-resume;
- specialist ownership boundaries;
- immutable/data-only Journey operation projection;
- indeterminate progress when totals are unknown/nonpositive;
- current production Journey semantic ownership.

The correction should be surgical.

If fixing BLOCKER 1 appears to require redesigning any of those accepted areas, STOP and report why before proceeding.

---

# SHOULD FIX 1 — HARDEN THE SEMANTIC DEPENDENCY CENSUS

Prompt 09 found that the new semantic dependency census is materially improved but not yet mechanically complete.

Current blind spots:

1. recursive traversal is limited to dependencies under:
   - `lib/essentials/onboarding/`
   - `lib/features/environment_readiness/`

   A future local wrapper/read model elsewhere in `lib/` can therefore be recorded but not traversed transitively to a forbidden raw evidence dependency.

2. traversal stops at the provider barrel and several action providers without mechanically proving that those stop boundaries remain intent-only.

This is a SHOULD FIX because current production source contains no side door, but the test does not yet guarantee the claimed future-wrapper property.

Correct it in this prompt.

---

# 7. Extend semantic census traversal

Refactor the architecture test so relevant local production dependency chains are traversed transitively regardless of whether an intermediate wrapper lives specifically under the two currently hard-coded prefixes.

The test should establish a property equivalent to:

> Any production Journey-semantic consumer reachable through local source dependencies must not obtain competing raw environment/graph/onboarding semantic evidence except through an explicitly verified authority or diagnostic boundary.

Do not solve this with an ever-growing list of known wrapper filenames.

Prefer principle-based traversal.

Keep development-only diagnostics explicitly bounded if they are intentionally permitted.

Avoid traversing generated/external/package edges that are not meaningful local semantic dependencies.

The test should remain understandable and maintainable.

---

# 8. Make stop/allowlist boundaries mechanically safe

Where traversal intentionally stops at:

- provider barrels;
- action adapters/providers;
- authority seams;
- diagnostic seams;

do not rely solely on comments or naming convention.

For each intentional stop boundary, mechanically establish the property that justifies stopping there.

In particular, if action providers remain terminal/allowlisted boundaries, prove that they are intent-only and cannot:

- read raw prerequisite semantic evidence;
- publish competing Journey state;
- expose a second Journey-semantic read model;
- hide a dependency on forbidden raw evidence behind the allowlisted adapter.

If an existing stop boundary cannot be justified mechanically, remove the stop and traverse through it instead.

The resulting census should make the Prompt 09 “future wrapper” guarantee an actual test property rather than a directory-layout convention.

---

# 9. Tests for the census itself

Where practical, add fixture/source-shape tests proving that the census fails for the classes of architectural violation identified by Prompt 09, for example:

- a semantic wrapper placed elsewhere under `lib/` that eventually consumes forbidden raw evidence;
- an allegedly intent-only action adapter that acquires a semantic read dependency.

Do not add fake production architecture merely for testing if the existing architecture test style provides a cleaner fixture mechanism.

The goal is to prove the tripwire, not simply expand an allowlist.

---

# 10. Do not perform deferred unrelated work

Do NOT address the OPTIONAL findings in this correction unless required by the blocker/SHOULD FIX work.

In particular:

- do not remove or adopt `onboardingJourneyAllowsCommandedTransition` merely because it remains unused;
- do not start the deferred canonical documentation tranche;
- do not update the stale canonical `20-environment-readiness.md` paragraph yet;
- do not perform unrelated cleanup/refactoring;
- do not alter archive/database schemas;
- do not touch attachment relocation;
- do not access real user databases or archives;
- do not touch the parked patch.

---

# VALIDATION

After implementing the corrections, run the narrow validation needed to prove this correction.

At minimum:

1. focused coordinator tests covering:
   - late prerequisite regression during held controller acquisition;
   - Retry;
   - Continue Setup;
   - any additional affected mutation paths you add coverage for;

2. focused onboarding/Journey authority tests affected by the correction;

3. complete architecture suite;

4. `flutter analyze --no-pub`;

5. `git diff --check`.

Run code generation only if this correction changes annotated/generated-source inputs.

Do NOT run native tests unless native code changes.

Do NOT access production databases/archives.

Do NOT run the full repository test suite merely to compensate for the architectural failure. Prompt 09 explicitly established that the previous green full/scoped results did not exercise this race. The purpose of this prompt is to close the race with deterministic focused proof plus architecture validation.

If repository instructions independently require a broader suite because of the actual files changed, obey them and explain why.

---

# REVIEW THE ACTUAL DIFF AFTER IMPLEMENTATION

Before reporting completion:

- inspect the complete diff;
- confirm no unrelated tracked file changed;
- confirm the Prompt 08 corrections remain present;
- confirm no second prerequisite authority was introduced;
- confirm there is a final latest-prerequisite check after relevant awaits and immediately before each operational mutation;
- confirm no await remains between that final currentness decision and `begin` / `resume` / automatic reset;
- confirm the semantic census no longer depends on the two-prefix traversal assumption;
- confirm every retained traversal stop boundary is mechanically justified;
- confirm the shared-instructions submodule remains clean;
- confirm the parked patch remains unchanged and unapplied.

---

# GIT / SCOPE RULES

This is still pre-checkpoint correction work.

Therefore:

- leave ALL implementation/test changes UNSTAGED;
- do not commit;
- do not push;
- do not merge;
- do not apply the parked patch;
- do not start final qualification;
- do not begin another feature.

Preserve all unrelated untracked files untouched.

---

# RESPONSE ARTIFACT

Save the correction report as:

`10-CORRECT-POST-AWAIT-PREREQUISITE-CURRENTNESS-AND-SEMANTIC-CENSUS.md`

under:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/responses/`

The report must include:

## A. Baseline identity

- branch;
- HEAD;
- index state;
- tracked/untracked state relevant to this correction;
- shared-instructions submodule state;
- parked-patch path, size, and SHA-256;
- confirmation patch remains unapplied.

## B. BLOCKER correction

Describe:

- the coordinator-owned prerequisite-currentness helper;
- exactly what evidence it evaluates;
- where it is invoked;
- final pre-mutation ordering for:
  - initial import;
  - reimport;
  - Continue Setup;
  - automatic recovery;
- behavior when prerequisites regress during the await window.

Explicitly confirm whether any await exists between the final prerequisite check and mutation.

## C. Deterministic race proof

For each held-await test report:

- command/action under test;
- where execution is deliberately suspended;
- which prerequisite regression is injected;
- how controller acquisition is released;
- proof that `begin` / `resume` / reset was untouched;
- resulting typed Journey state.

## D. Semantic-census correction

Describe:

- old traversal limitation;
- new traversal rule;
- explicit stop boundaries;
- mechanical proof for each retained stop class;
- tests proving future wrappers/action adapters cannot hide raw semantic evidence.

## E. Regression preservation

Explicitly confirm that all Prompt 08 PASS areas remain intact.

## F. Validation

Report exact results for:

- focused correction tests;
- any wider focused Journey/onboarding tests;
- architecture suite;
- analyzer;
- `git diff --check`;
- code generation if run;
- any broader suite required by repository instructions.

## G. Exact Git status

Report:

- branch;
- HEAD;
- index;
- tracked worktree count/state;
- intended untracked implementation/test/review files;
- unrelated untracked files untouched;
- shared-instructions submodule state;
- parked-patch state;
- staging/commit/push/merge status.

---

# STOP GATE

After completing the correction and validation:

STOP.

Do not perform the repeated architectural review yourself unless this prompt explicitly contains a separate review phase. It does not.

Do not declare the integration qualified.

Do not checkpoint.

Do not stage.

Do not commit.

Do not push.

The next step will be a fresh human architectural review of the corrected source.

Your final response should state clearly:

**Prompt 10 correction complete; ready for repeated human architectural review.**