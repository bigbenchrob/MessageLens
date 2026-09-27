# MessageLens Feature 35
## 03 — Human Architectural Review Before Exclusive Authority Tenure Checkpoint

Date: 2026-09-25

## Executive verdict

The generic tenure mechanics and the archive adapter's ordinary execution path
are structurally sound: live proof is identity-based, release is exact-scope,
diagnostics are non-authoritative, and archive policy remains in
`ArchiveMutationCoordinator`.

The implementation is not yet safe to checkpoint. Three concrete SHOULD FIX
findings remain:

1. the fixed test key is a normal public enum value, so `@visibleForTesting`
   does not mechanically prevent production adoption;
2. refreshing/invalidating the keep-alive Riverpod provider rebuilds the same
   notifier after `_dispose` has made it permanently unavailable; and
3. several central stale-release and archive-capability claims are not tested
   at the exact boundary claimed by the implementation report.

There are no BLOCKER findings in the currently reachable production path, but
the Project Conformance standard requires SHOULD FIX findings to be resolved
before checkpoint.

## Reviewed against

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`
- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/10-ARCHITECTURE-CONTRACT.md`
- Feature 26
  `responses/07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md`
- Feature 34
  `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`
- the complete tracked and untracked Feature 35 implementation delta

## 1. Baseline and isolation verdict

**NO ISSUE.**

Feature 35 remains isolated in:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

- branch: `feature/exclusive-authority-tenure`
- HEAD/base: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream: `origin/main`
- ahead/behind: `0/0`
- index: empty
- tracked implementation delta: exactly three modified files
- untracked delta: only the approved generic essential, its tests,
  architecture test, and Feature 35 prompt/response records

The linked worktree's shared-instructions entry remains at
`95326f515ef4719f155ce6e223990398daad6311`; it is uninitialized in this
worktree, not a dirty pointer.

The frozen Onboarding worktree also remains at its expected branch, HEAD,
tracked/untracked counts, empty index, clean submodule, and preservation hashes.

## 2. Generic registry responsibility verdict

**NO ISSUE.**

`ExclusiveAuthorityRegistry` contains only typed-key occupancy, opaque tenure
identity, exact scope tracking, re-entry, current-proof validation, bounded
diagnostics, typed denial, and lifecycle revocation. It contains no archive,
Onboarding, database, FDA, Contacts, recovery, presentation, retry, wait,
timeout, or scheduling policy.

No domain policy leaked into the generic layer.

## 3. Typed-key verdict

**SHOULD FIX.**

`ExclusiveAuthorityKey.testOnlyIndependent` is declared as an ordinary public
enum member in
`lib/essentials/exclusive_authority/domain/exclusive_authority_key.dart:8`.
The `@visibleForTesting` annotation is advisory; any production file can import
and use the value. The public feature seam also exports the entire key type.

The architecture test currently requires the public value and its annotation
at `test/architecture/exclusive_authority_architecture_test.dart:84`, but does
not reject production references to `testOnlyIndependent`. Its adopter scan
looks only for `exclusiveAuthorityRegistryProvider` or
`ExclusiveAuthorityTenure`, so a production consumer that receives an
`ExclusiveAuthorityRegistry` by injection, or merely references the test key,
can evade the tripwire.

This is not a narrow library/test seam. Before checkpoint, make the independent
test key unavailable to ordinary production code, or add a mechanically closed
test seam plus an architecture rule that rejects every production reference to
it.

Production currently uses only `archiveMutation`; the finding is about the
boundary's mechanical enforceability.

## 4. Tenure opacity and proof verdict

**NO ISSUE.**

`ExclusiveAuthorityTenure` has a library-private constructor, default identity
equality, and private registry/tenure identities. Visible authority,
occurrence, and timestamp values are diagnostic only. There is no copy,
serialization, value-equality, revival, or public release path.

Proof requires the originating registry identity, the exact live tenure
object, and the exact private tenure identity. Equal key, occurrence, label,
or timestamp cannot recreate proof. A tenure from another registry fails.

