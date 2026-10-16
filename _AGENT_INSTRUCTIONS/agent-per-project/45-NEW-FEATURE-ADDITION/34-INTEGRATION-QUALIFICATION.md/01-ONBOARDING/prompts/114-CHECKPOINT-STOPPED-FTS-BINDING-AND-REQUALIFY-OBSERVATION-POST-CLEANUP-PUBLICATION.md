# MessageLens — Feature 34
## Prompt 114 — Checkpoint Stopped FTS Binding and Requalify Observation Post-Cleanup Publication

**Task type:** Narrow correction of an existing test-only evidence owner; characterization-first, fail-closed. **NOT** resumption of Prompt 113 integration.

### 0. Authority, intent and absolute constraints

Response 113 STOPPED correctly. Its executed characterization demonstrated that the existing Response 109 `CoherentPopulatedReconstructionObservationEnvelope` can publish previously accepted phase evidence when cancellation or the monotonic deadline becomes effective **during successful `attempt.close()`**. The observed result was `FALSE` rather than the required `UNKNOWN` with no published phases. Prompt 113's exact two-new-file allowlist prohibited modifying the existing envelope. This prompt explicitly authorizes **only the minimal correction in that existing test-only envelope and its existing test file**, together with explicitly named Feature 34 prompt/response documentation.

The goal is to ensure the single envelope owner checks terminal cancellation/deadline *after awaited cleanup and before every publication of accepted evidence*, without introducing a second policy/evaluator, false success, automatic retry, leaked phase evidence or destructive authorization.

**No changes to `lib/`, production AppCzar activation, jurisdictions, native/Rust, schemas/migrations, generated files, dependencies, providers, archive, overlay, real-source readers, FTS implementation, or reset behavior.** No real Messages/Contacts/MessageLens database, admitted development/production root, WD/Toshiba archive, attachment payload, TCC/FDA/bookmark, cloud storage, or application launch. Use deterministic synthetic evidence only. Do not implement Prompt 113 adapter in this milestone. No source or archive mutation capabilities.

**Fair Witness:** distinguish source inspection, reproducible test behavior, accepted conclusion, and remaining unknowns. STOP if the verified source contradicts Response 113, the patch would require more than the permitted files, or a terminal lifecycle outcome cannot be expressed by the existing types without broadening scope. Never claim a completed populated witness, cross-file atomicity, exhaustive FTS, or safe Start Fresh.

### 1. Reestablish exact baseline and checkpoint only legitimate documentation

1. Inspect `git status --short`, branch, HEAD, upstream sync, registered worktrees, shared instruction submodule state, and source/test tracked/untracked manifest. Expected from Response 113: branch `fix/onboarding-import-stuck-state`; HEAD `5365dab027761dffe1be4185a7d60ec8ee1b61bb`, synced `0/0`; submodule `95326f515ef4719f155ce6e223990398daad6311` clean; exactly one Feature 34 worktree. **Verify; do not assume.** Preserve all pre-existing unrelated untracked content and every other worktree. No `git clean`, stash, hard reset, rebase, force-push or sweeping staging.
2. Locate the exact Prompt 113 and Response 113 in Feature 34 `01-ONBOARDING/prompts/` and `responses/`. Response 113 intentionally remained untracked; check whether it has since been checkpointed. If untracked and both exact documents are complete, stage **only those two documentation files**, whitespace-check, make one separate documentation commit and normally push before implementation. If already checkpointed, verify its ancestry and do not duplicate. If modified/unexpected, STOP and report.
3. Check presence of the preserved characterization reproducer `/private/tmp/messagelens-prompt113-characterization-test.dart` and its recorded SHA-256 `9ec1fd397b6efd35525675bc4782726cdc45a870ed95849baffa9ad6908aaeb9`. If it is absent, Response 113 contains the complete test and may be used to reconstruct it **inside the existing envelope test file**; don't assume a temporary file persists. Do not treat temporary artifacts as necessary authority.
4. Read current implementation and tests, the canonical Project Conformance audit standard, Prompt/Response 109 and Prompt/Response 113. Capture pre-edit characterization and file hashes.

### 2. Exact implementation allowlist

