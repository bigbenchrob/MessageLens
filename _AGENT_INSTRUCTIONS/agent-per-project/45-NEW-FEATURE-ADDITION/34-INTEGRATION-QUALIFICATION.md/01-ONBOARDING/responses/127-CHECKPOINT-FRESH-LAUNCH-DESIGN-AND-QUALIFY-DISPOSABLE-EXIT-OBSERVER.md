# Response 127 — Disposable registered exit observer qualified

## Outcome and evidence limit

On this macOS 26.6.2 arm64 host, the isolated parent/helper experiment completed **22 cases**, warning-free compilation and Clang static analysis. Six cases emitted one fixed synthetic sink token each; sixteen emitted none. No case emitted two sinks. Each emitted sink followed a recorded registered-parent `NOTE_EXIT`, with valid readiness, one arm and an unexpired observation window. The deliberately inherited lock descriptor kept the synthetic lock held after parent exit; explicit file-action exclusion and the separately tested `FD_CLOEXEC` mode did not.

This is a measured disposable-process result, not production restart qualification. No MessageLens process was launched or exited. No LaunchServices, `open` application command, shell launch, NSWorkspace, native Runner integration, real archive lock, source/database, permission, bookmark, signing or application admission operation ran. The only sink is a fixed JSON `SYNTHETIC_SINK` event on a fixture-owned pipe. No coordinator state or authority crosses a process boundary.

Source checkpoint: **`c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`**, normally pushed. It contains exactly the two authorized new probe files. The exact Prompt/Response 127 documentation pair is checkpointed separately; the final handoff reports its hash rather than embedding it here.

## Verified baseline and preservation

Branch `fix/onboarding-import-stuck-state`, initial HEAD `523a48d3a71ef102e9e6d37db3c04a7505ad9aad`, upstream `0/0`, tracked tree/index clean. That HEAD already contains exactly Prompt/Response 126. Its ancestry and reviewed contents were verified, so no duplicate prerequisite documentation commit was made.

Both `tool/macos_fresh_launch_probe.c` and `tool/macos_fresh_launch_probe_test.py` were absent before work. `/private/tmp/prompt127-baseline.json` records **6,030 tracked regular files and 50 untracked files** (Prompt 127 plus 49 unrelated). All baseline bytes remain unchanged. The navigation README, restored historical documents and three `_ARCHIVED` scripts are preserved and were not staged. Only the primary worktree advances:

| Worktree | Baseline HEAD |
| --- | --- |
| `remember_every_text` | `523a48d3a71ef102e9e6d37db3c04a7505ad9aad` |
| `remember_every_text-feature-35` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `remember_every_text-main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `remember_every_text.worktrees/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

