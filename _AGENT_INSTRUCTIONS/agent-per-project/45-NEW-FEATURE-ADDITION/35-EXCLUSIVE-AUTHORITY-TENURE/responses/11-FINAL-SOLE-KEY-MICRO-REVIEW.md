# MessageLens Feature 35
## 11 — Final Sole-Key Micro-Review — Response

Date: 2026-09-27

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
- tracked modifications: exactly the same three previously reviewed archive
  coordinator/generated/test files;
- shared-instructions pointer:
  `95326f515ef4719f155ce6e223990398daad6311`, uninitialized rather than
  dirty.

The review trail and current repository state confirm Prompt 10 changed only:

- `test/architecture/exclusive_authority_architecture_test.dart`; and
- `responses/10-CLOSE-CONSTRUCTOR-ALIAS-ENFORCEMENT-GAP.md`.

The architecture-test SHA-256 is
`a1d96ad6762fb022c88ef9d77fdaac67bf697a85445d0988ef229b9bc73b216b`.
No runtime production source changed in Prompt 10 or this review.

The frozen Onboarding worktree matched every required preservation value
before review. It was not modified.

## 2. Private-constructor library-boundary verdict

**NO ISSUE.**

Dart private names are library-private. The current
`ExclusiveAuthorityKey._` library consists exactly of:

- `exclusive_authority_key.dart`; and
- its sole declared part,
  `exclusive_authority_key_test_support.dart`.

Code in another library cannot legally name `_` through an import prefix,
an externally declared typedef, a re-export, an extension, a factory wrapper,
or another top-level helper. A re-export does not change the declaring library
of a private identifier. An outside typedef preserves the aliased type's
constructor privacy. Extensions cannot add constructors and do not acquire
another library's private-name access. A wrapper outside the library still
needs a callable constructor or tear-off supplied by the privileged library.

The Prompt 10 analyzer probes independently established that same-library
direct and transitive aliases can invoke `_`, while an alias in an importing
library cannot. The current policy therefore needs to close only the two
privileged compilation units, which it does.

## 3. Privileged key-library surface verdict

**NO ISSUE.**

`_auditProductionKeys` applies the AST-backed
`_topLevelDeclarationCensus` to `exclusive_authority_key.dart` and permits
exactly:

- `class ExclusiveAuthorityKey`.

`_matchesExactDeclarationCensus` checks both the declaration-list length and
the exact set of declaration descriptions. It therefore rejects an added:

- typedef or type alias;
- top-level variable;
- getter, setter, or function;
- enum;
- mixin;
- class;
- named or unnamed extension;
- extension type; or
- future/unknown `CompilationUnitMember`.

Unknown member kinds enter the census as an `unsupported` declaration rather
than being ignored. Duplicate descriptions cannot collapse into a pass because
the original declaration count must also equal one.

## 4. Friend-part surface verdict

**NO ISSUE.**

The key source's exact part-directive set is:

- `exclusive_authority_key_test_support.dart`.

The friend part's exact AST top-level surface is:

- `class ExclusiveAuthorityKeyTestSupport`.

The same exhaustive declaration census rejects any additional alias, getter,
setter, function, variable, enum, mixin, class, extension, extension type, or
unknown declaration. Discovery of `*_test_support.dart` files is also checked
against the exact two approved friend files, so an additional privileged
friend file fails.

The production feature seam exports `exclusive_authority_key.dart` with
`show ExclusiveAuthorityKey`; it does not export
`ExclusiveAuthorityKeyTestSupport`. Friend-symbol scanning separately
prohibits production references outside the designated friend files.

## 5. Constructor-declaration verdict

**NO ISSUE.**

The unified policy requires:

- exactly one `ExclusiveAuthorityKey` class declaration;
- that declaration at the exact key path;
- the class to remain `final`;
- exactly one constructor;
- constructor name `_`;
- `const`;
- generative, not factory;
- non-`external`;
- no redirected constructor target; and
- no generative redirect initializer.

The count check rejects a second private constructor, public unnamed or named
constructor, factory, redirecting constructor, and external constructor. Each
constructor is also individually checked, so an unapproved sole constructor
cannot pass by preserving the count.

## 6. Construction-site verdict

**NO ISSUE.**

The accepted constructor-use multiset remains exactly:

1. the canonical `archiveMutation` invocation in
   `exclusive_authority_key.dart`; and
2. the independent test-key invocation in
   `exclusive_authority_key_test_support.dart`.

The canonical field has its own AST check requiring the static const
`archiveMutation` field, the approved private constructor, and the exact
`archiveMutation` diagnostic literal.

Every additional literal invocation or constructor tear-off is left in the
construction-use census and becomes a `sole-production-key` violation. This
remains useful defence in depth after the stricter privileged top-level
surface closes aliases earlier.

## 7. Direct alias verdict

**NO ISSUE.**

