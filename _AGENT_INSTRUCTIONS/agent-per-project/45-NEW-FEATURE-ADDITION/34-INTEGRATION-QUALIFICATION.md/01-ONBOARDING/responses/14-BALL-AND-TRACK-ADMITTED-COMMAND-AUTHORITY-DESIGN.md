# MessageLens Clean-Slate Integrated Qualification
## 14 — Ball-and-Track Admitted-Command Authority Design

Date: 2026-09-25

## Executive decision

The earlier Ball/Track mechanism still exists and is sufficient. No new token,
lease, operation UUID, report authority, or presentation authority is needed.

The selected correction is a bounded hybrid of Prompt 14 options **B + C**:

1. keep `OnboardingEnvironmentReport` as owner-agnostic installation and
   diagnostic evidence;
2. preserve the four positive, command-specific predicates as the
   **pre-admission** policy;
3. enter mutation authority with the existing
   `ArchiveMutationCoordinator.runWithCapability` API;
4. use the resulting `ArchiveMutationCapability` as the mechanical proof that
   the exact Onboarding operation scope still holds the ball;
5. after every relevant await, revalidate the same Journey command, action
   occurrence, operation binding where applicable, fresh independent
   prerequisites, and the exact-scope capability; and
6. never ask an ownerless `maintenanceInProgress` aggregate to decide whether
   the operation that caused that aggregate may continue.

The important distinction is:

```text
installation observation: an archive mutation is active

is not the same question as:

command authorization: does this exact admitted command still own the ball,
and are all facts independent of its own lock still valid?
```

This preserves the sole Journey authority. Presentation remains completely
unaware of mutation ownership.

## 1. Baseline

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- HEAD subject: `docs(onboarding): restore journey-only authority`
- Index: empty
- Tracked worktree before this response: 47 modified files and 2 deleted
  files, matching the still-unstaged Prompt 06/08/10/12 Onboarding authority
  correction
- Intended untracked implementation/test files remain:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch:
  `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`
  - 21,137 bytes
  - SHA-256
    `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`
  - unchanged and unapplied
- `git diff --check`: passed

No production code, test, generated file, schema, archive configuration, real
database, or attachment archive was accessed or changed. MessageLens
Development was not launched.

## 2. Rediscovered Ball/Track history

### VERIFIED HISTORY

1. The project constitution names the original execution gate the **Cricket
   Ball**, after the railway single-track token model: a non-holder cannot enter
   mutation-producing work. The readers/integrators/orchestrators contract
   describes the same exclusive execution-ownership rule.
2. Commit `5790ceeae483e0bbe0e6051745b0376549cb264c`
   (`establish production archive protection and attachment recovery`,
   2026-07-28) introduced `ArchiveMutationCoordinator`, a process-local owner
   ID, private async `Zone` propagation, exclusive outer admission, and
   same-owner reentry.
3. Historical Archive import later exposed the inverse defect: it acquired
   mutation ownership, projected that rich ownership into a Boolean maintenance
   lock, and was denied a fresh `working_ss.db` connection by its own Boolean.
   Feature 26 Audit 07 records the exact self-blocking path.
4. Commit `f638d0cbd6508a212674f470999e276994064bf3`
   (`restore owner-aware graph admission`, 2026-08-17) corrected that defect.
   It introduced:
   - `_ArchiveMutationAsyncContext` carrying owner and operation;
   - truthful active nested-operation scopes;
   - `ArchiveMutationResourceAdmission`;
   - `resourceAdmissionForCurrentCaller`;
   - operation-specific graph-open permission; and
   - tests proving the admitted owner can open its required graph while an
     unrelated caller cannot.
5. The same commit retained `dbMaintenanceLockProvider` as a coarse
   compatibility/read-suppression signal and explicitly removed it as the sole
   resource-admission answer.
6. Commit `230479da114d410b0577c08d488869af4037250a`
   (`enable MessageLens archive recovery preflight`, 2026-08-22) strengthened
   the context with a private scope ID and added
   `ArchiveMutationCapability`/`runWithCapability`. The capability proves one
   exact active operation scope, becomes invalid outside its originating Zone,
   is invalid in a different nested scope, and becomes stale on release.
