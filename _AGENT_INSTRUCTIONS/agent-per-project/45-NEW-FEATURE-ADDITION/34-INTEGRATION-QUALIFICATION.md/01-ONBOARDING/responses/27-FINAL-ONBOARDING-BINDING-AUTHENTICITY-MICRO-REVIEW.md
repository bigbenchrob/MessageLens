# MessageLens Feature 34 / Feature 35
## Response 27 — Final Onboarding Binding-Authenticity Micro-Review

## 1. Baseline and preservation verdict — NO ISSUE

The required baseline is intact:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked worktree: 55 modified / 2 deleted;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: PASS.

The Prompt 26 baseline manifest remains at:

`/private/tmp/messagelens-onboarding-prompt26-baseline.OckfNG/MANIFEST.json`

with SHA-256:

`1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`

All 57 tracked-delta entries match that manifest. All 96 unaffected
pre-existing untracked entries match it. The only changed baseline entry is
the reviewed architecture test, whose SHA-256 is now
`b9d050f78255177eb7088f3e0267a265612ac86e5759181763b8002fb048285e`.
The only post-baseline files before this response were Prompt 27 and Response
26. Therefore Prompt 26 changed exactly the architecture test and Response 26;
no production, generated, or behavioral-test byte changed.

## 2. Analyzer-resolution verdict — NO ISSUE

The three reviewed policies use resolved compilation units obtained from
`AnalysisSession.getResolvedUnit`. Repository units share one
`AnalysisContextCollection` rooted at the repository. The explicit SDK path
selects the Flutter-bundled Dart SDK while package resolution remains rooted
in the repository analysis context; it does not create a second repository
source universe.

The standalone mutation sources are written to isolated temporary Dart files,
resolved by a short-lived analysis context, and deleted after resolution.
Their declarations and references therefore have real semantic bindings.

The comparisons use `Element2` and normalize through `nonSynthetic2` before
identity comparison. That is appropriate for the reviewed formal parameters,
methods, fields, provider variables/getters, and referenced interface
declarations. Unrelated parse-only architecture policies were not converted.

## 3. Proof-callback declaration verdict — NO ISSUE

The protected-I/O rule obtains the reviewed formal parameter's declared
element. A direct function-expression invocation is accepted only when its
identifier resolves to that formal. A nullable `.call()` invocation is
accepted only when the receiver resolves to that same formal.

The actual admitted functions exercise both the direct and nullable forms.
The same-named nested function and same-named unrelated callable alias resolve
to different elements and are rejected. The callback spelling alone does not
authorize the reviewed production boundaries.

## 4. Admitted non-null propagation verdict — NO ISSUE

The resolved propagation policy covers the admitted chain:

```text
readAttachmentArchiveLocationEvidenceWithAdmission
-> AttachmentArchiveLocationController.load
-> _resolveCustom
-> both admitted _availableCustomState branches
-> the protected-I/O checkpoint invocation
```

Each admitted named argument must be a simple reference to the caller's exact
formal callback. `null` and unrelated aliases fail. Each callee is located by
its resolved method declaration, and its checkpoint must invoke its own formal
callback. The ordinary nullable, non-admitted `load` path is outside this
admitted propagation chain and remains allowed.

## 5. Proof-callback mutation verdict — NO ISSUE

The resolved fixtures reject admitted `null`, the same-named nested local
function, and the same-named unrelated callable alias by declaration identity.
The retained wrong-receiver mutation is rejected structurally; inspection of
the resolved production form also shows that such a receiver cannot compare
equal to the reviewed formal callback. The prior conditional, returning-branch,
post-proof-await, and missing-renewal mutations remain active.

No callback shadow or alias was found that preserves the formal callback's
resolved element while changing the invoked declaration.

## 6. Command-helper/predicate binding verdict — SHOULD FIX

The helper and predicate method invocations themselves are correctly bound:

- `_commandAndActionAreCurrent`;
- `_commandRetainsBinding`;
- `_commandOwnsBoundOperation`;
- `_reportAllowsCommand`;
- the three named report predicates;
- the interrupted-continuation predicate call; and
- `ArchiveMutationCapability.requireOperation`.

However, the value provenance consumed by those authentic methods is not yet
fully declaration-authenticated. `_bindingExpressionKey` returns the source
name of any resolved simple identifier that is absent from the role map:

```dart
return element == null ? unwrapped.name : roles[element] ?? unwrapped.name;
```

