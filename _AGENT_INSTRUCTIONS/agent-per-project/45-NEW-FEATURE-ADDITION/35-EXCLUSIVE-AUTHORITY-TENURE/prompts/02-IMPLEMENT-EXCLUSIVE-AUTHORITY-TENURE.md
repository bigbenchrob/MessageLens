# MessageLens Feature 35
## 02 — Implement Exclusive Authority Tenure and Adapt Archive Mutation

Feature 35 Architecture Audit 01 is complete and approved.

The audit established that MessageLens already contains a proven Ball/Track
authority model inside `ArchiveMutationCoordinator`, and that the correct next
step is to extract only the reusable exclusive-tenure mechanics into a small,
domain-ignorant essential.

The approved architecture is:

```text
ExclusiveAuthorityRegistry
  + closed typed ExclusiveAuthorityKey
  + opaque occurrence-unique ExclusiveAuthorityTenure
  + identity-checked scoped acquisition/re-entry/release
  + bounded non-authoritative diagnostics
```

`ArchiveMutationCoordinator` remains the **first and only production adopter**.

The frozen Onboarding worktree must remain untouched.

Read in full before editing:

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- all canonical architecture/conformance rules cited by that audit;
- current `ArchiveMutationCoordinator` implementation and tests;
- current archive capability/resource-admission tests.

This task implements the generic primitive and adapts
`ArchiveMutationCoordinator` to use it.

Do NOT modify Onboarding production or test files.
Do NOT touch the frozen Onboarding worktree.
Do NOT apply the frozen Onboarding preservation bundle or parked patch.
Do NOT change archive policy.
Do NOT add a second production authority key.
Do NOT add queueing, timeout, cancellation, retry, workflow, or presentation
semantics to the generic primitive.
Do NOT change database schemas, persisted formats, native process locks, or
attachment archive configuration.
Do NOT stage, commit, merge, rebase, or push.

Leave the Feature 35 implementation unstaged for human architectural review.

---

# 1. Baseline

Work only in the Feature 35 worktree.

Expected branch:

`feature/exclusive-authority-tenure`

Expected base:

`fe14793bbee8622b08829c4973a1e6ae218e8bb2`

Expected upstream/base relationship:

- local `main` = `origin/main` =
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- merge base = same commit

According to Audit 01, the linked worktree was moved after the audit to:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

Confirm the actual registered worktree path with Git rather than assuming the
old `/private/tmp/...` path still applies.

Expected Feature 35 worktree content before implementation:

- no tracked code changes;
- only the approved untracked Feature 35 prompt/response records;
- clean index;
- shared-instructions submodule clean.

Also verify the frozen Onboarding worktree remains exactly:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty;
- tracked delta preserved;
- preservation bundle and parked patch unchanged.

If the frozen Onboarding state differs, STOP AND REPORT.

---

# 2. Implement the generic essential exactly at the audited boundary

Create the generic essential under:

`lib/essentials/exclusive_authority/`

The generic layer must remain domain-ignorant.

It may know only:

- typed authority keys;
- live tenure identity;
- scoped acquisition/re-entry/release;
- stale-proof rejection;
- bounded diagnostics;
- registry lifecycle.

It must not import or branch on:

- Onboarding;
- archive mutation operations;
- database maintenance;
- FDA;
- Contacts;
- recovery policy;
- presentation;
- Presence;
- attachment archive configuration;
- graph policy.

No generic method may accept archive-domain enums or callbacks whose semantics
require archive knowledge.

---

# 3. Closed typed key

Implement a closed typed `ExclusiveAuthorityKey`.

Initial production key:

`ExclusiveAuthorityKey.archiveMutation`

Requirements:

- no public arbitrary constructor;
- no `fromString`;
- no string-keyed acquisition API;
- diagnostic name is never parsed back into authority;
- no speculative second production key;
- equality comes from canonical typed constants.

A test-only second key may exist through a narrow library/test seam solely to
prove independent-key behavior without creating a production authority.

---

# 4. Opaque occurrence-unique Tenure

Implement `ExclusiveAuthorityTenure` as the opaque Ball.

