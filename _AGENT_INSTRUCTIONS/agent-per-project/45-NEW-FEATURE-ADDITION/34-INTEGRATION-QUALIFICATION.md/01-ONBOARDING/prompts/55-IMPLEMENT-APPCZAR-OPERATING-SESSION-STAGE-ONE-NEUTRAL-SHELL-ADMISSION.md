# MessageLens Feature 34
## 55 — Implement AppCzar Operating Session Stage One: Neutral Shell Admission

Response 54 checkpointed Source Access Repair and completed the Operating Session design audit.

Current recovery anchor:

- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `7d0393c214c9ad701c0c856f03ddcb17b490ea03`
- Source Access Repair implementation checkpoint:
  `1ffc4b0c9a96defb80390536a00562ba468c71fd`
- documentation/recovery-anchor checkpoint:
  `7d0393c214c9ad701c0c856f03ddcb17b490ea03`

The audit concluded that a fresh healthy AppCzar assessment can safely admit a
normal Operating Session, but only if the normal shell cannot immediately
restore historical semantic state or reactivate the old Journey/readiness
authorities.

This task implements **Operating Session Stage One only**.

Stage One goal:

```text
fresh process
-> AppCzar proves healthy/current
-> exact Operating Session admission
-> normal MessageLens shell appears
-> neutral navigation state
-> no legacy startup/readiness semantic authority
-> no ambient live-update mutation yet
```

This task deliberately does **not** yet implement the Operating-owned
`ChatDbChangeMonitor` replacement from Response 54 Design B.

That is a separate follow-up milestone.

The purpose is to qualify the semantic handoff into the normal UI before adding
long-lived automatic currentness maintenance.

After this task, exactly three AppCzar dispositions may be executable in the
development harness:

```text
Data Update
Source Access Repair
Operating Session
```

All others remain virtual.

Do NOT route production startup through AppCzar.
Do NOT delete production legacy startup yet.
Do NOT make Onboarding executable.
Do NOT make Local Data Repair executable.
Do NOT make Attachment Archive Repair executable.
Do NOT make Diagnostic Review executable.
Do NOT reintroduce historical navigation restoration.
Do NOT stage, commit, push, merge, or rebase before human qualification.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `7d0393c214c9ad701c0c856f03ddcb17b490ea03`
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

Read:

- Response 50;
- Response 51;
- Response 52;
- Response 53;
- Response 54;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Preserve the exact Operating selection predicate

Do not invent a new `ready` flag.

Operating Session may execute only when the completed AppCzar assessment
already selects:

`AppCzarVirtualCoordinator.operatingSession`

and the exact supporting facts satisfy the current evaluator contract described
in Response 54:

- development/data root admitted;
- import, graph, and overlay not unhealthy or unknown;
- attachment archive condition accepted by the current evaluator;
- Messages source readable;
- source sample stable;
- local dataset complete;
- source/local delta known;
- source is not ahead;
- no higher-priority contradiction selected another disposition.

Bind execution to the exact assessment generation.

Add an explicit:

`shouldExecuteAppCzarOperatingSession(...)`

predicate.

Do not add a generic coordinator dispatcher.

---

# 3. Operating Session Stage One jurisdiction

For this milestone, Operating Session owns only:

> Present the normal MessageLens application UI after fresh AppCzar evidence has
> established a healthy/current installation.

It may own:

- router/navigation for the current process;
- same-session SidebarFlow mutations after user interaction;
- current panel/cassette state;
- normal feature resolvers;
- read-only graph/overlay presentation;
- theme/typography/logging;
- normal window geometry/position restoration;
- ordinary user navigation.

It does NOT yet own:

- ambient source polling;
- automatic `LiveGraphUpdateWorker` execution;
- background Data Update behavior;
- automatic Start Fresh/reset execution;
- old Journey/readiness recovery semantics.

Those are intentionally deferred.

---

# 4. Do not reuse the generic current `App` composition blindly

Response 54 found that the current generic `App` root still starts or mounts
legacy semantic machinery, including:

