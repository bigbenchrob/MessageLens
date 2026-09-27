# MessageLens Feature 35
## 01 — Freeze Onboarding and Establish Exclusive Authority Tenure Architecture

Feature 34 / Onboarding qualification has reached a deliberate freeze point.

The current Onboarding worktree contains a large, unstaged authority correction
that is **not approved for checkpoint** because Prompt 13 exposed a remaining
self-denial defect:

> an admitted mutation can cause the environment to report
> `maintenanceInProgress`, and the admitted command can then reject itself
> because its own authority made the track look occupied.

Do not continue patching Onboarding in this task.

We are extracting the reusable mechanism underneath the existing Ball And Track
pattern into a new Feature 35:

> **Exclusive Authority Tenure**

Working conceptual names:

- **Ball Czar** — generic exclusive-authority registry/coordinator
- **Ball** — opaque unique authority lease/capability
- **Authority key** — typed name of the exclusive authority being held

Production names may differ after the architecture audit, but preserve the
conceptual model while reasoning.

The Ball Czar must be deliberately domain-ignorant:

> “I do not care why you need authority or what you intend to do. I only know
> which named authority currently has a ball, who owns that ball, whether a
> claimant can prove possession of the current ball, and when that ball has been
> permanently retired.”

---

# 1. Git isolation: freeze the current Onboarding work exactly as-is

Current primary worktree is expected to be:

- repository:
  `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch:
  `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index: empty
- large unstaged Onboarding correction present
- shared-instructions submodule clean
- parked older WIP patch present and unapplied

First verify that state.

Do NOT:

- stage the Onboarding work;
- commit it;
- stash it;
- reset it;
- clean untracked files;
- apply the parked patch;
- switch this worktree to another branch.

This worktree is now **frozen in place** as the exact current Onboarding
investigation state.

Create a read-only preservation patch of the current tracked + intended
untracked implementation delta if practical, stored outside the repository
under `/private/tmp/`, and record its SHA-256. This preservation patch is a
backup only; do not apply it anywhere during Feature 35.

If producing one patch cannot safely include the intended untracked
implementation files, produce:

- one tracked binary-capable diff patch; and
- a manifest/hash record for the intended untracked implementation files.

Do not modify the frozen worktree to create the backup.

---

# 2. Create a separate Feature 35 worktree

Fetch refs without modifying the frozen worktree.

Feature 35 must be developed independently from the uncommitted Onboarding
correction.

Use a separate worktree and branch.

Preferred branch:

`feature/exclusive-authority-tenure`

Preferred temporary worktree:

`/private/tmp/messagelens-feature-35-exclusive-authority-tenure`

Base Feature 35 on the current clean `origin/main`, not on the frozen
Onboarding worktree's uncommitted delta.

Before creating the branch, report:

- local `main`;
- `origin/main`;
- merge base;
- whether `origin/main` differs from the previously integrated Feature 34 base.

If local `main` and `origin/main` differ unexpectedly, STOP AND REPORT before
choosing a base.

Do not delete or repurpose any existing worktree.

---

# 3. Create the Feature 35 instruction folder

In the Feature 35 worktree create:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/`

with:

```text
35-EXCLUSIVE-AUTHORITY-TENURE/
├── prompts/
└── responses/
```

Save this prompt as:

`prompts/01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md`

Create the response as:

`responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`

Do not reorganize any existing Feature 34 qualification files.

---

# 4. Feature objective

The objective is to create a small, reusable, details-agnostic mechanism for
exclusive authority tenure.

Conceptually:

```text
claimant:
    "I need exclusive authority X."

Ball Czar:
    "Authority X is available.
     Here is Ball 42.
     Ball 42 belongs to you until you release it."

later:

claimant presents Ball 42
    -> yes, current authority proven

other claimant presents no ball / Ball 17
    -> no

Ball 42 released
    -> Ball 42 is permanently dead

Authority X later reacquired
    -> issue Ball 43
