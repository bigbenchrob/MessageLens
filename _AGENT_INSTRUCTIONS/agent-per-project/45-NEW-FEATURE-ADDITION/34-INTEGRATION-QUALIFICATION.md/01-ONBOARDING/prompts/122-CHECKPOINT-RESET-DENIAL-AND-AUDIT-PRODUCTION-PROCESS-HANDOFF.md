# MessageLens — Feature 34
## Prompt 122 — Checkpoint Reset Denial and Audit Production Process Handoff

**Task:** Read-only, source-grounded production-cutover lifecycle audit. **Do not implement a restarter or activate production AppCzar.** This is a bounded decision and exact next-implementation plan, not another reconstruction-evidence milestone.

### 0. Goal and source of authority

Response 121 reports that Stage 2 reset denial qualified under its expressly amended contract, with source implementation checkpoint `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`. Preserve that result and its limits. Stage 1 reset-admission lifetime, selected-composition denial, command and service guards, and Local Data Repair invariants must remain untouched.

The next actual production blocker is the **process handoff**: an AppCzar jurisdiction may require the current process to stop and drain, exit, relaunch the correct signed production application, repeat native and Dart archive admission, and independently reassess in a new process. Development's `MacosDevelopmentProcessRestarter` and in-process navigation do not establish this production contract. Determine the smallest safe production implementation and its prerequisites from current source—not from assumed APIs or prior narrative.

**Non-goals:** no populated reconstruction witness or FTS work; no Start Fresh work; no activation toggle; no production launch, signed-app experiment, actual process exit, user permissions change, real databases, WD/Toshiba archive reads, attachment payload reads, cloud operations, code edits, generator, or runtime tests. No mutation capability, archive lease or Ball. This prompt authorizes repository/source/Git/documentation inspection only.

**Fair Witness:** distinguish verified source, historical qualification, proposed design and UNKNOWN. Do not infer real signed-runtime behavior from a development fixture. If a requirement cannot be grounded, STOP and identify the absent seam rather than producing an overconfident implementation plan.

### 1. Baseline and prerequisite documentation

