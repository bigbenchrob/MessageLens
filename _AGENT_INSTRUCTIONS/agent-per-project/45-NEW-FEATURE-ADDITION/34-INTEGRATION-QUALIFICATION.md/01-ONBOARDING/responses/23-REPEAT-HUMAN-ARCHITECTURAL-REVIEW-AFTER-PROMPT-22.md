# MessageLens Feature 34 / Feature 35
## Response 23 — Repeated Human Architectural Review After Prompt 22

## 1. Baseline and preservation verdict — NO ISSUE

The required baseline is intact:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked worktree: 55 modified / 2 deleted;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: PASS.

The Prompt 22 baseline manifest remains at
`/private/tmp/messagelens-onboarding-prompt22-baseline.ETdg87/MANIFEST.json`
with the required SHA-256:

`e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`

The Prompt 20, Prompt 18, reconstruction, pre-merge, and Feature 35 collision
manifests also retain their recorded hashes. Relative to the Prompt 22
baseline, only the reported Prompt 22 implementation/test changes, Response
22, and the supplied Prompt 23 are present. No unrelated implementation byte
changed after Prompt 22.

## 2. Protected-I/O checkpoint-interface verdict — NO ISSUE

`readAdmittedOnboardingEnvironmentEvidence` remains the capability owner. Its
callback-local proof:

1. re-requires the exact expected `ArchiveMutationOperation`; and
2. asks the existing archive coordinator to re-admit the current caller for
   `ArchiveMutationResourceAction.openPersistentArchiveStore`.

Failure storage and attachment-location specialists receive only that bounded
proof callback. They do not receive or retain the capability or tenure, do not
publish authority state, do not know Journey semantics, and do not perform an
ambient current-Ball lookup. Proof responsibility therefore remains supplied
by the admitted caller rather than migrating into specialist state.

## 3. Source failure-storage verdict — NO ISSUE

`OverlayOnboardingFailureStorage.loadSourceImportFailureEntry` executes the
required sequence:

```text
persistent-store proof
-> await overlay database acquisition
-> persistent-store proof
-> protected setting read
```

The proof after database acquisition occurs outside the storage read's
ordinary error-catching block. Capability/resource exceptions therefore
propagate and fail closed rather than being converted to missing or corrupt
evidence. The injectable setting reader is a test observation seam; the
production default still delegates directly to
`OverlayDatabase.readOverlaySetting`.

## 4. Graph primary/fallback verdict — NO ISSUE

The current graph key uses the same proof/acquire/proof/read sequence as the
source key. If it returns `null`, `loadGraphProjectionFailureEntry` re-proves
admission before calling the historical-key helper. That helper independently
proves before database acquisition and again before the historical setting
read.

Thus a stale primary result cannot authorize historical protected I/O. A
withdrawal after the primary read prevents fallback acquisition from starting;
a withdrawal during fallback acquisition prevents its setting read.

## 5. Attachment one-shot evidence verdict — NO ISSUE

`readAttachmentArchiveLocationEvidenceWithAdmission` does not consume or
publish the ambient location provider. It reads synchronous dependencies,
proves admission, awaits the settings-store provider, re-proves admission,
constructs a local controller, invokes its proof-aware load, and re-proves
before return.

The controller proves immediately before and after its setting read. No
capability or caller-relative authority is retained. The ordinary ambient
provider still constructs and loads the same controller without an admitted
callback, preserving its non-admitted behavior.

## 6. Bookmark-refresh write verdict — NO ISSUE

The runtime custom-bookmark path is correct:

```text
proof
-> await bookmark resolution
-> proof
-> if refreshed metadata differs:
     proof
     -> await settings write
     -> proof
```

Withdrawal or stronger resource policy while resolution is suspended throws
before `_persistConfigurationUnchecked` is invoked, so the refreshed write
does not start. The valid-authority test also confirms that ordinary refreshed
bookmark metadata is still persisted.

## 7. Resource-action semantic-fit verdict — NO ISSUE

`openPersistentArchiveStore` is the existing action used to admit the
persistent archive-owned stores. The failure-overlay setting reads,
attachment-location setting read, and refreshed bookmark setting write all
operate on that existing overlay/settings persistence boundary. None is being
forced under an unrelated filesystem or graph action. The synchronous graph
probes retain their distinct `openConversationGraphConnection` proof.

