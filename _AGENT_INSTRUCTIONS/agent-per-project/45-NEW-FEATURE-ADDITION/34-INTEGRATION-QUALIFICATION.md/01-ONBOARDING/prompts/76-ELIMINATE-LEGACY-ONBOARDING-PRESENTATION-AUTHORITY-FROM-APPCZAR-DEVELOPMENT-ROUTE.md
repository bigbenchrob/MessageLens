# MessageLens Feature 34
## 76 — Eliminate Legacy Onboarding Presentation Authority from the AppCzar Development Route

Response 75 reached AppCzar for the first time with a disposable safe-empty
development root, and the corrected canonical-root contract passed live.

The qualification then exposed a separate architectural defect:

```text
safe-empty disposable root
-> archive admission PASS
-> current facts support AppCzar Onboarding

but

legacy Onboarding Journey overlay
+ Environment Readiness center-panel authority
also remained mounted/active
-> legacy surface claimed visible semantic authority
-> AppCzar Onboarding could not be human-qualified
```

The visible legacy evidence was:

```text
Messages / History / Contacts / Ready / Import / Start

MessageLens needs Full Disk Access
```

and logs showed:

```text
OnboardingCenterPanelSyncController
-> Environment Readiness
-> onboardingStatus: awaitingUserAction
```

This violates the core invariant:

> **At most one top-level semantic jurisdiction owner and one corresponding
> presentation authority may exist at a time.**

The exact-development AppCzar route must not merely place an AppCzar screen
under a still-active Journey overlay.

This task fixes that presentation/authority collision.

It does NOT change AppCzar facts, evaluator semantics, Onboarding worker
semantics, archive admission, or production startup behavior.

Do NOT route production through AppCzar.
Do NOT delete the legacy Journey yet.
Do NOT hide the legacy overlay with opacity/z-order tricks while leaving its
semantic providers active.
Do NOT modify the Onboarding selection predicate merely to avoid the collision.
Do NOT access or mutate real MessageLens databases or archives.
Do NOT launch production MessageLens.

---

# 1. Baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `cc5847c1e311ef9b81a3223e1be2388429e4e02b`
- ahead/behind `0/0`;
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree.

Verify Prompt 74 implementation ancestry:

`182d96812dc6c96e14387d5af51c235d41d0de0b`

Read:

- Response 44;
- Response 51;
- Response 54;
- Response 55;
- Response 72;
- Response 75;
- current `main.dart`;
- `AppCzarStartupHarness`;
- `production_macos_app_shell.dart`;
- `OnboardingOverlay`;
- `OnboardingCenterPanelSyncObserver`;
- `OnboardingCenterPanelSyncController`;
- `OnboardingSidebarVisibilityOwner`;
- Environment Readiness presentation/action providers;
- Journey/gate/status providers;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Prompt 75 / Response 75 as failed live evidence first

Prompt 75 made no source/test changes.

Create a narrow documentation checkpoint containing Prompt 75 and Response 75
before source edits.

Record exactly:

```text
canonical-root correction:
    LIVE PASS

safe disposable root archive admission:
    PASS

safe-empty current facts:
    ESTABLISHED

AppCzar Onboarding human qualification:
    FAIL / NOT COMPLETED

blocking defect:
    legacy Journey overlay + Environment Readiness presentation authority
    remained active in the exact-development AppCzar route

initial build:
    NOT REACHED

unsafe partial experiment:
    NOT REACHED
```

Do not call this an AppCzar evaluator failure.

Push the checkpoint normally before editing.

No force push, rebase, squash, or unrelated staging.

---

# 3. Reconstruct the exact widget/provider composition that produced the collision

Before editing, source-trace the exact live call graph from process startup to
the two competing presentation authorities.

At minimum answer:

1. What object owns the top-level `MacosApp` / router in the exact-development
   AppCzar route?
2. Where is `AppCzarStartupHarness` mounted?
3. Where and why is `production_macos_app_shell.dart` mounted in the same live
   process?
4. What exact watcher/listener/provider causes `OnboardingOverlay` to appear?
5. What exact watcher/listener/provider activates
   `OnboardingCenterPanelSyncObserver` / controller?
6. What constructs or watches the legacy Journey in this route?
7. What constructs or watches `onboardingGateProvider` / compatibility status?
8. What constructs Environment Readiness semantic projection?
9. Are these legacy providers instantiated before or after AppCzar selects a
   coordinator?
