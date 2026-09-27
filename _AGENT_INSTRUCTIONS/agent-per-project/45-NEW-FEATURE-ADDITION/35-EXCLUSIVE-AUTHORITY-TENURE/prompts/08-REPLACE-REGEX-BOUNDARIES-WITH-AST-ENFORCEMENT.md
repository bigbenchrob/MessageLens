# MessageLens Feature 35
## 08 — Replace Regex Boundary Claims with AST-Backed Enforcement

Prompt 07 completed the final human architectural review.

The runtime authority design remains sound.

There are:

- BLOCKER: 0
- SHOULD FIX: 2

Both remaining findings are confined to the architecture policy in:

`test/architecture/exclusive_authority_architecture_test.dart`

They are false-negative gaps in two claims that the test currently presents as exhaustive:

1. the production authority-key constructor census;
2. the friend test-seam top-level declaration census.

No runtime production change is indicated.

This task corrects **only those two architecture-policy gaps**.

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

- `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `responses/03-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`
- `responses/04-CORRECT-PRE-CHECKPOINT-ARCHITECTURAL-FINDINGS.md`
- `responses/05-REPEAT-HUMAN-ARCHITECTURAL-REVIEW.md`
- `responses/06-CLOSE-ARCHITECTURE-ENFORCEMENT-GAPS.md`
- `responses/07-FINAL-HUMAN-ARCHITECTURAL-REVIEW-BEFORE-CHECKPOINT.md`

The governing rule remains:

> **The Ball proves exclusive tenure. Domain capability proves what the current owner may do while holding that Ball. Diagnostics prove neither.**

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

Confirm Prompt 07 changed no implementation or tests.

Re-verify the frozen Onboarding worktree remains unchanged:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- index empty
- tracked/untracked preservation state unchanged
- preservation hashes unchanged
- parked patch unchanged and unapplied

If either worktree differs materially, STOP AND REPORT.

---

# 2. Replace the key-constructor regex with an exhaustive Dart syntax census

Prompt 07 found that the current sole-key enforcement recognizes only calls to the private constructor named `_`.

That is not exhaustive.

A second constructor could be introduced as:

```dart
const ExclusiveAuthorityKey.named(...);
```

or a public generative constructor could be added and used without the current regex noticing.

Correct the architecture policy so it reasons from Dart syntax rather than one constructor spelling.

## Required property

The production `ExclusiveAuthorityKey` declaration must have exactly:

- one class declaration;
- one approved private generative constructor used by the canonical production key and the designated test friend;
- no additional generative constructor;
- no named constructor;
- no public constructor;
- no factory constructor;
- no redirecting constructor;
- no other constructor path that ordinary production code can invoke.

Production construction sites must be exactly:

1. the canonical `archiveMutation` construction in the key library;
2. the designated independent test-key construction in the friend part.

No other production Dart source may construct an `ExclusiveAuthorityKey`.

## Implementation approach

Use the Dart parser/analyzer AST if available in the repository/test environment.

Prefer AST-backed inspection for:

- class declarations;
- constructor declarations;
- constructor names;
- constructor visibility;
- constructor invocations/instance creation expressions;
- constructor tear-offs where applicable.

Do not expand the regex set to enumerate more spellings.

The point is to make the claim exhaustive rather than chase syntax variants.

If the current architecture-test environment cannot use the Dart analyzer/parser without adding a new runtime dependency or broad infrastructure change, STOP AND REPORT before introducing one.

A test-only/dev dependency already present in the Flutter/Dart toolchain may be used if project rules permit it.

---

# 3. Add constructor mutation cases that previously escaped

Using the same real architecture-policy helper, add mutation fixtures proving the audit fails for at least:

1. a second private named constructor;
2. a public unnamed generative constructor;
3. a public named constructor;
4. a factory constructor returning a key;
5. a redirecting constructor if syntactically applicable;
6. a second construction site using an alternate constructor;
7. a constructor tear-off if that syntax could expose construction.

Retain the already-covered:

- explicit typed second key;
- inferred second key;
- getter-created second key;
- canonical private constructor usage.

Positive fixtures must still prove the current approved key library passes.

---

# 4. Replace friend-symbol regex discovery with AST-backed top-level declaration census

Prompt 07 found that friend declaration discovery misses valid typed mutable top-level variables.

The friend seam must not depend on hand-enumerating declaration syntax.

Inspect each designated friend part with the Dart parser/AST and enumerate **every top-level declaration** that can create an externally usable symbol.

At minimum include:

- classes;
- enums;
- mixins;
- extensions if named/exportable;
- typedefs;
- top-level functions;
- getters;
- setters;
- top-level variables, regardless of:
  - `const`;
  - `final`;
  - `var`;
  - explicit type;
  - `late`;
- any other named top-level declaration supported by the parser.

The architecture policy should require the friend files to contain exactly the approved declarations and no undeclared public friend surface.

Do not infer friend symbols from a partial regex grammar.

---

# 5. Add the exact escaping friend mutation

Add the counterexample from Prompt 07.

For example, mutate a friend part with a typed mutable top-level alias such as:

```dart
ExclusiveAuthorityKey independentAlias =
    ExclusiveAuthorityKeyTestSupport.independent;