Shared instructions remain clean at `95326f515ef4719f155ce6e223990398daad6311`. Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`, and Prompt 126 are ancestors. All 17 Stage 2 and six Source Access qualification hashes match. The complete tracked-file manifest independently protects all application code, six specialist hosts, Operating, seven jurisdictions, reset denial and unconditional production activation OFF.

## Characterization before sink classification

The first C/Python implementation contained **no sink classifier**. It only took a private lock, directly spawned itself in helper mode, explicitly closed the helper's copy of the lock descriptor, checked parent relationship around process-filter registration, and returned readiness over a private pipe. It compiled with `-std=c11 -Wall -Wextra -Werror -O0` and ran with exit 0. Tool output recorded:

- `descriptor_closed: 1`;
- `parent_before: 1`, `parent_after: 1`;
- `registration_result: 0`, `registration_errno: 0`;
- `same_child_ack: 1`, `child_reaped: 1`, `sink_count: 0`;
- temporary root removed.

This established actual API availability before success expectations for an exit-triggered sink were added. The first complete matrix had 19 passing cases. Review then strengthened readiness with a parent confirmation, added three adversarial cases, shared the physical/duplicate-event sink gate, and applied a real shared cleanup-evidence refusal gate. The 22-case intermediate matrix also passed. These are development observations, not substitutes for the final run below.

## Exact implementation and ownership

### C probe

`tool/macos_fresh_launch_probe.c` is self-contained, with parent/helper modes only. The driver executes the compiled probe; parent uses direct `posix_spawn` of that same executable with a minimal `LANG=C` environment. No argument selects another executable or application target. `open("fixture.lock", O_CREAT | O_EXCL | O_RDWR, 0600)` is a POSIX fixture-file open in the driver's unique temporary directory, not the macOS application-launch command.

The driver passes one helper-control pipe read descriptor to the parent. The parent creates a private socket pair for readiness, acquires the temporary exclusive lock, and configures spawn file actions to close parent-only descriptors in the helper. Normal mode explicitly closes the lock descriptor. A separate mode sets `FD_CLOEXEC`; a negative-control mode intentionally retains it. Helper checks descriptor presence with `fcntl(F_GETFD)` before opening kqueue, avoiding descriptor-number reuse in that measurement. No child calls `LOCK_UN` on an inherited reference.

Helper is initially held on a `G` barrier. It verifies `getppid()` against the originating parent's recorded PID, registers `EVFILT_PROC` with `EV_ADD | EV_ONESHOT` / `NOTE_EXIT`, checks the registration result and rechecks the parent relationship. Only then does it announce registration. A separate `R` barrier allows readiness. The helper sends readiness on its dedicated socket; parent reads it and sends a `V` confirmation. Helper requires that confirmation and a still-matching parent before announcing ready. A write alone is not treated as received readiness.

The driver arms only after both readiness observations. One arm is admitted; a second arm seals/refuses. Helper uses the same kqueue for registered parent exit and control readability. Queued disarm/invalidation/duplicate commands are processed before a returned exit event is considered. `consider_exit` is the shared sink gate for the physical event and the injected duplicate event. It requires armed, not sealed, eligible and within deadline, then seals before emitting the fixed token. Acknowledged disarm and expiry are terminal for sink admission even if the parent exits later. An unacknowledged disarm racing an already-observed exit is not claimed safe; callers must await acknowledgment before relying on disarm.

The eligibility control is a synthetic Boolean invalidation, not a signed bundle token or identity check. The helper never acquires archive authority and never chooses a successor jurisdiction.

### Driver and cleanup

`tool/macos_fresh_launch_probe_test.py` uses only Python standard library. It compiles into a unique temporary directory and runs cases serially. The driver is the parent process's direct owner. Before allowing the helper through `G`, the driver independently registers that helper's `NOTE_EXIT`; this is an exit witness for the known held helper, not subsequent `kill(pid, 0)` lookup.

The parent reaps helpers when it remains alive. In parent-exit cases, the helper is necessarily reparented; the driver **cannot waitpid a grandchild** and does not claim it did. Instead it verifies the pre-registered helper exit event, pipe EOF and released fixture lock. The OS handles the reparented process's reaping. Driver directly waits/reaps each parent; no live helper is left intentionally. Process exit closes the helper's remaining handles and cancels its alarm; the driver explicitly closes its pipes, selector and kqueue. Temporary locks/directories and the compiled executable are removed only after fixture completion.

Emergency signaling is restricted to an unreaped direct child: C's retained direct helper PID, or Python's owned Popen parent/compiler child. No process-name kill, PID scanning, installed-app PID or grandchild signal by numeric lookup exists. On ambiguous helper observation, cleanup raises STOP rather than claiming success. A watchdog exit is not accepted as a successful ordinary case.

### Bounded resources

| Resource | Bound / ownership |
| --- | --- |
| Active fixture processes | Maximum 2: disposable parent and helper; cases serial. Compiler runs separately before fixtures. |
| Arm attempts | One admitted; duplicate request seals/refuses; at most 16 helper commands. |
| Readiness/control waits | 2,000 ms C deadline; driver phase wait at most 3 seconds. Socket readiness needs parent confirmation. |
| Armed observation | 800 ms; expiry denies sink and does not kill parent. |
| Helper fixture lifetime | 6,000 ms; expiry of total fixture lifetime is an error, not successful cleanup. |
| C emergency watchdog | 8-second alarm, only on the disposable process itself. |
| Output | 64 events/process, each under 200 bytes; driver enforces 16,384 bytes/fixture while reading. Compiler output is bounded while reading too. |
| Driver | 12-second case deadline; suite launch budget 150 seconds checked before each bounded case; compiler 20 seconds. |
| Failure cleanup | Direct-child waits bounded at 3 seconds; registered helper exit wait at most 9 seconds for emergency watchdog. No indefinite observation loop. |

The suite budget is an admission deadline for starting cases, not a promise to abandon owned cleanup at exactly 150 seconds. Cleanup is still bounded and must complete or be reported UNKNOWN. The C `waitpid(WNOHANG)` cleanup loop uses a finite deadline and short sleep only for reaping its own child; it is not the process-exit classification mechanism or a launch polling service.

## Actual compiler/runtime and final validation

- Host: `macOS-26.6.2-arm64-arm-64bit`.
- Python: 3.9.6, built with Clang 17.0.0 (`clang-1700.3.19.1`).
- Compiler: Apple Clang 17.0.0 (`clang-1700.3.19.1`), target `arm64-apple-darwin25.6.0`.
- Direct compiler: `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang`.
- Explicit SDK: `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`.
- Final flags: `-std=c11 -Wall -Wextra -Werror -O0 -isysroot <that SDK>`.
- Compiler environment: only `LANG=C` and `TMPDIR=<driver-owned temporary root>`; no inherited application/development-root environment.

Final command:

```sh
python3 tool/macos_fresh_launch_probe_test.py
```

**Exit 0, 22 cases, compile exit 0, zero diagnostic bytes.** Attributable log: `/private/tmp/prompt127-probe-final-qualified.log`. Final six emitted sinks all followed physical `NOTE_EXIT`; sixteen cases emitted zero. Temporary suite root removal was confirmed.

Static analysis:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang --analyze -std=c11 -Wall -Wextra -Werror -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk tool/macos_fresh_launch_probe.c -o /private/tmp/prompt127-static-qualified.plist
```

