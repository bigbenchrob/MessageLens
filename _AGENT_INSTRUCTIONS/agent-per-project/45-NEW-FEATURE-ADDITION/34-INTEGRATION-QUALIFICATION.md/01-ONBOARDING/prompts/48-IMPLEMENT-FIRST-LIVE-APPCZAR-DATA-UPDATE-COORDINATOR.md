# MessageLens Feature 34
## 48 — Implement the First Live AppCzar Coordinator: Data Update

Response 47 passed the repeated direct-launch Fair-Witness experiment.

The current real development evidence with source access ON was:

```text
Messages source              138,831 messages
Source high-water            155007
MessageLens import data      138,823 messages
Local live high-water        154999
MessageLens graph            138,823 messages
New messages                 8
```

AppCzar therefore diagnosed:

`The Messages source currently contains newer local data.`

and selected the virtual coordinator:

`Data Update`

This task gives AppCzar its **first narrowly bounded live coordinator**.

The intended experiment is:

```text
launch
-> AppCzar observes current world
-> AppCzar selects Data Update
-> exactly one Data Update coordinator runs
-> it updates the healthy local dataset from the current Messages source
-> it does NOT declare Operating
-> it ends by requesting a real application restart
-> fresh process
-> fresh AppCzar reassesses from zero
-> if the evidence now reconciles, AppCzar independently selects Operating Session
```

This is the first end-to-end proof of:

> **Do it. Stop. Reassess.**

All other coordinator mappings remain virtual.

Do NOT make Onboarding live.
Do NOT make Source Access Repair live.
Do NOT make Archive Repair live.
Do NOT make Local Data Repair live.
Do NOT make Diagnostic Review live.
Do NOT route production startup through AppCzar.
Do NOT stage, commit, or push.

---

# 1. Baseline

Require:

- worktree `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch `fix/onboarding-import-stuck-state`
- HEAD/upstream `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- accumulated Prompt 32 + 35 + 44 + 46 changes present
- Response 47 made no source/test changes
- index empty
- shared-instructions submodule clean.

Read Responses 44, 46, and 47 before editing.

Create a fresh external baseline manifest.

Do not assume the source will still be exactly eight messages ahead when the
human later launches. AppCzar must observe current reality again.

---

# 2. Only Data Update becomes executable

Only this mapping becomes live:

```text
current source is proven ahead of a complete healthy local dataset
-> Data Update Coordinator
```

All other mappings remain:

```text
diagnosis
-> display-only virtual coordinator
-> remain on AppCzar screen
```

Do not create a generic seam that can execute every virtual coordinator enum.

Prefer an explicit development-only Data Update execution seam.

---

# 3. Reuse existing incremental update machinery

Before editing, source-trace the current proven machinery that already updates
a healthy MessageLens installation when `chat.db` advances.

Audit likely existing components such as:

- `ChatDbChangeMonitor`
- source-scoped incremental import workers
- graph update/projector workers
- attachment preservation/sweep workers
- `messageDataVersionProvider`
- existing ArchiveMutationCoordinator/capability/resource admission.

Report:

1. exact worker/service path to reuse;
2. source boundary it consumes;
3. how import and graph are kept coherent;
4. how new attachments are handled;
5. required authority/capability;
6. old semantic callbacks/state publications currently attached to the worker;
7. which parts can be reused as pure workers.

Do **not** build a second importer.

If current incremental machinery cannot safely be invoked without importing old
semantic authority, STOP AND REPORT.

---

# 4. Data Update Coordinator jurisdiction

Its sole job is:

> Bring an already complete, healthy local dataset up to the current readable
> Messages source using existing supported incremental-update workers.

It may:

- acquire existing typed mutation authority;
- invoke proven incremental import/projector workers;
- preserve newly referenced attachment payloads;
- publish live in-memory progress;
- surface a bounded failure;
- end by requesting RESTART.

It may NOT:

- classify the app;
- call AppCzar;
- create another coordinator;
- transition to Operating;
- publish `ready=true`;
- publish Onboarding state;
- write cross-session operation/resume state;
- restore navigation;
- decide what comes after restart.

---

# 5. Revalidate worker prerequisites, not app semantics

AppCzar selected Data Update from one immutable assessment.

Before mutation, reuse the exact resource/currentness checks required by the
existing worker.

Do not create a second application classifier.

If the source has advanced farther since AppCzar assessed it, update to the
worker's supported current/frozen boundary.

If the source becomes unavailable or another hard prerequisite fails before
mutation:

- do not guess;
- do not start another coordinator;
- show a factual coordinator failure;
- restart/reassess.

---

# 6. Exactly one coordinator and one Ball

Required shape:

```text
AppCzar diagnosis
-> one Data Update Coordinator
-> ArchiveMutationCoordinator / existing typed operation
-> one live tenure/capability
-> bounded workers
```

No parallel updater.
No direct use of ExclusiveAuthorityRegistry if ArchiveMutationCoordinator
already owns the domain seam.

Feature 35 remains mutation authority only.

---

# 7. Visible Data Update screen

When Data Update is selected, transition from AppCzar assessment to a dedicated
Data Update coordinator screen.

Use the same calm factual style.

Show actual work only, for example:

```text
Updating MessageLens

Source messages             138,831
MessageLens messages        138,823
Messages to import                 8

Importing messages              3 / 8

Attachments found                  1
Preserving attachment
IMG_1234.HEIC

Updating conversation data…
```

Use only real worker progress/counts/stages.

No fake percentage.
No durable operation-snapshot state.

---

# 8. Coordinator starts mechanically

Once current AppCzar assessment selects Data Update:

- exactly one Data Update coordinator starts;
- the AppCzar rerun control becomes unavailable;
- user cannot start another coordinator occurrence.

Other dispositions still stop at diagnosis and virtual coordinator.

---

# 9. No semantic success callback

This is the central invariant.

The worker/coordinator may internally know its awaited work returned normally.

It may **not** publish:

```text
App is current
App is ready
Operating = true
```

It may not transition AppCzar.

At successful terminal boundary:

```text
bounded Data Update work finished
-> RESTART
```

Fresh AppCzar decides what is true next.

---

# 10. Real process restart

Audit for an existing reliable macOS restart mechanism.

Requirements:

- worker/resources/Ball scope complete before process termination;
- old process actually terminates;
- macOS launches a new process;
- new AppCzar assessment starts from zero;
- no in-memory facts/progress survive.

Do not simulate restart by invalidating Riverpod or navigating to AppCzar in the
same process.

If no suitable existing mechanism exists, implement the smallest
development-safe restart seam and test it carefully.

---

# 11. Preserve the direct-launch development environment

The relaunched development process must still receive:

`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`

from the launchd environment already used for direct-launch experiments.

Do not hard-code the WD path in restart code.

Production behavior remains unchanged.

---

# 12. Failure behavior

If Data Update fails:

- show the literal worker failure;
- do not claim the whole app is broken;
- do not invoke a second coordinator;
- do not resume from a persisted cursor;
- do not enter normal app UI.

Provide a simple `Restart and reassess` path after terminal failure, unless an
automatic restart is clearly safer and already supported.

Fresh AppCzar owns the next semantic decision.

---

# 13. Tests

Use isolated fixtures/temp stores only.

Prove at minimum:

1. only Data Update mapping is executable;
2. healthy/current Operating remains virtual;
3. Source Access Repair remains virtual;
4. Onboarding remains virtual;
5. Data Update selection creates exactly one coordinator;
6. existing incremental worker is invoked once;
7. mutation authority is acquired/released correctly;
8. source advancing between assessment and worker snapshot is safe;
9. source becoming unavailable before mutation produces no semantic handoff;
10. import and graph reach the supported boundary coherently;
11. attachments use existing preservation semantics;
12. progress is memory-only;
13. no durable resume snapshot is required;
14. successful completion cannot create Operating in-process;
15. success requests exactly one restart;
16. restart happens only after resources/tenure release;
17. new process starts with no previous AppCzar facts;
18. normal sidebar/center remains unavailable before fresh reassessment;
19. virtual coordinator mappings cannot accidentally execute.

