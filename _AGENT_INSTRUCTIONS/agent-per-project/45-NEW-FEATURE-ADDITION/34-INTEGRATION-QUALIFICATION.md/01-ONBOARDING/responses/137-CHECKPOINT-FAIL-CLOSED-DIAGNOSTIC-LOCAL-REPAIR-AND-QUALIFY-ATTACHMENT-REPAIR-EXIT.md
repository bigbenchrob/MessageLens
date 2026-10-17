# Response 137 — PASS: Attachment Repair ownership and fail-closed exit

## Result and limits

Attachment Archive Repair now owns scheduled construction/inspection, explicit preservation and check work, executor drainage, queued restart, active restart and ordinary stop. Ordinary stop seals admission synchronously, revokes queued restart, waits for admitted non-restart work and actual executor settlement, and refuses an active restart with `StateError` rather than awaiting its own caller. Later ordinary drain succeeds only after successful settlement with no retained failure. The actual registered Attachment host captures the selected notifier at initialization and translates drain failure/refusal into `AppExitResponse.cancel`.

This qualifies owner settlement and permission to exit using inert ports. It does not prove native process death, archive-lock release, a new PID, a signed launch target, independent next-process admission, or real preservation. Operating's listener remains unqualified here. Production activation remains OFF. No real executor operation, source/archive/database/payload access, mutation capability, writable-root lease, Ball, native launch/exit, FDA/Settings access, production build or cloud operation ran. All new behavioral fixtures install inert overrides before owner/host construction.

## Recovered checkpoint and preservation

Baseline branch `fix/onboarding-import-stuck-state`, HEAD `758dad01c99bb9c1542bf6ab884c1fdf2ca365a7`, upstream `0/0`, clean tracked tree and index. That commit already contains exact Prompt/Response 136, separately from its implementation `ab013750491fb9ddf5208446ee8367f388882912`; no duplicate prerequisite checkpoint was made.

Verified all eight required implementation ancestors:

- Stage 1: `e21334de96c2ab1484acbb8f3378ccad2cc49972`.
- Stage 2: `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`.
- Data Update: `a90612830fac05d79fff5d6097c2b0d35dd23b6e`.
- Source Access: `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`.
- Onboarding: `8e10bd58537f5fa2f409b3c69e16a805be8b12b2`.
- Local Repair: `891ae8483a8a463e895cf656924226268d758b0b`.
- Diagnostic: `35fab08a77c5f872acfd1afe84cee1777e62c5bc`.
- Qualified Diagnostic/Local hosts: `ab013750491fb9ddf5208446ee8367f388882912`.

The baseline matches all 17 Prompt 121 protected hashes, both Prompt 127 probe hashes, all three Local Repair owner/generated/controller-test hashes, all three Diagnostic owner/generated/controller-test hashes, and all three final Prompt 136 hashes. This is byte provenance, not a fresh behavioral qualification of those checkpoints.

`/private/tmp/prompt137-baseline.json` records 6,052 tracked regular files and 50 untracked files: this prompt plus 49 unrelated files. Full comparison preserves every baseline file outside the six authorized implementation paths. The navigation README, restored historical documents, three archived scripts, screenshot/configuration and all unrelated untracked material remain untouched and unstaged. No archive move, stash, reset, clean, branch switch, force push or broad staging occurred.

One worktree holds this branch. Other registered worktree HEADs remain Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Shared instructions remain clean at `95326f515ef4719f155ce6e223990398daad6311`.

Implementation checkpoint, six files, committed and normally pushed: **`41a088fe95546726cd61bf2d4c8a9233500b010a`**. Upstream is `0/0` after this push. Exact Prompt/Response 137 are a separate subsequent documentation checkpoint; its self-referential hash is reported in the final handoff. Final index/upstream/worktree checks follow that push.

## Source audit and owner-flight matrix

The original controller constructed the executor before registering scheduled inspection; `_runOne` invoked its action before retaining the future; check and retry lacked complete independent ownership; stale drainage was detached; and restart could be nested inside `_activeRun`. Ordinary stop set a flag but did not distinguish permanent sealing from internal restart intent. Caught inspection/preservation failures could disappear after stop. The original host performed an exit-time provider read and propagated drain errors.

The read-only real executor owns its pending plan and `_activeDrain`. Its `stopAndDrain` seals admission, clears the plan and awaits its recorded worker drain. Its batch operation awaits the mutation executor before returning. Those are source observations only: this task never called the real executor, its factory or its mutation boundary. The controller still awaits the existing executor port and adds no preservation authority.

