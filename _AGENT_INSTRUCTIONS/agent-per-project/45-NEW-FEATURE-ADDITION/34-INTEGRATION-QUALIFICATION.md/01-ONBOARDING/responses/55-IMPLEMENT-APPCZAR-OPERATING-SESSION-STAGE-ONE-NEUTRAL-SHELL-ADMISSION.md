# MessageLens Feature 34
## Response 55 — AppCzar Operating Session Stage One: Neutral Shell Admission

Date: 2026-10-03

Operating Session Stage One is implemented and validated. The exact
development-only AppCzar route can now replace a completed healthy/current
assessment with the normal MessageLens workspace in a neutral semantic state.
The production startup route remains unchanged, the ambient live-update service
remains deliberately disabled in this Stage One composition, and the completed
development artifact was built but not launched.

## 1. Baseline verification

The fresh external baseline manifest is:

`/private/tmp/messagelens-prompt55-baseline-manifest.txt`

It records:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `7d0393c214c9ad701c0c856f03ddcb17b490ea03`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- untracked baseline: 46 paths, comprising 44 known unrelated paths plus
  Prompt 55 and Response 54.

Responses 50 through 54 and the canonical Project Conformance standard were
reviewed before implementation.

## 2. Exact Operating selection predicate reused

`shouldExecuteAppCzarOperatingSession(...)` admits only a completed assessment
whose selected disposition is exactly
`AppCzarVirtualCoordinator.operatingSession` and whose evidence contains
exactly one `TRUE` proposition for each of:

- development root admitted;
- Messages source readable;
- source sample stable;
- import store healthy;
- graph store healthy;
- overlay healthy;
- local dataset complete;
- attachment archive available;
- source/local delta known.

It additionally requires exactly one `FALSE` source-ahead proposition.
Missing, duplicate, contradictory, or unknown required evidence fails closed.
No new `ready` flag was introduced.

## 3. Operating execution seam

The new keep-alive `AppCzarOperatingSessionController` owns one bounded visual
entry occurrence for one exact assessment generation. It:

1. observes the existing assessment;
2. applies the exact predicate;
3. records that generation before scheduling work;
4. restores visual window state and enforces the minimum window size;
5. rechecks the same generation and exact Operating predicate;
6. publishes admission only when both still agree.

A newer assessment generation resets the old occurrence before it can admit.
Late work from an older generation cannot overwrite the newer generation.
Successful entry does not restart the process, carry a semantic handoff
payload, acquire archive mutation authority, or invoke AppCzar again.

The startup harness replaces the assessment root with the Operating root after
admission. Assessment controls are absent after that replacement. While visual
entry is in flight, `Run assessment again` is disabled. The window delegate is
attached only through the admitted Operating callback, after the Operating
shell has mounted.

## 4. Exactly three executable dispositions

The development harness now contains exactly three explicit execution
predicates and explicit host branches:

1. Data Update;
2. Source Access Repair;
3. Operating Session.

Architecture enforcement counts those three exact predicates and rejects a
generic enum dispatcher. Onboarding, Local Data Repair, Attachment Archive
Repair, and Diagnostic Review remain virtual.

## 5. Shell composition strategy

The reusable workspace was mechanically split into:

- `MessageLensWorkspaceShell`: the neutral normal workspace; and
- `MacosAppShell` in `production_macos_app_shell.dart`: the existing production
  Journey/onboarding decorations around that workspace.

The production router still constructs `MacosAppShell`, preserving its prior
startup behavior. The admitted Operating branch owns one top-level
`MacosApp.router` and one single-route `GoRouter` whose route builds the neutral
workspace directly. It does not nest one `MacosApp` inside another.

## 6. Legacy semantic-authority exclusions

The AppCzar Operating package and neutral workspace do not import, watch, or
mount:

- `MessageLensInstallationState` or the installation classifier;
- Onboarding Journey, compatibility status, or gate;
- Environment Readiness semantic state;
- `OnboardingSidebarVisibilityOwner`;
- `OnboardingCenterPanelSyncObserver`;
- `OnboardingOverlay`;
- `AdvancedStartFreshOverlayHost`;
- persisted onboarding failure or pipeline-incident startup takeover;
- legacy startup completion callbacks or handoffs.

Those authorities remain compiled only behind the unchanged production wrapper.
Architecture tests enforce both sides of this composition boundary.

## 7. Neutral navigation implementation

The generated `sidebarNavigationRestorationEnabledProvider` defaults to `true`
for existing compositions. The exact AppCzar development scope overrides it to
`false`. `SidebarFlow` checks the policy before any durable preference read, so
the first visible Operating frame uses the existing provider defaults:

- sidebar mode: Messages;
- top branch: Conversations;
- selected conversation: none;
- selected contact: none;
- selected handle: none;
- Settings context: none.

This is prevention before mount, not a post-mount clearing operation.

