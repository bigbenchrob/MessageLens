# MessageLens Feature 35
## 05 — Repeat Human Architectural Review Before Checkpoint

Prompt 04 reports that all four SHOULD FIX findings from the first Feature 35
human architectural review have been corrected.

This task repeats the **full read-only human architectural gate** against the
actual current unstaged Feature 35 implementation.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT merge, rebase, cherry-pick, or push.
Do NOT touch the frozen Onboarding worktree.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`
- `responses/03-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md`
- all canonical architecture/conformance records cited by those responses;
- the complete current Feature 35 unstaged diff.

Governing rule:

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

The objective is to determine whether Feature 35 is now safe to checkpoint as a
known-good architectural foundation.

---

# 1. Baseline and isolation

Verify:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`
- branch:
  `feature/exclusive-authority-tenure`
- HEAD/base:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream:
  `origin/main`
- index: empty

Confirm Prompt 04 changed only the intended Feature 35 implementation/test files
and introduced no unrelated tracked work.

Re-verify the frozen Onboarding worktree remains exactly preserved:

- branch: `fix/onboarding-import-stuck-state`
- HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty;
- tracked/untracked preservation state unchanged;
- preservation hashes unchanged;
- parked patch unchanged and unapplied.

If either worktree differs materially, STOP AND REPORT.

---

# 2. Repeat the complete Feature 35 architectural review

Do not inspect only the four corrected findings.

Repeat the full architectural review of the current source/test delta under the
same categories used in Prompt 03:

1. generic registry responsibility;
2. typed authority-key boundary;
3. tenure opacity/proof identity;
4. exclusive acquisition;
5. re-entry and hold lifetime;
6. exact-scope release/finally semantics;
7. Riverpod/provider lifecycle;
8. diagnostics as non-authority;
9. typed exception boundary;
10. ArchiveMutationCoordinator ownership;
11. private Zone propagation;
12. ArchiveMutationCapability grounding;
13. stale callback/reacquisition;
14. concurrency semantics;
15. architecture-tripwire quality;
16. test-quality proof;
17. diff/scope safety.

The purpose is to ensure Prompt 04 did not close one seam by opening another.

---

# 3. Verify the mechanically test-only authority-key seam

Inspect the current `ExclusiveAuthorityKey` implementation and friend/test parts.

Confirm:

- production has exactly one constructible authority key:
  `ExclusiveAuthorityKey.archiveMutation`;
- ordinary production code cannot construct or import an independent test key;
- the test-only key/factory is not exported through the public Feature 35 seam;
- direct production references to the test support are mechanically rejected;
- no public string/dynamic key constructor exists;
- no second production key was accidentally created while replacing the enum.

Check the architecture test against actual Dart library/part visibility.

The result must be stronger than naming or `@visibleForTesting`.

---

# 4. Verify the provider lifecycle contract

Prompt 04 selected:

> refresh/invalidation is unsupported in production.

Review that decision and its enforcement.

Confirm:

- the registry is stable for one ProviderContainer lifetime;
- ordinary framework behavior does not rebuild it;
- no watched/listened dependency can trigger reconstruction;
- ProviderContainer disposal is the sole supported revocation boundary;
- production code cannot call refresh/invalidate on
  `exclusiveAuthorityRegistryProvider`;
- architecture tests detect direct and equivalent production refresh/invalidate
  usage;
- stale tenure after container disposal fails closed;
- sequential acquisitions during a normal container lifetime remain usable.

Check that the implementation no longer makes any claim that refresh is a
supported lifecycle.

If unsupported refresh can still occur through a normal production path, this is
a BLOCKER.

---

# 5. Verify stale internal release mechanically

Inspect the friend/test seam and the real release implementation.

Confirm the exact tested sequence really reaches production `_releaseScope` (or
its current equivalent):

```text
Ball 1 / scope 1
-> scope 1 released
-> Ball 2 / scope 2 acquired and held
-> stale scope-1 cleanup replayed
-> Ball 2 remains current
-> Ball 2 hold count unchanged
```

Verify:

- no public release API was added;
- stale cleanup cannot match by occurrence/label/count alone;
- exact tenure identity and exact scope identity are required;
- repeated stale cleanup is harmless;
- the test seam cannot be used by production code.

This is one of the core mechanical-impossibility proofs.

---

# 6. Verify retained old-Zone stale capability proof

Inspect the strengthened archive regression.

Confirm the callback is actually registered while executing inside Ball 1's
archive Zone, retained after Ball 1 releases, and later executed while Ball 2 is
live.

Verify mechanically:

- callback still observes the old Ball-1 lineage;
- capability 1 fails;
- capability 2 remains valid;
- Ball 2 owner/hold count is unchanged;
- denial is not merely caused by executing stale capability 1 from Ball 2's
  Zone.

The test must isolate the stale lineage it claims to prove.

---

# 7. Verify generic-tenure grounding of ArchiveMutationCapability

Inspect the isolated grounding test.

Confirm:

- archive coordinator remains alive;
- archive scope remains active as far as the test model permits;
- private archive Zone remains otherwise correct;
- only the underlying generic tenure is made non-current through the internal
  test seam;
- capability validation then fails specifically because generic
  `requireCurrent` rejects the tenure;
- later normal `finally` cleanup is harmless and does not corrupt registry
  state.

Confirm this test does not rely on an impossible production state that the
implementation itself could never represent.

If it uses a deliberately impossible test-only state, explain why that is still
a valid unit proof of the capability's grounding and why the friend seam cannot
leak into production.

---

# 8. Re-review the generic registry as a minimal primitive

Confirm the implementation still owns only:

- one live tenure per typed key;
- opaque tenure identity;
- scoped acquisition/re-entry/release;
- exact current proof;
- stale/released/wrong-key/wrong-registry/disposed rejection;
- bounded diagnostics.

