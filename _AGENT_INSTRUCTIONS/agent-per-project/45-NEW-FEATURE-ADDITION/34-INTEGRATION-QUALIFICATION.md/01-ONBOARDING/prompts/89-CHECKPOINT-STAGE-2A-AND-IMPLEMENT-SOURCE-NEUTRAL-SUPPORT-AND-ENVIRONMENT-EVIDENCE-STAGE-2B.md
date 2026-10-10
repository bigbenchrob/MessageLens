# MessageLens Feature 34
## 89 — Checkpoint Stage 2A and Implement Source-Neutral Support and Environment Evidence (Production-Safe Shell Stage 2B)

Response 88 completed Stage 2A: the neutral current-Messages evidence boundary is now shared by Message History Coverage, Historical Archives, and the legacy Onboarding compatibility adapter. Its low-level read-only probe was **reused**, not copied. AppCzar's existing two-sample assessment source reader, all seven dispositions, production startup selection, and operation-specific mutation authorities remained unchanged.

The next dependency is **Stage 2B**, as designed in Response 87:

1. preserve the existing **Send Logs…** command and its privacy-preserving exporter mechanics, while removing the necessity for an AppCzar Operating composition to construct legacy Onboarding operation/Journey evidence;
2. preserve the existing **Environment Summary** presentation and factual domain cards, while replacing legacy startup/installation fields with a display-only, composition-appropriate projection of already established facts;
3. do this without creating a second evaluator, a new startup vote, or an eager read/worker; and
4. keep production AppCzar activation **unconditionally disabled**.

This is an **implementation and automated-validation prompt**, bounded by a mandatory source audit before the first edit. If the source audit cannot support a small safe extraction without altering the semantics or privacy of the existing exporter, STOP and report rather than expanding into a diagnostics framework.

**Do not** implement Stage 2C Start Fresh, Stage 2D shell construction, Stage 2E lifecycle closure, a production restarter, a production activation switch, or actual cutover in this task.

---

# 1. Baseline and worktree discipline

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- upstream ahead/behind `0/0`;
- clean tracked worktree and index;
- clean shared instructions submodule pinned at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree;
- known unrelated untracked files left untouched.

Verify that the Stage 2A implementation commit is in ancestry:

`ef95447d1f4e6659dccf16e4d916b4bd4bfd4824`

Resolve the **actual** current HEAD and upstream from Git. Response 88 was written before its documentation checkpoint finalized, so do not assume the implementation commit is still HEAD.

Read the canonical Project Conformance standard and the controlling Response 85, Response 86, Response 87, and Response 88, plus source paths discovered below. Create a fresh external Git/source-only baseline manifest. No real user data in that manifest.

Do not switch branches, create another worktree, merge, rebase, squash, or force push.

---

# 2. Checkpoint Prompt 88 / Response 88 first

Before source edits, determine whether Prompt 88 and Response 88 are already committed and pushed.

If so, report their exact documentation commit and do not duplicate it.

If not, checkpoint **only** those exact two records, run staged diff checks, and push normally. Do not stage unrelated untracked files.

Preserve the literal Stage 2A evidence:

```text
Neutral Messages evidence extracted: YES
Message History Coverage no longer imports Onboarding source providers: YES
Historical Archives no longer imports Onboarding source providers: YES
Legacy Onboarding delegates through the neutral reader: YES
AppCzar two-sample evaluator unchanged: YES
Production AppCzar activation: OFF
Stage 2B: NOT YET IMPLEMENTED
```

---

# 3. Source audit — mandatory before edits

Trace the exact current source call graph, providers, asynchronous actions, and import dependencies for:

- the Settings **Send Logs…** row, its dispatcher/action provider, and actual exporter;
- `diagnosticReportProvider`, diagnostic evidence builder/formatter, support bundle provider, and any private-data redaction or size constraints;
- the legacy Onboarding operation controller, Journey/Environment report, operation snapshot, pipeline telemetry, installation classification, and any incident/failure source transitively constructed when Send Logs is invoked;
- the existing **Environment Summary** provider, view/model, source cards, archive/database/environment evidence, and its startup/installation fields;
- the current `AppCzarAssessmentState`, `AppCzarPresentationProjector`, admitted `ArchiveAccessAuthority`, and AppCzar Operating composition;
- the newly introduced `lib/essentials/messages_source/` reader and its provider(s);
- the current Settings dispatcher, workspace/cassette spec, and production and development composition boundaries.

Deliver a before/after **provider-construction and dependency graph**, including the exact transition from UI action to formatter/exporter and the exact fields displayed by Environment Summary.

