# MessageLens Feature 34
## 40 — AppCzar Architecture Audit and Simplification Design

Prompt 39 is superseded. Do **not** implement the two local Response 38 fixes yet.

This task is a **read-only architecture audit and simplification design**.

The objective is not to patch the current state machinery. The objective is to determine how much of it can be deleted and replaced by one simple governing model:

> **AppCzar wakes up on every launch knowing nothing, directly inspects reality, derives exactly one current application condition, and chooses exactly one coordinator to govern what happens next.**

The design must be explainable to a human on a whiteboard in a few minutes.

Do NOT modify source or tests.
Do NOT stage, commit, or push.
Do NOT launch MessageLens Development.
Do NOT run Start Fresh or import Messages.
Do NOT mutate any database.
Do NOT access production data.
Do NOT continue Prompt 39 implementation.
Do NOT preserve complexity merely because it already exists.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- accumulated Prompt 32 + Prompt 35 correction present and unchanged;
- index empty;
- shared-instructions submodule clean;
- no Prompt 39 implementation has occurred.

Read Response 38, the current Onboarding/Journey architecture, Feature 35 authority records, startup classification, SidebarFlow/center-panel architecture, durable operation state, import/graph/reset orchestration.

Do not assume any existing system should survive unchanged.

---

# 2. Proposed governing laws

Treat these as candidates to test and simplify.

1. **Every launch begins with AppCzar knowing nothing.**

2. **All current app-state judgments are derived from directly observable present evidence, never from persisted historical state calculations.**

3. **The complete observation set must collapse into one and only one AppCzar classification. Zero or multiple matches are themselves an error condition.**

4. **AppCzar chooses one and only one coordinator.**

5. **AppCzar chooses jurisdiction, not Journey position.** If it selects Onboarding, the self-contained Onboarding Journey runs its own current tests and determines its own Trip/Step.

6. **A Journey has no durable cursor.** No persisted current Trip, current Step, waiting-for-FDA state, or Journey completion position.

7. **Progress belongs to one live execution.** Batch/page/high-water/progress state may live in memory while a coordinator runs; it is not cross-session app state.

8. **Interrupted derived builds are disposable.** If a build was not independently verified as complete, discard it and rebuild from the beginning rather than resume it.

9. **Coordinators do not declare the next app state.** No semantic completion handoff such as `onOnboardingComplete`, `installationReady=true`, or `transitionToOperating`.

10. **Only a freshly launched AppCzar may determine that MessageLens is Operating.**

11. Explore whether every coordinator has only two legal terminal behaviours:

   - `OK`: bounded work completed without requiring reclassification; yield to user.
   - `RESTART`: work may have changed the fundamental app classification; restart the app so a fresh AppCzar reassesses from zero.

12. **Do it. Stop. Reassess.** If a design says “do A, then depending on the result hand control to B or C,” first ask whether A should instead restart and let fresh AppCzar determine reality.

---

# 3. Observable evidence

Audit what AppCzar can independently observe and truly needs.

Potential evidence:

- current FDA reality;
- `chat.db` reachability/readability;
- current source message count/high-water facts;
- Contacts source reachability;
- working graph schema/integrity;
- graph counts/topology/readability;
- overlay schema/integrity;
- attachment archive configuration/identity/volume availability;
- source-vs-derived deltas;
- other independently inspectable current health facts.

For each, state:

1. how it is observed;
2. whether it is current reality or historical fact;
3. whether AppCzar truly needs it;
4. whether it can be removed from launch assessment.

Do not force non-database facts such as FDA into SQLite merely for uniformity.

---

# 4. Durable facts versus durable conclusions

Census every durable record currently used to control app state and classify it as:

- **A — directly observable current fact**: persistence may be unnecessary;
- **B — irreducible durable fact**: cannot reliably be reconstructed and has legitimate future value;
- **C — historical diagnostic fact only**: may be retained but must have zero authority;
- **D — persisted conclusion/stale state**: candidate for deletion.

Scrutinize especially:

- operation status;
- resumability;
- current Journey Trip/Step;
- waiting-for-FDA flags;
- installation-complete/readiness conclusions;
- persisted current sidebar/contact/conversation selection;
- cross-session orchestration state.

Ask of every C/D item:

> What breaks if AppCzar stops consulting this on launch?

Favor deletion.

---

# 5. Is any durable Journey/operation state needed?

Answer directly:

- Does Onboarding need durable Journey state if every activation reruns its own reality tests?
- Does initial import need durable page/batch progress if interrupted work is always discarded?
- Does graph build need cross-session resume state?
- Does rich-text enrichment need cross-session resume state?
- After a crash, is observable incomplete derived data + logs + a tiny retry fact enough?

Design the minimum durable execution record, if any.

A preferred result is “none beyond a tiny failure-attempt counter/ledger and ordinary logs,” but do not force it if correctness genuinely requires more.

---

