# MessageLens Feature 34
## 71 — Checkpoint Operating Qualification and Audit the AppCzar Onboarding Jurisdiction

Response 70 completed the human live qualification of Operating Stage Two.

The live evidence now proves:

```text
known source-absent attachment debt
    may coexist truthfully with Operating

ordinary text delta
    -> same PID
    -> same Operating occurrence
    -> same selected conversation
    -> new message appears automatically

ordinary attachment-bearing delta
    -> same PID
    -> same Operating occurrence
    -> attachment preservation/verification
    -> no repair opportunity remains

source access loss
    -> Operating stops/drains
    -> real process boundary
    -> fresh AppCzar
    -> Source Access Repair

source access restoration
    -> repair stops
    -> real process boundary
    -> fresh AppCzar
    -> Operating
```

This qualifies the current AppCzar jurisdictions:

```text
Data Update                 executable / qualified
Source Access Repair        executable / qualified
Attachment Archive Repair   executable / qualified
Operating Session           executable / qualified
```

The remaining virtual AppCzar dispositions are:

```text
Onboarding
Local Data Repair
Diagnostic Review
```

Production startup still uses the legacy startup/Journey authority. Do NOT cut
production over yet.

The next architectural milestone is to make **Onboarding** source-grounded and
bounded enough to replace the legacy Journey authority later.

This prompt is primarily an **audit/design task**.

It checkpoints Response 70 first, then performs a complete source-grounded audit
of the existing Onboarding/Journey machinery and produces the exact executable
AppCzar Onboarding design.

Do NOT implement the Onboarding coordinator unless Section 16 explicitly proves
that implementation is mechanically narrow and all stop gates are satisfied.
Default: audit/design only.

Do NOT route production startup through AppCzar.
Do NOT delete legacy Journey/startup code yet.
Do NOT weaken existing qualified jurisdictions.
Do NOT mutate real MessageLens databases or attachment archives.
Do NOT launch production MessageLens.

---

# 1. Baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- current HEAD/upstream equal at the pushed Response 69/Prompt 70 qualification
  state;
- tracked worktree clean;
- index clean;
- ahead/behind `0/0`;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- one active Feature 34 worktree.

Read:

- Response 40;
- Response 41;
- Response 51;
- Response 70;
- current AppCzar evaluator/dispositions;
- current legacy Onboarding Journey;
- initial import/graph workers;
- reset/cleanup machinery;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Prompt 70 / Response 70 qualification evidence first

Prompt 70 made no source/test changes but is now governing human evidence.

Create a narrow Feature 34 documentation checkpoint containing Prompt 70 and
Response 70 if they are not already committed.

Record exactly:

```text
Operating Stage Two human live qualification: PASS

Qualified live behaviors:
    source-absent attachment debt coexists with Operating
    ordinary text update remains same PID
    navigation remains selected
    ordinary attachment-bearing update remains same PID
    fresh process reconstructs attachment debt without waiver
    source-access loss crosses real process boundary
    fresh AppCzar owns Source Access Repair
    source restoration returns through fresh AppCzar authority
```

Also preserve the observed non-architectural follow-ups:

```text
live update latency observed:
    text ~100 s
    photo ~76 s

debt card:
    partially obscured by sidebar in neutral empty-center layout
```

Do not reopen those presentation/performance issues in this prompt unless they
block Onboarding audit work.

Push the documentation checkpoint normally before any source edit.

---

# 3. Reconfirm current AppCzar execution census

Before auditing Onboarding, verify current source still provides exactly:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Onboarding                  VIRTUAL ONLY
Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

No generic enum dispatcher.

No production AppCzar startup route.

If this census differs, STOP AND REPORT.

---

# 4. Re-audit the exact current Onboarding selection predicate

Trace the current AppCzar fact DAG and disposition selector.

Answer from source:

1. What exact present-tense facts cause the virtual Onboarding disposition?
2. Does Onboarding mean:
   - no complete local message dataset;
   - disposable incomplete live-only derived data;
   - absent initial stores;
   - another condition?
3. Which preservation/configuration stores must already be safe before
   Onboarding may be selected?
4. What facts distinguish Onboarding from:
   - Source Access Repair;
   - Local Data Repair;
   - Diagnostic Review?
5. Can source readability be FALSE while Onboarding still owns jurisdiction?
6. Can source readability be UNKNOWN while Onboarding owns jurisdiction?
7. How does AppCzar distinguish:
   - virgin/no-dataset Onboarding;
   - established installation that lost source access?
8. What evidence prevents protected historical/non-live material from being
   mistaken for disposable initial-build debris?

Do not alter the predicate in this prompt unless the audit finds a pure,
already-tested factual bug.

---

# 5. Source-trace the legacy Journey authority completely

Trace every legacy Onboarding semantic layer currently used by production.

