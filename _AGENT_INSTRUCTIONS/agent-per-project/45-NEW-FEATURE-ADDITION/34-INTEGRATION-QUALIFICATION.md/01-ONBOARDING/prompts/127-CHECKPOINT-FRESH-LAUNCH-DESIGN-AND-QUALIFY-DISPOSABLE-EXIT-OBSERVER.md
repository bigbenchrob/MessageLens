# MessageLens — Feature 34
## Prompt 127 — Checkpoint Fresh-Launch Design and Qualify a Disposable Exit Observer

**Task:** One bounded macOS process-observation experiment. **Not:** a production restarter, actual MessageLens launch, native Runner integration, process-to-process coordinator handoff, or AppCzar activation.

### 0. Governing architectural decision and Fair Witness

Response 126 concluded that the desired sequence is **coordinator completion → actual process exit → one fresh launch request → independent native/Dart admission and AppCzar reassessment**. No jurisdiction, assessment, archive capability, currentness generation, user data, database handle, UI route, or outstanding work crosses that process boundary. A proposed short-lived external observer/launcher could arrange the next launch, but **the operating-system exit-observation and file-descriptor semantics have not been measured or qualified**. This prompt authorizes only an isolated, disposable experiment with an inert launch sink.

The experiment must answer: Can a directly spawned macOS child, using a registered live-parent `kqueue`/`EVFILT_PROC`/`NOTE_EXIT` observation and bounded readiness/disarm protocol, reliably distinguish observed parent exit from a numeric PID becoming apparently absent; exclude inherited file descriptors; and invoke a synthetic sink at most once? If not, report UNKNOWN/STOP, not a fallback `kill -0` polling launcher.

**Fair Witness:** Separately label source/API inspection, executed macOS probe observations, synthetic fault injection and unqualified production behavior. Test outcomes on probe-owned processes are not evidence of actual Flutter cancellation, MessageLens process death, LaunchServices success, official bundle integrity, FDA continuity, archive admission, or full production safety. Do not describe a successful sink as an application launch. No automatic production AppCzar activation exists; it must remain OFF.

### 1. Baseline and prerequisite checkpoint

1. Inspect actual branch, HEAD, upstream ahead/behind, tracked/index cleanliness, registered worktrees, shared-instructions submodule, and complete tracked/untracked hashes. Expected branch: `fix/onboarding-import-stuck-state`; Response 126 reported HEAD `99f9f46e9ac2b46035128aceafdc91bf4a13fc4d` before its documentation checkpoint, four worktrees, and submodule `95326f515ef4719f155ce6e223990398daad6311`. **Verify, do not assume** current HEAD or unchanged files.
2. Verify the exact Prompt/Response 126 pair under the existing Feature 34 `01-ONBOARDING/prompts/` and `responses/` paths. If still untracked, complete and byte-identical to reviewed originals, checkpoint **only those two documents**, perform whitespace/staged-name checks and push normally before implementation. If already committed, confirm ancestry and do not duplicate. Unexpected changes are STOP conditions.
3. Preserve the onboarding navigation README, restored historical documents, three `_ARCHIVED` backup scripts, 49 or actual current unrelated untracked files, and the other three worktrees. No `git clean`, stash, reset, rebase, branch switch, force-push, or broad `git add`.
4. Re-read Response 126 in full and the canonical Feature 34 Project Conformance standard. Inspect documented macOS `kqueue`, `kevent`, `NOTE_EXIT`, `posix_spawn`, `fcntl`, `flock` and process-parent/exit APIs as needed. Distinguish documentation contracts from experiment results. Do not use external SDK internals as a substitute for actual test evidence.

### 2. Exact source and documentation allowlist

Create **only these two new files**, both absent per Response 126 (verify):

