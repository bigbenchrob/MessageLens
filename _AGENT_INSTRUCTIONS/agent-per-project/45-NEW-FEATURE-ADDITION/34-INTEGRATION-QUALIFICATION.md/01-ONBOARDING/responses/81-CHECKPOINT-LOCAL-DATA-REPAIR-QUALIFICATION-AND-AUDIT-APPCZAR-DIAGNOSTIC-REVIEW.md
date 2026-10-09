# Response 81 — Checkpoint Local Data Repair Qualification and Audit AppCzar Diagnostic Review

Date: 2026-10-09

This response records the Prompt 80/Response 80 documentation checkpoint and
the read-only source audit/design requested by Prompt 81. No production source,
test, generated, release-metadata, build, fixture, database, or archive change
was made during the audit.

## 1. Baseline verification

The pre-checkpoint baseline satisfied the prompt:

- primary worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- starting HEAD and upstream:
  `c736840c7b64591bfbac3c157087e14ba286f959`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Feature 34 worktrees: exactly one (the primary worktree); the other three
  registered worktrees are for Feature 35, `main`, and an unrelated Gradle
  branch;
- Response 80's reported qualification HEAD was the actual starting HEAD;
- Local Data Repair implementation commit
  `ceb12fef80b51c8cc340cca196d5e427419f084f` was in ancestry;
- only the 49 already-known untracked leaf paths were present.

A fresh external baseline manifest was written outside the repository at:

`/private/tmp/messagelens-prompt81-baseline-c736840c.txt`

Its SHA-256 is
`f40221af73ad443478c4cbb3c8b881fac7ef8e203b194050ad93ccfc54d6627f`.
It records the baseline status digest and the Prompt 80, Response 80, and
Prompt 81 hashes. No fixture or observer output was added to the repository.

The required prior records (Responses 40, 41, 51, 71, 78, 79, and 80), current
AppCzar packages, coordinator hosts, archive admission/composition policies,
restart/drain seams, diagnostic/export utilities, and Project Conformance
standard were inspected.

## 2. Prompt 80/Response 80 documentation checkpoint and push

Only these two files were staged:

- `01-ONBOARDING/prompts/80-ISOLATED-APPCZAR-LOCAL-DATA-REPAIR-HUMAN-QUALIFICATION.md`;
- `01-ONBOARDING/responses/80-ISOLATED-APPCZAR-LOCAL-DATA-REPAIR-HUMAN-QUALIFICATION.md`.

`git diff --cached --check` passed. The documentation checkpoint is:

`fd24d92508e85712ba051bab2c7a012ccd7c3266`

with message:

`docs(app-czar): record local data repair qualification`

It was pushed normally to
`origin/fix/onboarding-import-stuck-state`; local and upstream are synchronized
at `0/0`. No force push, rebase, squash, or unrelated staging occurred.

The checkpoint preserves the qualified result literally:

- A: reconstructible live-only partial -> one reset -> physical postcondition
  -> real restart -> fresh AppCzar/Onboarding;
- B: missing current source fact -> no reset;
- C: protected historical/non-live data -> no reset;
- D: corrupt/unknown evidence -> virtual Diagnostic Review, no reset;
- the first A attempt had unreadable source evidence, did not mutate, and was
  discarded;
- replacement boundary observed as PID `81643` -> PID `82061`;
- no zero-PID interval was observed;
- Ball tenure is formally proven by automated tests and only corroborated by
  the live log;
- a provider-close warning was observed although the physical reset
  postcondition passed.

The checkpoint does not claim that Diagnostic Review is executable or human
qualified.

## 3. Current execution census

The source census matches the required census exactly:

| AppCzar disposition | Current execution category | Exact execution edge |
|---|---|---|
| Data Update | Executable top-level coordinator | `shouldExecuteAppCzarDataUpdate` plus explicit host branch |
| Source Access Repair | Executable top-level coordinator | `shouldExecuteAppCzarSourceAccessRepair` plus explicit host branch |
| Attachment Archive Repair | Executable top-level coordinator | `shouldExecuteAppCzarAttachmentArchiveRepair` plus explicit host branch |
| Onboarding | Executable top-level coordinator | `shouldExecuteAppCzarOnboarding` plus explicit lifecycle host |
| Local Data Repair | Executable top-level coordinator | `shouldExecuteAppCzarLocalDataRepair` plus explicit lifecycle host |
| Operating Session | Executable admitted session | `shouldExecuteAppCzarOperatingSession` plus admitted-session host |
| Diagnostic Review | Virtual only | no predicate/controller/host; falls through to `AppCzarAssessmentScreen` |

`AppCzarStartupHarness` contains explicit branches, not a generic
`execute(AppCzarVirtualCoordinator)` or switch-based dispatcher. The
architecture census test currently requires five executable top-level
coordinators, one executable admitted session, and virtual-only Diagnostic
Review. Production is not routed through AppCzar: `main.dart` chooses the
AppCzar harness only after archive admission and only when
`AppCzarDevelopmentCompositionPolicy` recognizes the official development
identity; otherwise it constructs `StartupApp`.

