# MessageLens Feature 35
## 01 — Exclusive Authority Tenure Architecture Audit

Date: 2026-09-25

## Executive decision

MessageLens should extract the generic tenure mechanics already proven inside
`ArchiveMutationCoordinator`, while leaving every archive policy in that
domain coordinator.

The smallest useful production model is:

```text
ExclusiveAuthorityRegistry
  + closed typed ExclusiveAuthorityKey
  + opaque, occurrence-unique ExclusiveAuthorityTenure (the Ball)
  + identity-checked scoped acquisition/re-entry/release
  + bounded non-authoritative diagnostics
```

The generic registry should **not** know about archive operations, databases,
checkpoints, FDA, maintenance, Onboarding, presentation, or retry policy. It
should also not provide a public ambient `currentBall` lookup. Intentional
descendants receive the opaque tenure explicitly; a domain adapter may retain
its own private Zone context when that domain has already proven the need.

The first adopter should be `ArchiveMutationCoordinator`. It should delegate
only the single-live-tenure mechanism to the generic registry and retain:

- `ArchiveMutationOperation` and nested operation scopes;
- checkpoint policy;
- archive environment/instance diagnostics;
- protected-resource action policy;
- its private async Zone context; and
- `ArchiveMutationCapability` as exact archive-operation proof.

This yields the later Onboarding proof without making Onboarding or the
Environment Report an authority client of a new global state model:

```text
ExclusiveAuthorityRegistry proves current Archive Mutation tenure
  -> ArchiveMutationCoordinator proves exact admitted operation scope
  -> OnboardingJourneyCoordinator applies command/prerequisite policy
  -> presentation renders Journey only
```

No implementation is performed by this audit.

## 1. Frozen Onboarding worktree state

The primary worktree remains frozen at:

- repository:
  `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- HEAD subject: `docs(onboarding): restore journey-only authority`
- index: empty
- tracked delta: 47 modified files and 2 deleted files
- intended untracked implementation/test files:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check`: passed

The pre-existing parked patch remains present and unapplied:

- path:
  `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`
- size: 21,137 bytes
- SHA-256:
  `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`

The primary worktree was not staged, committed, stashed, reset, cleaned, or
switched. None of its tracked or untracked files was modified to create the
preservation backup.

## 2. Preservation backup and hashes

A preservation-only bundle was created outside the repository:

`/private/tmp/messagelens-feature35-onboarding-freeze.raq7aD`

Contents:

| Artifact | Size | SHA-256 |
| --- | ---: | --- |
| `tracked-onboarding-delta.patch` | 445,555 bytes | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| `untracked/lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart` | 2,204 bytes | `85a99027d0f487b15845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| `untracked/test/architecture/onboarding_journey_authority_architecture_test.dart` | 30,178 bytes | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| `MANIFEST.md` | preservation record | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

The tracked patch was created with full indexes and binary support. The two
intended untracked implementation files were copied with repository-relative
paths preserved because ordinary `git diff` cannot safely include them. The
bundle is not applied in Feature 35.

## 3. Feature 35 branch, worktree, and base

Refs were fetched before branch creation. The verified topology was:

| Ref | Commit |
| --- | --- |
| local `main` | `fe14793bbee8622b08829c4973a1e6ae218e8bb2` |
| `origin/main` | `fe14793bbee8622b08829c4973a1e6ae218e8bb2` |
| merge base | `fe14793bbee8622b08829c4973a1e6ae218e8bb2` |

Ahead/behind was `0/0`. The commit is:

`docs(integration): record main qualification`

It is the qualified Feature 34 integration tip. `origin/main` does not differ
from that previously integrated Feature 34 base, so the unexpected-divergence
stop gate did not apply.

Feature 35 was created as:

- branch: `feature/exclusive-authority-tenure`
- upstream: `origin/main`
- current worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`
- initial worktree before the approved human-workflow relocation:
  `/private/tmp/messagelens-feature-35-exclusive-authority-tenure`
