# MessageLens — Feature 34
## Prompt 126 — Checkpoint Source Access Quiescence and Design Fresh Launch After Process Exit

**Task type:** Read-only, finite macOS process-lifecycle design audit. **Not:** implementing a production restarter, enabling production AppCzar, creating an interprocess state-transfer protocol, running MessageLens, or accessing real data.

### 0. The architectural decision and precise vocabulary

The architecture is intentionally simple and must remain so:

1. **Coordinator completion:** AppCzar selects exactly one of seven jurisdictions. The selected coordinator completes its own work, settles admitted operations, and relinquishes its authority. No next jurisdiction is chosen by that coordinator.
2. **Process exit:** The current MessageLens process terminates completely. No Dart controller, provider container, operation capability, archive lock, coordinator state, or in-memory assessment is carried into another process.
3. **Fresh launch:** A narrowly scoped macOS restart mechanism arranges a new invocation of the **same, independently validated official application** after actual old-process exit. Its purpose is launch only, not domain work.
4. **Independent reassessment:** The fresh process repeats native archive claim, single-instance lock admission, Dart archive admission, and a new AppCzar assessment. Only the new assessment determines the next jurisdiction.

Do **not** use “handoff” to mean a transfer between coordinators. If discussing a low-level OS launch arrangement, use “fresh launch after exit.” Avoid inventing an interprocess state-transfer protocol, coordinator succession token, restart-specific data migration, serialized AppCzar state, persistent work queue, or synthetic assessment receipt. Any optional OS-level identity/launch diagnostic must not become an authority token or substitute for the new process's independent admission.

**Fair Witness:** Separate inspected source facts, documented macOS API contracts, testable disposable hypotheses, historical qualifications, and unproved signed-runtime behaviour. A command accepted by `open` or `NSWorkspace` does not prove a new application was admitted. Exit permission does not prove the old process died. A successful launch does not imply archive lock ownership, FDA grant, or a correct new assessment.

### 1. Prerequisite Git checkpoint and preservation

1. Verify the exact branch, HEAD, upstream, tracked/index state, four registered worktrees, shared-instructions submodule and a SHA-256 inventory of tracked and unrelated untracked files. The prior report was Response 125: source commit `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`; verify rather than assume the subsequent documentation checkpoint has happened.
2. Locate the exact Prompt 125 and Response 125 in the established Feature 34 `01-ONBOARDING/prompts` and `responses` directories. If still untracked, complete, byte-stable and explicitly allowed by this prompt, checkpoint **only those two documents** separately and push normally. If already committed, verify ancestry and do not duplicate.
3. Preserve all unrelated untracked files, restored historical documents, the navigation README, three `_ARCHIVED` backup scripts, and the other three worktrees. No stash, clean, hard reset, rebase, force push, directory reorganization or sweeping staging.
4. Confirm Stage 1 reset denial (`e21334de...`) and Stage 2 (`daac3e6b...`) are intact; Data Update source (`a9061283...`) and Source Access Repair source (`5eb7e58b...`) must be intact. Current production AppCzar activation must remain unconditionally OFF.

### 2. Absolute read-only scope

This is **source, relevant external API documentation and Git inspection only**. No tracked application implementation, test, generated file, signing configuration, entitlement, native project or dependency change. No test, build, generator, app launch/exit, process spawning, external tool invocation that opens MessageLens, SQLite access, Messages/Contacts access, live archive inspection, FDA/TCC/bookmark change, attachment operation, or mutation authority. No native prototype that could accidentally launch the installed production application.

The only authorized repository content addition is this task's Response 126; the exact Prompt/Response 126 pair may receive its own separate documentation checkpoint after successful audit. External documentation consultation is allowed; cite explicit API contracts and distinguish them from behaviour measured on the user's Mac. If source or authoritative API evidence is insufficient for a safe finite proposal, STOP and give the smallest missing fact rather than fabricating certainty.

### 3. Verify the existing process lifecycle, without redesigning it

Inspect the actual current source and trace:

- native `MainFlutterWindow.swift` archive claim, code-signature evidence, bundle/product/root validation, lock acquisition/retention and duplicate-instance handling;
- `AppDelegate.swift` application quit behavior, cancelable-exit requests and any Flutter/native channel involvement;
- `lib/main.dart` native/Dart archive admission, production eligibility/disabled activation, root ProviderContainer lifetime and assessment startup;
- development `AppCzarProcessRestarter` port/provider and `MacosDevelopmentProcessRestarter`; identify precisely why its detached `/bin/sh`, PID polling, `open -n` and `exit(0)` are not a production qualification;
- all six specialist cancelable-exit hosts and the separately owned Operating exit listener, with special attention to the newly qualified Data Update and Source Access Repair drain semantics;
- the root archive lock and the old-process-exit condition. Establish if lock descriptor close-on-exec or helper descriptor inheritance is actually configured; unknown must remain UNKNOWN.

Report the **smallest real boundary** between controller completion and macOS relaunch. The launch mechanism must not have to know which coordinator ran or will run. Do not give any coordinator the ability to override AppCzar's next choice, alter the archive, force-admit the replacement, or bypass the ordinary native/Dart checks.

### 4. Compare only minimal macOS fresh-launch-after-exit mechanisms

Evaluate a finite set of approaches against the actual requirements. At minimum:

**A. Ordinary application quit followed by human reopening.** Treat as a useful safe fallback/reference, not as automatic continuity. State what it already guarantees and what it leaves to the user.

**B. macOS LaunchServices / NSWorkspace relaunch scheduling.** Examine whether a supported API actually guarantees launch *after* old exit or merely requests launch while the old app is still running. Do not assume `open -n`, `NSWorkspace.openApplication`, or reopening the application bundle solves the existing single-instance lock race.

**C. Minimal external one-shot launcher which survives old-process exit.** Determine what absolutely has to survive: a fixed approved target identity/path and bounded one-shot launch responsibility, if justified. Prefer no durable handoff record. Investigate safe old-process-incarnation observation, PID reuse, lock descriptor inheritance, target replacement/race and finite refusal. Do not specify a bespoke daemon, service registry, polling framework or state-transfer protocol unless ordinary OS primitives cannot satisfy the requirement and the extra complexity is explicitly defended.

**D. Existing development helper reused unchanged.** Evaluate it as a negative control, identifying which precise requirements it fails. Do not recommend broadly removing its development gate.

For every candidate, assess: required changes; how it is invoked only after coordinator drain; whether old-process death precedes a successor's archive lock claim; exact official bundle and signature/integrity validation; whether failure can leave a safe stopped state; ownership of timeout/error; duplicate-launch races; manual recovery; and compatibility with the new process independently reassessing.

Explicitly investigate relevant supported macOS APIs for lifecycle, exit notifications, `NSRunningApplication` identity and launch, `posix_spawn`, `waitpid`/parent-child restrictions, `flock`, `FD_CLOEXEC`/descriptor inheritance, LaunchServices or ServiceManagement if pertinent. State what documentation proves and what would require later disposable/native qualification. Do not equate a PID no longer responding to `kill -0` with unambiguous identity or reliable death in all conditions.

### 5. Minimal decision contract — no distributed handoff machinery

Define the minimum truthful lifecycle contract for one automatic restart attempt, preferably in ordinary prose or a compact sequence. It must have the following boundaries:

1. Selected coordinator finishes or refuses. A restart request is not admitted until that owner's documented actual work settlement is established. In Source Access Repair, an in-flight restart causes `stopAndDrain` refusal; never reinterpret refusal as success.
2. The current process requests an ordinary termination path and does not release the archive lock early merely to make launch easier. A cancelable exit listener may refuse on unsettled work.
3. The one-shot launch mechanism, if proposed, waits for evidence sufficient for it to avoid overlapping archive writers. No coordinator state, archive authority or UI route travels with it.
4. The successor is invoked using the **validated official bundle**, not the current development executable, an ambient `PATH`, a guessed executable, a user-selectable path or a changing shell interpolation.
5. The successor independently repeats native claim, singleton lock, Dart admission and AppCzar assessment. An attempted launch is not a proven admission.
6. Failures stop safely: no repeated launch loop, lock-file deletion, synthetic reclassification, broad reset, generic legacy fallback, premature `AppExitResponse.exit` or forceful timeout-as-cancel.

