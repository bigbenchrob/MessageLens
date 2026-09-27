# MessageLens Feature 35
## 09 — Final Targeted Human Review of AST Enforcement — Response

Date: 2026-09-26

## Executive verdict

Prompt 08 correctly replaced both regex grammars with AST inspection, and the
friend top-level declaration boundary is now exhaustive for the stated scope.
The constructor-declaration census is also exhaustive.

The constructor-**use** census is not yet exhaustive. It parses unresolved
syntax and recognizes an invocation or tear-off only when the syntactic target
is literally named `ExclusiveAuthorityKey`. Dart permits a same-library type
alias to invoke the private constructor:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;

const another = KeyAlias._('another');
```

This is valid Dart, creates a distinct authority key, and is not classified by
the current construction or member visitors. Because a typedef and top-level
key declared in the key source are not otherwise prohibited, the same real
policy can accept this mutation.

This is one bounded SHOULD FIX architecture-enforcement finding. It is not a
current runtime defect and does not justify a runtime authority redesign.

## 1. Baseline and isolation

**NO ISSUE.**

The review was confined to:

`/Users/rob/Development/FlutterProjects/remember_every_text-feature-35`

Verified baseline:

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

Prompt 08 changed only the untracked Feature 35 architecture test and its
response record. No runtime production source changed in Prompt 08. Prompt 09
itself was the only additional untracked item at the start of this review.

The frozen Onboarding worktree passed its preservation gate before review. No
baseline stop gate fired.

## 2. AST parser mechanism verdict

**NO ISSUE with parser adoption and fail-closed parsing; SHOULD FIX in semantic
constructor-target identification.**

The architecture test uses the existing direct dev dependency on `analyzer`
7.6.0. `_productionSources()` supplies the same real `lib/**/*.dart` text to
the same `_ExclusiveAuthorityProductionPolicy` used by virtual mutations.
`parseString` creates a `CompilationUnit` for every source. Parse diagnostics
produce a `dart-syntax` violation and the invalid unit is withheld, so parse
failure cannot become a pass.

Comments and strings do not create declaration or constructor AST nodes. The
new AST work is confined to key construction/member use and friend top-level
declarations; the unrelated Prompt 06 provider, adopter, proof, presentation,
and native-lock checks remain in place. No runtime dependency or production
parser code was introduced.

The remaining problem is that `parseString` produces an unresolved AST. The
visitors compare token spellings rather than resolved constructor identity, so
a valid alias target is invisible to them.

## 3. Constructor-declaration census verdict

**NO ISSUE.**

The policy mechanically requires:

1. exactly one `ClassDeclaration` named `ExclusiveAuthorityKey` across all
   parsed production units;
2. that declaration at the exact key path;
3. the class to remain `final`;
4. exactly one `ConstructorDeclaration`;
5. its name to be `_`;
6. `const` to be present;
7. `external` and `factory` to be absent;
8. no redirecting factory target;
9. no `RedirectingConstructorInvocation` initializer.

The canonical `archiveMutation` field is separately checked as one static const
field with the expected constructor and literal diagnostic name. Second named,
public, factory, redirecting, external, or implicit-only constructor surfaces
cannot pass this declaration census.

## 4. Constructor-use census verdict

**SHOULD FIX.**

For literal class spelling, the accepted multiset is narrow and correct:

- one `_` invocation in `exclusive_authority_key.dart`;
- one `_` invocation in `exclusive_authority_key_test_support.dart`;
- no remaining invocation or tear-off.

Explicit `new`/`const` expressions, unresolved implicit calls, direct
tear-offs, and import-prefixed literal class references are covered by
`InstanceCreationExpression`, `MethodInvocation`, `PrefixedIdentifier`, and
`PropertyAccess` handling.

However, `_isAuthorityKeyReference` accepts only a `SimpleIdentifier` whose
name is literally `ExclusiveAuthorityKey`, or a `PrefixedIdentifier` whose
final identifier has that literal name. Therefore `KeyAlias._(...)` and
`KeyAlias._` are not recorded even when `KeyAlias` resolves to
`ExclusiveAuthorityKey`.

The key source is not subject to the friend declaration census, the key-class
census ignores its additional `TypeAlias` and top-level variable, and the
generic-root adopter census deliberately skips generic-module sources. The
canonical field and two expected literal invocations remain present, so the
alias mutation can leave every current rule satisfied.

The smallest correction is to make constructor-use identity resolution-aware,
or to fail closed over all same-library aliases and their transitive targets.
Add the exact typedef-alias construction mutation to the unified policy tests.
An exact top-level declaration census for the key library could also close the
current route if that stricter boundary is explicitly intended.

## 5. Constructor mutation-test verdict

**NO ISSUE for the seven required Prompt 08 shapes; SHOULD FIX for the newly
identified ordinary Dart alias shape.**

The real `_ExclusiveAuthorityProductionPolicy` used by the repository audit is
also used by every virtual fixture. It rejects:

- a second private named constructor;
- a public unnamed constructor;
- a public named constructor;
- a factory constructor;
- a redirecting constructor;
- an alternate literal construction site;
- a constructor tear-off.

The approved virtual source passes through the same helper. There is no
separate simplified checker. The current suite has no typedef-alias
construction mutation, so its 36 passing tests do not expose the remaining
false negative.

## 6. Friend declaration census verdict

**NO ISSUE.**

`_topLevelDeclarationCensus` walks every `CompilationUnit.declarations` member
and classifies:

- classes;
- enums;
- mixins;
- extension types;
- named and unnamed extensions;
- functions, getters, and setters;
- every variable in each top-level variable declaration, independent of
  `const`, `final`, `var`, explicit type, or `late`;
- all `TypeAlias` forms.

An unknown future `CompilationUnitMember` enters the default branch and becomes
an unsupported declaration rather than disappearing. Identity and count are
both checked: the set of descriptions must match and the declaration-list
length must match, so duplicate declarations cannot collapse to an accepted
set.

Part structure does not hide friend declarations. The two exact friend paths
are enumerated, and the parent libraries' part directive sets are independently
restricted.

## 7. Exact friend-surface verdict

**NO ISSUE.**

The accepted key friend surface is exactly:

- `class ExclusiveAuthorityKeyTestSupport`.

The accepted registry friend surface is exactly:

- `class ExclusiveAuthorityRegistryTestSupport`;
- `class ExclusiveAuthorityScopeCleanupTestHandle`.

No other top-level declaration is accepted. The two `_test_support.dart` files
are the only privileged files. The public seam remains narrowed with `show`,
and scanning for every discovered friend name outside the exact friend files
remains active.

Local/member implementation details inside an approved friend class are not
mistaken for top-level declarations. Formatting and private field/local
renames therefore do not perturb this census. Rejecting an additional private
top-level declaration is intentional because the privileged friend files are
required to have an exact top-level surface.

## 8. Typed-alias escape verdict

**NO ISSUE — the Prompt 07 friend alias escape is closed.**

The mutation adds:

```dart
ExclusiveAuthorityKey independentAlias =
    ExclusiveAuthorityKeyTestSupport.independent;
