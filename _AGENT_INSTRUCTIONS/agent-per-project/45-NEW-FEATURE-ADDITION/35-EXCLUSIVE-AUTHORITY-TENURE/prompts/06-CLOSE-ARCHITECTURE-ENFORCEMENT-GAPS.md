# MessageLens Feature 35
## 06 — Close Remaining Architecture-Enforcement Gaps

Prompt 05 repeated the full Feature 35 human architectural review.

The runtime design remains sound.

There are:

- BLOCKER: 0
- SHOULD FIX: 3

All three remaining findings are **architecture-enforcement gaps**, not runtime
authority defects.

This task corrects only those three mechanical tripwire gaps.

Do NOT redesign the generic tenure model.
Do NOT change runtime authority semantics unless a stop gate below proves the
architecture test cannot express the intended rule without doing so.
Do NOT add another authority key.
Do NOT add another adopter.
Do NOT broaden archive policy.
Do NOT touch Onboarding.
Do NOT stage or commit.
Do NOT merge, rebase, cherry-pick, or push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/02-IMPLEMENT-EXCLUSIVE-AUTHORITY-TENURE.md`
- `responses/03-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md`
- `responses/05-REPEAT-HUMAN-ARCHITECTURAL-REVIEW.md`

Governing rule:

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

---

# 1. Baseline

Work only in:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

Expected:

- branch: `feature/exclusive-authority-tenure`
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`
- upstream: `origin/main`
- ahead/behind: `0/0`
- index: empty

Confirm Prompt 05 changed no implementation or tests.

Re-verify the frozen Onboarding worktree remains unchanged:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty
- preservation hashes unchanged
- parked patch unchanged and unapplied

If either worktree differs materially, STOP AND REPORT.

---

# 2. SHOULD FIX 1 — Make sole-key and friend-seam enforcement exhaustive

Prompt 05 found that the current architecture test can miss:

- a differently spelled second key declaration inside the already-approved key
  library;
- additional private-constructor use inside the approved key library; and
- test-support symbols referenced by other production files inside
  `lib/essentials/exclusive_authority/`.

Correct the architecture test so the rule is mechanical.

## Required property

Production must have exactly one constructible authority key:

`ExclusiveAuthorityKey.archiveMutation`

The only non-production independent key may be created by the two designated
friend test-support files.

## Required proof

The architecture test must detect **all** production key construction or
declaration shapes, not only one source spelling.

Use the strongest practical source/AST/import property available in this
repository.

At minimum, the test must fail if someone adds any of these in production:

```dart
static const ExclusiveAuthorityKey another = ExclusiveAuthorityKey._(...);
```

```dart
static const another = ExclusiveAuthorityKey._(...);
```

```dart
static ExclusiveAuthorityKey get another =>
    ExclusiveAuthorityKey._(...);
```

```dart
final another = ExclusiveAuthorityKey._(...);
```

or an equivalent production constructor expression.

The test should not depend on optional type annotation spelling.

## Friend-seam enforcement

Scan **all production Dart files under `lib/`**, including the generic essential,
except the exact two designated friend test-support files.

Reject references to:

- `ExclusiveAuthorityKeyTestSupport`;
- registry test-support symbols;
- test-only constructor helpers;
- any legacy `testOnlyIndependent` spelling;
- any other test-only authority mechanism introduced later.

Do not exempt the entire generic-essential directory.

The two friend files themselves may use the private constructor/test seam; no
other production file may.

---

# 3. SHOULD FIX 2 — Close refresh/invalidation aliases and indirection

The selected lifecycle contract remains:

> `exclusiveAuthorityRegistryProvider` is stable for one ProviderContainer
> lifetime. Production refresh/invalidation is unsupported.

Prompt 05 found the current test catches only direct calls whose first argument
uses the unqualified provider spelling.

Strengthen the enforcement so equivalent production usage also fails.

## Required property

Outside tests, no production code may:

- refresh;
- invalidate;
- hand off for later refresh/invalidation;
- alias for refresh/invalidation;
- wrap refresh/invalidation

of `exclusiveAuthorityRegistryProvider`.

## Preferred enforcement strategy

Because `ArchiveMutationCoordinator` is the sole production adopter, constrain
every production occurrence of the provider to the exact set of allowed
read/notifier-access patterns needed by that adapter.

That is stronger and simpler than trying to recognize every possible
`refresh(...)` syntax.

For example, the architecture test may:

1. inventory every production reference to
   `exclusiveAuthorityRegistryProvider`;
2. require each reference to occur only in the approved archive adapter;
3. require each use to match one of the small allowed notifier-read/access
   shapes;
4. reject all other use, including:
   - prefixed imports;
   - local aliases;
   - assignment to another variable;
   - passing the provider as an argument;
   - returning it from a helper;
   - wrapper-mediated refresh/invalidation.

Do not make the rule depend only on the literal text:

```dart
invalidate(provider: exclusiveAuthorityRegistryProvider)
```

The property is **no production lifecycle manipulation of the provider**.

If the approved adapter itself does not need direct provider-object handling,
the simplest acceptable rule is to forbid provider-object escape entirely.

---

# 4. SHOULD FIX 3 — Make diagnostic state mechanically unusable as authority

Prompt 05 found that the approved archive adapter could theoretically infer the
provider state type and use diagnostic fields such as:

- `isHeld`;
- owner label;
- occurrence number;
- timestamps;
- denial counters;

without spelling the diagnostic type name.

That would evade the current architecture test.

Correct the test so the approved adapter may use only the live proof path.

## Required property

`ArchiveMutationCoordinator` may obtain authority only through:

