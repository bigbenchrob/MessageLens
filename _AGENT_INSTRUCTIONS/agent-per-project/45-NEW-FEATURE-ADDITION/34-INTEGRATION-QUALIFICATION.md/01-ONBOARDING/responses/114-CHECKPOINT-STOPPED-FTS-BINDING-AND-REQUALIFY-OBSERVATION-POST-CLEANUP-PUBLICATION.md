# Feature 34 — Response 114

## Outcome

The existing test-only coherent-observation envelope is requalified for post-cleanup publication. A successful awaited close is now followed by the owner's existing cancellation/deadline checkpoint before returning accepted evidence or permitting a fingerprint-mismatch retry. A terminal cancellation or deadline produces typed UNKNOWN and discards every phase payload, including previously accepted FALSE evidence. Actual cleanup failure retains `ambiguousCleanup` precedence.

This corrects the exact Response 113 blocker. Prompt 113 binding integration was **not resumed**; no adapter or populated witness was created. The source/test checkpoint is `28449d2f7457f9c751b0a683d7012dc3812c62d0`, pushed normally. All required validation and bounded Project Conformance checks passed.

## Verified baseline and prerequisite checkpoint

Starting repository: `/Users/rob/Development/FlutterProjects/remember_every_text`.

- Branch: `fix/onboarding-import-stuck-state`.
- Starting HEAD: `5365dab027761dffe1be4185a7d60ec8ee1b61bb`.
- Upstream: `origin/fix/onboarding-import-stuck-state`, 0 ahead / 0 behind.
- Tracked worktree and index: clean.
- Exactly one worktree on this branch. The other three registered worktrees remained unchanged: Feature 35 at `09b1c767cc01410da5799273206e2ab2a4d3b283`, main at `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle worktree at `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`.
- Shared instructions: clean at `95326f515ef4719f155ce6e223990398daad6311`.
- Source-only manifest: `/private/tmp/messagelens-prompt114-baseline.json`, covering 5,994 tracked files and 51 untracked files before editing.

Manifest SHA-256: `2604f630c0ce4c1fc458caf13f74959de74b24e8dca2b4537f25095ceb4ae122`.

The 51 baseline untracked files comprised the exact Prompt 113/Response 113 pair, Prompt 114, and 48 unrelated files. All were preserved byte-for-byte. Both stopped documents were complete and still untracked. They alone were whitespace-checked, committed and normally pushed before implementation:

`29edb8977e63ab87893e0f1415f32c89317cde50` — `docs(feature34): record stopped coherent FTS binding qualification`.

No prior checkpoint was duplicated. The source implementation base is therefore `29edb8977e63ab87893e0f1415f32c89317cde50`.

The preserved reproducer existed at `/private/tmp/messagelens-prompt113-characterization-test.dart` and matched recorded SHA-256 `9ec1fd397b6efd35525675bc4782726cdc45a870ed95849baffa9ad6908aaeb9`. Response 113's complete embedded test remains durable provenance; the temporary file was not treated as necessary authority.

## Exact permitted changes and source hashes

Only these existing files changed in the implementation checkpoint:

| File | Before SHA-256 | After SHA-256 |
|---|---|---|
| `test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation.dart` | `214a6a9a3947521a1ac331253cc730b6b24754a2ace9b4bb93325723ab9b15f2` | `533584d4b4d22d93cfaf1d54bb2589c24057ffd521f03264f6859ac2819061a0` |
| `test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart` | `193524074c578c16ae00118cd1ae1613a7a5b59aeba076ddc2b4cdb758a7a488` | `921d69ba4cb1b6d0abcd0e43569cdb5e96802916195833bcd8cc2ab8958f5c26` |

The implementation diff contains 255 insertions and one deletion across exactly these two files: an eight-line owner diff and 248 test lines. The test harness gained an awaited close callback and separate completed-close accounting. Tests use the existing `fake_async` dependency; no dependency or lockfile changed.

No production, FTS helper/test, other existing test/helper, schema/migration, generated, native/Rust, provider, release, archive, overlay or reset source changed. The two proposed Prompt 113 implementation paths remain absent. Documentation writes were confined to the explicitly authorized Prompt/Response 113 prerequisite checkpoint and Prompt/Response 114 completion checkpoint.

## Characterization before correction

Source inspection confirmed Response 113 exactly. The envelope read and compared the end fingerprint, constructed an accepted outcome, awaited close, and returned the earlier outcome without a final terminal checkpoint. Cleanup exceptions already changed the outcome to ambiguous-cleanup UNKNOWN; successful cleanup that changed cancellation/deadline did not.

Two regression tests were added inside the existing envelope test file before changing the envelope. Each supplied an otherwise stable accepted interval with a FALSE graph phase. Successful close either set cancellation or advanced the injected monotonic clock to six seconds against a five-second deadline. Assertions required one attempt, one started and completed close, no destructive authority, UNKNOWN with the exact terminal reason, empty phase evidence and no retry.

Command:

```text
/Users/rob/Development/flutter/bin/flutter test test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart --reporter expanded
```

Pre-fix result: **16 passed, 2 failed, exit 1**. Both new regressions failed with:

```text
Expected: ReconstructionObservationTruth:<ReconstructionObservationTruth.unknown>
  Actual: ReconstructionObservationTruth:<ReconstructionObservationTruth.falseValue>
