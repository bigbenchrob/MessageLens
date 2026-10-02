# MessageLens Feature 34
## 32 — Correct Advanced Start Fresh Currentness and Reset UX

Response 31 completed the post-Onboarding forensic audit.

The runtime checkpoint remains sound. The next blocker is now specific and source-proven:

> Advanced Start Fresh evaluates stale startup installation classification instead of current durable installation state at invocation.

Observed sequence:

```text
startup classified resumable
-> new initialImport completes successfully
-> durable operation becomes completed
-> user invokes Reset message data…
-> AdvancedStartFreshActionImpl still sees resumable
-> request throws before authorization/presentation
-> error escapes to PlatformDispatcher
```

The Settings top menu also reopens after the first transient reset action, forcing a second selection merely to close it.

This task is a **bounded correction** of:
1. Advanced Start Fresh currentness;
2. visible ineligibility/failure handling;
3. the directly related transient Settings-menu closure behavior.

Do NOT investigate favourites here.
Do NOT change Contacts/picker/Scrollbar code.
Do NOT change rich-text import/progress behavior.
Do NOT reopen Journey authority or Feature 35.
Do NOT change Start Fresh destructive scope.
Do NOT alter schema/persistence.
Do NOT launch GUI qualification.
Do NOT stage/commit/push until review.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`
- HEAD `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- tracked worktree clean
- index empty
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`

Read:
- Response 31;
- canonical Start Fresh / clean-slate qualification records;
- Advanced Start Fresh action/provider;
- installation-classification provider/classifier;
- Settings transient-menu/action-dispatch code;
- existing Start Fresh/Settings tests.

Create a fresh external baseline manifest before editing.

If tracked source has drifted, STOP AND REPORT.

---

# 2. Preserve startup-vs-current-state distinction

Startup classification remains valid for startup routing.

Do not make startup classification itself continuously reactive merely to fix this action unless that is already the intended contract.

Advanced Start Fresh needs a separate invocation-time answer:

> **What is the installation classification now?**

That answer must come from current durable evidence.

---

# 3. Source-trace the stale boundary before editing

Trace:

```text
SettingsActionListActions.selectActionCallback
-> SidebarActionDispatcher.dispatch(ResetMessageDataRequested)
-> advancedStartFreshActionProvider
-> AdvancedStartFreshActionImpl.request
-> authorization/presentation
-> StartFreshService
```

Identify:
- where stale startup classification is captured;
- whether it is constructor-captured/provider-cached/read once;
- which existing classifier can produce a fresh current classification;
- whether it can be called read-only at invocation;
- what exact state permits Advanced Start Fresh.

Do not implement until this is source-proven.

---

# 4. Required currentness behavior

At each invocation:

1. obtain a **fresh current installation classification**;
2. evaluate reset eligibility from that result;
3. if current state is `completed`, continue to normal authorization/presentation exactly once;
4. if current state is legitimately ineligible, present typed visible feedback;
5. ordinary eligibility/currentness failure must not escape to `PlatformDispatcher`.

Do not cache invocation-time classification for future invocations unless already canonical.

---

# 5. Required regression scenario

Add a deterministic test reproducing the observed bug:

```text
startup classification = resumable
-> durable operation later becomes completed
-> Advanced Start Fresh invoked
-> fresh classification = completed
-> authorization/presentation occurs exactly once
```

The test must fail against the pre-correction implementation.

Do not simply override the action with `completed`; prove the action obtains current classification at invocation.

Also test:

- startup resumable -> current still resumable: no destructive action, no unhandled exception, visible ineligible state;
- startup completed -> current changed to another legitimate ineligible state: current state wins;
- one click -> at most one authorization/presentation attempt.

---

# 6. Visible failure handling

Response 31 showed eligibility failure occurs before `_execute` catch/presentation handling.

Correct that boundary.

Expected:

```text
fresh classification
-> eligibility decision
-> if ineligible:
     visible typed reset-state feedback
     no PlatformDispatcher exception
     no destructive action