- the registry/notifier;
- exact tenure;
- `requireCurrent`;
- `runExclusive`;
- `runReentrant`;
- the archive-domain capability built on those proof mechanisms.

It may not authorize work from observable registry diagnostic state.

## Mechanical enforcement

Constrain the archive adapter's use of the generic provider/registry to the
small approved proof API surface.

Reject production use in the adapter of:

- diagnostic state access;
- `diagnosticFor(...)`;
- `isHeld`;
- diagnostic owner label;
- occurrence;
- acquisition/release timestamps;
- denial count;
- any inferred state object used to make an authorization decision.

Prefer a positive allowlist of permitted generic-authority member calls in the
sole adopter over a brittle scan for every current diagnostic field name.

A future new diagnostic field should not automatically become usable as proof.

---

# 5. Unify the adopter/key/lifecycle/diagnostic census

Avoid three unrelated regex islands if one clearer policy can enforce the
boundary.

The architecture test should conceptually establish:

```text
production generic-authority consumers
    == exactly ArchiveMutationCoordinator

production authority keys
    == exactly archiveMutation

production use of registry/provider by ArchiveMutationCoordinator
    == approved proof/acquisition API only

production diagnostic state
    != authority proof

production provider refresh/invalidation
    == forbidden

production friend/test seams
    == forbidden
```

It is acceptable to implement this with several helper functions, but they
should operate on one coherent census of production files and symbols.

Failure messages should identify:

- violating file;
- violating symbol/use;
- which architectural rule was broken.

---

# 6. Add mutation tests for the architecture tripwire itself

Do not merely make the current repository green.

Add focused architecture-test fixtures/virtual source cases proving the new
rules fail for semantically equivalent violations.

At minimum prove the test catches:

1. second production key with explicit type annotation;
2. second production key with inferred type;
3. getter-created second key;
4. friend helper referenced from another generic production file;
5. direct provider refresh;
6. prefixed provider refresh;
7. provider assigned to an alias then handed to a helper;
8. wrapper-mediated provider lifecycle manipulation;
9. adapter reading `diagnosticFor(...).isHeld`;
10. adapter storing inferred diagnostic state and branching on a diagnostic
    field;
11. approved adapter using `requireCurrent` or equivalent proof path succeeds;
12. designated friend files remain allowed.

Use the same production policy helpers for virtual cases that the real census
uses. Do not create a simplified parallel checker.

---

# 7. Preserve runtime code unless mechanically necessary

The Prompt 05 review found no runtime defect.

Therefore the expected correction should primarily affect:

`test/architecture/exclusive_authority_architecture_test.dart`

and possibly narrow test-support organization if required for truly mechanical
enforcement.

Do not modify runtime production code simply to make the architecture test
easier unless source inspection proves the current public surface itself makes
the intended rule impossible to enforce.

If production API narrowing is genuinely necessary, STOP AND REPORT before
changing it.

---

# 8. Reconfirm the four previously corrected Prompt 03 findings

While updating the architecture test, re-run the relevant source checks and
confirm:

- test-only key seam remains mechanically closed;
- provider lifecycle remains stable for container lifetime;
- stale/double internal cleanup proof still reaches real release logic;
- retained old-Zone capability proof still reaches stale lineage;
- generic-tenure grounding proof still reaches `requireCurrent`.

Do not reopen these implementations unless the new test reveals a real defect.

---

# 9. Validation

After correction run:

1. Feature 35 architecture test;
2. complete architecture suite;
3. generic authority test suite;
4. archive coordinator test suite;
5. focused combined Feature 35 regression bundle if cheap;
6. `flutter analyze --no-pub`;
7. `git diff --check`.

Generation is unnecessary unless annotated/generated production source changes.

Do not rerun the complete repository Flutter suite yet; no runtime redesign is
expected.

The full suite belongs after the repeated human gate passes and immediately
before checkpoint.

---

# 10. Project Conformance correction-delta review

Re-evaluate Feature 35 against the three Prompt 05 findings.

Require proof that:

- exactly one production authority key exists;
- only designated friend files can use test-only key/support mechanisms;
- `ArchiveMutationCoordinator` is the sole production adopter;
- provider refresh/invalidation cannot be introduced through alias or wrapper;
- diagnostic state cannot become pseudo-authority, even through inferred types;
- approved proof paths remain available and explicit;
- no runtime/domain boundary changed.

Require:

`PROJECT CONFORMANCE: PASS`

with zero unresolved BLOCKER and zero unresolved SHOULD FIX findings.

---

# 11. Leave everything unstaged

Even if all validation passes:

- do not stage;
- do not commit;
- do not push;
- do not merge;
- do not integrate into `main`;
- do not touch the frozen Onboarding worktree.

Repeat the human architectural gate one final time before checkpoint.

---

# 12. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/06-CLOSE-ARCHITECTURE-ENFORCEMENT-GAPS.md`

Report:

1. baseline/isolation;
2. sole-production-key enforcement;
3. friend-seam enforcement;
4. provider-use census;
5. refresh/invalidation enforcement;
6. diagnostic/proof enforcement;
7. unified architecture policy;
8. virtual/mutation architecture tests;
9. runtime production changes, if any;
10. Feature 35 architecture result;
11. complete architecture result;
12. generic suite result;
13. archive coordinator result;
14. focused regression result;
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
25. readiness for final repeated human review.

Conclude exactly:

`FEATURE 35 ARCHITECTURE-ENFORCEMENT GAPS CLOSED: YES / NO`

If YES, also conclude:

`READY FOR FINAL FEATURE 35 HUMAN ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