## 8. Double-collection coherence verdict — NO ISSUE

Each `_OnboardingMaterialEvidence` sample contains source failure, graph
failure, one-shot attachment location, and Contacts evidence plus its captured
fingerprint. A pair of equal full samples is required. One unequal pair causes
one further two-sample attempt; a second unequal pair throws. The algorithm is
bounded to two attempts/four observations and cannot spin.

Only the second member of a matching pair becomes the coherent evidence. No
first-sample field leaks into the evaluator on mismatch, and no report reaches
the evaluator after the second mismatch. Every retry remains within the same
callback-local capability/resource proof regime.

## 9. Fingerprint-completeness verdict — NO ISSUE

- Failure comparison includes phase, batch ID, message, and recorded UTC
  timestamp. Those are all failure-entry fields that can affect evaluator or
  reset semantics.
- Attachment comparison uses full immutable
  `AttachmentArchiveLocationState` equality, including availability,
  generation, configuration, path, and issue; configuration equality covers
  its complete identity/policy/metadata value.
- Contacts comparison captures availability plus the exact selected physical
  source path or failure message used by the evaluator. It does not depend on
  aggregate object identity or recompute a fingerprint later.

No evaluator-relevant omission was found.

## 10. Final coherence-boundary verdict — NO ISSUE

After the final matching material sample there is no further await. The code
synchronously rereads developer overrides, database probe reader, FDA,
Messages path, canonical data root, maintenance, graph build, and live-update
state. It then re-proves persistent-store and graph-connection admission and
runs the shared evaluator synchronously.

Accordingly, command-relevant async evidence is pair-stabilized, and all other
mutable command facts are read only after the final material suspension. No
pre-await mutable fact is reused without a revision check.

## 11. Reset-driving failure currentness verdict — NO ISSUE

For `A -> later change -> B`, unequal failure fingerprints reject the pair.
That covers changed, cleared, and newly appeared source/graph failures. A
second pair must agree or the read fails closed. The evaluator therefore sees
the current stable failure entry—including its reset-driving phase, batch ID,
message, and timestamp—or no report is produced.

## 12. Failure-storage withdrawal-test verdict — NO ISSUE

The source and graph-primary tests record the injected actual setting-read
boundary. Capability withdrawal and stronger persistent-store denial during
database acquisition both leave its count at zero and surface a
proof/resource `StateError`.

The historical fallback test lets the primary protected read return `null`,
withdraws admission at that boundary, and verifies the historical protected
read count remains zero. This models the runtime callback position rather than
counting only an outer storage method.

## 13. Attachment withdrawal-test verdict — NO ISSUE

The settings-store-acquisition test verifies the fake store's real `readKeys`
collection remains empty after withdrawal. The bookmark-resolution withdrawal
and stronger-policy tests verify the fake store's actual `writes` collection
remains empty. Removing the post-acquisition or post-resolution proof would
allow those concrete operations to run and would fail the tests.

## 14. Mixed-revision-test verdict — NO ISSUE

The Environment tests exercise the real double-sample implementation for:

- source failure changed during a later material await;
- graph failure changed;
- failure cleared;
- reset-driving failure newly appearing; and
- two consecutive mismatches.

The last case asserts failure after exactly four source observations, proving
both the retry bound and fail-closed outcome.

## 15. Real self-maintenance regression verdict — NO ISSUE

The four initial-import, reimport, Continue Setup, and automatic-recovery tests
still request `useRealGlobalEnvironmentFeedback: true`. In that mode the
fixture does not override the global Environment provider, archive mutation
coordinator, or exclusive-authority registry. Each scenario waits for a real
`maintenanceInProgress` aggregate observation before continuing through
Journey ingestion, admitted coherent evidence, and the command-specific late
boundary.

The Prompt 22 coherence additions did not replace this loop with a locally
stubbed report or authority.

## 16. Command-semantics unchanged verdict — NO ISSUE

`onboarding_journey_coordinator_provider.dart` remains byte-identical to the
Prompt 22 baseline (SHA-256
`7853f29c9385fc8e6caa9d414dc82e6886a230b5376d3789970c82d11e005632`).

