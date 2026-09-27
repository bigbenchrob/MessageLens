# MessageLens Feature 35
## 10 — Close the Remaining Constructor-Alias Enforcement Gap — Response

Date: 2026-09-26

## 1. Baseline and isolation

**NO ISSUE.**

Work was confined to:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

The pre-change baseline matched the prompt:

- branch: `feature/exclusive-authority-tenure`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- tracked modifications: the same three previously reviewed archive
  coordinator/generated/test files;
- shared-instructions pointer:
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty.

Prompt 09 changed no implementation or test file. At the start of Prompt 10,
the Feature 35 architecture-test SHA-256 remained
`1ea19878804cb042ece9f649a6763db3d922f99be0dc7df63531b18d8f99e7b1`;
only the Prompt 10 record had been added since Response 09.

The frozen Onboarding worktree matched its branch, HEAD, empty index,
tracked/untracked counts, submodule state, and preservation hashes before the
correction. It was not modified.

## 2. Exact legal scope of private-constructor access

The private constructor `_` is accessible only inside the Dart library that
declares `ExclusiveAuthorityKey`. In the current source layout that privileged
library consists exactly of:

- `exclusive_authority_key.dart`; and
- its sole declared part,
  `exclusive_authority_key_test_support.dart`.

Targeted Dart analyzer probes confirmed:

- a direct same-library typedef alias can invoke `_`;
- a transitive same-library alias chain can invoke `_`;
- a same-library alias constructor tear-off is legal;
- an alias declared in a different importing library cannot invoke `_` and is
  rejected with an undefined private constructor error.

The temporary probes were outside both worktrees and were removed immediately.
This confirms the escape can be closed completely at the two existing
privileged units without project-wide semantic resolution.

## 3. Selected correction approach

The correction uses the prompt's preferred smallest reliable rule: exact
AST-backed privileged-library surface closure.

The existing `_topLevelDeclarationCensus` is now also applied to
`exclusive_authority_key.dart`. The same `_ExclusiveAuthorityProductionPolicy`
continues to audit both the real repository and every virtual mutation.

This adds no resolver infrastructure, dependency, production parser, or
runtime code.

## 4. Privileged key-library surface rule

The key library must now contain exactly one top-level declaration:

- `class ExclusiveAuthorityKey`.

Declaration identity and declaration count must both match. Therefore the key
library cannot add a top-level:

- typedef or alias chain;
- variable;
- getter or function;
- enum, mixin, class, extension, or extension type;
- unknown future `CompilationUnitMember`.

The existing constructor-declaration census still requires the class to remain
`final` with exactly the one approved const private generative constructor.
The canonical field and literal constructor-use censuses remain separate
defence-in-depth checks.

The existing part-directive policy still permits only
`exclusive_authority_key_test_support.dart`, and that friend's declaration
census still permits only `class ExclusiveAuthorityKeyTestSupport`. An alias
cannot be introduced in another privileged part without an intentional policy
change.

## 5. Resolved semantic-constructor rule

**Not used and not needed.**

The exact library/part boundary fully contains private-constructor access.
Resolved whole-project element analysis would add infrastructure without
closing any route left open by the stricter privileged-surface rule.

## 6. Direct alias mutation result

The exact mutation was added to the unified policy fixture:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;
const another = KeyAlias._('another');
```

Result: **PASS — mechanically rejected** by `sole-production-key` at the key
library path. The assertion requires the privileged-surface diagnostic to name
`typedef KeyAlias`; it cannot pass because of malformed syntax or an unrelated
policy rule.

## 7. Transitive alias mutation result

The valid transitive case was added:

```dart
typedef KeyAlias1 = ExclusiveAuthorityKey;
typedef KeyAlias2 = KeyAlias1;
const another = KeyAlias2._('another');
```

Result: **PASS — mechanically rejected** at the key-library declaration
boundary, with the assertion requiring `typedef KeyAlias2` in the diagnostic.

Because every top-level type alias is forbidden in the privileged key library,
alias-chain length cannot evade the rule.

## 8. Alias tear-off result and legality

Dart permits this inside the same library:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;
final constructor = KeyAlias._;
```

The targeted analyzer probe reported no issue. A matching unified-policy
mutation was added.

Result: **PASS — mechanically rejected** at the privileged key-library surface,
with the assertion requiring `variable constructor` in the diagnostic.

## 9. Preservation of prior AST rules

**NO ISSUE.**

The correction extends `_auditProductionKeys`; it does not replace or weaken:

- the exhaustive constructor declaration census;
- the canonical `archiveMutation` AST field check;
- the exact literal invocation/tear-off multiset;
- the exact friend top-level declaration census;
- typed mutable friend-alias rejection;
- friend symbol leakage scanning;
- sole production adopter enforcement;
- provider lifecycle and alias/wrapper prohibition;
- diagnostics-not-proof and approved proof API enforcement;
- no public release, ambient lookup, or serialization;
- presentation/workflow and native-lock separation.