10. Which of them perform semantic side effects even when their widgets are not
    visible?

Produce an exact source path and ownership graph.

Do not assume the collision is merely z-order.

---

# 4. Reconcile with the previously qualified Operating composition

Response 55 established that AppCzar Operating uses a neutral workspace
composition and does not mount:

- Journey authority;
- Environment Readiness semantic state;
- `OnboardingCenterPanelSyncObserver`;
- `OnboardingOverlay`;
- onboarding sidebar visibility ownership;
- pipeline-incident semantic takeover.

Audit why that exclusion succeeded for Operating but did not mechanically cover
AppCzar Onboarding.

Prefer extending the already-proven composition boundary rather than inventing
a second suppression system.

Report the exact reuse opportunity.

---

# 5. Define the presentation-authority invariant

For the exact-development AppCzar route:

```text
ASSESSING
    -> AppCzar assessment surface only

Data Update
    -> Data Update coordinator surface only

Source Access Repair
    -> Source Access Repair surface only

Attachment Archive Repair
    -> Attachment Archive Repair surface only

Onboarding
    -> AppCzar Onboarding surface only

Operating
    -> admitted neutral/normal Operating workspace only
```

Legacy startup/Journey surfaces must not be a second overlay, listener, center
panel publisher, or action authority in any of these states.

The allowed architecture is:

```text
one AppCzar assessment
OR
one selected coordinator host
OR
one admitted Operating session
```

Never:

```text
AppCzar coordinator
+
legacy Journey overlay
```

---

# 6. Suppress authority structurally, not cosmetically

The preferred correction is **composition separation**.

The exact-development AppCzar route should not construct the legacy semantic
presentation stack at all.

Preferred conceptual shape:

```text
main.dart
-> exact development AppCzar gate TRUE
-> AppCzarDevelopmentComposition
   -> AppCzarStartupHarness
   -> selected coordinator host
   -> NO legacy Journey wrapper

main.dart
-> all other/production routes
-> existing StartupApp / production legacy composition unchanged
```

If the current root structure requires a policy seam, it may be introduced only
as a **composition policy**, not semantic app state.

For example, conceptually:

```text
legacyStartupSemanticsEnabled = false
```

for the exact-development AppCzar composition.

But prefer structural non-construction over providers that are constructed and
then told not to display.

Do not persist such a policy.

Do not let it participate in AppCzar facts or disposition selection.

---

# 7. Legacy semantic machinery that must be inert in the AppCzar development route

At minimum prove that the exact-development AppCzar composition does not
construct/watch/listen to:

- `OnboardingJourneyCoordinator`;
- Journey Trip / Step / Episode state;
- `OnboardingStatus`;
- `onboardingGateProvider`;
- `OnboardingOverlay`;
- `OnboardingSidebarVisibilityOwner`;
- `OnboardingCenterPanelSyncObserver`;
- `OnboardingCenterPanelSyncController`;
- Environment Readiness semantic provider/projection/action bridge;
- legacy pipeline-incident center-panel takeover;
- legacy startup completion/ReadyToStart handoff;
- Journey-dependent Advanced Start Fresh overlay/action authority.

Raw factual readers may remain reusable where explicitly consumed by AppCzar.

Historical diagnostics may remain stored but inert.

---

# 8. Do not accidentally remove required coordinator presentation infrastructure

The correction must preserve:

- AppCzar assessment UI;
- Data Update screen;
- Source Access Repair screen;
- Attachment Archive Repair screen;
- AppCzar Onboarding screen;
- Operating workspace;
- macOS window/theme/typography infrastructure;
- ordinary coordinator-specific buttons/actions;
- normal same-session Operating navigation after admission.

Do not solve the collision by stripping the common application shell so far that
coordinator screens lose required platform/window behavior.

---

# 9. Production behavior remains unchanged

The production route still uses the legacy startup/Journey architecture until
the separately approved production cutover.

Production must continue to be able to mount:

```text
StartupApp
Journey
OnboardingOverlay
Environment Readiness
legacy action bridges
```

exactly as it does before this task.

Add explicit tests proving that the production composition still constructs the
legacy wrapper when its existing predicates require it.

Do not delete legacy files in Prompt 76.

---

# 10. AppCzar Onboarding screen must own its source prerequisite

Response 75 naturally produced:

```text
Messages source -> accessDenied
```

while the visible FDA toggle was ON.