- unconditional `chatDbChangeMonitorProvider`;
- Journey/gate/status consumers;
- Environment Readiness projection;
- `OnboardingCenterPanelSyncObserver`;
- onboarding sidebar/overlay ownership;
- pipeline-incident center takeover;
- automatic SidebarFlow durable semantic restoration;
- Journey-dependent Advanced Start Fresh presentation/action.

Audit the current composition and extract/reuse the **normal shell pieces** only.

Preferred shape:

```text
AppCzarStartupHarness
-> explicit Operating branch
-> OperatingSessionHost
-> normal router / MacosAppShell / workspace
```

without remounting the legacy startup authority stack.

Do not create a second nested `MacosApp` if the current harness already owns the
top-level `MacosApp`.

If the framework structure requires a root composition refactor, keep it
mechanical and shared; production startup behavior must remain unchanged.

---

# 5. Neutral navigation is a hard invariant

A fresh Operating Session must begin from current neutral defaults:

```text
sidebar mode: Messages
top branch: Conversations
selected conversation: none
selected contact: none
selected handle: none
persistent Settings context: none
center panel: empty / neutral
right panel: empty
```

Use existing neutral provider defaults where possible.

Do **not**:

- mount the shell and then clear stale selections;
- restore `sidebar_flow_navigation`;
- restore prior contact/conversation selection;
- restore prior center/right semantic content.

Prevent automatic semantic restoration before the shell becomes visible.

Same-session user navigation becomes authoritative only after Operating has
started.

---

# 6. Durable navigation preference becomes history-only in Stage One

Do not delete the stored preference yet.

Instead, make the AppCzar Operating composition ignore automatic semantic
restoration.

The old stored value may remain untouched on disk.

Stage One semantics:

```text
fresh Operating occurrence
-> ignore stored semantic navigation preference
-> use neutral defaults
-> user navigates
-> same-session state updates normally
```

Do not offer `Restore last view` yet.

Do not change production legacy behavior outside the exact development AppCzar
route.

---

# 7. Remove legacy semantic authority from the Operating composition

The development Operating shell must not watch/read/listen to any of these as
application-state authority:

- `MessageLensInstallationState`;
- installation classifier/provider;
- Onboarding Journey;
- Onboarding compatibility status/gate;
- Environment Readiness semantic state;
- `OnboardingCenterPanelSyncObserver`;
- onboarding sidebar visibility owner;
- onboarding overlay;
- persisted onboarding failure promoted into current state;
- pipeline incident history promoted into current center content;
- legacy startup completion callbacks/handoffs.

It is acceptable for those classes to remain compiled for the untouched
production route.

Add architecture tests that the new Operating Session package/composition cannot
import those authorities.

---

# 8. Temporarily disable ambient live update in AppCzar Operating Stage One

This is intentional.

The current `ChatDbChangeMonitor` must **not** start from the new Operating
composition in this task.

Reason:

Response 54 established that the current monitor is ambient/self-authorizing
and therefore not yet suitable as the Operating-owned currentness service.

For Stage One:

- do not watch `chatDbChangeMonitorProvider`;
- do not start a timer/poller;
- do not invoke `LiveGraphUpdateWorker`;
- do not run attachment sweep automatically.

This is a development-only qualification limitation.

Display no misleading “live updating” claim.

The human qualification should be short enough that ordinary source advancement
is not relied upon.

A later prompt will implement Response 54 Design B as an Operating-owned service.

---

# 9. Fix display-identity resolver currentness before Operating qualification

Response 54 identified one remaining prerequisite:

`displayIdentityResolverProvider` currently builds an immutable identity map but
does not watch `messageDataVersionProvider`.

Correct that dependency with the smallest idiomatic change.

Preferred behavior:

- resolver cannot be constructed before Operating admission in the development
  AppCzar path;
- after admission, it watches the current message-data generation or is
  explicitly generation-bound;
- a graph-generation change invalidates/rebuilds the resolver;
- no selected contact is required to “repair” identity display.