- base/HEAD:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`

The linked worktree was moved in place after the audit, preserving its branch,
HEAD, prompt, and response. No existing worktree was deleted or repurposed.

## 4. Feature 35 folder structure

The isolated worktree now contains:

```text
35-EXCLUSIVE-AUTHORITY-TENURE/
├── prompts/
│   └── 01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md
└── responses/
    └── 01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md
```

The prompt is byte-identical to the supplied prompt in the frozen worktree.
No Feature 34 file was reorganized.

## 5. Rediscovered Ball/Track history

### VERIFIED HISTORY

1. The Architectural Constitution identifies the Import Execution Gate as
   **The Cricket Ball**, drawing on a railway single-track token: mutation work
   cannot enter the protected track without exclusive authority.
2. Before the current coordinator, the project had
   `GraphMaintenanceExecutionGate`. Its public `tryAcquire(String owner)` and
   `release(String owner)` model allowed same-string re-entry with a hold
   count. It expressed exclusivity but treated a human-readable owner string
   as proof. A stale release using a later-reused owner string could not
   distinguish tenure occurrences.
3. Commit `5790ceeae483e0bbe0e6051745b0376549cb264c`
   (`establish production archive protection and attachment recovery`,
   2026-07-28) replaced that gate with `ArchiveMutationCoordinator` and made
   it the process-local admission authority for all admitted-archive mutation.
   It added a private Zone key, unique owner sequence, same-owner re-entry,
   production checkpoint enforcement, and release in `finally`.
4. Historical Archive import later acquired mutation authority, caused the
   coarse database-maintenance Boolean to become true, and was denied the
   graph connection it legitimately required. Rich owner provenance had been
   collapsed to ownerless `track closed` evidence.
5. Feature 26 Audit 07 rejected provider pre-opening as an order-dependent
   workaround. It required caller-specific, operation-specific resource
   admission.
6. Commit `f638d0cbd6508a212674f470999e276994064bf3`
   (`restore owner-aware graph admission`, 2026-08-17) added truthful nested
   operation scopes, caller-specific resource admission, and tests proving
   Riverpod provider construction observes the requesting async Zone.
7. Commit `230479da114d410b0577c08d488869af4037250a`
   (`enable MessageLens archive recovery preflight`, 2026-08-22) added private
   scope identities and `ArchiveMutationCapability`. A capability is valid
   only for its exact active operation scope and current Zone, and becomes
   invalid on release or coordinator disposal.
8. Current code still contains those mechanics. The Feature 34 Onboarding
   freeze was caused by failing to carry this admitted-owner proof into a
   post-await command decision, not by absence of a working Ball/Track core.

### STRONGLY SUPPORTED INFERENCE

- The original public-string execution gate solved concurrent orchestration
  but did not yet model tenure occurrence robustly. Private generated owner and
  scope identities were introduced as concrete defects demanded stronger
  proof.
- `ArchiveMutationCoordinator` is now doing two jobs: a reusable exclusive
  tenure job and an archive-domain policy job. Extracting only the former is a
  natural consolidation of proven behavior, not a speculative framework.
- The current exact-scope archive capability should remain above the generic
  tenure. A generic Ball answers `who owns authority X now?`; it does not
  answer `which archive operation may open which resource?`.

### UNKNOWN

- Repository history does not establish a need for authority to cross Dart
  isolates, survive process restart, or be persisted. Feature 35 must not add
  those semantics.
- No fairness or FIFO requirement is documented. Immediate typed denial is
  therefore the smallest defensible behavior.
- No current domain other than archive mutation is proven to require a second
  generic authority key.

## 6. Existing owner/provenance implementation

The current archive owner chain is:

```text
private Zone key
  -> _ArchiveMutationAsyncContext
       ownerId: generated ownerLabel#sequence
       scopeId: monotonically increasing within coordinator instance
       operation: typed ArchiveMutationOperation
  -> _activeScopes[scopeId] = operation
  -> ArchiveMutationCapability private constructor
       operation
       closure back to exact current-scope validation
