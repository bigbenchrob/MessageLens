# MessageLens Feature 34
## 82 — Implement Executable AppCzar Diagnostic Review Stage One

Response 81 completed the source-grounded Diagnostic Review audit/design and found no prerequisite reader, authority, or architecture blocker. It intentionally made no implementation changes.

Diagnostic Review is the final virtual AppCzar coordinator. Five other top-level coordinators and Operating Session already execute and have been qualified. This task implements the bounded **read-only Diagnostic Review presentation and lifecycle jurisdiction**, but does **not** human-qualify it or cut production over to AppCzar.

**Response 81 is controlling. Read it in full before editing.** Its exhaustive 22-row evaluator/frontier inventory, exact occurrence contract, UI copy, host composition, no-export decision, test matrix, and stop gates take precedence over shorthand in this prompt. Do not reinterpret an audit finding from memory.

### Governing rule

> Diagnostic Review presents exactly what the completed AppCzar assessment already proves. It does not invent new facts, poll for new evidence, re-run AppCzar in-process, change the selected disposition, borrow a mutation capability, or infer a history explaining the current condition.

The only user-initiated actions in Stage One are **Try Assessment Again** (a real process restart) and **Quit** (ordinary application exit without relaunch).

Do NOT:
- route production through AppCzar;
- implement copy/export in Stage One;
- instantiate legacy Journey or Environment Readiness;
- build another diagnostic fact reader/evaluator;
- call AppCzar assessment `runAgain()` from Diagnostic Review;
- schedule automatic retry, polling, timers, or restart;
- acquire the Ball or call a mutation worker;
- touch real WD development data, Toshiba attachment archives, or real source databases;
- launch the development or production application during this implementation prompt.

---

# 1. Baseline and source inventory

Use the primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- starting HEAD/upstream `fd24d92508e85712ba051bab2c7a012ccd7c3266` unless a subsequent, independently explained documentation-only commit has advanced both equally;
- ahead/behind `0/0`;
- clean tracked worktree and index;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree;
- known unrelated untracked artifacts untouched.

Verify Prompt/Response 80 qualification documentation commit is an ancestor:

`fd24d92508e85712ba051bab2c7a012ccd7c3266`

Read **Response 81**, Responses 40, 41, 51, 71, 78, 79, 80, and the canonical Project Conformance standard. Trace the current source for:

- `AppCzarAssessmentController`, `AppCzarAssessmentState`, `AppCzarAssessment`, and `AppCzarObservationSet`;
- `AppCzarPresentationProjector` and current assessment row rendering;
- `AppCzarStartupHarness` and explicit coordinator host construction order;
- `AppCzarProcessRestarter` / `appCzarProcessRestarterProvider`;
- existing coordinator lifecycle hosts, `AppLifecycleListener`, and their `stopAndDrain()` conventions;
- development composition policy, product/bundle identity, and production legacy route;
- current Diagnostic Review virtual fallthrough UI;
- architecture census and forbidden-import rules.

Create an external baseline manifest before editing. Report exact current file paths, methods, and changes from Response 81 if any. Never infer a method signature from this prompt.

---

# 2. Checkpoint Prompt 81 / Response 81 before source edits

These audit documents are untracked and must be preserved as a narrow documentation-only commit before implementation.

Stage only:

- `01-ONBOARDING/prompts/81-CHECKPOINT-LOCAL-DATA-REPAIR-QUALIFICATION-AND-AUDIT-APPCZAR-DIAGNOSTIC-REVIEW.md`;
- `01-ONBOARDING/responses/81-CHECKPOINT-LOCAL-DATA-REPAIR-QUALIFICATION-AND-AUDIT-APPCZAR-DIAGNOSTIC-REVIEW.md`.

Adapt only the repository-relative prefix if source inspection proves a different canonical location.

Record:

```text
Local Data Repair human live qualification: PASS
Diagnostic Review: VIRTUAL ONLY
Diagnostic Review audit/design: PASS
No new factual reader or mutation authority required
Production AppCzar cutover: NOT AUTHORIZED
```

Check the staged diff and push the documentation checkpoint normally. Do not use `git add .`, force push, rebase, squash, merge, or stage unrelated untracked artifacts.

---

# 3. Reconfirm the pre-change execution census

