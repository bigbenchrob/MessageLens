# MessageLens Feature 34
## Response 35 — Correct Advanced Start Fresh Single-Flight Admission and Immediate Feedback

## Verdict

Advanced Start Fresh now admits one user request synchronously and retains that
claim from the first current-state read through authorization, service execution,
verified-virgin publication, Journey handoff, and overlay dismissal. Calls made
while that request is active join the exact active Future; they cannot start a
second read, dialog, presentation occurrence, or service execution.

The Settings action now acknowledges the first tap immediately, remains visibly
busy and disabled while classification runs, and the confirmation action prevents
double submission while transitioning promptly to the existing preparation
presentation. The implementation preserves the Prompt 32 currentness correction,
the Feature 35 mutation-authority boundary, Journey semantic authority, and the
existing Start Fresh destructive scope.

---

## 1. Baseline and virgin-state preservation gate

The pre-edit gate passed:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD and upstream: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Prompt 32 tracked diff SHA-256:
  `c241e850a739db92684af6f015822eda6a42999790c7a3008a7d9ba2298d9aad`;
- Response 32 and Response 34 bytes: unchanged;
- pre-edit `git diff --check`: PASS.

A fresh external manifest was written to
`/private/tmp/messagelens-prompt35-baseline-20260930T143213-0700.txt`.
Its SHA-256 is
`01d65a0b721278178391ae535909bd1ab83b05358d4741946e160c96d3040ecf`.

The development app was not running before work began and was not launched. The
opening and closing read-only fingerprints of the virgin development state match
exactly. The import database remains absent, the graph remains valid and empty,
the operation snapshot remains idle, both named favourite intents remain set,
and the Toshiba archive configuration remains unchanged.

## 2. Exact pre-edit file scope

The declared Prompt 35 production scope was:

1. `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`;
2. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`;
3. its generated provider file;
4. `lib/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart`;
5. its generated provider file;
6. `lib/features/settings/application/sidebar_cassette_spec/actions/settings_action_list_actions_provider.dart`;
7. its generated provider file;
8. `lib/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart`;
9. `lib/essentials/onboarding/presentation/start_fresh_authorization_dialog.dart`.

The declared test scope was the corresponding action, provider, presentation,
authorization-dialog, Settings-action interaction, and narrow Start Fresh
architecture tests. No Journey coordinator, Feature 35 runtime, reset service,
favourites, Contacts, import/rich-text pipeline, archive relocation/adoption, or
release-metadata file was in scope.

## 3. Selected single-flight design

`AdvancedStartFreshActionImpl` owns a local, in-memory active-request claim. The
first `request()` call claims synchronously and starts one retained execution.
Every `request()` or `retry()` made before that execution's terminal release
returns the same active Future. The mechanism is deliberately local to Advanced
Start Fresh; it is neither a time-window debounce nor a new global authority.

The Settings action provider adds only immediate local presentation feedback and
activation disablement. Correctness does not depend on that UI layer because the
action independently enforces single-flight admission.

## 4. Synchronous claim point

`request()` calls `_claimRequest()` before crossing any asynchronous boundary.
The claim and its completion Future are stored before current-state reading,
authorization, presentation occurrence creation, or service invocation. A narrow
architecture assertion verifies that ordering and forbids timer-based debounce or
an unretained execution Future.

## 5. Duplicate-request behavior

While a request is active, duplicates:

- return the identical active Future;
- do not invoke the current-state reader again;
- do not request another authorization route;
- do not mint another presentation occurrence;
- do not invoke `StartFreshService` again;
- cannot replace or mask the active request's terminal result.

This applies equally to direct requests and retries attempted during an active
request.

## 6. Request identity and lifetime

Each admitted request receives one private, non-persisted request ID. The same ID
is carried through classification, authorization, presentation, service,
terminal publication, and release diagnostics. It is not Journey state and does
not confer mutation authority.

On verified success, the claim remains held while the verified-virgin / Starting
Onboarding occurrence is current and until the exact occurrence is dismissed by
the existing Journey reconciliation. Thus the request lifetime covers the whole
human-visible handoff, not merely the destructive service Future.

## 7. Red-action immediate-feedback correction

The reset row now has macOS-appropriate hover and pressed surfaces derived from
semantic theme tokens. On the first accepted tap, its provider records the active
intent synchronously. The row immediately changes to an indeterminate activity
indicator and `Checking reset availability…`, becomes semantically disabled, and
uses the disabled cursor. No percentage or mutation claim is fabricated.

## 8. Slow-classification feedback behavior

The checking state remains visible for the entire bounded current-state read.
The row cannot dispatch again during that interval, and the action itself rejects
any duplicate that bypasses the widget. No authorization occurrence exists until
the classification returns eligible. Typed ineligible and unavailable-state
results remain the terminal visible outcomes for their respective paths.

## 9. Authorization single-route correction

One admitted eligible request calls the authorization port exactly once. While
that Future is pending, all duplicate calls join the active Future and perform no
second classification or navigation. Cancellation publishes no preparing
occurrence, invokes no service, releases the claim, and permits a later request.

## 10. Confirmation double-submit prevention

The authorization dialog synchronously claims its local submission before
dismissing. The accepted button immediately changes to `Starting…`; both Cancel
and Start Fresh become inactive; and the route returns `true` exactly once.
Repeated direct callback invocation cannot pop or submit twice. No delayed or
timer-based transition was introduced.

## 11. Service single-invocation correction

After the one authorization is accepted, the same admitted request publishes the
existing preparation occurrence and calls `StartFreshService` exactly once.
During a blocked service Future, duplicate requests return the active Future and
cannot start another service or presentation occurrence.

## 12. Verified-success presentation ownership

The admitted request alone owns its occurrence. A verified-virgin service result
publishes the existing verified-success / Starting Onboarding phase on that same
occurrence. The action then awaits dismissal of that exact occurrence before
releasing its claim. Since duplicates cannot mint a newer occurrence, neither an
authority-denied result nor an already-virgin result can supersede the successful
destructive outcome.

Existing stale-result protection remains intact for genuinely obsolete work;
Journey remains the sole authority for onboarding phase and handoff semantics.

## 13. Terminal release semantics

- **Cancel:** zero service calls, claim released after cancellation; a later
  request can run.
- **Ineligible:** existing typed ineligibility is shown, zero service calls, then
  the claim releases.
- **Read failure:** existing typed unavailable-state feedback is shown, zero
  service calls, then the claim releases without an uncaught error.
- **Service failure:** the admitted occurrence publishes the existing typed
  failure; duplicates cannot mask it; the claim releases according to the
  existing failure contract, and a later retry can begin.
- **Verified success:** release occurs only after the exact success occurrence is
  dismissed during Journey handoff.

## 14. Privacy-safe lifecycle diagnostics

A typed lifecycle reporter records: request received, request claimed, duplicate
joined, current-state read start/end and classification, authorization requested
and cancelled/accepted, service start/end, terminal outcome, and request release.
The stable provider maps these events to the existing app logger using only event
name, private request ID, and non-content detail. Reporter failures cannot change
flow or authority. No message/contact content or request ID is persisted.

## 15. Slow-reader duplicate-request test result

PASS. A deterministic Completer holds the current-state read. Two requests return
the identical Future; the reader is called once; authorization has not started;
and no presentation occurrence exists before the barrier is released.

## 16. Authorization-pending duplicate test result

PASS. A deterministic authorization barrier proves one reader invocation, one
authorization invocation, no service execution before acceptance, and no second
classification or route after duplicate requests.

## 17. Service-pending duplicate test result

PASS. A deterministic service barrier proves one service invocation and one
presentation occurrence. Duplicate input joins the original Future without
altering the occurrence.

## 18. Destructive success under duplicate input

PASS. The Response 34 concurrency shape is reproduced without real I/O. Under
duplicate calls, the admitted service publishes verified virgin, Journey handoff
is requested once, the successful occurrence remains current until dismissal,
and neither an authority-denied nor an already-virgin duplicate failure appears.

## 19. Cancel, failure, and retry results

PASS. Deterministic tests cover cancellation followed by a new successful
request, typed ineligibility, typed reader failure, service failure without
duplicate masking, and the pre-existing retry contract. Every terminal path
releases safely at its specified boundary.

## 20. UI hover, pressed, busy, and disabled results

PASS. Widget tests verify the idle reset row is clearly enabled, exposes rollover
and pressed acknowledgement, enters checking feedback immediately after dispatch,
is disabled while the dispatch Future is pending, and ignores further taps. The
authorization widget test directly invokes the accepted callback twice and
observes one route completion plus immediate `Starting…` acknowledgement.

## 21. Prompt 32 regression results

PASS. Fresh invocation-time classification, typed ineligibility, typed
unavailable-state feedback, one-selection Settings-menu closure, persistent
Settings navigation, and the existing reset presentation behavior remain covered.
The Prompt 32/Start Fresh/Settings regression pack passed **45/45** tests.

## 22. Start Fresh service regressions

PASS. The unchanged service semantics and their regressions passed within the
45/45 focused regression pack and the complete suite. No destructive allow-list,
virgin-verification, overlay/favourite preservation, archive preservation, or
Feature 35 mutation-tenure behavior was changed.

## 23. Settings-menu regressions

PASS. One-click menu closure, persistent navigation, resolver behavior, and the
new Settings action feedback interaction passed within the 45/45 regression pack
and the complete suite. The new action-provider busy state is local feedback, not
semantic onboarding state.

## 24. Exact Prompt 35 changed-file census

Prompt 35 adds or changes these 16 files, all left unstaged:

### Production/generated — 9

1. `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`
2. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`
3. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.g.dart`
4. `lib/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart`
5. `lib/essentials/onboarding/application/advanced_start_fresh_presentation_provider.g.dart`
6. `lib/essentials/onboarding/presentation/start_fresh_authorization_dialog.dart`
7. `lib/features/settings/application/sidebar_cassette_spec/actions/settings_action_list_actions_provider.dart`
8. `lib/features/settings/application/sidebar_cassette_spec/actions/settings_action_list_actions_provider.g.dart`
9. `lib/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart`

### Tests — 6

10. `test/architecture/onboarding_start_fresh_architecture_test.dart`
11. `test/essentials/onboarding/application/advanced_start_fresh_action_provider_test.dart`
12. `test/essentials/onboarding/application/advanced_start_fresh_action_test.dart`
13. `test/essentials/onboarding/application/advanced_start_fresh_presentation_provider_test.dart`
14. `test/essentials/onboarding/presentation/start_fresh_authorization_dialog_test.dart`
15. `test/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list_test.dart`

### Documentation — 1

16. `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/responses/35-CORRECT-ADVANCED-START-FRESH-SINGLE-FLIGHT-AND-FEEDBACK.md`

These coexist with the already-approved, unstaged Prompt 32 correction. No
unrelated tracked file entered the accumulated implementation diff.

## 25. Architecture result

PASS: complete architecture suite **556/556**. The narrow Start Fresh boundary
also proves claim-before-execution, exact active-Future joining, success dismissal
ownership, and absence of timer debounce or unretained action execution. No
allowlist was broadened.

## 26. Analyzer result

PASS: `flutter analyze` reported `No issues found!` in **4.5 seconds**.

## 27. Full Flutter-suite result

PASS: **2,762 passed, 1 skipped, 0 failed**.

The focused Prompt 35 action/provider/presentation/overlay/dialog/Settings UI and
narrow architecture group passed **38/38**. The accumulated Prompt 32/Start
Fresh/Settings regression pack passed **45/45**.

## 28. Diff, format, and generated hygiene

- `git diff --check`: PASS.
- All selected Dart files were formatted.
- A narrowly filtered `build_runner` consistency run completed successfully.
- Intended generated hashes were stable across that run:
  - action provider: `99a84e6f88f035ffa17cf9c9b70bcaf3f8359048332f6b05aa766fbf35418962`;
  - presentation provider: `4a24e0dc1ac434f0310c98db6e46306e4163837544e245cdb3b85b46ec2ebdc3`;
  - Settings action provider: `0cd79ee7f5c50c8c78728814c106847f32ba272feb23f44bbabdaab188e36930`.
- Unrelated outputs touched by the initial broad generator check were restored
  exactly from HEAD and do not remain in the diff.
- The index remains empty; nothing was staged, committed, or pushed.

## 29. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The synchronous claim, one-active-request/read/authorization/service limits,
presentation ownership, immediate feedback, double-submit prevention, terminal
release rules, Prompt 32 currentness, Settings closure/navigation, Feature 35
tenure, Journey authority, destructive scope, archive preservation, and untouched
real virgin state all conform.

## 30. BLOCKER findings

`BLOCKER: 0`

## 31. SHOULD FIX findings

`SHOULD FIX: 0`

## 32. Real development virgin state remained untouched

Confirmed. MessageLens Development was never launched, no Start Fresh or import
was run, no write-capable helper opened the real development databases, and no
attachment payload directory was traversed. Closing metadata and SHA-256 values
exactly match the opening gate for the archive configuration, app log,
`working_ss.db`, `user_overlays.db`, `presence.db`, and archive identity file.

The import database and all database sidecars remain absent. Graph counts remain
zero for messages, chats, contacts, handles, and chat-message edges. Favourite
intents `17592186044433` and `17592186044472` remain `1`; failure keys remain
empty; and operation evidence remains idle with no operation ID and revision 0.
Toshiba remains the configured attachment archive.

## 33. Exact Git status

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- upstream: `origin/fix/onboarding-import-stuck-state` at the same commit;
- index: empty;
- tracked worktree: 29 modified files, comprising only the accumulated Prompt 32
  and Prompt 35 correction;
- untracked: 41 porcelain status entries representing 60 files after this
  response, comprising the four accumulated Prompt 32/35 implementation/test
  files, Feature 34 prompts/responses and preparation records, and the
  pre-existing unrelated prompt/history and `.vscode` artifacts;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- staged files: none;
- commits/pushes: none.

## 34. Readiness for corrected-build human qualification

The accumulated Prompt 32 + Prompt 35 correction is ready for the next bounded
task to build the correct main-worktree development app and hand it to the human
against the already-virgin development state. This response does not perform that
build or launch.

ADVANCED START FRESH SINGLE-FLIGHT CORRECTED: YES

RESET FLOW IMMEDIATE FEEDBACK CORRECTED: YES

READY FOR CORRECTED-BUILD CLEAN-SLATE HUMAN QUALIFICATION: YES