No census stop gate was encountered.

## 4. Exhaustive Diagnostic Review disposition/frontier table

The table below follows `_select()` in evaluator order. “Facts” lists the
material derived truth; the literal observation remains part of the immutable
assessment state. Each row that says Diagnostic selects
`AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence` and
`AppCzarVirtualCoordinator.diagnosticReview` today.

| # | Current observation/frontier | Material fact result | Current disposition | Current coordinator |
|---:|---|---|---|---|
| 1 | Post-admission root observation reports not admitted or its bounded read throws and is converted to `admitted: false` | `developmentRootAdmitted = FALSE` | Development data root is not currently admitted | Diagnostic Review |
| 2 | Initial-construction scope cannot be established | `initialConstructionScopeSafe = UNKNOWN` | Physical evidence does not establish construction scope | Diagnostic Review |
| 3 | Initial scope contains retired or unsupported material | `initialConstructionScopeSafe = FALSE` | Protected/retired/unsupported data needs separate review | Diagnostic Review |
| 4 | Initial scope is unhealthy | `initialConstructionScopeSafe = FALSE` | Unhealthy local evidence needs separate review | Diagnostic Review |
| 5 | Import, graph, or overlay observation is `unhealthy` | affected health fact `FALSE`; local completeness may also be `FALSE` | Current store is unhealthy and cannot be reset automatically | Diagnostic Review |
| 6 | Import, graph, or overlay observation is `unknown` | affected health fact `UNKNOWN`; local completeness may be `UNKNOWN` | Current store could not be inspected | Diagnostic Review |
| 7 | Archive observation is `unknown` | `attachmentArchiveAvailable = UNKNOWN` | Configured archive could not be assessed | Diagnostic Review |
| 8 | Safe-empty scope has no complete authentic archive binding | archive availability may be `TRUE`, but binding is incoherent/incomplete and coverage/actionability cannot be trusted | Archive identity/configuration not coherently bound | Diagnostic Review |
| 9 | Safe-empty scope has Contacts `notRequiredForCurrentScope`, `invalidOrCorrupt`, or `unknown` | Contacts fact is respectively `TRUE`, `FALSE`, or `UNKNOWN`, while the literal scope observation proves it is not an admissible construction prerequisite | Contacts evidence is invalid, conflicting, or inconclusive | Diagnostic Review |
| 10 | Safe-empty scope has source readability `UNKNOWN` | `messagesSourceReadable = UNKNOWN` | Readability is not established | Diagnostic Review |
| 11 | Safe-empty source is readable but its bounded two-sample result is `FALSE` or `UNKNOWN` | `messagesSourceReadable = TRUE`; `sourceSampleStable != TRUE` | Source did not settle into one stable sample | Diagnostic Review |
| 12 | Consequential or protected/non-live partial local data is incomplete and exact Local Data Repair safety is `FALSE` or `UNKNOWN` | `localDatasetComplete != TRUE`; `localDataRepairMayResetDerivedStores != TRUE` | Partial data is protected, unsupported, or not proven reconstructible | Diagnostic Review |
| 13 | Outside safe-empty handling, source readability is `UNKNOWN` | `messagesSourceReadable = UNKNOWN` | Readability is not established | Diagnostic Review |
| 14 | Outside safe-empty handling, source sample is unstable or absent | `sourceSampleStable = FALSE` or `UNKNOWN` | Source did not settle into one stable sample | Diagnostic Review |
| 15 | Local import/graph evidence is inspected but does not establish one complete dataset | `localDatasetComplete = FALSE` | No proven complete local dataset | Diagnostic Review |
| 16 | Attachment coverage is unknown, including incoherent coverage binding | `attachmentCoverageComplete = UNKNOWN` | Complete required coverage is not established | Diagnostic Review |
| 17 | Current attachment repair opportunity is unknown, including incoherent repairability binding | `attachmentRepairOpportunityPresent = UNKNOWN` | Uncovered evidence is unknown or conflicting | Diagnostic Review |
| 18 | Coverage is incomplete, no specialist repair is currently selected, and repairability is not Operating-safe because evidence is unknown, record-conflicting, or otherwise unsafe | coverage `FALSE`; repair opportunity may be `FALSE`; `isOperatingSafe = false` | Incomplete coverage is not safe for Operating admission | Diagnostic Review |
| 19 | Coverage says complete while current repairability evidence is not Operating-safe | coverage `TRUE`; repairability observation conflicts with that conclusion | Complete coverage contradicts repairability evidence | Diagnostic Review |
| 20 | Later prerequisite conjunction cannot prove both local completeness and source/local delta comparability | `localDatasetComplete != TRUE` or `sourceLocalDeltaKnown != TRUE` | Evidence is insufficient to choose a safe action | Diagnostic Review |
| 21 | Source count/high-water is behind a complete local live-import count/high-water | delta prerequisites `TRUE`, but `sourceAheadOfLocal = UNKNOWN` with literal anti-direction detail | Current source and local evidence contradict | Diagnostic Review |
| 22 | Late archive-binding check lacks one complete authentic location binding | archive may be available and prior coverage facts known, but `hasCompleteArchiveBinding = false` | Authentic archive binding not established | Diagnostic Review |

