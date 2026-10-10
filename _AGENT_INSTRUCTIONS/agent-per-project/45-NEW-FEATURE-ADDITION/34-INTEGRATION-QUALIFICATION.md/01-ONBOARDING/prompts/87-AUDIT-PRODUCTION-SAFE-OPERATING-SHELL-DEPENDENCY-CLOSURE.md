# MessageLens Feature 34
## 87 — Checkpoint Inactive Production Eligibility and Audit Production-Safe Operating-Shell Dependency Closure

**Task type:** whole-repository, source-grounded, **audit/design only**. Do not implement Stage 2 in this prompt.

Response 86 implemented the first, deliberately inert production-cutover seam:

```text
native + Dart archive admission
  -> immutable ArchiveAccessAuthority
  -> official production identity may be AppCzar-eligible
  -> ProductionAppCzarActivation.disabled (unconditionally FALSE)
  -> production continues to StartupApp / legacy Journey
```

The official development composition remains AppCzar; the production process restarter remains **development-only**; the WD root/UUID attachment-adoption gate remains operation-specific. Response 86 passed Project Conformance with zero in-scope BLOCKER and SHOULD FIX findings, and no real application or data was touched.

**Stage 2's objective** is to identify the complete, minimal dependency closure required for the *normal MessageLens product shell* to run under an eventual AppCzar-owned production Operating Session without importing legacy startup semantics, losing user features, or creating a second data-update worker. It is **not** to activate production, delete Journey, or implement any rewiring yet.

The governing rule is:

> The future production Operating shell must preserve legitimate user-visible features and their exact specialist authorities, but may not let the legacy Journey, installation classifier, Environment Readiness, center-panel takeover, or ambient source monitor acquire a second opinion about application state.

This task must distinguish **reuse of working UI/worker mechanics** from **reuse of obsolete semantic authority**. A shell that simply hides legacy surfaces, or a shell that drops existing functionality, is not an acceptable design.

---

# 1. Exact baseline and safety gates

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- starting HEAD/upstream `53a695706e483ea6064da2376f4e0edf1ba7f973`, or resolve and explain any subsequent change before continuing;
- ahead/behind `0/0`;
- tracked worktree and index clean;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one worktree on the Feature 34 branch;
- all known unrelated untracked files left untouched.

Create a fresh Git/source-only baseline manifest under `/private/tmp`, including branch topology, source hashes for audited entry points, and explicitly enumerated permitted audit outputs.

Read in full:

- Responses 51, 54, 55, 61/Operating Stage Two (as applicable), 70, 71, 72, 76, 77, 80, 82, 84, 85, and 86;
- the canonical Project Conformance standard;
- the source-level architecture and user-command inventory;
- current production and development composition policies;
- the actual widget/provider/action/mutation paths listed below.

If a referenced prior response is unavailable, search the project records and state the gap; do not invent its conclusions.

**Do not** launch, install, build, notarize, test with live resources, alter source/tests/generated files, touch launchd/FDA/TCC, query any real MessageLens or Apple database, enumerate any real archive, or change production application state. Do not switch, merge, rebase, cherry-pick, or modify another worktree.

---

# 2. Checkpoint Prompt 86 / Response 86 first

Verify both records and that no documentation checkpoint duplicates already exist.

Response 86 reports:

- implementation: `4a8b549e65bf16416065797aeaebde062f8558fd`;
- documentation: `53a695706e483ea6064da2376f4e0edf1ba7f973`;
- official production eligibility is pure and source-grounded;
- activation is mechanically disabled;
- production remains `StartupApp`;
- development remains AppCzar;
- adoption mutation gate remains WD/UUID-specific;
- no restart, signing, build, real-data, or product behavior changed.

These records are already reported committed and pushed. **Do not recommit them.** Verify the actual hashes and ancestry; report any discrepancy. Keep Prompt 87 / Response 87 unstaged as the audit evidence, unless a separate explicit instruction changes that convention.

---

# 3. Reconfirm the inactive production boundary

Source-trace, not merely quote tests:

```text
native claim / Dart archive admission
  -> admitted ArchiveAccessAuthority
  -> AppCzarDevelopmentCompositionPolicy
  -> AppCzarProductionCompositionEligibilityPolicy
  -> ProductionAppCzarActivation.disabled
  -> selectMessageLensStartupPresentation
```

Prove separately:

1. No production AppCzar composition is currently mounted.
2. `ProductionAppCzarActivation` has no enabled constructor, runtime switch, persisted key, configuration, or environment override.
3. Production eligibility is independent of physical root/UUID and is never used to grant a Ball, process restart, attachment adoption, or source access.
4. The current development policy still exclusively governs development restarts, neutral-navigation restoration suppression, and Journey-dependent Start Fresh suppression.
5. The operation-specific WD/UUID adoption gate is not a global composition selector.
6. Production native/signature/root/marker admission remains before this logic.

Do not change this contract in Prompt 87.

---

# 4. Reconstruct the two actual shell graphs

Build exact call graphs with file/function/line anchors for both:

```text
PRODUCTION TODAY
main -> StartupApp -> App -> router -> MacosAppShell
  -> MessageLensWorkspaceShell
  -> Journey / Environment / center observers / overlays
  -> normal features and ordinary session actions
```

```text
APPCZAR DEVELOPMENT TODAY
main -> AppCzarStartupHarness
  -> selected coordinator host OR AppCzarOperatingSessionApp
  -> neutral MessageLensWorkspaceShell
  -> AppCzar-owned Operating services and normal features
```

Record:

- who constructs the top-level `MacosApp` and router;
- when `ProviderContainer`, root-scoped providers, and logging become available;
- exactly which normal shell widgets are shared;
- which wrappers add Journey/Environment/operation overlays;
- which providers perform actions merely by being watched or constructed;
- which normal features are absent, disabled, or altered in development AppCzar Operating;
- which differences are deliberate launch semantics versus accidental missing functionality.

Separate **pure view composition**, **read-only observation**, **user command**, **background worker**, and **global semantic authority**. Do not count a compiled but unmounted legacy provider as active.

---

# 5. Complete legacy-authority reachability census

Trace transitive import/watch/listen/invalidation/action paths for all of these, including less-visible callers:

- `StartupApp` and installation-state classification;
- Journey Trip/Step/Episode and legacy `OnboardingGate`/compatibility status;
- `OnboardingOverlay`, visibility owner, Presence host;
- `OnboardingCenterPanelSyncObserver` and controller;
- Environment Readiness selection, action bridge, and ViewSpec publication;
- pipeline-incident center takeover;
- durable operation snapshots, failure records, reconciliation, and legacy completion callbacks;
- Journey-dependent Advanced Start Fresh presentation/actions;
- `App.build()` and any unconditional `chatDbChangeMonitorProvider` subscription;
- support/log export and technical-details surfaces that construct legacy providers;
- generic router/shell hooks that restore prior semantic navigation;
- all other source-verified indirect readers/writers of the above.

For every edge report:

```text
producer / consumer
source path and function
when constructed
whether it observes historical fact or asserts current authority
whether construction starts work or mutates state
expected ownership in future AppCzar production shell
KEEP / REUSE LOWER-LEVEL / REWIRE / DEMOTE / DELETE LATER
prerequisites for safely removing the edge
```

A hidden watcher remains a blocker even if its UI is covered by another screen. Conversely, never propose deleting fact readers or specialist workers solely because the legacy UI happens to call them.

---

# 6. Inventory complete normal-product feature parity

Audit the **real currently exposed product**, not an imagined feature list. At least cover:

- Conversations, Contacts, Favourites and saved/working-set views where present;
- message timelines, timeline jumps/search, tags, notes, suppressed and dormant visibility;
- attachment display, archive resolution and coverage/debt notices;
- Settings, About/Environment/technical-detail panels and preferences;
- attachment-location selection, relocation, retained-source review, repair/recovery controls;
- explicit Start Fresh / rebuild / reimport controls;
- historical-source import, list, removal, and protected provenance;
- support/export and diagnostic access;
- sidebar/cassette/panel navigation and keyboard/menu commands;
- window geometry, appearance/theme, normal Quit, modal dialogs;
- any supported feature uncovered by source audit.

For every feature supply a parity matrix with:

| Product capability | Production legacy entry | AppCzar development entry | Current status | Actual user intent/data touched | Specialist owner | Proposed reuse/rewire | Qualification |

Status vocabulary:

```text
PRESENT AND REUSED
PRESENT BUT SEMANTICALLY DIFFERENT BY DESIGN
DISABLED IN APPCZAR DEVELOPMENT
LEGACY-ONLY
NOT YET SOURCE-PROVEN
```

Do not assume a control is present or operational merely because its underlying widget exists. Trace its button/menu callback to the executable specialist and its capability.

---

# 7. Operating navigation and UI authority

Recheck the qualified Operating contract:

```text
fresh Operating process
-> neutral Conversations / no selected contact, handle, or conversation
-> no persisted prior center/right semantic selection as current authority
-> ordinary same-session navigation permitted
```