```

The infrastructure must not know what authority X means.

It must not know about:

- Onboarding;
- databases;
- archives;
- FDA;
- Contacts;
- import;
- maintenance;
- UI;
- Journey Episodes;
- recovery policy.

Those belong to domain authorities.

---

# 5. Core Mechanical Impossibility invariants

The audit/design must aim to make these properties mechanically true.

## One live ball per authority

For a given authority key, at most one live tenure exists at a time.

## Opaque unique tenure

Every acquisition receives a new opaque ball/lease identity.

A released ball is permanently invalid.

Ball identities are never recycled as authority proof.

## Ownership proof

A protected action can ask:

> Does this execution possess the current live ball for authority X?

The answer is mechanically yes or no.

## Same-owner descendant/re-entrant use

Work descended from the current owner may act under the same live ball when the
architecture intentionally propagates that authority.

It must not compete against itself for a second ball merely because execution
crossed service or async boundaries.

## Foreign ownership fails closed

If another owner holds authority X, a claimant without the matching current ball
is denied.

If ownership cannot be proven, deny.

## Release is terminal

Once released, the old ball cannot become valid again even if:

- the same logical component reacquires the authority;
- a stale callback arrives;
- a new tenure has the same human-readable owner label.

## Domain ignorance

The Ball Czar knows only:

- authority key;
- unique tenure identity;
- owner identity/provenance;
- live/released state;
- possibly bounded diagnostics.

It does not decide whether a domain operation is semantically appropriate.

---

# 6. Rediscover the existing Ball And Track mechanism before designing anything

Search source, tests, canonical docs, architecture records, and Git history for
the previous Ball And Track / Mechanical Impossibility implementation.

Look for:

- `ArchiveMutationCoordinator`;
- mutation ownership;
- same-owner re-entry;
- `Zone` ownership;
- owner tokens;
- lock identity;
- `dbMaintenanceLockProvider`;
- nested protected-resource access;
- mutation operation kinds;
- stale owner rejection;
- lease/capability terminology.

Establish:

1. what earlier defect caused the Ball/Track design;
2. what the existing “ball” is in actual code;
3. how owner identity is generated;
4. how it propagates across async boundaries;
5. how same-owner descendants prove authority;
6. how foreign callers are denied;
7. how release invalidates ownership;
8. whether stale owner identity can be replayed;
9. whether the mechanism is generic already or archive-specific;
10. what should be extracted rather than reimplemented.

Label historical statements:

- VERIFIED HISTORY
- STRONGLY SUPPORTED INFERENCE
- UNKNOWN

---

# 7. Audit current exclusive-authority patterns project-wide

Search for other cases where MessageLens expresses:

- only one owner at a time;
- maintenance locks;
- mutation locks;
- coordinator ownership;
- single-writer authority;
- process-local occurrence ownership;
- async re-entrant authorization;
- stale-token/currentness rejection.

Do not refactor them in this task.

Classify each as:

A. likely future adopter of a generic exclusive-authority primitive;

B. conceptually similar but should remain domain-specific;

C. unrelated.

The purpose is to ensure Feature 35 is generic enough to reuse without making it
an over-general framework.

---

# 8. Determine the correct abstraction boundary

Compare at least these possible shapes against current project idioms:

## Registry/coordinator model

```text
ExclusiveAuthorityRegistry
    acquire(authorityKey, owner)
        -> ExclusiveAuthorityLease