Require exactly:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Local Data Repair           EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Diagnostic Review           VIRTUAL ONLY
```

Only Diagnostic Review may change from virtual to executable during Prompt 82.

After implementation the census must be **six explicit executable top-level coordinators plus one admitted Operating session**. No generic dispatcher or broad `switch` over all coordinators may be added.

---

# 4. Preserve the existing AppCzar evaluator and facts

Response 81 establishes that one completed AppCzar assessment already contains every needed current observation and fact. Do not create another truth source.

No changes to:

- `AppCzarEvaluator` disposition ordering, predicates, or fact values;
- `AppCzarTruth` or its TRUE/FALSE/UNKNOWN semantics;
- source, archive, attachment, import, graph, overlay, or root readers;
- Local Data Repair safety classification;
- any mutation permission or archive-root admission policy.

A presentation-only conflict label is permitted **only** when literal frozen observations establish an actual contradiction/instability. It must not become a fourth logical truth value or an alternate readiness conclusion.

---

# 5. Add one exact Diagnostic execution predicate

Implement the named, independently testable predicate, using source-conforming type names:

```text
shouldExecuteAppCzarDiagnosticReview(...)
```

The predicate is TRUE only when:

```text
completed AppCzar assessment exists
AND assessment.virtualCoordinator == diagnosticReview
AND its exact completed generation is available for capture
```

Do not match on a broad diagnosis kind; do not let a null/in-progress assessment become executable. Require explicit equality to the sole Diagnostic coordinator.

The predicate does not evaluate facts, launch workers, read SQLite, or mutate anything.

---

# 6. Capture one immutable Diagnostic occurrence

Create a small application package under:

`lib/essentials/app_czar_diagnostic_review/`

The controller captures **by identity** the completed `AppCzarAssessmentState` selected by AppCzar:

- immutable process-local occurrence identity;
- completed assessment generation;
- exact captured `AppCzarObservationSet` and `AppCzarAssessment` as supplied;
- capture time sampled once through an injected clock;
- memory-only phase and optional literal action failure;
- closed/open action-admission state and one in-flight lifecycle Future.

Preferred phases follow Response 81:

```text
presenting

draining

restartFailed

quitRequested
```

Adjust names only for an existing idiomatic state design and explain the mapping.

The occurrence must never:

- persist its identity, generation, facts, consent, verdict, cursor, prior failure, or restart intent;
- watch fresh source/archive readers;
- call `AppCzarEvaluator`;
- watch another mutable assessment as its live presentation source;
- use a durable operation snapshot or historical Journey state.

If the assessment provider's generation changes in the same process, stale callbacks cannot operate under the old occurrence. Do not silently replace the frozen display with a new assessment; a genuine new AppCzar jurisdiction requires the established process boundary.

---

# 7. Generation and capture-time evidence

The Diagnostic screen must display:

```text
Assessment generation N

Captured at [literal time]