```

### Acquisition

`_tryAcquire` is synchronous. When free, it creates the first scope and
publishes the owner. When the private Zone context carries the same owner ID,
it creates a nested scope for the new operation. A caller without that private
context is foreign and denied.

### Async propagation

`runZoned` installs `_ArchiveMutationAsyncContext`. Dart async callbacks
registered in that Zone continue to observe it across ordinary `await`, Future,
microtask, and Timer boundaries. A separate isolate does not share the Zone or
the in-memory coordinator.

### Proof

- `resourceAdmissionForCurrentCaller` compares the private current Zone owner
  with the active coordinator owner and then applies archive operation policy.
- `ArchiveMutationCapability.requireOperation` checks the requested operation,
  the active scope map, coordinator disposal, and exact current Zone owner,
  scope, and operation.
- Feature code cannot construct the private async context or capability.

### Release and stale rejection

Every admitted scope releases in `finally`. Release removes the exact scope
ID. The tenure remains active while another same-owner scope remains. Once no
scope remains, the coordinator clears the owner. A retained capability then
fails because its scope is absent. Disposal also makes every old capability
fail.

Owner and scope counters are monotonic within one coordinator instance. Across
a rebuilt coordinator, old capabilities still close over the disposed old
instance and cannot become valid merely because diagnostic sequence values are
reused.

### Generic versus archive-specific responsibilities

Reusable tenure mechanics:

- one active owner per authority;
- unique private occurrence identity;
- opaque current-owner proof;
- intentional re-entry;
- hold/scope counting;
- identity-checked release;
- terminal stale-proof rejection;
- bounded owner/denial diagnostics.

Archive-specific mechanics that must remain in `ArchiveMutationCoordinator`:

- `ArchiveMutationOperation`;
- archive checkpoint requirements;
- archive environment and instance ID;
- nested operation-strength aggregation;
- `ArchiveMutationResourceAction` policy;
- graph/database reopen decisions; and
- exact archive-operation capabilities.

## 7. Project-wide analogous authority patterns

### A — likely adopter of the generic primitive

| Pattern | Classification rationale |
| --- | --- |
| `ArchiveMutationCoordinator` | The proven first adopter. Its occupancy, occurrence, re-entry, release, and current-proof mechanics are the generic primitive being extracted. |

No second authority key is justified by current evidence.

### B — conceptually similar but domain-specific

| Pattern | Why it should remain domain-specific |
| --- | --- |
| macOS `MessageLensSingleInstanceAuthority` / `flock` | Cross-process OS admission at bootstrap. A process-local Dart registry cannot replace a kernel-held filesystem lock. |
| `AttachmentArchiveWritableRootLease` | Proves location generation, configuration identity, root continuity, and write policy. It is a domain permission/currency lease, not mutual exclusion. |
| attachment adoption/remediation authorities | Bind verified evidence, transaction state, payload identity, and archive capability. They should compose with exclusive tenure, not be reduced to it. |
| `OnboardingJourneyCoordinator` | Sole semantic Journey writer with command/occurrence currentness. It decides workflow truth, not generic resource occupancy. |
| Presence `Schedule`/`Trip` occurrence and `_currentTripActivation` | Reject stale user interactions against a specific semantic episode. This is occurrence currentness, not a shared resource lock. |
| Search and stray-handle investigation generation IDs | Bind projections to a current investigation. They are compatibility identities, not live exclusive tenure. |
| `ConversationGraphBuildController._inFlight` | Coalesces callers onto one graph-build Future. Actual mutation exclusion already belongs to Archive Mutation. |
| Chat monitor and attachment-service in-flight Booleans | Local scheduling/deduplication controls. They neither confer authority nor need cross-component ownership. |
| `dbMaintenanceLockProvider` | Derived read-suppression/diagnostic evidence. It must never become acquisition or proof authority. |
| archive checkpoint receipts | Durable safety evidence required by domain policy. They do not establish live ownership. |

### C — unrelated

| Pattern | Why unrelated |
| --- | --- |
| Messages lineage admission authority | Validates candidate source lineage; there is no live exclusive owner. |
| FDA settings-opening authority | Adapter boundary for opening settings; no tenure semantics. |
| navigation, sidebar, cassette, tooltip coordinators | Presentation/routing coordination, not protected mutation ownership. |
| filesystem `create(exclusive: true)` | Atomic path creation primitive, not application authority tenure. |
| video-thumbnail `_inFlight` map | Per-key Future memoization and duplicate-work coalescing. |

This classification deliberately leaves the generic mechanism with one proven
key rather than turning every occurrence ID, Boolean, or class named
`Authority` into a registry client.

## 8. Recommended generic abstraction

Use a **registry with scoped execution and explicit opaque tenure proof**.

Recommended production terms:

- `ExclusiveAuthorityRegistry` — the Ball Czar;
- `ExclusiveAuthorityKey` — a closed typed authority name;
- `ExclusiveAuthorityTenure` — the opaque Ball;
- `ExclusiveAuthorityDeniedException` — busy/foreign admission denial; and
- `ExclusiveAuthorityProofDeniedException` — missing, wrong-key, wrong-registry,
  or stale proof.

Conceptual API:

```dart
Future<T> runExclusive<T>({
  required ExclusiveAuthorityKey authority,
  required String ownerLabel,
  required Future<T> Function(ExclusiveAuthorityTenure tenure) action,
});