Consequently, an unrelated nested local literally named `token`, `context`,
`binding`, `controller`, `admittedReport`, or `resetReport` can satisfy the
expected semantic role without sharing the admitted declaration. For example,
a nested `final token = renamedToken + 1;` passed to the real
`_commandAndActionAreCurrent` is reduced to the expected `token` role. The
existing negative fixture uses the non-matching name `unrelatedToken`, so it
does not expose this hole.

This is a concrete same-spelling/different-declaration acceptance path in one
of the three required binding-authenticity groups.

## 7. Mutation-target provenance verdict — SHOULD FIX

The mutation method elements are authentic:

- `begin` resolves to `OnboardingOperationSnapshotController.begin`;
- `resume` resolves to `OnboardingOperationSnapshotController.resume`;
- `resetDerivedData` resolves to `MessageDataResetService.resetDerivedData`.

The provider provenance is weaker than reported:

- a controller variable is assigned the `controller` role when its initializer
  has the expected controller type and merely *contains* any reference to
  `onboardingOperationControllerProvider`; the policy does not prove that the
  initializer's resulting value came from the provider read;
- a report variable is assigned its report role when its initializer merely
  contains the real report-reader invocation, even if a conditional or wrapper
  returns unrelated evidence;
- the reset target checks only that its target is a method invocation with the
  canonical provider as its sole argument. It does not bind that accessor to
  Riverpod's reviewed `ref.read` declaration.

A conditional initializer can therefore mention the real provider/report
reader in one branch while returning an unrelated same-typed value in the
executed branch. Likewise, a same-typed fake accessor can accept
`messageDataResetServiceProvider` and return a different reset service. The
real mutation method declaration then passes, even though the value did not
originate from the reviewed provider path.

The existing Boolean/control-flow policy remains active and correctly enforces
polarity, conjunction, return shape, adjacency, and post-guard await rules.
It does not close these provenance holes.

## 8. Harmless-rename verdict — NO ISSUE

The positive command fixture renames token, action context, controller,
admitted report, and capability locals. Its authentic declarations are mapped
to semantic roles and it passes without depending on those renamed spellings.

That is valid positive evidence. It does not cure the fallback for *unmapped*
resolved identifiers described above.

## 9. Command-binding mutation verdict — SHOULD FIX

The supplied mutations correctly reject shadowed currentness, report-helper,
and command-specific predicate declarations, as well as the lookalike
controller method. Prompt 24's wrong-polarity, wrong-operator, missing-conjunct,
missing-negation, and stale-pre-await-guard mutations remain rejected.

The unrelated-value mutation is incomplete: `unrelatedToken` fails, but the
same unrelated declaration renamed to `token` is accepted by the source-name
fallback. There is also no mutation proving that a value-producing initializer
cannot merely contain the canonical provider/report-reader reference while
returning a different value.

## 10. ProviderContainer authenticity verdict — NO ISSUE

The fixture listener method must resolve to Riverpod's actual
`ProviderContainer.listen`. Its receiver must be the exact local whose direct
initializer constructs the resolved Riverpod `ProviderContainer`, and the
returned fixture must carry that same local element. Fake local containers and
an alternate real `ProviderContainer` are rejected.

## 11. Global Environment provider authenticity verdict — NO ISSUE

The canonical provider is located from the expected Environment-report
provider library and normalized to its resolved declaration element. The
listener's first positional argument must resolve to that element. A local
variable with the same spelling resolves differently and fails.

The provider/library spelling is used to locate the canonical declaration;
acceptance is then based on the element comparison.

## 12. Recorder/wait binding verdict — SHOULD FIX

The policy authenticates the recorder type, recorder local, recorder field,
`record` method, `waitFor` method, returned recorder element, and fixture-field
access. Two links are still only containment/spelling checks:

1. The resolved listener check does not compare the argument passed to
   `record` with the listener callback's exact `next` formal. The retained
   structural rule checks only `toSource() == 'next'`. A nested local also
   named `next` can therefore supply unrelated evidence while both policies
   pass.
2. A critical-test local is accepted as the real fixture when its initializer
   merely *contains* one call to the exact `_JourneyFixture.create` method.
   The initializer need not return that call's result. A wrapper can invoke
   and discard the real fixture, return another `_JourneyFixture`, and then
   satisfy the exact field/`waitFor` checks on the unrelated result.

These are concrete ways to disconnect the asserted maintenance evidence from
the authenticated provider while retaining the inspected source shape.

