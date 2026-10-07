# MessageLens Feature 34
## Response 76 — Eliminate Legacy Onboarding Presentation Authority from the AppCzar Development Route

Date: 2026-10-07

### 1. Baseline verification

The external baseline manifest was created at
`/private/tmp/messagelens-prompt76-baseline-20261007.md` before source edits.
It established:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream `cc5847c1e311ef9b81a3223e1be2388429e4e02b`;
- ahead/behind `0/0`;
- clean tracked worktree and index;
- clean shared-instructions submodule at
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree;
- Prompt 74 implementation
  `182d96812dc6c96e14387d5af51c235d41d0de0b` in ancestry; and
- all known unrelated untracked files left untouched.

### 2. Prompt 75 / Response 75 failed-qualification checkpoint

Prompt 75 and Response 75 were checkpointed and pushed before source edits:

- commit: `3785108d05ba222673d5518f275fe1a6e141bf49`;
- subject: `docs(onboarding): record failed AppCzar qualification`.

That immutable record reports canonical-root correction **LIVE PASS**, safe
disposable-root archive admission **PASS**, and safe-empty current facts
**ESTABLISHED**. AppCzar Onboarding human qualification was **FAIL / NOT
COMPLETED** because the process selected the legacy startup composition.
Initial build and the unsafe partial experiment were not reached. This was not
an AppCzar evaluator failure.

### 3. Exact top-level widget/composition call graph

The reconstructed pre-change graph was:

```text
native/Dart archive admission
  -> immutable ArchiveAccessAuthority
  -> attachmentArchiveAdoptionExecutionEnabledProvider
     (qualified WD root + qualified archive UUID)
  -> selectMessageLensStartupPresentation
  -> disposable valid development root evaluates FALSE
  -> StartupApp(admittedChild: App)
  -> App / MacosApp.router
  -> goRouterProvider
  -> router.dart root builder
  -> production_macos_app_shell.dart / MacosAppShell
  -> legacy Journey presentation stack
```

The post-change graph is:

```text
native/Dart archive admission
  -> immutable ArchiveAccessAuthority
  -> AppCzarDevelopmentCompositionPolicy
     (development + recognized development build + exact bundle/product)
  -> selectMessageLensStartupPresentation
  -> AppCzarStartupHarness
  -> AppCzar-owned MacosApp
  -> one selected coordinator host OR admitted Operating app
```

Production and non-admitted/non-official identities retain the separate
`StartupApp -> App -> MacosApp.router -> MacosAppShell` graph.

The audit therefore corrected the initial collision description: AppCzar and
Journey were not both active. The overly narrow adoption predicate selected the
legacy composition before AppCzar mounted.

### 4. Exact legacy overlay mount path

`lib/essentials/navigation/application/router.dart` builds
`MacosAppShell`. In
`lib/essentials/navigation/presentation/view/production_macos_app_shell.dart`,
`MacosAppShell` watches `onboardingJourneyCoordinatorProvider` and supplies:

```text
journey.requiresOperationOverlay
  -> OnboardingOverlay
```

to `MessageLensWorkspaceShell.fullWindowOverlays`. The same production wrapper
also mounts `AdvancedStartFreshOverlayHost`.

### 5. Exact Journey provider activation path

The legacy production `MacosAppShell.build` directly watches
`onboardingJourneyCoordinatorProvider`. `OnboardingOverlay`,
`OnboardingCenterPanelSyncObserver`, Environment Readiness, the pipeline
incident view, and compatibility `onboardingGateProvider` all derive from or
delegate to that Journey authority. Selecting `StartupApp` therefore
legitimately activated Journey even though AppCzar facts supported Onboarding.

The AppCzar branch now returns `AppCzarStartupHarness` directly and never
constructs `App`, `goRouterProvider`, or `MacosAppShell`.

### 6. Exact center-panel sync activation path