Reader exceptions do not create additional semantic branches: the assessment
controller catches them and turns the relevant observation into typed UNKNOWN
(or, for the root probe, `admitted: false`), after which the table above
applies. The evaluator is deterministic; there is no unresolved multi-result
dispatcher. The “insufficient to choose” branch is the final explicit failure
of the required conjunction, not an arbitrary fallback to another authority.

Conclusive deficiencies correctly remain outside Diagnostic Review:

- archive availability `FALSE` -> Attachment Archive Repair;
- safe-empty, coherently bound scope with admissible Contacts and settled source
  evidence -> Onboarding (including its own bounded human prerequisite work);
- exact reconstructible live-only partial proof -> Local Data Repair;
- non-safe-empty source readability `FALSE` -> Source Access Repair;
- incomplete coverage with available current work or record-backed recovery ->
  Attachment Archive Repair;
- source ahead `TRUE` -> Data Update;
- all Operating predicates proven, including known source-absent attachment
  debt with no actionable/uncertain repair evidence -> Operating Session.

There is no other virtual, non-executable specialist action today. Diagnostic
Review is the only virtual-only disposition; the five named specialists and
Operating all have explicit execution edges.

## 5. Known FALSE versus UNKNOWN versus conflict distinctions

The domain truth is deliberately three-valued:
`TRUE`, `FALSE`, and `UNKNOWN`. It does not contain a fourth semantic truth
named `CONFLICT`. Conflict is a presentation characterization of literal
observations which are inconsistent or unstable; it must not become another
evaluator.

- `FALSE` means the negation was established: examples are an unavailable
  source, incomplete local dataset, incomplete attachment coverage, or an
  exact Local Data Repair safety condition that does not authorize reset.
- `UNKNOWN` means the required evidence was unavailable or insufficient:
  examples are a reader exception, an uninspectable store, missing coherent
  binding, or an unestablished delta.
- `CONFLICT` may be shown only when the frozen observations literally prove a
  conflict: a bounded source sample changed, source count/high-water points
  behind local evidence, coverage contradicts repairability, an archive binding
  is incoherent, or unsafe/conflicting attachment counts are nonzero.

The future presentation adapter should extend the existing pure
`AppCzarPresentationProjector`; it may add a display-only conflict badge from
those already-recorded literal observations. It must not change
`AppCzarTruth`, recalculate readiness, or select a coordinator. Generic
UNKNOWN remains “insufficient/unavailable,” not “FALSE” or “conflict.” An
`accessDenied` source condition remains only a failed read-only source check;
it is not proof that the visible Full Disk Access toggle is off.

## 6. Proven local-source anti-difference behavior

Two distinct source-grounded cases already reach Diagnostic Review without
being diluted into generic permission narrative:

1. `AppCzarLocalDataRepairSafetyCondition.sourceFactMissing` maps
   `localDataRepairMayResetDerivedStores` to `FALSE`. In a partial consequential
   dataset it therefore cannot acquire Local Data Repair and selects Diagnostic
   Review. This is a known negative reconstruction-safety result, not UNKNOWN.
2. When source and local delta prerequisites are otherwise established but the
   current source count or high-water is lower than the local live-import
   value, `_sourceAheadFact` returns `UNKNOWN` with the literal two value pairs
   and `_select()` describes them as contradictory. It does not call the source
   “behind because an import was interrupted,” delete local data, or force Data
   Update.

The Diagnostic screen should display the existing safety fact and literal
counts/high-water evidence. It must not convert either case into a causal story
or merely say “something is unknown.”

## 7. Protected historical/retired behavior

- `protectedNonLiveData` plus an incomplete local dataset cannot satisfy the
  exact live-only reconstruction proof; it selects Diagnostic Review and
  retains `localDataRepairMayResetDerivedStores = FALSE`.
- `protectedMaterialPresent` from the Local Data Repair safety reader likewise
  selects Diagnostic Review through the partial-data frontier.
- `retiredOrUnsupportedMaterial` in the initial-scope observation is caught
  before any repair specialist and selects Diagnostic Review.
- `retiredArtifactsPresent` in the detailed Local Data Repair safety taxonomy
  cannot authorize reset.

The presentation must say that this material is protected, retired,
unsupported, or requires separate review exactly as observed. It must not call
the material lost, corrupt, disposable, or safe to rebuild unless another
independent fact proves that narrower statement. No historical-source removal
action belongs to this jurisdiction.

## 8. Corrupt/unsupported behavior

Unhealthy import/graph/overlay inspection, an unsupported schema, corrupt
content, or `AppCzarLocalDataRepairSafetyCondition.unsupportedOrCorrupt`
selects Diagnostic Review. A bounded SQLite failure such as “file is not a
database” remains literal inspection evidence. It is not reframed as an empty
store and never becomes reset authorization.

