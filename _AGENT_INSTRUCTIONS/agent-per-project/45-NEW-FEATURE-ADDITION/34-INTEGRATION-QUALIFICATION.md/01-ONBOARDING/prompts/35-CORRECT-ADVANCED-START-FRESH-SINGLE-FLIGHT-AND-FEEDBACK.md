# MessageLens Feature 34
## 35 — Correct Advanced Start Fresh Single-Flight Admission and Immediate Feedback

Response 34 established that Start Fresh itself succeeded and the installation is now virgin, but repeated taps on the visually inert reset action created overlapping Advanced Start Fresh flows. At least three accepted requests reached execution paths: one completed the reset, one collided with mutation authority, and one later failed because the installation was already virgin.

This is **not primarily a debounce problem**. The required correction is:

> **Advanced Start Fresh must be single-flight from the first human request through classification, authorization, mutation, verification, Journey handoff, and terminal presentation.**

A time-window debounce is insufficient because fresh classification can legitimately take several seconds.

The current development data state is valuable and must remain untouched:

- installation: virgin;
- operation snapshot: idle;
- import DB: absent;
- graph DB: valid and empty;
- Claire and Rusung favourite intents preserved;
- Toshiba archive configuration/identity preserved.

Do NOT launch MessageLens Development.
Do NOT run Start Fresh.
Do NOT import Messages.
Do NOT mutate the development databases.
Do NOT reopen Journey authority or Feature 35.
Do NOT change Start Fresh destructive semantics.
Do NOT stage, commit, or push.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`
- HEAD `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- Prompt 32 correction present and unstaged
- index empty
- shared-instructions clean at `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check` PASS.

Read Responses 32 and 34 plus the current Advanced Start Fresh action/provider/presentation, reset Settings action/button, authorization dialog, and focused tests.

Create a fresh external baseline manifest before editing.

If Prompt 32 bytes have drifted, STOP AND REPORT.

---

# 2. Preserve the two exclusivity layers

There are two different exclusivity problems:

1. **User-action single-flight** — only one Advanced Start Fresh human intent may be active.
2. **Mutation authority** — only the admitted holder of `ArchiveMutationOperation.startFresh` may mutate protected state.

Feature 35 already solves the second. Do not misuse mutation tenure as a substitute for the first and do not add another global authority.

The single-flight mechanism must remain local to Advanced Start Fresh.

---

# 3. Do not implement time-based debounce

Do not use timers or 300–500 ms click suppression.

Required semantics:

```text
inactive
-> first request synchronously claims action
-> immediate visible feedback
-> classification
-> one authorization
-> one service execution
-> terminal result
-> release claim
```

Any later request while active may join the active Future or return a typed no-op, but it must not:

- perform another current-state read;
- open another authorization dialog;
- mint another presentation occurrence;
- invoke StartFreshService again.

---

# 4. Claim before the first await

The request claim must happen synchronously before:

- current-state reading;
- authorization;
- presentation occurrence creation;
- service invocation.

Unsafe sequence to eliminate:

```text
tap A -> await classification
tap B -> second classification -> second authorization
```

Required:

```text
tap A -> synchronous claim A -> busy feedback -> await classification
tap B while A active -> no new flow
```

The action itself must enforce this; UI disablement alone is not sufficient.

---

# 5. Carry one request identity through the whole flow

Use one private action/request identity from claim to terminal outcome:

```text
request A
-> current-state read A
-> authorization A
-> presentation A
-> service A
-> virgin verification A
-> Journey handoff A
-> terminal presentation A
```

Do not persist it.
Do not expose it as Journey state.
Do not make it mutation authority.

It may be used in privacy-safe diagnostics.

---

# 6. Immediate feedback on the red Reset Message Data action

Response 34 confirms the red action currently looks dead during the several-second current-state read.

When idle, provide normal macOS-appropriate interaction feedback:

- hover/rollover;
- pressed acknowledgement;
- clear enabled state.

Immediately on the first accepted tap:

- enter visible busy/checking state synchronously;
- disable further activation;
- show concise text such as `Checking reset availability…`.

Do not imply mutation has begun yet.

The UI should clearly distinguish:

1. checking eligibility;
2. waiting for confirmation;
3. starting fresh/resetting.

Do not fabricate percentage progress.

---

# 7. While classification runs

During the bounded read:

- red action stays disabled;
- busy/checking feedback stays visible;
- no second state read can begin;
- no authorization exists yet.

