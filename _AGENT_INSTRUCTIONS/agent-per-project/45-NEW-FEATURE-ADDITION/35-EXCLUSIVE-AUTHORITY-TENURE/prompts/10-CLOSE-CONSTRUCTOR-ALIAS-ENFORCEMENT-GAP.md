# MessageLens Feature 35
## 10 — Close the Remaining Constructor-Alias Enforcement Gap

Prompt 09 completed the targeted human review of Prompt 08.

The runtime authority design remains sound.

There are:

- BLOCKER: 0
- SHOULD FIX: 1

The single remaining finding is an architecture-test false negative:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;

const another = KeyAlias._('another');
```

This is valid same-library Dart. The current constructor-use visitor sees the
syntactic target `KeyAlias`, not the aliased type, so it does not recognize this
as construction of `ExclusiveAuthorityKey`.

No runtime production change is indicated.

This task corrects **only this one mechanical enforcement gap**.

Do NOT redesign the generic tenure model.
Do NOT modify runtime production authority semantics.
Do NOT add another production key.
Do NOT add another adopter.
Do NOT broaden archive policy.
Do NOT touch Onboarding.
Do NOT stage or commit.
Do NOT merge, rebase, cherry-pick, or push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `responses/07-FINAL-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/08-REPLACE-REGEX-BOUNDARIES-WITH-AST-ENFORCEMENT.md`
- `responses/09-FINAL-TARGETED-HUMAN-REVIEW-AST-ENFORCEMENT.md`
- the current `test/architecture/exclusive_authority_architecture_test.dart`

Governing rule:

> **Production must have exactly one constructible authority key:
> `ExclusiveAuthorityKey.archiveMutation`.**

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

Confirm Prompt 09 changed no implementation or tests.

Re-verify the frozen Onboarding worktree remains unchanged:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty
- preservation hashes unchanged
- parked patch unchanged and unapplied

If either worktree differs materially, STOP AND REPORT.

---

# 2. Close the alias route mechanically

The required invariant is stronger than literal constructor-spelling detection.

A production caller must not be able to create another
`ExclusiveAuthorityKey` through:

- a typedef alias;
- a type alias chain;
- a constructor tear-off through an alias;
- an alternate same-library name for the type;
- another declaration that indirectly exposes the private constructor.

The correction must make this mechanically impossible under the architecture
policy.

Use the **smallest reliable rule** supported by the current library structure.

---

# 3. Prefer closing the privileged library surface over broad semantic resolution

Before introducing analyzer element-resolution machinery, inspect the actual
library/part structure.

Because the `_` constructor is library-private, ordinary code outside the
`ExclusiveAuthorityKey` library cannot call it.

Therefore determine whether the alias escape can exist only inside:

- `exclusive_authority_key.dart`; or
- one of its `part` files.

If yes, prefer an exact AST-backed privileged-library surface rule:

## Key library

Require the key library's top-level declarations to contain only the approved
production declaration(s), with no top-level:

- typedef/type alias;
- variable alias;
- getter/function returning the type;
- extension/extension type that exposes construction;
- additional class/type surface capable of re-exporting private construction.

## Friend part

Continue requiring its exact already-approved test-support declaration and no
additional top-level declaration.

This is preferable to project-wide type resolution if it fully closes the
private-constructor route.

The architecture test should fail at the privileged declaration boundary before
constructor-use tracing becomes relevant.

---

# 4. If privileged-surface closure is insufficient, use resolved identity

If source inspection proves an alias can legally expose the private constructor
from outside the exact key library/parts, then use analyzer resolution to
identify constructor targets by semantic element rather than token spelling.

In that case:

- resolve the relevant library units;
- identify constructor invocations/tear-offs whose resolved constructor belongs
  to `ExclusiveAuthorityKey`;
- follow typedef aliases transitively;
- compare semantic identity, not text.

Do not add a runtime dependency.

Use the existing analyzer dev dependency only.

Do not build a general whole-project semantic analyzer if the exact privileged
library boundary makes that unnecessary.

---

# 5. Add the exact failing mutation

Add a virtual mutation using the same
`_ExclusiveAuthorityProductionPolicy` as the real repository audit:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;

const another = KeyAlias._('another');
```