## 5. Acquisition verdict

**NO ISSUE.**

`runExclusive` checks and publishes occupancy synchronously before invoking
the action. A live map entry and exact first scope exist before protected work
starts. Foreign denial occurs before the denied callback is invoked and does
not advance the occurrence. There is no check-then-await gap, queue, or second
live tenure within one registry instance.

## 6. Re-entry and hold-lifetime verdict

**NO ISSUE.**

`runReentrant` validates the exact current tenure before creating its exact
scope object. It reuses the same tenure and releases only that scope.

The child-outliving-outer test deliberately retains the returned child Future,
waits for the child's synchronous admission, allows the outer scope to finish,
and later awaits the child. The registry's identity set retains the Ball until
the child's final scope exits. The behavior is deliberate and counted rather
than an untracked ambient-Zone side effect.

## 7. Release/finally verdict

**NO ISSUE in implementation; SHOULD FIX in proof coverage.**

Both outer and re-entrant actions release in `finally`. Release compares the
current live tenure and removes the exact private scope identity before it can
alter hold count. A stale cleanup therefore cannot remove a scope belonging to
a later tenure. Original action failures are preserved.

The implementation is correct by inspection. The claimed matrix item for
"stale/double internal release" is not directly exercised, however; see the
test-quality finding below.

## 8. Provider-lifecycle verdict

**SHOULD FIX.**

The provider is keep-alive, owns no watched dependency, and has no global
singleton. Normal root-container lifetime is sound, container disposal revokes
proof, and multiple-container tests use distinct registry identities.

Explicit Riverpod refresh/invalidation is not soundly defined. `_dispose` sets
`_isDisposed = true`, while a NotifierProvider refresh calls `build` again on
the same notifier instance. `build` does not restore availability or establish
a new lifecycle identity. A narrow external probe established that after
`container.refresh(exclusiveAuthorityRegistryProvider)`:

- the notifier object is the same object;
- the old tenure is revoked; and
- every subsequent acquisition fails with
  `ExclusiveAuthorityProofDenialReason.registryDisposed`.

Thus a publicly exported provider can be permanently bricked for its container
by normal Riverpod invalidation. No current production code invalidates this
provider, so this is not an active production failure, but the lifecycle
contract is incomplete for a reusable authority foundation.

Before checkpoint, either make rebuild semantics explicitly safe or
mechanically forbid production invalidation/refresh and enforce that rule with
an architecture test. The chosen correction must not allow an old admitted
action and a replacement registry to authorize overlapping protected work.

## 9. Diagnostics verdict

**NO ISSUE in current production use; architecture guard included in Finding
1.**

Diagnostics contain only key, occupancy, occurrence, bounded labels,
timestamps, hold count, denial count, and release time. They contain no tenure,
registry identity, tenure identity, scope identity, or proof conversion.

A production search found no consumer using `isHeld`, label, or occurrence to
authorize work. The current tripwire does not mechanically prevent a future
consumer from doing so; the typed-key/adopter correction should close the
generic seam allowlist around all production consumers, not only two symbol
spellings.

## 10. Exception verdict

**NO ISSUE for the current sole-adopter contract.**

Busy acquisition and invalid proof are typed separately. Payloads contain no
private identities or tenure. Owner labels remain bounded diagnostics.
`ArchiveMutationCoordinator` translates the generic exception types to its
established archive denial type.

An OPTIONAL hardening is recorded below for the adapter's broad catch extent.

## 11. Archive-adapter ownership verdict

**NO ISSUE.**

The extraction removed only generic live-tenure admission. The archive
coordinator still owns operation kinds, checkpoints, environment/archive
identity diagnostics, nested archive scopes, operation aggregation, protected
resource actions, graph reopen policy, its private Zone, and exact archive
capabilities.

