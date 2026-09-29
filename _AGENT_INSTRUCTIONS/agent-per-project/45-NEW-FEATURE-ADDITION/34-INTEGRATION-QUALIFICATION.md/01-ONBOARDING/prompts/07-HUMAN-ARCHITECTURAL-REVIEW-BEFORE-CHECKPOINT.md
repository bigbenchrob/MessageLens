# MessageLens Clean-Slate Integrated Qualification
## 07 — Human Architectural Review Before Onboarding Authority Checkpoint

Prompt 06 reports a complete, validated implementation of the approved Onboarding authority correction.

This task is a **read-only architectural review of the actual unstaged diff**.

Do NOT modify production code, tests, generated files, or documentation. Do NOT stage or commit. Do NOT apply the parked WIP patch. Do NOT launch MessageLens Development. Do NOT access real databases or attachment archives.

Read in full:

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- `responses/03-ONBOARDING-AUTHORITY-FORENSIC-AUDIT.md`
- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`
- `responses/06-IMPLEMENT-ONBOARDING-AUTHORITY-CORRECTION.md`
- corrected canonical onboarding authority documents.

Governing invariant:

> **Evidence may be distributed. Journey authority may not be.**

## 1. Baseline

Expected:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty
- implementation unstaged/uncommitted
- shared-instructions submodule clean
- parked WIP patch unchanged and unapplied

Confirm that the diff under review is exactly the Prompt 06 implementation delta plus expected generated/test changes and no unrelated tracked work.

If unrelated tracked changes are present, STOP AND REPORT.

## 2. Review the actual state-owner lifetime

Inspect the coordinator implementation, not only tests.

Confirm:

- `OnboardingJourneyCoordinator` is still the only writer of `OnboardingJourneyState`;
- changing environment/operation/lock evidence reaches it by listener/event ingestion rather than `ref.watch` reconstruction;
- no command can invalidate/reconstruct the notifier that must later finish or fail that command;
- no production caller invalidates the Journey provider;
- explicit container teardown remains the only normal owner-disposal boundary;
- listener registration cannot duplicate semantic processing if the provider is rebuilt for any legitimate reason.

Explain the exact source mechanism that prevents recurrence of the original Riverpod `!_didChangeDependency` failure.

## 3. Verify the operation identity chain end to end

Trace one concrete first-import operation through actual symbols:

```text
Journey action
-> mutation admission
-> snapshot begin
-> operation UUID
-> Journey binding
-> running Episode
-> executor
-> progress
-> completion/failure
-> terminal/failure Episode
```

Confirm there is exactly one operation UUID for the attempt and no hidden second generation or executor-created ID.

Verify the same for retry, reimport, and interrupted Continue Setup/resume.

Confirm wrong operation ID, Journey occurrence, process session, stage/substage, or progress revision cannot alter the current Journey.

## 4. Verify all three semantic side doors are genuinely gone

Search production Onboarding presentation and shell/readiness surfaces.

Confirm that no production UI derives Journey meaning directly from:

- `onboardingEnvironmentReportProvider`;
- `conversationGraphBuildControllerProvider`;
- `onboardingOperationSnapshotProvider`.

Distinguish explicitly labelled development diagnostics from production presentation.

Check for indirect replacements such as wrapper providers/read models that still combine raw evidence outside the coordinator.

The result must be semantically—not merely textually:

> Journey state in, widgets out.

## 5. Review the Journey operation projection

Inspect the new projection and every Episode that carries it.

Confirm:

- it is immutable/data-only;
- it contains only coordinator-approved presentation facts;
- it does not expose controllers/providers/stores/mutation authority;
- raw `recoveryDisposition` does not become UI policy;
- unknown numeric progress remains null/indeterminate;
- no terminal graph state or elapsed-time fallback can fabricate 100%;
- action availability is Journey-owned.

Check that admission/begin failures before an operation ID exists still have a truthful typed Journey failure representation without fabricating an operation projection.

## 6. Review failure publication ordering in actual catch paths

Inspect every changed catch path named by the forensic audit.

Confirm that once a current operation failure is known:

1. currentness is checked without fallible provider/I/O work;
2. Journey failure is published;
3. only afterward do persistence, logging, diagnostics, and evidence refresh occur behind independent containment boundaries.

Review in particular graph/import failure, snapshot `runStage`, durable verification, admission/begin failure, reimport, automatic recovery, and terminal/completion persistence.

Confirm a failure in any secondary evidence action cannot strand or replace the Journey outcome and cannot mask the primary error.

## 7. Review action provenance/currentness

Inspect actual callback/action plumbing for:

- Import My Messages;
- Retry;
- Continue Setup;
- Reimport;
- terminal OK/Done;
- dismissal where applicable.

Confirm async actions revalidate the captured Journey occurrence/Episode and operation ID after awaits.

Check that stale callbacks from an earlier compatible-looking Episode cannot act on the current Journey.

## 8. Review restart and reconciliation semantics

Inspect startup/reconciliation code and tests.

Confirm:

- prior-process `running` becomes interrupted evidence;
- ordinary interrupted user import never auto-resumes;
- exact safe-boundary continuation is exposed only through coordinator-owned **Continue Setup**;
- incompatible prerequisites block continuation truthfully;
- completed unbound snapshots are historical evidence rather than terminal UI authority;
- stale unrelated snapshots cannot recreate Start/Done;
- shell no longer owns an independent reconciliation side effect.

### Special precedence check

Prompt 06 reports:

> persisted failure is authoritative even if prerequisites also changed.

Review this carefully against canonical blocker priority and Prompt 05 restart semantics.

The canonical Journey rules put external prerequisite blockers (Messages/FDA/history/Contacts) ahead of app-owned import/graph readiness, while Prompt 05 explicitly required an interrupted operation with changed prerequisites to show the prerequisite Episode.

Determine precisely what “persisted failure is authoritative” means in the implementation:

- If it means the failure record remains durable evidence while the **visible Journey truthfully shows the current prerequisite blocker**, that is fine.
- If it means an old operation failure **visibly overrides a newly current FDA, Messages, history, or Contacts prerequisite blocker**, treat that as an architectural contradiction and STOP before checkpointing.

Do not silently choose precedence. Cite the canonical rule and actual code path.

## 9. Review specialist boundaries

Confirm the correction did not turn the coordinator into a god object.

It may own Journey occurrence, Episode, operation binding/currentness, evidence interpretation, user-visible action policy, and what happens next.

It must not absorb SQL/import mechanics, graph construction, durable snapshot storage mechanics, reset implementation, archive mutation authority, FDA/Contacts probing, or completion-proof mechanics.

Report any dependency-direction regression.

## 10. Review tests for architectural truth rather than implementation lock-in

Inspect the new/rewritten tests.

Confirm they protect principles rather than accidental private structure.

In particular verify:

- architecture tests prohibit semantic side doors, not merely named imports;
- deterministic replay asserts Journey behavior;
- hostile-noise tests actually inject stale/wrong identity evidence;
- failure-injection tests prove Journey publication precedes secondary failure;
- old tests that encoded `buildingGraph + graph succeeded -> ready/100%` are removed or inverted;
- no new test canonizes an unnecessary implementation detail that would make a future equivalent conforming refactor impossible.

## 11. Review deletions and compatibility seams

Inspect every deleted/retired symbol.

Confirm:

- reconciliation provider removal leaves no hidden startup dependency;
- environment-report snapshot removal does not break legitimate diagnostics;
- `presenceState` was truly unused;
- gate remains a read-only compatibility/intent-forwarding seam;
- development diagnostics remain explicitly nonauthoritative;
- no dormant production path still expects the removed direct state.

## 12. Diff-shape sanity review

Review the complete diff for concrete issues only:

- duplicated state models;
- parallel operation identities;
- dead compatibility machinery;
- accidental widening of public/provider APIs;
- generated changes not explained by source annotations/signatures;
- unrelated formatting/refactors;
- stale comments/docs that now describe old authority;
- privacy/safety regressions;
- attachment/archive/data mutation changes.

This is not an invitation to aesthetic refactoring.

## 13. Do not re-run the full suite unless needed

Prompt 06 already reports:

- focused: 281 passed;
- architecture: 493 passed;
- full Flutter: 2,597 passed / 1 skipped;
- analyzer: clean;
- generation: successful;
- `git diff --check`: passed;
- Project Conformance: PASS.

For this review, rerun only narrow tests if source inspection raises a specific question.

## 14. Required review response

Create:

`01-ONBOARDING/responses/07-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`

Report:

1. baseline/diff identity;
2. coordinator lifetime verdict;
3. operation identity-chain verdict;
4. semantic side-door verdict;
5. operation projection verdict;
6. failure-order verdict;
7. action-currentness verdict;
8. restart/reconciliation verdict;
9. prerequisite-vs-persisted-failure precedence finding;
10. specialist-boundary verdict;
11. test/tripwire quality verdict;
12. deletion/compatibility verdict;
13. concrete BLOCKER findings;
14. concrete SHOULD FIX findings;
15. OPTIONAL findings;
16. whether any narrow tests were rerun;
17. exact Git status;
18. checkpoint recommendation.

Use the existing conformance severity vocabulary:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify the implementation.

Conclude exactly:

`HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT ONBOARDING AUTHORITY CORRECTION: YES / NO`

Then STOP.
