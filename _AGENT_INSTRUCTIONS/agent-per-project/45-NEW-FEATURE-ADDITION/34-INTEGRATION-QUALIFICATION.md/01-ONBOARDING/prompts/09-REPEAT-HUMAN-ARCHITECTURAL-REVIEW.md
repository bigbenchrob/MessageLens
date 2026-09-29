# MessageLens Clean-Slate Integrated Qualification
## 09 — Repeat Human Architectural Review After Prompt 08 Corrections

Prompt 08 reports that both BLOCKER findings and all three SHOULD FIX findings
from Prompt 07 have been corrected.

This task repeats the architectural gate against the **actual current unstaged
implementation**.

It is a read-only review.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT apply the parked WIP patch.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`
- `responses/06-IMPLEMENT-ONBOARDING-AUTHORITY-CORRECTION.md`
- `responses/07-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/08-CORRECT-ONBOARDING-AUTHORITY-REVIEW-FINDINGS.md`
- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- corrected canonical onboarding authority documents.

Governing invariant:

> **Evidence may be distributed. Journey authority may not be.**

The purpose is to determine whether the complete Prompt 06 + Prompt 08 delta is
now architecturally safe to proceed to final validation before checkpoint.

---

# 1. Baseline and diff identity

Expected:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- tracked worktree: Prompt 06 implementation plus Prompt 08 corrections only
- shared-instructions submodule: clean
- parked WIP patch: unchanged and unapplied

Confirm Prompt 08 did not introduce unrelated tracked work.

If unrelated tracked changes are present, STOP AND REPORT.

---

# 2. Re-review the original Prompt 07 architecture gate

Do not inspect only the five corrected findings.

Repeat the full architectural review of the current source and tests against the
same categories used in Prompt 07:

1. stable coordinator lifetime;
2. operation identity chain;
3. semantic side doors;
4. Journey-owned operation projection;
5. failure publication ordering;
6. action provenance/currentness;
7. restart/reconciliation semantics;
8. prerequisite precedence;
9. specialist boundaries;
10. test/tripwire architectural quality;
11. deletion/compatibility seams;
12. complete diff-shape sanity.

The purpose is to ensure that correcting the Prompt 07 findings did not create a
different authority defect.

---

# 3. Verify BLOCKER 1 is actually resolved

Inspect the production coordinator paths for:

- initial reconstruction;
- later environment-report ingestion;
- failed-operation resurfacing;
- interrupted-operation resurfacing;
- Retry;
- Continue Setup.

Confirm that current external prerequisites have visible precedence over
retained failed/interrupted operation evidence.

Specifically verify:

```text
current prerequisite blocker
        >
