# MessageLens Feature 34 / Feature 35
## 17 — Minimal Onboarding Tenure Correction Design

Date: 2026-09-27

This is a design-only response. No production file, test, generated file,
database, archive, configuration, index entry, or commit was changed.

## 1. Baseline verification

The required frozen implementation baseline is intact:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- first parent: `622a4d25842f15817ec93f2dc5866627189a68ad`;
- second parent: `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- index: empty;
- tracked delta: exactly 47 modified and 2 deleted paths;
- `git diff --check`: passes;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- untracked files before this response: 79 physical files, comprising the
  already-preserved instruction/history artifacts plus Prompt 17;
- the 49 preserved tracked entries still match their post-merge file types and
  hashes in the controlled reconstruction manifest;
- preservation-manifest hashes remain:
  - reconstruction:
    `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`;
  - pre-merge:
    `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`;
  - Feature 35 collision backup:
    `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`.

The response itself is the sole intentional repository addition from this
task. The frozen implementation bytes have not changed.

## 2. Exact current command-path traces

### 2.1 Initial import

Entry point:

```text
OnboardingReadyToImport action
-> startVirginImportAndGraphBuild(actionContext)
-> _runNewInitialImport(actionContext)
```

Current decision path:

```text
claim Journey command token
-> await ArchiveMutationCoordinator.run(onboardingImport)
   -> ExclusiveAuthorityRegistry.runExclusive(archiveMutation)
   -> registry synchronously installs tenure T and publishes held diagnostics
   -> ArchiveMutationCoordinator._activateArchiveScope publishes isLocked=true
   -> await _requireVerifiedCheckpointWhenApplicable
   -> enter private archive Zone carrying T/scope/operation
   -> action callback
      -> command/action-current check
      -> direct FDA check
      -> _latestReportAllowsInitialImport
      -> await onboardingOperationControllerProvider.future
      -> command/action-current check
      -> _latestReportAllowsInitialImport       <-- self-denial boundary
      -> await controller.begin(initialImport)  <-- durable protected work starts
      -> bind operation
      -> await import/graph executor
      -> await durable verification/completion
```

Awaits before the durable operation starts are:

1. the outer wait on `ArchiveMutationCoordinator.run`;
2. the coordinator's checkpoint-policy await after scope activation (the
   current operation does not require a production checkpoint, but the async
   boundary remains);
3. `onboardingOperationControllerProvider.future`.

The archive lock changes before the coordinator's checkpoint await and before
the action callback. `onboardingEnvironmentReportProvider` watches
`ArchiveMutationCoordinatorState.isLocked`; its result is listened to by
`OnboardingJourneyCoordinator._ingestEnvironmentReport`, which always replaces
`_latestReport` even while an active command suppresses a visible Journey
transition. Both report predicates inside the callback can therefore observe
self-induced maintenance; the post-controller predicate is the final rejecting
predicate before `begin`.

The callback is in the private admitted Zone, but current code uses `.run`, so
it receives no `ArchiveMutationCapability`. The exact tenure exists but is not
available to Onboarding as proof.

### 2.2 Explicit reimport

Entry point:

```text
OnboardingNormalApplication action
-> startReimport(actionContext)
-> _runNewReimport(actionContext)
```

The path is materially the same as initial import:

```text
claim token
-> await ArchiveMutationCoordinator.run(onboardingImport)
   -> publish isLocked=true before first await
   -> enter private admitted Zone
   -> command/action-current check
   -> _latestReportAllowsReimport
   -> await onboardingOperationControllerProvider.future
   -> command/action-current check
   -> _latestReportAllowsReimport              <-- self-denial boundary
   -> await controller.begin(reimport)         <-- durable protected work starts
   -> bind operation
   -> await reset/import/graph work
   -> await durable verification/completion
