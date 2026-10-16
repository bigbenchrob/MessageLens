# Feature 34 — Response 113

## STOP: existing envelope publication boundary fails characterization

Prompt 113 is **not qualified or implemented**. Pre-composition characterization exposed one blocking lifecycle gap in the unchanged Response 109 envelope: cancellation or monotonic deadline expiry during successful cleanup does not invalidate a previously accepted result. Both cases returned FALSE where Prompt 113 requires UNKNOWN and discarded phase evidence.

This triggers Prompt 113 sections 2, 3 and 8. The required correction belongs to the existing envelope, which is outside the exact two-new-file allowlist. No adapter, second evaluator, cleanup-policy workaround, weakened assertion or success checkpoint was introduced. The exploratory new test was copied outside the repository and removed. Existing source/test baseline is intact. This uncommitted response records the reproducer and requested contract gap for review.

## Baseline and checkpoint verification

- Repository: `/Users/rob/Development/FlutterProjects/remember_every_text`.
- Branch: `fix/onboarding-import-stuck-state`.
- HEAD, unchanged throughout: `5365dab027761dffe1be4185a7d60ec8ee1b61bb`.
- Upstream: `origin/fix/onboarding-import-stuck-state`, 0 ahead / 0 behind.
- Tracked worktree and index: clean before and after characterization.
- Exactly one worktree on the Feature 34 branch; all four existing worktrees preserved.
- Other worktrees: `remember_every_text-feature-35` at `09b1c767cc01410da5799273206e2ab2a4d3b283`; `remember_every_text-main` at `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`; `remember_every_text.worktrees/gradle-fix-flutter-projects` at `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`.
- Shared instructions clean at `95326f515ef4719f155ce6e223990398daad6311`.
- Required ancestors verified: envelope `281d7e01161ac779f281c397bac5c626a9eb320b`, protected references `89aa7317b52f704689cdcecc36f81f0f31e46554`, FTS evidence `478dc11fef099202fcb18e62d88501152ffc5739`.
- Prompt/Response 112 already committed together at HEAD, `5365dab027761dffe1be4185a7d60ec8ee1b61bb`, subject `docs(feature34): record bounded FTS evidence qualification`. Both exact paths verified in that commit; checkpoint already synchronized. No duplicate commit or push.
- Both proposed Prompt 113 implementation files were absent before work; pre-edit hashes are not applicable.

The source-only pre-edit manifest is `/private/tmp/messagelens-prompt113-baseline.json`, SHA-256 `7ee8765a443217bf909aff9ec9df1c74933c0175acf25f2660321546e5e33a26`. It records 5,994 tracked file hashes and 49 untracked file hashes, including Prompt 113 and 48 unrelated files. Every recorded hash was checked unchanged after removal of the exploratory test. This manifest covers a broader tracked-file inventory than the preceding Prompt 112 manifest; the count difference is not source churn.

No existing untracked file was altered, staged or removed. Response 113 is the only new repository file remaining. Prompt 113 and this response remain untracked; no implementation/documentation checkpoint was made because qualification failed.

## Pre-edit contract audit

### Ownership and representability

`coherent_populated_reconstruction_observation.dart` owns attempt creation, start/end fingerprint comparison, all eight phase reads, discard/retry and final publication. Its phases are archive binding; source occurrences/registry; ledger; graph; overlay; Presence; journals/receipts/operations; implementation/runtime. A first fingerprint mismatch discards the phase list and allows one fresh attempt. Two mismatches return interval-instability UNKNOWN without retained phase evidence. Known accepted contradictions take precedence over unrelated UNKNOWN evidence. No cross-file atomic snapshot follows.

`ReconstructionPhasePayload` is an interface, and `ReconstructionPhaseEvidence.unknown` accepts a payload. Thus a custom graph-phase payload can retain a complete `FtsEvidenceResult` without casts, existing-helper edits or promoting its unassessed dimensions. The first passing characterization retains the identical payload object and returns UNKNOWN. The second passes a deliberately supplied graph-phase contradiction and confirms FALSE remains beside unrelated UNKNOWN phases. These are representation/aggregation characterizations, **not a qualified binding adapter**.