Classify each existing datum:

```text
A. neutral, current read-only machine/archive fact
B. immutable admitted application/archive identity
C. already-completed AppCzar assessment fact or observation
D. legacy Journey/Onboarding operation or completion narrative
E. operation-recovery evidence with independent product value
F. secret, private or sensitive information excluded from export
```

Do not assume a provider is safe because its name says `diagnostic`, `environment`, or `readOnly`. Source-trace all transitive watches and side effects.

**Stop gate:** if either UI path cannot be separated from legacy semantic authority without redesigning the support exporter, changing diagnostic privacy, or introducing new AppCzar assessment reads, do not implement. Produce a narrower Stage 2B audit and a follow-up seam proposal instead.

---

# 4. One neutral evidence model, not a second readiness system

Introduce the minimum typed, *presentation-only* input needed to reuse existing output mechanics in both currently supported compositions.

A reasonable conceptual shape (use codebase-idiomatic names) is:

```text
SupportEvidenceContext
    application/archive identity, when admitted
    composition kind (legacy / AppCzar)
    optional already-completed AppCzar assessment generation
    bounded current diagnostic metadata
    optional existing domain-health evidence

EnvironmentStartupEvidenceProjection
    explicit source/provenance
    optional bounded assessment state
    literal unestablished/not observed state
```

The precise classes should follow the source audit, not these example names.

Requirements:

- models are immutable, small, and independently testable;
- every diagnostic statement names/retains its provenance and observation scope;
- facts are not silently refreshed merely because a Settings panel mounts;
- unknown/unavailable/unsupported information is **not** mapped to healthy, empty, complete, broken, or permission denied;
- a stale AppCzar assessment is explicitly a snapshot at assessment generation, not current live telemetry;
- no new `isReady`, `isOnboarded`, `shouldStart`, `mayReset`, or other semantic selector;
- no durable state, cursor, retry, polling, or background listener;
- no generic all-purpose evidence bus or parallel AppCzar evaluator.

**Single semantic authority:** AppCzar owns AppCzar startup meaning; legacy StartupApp retains its currently active legacy meaning until production activation is separately authorized. The neutral model translates/provides *display evidence*, never chooses between them.

---

# 5. Compose evidence only within the already-selected architecture

Legacy production is still mounted through `StartupApp`. It must keep its existing reporting behavior until the cutover/retirement milestone, including its current operation-specific detail where relevant. Do not remove the legacy provider or make it depend on AppCzar.

In an AppCzar composition:

- consume **only a completed existing AppCzar assessment** when assessment context is needed;
- project that captured generation/read-only observations, not a fresh `AppCzarEvaluator` invocation;
- do not initialize `onboardingOperationControllerProvider`, Journey, Environment Readiness, operation completion controllers, or legacy pipeline incidents;
- do not start import, graph update, `chatDbChangeMonitorProvider`, archive sweep, or support export while merely projecting the UI;
- if no completed current assessment was supplied to a particular adapter, present an explicit unavailable/not-established value rather than constructing a legacy provider;
- select the adapter through an already-established composition dependency/explicit input, **not** a root path, UUID, or the development-only predicate used for unrelated permissions.

Do not introduce a simulated active-production AppCzar activation path merely to test this. Production eligibility may be TRUE, but `ProductionAppCzarActivation` remains disabled.

---

# 6. Preserve Send Logs command and exporter mechanics

Keep the current Settings row and ordinary deliberate human Send Logs flow.

Reuse the existing privacy-safe enumeration, formatting, packaging, bounded file selection, OS share/destination logic, and explicit user action where safe. Extract only the existing *legacy-coupled evidence assembly* necessary to let an AppCzar Operating session invoke the same exporter without constructing Journey or Onboarding operation state.

Prefer this conceptual layering:

```text
Settings Send Logs action
    -> composition-appropriate evidence adapter
    -> existing bounded neutral diagnostic report core
    -> existing privacy-reviewed exporter and user destination
```

Legacy stays:

```text
legacy Settings action
    -> existing legacy-specific evidence adapter
    -> same neutral report/export core
```

Do not create a second independent report/export implementation.

The exported report must never include:

- message bodies or rich-text payloads;
- raw Contacts records or channels;
- attachment payloads, source SQL, database pages or WAL files;
- security-scoped bookmark bytes, passwords, auth tokens or mutation capability material;
- unbounded personal paths/UUIDs or unredacted private diagnostic excerpts;
- an entire archive directory merely because support export was requested.