The production wrapper places `OnboardingCenterPanelSyncObserver` in
`MessageLensWorkspaceShell.centerOverlayObservers`. The observer watches
Journey compatibility status, the active blocking incident, and the current
center spec, then schedules
`OnboardingCenterPanelSyncController.synchronize` after the frame. That
controller can publish or clear Environment Readiness and pipeline-incident
`ViewSpec`s through `panelsViewStateProvider`.

No element in that path is constructed by the AppCzar development composition.

### 7. Exact Environment Readiness publication path

The legacy path is:

```text
Journey compatibility status / blocking incident / current center spec
  -> OnboardingCenterPanelSyncObserver
  -> OnboardingCenterPanelSyncController.synchronize
  -> panelsViewStateProvider.show
  -> ViewSpec.environmentReadiness(readinessPanel | pipelineIncidentPanel)
  -> panel coordinator / EnvironmentReadinessPanelView
  -> environmentReadinessSurfaceProvider and action bridge
```

The AppCzar composition neither mounts the observer nor watches the surface or
action providers.

### 8. Why Operating avoided the same collision

Operating already entered through `AppCzarStartupHarness` and returned the
neutral `AppCzarOperatingSessionApp`. That composition did not mount the
production `MacosAppShell`, Journey overlay, center-sync observer, onboarding
sidebar owner, Environment Readiness authority, or pipeline-incident takeover.
The defect occurred earlier: the WD-specific adoption gate prevented a valid
disposable development archive from selecting this proven AppCzar composition.

### 9. Selected structural reuse from Operating composition

The correction reuses the existing top-level separation already proven by
Operating: `AppCzarStartupHarness` owns the AppCzar `MacosApp`, coordinator
hosts, and Operating handoff. No suppression flag, hidden overlay, second
router, or cosmetic z-order rule was added.

### 10. Presentation-authority invariant implementation

`AppCzarDevelopmentCompositionPolicy` now answers only the composition
question for an already-admitted authority. It requires:

- non-null `ArchiveAccessAuthority`;
- development environment;
- development debug, profile, or release build identity;
- bundle `com.bigbenchsoftware.MessageLens.development`; and
- product `MessageLens Development`.

It deliberately does not inspect physical root or archive UUID. The policy is
evaluated only after archive admission has produced immutable authority. The
existing attachment-adoption provider remains independently narrower and
unchanged.

The same composition result controls startup selection, neutral navigation
restoration, Advanced Start Fresh availability, and AppCzar process-restart
authorization.

### 11. Exact source files changed

The implementation checkpoint contains exactly these 12 files:

1. `CHANGELOG.md`
2. `pubspec.yaml`
3. `lib/main.dart`
4. `lib/essentials/app_czar/application/app_czar_development_composition_policy.dart`
5. `lib/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart`
6. `lib/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.g.dart`
7. `test/app_czar_startup_composition_test.dart`
8. `test/essentials/app_czar/application/app_czar_development_composition_policy_test.dart`
9. `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`
10. `test/architecture/app_czar_architecture_test.dart`
11. `test/architecture/attachment_archive_repair_architecture_test.dart`
12. `test/architecture/forbidden_imports_test.dart`

Version advanced from `0.2.140+158` to `0.2.141+159`.

### 12. Proof legacy Journey is not constructed in the AppCzar development route

Startup-composition tests prove both the qualified WD authority and an admitted
disposable development authority select `AppCzarStartupHarness`, not
`StartupApp`. A provider-initialization observer in the integrated AppCzar
Onboarding widget test proves `onboardingJourneyCoordinatorProvider` and
`onboardingGateProvider` are never initialized.

### 13. Proof `OnboardingOverlay` is not mounted

The integrated access-denied AppCzar Onboarding test finds exactly one
`AppCzarOnboardingScreen` and no `OnboardingOverlay` or
`OnboardingJourneyPath`. Static enforcement rejects imports or references to
the legacy overlay from every AppCzar composition package.

### 14. Proof center-panel legacy sync is inert

The same provider observer proves
`onboardingCenterPanelSyncControllerProvider` is never initialized. Widget
assertions prove `OnboardingCenterPanelSyncObserver` is absent. Architecture
tests forbid that observer/controller dependency throughout the AppCzar,
Onboarding, coordinator, and Operating packages.

