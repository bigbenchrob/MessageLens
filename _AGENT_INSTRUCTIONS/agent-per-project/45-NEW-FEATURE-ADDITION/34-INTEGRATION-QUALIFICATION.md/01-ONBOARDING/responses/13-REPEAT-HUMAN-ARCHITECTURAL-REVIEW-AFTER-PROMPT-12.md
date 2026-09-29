# MessageLens Clean-Slate Integrated Qualification
## 13 — Repeated Human Architectural Review After Prompt 12

Date: 2026-09-25

## Executive finding

Prompt 12 corrected the previously identified broad-policy defect. The current
coordinator has four distinct positive predicates, checks the latest retained
coherent report after the last relevant await, and has no intervening await
before `begin`, `resume`, or reset. The five new non-external withdrawal tests
also reach their stated held boundaries and prove the intended counters and
retained identities.

The complete production trace nevertheless exposes a new **BLOCKER** that the
test fixture removes from the system under test.

The real `ArchiveMutationCoordinator` publishes its locked state before an
await and before invoking the admitted action. The real environment-report
provider watches that lock and classifies every admitted archive mutation,
including Onboarding import, as `maintenanceInProgress`. While a command is
active, the Journey coordinator accepts that newly completed report into
`_latestReport` but intentionally keeps the rendered action occurrence in
place. The final exact-command predicate can therefore observe maintenance
caused by the command's **own admitted mutation scope**.

Initial import and reimport require `readyToImport` and `ready` respectively,
and interrupted continuation treats maintenance as unavailable. Depending on
which asynchronous provider finishes first, those commands can reject
themselves after admission but before `begin`/`resume`. The generic denial path
then projects `maintenanceInProgress` through `_journeyFromEnvironment`, which
currently produces `OnboardingNormalApplication`. The same user action can
therefore either begin or silently disappear/release normal application based
on provider timing.

The coordinator race fixture overrides the archive coordinator with
`_ImmediateArchiveMutationCoordinator`, whose `run` invokes the action without
ever publishing a locked state. None of the ten held-report races exercises
the real mutation-lock/report interaction.

The one-way authority architecture remains intact, but exact-command
authorization is not yet deterministic against the actual evidence graph.
The implementation is not safe for final full validation or checkpoint.

## 1. Baseline and diff identity — NO ISSUE

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- HEAD subject: `docs(onboarding): restore journey-only authority`
- Index: empty
- Tracked worktree before this response: 47 modified files and 2 deleted
  files, matching the reviewed Onboarding correction
- Intended untracked implementation/test files remain present:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch: present outside the worktree, unapplied, 21,137 bytes, SHA-256
  `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`

The current tracked inventory is the Prompt 06/08/10/12 implementation. Prompt
12 changed only the coordinator, readiness-action import, coordinator tests,
authority architecture test, and its response record. No unrelated tracked
file, archive implementation, database schema, native source, or data-root
configuration is mixed in.

`git diff --check` is clean. No file was staged.

## 2. Sole-authority and lifetime verdict — NO ISSUE

`OnboardingJourneyCoordinator` remains the sole production writer/selector of
`OnboardingJourneyState`.

- Its annotation remains `@Riverpod(keepAlive: true)`.
- Generated output is a non-auto-dispose `NotifierProvider`.
- `build()` installs listeners for environment, operation, and mutation-lock
  evidence.
- It uses `ref.read` for initial evidence and does not `ref.watch` changing
  evidence in `build()`.
- It does not invalidate itself.
- No production caller invalidates
  `onboardingJourneyCoordinatorProvider`.
- `_latestReport` is the one retained coherent report. Prompt 12 did not add a
  parallel cache, presentation authority, or independent policy state machine.

The original stale-`ref`/owner-reconstruction failure remains impossible by
the implemented lifetime structure.

## 3. Exact-command authorization verdict — BLOCKER

The local ordering is correct:

```text
last relevant await
-> command/action/operation identity check
-> command-specific latest-report predicate
-> begin, resume, or reset
```

There is no await between each final predicate and its mutation call.

The end-to-end evidence graph is not correct, however:

1. `ArchiveMutationCoordinator._tryAcquire` assigns a locked state before the
   coordinator awaits checkpoint validation and before invoking the action.