Future<T> runReentrant<T>({
  required ExclusiveAuthorityTenure tenure,
  required Future<T> Function() action,
});

void requireCurrent({
  required ExclusiveAuthorityKey authority,
  required ExclusiveAuthorityTenure tenure,
});
```

Properties:

1. `runExclusive` synchronously acquires or synchronously determines denial
   before its first internal `await`.
2. A free key receives a new private tenure identity and one opaque tenure.
3. `runReentrant` succeeds only when explicitly presented with the exact live
   tenure; it reuses the same Ball and increments the active-scope count.
4. Both paths release their exact scope in `finally`.
5. A key becomes free only after every admitted scope for the same tenure has
   released.
6. `requireCurrent` consults registry-owned live state. The tenure object does
   not claim authority from cached local state.
7. Different keys have independent live entries.
8. There is no wait queue, retry timer, pre-emption, timeout, or workflow
   policy.

The registry should be process/isolate local and keep-alive for the provider
container lifetime. Disposal revokes all live tenures.

### Archive adapter shape

`ArchiveMutationCoordinator` should obtain/reuse the generic tenure, but keep
its existing private Zone context:

```text
outer archive operation
  -> registry.runExclusive(archiveMutation)
  -> private archive Zone context stores tenure + archive scope + operation

nested archive operation
  -> reads tenure only from private archive Zone context
  -> registry.runReentrant(tenure)
  -> creates a new archive operation scope
```

The generic registry does not inspect the archive Zone or operation. The
archive adapter deliberately translates its proven async lineage into an
explicit generic tenure presentation.

## 9. Rejected abstraction alternatives

### Public string-keyed registry

Rejected. Spelling differences silently create different tracks, and dynamic
strings allow feature code to invent authorities without architectural review.

### Public owner IDs or owner-label equality

Rejected. Labels are diagnostics, not proof. Reusing a label must never make a
stale release or callback current.

### Manual `acquire()` returning a publicly releasable lease

Rejected for the first version. It makes forgotten release, double release,
and stale release ordinary API states. Scoped execution with internal
identity-checked `finally` cleanup is smaller and safer.

### Global ambient `currentBall(authorityKey)`

Rejected. Dart Zones propagate to all async work registered inside them,
including detached work. An ambient lookup would let any code running in that
lineage discover authority without deliberate delegation. Explicit tenure
presentation makes propagation intentional.

### Zone-only generic authority

Rejected. Zone context is useful for the existing archive adapter and provider
construction, but it should not be the only generic proof. A protected action
must receive the opaque tenure or a domain capability that contains it and ask
the registry whether it is current.

### Hybrid manual lease plus `runWithLease`

Rejected initially. It introduces a second lifecycle mode and public release
without a demonstrated need. `runExclusive` plus explicit `runReentrant`
already covers the proven use case.

### Queueing/FIFO mutex

Rejected. Waiting, cancellation order, priority, and user feedback are domain
scheduling decisions. The generic primitive should fail closed immediately so
the domain may defer, retry, or surface busy state intentionally.

### Permissions/policy framework

Rejected. The registry answers only current exclusive tenure. Operation kinds,
resource permissions, prerequisites, and workflow state stay in domain code.

### Replacing the native instance lock

Rejected. Native `flock` protects against separate processes before Dart and
Riverpod exist. Feature 35 is a process-local layer beneath that admission.

## 10. Authority-key model

Use a closed typed key with no public constructor and exactly one initial key:

```dart
final class ExclusiveAuthorityKey {
  const ExclusiveAuthorityKey._(this.diagnosticName);