Trace:

- `SidebarFlow` state, its restoration policy and overlay preferences;
- selected contact/conversation/handle, centre/right panel stacks, cassette projections;
- user-initiated changes and how preferences are persisted;
- settings/menu commands that require a selected context;
- any production-only window/overlay initialization.

**Keep distinct** window geometry/appearance/preferences from semantic selection and old Journey state. Preserving preferences does not mean silently restoring an obsolete startup semantic conclusion. Avoid a post-mount reset/clear race; design the correct pre-mount composition policy.

Identify the minimum reusable lower-level neutral navigation and Settings shell pieces, and exact places where development-only policy needs eventual independent production activation binding.

---

# 8. Start Fresh / Reimport: preserve command without Journey

Trace the complete current product path:

```text
visible Settings / menu intent
-> human authorization / confirmation
-> eligibility recheck
-> typed mutation admission
-> MessageDataResetService / existing worker
-> physical postcondition
-> process and user-visible terminal
```

Separate:

- explicit Start Fresh of an otherwise healthy dataset;
- failed/partial derived-data Local Data Repair;
- optional user-requested reimport/rebuild;
- historical-source removal;
- ordinary Operating live currentness.

Answer exactly:

1. Which commands are actually available in production today?
2. Which are suppressed in development AppCzar, and why?
3. Which UI controllers import Journey or use durable operation conclusions as authority?
4. Which lower workers/validators/consent panels can be reused without old authority?
5. What exact Ball/capability, data-preservation, and restart terminal does each require?
6. What must be added to Operating/Settings before turning off the legacy composition?

**Do not implement** or silently drop any command. A new command host must never use AppCzar assessment as permission to erase data; human command authorization remains separate.

---

# 9. Historical-source and protected-provenance commands

Trace existing historical-source import/removal workflows, read-only donors, explicit user confirmation, and preservation protections.

Identify exact UI and worker seams. Preserve all source registry/overlay provenance and any imported historical messages. A future production shell must not convert historical removal into Local Data Repair or Start Fresh. The current Local Data Repair safety class remains intentionally too narrow to erase protected history.

Identify any lifecycle handoff that currently depends on Journey or a same-process `ReadyToStart` conclusion, and propose a real drain/restart boundary where current startup facts change.

---

# 10. Attachment location, repair, preservation, and recovery

Audit each user-facing command and read-only status path for:

- archive binding/location and bookmark restoration;
- internal/custom external archive selection;
- relocation/copy/verify/finalize, pause/resume/cancel, journals/receipts;
- disconnected/read-only media and retained-source review;
- required coverage and source-absent debt display;
- human-confirmed bounded preservation/record-backed recovery;
- adoption's separate root/UUID gate.

Specify which normal Settings flows already run under the neutral AppCzar Operating shell and which depend on production legacy wrappers. Maintain current exact-tenure/Ball, writable-lease, no-overwrite, binding/generation, and human-consent contracts. None may be automatically executed by selecting a composition.

---

# 11. One currentness owner and one importer-admission path

Source-trace the exact current paths to:

```text
chatDbChangeMonitorProvider
LiveGraphUpdateWorker
ConversationGraphBuildController / graph-build orchestration
archive preservation/sweep
OperatingCurrentnessService or current equivalent
messageDataVersion publication
```

Enumerate every startup or widget-construction edge that starts a timer, poller, importer, attachment sweep, or background work.

The future AppCzar production shell must have:

```text
before Operating admission:
    no ambient mutation worker

once Operating admitted:
    exactly one Operating-owned currentness occurrence
    same-PID update only while current Operating jurisdiction remains valid

jurisdiction change:
    stop/drain -> real restart -> fresh AppCzar
```

Propose static import/reachability tests and provider-construction tests capable of catching a second live monitor. Do not merely assert that Operating's existing monitor is good; prove the old one cannot start in the new production composition.

---

# 12. Support/diagnostic parity and privacy

Audit existing support export, logs, Environment Summary, technical panels, and their provider dependencies. Response 81/82 already established that the old exporter can construct Journey/onboarding operation state; Diagnostic Review intentionally excluded it.

Design distinct entry points for:

1. **Diagnostic Review**: frozen, bounded, user-visible assessment; no implicit export, copy, or new readers.
2. **Operating support**: user-initiated support details/export which may combine current facts with clearly labelled historical logs under explicit privacy controls.

Any future reusable exporter must use a privacy-reviewed formatter that does not create a second semantic classifier. Specify redaction of personal message/contact content, technical paths/UUIDs by default, output limits, user consent, and a destination that is not an implicit write to the archive root. Reuse useful existing lower mechanics where possible, but never import old Journey authority.

