# MessageLens Feature 35
## 04 — Correct Pre-Checkpoint Architectural Review Findings

Date: 2026-09-25

## Outcome

All four SHOULD FIX findings from Prompt 03 are corrected without changing the
approved authority model.

Production now has one constructible authority key, `archiveMutation`.
Independent-key and exact-cleanup tests use non-exported friend part files, and
architecture tests prohibit any production reference to those test seams.
Registry refresh/invalidation is explicitly unsupported and mechanically
rejected in production; ProviderContainer disposal remains the sole supported
revocation boundary. The previously under-isolated stale-cleanup and archive
capability cases now reach the exact production identity checks they claim.

The implementation remains unstaged and uncommitted.

## 1. Baseline and isolation

**PASS.**

Feature 35 remained isolated in:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

- branch: `feature/exclusive-authority-tenure`
- HEAD/base: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream: `origin/main`
- ahead/behind: `0/0`
- index: empty

Before correction, the delta still contained only the approved Feature 35
implementation, tests, generated output, prompts, and responses. Prompt 03 had
changed only its response record.

The frozen Onboarding worktree matched its expected branch, HEAD, empty index,
47 modified/2 deleted tracked files, 76 fully enumerated untracked files,
clean shared submodule, and preservation hashes before correction. It was not
used for implementation.

## 2. Test-only key correction

`ExclusiveAuthorityKey` is now a final closed value type with a private
constructor and one production constant:

```text
ExclusiveAuthorityKey.archiveMutation
```

The former public enum value was removed. Independent-key tests use
`ExclusiveAuthorityKeyTestSupport.independent`, declared in a `part` file of
the key library so it can reach the private constructor.

That friend seam is not exported by `feature_level_providers.dart`; the public
export uses `show ExclusiveAuthorityKey`. A production source can no longer
receive the test helper through the approved Feature 35 seam, and the
architecture suite rejects direct production references to the helper,
`testOnlyIndependent`, or another test-only authority mechanism.

No public constructor, string factory, dynamic key API, or second production
key was introduced.

## 3. Production key/adopter tripwire correction

The Feature 35 architecture test now proves:

- the key source declares exactly one production constant;
- only the key library and its designated friend part construct keys;
- the public seam hides both test-support parts;
- no production source outside the generic essential references a test-only
  authority symbol or diagnostic name;
- every production import of the generic essential belongs to
  `ArchiveMutationCoordinator`;
- an expanded symbol census catches direct registry injection, tenure use,
  key use, exception use, provider use, and diagnostic-state use; and
- adding a production key or adopter requires an intentional test update.

The importer check parses both one-line and multi-line Dart imports.

## 4. Selected provider lifecycle contract

**Option A — refresh/invalidation is unsupported and mechanically
prohibited.**

The registry is keep-alive for exactly one ProviderContainer lifetime. It has
no watched/listened dependency and therefore no ordinary framework-driven
rebuild trigger. Container disposal is the sole supported revocation boundary
and permanently invalidates every tenure from that registry lifecycle.

Production calls to `invalidate` or `refresh` with
`exclusiveAuthorityRegistryProvider` are rejected by architecture validation.
The registry itself is also checked for `ref.watch`, `ref.listen`, and
`invalidateSelf`.

The implementation does not reset `_isDisposed` or construct a replacement
registry that could overlap an admitted old action.

## 5. Lifecycle tests

The generic suite now explicitly proves that:

- the same notifier remains stable across ordinary asynchronous work for the
  container lifetime;
- sequential acquisitions remain usable and advance occurrence identity; and
- ProviderContainer disposal invalidates a live tenure.

The architecture test proves production cannot opt into the unsupported
refresh/invalidation lifecycle. No test implies refresh is a supported runtime
operation.

## 6. Diagnostic/proof tripwire correction

The architecture suite now combines two mechanical properties:

1. `ArchiveMutationCoordinator` is the only production importer/consumer of
   the generic authority essential, and it does not import diagnostic state;
2. `_requireLiveTenure` is checked to consult `_liveAuthorities` rather than
   Riverpod diagnostic state, `isHeld`, owner labels, occurrence values, or
   timestamps.

Therefore current production code cannot substitute the observable read model
for tenure/capability proof without failing architecture validation.

Presentation/workflow tenure separation and native single-instance separation
remain enforced.

## 7. Stale internal-release proof

A non-exported registry friend seam can capture one exact live production
scope identity and later replay its cleanup through the real `_releaseScope`
implementation.

The new deterministic test proves:

```text
Ball 1 / scope 1 acquired
-> exact scope-1 cleanup captured
-> Ball 1 releases
-> Ball 2 / scope 2 acquired and held
-> stale scope-1 cleanup replayed twice
-> Ball 2 remains current
-> Ball 2 hold count remains 1
-> Ball 2 completes normally
```

No public release API was added. The friend seam is hidden from the public
provider export and forbidden to production consumers by architecture tests.

## 8. Retained old-Zone capability proof

The equal-label archive regression was strengthened.

Capability 1 now registers an asynchronous callback while executing inside the
Ball-1 archive Zone. Ball 1 then fully releases. Ball 2 is acquired with the
same owner label and remains live while that registered callback executes in
its retained Ball-1 Zone.

The test proves:

- capability 1 is denied from its retained old lineage;
- Ball 2's owner identity and hold count remain unchanged; and
- capability 2 remains valid.

This no longer relies on calling stale capability 1 from Ball 2's Zone.

## 9. Generic-tenure grounding proof

The registry friend seam also enables an exact isolated proof without changing
production lifecycle behavior.