**Exit 0, no diagnostics; plist diagnostics array empty.** Python AST parsing passed without writing bytecode. Working/staged whitespace checks passed; new untracked-file `git diff --no-index --check /dev/null <path>` produced no diagnostics (exit 1 denotes the new-file differences). Exact staged bytes matched `/private/tmp/prompt127-qualified-hashes.json` before source commit.

Two final-run setup attempts stopped **before fixtures** while hardening compiler environment isolation. With only `LANG=C`, the `/usr/bin/clang` wrapper could not create a temporary file; after assigning private TMPDIR, compilation returned 0 but developer-tool-wrapper cache diagnostics caused the strict no-diagnostics gate to refuse the run. Logs: `/private/tmp/prompt127-probe-final.log` and `/private/tmp/prompt127-probe-qualified.log`. The correction was direct use of the already-inspected Clang executable and explicit SDK with private TMPDIR. No OS assertion, sink rule, compiler warning flag or expected observation was weakened. No elevated execution was requested for the experiment.

Application/native/Flutter runtime suites, generators and release builds were excluded: no application code changed, and the prompt authorizes only standalone native fixture execution. Source guards instead verified no references to the probe from `lib`, `macos`, `test` or `pubspec.yaml`; no shell/application-launch APIs in the new source; exact allowlist; complete baseline hashes; and unchanged activation/host/reset sources. These checks are not reported as a fresh 644-test architecture-suite run.

## Adversarial results — propositions and evidence classes

Every row below is from the final 22-case command unless described as injection. PASS means the named observable proposition held, not arbitrary production correctness.