`fts_equivalence_evidence.dart` separately owns six typed dimensions, assessed flags and reason values, runtime/schema/binding/corpus identity, bounded redacted diagnostics and one-attempt cleanup. Its first four finite dimensions must not substitute for qualified internal-index or exhaustive semantics. Its internal/exhaustive dimensions remain UNKNOWN/unassessed. The FTS comparator checks its cancellation/deadline after awaited close; the coherent envelope currently does not.

The new characterization supplied synthetic FTS-shaped results directly. Expected/observed runtime and binding fields were intentionally null: no actual SQLite/runtime qualification or full provenance claim is made. A direct result constructor is not validation. The tests isolate payload retention and envelope lifecycle; they do not claim to implement the proposed adapter's binding admission.

### Exact source gap

At the verified unchanged source:

`test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation.dart`

- Lines 557–570 read the end fingerprint and construct `_AttemptOutcome.accepted(phaseEvidence)` after matching fingerprints.
- Lines 579–586 await `attempt.close().timeout(limits.cleanupTimeout)` and replace the outcome only if cleanup throws or times out.
- Line 588 returns the outcome, without a post-cleanup `context.checkpoint()` or equivalent owner-level publication guard.
- The public result path preserves that accepted outcome and its phase list.

Consequently, a successful close callback that sets the existing cancellation reader true, or advances the injected monotonic clock beyond the attempt deadline, still publishes the earlier accepted result. This is independent of any FTS interpretation and is not a database failure. The reproducer observes one close and one attempt before the failing assertion.

Existing Response 109 tests check cancellation/failure inside phases and thrown cleanup errors. They do not cover cancellation/deadline becoming effective during a successful close. Their continued passing result does not establish this newly required boundary.

### Binding elements still requiring qualification

A later adapter can receive an explicit immutable synthetic binding, but the following must still be supplied and tested; none was inferred here:

- Expected/observed graph occurrence identity stronger than path equality, plus start/end material fingerprints.
- Source occurrence, registry allocation and ledger identity used for replay.
- Explicit schema version and normalized FTS table/trigger DDL.
- Actual loaded SQLite version/source/options and runtime contract.
- Exact named finite corpus revision and production parser/search implementation identity.
- Enclosing attempt token/generation, archive/root/location generation and implementation identity.

The envelope fingerprint provides opaque material identity fields, not an automatically verified mapping to FTS fields. FTS results retain a corpus identity label, not the complete request definitions or parser implementation contract. Additional explicit input would be required even for synthetic composition. The existing physical fixture classes in the FTS test are private to that test library; safely reusing them without changing a previous helper is not currently demonstrated. Physical read composition remains unqualified. No fake binding is presented as actual SQLite connection evidence.

## Characterization results and reproducer

Executed once using the existing helpers, with no wall-clock sleeps, live data, new policy or DB opening:

```text
flutter test test/essentials/app_czar/application/reconstruction/coherent_fts_evidence_binding_test.dart --reporter expanded
```

Result: **2 passed, 2 failed; exit 1**.

| Case | Result |
|---|---|
| Typed phase payload retains all six dimensions; last two UNKNOWN/unassessed | PASS |
| Stable supplied contradiction retained beside unrelated UNKNOWN phases | PASS |
| Cancellation becomes true during successful cleanup; result must be UNKNOWN | FAIL: actual FALSE |
| Monotonic deadline expires during successful cleanup; result must be UNKNOWN | FAIL: actual FALSE |

Both failures reported:

```text
Expected: ReconstructionObservationTruth:<ReconstructionObservationTruth.unknown>
  Actual: ReconstructionObservationTruth:<ReconstructionObservationTruth.falseValue>
```

The truth assertion failed before subsequent empty-phase-list and typed-reason assertions executed. No pass is claimed for those later assertions; source inspection explains why the accepted phase list remains attached. Both tests had already verified one close, one attempt and no destructive authority.