| Trigger | Retained flight and owner | Settlement/restart boundary | Repetition and permanent sealing |
| --- | --- | --- | --- |
| Selected assessment | `_activeRun`, registered before the scheduler invokes factory/inspection | Initial inspecting presentation remains immediate; factory and inspection execute within the retained flight; binding rechecked before construction | Duplicate admission blocked; stop/disposal before scheduler prevents construction |
| Human preservation | `_activeRun`, admitted only for the identical current authorization | Executor retains batch authority; controller awaits its actual observation; progress requires live binding | Duplicate confirmation does not invoke another batch; queued work is revoked by stop |
| Check again | `_activeRun` includes old executor drain and any replacement construction/inspection | Executor drain failure retained; post-wait sealing/binding check precedes replacement | Duplicate check blocked; ordinary stop waits for check drain and prevents replacement |
| Terminal observation / stale assessment | Separate `_restartFlight` captures prior worker; `_executorDrain` retains executor settlement | Worker never awaits its own restart. Queue requests executor stop, awaits prior work and drain, then checks sealing/occurrence | Stale changes coalesce; ordinary stop revokes queued dispatch; success remains one-shot |
| Human retry after restart failure | `_restartFlight`, coalesced with existing flight | Earlier failure remains retained until actual successful work/restart; merely admitting a retry cannot erase it | Stop before dispatch revokes retry and still reports earlier failure |
| Active restart port | `_restartActive` established before publication/port entry, separate `_restartFlight` | Ordinary/reentrant stop promptly throws `StateError`; no recursive await | Later drain succeeds only after actual successful settlement; late error remains retained |
| Ordinary stop | Permanent seal, then `_ordinaryStopFlight` before executor entry | Directly awaits executor or its already-retained drain, controller work, any returned replacement executor, and revoked queued restart | Repeated ordinary stop coalesces; active restart refuses before this wait; no later work admission |
| Disposal | Synchronous permanent seal and publication suppression | Disposal does not await or claim drainage; retained owner can still drain admitted work | No late publication or restart; pre-scheduler disposal prevents construction |

Human preservation/check futures retain their prior completion semantics: they await their worker and any resulting separately owned restart. The worker itself never includes that restart, avoiding the old cycle. No new public API, lifecycle service, provider, jurisdiction or generic shutdown framework was added.

## Executed red-before and green-after evidence

Before production edits, three desired controller assertions ran against unchanged source (`--plain-name 'Prompt 137'`): **exit 1, 0 passed / 3 expected failures**, `/private/tmp/prompt137-red.log`.

1. Stop before scheduler still found one executor construction, expected zero. The legacy admitted inspection was explicitly released before asserting.
2. The restarter synchronously reentered the real owner's drain while its own future was held. Drain did not promptly refuse; the retained inspection/restart dependency remained pending until release. This was not a false-success trace and no native exit was inferred.
3. An inspection error delivered after stop was swallowed by the owner; drain succeeded without retaining that error. Expected failure retention was absent.

First corrected full-controller run: **exit 1, 18 passed / 4 failures**, `/private/tmp/prompt137-owner-first.log`. These exposed the existing public preservation future's restart-completion timing; the implementation was corrected to preserve that contract, without weakening old assertions. Expanded controller run then passed **35**, exit 0, `/private/tmp/prompt137-owner-expanded.log`. Subsequent cases cover queued human retry, pre-scheduler disposal, queued preservation and one-shot completed restart; final controller count is **39**.

The first host setup attempt had incomplete synthetic presentation evidence: **exit 1, 0 passed / 9 fixture failures**, `/private/tmp/prompt137-host-red.log`. It is excluded from behavioral proof. The fixture now supplies full synthetic root/source/store/archive evidence, and the owner preserves immediate initial inspecting presentation while deferring construction.

Against the unchanged Attachment listener, the corrected nine-case host matrix produced **exit 1, 3 passed / 6 expected failures**, `/private/tmp/prompt137-host-red-corrected.log`: two real pending work failures, two real active-restart refusals, and injected synchronous/asynchronous drain errors propagated instead of returning cancel. Three successful/pending controls passed. Only then was the Attachment listener changed.

Final real-owner tests establish:

- Pending inspection and preservation keep both repeated registered exit requests pending. Actual fake work is released and awaited; success yields two exit responses, error yields two cancel responses. No restart occurs; exactly one executor is constructed.
- Pending preservation is genuinely awaited, including its failure. Late progress and observations cannot republish stopped state. Duplicate preservation and check events do not admit extra work.
- A synchronous factory callback reenters stop before returning its executor. Stop remains pending until that returned executor's controlled drain settles; inspection never starts.
- Real assessment replacement while inspection or preservation is held queues retirement. Ordinary stop revokes that queued restart; settling the work cannot dispatch it.
- UNKNOWN, source loss and changed binding delivered after stop remain stopped, without a fabricated complete/empty snapshot or restart.
- Reentrant and ordinary active-restart drainage refuse with `StateError`; actual host requests return cancel while the restarter remains pending. Later successful settlement permits exit; later failure still cancels. Native process death is not tested.
- Retry coalesces; revoked retry retains the previous failure. Successful restart does not redispatch on later assessment events.
- Disposal suppresses publication/restart but cannot substitute for awaiting work. Listener unmount removes exit callbacks; requests after unmount do not increase drain counts.

