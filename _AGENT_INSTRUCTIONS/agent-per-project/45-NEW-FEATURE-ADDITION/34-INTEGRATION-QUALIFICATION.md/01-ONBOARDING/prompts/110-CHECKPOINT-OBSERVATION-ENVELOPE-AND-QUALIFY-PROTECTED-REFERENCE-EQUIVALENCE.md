# MessageLens — Feature 34
## Prompt 110 — Checkpoint Observation Envelope and Qualify Protected-Reference Equivalence

**Authorization: test-only qualification. No production changes, live data, repair, reset, or cutover.**

### Objective

Response 109 qualified a bounded, two-attempt, test-only coherent-observation envelope. Responses 105–107 qualified disposable graph replay and schema-wide graph/ledger material comparison. This prompt characterizes whether *protected user-authored references* retain their exact intended targets across independently constructed, disposable observed and expected graphs. Equality of visible names or message text is not identity equivalence. This milestone must not claim complete populated reconstruction equivalence.

### 1. Preflight and checkpoint

Work in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`. Verify actual HEAD, upstream `0/0`, clean tracked worktree and index, one worktree on the branch, clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`, and inventory all untracked material. Confirm implementation commit `281d7e01161ac779f281c397bac5c626a9eb320b` is in ancestry. Determine whether Prompt 109/Response 109 documentation is already checkpointed and pushed; if so do not duplicate. If not, checkpoint and push **only** those records before edits, as authorized here. Preserve all unrelated untracked files. Stop on unexplained baseline changes.

Read the canonical project instructions, Project Conformance standard, Responses 102–109 (especially 104, 106, 108, 109), and inspect actual overlay schema v8, graph schema v3, source-scoped ledger schema v10, overlay compatibility readers, identity utilities, and relevant tests. Current source controls actual semantics. If the approved narrow test-only scope below is insufficient, stop for review rather than edit production code.

### 2. Pre-edit characterization and authoritative inventory

Before creating implementation, document the actual production overlay reference schema and lookup semantics. Inventory direct references, namespace constraints, fallback resolution, and overlay-local-only records. At minimum inspect `participant_overrides`, `chat_overrides`, `message_annotations`, `message_user_flags`, `message_user_tags`, `conversation_tag_assignments`, `handle_to_participant_overrides`, `favorite_contacts`, `handle_visibility_overrides`, `dismissed_handles`, `archived_attachments`, virtual participants, overlay settings and tags. Confirm which columns are truly direct graph keys versus GUIDs, normalized handles, overlay-local IDs, canonical conversation IDs, or compatibility tuples. Do not assume every numeric ID belongs to the same namespace.

Characterize existing production interpretation of unique message GUID fallbacks, canonical handle normalization/representative selection, virtual participant bridges, archived attachment `(message_guid, import_attachment_id)` compatibility, and live-only source occurrence restrictions. Record any ambiguity or unsupported semantic contract as UNKNOWN; do not invent a fallback rule.

### 3. Narrow implementation scope

Implement a **test-only** protected-reference equivalence reader/comparator and qualification tests under an existing appropriate `test/essentials/.../reconstruction/` location. Prefer exactly two new files: one helper and one test file. The helper may read **only caller-supplied disposable** production-schema overlay, graph and, where necessary, ledger databases. Reuse existing production read-only interpretation and canonical identity utilities where available; do not duplicate their semantics or add a parallel authority. No `lib/`, Rust, native, schema, migration, provider, generated, dependency, release, AppCzar, archive or reset changes.

If production overlay APIs cannot be safely instantiated with disposable paths or a required semantic resolver is inaccessible, stop and report the precise missing seam. Do not bypass it with guessed SQL semantics. Establish complete, schema-checked reference inventory before qualifying any comparison. The helper returns evidence only: matching, known coherent contradiction (FALSE), or incomplete/ambiguous (UNKNOWN). It cannot return reset eligibility or mutation authority.

### 4. Required synthetic qualification

Use small, fixed synthetic disposable databases with **independent expected and observed graph material**, exact source registry allocations, and protected overlay intent. Qualify:

1. All supported direct contact, chat, message, canonical handle and conversation references resolve to the same intended object in both graphs.
2. Missing expected target, extra or rebound target, and packed source-ID reallocation are visible as contradictions, not normalized away.
3. GUID fallback is accepted only under the production-defined unique-resolution scope; zero, multiple, historical/live collision, and changed target cases remain explicit.
4. Normalized handle fallback and canonical representative changes do not silently redirect authored intent.
5. Archived attachment compatibility binds GUID and unscoped attachment ROWID to the **admitted live source occurrence**, never an identically numbered historical attachment. Keep relationship provenance distinct from payload coverage.
6. Virtual participant and overlay-local tag IDs are not misinterpreted as graph keys; enforce explicit namespace rules.
7. Dangling overlay references and contradictory direct-versus-fallback evidence remain visible even if the rest of the graph compares equal.
8. Null/absent/ambiguous fields, unsupported overlay schema, unreadable required source, and unqualified production lookup semantics produce UNKNOWN rather than an invented target.
9. Test-only comparator diagnostics are deterministic, bounded and non-content-leaking; no protected row is modified or dropped.
10. All disposable database handles and directories are closed/deleted on success, failure and cancellation. No real root or archive path is opened.

Where the current production semantics establish a different literal outcome than the above suggested cases, preserve that outcome, report the conflict and stop before redefining it.

### 5. Evidence and architecture requirements

Explicitly distinguish: (a) overlay intent preserved byte-for-byte, (b) target identity equivalence, (c) unique compatibility resolution, (d) source-occurrence and historical provenance, and (e) attachment payload coverage. None implies the others. Prove both directions of reference resolution and report all known mismatches even when other domains are UNKNOWN. Do not claim coherent cross-store observation from this isolated test; Response 109's envelope remains a separate qualified test-only component.

Keep resource usage bounded: fixed synthetic fixture, explicit row/byte/diagnostic limits, and deterministic cleanup. No unbounded scans, no live source readers, no writable admitted root, no mutation Ball, no new AppCzar evaluator or coordinator.

### 6. Validation

Run focused qualification tests, relevant overlay/graph/source-ledger regressions, architecture/forbidden-import tests, full `flutter analyze`, formatting, generated-source consistency and Git diff checks. Run the full Flutter suite only if the canonical Project Conformance standard requires it for this test-only scope. Report exact attributable results, interruptions and retries without inferring success. Complete the canonical Project Conformance audit, including BLOCKER/SHOULD FIX counts. Stop on unqualified semantic resolution, unsafe dependency, parity contradiction, unbounded work or unauthorized file changes.

### 7. Git sequence and Response 110

If all gates pass, stage/commit/push only the authorized test helper and test file as a narrow implementation checkpoint. Then create `110-CHECKPOINT-OBSERVATION-ENVELOPE-AND-QUALIFY-PROTECTED-REFERENCE-EQUIVALENCE.md` in Feature 34 `01-ONBOARDING/responses/`; checkpoint Prompt 110/Response 110 separately as prescribed, without unrelated files. If any gate fails, preserve evidence and stop without a success checkpoint.

Response 110 must record baseline/checkpoints; exact schema and resolver inventory; pre-edit characterization; tested identity namespaces; direct/GUID/normalized/virtual/archived-attachment results; TRUE/FALSE/UNKNOWN semantics; source/graph/overlay isolation; resource and cleanup evidence; validation and conformance; exact files and Git state; and remaining FTS, coherent populated-source, production-scale and protected-operation gaps.

Conclude:

`OBSERVATION ENVELOPE CHECKPOINTED: YES / NO`

`PROTECTED-REFERENCE SCHEMA AND PRODUCTION RESOLUTION INVENTORIED: YES / NO`

`DISPOSABLE PROTECTED-REFERENCE EQUIVALENCE QUALIFIED: YES / NO`

`HISTORICAL/LIVE AND FALLBACK AMBIGUITY PRESERVED: YES / NO`

`OVERLAY USER INTENT MUTATED: NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not implement FTS qualification, a populated witness, or Start Fresh under this prompt.