---

# 14. Real human qualification target

Build but do not launch the final artifact.

The human will direct-launch with the development-root launchd environment set
and source access readable.

Expected sequence:

```text
AppCzar:
source ahead by N
-> Data Update

Data Update Coordinator:
imports N current messages
updates graph/attachments as required
-> RESTART

new PID

AppCzar:
fresh assessment
-> ideally healthy/current
-> Operating Session remains virtual
-> stay on AppCzar screen
```

The human records pre-update and post-restart AppCzar screens.

---

# 15. Do not enter normal Operating UI yet

Even if the new AppCzar assessment says healthy/current after restart:

- `Operating Session` remains virtual;
- do not open Conversations;
- remain on AppCzar screen.

This experiment tests the self-healing control loop only.

---

# 16. Validation

Run:

1. focused Data Update coordinator tests;
2. existing incremental worker regressions;
3. mutation/capability regressions;
4. restart tests;
5. AppCzar mapping/isolation tests;
6. AppCzar coordinator-host UI tests;
7. relevant architecture tests;
8. complete architecture suite;
9. analyzer;
10. full Flutter suite;
11. `git diff --check`;
12. format/generated consistency.

Do not launch production.

---

# 17. Project Conformance

Require PASS for:

- exactly one executable live coordinator mapping;
- all other mappings virtual;
- existing update machinery reused;
- one mutation tenure;
- no second importer;
- no semantic success callback;
- no in-process transition to Operating;
- real restart after jurisdiction-changing success;
- fresh AppCzar assessment after restart;
- progress memory-only;
- no resume snapshot;
- Fair Witness copy only;
- production startup unchanged;
- normal app UI inaccessible in the development harness.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 18. Leave unstaged for human self-healing experiment

Do not stage, commit, or push.

Build the exact development artifact and provide:

- bundle path;
- executable hash;
- App.framework hash;
- version/build;
- direct-launch instructions.

Then STOP.

---

# 19. Required response

Create Response 48 and report:

1. baseline verification;
2. exact existing update machinery selected for reuse;
3. proof no second importer was created;
4. Data Update coordinator scope;
5. AppCzar-to-coordinator execution seam;
6. proof only Data Update is executable;
7. worker prerequisite/currentness checks;
8. mutation-tenure path;
9. live progress model;
10. attachment-preservation behavior;
11. semantic-success-callback non-use;
12. exact restart mechanism;
13. proof restart creates a new process boundary;
14. relaunch environment behavior;
15. terminal failure behavior;
16. coordinator-focused tests;
17. incremental-worker regressions;
18. mutation-authority regressions;
19. restart tests;
20. AppCzar isolation/mapping tests;
21. architecture result;
22. analyzer result;
23. full Flutter-suite result;
24. diff/format/generated hygiene;
25. Project Conformance verdict;
26. BLOCKER findings;
27. SHOULD FIX findings;
28. exact build identity/path/hashes;
29. exact Git/worktree/index/submodule state;
30. readiness for real self-healing Data Update experiment.

Conclude exactly:

`FIRST LIVE APPCZAR COORDINATOR IMPLEMENTED: YES / NO`

`DATA UPDATE REUSES EXISTING UPDATE MACHINERY: YES / NO`

`DATA UPDATE CAN DECLARE OPERATING IN-PROCESS: YES / NO`

`SUCCESS ENDS IN REAL PROCESS RESTART: YES / NO`

`READY FOR HUMAN SELF-HEALING DATA-UPDATE EXPERIMENT: YES / NO`

Then STOP.