```

and a generic production consumer that uses only `independentAlias`. Its
assertion requires a `friend-test-seam` violation at the friend file with the
AST description `variable independentAlias`. The test therefore proves the
declaration itself is rejected; it cannot pass solely because downstream code
spells a known helper symbol.

## 9. Other friend mutation verdict

**NO ISSUE.**

The same boundary-level assertion rejects:

- typed top-level `final`;
- `late` typed variable;
- getter alias;
- function returning the test key;
- typedef;
- named extension.

The prior added-function mutation now also asserts the AST declaration at the
friend path.

## 10. AST false-negative/false-positive verdict

**SHOULD FIX — one concrete false negative.**

Concrete valid Dart shape:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;
const another = KeyAlias._('another');
```

A minimal external probe containing the real private constructor and this
same-library alias passed `dart analyze` with **no issues**, confirming this is
ordinary legal Dart rather than hypothetical parser recovery syntax. The
temporary probe was outside both worktrees and was removed immediately.

Tracing it through the actual policy:

- the class and sole constructor declarations remain unchanged;
- canonical `archiveMutation` remains unchanged;
- the construction visitor ignores target `KeyAlias`;
- the member visitor ignores target `KeyAlias`;
- the added typedef/top-level variable are in the key source, not a friend
  source;
- generic-root sources are excluded from the adopter census;
- provider/proof checks are unaffected.

