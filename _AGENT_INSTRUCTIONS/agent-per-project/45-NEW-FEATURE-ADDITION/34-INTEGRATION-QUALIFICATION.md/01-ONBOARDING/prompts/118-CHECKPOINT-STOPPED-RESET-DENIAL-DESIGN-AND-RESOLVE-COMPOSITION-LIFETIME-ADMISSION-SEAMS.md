# MessageLens — Feature 34 — Prompt 118
## Checkpoint stopped Prompt 117 and resolve composition lifetime, pre-tenure admission, and destructive-operation scope

**Mode: READ-ONLY, bounded architecture/design resolution. NO implementation and NO reset execution.**

### 0. Purpose and decision rule

Response 117 STOPPED correctly. Do not implement its candidate four-boundary sketch or present its eight-file impact inventory as an approved patch. The goal of this prompt is to settle **three finite design decisions** necessary to make the non-destructive AppCzar cutover safe:

1. A single explicit, process/container-lifetime selected-composition input that distinguishes **explicit legacy** from **missing/rejected/disposed** and revokes stale action/service instances.
2. A safe, production-path-faithful **pre-tenure** test seam proving denial of both direct and nested/reentrant reset admission *without creating an exclusive-authority Ball, lease or tenure*.
3. A clear destructive-operation scope: deny **`startFresh` and `messageDataReset`** for an AppCzar-selected composition (and any missing/rejected/disposed selection), retain **`localDataRepair` only under its unchanged exact gate**, and preserve explicitly selected legacy behavior only in its own valid, current composition. Verify from current source whether any additional operation or direct route makes this stated set incomplete; do not silently expand it.

The deliverable is a complete design with one **bounded, staged implementation recommendation** for Prompt 119 and exact anticipated file impact. This is not an excuse for an open-ended new safety framework. Prefer existing provider/authority/lifetime mechanisms; introduce a new contract only if the source proves it necessary. If these decisions cannot be settled safely from inspection, issue a factual STOP with the precise missing seam and a single smaller follow-up, not a speculative implementation plan.

### 1. Nonnegotiable restrictions

- **No production/test code edits**, generated file changes, dependencies, schema/migration changes, release or main app changes, and no app launch/build/test execution. Read-only source, Git, existing tests and documentation inspection only. No mutation Ball/lease/tenure, actual reset, live SQLite or source database, real archive/root, WD/Toshiba volume, native permissions, bookmark, FDA/TCC or S3 access.
- Production AppCzar activation remains unconditionally OFF. Do not change seven jurisdictions or introduce parallel assessment/evaluator/policy authority. Do not resume the populated reconstruction witness or Prompt 113 FTS binding.
- Keep Local Data Repair's existing safety reader, binding recheck, operation, and derived footprint **unchanged**. Never relabel a voluntary populated reset as local repair.
- No fallback into legacy from AppCzar, no hidden UI as an admission guard, no default missing selection to an allowed legacy state, no global mutable reset switch, no cached bool as sole lifetime evidence.
- **Fair Witness:** cite current functions, construction/await boundaries, current tests and exact source locations. Separate observed facts, inferences, proposals, unknowns. Do not claim a production gate exists before it is implemented or a test port is safe before its call path is traced.

### 2. Baseline, preservation and prerequisite checkpoint

1. Inspect branch, HEAD, upstream tracking, index/tree, four worktrees, submodule pin and all tracked/untracked changes. Response 117 reported HEAD `5120999325ab34fbca4ae47d58f022686923a0a3`, synchronized 0/0, shared submodule `95326f515ef4719f155ce6e223990398daad6311`, one Feature 34 branch worktree, 50 original untracked files including Prompt 117, and an untracked STOP Response 117. **Verify rather than assume.**
2. If Prompt 117 and Response 117 remain untracked and byte-complete, checkpoint **only that pair** as a distinct docs commit and push normally, if permitted by repository instructions. If already committed, verify and do not duplicate. If any unrelated dirty state, unexpected move or document conflict exists, STOP for review; no clean/stash/reset/squash/rebase/force push.
3. Preserve `01-ONBOARDING/README.md`, the three `_ARCHIVED` scripts and the prior 218 restored document paths unchanged and unstaged. Capture an independent hashes/paths manifest outside repo.
4. Read Prompt/Response 115–117, the earlier cutover audit Response 85 and extraction Responses 86–89 as necessary, the canonical Project Conformance standard, repository AGENTS and project architecture/inviolable rules. This audit must use current source as final authority.

### 3. Decision A — explicit composition and lifetime authority

Trace and compare existing startup composition evidence from:

- `lib/main.dart` final startup selection, root ProviderScope overrides and container/process lifetime;
- `startup_presentation_evidence_inputs.dart` raw selected-composition provider and generated shape; domain enum and display-only StartupSupportEvidence;
- `SidebarActionDispatcher`, advanced Start Fresh action factory and the plain action's `request`, `retry`, `dismissFailure`, async `_execute`;
- Start Fresh service factory including first await, all subsequent awaits and plain service `startFresh` pre-Ball reads;
- lower archive-mutation coordinator provider and its owner/container lifetime.

Propose **one** authoritative, minimal contract with explicit states (at least selected legacy, selected AppCzar, missing/unavailable, revoked/disposed) and immutable lifetime/epoch identity or a source-proven equivalent. Specify its single owner and how the exact selected startup composition is frozen for a live container. State precise behavior for never-overridden provider, provider throw/dispose, stale action/service object, await then revoke, replacement container selecting legacy again (ABA), and attempts to reuse an object created in a prior container. State which operations are allowed before and after each state transition. Distinguish denying *execution* from preventing already-completed construction; no false retroactive claims.