Spot checks retain the accepted order:

```text
positive global handoff
-> runWithCapability
-> admitted coherent report
-> exact capability proof
-> late currentness/binding/semantic rejecting guard
-> immediate begin/resume/reset
```

No await was inserted between the final production guard and the relevant
mutation.

## 17. Protected-I/O architecture verdict — SHOULD FIX

The current runtime is correct, but the AST rule does not yet prove the exact
claim made by Prompt 23.

First, the bookmark-refresh audit treats the call to
`_persistConfigurationUnchecked` as the protected operation. The actual
protected operation is `_settingsStore.writeSetting` inside that helper. A
mutation that inserts an await inside `_persistConfigurationUnchecked` before
`writeSetting` would remain green because that method is not among the AST
roots and the real write invocation is never inspected. This recreates, one
level lower, the outer-Future blind spot the correction was intended to close.

Second, `_isPersistentStoreCheckpoint` accepts any adjacent statement
containing an invocation named
`requirePersistentArchiveStoreAdmission`. It does not prove that the
caller-supplied callback executes unconditionally on the path to the protected
operation. For example, an adjacent conditional/non-dominating call—or an
unrelated receiver exposing the same method name—would satisfy the matcher.

The supplied synthetic mutation proves only the absence of a preceding
checkpoint before a direct read. It does not prove either of these actual
production evasion cases. The rule must inspect the concrete settings write
and structurally require the approved callback invocation on the dominating
path.

## 18. Command-boundary architecture verdict — SHOULD FIX

Production command ordering is correct, and the virtual “guard before await”
mutation is rejected. However, `_commandGuardViolations` identifies a complete
guard only by checking whether the condition's source text contains every
required fragment.

It does not prove rejecting polarity or the required Boolean conjunction. A
guard such as:

```dart
if (_commandAndActionAreCurrent(...) &&
    _reportAllowsCommand(...predicate: _reportAllowsInitialImport)) {
  return;
}
```

contains every required fragment, terminates with `return`, can be immediately
preceded by the exact capability proof, and has no intervening await. It would
therefore pass even though it rejects the valid branch and lets the invalid
branch reach mutation. Similar `||`/negation rearrangements can preserve all
tokens while changing meaning.

The AST check must validate the actual rejecting expression structure, not
only fragment membership.

## 19. Test-realism architecture verdict — SHOULD FIX

The repository's current real-feedback fixture is genuine. The enforcement
rule nevertheless does not mechanically prove the complete realism claim.

`_fixtureRealismViolations` proves the conditional Environment override and
the absence of coordinator/registry overrides. For aggregate observation it
only requires `_JourneyFixture.create.toSource()` to contain the recorder type
name and provider name. Separately, the group audit counts a `waitFor` call
whose argument mentions `maintenanceInProgress`; it does not tie that call to
the recorder returned by the real global provider.

A fixture could retain an unused/dead recorder reference and wait on an
unrelated fake while satisfying both checks. The existing synthetic mutations
cover an ignored flag and replaced authorities, but not this disconnected
observation mutation. The rule should structurally connect the real provider,
recorder/listener, returned fixture handle, and asserted maintenance wait.

## 20. Root-aware traversal verdict — NO ISSUE

`_transitiveLocalDependencies` traverses the root before applying `stopAt` to
descendants. Real semantic roots are removed from the trusted-stop set by
construction, and `shellPath` is not trusted. Approved coordinator/composition
boundaries still stop descendant traversal where intended.

The real census and virtual mutation use the same trusted-boundary set. The
virtual `shell -> wrapper -> raw conversation-graph barrel/controller` path is
therefore visible and rejected.

## 21. Semantic-root/raw-graph census verdict — NO ISSUE

`OnboardingStatus` remains a semantic marker, so status-only consumers are
found. The raw graph controller and graph barrel remain in the primary
evidence set. Wrapper/configuration transitive paths remain traversable, and
the shell is audited. No production presentation/semantic side door to raw
Environment, snapshot, or graph evidence was found outside the accepted
Journey boundary.

## 22. Accumulated-delta/reuse/authority verdict — NO ISSUE

