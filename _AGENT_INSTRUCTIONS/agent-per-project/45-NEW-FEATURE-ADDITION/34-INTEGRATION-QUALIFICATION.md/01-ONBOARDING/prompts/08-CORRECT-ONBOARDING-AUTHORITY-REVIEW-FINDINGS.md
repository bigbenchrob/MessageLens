# MessageLens Clean-Slate Integrated Qualification
## 08 — Correct Onboarding Authority Review Findings

Prompt 07 correctly failed the architectural review.

Read in full before editing:

- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`
- `responses/06-IMPLEMENT-ONBOARDING-AUTHORITY-CORRECTION.md`
- `responses/07-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- corrected canonical onboarding authority documents.

The implementation must remain uncommitted until the architectural gate passes.

This task corrects exactly the two BLOCKER findings and three SHOULD FIX findings
from Prompt 07.

Do NOT redesign the completed authority correction.
Do NOT apply the parked WIP patch.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.
Do NOT stage or commit.
Do NOT edit canonical/conformance documentation in this task.

Governing invariant:

> **Evidence may be distributed. Journey authority may not be.**

And the canonical blocker rule remains:

> Current external prerequisites (FDA / Messages / local history / Contacts)
> outrank app-owned import/graph readiness or historical operation failure when
> selecting the visible current Journey Episode.

---

# 1. Baseline

Expected:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- Prompt 06 implementation still entirely unstaged/uncommitted
- shared-instructions submodule clean
- parked WIP patch unchanged and unapplied

Confirm the tracked delta still matches the Prompt 06 implementation inventory
and that Prompt 07 made no implementation changes.

If unrelated tracked changes are present, STOP AND REPORT.

---

# 2. BLOCKER 1 — Restore prerequisite precedence over persisted operation failure

Prompt 07 proved that the current implementation incorrectly lets persisted
failed/interrupted operation evidence become visible Journey authority ahead of
newly current external prerequisite blockers.

Correct the coordinator so that:

1. the current coherent environment report is always allowed to establish the
   truthful external-prerequisite Episode first;
2. persisted failed/interrupted operation evidence remains retained as durable
   evidence while a prerequisite blocker is visible;
3. the operation failure/interruption may become visible again only after fresh
   compatible prerequisite evidence permits the Journey to return to that
   operation concern;
4. a later prerequisite regression while failed/interrupted evidence is already
   bound immediately moves visible Journey state to the truthful prerequisite
   Episode;
5. Retry / Continue Setup is not offered while prerequisites are currently
   incompatible.

Apply this consistently to:

- initial reconstruction;
- later environment-report ingestion;
- later operation-evidence ingestion;
- retry;
- Continue Setup.

Do not discard the durable failure/interruption record merely because a
prerequisite is currently blocking.

Do not invent a second authority.

The coordinator remains the only component deciding which retained evidence is
currently visible.

---

# 3. Invert the contradictory precedence test

Replace the existing test that requires:

`persisted manual-inspection failure remains authoritative`

with tests that prove the canonical precedence.

At minimum cover:

- missing FDA + persisted failure -> FDA prerequisite Episode;
- missing Messages/local source + persisted failure -> Messages prerequisite
  Episode;
- local-history blocker + persisted failure -> history Episode;
- Contacts blocker + persisted failure -> Contacts Episode;
- failure visible while prerequisites are compatible, followed by new FDA loss
  -> visible FDA Episode while failure evidence remains retained;
- interrupted/Continue Setup visible while compatible, followed by prerequisite
  regression -> prerequisite Episode and Continue Setup unavailable;
- prerequisites become compatible again -> coordinator may truthfully surface
  the retained failure/interruption according to Journey policy.

Use the actual typed Episodes, not compatibility-status-only assertions.

---

# 4. BLOCKER 2 — Restrict unbound snapshot adoption to one startup window

Prompt 07 found that `_ingestOperationEvidence` can adopt unbound failed or
interrupted snapshots outside startup, including after an operation binding has
been deliberately retired.

Introduce an explicit, one-shot startup reconciliation/adoption context.

The design must ensure:

- unbound failed/interrupted snapshot evidence may be adopted only during the
  coordinator's bounded startup reconstruction/reconciliation phase;
- that phase is explicitly opened and then permanently closed for the current
  coordinator lifetime;
- normal post-startup snapshot emissions with no current operation binding are
  diagnostic/history only;
- after terminal acknowledgement / normal application, replayed or delayed
  failed/interrupted evidence from the retired operation cannot create a new
  Journey occurrence;
- after a retry creates a new operation, old operation-A evidence cannot be
  rebound as operation B;
- startup adoption still supports the intended interrupted/resumable behavior;
- completed unbound historical snapshots remain nonauthoritative as already
  designed.

Prefer a small coordinator-owned startup-adoption state/token over adding a new
provider or state machine.

Document in code why unbound adoption is startup-only.

---

# 5. Add hostile-noise tests for unbound replay

Add focused tests that deliver old unbound evidence after authority has moved on.

At minimum:

1. operation A succeeds -> terminal acknowledgement -> normal application ->
   delayed A `failed` emission -> Journey unchanged;
2. same sequence with delayed A `interrupted` emission -> Journey unchanged;
3. operation A fails -> retry starts operation B -> delayed unbound A failure /
   interruption -> B unchanged;
4. provider/container startup with legitimate prior interrupted evidence ->
   startup adoption still works once;
5. after startup adoption closes, repeating the same snapshot cannot invent a
   second occurrence.