The screen should identify the affected store and show its bounded failure
text using a privacy-reviewed technical-details disclosure. User-facing copy
should be “could not be read/unsupported” rather than “resettable.” Diagnostic
Review has no action that opens or rewrites the store.

## 9. Attachment/archive uncertainty behavior

The existing frontier correctly separates availability, coverage, and current
repair opportunity:

- archive unavailable (`FALSE`) is conclusive specialist work and stays
  Attachment Archive Repair;
- archive availability `UNKNOWN` is Diagnostic Review;
- coverage binding or repairability binding incoherent -> corresponding fact
  `UNKNOWN` -> Diagnostic Review;
- coverage `FALSE` with available source payloads or record-backed recovery ->
  Attachment Archive Repair;
- coverage `FALSE` with conclusive source-absent debt and no unknown/conflict ->
  Operating Session with known debt;
- coverage `FALSE` with unknown/conflicting/unsafe repair evidence -> Diagnostic
  Review;
- coverage `TRUE` contradicting unsafe repairability -> Diagnostic Review;
- missing complete authentic archive location binding -> Diagnostic Review.

Diagnostic Review reports these frozen facts. It does not run an attachment
sweep, preserve a payload, adopt a location, infer a waiver, or turn historical
debt into complete coverage.

## 10. Pre-AppCzar archive-admission boundary

The boundary remains:

```text
native/Dart archive admission failure
    -> pre-AppCzar admission error

successful archive admission
    -> immutable ArchiveAccessAuthority
    -> official development-composition policy
    -> AppCzar observation/evaluation
    -> possible Diagnostic Review
```

`main.dart` obtains the admitted authority before constructing the provider
container and AppCzar composition. The development-composition policy rejects
null authority and then checks official development environment/build/bundle/
product identity. It does not use the physical root or UUID to select the
semantic architecture. The WD root/UUID adoption mutation gate remains a
separate, narrower operation-specific authority.

The post-admission `developmentRootAdmitted = FALSE` branch is a current
observation disagreement or inspection failure inside an already admitted
process. Diagnostic Review may report it but cannot retroactively admit a
root, bypass native/Dart admission, or open persistent stores before admission.
No Diagnostic host is proposed outside the admitted AppCzar composition.

## 11. Immutable assessment-evidence reuse opportunity

`AppCzarAssessmentController` reads each bounded observation for one generation,
creates one `AppCzarObservationSet`, evaluates it once, and stores the resulting
`AppCzarAssessment` in `AppCzarAssessmentState`. Facts are final and the fact
list is unmodifiable. The current presentation projector is pure and does not
invoke the evaluator.

The future Diagnostic occurrence should capture that completed
`AppCzarAssessmentState`—generation, observations, and selected assessment—by
identity. Its screen should project only that frozen occurrence. It must not
watch Environment Readiness, run a second database report, call a fact reader,
or invoke `AppCzarEvaluator` again. This prevents two answers to “what state
are we in?” and avoids duplicate source/archive scans.

## 12. Proposed Diagnostic Review jurisdiction and minimal state

The exact predicate should be a named, directly tested function:

```text
assessment exists
AND assessment.virtualCoordinator == diagnosticReview
AND the completed assessment generation is captured
```

No broad diagnosis-kind match and no switch over all coordinators is needed.

A small occurrence-bound controller is justified because two user actions must
be single-flight, stale callbacks must become inert, and exit/restart must be
drainable. Its memory-only state needs only:

- immutable occurrence identity;
- captured assessment generation and completed assessment state;
- phase: `presenting`, `draining`, `restartFailed`, or `quitRequested`;
- optional literal action error;
- accepting-actions flag/active action future held privately.

It must not persist a cursor, semantic verdict, prior outcome, permission state,
or repair history. It does not own facts; AppCzar's captured assessment remains
the sole semantic authority. It owns only the lifetime of the visible
Diagnostic occurrence and its user-requested lifecycle actions.

The coordinator host should watch this Diagnostic controller first. If it is
visible, it must return the explicit Diagnostic lifecycle host before
constructing any repair/Onboarding/Operating controller provider. Existing
explicit branches remain unchanged for non-diagnostic dispositions. This
avoids ambient specialist construction without introducing a generic
dispatcher.

## 13. Current snapshot/time/generation presentation semantics

Current `AppCzarAssessmentState` has a process-local integer `generation`, but
the generic assessment screen does not display it or an observation time. It
also offers an in-process `runAgain()`. Consequently, a completed screen can
look continuously current even though it is one bounded generation.

The future Diagnostic occurrence should display:

- “Assessment generation N”;
- a capture/completion time recorded once when the completed state is admitted
  to the occurrence (with an injected clock for deterministic tests);
- “This is a bounded snapshot from this process; it is not continuously
  refreshed.”