  static const archiveMutation = ExclusiveAuthorityKey._(
    'archiveMutation',
  );

  final String diagnosticName;
}
```

An enum is also type-safe, but a closed value type makes the non-extensible
constructor rule explicit and leaves room for carefully reviewed metadata
without a string factory.

Rules:

- no `fromString` production constructor;
- no arbitrary public constructor;
- no speculative keys;
- key equality comes only from the canonical constants;
- diagnostic names are never parsed back into authority; and
- adding a key requires an identified protected resource and conformance
  review.

The generic module may know the key's stable name but must not branch on its
domain meaning.

## 11. Ball/tenure model

`ExclusiveAuthorityTenure` should contain the minimum proof envelope:

- public typed authority key;
- public diagnostic occurrence number;
- optionally public issued-at timestamp for diagnostics;
- private registry-instance identity;
- private tenure identity; and
- no public owner identity.

The authoritative live/released state remains in the registry's map. The
tenure must not expose a cached `isCurrent` Boolean. Callers ask the registry
through `requireCurrent` (or a non-throwing typed proof query where a read-only
decision genuinely requires it).

Occurrence numbers are diagnostics only. Proof uses private object identity:

```text
same registry instance
AND same typed key
AND identical private live-tenure identity
AND registry not disposed
```

This prevents:

- construction by ordinary callers;
- replay by copying a sequence number;
- revival after release;
- revival after registry reconstruction with reused diagnostic counters;
- wrong-key use; and
- stale release affecting a newer tenure.

Do not override equality so that two tenures compare equal by visible fields.
Do not serialize a tenure.

## 12. Async propagation and re-entry model

### What Dart Zone propagation means

- Code invoked by `runZoned` sees that Zone synchronously.
- Future continuations, microtasks, and timers registered in the Zone normally
  execute in the same Zone.
- Awaiting does not by itself lose the Zone.
- Work created outside the Zone does not acquire it merely because it later
  interacts with a Future created inside.
- A spawned isolate has separate memory and does not inherit the Zone or live
  registry.
- Unawaited work created inside a Zone can retain the Zone after the creating
  callback returns.

The last property is why the generic primitive must not treat ambient Zone
presence as a universally discoverable Ball.

### Generic rule

Intentional propagation is explicit:

```text
runExclusive supplies Tenure 42
  -> caller passes Tenure 42 to intended descendant/service
  -> descendant calls requireCurrent or runReentrant with Tenure 42