2. `onboardingEnvironmentReportProvider` watches
   `archiveMutationCoordinatorProvider.select((state) => state.isLocked)`.
3. Its evaluator maps that fact to
   `OnboardingEnvironmentState.maintenanceInProgress`.
4. `_ingestEnvironmentReport` stores that report in `_latestReport` while the
   active command token suppresses visible Journey replacement.
5. The final command-specific predicate reads that maintenance report.
6. Initial import/reimport/continuation can reject their own admitted scope,
   and `_latestReportAllowsCommand` publishes the denial through
   `_journeyFromEnvironment`.
7. `_journeyFromEnvironment` currently maps maintenance to
   `OnboardingNormalApplication`.

This is a scheduling race between the real report recomputation and controller
acquisition, not a hypothetical future refactor. A command must distinguish
maintenance owned by its own admitted scope from unrelated maintenance without
relaxing the fail-closed rule for unrelated locks and without creating a
second prerequisite authority.

## 4. Initial-import predicate verdict — BLOCKER

The predicate itself is positively scoped as intended:

- no external prerequisite blocker;
- no automatic-reset requirement; and
- `readyToImport`, or sparse/local history explicitly accepted in the current
  process Journey.

It correctly denies `ready`, reset-required, app-owned failure, maintenance,
and external blockers.

That correct maintenance denial becomes unsafe after the command has acquired
its own `onboardingImport` scope. A report recomputation caused by that scope
changes `readyToImport` to `maintenanceInProgress`, so the final guard can
cancel the otherwise valid first import before `begin` and publish normal
application. The production path is therefore not deterministic.

## 5. Reimport predicate verdict — BLOCKER

The explicit reimport policy is correctly different from first import: it
requires current `ready`, no external blocker, and no automatic-reset
requirement.

The same self-maintenance race changes the report from `ready` to
`maintenanceInProgress` after the reimport scope is acquired. Reimport can
therefore become a silent no-op before `begin`, with the denial projected as
normal application. This is not a legitimate policy withdrawal; it is an
observation of the command's own admission.

## 6. Continue Setup predicate verdict — BLOCKER

The final continuation predicate otherwise has the correct semantics:

- exact action/command occurrence;
- exact UUID, prior process session, and interrupted status;
- non-automatic-recovery kind; and
- the same reconciliation specialist must classify the exact current snapshot
  as `resumable` under the latest report.

`ready` correctly supersedes interruption, and wrong/missing safe boundaries
are rejected.

But reconciliation classifies `maintenanceInProgress` as unavailable. The
real `onboardingImport` admission can therefore cause Continue Setup to reject
its own lock before `resume`. The retained interrupted identity stays truthful,
but the current denial can hide the interaction behind normal application
until later evidence happens to resurface it.

## 7. Automatic-recovery predicate verdict — NO ISSUE in the predicate;
shared admission/report coupling remains unproved

Automatic recovery positively requires:

- no external prerequisite blocker; and
- `shouldResetAppDatabasesBeforeImport == true`.

It is checked before `begin` and again after resetting-progress persistence,
immediately before reset. The Prompt 11 destructive race—reset proceeding
after the reset requirement disappears—is closed.

Unlike first import/reimport, this predicate does not require a particular
report state, so a maintenance report can still pass if it retains the reset
requirement. The current tests nevertheless do not exercise the real locked
report, so the full admission/report interaction remains part of BLOCKER 1's
required regression coverage.

## 8. Deterministic withdrawal-race verdict — NO ISSUE for the five claimed
races; BLOCKER coverage gap for the real admission seam

The five Prompt 12 tests are genuine completer-held races:

1. first import: `readyToImport -> ready` while controller acquisition is held;
2. reimport: `ready -> readyToImport` while acquisition is held;
3. Continue Setup: interruption -> `ready` while acquisition is held;
4. automatic recovery: reset-required -> `ready` before `begin`; and
5. automatic recovery: reset-required -> `ready` after `begin` but before
   reset.

They use no timing sleep as the proof mechanism. The controller-access and
snapshot-store completers establish the exact boundary. `begin`, `resume`,
reset, graph-executor, UUID/session/status, and retained-evidence assertions
are appropriate.