Captured output: `/private/tmp/messagelens-prompt113-characterization.log`.
Preserved exact formatted test: `/private/tmp/messagelens-prompt113-characterization-test.dart`.
Test SHA-256: `9ec1fd397b6efd35525675bc4782726cdc45a870ed95849baffa9ad6908aaeb9`.
The test was created only at the authorized new test path, then removed to restore the source/test baseline. Its complete contents are included below so the finding survives temporary-file removal. Relative imports are for that original authorized path.

## Other validation and noninterference

After the stop finding, the two unchanged independent qualification suites were run to distinguish the new boundary gap from a pre-existing suite regression:

```text
flutter test \
  test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart \
  test/essentials/conversation_graph/application/reconstruction/fts_equivalence_evidence_test.dart \
  --reporter expanded
```

Result: **38 passed, 0 failed; exit 0**. Log: `/private/tmp/messagelens-prompt113-existing-contracts.log`. This includes the existing disposable physical FTS qualification, not integration of its reads with the envelope.

The exploratory test was formatted successfully. No compile/bootstrap failure or interrupted result was counted. Further graph/ledger/protected-reference regressions, architecture suite, full analyzer and full integration matrix were **not run for Prompt 113** after the mandatory pre-composition stop. Their prior passes are not reported as new Prompt 113 validation. No implementation exists to checkpoint. Git diff/staged diff and baseline hash checks verify restoration; generation is not applicable.

All characterization used fixed synthetic evidence. The existing FTS suite used only its previously qualified synthetic disposable worlds and read-only observation seam. No actual Messages/Contacts, app databases, real overlay/Presence/archive, external drive, attachment payload, bookmark, FDA/TCC, provider root, application build/launch/install or production operation was accessed. Existing production parser/repository/schema authority was unchanged.

## Conformance and exact next dependency

**Reviewed against:** global `agent-guardrails.md`; project `README.md` and `AGENTS.md`; Feature 34 `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompts/Responses 108–112 and current Prompt 113; the existing coherent envelope and tests; FTS evidence helper/tests and their production parser/repository injection seam. Current source and executed characterization control the lifecycle finding over broader previous narrative.

Scope: Prompt 113 pre-composition audit at `5365dab027761dffe1be4185a7d60ec8ee1b61bb`, not a whole-repository conformance verdict.

**BLOCKER 1 — owner-level cancellation/deadline publication gap.** The unchanged envelope can publish a known contradiction after cancellation or deadline expiry during cleanup. Governing requirements: Prompt 113 §6 cases 10–12, §2 compatibility stop, §3 no previous-helper changes, §8 stop on failed gates. This prevents the requested integration milestone from passing within its exact scope.

**SHOULD FIX: 0** additional findings. Other provenance/physical integration questions remain unqualified work, not claimed as defects or completed tests.

- Reuse/layering/dependency direction: no production change or replacement evaluator introduced.
- Proof semantics: representation can preserve six dimensions; no overall FTS TRUE asserted; full binding integration not reached.
- Single owner: retained; adapter does not take over envelope publication/retry.
- Bounds/privacy: small fixed fake payload, existing finite limits, deterministic clock, category-only assertions; no content-bearing diagnostics.
- Lifecycle: BLOCKER above; fake close count itself is correct.
- Generated/dependency/release/UI: unchanged; UI conventions not applicable.
- Documentation: literal failures and unqualified scope recorded; no success claim.

PROJECT CONFORMANCE: FAIL

The smallest next authorized work is a separate correction/qualification of the **existing test-only envelope and its existing tests**, specifically its cancellation/deadline check after cleanup and before publication, with typed UNKNOWN and no accepted phase evidence. Preserve close-once ownership and existing two-attempt semantics. Review timeout/quiescence limitations separately before any actual SQLite composition: `Future.timeout` alone does not stop native work. No source change is proposed or performed here.

A callback that deliberately throws after close would be classified as `ambiguousCleanup`, not the required cancellation/deadline reason. A new adapter that post-processes accepted results or owns publication checks would move lifecycle policy into a second owner. Neither is a faithful substitute for fixing the envelope under a separately approved scope. After that owner-level contract is qualified, resume the two-file synthetic binding milestone; physical FTS-read composition remains a separate qualification unless safely reusable seams are authorized.

## Final state and remaining blockers

HEAD and upstream unchanged at `5365dab027761dffe1be4185a7d60ec8ee1b61bb`, 0/0. Tracked worktree/index and shared submodule remain clean. All 5,994 baseline tracked hashes and 49 baseline untracked hashes remain unchanged. With this response there are 50 untracked files: the 49 original entries plus Response 113. Neither proposed implementation file remains. No new commit, push, reset, clean, squash, force push or unrelated staging occurred.

The complete populated witness, exhaustive FTS proof and destructive policy eligibility remain unavailable. Internal/exhaustive UNKNOWN must not be replaced by four finite-TRUE dimensions. Seven jurisdictions remain unchanged and production activation remains off. The remaining Prompt 113 adversarial matrix—binding changes, rejected attempt discard with bound FTS details, budgets and every publication boundary—was not completed after the stop gate.

## Exact characterization test preserved for review

```dart
import 'package:flutter_test/flutter_test.dart';

