# MessageLens Feature 35
## 08 — Replace Regex Boundary Claims with AST-Backed Enforcement — Response

Date: 2026-09-26

## 1. Baseline and isolation

Work was confined to:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

The pre-change Feature 35 baseline matched the prompt:

- branch: `feature/exclusive-authority-tenure`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- shared-instructions pointer: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty.

Prompt 07 changed no implementation or test file. Before this correction the
same three previously reviewed tracked Feature 35 files were modified, the
same Feature 35 production/test additions were untracked, and only the Prompt
08 record had been added since the Prompt 07 review.

The frozen Onboarding worktree passed its full preservation gate before any
edit. It was not modified at any point.

## 2. Parser/AST mechanism

The correction uses the repository's existing direct dev dependency on
`analyzer` 7.6.0. No dependency or `pubspec` change was needed.

The real repository sources and every virtual mutation source are still fed to
the same `_ExclusiveAuthorityProductionPolicy`. That policy now calls
`parseString` and audits `CompilationUnit` syntax trees. A parse diagnostic is
itself an actionable `dart-syntax` architecture violation, so a malformed
fixture cannot manufacture a passing policy result.

The constructor census uses:

- `ClassDeclaration` and `ConstructorDeclaration`;
- `InstanceCreationExpression` for explicit `new`/`const` construction;
- `MethodInvocation` for the unresolved parser form of implicit constructor
  invocations such as `ExclusiveAuthorityKey._(...)`;
- `PrefixedIdentifier` and `PropertyAccess` for constructor tear-offs,
  including import-prefixed syntax.

The friend census walks `CompilationUnit.declarations` directly. Regex remains
only in the unrelated Prompt 06 checks that were not part of these two gaps.

## 3. Constructor-declaration census

The policy now requires, from AST nodes:

- exactly one `ExclusiveAuthorityKey` class declaration;
- that declaration to be at
  `lib/essentials/exclusive_authority/domain/exclusive_authority_key.dart`;
- the class to remain `final`;
- exactly one constructor declaration;
- that constructor to be the const, private, generative `_` constructor;
- no external, factory, redirecting, public, unnamed, or additional named
  constructor.

The canonical `archiveMutation` field is also inspected as AST structure. It
must remain the single static const field of that name initialized by
`ExclusiveAuthorityKey._('archiveMutation')`.

Current production result:

- key class declarations: **1**;
- constructor declarations: **1**;
- approved constructor: `const ExclusiveAuthorityKey._(...)`;
- additional constructor paths: **0**.

## 4. Constructor-use census

Every parsed production unit is visited for constructor invocations and
tear-offs. The accepted multiset is exactly:

1. one `_` invocation in `exclusive_authority_key.dart` for
   `archiveMutation`;
2. one `_` invocation in `exclusive_authority_key_test_support.dart` for the
   independent test key.

Every missing expected use and every extra invocation or tear-off reports the
file, constructor spelling, use kind, and source offset.

Current production result:

- approved invocations: **2**;
- additional invocations: **0**;
- constructor tear-offs: **0**.

The existing key-member policy is now fed from AST member references as well.
Outside the key/friend units, the only admitted key member remains
`ExclusiveAuthorityKey.archiveMutation` in the archive coordinator adapter.

## 5. Friend top-level declaration census

The friend boundary no longer infers declarations from selected regex forms.
It enumerates all AST top-level declarations, including:

- classes, enums, mixins, extension types;
- named and unnamed extensions;
- typedefs;
- functions, getters, and setters;
- every variable in a top-level variable declaration, regardless of explicit
  type, `const`, `final`, `var`, or `late`;
- a fail-closed descriptor for any future parser-supported declaration kind
  not explicitly classified.

The comparison checks both the exact declaration descriptions and declaration
count, so duplicate declarations cannot disappear inside a set comparison.

## 6. Exact approved friend declarations

The key friend part permits exactly:

- `class ExclusiveAuthorityKeyTestSupport`.

The registry friend part permits exactly:

- `class ExclusiveAuthorityRegistryTestSupport`;
- `class ExclusiveAuthorityScopeCleanupTestHandle`.

The only designated friend files remain:

- `exclusive_authority_key_test_support.dart`;
- `exclusive_authority_registry_test_support.dart`.

Unexpected declarations are rejected at their friend file before downstream
symbol-use scanning is considered.

## 7. New constructor mutation tests

The unified policy now proves rejection of:

1. a second private named constructor;
2. a public unnamed generative constructor;
3. a public named constructor;
4. a factory constructor returning a key;
5. a redirecting generative constructor;
6. a second construction site using an alternate constructor;
7. a private constructor tear-off.

The existing explicit-type, inferred-type, getter-created, and canonical
positive fixtures remain. The tear-off and alternate-construction fixtures
assert the specific AST use-census violation rather than merely accepting a
different failure from the same rule.

