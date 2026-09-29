# MessageLens Feature 34 / Feature 35
## Response 25 — Final Targeted Onboarding Architectural Review

## 1. Baseline and preservation verdict — NO ISSUE

The required baseline is intact:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked worktree: 55 modified / 2 deleted;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: PASS;
- `git diff --cached --check`: PASS.

The Prompt 24 baseline remains byte-identical at:

`/private/tmp/messagelens-onboarding-prompt24-baseline.v1bQ6f/MANIFEST.json`

with SHA-256:

`062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`

Relative to that manifest, the Prompt 24 implementation changed exactly the
pre-existing untracked Journey authority architecture test and added Response
24. The supplied Prompt 25 is the only later user input before this response.
Every runtime production and behavioral-test path remains byte-identical to
the Prompt 24 baseline.

## 2. Concrete bookmark-write enforcement verdict — NO ISSUE

The repository audit now includes
`AttachmentArchiveLocationController._persistConfigurationUnchecked` as an
explicit AST root and selects the concrete
`_settingsStore.writeSetting(...)` invocation by receiver and method.

`allowCallerProofBeforeEntry` permits the separately audited caller proof only
while the helper contains no earlier await. Once an inner await precedes the
write, `_protectedIoCheckpointViolations` requires an approved checkpoint
after the most recent await and immediately before the concrete write.

This closes Prompt 23's wrapper-depth blind spot for the reviewed production
shape.

## 3. Bookmark-wrapper mutation verdict — NO ISSUE

The negative virtual helper uses the same
`_protectedIoCheckpointViolations` policy as repository source. It keeps the
concrete `writeSetting` invocation, inserts `await someAsyncBoundary()`, and
omits a renewed checkpoint. The policy reports a missing dominating
checkpoint at the concrete write.

The positive variant inserts the approved checkpoint after the await and
before the write. It passes for that intended reason.

## 4. Checkpoint identity and dominance verdict — SHOULD FIX

The adjacency and branch-shape correction is materially stronger, but callback
identity is still not binding-aware.

`_isApprovedPersistentStoreCheckpoint` proves only that:

1. the audited root has a formal parameter spelled
   `requirePersistentArchiveStoreAdmission`; and
2. the adjacent expression invokes that spelling directly or as `.call()`.

The parse-only AST has no resolved-element comparison tying the invocation to
the formal-parameter declaration. It also accepts the null-aware production
form `requirePersistentArchiveStoreAdmission?.call()` without proving that the
admitted call path supplied a non-null callback.

A concrete legal regression remains mechanically invisible:

```dart
await _availableCustomState(
  // unchanged reviewed arguments
  requirePersistentArchiveStoreAdmission: null,
);
```

The helper still contains an adjacent same-spelled null-aware call, and the
concrete persistence helper still has no inner await, so both audited roots
pass even though the admitted path has dropped the caller proof before the
write. Likewise, a nested local function with the same name can shadow the
formal parameter while preserving the inspected syntax.

Prompt 25 explicitly requires a SHOULD FIX classification when callback
identity remains based on spelling rather than parameter origin/binding. That
condition is present.

## 5. Checkpoint-mutation verdict — SHOULD FIX

The common policy correctly rejects all five supplied mutations:

1. conditional checkpoint;
2. wrong receiver;
3. checkpoint in a returning branch;
4. await after the checkpoint without renewal; and
5. bookmark-wrapper inner await without renewal.

Current production paths pass. However, the non-null-propagation and lexical
shadowing counterexamples above preserve the accepted AST shape while severing
the approved callback identity. The mutation matrix therefore proves
dominance of a spelling, not yet dominance of the admitted callback binding.

## 6. Command-guard structural verdict — SHOULD FIX

The new `_CommandGuardSpec` model correctly recognizes the five reviewed
boundaries and is substantially better than token containment. It proves:

- the required rejecting disjunction;
- unary negation and inequality polarity;
- the exact set of currentness/binding/report atoms;
- terminal return shape;
- immediate capability proof;
- fall-through placement; and
- absence of an await or unapproved statement before mutation.