This is a bounded snapshot from this process; it is not continuously refreshed.
```

The capture timestamp describes **when the completed assessment was admitted into the Diagnostic occurrence**, not when every underlying source probe ran. Do not imply all constituent observations happened simultaneously.

Use an injectable clock for deterministic tests. Do not alter AppCzar domain facts solely to insert presentation time; prefer the occurrence controller as Response 81 recommends.

Prove generation, capture time, observation identity, and rendered rows remain stable while the occurrence stays visible.

---

# 8. Extend the existing pure presentation projector

Extend `AppCzarPresentationProjector` (or the exact audited equivalent) with a pure Diagnostic projection of the captured completed assessment.

Require:

- one immutable input: the frozen assessment occurrence;
- deterministic, bounded output;
- no I/O, provider reads, evaluator invocation, source sampling, or disk reads;
- reuse of existing observation/fact row descriptions where accurate;
- transparent TRUE, FALSE, UNKNOWN presentation;
- conflict/instability display derived only from the literal contradictory observations already captured;
- no extra user-facing claim stronger than its evidence.

Maintain the exact distinction:

```text
FALSE: a negated proposition was established
UNKNOWN: evidence unavailable/insufficient
CONFLICT: an explanatory label only when frozen observations actually disagree
```

Avoid a generic diagnosis that overwrites a more precise known condition.

---

# 9. Exhaustive Diagnostic selection coverage

Use Response 81 Section 4's **22 numbered frontier cases** as a test matrix. Do not compress materially different cases into one fixture merely because they all currently select `diagnosticReview`.

At minimum the projection must correctly express:

1. post-admission data-root observation disagreement/inspection failure;
2. unknown initial-construction scope;
3. protected/retired/unsupported initial scope;
4. unhealthy initial scope;
5. unhealthy import, graph, or overlay;
6. unknown import, graph, or overlay;
7. unknown attachment archive availability;
8. incoherent archive binding in safe-empty scope;
9. Contacts prerequisite invalid/unknown/not-applicable conflict in safe-empty scope;
10. unknown Messages source readability in safe-empty scope;
11. safe-empty source sampling instability;
12. consequential partial with Local Data Repair safety FALSE/UNKNOWN;
13. unknown source readability outside safe-empty scope;
14. unstable/absent source sample outside safe-empty scope;
15. noncomplete local dataset without a safe specific coordinator;
16. unknown attachment coverage;
17. unknown current attachment repair opportunity;
18. incomplete coverage with unsafe/conflicting actionability;
19. complete coverage contradicted by repairability evidence;
20. unavailable source/local completeness or delta comparability conjunction;
21. source-local count/high-water anti-direction;
22. missing authentic archive location binding late in the frontier.

Every one must mount exactly one Diagnostic Review host, without inventing a new diagnosis.

Also test representative **non-diagnostic** frontiers remain with their existing owners: known archive unavailable, source access conclusively denied outside safe-empty, actionable attachment repair, reconstructible live-only Local Data Repair, safe-empty Onboarding, source-ahead Data Update, and admitted Operating including conclusive source-absent attachment debt.

---

# 10. Specific Fair-Witness cases

The tests and UI must prove:

**Source fact missing:** `AppCzarLocalDataRepairSafetyCondition.sourceFactMissing` is an established safety FALSE, never generic UNKNOWN and never permission denial. Do not say the source was deleted unless the observed anti-difference proves only absence now.

**Source/local anti-direction:** display literal current-source count/high-water and local count/high-water, with the contradictory comparison. Do not infer how or when they diverged. Never run Data Update to fix an unsupported anti-direction.

**Protected history:** identify confirmed non-live/historical/retired material as protected or requiring review. Do not call it corrupt, disposable, or safe to reset.

**Corrupt/unsupported:** show the affected store and bounded, privacy-reviewed technical failure such as SQLite code 26. Never reinterpret it as a virgin/empty store.

**Source evidence:** read `accessDenied` as a source read result; never infer the visible FDA toggle is OFF.

**Archive/attachment uncertainty:** keep availability, coverage, repairability/actionability, and authentic location binding separate. Incomplete coverage with conclusive source-absent debt may be Operating-safe; unknown or conflicting repair evidence is not. Never infer a preservation waiver or complete coverage.

---

# 11. Privacy and bounded diagnostics

The current completed assessment may contain technical paths, archive UUIDs, counts, and error details. Add bounded presentation limits as needed without changing the underlying facts:

- bound number/length of displayed rows/details;
- bound line lengths for error excerpts;
- keep technical IDs/paths inside clearly labeled expandable details rather than indiscriminately promoting them into the main explanation;
- do not expose Messages text, rich-text blobs, contact fields, attachment bytes, SQL bodies, or other source payloads;
- do not automatically serialize an external report;
- no clipboard or export feature in Stage One.

If accurate diagnostic explanation requires adding a new current fact read, **STOP**; report that the Response 81 finding was incomplete rather than making Diagnostic Review a parallel observer.

---

# 12. Implement the Diagnostic Review screen

Create:

`lib/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart`

Use established AppCzar layout/theme/window conventions. Required elements:

- title **MessageLens needs a diagnostic review**;
- literal AppCzar diagnosis;
- explanatory copy: **Normal use or automatic repair cannot be selected from this bounded evidence**;
- generation, capture time, and snapshot limitation;
- factual summary rows clearly distinguishing confirmed positive, confirmed negative, insufficient, and literal contradictory evidence;
- expandable **Technical evidence** using the *same frozen projection*;
- **Try Assessment Again**;
- **Quit**;
- inline literal restart/action failure where applicable.

Forbidden actions: reset, rebuild, Start Fresh, preserve attachments, adoption, historical-source removal, manual worker, **Continue**, Operating, and generic in-process **Run assessment again**.

Do not mount the normal Operating shell, center-panel navigation, legacy Journey overlay, or Environment Readiness surface.

---

# 13. Explicit Diagnostic host comes first

Modify `AppCzarStartupHarness` to add exactly one explicit Diagnostic execution branch and lifecycle host.

The host must observe the completed AppCzar assessment and the exact Diagnostic occurrence **before it watches/constructs specialist controller providers**. When Diagnostic is selected, return the Diagnostic host immediately. Do not leave generic assessment fallthrough on that path.

Preserve existing branch ordering and predicates for non-Diagnostic cases except for the necessary early explicit Diagnostic branch. Do not introduce a generic coordinator dispatcher or nested second `MacosApp`.

Prove the Diagnostic composition does **not instantiate** other specialist providers merely by building its widget tree.

---

# 14. Try Assessment Again: one real process boundary

On explicit user action:

```text
validate exact current occurrence + generation
-> synchronously close new action admission
-> invalidate stale callbacks
-> stopAndDrain() exact occurrence
-> invoke qualified AppCzarProcessRestarter once
-> old process terminates
-> detached relaunch only after old PID exits
-> new process admits archive and evaluates fresh AppCzar
```

Reuse the existing `appCzarProcessRestarterProvider` and its official-development composition guard. The Diagnostic package must not import `dart:io`, call `Process.start`, or implement its own `exit()`/relaunch script.

Do not call `AppCzarAssessmentController.runAgain()`; do not re-evaluate facts under the same PID. The button does not promise that the next assessment will be different.

If scheduling a restart fails before process termination, remain inside Diagnostic Review with the captured frozen facts, show the literal error, and permit retry only after the previous action has settled. No new semantic selection is made.

---

# 15. Quit and ordinary OS exit

Use the established `AppLifecycleListener` host pattern.

The **Quit** button should request the standard Flutter application exit, so the same lifecycle listener owns shutdown. On quit/window close:

```text
invalidate occurrence
-> stop accepting actions
-> await stopAndDrain()
-> allow ordinary application exit
```

No process restarter, background relaunch, semantic handoff, or mutation.

If quit arrives while an action is active, drain the exact action Future safely; no double termination and no stale callback publication.

Do not build a new general lifecycle manager.

---

# 16. Single-flight and stale-action safety

`stopAndDrain()` must synchronously close action admission and invalidate the occurrence, then await any one active lifecycle action Future. Publication from older generations must be suppressed.

Test:

- double-click/reentrant **Try Assessment Again** invokes restarter at most once;
- simultaneous Quit/restart cannot schedule multiple restarts;
- stale button callbacks after disposal/replacement are inert;
- a restart failure that occurs before termination is displayed exactly once and cannot mutate the frozen assessment;
- ordinary exit drains without scheduling restart;
- no action may be accepted while draining;
- nothing persists across process death.

Avoid recursive/self-awaiting drain: audit the exact current lifecycle patterns and structure the action and drain Futures to avoid deadlock.

---

# 17. No automatic loop, polling, or hidden work

Diagnostic Review must stay visible indefinitely if current evidence is unchanged or unavailable. It must not automatically restart, refresh, or run an assessment.

Forbidden in the Diagnostic package/host:

```text
Timer / Timer.periodic
polling / periodic callbacks
stream subscription to current-source changes
retry counters / scheduled microtasks
in-process AppCzar runAgain()
background restarter invocation
```

Test with fake time/pump/settle over a bounded interval: no restarter call, no new observation, and no changed generation. If the user explicitly restarts and the next process reaches the same UNKNOWN, it must wait again without remembering any prior retry intent.

---

# 18. No mutation Ball, worker, or data access

Diagnostic Review is explicitly **read-only** and owns no archive resource mutation tenure. Add architecture enforcement excluding dependencies on:

- `ArchiveMutationCoordinator`, `ArchiveMutationOperation`, `ArchiveMutationCapability`, `runWithCapability`;
- `MessageDataResetService` and Start Fresh;
- graph/import/project worker providers;
- attachment archive writers, attachment repair executors/adoption;
- historical-source removal;
- direct database/source/attachment reader providers;
- legacy operation-snapshot and pipeline-incident authority.

The initial AppCzar assessment already performed bounded read-only probes. Ordinary process lock, logging, and presentation services may have been initialized before Diagnostic admission. Do not overclaim total filesystem immutability; the enforceable claim is **Diagnostic Review causes no new source read or MessageLens data mutation**.

---

# 19. No legacy Journey or support exporter

The Diagnostic package and AppCzar host must not watch, import, or construct:

- `StartupApp`, `MacosAppShell` production legacy wrapper;
- Journey/Trip/Step/Episode;
- `OnboardingOverlay`, onboarding gate/status, center-panel sync;
- Environment Readiness evaluator/action bridge;
- pipeline-incident current-authority or persisted operation snapshots;
- legacy completion handoff;
- legacy support/log exporter.

Response 81 found the existing support exporter still constructs legacy Onboarding telemetry/operation dependencies. **Do not reuse it**. Stage One offers no copy/export action; a future isolated redacted formatter must be separately reviewed and authorized.

---

# 20. Preserve production behavior and archive authority

Production continues through:

```text
archive admission
-> production/other identity
-> StartupApp
-> existing legacy startup/Journey
```

Official admitted MessageLens Development continues through AppCzar. The WD-root/UUID-specific attachment-adoption mutation gate remains narrower and unchanged.

No change to `selectMessageLensStartupPresentation`, admitted identity policy, native archive claim, marker format, FDA-experiment route, or production bundle behavior unless a mechanically required source correction is reviewed and separately approved. Any contradiction is a STOP gate.

---

# 21. Proposed file scope

Use the source-grounded minimal inventory from Response 81 Section 23.

**New production:**

- `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart`;
- its generated Riverpod provider companion, if needed;
- `lib/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart`.

**Existing production:**

- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`;
- `lib/essentials/app_czar/application/app_czar_presentation_projector.dart`.