At minimum inspect:

- Journey coordinator;
- Trip / Step / Episode enums and state;
- `OnboardingStatus`;
- `onboardingGateProvider`;
- Onboarding action context;
- `OnboardingEnvironmentReport` semantic evaluator/conclusions;
- durable Onboarding operation snapshot;
- resume/reconciliation logic;
- completion verifier / installation-ready proof;
- Environment Readiness surface;
- center-panel synchronization;
- startup completion callbacks;
- legacy `StartupApp` handoff.

For each classify:

```text
REUSABLE FACT SOURCE
REUSABLE WORKER
REUSABLE PRESENTATION COMPONENT
SAME-SESSION ONBOARDING POLICY
LEGACY SEMANTIC AUTHORITY — DELETE LATER
HISTORICAL DIAGNOSTIC ONLY
UNKNOWN
```

No item may remain UNKNOWN at the end of the audit without a stop/report.

---

# 6. Identify the reusable initial-build worker path

Trace the exact existing production machinery that can construct a new
MessageLens local dataset from current Apple sources.

Report:

1. exact source-reader/importer entry point;
2. source-scoped import database creation path;
3. contacts import/enrichment path;
4. conversation graph projection path;
5. attachment preservation path;
6. rich-text decoding path;
7. bounded page/high-water semantics;
8. mutation/Ball authority;
9. message-data generation behavior;
10. exact worker progress currently published;
11. current callbacks that publish Journey/readiness/completion semantics;
12. which callbacks can be removed while keeping worker mechanics.

Do NOT create a second importer or graph builder.

If initial build cannot be invoked without old semantic authority, identify the
smallest extraction needed for a future implementation.

---

# 7. Audit current prerequisite/self-location checks

Response 40/41 intended Onboarding to self-locate from current evidence each
time it owns jurisdiction.

Audit whether current source already has reusable factual checks for:

- Messages database readability;
- current source inventory/history sufficiency;
- Contacts access/readability;
- required data-root/archive configuration;
- local import/graph emptiness/incompleteness;
- safe cleanup eligibility for incomplete live-only derived data;
- historical/non-live source protection;
- current archive availability;
- any user choice required before build.

For each state:

- identify the fact source;
- identify whether it is read-only;
- identify whether it currently returns a fact or a semantic conclusion;
- identify whether it depends on persisted Journey position/history.

The target Onboarding self-location must use facts only.

---

# 8. Define Onboarding jurisdiction precisely

Propose the smallest executable jurisdiction:

> **Onboarding owns the application only when no complete coherent local message
> dataset currently exists and the current evidence says initial construction
> is the appropriate jurisdiction rather than repair/diagnostic work.**

Onboarding may internally:

- inspect current prerequisites;
- guide the human to satisfy prerequisites;
- recheck prerequisites while still in Onboarding;
- obtain any required initial-build user choices;
- run exactly one admitted initial build;
- show factual current progress/failure;
- retry within Onboarding only when jurisdiction remains Onboarding;
- request real restart after work changes AppCzar-relevant facts.

It may NOT:

- classify the whole application;
- invoke another coordinator;
- declare Operating;
- use a durable Journey cursor;
- restore an old Episode;
- infer current failure from an old failure row;
- publish installation-ready proof.

---

# 9. Define Onboarding self-location states

Do not reuse old Trip/Step/Episode values merely because they exist.

Derive the minimum in-memory states from current evidence.

Conceptual examples:

```text
checkingPrerequisites

messagesSourceNeedsHumanAction

contactsNeedsHumanAction

readyToBuild

cleaningDisposableIncompleteBuild

buildingInitialDataset

buildFailed

waitingForRetryChoice

restarting
```

Use fewer states if source permits.

For every proposed state specify:

- exact current fact predicate;
- allowed user action;
- allowed worker action;
- whether jurisdiction remains Onboarding;
- terminal behavior.

No post-Onboarding state such as `normalApplication` is allowed.

---

# 10. Source access inside Onboarding

Explicitly resolve this distinction:

## No complete local dataset

If AppCzar has already selected Onboarding and current Messages access is
unreadable:

- should Onboarding guide the human to System Settings and retest in-process?
- or should fresh AppCzar select Source Access Repair instead?

Use current fact-DAG meaning, not coordinator convenience.

Preferred architecture from Response 40/41 was:

```text
no complete local dataset
-> Onboarding jurisdiction

within Onboarding:
    current source unreadable
    -> human prerequisite step
    -> Check Again
    -> remain Onboarding while no dataset exists
```

Whereas:

```text
complete established local dataset
+ source becomes unreadable
-> Source Access Repair jurisdiction
```

Confirm or correct this from current source semantics.

Do not duplicate the Source Access Repair controller merely to reuse its UI.