```

The exact rejecting predicate requires a complete `ready` report with no
external blocker and no reset requirement. A self-induced maintenance report
does not satisfy it. As with initial import, the exact tenure is in the Zone but
no capability is passed to the `.run` callback.

### 2.3 Continue Setup / interrupted-operation continuation

Entry point:

```text
OnboardingOperationInterrupted action
-> continueInterruptedOperation(actionContext)
```

Current path:

```text
validate Journey Episode, action, available action, and retained binding
-> _latestReportAllowsInterruptedContinuation(binding.snapshot)
   (positive pre-admission check already exists)
-> claim token
-> await ArchiveMutationCoordinator.run(onboardingImport)
   -> publish isLocked=true before first await
   -> enter private admitted Zone
   -> command/action-current check
   -> _latestReportAllowsInterruptedContinuation(binding.snapshot)
   -> await onboardingOperationControllerProvider.future
   -> revalidate action, UUID, process session, and interrupted status
   -> _latestReportAllowsInterruptedContinuation(controller.current)
                                                     <-- self-denial boundary
   -> await controller.resume(operationId)          <-- durable resume starts
   -> refresh binding and publish accepted operation Journey
   -> await resumed operation work
```

Continuation is the only path that already has an explicit positive check
immediately before command claim/admission. It nevertheless repeats the exact
report predicate after admission, where maintenance makes reconciliation
`unavailable` rather than `resumable`.

### 2.4 Automatic recovery/reset

Entry point:

```text
_ingestEnvironmentReport(reset-required report)
->_maybeTriggerAutomaticRecovery(report)
-> scheduleMicrotask(_runAutomaticRecovery(actionContext, report))
```

Current path:

```text
claim token
-> await ArchiveMutationCoordinator.run(automaticRecovery)
   -> publish isLocked=true before first await
   -> enter private admitted Zone
   -> command/action-current check
   -> _latestReportAllowsAutomaticRecovery
   -> await onboardingOperationControllerProvider.future
   -> command/action-current check
   -> _latestReportAllowsAutomaticRecovery          <-- first self-denial boundary
   -> await controller.begin(automaticRecovery)     <-- durable operation starts
   -> bind operation
   -> await controller.runStage(automaticRecoveryReset)
      -> await enterStage persistence
      -> await progress.observe(resettingDerivedData)
      -> command/bound-operation-current check
      -> _latestReportAllowsAutomaticRecovery       <-- final reset boundary
      -> await messageDataResetService.resetDerivedData()
