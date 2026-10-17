# Response 126 — Fresh launch after exit: finite design audit

## Decision and limits

Recommend a **bounded external one-shot exit observer/launcher**, with ordinary quit and human reopening as the fallback. Its entire responsibility is to observe the originating process's exit and attempt one launch of an independently validated official application. It receives no coordinator identity, archive capability, assessment, UI route, domain state or persistent work record. The fresh process independently admits itself and reassesses.

This is a grounded architecture for isolated characterization, **not an implementable production cutover approval**. The next milestone is only a disposable process-observer experiment with an inert launch sink. Target integrity across validation/launch, production quit wiring, signed runtime behavior and archive admission remain separate blockers. There is no claim that the current restarter can be made production-ready simply by replacing its shell command.

No tests, builds, generators, app launches/exits, native prototypes, installed-app inspection, database/archive reads, permission operations, or mutation authority ran in Prompt 126. Commands were limited to repository/SDK source, Git, SHA-256 inventory and external documentation inspection. Python was used for inventory/document writing only, not to exercise lifecycle behavior.

## Recovered checkpoint and preservation

Branch `fix/onboarding-import-stuck-state`; initial HEAD `99f9f46e9ac2b46035128aceafdc91bf4a13fc4d`; upstream `0/0`; tracked tree and index clean. Commit `99f9f46e` already contains exactly Prompt/Response 125, after source `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`. Ancestry and file contents were inspected; no duplicate prerequisite checkpoint was made.

Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e` and Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a` are ancestors. All 17 Stage 2 manifest hashes and all six Source Access qualification hashes match. The Data Update module has no delta from its checkpoint. Prior 38/50/644 test counts remain historical Prompt 125 evidence; nothing was rerun here.

`/private/tmp/prompt126-baseline.json` records 6,028 tracked regular files and 50 untracked files (Prompt 126 plus 49 unrelated). All baseline bytes must remain identical, including restored historical documents, navigation README and three `_ARCHIVED` scripts. Only Response 126 is added, and only exact Prompt/Response 126 may be staged. The final handoff reports the documentation commit and synchronization; its own hash is intentionally not embedded here.

| Registered worktree | Initial HEAD; disposition |
| --- | --- |
| `remember_every_text` | `99f9f46e9ac2b46035128aceafdc91bf4a13fc4d`; only active task tree |
| `remember_every_text-feature-35` | `09b1c767cc01410da5799273206e2ab2a4d3b283`; untouched |
| `remember_every_text-main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`; untouched |
| `remember_every_text.worktrees/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`; untouched |

Shared instructions are clean at `95326f515ef4719f155ce6e223990398daad6311`. No implementation, test, generated file, entitlement, signing identity, dependency, native project or activation setting changed.

## Inspected current lifecycle — source facts

Paths below are repository-relative unless explicitly marked SDK. Symbols are the stable inspection anchors.

