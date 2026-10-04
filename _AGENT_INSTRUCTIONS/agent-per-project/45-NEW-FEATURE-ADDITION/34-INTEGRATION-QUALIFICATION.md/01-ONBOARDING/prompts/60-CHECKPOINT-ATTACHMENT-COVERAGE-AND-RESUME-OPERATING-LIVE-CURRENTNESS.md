# MessageLens Feature 34
## 60 — Checkpoint Attachment Coverage and Resume Operating-Owned Live Currentness

Response 59 closed the Prompt 58 architectural blocker.

A fresh AppCzar can now independently reconstruct whether the currently admitted
local graph's required conventional attachment payloads are completely covered
by durable archive evidence.

The important new invariant is:

```text
Operating
    implies
attachment coverage == TRUE
```

and the critical previously-unclassifiable state is now reconstructible:

```text
source/import/graph current
archive root available
attachment coverage incomplete
-> fresh AppCzar does NOT admit Operating
```

No historical operation-success/failure flag participates.

Before resuming Operating-owned live currentness, however, one wording/source
consistency issue in Response 59 must be resolved explicitly.

Response 59 Section 30 says the three executable AppCzar predicates are:

```text
Onboarding
Data Update
Source Access Repair
```

and says Operating is an admitted shell.

Earlier qualified milestones instead established the development AppCzar live
set as:

```text
Data Update
Source Access Repair
Operating Session
```

with Onboarding still virtual.

This task must source-audit the actual code before making any Stage Two edit.
Do not assume the Response 59 list is either correct or a typo.

If the source actually makes Onboarding executable in the development AppCzar
route, STOP AND REPORT before Stage Two work.

If the source confirms the prior intended architecture and Response 59 merely
misstated the census, record the exact correction and continue.

This task then:

1. checkpoints and pushes the Prompt 59 attachment-coverage milestone;
2. implements Operating Session Stage Two: Operating-owned live currentness;
3. adds the awaitable Operating shutdown/drain boundary identified in Response
   58;
4. leaves Stage Two unstaged for human qualification.

Do NOT route production startup through AppCzar.
Do NOT make Attachment Archive Repair executable.
Do NOT re-enable Journey/readiness authority.
Do NOT add a generic coordinator dispatcher.
Do NOT stage/commit/push Stage Two before human qualification.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`
- Prompt 59 implementation present and unstaged;
- index empty;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

Read:

- Response 54;
- Response 57;
- Response 58;
- Response 59;
- current AppCzar host/composition source;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. First resolve the executable-disposition census

Before staging or Stage Two editing, trace the actual source.

Report every production/development AppCzar execution predicate and every host
branch that can start top-level work.

At minimum inspect:

- `AppCzarStartupHarness`;
- all `shouldExecuteAppCzar...` functions;
- Operating admission/controller;
- Onboarding selection/execution code;
- architecture tests that count executable predicates.

Classify each AppCzar disposition as exactly one of:

```text
EXECUTABLE TOP-LEVEL COORDINATOR
EXECUTABLE ADMITTED SESSION
VIRTUAL ONLY
LEGACY PRODUCTION-ONLY / OUTSIDE DEVELOPMENT APPCZAR ROUTE
```

Required architectural expectation unless source proves an approved change:

```text
Data Update          EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session    EXECUTABLE ADMITTED SESSION
Onboarding           VIRTUAL ONLY
Attachment Repair    VIRTUAL ONLY
Local Data Repair    VIRTUAL ONLY
Diagnostic Review    VIRTUAL ONLY
```

Do not reduce this to a count alone.

If Onboarding is now executable from the development AppCzar route, STOP AND
REPORT.

If Response 59 Section 30 is a documentation error, explicitly say so and
continue without changing source merely to match the report.

---

# 3. Checkpoint Prompt 59

Audit the exact Prompt 59 diff.

Separate:

1. attachment-coverage observation/domain;
2. read-only coverage probe;
3. AppCzar fact-DAG integration;
4. Operating-admission predicate change;
5. archive-probe composition;
6. tests/architecture enforcement;
7. generated files;
8. release metadata;
9. Prompt/Response 58–60 documentation;
10. unrelated untracked material.

Do not use `git add .`.

Re-run the required Prompt 59 validation on the exact staged tree.

If clean, create:

### Attachment coverage implementation checkpoint

Recommended subject:

`feat(startup): add reconstructible attachment coverage`

### Documentation checkpoint

Follow the existing Feature 34 documentation convention.

Push the branch normally as a recovery anchor.

No force push, rebase, merge, or PR merge.

Report exact commits and branch/upstream state before Stage Two edits.

---

# 4. Stage Two governing model

Operating Session remains the one long-lived top-level jurisdiction after fresh
AppCzar admission.

Ordinary currentness maintenance is an internal Operating service:

```text
fresh AppCzar
-> Operating Session admitted
-> normal workspace