7. Current tests prove:
   - awaited provider construction observes the requesting async Zone;
   - same-owner nested work reuses owner identity;
   - active nested scopes preserve stronger reopen and checkpoint policy;
   - exact-scope capabilities fail outside their scope and after release; and
   - unrelated graph opens remain denied while an admitted historical owner is
     allowed the operation-specific resource action.

### What the “ball” is in current code

The ball is not the public `isLocked` Boolean. It is the coordinator-created,
process-local ownership chain:

```text
private owner ID
  + private scope ID
  + typed ArchiveMutationOperation
  + active-scope registration
  + private Zone inheritance
  + coordinator-issued ArchiveMutationCapability
```

`ArchiveMutationCapability` is the narrow opaque proof suitable for an
admitted Onboarding command. Feature code cannot construct it because its
constructor is private. `requireOperation` verifies both the requested typed
operation and that the exact caller scope is still active.

### How descendants prove authority

`runZoned` installs `_ArchiveMutationAsyncContext`. Awaited descendants inherit
the Zone. Reentrant `run`/`runWithCapability` reads the inherited owner ID,
adds a new scope for the nested operation, enforces that operation's checkpoint
policy, and restores the previous Zone context and active-scope set on exit.

An unrelated caller has no matching private Zone context. It cannot forge a
raw owner string into the private object-keyed Zone entry, cannot construct a
capability, and cannot acquire the coordinator while another owner is active.

### STRONGLY SUPPORTED INFERENCE

- The unconditional historical mapping
  `maintenanceInProgress -> OnboardingStatus.notNeeded` was intended to stop a
  legitimate Historical Archives mutation from looking like graph failure and
  temporarily redirecting an already-established installation into
  Onboarding. Feature 26's audit/implementation record and the change history
  support that purpose.
- When typed Journey authority was later centralized, that compatibility
  decision was translated too literally into
  `maintenanceInProgress -> OnboardingNormalApplication`. The old Boolean
  answer survived while the richer owner provenance was not connected to the
  Onboarding command path.

### UNKNOWN

- Repository evidence does not establish that the authors consciously decided
  Onboarding commands should bypass `runWithCapability`. The present `.run`
  calls may simply predate the need for exact admitted-command proof.
- Repository evidence does not identify a requirement for mutation ownership
  to cross isolates or outlive the coordinator action. Therefore a new public
  lease system is not justified.

## 3. Current mutation authority and provenance

### Admission APIs

- `ArchiveMutationCoordinator.run` admits a named operation but deliberately
  discards the generated capability at the call boundary.
- `ArchiveMutationCoordinator.runWithCapability` admits the same operation and
  supplies the coordinator-created exact-scope capability to the action.

Both enter the same `_run` implementation.

### Published mutation state

`ArchiveMutationCoordinatorState` publishes:

- outer `operation`;
- `ownerId` and diagnostic `ownerLabel`;
- all `activeOperations`;
- admitted archive `environment` and `archiveInstanceId`;
- `holdCount`;
- acquisition/release timestamps; and
- last denied operation/owner/time plus denial count.

`isLocked` answers only whether an owner exists. `blocksDatabaseReopen`
aggregates all active scopes and is true if any active operation has the
stronger policy.

The state does not and should not publish a universal `selfOwner` Boolean.
“Self” is relative to the requesting async context. The typed relative answer
is obtained only through coordinator methods such as
`resourceAdmissionForCurrentCaller`, or through an exact capability inside its
Zone.

### Private identity and lifetime

- A new outer owner ID is `<ownerLabel>#<process-local sequence>`.
- Each admitted scope gets a private monotonically increasing `scopeId`.
- `_activeScopes` maps that scope ID to its typed operation.
- `_ArchiveMutationAsyncContext` carries owner ID, scope ID, and operation in a
  private object-keyed Zone entry.
- Same-owner reentry adds a scope and increments aggregate hold state; a
  different owner is denied.