If classification is ineligible, show the existing typed ineligibility presentation and release the single-flight claim after terminal visible outcome.

If the read fails, show the existing typed unavailable-state presentation and release safely.

No uncaught `PlatformDispatcher` error.

---

# 8. Exactly one authorization route

For one active request:

- request authorization exactly once;
- no stacked dialogs;
- later taps/calls while authorization is pending do nothing/join.

If cancelled:

- no mutation;
- return to idle;
- release claim;
- later request may start fresh.

If accepted:

- the same request identity continues;
- do not release the claim.

---

# 9. Immediate feedback after Start Fresh confirmation

When the user clicks **Start Fresh** in the confirmation UI:

- acknowledge immediately;
- prevent double-submit;
- dismiss/transition the confirmation exactly once;
- show the existing preparing/operation presentation immediately.

Reuse truthful existing copy such as `Preparing a fresh start`.

If no real subphase evidence exists, keep one stable indeterminate busy state while service runs. Do not invent fake progress.

The operation presentation must not be hidden behind another authorization route.

---

# 10. Service execution and success ownership

After authorization:

- exactly one `StartFreshService` call may occur;
- duplicate requests cannot supersede its presentation.

On verified success:

```text
service returns verified virgin
-> same request publishes verified-virgin / Starting Onboarding
-> Journey refresh/handoff
-> overlay dismisses via existing reconciliation
-> release single-flight claim
```

A successful destructive operation must never become visually lost because a duplicate request created a newer occurrence.

Preserve stale-result protection for genuinely obsolete work outside this now-single-flight request.

---

# 11. Failure ownership

If service execution fails:

- the same request publishes the existing typed failure;
- no duplicate request may hide it;
- no uncaught error;
- release/retry behavior follows the existing terminal failure contract.

A late duplicate must never replace the active request's success/failure.

---

# 12. Privacy-safe lifecycle diagnostics

Add minimal diagnostics with the private request identity:

- request received;
- request claimed;
- duplicate request ignored/joined;
- current-state read start/end + classification kind;
- authorization requested;
- authorization cancelled/accepted;
- service start/end;
- terminal presentation outcome;
- request released.

Do not log message/contact content.
Do not persist the request ID.

Diagnostics are not authority.

---

# 13. Deterministic race tests

Use Completers/barriers, never sleeps.

Required:

### A. Rapid taps during slow current-state read
Assert one reader invocation, one active request, one authorization max, zero duplicate occurrences.

### B. Repeated taps while authorization pending
Assert one dialog/authorization and no second classification.

### C. Repeated taps while service pending
Assert one service invocation and one presentation occurrence.

### D. Successful destructive completion under duplicate input
Reproduce Response 34's race. Assert successful verified-virgin presentation remains current, no authority-denied duplicate failure appears, no already-virgin duplicate failure appears, and Journey handoff occurs once.

### E. Cancel
One classification, one authorization, zero service, claim released, later request succeeds.

### F. Ineligible state
Visible typed ineligibility, one read, zero service, claim released.

### G. Reader failure
Visible unavailable-state feedback, zero service, safe release.

### H. Service failure
One service, visible terminal failure, no duplicate masking, existing retry semantics preserved.

---

# 14. Widget/interaction tests

Required:

### Red action idle
- hover/rollover visible;
- press acknowledgement visible;
- clear enabled affordance.

### Slow classification
- busy/checking feedback appears immediately;
- action disabled;
- further taps do not dispatch new flows.

### Authorization transition
- exactly one confirmation route;
- no stacking.

### Confirmation Start Fresh button
- immediate acknowledgement;
- cannot submit twice;
- preparing presentation replaces confirmation promptly.

### Service pending
- stable busy/preparing feedback.

### Verified success
- existing verified-success / Starting Onboarding presentation appears;
- Journey handoff may dismiss it;
- no duplicate dialog obscures it.

No arbitrary millisecond assertions.

---

# 15. Preserve Prompt 32 corrections

Do not regress:

- fresh invocation-time classification;
- typed ineligibility;
- typed unavailable-state feedback;
- one-selection Settings-menu closure;
- persistent Settings navigation.

Do not revert to startup classification.

---

# 16. Preserve destructive and authority semantics

Do not change:

- StartFreshService destructive allow-list;
- MessageDataResetService semantics;
- overlay/favourite preservation;
- archive configuration/identity preservation;
- attachment archive preservation;
- virgin verification;
- Feature 35 mutation tenure;
- Journey sole semantic authority;
- snapshot schema;
- restart reconciliation.

