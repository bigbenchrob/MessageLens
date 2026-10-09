# MessageLens Feature 34
## 81 — Checkpoint Local Data Repair Qualification and Audit AppCzar Diagnostic Review

Response 80 completed the isolated human qualification of executable AppCzar Local Data Repair.

The qualified live result is:

```text
A. Current-source-reconstructible, live-only partial
   -> fresh AppCzar selects Local Data Repair
   -> fresh schema-wide safety revalidation
   -> one typed mutation tenure
   -> only active import/graph derived stores reset
   -> physical reset postcondition passes
   -> process restart
   -> fresh AppCzar selects Onboarding
   -> later fresh AppCzar selects Attachment Archive Repair

B. Live provenance, but local source fact now absent
   -> no reset; fixture unchanged

C. Protected historical/non-live data
   -> no whole-store reset; fixture unchanged

D. Corrupt/unknown local evidence
   -> virtual Diagnostic Review; no mutation; fixture unchanged
```

The repair was observed in PID `81643`, followed by fresh PID `82061`. The observer did not capture a no-process interval, so do not claim one. The first A attempt had unreadable source evidence and did not mutate; only the fresh A retry qualified. The reset log also contained a provider-close warning, but the observed deletion/postcondition passed. Preserve those limitations literally.

The development execution census is now expected to be:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Local Data Repair           EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Diagnostic Review           VIRTUAL ONLY
```

**Diagnostic Review is the final virtual AppCzar disposition.** Its proper role is fundamentally different from a repair coordinator: it must communicate what is provable when MessageLens cannot safely choose or execute another jurisdiction. It must not guess, mutate data to learn what was present, retry indefinitely, or borrow another coordinator's authority.

This prompt is an **audit/design task**, not an implementation or live-qualification task. First checkpoint Prompt 80 / Response 80, then source-trace the complete Diagnostic Review frontier and design the narrowest executable, non-destructive jurisdiction.

Do NOT make Diagnostic Review executable in this prompt.
Do NOT route production startup through AppCzar.
Do NOT delete legacy Journey/StartupApp yet.
Do NOT change existing AppCzar evaluator semantics without a separately identified factual defect.
Do NOT mutate or inspect the real WD development archive or Toshiba attachment archive.
Do NOT launch production or development MessageLens.
Do NOT stage unrelated files, create fixtures, or perform a reset.

---

# 1. Exact repository baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream synchronized `0/0`;
- tracked worktree and index clean;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one active Feature 34 worktree.

Response 80 reports its qualification HEAD as:

`c736840c7b64591bfbac3c157087e14ba286f959`

Verify this is the actual starting HEAD or an ancestor; do not force the tree backward to match this document. Verify Local Data Repair implementation commit in ancestry:

`ceb12fef80b51c8cc340cca196d5e427419f084f`

Read Responses 40, 41, 51, 71, 78, 79 and 80; current AppCzar fact/evaluator/assessment and presentation packages; existing coordinator hosts; archive-admission and development-composition code; qualified restart/stopAndDrain implementations; current diagnostic/log/export utilities; and the canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Prompt 80 / Response 80 first

Prompt 80 made no source/test changes. Create a narrow Feature 34 documentation checkpoint containing **only** Prompt 80 and Response 80 unless already committed.

Record exactly:

```text
AppCzar Local Data Repair human live qualification: PASS

A: reconstructible live-only partial -> one reset -> physical postcondition
   -> real restart -> fresh AppCzar / Onboarding
B: missing current source fact -> no reset
C: protected historical/non-live data -> no reset
D: corrupt/unknown evidence -> virtual Diagnostic Review, no reset

