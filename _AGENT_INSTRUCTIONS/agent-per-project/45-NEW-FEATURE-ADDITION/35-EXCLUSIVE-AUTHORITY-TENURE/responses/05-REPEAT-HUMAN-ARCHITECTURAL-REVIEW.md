# MessageLens Feature 35
## 05 — Repeated Human Architectural Review Before Checkpoint

Date: 2026-09-25

## Executive verdict

The current runtime implementation remains structurally sound. The generic
registry owns only live-tenure mechanics; exact identity rather than labels or
diagnostics proves authority; stale cleanup cannot affect a later tenure; and
the archive adapter retains all archive policy and requires the current generic
tenure beneath its exact operation capability.

The implementation is nevertheless not yet safe to checkpoint. The corrected
architecture suite still does not mechanically enforce several claims that
Prompt 04 and Prompt 05 require it to enforce:

1. its sole-production-key check can miss a differently spelled key
   declaration in the already-allowed key library, and its test-support scan
   excludes the entire generic production directory rather than only the two
   designated friend files;
2. its lifecycle rule catches only direct refresh/invalidate calls whose first
   argument is the unqualified current provider spelling, not an alias,
   prefixed reference, or equivalent indirection; and
3. its diagnostic/proof rule does not prevent the approved archive adapter
   from reading provider state through inferred types and using diagnostic
   fields as pseudo-authority.

There is no current production misuse behind any of those gaps, so they are
SHOULD FIX findings rather than BLOCKER findings. The Project Conformance
standard nonetheless requires their correction before checkpoint.

## Reviewed against

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`
- `responses/03-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md`
- `00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md`
- `55-READERS-INTEGRATORS-ORCHESTRATORS/10-ARCHITECTURE-CONTRACT.md`
- Feature 26
  `responses/07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md`
- Feature 34
  `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`
- the complete current tracked and untracked Feature 35 delta

## 1. Baseline and isolation verdict

**NO ISSUE.**

Feature 35 remains isolated in:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

- branch: `feature/exclusive-authority-tenure`
- HEAD/base: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream: `origin/main`
- ahead/behind: `0/0`
- index: empty
- shared-instructions pointer: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`; uninitialized rather than dirty

The tracked delta remains exactly the archive coordinator, its generated hash,
and its test. The untracked delta contains only the Feature 35 generic
essential, generated provider, two friend test-support parts, generic and
architecture tests, and Feature 35 prompts/responses. Prompt 04 introduced no
unrelated tracked work.

## 2. Generic-registry responsibility verdict

**NO ISSUE.**

`ExclusiveAuthorityRegistry` owns only:

- one live tenure per typed key;
- opaque registry and tenure identities;
- occurrence-unique acquisition;
- exact outer and re-entrant scope identities;
- current-tenure validation;
- exact-scope release in `finally`;
- fail-closed lifecycle revocation;
- bounded occupancy diagnostics; and
- typed acquisition/proof denial.

It contains no archive operation, checkpoint, database/resource, Onboarding,
FDA, Contacts, workflow, retry, presentation, or native-lock policy. Prompt 04
did not leak a domain concept into the generic layer.

## 3. Production/test-key boundary verdict

**SHOULD FIX.**

The current source has exactly one production key,
`ExclusiveAuthorityKey.archiveMutation`. The constructor is private, no string
or dynamic factory exists, and `ExclusiveAuthorityKeyTestSupport.independent`
is hidden by the public seam's `show ExclusiveAuthorityKey` export.

The remaining problem is mechanical enforcement:

- `exclusive_authority_architecture_test.dart:62-67` recognizes only the exact
  untyped spelling `static const name = ExclusiveAuthorityKey._(...)`. A second
  key declared in the already-allowed key file with an explicit type, a getter,
  or another constructor-expression shape would not change that match set.
- `exclusive_authority_architecture_test.dart:86-90` checks only the set of
  files containing the private-constructor spelling. It permits arbitrary
  additional constructor calls inside the already-allowed key file.