However, `_JourneyFixture` replaces the real archive coordinator with
`_ImmediateArchiveMutationCoordinator`, whose `run` calls the action directly
and never sets `isLocked`. The production-only maintenance transition is
therefore absent from every race. A deterministic regression must use the real
lock/report relationship or an equivalent lock-publishing test double and
prove that self-owned maintenance neither cancels nor reauthorizes the wrong
command.

## 9. Retained-evidence verdict — NO ISSUE

- Retry stopped before replacement `begin` restores the prior failed binding
  and UUID privately.
- A genuinely new admission/`begin` failure remains UUID-less.
- Continue stopped before `resume` preserves UUID, process session, and
  interrupted status.
- Automatic recovery stopped after `begin` retains truthful retryable failed
  evidence and does not become success.
- Compatible resurfacing uses a new Journey occurrence, so captured actions
  are stale.
- Operation A cannot replace operation B.

The self-maintenance blocker concerns whether a valid command can reach its
operation boundary; it does not reveal identity corruption in these retention
paths.

## 10. Prerequisite-precedence verdict — NO ISSUE for external prerequisites

The visible rule remains:

```text
current external prerequisite truth
        >
retained app-owned failure/interruption
```

Messages/FDA, local Messages/source availability, local-history confirmation,
and Contacts access displace retained failed/interrupted presentation while
the durable identity remains private. Compatible evidence can resurface it
only through the coordinator under a fresh occurrence.

The blocker is distinct: `maintenanceInProgress` is being generated by the
same admitted command, then treated as if it were independent withdrawal
evidence.

## 11. Startup-adoption verdict — NO ISSUE

The startup adoption window is explicit and one-shot. It closes after both
initial report and snapshot channels settle. Unbound failed/interrupted
evidence may be adopted only during that window; later emissions remain
history/diagnostics only. Terminal acknowledgement and operation-B start
cannot be reversed by operation-A replay, and a legitimate startup
interruption is adopted only once.

## 12. Operation identity/projection verdict — NO ISSUE

- New attempts receive one UUID from durable `begin`.
- Retry receives a new UUID only after replacement `begin` succeeds.
- Continue retains the exact interrupted UUID and changes process session only
  through persisted `resume`.
- Evidence acceptance verifies occurrence, UUID, kind, process session,
  status transition, stage/substage order, progress revision/fingerprint, and
  progress bounds.
- `OnboardingJourneyOperationProjection` is immutable/data-only and exposes
  no provider, controller, store, process session, snapshot history,
  `recoveryDisposition`, or mutation capability.
- Unknown/nonpositive progress remains indeterminate; graph terminal state and
  elapsed time do not fabricate completion.

## 13. UUID-less failure/action verdict — NO ISSUE

Pre-UUID failures remain UUID-less. Coordinator-owned
`OnboardingJourneyFailureAction` truthfully preserves the failed command:

- initial import -> `retryInitialImport`;
- reimport -> `retryReimport`;
- automatic recovery -> `retryAutomaticRecovery`;
- environment-only failure -> `recheckEnvironment`; and
- manual/nonrecoverable failure -> `none`.

No retained UUID is attached to a new admission/`begin` failure, and
presentation derives the action from Journey state rather than snapshot
capability.

## 14. Failure-order verdict — NO ISSUE

`_publishFailureBeforeSideEffects` publishes a valid Journey failure before
snapshot failure persistence, graph/import failure storage, logger
acquisition/write, or evidence invalidation. Each secondary boundary is
contained independently. Boundary-spy tests observe the primary Journey
failure from inside each secondary callback, and the original operation error
remains primary.

The exact-command helpers add no fallible provider access ahead of this
failure publication path.

## 15. Semantic root-discovery verdict — SHOULD FIX

The test does enumerate every non-generated Dart file under `lib/`, and it
strips comments/string literals before applying its root regex. Selected
directory roots and the shell skip are gone.

Root classification is still narrower than the complete user-visible semantic
surface. `_sourceConsumesJourneySemantics` recognizes only
`OnboardingJourney*`, the Journey/Gate providers, and
`EnvironmentReadinessSurface*`. It does not recognize the compatibility
semantic `OnboardingStatus` itself.