The accumulated runtime delta retains one Journey semantic authority and one
shared Environment evaluator. Presentation consumes Journey episodes and the
Journey-owned operation projection rather than choosing state from raw
snapshot evidence. The old reconciliation providers remain deleted while the
pure reconciliation specialist remains used.

No duplicate readiness policy, second authority, public proof API,
capability/tenure retention, caller-relative global cache, or test-only
provider hook leaking into production was found. The optional proof callbacks
are confined to the specialist invocation boundary, allowing ordinary
non-admitted attachment consumers to preserve existing behavior.

## 23. Persistence/migration/restart verdict — NO ISSUE

- database schema migration: none;
- persisted snapshot migration: none;
- snapshot format: remains version 1 and existing records remain readable;
- startup reconciliation semantics: unchanged by Prompt 22;
- interrupted imports: still require explicit Continue Setup;
- automatic resume: absent;
- serialized capability/tenure: absent;
- Prompt 22 presentation change: none.

The accumulated earlier correction does add Journey-owned presentation and
resume semantics, but Prompt 22 did not alter them.

## 24. Concrete BLOCKER findings

BLOCKER: 0.

No current runtime path was found that begins protected I/O under stale
authority, produces a mixed-revision report, duplicates Journey authority, or
changes protected persistence/restart semantics.

## 25. Concrete SHOULD FIX findings

SHOULD FIX: 3.

1. Protected-I/O AST enforcement stops at the bookmark persistence wrapper
   instead of reaching the concrete settings write, and its checkpoint matcher
   does not prove unconditional execution of the approved callback.
2. Command-boundary AST enforcement checks condition tokens but not rejecting
   polarity or the required Boolean conjunction.
3. Critical-fixture realism enforcement does not structurally connect the
   real Environment provider's recorder to the asserted maintenance wait.

These are enforcement defects rather than observed production-runtime defects,
but all three concern invariants this checkpoint is specifically intended to
make mechanically durable. They should be corrected before checkpointing.

## 26. OPTIONAL findings

- Add an explicit stronger-resource-policy variant for the historical graph
  fallback test. The same callback boundary is already exercised by the
  withdrawal test, so this is additional matrix clarity rather than a distinct
  runtime gap.
- Remove the unused `onboardingJourneyAllowsCommandedTransition` helper in a
  later cleanup.
- Remove the unused `_runAutomaticRecovery` `report` parameter in a later
  cleanup.
- Correct previously recorded canonical Environment Readiness wording that
  still describes the former raw snapshot/presentation relationship.

No aesthetic cleanup belongs in the present correction.

## 27. Narrow tests rerun

None. Source and AST inspection established the three enforcement gaps
directly; rerunning already-green tests would not answer whether the missing
mutations are rejected. The Prompt 22 validation evidence remains:

- Environment: 27 passed;
- failure storage: 12 passed;
- attachment location: 24 passed;
- real feedback Journey group: 4 passed;
- Journey coordinator: 60 passed;
- complete architecture: 554 passed;
- full Flutter suite: 2,743 passed / 0 failed / 1 intentional skip;
- analyzer: clean.

`git diff --check` was rerun and passed.

## 28. Exact Git status

After adding this required response only:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- staged files: 0;
- accumulated tracked worktree: 55 modified / 2 deleted;
- physical untracked files: 92, comprising the 89-file Prompt 22 baseline,
  Response 22, supplied Prompt 23, and this Response 23;
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- all onboarding work: unstaged and uncommitted.

## 29. Preservation-artifact verification — NO ISSUE

The recorded manifest hashes remain unchanged:

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
- Prompt 22:
  `e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`

No preservation artifact or shared-submodule byte was modified. MessageLens
Development was not launched. No real Messages/Contacts database, attachment
archive, archive configuration, or abandoned relocation artifact was accessed
or modified. Nothing was staged, committed, or pushed.

## 30. Checkpoint recommendation

Do not checkpoint yet. Runtime authority and coherence are sound, but the
checkpoint's architecture enforcement still permits three concrete
regressions that its stated policy says must fail. Correct those narrowly,
add synthetic mutations for the exact evasions, repeat this review, and only
then checkpoint the accumulated onboarding correction.

POST-PROMPT-22 ONBOARDING HUMAN ARCHITECTURAL REVIEW: FAIL