The timestamp is presentation/lifetime metadata, not a new environmental fact,
and must not claim that concurrent sub-reads happened at one instant. The
occurrence identity, generation, and captured state are compared on every
action so an action from a replaced occurrence is inert. No durable generation
or cross-process history is needed.

## 14. Exact diagnostic screen and human actions

The Stage One screen should contain:

1. title: “MessageLens needs a diagnostic review”;
2. literal assessment diagnosis and “Normal use or automatic repair cannot be
   selected from this bounded evidence”;
3. generation/capture disclosure described above;
4. summary rows projected from the frozen assessment, visibly distinguishing
   established TRUE, established FALSE, insufficient UNKNOWN, and literal
   conflict/instability;
5. an expandable technical-evidence section using the same frozen rows;
6. **Try Assessment Again**;
7. **Quit**;
8. an inline action failure if restart could not be scheduled.

It should not show repair, reset, build, archive-adoption, preserve,
historical-removal, or “Continue” actions. It must not mount the Operating
shell. Stage One should omit copy/export because no currently qualified,
AppCzar-isolated privacy seam exists (Section 18).

## 15. Fresh-restart contract

**Try Assessment Again** must:

```text
validate exact current occurrence
-> stop accepting callbacks/actions
-> stopAndDrain()
-> call the existing qualified AppCzarProcessRestarter once
-> current process exits
-> detached relaunch occurs after the old PID exits
-> fresh process performs archive admission and AppCzar assessment
```

It must not call `AppCzarAssessmentController.runAgain()`, read a source fact
directly, or hand off to another coordinator in the current process. The
existing restarter is already guarded by
`AppCzarDevelopmentCompositionPolicy`, derives the current `.app`, launches a
detached open-after-PID-exit script, and terminates the current process. The
Diagnostic controller should reuse it rather than add process mechanics.

If scheduling the restart fails before termination, the occurrence remains in
Diagnostic Review, publishes the literal failure, and may re-enable explicit
actions only after the flight has settled. It does not infer a new disposition.

## 16. No automatic retry/restart loop proof/design

The Diagnostic package should contain no `Timer`, `Timer.periodic`, stream
subscription, source monitor, retry counter, microtask assessment loop, or
automatic restarter call. Initial AppCzar assessment runs once because the
existing keep-alive assessment controller is constructed; Diagnostic then
freezes its selected generation.

Repeated identical UNKNOWN evidence therefore remains visible indefinitely.
Only a user press on **Try Assessment Again** causes one restart. If the new
process reaches the same result, it displays a new occurrence and waits again;
it does not remember an intent to retry or self-restart.

Architecture tests should reject timer/polling APIs and verify no restart call
occurs after pump/settle until the button is pressed.

## 17. Quit and stopAndDrain design

The Diagnostic lifecycle host should follow the qualified host convention:

- install `AppLifecycleListener` for ordinary macOS quit/window-close;
- on exit request, invalidate the exact occurrence, await its
  `stopAndDrain()`, and permit the ordinary exit;
- inject an `onQuitRequested` callback into the screen; the callback requests
  the standard Flutter application exit so it traverses the same listener;
- do not invoke the process restarter for Quit.

`stopAndDrain()` prevents new actions, marks stale callbacks inert, and awaits
the one active lifecycle action if present. Diagnostic owns no worker or I/O
flight, so there is otherwise nothing to cancel. The restart button invalidates
and drains its occurrence before invoking the existing restarter; the restarter
does not return after a successful termination.

No new general process-lifecycle framework or duplicate `dart:io` terminator is
needed.

## 18. Diagnostic copy/export availability and privacy policy

The existing support/log exporter is not safe for direct AppCzar Diagnostic
reuse: it constructs legacy onboarding operation/telemetry dependencies. Using
it would violate legacy-authority isolation and could create ambient work. The
Environment Summary clipboard behavior is feature-private rather than a
qualified general diagnostic seam.

Therefore Stage One should provide display/restart/quit only. This is the
narrowest safe choice and works even if every MessageLens store is corrupt or
unwritable.

If a later milestone adds copy/export, it requires a separately reviewed
in-memory formatter and an explicit user destination or clipboard action. Its
contract must:

- serialize only the already-frozen assessment;
- bound row/detail/path lengths and total bytes;
- exclude message bodies, attachment bytes, contact fields, source SQL, and
  unnecessary identifiers;
- label technical paths/UUIDs separately and redact them by default;
- perform no automatic write and never target the archive/data root;
- treat denied clipboard/destination creation as a displayed action failure,
  not a jurisdiction change or repair result.

## 19. Hidden provider/ambient mutation audit

The proposed Diagnostic host needs only the completed AppCzar assessment,
Diagnostic occurrence controller, themes, and the existing restarter read on
an explicit action. Placing its branch first means it does not construct Local
Data Repair, Data Update, Onboarding, Source Access, Attachment Repair, or
Operating controllers while Diagnostic is visible.

It must not watch/import:

- Journey, Environment Readiness, Onboarding overlay/panel sync, or pipeline
  incident providers;