Only touch `app_czar_models.dart` or `app_czar_assessment_provider.dart` if the chosen implementation demonstrably cannot attach capture time to the occurrence controller as preferred. Preserve evaluator semantics.

**Tests:**

- new Diagnostic controller and screen tests;
- startup harness / host routing tests;
- AppCzar architecture census tests;
- forbidden-import architecture tests;
- pure projector tests;
- existing evaluator, other coordinator, Operating, archive, and production selection tests.

Release metadata/CHANGELOG may advance under repository convention. Do not redesign other coordinator packages.

---

# 22. Focused test matrix

Implement Response 81 Section 25's complete matrix. At minimum require:

1. each of 22 Diagnostic frontier cases selects exactly one explicit Diagnostic host;
2. predicate rejects incomplete assessments and all non-Diagnostic selections;
3. correct TRUE/FALSE/UNKNOWN/conflict presentation from frozen evidence;
4. sourceFactMissing remains known FALSE;
5. protected history and retired artifacts remain non-resettable;
6. corrupt/unsupported store shows bounded literal inspection failure;
7. safe-empty source UNKNOWN and established-dataset source UNKNOWN remain literal and do not infer FDA toggle;
8. source sampling instability shows observed instability only;
9. source/local anti-direction renders both sides and no Data Update;
10. archive/coverage/repairability binding uncertainty remains Diagnostic;
11. complete-coverage/repairability contradiction is correctly displayed;
12. actionable available attachment work remains Attachment Archive Repair;
13. conclusive source-absent debt remains Operating-safe under the original predicate;
14. AppCzar Diagnostic does not construct Operating or other coordinator providers;
15. Journey/Environment Readiness/legacy exporter remain unconstructed;
16. zero Ball/mutation/reset/import/writer entry points reachable;
17. no automatic retry, polling, source read, or restart while time advances;
18. repeated identical UNKNOWN stays stable;
19. **Try Assessment Again** closes admission, drains, and calls one qualified restarter;
20. scheduling failure stays Diagnostic with literal error;
21. **Quit** and OS quit/window close drain without restarter;
22. stale/reentrant callbacks remain inert/single-flight;
23. frozen rows do not change when unrelated providers change;
24. occurrence generation and capture time are stable;
25. no copy/export surface exists;
26. all five existing top-level coordinator regressions pass;
27. Operating regressions pass;
28. production legacy startup and development selection regressions pass;
29. artifact tests use temporary read-only evidence, never real archives;
30. entire architecture, analyzer, and deterministic Flutter suites pass.

