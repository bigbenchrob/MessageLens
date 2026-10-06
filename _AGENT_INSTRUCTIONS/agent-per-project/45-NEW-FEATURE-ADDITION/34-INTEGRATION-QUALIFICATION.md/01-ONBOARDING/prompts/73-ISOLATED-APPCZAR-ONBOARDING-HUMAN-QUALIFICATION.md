# MessageLens Feature 34
## 73 — Isolated AppCzar Onboarding Human Qualification

Response 72 implemented source-grounded executable AppCzar Onboarding Stage One
and passed all automated/conformance gates.

The development execution census is now:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

Onboarding Stage One is deliberately narrow:

```text
safe empty/absent initial derived state
-> Onboarding may build

consequential partial data
protected non-live/historical data
retired/unsupported material
unhealthy or unknown scope
-> NOT Onboarding
```

It performs no cleanup.

This task human-qualifies that architecture using **disposable fixture roots
only**.

It must never point MessageLens Development at the user's populated development
root or active Toshiba attachment archive during the Onboarding experiment.

This task has two required fixture experiments:

```text
A. SAFE EMPTY FIXTURE
   prove AppCzar admits Onboarding
   prove existing initial-build pipeline runs
   prove completion crosses a real process boundary
   prove fresh AppCzar owns the next disposition

B. CONSEQUENTIAL PARTIAL FIXTURE
   prove AppCzar refuses Onboarding
   prove no cleanup/build occurs
   prove Local Data Repair or Diagnostic Review owns the unresolved condition
```

The real Apple Messages and Contacts databases may be read through their normal
read-only source paths. The disposable MessageLens fixture databases are the
only MessageLens stores that may be created or mutated.

Do NOT modify source/tests.
Do NOT stage, commit, push, merge, or rebase.
Do NOT launch production MessageLens.
Do NOT access or mutate the real development root:
`/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`
except for a path-existence guard proving it is not the selected fixture.
Do NOT access or mutate the active Toshiba archive.
Do NOT authorize Attachment Archive Repair if fresh AppCzar selects it after
the disposable initial build.

---

# 1. Exact repository and artifact preflight

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- clean tracked worktree/index;
- ahead/behind `0/0`;
- one Feature 34 development worktree;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

Response 72 implementation commit:

`5435e803b55ba0362a5c8f1e08cfac2bbc43ea72`

Verify it is an ancestor of current HEAD.

Response 72's documentation checkpoint follows that implementation commit and
cannot embed its own hash in the response body. Resolve the actual current HEAD
from Git and report it.

Use the exact Response 72 artifact:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected:

- product: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.139 (157)`
- executable SHA-256:
  `dc457ebd321a5962ea3e42dc733cc9aae7a08ba644dc7104eff0592ab5fcd26e`
- `App.framework/App` SHA-256:
  `ae6b311a95fccd76c1b8734e16def9c50dac3857f43ecd5b0a53a726c5972f8c`

If either hash differs, STOP AND REPORT.

Do not rebuild before qualification.

---

# 2. Source-audit the fixture-construction seam before creating anything

Before creating a fixture, inspect current source/tests and identify the safest
existing way to construct a disposable **admitted development archive root**
with current schemas and identity.

Prefer, in order:

1. an existing qualification/fixture/bootstrap utility already used by tests;
2. a current lower-level archive-marker/database fixture builder;
3. a small external qualification script that calls current project fixture
   APIs.

Do NOT manually invent schema SQL or archive-marker fields if a current typed
fixture/helper exists.

Report:

- exact helper/tool selected;
- files it creates;
- environment marker/instance identity behavior;
- overlay/archive-location behavior;
- whether import/graph stores begin absent or healthy-empty;
- whether it creates any non-live/historical rows;
- whether it touches the real development root or active archive.

If no safe current fixture seam exists, STOP AND REPORT rather than improvising
a pseudo-installation.

---

# 3. Fixture location and isolation

Create a unique disposable qualification parent outside every real MessageLens
data root, for example:

`/private/tmp/messagelens-appczar-onboarding-qualification-<timestamp>/`

Inside it create:

```text
safe-empty/
unsafe-partial/
```

or equivalent isolated roots.

Every root must have its own current archive identity and any required
fixture-local attachment archive/configuration.

Hard guards:

- resolved safe fixture path != real development root;
- resolved unsafe fixture path != real development root;
- neither fixture archive path == Toshiba active archive;
- neither fixture path is nested inside a real MessageLens root;
- no symlink may redirect fixture paths into real data.

Record absolute resolved paths before launch.

---

# 4. Human-visible source-permission preflight

Before Experiment A, record the human-visible Full Disk Access state of the exact
development app.

Treat it only as configuration.

Do not require changing FDA unless the Onboarding experiment naturally reaches a
source prerequisite.

The qualification may read the real Apple Messages and Contacts sources, but
must not write them.

---

# 5. Configure the development launch contract for the SAFE fixture

Set:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "<SAFE_FIXTURE_ROOT>"
```