## 8. Durable navigation becomes history-only

The stored `sidebar_flow_navigation` value is neither deleted nor rewritten on
entry. It is simply not read by the exact AppCzar Operating composition.
Ordinary same-session user navigation still mutates and persists through the
existing `SidebarFlow` behavior. A later fresh process again starts from the
neutral defaults rather than promoting that durable history into current
semantic state.

## 9. Center and right panel initial behavior

The neutral SidebarFlow defaults derive no selected content, so the center and
right panels begin empty/neutral. The Operating composition supplies no
readiness observer, onboarding observer, or pipeline-incident owner that could
replace that neutral content during startup. After admission, ordinary user
navigation and normal feature resolvers populate the panels normally.

## 10. Ambient monitor suppression

Operating Stage One does not watch `chatDbChangeMonitorProvider`, start any
timer or poller, invoke `LiveGraphUpdateWorker`, or run an automatic attachment
sweep. It presents no live-updating claim. This is an intentional,
development-only qualification limitation.

## 11. Display-identity resolver correction

`displayIdentityResolverProvider` now synchronously watches the established
`messageDataVersionProvider` before its asynchronous graph reads. A retained
resolver therefore invalidates and rebuilds on message-data generation changes
without a second cache, selected contact, click, navigation mutation, or
provider recreation. AppCzar assessment and coordinator phases do not construct
the resolver; normal feature resolution first constructs it after Operating
admission.

## 12. Display-identity focused tests

Focused coverage proves:

- first construction reads populated current graph identities;
- a retained resolver rebuilds when message-data generation advances;
- retained contacts-list readers receive the rebuilt identity snapshot;
- the AppCzar pre-Operating composition cannot construct display identity;
- fallback `contact <id>` labels do not require a navigation action to repair.

## 13. Window restoration behavior

The Operating visual initializer reuses the existing `WindowStateService` and
performs only visual restoration followed by minimum-size enforcement. It does
not restore a selected conversation, contact, handle, Settings context,
center/right semantic payload, readiness panel, or coordinator state. The
application window delegate is not attached during Fair Witness assessment; it
is attached only after admitted Operating presentation is mounted.

## 14. Advanced Start Fresh handling

Stage One takes the preferred safe option: Advanced Start Fresh is hidden only
in the exact AppCzar Operating route. A generated availability policy defaults
to `true` for existing routes and is overridden to `false` by the same exact
development AppCzar scope. Both the ordinary Settings resolver and the Message
History Coverage Settings path honor it. The neutral shell also omits the
Journey-owned reset overlay. Production behavior remains unchanged.

## 15. Operating admission tests

Controller tests cover the exact healthy/current predicate, all non-Operating
and malformed-evidence rejections, one occurrence per generation, visual
initialization ordering, stale-generation rejection, failure behavior,
generation replacement, and late-completion isolation. The core Operating
package tests pass: **12 passed**.

## 16. Neutral navigation tests

Tests prove the initial Messages/Conversations defaults, absence of selected
conversation/contact/handle and Settings context, empty derived center/right
content, no durable preference read when restoration is disabled, and normal
same-session mutation/persistence after entry.

## 17. Shell composition tests

Composition and architecture tests prove:

- one Operating `MacosApp.router`, not nested application roots;
- the single route builds the real neutral workspace;
- neutral workspace decoration slots are empty;
- normal feature-resolution providers remain available;
- production uses the production wrapper unchanged;
- Journey/readiness owners, center sync, pipeline takeover, ambient monitor,
  live worker, mutation Ball, and Advanced Start Fresh are absent from the
  Operating composition;
- visual window restoration is ordered before admission;
- the window delegate attaches only after admission.

## 18. Data Update regression result

The existing Data Update controller, progress, mutation-tenure, release, and
restart regressions pass in the final focused set and complete suite. Operating
does not invoke or chain to Data Update.

## 19. Source Access Repair regression result

The existing FALSE-versus-UNKNOWN mapping, explicit fresh `Check Again`,
settings-navigation-only, single-flight, restart-only, and no-handoff
regressions pass in the final focused set and complete suite. Operating does not
invoke or chain to Source Access Repair.

## 20. AppCzar mapping and host result

The final combined AppCzar, Data Update, Source Access Repair, Operating,
startup-host, navigation-policy, reset-policy, and display-identity focused run
passed **107 tests**. The host presents only the exact selected executable
branch, disables reassessment during Operating visual entry, and cannot execute
the remaining virtual dispositions.

## 21. Architecture result

The standalone complete architecture suite passed **574 tests**. The AppCzar
architecture subset passed **18 tests**, including the exact-three-predicate
rule, no generic dispatcher, production/development route boundary, neutral
shell exclusions, public provider seams, no pre-Operating identity
construction, post-admission delegate attachment, and Stage One reset and
navigation policies.