import '../../../conversation_graph/application/reconstruction/fts_equivalence_evidence.dart';
import 'coherent_populated_reconstruction_observation.dart';

// Characterization only: no binding adapter or observation policy is added.
void main() {
  test(
    'existing payload seam retains all six dimensions without promotion',
    () async {
      final payload = _Payload(_fts());
      final result = await _observe(payload);
      expect(result.truth, ReconstructionObservationTruth.unknown);
      expect(result.phaseEvidence, hasLength(8));
      expect(result.phaseEvidence[3].payload, same(payload));
      for (final dimension in FtsDimension.values.skip(4)) {
        expect(payload.evidence.dimensions[dimension]!.truth, FtsTruth.unknown);
        expect(payload.evidence.dimensions[dimension]!.assessed, isFalse);
      }
      expect(result.canAuthorizeDestructiveMutation, isFalse);
    },
  );

  test(
    'accepted contradiction survives beside unrelated unknown phases',
    () async {
      final payload = _Payload(_fts(rawMismatch: true));
      final result = await _observe(payload, contradiction: true);
      expect(result.truth, ReconstructionObservationTruth.falseValue);
      expect(result.phaseEvidence[3].payload, same(payload));
      expect(
        result.phaseEvidence[0].truth,
        ReconstructionObservationTruth.unknown,
      );
      expect(result.canAuthorizeDestructiveMutation, isFalse);
    },
  );

  for (final deadline in <bool>[false, true]) {
    test(
      '${deadline ? 'deadline' : 'cancellation'} during cleanup must discard phase evidence',
      () async {
        var cancelled = false;
        var now = Duration.zero;
        var closes = 0;
        final payload = _Payload(_fts(rawMismatch: true));
        final result = await _observe(
          payload,
          contradiction: true,
          cancelled: () => cancelled,
          clock: () => now,
          close: () async {
            closes++;
            if (deadline) {
              now = const Duration(seconds: 6);
            } else {
              cancelled = true;
            }
          },
        );
        expect(closes, 1);
        expect(result.attemptCount, 1);
        expect(result.canAuthorizeDestructiveMutation, isFalse);
        expect(result.truth, ReconstructionObservationTruth.unknown);
        expect(result.phaseEvidence, isEmpty);
        expect(
          result.unknownReason,
          deadline
              ? ReconstructionObservationUnknownReason.deadline
              : ReconstructionObservationUnknownReason.cancellation,
        );
      },
    );
  }
}

final class _Payload implements ReconstructionPhasePayload {
  const _Payload(this.evidence);
  final FtsEvidenceResult evidence;

  @override
  ReconstructionObservationPhase get phase =>
      ReconstructionObservationPhase.graph;
}