Reuse lower-level source-readability/settings-navigation seams where
appropriate.

---

# 11. Contacts prerequisite

Audit Contacts separately.

Answer:

- Is Contacts access required for initial dataset construction?
- Is it required for graph correctness or only enrichment?
- Can initial build proceed without Contacts?
- What exact current evidence distinguishes:
  - source unavailable;
  - contact enrichment unavailable;
  - contact database empty;
  - successful but zero contacts?
- Does old Journey overstate Contacts as a hard prerequisite?

Fair-Witness rule:

Do not block initial build on Contacts merely because legacy Journey did so if
current source proves Contacts is optional enrichment.

Likewise do not weaken a real graph prerequisite.

---

# 12. Interrupted/incomplete initial-build handling

Audit the current ability to recognize:

```text
no complete dataset
+ incomplete live-only derived import/graph state
```

Determine whether it is mechanically safe to delete/rebuild that derived state
from the beginning.

Required safety:

- only live-source derived import/graph state may be disposable;
- protected non-live/historical source material blocks automatic cleanup;
- overlay/user-authored state is never deleted as derived cleanup;
- attachment archive payloads are never cleanup targets;
- Presence/configuration/identity are not cleanup targets;
- current evidence, not "previous build interrupted", authorizes cleanup.

If current cleanup authority is mixed with Start Fresh or old Journey semantics,
identify the narrow extraction required.

Do not implement automatic cleanup in this audit unless already available as a
pure typed worker with complete tests.

---

# 13. Repeated initial-build failure policy

Audit whether a `consecutive_initial_build_attempts` equivalent exists.

If retained:

- it may influence only retry policy inside an already-selected Onboarding
  occurrence;
- AppCzar must not read it;
- it must not select Journey position;
- it must not determine whether the installation is Onboarding vs Repair;
- Operating may clear it without reading it after fresh healthy admission.

Determine whether this counter still provides real product value.

If not, recommend deletion.

Do not create a broader attempt ledger.

---

# 14. Initial-build success terminal

This invariant is mandatory:

```text
initial build worker completes
-> release mutation authority
-> stopAndDrain Onboarding occurrence
-> real process restart
-> fresh AppCzar
```

Never:

```text
build success
-> Journey says ready
-> same process opens Conversations
```

Fresh AppCzar alone decides whether the resulting durable facts mean:

- Data Update;
- Attachment Archive Repair;
- Local Data Repair;
- Diagnostic Review;
- Operating.

The Onboarding coordinator does not predict that result.

---

# 15. Human quit / lifecycle semantics

Design an Onboarding `stopAndDrain()` contract.

It must account for:

- prerequisite observations;
- initial-build mutation tenure;
- bounded importer transactions;
- graph projection;
- attachment preservation;
- any cleanup operation if later admitted.

Normal quit must stop new work and drain admitted mutation.

No stale Journey/onboarding completion may publish into a replacement process.

Reuse the qualified lifecycle pattern conceptually, without importing Operating
or Repair controllers.

---

# 16. Determine whether implementation is safe in this prompt

After completing Sections 4–15, answer this binary question:

> Can executable AppCzar Onboarding be implemented by composing existing factual
> readers and proven workers without redesigning the import pipeline, inventing
> new durable semantic state, or performing unsafe derived-data cleanup?

If NO:

- do not implement;
- provide the exact blockers and the next narrow implementation prompt.

If YES, implementation MAY proceed in this prompt only if ALL are true:

- no UNKNOWN audit item remains;
- source-readability jurisdiction is resolved;
- Contacts semantics are resolved;
- initial-build worker has a clean callable boundary;
- success restart boundary is clear;
- unsafe partial-build cleanup is either unnecessary for Stage One or already
  mechanically proven;
- production startup remains unchanged.

If there is any doubt, default to audit-only.

---

# 17. If implementation proceeds: executable Onboarding Stage One

Only if Section 16 is unequivocally YES.

Create a new AppCzar Onboarding package with:

- exact executable predicate;
- occurrence/generation-bound controller;
- memory-only self-location state;
- read-only prerequisite reader(s);
- one admitted initial-build executor;
- factual progress;
- `stopAndDrain()`;
- real process restart after successful build.

Do not introduce a generic coordinator dispatcher.

Do not import old Journey semantic state into the new controller.

Legacy Journey may remain untouched for production until later cutover.

---

# 18. Stage One implementation scope limit

For the first executable Onboarding milestone, prefer the narrowest useful
scenario:

```text
safe empty/no-dataset development fixture
+ source readable
+ required current prerequisites known
-> initial build
-> restart
-> fresh AppCzar
```

If source access waiting can also be safely reused, include it.

If partial-build cleanup is not yet mechanically proven, leave that scenario
virtual/diagnostic and STOP rather than broadening Stage One unsafely.