While an archive scope, coordinator, capability, and matching archive Zone are
all still active, the test releases the exact underlying generic registry
scope through production `_releaseScope`. The archive scope remains present
and the coordinator remains undisposed, but capability validation fails.

This reaches `ArchiveMutationCapability`'s generic `requireCurrent` grounding
independently of archive-scope release, wrong Zone, or coordinator disposal.
The registry's ordinary `finally` cleanup later replays the same scope cleanup
as a harmless exact-identity no-op.

## 10. Claims narrowed

None.

All three previously under-isolated claims are now directly and
deterministically proved. No impossible production state or widened public API
was introduced.

## 11. Changed files

Prompt 04 corrected or added:

```text
lib/essentials/exclusive_authority/application/
  exclusive_authority_registry_provider.dart
  exclusive_authority_registry_provider.g.dart
  exclusive_authority_registry_test_support.dart

lib/essentials/exclusive_authority/domain/
  exclusive_authority_key.dart
  exclusive_authority_key_test_support.dart

lib/essentials/exclusive_authority/
  feature_level_providers.dart

test/essentials/exclusive_authority/application/
  exclusive_authority_registry_provider_test.dart

test/essentials/archive_environment/application/
  archive_mutation_coordinator_provider_test.dart

test/architecture/
  exclusive_authority_architecture_test.dart

_AGENT_INSTRUCTIONS/.../35-EXCLUSIVE-AUTHORITY-TENURE/
  prompts/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md
  responses/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md
```

No Onboarding, Environment Readiness, presentation, database schema, persisted
format, native lock, archive configuration, or real-data file changed.

## 12. Focused generic results

`exclusive_authority_registry_provider_test.dart`:

- **23 passed**
- includes stable container lifetime and exact stale/double cleanup proof
- no timing sleeps

## 13. Archive regression results

`archive_mutation_coordinator_provider_test.dart`:

- **17 passed**
- includes retained Ball-1 Zone and isolated generic-tenure grounding proofs

Combined generic, coordinator, scoped persistent-provider, approval
revalidation, recovery batch, and recovery installer run:

- **85 passed**
- existing Drift multiple-database debug warnings only
- no failures

## 14. Architecture results

Feature 35 architecture test:

- **14 passed**

Complete architecture suite:

- **501 passed**
- no failures

## 15. Analyzer result

`flutter analyze --no-pub`:

- **passed**
- no issues

## 16. Generation result

Filtered build generation was run for the generic registry and archive
coordinator provider outputs.

The final generation pass reported the generated outputs as unchanged/same.
No unrelated tracked generated file changed.

## 17. Diff check

`git diff --check` passed.

Changed Dart files were formatted. The new untracked files contain no trailing
whitespace.

## 18. Project Conformance verdict

Reviewed specifically against the four Prompt 03 findings, the Feature 35
audit/design, the Architectural Constitution, the Reader/Integrator/
Orchestrator execution-ownership contract, Feature 26 owner-aware admission,
and the Project Conformance Audit Standard.

- approved production keys only: PASS
- test-only machinery unavailable through the public seam and forbidden to
  production: PASS
- provider lifecycle explicitly defined and enforced: PASS
- sole generic production adopter: PASS
- diagnostics cannot authorize: PASS
- stale cleanup cannot alter a newer tenure: PASS
- archive capability grounded in current generic tenure: PASS
- archive policy remains domain-owned: PASS
- no second adopter: PASS
- no Onboarding dependency/change: PASS
- privacy/data safety: PASS
- generated/dependency hygiene: PASS

`PROJECT CONFORMANCE: PASS`

## 19. Remaining BLOCKER findings

**0.**

## 20. Remaining SHOULD FIX findings

**0.**

## 21. OPTIONAL findings

The Prompt 03 observation about the archive adapter's broad generic-exception
catch remains optional and unchanged. It concerns a hypothetical future second
adopter; there is still only one approved adopter, and Prompt 04 did not touch
that catch boundary.

## 22. Exact Feature 35 Git status

The branch remains `feature/exclusive-authority-tenure` at
`fe14793bbee8622b08829c4973a1e6ae218e8bb2`, tracking `origin/main` at `0/0`.

The index is empty. The only tracked modifications remain:

```text
 M lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart
 M lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart
 M test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
```

The untracked files are the four Feature 35 prompts, four Feature 35 responses,
the generic essential (including its two friend test-support parts and
generated provider), the Feature 35 architecture test, and the generic
registry test. Nothing is staged.

The shared-instructions pointer remains unchanged at
`95326f515ef4719f155ce6e223990398daad6311`; it is uninitialized, not dirty, in
this linked worktree.

## 23. Frozen Onboarding verification

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
| tracked frozen delta | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f487b15845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

The parked patch remains present and unapplied. No frozen file, real database,
or real archive was accessed or modified.

## 24. Stop gates

No stop gate was encountered.

- baseline mismatch: no
- frozen preservation mismatch: no
- Dart privacy required a second production key: no
- provider rebuild support required unsafe overlap: no; Option A selected
- public release API required for proof: no
- second adopter required: no
- Onboarding change required: no
- real data required: no
- implementation scope expansion required: no

## 25. Readiness for repeat human review

All Prompt 03 SHOULD FIX findings are corrected, focused and architecture
validation is green, analyzer and generation are clean, and Project
Conformance passes with zero unresolved BLOCKER or SHOULD FIX findings.

The implementation remains unstaged for the required repeated human
architectural review.

FEATURE 35 PRE-CHECKPOINT FINDINGS CORRECTED: YES

READY TO REPEAT FEATURE 35 HUMAN ARCHITECTURAL REVIEW: YES