```

The original 16 tests remained green. The unchanged owner hash and test-only diff establish attribution. No compile/bootstrap problem or changed source behavior invalidated characterization. Captured log: `/private/tmp/messagelens-prompt114-red.log`. The original Response 113 expected failures were not substituted for this fresh red-before-fix run.

## Minimal owner correction and precedence

The existing `_runAttempt` owner now performs:

1. Existing bounded reads and start/end fingerprint comparison.
2. Exactly one awaited `attempt.close().timeout(limits.cleanupTimeout)`.
3. If cleanup throws/times out: immediately return `_AttemptOutcome.unknown(ambiguousCleanup)`.
4. Only after successful cleanup: call the existing `context.checkpoint()`.
5. If that checkpoint throws the existing typed cancellation/deadline abort: replace the outcome with `_AttemptOutcome.unknown(error.reason)`, which has an empty phase list and is not a fingerprint-mismatch retry outcome.
6. Otherwise return the previously classified outcome unchanged.

No deadline arithmetic, model shape, constructor, phase type, evidence policy or retry owner was added. The existing checkpoint uses `elapsed >= deadline`; exact equality is therefore terminal. It checks cancellation first; this ordering is unchanged.

Precedence is explicit: **actual cleanup throw/timeout → ambiguousCleanup** even when cancellation/deadline has also become active. **Successful cleanup + terminal cancellation/deadline → that typed terminal reason**, overriding accepted TRUE, accepted FALSE, or fingerprint mismatch. A real cleanup failure is not relabeled successful cancellation. No terminal outcome can carry accepted phases or request another attempt.

This change does not interrupt close, start a second close or delete resources. The final checkpoint runs after awaited cleanup succeeds. The existing timeout path is not a native-work cancellation mechanism: it can return ambiguous-cleanup UNKNOWN while a close remains pending. The test completes that fake close afterward and verifies that it completes once without changing the published UNKNOWN. No claim that timeout implies quiescence is made.

## Adversarial matrix

The final focused suite contains the original 16 tests plus 24 new tests, **40 passed**:

| Case | Evidence |
|---|---|
| Original Response 113 FALSE regressions | Cancellation and exceeded deadline during successful close: exact terminal UNKNOWN, empty phases, one completed close, one attempt |
| Accepted TRUE and accepted FALSE | Each tested with cancellation, deadline equality and deadline exceeded during close; all terminal outcomes discard evidence |
| First mismatch then second stable attempt | All three terminal modes during second close: exactly two attempts, both completed closes once, no phase evidence and no third attempt |
| First mismatch with terminal stop during first close | All three modes: UNKNOWN after one completed close; attempt two never starts |
| Cleanup throws with terminal stop active | Three modes: ambiguousCleanup, empty phases, one close invocation, no successful close count and no retry |
| Cleanup times out with terminal stop active | Three virtual-time cases: ambiguousCleanup; close remains pending at publication, later completes exactly once, published result unchanged |
| Terminal stop active before close | Three modes injected during graph phase: subsequent work stops, owned cleanup still completes once, exact terminal reason retained |
| Awaited successful close below deadline | Result stays unpublished while close is pending; after completion at four seconds, TRUE and eight phases survive |
| Existing stable FALSE beside unrelated UNKNOWN | Original test remains green; both domain observations retained when no terminal boundary fires |
| Existing missing phase | Explicit UNKNOWN phase evidence retained when interval and cleanup are otherwise stable |
| Existing retry semantics | One mismatch retries once; two mismatches produce UNKNOWN with no retained evidence; callback/resource isolation and close-once tests remain green |
| Existing bounds and lifecycle semantics | Row/byte/memory/disk/diagnostic limits, ordinary phase cancellation/deadline/failure, operational timestamp validation and 10,001-row bounded stream unchanged |

No test sleeps or relies on wall-clock scheduling. FakeAsync advances the existing cleanup timeout deterministically and flushes pending microtasks. Timeout cases assert no result before the deadline, one started but unfinished close at timeout, one completion after explicitly releasing the fake close, no further attempt, unchanged result identity and no pending timers at test end. No real resource is deleted underneath pending work.

Every new terminal case asserts no destructive authorization. The property remains unconditionally false in the unchanged public model. No FTS/protected-reference proof level is promoted and no production policy consumes this evidence.

## Required validation

All results below are attributable to completed processes, not inferred from interrupted commands:

| Gate | Result | Exit |
|---|---|---|
| Pre-fix focused suite | 16 passed, 2 expected failures | 1 |
| Post-fix focused suite | 40 passed, 0 failed | 0 |
| Relevant regression group, including unchanged FTS | 260 passed, 0 failed | 0 |
| Complete forbidden-import architecture suite | 394 passed, 0 failed | 0 |
| Full flutter analyze | No issues found, 7.5 seconds | 0 |
| Targeted no-change formatting | 2 files, 0 changed | 0 |
| Git working/staged whitespace checks | Passed | 0 |

The focused command was the same before and after the correction. Exact regression invocation:

```text
/Users/rob/Development/flutter/bin/flutter test \
  test/essentials/app_czar \
  test/essentials/app_czar_operating_session \
  test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart \
  test/essentials/source_scoped_import/application/reconstruction/source_scoped_import_ledger_material_comparison_test.dart \
  test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence_test.dart \
  --reporter expanded