retained app-owned operation failure/interruption
```

for:

- FDA / protected Messages access;
- local Messages/source availability;
- local-history confirmation;
- Contacts access.

Retained failure/interruption evidence may remain private/durable.

It must not remain visible merely because it existed first.

When prerequisites become compatible again, resurfacing retained operation
evidence must create or use a current Journey occurrence so previously rendered
actions remain stale.

Check the new typed-Episode tests against the actual implementation rather than
accepting test names as proof.

---

# 4. Verify BLOCKER 2 is actually resolved

Inspect the startup-adoption mechanism.

Confirm:

- unbound failed/interrupted durable evidence may be adopted only during one
  explicit bounded startup reconciliation phase;
- startup adoption closes permanently for that coordinator lifetime after the
  required initial evidence channels settle;
- post-startup unbound failed/interrupted emissions cannot create a new Journey
  occurrence;
- terminal acknowledgement followed by replayed old evidence leaves normal
  application unchanged;
- operation A evidence cannot be rebound after operation B begins;
- startup still truthfully adopts legitimate interrupted evidence once;
- repeated evidence after closure cannot create another occurrence.

Ensure the mechanism is coordinator-owned and does not introduce another
provider/state-machine authority.

---

# 5. Verify prerequisite revalidation on Retry and Continue Setup

Prompt 07 found that action contexts could be mechanically current relative to a
stale Journey.

Inspect current Retry and Continue Setup paths and verify they now re-check:

- current Journey occurrence;
- expected Episode;
- expected operation ID where applicable;
- current coherent prerequisite evidence;

both:

- before asynchronous admission; and
- again after admission / immediately before execution or resume.

A stale Retry/Continue callback must not bypass a newly current prerequisite
blocker.

---

# 6. Verify UUID-less failure semantics

Inspect `OnboardingOperationFailed` and the new
`OnboardingJourneyFailureAction` (or actual equivalent).

Confirm:

- UUID-less failure does not fabricate operation identity;
- failed-command intent is coordinator/Journey state, not snapshot state;
- first-import admission/begin failure retries first import;
- reimport admission/begin failure retries reimport;
- automatic recovery uses its own truthful policy;
- environment-only failure presents Re-check rather than a false Try Again;
- nonrecoverable/manual failure exposes no action that cannot perform what it
  claims;
- stale action-context validation remains intact.

Check presentation copy/actions as well as coordinator behavior.

---

# 7. Verify failure-order proof quality

Inspect the new failure-order tests.

Confirm they mechanically observe Journey state **inside** each secondary
boundary rather than merely checking the final state after the command returns.

At minimum verify coverage for:

- snapshot failure persistence;
- graph/import failure persistence;
- logger acquisition;
- logger write;
- evidence refresh/invalidation.

The test must prove:

1. Journey failure was already published;
2. secondary work then runs/fails;
3. the primary failure remains authoritative.

Also verify production source still has the same ordering.

---

# 8. Verify the strengthened side-door tripwire

Inspect the updated architecture test.

Determine whether it now protects the **semantic boundary**, not merely known
provider names.

Confirm that it inventories the relevant production:

- Onboarding presentation;
- Environment Readiness presentation/resolvers;
- application shell;
- center-panel synchronization;
- local dependency chains used by those surfaces.

Verify that a future wrapper/read-model that consumes raw environment, graph,
snapshot, controller, or reconciliation evidence and republishes onboarding
semantics would be caught.

The development-only diagnostic panel may remain an explicit bounded exception.

Avoid treating harmless implementation flexibility as a violation merely because
a private symbol name changes.

---

# 9. Reconfirm the original architecture correction

Independently reconfirm the major Prompt 06 claims remain true after Prompt 08:

- `OnboardingJourneyCoordinator` is sole Journey-semantic authority;
- stable listener ingestion prevents the original Riverpod stale-`ref` failure;
- one operation UUID flows begin/bind/execute/progress/complete;
- operation evidence is identity/currentness checked end-to-end;
- production presentation has zero raw semantic side doors;
- Journey projection is immutable/data-only;
- unknown progress remains indeterminate;
- operation failure is published before secondary evidence work;
- restart never auto-resumes ordinary interrupted user onboarding;
- unbound completed historical snapshot cannot replay terminal UI;
- specialists still own import, graph, persistence, reset, archive admission,
  probes, and completion proof.

---

# 10. Review tests for principle rather than overfitting

Inspect the corrected test suite for a new form of architectural lock-in.

Confirm:

- prerequisite precedence tests assert typed Journey behavior;
- hostile-noise tests truly send late/unbound evidence;
- startup-adoption tests prove one-shot behavior;
- UUID-less retry tests execute the intended command;
- failure-order tests inspect ordering;
- architecture census protects authority direction;
- no test requires unnecessary exact private implementation spelling where an
  equivalent conforming refactor should pass.

Report only concrete brittleness that would meaningfully impede a conforming
future refactor.

---

# 11. Diff-shape and cleanup review

Inspect the complete current diff for:

- duplicate authority/state;
- dead temporary Prompt 08 machinery;
- old contradictory comments;
- unused fields/helpers introduced by the correction;
- accidental API widening;
- generated mismatch;
- unrelated formatting/refactors;
- archive/database/safety boundary changes.

`onboardingJourneyAllowsCommandedTransition` was intentionally left as an
optional cleanup item. Do not fail the review merely because it remains unused
unless it now causes a concrete architecture problem.

---

# 12. Validation scope

Prompt 08 already reports:

- scoped tests: 295 passed;
- architecture: 493 passed;
- analyzer: clean;
- `git diff --check`: passed;
- correction-delta Project Conformance: PASS.

Do not rerun the full repository suite in this review.

Rerun only a narrow test if source inspection reveals an ambiguity that cannot
otherwise be resolved.

The full repository suite belongs to the **next final-validation step if this
architectural review passes**.

---

# 13. Required response

Create:

`01-ONBOARDING/responses/09-REPEAT-HUMAN-ARCHITECTURAL-REVIEW.md`

Report:

1. baseline/diff identity;
2. coordinator lifetime verdict;
3. operation identity-chain verdict;
4. prerequisite-precedence verdict;
5. startup-only unbound-adoption verdict;
6. Retry/Continue prerequisite-currentness verdict;
7. UUID-less failure/action verdict;
8. semantic side-door verdict;
9. operation-projection verdict;
10. failure-order source verdict;
11. failure-order test-proof verdict;
12. restart/reconciliation verdict;
13. specialist-boundary verdict;
14. tripwire/test-quality verdict;
15. deletion/compatibility/diff-shape verdict;
16. concrete BLOCKER findings;
17. concrete SHOULD FIX findings;
18. OPTIONAL findings;
19. narrow tests rerun, if any;
20. exact Git status;
21. final architectural recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify the implementation.

Conclude exactly:

`REPEATED HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO PROCEED TO FINAL VALIDATION BEFORE CHECKPOINT: YES / NO`

Then STOP.