OperatingCurrentnessService
-> bounded observation cadence
-> if no delta: silence
-> if ordinary source-ahead:
     one internal live-update occurrence
     -> existing mutation authority
     -> LiveGraphUpdateWorker
     -> attachment preservation
     -> generation refresh
     -> same PID
     -> same Operating occurrence
     -> same navigation
```

The internal service is **not** added to `AppCzarVirtualCoordinator`.

It cannot select another top-level disposition.

---

# 5. Reuse current factual seams

The currentness service may observe only the minimum current facts needed to
decide ordinary same-session maintenance:

- current source readability;
- stable source count/high-water;
- local imported count/high-water;
- graph/import prerequisites required by the worker;
- current admitted archive identity/generation;
- current attachment coverage as needed before/after mutation.

Do not depend on:

- Journey;
- Environment Readiness;
- installation-state classifier;
- persisted failure history;
- operation-completion flags.

Do not instantiate the full AppCzar evaluator as an internal mini-Czar.

---

# 6. Operating-owned lifetime

Implement one generation/occurrence-bound currentness service.

Required:

- starts only after Operating admission;
- bound to the exact Operating assessment generation plus a unique
  process-local occurrence identity;
- one observation scheduler;
- no work before shell admission;
- stops accepting work immediately when Operating begins shutdown;
- stale callbacks from an old occurrence cannot publish/mutate a new one;
- provider disposal alone is not relied upon to await in-flight mutation.

No generic App-root watcher.

---

# 7. Implement an awaitable `stopAndDrain()` boundary

Response 58 identified this as a mandatory lifecycle condition.

Implement the smallest explicit lifecycle contract such as:

```text
Future<void> stopAndDrain()
```

or an idiomatic equivalent.

It must:

1. synchronously mark the occurrence as no longer accepting new observations or
   updates;
2. cancel/disarm the next scheduled observation;
3. wait for any admitted observation to settle;
4. wait for any admitted live-update mutation tenure/worker occurrence to
   return and release;
5. prevent stale completion from republishing into a disposed/new occurrence.

Use the Flutter/macOS exit-request lifecycle seam already audited if that is
still the correct integration point.

Normal user quit must await/drain this boundary before Operating teardown
completes where platform lifecycle permits.

Any AppCzar-required restart from Operating must also drain first.

Do not allow an active Ball tenure to outlive Operating.

---

# 8. Observation cadence

Use the audited normal product interval:

`15 seconds`

unless current source proves a different canonical constant.

Prefer a rescheduled one-shot timer:

```text
observe
-> finish
-> schedule next
```

rather than a periodic timer that can overlap.

Requirements:

- no overlapping observations;
- no hidden queue;
- no high-frequency polling;
- no observation after stop begins.

Make the cadence injectable/testable.

---

# 9. No-change result

When source/local facts are conclusively equal:

- no Ball;
- no worker;
- no progress UI;
- no generation bump;
- no semantic state publication.

Schedule the next bounded observation.

---

# 10. Source-ahead result

When current facts conclusively prove ordinary source advancement:

```text
source readable
source sample stable
local dataset coherent
source count/high-water > local
archive identity/generation still admitted
```

start exactly one internal update occurrence.

Synchronously claim the update flight before first await.

Ticks/observations while updating must not queue another worker.

Do not call `AppCzarDataUpdateController`.

---

# 11. Mutation authority path

Use the existing typed authority:

```text
Operating currentness occurrence
-> Operating-only live-update executor
-> ArchiveMutationCoordinator.runWithCapability(
     liveGraphUpdate)
