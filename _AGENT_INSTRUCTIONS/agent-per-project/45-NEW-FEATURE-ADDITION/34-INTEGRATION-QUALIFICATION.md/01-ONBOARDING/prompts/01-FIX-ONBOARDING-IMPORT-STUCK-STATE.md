# MessageLens Clean-Slate Integrated Qualification
## 08 — Fix Onboarding Import Stuck-State Regression

During the first human clean-slate qualification of integrated `main`, onboarding
hit a genuine product defect.

Observed UI:

- onboarding remained on the non-dismissible **Import** modal;
- the modal displayed a full progress bar;
- copy said **Browsing data ready**;
- no progress changed;
- no failure/retry controls appeared;
- there was no way to dismiss the modal through the UI.

Codex's initial runtime diagnosis reported:

- the import failed immediately with a Riverpod lifecycle assertion;
- onboarding remained stuck in `buildingGraph`;
- stale prior success/progress state continued to render the full bar and
  “Browsing data ready”;
- the failure handler then hit the same stale-provider condition before it could
  publish the retry/error state;
- the import databases had not progressed since Start Fresh.

Treat those statements as evidence to verify against current source/logs, not as
permission to assume the exact root cause without inspection.

The user has been instructed to quit MessageLens Development normally and stop
the Flutter run if necessary.

This is now a code-correction task. Human qualification is paused.

Do NOT repeat Start Fresh.
Do NOT retry Import from the UI.
Do NOT touch production MessageLens.
Do NOT touch either attachment archive.
Do NOT alter archive configuration.
Do NOT inspect abandoned relocation artifacts.
Do NOT use real archive payloads as test fixtures.

---

# 1. Establish safe repository state

Expected integration baseline:

- `main = origin/main =
  fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- release/version at qualification start:
  `0.2.128+146`

Verify:

- tracked worktree/index clean;
- shared-instructions submodule unchanged;
- known qualification/history prompts remain untracked/untouched;
- MessageLens Development is no longer running before implementation work.

Production MessageLens remains strictly off-limits.

---

# 2. Create a narrow bug-fix branch

Create a new branch from current integrated `main`:

`fix/onboarding-import-stuck-state`

Do not develop this repair directly on `main`.

Do not rewrite or amend integrated history.

---

# 3. Inspect the actual failure before changing code

Inspect the development application log and current source to determine the
exact Riverpod lifecycle assertion and call path.

Focus on the onboarding/import orchestration path that transitions through
states equivalent to:

- ready to import;
- importing/projecting/building graph;
- success;
- failure/retry.

Establish:

1. which provider/notifier/ref operation triggered the lifecycle assertion;
2. why the provider/ref was stale/disposed/invalid at that point;
3. why the failure handler encountered the same condition;
4. why the UI retained stale success/progress evidence while the workflow state
   remained `buildingGraph`;
5. why the modal had no reachable error/retry path.

Do not “fix” the symptom in the widget before understanding the application
lifecycle defect.

---

# 4. Correct the smallest owning-layer defect

Fix the lifecycle error at the correct application/provider ownership boundary.

Requirements:

- no widget-side authority or lifecycle workaround;
- no arbitrary delays;
- no swallowed Riverpod assertions;
- no permanent keepAlive added merely to mask disposal unless ownership rules
  genuinely require it;
- no duplicate import state machine;
- no new global singleton merely to preserve stale state;
- no broad reset of onboarding providers after every failure.

The corrected design must ensure:

- the import operation owns/uses a valid provider/ref lifecycle for the duration
  of its work;
- success state can only render after the corresponding operation succeeds;
- failure state can always publish even if the operation fails early;
- stale success/progress from a previous operation cannot render over a current
  failed `buildingGraph` state;
- the modal transitions to an actionable retry/error state on failure;
- ordinary success behavior remains unchanged.

If the current architecture already contains a canonical operation/controller
pattern for long-running onboarding work, reuse it rather than inventing a new
lifecycle mechanism.

---

# 5. Explicitly fix the stale progress/success rendering

The screenshot proved that workflow state and progress presentation could become
inconsistent.

Ensure the UI cannot show:

- full progress / “Browsing data ready”

while the authoritative workflow state is:

- failed;
- retryable;
- cancelled;
- not actually complete.

Progress/success presentation must derive from authoritative current-operation
state, not an independently stale provider snapshot.

Prefer correcting the read model/state composition over adding conditional
widget hacks.

---

# 6. Failure-state UX requirement

If import fails, onboarding must surface an explicit, reachable state such as:

- import could not continue;
- retry;
- optionally diagnostics/details if already part of product conventions.

The non-dismissible modal is acceptable only while a real operation is actively
running.

Once the operation has failed, the user must not be trapped behind an
indefinite modal with no action.

Do not add a generic close button merely to hide the lifecycle bug unless the
existing UX design independently calls for one.

---

# 7. Regression tests

Add focused tests that reproduce the actual defect as closely as possible.

At minimum cover:

1. early import/build-graph failure caused before meaningful progress;
2. failure handler can publish a retry/error state without a lifecycle
   assertion;
3. stale success/progress from an earlier state does not remain visible after
   failure;
4. the modal exposes retry/error controls after failure;
5. retry begins a fresh valid operation lifecycle;
6. successful retry can proceed to success;
7. ordinary successful first-run import still works;
8. provider disposal/reconstruction at the failure boundary does not re-create
   the stuck state.

Use disposable/in-memory fixtures.

Do not require the user's real Messages database to reproduce the lifecycle
bug if it can be triggered deterministically with fakes.

---

# 8. Project Conformance Audit

Before checkpointing, run the MessageLens Project Conformance Audit Standard
against the complete bug-fix delta.

Pay particular attention to:

- Riverpod ownership/lifecycle;
- application vs presentation responsibilities;
- single source of truth for onboarding state;
- no stale parallel progress authority;
- reuse before invention;
- failure-state semantics;
- test quality.

Require:

`PROJECT CONFORMANCE: PASS`

with zero unresolved BLOCKER or SHOULD FIX findings.

---

# 9. Validation

Run at minimum:

- focused onboarding/import lifecycle tests;
- focused onboarding UI/modal tests;
- architecture suite;
- `flutter analyze --no-pub`;
- complete repository Flutter suite;
- `git diff --check`;
- generation if affected;
- documentation/reference validation if feature records are updated.

Native tests are not required unless native code changes unexpectedly.

Do not launch production MessageLens.

Do not perform another real Start Fresh or human import during automated
validation.

---

# 10. Documentation and release metadata

Create the next chronological qualification/correction record under Feature 34
describing:

- human-observed stuck modal;
- exact Riverpod lifecycle root cause;
- stale success/progress composition defect;
- fix;
- regression tests;
- conformance result;
- validation.

Use the next available number after the existing qualification records.

Update `CHANGELOG.md` and version/build according to project conventions if
production code changes.

Keep wording user-facing and factual.

---

# 11. Checkpoint and integration

After:

- root cause is understood;
- fix is complete;
- focused tests pass;
- project conformance passes;
- full validation passes;

commit the bug fix on:

`fix/onboarding-import-stuck-state`

Use a concise commit message such as:

`fix(onboarding): recover cleanly from import failure`

Do not merge into `main` yet unless explicitly authorized in this prompt by
repository convention. Prefer to stop with the reviewed bug-fix branch ready.

Do not push unless normal recovery-anchor convention requires it and repository
instructions explicitly authorize it.

---

# Mandatory stop-and-report gates

STOP AND REPORT if:

- the observed failure is not actually reproducible/explained by source/logs;
- fixing it requires redesigning the entire onboarding state machine;
- a schema/migration change appears necessary;
- the repair would require touching attachment archive authority;
- the only proposed fix is widget-side masking of a provider lifecycle problem;
- production MessageLens or production data would need to be accessed;
- a new unrelated architecture defect is uncovered.

Do not work around a stop gate.

---

# Final report

Report:

1. exact log/assertion;
2. root-cause call path;
3. why failure publication also failed;
4. why stale success/progress remained visible;
5. exact code correction;
6. files changed;
7. tests added/changed;
8. focused validation results;
9. architecture result;
10. full-suite result;
11. analyzer result;
12. generation result;
13. `git diff --check`;
14. project conformance verdict;
15. documentation/release metadata changes;
16. commit hash;
17. complete Git status;
18. whether any stop gate occurred.

Conclude exactly:

`ONBOARDING IMPORT STUCK-STATE FIX READY FOR REVIEW: YES / NO`

Then STOP.