| Scenario | Observable result | Evidence class |
| --- | --- | --- |
| normal | Parent live at confirmed readiness; registered exit precedes exactly one sink; helper exit/EOF/lock release confirmed. | Actual spawn, kqueue and exit. |
| inherit | Descriptor present; separate driver cannot acquire lock before **or after** parent exit while helper holds inherited copy; helper closes it without unlock; contender then succeeds. One synthetic sink. | Actual deliberate inheritance negative control. |
| cloexec | Helper sees no inherited lock descriptor; after parent exit contender succeeds while helper still alive. One sink. | Actual FD_CLOEXEC construction mode. |
| wrong_parent | Injected parent+1 fails relationship check before registration; zero sink. | Synthetic ID mismatch; actual refusal. |
| early_parent | Parent exits before helper registration barrier; changed relationship refuses; zero sink. | Actual controlled early exit. |
| before_ack | Parent exits after registration but before readiness barrier; no readiness and zero sink. | Actual registered-process/early-exit ordering. |
| registration_failure | Invalid kqueue descriptor injected; actual `kevent` returns EBADF; zero sink, no fallback registration. | Injected input, actual API error. |
| missing_readiness | Helper intentionally withholds readiness and exits; parent sees no readiness; zero sink. | Injected omission, physical child exit/EOF. |
| spawn_failure | Empty executable pathname produces actual spawn error; no helper created, zero sink. | Injected invalid path, actual spawn denial; no arbitrary target. |
| helper_death | Helper exits on start barrier before registration; parent gets no readiness; zero sink. | Controlled actual premature exit. |
| stale_identity | Recorded ID replaced by 1; relationship check refuses before attachment. | Synthetic stale-ID control, not real PID reuse. |
| readiness_timeout | Helper withholds acknowledgment across bounded wait; readiness expires, zero sink. | Injected stalled readiness; actual bounded waits. |
| unconfirmed_ack | Parent receives helper acknowledgment but withholds confirmation; helper refuses, zero sink. | Injected missing confirmation over actual socket. |
| disarm | Acknowledged disarm while parent alive; later actual parent exit produces refusal, zero sink. | Actual protocol barrier and registered exit. |
| duplicate_arm | Second arm seals/refuses; later actual exit emits zero sinks. | Duplicate request through actual pipe. |
| expiry | Observation expires; parent remains alive and holds lock; later exit emits zero sinks. | Actual deadline refusal, not timeout-as-cancellation. |
| pending_parent | Parent deliberately remains live through observation window; no signal sent to it by observer; later controlled exit yields zero sink. | Actual pending-parent/deadline control. |
| force_exit | Armed disposable parent signals itself SIGKILL; driver observes -SIGKILL; NOTE_EXIT precedes one sink. | Actual fixture-only forced exit; no graceful-drain claim. |
| unarmed_force | Same actual self-SIGKILL without arm; registered exit but zero sink. | Actual fixture-only forced exit and refusal. |
| invalid_target | Boolean eligibility invalidated before exit; zero sink. | Synthetic state-machine control only; not bundle validation/TOCTOU. |
| duplicate_event | Physical exit emits one sink; injected second notification calls the same sink gate and emits no second sink. | One actual event plus explicit synthetic duplicate. |
| cleanup_error | Physical fixture cleanup confirmed; injected error passed to the **same** cleanup-evidence gate raises `UNKNOWN/STOP`; separately rechecking actual evidence succeeds. | Synthetic reporting ambiguity, not a leaked-process experiment. |

Cleanup evidence for each created helper: independently registered helper NOTE_EXIT; parent direct-child wait; stdout EOF with no partial record; lock available; driver handles closed; fixture directory removed. Spawn-failure has no helper and is explicitly recorded as such. No claim is made that a grandchild was directly reaped by Python or that its unrelated numeric PID was later absent.

**Identity proposition:** in the tested topology, helper observed its live direct parent, successful registration, matching relationship afterward, and parent-confirmed readiness before arming. It never reattached after failure. **Not established:** immunity to every possible real PID-reuse schedule, other supervisors/process topologies, different OS releases, installed app lifecycle or adversarial host interference. Stale-ID controls are simulated and labelled.

## Qualified source hashes

| New path | SHA-256 |
| --- | --- |
| `tool/macos_fresh_launch_probe.c` | `8d7f79113dcbdf3642e7070c89e970690816ffeb729cd4cd1dbe6c5e7f04b2eb` |
| `tool/macos_fresh_launch_probe_test.py` | `4eee3b1a31bd01f421a219518e514654d913c2c7879b63b2bf2e0798357e5e43` |

## Canonical Project Conformance Audit

Scope: complete two-file delta from `523a48d3`, reviewed while unstaged, now `c5d727a9`; this is a disposable probe audit, not the whole production feature.