The archive active-scope map no longer admits a foreign owner. It is used for
archive policy, aggregation, resource decisions, and scope/capability
validation. The generic registry is the only ordinary acquisition authority.

## 12. Private-Zone verdict

**NO ISSUE.**

The Zone key and context remain library-private. The context carries exact
coordinator identity, generic tenure, archive scope ID, and operation. A
same-coordinator descendant presents that tenure to `runReentrant`; foreign
code cannot construct or discover the context. The generic registry does not
read the Zone and exposes no ambient current-tenure lookup.

## 13. Archive-capability verdict

**NO ISSUE in implementation; SHOULD FIX in isolated regression proof.**

Capability validation checks all required dimensions:

- requested operation equals the capability operation;
- exact archive scope remains active for that operation;
- current Zone carries the exact coordinator, tenure, scope, and operation;
- coordinator is not disposed; and
- the generic registry still recognizes the exact tenure.

Generic tenure alone therefore cannot grant archive resource access. The
implementation fails closed after scope release, tenure invalidation,
coordinator disposal, stale callback, wrong operation, and wrong Zone.

The tests do not isolate the underlying-tenure check from the other failure
dimensions; see section 17.

## 14. Stale-callback/reacquisition verdict

**NO ISSUE in source mechanics; SHOULD FIX in exact regression proof.**

Ball 1 and Ball 2 have distinct tenure objects and private identities. A stale
Ball 1 fails `runReentrant` and cannot change Ball 2's count. Archive capability
1 also closes over scope 1 and Ball 1, so it cannot validate against scope/Ball
2.

The archive regression currently invokes capability 1 from Ball 2's Zone. It
therefore fails for several reasons at once and does not reproduce the required
retained Ball-1 Zone callback while Ball 2 is live. The mechanism is correct by
inspection, but the most important regression sequence is not directly
demonstrated.

## 15. Concurrency-semantics verdict

**NO ISSUE.**

The implementation is in-memory and registry/container local. It claims no
cross-isolate, cross-process, durable, FIFO, fairness, starvation, timeout,
pre-emption, cancellation, or persistence semantics. Native single-instance
authority remains independent.

## 16. Architecture-tripwire verdict

**SHOULD FIX.**

The test correctly guards domain-ignorant imports, the current private
constructor spelling, absence of the current serialization/release/ambient
surfaces, current adapter use, presentation separation, and native-lock
separation.

It is not yet a complete mechanical tripwire for the approved boundary:

- it blesses a public test-only enum value and checks only the advisory
  annotation;
- its adopter scan can miss direct `ExclusiveAuthorityRegistry` injection and
  direct `ExclusiveAuthorityKey` use;
- it does not reject production references to `testOnlyIndependent`; and
- its diagnostics check proves that the diagnostic model lacks a tenure, but
  not that production code refrains from using `isHeld`, label, or occurrence
  as authorization.

These are concrete gaps in the rules Prompt 02 said the architecture test
would enforce. Strengthen the allowlist around imports/symbol use rather than
relying on names and comments.

## 17. Test-quality verdict

**SHOULD FIX.**

The deterministic Completer-based tests genuinely prove ordinary acquisition,
foreign denial before callback start, current proof across awaits, re-entry,
outer/inner failure cleanup, child lifetime, distinct occurrences, foreign
registry, disposal, diagnostics, equal labels, and absence of queuing.

Three reported claims are weaker than stated:

1. `stale proof cannot decrement or clear a newer tenure` invokes public
   `runReentrant` with a stale tenure. It proves pre-admission rejection and an
   unchanged hold count, but never exercises stale/double internal release.
2. `stale capability stays invalid after equal-label reacquisition` invokes
   the stale capability from the new tenure's Zone, not from a retained stale
   callback in the old Zone while Ball 2 is live.
3. `provider disposal invalidates capability in its retained Zone` disposes
   the entire container, so coordinator disposal and registry disposal happen
   together. It does not isolate the capability's exact-current generic-tenure
   grounding while the archive coordinator/scope otherwise remain active.