Read it back and verify exact equality.

Before launch, prove:

- no `MessageLens Development` process is running;
- the selected root is the safe fixture;
- safe fixture contains no consequential import/graph data;
- initial-construction observation for the fixture is expected to be
  `safeEmpty`;
- no protected non-live/historical material is present.

Do not use the populated development root merely as a template copy.

---

# 6. Experiment A — fresh AppCzar selects Onboarding

Direct-launch the exact artifact.

Record PID.

Allow AppCzar to gather current evidence without interference.

Required result:

```text
safe initial-construction scope TRUE
no complete local dataset
-> Onboarding
```

Record the visible Onboarding presentation and current prerequisite state.

There must be:

- no Source Access Repair selection merely because the dataset is absent;
- no Local Data Repair selection;
- no legacy Journey/Environment Readiness authority;
- no normal Conversations workspace before the build/restart cycle completes.

If safe-empty fixture does not select Onboarding, STOP AND REPORT.

---

# 7. Messages prerequisite behavior — qualify only if naturally encountered

If current Messages source is readable, record that and continue.

If Onboarding sees conclusive current source unreadability:

- it must remain in the **same Onboarding jurisdiction**;
- it may show literal source-readability copy;
- it may expose System Settings only when current evidence supports that action;
- `Check Again` must be single-flight;
- it must not invoke Source Access Repair in-process.

If human OS action is needed, perform only the ordinary qualified permission
action.

If macOS itself requires a process restart for the permission change, record
that limitation literally. Do not claim an in-process Check Again success that
the OS does not permit.

If source evidence is UNKNOWN rather than conclusively unreadable, Onboarding
must stop/drain/restart for fresh AppCzar rather than guessing.

Do not force an FDA toggle solely to manufacture this branch.

Automated tests remain the governing evidence if the branch is not naturally
encountered.

---

# 8. Contacts prerequisite behavior

Record the exact typed Contacts result shown/observed.

Expected acceptable current worker prerequisites are:

```text
viable source with contacts
or
viable source with zero contacts
```

If a conclusive human-remediable Contacts prerequisite is encountered:

- remain Onboarding;
- present the literal condition;
- use Check Again after the human action.

If Contacts is invalid/corrupt/UNKNOWN/conflicting:

- stop;
- allow Onboarding to drain/restart;
- fresh AppCzar must own the next disposition.

Do not alter real Contacts data.

Do not claim Contacts is optional.

---

# 9. Initial-build admission

Once all current prerequisites are satisfied, verify that Onboarding admits
exactly one initial build occurrence through:

```text
AppCzar Onboarding
-> ConversationGraphBuildController.runOnce()
-> existing graphBuild mutation tenure
-> existing importers/projectors
```

Record:

- PID;
- visible stage/progress labels actually observed;
- whether Messages import progress is visible;
- whether Contacts/rich-text/graph stages are visible when they occur;
- whether any legacy Journey Episode/ReadyToStart wording appears.

There must be:

- no second importer;
- no cleanup/reset action;
- no attachment-repair coordinator invoked by Onboarding;
- no normal application UI during the build.

---

# 10. Initial-build terminal process boundary

When the initial build worker completes:

Required:

```text
worker completes
-> mutation tenure released
-> Onboarding stopAndDrain
-> old PID disappears
-> fresh PID
-> fresh AppCzar
```

Record:

- old Onboarding PID;
- completion status actually observed;
- old PID disappearance;
- replacement PID;
- whether a no-process interval is observable;
- first fresh AppCzar disposition.

There must be no same-process:

```text
ReadyToStart
-> Conversations
```

handoff.

If Operating appears, it must be selected by the **fresh PID**, not the old one.

---

# 11. Accept any truthful fresh post-build disposition

The disposable fixture may legitimately produce several fresh dispositions
depending on current source/archive facts.

Acceptable examples include:

```text
Attachment Archive Repair
Data Update
Operating
Local Data Repair
Diagnostic Review
```

provided the disposition is based on fresh current evidence.

Because the fixture attachment archive begins empty, Attachment Archive Repair
may be the likely result if current source attachment payloads are available.

If Attachment Archive Repair appears:

- record the current partition;
- DO NOT authorize any preservation batch;
- this qualification does not need payload repair.

The purpose is to prove fresh AppCzar owns the post-Onboarding semantic decision.

---

# 12. Verify the safe fixture was built through existing durable facts

After the restart, inspect only the disposable fixture.

Record:

- current source-scoped import database existence/count;
- conversation graph existence/count/topology;
- overlay/config state;
- archive marker/identity;
- absence of any durable Journey cursor used to resume Onboarding.

Use application-visible current facts where possible; bounded read-only fixture
inspection is permitted.

Do not inspect the real development databases.

---

# 13. End Experiment A cleanly

Quit the development app normally.

Confirm no development process remains.

Unset:

`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`

and verify empty.

Do not delete the safe fixture yet; it may be used only as a source for
constructing the unsafe fixture if the construction method preserves isolation
and is explicitly reviewed in the next section.

---

# 14. Construct Experiment B — deliberately consequential partial fixture

The unsafe fixture must prove the most important Stage One safety property:

> **Consequential partial derived data cannot be mistaken for virgin/empty
> Onboarding scope.**

Use a current fixture/helper or a reviewed fixture-only transformation.

Preferred simple shape:

```text
valid current archive identity/configuration
+ source-scoped import store containing consequential message/import data
+ conversation graph absent or incomplete
```

This may be constructed from a copy of the disposable safe fixture **only if**:

- all paths/configuration are rebound to the unsafe fixture;
- it does not share a writable fixture archive/root with Experiment A;
- no real data root is referenced;
- the transformation affects disposable fixture data only.

Alternative fixture builders are acceptable if they express the same
consequential-partial fact more cleanly.

Do NOT use corruption as the primary unsafe case; this experiment is about
consequential partial data, not unhealthy SQLite.

Before launch, record the exact fixture facts that make it unsafe for
Onboarding.

---

# 15. Configure launch contract for the UNSAFE fixture

Set:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "<UNSAFE_FIXTURE_ROOT>"
```

Verify exact equality.

Confirm no development process is running.

Take a before-launch bounded fingerprint/count snapshot of the fixture's
consequential derived data.

This is the no-cleanup witness.

---

# 16. Experiment B — AppCzar must refuse Onboarding

Direct-launch the exact same artifact.

Record PID.

Required result:

```text
consequential partial derived data
-> initialConstructionScopeSafe FALSE
-> NOT Onboarding
```

Expected current destination:

```text
Local Data Repair
```

if the facts are conclusive and match that disposition, or:

```text
Diagnostic Review
```

if the fixture evidence is intentionally/actually insufficient.

Either is acceptable if current facts justify it.

What is NOT acceptable:

```text
Onboarding
-> cleanup
-> initial build
```

Record the exact AppCzar facts/disposition shown.

---

# 17. Prove no cleanup or build occurred

While the unsafe disposition remains visible:

- do not invoke any repair action;
- do not modify the fixture.

Verify:

- no Onboarding controller started;
- no graph build started;
- no reset/cleanup worker started;
- no import/graph deletion occurred;
- no normal workspace was admitted.

After quitting, compare the disposable fixture against the before-launch
fingerprint/count snapshot.

Consequential partial data must still exist unchanged, except for strictly
identified non-semantic fixture-local diagnostic/log writes if the application
normally produces them.

If any derived-data cleanup occurred, qualification FAILS.

---

# 18. Optional protected non-live fixture extension

Only if an existing fixture helper makes this trivial and low risk, add a third
disposable fixture containing protected non-live/historical source material.

Expected:

```text
protected non-live material
-> NOT Onboarding
```

Do not create this case manually if it requires complex schema manipulation.

This subtest is OPTIONAL; automated tests remain governing evidence if not
exercised.

---

# 19. Fair-Witness review

Across both experiments confirm:

- safe-empty scope is positively proven, not inferred from missing completion;
- source FALSE does not by itself force Source Access Repair when safe
  no-dataset scope owns Onboarding;
- source UNKNOWN is not called denial;
- Contacts zero is not called failure;
- Contacts UNKNOWN/corrupt is not guessed;
- initial build does not declare Operating;
- post-build fresh AppCzar owns the next disposition;
- consequential partial data is not called disposable;
- no old Journey Episode, snapshot, or failure row selects current state.

---

# 20. stopAndDrain corroboration

Experiment A should corroborate the build-success drain boundary.

Record evidence that:

- no stale Onboarding progress appears in the replacement PID;
- old PID is gone before replacement AppCzar owns the next jurisdiction;
- no second build starts automatically after restart.

Do not deliberately interrupt a live initial build during this first
qualification.

Automated tests remain the proof of mid-build quit/failure drain semantics.

---

# 21. Cleanup

At the end:

1. quit any remaining MessageLens Development process;
2. verify none remains;
3. unset `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`;
4. verify it is empty;
5. leave human-visible FDA configuration in its pre-test intended state;
6. do not modify/stage/commit source or tests;
7. preserve the disposable fixture roots until Response 73 is written and all
   evidence is captured;
8. then they may be deleted only if the human does not request preservation.

Do not touch the real development root or Toshiba archive during cleanup.

---

# 22. Qualification verdict

A full PASS requires both:

## Experiment A

```text
safe empty current facts
-> Onboarding

