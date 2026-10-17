# Response 128 — STOP: Onboarding drain omits admitted Settings work

## Disposition

**STOP before implementation or executable qualification.** Source inspection found an owner-quiescence defect outside Prompt 128's allowlist. No application, test, architecture, generated or probe file was changed. Only this factual response was added, unstaged. No source or documentation success checkpoint was created, and nothing was pushed.

The governing instruction is Prompt 128 §4.3:

> If a controller's **successful** drain currently conceals unsettled work, that is a separate owner defect: **STOP and report it**, not a reason to add a broad catch or unconditional exit.

Section 6 also makes a controller-quiescence defect outside the allowlist a mandatory STOP. Adding the five requested listener catches would not repair the successful-but-incomplete Onboarding drain described below.

## Verified baseline

- Branch: `fix/onboarding-import-stuck-state`.
- HEAD: `12462fdbea09c64dfe45d262f3b1c487a93fcda4`; upstream ahead/behind `0/0`.
- Initial tracked tree and index clean.
- Probe source checkpoint `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2` is an ancestor; both probe hashes match `/private/tmp/prompt127-qualified-hashes.json`. Probe files were not executed or edited.
- HEAD already contains exactly Prompt/Response 127 as a separate documentation pair. No prerequisite checkpoint was duplicated.
- `/private/tmp/prompt128-baseline.json` records 6,034 tracked regular files and 50 untracked files: Prompt 128 plus 49 unrelated files. All baseline bytes remain unchanged; this response is the sole new file.
- Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798` remain ancestors. All 17 recorded Stage 2 hashes match.
- Shared-instructions submodule remains clean at `95326f515ef4719f155ce6e223990398daad6311`.

Registered worktrees remain:

| Worktree | HEAD |
| --- | --- |
| `remember_every_text` | `12462fdbea09c64dfe45d262f3b1c487a93fcda4` |
| `remember_every_text-feature-35` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `remember_every_text-main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `remember_every_text.worktrees/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

Navigation README, restored historical documents, three archived backup scripts, all unrelated files and other worktrees are preserved. Final disposition is unchanged HEAD, clean tracked tree/index, and 51 untracked files: 49 unrelated plus exact Prompt/Response 128.

## Concrete source finding

**BLOCKER — Onboarding's successful drain does not establish settlement of an admitted Settings-open request.**

Repository-relative source anchors:

1. `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart:91`: `openSystemSettings()` admits an explicit action while the state permits checking/Settings and `_accepting` is true. At line 98 it awaits `realFdaSettingsOpeningAuthorityProvider.openSettings()` directly. It does not assign that future to `_activeRun` or any separately retained Settings flight.
2. The same file, lines 122–131: `stopAndDrain({bool restart = false})` seals admission and increments generation, then waits only for a snapshot of `_activeRun`. With the default `restart: false`, no other work is awaited.
3. `_schedule` at lines 134–153 owns the prerequisite/build run and clears `_activeRun` when it settles. The source-denied/unavailable prerequisite path publishes `sourceNeedsHuman` and returns (lines 203 onward). Thus a stable waiting-for-human state with `_activeRun == null` is an ordinary reachable state, not an artificial invalid combination.
4. `lib/essentials/onboarding/application/real_fda_settings_opening_authority_provider.dart` constructs `FdaSettingsOpeningAdapter` from `fullDiskAccessProvider`. The adapter's `openSettings()` forwards the underlying `Future<void>` unchanged.
5. `lib/essentials/onboarding/infrastructure/system/macos_full_disk_access.dart:45` awaits `Process.run` for the Settings navigation request. Source inspection does not establish synchronous completion or any contract preventing that future from remaining pending. This native method was **not executed**.
6. `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart:355`: the Onboarding listener awaits this controller's `stopAndDrain()` and then returns `AppExitResponse.exit`.

The source-derived counterexample is therefore:

- Onboarding finishes its initial synthetic-or-real prerequisite run and waits for human source access; `_activeRun` is null.
- An explicit Settings action starts and its awaited port future remains pending.
- An exit callback invokes `stopAndDrain()`. It closes admission but has no retained reference to that already-admitted Settings action, so it can complete successfully.
- The listener returns exit permission while the Settings action is still pending.

This is a source-derived asynchronous ordering, **not an executed callback reproduction or a claim that Settings was launched on this Mac**. A catch around the listener cannot detect it: no drain exception is required. A related source observation is that the Settings error handler calls `_publish` without a post-await admission/generation check, and `_publish` itself is unconditional (lines 338–340); a late error can therefore attempt publication after sealing. Neither owner behavior was changed.

Settings-request settlement is not permission/FDA grant. Tracking and awaiting the request would prove only that the admitted action settled, not that the user granted access or that an external Settings window closed.

## Listener inspection and qualification status

The described five unguarded listeners are present. There is no duplicate alternate catch-to-cancel implementation to add.

| Listener | Current source inspected | Prompt 128 runtime result |
| --- | --- | --- |
| Diagnostic Review | Awaits controller drain, then exit; no explicit Object-to-cancel guard. | Not executed; STOP reached. |
| Onboarding | Awaits controller drain, then exit; no guard, and owner omits Settings flight. | Not executed; source BLOCKER above. |
| Local Data Repair | Awaits controller drain, then exit; no explicit guard. | Not executed; STOP reached. |
| Attachment Archive Repair | Awaits controller drain, then exit; no explicit guard. | Not executed; STOP reached. |
| Data Update | Existing captured-owner await and explicit error-to-cancel preserved. | Historical qualification only; not rerun. |
| Source Access Repair | Existing captured-owner await and explicit error-to-cancel preserved, including active-restart refusal. | Historical qualification only; not rerun. |
| Operating | Separate listener returns the drain helper's future; helper awaits occurrence-specific drain without catch. | Not executed; STOP reached. |

Six specialist listener constructions and one separate Operating listener remain unchanged. Host mounting/disposal, exact ownership, repeated requests, synchronous/asynchronous errors, pending futures and Source Access refusal have **not** received new executable qualification in this task. Existing controller sources and relevant presentation tests were inspected before identifying the STOP; no safe fake was replaced by a real worker to obtain runtime evidence.

## Minimum scope needed before resuming

A separate explicit amendment must first address Onboarding-owned Settings work. Existing paths confirmed for that narrow owner correction are:

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart` — retain admitted Settings work, integrate it into synchronous sealing/actual drainage, suppress late publication and preserve existing permission-UNKNOWN semantics. Account for multiple admitted requests; do not merely record the latest future and lose an earlier one.
- `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart` — controlled inert Settings future proving pending action blocks drain, late results cannot publish after sealing, errors fail closed where required, and no new action is admitted after stop.
- Its existing generated companion `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart` only if normal generation changes it. Prompt 128 presently forbids that controller edit and generator run.