```

An unrelated task without the object cannot prove authority. Capturing and
passing the opaque object is deliberate delegation. A callback that retained
the object but runs after terminal release is denied by the registry.

### Archive adapter rule

The archive coordinator may continue using its private Zone because:

- provider construction has already proven it observes the requesting Zone;
- feature code cannot read or forge the private Zone key/context;
- the adapter translates the private context into explicit
  `runReentrant(tenure)` calls; and
- archive mutation boundaries still validate the exact archive capability.

The generic registry itself does not expose or interpret that Zone.

### Nested authorities

- same key + exact current tenure: reuse the same Ball and add a scope;
- same key + no/wrong/stale tenure: typed denial;
- different free key: issue an independent Ball;
- different held key: typed denial for that key only.

Because there is no waiting queue, nested different-key requests cannot block
in a circular wait. They may still be denied; domain code decides what to do.

## 13. Acquisition, denial, release, and lifecycle semantics

| Case | Required behavior |
| --- | --- |
| Acquire free key | Succeed synchronously, issue a never-before-live private tenure identity, then run the action. |
| Acquire held key without current tenure | Throw typed busy/foreign denial before action starts. |
| Present current Ball for same key | Re-enter under the same Ball; add one exact active scope/hold. |
| Present Ball for another key | Throw typed proof denial. |
| Present Ball from another registry/container | Throw typed proof denial. |
| Nested same-owner protected operation | Reuse Ball; domain adapter may create its own narrower operation capability. |
| Action returns | Release that exact scope in `finally`. |
| Action throws | Release that exact scope in `finally`, then rethrow original failure. |
| Caller stops awaiting | No implicit cancellation; action retains tenure until its Future actually completes. |
| Action never completes | Tenure remains live; generic code does not time out or steal it. Diagnostics may expose age. |
| Root completes while explicitly re-entered child remains | Child hold keeps the Ball live until its admitted scope completes. |
| Explicit release request | Not a public API in v1; release is scoped/internal only. |
| Double/stale internal release | Identity check makes it unable to decrement or clear a different/newer tenure; assert/log in debug if useful. |
| Final scope release | Remove live entry immediately; Ball becomes permanently dead. |
| Reacquire after release | Issue a distinct Ball/identity and increment diagnostic occurrence. |
| Old callback after reacquire | Old Ball fails identity comparison even if key and owner label match. |
| Registry/provider disposal | Mark disposed and clear live entries; all issued Balls fail thereafter. |
| Process teardown | Authority disappears with memory; no durable authority record exists. |

Dart has no universal forced cancellation for arbitrary Futures. Feature 35
must not pretend otherwise. Cooperative cancellation may be domain policy, but
every protected mutation boundary must still validate current proof.

## 14. Diagnostics and privacy

The registry may publish an immutable read model containing only:

- authority key;
- free/live state;
- diagnostic tenure occurrence;
- bounded owner label;
- acquisition timestamp;
- active hold/scope count;
- bounded last-denial label/time/count; and
- last release timestamp.

Diagnostics must not contain:

- private registry identity;
- private tenure identity;
- a serializable proof token;
- message content;
- database or archive paths;
- source payloads;
- user data; or
- domain operation payloads.

Owner labels are descriptive text only. Equality of owner labels has no effect
on acquisition, re-entry, proof, or release.

Watching diagnostics must never grant a Ball. A Boolean such as `isHeld` may
help presentation or scheduling, but it is not an authorization decision.

## 15. Exhaustive primitive test matrix

Use a pure Riverpod/container fixture or direct registry harness and
`Completer` barriers. No timing sleeps.

1. Free `archiveMutation` acquisition issues Ball 1 and reports it current.
2. A foreign acquisition while Ball 1 is live is denied and its action never
   starts.
3. An intended async descendant explicitly given Ball 1 proves current after
   one or more awaits.
4. `runReentrant(Ball 1)` reuses Ball 1, increments hold count, and does not
   issue Ball 2.
5. Final release invalidates Ball 1 immediately.
6. Reacquisition issues Ball 2; Ball 1 remains invalid.
7. A stale callback presenting Ball 1 while Ball 2 is live is denied and
   cannot release Ball 2.
8. An exception inside the outer scoped action releases Ball 1 and preserves
   the original exception.
9. An exception inside a re-entrant scope releases only that scope; the still
   active outer scope remains current.
10. An unrelated async task not given Ball 1 cannot prove or re-enter even
    while Ball 1 is live.
11. A detached callback explicitly holding Ball 1 may prove it only while the
    Ball remains live; after terminal release it is denied.
12. Two different typed keys, using a test-only second key within the same
    library/test seam rather than a new production key, can be held
    independently.
13. Wrong-key Ball presentation fails closed.
14. Ball from another registry/container fails closed.
15. Double/stale internal release cannot decrement or clear a newer Ball.
16. Outer completion with an active explicitly re-entrant scope preserves the
    Ball until the last scope completes.
17. Registry disposal invalidates a live Ball and does not persist authority.
18. Diagnostics show live/free, occurrence, owner label, hold count, denial,
    and release without exposing proof identity.
19. Equal owner labels across two acquisitions do not make the old Ball
    current.
20. A denied acquisition does not consume a tenure occurrence or alter the
    current Ball.
21. No queue/fairness behavior is implied: after release, a newly attempted
    claimant is evaluated fresh.

The archive-adapter test suite must additionally prove that extracting the
registry preserves all current coordinator behavior:

- private Zone re-entry;
- exact nested operation scopes;
- stronger aggregate policies;
- checkpoint enforcement;
- resource admission;
- exact-scope capability invalidation; and
- existing denial diagnostics.

## 16. First Onboarding integration proof design

This integration is deliberately deferred until Feature 35 is implemented,
validated, reviewed, checkpointed, and integrated into `main`.

### Self-owned maintenance

```text
Onboarding command passes exact positive policy predicate
  -> ArchiveMutationCoordinator acquires Archive Mutation Tenure 42
  -> coordinator issues exact ArchiveMutationCapability for command scope
  -> maintenance/read-suppression becomes visible diagnostically
  -> command reaches post-await authorization
  -> capability revalidates exact operation scope
  -> capability's underlying Tenure 42 is still current in registry
  -> self-induced maintenance is not treated as a foreign conflict
  -> independent prerequisites and exact Journey command policy are checked
  -> command may continue
