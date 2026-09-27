# MessageLens Feature 35
## 04 — Correct Pre-Checkpoint Architectural Review Findings

Feature 35 Prompt 03 completed the first human architectural review.

Verdict:

- BLOCKER: 0
- SHOULD FIX: 4
- checkpoint: not yet safe

The implementation itself is structurally sound. The remaining findings are
bounded corrections to mechanical enforceability, Riverpod lifecycle semantics,
architecture-tripwire coverage, and exact regression proof.

This task corrects **only** those four SHOULD FIX findings.

Do NOT redesign the generic tenure model.
Do NOT add a second production authority key.
Do NOT add another adopter.
Do NOT broaden archive policy.
Do NOT touch Onboarding.
Do NOT apply the frozen Onboarding preservation bundle or parked patch.
Do NOT stage or commit.
Do NOT merge, rebase, cherry-pick, or push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`
- `responses/03-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`

The governing model remains:

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

---

# 1. Baseline

Work only in the Feature 35 worktree.

Expected:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`
- branch:
  `feature/exclusive-authority-tenure`
- HEAD/base:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream:
  `origin/main`
- index: empty

Confirm the current implementation delta still contains only the approved
Feature 35 files and that Prompt 03 changed no implementation.

Re-verify the frozen Onboarding worktree remains untouched at:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty
- tracked/untracked preservation state unchanged
- preservation hashes unchanged
- parked patch unchanged and unapplied

If either worktree differs materially, STOP AND REPORT.

---

# 2. SHOULD FIX 1 — Make the second authority key mechanically test-only

Prompt 03 found that:

`ExclusiveAuthorityKey.testOnlyIndependent`

is a normal public enum member.

`@visibleForTesting` is advisory and does not mechanically prevent production
code from using it.

Correct this boundary.

The production authority-key model must satisfy all of these:

1. ordinary production code can use only:
   `ExclusiveAuthorityKey.archiveMutation`;
2. the test suite can still prove independent-key behavior;
3. no arbitrary string/public constructor is introduced;
4. no second production key is created merely for testing;
5. the architecture test mechanically rejects production references to any
   test-only authority mechanism.

Prefer the smallest Dart/library structure that makes the test-only second key
unavailable to ordinary production importers.

Possible approaches include:

- a private/test-only factory or library-part seam;
- a package-private test hook that ordinary production code cannot import
  through the public Feature 35 seam;
- another mechanically closed approach consistent with project conventions.

Do not rely only on:

- `@visibleForTesting`;
- naming;
- comments;
- developer discipline.

If Dart library mechanics make a truly closed test-only key impossible without
distorting the public API, STOP AND REPORT rather than inventing a second
production key.

---

# 3. Strengthen authority-key architecture proof

Update the architecture tripwire so it proves:

- `archiveMutation` is the only production authority key;
- no production source references the test-only key or test-only key factory;
- no production source constructs or aliases a second key;
- no string or dynamic key API exists;
- adding another production key requires an intentional architecture-test
  update.

The test must scan actual production use, not only the key declaration.

A future production file must not be able to adopt the test key without failing
architecture validation.

---

# 4. SHOULD FIX 2 — Define safe Riverpod refresh/invalidation semantics

Prompt 03 established an important lifecycle fact:

- the provider is keep-alive;
- `container.refresh(exclusiveAuthorityRegistryProvider)` rebuilds the **same**
  notifier object;
- `_dispose` marks that notifier permanently disposed;
- subsequent acquisition then fails as `registryDisposed`.

A reusable authority foundation must have a mechanically defined provider
lifecycle.

Choose the **smallest safe contract**.

There are two acceptable design directions.

## Option A — Refresh/invalidation is unsupported and mechanically prohibited

If the registry is intended to exist for the ProviderContainer lifetime and
should never be refreshed in production:

- make that lifecycle rule explicit;
- add an architecture tripwire rejecting production
  `ref.invalidate`, `ref.refresh`, `container.invalidate`,
  `container.refresh`, or equivalent use of
  `exclusiveAuthorityRegistryProvider`;
- ensure ordinary framework rebuilds do not trigger disposal/rebuild;
- retain ProviderContainer disposal as the only supported revocation boundary.

This is likely the smallest design if no legitimate production refresh use
exists.

## Option B — Rebuild is explicitly safe

If project conventions require refresh to be supported:

- the same notifier instance must be able to reinitialize safely;
- old tenure must remain permanently invalid;
- no admitted old action and rebuilt registry may overlap authority;
- the rebuild must establish a new registry lifecycle identity;
- acquisition after rebuild must work;
- stale callbacks from the old lifecycle must fail closed.

Do not implement a replacement registry that overlaps a still-running admitted
old action.

Do not silently reset `_isDisposed` unless the full overlap/lifecycle proof is
mechanically sound.

Choose one option based on actual project needs.

Do not support refresh merely because Riverpod exposes it.

---

# 5. Add lifecycle regression proof

Add deterministic tests for the selected lifecycle contract.

If Option A is chosen:

- prove the registry remains valid for normal container lifetime;
- prove container disposal revokes tenure;
- add architecture proof that production code cannot explicitly refresh/
  invalidate the provider;
- remove or avoid any test implying refresh is supported.

If Option B is chosen:

- prove refresh revokes old Ball;
- prove new acquisition succeeds afterward;
- prove stale old Ball cannot affect the new lifecycle;
- prove no overlapping admitted actions can exist across refresh;
- prove provider/container identity behavior exactly.

Do not use timing sleeps.

---

# 6. SHOULD FIX 3 — Complete the architecture tripwire

Prompt 03 found the current tripwire can miss:

- direct `ExclusiveAuthorityRegistry` injection;
- direct `ExclusiveAuthorityKey` use;
- production references to the test-only key;
- diagnostic values used as pseudo-authority.

Strengthen the architecture test so that the approved boundary is mechanical.

At minimum enforce:

## Generic adopters

Production access to the generic authority essential must be limited to the
approved first adopter:

`ArchiveMutationCoordinator`

plus narrowly justified generic-essential internals.

The scan must detect:

- provider use;
- direct registry type use;
- tenure type use;
- authority-key use;
- diagnostic-state use where relevant.

Do not identify adopters using only two symbol spellings.

## Diagnostics are not proof

Mechanically reject production authorization logic that uses:

- `isHeld`;
- diagnostic owner label;
- occurrence number;
- acquisition/release timestamps;
- denial counters;

as substitutes for tenure/capability proof.

Use the most robust practical property available from current source structure.
Do not create an unreadable pseudo-parser.

## Presentation/workflow separation

Retain the existing prohibition on presentation/workflow use of live tenure.

## Sole production adopter/key

A future second adopter or authority key must fail the architecture test until a
separate reviewed architecture change approves it.

---

# 7. SHOULD FIX 4 — Add exact stale-release/capability proofs

Prompt 03 found three places where the implementation appears correct by source
inspection, but the tests do not isolate the exact mechanism claimed.

Add narrow deterministic proof where possible.

Do NOT add a public release API or weaken encapsulation merely to make testing
easy.

---

# 8. Exact proof A — stale/double internal release cannot alter newer tenure

The current test only passes stale Ball 1 to public `runReentrant`, proving
pre-admission rejection.

That is not the same as proving stale internal scope cleanup cannot affect Ball
2.

Design a test-only/internal seam that exercises the actual release mechanism
without widening the production public API.

Prove:

```text
Ball 1 / scope 1 exists
-> scope 1 releases
-> Ball 2 / scope 2 exists
-> stale/double cleanup for scope 1 occurs
-> Ball 2 remains current
-> Ball 2 hold/scope count unchanged
-> Ball 2 action remains authorized
```

The proof must reach the same exact identity-checked release code used in
production.

If Dart privacy makes this unreachable without a harmful production seam,
document that limitation and revise the implementation report claim to the
strongest mechanically proved statement. But first prefer a narrow library/test
seam.

---

# 9. Exact proof B — stale archive capability from retained Ball-1 lineage

Prompt 03 found the current stale-capability test invokes capability 1 while
running in Ball 2's Zone.

That fails for multiple reasons simultaneously.

Construct the stronger deterministic sequence if the current private Zone/test
structure permits it:

```text
Ball 1 acquired
-> archive scope/capability 1 issued
-> callback created inside Ball-1 archive Zone retains capability 1
-> Ball 1 fully releases
-> Ball 2 acquired
-> while Ball 2 is live, retained Ball-1 callback attempts capability use
-> capability 1 fails
-> Ball 2 remains unchanged
```

The test must demonstrate stale proof rejection against the old retained lineage,
not merely wrong-current-Zone rejection.

Use completers or retained callbacks; no sleeps.

---

# 10. Exact proof C — generic-tenure grounding of ArchiveMutationCapability