1. **Native identity before Flutter:** `macos/Runner/MainFlutterWindow.swift`, `MessageLensNativeArchiveClaimResolver.resolve` (line 161), validates environment/build pairing, bundle ID/product name and configured production certificate evidence. Production identity is `com.bigbenchsoftware.MessageLens` / `MessageLens`; development and FDA experiment identities differ. Root resolution binds Application Support plus bundle ID; a development override is rejected in production. `MessageLensCodeSignatureValidator.hasCertificate` (line 102) obtains signing information and compares certificate subject summaries. It does **not** call full static code validity verification or establish an independently approved installed target path.
2. **Root lock:** `MessageLensProcessLock.acquire` (line 337) opens `MessageLens.instance.lock` with `O_CREAT | O_RDWR`, takes `flock(LOCK_EX | LOCK_NB)` and retains the descriptor. There is no `O_CLOEXEC` or `F_SETFD` here; repository search found no explicit close-on-exec configuration. The static `MainFlutterWindow.instanceAuthority` retains the owner before engine creation. `release` unlocks/closes; no early release is part of the proposed restart design. A lock file's existence is not ownership. Actual descriptor inheritance by Dart's detached-process implementation is **UNKNOWN**, not established safe by the absence of a visible failure.
3. **Duplicate admission:** `MessageLensSingleInstanceAuthority.claim` (line 410) checks earlier same-bundle applications by launch date/PID, then nonblocking root lock; duplicates activate the existing app and terminate before Flutter. `awakeFromNib` (line 461) resolves claim, acquires authority and only then creates `FlutterViewController`. This is the successor's guard, not a launcher's license to release another process's lock.
4. **Quit:** `macos/Runner/AppDelegate.swift` subclasses `FlutterAppDelegate`, returns true from `applicationShouldTerminateAfterLastWindowClosed`, and installs startup flags/link/log channels. It does not implement a production restart channel or override `applicationShouldTerminate`. The startup channel only returns Option-launch reset flags.
5. **Flutter/native bridge:** the configured SDK root is `/Users/rob/Development/flutter`. Its `engine/src/flutter/shell/platform/darwin/macos/framework/Source/FlutterAppDelegate.mm:77` delegates normal termination to `FlutterEngineTerminationHandler`, initially canceling synchronous AppKit termination while asking Dart. `FlutterEngine.mm:237` sends `System.requestAppExit`; an explicit cancel clears termination intent. **The inspected engine also invokes termination for a FlutterError or malformed reply, and before Dart accepts requests it uses required termination.** These are source facts about this SDK checkout, not verification of a shipped engine binary.
6. **Dart exit:** SDK `packages/flutter/lib/src/services/binding.dart:512` sends `System.exitApplication`; cancelable requests consult observers. SDK `widgets/binding.dart:818` awaits observers and combines explicit cancel responses, but does not wrap each observer exception. A thrown drain is therefore not universally equivalent to cancel. No post-mortem UI success response is available.
7. **Fresh Dart admission:** `lib/main.dart:_admitArchive` (line 170) reads the native claim, derives expected Application Support root, validates claim/root, then executes existing marker/legacy-journal compatibility admission. `main` admits before constructing persistent providers. The root `ProviderContainer` (line 346) contains newly admitted authority and newly selected reset composition; `UncontrolledProviderScope` uses that container. No serialization or transfer of it exists. Harness assessment starts by watching `appCzarAssessmentControllerProvider`. These ordinary paths can access persistent stores; this audit only read their source.
8. **Activation:** `lib/main.dart:330` sets `ProductionAppCzarActivation.disabled` unconditionally. Production eligibility is not activation. A new production invocation today does not imply an activated AppCzar composition.
9. **Restarter seam:** `lib/essentials/app_czar_data_update/application/app_czar_process_restarter.dart` exposes only `Future<void> restartAndReassess()`. Its generated-provider source selects `MacosDevelopmentProcessRestarter` using the exact development composition policy. The infrastructure implementation derives a bundle from `Platform.resolvedExecutable`, spawns detached `/bin/sh`, loops on `kill -0` with sleeps, then invokes `/usr/bin/open -n`; the old process calls `exit(0)`. No independent official-target validation, bounded death observation or ordinary cancelable termination is present.

### Seven jurisdiction exit paths

`lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` contains exactly six specialist listener constructions. `lib/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart` contains one separate Operating listener. Counts were inspected, not runtime-tested here.

| Owner | Actual source boundary and limit |
| --- | --- |
| Data Update | Host captures selected notifier at mount, awaits drain, catches Object into cancel. Controller seals and waits `_activeWork`; restart dispatch is separately owned and excluded from that drain. This permits reentry after data work settlement, not proof that the restart task itself died. |
| Source Access Repair | Host captures selected notifier and catches drain failure into cancel. Controller seals, waits Settings/source, refuses if `_restartFlight` exists, then retires the check continuation. Calling normal termination from inside the pending restart callback will be refused. Refusal must never be reinterpreted as success. |
| Diagnostic Review | Host reads notifier at exit, awaits drain, then exit; no local exception-to-cancel catch. Controller closes actions/increments publication generation and awaits lifecycle action. |
| Onboarding | Host reads notifier at exit and awaits drain; no local catch. Controller seals and awaits active run; optional restart is distinct behavior. |
| Local Data Repair | Host reads notifier at exit and awaits drain; no local catch. Controller seals and awaits active run. Remains distinct from Source Access. |
| Attachment Archive Repair | Host reads notifier at exit and awaits drain; no local catch. Controller stops admission, awaits executor and active run (including finally). Executor failure may propagate. |
| Operating | Separate listener reads session, binds occurrence-specific currentness drain, awaits active flight. No local exception-to-cancel catch. Shell/currentness ownership is not transferred. |