Evaluate at least two realistic minimal implementations: refining the existing raw provider input versus adding a single narrow authority input, including generated-code/test migration impacts and dependency cycle analysis. Pick one, or STOP with a specific irreducible unresolved dependency. Do **not** derive authorization from release eligibility, development flag, selected menu visibility, archive identity string, or display/support evidence.

### 4. Decision B — faithful no-tenure admission qualification

Trace `ArchiveMutationCoordinator.run`, `runWithCapability`, `_run`, private Zone read, registry `runReentrant`/`runExclusive`, `_runAdmittedArchiveScope` and capability minting; document the earliest *shared* gate that is executed **before either tenure branch**. Propose a minimal testable seam that executes **that same real production branch decision**, with inert continuation counters for both ordinary and reentrant candidate paths, but **cannot** mint a Ball, construct tenure, acquire writable lease, invoke a callback, or synthesize an admitted archive.

Do not call tests against a copied predicate qualification of the production gate. Do not use existing nested tests that acquire real tenure and then label them inert. Prefer a source-local, private/injected continuation seam if feasible without weakening actual authority encapsulation. Address production exposure/build-mode fences, test file placement, false admission, provider cycle, and avoiding a new lower policy owner. If a true nested production path cannot be exercised without a tenure, explicitly separate proof of *pre-branch denial* (possible with counters) from runtime nested-tenure behavior (still unqualified); do not claim the latter was executed. Explain whether the required acceptance goal can be proven from the shared gate path plus inert branch continuations or must be deferred.

### 5. Decision C — reset-operation scope and historical safety

Produce a complete *source-grounded* operation/entry-point matrix for:

- `ArchiveMutationOperation.startFresh`;
- `ArchiveMutationOperation.messageDataReset`, including Journey recovery/reimport and dev panel paths;
- `ArchiveMutationOperation.localDataRepair`;
- any other archive-operation or direct derived-store deletion caller identified by a bounded call-site search.

For each: identify provider construction, explicit/cached calls, callback boundaries, lower operation acquisition, current startup composition reachability and any independent specialist gate. State proposed handling for selected AppCzar, explicitly selected legacy, missing/revoked selection, and direct programmatic use. For AppCzar, **deny both startFresh and messageDataReset before lower tenure** unless a current production dependency proves an even stricter solution necessary. Do not automatically disable specialist operations unrelated to those reset semantics. Preserve localDataRepair unchanged; evaluate direct `message_data_reset_service` exposure without blocking its local-repair method.

Legacy operations must not become unintentionally available in an AppCzar occurrence via retained objects or fallback; if their continued legacy operation is not demonstrably safe, report that explicitly rather than weakening the AppCzar denial.

### 6. Produce a FINITE staged implementation plan, not code

Choose a maximum of **two implementation stages**. The first should target the smallest dependency-ordered seam needed to establish selection/lifetime and safe admission testability; the second should complete command/action/service/lower reset denial. You may recommend a different two-stage split if justified by exact construction dependencies. Each stage must include:

- exact **existing** source paths needing changes, plus exact generated paths if relevant and existing/new test paths (new names clearly labelled proposed);
- one owner per policy/lifetime fact; no duplicated allow/deny logic;
- an explicit red-before/green-after executable matrix using only inert spies, disposable synthetic evidence and no actual Ball;
- source-gated STOP cases and Project Conformance acceptance;
- a Git checkpoint plan separating implementation and documentation;
- proof that production AppCzar remains inactive;
- concrete *completion* and *non-goal* definitions that preclude sliding back into another open-ended witness project.

If stage one by itself does not close reset capability, require that any future AppCzar activation remains OFF; do not claim partial work is a safe cutover. If the complete change needs eight or more production files, identify them transparently. Do not arbitrarily force a four-file patch.

### 7. Validation for this audit and response format

No tests or analyzer expected: this is read-only design. Verify the precise Git baseline and unchanged manifest; do not imply historical tests were rerun. Apply the canonical Project Conformance audit to the **design completeness**: a STOP is correct if any of the three decisions remains unproven. A PASS here means a reviewable plan, **not** a safe active production build.

Create one response:
`01-ONBOARDING/responses/118-CHECKPOINT-STOPPED-RESET-DENIAL-DESIGN-AND-RESOLVE-COMPOSITION-LIFETIME-ADMISSION-SEAMS.md`.

Include (a) verified Git facts and Prompt/Response117 disposition; (b) selected composition/lifetime contract with ABA and async timeline; (c) direct/reentry safe admission seam and what it cannot prove; (d) complete reset-operation matrix with unchanged local repair; (e) exact two-stage path/test allowlists and red/green matrix; (f) design blockers and explicit next Prompt119 recommendation; (g) in-scope conformance, verification and preservation. Record any missing proof as UNKNOWN, not successful denial.

Checkpoint only the exact Prompt/Response118 pair separately *if* allowed and complete; no fabricated self-referential commit ID. End with:

- `EXPLICIT COMPOSITION/LIFETIME CONTRACT RESOLVED: YES/NO`
- `SAFE PRE-TENURE ADMISSION TEST SEAM RESOLVED: YES/NO`
- `STARTFRESH AND MESSAGEDATARESET SCOPE RESOLVED: YES/NO`
- `LOCAL DATA REPAIR CONTRACT UNCHANGED: YES/NO`
- `TWO-STAGE IMPLEMENTATION PLAN COMPLETE: YES/NO`
- `PRODUCTION START FRESH DENIAL IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `POPULATED RECONSTRUCTION WITNESS ON CUTOVER CRITICAL PATH: NO (architectural)`
- `PROJECT CONFORMANCE (DESIGN): PASS/FAIL`
- `READY FOR NARROW PROMPT 119: YES/NO`

**STOP. Do not implement either stage, run native tests or launch MessageLens under this prompt.**