### 15. Proof Environment Readiness cannot take over

The integrated test proves neither `environmentReadinessSurfaceProvider` nor
`environmentReadinessActionsProvider` is initialized and that no legacy
center-sync observer exists to publish an Environment Readiness `ViewSpec`.
`activeBlockingPipelineIncidentProvider` is likewise not initialized by the
AppCzar Onboarding presentation.

### 16. Proof AppCzar Onboarding owns source `accessDenied`

An AppCzar Onboarding fixture fixed at `sourceNeedsHuman` with
`AppCzarSourceCondition.accessDenied` renders `AppCzarOnboardingScreen`, the
literal “Messages access needs attention” prerequisite, “Open System
Settings,” and “Check Again.” No Journey, compatibility gate, or Environment
Readiness provider participates.

### 17. Proof the six-node Journey rail is absent

The integrated widget test checks that the six rail labels `Messages`,
`History`, `Contacts`, `Ready`, `Import`, and `Start` are absent while the
AppCzar source prerequisite is visible. It also checks the Journey path widget
type directly rather than relying only on text.

### 18. Proof AppCzar assessment and coordinator screens remain intact

The existing harness tests still prove assessment, Data Update, Source Access
Repair, Attachment Archive Repair, Onboarding, and Operating routing. The
combined focused Prompt 76 regression matrix passed all **272** tests. No
AppCzar fact, evaluator, disposition, worker, or coordinator-selection
production source changed.

### 19. Proof Operating composition remains intact

Operating continues to return `AppCzarOperatingSessionApp` from
`AppCzarStartupHarness` once its controller owns the shell. Existing neutral
shell, same-session admission, currentness, attachment coverage, navigation,
and controller regressions all passed in the focused matrix and full suite.

### 20. Proof production legacy Onboarding remains unchanged

The production authority still fails the development-composition policy and
selects `StartupApp(admittedChild: App)`. Tests assert that exact type graph.
No production shell, Journey, overlay, Environment Readiness, action bridge,
or production admission source was modified. Architecture tests explicitly
prove the production shell retains Journey, center sync, Advanced Start Fresh,
and its conditional `OnboardingOverlay`.

### 21. Post-change execution census

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

No generic dispatcher or additional executable coordinator was introduced.

### 22. Focused composition-test result

**PASS.** Policy/startup selection passed 8/8 focused tests. Harness routing
and presentation passed 6/6 tests. The broader focused matrix passed 272/272.

### 23. Onboarding regression result

**PASS.** AppCzar Onboarding controller/presentation tests, legacy Onboarding
tests, compatibility-gate tests, center-sync tests, and the new provider
non-initialization proof all passed.

### 24. Other coordinator regression result

**PASS.** Data Update, Source Access Repair, Attachment Archive Repair,
Operating Session, archive-repair executor, and coordinator-census tests all
passed without semantic changes.

### 25. Production startup regression result

**PASS.** Production continues to select `StartupApp` and retain `App` as its
admitted child. Production startup-surface and legacy presentation regressions
passed.

### 26. Architecture result

**PASS — 603 tests.** The complete `test/architecture` suite passed. New
tripwires enforce AppCzar/legacy presentation separation, authority-gated
composition, unchanged narrow adoption authority, and composition-aligned
restart/reset/navigation policies.

### 27. Analyzer result

**PASS.** `flutter analyze` reported `No issues found!` in 7.2 seconds.

### 28. Full Flutter-suite result

**PASS — 3,070 tests, 1 intentionally skipped qualification workload.** The
complete deterministic Flutter suite finished with `All tests passed!`.

### 29. Native test result

**NOT RUN / NOT REQUIRED.** Prompt 76 changes no native/bootstrap source or
assumption. The native/Dart archive-admission contract remains the separately
qualified Prompt 74 implementation.

### 30. Diff / format / generated hygiene