Current `OnboardingStatus`-only consumers such as
`onboarding_sidebar_visibility_owner.dart` and
`onboarding_center_panel_sync_controller.dart` are presently reached through
the shell/observer roots, so there is no current production side door. But a
standalone or moved compatibility consumer can leave the census without
changing its semantic role. The promised repository-wide consumer discovery
is therefore not yet a property of the root detector itself.

## 16. Transitive stop/leaf verdict — SHOULD FIX

Shell and config dependencies are now traversed. Intent adapters are stopped
only after a transitive proof, and the retained Start Fresh, graph-status, and
developer-panel boundaries have explicit source/importer checks.

One material omission remains: the main production `sideDoors` set contains
the environment, snapshot/controller, reconciliation, and FDA implementation
paths, but it does **not** contain
`conversationGraphBuildControllerProvider` or its feature barrel. Those graph
paths are added only to the evidence set used to decide whether an intent
adapter may stop.

A production semantic root that directly or transitively reaches the raw graph
controller without passing through such an adapter will therefore be
traversed, but the reached graph path will not be reported as a side door. The
separate developer-panel assertion scans direct provider spellings, not the
same transitive graph. The claim that the developer panel is the sole bounded
raw graph-evidence presentation exception is not mechanically proved.

## 17. Virtual census-test verdict — SHOULD FIX

The synthetic tests do use the production discovery/traversal/stop helpers and
correctly prove:

- arbitrary `lib/shared` wrapper traversal;
- shell wrapper traversal;
- hidden raw snapshot evidence behind an apparent intent adapter;
- config wrapper traversal;
- a genuinely narrow intent adapter; and
- the direct development-panel exception.

They do not exercise a semantic root reaching raw graph/controller evidence,
and they do not exercise an `OnboardingStatus`-only semantic root. Consequently
they cannot expose the two production-policy gaps above. Existing failure
messages do retain useful dependency chains for paths that are actually
classified as violations.

## 18. Census overfitting verdict — SHOULD FIX

The Prompt 12 rewrite materially reduced layout coupling. Stable named seams
for the coordinator, immutable Journey domain, Advanced Start Fresh,
independent graph status, and diagnostic developer panel are reasonable.

The remaining token-based omission of compatibility-status consumers and the
different raw-evidence sets used by main side-door detection versus
intent-adapter proof are semantic underreach, not merely aesthetic coupling.
They should be corrected before this test is relied on as the complete future
side-door tripwire.

## 19. Specialist-boundary verdict — NO ISSUE

The coordinator owns Journey occurrence/Episode, coherent report retention,
exact-command policy interpretation, operation binding/currentness, action
policy, orchestration, and next-state choice. Specialists still own FDA and
Contacts probes, import/graph work, reset mechanics, snapshot persistence,
archive admission, failure storage/logging, and durable completion proof.

No SQL, database construction, filesystem/archive mutation mechanics, or
completion-proof implementation moved into the coordinator.

## 20. Diff-shape/safety verdict — NO ISSUE

The complete file inventory and targeted production/test diffs agree with the
reported correction:

- stable listener-owned coordinator and typed Journey projection;
- operation-ID binding/currentness;
- Journey-only production presentation and typed actions;
- reconciliation-provider removal;
- snapshot/controller evidence cleanup;
- generated Riverpod updates;
- focused replay/failure/presentation/architecture tests; and
- Prompt 12's coordinator/readiness-import/census changes.

No duplicate Journey state, second report cache, schema change, archive
authority change, attachment mutation, real-data path, unrelated refactor, or
privacy regression was found. The two deleted reconciliation-provider files
have no remaining production reference. Generated changes match changed
provider inputs, and the reported analyzer/generation results remain coherent
with the diff.

## 21. Concrete BLOCKER findings

### BLOCKER 1 — Exact-command authorization consumes self-induced maintenance

- **Files/symbols:**
  `ArchiveMutationCoordinator._run/_tryAcquire`,
  `onboardingEnvironmentReportProvider`,
  `_OnboardingEnvironmentEvaluator._classifyState`,
  `_ingestEnvironmentReport`, `_latestReportAllowsCommand`,
  `_reportAllowsInitialImport`, `_reportAllowsReimport`,
  `_reportAllowsInterruptedContinuation`, and `_journeyFromEnvironment`.