Only these two *existing* code/test files may be edited:

- `test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation.dart`
- `test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart`

Documentation only, at the existing Feature 34 path:

- `01-ONBOARDING/prompts/113-CHECKPOINT-FTS-QUALIFICATION-AND-QUALIFY-COHERENT-FTS-EVIDENCE-BINDING.md` and matching `responses/113-...md`, strictly for prerequisite checkpoint if not already tracked;
- `01-ONBOARDING/prompts/114-CHECKPOINT-STOPPED-FTS-BINDING-AND-REQUALIFY-OBSERVATION-POST-CLEANUP-PUBLICATION.md` and matching `responses/114-...md`, for separate documentation checkpoint.

The Feature 34 root prefix is the existing `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/`. Preserve its actual layout; do not create a new directory or duplicate previous files.

No test fixture helper outside the two permitted existing files. The FTS helper and tests are reuse-only. Do not create the two planned Prompt 113 implementation files, nor a `lib/` adapter.

### 3. Characterize the defect before changing the envelope

In the existing envelope test file, add the smallest deterministic regression cases reproducing Response 113's two failed post-cleanup-publication scenarios. Use injected `isCancelled`, monotonic `clock`, and successful `close` that sets cancellation or advances elapsed time beyond the deadline. No sleeps. Supply a coherent accepted interval with a known FALSE phase so the published contradiction would be visible absent the fix. Require:

- one attempt and **exactly one completed close**;
- no destructive-mutation authority;
- terminal result `UNKNOWN`, reason `cancellation` or `deadline` respectively;
- empty published `phaseEvidence`, no retained accepted payload/evidence from the disqualified attempt;
- no unexpected retry merely because cancellation/deadline changed during cleanup.

Run the focused test and retain an attributable expected failure against the unchanged implementation. If either fails for an unrelated reason, correct the fixture and rerun without weakening the contract. If both unexpectedly pass on the current source, STOP: report changed behavior and do not perform a speculative patch. Retain Response 113's captured test provenance in the response.

### 4. Minimal single-owner correction

Inspect the envelope's current sequence around the end fingerprint, `_AttemptOutcome.accepted`, awaited `attempt.close().timeout(limits.cleanupTimeout)` and publication. Correct only the owner's post-cleanup boundary so that:

1. An accepted result is never published unless cancellation and monotonic deadline are still clear **after successful awaited cleanup**. Use the envelope's existing typed context/checkpoint semantics where possible. Avoid duplicating deadline calculations or creating a second owner.
2. A newly effective cancellation/deadline returns the appropriate typed `UNKNOWN`, with **all phase evidence discarded**, even if it had contained a known coherent contradiction. Do not rewrite it as `FALSE` and do not leak any accepted payload.
3. A cleanup throw/timeout preserves existing fail-closed `ambiguousCleanup` semantics and cleanup evidence. Do not masquerade a throw as successful cleanup; preserve clear precedence, record it in tests, and do not suppress failure.
4. The owner closes each created attempt exactly once. Check cancellation/deadline *after* cleanup without interrupting a still-active close, double-closing, or deleting resources prematurely. Do not rely on `Future.timeout` to imply native work stopped.
5. The two-attempt retry policy stays exactly as qualified for fingerprint mismatch: never retry on terminal cancellation, deadline or cleanup ambiguity; never publish discarded attempt-one evidence. There is no cross-file atomic snapshot claim.
6. Existing stable TRUE, stable FALSE with unrelated UNKNOWN, first-mismatch-then-stable, two-mismatch UNKNOWN, thrown-close UNKNOWN, resource-bound failure and operational timestamp lifecycle semantics remain unchanged when the new terminal boundary is not triggered.
7. `canAuthorizeDestructiveMutation` remains unconditionally false.

Do not refactor unrelated code or change constructor/public model shape unless unavoidable; if unavoidable STOP for new review.

### 5. Adversarial matrix in the existing test file

In addition to the two red-before/green-after regressions, qualify deterministic cases:

- cancellation and deadline become effective during close after an otherwise TRUE accepted interval; also after a FALSE known contradiction; both discard evidence;
- cancellation and deadline occur during close on the second, stable attempt after a first fingerprint mismatch; exactly two attempts, attempt-one evidence already discarded, terminal UNKNOWN, no third attempt;
- first fingerprint mismatch followed by successful close that becomes cancelled/deadline: terminal UNKNOWN **without starting attempt two**;
- cleanup throws or times out while cancellation/deadline is also set: assert the deliberately selected, source-grounded precedence and ensure neither result can be TRUE/FALSE, with no leaked phases;
- cancellation/deadline already active before close: still attempt owned cleanup exactly once; report typed UNKNOWN;
- no cancellation/deadline, successful close preserves known TRUE/FALSE semantics and the explicitly qualified `UNKNOWN` phase evidence;
- boundary clock equals deadline versus strictly exceeds deadline, following the existing comparison rule (inspect instead of guessing);
- successful close on a fingerprint mismatch preserves exactly the existing permitted retry behavior when no terminal stop is active;
- resource-limit/cancel/deadline at ordinary phase boundaries and cleanup-error handling regressions stay green;
- no hidden retries, no double-close, no reusable phase payload from a discarded attempt, no mutation authority.

If any test reveals a second independent defect, STOP after reporting it rather than broadening patch scope. Avoid fragile timing assertions and wall-clock sleeping.

### 6. Verification and conformance

Run and report exact attributable exit statuses/counts for:

- focused existing `coherent_populated_reconstruction_observation_test.dart`;
- existing FTS evidence qualification test (unchanged), plus the relevant AppCzar/reconstruction/protected-reference test group;
- `test/architecture/forbidden_imports_test.dart` (and broader architecture suite if the standard requires it);
- full `flutter analyze` and targeted `dart analyze` if useful;
- `dart format --output=none --set-exit-if-changed` on the two permitted files;
- `git diff --check`, staged-diff check, exact changed-file inventory, pre/post manifest preservation and shared-instructions submodule check.

If sandbox/SDK-cache restrictions prevent a run, mark it unverified and rerun through the already approved SDK environment as appropriate; never count an aborted command as PASS. Full Flutter suite only if mandated by governing standard or a concrete failure.

Conduct the canonical Project Conformance review. PASS requires `BLOCKER: 0`, `SHOULD FIX: 0` in this narrow correction. Verify strict test-only placement, single owner, typed fail-closed semantics, bounded resource ownership, no second evaluator, no user/real data and no destructive authorization.

### 7. Git checkpoints and Response 114

After characterization, correction, full qualification and PASS, create a single source/test implementation checkpoint containing **exactly the two existing permitted files**, with a descriptive subject such as `test(appczar): requalify post-cleanup observation publication`. Push normally. Keep Prompt/Response 114 documentation in a **separate** documentation checkpoint only after implementation is proven; do not report a self-referential hash inside its own response. If any mandatory gate fails, do not commit success; leave a factual STOP response preserving the repository and any requested reproducer.

Response 114 must explicitly report:

- verified baseline, original and final Git state, precise touched paths, checkpoint hashes and remote sync;
- the red-before fix reproducer and green-after outcome, all boundary cases, counts and real command outcomes;
- how the existing owner now guards publication after successful cleanup, and why it does not race ongoing resource work;
- precedence of actual cleanup failure vs cancellation/deadline;
- two-attempt retry and close-once evidence, treatment of accepted FALSE and retained phases;
- Project Conformance findings;
- unqualified limits: native cancellation/preemption, full cross-store coherence, FTS internal/exhaustive equivalence, protected payload bytes, populated replay and destructive readiness.

End with literal status flags: `POST-CLEANUP PUBLICATION REGRESSION: PASS/FAIL`, `EXISTING ENVELOPE REQUALIFIED: YES/NO`, `PROMPT 113 FTS BINDING RESUMED: NO`, `COMPLETE POPULATED RECONSTRUCTION WITNESS: NO`, `DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`, `PRODUCTION APPCZAR ACTIVATION: OFF`, `PROJECT CONFORMANCE: PASS/FAIL`, and `READY FOR A NEW SEPARATE PROMPT 115: YES/NO`.

**STOP.** Do not proceed to the FTS binding adapter, production witnesses, Stage 2C, or cutover under this prompt.