- `exclusive_authority_architecture_test.dart:175-180` scans only production
  files *outside* `lib/essentials/exclusive_authority`. It therefore does not
  reject a production generic-essential file that references either public
  friend helper. Because Dart `part` declarations join the parent library,
  those public helper symbols are visible to a direct importer of the parent
  implementation library; the architecture rule is the intended mechanical
  closure and must cover all production files except the two designated friend
  parts themselves.

No current production file commits those violations. The smallest correction
is to count every production constructor expression/declaration independently
of optional type spelling and to scan all `lib/` sources except the exact two
friend files for test-support symbols.

## 4. Tenure opacity/proof verdict

**NO ISSUE.**

`ExclusiveAuthorityTenure` has a library-private constructor and default
identity equality. Registry identity, tenure identity, live entries, and scope
identities remain private. Visible key, occurrence, and timestamp values are
diagnostic only.

`_requireLiveTenure` validates registry availability, requested key, originating
registry identity, exact live tenure object, and exact private tenure identity.
Released, stale, wrong-key, foreign-registry, and disposed proof fails closed.
There is no copy, serialization, revival, ambient lookup, or public release
surface.

## 5. Acquisition/re-entry verdict

**NO ISSUE.**

`runExclusive` publishes the live tenure and its first exact scope before the
admitted callback begins. Foreign denial occurs before the denied callback is
invoked and consumes no occurrence.

`runReentrant` requires the exact current tenure, adds an exact scope identity,
and reuses the same Ball. Nested hold counting is set-based and exact. A child
that was deliberately admitted before its outer scope completes keeps the Ball
live until its own scope completes. No queue, fairness, timeout, or pre-emption
semantics appeared.

## 6. Release/finally verdict

**NO ISSUE.**

Both acquisition paths release through `_runScope` in `finally`. `_releaseScope`
requires the currently mapped tenure, exact tenure identity, and exact scope
identity before it can remove a hold. It removes the live entry only after the
last exact scope exits. Original action failures are preserved.

## 7. Provider-lifecycle verdict

**SHOULD FIX in architecture enforcement; NO ISSUE in current runtime use.**

The selected Option A runtime contract is coherent:

- the provider is keep-alive;
- the registry watches/listens to no dependency;
- ordinary framework behavior has no rebuild trigger;
- the notifier remains usable for sequential acquisitions during its normal
  ProviderContainer lifetime; and
- ProviderContainer disposal permanently revokes its tenures.

The source and generated documentation no longer claim refresh support.

The prohibition is not yet enforced against equivalent production usage.
`exclusive_authority_architecture_test.dart:187-189` requires the unqualified
token `exclusiveAuthorityRegistryProvider` immediately after the opening
parenthesis of `.invalidate(...)` or `.refresh(...)`. It does not catch, for
example, a locally aliased provider, a prefixed import reference, or a helper
call that receives the provider before invalidating it. The sole-adopter rule
would still allow such code inside `ArchiveMutationCoordinator`.

The smallest correction is to constrain every production occurrence of the
provider symbol in the approved adapter to the one allowed notifier-read shape,
in addition to rejecting direct refresh/invalidate syntax. That closes aliases
and wrapper handoff without attempting a general Dart parser.

## 8. Diagnostics/adopter verdict

**SHOULD FIX in architecture enforcement; NO ISSUE in current production
source.**

The current production census finds one importer and symbol consumer only:
`ArchiveMutationCoordinator`. The adapter asks the registry notifier for exact
current-tenure proof. It does not read generic diagnostic state.

The architecture test does not fully protect that fact.
`exclusive_authority_architecture_test.dart:218-246` looks for the two
diagnostic type names outside the generic root and checks only that the
registry's own `_requireLiveTenure` body avoids diagnostic fields. The approved
archive adapter can instead infer the state type through
`ref.read(exclusiveAuthorityRegistryProvider)`, then consult
`diagnosticFor(...).isHeld` or another diagnostic field without spelling either
diagnostic type. It would remain the approved importer and the current test
would pass.

The adapter's generic-provider use should be mechanically limited to the
notifier proof path, or the adapter should be scanned for state/diagnostic
authorization expressions. Current proof does terminate at registry live
identity; the finding concerns preserving that invariant.