- **Cause:** the mutation scope publishes `isLocked` before the admitted
  action; the report converts that lock to `maintenanceInProgress`; the active
  command stores it as the latest report; exact predicates then treat the
  command's own lock as independent policy withdrawal.
- **Impact:** first import, reimport, and Continue Setup can become
  scheduling-dependent no-ops. The denial can publish normal application even
  though the requested operation never began and interrupted/first-run work
  remains outstanding.
- **Why tests miss it:** `_JourneyFixture` defaults to
  `_ImmediateArchiveMutationCoordinator`, which never changes lock state.
- **Required correction:** establish one typed, coordinator-owned way to
  revalidate external/command eligibility while recognizing the currently
  admitted command's own maintenance scope. Unrelated maintenance must remain
  fail-closed. Do not solve this by accepting all maintenance reports, caching
  a second independently mutable prerequisite authority, or bypassing the
  exact post-await check.
- **Required proof:** completer-held tests with the real lock/report coupling
  (or an equivalent lock-publishing coordinator) for first import, reimport,
  Continue Setup, and automatic recovery. They must prove deterministic
  behavior, correct Journey presentation, and untouched mutation counters when
  an independent blocker—not the owned lock—withdraws authorization.

## 22. Concrete SHOULD FIX findings

### SHOULD FIX 1 — Raw graph evidence is absent from the main side-door set

Add raw graph/controller paths to the same semantic violation policy used by
production traversal, with narrowly proved independent graph-status and
diagnostic exceptions. Add a virtual root/wrapper case that fails with a full
dependency path.

### SHOULD FIX 2 — Compatibility-status semantic consumers are not roots

Make repository-wide discovery include user-visible compatibility-status
consumers (or mechanically prove that every such consumer is necessarily
reachable from a Journey root). Add a virtual `OnboardingStatus`-only consumer
case so a conforming move/reuse cannot silently leave the census.

## 23. OPTIONAL findings

- Canonical `20-environment-readiness.md` still says the environment report
  carries the persisted operation snapshot and that presentation renders that
  snapshot. Current source correctly removed that field and uses the
  Journey-owned projection. This deferred canonical wording should be updated
  in the later documentation tranche.
- `OnboardingOverlay` retains comments about a production prerequisite
  Presence runner and `OnboardingGate.build`; current presentation uses the
  Journey coordinator and Environment Readiness.
- `onboardingJourneyAllowsCommandedTransition` remains unused. It is not an
  active authority defect.

## 24. Narrow tests rerun

None.

Source inspection conclusively establishes the real lock-to-report dependency,
the pre-action lock publication, the maintenance classification, the active
command's `_latestReport` update, and the test fixture's non-locking override.
The census omissions are likewise conclusive from the two evidence sets and
root regex. Prompt 13 permits a narrow rerun only for a specific unresolved
question; no existing test exercises either unresolved seam, so rerunning it
would not add proof.

Prompt 12's reported validation remains recorded as:

- focused Journey bundle: 88 passed;
- authority architecture: 13 passed;
- complete architecture: 500 passed;
- analyzer: clean; and
- `git diff --check`: clean.

Those results do not exercise the real mutation-lock/report coupling and do
not invalidate this source-level finding.

## 25. Exact Git status

- Branch/HEAD: `fix/onboarding-import-stuck-state` /
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty
- Tracked worktree: 47 modified files and 2 deleted files
- Untracked worktree: 73 files after adding this response
- Intended untracked implementation/test files: Journey operation projection
  and Journey authority architecture test
- This Prompt 13 response is the only file created by this review
- Shared-instructions submodule: clean and unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch: unchanged and unapplied, 21,137 bytes, SHA-256
  `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`
- Staging/commit/push/merge: none
- MessageLens Development: not launched
- Real databases, archives, and application state: not accessed or modified

## 26. Final architectural recommendation

Do not proceed to final full validation or checkpoint. Correct BLOCKER 1
without introducing a second prerequisite authority, add deterministic
production-realistic lock/report race coverage, and close the two census proof
gaps. Then repeat this human architectural gate against the complete unstaged
source.

`POST-PROMPT-12 HUMAN ARCHITECTURAL REVIEW: FAIL`