first A attempt: source unreadable, no mutation; discarded
A replacement process: PID 81643 -> PID 82061
no observed zero-PID interval
Ball tenure: formally proven by automated tests; live log corroboration only
provider-close warning: observed; postcondition nevertheless passed
```

Do not claim that Diagnostic Review itself has been implemented or qualified. Do not include `/private/tmp` fixtures or observer logs in the repository checkpoint.

Push the documentation checkpoint normally before continuing with the audit. No force push, rebase, squash, or unrelated staging.

---

# 3. Reconfirm the exact execution census

Source-trace the explicit predicates and host branches. Require the five qualified top-level coordinators, one Operating Session, and virtual-only Diagnostic Review listed above.

There must be no generic virtual-coordinator dispatcher and no production AppCzar route. If the census differs, STOP AND REPORT.

---

# 4. Audit every current Diagnostic Review selection path

Produce an exhaustive, source-grounded table of current observations, derived TRUE/FALSE/UNKNOWN facts, descriptive disposition, and virtual coordinator result.

At minimum investigate:

1. Missing, unknown, or contradictory admitted-root-related evidence **after successful archive admission**;
2. Messages source readability UNKNOWN versus conclusively FALSE;
3. Source sample unstable or changing during coherent assessment;
4. Incomplete/contradictory import-and-graph evidence;
5. Unsupported, corrupt, or unreadable local database content;
6. Source/local lineage conflict or known missing current-source facts;
7. Protected historical/non-live source material in an unsafe partial dataset;
8. Retired derived artifacts with unproven safety;
9. Attachment coverage/actionability UNKNOWN or unsafe/conflicting;
10. Archive availability/binding/identity uncertainties;
11. A fact graph that cannot produce a unique supported top-level disposition;
12. Any other evaluator branch that selects the current virtual Diagnostic Review result.

For every class identify whether it actually chooses Diagnostic Review **today**. Do not route conclusive deficiencies away from Source Access Repair, Attachment Archive Repair, Local Data Repair, or another specialist merely to enlarge Diagnostic Review.

Also identify any state where the current evaluator returns a virtual *different* coordinator for a known, non-executable specialist action. Diagnostic Review must not silently absorb those jurisdictions.

---

# 5. Distinguish pre-AppCzar admission failure from Diagnostic Review

Prompts 73–76 established this important boundary:

```text
native/Dart archive admission fails
    -> pre-AppCzar admission error, not an AppCzar disposition

archive admission succeeds
    -> immutable ArchiveAccessAuthority exists
    -> AppCzar may assess and choose Diagnostic Review
```

Audit any error-handling code that could conflate them. Do not propose an AppCzar Diagnostic Review host that needs to exist before archive admission, or let it bypass admission to inspect persistent stores.

The official development-composition policy must remain root/UUID-independent after valid admission. The WD-specific attachment-adoption mutation gate remains narrower.

---

# 6. Define the Diagnostic Review jurisdiction precisely

Proposed governing contract:

> When fresh AppCzar cannot establish a uniquely actionable and safe disposition from current evidence, Diagnostic Review owns a **read-only human-attention jurisdiction**. It reports the evidence and uncertainty, offers only bounded diagnostic/user actions, and never transforms its own conclusions into permission for another coordinator.

It may:

- present the exact assessment that selected it;
- distinguish proven facts, known negative facts, contradictory observations, and UNKNOWN dependencies;
- explain in literal, non-causal language why normal use or an automatic repair cannot proceed;
- allow an explicit user-requested new *process* assessment;
- allow Quit;
- support safe, privacy-aware copying/exporting of already-observed diagnostic evidence if an existing service supports it.

It may NOT:

- select another coordinator;
- construct a parallel AppCzar evaluator;
- trigger reset, graph build, archive adoption, attachment repair or historical-source removal;
- acquire the Ball;
- run an automatic repair or background state-correction loop;
- infer a previous import was interrupted or permissions were revoked;
- persist a Diagnostic Review cursor or semantic verdict;
- declare the installation repaired or Operating.

Decide whether this requires a controller with memory-only lifetime state, or a minimal occurrence-bound screen/host with only user actions. Prefer fewer types and less state.

---

# 7. The Fair-Witness presentation contract

Audit the current `AppCzarAssessment` model and presentation mappers for reuse.

The screen should render the **same assessment evidence** that selected Diagnostic Review, not re-derive facts through a second readiness/report provider.

Required distinctions:

```text
TRUE      -> current fact established by evidence
FALSE     -> current negation established by evidence
UNKNOWN   -> current evidence insufficient/unavailable
CONFLICT  -> observations inconsistent or unstable
```

UNKNOWN is not FALSE. Contradictory observations are not an invented cause. Source `accessDenied` is not proof of the human-visible FDA toggle state. Protected historical data is not called lost, disposable, or corrupt unless separately proven.

Audit whether the assessment snapshot needs to display its observation time/generation so old factual copy does not misleadingly claim to be a continuously refreshed current reading.

No UI component may independently choose disposition from individual rows.

---

# 8. Human actions and process boundaries

Audit exact reuse of existing coordinator restarter, quit, and lifecycle conventions.

Preferred interactions:

```text
Review current assessment evidence

Try Assessment Again [explicit human action]
    -> close current Diagnostic Review occurrence
    -> stopAndDrain()
    -> real process restart
    -> fresh AppCzar reads the world

Quit
    -> ordinary drain and exit, no relaunch