Existing privacy rules are the floor. Keep or strengthen bounding/redaction only with source-grounded tests; avoid a broad output-format change without necessity. Detail provenance should distinguish current bound facts, old legacy-operation history, and currently unavailable evidence.

No automatically generated file or exported artifact may be written into the admitted archive/data root unless that is the existing explicitly authorized output policy (if found, STOP for review). No action may run merely from opening Settings or Environment Summary.

Diagnostic Review Stage One continues to have **no** Send Logs/export control added to its frozen screen; do not alter that coordinator's read-only human contract.

---

# 7. Environment Summary: retain product parity, replace only semantic startup fields

Preserve the existing Environment Summary card/panel layout and ordinary domain-health evidence to the greatest extent possible.

For the startup/installation fields that currently consume legacy Onboarding, Journey, or startup telemetry:

- in a **legacy composition**, preserve the existing legacy display and workflow;
- in an **AppCzar composition**, show the selected disposition, assessment generation, and applicable bounded facts from the already-captured AppCzar assessment;
- render unknown, not observed, or unavailable facts literally;
- label bounded assessment evidence as a snapshot, not as continuously refreshed current health;
- do not render a stale Journey stage under a new AppCzar label;
- do not derive completion from prior worker result or `OnboardingGate` state;
- do not make the display itself assess, build, repair, migrate, or choose a coordinator.

Reuse existing neutral archive/database/root/feature cards. Avoid duplicating those readers; prove that opening Environment Summary in AppCzar does not construct a second startup observer or a legacy authority provider.

The new Stage 2A current-Messages evidence may be reused for **feature-level bounded source reporting only** when necessary. Its single max-ROWID probe is not the AppCzar two-sample startup fact. Do not substitute it for AppCzar source stability or grant it startup authority.

---

# 8. Command dispatch and scope boundaries

Stage 2B covers only these two normal-user surfaces:

1. **Send Logs…** evidence assembly and invocation using existing export mechanics;
2. **Environment Summary** startup-evidence presentation.

Do not implement or rewire now:

- the voluntary **Reset Message Data… / Start Fresh** action;
- Historical Archives import/removal lifecycles (Stage 2A only fixed their source path);
- attachment adoption/relocation or archive mutation permissions;
- Operating or startup process restarter;
- product navigation root or selected production AppCzar shell;
- app startup initialization or release signing;
- Diagnostic Review's optional copy/export action.

If safe access to the AppCzar adapter requires exposing one narrow input/provider through the already existing development Operating shell, do so without introducing a second authority or mounting a legacy root.

---

# 9. Authority and presentation invariants

Require mechanically:

```text
archive admission precedes all startup composition selection
production eligibility != activation
production activation == false
production still mounts StartupApp
recognized development still mounts AppCzarStartupHarness
one AppCzar assessment controls displayed startup meaning
no additional source monitor / currentness owner
no new Ball, reset, import, archive writer or historical removal edge
```

Keep `attachmentArchiveAdoptionExecutionEnabledProvider` restricted to its already-qualified development root/UUID and independent from composition selection.

The neutral support/environment packages must not import Journey selectors, Onboarding gate/operation controllers, or Environment Readiness as AppCzar dependencies. It is acceptable for the separate legacy adapter to retain its current legacy imports; tests must enforce the layering and only one owner per composition.

---

# 10. Focused automated tests — support evidence

Add/update tests for:

1. legacy Send Logs uses the legacy evidence adapter and retains product behavior;
2. AppCzar Operating Send Logs uses a complete AppCzar assessment and does **not** construct legacy operation/Journey providers;
3. exporter core is one reused implementation, not duplicated;
4. opening Settings does not export or trigger new expensive reads;
5. clicking Send Logs is the only export trigger;
6. no archive-root or sensitive destination is selected by default;
7. null/not-established assessment produces explicit bounded omission, not a claimed healthy outcome;
8. FALSE, UNKNOWN, and literal conflict remain distinct;
9. report content redaction, size bounds, file inventory bounds, and sensitive path/UUID treatment are at least as strict as pre-change;
10. generated report contains no message text, contact data, attachment bytes, bookmarks, capabilities, source SQL, or unrestricted paths;
11. exporter failure/denied destination produces literal user-visible failure and no change in coordinator jurisdiction;
12. no background writer/monitor/provider is initialized by this path.

Use isolated fixture providers and temp files only, with no real user data. Do not export actual support bundles in a real application session.

---

# 11. Focused automated tests — Environment Summary

Add/update tests for:

1. legacy startup fields retain their current meaning and render from the legacy adapter;
2. AppCzar startup fields render only supplied frozen AppCzar assessment facts;
3. selected disposition and generation are presented without re-evaluation;
4. assessment-unknown remains UNKNOWN and is not permission denial;
5. known FALSE remains known FALSE;
6. literal conflict is displayed only if the captured evidence proves conflict;
7. unobserved fields are omitted/labeled unestablished rather than filled from Journey;
8. provider updates elsewhere do not mutate a captured assessment projection;
9. opening the panel does not start AppCzar assessment, read Messages/Contacts, or mount legacy Journey providers;
10. normal neutral environment cards/layout remain present;
11. source evidence from Stage 2A is not treated as AppCzar's two-sample source-stability authority.

If there is no real AppCzar Settings/Environment Summary surface yet, test the composition-neutral model and explicit injected-adapter wiring honestly. Do not claim a user-visible production path is mounted or qualified when it is not.

---

# 12. Architecture tests and exclusion probes

Update architecture tests to require:

- source-neutral support and Environment evidence packages have no forbidden semantic imports;
- legacy-specific adapters are kept isolated from AppCzar host/Operating composition;
- one source of AppCzar selected-disposition facts: completed assessment/projection;
- no generic startup state classifier;
- no extra `AppCzarEvaluator` or source probes in the display adapter;
- no second support exporter core;
- no new `ArchiveMutationCoordinator.runWithCapability` edges;
- no new timer, polling loop, import worker, graph updater, attachment sweep, or `chatDbChangeMonitorProvider` construction;
- production AppCzar activation still has only the disabled value;
- official production `StartupApp` route unchanged;
- Stage 2A Coverage/Historical Archives neutral-reader and historical mutation tripwires retained.

Where useful, override legacy providers with throwing counters and prove **AppCzar** construction/invocation doesn't initialize them. Avoid brittle tests asserting incidental file names or comments instead of reachability.

---

# 13. Regression and validation matrix

Run the source-relevant focused suites, including:

- support report assembly/export/privacy tests;
- Settings command-dispatch tests;
- Environment Summary view/model/provider tests;
- Stage 2A `messages_source` reader and Coverage/Historical Archives regressions;
- AppCzar assessment/evaluator/presentation/Operating tests;
- legacy startup, Onboarding, Journey and Start Fresh regression tests;
- archive admission, production eligibility/default-off activation and adoption-gate tests;
- complete architecture/forbidden-import suite;
- full deterministic Flutter suite;
- `flutter analyze`;
- code generation consistency (if Riverpod files changed);
- formatting and staged/unstaged `git diff --check`.

Use temporary in-memory/fixture data only. No app build or launch is needed or authorized. Do not access real Apple Messages/Contacts, WD/Toshiba, or real production/development MessageLens data.

Report actual test counts and any existing skips, not inherited counts from Response 88.

---

# 14. Project Conformance

Require `PROJECT CONFORMANCE: PASS`, `BLOCKER: 0`, `SHOULD FIX: 0` within this bounded implementation scope.

Explicitly evaluate:

- provenance and Fair-Witness truth for support and Environment fields;
- one top-level semantic authority per composition;
- no AppCzar/legacy parallel readiness answer;
- read-only projection versus deliberate user action;
- support-export privacy and boundedness;
- preservation of legacy product behavior;
- no eager assessment or archive/source activity;
- mutation/operation and archive-adoption gate separation;
- production activation still unconditionally disabled;
- no source/release/signing/restarter/build changes outside scope.

If strict parity exposes a conflict between legacy-report content and AppCzar semantics, do not paper it over with fallback to legacy facts. State the incompatibility and stop for a separate approval.

---

# 15. Implementation, documentation, and recovery checkpoints

If validation/conformance passes:

1. commit **only** bounded Stage 2B production/test/generated files;
2. push the implementation as an ordinary recovery anchor;
3. create Response 89 with exact findings, validation, and preservation results;
4. checkpoint Prompt 89/Response 89 documentation by exact paths and push;
5. leave unrelated untracked files, other worktrees, and the shared submodule untouched.

Suggested implementation subject:

`refactor(startup): decouple support and environment evidence from onboarding`

No release version bump or development artifact is required absent an explicit project source policy. Do not rebuild, install, or launch either app.

---

# 16. Stage 2C decision remains separate

Do not turn voluntary Start Fresh into an eighth top-level AppCzar jurisdiction. Its natural owner is an **Operating-owned explicit command occurrence** unless a later source-grounded architecture review demonstrates otherwise. It is different from system-selected Local Data Repair, and it must never inherit Local Data Repair's automatic authorization.