- Every scope, including a nested one, independently enforces verified
  checkpoint policy before its action begins.
- `finally` removes the exact scope. The coordinator remains locked until the
  final scope leaves; then it clears ownership and records release time.
- Dart Zone inheritance preserves identity across awaits. Current Riverpod
  provider-construction tests prove provider evaluation sees the requesting
  Zone.

### Capability behavior

`ArchiveMutationCapability.requireOperation` succeeds only when:

1. the capability's typed operation matches;
2. the scope is still registered for that operation;
3. the current Zone owner ID matches;
4. the current Zone scope ID matches; and
5. the current Zone operation matches.

It therefore proves more than “some mutation is active.” It proves “this exact
async branch still holds this exact admitted operation scope.”

### Current Onboarding use

Onboarding currently calls `.run`, not `.runWithCapability`, for:

- first import;
- reimport;
- Continue Setup; and
- automatic recovery.

It therefore causes mutation ownership but throws away the one existing value
that could mechanically prove that the resulting maintenance is its own.

## 4. Exact provenance-loss point

Yes. The current environment-report path collapses **locked by this command**
and **locked by another command** into the same value.

The exact path is:

```text
ArchiveMutationCoordinatorState
  ownerId + activeOperations + private Zone scope
        |
        | select((state) => state.isLocked)
        v
onboardingEnvironmentReportProvider
  _OnboardingEnvironmentInputs.isMaintenanceLocked : bool
        |
        v
_OnboardingEnvironmentEvaluator._classifyState
        |
        v
OnboardingEnvironmentState.maintenanceInProgress
        |
        v
OnboardingEnvironmentReport (no owner/scope provenance)
        |
        v
OnboardingJourneyCoordinator._latestReport
        |
        v
command-specific report predicate
```

The decisive call site is the
`archiveMutationCoordinatorProvider.select((state) => state.isLocked)` watch
inside `onboardingEnvironmentReportProvider`. It is ORed with the already
coarse `dbMaintenanceLockProvider`, then stored only as
`_OnboardingEnvironmentInputs.isMaintenanceLocked`.

This is broader than the graph-reopen lock. `onboardingImport` and
`automaticRecovery` do not set `blocksDatabaseReopen`, but they still set
`isLocked`; therefore every admitted Onboarding command makes the environment
report classify maintenance.

The evaluator intentionally suppresses import/graph observational row counts
while maintenance is active. It also suppresses automatic-reset detection for
that observation. The resulting report truthfully says that aggregate
readiness is unavailable during mutation, but it cannot answer whether the
observer owns the mutation or whether a pre-admission policy was withdrawn.

## 5. Mechanical Impossibility invariant

The implementation contract must be:

```text
if no mutation owner:
    evaluate the exact positive command policy
    then attempt synchronous coordinator admission

if this exact command owns the admitted operation scope:
    prove it with ArchiveMutationCapability
    revalidate command/action/operation currentness
    revalidate fresh facts independent of the owned mutation
    do not let the command's own aggregate maintenance deny it

if another owner holds mutation authority:
    coordinator admission fails closed
    no command action and no capability are produced

if the capability is absent, stale, wrong-operation, or otherwise unproved:
    deny/fail closed
```

No command may reason that maintenance “probably” belongs to itself. Only the
coordinator-issued capability can establish that fact.

Conversely, no ownerless Boolean may overrule an exact active capability merely
because that capability itself caused the Boolean.

## 6. Selected design

### Selected: B + C

Use **separate post-admission prerequisites** together with the **existing
Ball/Track capability**.

The correction has two authorization moments.

#### Before admission

Immediately before calling the mutation coordinator, apply the unchanged
positive Prompt 12 predicate to the latest coherent non-admitted report:

- initial import -> `_reportAllowsInitialImport`;
- reimport -> `_reportAllowsReimport`;
- continuation -> `_reportAllowsInterruptedContinuation` for the exact
  snapshot; and
- automatic recovery -> `_reportAllowsAutomaticRecovery`.

The call to `runWithCapability` follows without an intervening await. `_run`
performs `_tryAcquire` synchronously before its first await. This makes the
handoff from positive Journey policy to exclusive mutation ownership one
continuous admission boundary.