```

Before the actual derived-data reset there are async boundaries in coordinator
admission, controller acquisition, `begin`, stage entry, and progress
persistence. The final reset check is correctly late, but its report predicate
cannot distinguish a genuinely withdrawn reset requirement from reset evidence
that the maintenance evaluator deliberately did not compute.

## 3. Source-proven self-denial sequence

The sequence remains real after Feature 35 integration:

1. A positive report creates the current Journey Episode/action context.
2. The Journey command claims `_activeCommandToken`.
3. All four command implementations still call
   `ArchiveMutationCoordinator.run`, not `runWithCapability`.
4. `ExclusiveAuthorityRegistry.runExclusive` installs the exact
   `archiveMutation` tenure before invoking the admitted action.
5. `_activateArchiveScope` publishes `ArchiveMutationCoordinatorState` with an
   owner and therefore `isLocked == true`.
6. `onboardingEnvironmentReportProvider` watches
   `dbMaintenanceLockProvider || archiveMutationCoordinatorProvider.isLocked`.
7. The evaluator classifies the resulting evidence as
   `maintenanceInProgress` after higher-priority Messages/Contacts/source
   blockers.
8. the Journey listener calls `_ingestEnvironmentReport`, which assigns that
   report to `_latestReport` before returning early because a command is active.
9. `_latestReportAllowsInitialImport`, `_latestReportAllowsReimport`,
   `_latestReportAllowsInterruptedContinuation`, or
   `_latestReportAllowsAutomaticRecovery` consults the replaced report.
10. None of the exact positive predicates accepts `maintenanceInProgress`, so
    the command returns before `begin`, `resume`, or reset.

This is a provider-scheduling race as to whether the first in-callback check or
the later post-controller check observes maintenance. It is not a merely
theoretical race: lock publication is synchronous and occurs before the
coordinator's first await, while controller acquisition and automatic-recovery
progress persistence provide deterministic barriers at which the maintenance
report can be delivered. Automatic recovery has the most exposure because it
contains three report checks and multiple persistence awaits.

Feature 35 did not remove the defect. It supplied exact proof machinery, but
the Onboarding code still uses the capability-free entry point. The existing
`_ImmediateArchiveMutationCoordinator` unit-test fake hides the defect because
it calls the action without publishing lock state or creating real tenure.

## 4. Tenure / archive / Journey authority separation

The correction must keep three independent answers:

| Question | Sole authority | What it does **not** prove |
|---|---|---|
| Does this async branch hold the exact current archive Ball? | `ExclusiveAuthorityRegistry`, translated through the archive coordinator's private Zone and current capability closure | Onboarding eligibility, FDA, Contacts, or archive-domain operation permission |
| What may this admitted archive scope do? | `ArchiveMutationCoordinator`, `ArchiveMutationOperation`, `ArchiveMutationCapability`, and resource-admission policy | The current Journey occurrence or user-visible outcome |
| Is this exact Onboarding command still semantically appropriate? | `OnboardingJourneyCoordinator`, its action context/token/binding, and current Environment evidence | Archive tenure or permission |

The conjunction is required. No diagnostic `isHeld`, owner label, occurrence
number, `isLocked`, or maintenance state is proof. Conversely, a current
capability is necessary but not sufficient for an Onboarding command.

## 5. Current maintenance-report semantics

1. **Coarse input:** yes. The ordinary report receives one Boolean formed from
   `dbMaintenanceLockProvider` OR archive-coordinator `.isLocked`.
2. **Whole-evaluator short circuit:** no. The evaluator still loads recorded
   failures, probes Messages, Contacts, the attachment archive, and reads source
   Messages/attachment counts.
3. **Suppressed app-owned evidence:** yes. While maintenance is true it does
   not read import-ledger or graph row counts, forces graph readiness false, and
   forces reset detection to return null.
4. **Preserved prior truth:** no. The report does not retain the last complete
   underlying classification. It contains null derived counts, false graph
   readiness, `shouldResetAppDatabasesBeforeImport == false`, and the aggregate
   maintenance state.
5. **External change during self-maintenance:** yes. FDA, Messages source
   availability/count/history, and Contacts can change independently of the
   archive Ball.
6. **Visibility:** hard external blockers remain visible because the evaluator
   orders them ahead of maintenance. However, exact `readyToImport`, `ready`,
   reconciliation, and automatic-reset semantics can remain masked because
   their derived probes are suppressed.

One further source fact narrows the model: `dbMaintenanceLockProvider` is a
compatibility read model derived from
`archiveDatabaseReopenBlockedProvider`; it is not a second native or unrelated
lock authority. For current `onboardingImport` and `automaticRecovery`
operations, `blocksDatabaseReopen` is false. The global report nevertheless
uses `.isLocked` expressly so an unrelated observer does not open derived
stores during any admitted archive operation.

Therefore a cached pre-maintenance report is not an acceptable final check,
and Candidate A cannot safely treat the aggregate maintenance report as though
it contained complete current command evidence.

## 6. Existing owner-aware API inventory

Feature 35 already supplies the mechanics needed by a narrow correction:

- `ExclusiveAuthorityRegistry.runExclusive` creates an opaque,
  occurrence-unique tenure;
- `runReentrant` accepts only the exact current tenure;
- `requireCurrent` rejects disposed registries, wrong authority, foreign
  registries, and stale/released tenure;
- there is no public ambient `currentBall` lookup;
- `ArchiveMutationCoordinator.runWithCapability` translates registry tenure
  into an archive-domain capability;
- `ArchiveMutationCapability.requireOperation` validates operation, originating
  coordinator, exact current Zone/scope, active-scope registration, and live
  tenure;
- `resourceAdmissionForCurrentCaller` applies archive resource policy for the
  current private Zone lineage.

`ArchiveMutationCoordinatorState` and generic registry diagnostics remain
observability only. `resourceAdmissionForCurrentCaller` is useful for the
owner-scoped probe's resource-policy check, but its `unrestricted` result is
not ownership proof. It must be conjoined with
`ArchiveMutationCapability.requireOperation`.

No new owner model, tenure state, ambient lookup, or public diagnostic proof is
needed.

## 7. Candidate A — ignore self-owned maintenance

**Assessment: insufficient by itself.**

An exact capability can prove that the callback owns the archive tenure. It
cannot make the aggregate maintenance report complete. In particular, the
ordinary evaluator suppresses the derived probes needed to distinguish:

- initial-import readiness from already-ready data;
- reimport readiness from a newly inconsistent derived state;
- resumable interruption from superseded durable readiness; and
- a still-valid automatic-reset requirement from a withdrawn one.

Hard FDA/Contacts/sparse-source regressions would still be visible, but that is
not the entire command predicate. Treating maintenance as neutral on capability
proof alone would allow a current Ball to substitute for missing Onboarding
evidence. That violates the authority separation and hostile-race requirements.

Candidate A is usable only as part of a design that obtains complete current
command evidence through an owner-scoped read.

## 8. Candidate B — owner-aware Environment evaluation

**Assessment: selected, but only as a narrow, non-publishing, current-caller
evidence read.**

The global `onboardingEnvironmentReportProvider` must remain owner-agnostic and
must continue publishing truthful aggregate maintenance for unrelated
observers. Making its cached value depend on whichever caller happened to
trigger evaluation would leak a caller-relative result to other consumers.

Instead, add one Onboarding-internal evidence-reader entry point alongside the
existing evaluator. It is called only from inside a `runWithCapability`
callback and:

1. requires the exact expected operation on the supplied capability;
2. checks `resourceAdmissionForCurrentCaller` for each derived resource it must
   inspect;
3. evaluates the same Environment facts without treating the current archive
   scope's coarse `.isLocked` observation as foreign maintenance;
4. still honors the stronger database-reopen policy read model;
5. revalidates capability and resource admission after its own awaits; and
6. returns evidence to Journey without publishing it as global Environment
   state.

This is evidence, not authority. The reader cannot publish a Journey state and
cannot grant tenure. Journey applies the unchanged command-specific predicate
to the returned complete report.

## 9. Candidate C — split occupancy from prerequisite truth

**Assessment: reject as a new public/durable projection; use only the narrow
one-shot distinction inherent in Candidate B.**

A second long-lived “latest prerequisites” provider would create freshness,
ordering, and possible parallel-authority problems. Retaining the last
non-maintenance report would be stale exactly when external prerequisites
change. Adding owner identity to the global report would also turn evidence
into an authorization carrier.

The selected reader separates occupancy from prerequisite inspection only for
one admitted callback, validates proof on both sides of its awaits, and returns
no retained state. There is no new Journey state, provider-held semantic cache,
or persisted truth.

## 10. Candidate D — move final check before admission

**Assessment: reject.**

After any pre-admission check, current code still crosses:

- archive-coordinator admission/checkpoint awaits;
- operation-controller acquisition;
- `begin` and stage persistence for automatic recovery; and
- progress persistence before reset.

External prerequisites can change across those boundaries. A pre-admission
check is required for a valid handoff, but it cannot replace the final check.

## 11. Candidate E — put tenure proof in Journey action context

**Assessment: reject.**

The action context is immutable user-intent provenance: Journey occurrence,
Episode, evidence revision, and operation UUID. A capability does not exist
until archive admission, is valid only in its exact private Zone/scope, and must
die on release. Putting it in action context would either expose an unusable
pre-admission placeholder or duplicate live authority/lifetime state inside
Journey.

The capability must remain a local variable of the admitted callback. It must
never be serialized, published in Journey state, stored in operation evidence,
or handed to presentation.

## 12. Selected minimal design

Select a narrow form of Candidate B, combined with the required pre-admission
handoff and late Journey validation.

The invariants are:

1. Apply the existing exact command predicate to the latest complete global
   report immediately before archive admission.
2. Call `runWithCapability` with no intervening await.
3. Keep the capability local to that callback.
4. After every await that precedes `begin`, `resume`, or reset, obtain a fresh,
   complete owner-scoped Environment report through the capability-gated
   evidence reader.
5. Revalidate the exact capability/operation and resource policy after the
   reader's awaits.
6. Revalidate Journey action context, private command token, and durable
   operation binding as applicable.
7. Apply the unchanged command-specific positive predicate to the complete
   owner-scoped report.
8. Invoke `begin`, `resume`, or reset immediately after that combined check,
   with no additional await.
9. Foreign tenure never supplies the callback/capability. Stale, wrong-scope,
   wrong-operation, foreign-registry, or disposed proof fails closed.
10. The ordinary global Environment report remains aggregate,
    owner-agnostic, and truthful.
11. Global `maintenanceInProgress` is not itself positive Journey evidence and
    must not independently create `OnboardingNormalApplication`.
12. Journey remains the only publisher of user-visible Onboarding meaning.

The four commands use the same proof/evidence mechanism but retain different
semantic predicates and binding checks. They are not collapsed into one generic
“maintenance allowed” Boolean.

## 13. Exact proof/currentness pseudocode

```text
prepare command C:
    require exact Journey Episode/action context for C
    require latest global Environment report G exists
    require unchanged positive predicate P_C(G)
    claim private command token K

    without an intervening await:
        ArchiveMutationCoordinator.runWithCapability(
            operation = archiveOperationFor(C),
            action = (capability) async {
                ...perform any required controller acquisition await...

                report = await readAdmittedEnvironmentEvidence(
                    capability,
                    expectedOperation = archiveOperationFor(C),
                )

                // The evidence reader performs these before and after its awaits:
                capability.requireOperation(expectedOperation)
                require current-caller resource admission for every probed store

                require K is still the active command token
                require the original Journey action context is still current
                require exact UUID/session/status binding where C has one
                require unchanged positive predicate P_C(report)

                // No await between this conjunction and the boundary.
                begin | resume | reset
            },
        )
