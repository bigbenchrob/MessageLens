# MessageLens Feature 34 / Feature 35
## Response 28 — Close the Last Two Binding-Provenance Gaps

## 1. Baseline and preservation verification — PASS

The required entry state was verified before editing:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked worktree: 55 modified / 2 deleted;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: PASS.

The Prompt 26 manifest remains at its required SHA-256:

`1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`

A fresh Prompt 28 baseline was created before edits at:

`/private/tmp/messagelens-onboarding-prompt28-baseline.uP28xG/MANIFEST.json`

Its SHA-256 is:

`ffbbd316957c07706fcbaea24023a439ce3e0f88fb45e15f83261351cd458577`

It records 57 tracked-delta entries and 101 untracked entries. No production,
runtime, generated, behavioral-test, prior-response, or unrelated architecture
file differed from the Prompt 27 state at entry.

## 2. Removal of source-name role fallback — PASS

`_bindingExpressionKey` now fails closed. A simple identifier contributes a
semantic role only when its resolved declaration element is present in the
approved role map. An unmapped or unresolved identifier returns no role; its
source spelling is never substituted.

Enum constants are authenticated through their resolved property accessor and
underlying enum field. Property chains are accepted only when their base has
already resolved to an approved role.

## 3. Same-spelling/unrelated-value mutation result — PASS

The new `sameSpelledUnrelatedToken` mutation introduces a nested local named
`token` whose value is not the claimed command token. It invokes the authentic
currentness helper and authentic mutation but is rejected because the nested
declaration has no approved token role.

The harmless-renamed authentic token case continues to pass.

## 4. Controller provenance enforcement — PASS

A controller role is now assigned only when the initializer itself is the
direct, optionally awaited/null-checked result of the exact resolved
`Ref.read` method applied to the canonical
`onboardingOperationControllerProvider.future`, and the resulting local has the
canonical controller interface type.

Merely containing the canonical provider read in a conditional, closure, or
wrapper is insufficient.

## 5. Report provenance enforcement — PASS

The admitted/reset report role is now assigned only when the initializer
itself directly invokes the exact resolved
`readAdmittedOnboardingEnvironmentEvidence` declaration. A conditional branch
or wrapper that mentions or discards the canonical reader does not establish
report provenance.

## 6. Reset-service provenance enforcement — PASS

The `resetDerivedData` receiver must now be the immediate value produced by the
exact resolved `Ref.read` method with the canonical
`messageDataResetServiceProvider` declaration. Interface type, provider
argument spelling, and accessor method spelling are not sufficient.

The same-signature `FakeResetAccessor.read(...)` mutation is rejected.

## 7. Value-provenance mutation results — PASS

The common resolved policy produced the required matrix:

- direct canonical controller provider read: PASS;
- conditional controller source: FAIL as intended;
- canonical controller read discarded by a closure: FAIL as intended;
- direct canonical report reader: PASS;
- conditional report source: FAIL as intended;
- canonical report read discarded by a closure: FAIL as intended;
- canonical provider passed to a fake reset accessor: FAIL as intended;
- lookalike controller mutation: FAIL as intended.

## 8. Preserved command control-flow rules — PASS

The Prompt 24/26 controls remain active and green: exact helper and predicate
declaration identity, required rejecting atoms, Boolean polarity and
conjunction, terminal return shape, valid fall-through mutation, immediately
preceding capability proof, no intervening await, and authentic mutation method
identity. This correction changes only the provenance of values supplied to
those calls.

## 9. Listener-payload binding enforcement — PASS

The resolved listener policy obtains the second callback formal's declaration
element and requires the authenticated recorder's single `record(...)`
argument to resolve to that exact element. `toSource() == 'next'` is no longer
used as payload proof.

## 10. Shadowed-`next` mutation result — PASS

The legal nested-block mutation declares another local named `next` and records
that value. It is rejected because the argument resolves to the nested local,
not the listener callback's report formal. The current direct listener payload
passes.

## 11. Fixture-create-result provenance enforcement — PASS

Each critical-test fixture local must now have a direct initializer whose
resolved invocation is the exact `_JourneyFixture.create` declaration. The
assigned value can no longer qualify merely because its initializer contains a
real create call.

The exact recorder field and resolved `waitFor` method must still be reached
through that directly created fixture local.

## 12. Discarded-create/fake-fixture mutation results — PASS

The expanded real-feedback matrix produced the required results:

- direct authentic create result: PASS;
- authentic create result discarded by an async closure: FAIL as intended;
- conditional authentic/unrelated fixture source: FAIL as intended;
- wrapper supplied the authentic fixture but returning the unrelated fixture:
  FAIL as intended.

The previously retained fake provider, fake/alternate container, dead real
recorder, fake wait recorder, fake returned recorder, unrelated recorder
writer, ignored feedback flag, and authority-override mutations remain active
and rejected.

## 13. Preserved proof-callback group — PASS

The already-closed proof-callback policy was not redesigned. Its resolved
formal declaration identity, non-null admitted propagation, shadow/alias
rejection, and post-await dominance enforcement remain unchanged and green.

## 14. Remaining safety-critical spelling-dependency audit — PASS

The three bounded binding groups were inspected for remaining `.name`,
`toSource()`, containment, and source-text matching.

Remaining name/source uses are non-provenance utilities:

- class, method, group, constructor, named-argument, and canonical-library
  names locate declarations or API contract members before resolved-element
  comparisons;
- fixed property-member labels such as `current`, `operationId`, and `future`
  describe the reviewed API shape only after the base provider/value has an
  authenticated declaration role;
- enum display names are emitted only after the referenced element is proven
  to be an enum constant field;
- `toSource()` remains for terminal-return/control-flow shape checks and
  diagnostic messages, not value provenance;
- older structural fixture-realism checks retain source matching as a coarse
  complementary policy, while the resolved binding policy now exclusively
  authenticates provider, container, payload, recorder, fixture, and wait
  provenance;
- callback/member names locate the reviewed callback contract; accepted
  callback invocations still require the exact formal declaration element.

`ArchiveMutationCapability.requireOperation` now also authenticates its enum
argument through the resolved enum field rather than source text.

No remaining source spelling substitutes for declaration identity or value
provenance in the three reviewed groups.

## 15. Runtime/test byte-identity verification — PASS

The Prompt 28 manifest contains 158 repository entries. A final comparison
found no unexpected missing entries (the two baseline `D` entries remain
absent as recorded) and exactly one changed baseline entry:

`test/architecture/onboarding_journey_authority_architecture_test.dart`

Its SHA-256 changed from:

`b9d050f78255177eb7088f3e0267a265612ac86e5759181763b8002fb048285e`

to:

`c74029388cb92402ac91a439716b3ee3890957ea0e1819c7c12c44b14ceb0733`

All other 157 baseline entries are byte-identical. Therefore all production,
runtime, generated, behavioral-test, prior-response, unrelated architecture,
and unrelated untracked files remain unchanged. This response is the only new
post-baseline repository file.

## 16. Focused architecture result — PASS

Command:

`flutter test test/architecture/onboarding_journey_authority_architecture_test.dart --reporter expanded`

Result: 25 passed, 0 failed.

## 17. Related architecture result — PASS

The related Onboarding/Feature 35 set was run together:

- `exclusive_authority_architecture_test.dart`;
- `onboarding_operation_snapshot_architecture_test.dart`;
- `onboarding_start_fresh_architecture_test.dart`;
- `virgin_onboarding_boundary_test.dart`.

Result: 66 passed, 0 failed.

## 18. Complete architecture result — PASS

Command:

`flutter test test/architecture --reporter compact`

Result: 554 passed, 0 failed.

The full Flutter behavioral suite was not run, as required.

## 19. Analyzer result — PASS

Command:

`flutter analyze --no-pub`

Result: `No issues found!`

## 20. Diff/format hygiene — PASS

- `git diff --check`: PASS;
- changed-file format check with `dart format --output=none
  --set-exit-if-changed`: PASS, 0 files changed;
- index: empty;
- no staging, commit, push, or application launch occurred.

## 21. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

Both Prompt 27 enforcement gaps are mechanically closed within the bounded
scope. Runtime design and behavior remain unchanged.

## 22. BLOCKER findings

BLOCKER: 0.

## 23. SHOULD FIX findings

SHOULD FIX: 0.

## 24. Exact Prompt 28 changed-file census

Exactly two repository files differ from the fresh Prompt 28 baseline:

1. `test/architecture/onboarding_journey_authority_architecture_test.dart`;
2. `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/responses/28-CLOSE-LAST-TWO-BINDING-PROVENANCE-GAPS.md`.

The architecture test is the sole edited baseline entry. The response record
is newly created. No other file changed.

## 25. Baseline-manifest comparison — PASS

Against the fresh Prompt 28 manifest:

- entries checked: 158;
- unexpected missing entries: 0; the two recorded deletions remain absent;
- changed baseline entries: 1, the expected architecture test;
- unchanged baseline entries: 157;
- new post-baseline entries: 1, this response.

The fresh manifest itself remains unchanged at SHA-256
`ffbbd316957c07706fcbaea24023a439ce3e0f88fb45e15f83261351cd458577`.

## 26. Preservation-artifact verification — PASS

All preservation manifests remain unchanged:

- Feature 35 collision:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`;
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`;
- Prompt 18:
  `0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`;
- Prompt 20:
  `6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`;
- Prompt 22:
  `e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`;
- Prompt 24:
  `062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`;
- Prompt 26:
  `1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`;
- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`.

## 27. Exact Git status

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- tracked worktree: preserved 55 modified / 2 deleted files;
- untracked files: 102, consisting of the 101 Prompt 28 baseline untracked
  files plus this response;
- expected Prompt 28 architecture test: untracked, modified from its baseline
  hash as reported above;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- staged: none;
- committed: none;
- pushed: no.

## 28. Stop gates encountered

None. No production change, behavioral-test change, new authority design,
resource-action mismatch, runtime redesign, archive/database access, or scope
expansion was required.

Two validation details were corrected within the authorized architecture file:
the actual Riverpod `Ref.read` library URI and enum constants resolving through
their accessor elements. Neither affected runtime scope.

## 29. Checkpoint readiness

The accumulated Onboarding correction now has mechanically closed proof-callback,
command value/mutation-target, and critical-feedback provenance enforcement.
The bounded conformance result is green and the work remains unstaged and
uncommitted for checkpoint review.

LAST ONBOARDING BINDING-PROVENANCE GAPS CLOSED: YES

READY TO CHECKPOINT ACCUMULATED ONBOARDING CORRECTION: YES