Assert Journey occurrence as well as Episode.

---

# 6. SHOULD FIX 1 — Broaden the semantic-side-door tripwire

The current tripwire is too dependent on three provider names and fixed source
spellings.

Strengthen it so it enforces the architectural principle rather than only the
current implementation.

The architecture test should census production Onboarding presentation/resolver/
shell surfaces and prove that their workflow-semantic roots are Journey state
(or read-only compatibility projections derived only from Journey).

It should detect a future wrapper/read-model that:

- watches raw environment/graph/snapshot evidence; and
- republishes onboarding-semantic state to presentation.

Avoid brittle assertions that require unnecessary private method names or exact
source layout where an equivalent conforming refactor should pass.

It is acceptable to combine:

- forbidden dependency/import rules;
- an allowlisted list of explicitly diagnostic-only raw evidence surfaces;
- dependency-direction checks;
- semantic-root assertions.

The development diagnostic panel may remain an explicit bounded exception.

---

# 7. SHOULD FIX 2 — Prove failure publication ordering mechanically

Current production source is correct, but tests only verify the final state.

Add spies/fakes around secondary failure boundaries that assert the Journey has
already entered its failure Episode **at the moment** each secondary action is
invoked.

Cover at least:

- snapshot failure persistence;
- graph/import failure-store persistence;
- logger acquisition/write;
- evidence refresh/invalidation.

Also inject failure from each boundary and prove:

- Journey failure was already published;
- the primary operation error remains primary;
- the secondary error does not replace or strand the Journey.

Do not expose production-only hooks merely for test convenience if an existing
dependency override/fake can observe the ordering.

---

# 8. SHOULD FIX 3 — Make UUID-less failure actions truthful

Prompt 07 found that an admission/begin failure can produce a truthful failure
Episode without an operation projection/UUID, but `retryFailedOperation` does
not know which command actually failed.

Fix this semantically.

A UUID-less failure must retain enough coordinator-owned command intent to make
its visible action truthful.

At minimum distinguish:

- first import admission/begin failure;
- reimport admission/begin failure;
- automatic recovery admission/begin failure where applicable.

Choose the smallest type-safe representation, for example a coordinator-owned
failed-command kind attached to the failure Episode or private Journey failure
model.

Requirements:

- this is Journey command intent, not operation snapshot state;
- it must not fabricate an operation UUID;
- **Try Again** must actually retry the failed command it describes;
- if a failure is only a re-evaluation condition, use truthful copy/action such
  as Re-check rather than pretending to retry;
- stale action context/occurrence validation still applies.

Add focused tests for UUID-less first-import and reimport admission/begin
failures.

---

# 9. Optional cleanup

Prompt 07 identified two optional bounded cleanup candidates:

- `_latestOperationEvidence` assignments after startup appear unused;
- `onboardingJourneyAllowsCommandedTransition` appears unused.

Remove either only if source/use proof is clear and doing so simplifies this
same delta without widening scope.

Otherwise leave them for later.

They are not required for PASS.

---

# 10. Re-run focused validation only

After corrections, run the smallest complete validation needed to establish the
review findings are resolved:

- affected coordinator/application tests;
- restart/reconciliation tests;
- precedence tests;
- hostile-noise tests;
- UUID-less failure/action tests;
- failure-order tests;
- onboarding authority architecture tests;
- complete architecture suite;
- `flutter analyze --no-pub`;
- generation only if source annotations/signatures changed;
- `git diff --check`.

Do NOT rerun the complete repository Flutter suite yet unless the correction
touches a sufficiently broad shared seam that focused + architecture coverage is
not credible.

Prompt 07 should be repeated after these corrections. The full suite may be run
again after the architectural gate passes.

---

# 11. Re-run Project Conformance only for the correction delta

Re-evaluate the prior PASS specifically against the Prompt 07 findings.

The authority census must now prove:

- current prerequisite evidence can displace retained failed/interrupted
  operation evidence in visible Journey state;
- unbound operation evidence cannot be adopted outside startup;
- all stale-sensitive actions remain occurrence/identity bound;
- failure publication ordering is mechanically tested;
- presentation remains Journey-only.

Require zero unresolved BLOCKER and zero unresolved SHOULD FIX findings.

Do not edit the Project Conformance Standard yet.

---

# 12. Leave everything unstaged and uncommitted

Even if every narrow test passes:

- do not stage;
- do not commit;
- do not push;
- do not merge;
- do not launch MessageLens Development.

The next step is to repeat the architectural review gate against the corrected
unstaged diff.

---

# Required response record

Create:

`01-ONBOARDING/responses/08-CORRECT-ONBOARDING-AUTHORITY-REVIEW-FINDINGS.md`

Report:

1. baseline;
2. prerequisite-precedence correction;
3. inverted/added precedence tests;
4. startup-only unbound-adoption mechanism;
5. hostile-noise replay tests;
6. strengthened semantic-side-door tripwire;
7. mechanical failure-order test proof;
8. UUID-less failure/action semantics;
9. optional cleanup performed or deferred;
10. changed files;
11. focused test results;
12. architecture result;
13. analyzer result;
14. generation result if applicable;
15. `git diff --check`;
16. Project Conformance verdict;
17. remaining BLOCKER findings;
18. remaining SHOULD FIX findings;
19. Git status;
20. any stop gate.

Conclude exactly:

`PROMPT 07 ARCHITECTURAL FINDINGS CORRECTED: YES / NO`

If YES, also conclude:

`READY TO REPEAT HUMAN ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