**Reviewed against:** repository `AGENTS.md`; shared `00-global/agent-guardrails.md`; project `README.md`; `01-PROJECT/02-architecture-overview.md`; overlay independence and attachment-preservation invariants; `60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`; canonical `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; full Response 126; Prompt 127. The probe uses the [documented kqueue process-exit contract](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/kqueue.2.html), [spawn descriptor rules](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/posix_spawn.2.html), [fcntl descriptor flags](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/fcntl.2.html), [flock inheritance](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/flock.2.html) and [waitpid child scope](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/waitpid.2.html) inspected in Prompt 126; those contracts are distinguished from the fresh observations above.

| Area | Classification / evidence |
| --- | --- |
| Reuse / layering / ownership | NO ISSUE: standalone fixture only, existing OS APIs, no second app coordinator or generic shutdown system. |
| Dependency direction / single source of truth | NO ISSUE: no production imports/callers; no domain state, archive identity, taxonomy or capability copied. |
| Project idioms | NO ISSUE: standard-library Python and standalone C are appropriate to the explicitly authorized native experiment; no Riverpod/generated change. |
| Bounded work / resource ownership | NO ISSUE: declared command/event/deadline/output limits; finite fixture lifecycle, no daemon or launch loop; actual cleanup evidence required. |
| Privacy / mutation | NO ISSUE: fixed synthetic token and temporary lock only; no app/database/archive/source paths or content used. Compiler/SDK paths are toolchain provenance, not launch targets. |
| Error/state semantics | NO ISSUE: readiness requires parent receipt, disarm/expiry seal, failures never become sink permission, ambiguous cleanup raises STOP. |
| Dead machinery | NO ISSUE: characterization-only code evolved into the same two-file probe; no third helper, fallback shell or production compatibility layer. |
| Behavioral/static coverage | NO ISSUE: 22 actual/injected labelled cases, shared duplicate gate, inherited-descriptor negative control, static analysis and source guards. |
| Generated/dependency hygiene | NO ISSUE: no dependencies, native project, generated output or release metadata changed. |
| Documentation agreement | NO ISSUE: failed setup runs recorded; process observation is not application launch/admission; inherited-control limitations explicit. |
| UX | Not applicable: no app UI changed. Signed user-facing behavior remains unqualified. |

Zero unresolved in-scope BLOCKER or SHOULD FIX. No OPTIONAL cleanup proposed. The compile environment setup errors were corrected within the two-file allowlist and the complete final matrix rerun. No observed parent-registration ambiguity, late post-disarm sink, duplicate sink, retained lock in intended mode or unconfirmed live-helper cleanup occurred in the qualified run.

## Remaining production blockers and checkpoint disposition

The experiment does not settle: exact official installed target location; complete code validity and replacement/TOCTOU safeguards; helper packaging/trust; actual Runner lock descriptor inheritance; Source Access restart-owned-future/ordinary-quit separation; older Flutter exit-host exception-to-cancel behavior; LaunchServices execution; native old-process death in a signed app; real FDA continuity; successor native/Dart archive admission; currentness closure; in-place schema/migration and backup/rollback; final signed human rehearsal. No release-readiness or production activation inference follows from a synthetic sink.

All seven jurisdictions, six specialist hosts and Operating, Stage 1/2, Data Update and Source Access remain byte-identical to baseline. Source commit is pushed. Exact documentation pair follows separately; final handoff verifies tracked/index cleanliness, upstream `0/0` and 49 unrelated untracked files preserved. No Prompt 128 work begins here.

DISPOSABLE REGISTERED EXIT OBSERVER: PASS
READINESS AND DISARM BOUNDS: PASS
SYNTHETIC LOCK-DESCRIPTOR EXCLUSION: PASS
INERT LAUNCH SINK AT MOST ONCE: PASS
REAL MESSAGELENS LAUNCH OR EXIT PERFORMED: NO
COORDINATOR STATE/AUTHORITY TRANSFERRED: NO
PRODUCTION PROCESS RESTART IMPLEMENTED: NO
SIX SPECIALIST EXIT HOSTS / OPERATING HOST UNCHANGED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: PASS
READY FOR A SEPARATE PROMPT 128: YES