```

If a diagnostic copy/export exists, it must not change jurisdiction and must never be interpreted as a repair. No implicit polling, auto-restart loop, in-process AppCzar rerun, or handoff to another host.

Determine how repeated identical UNKNOWN evidence remains stable until the human takes another action, avoiding an endless restart loop.

---

# 9. Diagnostic privacy and storage safety

Source-trace existing support report, logs, clipboard, and diagnostic export utilities. Prefer reuse rather than a new reporting framework.

If export is warranted, define:

- whether an explicit user-selected destination is available without relying on a writable or healthy MessageLens data store;
- bounded size and privacy filtering;
- exclusion of message bodies, attachment bytes, private contact fields, and unnecessary source identifiers;
- clear distinction between technical paths/identifiers and user-facing summary;
- failure behavior when destination creation is denied.

Do not auto-write a new diagnostic report into a corrupt, inaccessible, or unknown archive root. Do not silently copy private source data.

If no safe export seam exists, Stage One may offer only a bounded in-memory text copy or just display/retry/quit; report the tradeoff.

---

# 10. No destructive or ambient side effects

Audit the prospective coordinator composition for hidden provider construction, database opening, auto-initialization, attachment sweeps, graph monitors, or legacy Journey/Environment Readiness observers.

The goal is stronger than an absence of visible repair buttons:

```text
Diagnostic Review itself causes no MessageLens data mutation
```

Ordinary pre-existing process lock/log/appearance behavior should be described separately; do not claim absolute filesystem immutability when those mechanisms run before coordinator admission.

No `ArchiveMutationCoordinator`, `MessageDataResetService`, Start Fresh or generic worker should be reachable from Diagnostic Review.

---

# 11. Jurisdiction and lifetime model

Design the exact execution predicate for only:

`AppCzarVirtualCoordinator.diagnosticReview`

or the precise current equivalent.

The coordinator/host must:

- admit only one exact assessment generation and disposition;
- present that occurrence's immutable facts;
- prevent stale callbacks/actions after replacement or quit;
- use an awaitable `stopAndDrain()` where necessary;
- never execute another coordinator within the same process;
- never restart automatically merely because evidence is UNKNOWN;
- not acquire Ball tenure.

Preserve explicit AppCzar host branching; do not introduce a generic dispatcher.

---

# 12. Production and legacy isolation

Production must continue to use `StartupApp`, legacy Journey, and its existing presentation/action bridges until the separately approved cutover.

The exact-development AppCzar route must remain isolated from:

- Journey / Trip / Step / Episode;
- `OnboardingOverlay`;
- `OnboardingCenterPanelSyncObserver` and its controller;
- Environment Readiness semantic evaluators/actions;
- pipeline-incident semantic takeover;
- legacy completion handoffs.

Reuse factual widgets if helpful, not their old semantic providers.

---

# 13. Plan the smallest future implementation

Produce a source-grounded Stage One file/module plan, including:

1. exact Diagnostic Review predicate;
2. occurrence-bound host/controller only if necessary;
3. immutable assessment-to-presentation adapter;
4. literal diagnostic screen;
5. explicit fresh-process reassess and Quit actions;
6. optional safe export/copy seam where already supported;
7. architecture tripwires forbidding mutation and legacy authority;
8. production-isolation tests.

Do NOT implement in Prompt 81. The next prompt should be an independently reviewable implementation milestone followed by its own isolated human qualification.

---

# 14. Future automated test matrix

Design tests for at least:

1. every current Diagnostic Review disposition selects exactly one diagnostic host;
2. every non-diagnostic disposition fails the diagnostic execution predicate;
3. corrupt/unsupported import store is displayed as unsupported/unreadable, not resettable;
4. source-missing local fact is displayed as a known anti-difference, not merely UNKNOWN;
5. protected historical material remains explicitly protected;
6. unstable/contradictory source observations remain UNKNOWN/conflicting;
7. archive/actionability uncertainty fails closed;
8. no operating shell or other coordinator is mounted;
9. no Journey, Environment Readiness, panel sync, or old completion authority is mounted;
10. no Ball, reset, importer, projector, attachment writer, or historical-source removal can be reached;
11. no automatic polling/restart loop occurs;
12. user-requested reassessment drains and performs one genuine process restart;
13. normal Quit drains and does not relaunch;
14. stale actions after occurrence invalidation are inert;
15. copy/export redacts sensitive data and remains bounded, if implemented;
16. a repeated identical UNKNOWN result may stay visible without self-restarting;
17. production legacy startup remains unchanged;
18. existing five coordinators and Operating remain qualified by regressions.

All fixture tests must use temp stores and read-only providers, not the real development archive.

---

# 15. Future human qualification design

Use fresh disposable fixtures only. At minimum propose:

```text
A. corrupt/unsupported derived store
   -> Diagnostic Review
   -> literal reason
   -> no mutation