1. Verify branch, HEAD, upstream ahead/behind, clean tracked index/tree, four worktrees and the single active branch worktree, shared instructions submodule hash, and baseline tracked/untracked path/hash inventory. Do not assume the prior response's state is still current. No stash, reset, clean, branch switch, force push or sweeping staging.
2. Verify that the exact Prompt 121 and Response 121 documents have been separately checkpointed from the Stage 2 source change. If they are complete but untracked, checkpoint **only that exact documentation pair** and normally push before the audit; if already committed, verify ancestry and do not duplicate. If unexpected differences arise, STOP. Preserve the onboarding README, historical document paths, archived scripts and all unrelated material.
3. Verify Stage 1 commit `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Stage 2 commit `daac3e6b54812c98d56dba7eb3ea8fb8f8296798` in ancestry. Confirm `ProductionAppCzarActivation` still unconditionally disabled and seven jurisdictions remain unchanged.
4. Inspect the canonical Project Conformance audit standard and current project/global instructions. Record any current source divergence instead of silently updating the narrative.

### 2. Trace the actual process and admission path

Perform a complete bounded source census of the **production and development** restarter contracts and consumers:

- `lib/main.dart`: native archive claim to Dart admission; production eligibility versus activation; final composition selection; root/provider lifetime; legacy StartupApp versus AppCzar harness selection.
- macOS Runner native startup and process-lock/admission code: signed identity, bundle/product constraints, canonical-root admission, single-instance lock and the timing/ownership of lock release.
- `app_czar_process_restarter_provider.dart`, `MacosDevelopmentProcessRestarter`, underlying port/interfaces and any existing production restarter implementation or stub. Verify imports and consumers from the current repository, not assumed filenames.
- Each coordinator and Operating Session path requesting restart: Data Update, Source Access Repair, Attachment Archive Repair, Onboarding, Local Data Repair, Diagnostic Review and Operating currentness. Distinguish automatic builds/reads from explicit human requests, all stop/drain operations, in-flight work ownership and process termination.
- Post-relaunch fresh assessment: native re-admission, Dart archive identity, new AppCzar evaluator generation, exact source/graph/archive binding, and no re-use of the old process's provider container or currentness occurrence.
- Legacy ambient chat monitor, window restoration, Settings reset and any process-shell fallback. The AppCzar selected shell must not re-enter generic legacy App or mount a second polling owner.

For every relevant method, report repository-relative file path and line number, exact inputs, side effects, await points, cancellation/timeout handling, failure outcomes, and what evidence proves old process termination versus simply requesting it. Identify any native-specific launch mechanisms and permissions implications without executing them.

### 3. Model the required lifecycle contract

Describe an exact, finite state machine or equivalent sequence for one jurisdiction handoff:

1. Current admitted process and jurisdiction owns a bounded occurrence.
2. Prevent new work; `stopAndDrain` existing currentness, import/preservation writers and other applicable flights with explicit success/timeout/UNKNOWN outcome.
3. Validate target launch identity using the existing admitted native identity and expected official production bundle, path and signature. Do not construct a target from ambient environment, development path or user-entered root.
4. Start a replacement in a way that cannot cause two active writers, including a coherent protocol for existing single-instance archive lock ownership. Explicitly address whether launch-before-exit, exit-before-launch, or an external launcher is necessary. **Do not invent a working protocol without source support.**
5. The old process actually terminates and relinquishes lock, including failure cases (launch failed, parent crashed, target refused, no permission, child launches before lock is released, duplicate process, wrong app).
6. The replacement independently completes native claim/signature/root validation, Dart archive admission and fresh AppCzar assessment. The same-PID/in-process route never counts as a restart.
7. Exactly one new currentness owner or selected specialist proceeds; no old-provider/epoch evidence or legacy monitor remains alive.

Spell out what is observable at each boundary and what remains UNKNOWN without a signed runtime/human rehearsal. Identify a finite refusal/reporting path for any incomplete proof. Do not use an ordinary `Future.timeout` to claim that a native process has stopped.

### 4. Jurisdiction and safety matrix

For **all seven jurisdictions**, tabulate: why a handoff is required; controller or executor initiating it; current process-owned work to drain; shared mutation authority (if any); expected restart target; preservation requirements; production-specific identity/permission concerns; current implementation state; and the minimal safe evidence/STOP gate. Include the distinct `localDataRepair` scoped partial-graph reset and the now-closed `startFresh`/`messageDataReset` AppCzar paths without reopening their code.

Explicitly distinguish:

- inability to access Messages / FDA from having a permission grant;
- evidence of relaunch request from evidence of old PID termination and new PID admission;
- a development restarter's success from production signed identity success;
- independently healthy existing data from unsupported schema/migration cases;
- onboarding/repair application writes from voluntary populated teardown;
- diagnostic nonmutating reporting from implicit repair or reset.

### 5. Choose one next implementation milestone, not an open-ended program

Review candidate approaches for production lifecycle composition (existing restarter extension, separate production implementation behind the same port, native host coordination, or necessary external launch support). Recommend **one** that actually respects lock ownership, identity, and the seven-jurisdiction handoffs. For rejected alternatives, give the concrete failure reason.

Specify one tightly bounded **Prompt 123** milestone with:

- exact existing/new handwritten file allowlist and generated file treatment, grounded in inspected source;
- characterization-first regressions and synthetic/inert process/launch/spawn/termination doubles, with no actual process exit and no real archive access;
- construction-time provider side-effect checks and same-process/double-writer/legacy-fallback adversarial scenarios;
- cleanup, rollback, no-launch, crash and timeout semantics, with explicit UNKNOWN where an OS outcome cannot be faked;
- a precise completion definition that advances actual production readiness rather than merely creating a new evidence framework;
- validation (focused relevant regressions, architecture, analyzer, format, exact diff and Project Conformance) and STOP gates;
- clear separation of subsequent signed/staged human qualification requiring independent approval.

If no safe finite implementation milestone is identifiable yet, recommend exactly **one narrow prerequisite** and explain why it blocks actual implementation. Do not repeat an architectural audit without resolving a specific missing port.

### 6. Required deliverable and checkpoints

Produce `responses/122-CHECKPOINT-RESET-DENIAL-AND-AUDIT-PRODUCTION-PROCESS-HANDOFF.md` under the existing Feature 34 `01-ONBOARDING` tree. Include: baseline/ancestry and exact document disposition; source-anchored graph; development-versus-production restarter comparison; old/new PID and native-lock race analysis; seven-jurisdiction table; candidate comparison; exactly one recommended Prompt 123; constraints/UNKNOWNs; canonical Project Conformance audit; final Git state and preservation.

Audit-only conformance PASS is separate from production readiness. Do not claim any test, app launch, native verification, signed identity qualification or real-data observation that did not occur. If completed and authorized by the established documentation workflow, checkpoint only Prompt/Response 122 together after writing, and normally push; do not embed an invented self-referential commit hash. Do not stage navigation/archived/unrelated files.

End with literal status flags:

- `STAGE 1 AND STAGE 2 RESET DENIAL CHECKPOINTED: YES/NO`
- `PRODUCTION PROCESS HANDOFF IMPLEMENTED: YES/NO`
- `DEVELOPMENT AND PRODUCTION RESTART CONTRACTS INVENTORIED: YES/NO`
- `SEVEN JURISDICTION LIFECYCLES MAPPED: YES/NO`
- `NEXT FINITE IMPLEMENTATION SCOPE IDENTIFIED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `POPULATED RECONSTRUCTION WITNESS REQUIRED FOR CUTOVER: NO (ARCHITECTURAL)`
- `PROJECT CONFORMANCE (AUDIT): PASS/FAIL`
- `READY FOR NARROW PROMPT 123: YES/NO`

**STOP after the audit. Do not start Prompt 123, activate production, or run any process handoff under Prompt 122.**