## 13. Feedback-origin mutation verdict — SHOULD FIX

The supplied resolved mutations reject the fake provider, fake container,
alternate actual container, and fake-provider-fed recorder. Prompt 24's dead
recorder, fake wait recorder, fake returned recorder, unrelated writer,
ignored-feedback flag, and authority-override mutations remain active. The
fully connected current fixture passes.

The matrix does not cover either remaining accepted regression: shadowing the
listener payload with a same-named local, or invoking the real create method
inside an initializer whose result is a different fixture.

## 14. Remaining intentional-name-dependency verdict — SHOULD FIX

Canonical paths, libraries, class/method names, enum members, named arguments,
and field names are used acceptably to locate reviewed declarations and API
contracts.

Two safety-critical spelling dependencies remain unacceptable:

- `_bindingExpressionKey` uses an unmapped local identifier's spelling as its
  semantic role;
- the structural recorder policy uses the spelling `next` rather than the
  listener formal's resolved element, while the binding policy omits that
  argument comparison.

These spellings still stand in for provenance rather than merely locating a
canonical declaration.

## 15. Prior-policy regression verdict — NO ISSUE

The Prompt 26 changes did not weaken the concrete bookmark settings-write
audit, post-await checkpoint dominance, command Boolean polarity/conjunction,
terminal return/fall-through, no-await-after-final-guard rule, root-aware
traversal, `OnboardingStatus` census, raw graph-evidence census, or real-feedback
override restrictions.

The findings above concern the newly claimed binding closure, not regressions
in those prior structural policies.

## 16. Runtime/test byte-identity verdict — NO ISSUE

Every production, generated, and behavioral-test file is byte-identical to the
Prompt 26 baseline. All 57 tracked-delta hashes match. All other 96 pre-existing
untracked hashes match. The architecture test alone changed from its baseline
SHA-256 `35aec9db4dc27721a76a7faff03748ed53f99046583f3ed25188c4f12900e085`
to `b9d050f78255177eb7088f3e0267a265612ac86e5759181763b8002fb048285e`.

All previously accepted runtime conclusions are preserved. No runtime defect
was found or alleged by this micro-review.

## 17. Concrete BLOCKER findings

BLOCKER: 0.

The current production/runtime source remains unchanged and sound. The defects
are enforcement underreach in the architecture policy.

## 18. Concrete SHOULD FIX findings

SHOULD FIX: 2.

1. Command value and mutation-target provenance can be forged by an unmapped
   same-spelled local or by an initializer/accessor that merely contains the
   canonical provider/report-reader reference without returning its value.
2. Critical-feedback provenance can be disconnected by recording a shadowed
   same-spelled `next` value or by invoking and discarding the real fixture
   creation inside an initializer that returns another fixture.

Both are concrete acceptance paths within the three binding-authenticity
groups, so they prevent the required mechanical closure.

## 19. OPTIONAL findings

OPTIONAL: 0.

## 20. Narrow tests rerun

None.

The findings follow directly from the architecture policy's accepted AST and
element predicates; rerunning the unchanged focused suite would only repeat
Prompt 26's known 25-pass result and would not exercise these absent mutations.
The full behavioral suite was not run, as required.

## 21. Exact Git status

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`
- Index: empty
- Tracked worktree: preserved 55 modified / 2 deleted files
- Shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- Prompt 26 architecture-test hash:
  `b9d050f78255177eb7088f3e0267a265612ac86e5759181763b8002fb048285e`
- Newly present since the Prompt 26 baseline: Prompt 27, Response 26, and this
  Response 27
- Staged: none
- Committed: none
- Pushed: no

## 22. Preservation-artifact verification

PASS. All preserved manifest hashes remain unchanged:

- Feature 35 collision:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`
- Prompt 18:
  `0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`
- Prompt 20:
  `6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`
- Prompt 22:
  `e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`
- Prompt 24:
  `062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`
- Prompt 26:
  `1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`
- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`

## 23. Final checkpoint recommendation

The proof-callback binding group is mechanically closed. The command
value/mutation provenance group and the real-feedback recorder/wait provenance
group are not. Because the decision rule requires all three groups to be
closed, the accumulated onboarding correction is not yet safe to checkpoint.

FINAL ONBOARDING BINDING-AUTHENTICITY MICRO-REVIEW: FAIL

SAFE TO CHECKPOINT ACCUMULATED ONBOARDING CORRECTION: NO
