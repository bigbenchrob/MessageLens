# MessageLens — Feature 34
## Prompt 109 — Checkpoint Coherent-Witness Audit and Qualify Bounded Observation Envelope

**Scope: test-only, disposable, bounded characterization and implementation. No production changes.**

### Objective
Implement exactly the narrow milestone selected by Response 108: a test-only coherent-observation envelope and stability classifier for disposable evidence readers. This is **not** a populated reconstruction witness, a reset policy, or cross-file atomicity. The envelope must never confer destructive eligibility.

### 1. Preflight and governing evidence
Work only in `/Users/rob/Development/FlutterProjects/remember_every_text`, branch `fix/onboarding-import-stuck-state`. Verify actual HEAD/upstream (`0/0` expected), clean tracked worktree/index, exactly one worktree on the branch, clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`, and a precise inventory of unrelated untracked files. Stop on a material discrepancy; do not clean, reset, or stage unrelated files.

Read global agent instructions, canonical Project Conformance standard, Prompt/Response 108, Responses 102–107, and current AppCzar assessment, source currentness, graph and ledger comparator implementations. Verify that Prompt 108 and Response 108 are already checkpointed and pushed; if not, checkpoint **only those two documents** and push before edits. Never duplicate an existing checkpoint. Record the resulting baseline.

### 2. Characterize current behavior before implementing
Through source inspection and narrowly scoped test characterization, establish these three facts without modifying production code:

- AppCzar assessment generation prevents stale assessment publication but does **not** provide a cross-store read transaction or coherent snapshot.
- The qualified test-only ledger and graph comparators compare already captured snapshots; neither establishes observation-interval stability.
- Existing two-sample Messages source checks are source-local, not an atomic observation of all stores.

If any fact is contradicted by current code, STOP with literal evidence rather than duplicating authority.

### 3. Exact authorized implementation files
Create **only**:

- `test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation.dart`
- `test/essentials/app_czar/application/reconstruction/coherent_populated_reconstruction_observation_test.dart`

The first file is a test-only, typed, immutable, capability-free observation contract and runner. The second qualifies it with deterministic fake readers and disposable resources. No `lib/`, schema, migration, generated, native, Rust, provider, package, release, AppCzar, archive, reset, or other test/helper file may change. If additional files are necessary, STOP and report.

### 4. Contract and semantics
Accept injected, bounded, capability-free callbacks for compact immutable **start and end** fingerprints and typed per-phase evidence. Represent the full binding: admitted archive UUID/root/marker/location generation; physical source occurrences and source registry; ledger; graph; overlay; Presence; journals/receipts/operations; and implementation/runtime identity. Do not hold live database handles, writer/root leases, mutation Balls, production coordinators, or policy objects.

One attempt captures a start fingerprint, observes all bounded phases, captures an end fingerprint, closes all owned resources, and accepts the interval only if identities and material fingerprints agree. Do **not** claim distributed snapshot atomicity. On the first mismatch, discard the complete attempt including callbacks/resources/evidence and retry **once** with a fresh observation. On a second mismatch return typed UNKNOWN. No stabilization loop.

A coherent, known material contradiction yields FALSE even if another domain is unknown, retaining both typed domain observations. A contradiction assembled from an unstable/mismatched attempt cannot yield FALSE; the attempt is UNKNOWN. TRUE at this test-only envelope level means only *coherent interval and qualified supplied phase evidence*, never full reconstruction equivalence or reset eligibility. Unknown/missing/unsupported evidence must not become zero or TRUE.

Represent missing evidence, instability, cancellation, deadline, row/byte/memory/disk/diagnostic limit, unsupported dependency, and ambiguous cleanup as distinct UNKNOWN reasons. Operational timestamp exemptions are admissible only after an injected lifecycle validator confirms the exact approved provenance contract.

### 5. Adversarial qualification matrix
Test all of the following with fixed deterministic fake monotonic time and **no wall-clock sleeps**:

1. Identical start/end fingerprints accept one interval.
2. First interval mismatch discards all evidence; a second fully fresh matching interval is accepted.
3. Two mismatches yield UNKNOWN after exactly two attempts.
4. Archive UUID, canonical root, marker, and location generation drift independently yield UNKNOWN.
5. Source occurrence, registry, ledger, graph, overlay, Presence, journals/receipts, and implementation identity drift independently yield UNKNOWN.
6. Stable coherent contradiction yields FALSE while other incomplete domains remain explicitly unknown.
7. Contradiction from a discarded interval never leaks into the accepted result or becomes FALSE.
8. Cancellation and deadline stop subsequent work, close owned resources, and yield UNKNOWN.
9. Row, byte, memory, disk, and diagnostic-budget failures fail closed.
10. Every owned fake resource closes **exactly once** on success, retry, failure, cancellation, and timeout; ambiguous cleanup never yields TRUE.
11. Operational timestamp exclusion is rejected without successful lifecycle validation.
12. No callback, resource, handle, or evidence from attempt one survives into attempt two.
13. Process at least **10,001 synthetic page records** with at most one bounded page and fixed-size fingerprint/diagnostic state retained; demonstrate boundedness rather than asserting it from small fixtures.
14. Failure or cancellation at each observation phase cannot skip cleanup or create a third attempt.

Use immutable typed results and deterministic diagnostic ordering. Preserve complete mismatch counts independently of bounded examples. Do not log synthetic content beyond necessary bounded diagnostics.

### 6. Validation
Run the focused tests, relevant AppCzar/reconstruction regressions, architecture forbidden-import suite, full `flutter analyze`, formatting and generated-source consistency checks, and working/staged diff checks. Run the full Flutter suite only if governing conformance instructions require it. Report exact commands, attributable pass/fail/skip counts, retries, and any unresolved limits. Audit Project Conformance for one evidence owner, no parallel evaluator/policy, no database writer or mutation authority, bounded work, deterministic cleanup, and exact two-file implementation scope. STOP on a blocker, should-fix that undermines the proof, or unexplained mismatch.

### 7. Git and documentation
First checkpoint Prompt 108/Response 108 only if necessary and explicitly permitted above. After complete validation and conformance, review and stage **only** the two authorized implementation/test files, commit and push normally if all gates pass. Then create Response 109 in Feature 34 `01-ONBOARDING/responses/` with the matching numbered descriptive filename, separately checkpoint Prompt 109/Response 109, and push. Preserve all unrelated untracked material; never force-push, squash, or silently alter a checkpoint. If repository instructions require a different sequencing, stop for reconciliation rather than improvise.

Response 109 must report baseline and exact commits, pre-edit characterization, model contract, complete adversarial matrix, memory/page/resource evidence, all validation, conformance findings, final Git state, and literal remaining limitations. End with:

```
COHERENT-OBSERVATION AUDIT CHECKPOINTED: YES / NO
TEST-ONLY BOUNDED OBSERVATION ENVELOPE QUALIFIED: YES / NO
TWO-ATTEMPT STABILITY AND DISCARD SEMANTICS: PASS / FAIL
FALSE AND UNKNOWN EVIDENCE SEMANTICS: PASS / FAIL
RESOURCE AND CLEANUP OWNERSHIP: PASS / FAIL
CROSS-FILE ATOMIC SNAPSHOT CLAIMED: NO
COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES / NO
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```

Then STOP. Do not begin another witness component, real-data qualification, or production change.
