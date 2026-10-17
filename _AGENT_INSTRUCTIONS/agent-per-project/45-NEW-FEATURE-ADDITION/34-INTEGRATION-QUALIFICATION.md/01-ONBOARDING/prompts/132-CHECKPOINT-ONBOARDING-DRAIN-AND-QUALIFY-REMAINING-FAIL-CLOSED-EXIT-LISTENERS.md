# MessageLens — Feature 34
## Prompt 132 — Checkpoint Qualified Onboarding Drain and Qualify the Four Remaining Fail-Closed Exit Listeners

**Task type:** Narrow, characterization-first lifecycle correction. Complete the *remaining* Prompt 128 exit-listener obligations, now that Response 131 has qualified the Onboarding owner and its exit listener. **Not** a native fresh launcher, production activation, process exit, coordinator handoff, controller redesign, database repair, or reconstruction-witness milestone.

### 0. Decision, facts, and absolute boundaries

Response 131 reports **PASS** for Onboarding Settings ownership, queued-restart suppression, active-restart refusal without self-await, and explicit cancellation on Onboarding drain failure. The five original red cases are green. Its implementation source checkpoint is `8e10bd58537f5fa2f409b3c69e16a805be8b12b2` (verify ancestry and actual HEAD). Focused 55, selected regression 51, architecture 644, analyzer clean and bounded Project Conformance PASS are **historical reports**, not tests freshly run under this prompt.

The only intended remaining Prompt 128 gap is that these **four** exit callbacks currently await drains without a qualified exception-to-cancel boundary:

1. **Diagnostic Review** — `app_czar_startup_harness.dart`.
2. **Local Data Repair** — `app_czar_startup_harness.dart`.
3. **Attachment Archive Repair** — `app_czar_startup_harness.dart`.
4. **Operating Session** — `app_czar_operating_session_app.dart`, independently of the six specialist hosts.

**Do not modify** the previously qualified Data Update, Source Access Repair, or Onboarding controller/host branches, except the minimum shared harness changes required for these exact three other hosts. Do not alter their ownership or tests merely to make the suite pass. Six specialist listeners plus one separately owned Operating listener must remain.

**Original architecture:** A coordinator completes its jurisdictional work; the application exits; a fresh process independently admits its root and AppCzar reassesses. There is **no coordinator-to-coordinator transfer of state, authority, or work**. An AppExitResponse is a *permission/refusal*, not native process death. A new process can never be inferred from a Dart in-process assessment generation or fake restarter completion.

**Absolute prohibitions:** No production AppCzar activation; no process launch/exit; no native Runner/Swift/Objective-C changes; no real Messages/Contacts or any installed/development MessageLens databases; no admitted WD/Toshiba roots, attachment payloads, permission/FDA/TCC/bookmark operations, signing, AWS, migration, import, reset, actual graph/update worker, archive mutation Ball/tenure/lease, or FTS/populated reconstruction work. All executable tests must override dangerous ports **before** constructing a selected controller, host, or assessment. Do not run destructive/real-tenure tests merely because their filenames sound relevant.

**Fair Witness:** Characterization, source inspection, simulated fault, measured executable behavior, and production-runtime UNKNOWN are separate. If source already guarantees an obligation, report it rather than editing to duplicate. If *any* remaining owner's successful `stopAndDrain` can conceal admitted unfinished work, **STOP before adding a catch**. This is an owner defect outside this allowlist; do not conceal it under a listener fix. Never interpret a thrown drain, unknown settlement, missing owner or active restart as exit permission.

### 1. Git recovery and prerequisite checkpoint