The mutation must fail.

Assert the failure is specifically caused by the sole-key/privileged-surface
rule, not by unrelated malformed-fixture behavior.

Also add:

```dart
typedef KeyAlias1 = ExclusiveAuthorityKey;
typedef KeyAlias2 = KeyAlias1;

const another = KeyAlias2._('another');
```

if transitive aliasing is valid in the same library and would otherwise evade
the rule.

---

# 6. Cover alias tear-off if legal

If Dart permits a constructor tear-off through the alias, add a mutation such
as the legal equivalent of:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;
final constructor = KeyAlias._;
```

and require rejection.

If that syntax is not legal, record that fact in the response rather than
inventing a fixture.

---

# 7. Preserve all existing AST enforcement

Do not regress:

- exhaustive constructor declaration census;
- canonical `archiveMutation` field check;
- literal constructor-use census;
- exact friend top-level declaration census;
- typed mutable friend-alias rejection;
- friend symbol leakage scan;
- sole production adopter;
- provider lifecycle prohibition;
- diagnostics-not-proof;
- no public release;
- no ambient current-tenure lookup;
- no serialization;
- presentation/workflow separation;
- native-lock separation.

The correction should extend the sole-key proof, not replace the already sound
parts.

---

# 8. Adversarial review of the final sole-key rule

Before declaring success, inspect the corrected rule against these shapes:

- direct `_` construction;
- alternate named constructor;
- public constructor;
- factory/redirecting constructor;
- constructor tear-off;
- direct typedef alias;
- transitive typedef alias;
- top-level variable alias;
- getter/function alias;
- friend-part alias;
- import prefix.

The architecture claim is:

> There is no production syntax path by which another
> `ExclusiveAuthorityKey` can be constructed without an intentional change to
> the approved architecture surface.

Do not claim more than the test actually proves.

---

# 9. Validation

Run:

1. Feature 35 architecture test;
2. complete architecture suite;
3. `flutter analyze --no-pub`;
4. `git diff --check`.

Rerun generic/archive runtime suites only if shared test-support source used by
those tests changes.

No full repository suite yet.

No generation unless annotated/generated production source changes.

---

# 10. Project Conformance correction-delta review

Re-evaluate only the Prompt 09 finding.

Require:

- exactly one production constructible authority key;
- typedef/type aliases cannot create another key;
- friend seams remain exact;
- no runtime/domain boundary changed.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 11. Leave everything unstaged

Even if validation passes:

- do not stage;
- do not commit;
- do not push;
- do not merge;
- do not integrate into `main`;
- do not touch frozen Onboarding.

After this correction, perform one final **micro-review of the sole-key rule
only**. Do not repeat the whole Feature 35 architecture review again unless the
correction unexpectedly changes production code.

---

# 12. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/10-CLOSE-CONSTRUCTOR-ALIAS-ENFORCEMENT-GAP.md`

Report:

1. baseline/isolation;
2. exact legal scope of private-constructor access;
3. selected correction approach;
4. privileged key-library surface rule, if used;
5. resolved semantic-constructor rule, if used;
6. direct alias mutation result;
7. transitive alias mutation result;
8. alias tear-off result/legality;
9. preservation of prior AST rules;
10. adversarial sole-key review;
11. runtime production changes, if any;
12. Feature 35 architecture result;
13. complete architecture result;
14. analyzer result;
15. `git diff --check`;
16. Project Conformance verdict;
17. remaining BLOCKER findings;
18. remaining SHOULD FIX findings;
19. exact Feature 35 Git status;
20. frozen Onboarding verification;
21. stop gates;
22. readiness for final sole-key micro-review.

Conclude exactly:

`FEATURE 35 CONSTRUCTOR-ALIAS GAP CLOSED: YES / NO`

If YES, also conclude:

`READY FOR FINAL FEATURE 35 SOLE-KEY MICRO-REVIEW: YES / NO`

Then STOP.