Supplemental injected drain tests use a subclass only for synchronous throw, asynchronous error and controlled success translation. They assert one owner/factory construction and callback removal. They supplement real-owner proof rather than replacing it. No new sleep or timeout was introduced. Every admitted fake work/restart future is explicitly released and awaited; containers/listeners are disposed. Unadmitted completers do not represent work and are not treated as drainage evidence.

## Validation

SDK: `/Users/rob/Development/flutter/bin/flutter` and `dart`; authorized SDK-cache access. No interrupted/fixture-failed/static-failed run is counted as a pass.

| Final gate | Exit / result | Evidence |
| --- | --- | --- |
| Entire Attachment controller and startup harness | 0; **81 passed = 39 + 42** | `/private/tmp/prompt137-focused-final.log` |
| Screened related controllers/presentation, 13 files | 0; **148 passed** | `/private/tmp/prompt137-regressions.log` |
| Attachment presentation rerun after final owner refinement | 0; **2 passed** | `/private/tmp/prompt137-presentation-final.log` |
| Complete source/AST `test/architecture` | 0; **647 passed** | `/private/tmp/prompt137-architecture-final.log` |
| Full `flutter analyze --no-pub` | 0; no issues, 11.0 seconds | `/private/tmp/prompt137-analyze-final.log` |
| Targeted `dart format --output=none --set-exit-if-changed` | 0; six files, zero changes | `/private/tmp/prompt137-format-final.log` |
| Filtered normal `build_runner build` | 0; permitted companion hash only changed | `/private/tmp/prompt137-generation-final.log` |
| Working/staged whitespace, exact allowlist, full byte inventory | 0 / pass | Git checks and manifests |

Tests used `flutter test --no-pub ... --reporter expanded`. The focused paths are the two allowlisted controller/harness test files. Regression paths under `test/essentials/` are Attachment Repair presentation; Diagnostic, Local Repair, Onboarding, Data Update and Source Access application controller plus presentation screen files; Operating Session application session controller and presentation app. They use fixed/inert observations, fake work/settings/restart/visual ports, and no real mutation tenure. The 148 run preceded the final Attachment stop/failure refinements; its affected Attachment presentation was rerun afterward, as were the complete focused files. Unchanged other owners were not repeatedly requalified.

Intermediate post-host focused run passed 79 before the final two tests. The first architecture run had **645 passed / 2 failures**, exit 1: existing exact authorization identity and direct executor-drain source assertions. The controller was adjusted to preserve those guards; their file was not edited. The first analyzer run exited 1 with three test-style info findings; all corrected. The final architecture suite preserves its original assertions and adds one positive Attachment host guard. The allowlisted aggregate host assertion now expects an awaited captured drain instead of an exit-time method lookup, with the new per-host capture/await/cancel/dispose guard strengthening it. Six specialist listeners plus one Operating listener remain unchanged.

No entire Flutter suite, real archive/tenure/native probe or production build ran. All executor-file cases below were excluded from execution; most exercise the concrete executor even with fake infrastructure, forbidden by this prompt. The pure binding case was also unnecessary to the owner/host milestone. This report makes no fresh executor-runtime qualification claim:

- `classifies bounded pages without mutating and keeps unknown distinct from absent`
- `global source unavailability terminates as source access lost`
- `global inconclusive source evidence terminates as unknown`
- `mismatched bounded summary samples fail closed`
- `archive binding change terminates the occurrence`
- `binding and current context canonicalize the archive root once`
- `151 available items require three exact human confirmations`
- `fresh recomputation discovers later source availability without a durable cursor`
- `stale source evidence invalidates the displayed exact plan`
- `stale consent cannot refill an unavailable key with item 76`
- `new required items invalidate rather than expand old consent`
- `changed archive generation invalidates consent before mutation`
- `direct execution without the presented plan cannot mutate`
- `unknown byte scope is visible evidence but cannot admit mutation`
- `mutation source loss and inconclusive evidence fail closed`
- `preservation evidence-read failure becomes coverage unknown`
- `stopAndDrain waits for the in-flight batch and prevents new admission`