Do not store or later reuse that report. The durable fact carried forward is
the admitted command identity, not a cached environment report.

#### After admission and after every relevant await

The coordinator validates an internal admitted-command context containing only:

- exact Journey action context/occurrence;
- private command token and command kind;
- expected mutation operation;
- expected operation ID/session/status where applicable; and
- the `ArchiveMutationCapability` supplied by `runWithCapability`.

It then checks the latest report as follows:

1. If the report is not `maintenanceInProgress`, run the unchanged exact
   positive command predicate. A real `readyToImport -> ready`,
   `ready -> readyToImport`, continuation superseded by `ready`, or
   `shouldReset == true -> false` transition still denies the stale command.
2. If the report is `maintenanceInProgress`, it may be neutralized **only**
   after `capability.requireOperation(expectedOperation)` succeeds for this
   exact async scope.
3. Even in that proved self-maintenance case, revalidate the report's fresh
   independent prerequisite facts. Messages/FDA, source presence/history, and
   Contacts outrank maintenance in the evaluator, so a genuine external
   regression remains visible and denies the command.
4. Revalidate the action/command occurrence and exact durable operation
   binding. For continuation, require the same UUID, process session, and
   interrupted status. For post-`begin` automatic reset, require the newly
   bound operation UUID.
5. Only then call `begin`, `resume`, or reset, with no await between the final
   combined check and the mutation boundary.

This does not “accept maintenance.” It accepts only one mechanically proved
relationship:

```text
this maintenance observation is the aggregate consequence of the exact
operation scope whose capability is valid in this async branch
```

The positive report predicates remain authoritative whenever the report
contains a complete, non-maintenance classification.

### Why the protected basis remains current

The mutation ball excludes any unrelated archive mutation during the admitted
scope. Therefore the app-owned facts that justified the exact command cannot
be changed by a competing mutation between pre-admission policy and the final
boundary.

Facts not protected by the ball—Messages/FDA, local source/history, and
Contacts—are still read fresh and revalidated after awaits. Durable operation
identity is independently revalidated through the snapshot controller and
Journey binding.

This is not a cached-report design. No old report is consulted after
admission. The proof is the conjunction of current command provenance, current
independent facts, current durable operation identity, and current capability.

## 7. Rejected alternatives

### A. Owner-aware global environment report

Rejected as the primary correction.

“Owned by me” is observer-relative. A single cached global report should not
change semantic meaning depending on which async branch reads it. Adding raw
owner IDs or mutable owner-relative readiness to
`OnboardingEnvironmentReport` would leak mutation authority into an evidence
DTO, complicate provider caching, and tempt presentation to interpret
ownership.

The report should continue to say that aggregate installation readiness is
temporarily unavailable during mutation. It should not become a mutation
capability.

### Current Boolean maintenance model alone

Rejected. It is useful diagnostic/read-suppression evidence but cannot prove
self versus foreign ownership. Treating all maintenance as permission would
weaken unrelated-maintenance exclusion; treating all maintenance as denial is
the current self-block.

### A new lease/token/generation

Rejected. `ArchiveMutationCapability` already provides opaque, exact-scope,
Zone-bound, release-bound proof. A new lease would create parallel mutation
authority and duplicate the existing scope identity.

### Reusing the last non-maintenance report

Rejected. That is the cached pre-admission report regression prohibited by
Prompt 14. It would miss independent prerequisite withdrawal and would make
report freshness a convention rather than a mechanical property.

### Skipping the post-await checks

Rejected. Prompt 12 correctly established those boundaries. This design
changes the facts supplied to the final decision, not the requirement for a
final decision.

### Allowing all `maintenanceInProgress`

Rejected. Maintenance without a valid exact-operation capability remains
fail-closed. A stale or wrong-operation capability also remains fail-closed.

## 8. Environment Report semantic role

`maintenanceInProgress` should mean:

> A process-local archive mutation is active, so ordinary aggregate readiness
> observation is intentionally incomplete and derived-store probes may be
> suppressed.