Where useful, use provider-initialization observers rather than asserting only absence of rendered text.

---

# 23. Architecture tripwires

Update architecture census to:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Local Data Repair           EXECUTABLE TOP-LEVEL COORDINATOR
Diagnostic Review           EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION
```

Require exactly one `shouldExecuteAppCzarDiagnosticReview`, exactly one explicit Diagnostic host branch, no generic dispatcher, no Diagnostic Ball/mutation edges, and no source/database/legacy package imports.

Enforce first-branch construction ordering so Diagnostic admission does not watch other specialists. Require `appCzarProcessRestarterProvider` reuse and reject direct termination/process spawning inside the Diagnostic package. Enforce projector independence from evaluator and UI absence of fact-selection logic. Keep all existing mutation-edge counts unchanged.

---

# 24. Full validation and conformance

Run:

- focused Diagnostic controller, projector, presentation, lifecycle tests;
- exhaustive Diagnostic selection matrix;
- host construction/provider-initialization tests;
- AppCzar observation/evaluator regressions;
- Data Update / Source Access Repair / Attachment Archive Repair / Onboarding / Local Data Repair regressions;
- Operating Session and source-currentness regressions;
- archive admission/composition and Start Fresh/historical-source safety regressions;
- entire `test/architecture` suite;
- `flutter analyze`;
- full deterministic `flutter test` suite;
- native tests only if changed native/bootstrap assumptions require them;
- `git diff --check`, formatting, generated-code consistency;
- macOS development debug build **without launching**.

Require:

```text
PROJECT CONFORMANCE: PASS
BLOCKER: 0
SHOULD FIX: 0
```

Specifically audit Fair-Witness presentation, no new observations, exactly one semantic owner, no Ball, no retry loop, no persisted state, exact process boundary, diagnostic-only actions, no legacy authority, and unchanged production route.

Do not count the 22 frozen-evidence presentation cases as live qualification. Human qualification is separate.

---

# 25. Implementation checkpoint and artifact

If and only if all gates pass:

1. create a narrow implementation commit, suggested subject:
   `feat(startup): add AppCzar diagnostic review`;
2. advance sequential version/build and CHANGELOG if repository convention requires;
3. build the development artifact without launching it;
4. report exact product, bundle ID, `development/developmentDebug`, version/build, executable SHA-256, `App.framework/App` SHA-256, and bundle path;
5. create a narrow Prompt 82 / Response 82 documentation checkpoint containing the actual verified implementation and build results;
6. push normally.

A documentation commit cannot embed its own final hash; report that hash in the post-commit handoff. No force push, rebase, squash, merge, or unrelated staging.

Record the status precisely:

```text
Diagnostic Review implemented: YES
Automated validation: PASS
Human live qualification: PENDING
Production AppCzar cutover: NOT AUTHORIZED
```

---

# 26. Next human qualification design, but do not execute

After Prompt 82 passes, prepare a separate Prompt 83 to human-qualify against the **exact new development artifact** with fresh, isolated disposable roots only. Response 81 Section 26 defines six experiment classes:

A. corrupt/unsupported import;
B. live provenance with missing current source fact;
C. protected historical/non-live material;
D. UNKNOWN source/read failure;
E. unstable source sample or source/local anti-direction;
F. archive/coverage/actionability binding uncertainty.

Require before/after fixture fingerprints proving no repair or historical removal occurred. Under a stable Diagnostic UNKNOWN, observe the absence of automatic restart. In D, press **Try Assessment Again** exactly once and verify a real old-PID/new-PID boundary; if UNKNOWN remains, the next process waits again. Test **Quit** in a separate run, proving no relaunch. Do not infer an unobserved zero-PID interval.

Do not create fixtures or launch the app in Prompt 82. Do not skip human qualification because the automatic suite passes.

---

# 27. Stop gates

STOP AND REPORT without pretending implementation PASS if:

- Response 81's completed assessment lacks evidence needed for a promised UI claim, and a new read would be necessary;
- an immutable occurrence cannot be captured without rerunning AppCzar;
- UI presentation would require selecting a different disposition or editing evaluator semantics;
- Diagnostic would need to poll/monitor/read files to remain displayed;
- quit/restart cannot reuse the qualified restarter/lifecycle seams safely;
- same-process `runAgain()` is required to make Try Assessment Again work;
- diagnostic copy/export requires coupling to legacy Onboarding;
- other specialist controllers must be mounted/watchers active underneath Diagnostic;
- a Ball, reset, source reader, or historical-removal capability becomes reachable;
- production startup, development archive admission, or WD adoption mutation authorization must change;
- Project Conformance cannot reach PASS.

If any unexpected source fact contradicts the audit, stop with exact evidence and propose a separate narrow correction rather than expanding this task.

---

# 28. Required Response 82

Create Response 82 with, at minimum:

1. exact baseline/current HEAD/upstream/worktree/submodule;
2. Prompt 81/Response 81 audit documentation checkpoint and push;
3. pre-change execution census;
4. source-grounded Diagnostic selection predicate;
5. completed assessment-generation capture and identity;
6. frozen observation/fact reuse;
7. timestamp-clock semantics;
8. memory-only occurrence phases and invariants;
9. pure projector changes;
10. TRUE/FALSE/UNKNOWN/conflict display rules;
11. all 22 Diagnostic frontier cases covered;
12. literal sourceFactMissing/anti-direction presentation;
13. protected/retired/corrupt presentation;
14. source/FDA distinctions;
15. archive availability/coverage/repairability distinctions;
16. privacy/bounded technical details and no-export decision;
17. Diagnostic screen actual copy/actions;
18. explicit first coordinator host branch;
19. proof other specialist providers are not initialized;
20. exact Try Assessment Again restarter path;
21. restart scheduling failure semantics;
22. Quit and OS-exit lifecycle path;
23. stopAndDrain/single-flight/stale-action behavior;
24. no automatic retry/poll/monitor proof;
25. no mutation Ball/worker/reset/export authority;
26. no legacy Journey/Environment Readiness dependencies;
27. unchanged production startup and WD adoption gate;
28. post-change execution census;
29. focused Diagnostic tests and counts;
30. exhaustive frontier regression results;
31. five specialist and Operating regressions;
32. architecture suite and enforcement;
33. analyzer and full Flutter suite;
34. native test result if applicable;
35. format/generated/diff hygiene;
36. Project Conformance verdict;
37. BLOCKER findings;
38. SHOULD FIX findings;
39. implementation checkpoint commit;
40. documentation checkpoint commit or post-commit handoff;
41. pushed recovery anchor;
42. exact build version/path/hashes;
43. final Git/worktree/index/submodule state;
44. readiness for isolated Diagnostic Review human qualification;
45. readiness for whole-repository AppCzar production-cutover audit.

Conclude exactly:

```text
DIAGNOSTIC REVIEW IS AN EXPLICIT EXECUTABLE TOP-LEVEL COORDINATOR: YES / NO
DIAGNOSTIC REVIEW PRESENTS ONLY ONE FROZEN APPCZAR ASSESSMENT: YES / NO
DIAGNOSTIC REVIEW DISTINGUISHES FALSE, UNKNOWN, AND LITERAL CONFLICT: YES / NO
DIAGNOSTIC REVIEW PERFORMS NO NEW EVIDENCE READ OR MESSAGE DATA MUTATION: YES / NO
DIAGNOSTIC REVIEW ACQUIRES NO MUTATION BALL: YES / NO
TRY ASSESSMENT AGAIN USES A REAL PROCESS BOUNDARY: YES / NO
DIAGNOSTIC REVIEW HAS NO AUTOMATIC RETRY OR RESTART LOOP: YES / NO
QUIT DRAINS WITHOUT RELAUNCH: YES / NO
LEGACY AND PRODUCTION STARTUP BEHAVIOR IS UNCHANGED: YES / NO
EXECUTABLE APPCZAR DIAGNOSTIC REVIEW IMPLEMENTED: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR ISOLATED DIAGNOSTIC REVIEW HUMAN QUALIFICATION: YES / NO
READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO
```

Then STOP.