Add narrow deterministic proofs for those exact boundaries, or revise any
claim that cannot be reached without widening the production API. Do not add a
public release hook merely to make a test convenient.

## 18. Diff/scope verdict

**NO ISSUE.**

The complete delta contains only:

- the new generic essential and generated provider;
- the archive coordinator adapter and generated hash;
- generic, archive-regression, and architecture tests; and
- Feature 35 prompts/responses.

There are no Onboarding, Environment Readiness, presentation, database schema,
persisted format, native lock, archive configuration, or unrelated generated
changes. No duplicate generic tenure mechanism remains in the archive
coordinator. No speculative production adopter was added.

## 19. Concrete BLOCKER findings

**NO ISSUE — 0 BLOCKER findings.**

## 20. Concrete SHOULD FIX findings

1. **Test key is not mechanically test-only.** Public enum membership and
   `@visibleForTesting` permit ordinary production use.
2. **Provider rebuild lifecycle is incomplete.** Refresh/invalidation leaves
   the reused notifier permanently disposed; the public seam has no rule or
   tripwire forbidding that operation.
3. **Architecture tripwire is incomplete.** The adopter/key/diagnostic checks
   can miss production uses that violate the approved boundary.
4. **Central stale/release/capability test claims are not isolated.** The tests
   pass, but three named cases do not reach the exact mechanism claimed.

## 21. OPTIONAL findings

1. `ArchiveMutationCoordinator._run` catches generic denial types around the
   entire awaited registry action. With the current sole-adopter rule this is
   harmless. If a future archive action legitimately invokes another generic
   authority and that nested call throws one of these exceptions, the adapter
   would translate an action-body exception as though archive admission had
   failed. Revisit the catch boundary when a second adopter is actually
   approved; do not expand this feature pre-emptively.

## 22. Narrow tests rerun

The full suite was not rerun.

One temporary test outside both worktrees probed the unresolved Riverpod
lifecycle question:

```text
flutter test --no-pub \
  /private/tmp/exclusive_authority_provider_invalidation_probe_test.dart \
  --reporter expanded
```

Final result: **1 passed**. It established that refresh retains the same
notifier object, revokes the active tenure, and leaves later acquisition denied
as `registryDisposed`. The temporary probe was then deleted. Preliminary probe
expectations that refresh would construct a second notifier failed and were
corrected; no repository test failed.

Prompt 02's reported validation remains the supporting behavioral baseline:
21 generic, 16 archive coordinator, 18 combined resource/architecture, 497
architecture, 98 focused downstream, 2,639 full-suite passes with one
intentional skip, clean analyzer, clean generation, and clean diff check.

## 23. Exact Feature 35 Git status

At review completion, before adding this response, the index was empty and the
implementation status was:

```text
## feature/exclusive-authority-tenure...origin/main
 M lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart
 M lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart
 M test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
?? _AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/
?? lib/essentials/exclusive_authority/
?? test/architecture/exclusive_authority_architecture_test.dart
?? test/essentials/exclusive_authority/
```

This response is an additional intended untracked Feature 35 record. Nothing
is staged.

## 24. Frozen Onboarding verification

**NO ISSUE.**

The frozen worktree remains:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- tracked delta: 47 modified, 2 deleted
- untracked files with `--untracked-files=all`: 76
- intended untracked Journey projection and architecture test: present
- `git diff --check`: passed
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`

Preservation hashes remain unchanged:

| Artifact | SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| tracked frozen delta | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f487b15845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

The parked patch remains present and unapplied. No frozen file was edited,
staged, restored, switched, stashed, or cleaned.

## 25. Checkpoint recommendation

Do not checkpoint Feature 35 yet. Correct the four grouped SHOULD FIX findings,
rerun the affected narrow tests and architecture suite, and repeat this human
architectural review. No broad redesign is required.

FEATURE 35 HUMAN ARCHITECTURAL REVIEW: FAIL
