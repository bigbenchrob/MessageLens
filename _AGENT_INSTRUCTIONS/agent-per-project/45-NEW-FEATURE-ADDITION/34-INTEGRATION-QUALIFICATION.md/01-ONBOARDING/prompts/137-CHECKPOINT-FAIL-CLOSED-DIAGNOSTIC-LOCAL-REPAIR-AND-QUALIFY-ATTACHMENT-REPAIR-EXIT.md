# MessageLens — Feature 34
## Prompt 137 — Checkpoint Diagnostic/Local Repair Exit Qualification and Qualify Attachment Archive Repair Drain and Fail-Closed Exit

**Task:** Characterization-first, finite Attachment Archive Repair lifecycle qualification and narrowly scoped correction if warranted. **Not:** production relaunch/activation, native process changes, attachment migration/repair execution, Operating Session listener modification, reconstruction witness, or broader shutdown redesign.

### 0. Goal, provenance and STOP rules

Response 136 reports PASS for Diagnostic Review and Local Data Repair's actual registered exit listeners. Those two listeners now await their captured coordinator drains and return `AppExitResponse.cancel` on synchronous/asynchronous refusal/failure; its implementation checkpoint is `ab013750491fb9ddf5208446ee8367f388882912`. Data Update, Source Access Repair, and Onboarding had been independently qualified earlier. **Attachment Archive Repair and Operating Session are the only remaining listener boundaries not qualified for failure-to-cancel.** This prompt addresses **Attachment Archive Repair alone**.

The lesson from stopped Prompts 128, 132 and 134 is binding: **a successful `stopAndDrain()` must genuinely establish settlement of every admitted owner flight** before host-level error translation can be considered sufficient. In this prompt, characterize Attachment Archive Repair's active and queued inspection, preservation, check, retry, stale-assessment and restart continuations before adding a listener catch. The present source reportedly has `_activeRun`, `stopAndDrain`, an executor `stopAndDrain`, `_restartForFreshAssessment`, and stale/retry paths; verify exact names and ownership in HEAD rather than assuming any claim implies runtime correctness.

One task, one selected coordinator, no coordinator-to-coordinator handoff. Semantics remain **coordinator completion → process exit → fresh launch → independent AppCzar reassessment**. The restarter is an injected inert port in tests; its completion never establishes a new PID or fresh admission. Production AppCzar activation must remain unconditionally OFF.

**Fair Witness and STOP:** Clearly separate source assertions, executable tests, synthetic fault injection and remaining UNKNOWNs. STOP if an unsafe owner gap cannot be corrected inside the exact Attachment-only allowlist below; if a new mutation capability, archive writer, generic shutdown authority, public test forge, other jurisdiction change or uncontrolled external operation would be required; if a real owner returns successful drain while tracked work is pending and that is left uncorrected; or if required architecture/analyzer/conformance gates fail. Do not commit a success checkpoint on STOP. An out-of-scope failing test must be preserved, not suppressed, relabelled PASS or compensated for only with an exit-listener catch.

### 1. Recover exact Git and documentation disposition