- `git diff --check`: PASS.
- `git diff --cached --check`: PASS.
- Dart format: 9 files checked, 0 changed.
- Riverpod/build-runner consistency: PASS; generation completed successfully,
  writing 87 outputs, with only the expected restarter-provider hash changed.
- No generated file was edited manually.
- No unrelated untracked file was staged.

### 31. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The final diff preserves one top-level semantic presentation authority,
structurally excludes legacy semantics from AppCzar, introduces no cosmetic
suppression or persisted mode, leaves AppCzar facts/evaluation and Onboarding
worker semantics unchanged, and preserves the production legacy route.

### 32. BLOCKER findings

**BLOCKER: 0.** Archive admission remains a prerequisite. Operation-specific
mutation authority remains narrower. No real archive/database access, app
launch, or production routing change occurred.

### 33. SHOULD FIX findings

**SHOULD FIX: 0.** No duplicate policy, hidden Journey execution, hidden panel
publisher, root-shape dependency, generic dispatcher, or stale generated
output remains in the Prompt 76 scope.

### 34. Implementation checkpoint commit

`ef867dff28ae13fa1a4e26a07657e974e0864556`

Subject: `fix(startup): isolate AppCzar from legacy onboarding presentation`

### 35. Documentation checkpoint commit

Prompt 76 and this Response 76 form the narrow documentation checkpoint. Its
commit hash is reported in the post-commit handoff because a commit cannot
embed its own final hash without changing that hash.

### 36. Pushed recovery anchor

The failed-qualification recovery anchor is pushed at
`3785108d05ba222673d5518f275fe1a6e141bf49`. The implementation and
documentation checkpoints are pushed normally together after this response is
committed. No force push, rebase, or squash is used.

### 37. Exact build identity, path, and hashes

The exact artifact was built from implementation commit `ef867dff` and was not
launched:

- bundle path:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- product/display/executable: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- environment/build identity: `development` / `developmentDebug`
- version/build: `0.2.141 (159)`
- executable SHA-256:
  `5abee4d23602a0e5762834aff06fe191f54103be8cf5e25ad15cf95bf04a48fd`
- `App.framework/App` SHA-256:
  `68723a0e19f37aa3fb7ad1940bd04faccd6d0193cc0289fb39ff9b8bc7a2c048`

### 38. Final Git / worktree / index / submodule state

At the implementation checkpoint, tracked worktree and index were clean; only
Prompt 76, this Response 76, and the known unrelated untracked artifacts
remained. The shared-instructions submodule remained clean at
`95326f515ef4719f155ce6e223990398daad6311`. The final post-documentation push
state and exact HEAD/upstream are reported in the handoff.

### 39. Readiness to rerun isolated AppCzar Onboarding qualification

**YES.** Rerun with fresh disposable safe-empty and consequential-partial
fixtures. Do not substitute the real WD development root and do not weaken the
Prompt 75 experiment.

### 40. Readiness for the Local Data Repair milestone

**NO.** The isolated AppCzar Onboarding human qualification must complete
successfully first. Prompt 76 establishes presentation isolation only.

### 41. Readiness for production AppCzar cutover

**NO.** Production intentionally remains on the legacy Journey composition.
Prompt 76 neither authorizes nor performs production cutover.

`LEGACY JOURNEY IS INERT IN THE APPCZAR DEVELOPMENT ROUTE: YES`

`LEGACY ONBOARDING OVERLAY CAN CLAIM APPCZAR VISIBLE AUTHORITY: NO`

`LEGACY CENTER-PANEL SYNC CAN PUBLISH DURING APPCZAR JURISDICTION: NO`

`APPCZAR ONBOARDING OWNS ITS SOURCE-PREREQUISITE PRESENTATION: YES`

`PRODUCTION LEGACY ONBOARDING BEHAVIOR IS UNCHANGED: YES`

`APPCZAR JURISDICTION SEMANTICS CHANGED: NO`

`PROJECT CONFORMANCE: PASS`

`READY TO RERUN ISOLATED ONBOARDING HUMAN QUALIFICATION: YES`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