- database providers or AppCzar observation readers;
- attachment coverage/repair readers;
- graph/source monitors;
- support-bundle exporter or legacy operation snapshot;
- generic worker/executor providers.

The initial AppCzar assessment necessarily performed bounded read-only probes
before Diagnostic selection. Ordinary application lock/log/appearance setup may
also have occurred before coordinator admission. Those are pre-existing process
behaviors and prevent a claim of absolute filesystem immutability. The narrower
and provable claim is: Diagnostic Review itself causes no MessageLens data
mutation or new evidence read.

## 20. Absence of Ball/worker/reset authority

Diagnostic Review requires no mutation Ball. Its package must not import or
name:

- `ArchiveMutationCoordinator`, `ArchiveMutationCapability`,
  `ArchiveMutationOperation`, or `runWithCapability`;
- `MessageDataResetService`, Advanced Start Fresh, or reset methods;
- graph builders, import/project workers, attachment writers, archive adoption,
  or historical-source removal;
- any executable specialist controller/executor.

The only side-effecting seams are the existing process restarter after an
explicit user request and the ordinary application-exit request. Neither
changes MessageLens data or conveys semantic authority. Tests should prove
zero mutation-admission edges in the Diagnostic package.

## 21. Legacy Journey/Environment isolation

The Diagnostic package and host must have no dependency on Journey/Trip/Step/
Episode, `StartupApp`, `OnboardingOverlay`,
`OnboardingCenterPanelSyncObserver`, Environment Readiness evaluators/actions,
pipeline incidents, legacy completion handoffs, or operation snapshots.

It may reuse neutral theme/layout primitives. It may not reuse factual widgets
that internally watch old semantic providers. The assessment and pure projector
are the only source of visible semantic state.

## 22. Production startup preservation

No Prompt 81 source change occurred. Production continues through
`StartupApp` and the legacy Journey presentation/action bridges. The future
Diagnostic implementation must stay reachable only inside the already-admitted
official MessageLens Development AppCzar composition. It must not change
`selectMessageLensStartupPresentation`, production bundle behavior, or the
WD-specific attachment-adoption mutation gate.

Production AppCzar cutover remains a separate whole-repository audit and
approval milestone.

## 23. Proposed source/test file inventory

Smallest Stage One change set:

**New production files**

- `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart`
  — exact predicate, immutable occurrence capture, memory-only action state,
  restart action, stale-action invalidation, and `stopAndDrain()`;
- generated provider companion produced by Riverpod code generation;
- `lib/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart`
  — literal snapshot UI with injected restart/quit actions.

**Existing production files changed**

- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` — add
  the explicit first Diagnostic branch and lifecycle host; remove the generic
  in-process **Run assessment again** action from the Diagnostic route while
  retaining the generic assessment screen where still appropriate;
- `lib/essentials/app_czar/application/app_czar_presentation_projector.dart` —
  add a pure Diagnostic projection from the captured state, including literal
  conflict classification; no fact selection/evaluator call;
- `lib/essentials/app_czar/domain/app_czar_models.dart` and
  `lib/essentials/app_czar/application/app_czar_assessment_provider.dart` only
  if implementation uses a clock-stamped completion field. Prefer keeping the
  timestamp in the occurrence controller so evaluator/fact semantics remain
  unchanged.

No new database reader, exporter, mutation executor, process restarter, or
generic dispatcher is proposed.

**New/updated tests**

- `test/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller_test.dart`;
- `test/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen_test.dart`;
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`;
- `test/architecture/app_czar_architecture_test.dart`;
- `test/architecture/forbidden_imports_test.dart` if its package allowlists
  require the explicit new boundary;
- existing evaluator, five coordinator, Operating, main/startup-selection, and
  production-composition regression tests.

## 24. Proposed architecture enforcement

Add mechanical tests that:

1. classify Diagnostic Review as executable top-level and update the census to
   six top-level coordinators plus one Operating session;
2. require exactly one `shouldExecuteAppCzarDiagnosticReview` definition and
   exact equality to `AppCzarVirtualCoordinator.diagnosticReview`;
3. require the coordinator host's explicit Diagnostic branch and prohibit a
   generic coordinator dispatcher/switch;
4. forbid Diagnostic imports of mutation, reset, worker, database, source
   reader, attachment writer, historical removal, Journey, Environment
   Readiness, navigation/panel sync, and operation-snapshot packages;
5. reject `.runWithCapability`, `ArchiveMutationOperation`, Ball types,
   `MessageDataResetService`, `Timer`, `Timer.periodic`, and persisted settings
   in every Diagnostic file;
6. require reuse of `appCzarProcessRestarterProvider` only in the controller and
   forbid `dart:io`, `Process.start`, and `exit()` in the Diagnostic package;
7. require the projector to remain independent of `AppCzarEvaluator` and the
   screen to contain no `AppCzarTruth`/selection logic;
8. require Diagnostic to be the first host return, before specialist provider
   watches;