B. live-source provenance but required current source fact missing
   -> Diagnostic Review
   -> literal known mismatch
   -> no mutation

C. protected historical/non-live material
   -> Diagnostic Review when current evaluator so selects
   -> no mutation

D. UNKNOWN/unstable evidence
   -> Diagnostic Review
   -> no automatic restart loop
   -> explicit user-reassessment produces a real PID boundary
```

If any of these belongs to another existing disposition, explain the current source-grounded exception rather than force it into Diagnostic Review.

Never use the populated WD/Toshiba archives to qualify this milestone.

---

# 16. Project Conformance — audit only

Audit the proposed design against the canonical standard:

- one top-level jurisdiction/presentation authority;
- current evidence, not historical narrative;
- UNKNOWN not converted to FALSE;
- no parallel readiness classifier;
- no mutation-tenure acquisition;
- explicit restart rather than in-process handoff;
- no persisted diagnostic cursor;
- diagnostic/report privacy;
- no legacy presentation authority in AppCzar composition;
- production unchanged;
- reuse instead of another diagnostics subsystem.

Report `PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)` only if the design has no unresolved conceptual BLOCKER or SHOULD FIX finding. An audit PASS is **not** implementation certification.

---

# 17. No source changes, build, or live launch

This is audit-only. Do not modify production source/tests, generate code, update release metadata, build an app, or launch an app. Do not create or run fixtures. Leave Prompt 81 / Response 81 untracked for the next narrow documentation checkpoint unless repository convention requires otherwise.

If inspecting the current code reveals that Diagnostic Review cannot be implemented without another factual reader/authority correction, STOP AND REPORT the exact prerequisite seam instead of silently expanding scope.

---

# 18. Required Response 81

Create Response 81 and report:

1. baseline verification;
2. Prompt 80/Response 80 documentation checkpoint and push;
3. current execution census;
4. exhaustive Diagnostic Review disposition/frontier table;
5. known FALSE versus UNKNOWN versus conflict distinctions;
6. proven local-source anti-difference behavior;
7. protected historical/retired behavior;
8. corrupt/unsupported behavior;
9. attachment/archive uncertainty behavior;
10. pre-AppCzar archive-admission boundary;
11. immutable assessment-evidence reuse opportunity;
12. proposed Diagnostic Review jurisdiction and minimal state;
13. current snapshot/time/generation presentation semantics;
14. exact diagnostic screen and human actions;
15. fresh-restart contract;
16. no automatic retry/restart loop proof/design;
17. Quit and stopAndDrain design;
18. diagnostic copy/export availability and privacy policy;
19. hidden provider/ambient mutation audit;
20. absence of Ball/worker/reset authority;
21. legacy Journey/Environment isolation;
22. production startup preservation;
23. proposed source/test file inventory;
24. proposed architecture enforcement;
25. complete automated test matrix;
26. future isolated human qualification matrix;
27. audit implementation-feasibility verdict;
28. BLOCKER findings;
29. SHOULD FIX findings;
30. whether implementation proceeded (expected NO);
31. Project Conformance audit verdict;
32. any separately tracked provider-close warning/performance limitation from Response 80;
33. final Git/worktree/index/submodule state;
34. readiness for executable Diagnostic Review implementation;
35. readiness for Diagnostic Review human qualification;
36. readiness for whole-repository AppCzar production cutover audit.

Conclude exactly:

`LOCAL DATA REPAIR HUMAN LIVE QUALIFICATION CHECKPOINTED: YES / NO`

`DIAGNOSTIC REVIEW JURISDICTION IS SOURCE-GROUNDED: YES / NO`

`DIAGNOSTIC REVIEW CAN PRESENT UNKNOWN WITHOUT CLAIMING FALSE: YES / NO`

`DIAGNOSTIC REVIEW NEEDS NO MUTATION BALL: YES / NO`

`DIAGNOSTIC REVIEW CAN REQUEST FRESH ASSESSMENT ONLY ACROSS A REAL PROCESS BOUNDARY: YES / NO`

`DIAGNOSTIC REVIEW CAN REMAIN STABLE WITHOUT AN AUTOMATIC RESTART LOOP: YES / NO`

`EXECUTABLE APPCZAR DIAGNOSTIC REVIEW IMPLEMENTED: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL (AUDIT/DESIGN SCOPE)`

`READY FOR DIAGNOSTIC REVIEW IMPLEMENTATION: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