**Production blocker:** the four older specialist hosts and Operating cannot be described as universally fail-closed on drain exceptions from this source. The SDK's error-reply termination behavior makes this material. Prompt 125's two explicit catch-to-cancel hosts remain intact. No historical record or implementation is rewritten; eventual all-jurisdiction error/cancel native qualification is required before production wiring.

## Authoritative API evidence, and what it does not prove

External documentation consulted during this audit; archived Darwin man pages establish baseline contracts, not measured behavior on the user's current OS.

- [NSApplication termination delegate](https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldterminate(_:)): normal termination can be canceled or deferred. It is not a death notification and does not constrain force-kill/crash.
- [NSWorkspace openApplication](https://developer.apple.com/documentation/appkit/nsworkspace/openapplication(at:configuration:completionhandler:)): requests launch at a URL and asynchronously returns an application/error. No documented wait-for-old-exit scheduling guarantee is supplied by this API.
- [createsNewApplicationInstance](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/createsnewapplicationinstance): true requests a new instance even if another runs; false may reuse the running app. Neither choice resolves old-process ordering.
- [allowsRunningApplicationSubstitution](https://developer.apple.com/documentation/appkit/nsworkspace/openconfiguration/allowsrunningapplicationsubstitution): default permits substitution from a different URL; an exact-target proposal must disable it. That alone is not code-integrity verification.
- [NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication): represents an application instance, exposes PID, launch date, bundle/executable URL and termination state, and remains usable after exit. Time-varying properties depend on run-loop progress. PID lookup or nil is not by itself an incarnation-proof death witness. Workspace termination notifications/instance observation are candidates for diagnostics, not durable authority; registration races and delivery require qualification.
- [kqueue / EVFILT_PROC / NOTE_EXIT](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/kqueue.2.html): a registered process filter reports process exit; registration can fail for absent/inaccessible processes. This grounds a one-shot observer hypothesis. A successful filter attached while the known parent is alive is stronger than repeatedly looking up a numeric PID. Registration/error/deadline handling must be demonstrated on supported macOS.
- [waitpid](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/waitpid.2.html): waits for children. A helper spawned by MessageLens cannot ordinarily reap/waitpid its parent. Inverting the process tree into a permanent supervisor is unnecessary scope. Parent loss reparents a helper; it does not certify a particular app's admission.
- [posix_spawn](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/posix_spawn.2.html): creates a process; open descriptors survive unless close-on-exec/file actions exclude them. Prefer an absolute helper executable and explicit descriptor/environment handling, not PATH lookup or shell interpolation. Successful spawn is not helper readiness or target launch.
- [fcntl](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fcntl.2.html): descriptor flags control close-on-exec. [flock](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/flock.2.html): advisory exclusion applies to cooperating processes; duplicated/inherited descriptors reference the same lock. A child must close an inherited descriptor, **not unlock it**, which could release the parent's lock. No claim of old-process death alone proving release is safe without excluding surviving references.
- [SecStaticCodeCheckValidity](https://developer.apple.com/documentation/security/secstaticcodecheckvalidity(_:_:_:)) and [validation flags](https://developer.apple.com/documentation/security/static-code-validation-flags): full validation checks sealed components and an explicit requirement; all architectures/nested code require appropriate checks. Apple expressly limits validity to unmodified code and warns about concurrent modification. Revalidation before launch does not eliminate the final path-replacement race.
- [SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice): manages login items/agents/daemons. Registration and ongoing service lifetime are unnecessary for one bounded restart attempt; not selected.

## Finite mechanism comparison

| Candidate | Ordering/drain and required change | Identity, errors, duplicates, recovery |
| --- | --- | --- |
| A. Ordinary quit; human reopen | No launcher changes. Existing selected owner must settle, ordinary quit must actually finish, user then reopens. No automatic continuity guarantee. | User must select the independently verified official app. Native root lock still rejects overlap. No automatic timeout/retry owner; cancellation leaves app running, failed reopen leaves stopped state. Fresh admission remains mandatory. Safe fallback/reference, not a newly certified signed path. |
| B. LaunchServices / NSWorkspace alone | Direct API is a launch request, not an after-exit scheduler. Calling before exit can reuse old instance or start a duplicate which loses the lock. An in-process callback cannot survive its own process death. | Explicit URL helps target choice but needs integrity checks. Completion can report launch error, not archive admission. A new-instance flag is not ordering. Human recovery possible; not sufficient alone. |
| C. Bounded external one-shot observer plus launch call | Needs isolated helper, proven descriptor exclusion, pre-exit observation readiness and ordinary termination integration outside a restart-owned future. Wait for registered old incarnation exit; at most one launch attempt before finite deadline. | Fixed independently approved target, full validity and replacement safeguards required. Helper owns observation/launch errors and expires without force-killing or retrying. Successor owns lock/admission. Concurrent human launch may win; never loop to replace it. Failure leaves app running if quit refused, or stopped if exit occurred. Recommended for narrow characterization only. |
| D. Existing development helper unchanged | Detached shell polls PID then open -n; exit(0) bypasses ordinary quit. Poll is unbounded and identity is numeric. Not a production drain contract. | Current-executable-derived bundle, no complete signature/official-location proof, no explicit lock-descriptor handling or bounded error outcome. Positional quoted arguments avoid one interpolation hazard but do not cure these failures. Preserve development gate; reject reuse unchanged. |

## Minimal future lifecycle contract

The smallest boundary is **settled application work → ordinary process termination → one launch request**. The launch mechanism never selects a jurisdiction.

1. The selected owner finishes or refuses and seals new work. Actual admitted work must settle. Source Access's restart-owned future must have retired before successful drain/ordinary quit can be requested. A future integration must separate “request accepted” from termination execution and await explicit owner settlement outside the initiating callback. A timer/microtask delay is not proof. The present port does not expose this complete orchestration, and this audit does not authorize redesigning it.
2. Only after that boundary, native launch infrastructure prepares one bounded helper with a fixed target identity/path. The helper carries only volatile launch parameters and old-process observation context. No archive path/descriptor, capability, controller state, assessment, routing instruction or durable record passes to it.
3. Proposed observer: a directly spawned helper verifies it still has the expected parent, registers an EVFILT_PROC NOTE_EXIT event, verifies the parent relationship again and acknowledges readiness over a private short-lived pipe while the parent is still alive and waiting. Parent identity mismatch, early death, registration error or missing readiness means no launch. This small OS-readiness exchange closes a registration race; it is not a coordinator succession token. Its sufficiency is the next disposable hypothesis, not a proven runtime fact. Never reattach a reused PID after registration failure.
4. Parent then requests ordinary cancelable termination through the supported Flutter/AppKit path; it retains the archive lock. A cancellation disarms the helper and must receive disarm/retirement confirmation; helper expiry is a second finite guard. It cannot remain armed indefinitely to surprise-launch after some later unrelated quit. No timeout kills the parent or grants exit permission. Crash in the narrow already-armed interval may be observed as exit; this is not a general crash-restart service and does not prove graceful settlement.
5. Only an armed, unexpired registered exit event allows the helper to validate the fixed target and attempt launch once. Spawn/file actions must exclude the old archive descriptor and other unrelated descriptors; close-on-exec should be established at acquisition in any later production design. Do not “test” ownership by unlocking or deleting the real lock file. Successor independently arbitrates any competing launch via native admission; no early unlock to ease launch.
6. Launch via an explicit validated official bundle URL, with substitution disabled and no inherited development-root/debug injection. Default reuse of an already-running exact official target may be treated as already running, never proof of a new invocation. No forced duplicate/relaunch loop. Missing/moved/changed target, validation failure, ambiguous identity, deadline or API error ends the attempt. A launch callback still does not certify native lock/Dart admission.
7. New process repeats native signature/root/instance checks, Dart marker/admission and fresh assessment. No old assessment chooses the next jurisdiction. Schemas, overlay, Presence, protected ledger/graph and attachments remain in place. Failure needs manual recovery; the dead process cannot report a successful restart to its UI.

Ordinary external quit without an armed explicit restart gets **no** automatic reopen. Crash/forced termination without an armed request gets **no** automatic reopen. Crash/kill can bypass drain; the root lock and ordinary fresh admission remain guards, not retrospective evidence that work completed. An armed observer is launch-only and cannot reconstruct lost work or promise clean termination.

## Outstanding production blockers (not audit findings to silently fix)

- Official installed bundle location is **UNKNOWN**: source identity constants do not establish a particular installed application's path or validity. No `/Applications/...` guess or current development executable may substitute.
- Complete target requirement, all relevant signed components, helper trust/packaging and protection against concurrent bundle replacement remain unqualified. Immediate prelaunch validation narrows but does not close TOCTOU. Production must refuse where target stability cannot be established; this needs a separate deployment/security decision before any installed target launch.
- Native root binding and descriptor noninheritance require explicit implementation/qualification. Present lock acquisition has no explicit CLOEXEC. A helper retaining a lock reference could outlive its parent; early unlock is prohibited.
- Source Access restart settlement/ordinary-quit integration is unresolved in current source. All seven jurisdictions need error/refusal and reentry qualification; engine error envelopes must not silently become termination permission.
- Fresh native/Dart admission remains source-inspected only, and production AppCzar remains OFF. No fake launch proves actual replacement PID, archive ownership or correct assessment.
- Signed identity/FDA continuity must be tested later under the actual production identity and unchanged entitlements. Readable source is not FDA continuity. No signing identity changes are proposed.
- In-place schema/migration readiness, backup/rollback, shell/provider currentness closure, preservation and final signed human rehearsal remain separate cutover blockers. No reconstruction/FTS dependency or Start Fresh escape is proposed.

## Exactly one recommended Prompt 127 milestone

**Objective:** characterize a bounded, directly spawned macOS child observer of its parent's exit, with explicit descriptor exclusion and an inert at-most-once launch sink. Establish whether registration/readiness plus parent-incarnation checks can safely order the attempt. Do not implement a production launcher or wire Flutter/Runner.

Exact finite proposed allowlist (both confirmed absent; clearly **NEW**, not existing authorization):

- `tool/macos_fresh_launch_probe.c` — standalone disposable parent/helper modes, kqueue observation, explicit spawn file actions, finite readiness/disarm/deadline handling, and a launch sink that writes only a fixed synthetic result to a private test pipe. No NSWorkspace, open command, arbitrary executable target, installed-app bundle lookup, or domain imports.
- `tool/macos_fresh_launch_probe_test.py` — driver compiles only that standalone probe into its own temporary directory, runs only probe-owned disposable processes and temporary lock files, records deterministic barrier results, and reaps/cleans its own fixtures. No application test host.
- Exact Prompt/Response 127 documentation pair only, with the future prompt's chosen descriptive name. No other source/test/project/config files; in particular no `macos/RunnerTests/RunnerTests.swift`, whose app-host and bookmark tests are inappropriate for this isolated milestone.

Required success/denial/unknown cases:

1. Known live parent, registered observer and acknowledged readiness: no sink before exit; exactly one sink after observed exit. A retained temporary lock descriptor in parent must prevent a competing fixture claim until actual close/exit.
2. Real helper exec with explicit descriptor exclusion: temporary lock must not remain owned by helper after parent exits. Include an isolated deliberately inherited-descriptor negative control; close, never unlock, the inherited copy. No real archive lock.
3. Wrong parent, parent death before readiness, no registration, registration failure, missing readiness, disarm, duplicate request, helper failure and expired observation each produce zero sink. A refused/delayed quit must not produce a later surprise sink after disarm/expiry.
4. Parent remains alive indefinitely within the observation window: deadline produces refusal only, never parent termination or exit permission. Controlled barriers establish pending behavior; elapsed timeout alone must not prove settlement.
5. PID reuse reasoning must bind to the successfully registered live parent, never later PID lookup. Exercise injected stale/mismatched identifiers; do not claim simulated reuse is actual OS PID-reuse qualification. Ambiguous attachment is UNKNOWN/refusal.
6. Controlled crash/forced exit of probe-owned fixtures may establish observer behavior only; no promise of clean work or arbitrary-crash recovery. Duplicate exit events invoke inert sink at most once. Missing/changed synthetic target eligibility invokes no sink; this does not prove real signature/TOCTOU safety.

Native probe responsibility ends at registered exit observation and inert sink invocation. Flutter owner settlement, real LaunchServices behavior, official bundle trust and successor archive/assessment admission are deliberately not executed. A passing probe would qualify only those measured primitive behaviors.

Future STOP gates: any need for state transfer, a durable queue/daemon, production data, installed MessageLens launch, app-hosted tests, signing/entitlement changes, production activation, or broader allowlist. If API semantics cannot bind observation safely, record a failed/unknown result and stop; do not silently fall back to kill -0. Preserve all baseline files/worktrees; perform scoped canonical conformance and source review, compiler diagnostics and isolated test results, whitespace/hash checks; separately commit/push only qualified probe source/tests and exact documentation. This is a recommendation requiring Prompt 127 authorization, not work begun here.

## Canonical design conformance and final disposition

Scope: Response 126's proposed design against `99f9f46e`; zero application delta. Reviewed against `AGENTS.md`, shared `00-global/agent-guardrails.md`, project `README.md`, `01-PROJECT/02-architecture-overview.md`, `10-DATABASES/07-overlay-database-independence.md`, `25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md`, `60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`, canonical `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`, Prompt 126 and verified Prompt/Response 125 checkpoint. Existing application facts were inspected directly rather than inferred from historical claims.

| Conformance area | Classification / evidence |
| --- | --- |
| Reuse, ownership, layering | NO ISSUE: normal termination, OS process observation and existing independent admission; no coordinator succession mechanism. |
| Dependency direction / single source of truth | NO ISSUE: launch-only boundary carries no domain authority; fresh AppCzar remains decision owner. |
| Project idioms / generated hygiene | NO ISSUE: no application/generated/dependency change; standalone probe is only a future proposal. |
| Bounded work | NO ISSUE: one attempt, finite refusal, no polling service or persistent launch loop. |
| Privacy / mutation safety | NO ISSUE: no data inspected or modified; future probe has temporary fixtures and inert sink only. |
| Error/state semantics | NO ISSUE in design: explicit refusal/unknown, no permission or admission inference; current production gaps are enumerated rather than hidden. |
| Dead/superseded machinery | NO ISSUE: development helper retained under its gate, not promoted or replaced here. |
| Tests / documentation agreement | NO ISSUE: historical tests distinguished from current source/API inspection; no fresh executable qualification claimed. |
| UX / release | NO ISSUE within scope: human fallback, no UI or release changes; signed-runtime UX uninspected. |

Zero in-scope BLOCKER or SHOULD FIX for this documentation-only, isolated-characterization proposal. Production blockers above remain blocking production, not deferred implementation details claimed solved. No optional cleanup proposed. Before checkpoint, full baseline hash preservation, exact documentation staging and working/staged whitespace must pass; final Git synchronization is recorded in the handoff. Stop after this response; do not begin Prompt 127.

SIX SPECIALIST EXIT HOSTS PRESERVED: YES
NO COORDINATOR-TO-COORDINATOR HANDOFF: YES
FRESH-LAUNCH-AFTER-EXIT DESIGN GROUNDED: YES
PRODUCTION RESTART MECHANISM IMPLEMENTED: NO
FRESH NATIVE/DART ADMISSION QUALIFIED: NO
STAGE 1/2 RESET DENIAL UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE (AUDIT): PASS
READY FOR NARROW PROMPT 127: YES