It is:

- an installation/diagnostic aggregate;
- owner-agnostic;
- not a graph failure;
- not an Onboarding blocker (`blockerKind` remains `none`);
- not proof that the installation is ready;
- not proof that the installation is unready; and
- not suitable as the final authorization answer for an already-admitted
  operation owner.

The report answers:

> What can an ordinary observer truthfully say about the installation now?

The admitted-command contract answers:

> May this exact command, which proves it owns the ball, cross its next
> mutation boundary now?

Those answers meet only inside `OnboardingJourneyCoordinator`. Presentation
receives the resulting Journey state and never sees or evaluates the
capability.

## 9. Post-admission authorization contract

For every final mutation boundary, all applicable clauses must pass:

```text
same Journey command token
+ same action occurrence and Episode
+ same prerequisite evidence occurrence where applicable
+ same operation UUID/session/status where applicable
+ exact ArchiveMutationCapability is active for expected mutation operation
+ latest independent external prerequisites permit the command
+ latest non-maintenance report still satisfies the exact positive predicate,
   OR the only unavailable portion is mechanically proved self-maintenance
   protecting the already-admitted app-owned predicate
= authorized mutation
```

If any clause fails:

- do not call `begin`, `resume`, or reset;
- retain/restore prior failed or interrupted evidence as already designed;
- derive the truthful Journey from complete non-maintenance evidence when
  available;
- never derive normal application merely from maintenance; and
- request a later fresh report after maintenance releases where appropriate.

Capability failure is an authority failure, not a soft “probably changed”
condition. It should fail closed through the existing coordinator-owned failure
path.

## 10. Command-specific Ball/Track interaction

### First import

- Pre-admission: require current `readyToImport`, or current accepted sparse
  local history; reject reset-required and external blockers.
- Ball: `ArchiveMutationOperation.onboardingImport` capability.
- Final checks: same Ready action/occurrence, valid capability, fresh external
  prerequisites, then `begin(initialImport)`.
- Self-maintenance alone cannot deny.
- A real non-maintenance transition to `ready`, reset-required state, or an
  external prerequisite Episode denies.

### Reimport

- Pre-admission: require current `ready`, no reset requirement, and no external
  blocker.
- Ball: `ArchiveMutationOperation.onboardingImport` capability.
- Final checks: same normal-application reimport action/occurrence, valid
  capability, fresh independent prerequisites, then `begin(reimport)`.
- Self-maintenance alone cannot deny.
- A real non-maintenance transition away from `ready` denies.

### Continue Setup

- Pre-admission: the reconciliation specialist must classify the exact
  interrupted snapshot as resumable.
- Ball: `ArchiveMutationOperation.onboardingImport` capability.
- Final checks: same Continue action/occurrence, valid capability, exact UUID,
  previous process session, interrupted status, current safe-boundary snapshot,
  and fresh external prerequisites, then `resume`.
- Self-maintenance alone cannot turn resumable interruption into unavailable.
- A real `ready` report, unsafe snapshot change, automatic-recovery kind, or
  external blocker denies.

### Automatic recovery

- Pre-admission: positively require
  `shouldResetAppDatabasesBeforeImport == true` and no external blocker.
- Ball: `ArchiveMutationOperation.automaticRecovery` capability.
- Before `begin`: revalidate the same command/action/capability and independent
  prerequisites.
- Before reset after progress persistence: also require the newly bound
  automatic-recovery operation ID.
- A self-maintenance report may not erase the reset requirement merely because
  maintenance suppresses the ordinary probes.
- A complete non-maintenance report that actually clears `shouldReset` still
  cancels the reset.

## 11. Production-realistic race-test design

The current `_ImmediateArchiveMutationCoordinator` is not valid proof for
these races because it never publishes ownership.

### Fixture design

Use the real `ArchiveMutationCoordinator` with a synthetic admitted **test**
archive authority. Override the environment-report provider with a controlled
report source that watches the real coordinator's `isLocked` state and models
production ordering:

- current external blockers retain their higher priority;
- otherwise a held mutation publishes `maintenanceInProgress`;
- an explicit controlled non-maintenance report can model genuine policy
  withdrawal; and
- completers signal when the lock-derived report has actually reached the
  Journey coordinator.

Use the real `runWithCapability` path. Do not construct a fake capability.
Hold controller acquisition or progress persistence with completers. Do not use
timing sleeps as the proof mechanism.

### First import

1. Start from valid Ready-to-Import.
2. Invoke the real Import action.
3. Observe real lock publication and the resulting maintenance report.
4. Hold controller acquisition until that report is accepted.
5. Release acquisition and assert `begin(initialImport)` occurs exactly once.
6. Repeat with a fresh FDA/Contacts/source blocker while held; assert no begin.
7. Hold a foreign mutation owner before invoking Import; assert admission is
   denied, no capability reaches the action, and no begin occurs.

### Reimport

Repeat the same sequence from canonical normal-ready state. Prove self-owned
maintenance reaches `begin(reimport)`, while foreign ownership and a genuine
non-maintenance transition away from ready do not.

### Continue Setup

1. Start from an exact resumable interrupted operation.
2. Invoke the real Continue Setup action.
3. Observe self-owned maintenance while controller acquisition is held.
4. Release and assert `resume` occurs for the same UUID exactly once.
5. Repeat with a foreign owner, external blocker, changed UUID/session/status,
   and complete `ready` report; each must leave `resume` untouched.

### Automatic recovery

1. Start with reset-required evidence.
2. Observe the real automatic-recovery lock and self-maintenance.
3. Prove self-maintenance alone does not cancel `begin`.
4. Hold resetting-progress persistence, observe self-maintenance again, and
   prove reset executes once after release.
5. In a separate held run, publish a complete non-maintenance report with
   `shouldResetAppDatabasesBeforeImport == false`; assert reset remains zero.
6. Hold a foreign owner or use a stale/wrong-operation capability path; assert
   automatic recovery remains fail-closed.

### Direct capability proof

Retain the existing coordinator tests and add/extend a focused assertion that
the capability used after an await:

- succeeds in its exact operation Zone;
- fails in a nested different scope;
- succeeds again after the nested scope exits; and
- fails after outer release.

The test suite must prove both halves of the invariant:

```text
self-owned lock does not deny
foreign or unproven lock does deny
```

## 12. `maintenanceInProgress -> OnboardingNormalApplication` finding

Classification: **OBSOLETE DRIFT**, and a bounded blocker to checkpointing the
current correction.

The historical compatibility rule had a legitimate narrow purpose:
established application maintenance should not masquerade as graph failure and
redirect the application into Onboarding. Mapping maintenance to
`OnboardingStatus.notNeeded` achieved that in the old Gate vocabulary.

The current unconditional typed mapping is stronger:

```text
maintenanceInProgress -> OnboardingNormalApplication
```

That is not generally safe. A maintenance report contains deliberately
suppressed derived-store evidence and cannot prove that first-run setup is
complete. Applied while first-run, failed, or interrupted work remains
outstanding, it can release normal application without durable completion and
without the canonical terminal human acknowledgement.

The bounded correction is:

- maintenance does not independently select a new Journey Episode;
- an already-normal Journey may remain normal during unrelated maintenance;
- a prerequisite, failed, interrupted, or active-operation Journey remains in
  its coordinator-owned state;
- an initial reconstruction with only maintenance evidence remains checking,
  not normal; and
- release of maintenance causes a complete fresh report to select the next
  truthful Episode.

The admitted-command path must not call `_journeyFromEnvironment` merely
because its own maintenance report was unsuitable for an exact predicate.

This does not require a broader Journey redesign, a maintenance Episode, or
presentation ownership. It is a small transition-policy correction inside the
existing sole coordinator. Therefore the Prompt 14 broad-redesign stop gate is
not triggered.

## 13. Bounded semantic-census corrections

### One raw-evidence policy set

Replace the differing `evidenceImplementationPaths` and
`intentAdapterEvidencePaths` policies with one unified raw-evidence set that
contains:

- environment/FDA evidence implementation;
- operation snapshot provider/controller evidence;
- reconciliation evidence; and
- Conversation Graph build controller implementation and feature barrel.

Use that exact set for:

- production-root side-door detection;
- intent-adapter transitive-stop proof; and
- bounded development/independent-graph exceptions.

Add a virtual semantic root -> wrapper -> raw graph/controller path and require
the full chain to be reported.

### `OnboardingStatus` roots

Extend `_sourceConsumesJourneySemantics` so `OnboardingStatus` is a root signal
when it controls production Onboarding routing, visibility, or presentation.
Add a virtual file containing only an `OnboardingStatus` semantic dependency
and prove it is discovered and traversed.

Retain narrow, mechanically proved exceptions for:

- the explicitly diagnostic development panel; and
- the independent Conversation Graph status sheet that does not decide
  Onboarding meaning.

No broader census redesign is required.

## 14. Final authority graph

```text
 Messages / FDA / history / Contacts probes
                    |
                    v
     owner-agnostic Environment Report
       (maintenance is diagnostic only)
                    |
                    +-------------------------------+
                    |                               |
                    v                               |
       OnboardingJourneyCoordinator                 |
       - sole Journey authority                     |
       - exact positive command policy              |
       - action/occurrence currentness               |
       - operation binding currentness               |
                    |                               |
                    | synchronous admission handoff |
                    v                               |
       ArchiveMutationCoordinator                   |
       - exclusive owner (“ball”)                   |
       - private Zone owner/scope/operation          |
       - runWithCapability                          |
          |                         |                |
          | foreign/unproved        | exact owner    |
          v                         v                |
        DENY                 admitted capability    |
                                      |             |
             fresh independent facts -+-------------+
             + Journey/action identity
             + operation identity
             + exact-scope capability
                                      |
                                      v
                         authorized command execution
                                      |
                                      v
                         durable operation evidence
                                      |
                                      v
                         OnboardingJourneyCoordinator
                                      |
                                      v
                         OnboardingJourneyState
                                      |
                                      v
                              presentation
```

There is no path from presentation to mutation ownership and no path in which
the owner asks the ownerless consequence of its own lock whether it owns the
lock.

The mechanically impossible state is:

```text
valid exact-scope capability
+ current command/action/operation identity
+ valid independent prerequisites
+ only self-induced aggregate maintenance
-> denied because maintenance is active
```

## 15. Smallest implementation boundary

1. Convert the four Onboarding mutation entries from `.run` to
   `.runWithCapability`.
2. Keep the four Prompt 12 positive report predicates.
3. Add the pre-admission positive check immediately before the synchronous
   coordinator handoff.
4. Replace the current post-admission report-only helper with one private
   admitted-command authorization contract that requires:
   - the expected capability/operation;
   - command and action currentness;
   - operation binding where applicable;
   - fresh independent prerequisite compatibility; and
   - the exact positive predicate for every complete non-maintenance report.
5. Make self-maintenance neutral only under valid exact-scope proof.
6. Make maintenance incapable of deriving normal application by itself.
7. Replace the immediate coordinator in the critical race fixture with the
   real lock-publishing coordinator/report relationship.
8. Add self/foreign/withdrawal tests for all four command classes.
9. Close only the two bounded census gaps.

No mutation-coordinator production change is expected. Its existing API and
capability are sufficient.

## 16. Expected changed files and symbols

### Production

`lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart`

- imports `ArchiveMutationCapability`;
- `_runNewInitialImport`;
- `_runNewReimport`;
- `continueInterruptedOperation`;
- `_runAutomaticRecovery`;
- replacement for `_latestReportAllowsCommand` at admitted boundaries;
- a private typed admitted-command/currentness helper; and
- maintenance transition handling in `_journeyFromEnvironment` and/or its
  ingestion callers.

No change is expected in:

- `ArchiveMutationCoordinator`;
- `ArchiveMutationCoordinatorState`;
- `ArchiveMutationCapability`;
- `OnboardingEnvironmentReport` persisted/data shape;
- snapshot-v1 serialization;
- `onboarding_operation_reconciliation.dart`;
- presentation; or
- generated Riverpod files.