```

The owner-scoped evidence read is:

```text
readAdmittedEnvironmentEvidence(capability, expectedOperation):
    capability.requireOperation(expectedOperation)

    require ArchiveMutationCoordinator.resourceAdmissionForCurrentCaller(
        each required resource action
    ) is allowed

    report = await evaluate the same Onboarding Environment facts,
        treating aggregate archive isLocked as self-owned only because
        the exact capability is current,
        while still honoring stronger database-reopen policy

    capability.requireOperation(expectedOperation)
    re-require current-caller resource admission

    return report
```

Failure behavior:

- missing capability: the API cannot be called; deny;
- wrong operation: `requireOperation` throws; no protected boundary executes;
- stale/released capability: active-scope/current-tenure check fails; deny;
- wrong registry/coordinator: private identities do not match; deny;
- outside the originating Zone: exact Zone/scope check fails; deny;
- nested different scope: outer capability is inactive for that Zone; deny;
- disposed coordinator/registry: currentness check fails; deny;
- foreign maintenance: foreign owner wins admission, so this command receives
  no capability/action callback; deny;
- resource policy changes to forbid the probe: owner-aware admission fails;
  deny.

No diagnostic field participates in the decision.

## 14. Environment Readiness change verdict

**YES — one narrowly defined owner-aware evidence change is required.**

Change the current Environment report application module to expose an internal,
non-publishing admitted-caller evidence read that reuses
`_OnboardingEnvironmentEvaluator` and accepts an exact
`ArchiveMutationCapability` plus expected `ArchiveMutationOperation`.

The ordinary provider's semantics do not change: it continues treating every
live archive mutation as aggregate maintenance. The new read is not exported
through the Onboarding feature-level provider barrel and is allowlisted only to
`OnboardingJourneyCoordinator`.

It remains evidence because it can only inspect and return a report. It cannot
grant the Ball, grant archive permission, create an action context, or publish
a Journey state. Foreign maintenance remains truthful because no foreign owner
can produce the current callback's exact capability. FDA/Messages/Contacts and
the exact reset/import/graph facts are re-evaluated after the relevant awaits
rather than inherited from a cached pre-maintenance report.

The implementation must share the existing input/evaluator construction rather
than create a second copy of readiness policy.

## 15. Journey state / action-context verdict

- `OnboardingJourneyState`: **NO type/field change**.
- immutable Journey operation projection: **NO change**.
- `OnboardingJourneyActionContext`: **NO change**.
- persisted `OnboardingOperationSnapshot`: **NO change**.
- snapshot-v1 codec: **NO change**.

Only coordinator command implementation and private helpers change. Capability
is callback-local and ephemeral.

One existing coordinator mapping should be corrected in the same narrow file:
an ownerless global `maintenanceInProgress` report must not independently map to
`OnboardingNormalApplication`. During maintenance the coordinator retains an
already-authorized Journey Episode (including an already-normal one), or remains
checking during cold reconstruction, until complete evidence arrives after
release. This does not add a maintenance Episode or a second authority.

## 16. Persistence / migration verdict

- schema migration required: **NO**;
- persisted snapshot migration required: **NO**;
- existing interrupted-operation records remain readable: **YES**;
- startup reconciliation semantics change: **NO**;
- automatic resume introduced: **NO**.

Continue Setup remains an explicit human action for an ordinary interrupted
import. Automatic recovery remains automatic only where its existing exact
reset predicate is freshly true.

## 17. Hostile-race test matrix

Use Completers/barriers and the real `ArchiveMutationCoordinator` plus Feature
35 registry. The critical fixture must publish real lock state; the old
`_ImmediateArchiveMutationCoordinator` may remain only for unrelated legacy
unit cases.

1. **Initial import / self:** hold controller acquisition, acquire real
   `onboardingImport` tenure, observe global maintenance, release the barrier,
   return complete ready-to-import owner evidence, and assert one `begin`.
2. **Foreign Ball:** hold archive tenure in another async branch; invoke initial
   import; assert the action callback and `begin` never run.
3. **Stale/released proof:** retain a callback/capability continuation past
   release and trigger the final evidence boundary; assert capability denial and
   zero `begin`.
4. **FDA withdrawal:** after admission but before the final owner evidence
   completes, publish/read FDA false; assert no `begin`.
5. **Contacts withdrawal:** repeat with Address Book unavailable; assert no
   initial begin, reimport begin, or continuation resume where applicable.
6. **Command semantic supersession:** for initial import supply a complete
   current `ready` report; for reimport supply `readyToImport`; assert each
   command remains inert despite its own live tenure.
7. **Continuation superseded:** hold controller acquisition, replace resumable
   evidence with ready/new-state evidence, release, and assert the exact UUID is
   still interrupted and never resumed.
8. **Automatic reset withdrawn:** hold after archive admission and again after
   progress persistence; make the owner-scoped report complete with
   `shouldResetAppDatabasesBeforeImport == false`; assert zero reset calls and
   retained truthful operation evidence.
9. **Wrong operation:** give a valid capability for another archive operation
   to the evidence seam/final guard; assert typed capability denial and no work.
10. **Ball 1 versus Ball 2:** retain Ball 1's callback, release it, acquire Ball
    2, invoke the old continuation, and assert Ball 1 cannot authorize evidence
    or work while Ball 2 is live.
11. **Presentation isolation:** inject hostile raw maintenance, graph, and
    snapshot noise while a bound Journey operation exists; assert surfaces
    render only the Journey Episode/projection.
12. **Restart:** reconstruct an ordinary interrupted import and assert no
    automatic resume; only a current Continue Setup action may resume it.
13. **Reimport / self:** real self-maintenance plus complete current `ready`
    owner evidence reaches exactly one reimport `begin` and reset path.
14. **Continuation / self:** real self-maintenance plus complete resumable owner
    evidence resumes the same UUID/session exactly once.
15. **Automatic recovery / self:** self-maintenance alone does not erase the
    reset predicate; a complete owner-scoped report still requiring reset
    reaches reset exactly once.
16. **Reader's own await race:** invalidate capability or resource admission
    while the owner-evidence reader is awaiting; its post-await proof check must
    fail closed.

No test may use sleeps to establish ordering.

## 18. Architecture-tripwire plan

Add structural checks that enforce:

1. the four Onboarding command paths use `runWithCapability`, not capability-free
   `.run`;
2. the admitted Environment evidence seam requires
   `ArchiveMutationCapability` and an expected typed operation;
3. that seam validates capability and current-caller resource admission both
   before and after its awaits;
4. only `OnboardingJourneyCoordinator` may consume the admitted evidence seam;
5. the ordinary global Environment provider remains owner-agnostic and still
   reports aggregate maintenance;
6. no presentation file imports Environment evidence, generic tenure,
   capability, registry, or maintenance diagnostics to choose Onboarding state;
7. Journey state, action context, operation projection, and snapshot persistence
   contain no `ExclusiveAuthorityTenure` or `ArchiveMutationCapability`;
8. the Onboarding feature barrel does not export the internal admitted evidence
   seam;
9. no production code introduces a public ambient current-tenure lookup;
10. generic tenure diagnostics are never read as authorization proof;
11. `maintenanceInProgress` cannot independently construct normal Journey
    semantics; and
12. the exact command-specific predicate remains the last semantic check before
    each `begin`, `resume`, or reset boundary.

Use analyzer-AST call/type/import inspection for the ownership and call-boundary
rules where practical. Keep existing dependency-census/allowlist tests for the
Journey-only presentation boundary. Do not rely on owner labels or identifier
spelling as proof.

## 19. Exact expected implementation file scope

### Must change

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
   - share the existing evaluator/input construction;
   - add the capability-gated, non-publishing admitted evidence read;
   - keep the ordinary provider aggregate and owner-agnostic.
2. `lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart`
   - pre-admission exact checks for all four paths;
   - convert four entries to `runWithCapability`;
   - perform late owner-evidence/action/token/binding checks;
   - prevent aggregate maintenance from independently authorizing normal
     Journey state.
3. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
   - real-tenure hostile-race harness and command matrix.
4. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
   - ordinary-versus-admitted evidence semantics, proof failure, resource
     policy, and external-withdrawal coverage.
5. `test/architecture/onboarding_journey_authority_architecture_test.dart`
   - Journey/presentation/proof isolation and exact admitted-path tripwires.

### May change

1. `test/architecture/forbidden_imports_test.dart` only if the existing central
   AST/census helpers are the correct structural home for the new allowlist.
2. `lib/essentials/onboarding/application/onboarding_environment_report_provider.g.dart`
   only if implementation proves an annotated provider symbol is unavoidable;
   the preferred plain internal reader requires no generator change.

No other generated output is expected.

### Must not change

- all presentation widgets and panels;
- `OnboardingJourneyState`, action-context, operation-projection, and persisted
  snapshot schemas;
- snapshot codecs or database schemas;
- `ExclusiveAuthorityRegistry`, `ExclusiveAuthorityTenure`, or Feature 35
  generic registry internals;
- `ArchiveMutationCoordinator`, its capability, or archive operation policy
  unless implementation uncovers a source-proven defect and stops for review;
- archive relocation/adoption policy;
- native locks;
- attachment archive configuration;
- any production database or archive;
- unrelated Onboarding Trips/Steps;
- release metadata for this correction inside the still-uncheckpointed Feature
  34 repair, unless a later checkpoint prompt explicitly requires it.

If the capability-gated read cannot be expressed within this boundary, stop
instead of silently redesigning Feature 35 or Environment Readiness.

## 20. Validation plan

Run in this order after implementation approval:

1. focused admitted-evidence and self-maintenance hostile-race tests;
2. complete Journey authority/currentness test file;
3. complete Environment report test file;
4. archive mutation coordinator tests;
5. Feature 35 registry and AST architecture tests;
6. Onboarding Journey/snapshot architecture tests;
7. complete architecture suite;
8. `flutter analyze`;
9. full `flutter test` suite;
10. `git diff --check` and an exact intended-file census;
11. Project Conformance audit;
12. human architectural review before checkpoint.

Do not include GUI qualification. Clean-slate GUI qualification resumes only
after this architecture earns a checkpoint.

## 21. Project Conformance risks

1. **Duplicate readiness policy:** the admitted read must reuse the existing
   evaluator. Copying reset/readiness rules into Journey would create parallel
   semantic authorities.
2. **Caller-relative cache leakage:** the owner-scoped result must not be stored
   in the global Environment provider or exposed to presentation.
3. **Capability escape:** no field, provider state, closure retained past the
   callback, snapshot, or action context may hold the capability.
4. **Boolean ownership regression:** `.isLocked`, owner label, occurrence, and
   resource-admission `unrestricted` are not proof; exact capability validation
   remains mandatory.
5. **Resource-policy bypass:** a valid Ball alone does not allow a prohibited
   database reopen. Current-caller resource admission must also permit it.
6. **Lost late check:** every final boundary must follow its last evidence await
   with action/token/binding/capability revalidation and no new await.
7. **Global maintenance semantics:** correcting command admission must not make
   maintenance globally invisible or authorize normal application.
8. **Test-fake blindness:** critical tests using the immediate fake would pass
   without exercising the defect. The real registry/coordinator is mandatory.
9. **Barrel expansion:** the admitted evidence seam must remain an internal
   Onboarding implementation detail.
10. **Scope creep:** no reason has been found to change persistence,
    presentation, generic tenure, archive-domain policy, or real data.

## 22. Stop gates

Stop for review if implementation discovers any of the following:

- the owner-scoped evaluator cannot reuse the same readiness/reset policy;
- current operations are not resource-admitted to perform the required probes;
- a Feature 35 registry/coordinator change appears necessary;
- capability would have to be persisted, published, or stored in Journey state;
- a schema or snapshot migration appears necessary;
- a presentation change appears necessary;
- exact late checks cannot be placed without an intervening await;
- the current 49-path frozen implementation delta changes outside the approved
  file scope;
- a test requires a real archive/database, GUI launch, or production data;
- any preservation-manifest mismatch appears.

## 23. Readiness for implementation

The current architecture can support the correction without parallel
authorities. Feature 35 already supplies exact, fail-closed tenure and archive
scope proof. The remaining work is a narrow Onboarding integration: obtain
complete current evidence through that proof, then let Journey apply its
existing command-specific semantics.

The implementation boundary, proof rule, race matrix, and stop gates are now
specific enough to implement without inventing a second source of truth.

MINIMAL ONBOARDING TENURE CORRECTION DESIGN COMPLETE: YES

READY TO IMPLEMENT MINIMAL ONBOARDING TENURE CORRECTION: YES