No other ordinary constructor/declaration false negative was found. Literal
import prefixes and tear-offs are covered. The friend census covers all current
top-level AST member kinds and fails closed on future kinds.

No concrete false positive was found in the new AST boundaries. Comments and
strings are inert, declaration formatting is irrelevant, duplicate friend
declarations cannot collapse, and local/member declarations do not widen the
top-level friend surface.

## 11. Prompt 06 regression-check verdict

**NO ISSUE.**

Spot inspection confirms the policy still enforces:

- sole production adopter;
- provider refresh/invalidation prohibition;
- direct, prefixed, aliased, and wrapper-mediated provider escape;
- diagnostics-not-proof;
- only `runExclusive`, `runReentrant`, and `requireCurrent` as approved registry
  proof/acquisition calls;
- no public release;
- no ambient current-tenure lookup;
- no serialization;
- presentation/workflow separation;
- native-lock separation.

The Prompt 08 edits did not remove or broaden those rules.

## 12. Runtime-diff sanity

**NO ISSUE.**

Prompt 08 made no runtime production change. The tracked diff still names only
the same three pre-existing Feature 35 archive adapter/generated/test files.
The generic production additions, runtime tests, provider generation,
dependencies, Onboarding, database/archive code, and native code are unchanged
by Prompt 08.

The previously accepted runtime conclusions therefore remain in force: one
live tenure per key, exact identity proof, exact-scope release, stale cleanup
safety, archive capability grounding, and archive-domain policy ownership in
`ArchiveMutationCoordinator`.

## 13. Concrete BLOCKER findings

**BLOCKER: 0**

No current runtime, data-safety, privacy, archive, or isolation defect was
found.

## 14. Concrete SHOULD FIX findings

**SHOULD FIX: 1**

1. The unresolved constructor-use census can be bypassed by a same-library
   typedef alias of `ExclusiveAuthorityKey`. A distinct key constructed through
   `KeyAlias._(...)` is valid Dart but is not recognized by either AST visitor
   or another current policy rule. Make construction identity resolution-aware
   or fail closed over same-library aliases, and add this mutation to the real
   unified policy tests.

## 15. OPTIONAL findings

**OPTIONAL: 1 carried forward; 0 new AST OPTIONAL findings.**

The previously recorded future concern about the archive adapter's broad
generic-denial catch extent remains unchanged and harmless with one production
adopter. Prompt 09 found no new optional AST issue beyond the required alias
correction.

## 16. Narrow tests rerun

The permitted narrow suite was rerun:

`flutter test test/architecture/exclusive_authority_architecture_test.dart --reporter expanded`

Result: **PASS — 36 tests passed**.

This confirms the current suite remains green; it does not contain the typedef
alias counterexample and therefore does not close the finding.

A minimal external Dart semantic probe for the alias construction was also
checked with `dart analyze` and returned **No issues found**. No full repository
suite was run.

## 17. Exact Feature 35 Git status

After adding this review response:

- branch: `feature/exclusive-authority-tenure`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- upstream: `origin/main`;
- ahead/behind: `0/0`;
- index: empty;
- tracked modifications: exactly three:
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`;
  - `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart`;
  - `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart`;
- untracked files: 29:
  - nine Feature 35 prompts;
  - nine Feature 35 responses;
  - nine generic-authority production/generated/friend files;
  - the generic authority test;
  - the Feature 35 architecture test;
- shared-instructions pointer: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty.

Nothing is staged, committed, pushed, merged, rebased, or cherry-picked.

## 18. Frozen Onboarding verification

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

The parked patch remains present and unapplied. No frozen file was edited,
staged, restored, switched, stashed, or cleaned. No real database or attachment
archive was accessed.

## 19. Final recommendation

Do not run Feature 35 final full validation or checkpoint yet. Correct only the
bounded constructor-use alias gap and add its unified-policy mutation test.
Runtime production authority semantics and the now-sound friend AST census
should remain unchanged. Repeat this same narrow targeted review after that
correction.

`FINAL TARGETED FEATURE 35 HUMAN REVIEW: FAIL`

`SAFE TO RUN FEATURE 35 FINAL FULL VALIDATION AND CHECKPOINT: NO`