## 9. Exception verdict

**NO ISSUE.**

Busy acquisition and invalid proof remain distinct typed exceptions with no
private identity payload. The archive boundary translates both to the existing
archive denial type, so domain callers do not acquire a generic exception
dependency.

The broad catch extent around the awaited archive action remains the previously
accepted OPTIONAL future-second-adopter concern.

## 10. Archive-adapter ownership verdict

**NO ISSUE.**

`ArchiveMutationCoordinator` still owns operation kinds, production checkpoint
requirements, environment/archive-instance diagnostics, archive scope IDs,
nested operation aggregation, resource admission, graph/database reopen
policy, private Zone lineage, and `ArchiveMutationCapability`.

The generic registry alone decides whether a foreign owner can acquire the
archive-mutation track. `_activeScopes` does not deny acquisition; it records
and validates archive-domain policy after generic admission.

## 11. Private-Zone verdict

**NO ISSUE.**

The Zone key and context are private. The context carries the exact coordinator
identity, generic tenure, archive scope ID, and operation. Same-coordinator
descendants present the exact tenure to `runReentrant`; foreign or stale
lineage fails. The generic registry neither reads nor exposes the Zone.

## 12. Archive-capability grounding verdict

**NO ISSUE.**

Capability validation requires the requested operation, exact active archive
scope, exact current private Zone context, live coordinator, and exact current
generic tenure.

The isolated regression deliberately creates a state that public production
APIs cannot create: it replays the exact generic scope cleanup while the archive
scope and Zone are still active. That is a valid unit proof because it isolates
the final generic `requireCurrent` condition and reaches the real production
release implementation. Normal production ordering makes this state
unrepresentable: the archive scope releases inside the generic action before
the generic scope's ordinary `finally` runs. The later ordinary cleanup is an
identity-checked no-op.

This proof remains acceptable once the architecture guard truly prevents the
friend seam from every non-friend production file.

## 13. Stale internal-release verdict

**NO ISSUE.**

The new test captures Ball 1's exact `_LiveExclusiveAuthority` and exact scope
identity, lets normal Ball-1 cleanup complete, acquires and holds Ball 2, then
replays Ball-1 cleanup twice through production `_releaseScope`.

The replay cannot match Ball 2's tenure object/private identity and therefore
cannot reach its scope removal. Ball 2 remains current with hold count 1 and
completes normally. No public release API was added.

## 14. Stale callback/reacquisition verdict

**NO ISSUE.**

The stale callback is registered by `.then(...)` while Ball 1's archive action
is executing inside Ball 1's private Zone. Dart executes the registered
continuation in that registration Zone even though its completer is fulfilled
later.

Ball 1 fully releases before Ball 2 is acquired with the same owner label.
While Ball 2 is live, the retained Ball-1 callback uses capability 1 and is
denied. Ball 2's owner ID and hold count remain unchanged, and capability 2 is
still valid. This isolates old lineage rather than merely invoking capability 1
from Ball 2's Zone.

## 15. Architecture-tripwire verdict

**SHOULD FIX.**

The suite correctly protects current import direction, private tenure
construction, no serialization/public release/ambient lookup, the current sole
adopter, presentation separation, and native-lock separation. It does not yet
mechanically protect all semantically equivalent violations required by Prompt
04 and Prompt 05:

1. sole production key detection depends on one declaration spelling;
2. test-support consumption ignores generic production files;
3. lifecycle prohibition depends on the provider token being the direct,
   unqualified first argument; and
4. diagnostic-state authorization in the allowed adapter can use inferred
   types and evade the diagnostic-symbol scan.

These are bounded architecture-test defects. They do not require changing the
production authority design.

## 16. Test-quality verdict

**NO ISSUE for behavioral proof.**

The generic tests deterministically reach foreign denial before action start,
explicit proof across awaits, exact re-entry, exception cleanup, detached
proof, wrong key, foreign registry, stale Ball 1 while Ball 2 lives,
child-outliving-outer scope, disposal, equal labels, occurrence preservation,
no queue, and exact stale/double internal cleanup.