These names belong to `test/features/attachments/application/app_czar_attachment_archive_repair_executor_test.dart`. Other real mutation/factory/lease and Operating-currentness worker suites were outside this finite selection, not declared passing.

## Exact delta and Project Conformance

Only the six authorized implementation paths changed. The controller's admission predicate remains unchanged. Production host changes are confined to `_AppCzarAttachmentArchiveRepairLifecycleHostState`; removing that block from both baseline/current files gives byte-identical remaining harness content. All preservation executor/factory/model/UI, reset, Operating, other owner, native, dependency, release and activation bytes remain unchanged. Filtered generation changed only the permitted provider hash; no generated file was hand-edited. Full manifest: `/private/tmp/prompt137-final-hashes.json`.

| Path | SHA-256 |
| --- | --- |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` | `579951bc655df408800da68c6b677cbc2e7e23b04c9e935bb1e51e27bf729ec2` |
| `lib/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller.dart` | `2abe49580ac61ecc5bdd4e24d551957619bbecf33818565d64735937310bb3fc` |
| `lib/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller.g.dart` | `66534e65c04aaacbe589a955329e2c3a842240af2c10ca4fae6b00f9ce83054d` |
| `test/architecture/app_czar_architecture_test.dart` | `95085f89383aa7bdde678e4fb91a3253ef87e1d2945a86a51b4098c04c1929e5` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `5772eee02f4aeb1f89c9d598cdd68fad1993071ecb7f79a46614b95057092894` |
| `test/essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_controller_test.dart` | `d47bdeff791b2710c332bfe2119ca4492076faac92681efe515ece16226c1a6b` |

**Reviewed against:** repository AGENTS.md; shared global guardrails, Dart and generated Riverpod patterns; project README; database/overlay and attachment-preservation invariants; Feature 34 Project Conformance Audit Standard; Prompt 137, Prompt/Response 136 and relevant Responses 122, 126, 128, 132–135; actual owner, executor/factory contract, host, domain state and architecture requirements. Scope is baseline `758dad01` through this Attachment-only implementation, not the entire integration branch or production cutover.

**BLOCKER: 0. SHOULD FIX: 0. OPTIONAL: 0 within this milestone.**

- Reuse/layering/dependency direction: existing generated owner, injected ports and selected lifecycle host; no cross-owner authority, new framework, public forge or infrastructure import.
- Single source of truth: one retained non-restart flight, distinct restart flight, explicit active flag and permanent seal; executor remains sole batch/preservation owner. No new data/path/schema/version authority.
- Idioms and bounded work: scheduled registration precedes reentrant ports; finite existing work only; no new timer, polling, history, recursive I/O or unbounded allocation. Existing approved `unawaited` cleanup remains around retained flights, not detached preservation authority.
- Privacy and mutation: no new logs or content persistence; no archive bytes or permissions changed; current authorization identity and currentness checks retained; UNKNOWN is not reclassified as complete.
- Error/state semantics: errors remain retained after seal; queued intent is revocable, active restart explicitly refuses; retry admission alone does not clear errors; no late state publication. Existing UI states and human confirmation remain.
- Obsolete machinery: detached stale-drain path, unregistered check continuation and nested worker/restart flow replaced inside the same owner; no compatibility framework left behind.
- Tests/architecture: expected-red provenance and final runtime tests separate from injected/source-only evidence; unchanged architecture guards pass, host contract strengthened, census intact.
- Generated/dependency hygiene: only normal permitted companion hash changed; no dependencies, native or release metadata changes authorized or made.
- Documentation/UX: exact prompt/response pair records limits; no new surface or diagnostic text. Other UI/theming/navigation conventions are unaffected.

PROJECT CONFORMANCE: PASS

Native termination, fresh launch identity/signing/FDA continuity, real archive lock release, next-process admission and production cutover remain unimplemented/unqualified. Stop at this Attachment-only milestone; no Operating listener edit or Prompt 138 work was undertaken.

ATTACHMENT REPAIR OWNER COMPLETE DRAIN QUALIFIED: YES
ATTACHMENT REPAIR ACTIVE-RESTART REFUSAL/NO SELF-AWAIT: PASS
ATTACHMENT REPAIR ACTUAL EXIT LISTENER FAILS CLOSED: YES
ATTACHMENT PRESERVATION AUTHORITY/BYTES CHANGED: NO
OPERATING EXIT LISTENER QUALIFIED HERE: NO
SIX SPECIALIST / ONE OPERATING HOSTS PRESERVED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
REAL PRODUCTION FRESH LAUNCH/ADMISSION IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE (ATTACHMENT EXIT SCOPE): PASS
READY FOR SEPARATE PROMPT 138: YES