Audit whether lack of equivalent support functionality is a cutover BLOCKER versus explicitly approved deferred functionality.

---

# 13. Background/foreground lifecycle and provider construction order

Inspect the normal Flutter/macOS window lifecycle, provider containers, route construction, disposal, ordinary Quit, and application reopen semantics.

Identify how future production AppCzar can be selected **only after** immutable admission without eagerly:

- opening/migrating active databases;
- restoring old Journey completion/failure;
- constructing normal Operating navigation prematurely;
- creating or retaining hidden source monitors;
- invoking a special-purpose worker before jurisdiction selection.

Use the existing qualified coordinator lifecycle hosts. Do not propose a parallel lifecycle framework.

---

# 14. Production activation must remain inactive

Record an explicit dependency rule:

```text
Stage 1 eligibility   DONE
Stage 2 shell closure PENDING
Stage 3 restarter     PENDING
Stage 4 migration     PENDING
...
Production activation FALSE throughout
```

This prompt must not:

- introduce an enabled `ProductionAppCzarActivation` value;
- add a runtime or persisted activation input;
- change `selectMessageLensStartupPresentation`;
- broaden `AppCzarDevelopmentCompositionPolicy` or the development restarter;
- change marker/UUID/root handling;
- broaden the WD adoption operation gate;
- alter any worker or production startup provider;
- build or launch a production-like app.

The future reusable shell may be designed in the audit; it may not be mounted in product code yet.

---

# 15. Design the minimal production-safe shell composition

Provide a source-grounded target graph, e.g.:

```text
AppCzarStartupHarness (already admitted authority)
  -> one exact coordinator host
  OR
  -> AppCzar Operating lifecycle host
      -> one MacosApp/router
      -> reusable MessageLensWorkspaceShell
      -> normal browsing / navigation / Settings
      -> explicit user commands with specialist authority
      -> one Operating currentness service
      -> NO Journey / Environment / ambient monitor
```

Identify concrete existing components to reuse as-is, and the **smallest necessary extraction/adapter** for each incompatible feature.

**Do not build a new generic UI framework, second router, parallel Settings subsystem, second importer/projector, or duplicate archive controls.** Existing mechanics are presumed reusable until source proves otherwise.

For each proposed extraction specify:

- exact source files/functions and inbound/outbound dependencies;
- production legacy compatibility while activation remains false;
- tests to ensure the old product remains unchanged;
- tests to ensure AppCzar composition stays free of legacy authority;
- no hidden creation of background workers;
- how the feature will be human-qualified on disposable fixtures.

---

# 16. Build a dependency-ordered implementation backlog

The audit result must not be one giant refactor. Propose small follow-on prompts/checkpoints, each with:

- title and exact objective;
- prerequisite and expected source files;
- reuse/extraction scope;
- forbidden changes;
- automated test matrix and negative tests;
- Project Conformance gate;
- whether a disposable human qualification is required;
- stop conditions;
- exact completion criteria.

Prefer decomposition along actual source-owned subsystems, not arbitrary file count.

Expected themes (split/merge based on source truth):

```text
A. pure neutral shell composition / legacy provider reachability exclusions
B. navigation and Settings product parity
C. explicit Start Fresh and rebuild commands
D. historical-source command parity
E. archive location / recovery / preservation command parity
F. privacy-safe support/export capability
G. sole Operating currentness worker / old ambient monitor exclusion
H. production shell composition integration with activation still FALSE
```

Explain ordering constraints; notably, do not activate a production AppCzar shell before every required user command and single-writer guarantee is qualified. Production restarter, whole-root schema/migration qualification, signed rehearsal, backups, and explicit go/no-go remain separate later stages from Response 85.

---

# 17. Architecture-test and human-qualification proposal

Specify static and widget/provider tests that prove:

- production legacy route remains mounted while activation is false;
- development AppCzar remains unchanged;
- the future production AppCzar shell has no Journey/Environment/old snapshot semantic consumer;
- no ambient `chatDbChangeMonitorProvider` or secondary source worker is initialized;
- exactly one router/normal workspace exists after Operating admission;
- neutral initial sidebar/center/right semantics precede user action;
- all required Settings/menu/keyboard commands remain discoverable and authorized;
- historic provenance, user overlay and attachment data remain protected;
- no action runs merely because a widget mounts;
- long-running mutations drain before restart;
- no generic coordinator dispatcher or parallel readiness evaluator is introduced.