After the composition correction, the same current fact in a safe-empty
Onboarding scope must be presented by **AppCzar Onboarding**, not the Journey.

The new screen must use the already-implemented Response 72 semantics:

```text
safe initial scope
+ source accessDenied
-> remain Onboarding
-> literal source-readability prerequisite
-> Open System Settings only if supported
-> Check Again
```

Do not change those semantics here.

Add widget/composition coverage that the visible copy/action comes from
`AppCzarOnboardingScreen` and no Journey rail exists.

---

# 11. Center-panel side-effect isolation

It is not sufficient to hide `OnboardingOverlay`.

Prove that under the exact-development AppCzar route:

```text
OnboardingCenterPanelSyncObserver
```

cannot mutate panel state.

Likewise prove Environment Readiness and pipeline incident history cannot
publish a center ViewSpec while an AppCzar coordinator owns jurisdiction.

The test should fail if a future refactor reintroduces those watchers into the
development composition.

---

# 12. No hidden Journey execution

Add instrumentation/tests sufficient to prove that a safe-empty development
AppCzar Onboarding fixture does not instantiate or execute the legacy Journey
coordinator merely in the background.

The desired condition is stronger than:

```text
legacy overlay not visible
```

It is:

```text
legacy Journey semantic authority not participating
```

A raw provider existing in source is fine.

A watched/listened active semantic authority is not.

---

# 13. Preserve exact one-coordinator execution census

After the correction the development execution census must remain:

```text
Data Update                 EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair        EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair   EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                  EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session           EXECUTABLE ADMITTED SESSION

Local Data Repair           VIRTUAL ONLY
Diagnostic Review           VIRTUAL ONLY
```

Do not make Local Data Repair or Diagnostic Review executable.

Do not add a generic dispatcher.

---

# 14. Focused composition tests

At minimum prove:

1. exact-development AppCzar assessment mounts no legacy Journey overlay;
2. AppCzar Data Update mounts no legacy Journey overlay;
3. AppCzar Source Access Repair mounts no legacy Journey overlay;
4. AppCzar Attachment Archive Repair mounts no legacy Journey overlay;
5. AppCzar Onboarding mounts `AppCzarOnboardingScreen`;
6. AppCzar Onboarding does not mount `OnboardingOverlay`;
7. AppCzar Onboarding does not render the six-node Journey rail;
8. AppCzar Onboarding source `accessDenied` renders the new literal prerequisite;
9. AppCzar Onboarding cannot construct/listen to center-panel legacy sync;
10. Environment Readiness cannot replace AppCzar Onboarding presentation;
11. Operating remains the previously qualified neutral composition;
12. exact-development route has no legacy ReadyToStart handoff;
13. production legacy route still mounts legacy Onboarding when its existing
    predicate requires it.

Use provider construction/listen counters or architecture seams where useful.

Do not base the test solely on searching rendered text.

---

# 15. Architecture enforcement

Add or strengthen static/architecture tests so the exact-development AppCzar
composition cannot import or mount legacy semantic presentation authority.

Prefer mechanically checkable boundaries such as:

- AppCzar development composition cannot import Journey presentation package;
- AppCzar coordinator hosts cannot import `production_macos_app_shell.dart` if
  that file contains legacy semantics;
- neutral/common shell pieces remain in a lower semantic layer;
- production wrapper may depend on legacy Journey;
- legacy Journey may not depend on AppCzar coordinator packages.

Do not create cyclic dependencies to share UI.

---

# 16. Regression matrix

Run:

1. focused development-composition tests;
2. AppCzar Onboarding presentation/controller tests;
3. AppCzar host/census tests;
4. Operating composition regressions;
5. Data Update regressions;
6. Source Access Repair regressions;
7. Attachment Archive Repair regressions;
8. archive admission/canonical-root regressions;
9. legacy production startup/Onboarding regressions;
10. navigation/panel composition regressions;
11. architecture suite;
12. analyzer;
13. full deterministic Flutter suite;
14. native tests if composition changes touch native/bootstrap assumptions;
15. `git diff --check`;
16. formatting/generated consistency;
17. debug macOS development build.

Do not launch the development or production app in Prompt 76.

---

# 17. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Explicitly audit:

- exactly one top-level semantic presentation authority;
- legacy Journey absent from exact-development AppCzar composition;
- no cosmetic-only suppression;
- no hidden center-panel semantic side effects;
- no hidden Journey execution;
- no AppCzar fact/evaluator changes;
- no Onboarding worker changes;
- production legacy route unchanged;
- qualified coordinator behavior unchanged;
- no new persisted semantic state.