## 8. Typed mutable friend-alias mutation

The exact Prompt 07 escape is covered:

```dart
ExclusiveAuthorityKey independentAlias =
    ExclusiveAuthorityKeyTestSupport.independent;
```

A separate generic production source uses only `independentAlias`; it does not
spell the test-support class, `testOnlyIndependent`, or another known helper.
The test specifically requires a violation at the friend file containing
`variable independentAlias`. It therefore proves rejection at the declaration
boundary and does not rely on downstream symbol scanning.

## 9. Other friend-surface mutation tests

The AST friend census also proves direct boundary rejection of:

- a typed top-level `final` alias;
- a `late` typed variable;
- a top-level getter alias;
- a top-level function returning the test key;
- a typedef;
- a named extension.

The pre-existing added top-level function mutation remains and now asserts its
AST declaration description.

## 10. Unchanged Prompt 06 policy checks

The correction did not weaken or redesign any Prompt 06 enforcement. The same
policy still covers:

- sole production adopter and the all-`lib/` census;
- provider lifecycle prohibition and provider alias/wrapper escapes;
- diagnostics-not-proof;
- the approved registry proof API surface;
- friend-symbol leakage outside the exact friend parts;
- no public release or ambient current-tenure lookup;
- no serialization;
- presentation/workflow separation;
- native-lock separation.

## 11. Runtime production changes

**None for Prompt 08.**

Only
`test/architecture/exclusive_authority_architecture_test.dart` changed for this
correction, plus this Prompt 08 response record. The generic tenure model,
archive adapter, generated providers, friend production parts, domain policy,
Onboarding, dependencies, and release metadata were not changed.

## 12. Feature 35 architecture result

Command:

`flutter test test/architecture/exclusive_authority_architecture_test.dart --reporter expanded`

Result: **PASS — 36 tests passed**.

The previous 23 tests remain green and the 13 new AST/mutation tests pass.

## 13. Complete architecture result

Command:

`flutter test test/architecture --reporter expanded`

Result: **PASS — 523 tests passed**.

This is the previous 510-test result plus the 13 new Prompt 08 cases.

## 14. Generic authority suite result

Command:

`flutter test test/essentials/exclusive_authority/application/exclusive_authority_registry_provider_test.dart --reporter expanded`

Result: **PASS — 23 tests passed**.

## 15. Archive coordinator suite result

Command:

`flutter test test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart --reporter expanded`

Result: **PASS — 17 tests passed**.

## 16. Analyzer result

Command: `flutter analyze --no-pub`

Result: **PASS — no issues found**.

## 17. Diff hygiene

`git diff --check` passed. The untracked architecture test was also checked as
a complete added file with `git diff --no-index --check`; it reported no
whitespace errors. `dart format` reports the file formatted.

## 18. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The two Prompt 07 findings are closed:

- constructor enforcement is derived from constructor declarations,
  invocations, and tear-off AST shapes rather than the `_` spelling regex;
- friend declaration enforcement is derived from all top-level AST
  declarations rather than selected declaration regexes.

Current production still has one typed key, one production adopter, and only
the two exact friend parts. No runtime or domain boundary changed.

## 19. Remaining BLOCKER findings

**BLOCKER: 0**

## 20. Remaining SHOULD FIX findings

**SHOULD FIX: 0**

## 21. Exact Feature 35 Git status

- branch: `feature/exclusive-authority-tenure`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- tracked worktree: the same three previously reviewed modified archive
  coordinator/generated/test files;
- untracked: eight Feature 35 prompts, eight Feature 35 responses, nine generic
  production/generated/friend files, the Feature 35 architecture test, and the
  generic registry test;
- shared-instructions pointer: unchanged and uninitialized, not dirty.

Nothing is staged, committed, pushed, merged, rebased, or cherry-picked.

## 22. Frozen Onboarding verification

The frozen worktree remains:

- path: `/Users/rob/Development/FlutterProjects/remember_every_text`;
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

The parked patch remains present and unapplied. No frozen file was edited,
staged, restored, switched, stashed, or cleaned.

## 23. Stop gates

No stop gate was encountered:

- the existing analyzer dependency supported the correction;
- no baseline or preservation mismatch occurred;
- no runtime redesign or unrelated change was needed;
- no app was launched;
- no real database or attachment archive was accessed;
- no staging or Git integration action occurred.

## 24. Readiness for final targeted human review

The AST correction is complete and mechanically validated. The unchanged
runtime authority model and the new AST enforcement are ready for the final
targeted Feature 35 human review requested by Prompt 08.

`FEATURE 35 AST ENFORCEMENT COMPLETE: YES`

`READY FOR FINAL TARGETED FEATURE 35 HUMAN REVIEW: YES`