It must be constructible only by the generic registry implementation.

It may expose only bounded diagnostic information such as:

- typed authority key;
- diagnostic occurrence number;
- optional issued-at time if useful.

It must not expose:

- public owner identity;
- registry identity;
- private tenure identity;
- mutable currentness;
- serializable proof token;
- public release.

Do not implement equality by visible fields.

A copied occurrence number or equal owner label must never constitute proof.

The authoritative live state remains in the registry.

---

# 5. Registry acquisition contract

Implement the audited scoped API or the closest project-conforming equivalent:

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

The exact names may change only if project conventions strongly require it.
Preserve the semantics.

## `runExclusive`

For a free key:

1. synchronously determine that it is free;
2. create a never-before-live private tenure identity;
3. publish registry live state;
4. invoke the action with the opaque tenure;
5. release the exact admitted scope in `finally`.

For a held key without the exact current tenure:

- typed denial before the action starts;
- no queue;
- no waiting;
- no timeout;
- no retry loop;
- no occurrence consumption on denied acquisition.

## `runReentrant`

Requires the exact current tenure.

It:

- reuses the same Ball;
- adds one exact active scope/hold;
- does not create a new tenure;
- releases only its own scope in `finally`.

Wrong-key, stale, foreign-registry, released, or disposed-registry tenure must
fail closed.

## `requireCurrent`

It must consult live registry-owned state.

The tenure object itself must not claim authority from cached local state.

---

# 6. Release and stale-proof mechanics

Implement identity-checked release.

Required properties:

- each admitted scope has an internal exact scope identity;
- release of one scope cannot release another;
- final scope release clears the live tenure;
- old tenure is permanently dead;
- reacquisition creates a distinct private tenure identity;
- stale callback presenting old tenure cannot affect the new tenure;
- stale/double internal release cannot decrement or clear a newer tenure;
- action exception preserves the original exception while cleanup occurs;
- registry/provider disposal invalidates all issued tenures.

Do not expose a public `release()` API in v1.

---

# 7. Async propagation model

The generic registry must **not** expose an ambient global/current-ball lookup.

Intentional authority propagation is explicit:

```text
registry gives tenure to admitted action
-> action passes tenure deliberately to intended descendant
-> descendant presents tenure to requireCurrent/runReentrant
```

The generic primitive may not rely on a public Zone lookup as its sole proof.

The existing archive adapter may retain its private Zone mechanism because that
domain already proved the need for provider-construction/re-entrant lineage.

The generic registry itself must not know or inspect the archive Zone.

---

# 8. Diagnostics

Provide a bounded immutable diagnostic/read model if the existing Riverpod
architecture requires observable state.

Allowed diagnostic fields include:

- authority key;
- free/live state;
- diagnostic tenure occurrence;
- bounded owner label;
- acquisition timestamp;
- active hold/scope count;
- bounded last-denial label/time/count;
- last release timestamp.

Diagnostics must not expose proof material.

Watching diagnostics must never grant authority.

A Boolean such as `isHeld` is evidence/diagnostics only, never admission proof.

---

# 9. Typed exceptions

Implement typed generic failures equivalent to:

- `ExclusiveAuthorityDeniedException`
- `ExclusiveAuthorityProofDeniedException`

Distinguish at least:

- held/busy foreign acquisition;
- missing/stale/wrong-key/wrong-registry/disposed proof.

Keep exception payloads bounded and privacy-safe.

Owner labels are diagnostic text only.

---

# 10. Adapt `ArchiveMutationCoordinator` as the sole adopter

Refactor `ArchiveMutationCoordinator` so it delegates only the generic tenure
mechanics to `ExclusiveAuthorityRegistry`.

It must retain all archive-domain policy:

- `ArchiveMutationOperation`;
- checkpoint policy;
- archive environment/instance diagnostics;
- nested operation scopes;
- operation-strength aggregation;
- `ArchiveMutationResourceAction` policy;
- resource-admission decisions;
- graph/database reopen policy;
- private archive Zone context;
- `ArchiveMutationCapability`.

The adapter shape should be:

```text
outer archive operation
-> generic registry.runExclusive(archiveMutation)
-> private archive Zone context stores tenure + archive scope + operation

nested archive operation
-> private archive Zone retrieves tenure
-> generic registry.runReentrant(tenure)
-> archive coordinator creates narrower archive operation scope
```

The generic registry must not learn what archive operation is running.

---

# 11. Preserve exact archive capability semantics

`ArchiveMutationCapability` remains the exact archive-operation proof.

It must continue to validate:

- exact archive operation;
- exact current archive scope;
- current private Zone lineage;
- coordinator not disposed;
- scope still active.

After Feature 35 extraction it must also be grounded in the exact current
generic tenure, directly or through the archive coordinator's own exact
validation.

The capability must become invalid when:

- its archive scope releases;
- the underlying tenure releases;
- the coordinator disposes;
- a stale callback presents it after a later tenure is active.

Do not weaken archive resource policy merely because generic tenure proves
exclusive ownership.

Generic tenure proves **who owns the track**.

Archive capability proves **what this archive operation may do on that track**.

---

# 12. Translate generic denial at the archive boundary

Archive callers should not become coupled to generic registry policy.

Where current archive callers expect `ArchiveMutationDeniedException`, translate
generic busy/foreign denial at the archive coordinator boundary into the
existing archive-domain exception.

Preserve current archive diagnostics and user-visible behavior.

Do not leak `ExclusiveAuthorityDeniedException` through established archive
public APIs unless the audit's bounded contract genuinely requires a new seam.
If such a leak appears necessary, STOP AND REPORT.

---

# 13. Preserve private Zone behavior

Do not remove or generalize the archive coordinator's private Zone merely
because the generic registry now exists.

Existing behavior to preserve:

- same-owner async descendants retain archive lineage across ordinary awaits;
- provider construction observes the requesting archive Zone;
- foreign callers cannot forge the private Zone context;
- nested archive operations can re-enter under the same Ball;
- exact nested archive operation scope remains separately tracked.

Add tests proving generic extraction did not weaken this behavior.

---

# 14. Primitive test matrix

Implement the full audited test matrix using direct registry/Riverpod fixtures
and `Completer` barriers where concurrency ordering matters.

At minimum prove:

1. free acquisition issues Ball 1;
2. foreign acquisition while Ball 1 is live is denied before action starts;
3. explicitly delegated Ball 1 remains current across awaits;
4. re-entry with Ball 1 reuses Ball 1 and increments hold count;
5. final release kills Ball 1;
6. reacquisition issues distinct Ball 2;
7. stale Ball 1 cannot act on or release Ball 2;
8. outer exception releases and preserves original exception;
9. inner re-entrant exception releases only inner scope;
10. unrelated async task without Ball cannot prove authority;
11. detached callback with Ball works only while tenure remains live;
12. two typed keys can be held independently using a test-only second key;
13. wrong-key proof fails;
14. tenure from another registry/container fails;
15. stale/double internal release cannot alter newer tenure;
16. outer completion while explicit re-entrant child remains keeps Ball live
    until last scope exits;
17. registry disposal invalidates live tenure;
18. diagnostics expose no proof identity;
19. equal owner labels do not revive old tenure;
20. denied acquisition does not consume occurrence;
21. no queue/fairness behavior is implied.

No timing sleeps as proof of concurrency/currentness.

---

# 15. Archive-adapter regression tests

Run and extend the archive coordinator tests to prove all existing behavior
survives extraction.

At minimum prove:

- outer admission;
- foreign denial;
- private Zone same-owner re-entry;
- nested archive operation scopes;
- aggregate stronger operation policy;
- checkpoint enforcement;
- resource admission;
- graph/database reopen decisions;
- exact-scope capability validation;
- capability invalidation on scope release;
- capability invalidation on tenure release;
- coordinator disposal;
- stale callback after reacquisition;
- existing denial diagnostics;
- owner-label equality is not proof.

Where possible preserve existing tests unchanged and add only the cases needed
to prove the new underlying tenure seam.

If adapting the generic registry requires broad archive call-site rewrites,
STOP AND REPORT rather than expanding scope silently.