It must remain ignorant of:

- archive operation kinds;
- checkpoint policy;
- database/resource policy;
- Onboarding;
- FDA/Contacts;
- workflow/retry/presentation policy;
- native process locks.

Report any domain concept that leaked into the generic layer during Prompt 04.

---

# 9. Re-review acquisition and re-entry mechanical impossibility

Trace `runExclusive` and `runReentrant`.

Confirm:

> If you are not holding the Ball, you cannot enter the protected track.

and:

> Exact current Ball permits deliberate re-entry without creating a second Ball.

Verify:

- acquisition state is established synchronously before admitted work starts;
- foreign denial occurs before action start;
- denied acquisition consumes no occurrence;
- re-entry reuses the exact tenure;
- nested scope counting is exact;
- final release kills the Ball exactly once;
- no queue/fairness semantics appeared.

---

# 10. Re-review ArchiveMutationCoordinator ownership boundary

Confirm the generic extraction still leaves all archive policy in the archive
domain.

`ArchiveMutationCoordinator` must retain ownership of:

- `ArchiveMutationOperation`;
- checkpoint requirements;
- archive environment/instance diagnostics;
- nested archive operation scope;
- aggregate operation strength;
- resource-admission policy;
- graph/database reopen policy;
- private Zone lineage;
- `ArchiveMutationCapability`.

The generic registry alone must decide whether a foreign owner can acquire the
archive-mutation track.

There must not be a second occupancy decision hiding in the archive active-scope
map.

---

# 11. Re-review diagnostics and adopter restrictions

Inspect the strengthened architecture tripwire.

Confirm it catches all production use of the generic authority essential,
including:

- provider access;
- direct registry type use/injection;
- tenure use;
- key use;
- exception use where relevant;
- diagnostic-state use.

Verify that only `ArchiveMutationCoordinator` is an approved production adopter.

Also confirm diagnostics cannot be used as pseudo-proof:

- `isHeld`;
- owner label;
- occurrence number;
- timestamps;
- denial count.

The actual live proof path must terminate at registry identity/current-tenure
validation, not observable diagnostic state.

---

# 12. Re-review architecture-test quality

Determine whether the architecture suite now mechanically protects:

- sole production key;
- sole production adopter;
- hidden test-only seams;
- no public release;
- no ambient current-tenure lookup;
- no serialization;
- generic domain ignorance;
- diagnostic/proof separation;
- production refresh/invalidation prohibition;
- presentation/workflow separation;
- native-lock separation.

Avoid accepting checks that merely search one current symbol spelling while a
semantically equivalent violation could evade the rule.

At the same time, do not require unnecessary private source layout that would
make a conforming refactor impossible.

Report only material brittleness.

---

# 13. Re-review tests as proof

Inspect the current generic and archive regression tests.

Confirm the reported cases truly reach their claimed boundaries.

Particularly inspect:

- foreign denial before callback starts;
- explicit current proof across awaits;
- same-Ball re-entry;
- child outliving outer scope;
- stale internal cleanup replay;
- stale Ball 1 while Ball 2 is live;
- foreign registry;
- container disposal;
- equal owner labels;
- retained old-Zone stale capability;
- isolated generic-tenure capability grounding.

Concurrency/currentness proof must use deterministic barriers/completers, not
timing sleeps.

---

# 14. Diff and scope sanity

Inspect the complete Feature 35 diff for:

- duplicate generic tenure logic;
- unnecessary framework machinery;
- a second production key/adopter;
- public APIs wider than intended;
- test-support leakage;
- unrelated generated churn;
- unrelated archive refactors;
- Onboarding changes;
- Environment Readiness/presentation changes;
- database/persisted-format/native changes;
- privacy/data-safety changes.

The Prompt 03 optional broad exception-catch observation remains optional.
Do not fail the review merely because that hypothetical future-second-adopter
concern remains unchanged.

---

# 15. Validation scope

Prompt 04 already reports:

- generic suite: 23 passed;
- archive coordinator: 17 passed;
- combined focused regressions: 85 passed;
- Feature 35 architecture: 14 passed;
- complete architecture suite: 501 passed;
- analyzer: clean;
- generation: consistent;
- `git diff --check`: passed;
- Project Conformance: PASS;
- remaining BLOCKER: 0;
- remaining SHOULD FIX: 0.

Do not rerun the full repository suite during this review.

Run only narrow tests if source inspection reveals a specific ambiguity that
cannot otherwise be resolved.

If this review passes, the next step will be final validation/checkpoint of
Feature 35.

---

# 16. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/05-REPEAT-HUMAN-ARCHITECTURAL-REVIEW.md`

Report:

1. baseline/isolation verdict;
2. generic-registry responsibility verdict;
3. production/test-key boundary verdict;
4. tenure opacity/proof verdict;
5. acquisition/re-entry verdict;
6. release/finally verdict;
7. provider-lifecycle verdict;
8. diagnostics/adopter verdict;
9. exception verdict;
10. archive-adapter ownership verdict;
11. private-Zone verdict;
12. archive-capability grounding verdict;
13. stale internal-release verdict;
14. stale callback/reacquisition verdict;
15. architecture-tripwire verdict;
16. test-quality verdict;
17. concurrency-semantics verdict;
18. diff/scope verdict;
19. concrete BLOCKER findings;
20. concrete SHOULD FIX findings;
21. OPTIONAL findings;
22. narrow tests rerun, if any;
23. exact Feature 35 Git status;
24. frozen Onboarding verification;
25. final checkpoint recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`REPEATED FEATURE 35 HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO PROCEED TO FEATURE 35 FINAL VALIDATION AND CHECKPOINT: YES / NO`

Then STOP.