If implementation proves one of those changes unavoidable, stop and re-review
the boundary rather than expanding silently.

### Tests

`test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`

- real coordinator/lock-aware fixture;
- first-import, reimport, continuation, and automatic-recovery self-maintenance
  races;
- foreign/unproven maintenance denials;
- independent prerequisite and non-maintenance exact-policy withdrawal; and
- maintenance-never-releases-normal-application coverage.

`test/architecture/onboarding_journey_authority_architecture_test.dart`

- unified raw-evidence side-door set;
- raw graph virtual path; and
- `OnboardingStatus`-only semantic root.

An optional focused addition to
`archive_mutation_coordinator_provider_test.dart` is acceptable only if the
existing exact-scope-after-await proof is not sufficient for review. It is not
required for the production correction.

### Documentation after implementation proof

The next implementation response should record the exact contract and test
results. Canonical Onboarding docs may receive a narrowly worded post-proof
clarification that maintenance is diagnostic aggregate evidence and admitted
commands use Ball/Track proof; that documentation is not a reason to broaden
production code.

Release metadata belongs to the eventual approved checkpoint, not this
read-only design response.

## 17. Explicit non-goals

- no change to sole Journey authority;
- no new Journey writer or report authority;
- no owner-aware presentation;
- no direct presentation evidence path;
- no new operation UUID or generation model;
- no public raw owner-ID API;
- no new mutation lease/capability type;
- no startup-adoption redesign;
- no prerequisite-precedence redesign;
- no failure-publication-order redesign;
- no snapshot-v1 format change;
- no schema or data migration;
- no archive-preservation change;
- no database-provider admission change;
- no automatic acceptance of all maintenance;
- no cached pre-admission report;
- no skipped post-await guard; and
- no unrelated Onboarding or Historical Archives UX work.

## 18. Open human decisions

None are required before a narrowly scoped implementation prompt.

The repository already answers the material design questions:

- exact-scope capability is the admitted-owner proof;
- Journey remains the sole semantic authority;
- Environment Report remains owner-agnostic evidence;
- unrelated/unproved maintenance fails closed;
- maintenance alone cannot release normal application; and
- presentation does not receive mutation provenance.

## 19. Stop gates

No Prompt 14 stop gate was reached.

- Earlier Ball/Track model found: **yes**.
- Trustworthy current owner provenance found: **yes**.
- Existing exact-scope capability sufficient: **yes**.
- New capability system required: **no**.
- Unrelated-maintenance fail-closed behavior weakened: **no**.
- Direct presentation evidence required: **no**.
- Second Journey/report authority required: **no**.
- Maintenance-to-normal issue requires broader Journey redesign: **no**;
  bounded transition correction only.
- Schema/data/archive migration required: **no**.
- New canonical-document contradiction found: **no**. The unconditional typed
  maintenance mapping is the already-identified implementation drift audited
  by Prompt 14, not a second canonical authority.

## 20. Recommendation for the next implementation prompt

Authorize one bounded implementation pass with this order:

1. introduce the real lock/report race fixture and failing self-versus-foreign
   tests;
2. cut all four commands to `runWithCapability`;
3. implement the combined admitted-command authorization contract;
4. correct maintenance transition behavior so it cannot create normal
   application;
5. add true non-maintenance predicate-withdrawal tests, including clearing
   `shouldResetAppDatabasesBeforeImport`;
6. close the raw-graph and `OnboardingStatus` census gaps;
7. run focused coordinator tests, the focused authority architecture test, the
   complete architecture suite, analyzer, and `git diff --check`; and
8. repeat the human architectural review before any checkpoint.

The implementation must stop if it cannot use the existing exact capability,
if a raw owner ID must escape the coordinator, if a global owner-relative
report is required, or if any presentation surface must learn mutation
ownership.

BALL-AND-TRACK AUTHORITY DESIGN COMPLETE: YES

MECHANICAL SELF-DENIAL CAN BE MADE IMPOSSIBLE: YES