Do not create a second identity cache.

Add focused tests proving:

1. no resolver construction in the AppCzar assessment/coordinator phases;
2. resolver currentness changes with message-data generation;
3. populated graph identities render correctly on first Operating construction;
4. resolver does not require navigation/provider recreation to become current.

---

# 10. Window restoration is visual only

Retain automatic restoration only for non-semantic window properties already
supported, such as:

- width;
- height;
- x/y position;
- theme/appearance;
- minimized state if current product behavior intentionally keeps it.

Do not restore:

- selected contact;
- selected conversation;
- center/right semantic content;
- readiness/onboarding panel;
- coordinator/disposition state.

If `sidebarWidth` has no current consumer, leave it untouched as historical data
for now rather than expanding scope.

---

# 11. Advanced Start Fresh during Stage One

The current Advanced Start Fresh command is still Journey-dependent according
to Response 54.

Do not allow that old Journey boundary to regain semantic authority merely
because the Settings UI is mounted.

For this Stage One development Operating composition, choose the smallest safe
option:

- hide/disable the Advanced Start Fresh action in the AppCzar Operating route,
  with no effect on production; OR
- expose it only if it can be mechanically routed to a bounded existing reset
  worker without Journey semantic handoff and without expanding this task.

Default preference: **development-only hide/disable**.

Do not redesign reset in Prompt 55.

Report the exact choice and why.

---

# 12. Operating Session execution seam

Add the smallest explicit host/controller needed to admit Operating exactly once
for one AppCzar assessment generation.

Do not create an elaborate long-lived coordinator framework.

Required properties:

- exact admission predicate;
- one occurrence per assessment generation;
- no generic enum dispatch;
- no process restart merely for successful Operating entry;
- no handoff payload from AppCzar beyond the current admitted generation;
- once Operating is mounted, AppCzar assessment controls are gone;
- Operating does not call AppCzar again in-process.

For Stage One, normal user quit simply quits.

---

# 13. Development-only scope

The exact development AppCzar startup gate remains the only route into this new
Operating composition.

Production continues through the legacy route unchanged.

Architecture tests must prove:

- production startup composition is unchanged;
- AppCzar Operating cannot be reached outside the exact development gate;
- legacy production code remains compiled but is not imported by the new
  Operating composition.

---

# 14. Tests

Use fixtures/temp stores only.

At minimum prove:

1. exact healthy/current AppCzar predicate admits Operating;
2. any non-Operating disposition cannot admit Operating;
3. one Operating occurrence per assessment generation;
4. exactly three executable AppCzar dispositions now exist:
   - Data Update;
   - Source Access Repair;
   - Operating Session;
5. no generic coordinator dispatch exists;
6. neutral SidebarFlow defaults are present at first Operating frame;
7. stored contact/conversation/navigation preference is ignored on fresh
   Operating entry;
8. center/right panels begin empty/neutral;
9. same-session navigation works normally after entry;
10. normal shell feature resolvers work after admission;
11. no Journey/gate/status/readiness listener is mounted;
12. no center-panel sync observer is mounted;
13. no pipeline incident history can take over startup center content;
14. no ambient `ChatDbChangeMonitor` starts;
15. no `LiveGraphUpdateWorker` is invoked by Stage One Operating;
16. no archive mutation Ball is acquired merely to enter Operating;
17. display identity resolver is not built pre-admission;
18. display identity resolver observes/invalidate on message-data generation;
19. initial contact identity rendering uses the populated current graph;
20. no click/navigation is required to repair fallback `contact <id>` names;
21. window geometry can restore without semantic selection restoration;
22. Advanced Start Fresh is absent/disabled or otherwise cannot invoke Journey
    from the AppCzar Operating route;
23. Data Update and Source Access Repair regressions still pass;
24. production-route regression remains unchanged.

---

# 15. Human qualification artifact

Build but do not launch the final development artifact.

The human qualification will begin from a healthy/current zero-delta state.

Expected sequence:

```text
direct launch
-> fresh AppCzar assessment
-> Operating Session selected
-> normal MessageLens shell appears
```

Expected first shell state:

```text
Conversations
no selected conversation
no selected contact
neutral/empty center
no readiness/onboarding panel
```

The human will then:

1. inspect Contacts and confirm names are correct immediately;
2. navigate to a contact/conversation;
3. quit normally;
4. direct-launch again;
5. confirm fresh AppCzar reassesses;
6. confirm Operating starts neutral again rather than restoring the prior
   semantic selection.

Do not test incoming-message live updates in this Stage One qualification.

That belongs to the next milestone.

---

# 16. Stop gates

STOP AND REPORT if implementation requires any of the following:

- importing Journey/readiness authority into the new Operating composition;
- clearing stale semantic state after shell mount instead of preventing restore;
- running `ChatDbChangeMonitor` unchanged;
- invoking Data Update from Operating;
- adding a generic coordinator dispatcher;
- routing production startup through AppCzar;
- nesting conflicting `MacosApp` roots;
- keeping display identity stale until navigation occurs;
- changing real data during automated tests.

---

# 17. Validation

Run:

1. focused Operating admission tests;
2. neutral navigation tests;
3. display-identity generation tests;
4. shell composition tests;
5. Data Update regressions;
6. Source Access Repair regressions;
7. AppCzar mapping/host tests;
8. architecture tests;
9. complete architecture suite;
10. analyzer;
11. full deterministic Flutter suite;
12. `git diff --check`;
13. formatting/generated consistency;
14. development macOS build.

Do not launch production.

---

# 18. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- Operating admitted only from fresh current evidence;
- neutral navigation at entry;
- historical semantic restoration disabled;
- legacy Journey/readiness authorities absent from Operating composition;
- ambient monitor disabled for Stage One;
- display identity current on first use;
- no Ball for entry;
- no coordinator chaining;
- exactly three executable AppCzar dispositions;
- production startup unchanged.

---

# 19. Leave unstaged for human qualification

Do not stage, commit, push, merge, or rebase.

Build the exact development artifact.

Provide:

- bundle path;
- version/build;
- executable SHA-256;
- App.framework SHA-256;
- exact direct-launch preparation;
- exact human neutral-shell qualification steps.

Then STOP.

---

# 20. Required response

Create Response 55 and report:

1. baseline verification;
2. exact Operating selection predicate reused;
3. Operating execution seam;
4. proof exactly three dispositions are executable;
5. shell composition strategy;
6. legacy semantic-authority exclusions;
7. neutral navigation implementation;
8. durable navigation history-only behavior;
9. center/right panel initial behavior;
10. ambient monitor suppression;
11. display-identity resolver correction;
12. display-identity focused tests;
13. window restoration behavior;
14. Advanced Start Fresh handling in Stage One;
15. Operating admission tests;
16. neutral navigation tests;
17. shell composition tests;
18. Data Update regression result;
19. Source Access Repair regression result;
20. AppCzar mapping/host result;
21. architecture result;
22. analyzer result;
23. full Flutter-suite result;
24. diff/format/generated hygiene;
25. Project Conformance verdict;
26. BLOCKER findings;
27. SHOULD FIX findings;
28. exact build identity/path/hashes;
29. exact Git/worktree/index/submodule state;
30. readiness for human neutral-shell Operating qualification;
31. explicit reminder that live currentness monitoring is intentionally deferred
    to the next milestone.

Conclude exactly:

`APPCZAR OPERATING SESSION STAGE ONE IMPLEMENTED: YES / NO`

`FRESH OPERATING ENTRY RESTORES HISTORICAL SEMANTIC NAVIGATION: YES / NO`

`LEGACY JOURNEY/READINESS AUTHORITY PRESENT IN APPCZAR OPERATING SHELL: YES / NO`

`AMBIENT LIVE UPDATE ENABLED IN STAGE ONE: YES / NO`

`READY FOR HUMAN NEUTRAL-SHELL OPERATING QUALIFICATION: YES / NO`

Then STOP.