```

## Scoped execution model

```text
authority.runExclusive(
    authorityKey,
    owner,
    action,
)
```

where the live ball is propagated through the async execution context.

## Hybrid model

Acquisition returns an opaque lease and `runWithLease(...)` establishes the
current async execution authority.

Evaluate:

- stale callback safety;
- re-entrancy;
- async propagation;
- testability;
- explicit release;
- exception/cancellation cleanup;
- Riverpod integration;
- whether owner identity should be public, private, or diagnostic only;
- whether `Zone` remains appropriate;
- whether acquisition must be FIFO/fair or only exclusive;
- whether waiting/queueing belongs in the generic primitive or remains
  domain-specific.

Choose the smallest useful primitive.

Avoid building a permissions framework, scheduler, workflow engine, or policy
language.

---

# 9. Typed authority keys

Do not use arbitrary string authority names in production if a typed solution is
practical.

Evaluate a small typed authority-key model that prevents accidental creation of
distinct authorities by spelling differences.

The infrastructure should remain domain-agnostic even if authority keys are
defined centrally.

Examples are conceptual only:

```text
ExclusiveAuthorityKey.archiveMutation
ExclusiveAuthorityKey.onboardingJourneyMutation
ExclusiveAuthorityKey.databaseMaintenance
```

Do not add keys merely because they might someday be useful.

Feature 35's first real adopter should be the authority already proven by the
current Ball/Track implementation.

---

# 10. Lease / Ball semantics

Define the minimum Ball/lease data.

Consider:

- unique occurrence/generation ID;
- authority key;
- private owner identity;
- issued-at time for diagnostics only;
- live/released state held by the Czar rather than trusted from the Ball itself.

The Ball must be non-forgeable by ordinary callers.

A caller possessing an old object/value must not make it current again.

Decide whether the lease object itself exposes:

```text
isCurrent
```

or whether callers must ask the Czar.

Prefer a design that does not let stale local state claim authority.

---

# 11. Re-entrant async propagation

Audit the existing async-Zone solution carefully.

Determine whether the generic primitive should provide a concept equivalent to:

```text
currentBall(authorityKey)
```

within the admitted async execution scope.

Required behavior:

```text
owner acquires Ball 42
-> async descendant A
-> async descendant B
-> B asks for authority X
-> current Ball 42 proves same-owner authority
```

But an unrelated asynchronous task must not inherit the ball accidentally.

Document:

- how Dart Zone propagation behaves;
- how spawned work inherits or does not inherit it;
- cancellation/release behavior;
- what happens to a late callback after release;
- nested requests for the same authority;
- nested requests for a different authority.

Do not generalize re-entrancy until these semantics are proven.

---

# 12. Acquisition, denial, release, and lifecycle behavior

Define deterministic behavior for:

- acquire when free;
- acquire when already held by the same execution;
- acquire when held by a foreign owner;
- nested same-owner protected operation;
- exception inside admitted scope;
- cancellation;
- explicit release;
- double release;
- stale release;
- stale proof after release;
- reacquire after release;
- container/process teardown.

Decide which cases:

- succeed;
- reuse the current ball;
- throw a typed error;
- return a typed denial;
- are programmer errors.

The generic primitive should not decide domain retry/wait UI.

---

# 13. Diagnostics and privacy

The Ball Czar may need bounded diagnostics such as:

- authority key;
- live/free;
- tenure occurrence/generation;
- bounded owner label;
- acquisition time.

Do not include:

- message content;
- database paths;
- user data;
- domain payloads.

Determine whether owner labels are diagnostic descriptions only while authority
proof uses a private opaque identity.

---

# 14. Exhaustive primitive test matrix

Design tests for the generic mechanism itself before any Onboarding integration.

At minimum:

1. acquire free authority -> Ball 1/current;
2. foreign acquire while held -> denied;
3. same-owner descendant -> recognized as current;
4. nested same-authority call -> deterministic re-entrant behavior;
5. release -> old ball invalid immediately;
6. reacquire -> new Ball 2, old Ball 1 still invalid;
7. stale callback presenting Ball 1 after Ball 2 exists -> denied;
8. exception inside scoped execution -> release/cleanup correct;
9. unrelated async task cannot falsely prove ownership;
10. different authority keys can be held independently;
11. double/stale release cannot release a newer owner's ball;
12. process/container teardown leaves no externally persistent authority;
13. diagnostics reflect live authority without becoming authority themselves.

Use deterministic synchronization, not timing sleeps.

---

# 15. First integration proving case: the current Onboarding defect

Do not implement this integration in Prompt 01.

Design it as Feature 35's first adopter/proof.

The required proving scenario is:

```text
Onboarding command
-> acquires ArchiveMutation authority Ball 42
-> lock/maintenance becomes visible
-> final authorization asks whether maintenance conflicts
-> command proves it owns Ball 42
-> self-owned maintenance cannot deny it
```

Reciprocal proofs:

```text
foreign Ball 43 owns ArchiveMutation
-> Onboarding without Ball 43 denied
```

and:

```text
Onboarding once owned Ball 42
-> releases it
-> stale callback later presents Ball 42
-> denied forever
```

The integration must preserve independent prerequisite and exact-command policy
checks. Holding a ball proves exclusive authority; it does **not** prove that
FDA, Contacts, reset predicates, resumability, or Journey policy are satisfied.

---

# 16. Git/integration plan after Feature 35

Propose the safest future sequence.

Preferred direction unless repository evidence says otherwise:

1. keep frozen `fix/onboarding-import-stuck-state` worktree untouched;
2. design/implement/test Feature 35 on
   `feature/exclusive-authority-tenure` from clean `origin/main`;
3. run Feature 35 conformance and full validation;
4. checkpoint Feature 35;
5. integrate Feature 35 to `main` through the normal reviewed integration path;
6. return to the frozen Onboarding branch/worktree;
7. merge updated `main` into the Onboarding branch;
8. replace the local self-maintenance workaround/problem with the proven Feature
   35 primitive;
9. resume Onboarding architectural qualification from the exact frozen state.

Do not perform these integration steps in this prompt.

If Feature 35 must instead branch from another base to reuse existing mutation
work, explain why before changing the plan.

---

# 17. Project Conformance considerations

Identify reusable conformance rules Feature 35 should eventually add, such as:

> For every exclusive authority, is there exactly one live tenure at a time, and
> can mutation proceed only when current tenure is mechanically proven?

and:

> Can stale/released tenure ever regain authority after a new tenure is issued?

Do not edit the Project Conformance Standard yet.

---

# 18. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`

Report:

1. frozen Onboarding worktree state;
2. preservation backup/hash;
3. Feature 35 branch/worktree/base;
4. new Feature 35 folder structure;
5. rediscovered Ball/Track history;
6. existing owner/provenance implementation;
7. project-wide analogous authority patterns;
8. recommended generic abstraction;
9. rejected abstraction alternatives;
10. authority-key model;
11. Ball/lease model;
12. async propagation/re-entrancy model;
13. acquisition/denial/release semantics;
14. diagnostics/privacy;
15. exhaustive primitive test matrix;
16. first Onboarding integration proof design;
17. expected Feature 35 production/test files;
18. Git/integration plan back into frozen Onboarding;
19. future conformance rules;
20. open human decisions;
21. stop gates encountered.

Do not implement Feature 35 in this prompt beyond creating the instruction folder
and response document.

Conclude exactly:

`FEATURE 35 EXCLUSIVE AUTHORITY ARCHITECTURE AUDIT COMPLETE: YES / NO`

If YES, also conclude:

`SAFE TO DESIGN/IMPLEMENT THE GENERIC BALL CZAR PRIMITIVE: YES / NO`

Then STOP.