# 6. Repeated-failure policy

Explore a deliberately tiny persistent fact for repeated initial-build failures.

Candidate:

```text
fresh build attempt starts
-> increment durable consecutive-attempt count

fresh AppCzar later verifies a complete healthy installation
-> reset count to zero
```

After more than three failed/interrupted attempts, stop automatic retry and show the user a clear diagnostic dialog with:

- explanation that MessageLens has repeatedly failed to prepare;
- button to package/send diagnostic logs to the developer;
- optionally an explicit user-requested retry.

Determine whether a counter or tiny append-only attempt ledger is simpler/safer.

This fact may affect retry policy. It may **not** decide AppCzar state.

---

# 7. Foreground control model

Audit whether the entire foreground model can be reduced to:

```text
ASSESSING
    AppCzar owns attention

COORDINATOR RUNNING
    exactly one coordinator owns the current job

USER
    user is making the currently permitted choice / using the operating app
```

Clarify how a Journey waiting for user choice fits without creating a competing authority.

The design must make simultaneous coordinators mechanically impossible.

---

# 8. Startup assessment UI

Design a factual startup surface driven directly by AppCzar observations.

This is not a decorative splash.

Example:

```text
Checking MessageLens…

✓ Full Disk Access
✓ Messages database reachable
✓ MessageLens graph healthy

Messages on Mac                 138,832
Messages in MessageLens         138,822
New messages                         10

Attachments waiting                  2

Checking Contacts…
Checking archive…
```

Requirements:

- show observations as they are actually obtained;
- no fake progress;
- make failures visible;
- classification occurs only after the required evidence set is complete;
- normal operational UI cannot exist while AppCzar is Assessing.

Historical information such as `Last session: Contacts — Rusung` may be shown only if clearly diagnostic/history and has zero authority to restore navigation.

Identify which current startup/Environment UI could be deleted or reused.

---

# 9. Coordinator work UI

When a coordinator runs, show its actual work.

Example:

```text
Updating MessageLens…

Importing 10 new messages       6 / 10

Importing attachments           1 / 2
IMG_4821.HEIC
```

Journey coordinators may show their existing self-contained presentation such as FDA instructions.

Do not let generic app presentation independently infer what a coordinator is doing.

Audit which current progress/snapshot/presentation systems become unnecessary.

---

# 10. Fresh Operating session

Explore the simplest normal startup:

```text
Operating begins

sidebar = Conversations
selected conversation = null
selected contact = null
center = null
```

No previous navigation becomes current automatically.

If “restore where I left off” is ever desired, it must be an explicit product feature rather than hidden fundamental state restoration.

Audit current durable SidebarFlow/navigation preference machinery for deletion or demotion to history-only.

---

# 11. Ongoing health/remediation

The model must naturally handle conditions previously thought “onboarding-only.”

Examples:

```text
FDA missing + graph empty/incomplete
=> AppCzar chooses Onboarding

FDA missing + established healthy graph exists
=> AppCzar chooses Lost-FDA Remediation
```

Also consider:

- source DB unreachable;
- source ahead of graph;
- graph integrity failure;
- external archive unavailable;
- invalid archive identity/configuration;
- corrupt overlay;
- schema mismatch;
- graph absent;
- source/graph mismatch.

Do not design every remediation Journey yet. Prove AppCzar can classify these without historical workflow state.

---

# 12. Ball/track relationship

Preserve Feature 35's narrow role.

Ball/track answers:

> **Who currently has exclusive authority to mutate a protected resource?**

AppCzar answers:

> **What kind of application condition exists now, and which coordinator governs it?**

A coordinator may acquire mutation authority while running.

Do not make AppCzar itself the mutation lock.
Do not make Ball tenure an app-state classification.

Carry forward but do not implement the clarity cleanup:

> Rename `ownerLabel` toward `diagnosticOwnerLabel` later because it is diagnostic metadata, not proof.

---

# 13. Current authority census

Enumerate every current production object/provider/service that can influence:

- startup classification;
- onboarding position;
- readiness;
- reset state;
- sidebar state;
- center state;
- maintenance state;
- install/resume decisions;
- operational readiness;
- navigation restoration;
- graph/data generation currentness.

For each classify it as:

- KEEP AS AUTHORITY
- DEMOTE TO EVIDENCE
- KEEP AS WORKER
- KEEP AS PRESENTATION
- DELETE
- MERGE INTO APPCZAR
- MERGE INTO JOURNEY
- UNDECIDED

The target must contain dramatically fewer semantic authorities.

---

# 14. Deletion-oriented migration map

Do not propose a new additive framework sitting on top of the current system.

For each major mechanism, say whether it is:

- retained;
- simplified;
- absorbed;
- made in-memory only;
- made diagnostic-only;
- deleted.

Especially scrutinize:

- installation classifier;
- Environment Readiness;
- durable operation snapshot;
- restart reconciliation;
- resume disposition;
- durable Journey state;
- SidebarFlow navigation persistence;
- stored center-panel state;
- display-identity generation/currentness plumbing;
- maintenance lock projected into app semantics;
- startup splash/restricted shell;
- reset/onboarding completion handoffs.

Prefer fewer concepts/files/providers/states after migration than before.

---

# 15. Minimum AppCzar state set

Do not start with current state names.

Derive the smallest mutually exclusive set needed only to answer:

> Which jurisdiction owns the app now?

Do not encode Journey Trip/Step detail.

For every state give:

- observable predicate;
- chosen coordinator;
- whether coordinator may end `OK` or must `RESTART`;
- allowed UI;
- mechanically impossible UI.

The table must be understandable without Flutter/Riverpod knowledge.

---

# 16. Mechanical Impossibility rules

Develop a concise structural rule set, including at least:

1. If AppCzar is Assessing, operational sidebar/center do not exist.
2. If Onboarding governs, normal operational sidebar/center do not exist.
3. If Operating governs, installation/Journey presentation does not exist.
4. Non-Operating state cannot contain selected conversation/contact state.
5. Center exists only as a derivation of current operating sidebar state.
6. Persisted previous navigation cannot become current without a current human action.
7. A coordinator cannot select another coordinator.
8. A coordinator that changes jurisdiction restarts the app.
9. Only fresh AppCzar assessment can produce Operating.
10. Persisted facts cannot directly activate UI state.

Add only rules that materially simplify the model.

---

# 17. Scenario challenge

Walk the model through:

1. first launch, no FDA;
2. FDA granted during Onboarding;
3. quit while waiting for FDA;
4. killed halfway through initial import;
5. killed after import actually completed but before any old success flag;
6. import fails three times;
7. healthy launch, no new messages;
8. healthy launch, 10 new messages and 2 new attachments;
9. healthy app loses FDA between sessions;
10. graph integrity failure;
11. external archive missing;
12. Start Fresh completes;
13. user quits during reset/rebuild;
14. graph/source counts disagree;
15. stale previous contact/conversation navigation exists;
16. contradictory evidence fits no valid classification.

For each use only:

```text
observations
-> AppCzar classification
-> chosen coordinator
-> terminal behavior
-> next launch if applicable
```

If explanations become long, treat that as evidence the model is still too complex.

---

# 18. Evidence AppCzar must never consume

Create an explicit blacklist.

Candidate forbidden inputs:

- last rendered screen;
- last selected contact/conversation;
- previous Journey Trip;
- previous Journey Step;
- previous AppCzar classification;
- old Environment “ready” conclusion;
- worker success callback;
- UI progress snapshot;
- Ball diagnostic owner label;
- historical operation state whose current condition is independently observable.

This blacklist should later become enforceable.

---

# 19. Do not implement

This task ends with architecture only.

No code changes.

The user must be able to read the proposed laws/state table and understand the whole control model without specialist terminology.

If the target design still requires phrases such as:

- historical intent;
- restore/admission boundary;
- competing readiness states;
- semantic projection synchronization;
- reconciliation of multiple state authorities;

then the simplification has failed.

---

# 20. Required response

Create Response 40.

Use ordinary English first. Technical mapping comes afterward.

Report:

1. executive summary in plain language;
2. proposed final AppCzar laws;
3. evidence AppCzar observes;
4. evidence AppCzar must never trust;
5. minimum AppCzar state table;
6. exactly-one-coordinator rule;
7. coordinator `OK` versus `RESTART` rule;
8. Journey self-location rule;
9. whether durable Journey position can be deleted;
10. whether durable import resume state can be deleted;
11. minimum durable execution/failure facts still required;
12. repeated-failure policy;
13. startup assessment UI model;
14. coordinator work UI model;
15. fresh Operating session model;
16. ongoing FDA/remediation model;
17. Ball/track relationship;
18. current semantic-authority census;
19. deletion/demotion map;
20. Mechanical Impossibility rules;
21. 16-scenario walkthrough;
22. existing architecture pieces that can be deleted;
23. existing architecture pieces worth retaining;
24. migration risks;
25. migration sequencing recommendation;
26. estimated net change in conceptual/state complexity;
27. unresolved product decisions;
28. whether Prompt 39 remains superseded;
29. exact Git/worktree/index/submodule state;
30. confirmation nothing was modified.

Conclude exactly:

`APPCZAR SIMPLIFICATION DESIGN COMPLETE: YES / NO`

`TARGET CONTROL MODEL HAS ONE TOP-LEVEL SEMANTIC AUTHORITY: YES / NO`

`DURABLE JOURNEY CURSOR REQUIRED: YES / NO`

`INTERRUPTED INITIAL IMPORT RESUME REQUIRED: YES / NO`

`READY FOR HUMAN ARCHITECTURE REVIEW BEFORE IMPLEMENTATION: YES / NO`

Then STOP.