It does not, however, resolve the inspected identifiers to their declarations.
`_commandCurrentnessCallKey`, `_reportPredicateName`, mutation targets, and
inequality operands use method names and `toSource()` strings.

A local helper with the exact inspected name and parameters can shadow the
real currentness/report helper while returning permissive values. The guard
retains the same Boolean AST and passes the policy while no longer consulting
the reviewed command authority. The rule also rejects a harmless rename of
`token`, `context`, `binding`, `controller`, or `admittedReport` even when all
bindings and semantics are unchanged.

This is both binding underreach and obvious source-spelling overfitting.

## 7. Command-guard mutation verdict — SHOULD FIX

The common policy rejects the five required supplied mutations for their
intended structural reasons:

- accepting/inverted polarity;
- unsafe `&&` substitution;
- removed report conjunct;
- removed currentness negation; and
- real guard before an await with a non-rejecting dummy guard near mutation.

The positive initial-import and continuation shapes pass, as do all five
production boundaries.

Nevertheless, a same-named local `_commandAndActionAreCurrent` or
`_reportAllowsCommand` with altered semantics preserves every currently
inspected guard node. Because the policy checks spelling rather than resolved
call identity, that unsafe semantic substitution is not rejected. No focused
test rerun can disprove this static counterexample.

## 8. Real-feedback recorder-flow verdict — SHOULD FIX

The policy now structurally connects the locally named recorder through:

```text
container.listen(onboardingEnvironmentReportProvider, ...)
-> globalEnvironmentReports.record(next)
-> returned globalEnvironmentReports field
-> fixture.globalEnvironmentReports.waitFor(maintenanceInProgress)
```

It also enforces `fireImmediately: true`, retains the subscription, prevents a
second direct recorder writer, and rejects authority-provider overrides.

However, the start of that chain is still source-spelling based. The policy
does not inspect the declaration/initializer of `container`, and it does not
resolve `onboardingEnvironmentReportProvider` to the real top-level provider.
A fake local container named `container`, or a local fake provider shadowing
`onboardingEnvironmentReportProvider`, can emit unrelated evidence into the
otherwise correctly connected recorder and satisfy every current check.

The rule therefore proves a connected identifier chain, but not yet a chain
originating at the real global Environment provider through the real
`ProviderContainer`.

## 9. Disconnected-recorder mutation verdict — SHOULD FIX

The supplied common-policy mutations correctly reject:

1. dead real recorder;
2. fake recorder used by the critical waits;
3. fake returned observation handle;
4. unrelated second writer into the real recorder;
5. ignored real-feedback flag; and
6. Feature 35 authority replacement.

The connected positive fixture passes.

The matrix does not cover the legal fake-origin case where the same
`container.listen(onboardingEnvironmentReportProvider, ...)` spelling resolves
to a fake local container/provider. That case leaves the full inspected
recorder/return/wait chain intact while the asserted maintenance evidence is
unrelated to the real global provider.

## 10. Traversal and semantic-census regression verdict — NO ISSUE

Prompt 24 did not weaken the already-reviewed traversal/census rules:

- `_transitiveLocalDependencies` visits the root before applying `stopAt` to
  descendants;
- semantic roots remain excluded from trusted-stop roots;
- `shellPath` remains traversed;
- `OnboardingStatus` remains a semantic-consumer marker;
- raw conversation-graph controller and barrel paths remain primary evidence;
- virtual traversal mutations use the same trusted-boundary configuration.

No regression was found in this targeted spot-check.

## 11. Runtime byte-identity verdict — NO ISSUE

Prompt 24 made no production or behavioral-test change. The protected runtime
hashes remain:

- Environment report provider:
  `0ca9438aaf989b123912f29dbd7b66b17e1ffce525e02f09a484c79aa1c360e2`
- Journey coordinator:
  `7853f29c9385fc8e6caa9d414dc82e6886a230b5376d3789970c82d11e005632`
- failure store:
  `c0bdebcb03d0a6bbbf330ad0e5a1b988a654b6b6b5f16bf82203e3c883f80b43`
- overlay failure storage:
  `6b71db321b0f43ae9b77763aff30c7d3db49c94e0f454fe1c3c26152f80d48e3`
