# MessageLens Feature 34
## 52 — Implement Source Access Repair as the Second Live AppCzar Coordinator

Response 51 checkpointed the first AppCzar milestone and completed the legacy-semantic-authority audit.

Current recovery anchor:

- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`
- implementation milestone: `ddcbeb64fc17eac817ce2b8c802ae1c7e0530ac7`
- documentation milestone: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`

The first live AppCzar coordinator, `Data Update`, is qualified.

The next bounded coordinator is `Source Access Repair`, but Response 51 found one Fair-Witness defect that must be corrected first:

```text
messagesSourceReadable == FALSE
    -> Source Access Repair

messagesSourceReadable == UNKNOWN
    -> Diagnostic Review / insufficient evidence
```

At present, the evaluator collapses FALSE and UNKNOWN because it uses `truth != TRUE`.

This task:
1. corrects that evaluator defect;
2. implements `Source Access Repair` as the second and only other executable AppCzar coordinator;
3. keeps every other coordinator virtual;
4. gives the human a bounded way to restore source access;
5. ends successful repair with a real process restart;
6. never claims to know the macOS FDA setting itself.

Do NOT route production startup through AppCzar.
Do NOT make Onboarding executable.
Do NOT make Local Data Repair executable.
Do NOT make Archive Repair executable.
Do NOT make Diagnostic Review executable.
Do NOT make Operating Session executable.
Do NOT remove the legacy startup architecture yet.
Do NOT stage, commit, push, or merge until qualification is complete.

---

# 1. Baseline

Require:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`.

Read Responses 46, 47, 48, 50, and 51 plus the canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Correct FALSE versus UNKNOWN first

In `app_czar_evaluator.dart`, make source-readability selection exact.

Required behavior:

```text
Messages source readable == TRUE
    -> continue evaluating downstream facts

Messages source readable == FALSE
    -> Source Access Repair

Messages source readable == UNKNOWN
    -> Diagnostic Review / insufficient or contradictory evidence
```

Do not use `truth != TRUE` to select Source Access Repair.

The UNKNOWN branch must not claim an access defect.

Use the existing diagnostic/indeterminate virtual coordinator or introduce only the smallest pure enum/value needed.

Add focused tests proving:
- FALSE and UNKNOWN take different paths;
- FALSE selects Source Access Repair;
- UNKNOWN does not;
- neither path claims FDA state;
- observation order does not affect selection.

---

# 3. Source Access Repair selection contract

`Source Access Repair` may run only when a fresh AppCzar assessment contains a conclusive current source-readability failure.

Selecting fact:

```text
Messages source readable == FALSE
```

backed by a current source probe categorized as `accessDenied` or another conclusive `unavailable` condition.

Do not select it from:
- UNKNOWN;
- stale prior failure;
- persisted failure history;
- visible macOS settings state;
- previous coordinator result;
- old Onboarding/Journey state.

---

# 4. Coordinator jurisdiction

The coordinator owns only this bounded problem:

> The current MessageLens process cannot currently read the Messages source, and the human may need to change macOS privacy settings or otherwise restore access.

It may:
- explain the literal source-access failure;
- identify the current development bundle involved;
- guide the human to macOS Privacy & Security settings;
- open the relevant System Settings pane if a safe existing mechanism exists;
- perform a bounded read-only `Check Again` probe;
- show the literal result;
- on proven readable source, request a real process restart.

It may NOT:
- claim FDA is OFF;
- claim FDA is ON;
- claim MessageLens granted or revoked FDA;
- mutate TCC/privacy databases;
- shell out to unsupported permission-changing commands;
- infer the cause of every source-open failure;
- chain directly to Data Update;
- chain directly to Operating Session;
- persist repair success;
- write Journey/resume state;
- classify the whole application.

---

# 5. Fair-Witness screen

Use calm factual copy, for example:

```text
Messages access needs attention

MessageLens cannot currently read the Messages database.

macOS reported:
<literal bounded source-readability reason>

MessageLens cannot determine from this evidence whether Full Disk Access is enabled or disabled.

A common repair is to review:
System Settings → Privacy & Security → Full Disk Access