The archive tests deterministically reach private-Zone nesting, exact archive
scope capability checks, retained old-Zone stale use, isolated generic-tenure
grounding, operation aggregation, checkpoint enforcement, resource admission,
and disposal. Completers/Futures establish ordering; no timing sleeps are used.

The architecture test deficiencies are reported separately rather than
mischaracterized as failures of the runtime regression tests.

## 17. Concurrency-semantics verdict

**NO ISSUE.**

The model is registry/container local and in-memory. It claims no cross-isolate,
cross-process, durable, FIFO, fairness, timeout, cancellation, stealing, or
persistence semantics. Native single-instance authority remains separate.

## 18. Diff/scope verdict

**NO ISSUE.**

The complete delta contains only:

- the generic exclusive-authority essential and generated provider;
- its two test-only friend parts;
- the archive coordinator adapter and generated hash;
- generic, archive, and architecture tests; and
- Feature 35 prompt/response records.

There is no Onboarding, Environment Readiness, presentation, database schema,
persisted-format, native-lock, attachment-configuration, privacy, dependency,
or unrelated generated change. No second production adopter or duplicate
tenure implementation exists.

## 19. Concrete BLOCKER findings

**NO ISSUE — 0 BLOCKER findings.**

## 20. Concrete SHOULD FIX findings

1. **Production/test-key and friend-seam enforcement is incomplete.** The key
   census recognizes only one declaration spelling, and the production-use
   scan excludes the entire generic root rather than only the designated friend
   files.
2. **Unsupported provider refresh/invalidation is not fully guarded.** Alias,
   prefixed, or wrapper-mediated uses can evade the direct-call regex in the
   approved adapter.
3. **Diagnostic/proof separation is not fully guarded.** The approved adapter
   can read provider state through inferred types and use diagnostic values as
   authorization without triggering the diagnostic-type scan.

All three are bounded architecture-test corrections. No production-code
redesign is indicated by this review.

## 21. OPTIONAL findings

1. `ArchiveMutationCoordinator._run` catches generic denial types around the
   entire awaited registry action. With one approved adopter this remains
   harmless. Revisit only if a future second authority adopter is separately
   approved.

## 22. Narrow tests rerun

None. Source inspection resolved the review questions, and Prompt 05 directs
that the full repository suite not be rerun. Prompt 04's reported validation
remains the behavioral baseline:

- generic suite: 23 passed;
- archive coordinator: 17 passed;
- combined focused regressions: 85 passed;
- Feature 35 architecture: 14 passed;
- complete architecture suite: 501 passed;
- analyzer: clean;
- filtered generation: consistent; and
- Prompt 04 `git diff --check`: passed.

## 23. Exact Feature 35 Git status

At review completion, before adding this response:

- branch: `feature/exclusive-authority-tenure`
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream: `origin/main`
- ahead/behind: `0/0`
- index: empty
- tracked modifications: exactly three
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart`
  - `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart`
- untracked: five Feature 35 prompts, the first four Feature 35 responses, the
  generic essential and its generated/test-support files, the Feature 35
  architecture test, and the generic registry test
- shared-instructions pointer: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`; uninitialized, not dirty

This response is the fifth intended untracked Feature 35 response. Nothing is
staged.

## 24. Frozen Onboarding verification

**NO ISSUE.**

The frozen worktree remains:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- tracked delta: 47 modified, 2 deleted
- fully enumerated untracked files: 76
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check`: passed

Preservation hashes remain:

| Artifact | SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| tracked frozen delta (`git diff --binary --full-index`) | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f487b15845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

The parked patch remains present and unapplied. No frozen file was edited,
staged, restored, switched, stashed, or cleaned.

## 25. Final checkpoint recommendation

Do not checkpoint Feature 35 yet. Correct the three bounded architecture-test
findings, rerun the Feature 35 architecture test and complete architecture
suite, and then repeat the human architectural gate. Runtime production code
does not presently require redesign.

`PROJECT CONFORMANCE: FAIL`

REPEATED FEATURE 35 HUMAN ARCHITECTURAL REVIEW: FAIL