Design later disposable fixture tests for command availability, protected-state preservation, navigation and currentness; do not create fixtures yet. Be explicit about features that need separate human consent or cannot be exercised safely.

---

# 18. Risk register and go/no-go for beginning Stage 2 implementation

Rank each unresolved item:

```text
BLOCKER to shell parity
BLOCKER to staged production-identity rehearsal
BLOCKER to actual cutover
SHOULD FIX
FUTURE QUALIFICATION
```

Include at least:

- legacy provider/watcher/worker reachability;
- product command disappearance or authority leakage;
- dual source monitor/import worker;
- navigation-state regression;
- support/export privacy or loss of diagnostics;
- archival location/repair UI and backend coupling;
- persistent user-intent and history preservation;
- production restart absent;
- production-shaped migration/signature/TCC/backups still unqualified;
- genuine Messages-source UNKNOWN automated-only human gap.

Do not mislabel cutover blockers as blockers to a successful *audit*. Conversely, do not let a `PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)` claim actual production readiness.

---

# 19. No implementation / validation contract

This is **audit-only**, including any source/test findings. No need to run Flutter tests/analyzer/build, because no implementation changes are authorized. Do run read-only Git/source inspection and exact references. If a source gap requires creating code to resolve it, STOP AND REPORT instead of silently changing scope.

Create Response 87 under the existing numbered Feature 34 response directory. Leave Prompt 87 and Response 87 untracked for the next documentation checkpoint, as with prior audit-only responses.

The final state must retain:

```text
source/test/generated/release files unchanged
production activation FALSE
production still StartupApp
no apps built/launched
no real data roots, databases, Apple sources, bookmarks, TCC touched
clean tracked worktree and index
origin branch synchronized
shared instructions submodule unchanged
unrelated untracked files untouched
```

---

# 20. Required Response 87

Report:

1. baseline branch/HEAD/upstream/worktree/submodule and verified Response 86 checkpoint;
2. admitted-authority and inactive production selector reconfirmation;
3. exact production shell graph;
4. exact development AppCzar Operating shell graph;
5. shared widget/router/provider composition inventory;
6. legacy Journey/Environment/installation semantic-owner reachability census;
7. center-panel/overlay/visibility/pipeline-incident side-effect edges;
8. source monitor/background-worker construction census;
9. all normal product features and parity matrix;
10. navigation and Settings/menus/keyboard command provenance;
11. explicit Start Fresh/reimport action path and reusable lower worker seams;
12. historical-source import/removal action path and protections;
13. attachment-location/relocation/repair/recovery command parity;
14. sole currentness worker and graph/import admission design;
15. support/diagnostic/export privacy and authority design;
16. window lifecycle, provider construction, Quit and restart boundary analysis;
17. root/identity/adoption gate noninterference;
18. minimal reusable production-safe shell target graph;
19. source files/classes to KEEP, REUSE, REWIRE, DEMOTE, DELETE LATER;
20. complete dependency-ordered implementation backlog with proposed next numbered prompt;
21. architecture and provider-construction test plan;
22. disposable human qualification plan;
23. ranked BLOCKER/SHOULD FIX/FUTURE QUALIFICATION register;
24. source-grounded proof production remains inactive/legacy;
25. Project Conformance audit/design verdict;
26. whether implementation proceeded (must be NO);
27. exact final Git/worktree/index/submodule state;
28. readiness for first narrow Stage 2 implementation;
29. readiness for staged production-identity rehearsal;
30. readiness for actual production cutover.

Conclude exactly:

```text
RESPONSE 86 INACTIVE ELIGIBILITY CHECKPOINT VERIFIED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS UNCONDITIONALLY OFF: YES / NO
PRODUCTION STILL SELECTS LEGACY STARTUPAPP: YES / NO
DEVELOPMENT APPCZAR COMPOSITION IS UNCHANGED: YES / NO
ALL LEGACY SHELL AUTHORITY CONSUMERS HAVE BEEN INVENTORIED: YES / NO
EXISTING NORMAL USER COMMANDS HAVE PRESERVATION/REWIRE PLANS: YES / NO
SECOND AMBIENT SOURCE MONITOR HAS AN EXPLICIT EXCLUSION PLAN: YES / NO
PRODUCTION-SAFE SHELL IMPLEMENTED IN THIS PROMPT: NO
PROJECT CONFORMANCE: PASS / FAIL (AUDIT/DESIGN SCOPE)
READY FOR FIRST NARROW STAGE 2 IMPLEMENTATION: YES / NO
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP. No source implementation or production action may follow in the same run.