---

# 18. Checkpoint and build

If all validation passes:

1. create a narrow implementation commit;
2. build the exact corrected development artifact;
3. create Prompt 76 / Response 76 documentation checkpoint;
4. push normally.

Recommended implementation subject:

`fix(startup): isolate AppCzar from legacy onboarding presentation`

Advance version/build sequentially if required by repository convention.

Do not launch the artifact.

Report:

- bundle path;
- product;
- bundle identifier;
- version/build;
- executable SHA-256;
- App.framework SHA-256.

No force push, rebase, squash, or unrelated staging.

---

# 19. Next human step

If Prompt 76 passes, rerun the isolated Onboarding qualification using **fresh**
disposable fixtures.

Do not weaken the Prompt 75 experiment.

The expected safe path is now:

```text
valid disposable root
-> archive admission
-> AppCzar
-> AppCzar Onboarding screen
-> source prerequisite if needed
-> Contacts prerequisite
-> existing initial build
-> drain/restart
-> fresh AppCzar
```

The unsafe consequential-partial fixture must still prove:

```text
NOT Onboarding
-> no build
-> no cleanup
```

Do not use the real WD development root for that qualification.

---

# 20. Stop gates

STOP AND REPORT if:

- the legacy Journey overlay is actually mounted by a route that production and
  AppCzar development cannot safely separate;
- removal of legacy watchers from development requires changing production
  Journey semantics;
- AppCzar Onboarding currently depends on Environment Readiness/Journey action
  providers for required behavior;
- the correction requires a new persisted mode flag;
- the only available fix is cosmetic z-order/visibility suppression;
- AppCzar evaluator or Onboarding jurisdiction semantics must change;
- Project Conformance cannot reach PASS.

---

# 21. Required response

Create Response 76 and report:

1. baseline verification;
2. Prompt 75/Response 75 failed-qualification checkpoint;
3. exact top-level widget/composition call graph;
4. exact legacy overlay mount path;
5. exact Journey provider activation path;
6. exact center-panel sync activation path;
7. exact Environment Readiness publication path;
8. why Operating avoided the same collision;
9. selected structural reuse from Operating composition;
10. presentation-authority invariant implementation;
11. exact source files changed;
12. proof legacy Journey is not constructed in AppCzar development route;
13. proof `OnboardingOverlay` is not mounted;
14. proof center-panel legacy sync is inert;
15. proof Environment Readiness cannot take over;
16. proof AppCzar Onboarding screen owns source `accessDenied`;
17. proof six-node Journey rail is absent;
18. proof AppCzar assessment and other coordinator screens remain intact;
19. proof Operating composition remains intact;
20. proof production legacy Onboarding remains unchanged;
21. post-change execution census;
22. focused composition-test result;
23. Onboarding regression result;
24. other coordinator regression result;
25. production startup regression result;
26. architecture result;
27. analyzer result;
28. full Flutter-suite result;
29. native test result if run;
30. diff/format/generated hygiene;
31. Project Conformance verdict;
32. BLOCKER findings;
33. SHOULD FIX findings;
34. implementation checkpoint commit;
35. documentation checkpoint commit;
36. pushed recovery anchor;
37. exact build identity/path/hashes;
38. final Git/worktree/index/submodule state;
39. readiness to rerun isolated AppCzar Onboarding qualification;
40. readiness for Local Data Repair milestone;
41. readiness for production AppCzar cutover.

Conclude exactly:

`LEGACY JOURNEY IS INERT IN THE APPCZAR DEVELOPMENT ROUTE: YES / NO`

`LEGACY ONBOARDING OVERLAY CAN CLAIM APPCZAR VISIBLE AUTHORITY: YES / NO`

`LEGACY CENTER-PANEL SYNC CAN PUBLISH DURING APPCZAR JURISDICTION: YES / NO`

`APPCZAR ONBOARDING OWNS ITS SOURCE-PREREQUISITE PRESENTATION: YES / NO`

`PRODUCTION LEGACY ONBOARDING BEHAVIOR IS UNCHANGED: YES / NO`

`APPCZAR JURISDICTION SEMANTICS CHANGED: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY TO RERUN ISOLATED ONBOARDING HUMAN QUALIFICATION: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
