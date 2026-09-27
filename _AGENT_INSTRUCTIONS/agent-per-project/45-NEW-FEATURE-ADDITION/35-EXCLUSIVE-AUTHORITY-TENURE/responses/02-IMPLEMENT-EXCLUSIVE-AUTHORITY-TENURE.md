# MessageLens Feature 35
## 02 — Exclusive Authority Tenure Implementation

Date: 2026-09-25

## Outcome

Feature 35 now contains the approved domain-ignorant exclusive-tenure
primitive, with `ArchiveMutationCoordinator` as its first and only production
adopter.

The implemented authority flow is:

```text
ExclusiveAuthorityRegistry
  -> exact live ExclusiveAuthorityTenure
  -> ArchiveMutationCoordinator private Zone and archive operation scope
  -> ArchiveMutationCapability exact operation proof
```

The registry owns only tenure mechanics. All archive operation, checkpoint,
resource-admission, reopen, environment, instance, and capability policy
remains in `ArchiveMutationCoordinator`.

The implementation is unstaged. It was not committed, pushed, merged, or
integrated into `main`.

## Baseline and isolation

Feature 35 was implemented only in:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

Verified branch and base:

- branch: `feature/exclusive-authority-tenure`
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream: `origin/main`
- ahead/behind before implementation: `0/0`
- index: empty

The frozen Onboarding worktree was rechecked after implementation and remains:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- tracked delta: 47 modified files and 2 deleted files
- untracked files: 76
- `git diff --check`: passed
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`

The parked patch and preservation bundle remain present and byte-identical to
Audit 01:

| Artifact | SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| tracked frozen delta | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| untracked Journey projection | `85a99027d0f487b15845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| untracked Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

## Generic essential

The new `lib/essentials/exclusive_authority/` essential provides:

- a closed typed `ExclusiveAuthorityKey` enum;
- one production key, `archiveMutation`;
- one fixed `@visibleForTesting` independent key for the required two-key
  proof;
- opaque `ExclusiveAuthorityTenure` construction available only inside the
  registry library;
- private registry and tenure identities that never enter diagnostics;
- occurrence-unique acquisition;
- exact private scope identities for outer and re-entrant holds;
- scoped `runExclusive`, `runReentrant`, and live-state `requireCurrent`;
- identity-checked final release in `finally`;
- permanent rejection of stale, released, wrong-key, foreign-registry, and
  disposed-registry proof;
- bounded immutable occupancy diagnostics;
- typed acquisition and proof-denial exceptions; and
- Riverpod keep-alive lifecycle with disposal revocation.

There is no public release method, ambient current-tenure lookup, string key
factory, serialization, waiting queue, timeout, retry, cancellation, workflow,
or presentation policy.

## Archive adapter

`ArchiveMutationCoordinator` now delegates only live tenure mechanics to the
generic registry.

It retains:

- `ArchiveMutationOperation` policy;
- its private archive Zone key and context;
- exact nested archive scope IDs and active operation aggregation;
- production checkpoint enforcement at every applicable nested scope;
- archive environment and instance diagnostics;
- caller- and operation-specific resource admission;
- graph/database reopen decisions;
- existing archive denial diagnostics; and
- `ArchiveMutationCapability` as exact current archive-operation proof.

The private Zone now carries the exact generic tenure plus coordinator and
archive-scope identity. Nested archive operations present that tenure through
`runReentrant`. Capability validation checks the exact active archive scope,
current private Zone lineage, coordinator lifecycle, and current underlying
generic tenure.

Generic busy or proof denial is translated back into the existing
`ArchiveMutationDeniedException` at the archive boundary. No established
archive caller receives a generic exception.

The coordinator no longer decides whether a new archive owner may acquire the
track. Its retained active-scope map exists only for archive policy,
aggregation, resource admission, and exact operation-capability validation.

## Test coverage

The generic primitive suite proves all 21 required cases:

1. free acquisition and Ball 1;
2. foreign denial before action start;
3. explicit proof across awaits;
4. exact re-entry and hold count;
5. terminal final release;
6. distinct Ball 2;
7. stale Ball 1 rejection while Ball 2 lives;
8. original outer exception preservation;
9. inner-scope-only exception cleanup;
10. unrelated async work without the Ball denied;
11. detached explicit proof valid only during live tenure;
12. independent typed keys;
13. wrong-key denial;
14. foreign-registry denial;
15. stale proof cannot alter a newer tenure;
16. live re-entrant child outliving the outer scope;
17. disposal revocation;
18. diagnostic-only occupancy;
19. equal labels do not revive proof;
20. denied acquisition consumes no occurrence; and
21. denial creates no queue or fairness entitlement.

Archive regression coverage additionally proves equal-label stale capability
rejection after reacquisition and capability invalidation inside its retained
Zone after coordinator disposal. Existing tests continue to prove outer
admission, foreign denial, private-Zone re-entry, nested policy aggregation,
checkpoint enforcement, resource admission, graph reopen behavior, and exact
scope invalidation.

The new architecture test enforces domain-ignorant imports, private tenure
construction, closed typed keys, absence of serialization/public release/
ambient lookup, the sole production key and adopter, diagnostic/proof
separation, identity rather than label/occurrence proof, presentation
separation, and native-lock independence.

## Validation results

| Validation | Result |
| --- | --- |
| normal build generation | passed |
| filtered generated-file consistency | passed; both outputs reported `same` |
| generic primitive suite | 21 passed |
| archive coordinator suite | 16 passed |
| resource-admission plus Feature 35 architecture run | 18 passed |
| complete architecture suite | 497 passed |
| focused downstream archive capability consumers | 98 passed |
| `flutter analyze --no-pub` | passed; no issues |
| complete repository Flutter suite | 2,639 passed, 1 intentional skip |
| `git diff --check` | passed |
| Feature 35 index | empty |

The first full build-runner pass rewrote two unrelated Freezed files with
whitespace-only changes. Those two generated files were inspected and restored
exactly to `HEAD`. Filtered regeneration of the two Feature 35 provider outputs
then completed consistently without unrelated tracked changes.

## Project Conformance Audit

### Authority ownership

PASS. One generic registry owns live tenure mechanics. The archive coordinator
retains only domain-specific scope and capability mechanics.

### Closed typed keys

PASS. `ExclusiveAuthorityKey` is an enum. `archiveMutation` is the only
production key. The second fixed value is explicitly test-only and exists only
to prove independent-key behavior.

### Opaque occurrence-unique proof

PASS. Visible occurrence and timestamp fields are diagnostics. Proof requires
exact registry identity, exact tenure identity, exact live entry, and a
non-disposed registry.

### Fail-closed lifecycle

PASS. Released, stale, wrong-key, foreign-registry, and disposed-registry
tenures fail closed. Exact private scope removal prevents an old or duplicate
scope completion from decrementing or clearing another tenure.

### Domain boundary

PASS. Generic code imports no Onboarding, archive, database, FDA, Contacts,
UI, Presence, attachment, recovery-policy, or native-lock module. It contains
no archive operation branch.

### Archive policy preservation

PASS. Checkpoint, operation, aggregate strength, resource admission, reopen,
environment/instance, private Zone, and capability semantics remain owned by
`ArchiveMutationCoordinator`.

### Diagnostics and presentation

PASS. Diagnostics expose no tenure or private proof identity. No presentation
file imports or consumes tenure, and no workflow authority was introduced.

### Adoption scope

PASS. `ArchiveMutationCoordinator` is the only production adopter. Native
single-instance authority remains a separate cross-process layer.

### Findings

- BLOCKER: 0
- SHOULD FIX: 0

**PROJECT CONFORMANCE: PASS**

## Safety and scope confirmations

- No Onboarding production or test file changed.
- No Environment Readiness or presentation file changed.
- No database schema or persisted format changed.
- No native process-lock code changed.
- No attachment archive configuration changed.
- No real database or archive was opened, read, copied, moved, deleted, or
  modified.
- MessageLens Development was not launched.
- The frozen Onboarding worktree, preservation bundle, and parked patch remain
  untouched.