- `tool/macos_fresh_launch_probe.c` — a self-contained C probe executable with disposable parent/helper modes, direct spawn, bounded readiness/observation/disarm, explicit child descriptor closure/exclusion, and a synthetic one-shot launch sink. No production archive/root resolution or LaunchServices.
- `tool/macos_fresh_launch_probe_test.py` — isolated Python test driver that compiles the C probe into a unique temporary directory, runs only probe-owned test processes and lock files, controls barriers, captures outcomes and cleans/reaps every fixture it owns. Standard library only unless an existing local testing convention requires otherwise; STOP rather than adding dependencies.

Documentation only: exact `prompts/127-CHECKPOINT-FRESH-LAUNCH-DESIGN-AND-QUALIFY-DISPOSABLE-EXIT-OBSERVER.md` and matching `responses/127-CHECKPOINT-FRESH-LAUNCH-DESIGN-AND-QUALIFY-DISPOSABLE-EXIT-OBSERVER.md` under Feature 34 `01-ONBOARDING/`. Do not create the response ahead of completed evidence.

**All other repository files are read-only**, including `macos/Runner`, `main.dart`, Flutter/Dart providers, all seven jurisdictions, restarter interfaces/implementations, tests outside the allowlist, native signing/entitlements, archive/lock code, generated files, dependency/lock files, release metadata, and any populated-reconstruction/FTS work. Do not change architecture allowlists or create a third helper file. If safe executable qualification needs another file, STOP and identify it.

### 3. Hard safety boundaries of the probe

- **Never launch MessageLens or any installed application.** Do not call `open`, `NSWorkspace`, LaunchServices, shell commands, AppleScript, app paths, or the user's application bundle. The only "launch" event is an inert sink recording a fixed synthetic token through a probe-owned test channel, with no arbitrary executable target supplied by user input.
- **Never inspect or touch the real MessageLens archive lock.** Use unique temporary directories/files owned by the driver. Synthetic `flock` only on those fixture files. Do not unlock an inherited copy of the parent's descriptor: close it in the child. Do not delete a real lock file or use an existing application path.
- Do not spawn a daemon, install a launch agent/login item, create durable queues/receipts, register helpers with the OS, acquire elevated permissions, or initiate a restart of the running editor/test host. Do not execute real native/app tests under this prompt.
- Use direct `posix_spawn` or an equivalently source-grounded direct process API. No shell `kill -0` loop or `open -n`. Explicitly specify child file actions/descriptor inheritance for the probe; also measure the intentionally inherited-descriptor negative control with synthetic files. If `FD_CLOEXEC` behavior differs by construction mode, report the observed mode and avoid generalizing.
- Finite deadlines and output limits apply to **every** wait. No busy-loop or indefinite observer/parent. Terminate/reap only processes created by this probe, and confirm exact identities before any forced fixture cleanup. Test-only crash/kill of a fixture is permitted but cannot be described as clean application shutdown.
- No arbitrary-code or archive path in the helper protocol. No coordinator/assessment/domain metadata, live source/database, marker, bookmark, bundle identity, signing/FDA request, mutation Ball or archive lease. Avoid leaking unrelated environment and file descriptors.
- Emit bounded structured fixture evidence: scenario identifier, phases, attempts, counters, exit/sink/error classification and timing category. No user content or real absolute application/volume paths in log output. Capture raw diagnostic errors only when synthetic and bounded.

### 4. Characterization before implementing launch classification

Before writing a success-oriented classifier or test expectations, characterize actual macOS process APIs and the C compiler availability. Record exactly which compiler/toolchain/runtime executed. Start with probe-owned parent/helper creation, a direct helper process spawn, a synchronization channel, descriptor inventory/control and registered process observation. Instrument barriers to prove which side was alive at registration and when readiness was acknowledged.

Qualification prerequisites:

1. A helper must register for the **currently alive originating process** using a process filter and check the registration outcome. A subsequent fresh `kill(pid,0)` or numeric lookup must not substitute for registered identity. Do not claim PID-reuse immunity unless the tested API actually supplies it; record the exact identity property established.
2. Readiness must arrive from the **same observed child** over an explicitly owned short-lived channel while the originating process is still alive. The parent must not exit based solely on `posix_spawn` returning success.
3. Before a sink is possible, the helper must be armed for exactly one attempt, hold a valid observation, and be within its bounded deadline. A missing acknowledgment, observer error, early parent exit, wrong relationship, disarm or expiry forbids the sink.
4. The helper must neither inherit nor keep the parent's test-lock reference after exit in the intended mode. The intentionally inherited negative control must demonstrate why descriptor exclusion matters without ever unlocking on the child's behalf.
5. If direct macOS APIs cannot safely establish these premises without introducing an unsupported persistent supervisor or changing the process tree beyond the two allowed files, STOP and document the failed premise rather than upgrading a weaker protocol into success.

### 5. Mandatory isolated adversarial matrix

Use deterministic pipes/barriers/child-event counters wherever possible. Timing deadlines are only bounded failure controls; elapsed time alone does not prove process settlement. The driver must distinguish **observed OS events** from **injected/simulated faults**.

A. **Normal registered exit:** known live parent creates helper; helper registers, acknowledges readiness; sink remains zero while parent is held; parent exits; exactly one sink after recorded NOTE_EXIT. No second launch on duplicate wake/event.

B. **Descriptor exclusion:** fixture parent takes an exclusive `flock` on a private temporary file. During parent lifetime, a separate fixture contender cannot obtain it. In intended helper mode, helper cannot keep the lock owned after parent exit; contender can then obtain it. Add a separately isolated *deliberately inherited descriptor* negative control, verify contention can persist when inheritance is configured, then close the inherited descriptor without `LOCK_UN` and clean up. Attribute differences to actual observed file-action/descriptor state; do not infer real Runner inheritance.

C. **No-registration/no-readiness failures:** wrong parent, parent disappearance before registration/acknowledgment, `kevent` registration failure where safely injectible, absent readiness, failed child spawn, and helper premature death all result in zero sink. Record actual vs injected failure modes.

D. **Disarm, duplicate and expiration:** explicit disarm while old parent remains alive, duplicate arm/request and expired observer each give zero sink. The parent may quit later, but a disarmed/expired helper must not surprise-launch. A refused/delayed quit cannot be turned into successful restart by a timer.

E. **Pending parent:** parent remains alive across a bounded observation window; helper expires/refuses without killing parent or invoking sink. Ensure fixture-owned cleanup eventually terminates/reaps its own processes only.

F. **Identity mismatch and ambiguity:** inject stale/wrong recorded IDs or parent relationship mismatch and demonstrate refusal; do not call it a real PID-reuse experiment. A failed observation must not reattach to some later process with the same numeric PID.

G. **Fixture force-exit:** controlled signal/crash of disposable parent can produce a NOTE_EXIT event and at most one synthetic sink if the protocol was armed. Clearly state it does **not** prove graceful controller drain or general crash recovery; unarmed force-exit never invokes sink.

H. **Synthetic target eligibility:** change/invalidate a probe-owned fixed eligibility token before sink, or inject an expired/mismatched token; verify zero sink. This is only a state-machine/fault-injection control, **not** signed bundle validation, target integrity or TOCTOU qualification.

I. **Cleanup:** verify no surviving probe-owned helper, orphaned pipe, timer, claimed test lock, open handle or temporary fixture root at completion. Include injected cleanup errors and record UNKNOWN/STOP rather than declaring success after ambiguous cleanup. Track spawned PIDs with parent/child ownership; never terminate by process name or generic pattern.

Every expected TRUE, FALSE or UNKNOWN in the report must name the specific observable proposition. A successful ordinary scenario is not an all-purpose success result if another scenario fails.

### 6. Resource/lifecycle contract

Declare bounded constants in the probe/driver: maximum one arm per helper, finite helper observation deadline, finite readiness/disarm deadline, maximum fixture process count, maximum log/output bytes, bounded driver runtime and deterministic cleanup ordering. On an OS wait that cannot be interrupted or confirmed quiescent, refuse to claim clean completion. The parent owns its children in fixtures; the helper must never acquire production archive authority. No daemon or background process may survive the driver intentionally.