Prompt 03 found the disposal test invalidates coordinator and registry together,
so it does not isolate the capability's generic-tenure currentness check.

Add a narrow proof that, with archive scope/coordinator context otherwise still
valid as far as practical, the underlying generic tenure becoming non-current
causes capability validation to fail.

Do not violate real production lifecycle merely to manufacture an impossible
state.

Acceptable approaches include:

- a library-private/test seam that revokes/invalidates only the generic tenure
  while retaining the archive test harness;
- another mechanically equivalent setup that reaches the registry
  `requireCurrent` branch independently.

If the architecture intentionally makes independent tenure revocation impossible
while an archive scope remains active, say so and revise the test/report claim:
the capability's generic currentness grounding may be proven by source +
integration invariants rather than a physically unreachable production state.

Do not create an invalid production feature just to achieve test isolation.

---

# 11. Re-review exception catch boundary only if touched

Prompt 03 recorded one OPTIONAL observation:

`ArchiveMutationCoordinator._run` catches generic denial types around the
entire awaited registry action.

Do not broaden this correction to address that optional future-second-adopter
case unless the four required fixes naturally touch the same code and reveal a
current defect.

There is still only one approved adopter.

---

# 12. Preserve all proven Feature 35 behavior

The correction must not weaken:

- one live tenure per key;
- identity proof;
- exact re-entry;
- exact-scope release;
- stale Ball rejection;
- fail-closed wrong-key/wrong-registry/disposed proof;
- private archive Zone;
- archive nested operation scopes;
- checkpoint enforcement;
- resource admission;
- graph/database reopen policy;
- `ArchiveMutationCapability`;
- diagnostics/proof separation;
- domain ignorance of the generic essential.

No Onboarding change belongs in this task.

---

# 13. Validation

After correction run:

1. focused generic primitive tests;
2. new lifecycle tests;
3. exact stale-release tests;
4. exact stale-capability/tenure-grounding tests;
5. archive coordinator tests;
6. focused archive resource/capability regression tests;
7. Feature 35 architecture tests;
8. complete architecture suite;
9. `flutter analyze --no-pub`;
10. generation if annotated/generated source changed;
11. `git diff --check`.

Do not rerun the full repository Flutter suite yet unless the correction changes
runtime production behavior beyond the generic/provider seam in a way that
narrow validation cannot credibly cover.

The full suite can be rerun after the repeated human architecture gate passes.

---

# 14. Project Conformance correction-delta audit

Re-evaluate Feature 35 specifically against the four Prompt 03 findings.

Require proof that:

- only approved production authority keys exist;
- test-only authority machinery is mechanically unavailable to production;
- provider lifecycle is mechanically defined;
- generic registry cannot gain unauthorized production adopters;
- diagnostics cannot become authority proof;
- stale internal release cannot alter newer tenure;
- archive capability is grounded in exact current generic tenure;
- archive policy remains domain-owned;
- no second adopter or Onboarding dependency appears.

Require:

`PROJECT CONFORMANCE: PASS`

with zero unresolved BLOCKER and zero unresolved SHOULD FIX findings.

Do not update the global Project Conformance Standard yet.

---

# 15. Leave implementation unstaged

Even if all focused validation passes:

- do not stage;
- do not commit;
- do not push;
- do not merge;
- do not integrate into `main`;
- do not touch the frozen Onboarding worktree.

Repeat the human architectural review before checkpoint.

---

# 16. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md`

Report:

1. baseline/isolation;
2. test-only key correction;
3. production key/adopter tripwire correction;
4. selected provider lifecycle contract;
5. lifecycle tests;
6. diagnostic/proof tripwire correction;
7. stale internal-release proof;
8. retained old-Zone capability proof;
9. generic-tenure grounding proof;
10. any claim narrowed because an isolated state is mechanically unreachable;
11. changed files;
12. focused generic results;
13. archive regression results;
14. architecture results;
15. analyzer result;
16. generation result if applicable;
17. `git diff --check`;
18. Project Conformance verdict;
19. remaining BLOCKER findings;
20. remaining SHOULD FIX findings;
21. OPTIONAL findings;
22. exact Feature 35 Git status;
23. frozen Onboarding verification;
24. stop gates;
25. readiness for repeat human review.

Conclude exactly:

`FEATURE 35 PRE-CHECKPOINT FINDINGS CORRECTED: YES / NO`

If YES, also conclude:

`READY TO REPEAT FEATURE 35 HUMAN ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