Do not attempt every Onboarding edge case in one milestone.

---

# 19. Tests if implementation proceeds

Use fixtures/temp stores only.

At minimum prove:

1. exact Onboarding predicate is executable and no other virtual disposition
   accidentally becomes executable;
2. complete established dataset never enters Onboarding;
3. no complete dataset maps to Onboarding only under the audited prerequisites;
4. source-access semantics match Section 10;
5. Contacts semantics match Section 11;
6. no durable Journey cursor is read;
7. old Episode/status cannot select the new controller state;
8. old persisted failure cannot select a current step;
9. initial build invokes existing importer/projector, not a second implementation;
10. one Ball/mutation tenure path;
11. progress memory-only;
12. build success cannot admit Operating in-process;
13. build success causes exactly one real restart after tenure release;
14. fresh process owns next disposition;
15. quit drains active build;
16. stale completion cannot publish after drain;
17. production startup remains legacy/unchanged;
18. current qualified Data Update/Source Access/Attachment Repair/Operating
    regressions all pass.

---

# 20. Project Conformance

Whether audit-only or implementation, run the appropriate conformance review.

If implementation proceeds, require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- exactly one semantic jurisdiction owner;
- no old Journey semantic authority imported into new Onboarding;
- no durable Journey cursor;
- existing worker reuse;
- restart after classification-changing work;
- no in-process Operating handoff;
- production startup unchanged;
- current qualified coordinators unchanged.

---

# 21. Build/launch rules

If implementation proceeds:

- run focused tests;
- architecture suite;
- analyzer;
- full deterministic Flutter suite;
- diff/format/generated hygiene;
- debug macOS development build.

Do not launch the app.

Do not human-qualify Onboarding in this prompt.

Leave implementation unstaged unless the prompt reaches an explicit checkpoint
decision after full validation.

Default preferred outcome:

- implementation complete and validated;
- build exact artifact;
- leave unstaged for separate human qualification.

If audit-only:

- make no source/test change;
- no build required unless needed to validate an audit utility.

---

# 22. Production cutover remains forbidden

Even if executable Onboarding Stage One is implemented successfully:

Do NOT:

- route production startup through AppCzar;
- delete `StartupApp`;
- delete Journey;
- delete installation classifier;
- delete Environment Readiness;
- delete legacy production action bridges.

Those actions wait until:

```text
Onboarding executable + qualified
Local Data Repair executable + qualified
Diagnostic Review executable + qualified
```

and a separate production-cutover milestone is approved.

---

# 23. Required response

Create Response 71 and report:

1. baseline verification;
2. Prompt 70/Response 70 documentation checkpoint;
3. current AppCzar execution census;
4. exact current Onboarding disposition predicate;
5. Onboarding vs Source Access jurisdiction distinction;
6. Onboarding vs Local Data Repair distinction;
7. Onboarding vs Diagnostic Review distinction;
8. complete legacy Journey authority inventory;
9. reusable fact sources;
10. reusable workers;
11. reusable presentation components;
12. delete-later semantic authority components;
13. exact initial-build worker path;
14. source import semantics;
15. Contacts prerequisite result;
16. graph projection path;
17. attachment preservation path;
18. rich-text path;
19. mutation/Ball authority path;
20. current prerequisite/self-location fact sources;
21. proposed minimum in-memory Onboarding states;
22. source-access-in-Onboarding design;
23. Contacts handling design;
24. incomplete-build cleanup audit;
25. protected historical/non-live material rule;
26. repeated-attempt policy result;
27. initial-build success/restart contract;
28. Onboarding stopAndDrain design;
29. implementation-feasibility verdict;
30. BLOCKER findings;
31. SHOULD FIX findings;
32. whether implementation proceeded;
33. if implemented: exact source/test inventory;
34. if implemented: focused test results;
35. if implemented: architecture/analyzer/full-suite results;
36. if implemented: Project Conformance verdict;
37. if implemented: exact build identity/path/hashes;
38. final Git/worktree/index/submodule state;
39. readiness for executable Onboarding human qualification;
40. readiness for later Local Data Repair milestone;
41. readiness for production AppCzar cutover.

Conclude exactly:

`OPERATING STAGE TWO HUMAN QUALIFICATION CHECKPOINTED: YES / NO`

`ONBOARDING JURISDICTION IS SOURCE-GROUNDED: YES / NO`

`ONBOARDING CAN SELF-LOCATE WITHOUT A DURABLE JOURNEY CURSOR: YES / NO`

`INITIAL BUILD CAN REUSE EXISTING WORKERS WITHOUT A SECOND PIPELINE: YES / NO`

`EXECUTABLE APPCZAR ONBOARDING IMPLEMENTED: YES / NO`

`READY FOR ONBOARDING HUMAN QUALIFICATION: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