- attachment location provider:
  `a6b364152ba10533b0a62a4f74b9ec131f094523b0b0b9bee30092dfe3708803`
- attachment location controller:
  `2d1531739bb72437331991f8729303b988a845e4aa170e5b62de9d43730f9b90`

The previously accepted runtime conclusions therefore remain accepted and
were not re-litigated. No runtime defect was found in this review.

## 12. Architecture overfitting/underreach verdict — SHOULD FIX

The three policies reject the exact supplied regressions, comments, and
formatting changes do not matter, and Boolean atom order is tolerated.

They do not tolerate harmless binding-preserving local renames because formal
parameters, locals, receivers, and report variables are compared by literal
source spelling. Conversely, the same lack of resolved binding identity lets a
same-spelled shadow declaration preserve the inspected syntax while replacing
the protected callback, command helper, container, or provider semantics.

This is not a request for broad refactor tolerance. The narrow correction is
to connect accepted identifiers/calls to their intended declaration origins,
then keep the existing strict control-flow allowlists.

## 13. Concrete BLOCKER findings

BLOCKER: 0.

The current runtime source is unchanged and remains sound. No actual stale
protected I/O, duplicate Journey authority, incoherent report, unsafe command,
or fake critical-test feedback path was found in the current implementation.

## 14. Concrete SHOULD FIX findings

SHOULD FIX: 3.

1. The protected-I/O rule reaches the concrete write but does not prove that
   the accepted checkpoint invocation resolves to the supplied callback or
   that the admitted caller propagates a non-null proof into the shared helper.
2. The command rule proves Boolean spelling/shape but not declaration binding;
   same-named local helpers can replace currentness/report semantics, while
   harmless local renames fail.
3. The recorder rule connects the named recorder to the named wait but does
   not prove that the named container/provider resolve to the real
   `ProviderContainer` and global Environment provider; fake origins can pass.

These are architecture-enforcement defects, not current runtime defects.

## 15. OPTIONAL findings

None beyond the three required corrections. The existing strict control-flow
allowlists and mutation coverage should be retained while declaration-origin
checks are added.

## 16. Narrow tests rerun

None.

Source inspection produced concrete legal counterexamples that the current
parse-only, source-spelling checks accept. Re-running the already-green focused
test would confirm only that the current mutation set still passes; it would
not answer the binding-identity gaps. Prompt 24's validation evidence remains
unchanged:

- focused Onboarding authority architecture: 25 passed;
- related architecture: 66 passed;
- complete architecture: 554 passed;
- analyzer: clean.

`git diff --check` and `git diff --cached --check` were rerun and passed.

## 17. Exact Git status

After adding this required response only:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- staged files: 0;
- accumulated tracked worktree: 55 modified / 2 deleted;
- physical untracked files: 96, comprising the 93-path Prompt 24 baseline,
  Response 24, supplied Prompt 25, and this Response 25;
- shared instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- all Onboarding work: unstaged and uncommitted.

## 18. Preservation-artifact verification — NO ISSUE

The recorded manifest hashes remain unchanged:

- Prompt 24:
  `062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`
- Prompt 22:
  `e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`
- Prompt 20:
  `6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`
- Prompt 18:
  `0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`
- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`
- Feature 35 collision backup:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`

No preservation artifact or shared-submodule byte changed. MessageLens
Development was not launched. No real Messages/Contacts database, attachment
archive, archive configuration, or abandoned relocation artifact was accessed
or modified. Nothing was staged, committed, or pushed.

## 19. Final checkpoint recommendation

Do not checkpoint the accumulated Onboarding correction yet.

Prompt 24 successfully closed the three exact syntactic evasions identified by
Prompt 23, and the current runtime remains sound. The policies nevertheless
still confuse identifier spelling with declaration identity. Because Prompt 25
explicitly requires the protected callback and real provider chain to be
binding-authentic—and requires semantic enforcement rather than source-name
enforcement—the three findings above must be corrected and reviewed before
checkpointing.

FINAL TARGETED ONBOARDING ARCHITECTURAL REVIEW: FAIL