```

Then add a generic production source that uses only:

```dart
independentAlias
```

without spelling:

- `ExclusiveAuthorityKeyTestSupport`;
- `testOnlyIndependent`;
- another previously known helper name.

The audit must fail mechanically.

Also add at least these friend-surface mutations if AST parsing makes them relevant:

- typed top-level `final`;
- `late` typed variable;
- top-level getter alias;
- top-level function returning the test key;
- typedef or named declaration that would widen the friend surface.

The architecture test should reject the unexpected declaration at the friend boundary itself, before relying on downstream symbol-use scanning.

---

# 6. Keep the friend files exact

The approved friend files remain exactly:

- `exclusive_authority_key_test_support.dart`
- `exclusive_authority_registry_test_support.dart`

Their expected top-level declarations must be explicit and narrow.

A future test-support addition must require an intentional architecture-policy change.

Do not permit a general:

> anything inside these friend parts is trusted

rule.

The parts are privileged only for the exact test seams already reviewed.

---

# 7. Keep all Prompt 06 enforcement intact

Do not regress the already-correct architecture rules for:

- sole production adopter;
- all-`lib/` production census;
- provider lifecycle prohibition;
- provider alias/wrapper escape;
- diagnostics-not-proof;
- approved registry proof APIs;
- test-support symbol leakage outside exact friend files;
- no public release;
- no ambient current-tenure lookup;
- no serialization;
- presentation/workflow separation;
- native-lock separation.

The AST-backed constructor/declaration logic should replace only the two non-exhaustive regex claims.

Do not rewrite the rest of the architecture policy without a concrete need.

---

# 8. Verify AST policy against the real repository and virtual mutations

The real-tree audit and all mutation fixtures must continue to use the same `_ExclusiveAuthorityProductionPolicy` (or its direct successor).

Do not create a separate parser-only checker whose logic is not used by the real audit.

Failure output should remain actionable:

- violating file;
- violating declaration/construction;
- architectural rule violated.

---

# 9. Validation

Run:

1. Feature 35 architecture test;
2. complete architecture suite;
3. `flutter analyze --no-pub`;
4. `git diff --check`.

Also rerun the generic authority and archive coordinator suites if the architecture-test refactor touches any shared test-support part used by those runtime tests.

Generation is unnecessary unless annotated/generated production source changes.

Do not rerun the full repository Flutter suite yet.

No runtime production behavior is expected to change.

---

# 10. Project Conformance correction-delta review

Re-evaluate the two Prompt 07 findings.

Require proof that:

- constructor enforcement is exhaustive over Dart constructor declarations and construction expressions rather than one constructor name;
- friend declaration enforcement is exhaustive over Dart top-level declarations rather than selected regex forms;
- current production still has exactly one authority key;
- only the exact designated friend seams can create test authority;
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

After this correction, run one final targeted human gate focused on the new AST enforcement plus the unchanged runtime authority model.

---

# 12. Required response

Create:

`35-EXCLUSIVE-AUTHORITY-TENURE/responses/08-REPLACE-REGEX-BOUNDARIES-WITH-AST-ENFORCEMENT.md`

Report:

1. baseline/isolation;
2. parser/AST mechanism used;
3. constructor-declaration census;
4. constructor-use census;
5. friend top-level declaration census;
6. exact approved friend declarations;
7. new constructor mutation tests;
8. typed mutable friend-alias mutation test;
9. other friend-surface mutation tests;
10. unchanged Prompt 06 policy checks;
11. runtime production changes, if any;
12. Feature 35 architecture result;
13. complete architecture result;
14. generic suite result if rerun;
15. archive coordinator result if rerun;
16. analyzer result;
17. `git diff --check`;
18. Project Conformance verdict;
19. remaining BLOCKER findings;
20. remaining SHOULD FIX findings;
21. exact Feature 35 Git status;
22. frozen Onboarding verification;
23. stop gates;
24. readiness for final targeted human review.

Conclude exactly:

`FEATURE 35 AST ENFORCEMENT COMPLETE: YES / NO`

If YES, also conclude:

`READY FOR FINAL TARGETED FEATURE 35 HUMAN REVIEW: YES / NO`

Then STOP.