Compile with suitable warnings enabled (e.g. `-Wall -Wextra -Werror` where supported) and record exact flags/toolchain. An unsupported macOS compiler/API is a truthful STOP, not grounds to replace the C process observer with a shell or mock-only implementation. Test outcomes from Python subprocesses remain fixture evidence; report which scenarios used actual `kqueue` versus injected outcomes.

### 7. Verification, conformance and STOP gates

Run the entire isolated probe test driver with exact command, exit status, test/case counts and attributable logs. Validate warning-free compilation and any applicable static checking/formatting conventions without expanding repository scope. Inspect complete source for forbidden app paths, LaunchServices/open/shell launch, global persistent state, descriptor leaks, disallowed privileges and nondeterministic unbounded loops. Run the prescribed architecture/source guards only if they can be screened and executed without native app, real DB, archive tenure or user data; otherwise report exact exclusions rather than giving generic PASS. Perform `git diff --check`, exact staged-file inventory and full tracked/untracked baseline hash comparison.

Perform the canonical Project Conformance audit. **PASS requires zero in-scope BLOCKER and SHOULD FIX.** No application behavior was changed; source code review must verify no production import or invocation of this tool. STOP without success commit if observed process registration is ambiguous, the helper can keep the parent's lock in intended mode, disarm/expiry allows a late sink, a duplicate sink fires, cleanup leaves a helper alive, a real application operation becomes necessary, a third file is needed, or any required deterministic gate cannot be qualified. Do not weaken an assertion to rescue an unsound OS protocol.

On PASS only: commit/push exactly the two new probe files as one implementation checkpoint; separately commit/push exact Prompt/Response 127 documentation. On STOP: leave project and user files preserved, report reproducible findings and explicit unqualified cases; do not commit a false success. Preserve all four worktrees and shared submodule. Avoid self-referential docs hashes inside the response; put resulting hash in the final Codex handoff.

### 8. Required Response 127

Produce the complete Markdown response under the existing Feature 34 `01-ONBOARDING/responses/` directory. Report:

- Verified baseline, Prompt/Response 126 checkpoint and hash-preservation/commit disposition.
- Exact C/Python implementation, compiler, API calls, descriptor semantics, readiness/disarm/timeout ordering and what actual parent identity was observed.
- Each adversarial scenario's observed outcome, any injected versus physical controls, and cleanup results.
- Whether an acknowledged observer can reliably defer an **inert** one-shot sink until after the registered parent exit, under the tested OS/runtime.
- Why this says **nothing by itself** about MessageLens signed target identity, actual lock inheritance, Flutter error/exit listeners, LaunchServices, FDA, successor native/Dart admission or release readiness.
- Exact commands/counts/exit statuses, conformance findings, source/docs commit IDs and remaining native production-blocker inventory.

End with literal status lines:

`DISPOSABLE REGISTERED EXIT OBSERVER: PASS/FAIL/UNKNOWN`

`READINESS AND DISARM BOUNDS: PASS/FAIL/UNKNOWN`

`SYNTHETIC LOCK-DESCRIPTOR EXCLUSION: PASS/FAIL/UNKNOWN`

`INERT LAUNCH SINK AT MOST ONCE: PASS/FAIL/UNKNOWN`

`REAL MESSAGELENS LAUNCH OR EXIT PERFORMED: NO`

`COORDINATOR STATE/AUTHORITY TRANSFERRED: NO`

`PRODUCTION PROCESS RESTART IMPLEMENTED: NO`

`SIX SPECIALIST EXIT HOSTS / OPERATING HOST UNCHANGED: YES/NO`

`STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`

`PRODUCTION APPCZAR ACTIVATION: OFF`

`PROJECT CONFORMANCE: PASS/FAIL`

`READY FOR A SEPARATE PROMPT 128: YES/NO`

**STOP.** Do not integrate the probe into native Runner, build a production launcher, install a helper, execute a real quit/restart, change signing, or reactivate populated reconstruction under this prompt.