-> one ExclusiveAuthority tenure/Ball
-> LiveGraphUpdateWorker
-> release
-> Operating continues
```

Polling/observation acquires no Ball.

The executor and any capability are occurrence-bound.

No mutation may start after stop/drain begins.

---

# 12. Attachment coverage precondition and postcondition

Use the new Prompt 59 fact.

Before an ordinary live update:

- current admitted archive scope/generation must still match the Operating
  occurrence;
- pre-update coverage must be authentic and safe for the current local graph.

After `LiveGraphUpdateWorker` returns:

- do not infer success merely because graph/import mutation returned;
- perform a fresh read-only attachment-coverage observation against the now
  current graph/archive;
- the live update is considered fully successful only if post-update coverage is
  conclusively TRUE.

Required:

```text
worker returned
-> fresh coverage observation
-> coverage TRUE
-> successful same-session continuation
```

If coverage is FALSE or UNKNOWN:

- stop automatic currentness work;
- surface a factual fail-closed Operating issue;
- do not claim currentness;
- do not invoke Attachment Archive Repair in-process;
- do not reset navigation merely because the failure occurred.

Because fresh AppCzar can now classify the durable coverage fact, it is safe to
offer/request a real restart after `stopAndDrain()`.

Fresh AppCzar then selects virtual Attachment Archive Repair or Diagnostic
Review as appropriate.

---

# 13. Message-data generation ordering

The current worker bumps `messageDataVersionProvider` after graph build and
before attachment preservation.

Do not hide that fact.

During the bounded update, graph-backed presentation may refresh before final
coverage has been established.

Design the subordinate Operating progress/failure state so the user is not told
that the update is fully current until post-update coverage is TRUE.

If this interim generation exposure can produce unsafe UI semantics, STOP AND
REPORT rather than adding a historical completion flag.

A temporary factual `updating` state is allowed because it belongs to the live
Operating occurrence.

---

# 14. Successful same-session continuation

On post-update coverage TRUE:

- remain in the same PID;
- remain in the same Operating occurrence;
- keep SidebarFlow selection;
- keep center/right navigation state where referenced entities remain valid;
- allow graph/message providers to refresh from the generation bump;
- allow `displayIdentityResolverProvider` to refresh via its Stage One
  generation dependency;
- clear the transient updating affordance;
- schedule the next observation.

Do not reapply fresh-entry neutralization.

Do not restart.

Do not call AppCzar.

---

# 15. Progress presentation

Add only a compact subordinate factual status in Operating.

Possible states, based strictly on real evidence:

```text
Checking for new messages…
Updating MessageLens — N / M messages
Preserving attachments — X / Y
Update could not be completed
```

Use actual worker observation vocabulary.

Do not fabricate percentages.

Do not replace the whole workspace.

Do not publish `Current` as an operation conclusion.

No-change observations should ordinarily be silent.

---

# 16. Source access loss / UNKNOWN

If an Operating observation is conclusively unreadable:

- stop scheduling;
- `stopAndDrain()`;
- request a real process restart.

Fresh AppCzar selects Source Access Repair if still FALSE.

If source readability is UNKNOWN:

- do not call it denial;
- stop/drain;
- restart;
- fresh AppCzar may select Diagnostic Review.

No in-process top-level chaining.

---

# 17. Archive identity/generation change

Bind the Operating occurrence to the admitted archive identity/generation.

Before mutation, revalidate.

If identity or generation changes:

- do not start/continue new work on stale authority;
- stop scheduling;
- drain the occurrence;
- restart for fresh AppCzar.

No mixed-generation update.

---

# 18. Archive unavailable / coverage failure

If archive root becomes unavailable or unsafe:

- stop currentness work;
- drain;
- restart if fresh AppCzar has sufficient evidence to classify.

If post-update coverage becomes FALSE/UNKNOWN:

- fail closed as Section 12;
- restart only after the bounded issue is recorded in the live UI and the
  occurrence is drained.

No remembered failure flag.

---

# 19. Graph/local contradiction

If source/local comparison is contradictory rather than ordinary source-ahead,
or worker prerequisite revalidation fails:

- do not repair inside Operating;
- stop/drain;
- restart for fresh AppCzar when safely classifiable.

No Local Data Repair/Onboarding invocation in-process.

---

# 20. Navigation preservation

A successful live update must preserve same-session user semantics.

Tests must prove a selected:

- contact;
- conversation;
- normal center/right view

remains selected/mounted after successful worker + coverage TRUE.

Neutral Conversations entry applies only to a fresh Operating occurrence.

---

# 21. Display identity regression

Preserve Prompt 55 behavior.

After generation advances:

- resolver rebuilds automatically;
- no `contact <id>` fallback persists due to stale cache;
- no navigation click is needed.

Add Stage Two regression coverage.

---

# 22. Advanced Start Fresh remains disabled

Do not re-enable Advanced Start Fresh in the AppCzar Operating route.

Reset redesign remains a separate milestone.

---

# 23. Top-level executable disposition invariant

After Stage Two, classify and test the top-level AppCzar dispositions precisely.

Do not use a misleading count without categories.

Required intent:

```text
Data Update          executable top-level coordinator
Source Access Repair executable top-level coordinator
Operating Session    executable admitted session
Onboarding           virtual in development AppCzar route
Attachment Repair    virtual
Local Data Repair    virtual
Diagnostic Review    virtual
```

The Operating currentness service is internal and not an AppCzar disposition.

If source contradicts this expectation, STOP rather than changing tests to fit
an accidental architecture.

---

# 24. Tests

Use fixtures/temp stores only.

At minimum prove:

1. currentness service starts only after Operating admission;
2. exact occurrence/generation binding;
3. stop prevents new observations synchronously;
4. `stopAndDrain()` waits for admitted observation;
5. `stopAndDrain()` waits for admitted mutation/tenure release;
6. stale completion cannot publish after drain/new occurrence;
7. 15-second cadence is one-shot/non-overlapping;
8. no-change performs no mutation/Ball/version bump;
9. source-ahead starts exactly one internal worker;
10. duplicate ticks do not queue second update;
11. polling has no Ball;
12. mutation uses one existing tenure;
13. startup Data Update controller is never invoked;
14. Source Access Repair is never invoked in-process;
15. post-worker coverage is freshly observed;
16. coverage TRUE is required for full success;
17. coverage FALSE fails closed;
18. coverage UNKNOWN fails closed without being called incomplete/denied;
19. successful update remains same PID/Operating occurrence;
20. successful update preserves selected contact/conversation/panels;
21. generation refresh updates graph-backed presentation;
22. display identity refreshes automatically;
23. source access FALSE drains/restarts;
24. source UNKNOWN drains/restarts without denial claim;
25. archive identity/generation change drains/restarts;
26. archive unavailable does not continue mutation;
27. graph/local contradiction does not self-repair;
28. no old ambient ChatDbChangeMonitor is mounted;
29. Advanced Start Fresh remains unavailable;
30. top-level disposition classification matches Section 23;
31. Prompt 59 coverage regressions pass;
32. Stage One neutral-entry regressions pass;
33. Data Update regressions pass;
34. Source Access Repair regressions pass;
35. production route remains unchanged.

---

# 25. Human qualification handoff

Build but do not launch the final Stage Two artifact.

The later human qualification should:

1. set the exact admitted development-root launch environment;
2. direct-launch and reach Operating;
3. select a known conversation;
4. send or naturally receive one ordinary new message;
5. observe same PID throughout successful live update;
6. observe a compact update affordance if visible;
7. verify the selected conversation remains selected;
8. verify the new message appears without navigation/restart;
9. verify contact identities remain correct;
10. send/receive an attachment-bearing message if convenient and verify
    preservation/coverage;
11. separately turn source access off during Operating and verify a drained real
    restart followed by fresh Source Access Repair.

Do not perform that live experiment in Prompt 60.

---

# 26. Stop gates

STOP AND REPORT if:

- Onboarding is actually executable in the development AppCzar route;
- Stage Two requires mounting old `ChatDbChangeMonitor`;
- Stage Two needs Journey/readiness state;
- it invokes startup Data Update in-process;
- it introduces a fourth AppCzar disposition;
- it cannot await/drain an active tenure before teardown;
- post-worker coverage cannot be freshly verified;
- successful update requires restart;
- successful update resets navigation;
- interim generation exposure creates unsafe semantic claims that cannot be
  represented by live occurrence state;
- production startup must change.

---

# 27. Validation

Run:

1. Prompt 59 checkpoint validation;
2. focused Operating currentness tests;
3. `stopAndDrain()` lifecycle tests;
4. LiveGraphUpdateWorker regressions;
5. attachment coverage regressions;
6. archive mutation/tenure regressions;
7. Stage One regressions;
8. Data Update regressions;
9. Source Access Repair regressions;
10. AppCzar host/disposition tests;
11. architecture suite;
12. analyzer;
13. full deterministic Flutter suite;
14. `git diff --check`;
15. formatting/generated consistency;
16. debug macOS development build.

Do not launch production.

---

# 28. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- Prompt 59 is safely checkpointed before Stage Two edits;
- executable-disposition census is source-grounded;
- Operating remains sole long-lived jurisdiction;
- currentness service is internal and occurrence-bound;
- no old ambient monitor;
- no coordinator chaining;
- observation without Ball;
- one Ball only during mutation;
- drain waits for tenure release;
- post-update coverage TRUE required for success;
- no historical failure flag;
- same-session navigation preserved;
- display identity generation-current;
- production startup unchanged.

---

# 29. Leave Stage Two unstaged

Do not stage, commit, push, merge, or rebase Stage Two.

Build the exact development artifact.

Provide:

- bundle path;
- version/build;
- executable SHA-256;
- App.framework SHA-256;
- exact final Git/worktree/index/submodule state;
- readiness for human Stage Two live-currentness qualification.

---

# 30. Required response

Create Response 60 and report:

1. baseline verification;
2. executable-disposition source audit;
3. resolution of the Response 59 Section 30 census discrepancy;
4. exact Prompt 59 diff inventory;
5. Prompt 59 validation results;
6. attachment-coverage implementation checkpoint;
7. documentation checkpoint;
8. remote recovery-anchor commit;
9. branch/upstream state before Stage Two edits;
10. old monitor non-reuse proof;
11. Operating currentness service architecture;
12. occurrence/generation lifetime;
13. `stopAndDrain()` implementation;
14. observation cadence;
15. no-change behavior;
16. source-ahead behavior;
17. single-flight behavior;
18. mutation-tenure path;
19. post-worker attachment-coverage verification;
20. interim message-data generation semantics;
21. success semantics;
22. progress presentation;
23. navigation preservation;
24. display-identity behavior;
25. source access FALSE behavior;
26. source UNKNOWN behavior;
27. archive identity/generation behavior;
28. archive unavailable behavior;
29. graph/local contradiction behavior;
30. proof no top-level coordinator chaining exists;
31. exact top-level disposition classification after Stage Two;
32. focused Stage Two tests;
33. drain/lifecycle tests;
34. worker/coverage/mutation regressions;
35. Stage One regression result;
36. Data Update regression result;
37. Source Access Repair regression result;
38. architecture result;
39. analyzer result;
40. full Flutter-suite result;
41. diff/format/generated hygiene;
42. Project Conformance verdict;
43. BLOCKER findings;
44. SHOULD FIX findings;
45. exact Stage Two build identity/path/hashes;
46. exact final Git/worktree/index/submodule state;
47. readiness for human live-currentness qualification.

Conclude exactly:

`ATTACHMENT COVERAGE MILESTONE CHECKPOINTED: YES / NO`

`RESPONSE 59 EXECUTABLE-DISPOSITION CENSUS RECONCILED: YES / NO`

`OPERATING-OWNED LIVE CURRENTNESS IMPLEMENTED: YES / NO`

`OPERATING SHUTDOWN DRAINS ACTIVE MUTATION TENURE: YES / NO`

`POST-UPDATE COVERAGE TRUE IS REQUIRED FOR LIVE-UPDATE SUCCESS: YES / NO`

`SUCCESSFUL LIVE UPDATE PRESERVES SAME-SESSION NAVIGATION: YES / NO`

`READY FOR HUMAN OPERATING LIVE-CURRENTNESS QUALIFICATION: YES / NO`

Then STOP.