[Open System Settings]
[Check Again]
```

Exact wording may improve, but preserve the semantics:
- current fact: source cannot be read;
- cause: not overclaimed;
- FDA: guidance, not testimony;
- repair: human-controlled;
- verification: fresh read-only probe.

Do not use wording such as:
- `Full Disk Access is off`;
- `Full Disk Access is on`;
- `Permission repaired` merely because a toggle changed.

---

# 6. System Settings navigation only

Audit for an existing macOS settings-navigation helper.

If one exists, reuse it.

If not, add the smallest infrastructure adapter that opens the relevant System Settings pane through a supported macOS mechanism.

This action is navigation only.

It must not:
- inspect TCC internals;
- mutate TCC;
- parse the visible toggle;
- treat successful pane opening as repair success.

Test it behind an interface.

Keep platform mechanics out of evaluator/coordinator domain logic.

---

# 7. Check Again is a bounded read-only retest

Provide one explicit single-flight `Check Again` control.

On invocation:
1. synchronously claim a local single-flight guard before the first await;
2. perform one fresh bounded source-readability probe;
3. do not reuse the AppCzar assessment object as proof;
4. display the literal new result.

Possible outcomes:

## A. Readable

If the source is now conclusively readable:
- say only that the current read-only check succeeded;
- do not claim `FDA repaired`;
- do not inspect downstream source/local delta here;
- do not invoke Data Update;
- do not invoke Operating;
- request a real process restart.

Fresh AppCzar decides everything downstream.

## B. Still conclusively unreadable

Remain in the coordinator.
Show the current literal failure reason.
Allow another user-initiated `Check Again`.
No automatic polling.

## C. Inconclusive / UNKNOWN

Do not reinterpret it as access denial.

Show literal inconclusive copy such as:

```text
MessageLens could not determine whether the Messages source is currently readable.
```

The original coordinator jurisdiction is no longer proven by the retest.

Offer only `Restart and reassess`, or automatically request restart if simpler and clearly bounded.

Do not invoke Diagnostic Review in-process.

---

# 8. No polling

Do not continuously poll while System Settings is open.

One click equals one fresh bounded read-only probe.

No hidden repeated work.
No ambient semantic transitions.

---

# 9. Real restart on proven repair

Reuse the qualified process-restart mechanism from Data Update.

On readable retest:

```text
Source Access Repair
-> fresh read-only source probe succeeds
-> coordinator ends
-> old process terminates
-> LaunchServices relaunches same bundle
-> fresh AppCzar assessment from zero
```

No in-process semantic callback.
No handoff payload.
No `repair succeeded, now run Data Update`.

The fresh process may independently select Data Update, Operating Session, another virtual coordinator, or Diagnostic Review.

---

# 10. No Ball

Source Access Repair is not a MessageLens data mutation.

It must not acquire the archive mutation Ball merely to:
- render instructions;
- open System Settings;
- probe source readability;
- restart.

If an existing helper unexpectedly requires mutation authority, STOP AND REPORT.

---

# 11. Development-only execution seam

For this milestone, only the exact development AppCzar harness may execute the coordinator.

After Prompt 52, exactly two AppCzar coordinators may be executable:

```text
Data Update
Source Access Repair
```

All others remain virtual.

Do not introduce generic enum dispatch.

Prefer explicit per-coordinator execution seams with architecture tripwires.

---

# 12. Preserve Data Update qualification

Do not change Data Update semantics except for strictly necessary shared host plumbing.

Regression-test that:
- source-ahead still selects/runs Data Update;
- Data Update still cannot declare Operating;
- Data Update still ends in real restart;
- Source Access Repair cannot invoke Data Update;
- Data Update cannot invoke Source Access Repair.

No coordinator chaining.

---

# 13. Tests

Use fixtures/fakes only.

At minimum prove:

1. source-readable FALSE selects Source Access Repair;
2. source-readable UNKNOWN selects Diagnostic Review/indeterminate, not Source Access Repair;
3. source-readable TRUE does not select Source Access Repair;
4. only Data Update and Source Access Repair are executable;
5. Source Access Repair starts exactly once;
6. no archive mutation Ball is acquired;
7. settings navigation is navigation-only;
8. opening settings is not treated as source-access success;
9. Check Again is local single-flight;
10. Check Again performs a fresh read-only probe;
11. readable retest requests exactly one real restart;
12. readable retest does not invoke Data Update or Operating;
13. still-unreadable retest remains in coordinator with literal current reason;
14. UNKNOWN retest does not claim access denial;
15. UNKNOWN retest cannot chain to another coordinator;
16. no persisted Journey/operation/repair-success state is written;
17. no FDA ON/OFF statement appears in domain/presentation copy;
18. source failure history cannot select the coordinator;
19. restart uses the existing qualified process-boundary service;
20. fresh process receives no repair-result payload;
21. Data Update regressions still pass;
22. architecture rejects generic permission-wizard dependencies;
23. architecture rejects direct TCC mutation APIs/commands in the coordinator package.

---

# 14. Human qualification experiment to prepare

Build but do not launch the final development artifact.

The human will qualify:

## Scenario A — conclusive source access failure

1. direct-launch with the development app's visible FDA toggle OFF;
2. AppCzar should select live Source Access Repair;
3. Source Access Repair screen appears automatically;
4. no other coordinator starts;
5. human opens System Settings from the coordinator or manually;
6. human enables the development app entry;
7. human returns and presses `Check Again`;
8. current source probe becomes readable;
9. coordinator requests a real restart;
10. new PID launches;
11. fresh AppCzar independently decides what is true now.

If source data advanced while access was unavailable, fresh AppCzar may select Data Update. That must happen only after restart.

## Scenario B — UNKNOWN source evidence

Do not manufacture this on the real machine.

Automated tests are sufficient unless a natural inconclusive condition occurs.

Required semantic guarantee:

```text
UNKNOWN != access denied
```

---

# 15. Stop gates

Stop if:
- macOS privacy state is claimed rather than source readability;
- Source Access Repair acquires archive mutation authority;
- coordinator writes durable semantic state;
- coordinator polls continuously;
- readable retest directly runs Data Update;
- readable retest directly declares Operating;
- UNKNOWN is routed to Source Access Repair;
- generic coordinator dispatch is introduced;
- production startup behavior changes.

---

# 16. Validation

Run:

1. focused evaluator tests;
2. Source Access Repair controller tests;
3. settings-navigation adapter tests;
4. source-readability retest tests;
5. process-restart regressions;
6. Data Update regressions;
7. AppCzar host/mapping tests;
8. architecture tests;
9. complete architecture suite;
10. analyzer;
11. full Flutter suite;
12. `git diff --check`;
13. formatting/generated consistency.

Do not launch production.

---

# 17. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:
- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:
- FALSE and UNKNOWN are distinct;
- Fair-Witness copy only;
- no TCC mutation;
- no unsupported FDA statement;
- Source Access Repair is memory-only;
- no Ball;
- no coordinator chaining;
- real restart on proven readable retest;
- Data Update remains isolated;
- production startup unchanged.

---

# 18. Leave unstaged for human qualification

Do not stage, commit, push, merge, or rebase.

Build the exact development artifact.

Provide:
- bundle path;
- version/build;
- executable hash;
- App.framework hash;
- exact direct-launch instructions;
- exact Scenario A human steps.

Then STOP.

---

# 19. Required response

Create Response 52 and report:

1. baseline verification;
2. exact FALSE-vs-UNKNOWN evaluator correction;
3. focused evaluator test results;
4. Source Access Repair selection contract;
5. coordinator jurisdiction;
6. human-facing Fair-Witness copy;
7. settings-navigation implementation/reuse;
8. proof no TCC mutation exists;
9. Check Again single-flight design;
10. readable retest behavior;
11. still-unreadable retest behavior;
12. UNKNOWN retest behavior;
13. proof no polling exists;
14. proof no Ball is acquired;
15. exact restart path;
16. proof no coordinator chaining exists;
17. proof only Data Update and Source Access Repair are executable;
18. Data Update regression result;
19. Source Access Repair focused tests;
20. settings-navigation tests;
21. restart tests;
22. AppCzar mapping/host tests;
23. architecture result;
24. analyzer result;
25. full Flutter-suite result;
26. diff/format/generated hygiene;
27. Project Conformance verdict;
28. BLOCKER findings;
29. SHOULD FIX findings;
30. exact build identity/path/hashes;
31. exact Git/worktree/index/submodule state;
32. readiness for the human Source Access Repair qualification experiment.

Conclude exactly:

`UNKNOWN SOURCE READABILITY NO LONGER SELECTS SOURCE ACCESS REPAIR: YES / NO`

`SOURCE ACCESS REPAIR IMPLEMENTED AS SECOND LIVE COORDINATOR: YES / NO`

`SOURCE ACCESS REPAIR CAN CLAIM FDA STATE: YES / NO`

`SOURCE ACCESS REPAIR CAN CHAIN DIRECTLY TO DATA UPDATE OR OPERATING: YES / NO`

`READY FOR HUMAN SOURCE ACCESS REPAIR QUALIFICATION: YES / NO`

Then STOP.