```

Reuse existing Settings/Advanced Start Fresh presentation mechanisms.

Do not silently swallow the failure.

---

# 7. Settings transient-menu closure

Response 31 source-traced:

- menu handler calls `setOpen(false)`;
- transient action clears persistent Settings context;
- rebuild with `persistentContextActionId == null` forces menu open again;
- first selection fires correctly but menu visually reopens.

Correct narrowly so:

> selecting `Reset message data…` once dispatches once, shows the reset panel, and leaves the top menu closed.

Requirements:

- one selection dispatches once;
- one selection closes menu;
- projection/rebuild does not reopen it merely because no persistent selection exists;
- persistent Settings navigation remains normal;
- no timing hacks/delayed close.

Add focused tests for these behaviors.

---

# 8. Preserve Start Fresh semantics exactly

Do not change what Start Fresh resets.

It must continue to preserve:
- `user_overlays.db` user intent;
- favourites;
- archive configuration/identity;
- attachment archives.

It must continue to reset only bounded operation/failure/derived-message state and verify virgin state afterward.

No Complete Erase behavior.
No manual database deletion.

---

# 9. Preserve Onboarding authority architecture

Do not change:
- Journey sole semantic authority;
- Feature 35 tenure/capability;
- admitted Environment evidence;
- command predicates;
- operation snapshot schema;
- restart reconciliation.

If this fix appears to require those changes, STOP AND REPORT.

---

# 10. Expected scope

Likely allowed production areas:
- Advanced Start Fresh action/provider;
- narrow current-classification dependency used by that action;
- Settings action/menu state responsible for transient closure.

Likely tests:
- Advanced Start Fresh action tests;
- Settings action/menu tests;
- architecture test only if an existing rule should prevent stale startup classification use for invocation-time reset eligibility.

Do not touch:
- favourites;
- Contacts picker;
- rich-text/import code;
- Feature 35 runtime;
- archive adoption/relocation;
- release metadata.

Before editing, enumerate exact intended files and why.

---

# 11. Validation

Run:

1. focused Advanced Start Fresh currentness tests;
2. Start Fresh service regressions;
3. Settings transient-menu tests;
4. relevant Onboarding authority architecture tests if changed;
5. complete architecture suite;
6. analyzer;
7. full Flutter suite (production source changes in this task);
8. `git diff --check`;
9. formatting/generated consistency.

Record exact counts.

Do not launch GUI qualification in this task.

---

# 12. Project Conformance

Require PASS for:

- startup classification and invocation-time classification remain distinct;
- Advanced Start Fresh uses current durable classification;
- ineligibility is visible and typed, not a PlatformDispatcher escape;
- exactly-once reset authorization/presentation;
- transient Settings action closes menu in one selection;
- persistent Settings navigation unaffected;
- Start Fresh destructive scope unchanged;
- overlays/favourites preserved;
- Journey/Feature 35 authority unchanged;
- no schema/persistence drift;
- no unrelated feature changes.

Require:

`PROJECT CONFORMANCE: PASS`

with:
- BLOCKER: 0
- SHOULD FIX: 0

---

# 13. Leave unstaged for review

Do not stage, commit, or push.

Leave the correction unstaged for one bounded human review.

This is not permission to reopen the Onboarding architecture correction.

---

# 14. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline verification;
2. exact stale-classification source trace;
3. selected current-classification mechanism;
4. Advanced Start Fresh currentness correction;
5. visible ineligibility/failure-handling correction;
6. startup-resumable -> current-completed regression test;
7. other currentness regression tests;
8. exactly-once action result;
9. Settings transient-menu root cause;
10. Settings menu closure correction;
11. menu regression tests;
12. Start Fresh destructive-scope non-change;
13. Journey/Feature 35 non-change;
14. exact changed-file census;
15. focused test results;
16. complete architecture result;
17. analyzer result;
18. full Flutter-suite result;
19. diff/format/generated hygiene;
20. Project Conformance verdict;
21. BLOCKER findings;
22. SHOULD FIX findings;
23. preservation/baseline comparison;
24. exact Git status;
25. readiness for bounded human review.

Conclude exactly:

`ADVANCED START FRESH CURRENTNESS DEFECT CORRECTED: YES / NO`

`RESET MESSAGE DATA ONE-CLICK UX CORRECTED: YES / NO`

If both are YES, also conclude:

`READY FOR BOUNDED HUMAN RESET REVIEW BEFORE CHECKPOINT: YES / NO`

Then STOP.