The already-allowed harness test can subsequently exercise the real registered callback against that corrected owner with all source/Settings/restarter/build seams inert before construction. A meaningful regression must prove the pending Settings future prevents exit permission and explicitly release it during cleanup. This is a scope recommendation, not an implemented correction or permission to begin another prompt. Do not broaden into a general restart redesign.

Once the owner contract is independently qualified, resume the five-listener exception-to-cancel work and the required red/green, seven-host architecture and analyzer gates. Do not label the current source listener-safe merely by wrapping its successful drain in try/catch.

## Verification and canonical conformance

Executed: repository/source reads, Git ancestry/status/worktree/submodule inspection, full SHA-256 baseline capture/comparison, probe and Stage 2 hash comparison, listener count/activation inspection and whitespace checks. No Flutter/Dart tests, builds, analyzer, generator, C/Python probe, app launch/quit or native permission/data operation ran. There were no SDK-cache interruptions or expected-red test results to report. Required runtime/architecture/analyzer/format gates are **NOT RUN because of the mandatory source STOP**, not PASS.

Reviewed against repository `AGENTS.md`, global guardrails, project README/architecture and data-preservation rules, canonical `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`, Prompt 128 and the verified prior checkpoints. Scope is the proposed listener change against `12462fdb`; no implementation delta exists.

- **BLOCKER:** Onboarding owner quiescence defect above, violating Prompt 128 §4.3/§6 prerequisite. Smallest correction belongs in the owner, outside this allowlist.
- **NO ISSUE:** preservation, unchanged authority/jurisdiction structure, no dependencies/generated changes, no logging/privacy/data mutation, no launcher or coordinator-state transfer introduced.
- **NOT QUALIFIED:** five listener error-to-cancel corrections, runtime ownership/disposal and pending/error matrix, fresh architecture/analyzer results.
- UX/release behavior was not changed or runtime-inspected. No OPTIONAL cleanup proposed.

Conformance cannot pass with the unresolved prerequisite BLOCKER. Exact Prompt/Response 128 remain unstaged, with no success commit. Existing quiescence/observer evidence is preserved as historical evidence.

Remaining production unknowns remain literal: normal versus required OS termination, actual MessageLens process death, archive-lock release, one-shot launcher packaging/identity, LaunchServices, successor native/Dart admission, FDA/signed-runtime continuity and in-place data continuity. Production activation remains unconditionally OFF.

SPECIALIST EXIT FAILURE-TO-CANCEL QUALIFIED: NO
OPERATING EXIT FAILURE-TO-CANCEL QUALIFIED: NO
SIX SPECIALIST + ONE OPERATING HOSTS PRESERVED: YES
COORDINATOR-TO-COORDINATOR HANDOFF INTRODUCED: NO
REAL PRODUCTION FRESH-LAUNCH IMPLEMENTED: NO
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: FAIL
READY FOR SEPARATE PROMPT 129: NO