9. prove production composition imports no Diagnostic package and still selects
   legacy startup;
10. retain all existing mutation-edge counts for the five specialists and
    Operating.

## 25. Complete automated test matrix

Future implementation qualification must cover:

1. every evaluator branch listed in Section 4 that returns Diagnostic mounts
   exactly one Diagnostic host;
2. every non-diagnostic virtual coordinator fails the Diagnostic execution
   predicate;
3. corrupt/unsupported import is rendered literally and never described as
   resettable;
4. `sourceFactMissing` is rendered as a known reconstruction-safety FALSE, not
   generic UNKNOWN;
5. protected historical/non-live material stays explicitly protected;
6. retired artifacts stay non-resettable;
7. source readability UNKNOWN stays UNKNOWN while source readability FALSE is
   not absorbed from Source Access Repair outside safe-empty Onboarding scope;
8. unstable source sampling is shown as conflict/instability without a causal
   claim;
9. source/local count/high-water anti-direction shows both literal sides and no
   Data Update;
10. archive availability UNKNOWN fails closed;
11. coverage/binding/actionability UNKNOWN fails closed;
12. complete-coverage/repairability contradiction is displayed as conflict;
13. actionable attachment work remains Attachment Archive Repair, not
    Diagnostic;
14. known source-absent debt remains Operating-safe only under the existing
    complete conjunction;
15. no Operating shell or other coordinator is mounted for a Diagnostic
    occurrence;
16. no Journey, Environment Readiness, panel sync, old completion, or support
    exporter authority is constructed;
17. no Ball, reset, importer, projector worker, attachment writer, archive
    adoption, or historical-source removal is reachable;
18. no automatic polling, reassessment, or restart occurs while time advances;
19. repeated identical UNKNOWN remains visible and stable;
20. **Try Assessment Again** invalidates the occurrence, drains, and invokes
    exactly one genuine process-restarter call;
21. restart scheduling failure stays Diagnostic and is literal;
22. **Quit** drains and requests ordinary exit without restarter/relaunch;
23. OS quit/window close follows the same drain path;
24. stale restart/quit callbacks after invalidation are inert;
25. double-click/reentrant actions remain single-flight;
26. frozen presentation does not change if an unrelated provider changes;
27. generation/capture metadata is stable for the occurrence;
28. copy/export is absent in Stage One; if later added, bounded redaction and
    failure tests are mandatory;
29. production legacy startup selection is unchanged;
30. the five existing top-level coordinators and Operating pass all regression
    suites;
31. full analyzer, architecture suite, targeted suite, and full Flutter suite
    pass;
32. every fixture/provider test uses temporary read-only evidence and no real
    development archive.

## 26. Future isolated human qualification matrix

Use newly generated disposable `/private/tmp` fixtures and the exact built
development artifact only. Pre/post hashes and counts must be captured outside
the repository. Never use WD or Toshiba.

| Experiment | Fixture/evidence | Expected visible result | Required safety witness |
|---|---|---|---|
| A | Corrupt or unsupported derived import store | Diagnostic Review; affected store and literal bounded read failure | Fixture hash/count unchanged; no reset/worker/Ball log |
| B | Live-provenance partial with required current-source reconstruction fact missing | Diagnostic Review; explicit known safety mismatch/FALSE | Import/marker/root unchanged; no Local Data Repair |
| C | Protected historical/non-live material in a partial dataset | Diagnostic Review under current evaluator | Protected rows/files and marker unchanged; no historical removal |
| D | UNKNOWN source/read failure | Diagnostic Review; UNKNOWN, not FALSE/FDA-toggle assertion | Stable visible occurrence for an observation interval; no self-restart |
| E | Bounded source samples disagree or source/local high-water anti-direction | Diagnostic Review; literal conflict | No Data Update/reset; fixture unchanged |
| F | Archive/coverage/actionability binding uncertainty using a disposable archive | Diagnostic Review; literal archive uncertainty | No archive writes/adoption/repair |

For D, after the stable no-loop observation, press **Try Assessment Again**
once and observe old PID replacement by a fresh PID. Do not claim a zero-PID
interval unless actually sampled. If the same UNKNOWN returns, the new process
must remain stable and wait. Press **Quit** in a separate run and prove no
replacement process appears within a bounded observer interval.

Conclusive source access failure outside the safe-empty construction scope
belongs to Source Access Repair, actionable uncovered attachments belong to
Attachment Archive Repair, and an exact live-only reconstructible partial
belongs to Local Data Repair; do not force those fixtures into Diagnostic.

## 27. Audit implementation-feasibility verdict

**Feasible without another factual reader or authority correction.** The
current assessment already retains the observations and derived facts needed to
explain every Diagnostic selection. The evaluator is singular and
deterministic, the virtual disposition is explicit, the qualified restarter is
available, and lifecycle-host drain conventions already exist.

The implementation is a bounded presentation/lifetime milestone, not a new
readiness system. No evaluator semantic change is required by this audit.