The new single-flight mechanism is not a replacement for archive mutation tenure.

---

# 17. Protect the current virgin development state

Do not launch the app.
Do not run tests against the real development root.
Do not use write-capable database helpers on the development data.

All tests must use isolated fixtures/temp stores.

---

# 18. Scope discipline

Expected production scope may include:

- Advanced Start Fresh action/provider;
- Advanced Start Fresh presentation state;
- reset action widget/view-model for busy/disabled/hover feedback;
- authorization button only if needed to prevent double-submit;
- minimal diagnostics.

Expected tests:

- Advanced Start Fresh action/provider tests;
- presentation/widget tests;
- reset Settings action tests.

Do not touch:

- Journey coordinator;
- Feature 35 runtime;
- favourites;
- Contacts;
- rich-text/import pipeline;
- attachment relocation/adoption;
- release metadata.

Before editing, list exact intended files and why.

---

# 19. Architecture enforcement boundary

Do not start another architecture-hardening cycle.

If an existing architecture test needs a narrow update, do it.

Behavioral race tests are the primary proof.

Do not invent a new generic authority framework for this UI single-flight.

---

# 20. Validation

Run:

1. focused single-flight action tests;
2. slow-reader / authorization / service race tests;
3. reset UI feedback tests;
4. Prompt 32 currentness regressions;
5. Start Fresh service regressions;
6. Settings-menu regressions;
7. relevant architecture tests if changed;
8. complete architecture suite;
9. analyzer;
10. full Flutter suite;
11. `git diff --check`;
12. format/generation consistency.

Record exact counts.

Do not launch GUI qualification.

---

# 21. Project Conformance

Require PASS for:

- synchronous claim before first await;
- at most one active request;
- at most one state read per active human intent;
- at most one authorization route;
- at most one service invocation;
- duplicates cannot mint newer presentation occurrences;
- immediate checking/busy feedback;
- red action disabled while active;
- confirmation cannot double-submit;
- verified destructive success remains visible;
- cancel/failure release semantics correct;
- fresh current classification preserved;
- Settings one-click menu closure preserved;
- Feature 35 mutation authority unchanged;
- Journey authority unchanged;
- Start Fresh destructive scope unchanged;
- real virgin development state untouched;
- no unrelated changes.

Require:

`PROJECT CONFORMANCE: PASS`

with:
- BLOCKER: 0
- SHOULD FIX: 0

---

# 22. Leave unstaged for corrected-build human qualification

Do not stage, commit, or push.

Leave Prompt 32 + Prompt 35 accumulated correction unstaged.

The next task, if validation passes, will build the correct main-worktree app and hand it to the human starting from the already-virgin development state.

---

# 23. Required response

Create Response 35 and report:

1. baseline and virgin-state preservation gate;
2. exact pre-edit file scope;
3. selected single-flight design;
4. synchronous claim point;
5. duplicate-request behavior;
6. request identity/lifetime;
7. red-action immediate-feedback correction;
8. slow-classification feedback behavior;
9. authorization single-route correction;
10. confirmation double-submit prevention;
11. service single-invocation correction;
12. verified-success presentation ownership;
13. cancel/ineligible/read-failure/service-failure release semantics;
14. privacy-safe lifecycle diagnostics;
15. slow-reader duplicate-request test results;
16. authorization-pending duplicate test results;
17. service-pending duplicate test results;
18. destructive-success-under-duplicate-input result;
19. cancel/failure/retry results;
20. UI hover/pressed/busy/disabled results;
21. Prompt 32 regression results;
22. Start Fresh service regressions;
23. Settings-menu regressions;
24. exact changed-file census;
25. architecture result;
26. analyzer result;
27. full Flutter-suite result;
28. diff/format/generated hygiene;
29. Project Conformance verdict;
30. BLOCKER findings;
31. SHOULD FIX findings;
32. confirmation real development virgin state was untouched;
33. exact Git status;
34. readiness for corrected-build human qualification.

Conclude exactly:

`ADVANCED START FRESH SINGLE-FLIGHT CORRECTED: YES / NO`

`RESET FLOW IMMEDIATE FEEDBACK CORRECTED: YES / NO`

If both are YES, also conclude:

`READY FOR CORRECTED-BUILD CLEAN-SLATE HUMAN QUALIFICATION: YES / NO`

Then STOP.