Response 89 should carry this as a **future architecture review question**. Do not implement Start Fresh in Prompt 89.

The remaining proposed order is Stage 2C (review/implement voluntary Start Fresh), Stage 2D (neutral shell construction), Stage 2E (parity and lifecycle closure), Stage 2F (disposable production-identity rehearsal seam), then separate authorizations for signed rehearsal and any actual production cutover.

---

# 17. Stop gates

STOP AND REPORT if:

- checkpoint provenance cannot be verified;
- either feature's dependency cannot be decoupled without importing legacy semantic providers into an AppCzar path;
- the only feasible approach would add another evaluator, readiness classifier, or currentness monitor;
- the existing exporter would need an unreviewed privacy weakening, unbounded scan, or automatic archive-root write;
- an AppCzar report would depend on legacy Journey/operation completion state;
- normal legacy Send Logs/Environment Summary behavior cannot be preserved;
- current factual evidence is missing but implementation would have to fabricate healthy/complete/denied meaning;
- any AppCzar selection, production activation, process restarter, mutation gate, Start Fresh behavior, archive admission, or release identity needs changing;
- test behavior can only be demonstrated by reading or modifying real user data;
- Project Conformance has any outstanding in-scope BLOCKER or SHOULD FIX.

Do not widen to Stage 2C/D to work around a stop gate.

---

# 18. Required Response 89

Create Response 89 and report:

1. baseline Git state, implementation ancestry, worktree/submodule;
2. Prompt 88/Response 88 documentation checkpoint;
3. exact before-change support call graph;
4. exact before-change Environment Summary call graph;
5. source audit of legacy authority/ambient construction;
6. exporter mechanics and privacy inventory;
7. evidence classification and provenance;
8. typed neutral support-evidence design;
9. typed Environment startup-evidence design;
10. exact reuse/extraction diff versus duplication;
11. legacy Send Logs parity;
12. AppCzar Send Logs isolation and invocation boundary;
13. exporter output scope, bounding, redaction, and destination policy;
14. user-visible export failure semantics;
15. legacy Environment Summary parity;
16. AppCzar Environment Summary frozen assessment and UNKNOWN/FALSE semantics;
17. handling of absent/no-assessment facts;
18. Stage 2A source-evidence noninterference;
19. precise Settings action dispatch after changes;
20. provider-construction/throwing-probe evidence;
21. forbidden-import and mutation-edge evidence;
22. startup/production activation noninterference;
23. focused support/privacy tests;
24. focused Environment Summary tests;
25. Coverage/Historical Archives regressions;
26. AppCzar/Operating regressions;
27. legacy StartupApp/Journey/Start Fresh regressions;
28. archive/adoption authority regressions;
29. architecture suite count/result;
30. full Flutter suite count/result;
31. analyzer/generator/format/diff hygiene;
32. Project Conformance and BLOCKER/SHOULD FIX findings;
33. exact implementation commit, push, and diff inventory;
34. exact documentation checkpoint, push, and recovery anchor;
35. final Git/index/worktree/submodule state;
36. readiness for Stage 2C review;
37. readiness for Stage 2D production-safe shell construction;
38. staged production-identity rehearsal readiness;
39. actual production cutover readiness;
40. any separate Start Fresh ownership question for the next stage.

Conclude exactly:

`RESPONSE 88 STAGE 2A CHECKPOINT VERIFIED: YES / NO`

`SEND LOGS REUSES EXISTING EXPORT MECHANICS WITHOUT APPCZAR JOURNEY DEPENDENCY: YES / NO`

`ENVIRONMENT SUMMARY PRESENTS APPCZAR FACTS WITHOUT LEGACY STARTUP AUTHORITY: YES / NO`

`LEGACY SETTINGS AND SUPPORT BEHAVIOR IS PRESERVED: YES / NO`

`NO SECOND EVALUATOR, SOURCE MONITOR, OR MUTATION OWNER INTRODUCED: YES / NO`

`SUPPORT PRIVACY AND BOUNDING ARE PRESERVED: YES / NO`

`STAGE 2A SOURCE EVIDENCE AND HISTORICAL AUTHORITY ARE UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS UNCONDITIONALLY OFF: YES / NO`

`PRODUCTION STILL SELECTS LEGACY STARTUPAPP: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`STAGE 2B IMPLEMENTED: YES / NO`

`READY FOR STAGE 2C REVIEW: YES / NO`

`READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: YES / NO`

`PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO`

Then STOP.