1. Inspect branch, HEAD, upstream, index, tracked changes, registered worktrees, submodule and tracked/untracked path hashes before touching files. Expected branch is `fix/onboarding-import-stuck-state`; previous root identity is not authorization to infer current state. There should be one worktree on this branch and a clean shared-instructions submodule historically at `95326f515ef4719f155ce6e223990398daad6311` — verify all of it. Preserve the other three worktrees.
2. Verify exact implementation ancestry for Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`, Onboarding `8e10bd58537f5fa2f409b3c69e16a805be8b12b2`, Local Repair `891ae8483a8a463e895cf656924226268d758b0b`, Diagnostic `35fab08a77c5f872acfd1afe84cee1777e62c5bc`, and Response 136 source `ab013750491fb9ddf5208446ee8367f388882912`. Verify exact Stage 1/2 and recent controller/host bytes against existing provenance when possible; do not claim a fresh behavioral requalification from hash equality.
3. Inspect the exact Prompt/Response 136 documents. If already checkpointed, verify their ancestry and avoid duplication. If both complete and untracked, stage ONLY that pair and make a separate documentation checkpoint, whitespace-check and push normally before implementation. Unexpected modifications or a dirty tracked baseline not explained by approved task material cause STOP.
4. Preserve the Onboarding navigation README, restored historical documents, three `_ARCHIVED` backup scripts, all unrelated untracked files and existing screenshots/configuration. No `git clean`, stash, hard reset, broad staging, branch switching, force push or unrelated documentation moves.
5. Read current repository/global instructions, Feature 34's canonical `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`, Response 136 and relevant Responses 122, 126, 128, 132, 133, 134 and 135; read the actual Attachment Archive Repair controller, executor, provider, harness, tests, and pre-existing specialist host contracts.

### 2. Exact source/test allowlist

Existing handwritten Dart files, **only as needed to implement and qualify this one selected owner**:

1. `lib/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller.dart`
2. `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`
3. `test/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller_test.dart`
4. `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`
5. `test/architecture/app_czar_architecture_test.dart` — only relevant Attachment exit owner/host assertions; no weakening of six-specialist/one-Operating census or other host constraints.

The only permitted generated companion, **if** the normal generator produces a changed hash due to an authorized annotated source edit, is:

6. `lib/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller.g.dart`.

Before editing, verify every listed path and relevant declaration actually exists. If a necessary path is absent or an extra file is required, STOP and request amended scope. No hand-editing generated code; normal filtered generation only, with exact byte/diff inspection.

Documentation-only paths in the established Feature 34 `01-ONBOARDING/prompts/` and `responses/` folders: exact Prompt/Response 136 prerequisite if untracked and exact Prompt/Response 137 completion/STOP pair. No other documentation modifications.

**Read-only**: Attachment repair executor/factory, archive mutation coordinator, import/graph/overlay/Presence stores, preservation writers, native Runner, restarter/provider/port, all other six controllers, Operating app/currentness, main/selector/activation, Stage 1/2 reset code, archive repair UI, schema, generated outputs outside the one companion, dependencies, entitlements, signing/release metadata, FTS and populated reconstruction helpers.

### 3. Pre-edit owner-flight and return-path audit — executable characterization

Trace the exact Attachment Archive Repair `build()`, auto-inspection and executor construction, explicit preservation/check action, retry, stale-assessment/restart, cancellation, disposal, and `stopAndDrain()` paths. Prepare a concise owner-flight matrix in the response: trigger; admitted work future; executor/worker/capability owner; wait/cleanup boundary; whether a restart is nested inside `_activeRun`; whether repeated requests coalesce; whether a call after permanent sealing can invoke a port or publish UI.

Use existing injected fake executor/restarter/assessment seams; do not execute the real archive-preservation executor or acquire `attachmentReconciliation` Ball, native archive authority, writable root or payload access. Confirm the fake overrides are installed **before** constructing the selected controller/harness. Test selected actual presentation and registered exit callback, not merely copying callback code. If an existing test would invoke real archive readers/writers, do not run it; instead use safely identified inert selections.

Characterize and, if necessary, encode expected-red tests for:

- Selected build's scheduled/active inspection; stop during pending inspection and executor construction, before and after its scheduler microtask.
- Explicit preservation/check actions, including pending executor batch and completion/failure, plus the precise meaning of executor `stopAndDrain()`; no superficial UI-state-as-settlement.
- A real stale-assessment change that queues restart while inspection/preservation is pending; ordinary stop must revoke queued intent and must not spawn a restart after work settles.
- **Both** ordinary and reentrant paths when the restarter is synchronously invoked from within the owner's restart flow. A restarter reentering `stopAndDrain()` must not receive false success or recursively await itself. If restart already active, a typed refusal such as `StateError` is valid; cancelable exit must then return `cancel`.
- Explicit retry/restart and duplicate request paths, including a restart port suspended before returning and another ordinary quit request racing it.
- Pending exception, stale callback, disposal, archive-binding change, source/volume unavailable or UNKNOWN evidence: never reclassify as empty/correct, silently restart, or publish after sealing.
- Repeated exit requests and listener unmount: no additional owner/provider construction and no lingering listener.

**STOP gate before listener-only modification:** If actual owner `stopAndDrain()` succeeds with any admitted work pending, correct **only this Attachment controller** inside the authorized allowlist, characterize red-before/green-after, and preserve the executor's existing admission/preservation rules. If that correction needs executor or another owner edit, STOP rather than masking it with catch-to-cancel. If the current owner is already complete and cannot falsely succeed, leave it unchanged. Do not demand modification as a ritual.

Record counts, real observed results, limitations and the exact cause of any expected red. Do not mistake a source-only assertion or injected drain throw for proof of actual owner-flight settlement.

### 4. Attachment Archive Repair owner contract, if correction is required

- One source of truth for scheduled/active inspection, preservation/executor drain, controller work, queued restart intent and active restart; record or retain every admitted flight before an asynchronous port can reenter. Avoid a new generic lifecycle manager.
- `stopAndDrain()` must synchronously seal new work before awaiting anything, revoke queued restart on ordinary shutdown, await truly admitted non-restart work and executor settlement, and never report success while an active restart or preservation remains unsettled. **Do not await a restart which may itself be calling drain**; explicit refusal on active restart is preferable to self-await.
- The executor must retain sole authority over its in-flight preservation batch; controller drainage awaits the existing executor's actual settlement. Do not broaden archive location admission, batch authorization, mutation callback, overwrite/delete policy or permissions.
- Restart dispatch (fresh assessment) must occur only from the existing qualified trigger after prior owned work settles, with a post-wait admission/binding check. A pending queued restart is revoked by ordinary stop. If a restart is already active, stop refuses without claiming its completion. Later drain may succeed only after actual settlement and absent retained failure.
- Preserve existing state machine, human action semantics and restart error reporting. Retain failures admitted before stop without stale UI publication; suppress late error/success/assessment callbacks after sealing. Disposal is not an awaited drain. No hidden timeout converts pending work into success.
- Preserve the seven jurisdictions, one currentness owner, mutation boundaries, real preservation semantics and all current archive-protection rules. Do not create a new reset/start-fresh route or an eighth jurisdiction.

### 5. Actual registered Attachment exit listener

Only after the owner-flight prerequisites are satisfied, modify **the Attachment Archive Repair host alone** in `app_czar_startup_harness.dart` to mirror the qualified Diagnostic/Local Repair/Onboarding host pattern:

- Capture the **already-selected notifier's** `stopAndDrain` at host initialization. Never resolve another controller at exit time; mounting the host must not trigger unrelated work or construct a replacement owner.
- Await the captured drain. Return `AppExitResponse.exit` only on fully successful settlement; catch both synchronous and asynchronous drain failures/refusals and return `AppExitResponse.cancel`. Do not suppress original controller errors in its own state/reporting; the host only translates to exit permission/refusal.
- Pending work keeps the exit request pending; active-restart refusal promptly returns `cancel`, not `exit`, a thrown callback or an inferred native process death.
- One listener per mounted host; disposal removes it; repeated requests do not create another controller, executor, native port or listener. All non-Attachment branch bytes remain unchanged, including the separate Operating exit listener.
- At least one focused case must use **the real selected Attachment controller with inert executor/restarter** and the actual `tester.binding.handleRequestAppExit()` callback. Injected throw-only subclasses may supplement, not replace, this evidence.

### 6. Mandatory adversarial qualification and limits

Use controlled Completers/barriers, deterministic counters and explicit cleanup; no new sleeps or timers to infer causality. Qualification must distinguish:

- genuine pending preservation/inspection from source/volume UNKNOWN;
- pending controller work from pending restart, and queued from active restart;
- successful drain from a thrown drain and a drain that truthfully refuses active restart;
- native exit permission from native process death (the latter is **not** tested);
- synthetic port completion from actual external archive preservation.

Assert zero real mutation capability, no writable-root lease, no payload read/overwrite/deletion, no actual Flutter app exit or OS launch, no FDA/Settings access and no native/signed target. In all tests release every admitted fake future, await cleanup, dispose containers/listeners and verify no future still belongs to the fixture. Do not call real executor operations even with an empty batch. The exact tests must include stopped source/binding cases, settled/error cases, duplicate events, a restarter reentering drain, and repeated exit requests.

If the owner has a source-grounded unfixable gap under this finite allowlist, STOP and preserve the reproducer. Do not add a try/catch and claim completion.

### 7. Validation and Project Conformance gates

Run attributable commands (record exit codes and counts) for:

1. Full focused Attachment Archive Repair controller and startup-harness test files.
2. Screened related Attachment presentation/executor **test cases only if inert**, plus Diagnostic, Local Repair, Onboarding, Data Update, Source Access and Operating presentation/controller tests whose selected fixtures do not acquire real tenure. Record screened exclusions by exact test name when relevant.
3. Complete `test/architecture` suite if its actual tests remain source/AST and disposable safe; preserve its six specialist + one Operating host census; strengthen exact Attachment capture/await/cancel/dispose tests, not just counts.
4. Full `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed`, normal filtered build_runner only for the permitted generated companion if needed, `git diff --check` and staged whitespace checks.
5. Exact changed-file allowlist, source/test/generated SHA-256 preservation for every other tracked file and all unrelated untracked files, clean submodule and correct Git upstream state.

Do not count a sandbox SDK-cache error, interrupted process, obsolete historical result or synthetic fixture failure as a PASS. Do not run the whole Flutter suite or real archive/tenure tests merely for convenience. Project Conformance PASS requires `BLOCKER: 0`, `SHOULD FIX: 0` in this Attachment-only scope; it must **not** be misrepresented as a production AppCzar release/cutover PASS.

### 8. Checkpoints and Response 137

If and only if the full mandatory qualification passes, stage only the exact approved source/test/generated paths, whitespace-check, create one scoped implementation commit, normally push, then separately checkpoint exact Prompt/Response 137 as documents and push. If controller source needs no modification, do not include it just to match a proposed inventory. On STOP preserve recorded failures and any in-scope unstaged test/source work; no success checkpoint, no sweeping cleanup, no force push.

Response 137 must report actual baseline/HEAD/upstream, source versus executed findings, red-before/green-after cases, precise owner-flight and restart/stop precedence, actual registered callback observations, file/hashes, all test counts/exit statuses, reasoned exclusions, complete Project Conformance verdict, implementation/docs checkpoint IDs, and explicit limitations. Specifically include whether an active restart was refused rather than falsely drained; and whether a pending preservation batch was actually awaited. No user content in logs.

End with literal flags:

- `ATTACHMENT REPAIR OWNER COMPLETE DRAIN QUALIFIED: YES/NO`
- `ATTACHMENT REPAIR ACTIVE-RESTART REFUSAL/NO SELF-AWAIT: PASS/FAIL/NOT APPLICABLE`
- `ATTACHMENT REPAIR ACTUAL EXIT LISTENER FAILS CLOSED: YES/NO`
- `ATTACHMENT PRESERVATION AUTHORITY/BYTES CHANGED: NO` (otherwise STOP)
- `OPERATING EXIT LISTENER QUALIFIED HERE: NO`
- `SIX SPECIALIST / ONE OPERATING HOSTS PRESERVED: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `REAL PRODUCTION FRESH LAUNCH/ADMISSION IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE (ATTACHMENT EXIT SCOPE): PASS/FAIL`
- `READY FOR SEPARATE PROMPT 138: YES/NO`

**STOP at this Attachment-only milestone.** Do not modify Operating Session, implement a launcher, terminate/relaunch an application, activate production, access live data, or reopen populated reconstruction/FTS.