The approved real repository and approved virtual fixture continue to pass the
same unified policy.

## 10. Adversarial sole-key review

**NO ISSUE.**

| Shape | Mechanical disposition |
| --- | --- |
| direct extra `_` construction | extra literal construction use rejected |
| alternate named constructor | constructor count/declaration rejected |
| public constructor | constructor count/declaration rejected |
| factory constructor | constructor declaration rejected |
| redirecting constructor | constructor declaration rejected |
| literal constructor tear-off | extra tear-off rejected |
| direct typedef alias | key top-level declaration rejected |
| transitive typedef alias | every alias declaration rejected |
| alias constructor tear-off | alias and variable declarations rejected |
| top-level variable alias | key top-level variable rejected |
| top-level getter/function alias | key top-level function declaration rejected |
| friend-part alias | exact friend declaration census rejected |
| additional privileged part | exact parent `part` set rejected |
| import-prefixed private constructor | illegal outside the key library; a public constructor would fail the constructor census |

Additional mutations now prove top-level key variable, getter, and function
aliases fail at the privileged boundary. Inside the one approved class, an
additional key creation must still spell the only constructor or take its
tear-off, so the existing use census rejects it. Dart does not permit a nested
typedef that could create another alias inside the class.

The supported claim is now exact:

> Under the current key library and part structure, another constructible
> `ExclusiveAuthorityKey` requires an intentional change to an approved
> architecture surface.

## 11. Runtime production changes

**None.**

Prompt 10 changed only:

- `test/architecture/exclusive_authority_architecture_test.dart`; and
- this response record.

No generic authority implementation, archive adapter, generated source,
friend production part, Onboarding source, dependency, database/archive code,
or release metadata changed. No code generation was needed.

## 12. Feature 35 architecture result

Command:

`flutter test test/architecture/exclusive_authority_architecture_test.dart --reporter expanded`

Result: **PASS — 42 tests passed**.

This is the prior 36-test suite plus six direct/transitive/tear-off and
top-level key-surface mutations.

## 13. Complete architecture result

Command:

`flutter test test/architecture --reporter expanded`

Result: **PASS — 529 tests passed**.

No full repository suite was run. Generic/archive runtime suites were not
rerun because no runtime source or shared test-support source changed.

## 14. Analyzer result

Command: `flutter analyze --no-pub`

Result: **PASS — no issues found**.

## 15. Diff hygiene

`git diff --check` passed. The complete untracked architecture test was also
checked as an added file with `git diff --no-index --check`; it reported no
whitespace errors. `dart format` reports the file formatted.

## 16. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

- current production constructible authority keys: exactly one,
  `ExclusiveAuthorityKey.archiveMutation`;
- typedef/type aliases cannot introduce another constructible key without
  first violating the privileged key-library surface;
- friend seams remain exact;
- runtime/domain boundaries are unchanged.

## 17. Remaining BLOCKER findings

**BLOCKER: 0**

## 18. Remaining SHOULD FIX findings

**SHOULD FIX: 0**

The Prompt 09 constructor-alias finding is closed.

## 19. Exact Feature 35 Git status

After adding this response:

- branch: `feature/exclusive-authority-tenure`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- tracked modifications: exactly three:
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`;
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart`;
  - `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart`;
- untracked files: 31:
  - ten Feature 35 prompts;
  - ten Feature 35 responses;
  - nine generic-authority production/generated/friend files;
  - the generic authority test;
  - the Feature 35 architecture test;
- shared-instructions pointer: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty.

Nothing is staged, committed, pushed, merged, rebased, or cherry-picked.

## 20. Frozen Onboarding verification

**NO ISSUE.**

The frozen worktree remains:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`;
- index: empty;
- tracked delta: 47 modified and 2 deleted files;
- fully enumerated untracked files: 76;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: passed.

Preservation hashes remain:

| Artifact | SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| tracked frozen delta (`git diff --binary --full-index`) | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f48715845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

The parked patch remains present, byte-identical, and unapplied. No frozen file
was edited, staged, restored, switched, stashed, or cleaned. No real database
or attachment archive was accessed.

## 21. Stop gates

No stop gate was encountered:

- private-constructor access was fully containable at the current key
  library/part boundary;
- no resolver or dependency expansion was needed;
- no baseline or preservation mismatch occurred;
- no runtime or unrelated correction was needed;
- no app was launched and no real data was accessed;
- no staging or Git integration action occurred.

## 22. Readiness for final sole-key micro-review

The remaining constructor-alias route is now rejected at the earliest
privileged declaration boundary. The correction and its direct, transitive,
tear-off, and top-level surface mutations are ready for the requested final
sole-key micro-review.

`FEATURE 35 CONSTRUCTOR-ALIAS GAP CLOSED: YES`

`READY FOR FINAL FEATURE 35 SOLE-KEY MICRO-REVIEW: YES`
