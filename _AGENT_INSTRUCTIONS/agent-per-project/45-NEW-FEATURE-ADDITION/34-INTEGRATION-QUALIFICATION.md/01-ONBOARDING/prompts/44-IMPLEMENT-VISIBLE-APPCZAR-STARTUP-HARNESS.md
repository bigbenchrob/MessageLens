# MessageLens Feature 34
## 44 — Implement the Visible AppCzar Startup Harness

Prompt 43 is superseded in one important respect:

> AppCzar should no longer be invisible/shadow-only.

The human wants the development app to **open directly to the AppCzar assessment
screen** so we can watch the Fair-Witness assessment happen against the real
development installation.

For now, the rest of MessageLens does not matter.

The development app should:

1. launch;
2. show the AppCzar assessment surface immediately;
3. gather current observations;
4. derive TRUE / FALSE / UNKNOWN facts;
5. select exactly one descriptive actionable finding;
6. determine exactly one coordinator that *would* be called;
7. display both at the bottom of the AppCzar screen;
8. **STOP THERE**.

Do not actually launch the selected coordinator yet.

This makes the AppCzar screen an executable diagnostic harness we can exercise
against real conditions such as:

- FDA present;
- FDA deliberately removed later;
- archive volume disconnected;
- healthy source/graph;
- source ahead of graph;
- partial/incomplete derived data.

We will learn from real observations before allowing AppCzar to control the rest
of the app.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- accumulated Prompt 32 + Prompt 35 correction unchanged;
- Prompt 39 remains superseded/unimplemented;
- Responses 40 and 41 present;
- index empty;
- shared-instructions submodule clean.

Read Responses 38, 40, and 41 in full before editing.

Create a fresh external baseline manifest.

If the accumulated source differs from the last reviewed handoff, STOP AND REPORT.

---

# 2. Development-only takeover for the experiment

For the **development build only**, replace the current startup presentation
sequence with AppCzar.

The development app must no longer show:

- `Checking databases…`;
- `Checking what MessageLens needs`;
- Environment Readiness;
- normal Conversations/Contacts UI;
- Onboarding;
- any other current startup semantic surface.

Instead:

```text
launch
  -> AppCzar assessment screen
  -> remain on AppCzar screen after diagnosis
```

This is an intentional diagnostic hold.

Production/release behavior must remain unchanged during this experiment.

Use the existing exact development/build-identity gate. Do not introduce a
loose debug Boolean or environment-variable bypass.

---

# 3. AppCzar has observation authority only

The experimental AppCzar may:

- inspect current evidence;
- derive facts;
- select one actionable finding;
- calculate the coordinator mapping;
- present all of that to the human.

It may NOT:

- instantiate the coordinator;
- run Onboarding;
- run Update;
- run remediation;
- enter Operating;
- mutate SQLite;
- reset data;
- import data;
- acquire Ball tenure;
- navigate to normal application UI.

At this stage:

> **Diagnosis is real. Action is virtual.**

The line at the bottom says which coordinator **would** be called.

---

# 4. Build the smallest real fact model needed

Do not mechanically implement all Response 41 F00–F26 facts.

Start with the facts required to diagnose the current real development
installation correctly.

Add only enough neighbouring facts to distinguish obvious nearby states.

Expected initial observation areas:

- development data root admitted;
- FDA current status;
- `chat.db` current reachability;
- source message count/high-water when readable;
- import-store existence/readability/count;
- graph-store existence/readability/count/basic health;
- overlay existence/readability/basic health;
- configured attachment archive availability/identity if necessary to choose a
  launch action;
- source-versus-local delta when prerequisites allow it.

Every fact must be justified as necessary for diagnosis or coordinator
selection.

Prefer a smaller graph we can understand on the screen.

---

# 5. Fair-Witness semantics

Use exactly:

```text
TRUE
FALSE
UNKNOWN
```

Examples:

```text
Full Disk Access
  TRUE

Messages source readable
  UNKNOWN — waiting for FDA
```

Never use stale/history to fill UNKNOWN.

Do not consume:

- previous installation classification;
- previous Environment state;
- Journey state;
- operation snapshot;
- resume disposition;
- previous failure state;
- sidebar/navigation state;
- rendered UI state;
- worker callbacks;
- Ball owner labels.

---

# 6. AppCzar opening screen

Design this as the screen we could plausibly keep in the final product.

It should feel calm, factual, and useful rather than like a developer console.

Suggested structure:

```text
MessageLens

Checking your Messages environment…

✓ Full Disk Access
✓ Messages database
    138,832 messages

✓ MessageLens data
    138,822 messages

  New messages
    10

✓ Overlay
    Healthy

✓ Attachment archive
    Toshiba_manual_bu
    Connected

────────────────────────────────

Diagnosis

<plain-English descriptive AppCzar finding>

Coordinator

<coordinator that would be called>
```

During assessment:

- rows appear/update as evidence is actually obtained;
- use spinner/pending state only for genuinely pending work;
- show `?`/UNKNOWN with a plain-English reason;
- do not show fake percentage progress;
- do not hide failed checks.

The bottom Diagnosis/Coordinator area may say:

```text
Diagnosis
Still assessing…

Coordinator
Not selected yet
```

until the fact graph closes.

---

# 7. Keep internal terminology off the primary UI

The primary screen should use human language.

Do not display:

- F17/F24 identifiers;
- Riverpod provider names;
- SQL table names;
- `AppDisposition`;
- `ActionableFrontier`;
- operation UUIDs.

A development disclosure section may optionally expose compact technical details
behind a disclosure triangle if useful, but the default screen should be
understandable without knowing the architecture.

---

# 8. Diagnosis naming

The displayed diagnosis should be a present-tense Fair-Witness statement.

Examples:

```text
This appears to be a healthy current MessageLens installation.
```

```text
MessageLens does not currently have a complete local message dataset.
```

```text
The current Messages source cannot be inspected because Full Disk Access is unavailable.
```

```text
The configured attachment archive is currently unavailable.
```

Do not display historical stories such as:

- Onboarding was interrupted;
- FDA was revoked;
- import failed;
- previous setup was incomplete;

unless present evidence literally proves the statement.

---

# 9. Coordinator mapping display

At the bottom show one and only one virtual coordinator.

Examples:

```text
Coordinator that would be called
Operating Session
```

```text
Coordinator that would be called
Onboarding
```

```text
Coordinator that would be called
Source Access Repair
```

```text
Coordinator that would be called
Attachment Archive Repair
```

This mapping is diagnostic only.

No coordinator constructor should be reachable from the experimental screen.

Add architecture enforcement if useful so the assessment package cannot invoke
coordinator code.

---

# 10. Stop after diagnosis

Once diagnosis is complete, do not transition away.

The screen remains visible until the human closes/relaunches the app.

This is critical: we want to inspect the full result.

A small development-only button may be added:

`Run assessment again`

only if it performs a fresh read-only assessment from zero.

It must not preserve previous fact values.

If adding the button complicates the first implementation, omit it. Relaunching
the development app is sufficient.

---

# 11. Source-trace and bypass the existing broken startup UI

As part of implementation, identify exactly which existing source currently
renders:

1. `Checking databases…`;
2. `Checking what MessageLens needs`;
3. the later blank/empty screen.

For development mode, AppCzar must bypass those presentation paths.

Do not delete them yet.

Report the current sequence and the exact development-only interception point.

Production remains untouched.

---

# 12. Run against the actual development installation

After implementation and focused validation, build the correct development app.

The human will launch it.

Do not drive the GUI automatically.

Expected human experience:

```text
launch
-> AppCzar screen immediately
-> observations populate
-> diagnosis appears
-> virtual coordinator appears
-> screen stays there
```

There must be no intermediate legacy startup screens.

---

# 13. Prepare for deliberate environmental experiments

The design should make later experiments easy without code changes.

We expect to try things such as:

- turn FDA off;
- relaunch;
- observe AppCzar;
- turn FDA back on;
- relaunch;
- observe AppCzar;

and perhaps later:

- disconnect Toshiba archive;
- relaunch;
- reconnect;
- relaunch.

AppCzar must derive its answer afresh every launch.

Do not add developer switches that simulate these conditions if we can safely
exercise the real development environment later.