```

The AppCzar directory includes the coherent envelope and protected-reference reconstruction tests. The 260 count includes the focused 40 and unchanged FTS 22; it is not an additional disjoint test count.

Other commands:

```text
/Users/rob/Development/flutter/bin/flutter test test/architecture/forbidden_imports_test.dart --reporter expanded
/Users/rob/Development/flutter/bin/flutter analyze
/Users/rob/Development/flutter/bin/dart format --output=none --set-exit-if-changed test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation.dart test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart
git diff --check
git diff --cached --check
```

Logs: `/private/tmp/messagelens-prompt114-{red,focused,regression,architecture,analyze,format}.log`. SDK-cache access used the approved execution environment. There were no interrupted, sandbox-denied or unexpected failing runs in this milestone. Only the deliberately required red-before-fix run failed. Targeted analyzer was unnecessary after full analysis passed. No generation was needed; no generator input/output changed. The full Flutter suite and broader architecture suite were not required by the bounded conformance standard or a concrete regression.

## Project Conformance Audit

Scope: complete two-file implementation delta from `29edb8977e63ab87893e0f1415f32c89317cde50`, including unstaged changes reviewed before commit. This is a narrow test-only correction, not a whole-repository or populated-witness audit.

**Reviewed against:**

- `AGENTS.md` and `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`.
- `_AGENT_INSTRUCTIONS/agent-per-project/README.md` and the established project architecture/database ownership rules.
- `_AGENT_INSTRUCTIONS/agent-instructions-shared/10-language/dart.md`.
- Feature 34 `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`.
- Prompt/Response 109, Prompt/Response 113, Prompt 114, and the exact current envelope/test source.

| Area | Verdict and evidence |
|---|---|
| Reuse before invention | NO ISSUE: existing typed checkpoint and UNKNOWN constructor reused |
| Layering/ownership/dependency direction | NO ISSUE: existing test-only owner corrected; no second evaluator, adapter, provider or production dependency added |
| Single source of truth | NO ISSUE: deadline/cancellation remain owned by the existing attempt context; retry remains owned by envelope |
| Project idioms | NO ISSUE: typed reasons, awaited cleanup, braces and existing harness conventions retained |
| Bounded work/lifecycle | NO ISSUE within qualified scope: no new loop/retry, fixed deterministic tests, explicit completed-close accounting; timeout caveat preserved |
| Privacy/logging | NO ISSUE: synthetic evidence, categories and fixed identity tokens only; no user content |
| Mutation/authority | NO ISSUE: unconditional false authority untouched; no real data or mutation capability |
| Error semantics | NO ISSUE: actual cleanup failure takes precedence; successful close receives terminal check; all disqualified phases discarded |
| Dead/superseded machinery | NO ISSUE: no unused alternate evaluator or new public model introduced |
| Tests/architecture | NO ISSUE: red-before/green-after, complete boundary matrix, regressions and architecture pass |
| Generated/dependency/release hygiene | NO ISSUE: all unchanged; fake_async already declared |
| Documentation agreement | NO ISSUE: stopped integration remains stopped, timeout/preemption and proof limits explicit |
| UX/navigation/theming | Not applicable: no presentation change |

**BLOCKER: 0. SHOULD FIX: 0. OPTIONAL: 0.** The Response 113 lifecycle blocker is resolved within the newly authorized owner scope. No second independent defect was found by this matrix.

PROJECT CONFORMANCE: PASS

## Checkpoints, preservation and final Git state

- Starting checkpoint: `5365dab027761dffe1be4185a7d60ec8ee1b61bb`.
- Stopped Prompt/Response 113 documentation: `29edb8977e63ab87893e0f1415f32c89317cde50`, pushed normally before implementation.
- Exactly two source/test files: `28449d2f7457f9c751b0a683d7012dc3812c62d0`, subject `test(appczar): requalify post-cleanup observation publication`, pushed normally and verified upstream 0/0.
- Prompt 114 and this Response 114 form the subsequent separate documentation checkpoint. Its actual self-referential hash is reported after Git creates it in the final handoff, not guessed in this file.

Manifest comparison before checkpoint found exactly the two allowed tracked-file hash changes; all other 5,992 baseline tracked-file hashes and all 51 baseline untracked-file hashes were unchanged. The FTS files were specifically included in the unchanged baseline. All four worktrees and the clean shared submodule were preserved. No reset, stash, clean, rebase, squash, force push or unrelated staging occurred.

After the prescribed documentation checkpoint, the 48 unrelated baseline files remain untracked. Final tracked worktree/index cleanliness, upstream 0/0, submodule cleanliness and exact preservation are verified in the final handoff. No Prompt 113 adapter file exists.

## Remaining unqualified limits

The fix establishes the tested owner publication boundary for injected evidence; it does not provide native query/close cancellation or preemption. A timeout still cannot establish that a native operation has quiesced. It does not create a common cross-store transaction, qualify physical FTS reads inside a coherent observation, establish internal/exhaustive FTS equivalence, prove protected attachment payload bytes, implement production-scale populated replay, or authorize destructive Operating Start Fresh.

Seven AppCzar jurisdictions remain unchanged; production activation is OFF. A new separately authorized Prompt 115 may consider the next evidence milestone after this owner correction. No adapter, populated witness, Stage 2C or cutover was undertaken here.

POST-CLEANUP PUBLICATION REGRESSION: PASS

EXISTING ENVELOPE REQUALIFIED: YES

PROMPT 113 FTS BINDING RESUMED: NO

COMPLETE POPULATED RECONSTRUCTION WITNESS: NO

DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO

PRODUCTION APPCZAR ACTIVATION: OFF

PROJECT CONFORMANCE: PASS

READY FOR A NEW SEPARATE PROMPT 115: YES