FtsEvidenceResult _fts({bool rawMismatch = false}) => FtsEvidenceResult(
  dimensions: <FtsDimension, FtsDimensionEvidence>{
    for (final dimension in FtsDimension.values.take(4))
      dimension: FtsDimensionEvidence(
        rawMismatch &&
                dimension == FtsDimension.boundedRawMatchCorpusEquivalence
            ? FtsTruth.falseValue
            : FtsTruth.trueValue,
        rawMismatch &&
                dimension == FtsDimension.boundedRawMatchCorpusEquivalence
            ? FtsReason.mismatch
            : FtsReason.equal,
        assessed: true,
      ),
    FtsDimension.qualifiedInternalIndexEvidence: const FtsDimensionEvidence(
      FtsTruth.unknown,
      FtsReason.unqualifiedInternalInspection,
      assessed: false,
    ),
    FtsDimension.exhaustiveFtsSemanticEquivalence: const FtsDimensionEvidence(
      FtsTruth.unknown,
      FtsReason.finiteCorpusOnly,
      assessed: false,
    ),
  },
  expectedBinding: null,
  observedBinding: null,
  expectedRuntime: null,
  observedRuntime: null,
  corpusIdentity: 'synthetic-characterization-only',
  diagnostics: const [],
  diagnosticCount: 0,
);

Future<CoherentReconstructionObservationResult> _observe(
  _Payload payload, {
  bool contradiction = false,
  bool Function()? cancelled,
  Duration Function()? clock,
  Future<void> Function()? close,
}) =>
    CoherentPopulatedReconstructionObservationEnvelope(
      limits: const ReconstructionObservationLimits(
        deadline: Duration(seconds: 5),
        maximumRows: 128,
        maximumBytes: 262144,
        maximumMemoryBytes: 262144,
        maximumDiskBytes: 33554432,
        maximumDiagnostics: 32,
      ),
      clock: clock ?? () => Duration.zero,
      isCancelled: cancelled ?? () => false,
    ).observe(
      createAttempt: (number, context) async =>
          ReconstructionObservationAttempt(
            readFingerprint: (context) async =>
                ReconstructionObservationFingerprint(
                  archiveInstanceUuid: 'synthetic',
                  canonicalRoot: 'synthetic',
                  markerIdentity: 'synthetic',
                  locationGeneration: 1,
                  sourceOccurrencesIdentity: 'synthetic',
                  sourceRegistryIdentity: 'synthetic',
                  ledgerIdentity: 'synthetic',
                  graphIdentity: 'synthetic',
                  overlayIdentity: 'synthetic',
                  presenceIdentity: 'synthetic',
                  journalsReceiptsAndOperationsIdentity: 'synthetic',
                  implementationIdentity: 'synthetic',
                  runtimeIdentity: 'synthetic',
                ),
            phaseReaders: [
              ReconstructionObservationPhaseReader(
                phase: ReconstructionObservationPhase.graph,
                read: (context) async => contradiction
                    ? ReconstructionPhaseEvidence.known(
                        payload: payload,
                        isTrue: false,
                      )
                    : ReconstructionPhaseEvidence.unknown(
                        phase: ReconstructionObservationPhase.graph,
                        reason: ReconstructionObservationUnknownReason
                            .missingEvidence,
                        payload: payload,
                      ),
              ),
            ],
            close: close ?? () async {},
          ),
    );
```

FTS EVIDENCE-LEVEL QUALIFICATION CHECKPOINTED: YES

SIX FTS DIMENSIONS PRESERVED WITHOUT PROOF-LEVEL PROMOTION: YES

COHERENT INTERVAL REJECTION DISCARDS ALL FTS PHASE EVIDENCE: NO

KNOWN CONTRADICTIONS FROM ACCEPTED INTERVALS RETAINED: YES

ACTUAL READ-ONLY FTS OBSERVATION INTEGRATED WITH COHERENT ENVELOPE: NO

INTERNAL AND EXHAUSTIVE FTS EQUIVALENCE REMAIN UNASSESSED UNKNOWN: YES

NO FTS OR OBSERVATION EVIDENCE GRANTS DESTRUCTIVE AUTHORITY: YES

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: FAIL

READY FOR NEXT SEPARATE EVIDENCE MILESTONE: NO

READY TO RESUME DESTRUCTIVE STAGE 2C: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