Distinguish normal graceful quit, externally initiated quit, crash and forced termination. Do not promise automatic relaunch after arbitrary crash unless the chosen OS mechanism really provides that service and it is separately qualified. Do not imply the old process can deliver a post-mortem success confirmation to its own UI.

### 6. Production-specific independent guards

Inventory concrete outstanding proof requirements rather than silently expanding this milestone:

- Actual official app bundle location and complete code validity, not certificate-summary matching alone; avoid replacing signing identity or entitlements.
- Fresh Application Support root binding and noninheritance of the old archive lock through spawned helpers.
- Native/Dart archive admission and production activation selection (still OFF during development).
- Development versus production identity of the new process; FDA/TCC continuity must be qualified under the actual signed identity later.
- Existing schemas, historical/protected ledger/graph/overlay/Presence and attachment archive must stay in place; no destructive Start Fresh or reconstruction dependency.
- All jurisdiction quit/drain paths; production restarter must not call a controller's `stopAndDrain` recursively from the future that awaits it.
- In-place schema/migration, backup/rollback, shell/provider currentness closure and final signed human rehearsal remain **separate** cutover blockers. Do not describe a working launcher as production readiness.

### 7. Required result: one finite next milestone

Give one recommended architecture, or a firm STOP if no safe minimal architecture can be chosen from the available source/API evidence. Favor an arrangement that **does nothing except arrange a fresh launch after exit**. It must have no knowledge of the seven jurisdiction-specific states and no transport of provider/assessment/mutation state.

Then recommend **exactly one Prompt 127 milestone** with:

- a concrete objective (ideally a disposable/native or pure-port characterization of the smallest launch mechanism, not full activation);
- the exact finite source/test allowlist, only if paths are confirmed to exist or clearly marked NEW proposals;
- precise success/denial/unknown tests with inert or isolated targets only; no real installed app launch;
- where the native/Flutter/OS responsibilities stop and the independent successor admission begins;
- an explicit STOP gate for any need to create a state-transfer protocol, use native production data, broaden signing/entitlements, or enable production;
- preservation and separate Git source/documentation checkpoints, Project Conformance and validation requirements.

Avoid another generic audit of every AppCzar system. Do not propose more than one next milestone or reopen FTS/populated reconstruction.

### 8. Canonical conformance and deliverable

Audit the proposed design against the repository's actual `AGENTS.md`, global guardrails, project README/architecture/database invariants, source preservation rules, and `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`. A documentation/design PASS requires zero in-scope BLOCKER and SHOULD FIX; list remaining **production** blockers separately without misrepresenting the audit as signed-runtime certification. If there is an unresolved essential mechanism, record STOP, explain precisely what evidence would settle it, and do not invent Prompt 127 implementation authorization.

Write the complete Markdown **Response 126** to the existing Feature 34 `01-ONBOARDING/responses/` folder, with the matching numbered descriptive name. Include current Git state, prerequisite checkpoint disposition, inspected source and external-API citations, a compact mechanism comparison, the chosen non-state-transfer design, documented unknowns, one finite next step, test/activation prohibitions and explicit flags:

- `SIX SPECIALIST EXIT HOSTS PRESERVED: YES/NO`
- `NO COORDINATOR-TO-COORDINATOR HANDOFF: YES/NO`
- `FRESH-LAUNCH-AFTER-EXIT DESIGN GROUNDED: YES/NO`
- `PRODUCTION RESTART MECHANISM IMPLEMENTED: NO`
- `FRESH NATIVE/DART ADMISSION QUALIFIED: NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE (AUDIT): PASS/FAIL`
- `READY FOR NARROW PROMPT 127: YES/NO`

Only stage exact Prompt/Response 126 for a documentation commit on conformance PASS; never stage unrelated paths. A factual STOP response is preferable to a misleading success. Do not begin Prompt 127 under this prompt.

**STOP.**