---

# 16. Architecture tripwires

Add:

`test/architecture/exclusive_authority_architecture_test.dart`

Enforce at least:

- generic essential imports no Onboarding/archive/database/FDA/Contacts/UI/
  Presence/recovery-policy modules;
- only the generic registry implementation can construct
  `ExclusiveAuthorityTenure`;
- no public arbitrary/string authority-key constructor exists;
- no tenure serialization exists;
- no public release API exists;
- no public ambient `currentBall`/current-tenure lookup exists;
- archive mutation is the only production `ExclusiveAuthorityKey` and adopter;
- owner labels/diagnostic occurrence are not used for proof equality;
- presentation cannot consume tenure as workflow state;
- native single-instance authority remains unrelated.

Prefer semantic/import checks over brittle private-source spelling where
possible.

---

# 17. Preserve Feature 35 boundaries

Expected production changes should remain approximately within:

```text
lib/essentials/exclusive_authority/**
lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart
```

plus narrowly required provider/export/generated files.

Expected tests:

```text
test/essentials/exclusive_authority/**
test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
focused existing archive capability/resource tests
test/architecture/exclusive_authority_architecture_test.dart
```

Do NOT modify:

- Onboarding production/test files;
- Environment Readiness;
- presentation;
- database schemas;
- native single-instance code;
- attachment archive configuration;
- persisted operation snapshot formats.

If implementation pressure expands beyond the audited boundary, STOP AND REPORT.

---

# 18. Validation

After implementation:

1. normal code generation if required;
2. format changed Dart files;
3. focused generic primitive tests;
4. focused archive-adapter/capability/resource tests;
5. complete architecture suite;
6. `flutter analyze --no-pub`;
7. complete repository Flutter test suite;
8. `git diff --check`;
9. generated-file consistency;
10. shared-submodule status.

No real databases or archives.

No MessageLens Development launch.

Native tests are unnecessary unless native code unexpectedly changes.

---

# 19. Project Conformance Audit

Run the project conformance audit against the Feature 35 delta.

Explicitly verify:

- one generic registry owns live tenure mechanics;
- authority keys are closed and typed;
- tenure proof is opaque and occurrence-unique;
- stale/released/wrong-registry/wrong-key proof fails closed;
- archive policy remains in `ArchiveMutationCoordinator`;
- generic code is domain ignorant;
- only one production adopter/key exists;
- diagnostics never become proof;
- no presentation/workflow authority is introduced;
- no duplicate lock/tenure implementation remains in archive coordinator beyond
  its domain-specific scope/capability mechanics.

Require:

`PROJECT CONFORMANCE: PASS`

with zero unresolved BLOCKER and SHOULD FIX findings.

Do not edit the Project Conformance Standard yet.

---

# 20. Leave implementation unstaged

Even if all validation passes:

- do not stage;
- do not commit;
- do not push;
- do not merge;
- do not integrate into `main`;
- do not touch frozen Onboarding.

Feature 35 must receive a human architectural review before checkpoint.

---

# 21. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`

Report:

1. baseline/worktree identity;
2. generic file/module structure;
3. key model;
4. tenure/private identity model;
5. acquisition/re-entry/release implementation;
6. stale-proof behavior;
7. diagnostics;
8. exception model;
9. archive-adapter changes;
10. archive Zone preservation;
11. archive capability preservation;
12. generic primitive test results;
13. archive-adapter regression results;
14. architecture test results;
15. analyzer result;
16. full-suite result;
17. generation result;
18. `git diff --check`;
19. Project Conformance verdict;
20. changed files;
21. exact Git status;
22. frozen Onboarding verification;
23. stop gates encountered;
24. any OPTIONAL findings;
25. recommendation for human architectural review.

Conclude exactly:

`FEATURE 35 EXCLUSIVE AUTHORITY TENURE IMPLEMENTED AND VALIDATED: YES / NO`

If YES, also conclude:

`READY FOR FEATURE 35 HUMAN ARCHITECTURAL REVIEW BEFORE CHECKPOINT: YES / NO`

Then STOP.