1. Verify repo `/Users/rob/Development/FlutterProjects/remember_every_text`, branch `fix/onboarding-import-stuck-state`, HEAD and upstream (do not assume HEAD), tracked/index state, the four registered worktrees, shared instruction submodule (historically clean at `95326f515ef4719f155ce6e223990398daad6311`), and a full tracked/untracked SHA-256 baseline. Preserve the Onboarding README, restored historical docs, three `_ARCHIVED` backup scripts, and all unrelated untracked paths. No sweep-stage, `git clean`, stash, hard reset, rebase, force push, or mutation of other worktrees.
2. Verify the source commit `8e10bd58537f5fa2f409b3c69e16a805be8b12b2` and the unchanged Stage 1 (`e21334de96c2ab1484acbb8f3378ccad2cc49972`), Stage 2 (`daac3e6b54812c98d56dba7eb3ea8fb8f8296798`), Data Update (`a90612830fac05d79fff5d6097c2b0d35dd23b6e`), Source Access (`5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`) and disposable-exit-observer (`c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`) ancestors. Preserve their authoritative source/test boundaries.
3. Check disposition of **exact Prompt 131 and Response 131** in Feature 34 `01-ONBOARDING/prompts/` and `responses/`. If already checkpointed, verify the docs commit/ancestry; do not duplicate it. If still untracked, complete, and identical to the reviewed files, stage **only that exact pair**, whitespace-check, commit documentation separately, and push normally before implementation. If contents unexpectedly differ, stop/reconcile first.
4. Read source and tests for the four affected listener branches, the three qualified specialist listener branches, the seven AppCzar controller drain owners, `AppLifecycleListener`/Flutter exit semantics, relevant architecture tests and the Feature 34 `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`. Inspect source under the verified HEAD, not a historical line number alone.

### 2. Exact implementation allowlist

Only these **five existing handwritten files** may change:

- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` — fail-closed response for **Diagnostic Review, Local Data Repair, Attachment Archive Repair** only.
- `lib/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart` — fail-closed response for the **separate Operating Session** listener only.
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` — actual registered specialist listener qualification, preserving the Onboarding/Data Update/Source Access cases.
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart` — actual Operating listener qualification with inert session/currentness port.
- `test/architecture/app_czar_architecture_test.dart` — **only if necessary** to strengthen exact six-plus-one listener guard/catch ownership; no assertion weakening or broad architecture exception.

These are named existing paths based on the recent audits; **verify they exist**. If Operating test coverage actually lives elsewhere, STOP and request a specific allowlist amendment instead of creating a substitute or editing another file.

No other handwritten code, new helper, generated output, dependency, provider, controller, domain type, state enum, general exit coordinator, native file, restarter port, schema, release metadata or architecture-exemption edit is authorized. If generated code or extra source/test changes are required, STOP and report their exact paths. Documentation-only exceptions: Prompt/Response 131 prerequisite pair and exact Prompt/Response 132 at the established Feature 34 `01-ONBOARDING/` paths, each with a separate docs checkpoint as prescribed below.

### 3. Characterization before edits — inspect each owner, then test the actual callback

For **each** of the four target listeners, before touching production source:

1. Establish its *actual selected notifier/controller* and what `stopAndDrain()` awaits. Distinguish admitted work from restart-owned work, awaiting a self-invoking restarter, and ordinary producer disposal. Confirm that a **successful** drain does not knowingly conceal a still-running source, writer, Settings, preservation, callback or restart. Use current source and, where safe, existing inert controller tests. If a positive successful-but-incomplete counterexample is discovered, **STOP**, document it and leave host unchanged. Do not repeat the Prompt 128/129 owner-omission mistake.
2. Inspect whether the listener currently retains a selected controller at mount or reads its provider on exit. Establish whether the existing reference is the exact owner or whether an exit-time read can construct a different owner. Preserve existing owner semantics unless the minimal correction is provably within scope. Never add an automatic worker construction just for a listener test.
3. Add focused deterministic tests in the permitted test file(s) that call **the actual registered exit callback** (`tester.binding.handleRequestAppExit()` or the source-verified equivalent), not a copied callback or a fake function claimed to be production. Inject a controlled drain that throws synchronously and completes its Future with an error, and verify the current pre-edit outcome is not a qualified `AppExitResponse.cancel`. Record attributable red characterization. The synthetic exception is a fault injection, not proof a real archive worker throws in a particular way.
4. Also characterize a pending drain: exit permission must stay pending while the controlled drain is unresolved. Once it settles successfully, exit permission may be returned. Ensure no wall-clock sleeps and no real worker/native exit. Capture callback registration/disposal and listener counts when the existing harness permits.
5. Compare with existing qualified Data Update, Source Access and Onboarding listener assertions; their prior contracts are regression obligations, not targets for reimplementation. Read the Flutter/AppKit source behaviour as a reason to require explicit cancellation; do not infer the framework converts all callback exceptions to cancel.

If a necessary controller cannot be safely isolated through an existing override and inert fake within these exact files, STOP. Do not call its real selected auto-executing controller to force a passing test.

### 4. Minimal fail-closed listener correction

Only after characterization validates the owner contract, update the **four target callbacks** so that:

- They await the exact owning controller's successful drain before returning `AppExitResponse.exit`.
- A synchronous throw or awaited drain error returns `AppExitResponse.cancel` and **does not escape** the callback. No user content or exception payload is logged by this new boundary. Catch broadly enough (`Object`) to account for genuinely asynchronous Dart failures but do not swallow/cancel the owner error inside the controller or rewrite its state machine.
- A pending/never-settling drain yields **no positive exit permission**. There is no new production timeout, fake cancellation, `Future.timeout` result treated as worker quiescence, forced termination or speculative retry.
- Repeated pending exit requests do not construct new controllers, trigger duplicate worker admissions, register extra listeners, or turn refusal into success. Keep the exact existing listener lifecycle and disposal; no second status host or ambient monitor.
- A missing/disposed/invalid selected owner must never become permission to exit by falling back to a different controller, `StartupApp`, or a synthetic completed future. If existing APIs cannot make that distinction safely, STOP rather than introduce a new policy in the listener.
- In Operating, use the existing occurrence-specific `stopAndDrain`/currentness ownership; never treat `runAgain` as process exit. In Diagnostic, Local Repair and Attachment Repair preserve their existing automatic/executable work and specialist authority rules. A controller that intentionally refuses due to active restart must remain a **refusal**, not a resolved 'drain success'.
- Leave Data Update, Source Access, and Onboarding branches byte-identical outside explicitly shared syntax necessary for the four corrections. The production selected-composition and reset-denial gates remain unchanged. Seven jurisdictions remain exactly seven.

Prefer existing concise host patterns. Do not create a shared abstraction merely to avoid three local `try/catch` statements.

### 5. Mandatory adversarial qualification matrix

Use only controlled Completers, fake selected owners and inert port overrides, all installed **before** host/controller construction. For each target listener, qualify:

1. A pending drain blocks exit; completion permits exit.
2. Synchronous exception and asynchronous failed Future each return **cancel**, without an escaped exception or false `exit`.
3. A simulated owner refusal/active-restart `StateError` becomes **cancel**, not quiescence.
4. Repeated requests and host unmount/replacement do not create duplicate listeners or a fresh unrelated controller. Verify the selected occurrence rather than relying on a provider's current value after selection changes.
5. Callback removal at disposal; stale callback cannot grant exit after host unmount. Dispose and release all controlled barriers before ending each test.
6. No native exit, database, archive, mutation authority, Settings operation or production restarter is reached by the test. Check construction/call counters.

Across hosts, run the relevant existing Data Update, Source Access, Onboarding and Operating listener regressions, including Onboarding's preserved five red→green scenarios where safe. Assert **exactly six** specialist listeners in `app_czar_startup_harness.dart` and **exactly one** separate Operating listener, with positive ownership/await-before-exit/catch/disposal assertions. If architecture source checks already enforce these, strengthen narrowly rather than duplicating the test. No architecture allowlist weakening.

If the owner-drain precondition turns out to be false for any target, STOP **before** making a superficial listener-only fix; preserve the reproducer and report the exact owner gap. Do not declare an otherwise 'green' listener test to be equivalent to full owner quiescence.

### 6. Validation, Project Conformance, and scoped checkpoints

Require actual attributable command results/exit statuses on the changed bytes:

- Focused `app_czar_startup_harness_test.dart` and `app_czar_operating_session_app_test.dart`, with red-before/green-after evidence for each new failure-to-cancel case where possible.
- Screened relevant Diagnostic, Local Data Repair, Attachment Repair and Operating owner/presentation tests; do not run real-tenure or real worker/DB paths. Run qualified Data Update, Source Access and Onboarding controller/host regressions and startup-composition tests as applicable.
- The full `flutter test --no-pub test/architecture --reporter expanded` suite, screening architecture cases for real side effects before executing, and `flutter analyze --no-pub`.
- Targeted `dart format --output=none --set-exit-if-changed` for changed hand-authored files, `git diff --check`, `git diff --cached --check`, exact allowlist/staged hash manifest, preserved untracked/worktrees/submodule/Stage 1/2/probe hashes. No generated-code run is necessary unless a permitted annotation is changed (which this prompt does not authorize).

The full non-architecture Flutter suite is not required unless the canonical standard or a concrete regression demands it. SDK cache permission failures/interrupted processes do not count as validation. Do not broaden a test selection to unsafe authority-acquiring fixtures merely to increase test counts.

Conduct the canonical Project Conformance review. PASS requires `BLOCKER: 0`, `SHOULD FIX: 0` for this scope: actual selected-owner settlement, error-to-cancel, no duplicated listener/worker, exact six-plus-one host structure, preserved source boundaries, no stale callback publication, no alternate AppCzar evaluator, no reset authority expansion or real data access, no dependencies/generated churn. A discovered untracked work interval, unsafe provider construction, or failed mandatory gate is a **STOP** without a success implementation checkpoint.

After PASS, create a single implementation commit containing **exactly** the permitted changed production/test/architecture files; push normally. Checkpoint exact Prompt/Response 132 separately in a docs-only commit, push, and report its actual hash in the terminal Codex handoff (never guess a self-referential hash). If stopped, preserve changed tests as scoped unstaged evidence, produce a factual STOP Response 132 and do not commit success. Keep prior STOP histories intact. Never stage unrelated files.

### 7. Response 132 — required evidence and terminal flags

Report the verified starting HEAD/branch/upstream/submodule, all four worktrees, prerequisite 131 checkpoint, exact file/hashes, preserved untracked paths and source/ docs commits; current actual controller-drain ownership and positive/negative test observations for each of the four target hosts; synchronous versus asynchronous refusal; pending futures; repeated requests; ownership/disposal; six specialist and one Operating count; validation commands/counts/exits, architecture and analyzer, conformance, and all outstanding production-runtime unknowns.

Explicitly retain these limitations: **this does not implement** a production restarter, a LaunchServices call, real PID death or archive-lock release, installed app signing/FDA continuity, successor native/Dart admission, in-place data migrations/sidecar qualification, backup/rollback, or production activation. The disposable C/Python registered-exit observer remains an independent **qualified experiment**, not integrated production launch code. The populated reconstruction witness remains off the nondestructive cutover critical path.

End with literal flags:

- `DIAGNOSTIC EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `LOCAL DATA REPAIR EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `ATTACHMENT ARCHIVE REPAIR EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `OPERATING EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `ALL SIX SPECIALIST EXIT LISTENERS FAIL CLOSED: YES/NO`
- `OPERATING EXIT LISTENER FAILS CLOSED: YES/NO`
- `CONTROLLER DRAIN OWNERSHIP GAPS FOUND: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `REAL PRODUCTION FRESH LAUNCH IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR A SEPARATE PROMPT 133: YES/NO`

**STOP after this narrowly qualified listener milestone. Do not start native fresh-launch integration, another controller redesign, production activation or actual data operations under Prompt 132.**