existing initial-build pipeline
-> build

real process restart
-> fresh AppCzar
-> next jurisdiction
```

## Experiment B

```text
consequential partial current facts
-> NOT Onboarding
-> no cleanup
-> no build
-> fixture data preserved
```

The Messages/Contacts human-prerequisite branches may be `NOT EXERCISED` if
they do not naturally arise; their automated qualification remains valid.

---

# 23. Required response

Create Response 73 and report:

1. exact Git HEAD/upstream state;
2. Response 72 implementation ancestry;
3. exact artifact/hash verification;
4. fixture-construction seam audit;
5. safe fixture absolute path/identity/configuration;
6. proof safe fixture is isolated from all real MessageLens roots/archives;
7. human-visible source-permission preflight;
8. safe-fixture launchd value;
9. Experiment A initial PID;
10. fresh AppCzar safe-scope facts;
11. Onboarding selection result;
12. Messages prerequisite result;
13. Contacts prerequisite result;
14. Onboarding self-location result;
15. initial-build admission result;
16. visible build progress/stages;
17. proof existing worker pipeline was used;
18. proof no cleanup/reset occurred;
19. old Onboarding PID and terminal behavior;
20. new PID after build;
21. fresh post-build AppCzar disposition;
22. proof no same-process Operating handoff occurred;
23. safe fixture durable import/graph result;
24. proof no durable Journey cursor was used;
25. Onboarding stopAndDrain corroboration;
26. unsafe fixture construction method;
27. unsafe fixture absolute path/identity/configuration;
28. exact consequential partial facts before launch;
29. unsafe-fixture launchd value;
30. Experiment B PID;
31. unsafe initial-scope classification;
32. Local Data Repair / Diagnostic Review disposition;
33. proof Onboarding did not execute;
34. proof no graph build executed;
35. proof no cleanup/reset executed;
36. before/after fixture data preservation result;
37. optional protected-non-live subtest result or NOT EXERCISED;
38. Fair-Witness verdict;
39. errors/warnings/evidence limitations;
40. cleanup result;
41. overall Onboarding Stage One human qualification verdict;
42. recommendation for checkpointing qualification;
43. readiness for Local Data Repair milestone;
44. readiness for Diagnostic Review milestone;
45. readiness for production AppCzar cutover.

Conclude exactly:

`SAFE EMPTY FIXTURE SELECTED APPCZAR ONBOARDING: YES / NO / NOT REACHED`

`INITIAL BUILD USED THE EXISTING PIPELINE: YES / NO / NOT REACHED`

`INITIAL BUILD ENDED AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`FRESH APPCZAR OWNED THE POST-BUILD DISPOSITION: YES / NO / NOT REACHED`

`CONSEQUENTIAL PARTIAL FIXTURE WAS REFUSED BY ONBOARDING: YES / NO / NOT REACHED`

`NO CLEANUP OR BUILD OCCURRED ON CONSEQUENTIAL PARTIAL DATA: YES / NO / NOT REACHED`

`APPCZAR ONBOARDING HUMAN LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`READY TO CHECKPOINT ONBOARDING HUMAN QUALIFICATION: YES / NO`

`READY FOR LOCAL DATA REPAIR MILESTONE: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