## 28. BLOCKER findings

**None.** No source finding requires a prerequisite authority or factual-reader
correction before implementing the design. If implementation discovers that a
row cannot be explained without a new data read, it must stop rather than add a
second classifier; that stop gate was not reached in this audit.

## 29. SHOULD FIX findings

**None unresolved in the audit/design scope.** The current virtual-only screen's
in-process **Run assessment again**, lack of occurrence generation/time copy,
and generic fallthrough are precisely the scoped future implementation work,
not accepted residual design defects. The approved design replaces them for
Diagnostic Review with a real restart, frozen occurrence, and explicit host.

## 30. Whether implementation proceeded

**NO.** Prompt 81 made no Diagnostic implementation, production source, test,
generated, metadata, build, fixture, or launch change. Diagnostic Review
remains virtual only at this checkpoint. This response and Prompt 81 remain
untracked for the next narrow documentation checkpoint.

## 31. Project Conformance audit verdict

**PASS (AUDIT/DESIGN SCOPE).** The proposed design has:

- one top-level semantic authority: the captured AppCzar assessment;
- current bounded evidence, not historical narrative;
- UNKNOWN distinct from FALSE and conflict limited to literal evidence;
- no parallel readiness classifier or second evaluator;
- no mutation tenure/Ball;
- a real process boundary for fresh assessment;
- no persisted cursor, automatic loop, or same-process handoff;
- no unsafe diagnostic export in Stage One;
- no legacy authority in the AppCzar Diagnostic composition;
- production startup unchanged;
- reuse of the qualified restarter/projector/lifecycle patterns rather than a
  new diagnostics framework.

This PASS is a design audit only, not implementation or live-qualification
certification.

## 32. Separately tracked Response 80 warning/performance limitation

Response 80's provider-close warning remains separately tracked. The qualified
physical reset postcondition passed despite that warning; Prompt 81 neither
reproduced nor corrected it. The PID observation also remains limited: PID
`81643` was replaced by PID `82061`, but no zero-PID interval was captured.

Diagnostic presentation must reuse the completed assessment rather than repeat
expensive source/archive/attachment reads. The current assessment itself may
include bounded source sampling and attachment evidence work; Prompt 81 ran no
performance test. Removing in-process Diagnostic `runAgain()` prevents
unbounded user-interface reruns inside one process, while explicit restart
still intentionally pays for one fresh assessment.

## 33. Final Git/worktree/index/submodule state

After the documentation checkpoint and this audit record:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `fd24d92508e85712ba051bab2c7a012ccd7c3266`;
- ahead/behind: `0/0`;
- tracked worktree: clean;
- index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one worktree is on the Feature 34 branch;
- Prompt 81 and Response 81 are untracked as required;
- all known unrelated untracked files remain untouched;
- expected untracked leaf-path count after creating this response: 48 (the
  pre-checkpoint 49 minus the now-tracked Prompt 80 and Response 80, plus this
  untracked Response 81).

No real WD/Toshiba archive, real Messages database, or development app was
opened, inspected, or modified by Prompt 81.

## 34. Readiness for executable Diagnostic Review implementation

**YES.** The exact predicate, occurrence lifetime, frozen evidence source,
screen contract, restart/quit paths, forbidden dependencies, file inventory,
and automated test matrix are independently reviewable. The next prompt may
implement this bounded Stage One design under the stated stop gates.

## 35. Readiness for Diagnostic Review human qualification

**NO.** Human qualification must follow implementation, automated validation,
an implementation checkpoint/review, and a freshly built exact artifact. The
future disposable matrix is defined in Section 26, but no Prompt 81 fixture or
live app run occurred.

## 36. Readiness for whole-repository AppCzar production cutover audit

**NO.** Diagnostic Review is still virtual only and unqualified. Production
still intentionally uses legacy startup. A whole-repository production-cutover
audit can begin only after executable Diagnostic Review is implemented,
automatically validated, human-qualified on disposable fixtures, and
checkpointed, followed by an explicit separate authorization.

LOCAL DATA REPAIR HUMAN LIVE QUALIFICATION CHECKPOINTED: YES

DIAGNOSTIC REVIEW JURISDICTION IS SOURCE-GROUNDED: YES

DIAGNOSTIC REVIEW CAN PRESENT UNKNOWN WITHOUT CLAIMING FALSE: YES

DIAGNOSTIC REVIEW NEEDS NO MUTATION BALL: YES

DIAGNOSTIC REVIEW CAN REQUEST FRESH ASSESSMENT ONLY ACROSS A REAL PROCESS BOUNDARY: YES

DIAGNOSTIC REVIEW CAN REMAIN STABLE WITHOUT AN AUTOMATIC RESTART LOOP: YES

EXECUTABLE APPCZAR DIAGNOSTIC REVIEW IMPLEMENTED: NO

PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)

READY FOR DIAGNOSTIC REVIEW IMPLEMENTATION: YES

READY FOR PRODUCTION APPCZAR CUTOVER: NO
