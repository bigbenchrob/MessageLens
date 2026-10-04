# MessageLens Feature 34
## 58 — Checkpoint Operating Stage One and Implement Operating-Owned Live Currentness

Response 57 qualified AppCzar Operating Session Stage One against the real development environment.

The corrected direct-launch contract produced this live sequence:

```text
launchd development root present
-> fresh AppCzar route

PID 31944
-> fresh AppCzar
-> natural startup Data Update
-> real restart

PID 32059
-> fresh AppCzar
-> Operating Session
-> neutral Conversations shell
-> contact identities correct on first use
-> normal same-session navigation
-> no Journey/readiness authority

quit

PID 35462
-> fresh AppCzar
-> Operating Session
-> neutral Conversations shell again
-> prior contact/conversation/Settings state NOT restored
```

Stage One therefore proved the fresh-evidence-to-normal-shell handoff.

This task has two parts:

1. checkpoint and push the qualified Stage One milestone without integrating it to `main`;
2. implement **Operating Session Stage Two: Operating-owned live currentness**.

Stage Two must preserve the governing rule:

> Operating Session is the one top-level jurisdiction while the user is using MessageLens. Ordinary source advancement may be handled by a narrow internal worker, but that worker may not become a second top-level coordinator.

The intended steady-state model is:

```text
fresh AppCzar
-> Operating Session admitted
-> normal user navigation

Operating-owned currentness observer
-> detects ordinary source advancement
-> one bounded internal live-update occurrence
-> existing LiveGraphUpdateWorker
-> message-data generation advances
-> presentation refreshes
-> same PID
-> same Operating occurrence
-> user's navigation preserved
```

No startup Data Update coordinator is invoked in-process.

Do NOT route production startup through AppCzar.
Do NOT delete production legacy startup yet.
Do NOT make Onboarding executable.
Do NOT make Local Data Repair executable.
Do NOT make Attachment Archive Repair executable.
Do NOT make Diagnostic Review executable.
Do NOT add generic coordinator dispatch.
Do NOT stage/commit/push Stage Two before human qualification.

---

# 1. Baseline and Stage One checkpoint

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expected pre-checkpoint state:

- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream: `7d0393c214c9ad701c0c856f03ddcb17b490ea03`
- Prompt 55 implementation present and unstaged
- Response 57 made no source/test changes
- index empty
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`

Read Responses 54 through 57 and the canonical Project Conformance standard.

Create a fresh external baseline manifest.

Audit the exact Prompt 55 implementation paths before staging.

Do not use `git add .`.

If validation remains clean, create:

### Stage One implementation checkpoint

Recommended subject:

`feat(startup): admit neutral AppCzar operating session`

Commit only the exact Stage One source/test/generated/release-metadata tree.

### Stage One documentation checkpoint

Commit only the established Feature 34 Prompt/Response documentation through Prompt/Response 57, following the existing repository convention.

Push the branch normally as a recovery anchor.

No force push, rebase, merge, or PR merge.

Report exact local and remote commits before starting Stage Two work.

---

# 2. Stage One qualification evidence to preserve

Do not reinterpret Response 57.

Preserve these exact facts:

- the correct direct-launch AppCzar gate requires the admitted development root launch environment;
- a natural startup source delta was handled by the existing Data Update coordinator across a real process restart;
- first Operating frame was neutral;
- no prior contact/conversation/handle/Settings semantic selection appeared;
- no Journey/readiness/pipeline takeover appeared;
- contact names were correct before any contact selection;
- normal contact/conversation/message navigation worked;
- Advanced Start Fresh was absent in the exact development Operating route;
- second fresh Operating occurrence again started neutral;
- prior Rusung/Claire/Settings semantic state did not restore;
- ambient live currentness was intentionally not tested.

These are Stage Two invariants.

---

# 3. Stage Two jurisdiction

Operating Session Stage Two owns:

> Maintain ordinary MessageLens currentness during one already-admitted Operating occurrence without changing top-level jurisdiction.

This is not the startup `Data Update` coordinator.

The internal service may:

- observe the current Messages source on an Operating-owned cadence;
- detect a source-ahead condition;
- invoke one bounded existing live-update worker;
- preserve attachments using the existing worker path;
- advance/invalidate message-data generation;
- publish factual in-session update progress;
- remain in the same process and preserve user navigation when the bounded update succeeds.

It may NOT:

- evaluate the whole AppCzar disposition DAG;
- invoke the Data Update coordinator;
- invoke Source Access Repair;
- invoke Operating Session again;
- call AppCzar in-process;
- persist semantic "we are current" state;
- restore historical navigation;
- run outside an admitted Operating occurrence.

---

# 4. Refactor/reuse, do not resurrect the ambient monitor

Audit the current:

- `ChatDbChangeMonitor`;
- `LiveGraphUpdateWorker`;
- source probe reader;
- archive mutation/capability path;
- message-data generation invalidation;
- attachment preservation result.

Do not simply mount `chatDbChangeMonitorProvider` in Operating.

The old monitor is disqualified as an ambient self-authorizing authority because it starts from the generic App root and owns its own polling/mutation decisions.

Preferred implementation:

```text
AppCzarOperatingSessionController / admitted Operating generation
-> OperatingCurrentnessService
-> Operating-owned observation cadence
-> current source/local comparison
-> admitted internal update executor
-> ArchiveMutationCoordinator existing typed operation
-> LiveGraphUpdateWorker
```

Reuse the narrow worker.

Do not duplicate importer/projector/archive logic.

If the existing worker cannot be called with a sufficiently narrow typed authority/result contract, STOP AND REPORT rather than rebuilding it.

---

# 5. Operating-owned service lifetime

The currentness service exists only while one exact Operating occurrence is admitted.

Required:

- starts only after Operating admission;
- bound to the exact Operating generation/occurrence;
- one timer/listener owner;
- disposed on Operating teardown;
- disposed before normal quit completes;
- disposed before any restart request;
- stale callbacks from an old occurrence cannot mutate or publish into a newer occurrence.

No provider may keep the service alive merely because the generic App exists.

---

# 6. Observation cadence

Reuse the existing product cadence if source inspection shows the old monitor has a deliberate normal interval (historically approximately 15 seconds).

Do not introduce high-frequency polling.

Requirements:

- one bounded observation per tick;
- no overlapping observations;
- no overlapping update workers;
- timer callback cannot become a second semantic authority;
- cadence is Operating-owned and stops with Operating.

Expose the chosen cadence as an existing constant or one narrow testable value, not scattered magic numbers.

---

# 7. Decide from facts needed for currentness only

The Operating service is not a mini-AppCzar.

It should observe only facts necessary to answer:

> Has the readable stable Messages source advanced beyond this complete local dataset during this Operating occurrence?

At minimum use/reuse current factual seams for:

- source readability;
- source count/high-water;
- local imported count/high-water;
- current graph/import prerequisites required by the worker;
- archive generation/availability required for safe preservation.

Do not read:

- Journey state;
- installation disposition;
- Environment Readiness;
- persisted failure history as current truth;
- old operation completion flags.

---

# 8. Ordinary no-change observation

If current source/local evidence remains equal:

- do nothing;
- do not bump message-data generation;
- do not acquire mutation authority;
- do not show progress;
- do not publish a new semantic readiness state.

Silence is correct.

---

# 9. Ordinary source advancement

If current bounded evidence proves:

```text
source readable
source comparison known
source > local
```

then start exactly one internal update occurrence.

The service must synchronously claim single-flight before the first await.

If another timer tick occurs while work is active:

- skip/join according to the smallest existing idiom;
- do not queue a second update;
- do not start another Ball tenure.

---

# 10. Mutation authority

Ordinary in-session live update still performs real graph/archive mutation.

Use the existing exact archive/message mutation authority.

Required shape:

```text
Operating occurrence
-> one internal live-update executor
-> ArchiveMutationCoordinator typed capability
-> one ExclusiveAuthority tenure/Ball
-> LiveGraphUpdateWorker
-> release
-> Operating continues
```

Do not call the startup `AppCzarDataUpdateController`.

Do not acquire Ball merely to poll.

Do not allow capability/tenure to outlive the admitted Operating occurrence.

---

# 11. Progress presentation

Keep progress subordinate to Operating.

Do not replace the normal workspace with a top-level coordinator screen for ordinary live updates.

Use the smallest factual same-session affordance, for example a compact status surface or existing non-blocking progress location.

Only display values actually supplied by the worker:

- messages to import / completed;
- graph stage;
- attachment examined/preserved;
- bounded failure.

Do not fabricate percentages.

Do not claim `MessageLens is current` merely because one worker Future returned.

When the update finishes normally, ordinary UI remains where the user left it.

---

# 12. Post-update currentness and generation

A successful worker occurrence must:

- complete import/graph work through the existing path;
- complete required attachment preservation successfully;
- advance/invalidate `messageDataVersionProvider` through the existing qualified path;
- allow graph-backed presentation and `displayIdentityResolverProvider` to rebuild from the new generation;
- preserve same-session navigation if referenced entities remain valid.

Do not force provider recreation through navigation.

Do not restart merely for successful ordinary source advancement.

A later bounded observation may confirm there is no additional source delta.

---

# 13. Attachment preservation is part of success

This is a hard stop gate.

Response 54 identified a hazard: graph mutation occurs before attachment preservation.

Audit the exact `LiveGraphUpdateWorker` result.

Operating may treat the bounded update as successful only if attachment preservation is conclusively acceptable according to the existing typed result.

If attachment preservation:

- fails;
- is deferred in a way that leaves required preservation incomplete;
- becomes ambiguous;

then Operating must **not** silently continue as though fully current.

Required behavior:

- stop automatic update work for that Operating occurrence;
- surface a factual bounded failure;
- preserve existing user navigation/read-only browsing where safe;
- do not invoke another coordinator in-process;
- do not manufacture an AppCzar conclusion.

If fresh AppCzar currently lacks sufficient independent evidence to classify that durable partial condition safely after restart, remain fail-closed and STOP the implementation task for design review rather than adding a historical success/failure flag as semantic authority.

---

# 14. Source access loss during Operating

If a bounded observation changes from readable to conclusively unreadable:

```text
Operating currentness service
-> stop scheduling new work
-> quiesce any safe in-flight boundary
-> dispose currentness service
-> request real process restart
```

Fresh AppCzar then independently selects Source Access Repair if the source is still conclusively unreadable.

Operating must not invoke Source Access Repair directly.

If source readability is UNKNOWN/inconclusive:

- do not infer denial;
- stop the service;
- request restart for fresh AppCzar / Diagnostic Review.

---

# 15. Archive identity/availability change

Reuse existing current archive identity/generation/availability seams.

If the admitted archive generation or identity changes during Operating:

- stop scheduling new live updates;
- do not continue using stale capability/paths;
- dispose the currentness service;
- request restart.

If the archive becomes conclusively unavailable/unsafe:

- fail closed;
- request restart only if fresh AppCzar has sufficient current evidence to classify the condition;
- otherwise show a bounded Operating failure and STOP for design review.

No mixed archive generation within one update occurrence.

---

# 16. Graph/local contradiction

If Operating observes a contradiction rather than ordinary source advancement, such as:

- local count/high-water ahead unexpectedly;
- graph/import prerequisites no longer coherent;
- worker prerequisite revalidation fails;

do not "repair" it inside the currentness service.

Stop automatic work and request restart when fresh AppCzar can safely classify the durable facts.

No in-process Local Data Repair/Onboarding invocation.

---

# 17. Same-session navigation must survive successful update

This is a core Stage Two qualification target.

If the user currently has:

- a contact selected;
- a conversation selected;
- a message timeline open;
- another valid normal feature view;

a successful ordinary live update must not reset the shell to neutral.

Neutral entry is a **fresh Operating startup invariant**, not a rule applied after every graph update.

Tests must prove successful `messageDataVersion` changes refresh data without resetting SidebarFlow/panel semantic selection.

---

# 18. Display identity currentness regression

Preserve the Stage One correction.

After a live update:

- `displayIdentityResolverProvider` must rebuild/invalidate with message-data generation;
- newly resolvable contact identities must not require a click;
- existing contact/conversation names must remain correct;
- no stale fallback `contact <id>` snapshot survives.

Add focused regression coverage.

---

# 19. Start Fresh remains deferred

Do not re-enable Advanced Start Fresh in this milestone.

Its Journey-dependent reset authority remains outside the AppCzar Operating composition until separately redesigned.

Stage Two is only live currentness.

---

# 20. Exactly three top-level executable AppCzar dispositions remain

Stage Two adds an internal Operating worker/service, **not a fourth top-level coordinator**.

Architecture tests must still find exactly:

1. Data Update;
2. Source Access Repair;
3. Operating Session.

The Operating currentness service must not be represented in `AppCzarVirtualCoordinator`.

No generic top-level dispatcher.

---

# 21. Tests

Use fixtures/temp stores only.

At minimum prove:

1. currentness service cannot start before Operating admission;
2. service is bound to one exact Operating generation;
3. service disposes on Operating teardown;
4. stale old-generation callbacks cannot publish into a new occurrence;
5. cadence starts only inside Operating;
6. one tick = one bounded observation;
7. no overlapping observations;
8. equal source/local evidence performs no mutation;
9. source-ahead evidence starts exactly one internal update;
10. duplicate ticks while updating do not queue a second worker;
11. polling does not acquire Ball;
12. live update acquires exactly one existing mutation tenure;
13. startup Data Update controller is never invoked;
14. Source Access Repair is never invoked in-process;
15. successful worker completion remains same PID/same Operating occurrence;
16. same-session selected contact/conversation survives successful update;
17. message-data generation advances through existing path;
18. display identity refreshes with generation;
19. attachment preservation success is required before success presentation;
20. attachment failure/defer fails closed and stops automatic work;
21. source access loss requests restart rather than chaining coordinator;
22. source UNKNOWN does not claim denial;
23. archive generation/identity change invalidates Operating currentness service;
24. local/graph contradiction does not trigger hidden repair;
25. currentness timer/listener is absent outside Operating;
26. Advanced Start Fresh remains unavailable in development Operating route;
27. exactly three top-level executable AppCzar dispositions remain;
28. production route behavior remains unchanged;
29. Data Update regressions pass;
30. Source Access Repair regressions pass;
31. Stage One neutral-entry regressions pass.

---

# 22. Human Stage Two qualification artifact

Build but do not launch the final development artifact.

Human qualification will later:

1. direct-launch through the exact admitted-root development contract;
2. reach healthy Operating;
3. select a known conversation;
4. produce or naturally receive one ordinary new Messages record;
5. remain in the same PID;
6. observe bounded live-update activity;
7. verify the selected conversation remains selected;
8. verify the new message becomes visible without restart/navigation repair;
9. verify contact identity remains correct;
10. verify attachment preservation if the test message contains an attachment;
11. separately qualify source-access loss as a restart-to-fresh-AppCzar event.

Do not run that human experiment in Prompt 58.

---

# 23. Stage Two stop gates

STOP AND REPORT if:

- implementation requires mounting the old ambient `ChatDbChangeMonitor`;
- the service needs Journey/readiness state;
- it invokes the startup Data Update coordinator;
- it introduces a fourth top-level coordinator;
- it chains to Source Access Repair or another coordinator in-process;
- successful ordinary update requires process restart;
- successful update resets navigation;
- attachment failure can be silently treated as current;
- capability/tenure may outlive Operating;
- stale callbacks can survive Operating disposal;
- production startup must change.

---

# 24. Validation

After Stage One checkpoint and Stage Two implementation, run:

1. focused Operating currentness tests;
2. LiveGraphUpdateWorker regressions;
3. archive mutation/tenure regressions;
4. attachment preservation regressions;
5. display-identity generation regressions;
6. Stage One neutral-shell regressions;
7. Data Update regressions;
8. Source Access Repair regressions;
9. AppCzar mapping/host tests;
10. architecture suite;
11. analyzer;
12. full deterministic Flutter suite;
13. `git diff --check`;
14. formatting/generated consistency;
15. debug macOS development build.

Do not launch production.

---

# 25. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- Stage One recovery anchor exists before Stage Two edits;
- Operating remains sole top-level jurisdiction;
- currentness service is internal and generation-bound;
- existing worker reused;
- one Ball only during mutation;
- no Ball while observing;
- no coordinator chaining;
- successful live update preserves same-session navigation;
- attachment preservation is part of success;
- typed failure semantics fail closed;
- display identity remains generation-current;
- exactly three executable top-level AppCzar dispositions;
- production startup unchanged.

If the attachment-partial-failure problem cannot be represented safely without adding a remembered semantic conclusion, STOP with a BLOCKER rather than inventing one.

---

# 26. Leave Stage Two unstaged for human qualification

Do not stage, commit, push, merge, or rebase the Stage Two implementation.

The Stage One checkpoint/recovery anchor should already be committed and pushed at the beginning of this task.

Build the exact Stage Two development artifact and provide:

- bundle path;
- version/build;
- executable SHA-256;
- App.framework SHA-256;
- exact Git/worktree/index/submodule state;
- readiness for the separate human Stage Two live-currentness qualification.

---

# 27. Required response

Create Response 58 and report:

1. initial baseline verification;
2. exact Stage One diff inventory;
3. Stage One validation results;
4. Stage One implementation checkpoint commit;
5. Stage One documentation checkpoint commit;
6. remote Stage One recovery-anchor commit;
7. branch/upstream status before Stage Two edits;
8. old ChatDbChangeMonitor audit;
9. LiveGraphUpdateWorker reuse result;
10. Stage Two Operating currentness service design;
11. exact service lifetime/generation binding;
12. observation cadence;
13. no-change behavior;
14. source-ahead behavior;
15. single-flight behavior;
16. mutation-tenure path;
17. progress presentation;
18. message-data generation behavior;
19. same-session navigation preservation design;
20. display-identity behavior;
21. attachment preservation success/failure semantics;
22. source-access-loss behavior;
23. source-UNKNOWN behavior;
24. archive identity/availability behavior;
25. graph/local contradiction behavior;
26. proof no top-level coordinator chaining exists;
27. proof exactly three executable AppCzar dispositions remain;
28. focused Stage Two test results;
29. worker/mutation/attachment regression results;
30. Stage One regression results;
31. Data Update regression result;
32. Source Access Repair regression result;
33. architecture result;
34. analyzer result;
35. full Flutter-suite result;
36. diff/format/generated hygiene;
37. Project Conformance verdict;
38. BLOCKER findings;
39. SHOULD FIX findings;
40. exact Stage Two build identity/path/hashes;
41. exact final Git/worktree/index/submodule state;
42. readiness for human Operating live-currentness qualification.

Conclude exactly:

`OPERATING STAGE ONE CHECKPOINTED: YES / NO`

`OPERATING-OWNED LIVE CURRENTNESS IMPLEMENTED: YES / NO`

`LIVE CURRENTNESS INVOKES STARTUP DATA UPDATE COORDINATOR: YES / NO`

`SUCCESSFUL LIVE UPDATE PRESERVES SAME-SESSION NAVIGATION: YES / NO`

`ATTACHMENT PRESERVATION IS REQUIRED FOR LIVE-UPDATE SUCCESS: YES / NO`

`TOP-LEVEL EXECUTABLE APPCZAR DISPOSITIONS REMAIN EXACTLY THREE: YES / NO`

`READY FOR HUMAN OPERATING LIVE-CURRENTNESS QUALIFICATION: YES / NO`

Then STOP.