---

# 14. Deterministic tests

Add focused tests proving at least:

1. same observation set always produces same diagnosis/coordinator;
2. observation completion order cannot change diagnosis/coordinator;
3. FDA unavailable makes dependent source facts UNKNOWN, not FALSE;
4. healthy-current evidence maps to exactly one virtual Operating coordinator;
5. incomplete local dataset maps to one virtual Onboarding coordinator;
6. complete dataset + source inaccessible maps to one source-access coordinator;
7. unavailable archive maps deterministically according to the current tie rule;
8. contradictory/insufficient evidence maps to one diagnostic coordinator;
9. no assessment result can instantiate a coordinator;
10. rerunning a new assessment does not inherit previous fact values.

Use pure fixtures wherever possible.

---

# 15. Real-development read-only safety

The AppCzar screen may inspect the development installation using normal
read-only application readers.

It must not:

- delete partial data;
- repair anything;
- create missing stores merely to make inspection easier;
- migrate schemas;
- checkpoint databases;
- mutate overlay;
- touch attachment payloads;
- start monitors that write;
- run Onboarding/import.

If a missing store cannot be safely inspected without creating it, report its
absence as the observation.

---

# 16. Validation

Run:

1. focused AppCzar fact/evaluator tests;
2. UI projection tests;
3. development-gate tests;
4. architecture isolation tests;
5. complete architecture suite;
6. analyzer;
7. `git diff --check`;
8. formatting/generated consistency.

A full Flutter suite is appropriate if the startup composition changes broadly;
use judgment and report whether it was run and why.

Do not launch production.

---

# 17. Project Conformance

Require PASS for:

- development launch shows only AppCzar startup surface;
- production startup behavior unchanged;
- AppCzar consumes only current factual evidence;
- TRUE/FALSE/UNKNOWN semantics;
- no stale/history inputs;
- exactly one diagnosis;
- exactly one virtual coordinator;
- no coordinator invocation;
- no mutation;
- no Ball acquisition;
- no normal app UI construction in the development diagnostic hold;
- assessment order independence;
- relaunch begins from no previous fact state;
- no new semantic authority outside AppCzar.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 18. Leave unstaged for human experimentation

Do not stage, commit, or push.

Leave the AppCzar startup harness unstaged.

Build the correct development app and provide exact path/hash handoff.

Then STOP.

The human will launch it and report what AppCzar says about the current broken
development installation.

---

# 19. Required response

Create Response 44.

Report:

1. baseline verification;
2. exact development-only interception point;
3. source of old `Checking databases…` screen;
4. source of old `Checking what MessageLens needs` screen;
5. cause/source of old blank/empty state;
6. exact AppCzar implementation file scope;
7. minimum observation set;
8. minimum fact set;
9. TRUE/FALSE/UNKNOWN implementation;
10. diagnosis selection rule;
11. virtual coordinator mapping;
12. proof no coordinator can run;
13. AppCzar UI structure;
14. pending/UNKNOWN UI behavior;
15. bottom diagnosis display;
16. bottom virtual-coordinator display;
17. real-development read-only safety proof;
18. development-only gate proof;
19. production non-change proof;
20. deterministic fact tests;
21. observation-order test;
22. architecture isolation result;
23. focused UI result;
24. complete architecture result;
25. analyzer result;
26. full-suite decision/result;
27. diff/format/generated hygiene;
28. Project Conformance verdict;
29. BLOCKER findings;
30. SHOULD FIX findings;
31. exact build identity/path/hashes;
32. exact Git/worktree/index/submodule state;
33. readiness for human AppCzar experimentation.

Conclude exactly:

`VISIBLE APPCZAR DEVELOPMENT HARNESS IMPLEMENTED: YES / NO`

`LEGACY DEVELOPMENT STARTUP SURFACES BYPASSED: YES / NO`

`APPCZAR DIAGNOSIS IS READ-ONLY: YES / NO`

`APPCZAR VIRTUAL COORDINATOR DOES NOT EXECUTE: YES / NO`

`READY FOR HUMAN APPCZAR ENVIRONMENT EXPERIMENTS: YES / NO`

Then STOP.