The exact Prompt 09 counterexample:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;
const another = KeyAlias._('another');
```

is legal only inside the key library. The same real
`_ExclusiveAuthorityProductionPolicy` used for repository audit rejects it
at `exclusive_authority_key.dart` because the privileged declaration census
finds `typedef KeyAlias` in addition to the one approved class.

The mutation assertion requires the `sole-production-key` rule, the key path,
and the `typedef KeyAlias` diagnostic. It cannot pass because of unrelated
syntax or policy failure.

## 8. Transitive alias verdict

**NO ISSUE.**

The legal same-library chain:

```dart
typedef KeyAlias1 = ExclusiveAuthorityKey;
typedef KeyAlias2 = KeyAlias1;
const another = KeyAlias2._('another');
```

fails at the same exact privileged-surface boundary. Every top-level alias in
the chain is forbidden; the mutation assertion specifically requires
`typedef KeyAlias2` in the key-path diagnostic. Alias-chain length cannot
evade the rule.

## 9. Alias tear-off verdict

**NO ISSUE.**

The legal same-library tear-off:

```dart
typedef KeyAlias = ExclusiveAuthorityKey;
final constructor = KeyAlias._;
```

fails at the same real policy boundary. The alias is an unapproved typedef and
`constructor` is an unapproved top-level variable. The mutation requires the
key-path `sole-production-key` diagnostic to identify
`variable constructor`.

## 10. Adversarial legal-Dart escape review

**NO ISSUE for the MessageLens Flutter production runtime.**

The narrow adversarial review covered:

- direct and transitive typedef aliases;
- top-level getter, setter, function, and variable aliases;
- direct and aliased constructor tear-offs;
- class static members;
- extensions and extension types;
- mixins and additional classes;
- re-exports and additional parts;
- factory and redirecting constructors; and
- nested declarations.

The exact top-level censuses reject aliases, extensions, extension types,
mixins, extra classes, and helper declarations in either privileged unit. The
part set rejects another privileged file. Dart does not permit a relevant
nested typedef/class/extension declaration inside the approved class. A class
static member that creates or exposes a new key must name the private
constructor invocation or tear-off, which the construction-use census rejects.
An outside library cannot name that private constructor.

One deliberately adversarial boundary probe used `dart:mirrors`. A
standalone Dart VM can reflectively invoke a private named constructor without
spelling a constructor call in the AST. That probe successfully produced a
second object under standalone `dart run`. It is not a MessageLens
production escape: the current Flutter runtime rejected `dart:mirrors` before
isolate creation with:

`import of dart:mirrors is not supported in the current Dart runtime`

Both temporary probe files were outside the worktrees and were removed. No
repository file changed. On MessageLens's supported Flutter runtime, no
concrete legal construction path remains that leaves the current architecture
checks green.

The exact bounded guarantee is:

> Under the current key library/part structure and supported Flutter runtime,
> another constructible production `ExclusiveAuthorityKey` requires an
> intentional change to an approved privileged declaration, constructor,
> construction-site, or part surface.

## 11. False-positive / overfitting verdict

**NO ISSUE.**

The rule freezes the privileged authority surface, not ordinary class
implementation detail. It does not census member fields, methods, local
variables, comments, formatting, or private implementation names inside the
approved class. Those remain freely refactorable unless they add a constructor,
change the canonical field, or create/expose another key through an invocation
or tear-off.

Rejecting additional top-level declarations is intentional because those
declarations would widen the library-level privileged surface.

## 12. Regression spot-check

**NO ISSUE.**

Prompt 10 extended `_auditProductionKeys`; it did not remove or broaden:

- exact friend-file and friend-declaration enforcement;
- sole production adopter enforcement;
- provider-object occurrence and notifier-use restrictions;
- approved `runExclusive`, `runReentrant`, and `requireCurrent` proof
  surface;
- diagnostics-not-proof checks;
- no public release;
- no ambient current-tenure lookup; or
- no serialization.

No full re-review of those already accepted boundaries was performed.

## 13. Concrete BLOCKER findings

**BLOCKER: 0**

## 14. Concrete SHOULD FIX findings

**SHOULD FIX: 0**

The Prompt 09 alias finding is mechanically closed.

## 15. OPTIONAL findings

**OPTIONAL: 0 new sole-key findings.**

The previously recorded, unrelated future concern about the archive adapter's
broad generic-denial catch extent remains unchanged and outside this
micro-review.

## 16. Narrow tests rerun

The one permitted focused suite was rerun:

`flutter test test/architecture/exclusive_authority_architecture_test.dart --reporter expanded`

Result: **PASS — 42 tests passed**.

This includes the approved repository audit and the direct alias, transitive
alias, alias tear-off, top-level variable, getter, and function mutation
checks. No complete architecture suite or full repository suite was rerun.

The two external reflection probes described above were diagnostic only. The
standalone Dart probe succeeded; the Flutter-runtime probe rejected
`dart:mirrors` before isolate creation. Both were removed.

## 17. Exact Feature 35 Git status

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
- untracked files: 33:
  - eleven Feature 35 prompts;
  - eleven Feature 35 responses;
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

The parked patch remains present, byte-identical, and unapplied. No frozen file
was edited, staged, restored, switched, stashed, or cleaned. No real database
or attachment archive was accessed.

## 19. Final recommendation

The exact privileged key-library and friend-part surfaces, closed constructor
declaration set, exact construction-site multiset, and direct alias mutations
now support the bounded sole-key guarantee on MessageLens's Flutter runtime.

Proceed to Feature 35 final full validation and checkpoint. Do not integrate
or resume frozen Onboarding work as part of that validation unless a later
prompt explicitly authorizes it.

`FINAL FEATURE 35 SOLE-KEY MICRO-REVIEW: PASS`

`SAFE TO RUN FEATURE 35 FINAL FULL VALIDATION AND CHECKPOINT: YES`