```

### Foreign owner

```text
foreign Tenure 43 owns Archive Mutation
  -> Onboarding acquisition is denied before its action begins
  -> Onboarding has no current archive capability/Tenure 43
  -> it cannot reinterpret maintenance as self-owned
```

### Stale callback

```text
Onboarding once owned Tenure 42
  -> all scopes release
  -> another occurrence may receive Tenure 43
  -> late callback retains old archive capability/Tenure 42
  -> registry and exact-scope validation both deny forever
```

Tenure proof establishes only mutation ownership. It does **not** establish:

- FDA;
- Messages/Contacts availability;
- reset requirement;
- local-history acceptance;
- operation resumability;
- exact Journey command/action occurrence;
- current operation binding; or
- success/failure/ready Journey outcome.

`OnboardingJourneyCoordinator` remains the sole authority for those semantic
decisions. `OnboardingEnvironmentReport` remains owner-agnostic diagnostic and
installation evidence. Presentation remains unaware of the Ball.

## 17. Expected Feature 35 production and test files

The next implementation prompt should authorize a bounded file set similar to:

### New generic essential

```text
lib/essentials/exclusive_authority/
├── application/
│   ├── exclusive_authority_registry_provider.dart
│   └── exclusive_authority_registry_provider.g.dart
├── domain/
│   ├── exclusive_authority_key.dart
│   ├── exclusive_authority_registry_state.dart
│   ├── exclusive_authority_denied_exception.dart
│   └── exclusive_authority_proof_denied_exception.dart
└── feature_level_providers.dart
```

The opaque tenure may live in the registry library so only that library can
construct it, while being exported as a type through the narrow public seam.
Do not add an `application.dart` convenience barrel.

### First-adopter changes

- `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`
- its generated provider file only if code generation changes it;
- `lib/essentials/archive_environment/feature_level_providers.dart` only if a
  public type seam genuinely changes; and
- no archive operation-policy file unless implementation proves a necessary
  mechanical adjustment.

The archive coordinator should translate generic denial into the existing
`ArchiveMutationDeniedException` so domain callers do not become coupled to
generic registry policy.

### Tests

- `test/essentials/exclusive_authority/application/exclusive_authority_registry_provider_test.dart`
- `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart`
- focused existing archive resource/capability regression tests;
- `test/architecture/exclusive_authority_architecture_test.dart`; and
- the complete existing architecture suite.

### Documentation/release metadata after proof

- Feature 35 implementation response;
- narrowly updated canonical execution-ownership documentation;
- Project Conformance rules only after the implementation proves enforceable
  checks;
- `CHANGELOG.md` and `pubspec.yaml` at the approved release-worthy checkpoint.

Not expected in Feature 35 implementation:

- Onboarding production or test files;
- presentation files;
- database schemas;
- native process-lock files;
- attachment archive configuration; or
- persisted formats.

If generic extraction requires broad call-site rewrites or changes archive
operation policy, stop and re-audit rather than expanding silently.

## 18. Git/integration plan back into frozen Onboarding

1. Keep `/Users/rob/Development/FlutterProjects/remember_every_text` frozen on
   `fix/onboarding-import-stuck-state` with its unstaged delta intact.
2. Implement and test the generic primitive in the separate Feature 35
   worktree/branch from `origin/main`.
3. Adapt `ArchiveMutationCoordinator` as the single proven adopter without
   changing Onboarding.
4. Run focused primitive/adaptor tests, architecture tests, full validation,
   analyzer, formatting, and diff checks.
5. Perform human architecture review and checkpoint Feature 35.
6. Integrate Feature 35 into `main` through the normal reviewed path.
7. Return to the frozen Onboarding worktree.
8. Verify the frozen delta and preservation hashes before integration.
9. Merge updated `main` into `fix/onboarding-import-stuck-state`; do not rebase
   or reconstruct the frozen work unless explicitly approved.
10. Resolve only genuine overlap with the existing archive coordinator seam.
11. Replace the Onboarding self-maintenance defect with exact current-tenure
    proof via `ArchiveMutationCapability`, while preserving Prompt 12/14
    command and prerequisite guards.
12. Repeat Onboarding architectural qualification from the frozen state.

No merge, rebase, cherry-pick, push, or checkpoint occurs in Prompt 01.

## 19. Future Project Conformance rules

After implementation proof, add enforceable rules equivalent to:

1. Every registered exclusive authority key has at most one live tenure per
   registry instance.
2. Only `ExclusiveAuthorityRegistry` can construct a tenure.
3. Re-entry requires the exact current tenure; owner labels and diagnostic
   occurrence numbers are never proof.
4. Protected mutation boundaries accept either the current tenure or a
   domain capability that mechanically revalidates it.
5. Released, wrong-key, wrong-registry, and disposed-registry tenures fail
   closed.
6. A stale release cannot alter a newer live tenure.
7. Generic authority code imports no Onboarding, archive, database, FDA,
   Contacts, UI, Presence, or recovery-policy modules.
8. Typed authority keys are closed; arbitrary strings cannot create tracks.
9. Diagnostics cannot be converted into or substituted for authority proof.
10. Queueing, retry, timeout, and workflow semantics remain outside the
    generic primitive.
11. Archive mutation remains the only initial production key/adopter until a
    separate audit proves another shared exclusive resource.
12. Native single-instance authority remains a distinct cross-process layer.

Candidate architecture tests should enforce import direction, private tenure
construction, absence of raw string-key APIs, absence of serialization, and
the approved first-adopter set.

## 20. Open human decisions

No architectural decision blocks a next design/implementation prompt.

One naming preference may be confirmed before implementation:

- recommended production name: `ExclusiveAuthorityTenure`;
- conceptual/review shorthand: Ball;
- rejected production implication: a time-expiring `Lease`, because v1 has no
  clock expiry or public release.

If the project prefers `ExclusiveAuthorityBall`, that is a terminology choice,
not a change to the contract. The response recommends `Tenure` because it
describes the full live occurrence and avoids implying a serializable token.

## 21. Stop gates encountered

No Prompt 01 stop gate was reached.

- Frozen branch/HEAD/index matched: **yes**.
- Frozen tracked/untracked implementation delta preserved: **yes**.
- Older parked patch unchanged and unapplied: **yes**.
- Local `main` unexpectedly diverged from `origin/main`: **no**.
- `origin/main` differed from the qualified Feature 34 integration base:
  **no**.
- Preferred Feature 35 branch/worktree already existed: **no**.
- Existing worktree had to be deleted or repurposed: **no**.
- Earlier Ball/Track mechanism found: **yes**.
- Trustworthy current owner/provenance proof found: **yes**.
- Generic extraction requires domain policy in the primitive: **no**.
- Second production authority key proven necessary: **no**.
- Schema/data/archive/native migration required: **no**.
- Onboarding implementation changed: **no**.

FEATURE 35 EXCLUSIVE AUTHORITY ARCHITECTURE AUDIT COMPLETE: YES

SAFE TO DESIGN/IMPLEMENT THE GENERIC BALL CZAR PRIMITIVE: YES