## 22. Analyzer result

`flutter analyze` completed with **No issues found**.

## 23. Full Flutter-suite result

The final deterministic complete Flutter suite passed **2,848 tests** with
**1 intentional skip** and no failures.

## 24. Diff, format, generated, and build hygiene

- bounded formatting check over the intended/affected Dart inputs: no changes;
- `dart run build_runner build --delete-conflicting-outputs`: successful with
  all expected generated outputs current;
- `git diff --check`: passed;
- `git diff --cached --check`: passed with an empty index;
- debug macOS development build: successful.

Xcode emitted non-failing diagnostics about a blank device build number and the
third-party `volume_controller` privacy manifest processing rule. Neither
changed the successful build result or this feature's conformance verdict.

## 25. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

- BLOCKER: 0
- SHOULD FIX: 0

Operating is admitted only from fresh exact current evidence. It begins in a
neutral semantic state, excludes the legacy Journey/readiness authority stack,
does not start ambient mutation, has current display identity on first use,
acquires no Ball for entry, performs no coordinator chaining, leaves exactly
three explicit AppCzar dispositions executable, and does not alter production
startup.

## 26. BLOCKER findings

None.

No Prompt 55 stop gate was encountered.

## 27. SHOULD FIX findings

None remain. Independent review initially identified entry-generation recovery,
real-shell proof, early delegate attachment, private provider imports, and
changelog contradictions. Each was corrected before the final validation runs.

## 28. Exact development build identity

- bundle path:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- product: `MessageLens Development`;
- version/build: `0.2.133 (151)`;
- signing observed by `codesign`: ad hoc, arm64;
- executable SHA-256:
  `b3d06d0711084d16f7594856e0432b7163c92c7c5f672d8fdf595ce567b142a4`;
- App.framework SHA-256:
  `3b5f513c45e22fea3c8ba837589375e2bca6809ce9a848bbc0f1383612782028`.

No launch command was issued after the build.

## 29. Exact Git, worktree, index, and submodule state

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `7d0393c214c9ad701c0c856f03ddcb17b490ea03`;
- upstream: `origin/fix/onboarding-import-stuck-state`;
- ahead/behind: `0/0`;
- index: empty;
- tracked worktree: 25 intended modified files, all unstaged;
- new implementation/test/generated paths: 15, all untracked;
- Response 55: new and untracked;
- total untracked paths after Response 55: 62;
- known unrelated baseline paths: the original 44, untouched;
- Prompt 55 and Response 54: still untracked and untouched;
- shared-instructions submodule: clean and unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`.

No file was staged, committed, pushed, merged, or rebased. Neither a real
MessageLens archive nor a real MessageLens database was read or modified by
implementation, tests, validation, or build. The abandoned relocation
artifacts and unrelated untracked material remain untouched.

## 30. Human neutral-shell Operating qualification readiness

The artifact is ready for the bounded human qualification. Prepare and run it
exactly as follows:

1. Quit any running MessageLens Development instance.
2. Keep the qualified `WD_ELEMENTS` development data folder and
   `Toshiba_manual_bu` attachment archive connected.
3. In System Settings -> Privacy & Security -> Full Disk Access, verify that
   the exact app bundle at the path in Section 28 is present and enabled. If it
   is not, add that exact bundle; do not substitute another installed build.
4. Do not use VS Code `flutter run`, an environment root override, or another
   app copy.
5. Direct-launch the exact built artifact with:

   `/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"`

6. Confirm a fresh AppCzar assessment selects Operating Session and the normal
   shell appears.
7. Confirm the first shell state is Conversations with no selected
   conversation, contact, or handle, and neutral/empty center and right panels.
8. Confirm no readiness/onboarding panel appears.
9. Open Contacts and confirm names are correct immediately, without first
   selecting a contact to repair them.
10. Navigate to a contact and a conversation, then quit normally.
11. Repeat the same direct-launch command.
12. Confirm AppCzar reassesses from fresh evidence and the admitted shell again
    starts neutral rather than restoring the prior semantic selection.

## 31. Deferred live-currentness milestone

Do not test incoming-message live updates during this qualification. The
Operating-owned replacement for the ambient `ChatDbChangeMonitor` is
intentionally deferred to the next milestone. Stage One qualifies only the
fresh-evidence-to-neutral-shell handoff and ordinary same-session navigation.

APPCZAR OPERATING SESSION STAGE ONE IMPLEMENTED: YES

FRESH OPERATING ENTRY RESTORES HISTORICAL SEMANTIC NAVIGATION: NO

LEGACY JOURNEY/READINESS AUTHORITY PRESENT IN APPCZAR OPERATING SHELL: NO

AMBIENT LIVE UPDATE ENABLED IN STAGE ONE: NO

READY FOR HUMAN NEUTRAL-SHELL OPERATING QUALIFICATION: YES
