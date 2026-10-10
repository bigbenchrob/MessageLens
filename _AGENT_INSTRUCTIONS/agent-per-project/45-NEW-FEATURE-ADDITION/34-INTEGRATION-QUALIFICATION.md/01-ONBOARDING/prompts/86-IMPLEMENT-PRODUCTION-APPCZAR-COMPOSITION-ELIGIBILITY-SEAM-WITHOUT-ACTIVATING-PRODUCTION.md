# MessageLens Feature 34
## 86 — Implement Production AppCzar Composition Eligibility Without Activating Production

Response 85 completed the whole-repository, audit-only AppCzar production-cutover assessment. The audit found **eight blockers to actual production cutover**. It also identified one narrow implementation that can be safely undertaken before those blockers are removed:

> An already archive-admitted, official production MessageLens installation may be recognized as *eligible* for the future AppCzar composition, while production *activation remains false* and the actual application continues to select its existing legacy startup path.

This prompt implements **Stage 1 only** of Response 85's dependency-ordered plan. It does **not** authorize Stage 2 (shell rewiring), a production restarter, production-like migration rehearsals, signing changes, a production build, installation, launch, or cutover.

The desired separation is:

```text
native archive admission + Dart archive admission
    -> immutable ArchiveAccessAuthority
    -> official application-identity eligibility
    -> independent production activation policy (OFF)
    -> startup composition choice

production official identity + eligible + activation OFF
    -> StartupApp, unchanged

development official identity + admitted archive
    -> AppCzarStartupHarness, unchanged
```

Eligibility is **not** archive admission, permission to mutate, process-restart authorization, a current AppCzar disposition, or a user-setting preference.

**Hard rule:** After this task, every actual shipped/ordinary production startup must still use `StartupApp`. AppCzar's production restarter and safe Operating shell dependencies are *not* ready for activation.

Do NOT access real MessageLens databases, WD or Toshiba archives, Apple Messages, Contacts, markers, UUIDs, bookmarks, or TCC. Do NOT launch or install either app. Do NOT modify native signing, entitlements, root identity, release metadata, migration code, reset code, or existing coordinator semantics.

---

# 1. Baseline and governing evidence

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch: `fix/onboarding-import-stuck-state`;
- initial HEAD/upstream synchronized `0/0`;
- tracked worktree and index clean;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one worktree on Feature 34;
- no unrelated staging or modification.

Verify the Prompt 84/Response 84 checkpoint is in ancestry:

`bef7f2bf94c46c0322a49418a3431f7ef16fd6cd`

Resolve **actual** HEAD and upstream from Git. Do not presume Response 85's own documentation commit hash exists yet. If any startup implementation changed since Response 85, reconcile it first and STOP if this prompt's narrow contract is no longer valid.

Read **Response 85 in full** and use its Sections 5–8, 14–15, 24, 27, and 36 as the governing source audit. Also read:

- `lib/main.dart`, including `_admitArchive()` and the exact startup presentation selector;
- `AppCzarDevelopmentCompositionPolicy` and all consumers of its result;
- `ArchiveAccessAuthority`, `ArchiveIdentityValidator`, archive identity/environment/build types;
- native claim/signature verification implementation, *read only*;
- existing development-versus-production identity tests;
- current architecture tests for AppCzar host reachability and the WD-specific attachment-adoption gate;
- the canonical Project Conformance standard.

Write a fresh external baseline manifest under `/private/tmp`, containing only Git/source provenance.

---

# 2. Checkpoint Prompt 85 / Response 85 first

Prompt 85 made no source or test changes.

Create a **documentation-only checkpoint** for precisely Prompt 85 and Response 85, and push normally before editing source.

Preserve the literal audit verdict:

```text
Project Conformance: PASS (AUDIT/DESIGN SCOPE)
Production AppCzar activation: NOT AUTHORIZED
Production restart/quit qualification: NO
Staged signed rehearsal readiness: NO
Next narrow implementation: inactive production eligibility + activation seam
Eight production-cutover blockers remain
Genuine Messages-source UNKNOWN human-live gap remains
```

Do not claim Response 85 qualified production startup or removed the eight blockers.

No `git add .`, force push, squash, rebase, merge, or unrelated staging.

---

# 3. Trace existing identity and composition selection precisely

Before writing code, produce an exact call graph:

```text
native identity / root / signature checks
-> native immutable claim
-> Dart independent canonical-root and marker validation
-> ArchiveAccessAuthority
-> provider container
-> development composition policy
-> selectMessageLensStartupPresentation
-> AppCzarStartupHarness OR StartupApp
```

For every involved type, report **actual field names and trusted provenance**, including:

- archive environment;
- build identity;
- product name;
- bundle identifier;
- production signature verification evidence or the existing admission invariant that proves it;
- whether production identity is already immutable by the time Dart receives `ArchiveAccessAuthority`;
- how null/unadmitted/malformed claims fail before composition selection.

If official production signing cannot be safely grounded in already validated archive-admission authority, **STOP** rather than introducing an untrusted boolean claiming to represent signature validity. Do not add a new native channel or signature shortcut simply to meet the prompt.

Find all existing usages of `AppCzarDevelopmentCompositionPolicy`. In particular, identify:

- development startup selection;
- development-only process restarter;
- neutral navigation restoration behavior;
- Journey-dependent Start Fresh suppression;
- any other coordinator-specific capabilities.

These usages must **not** be silently broadened to production by a generic new `appCzarEnabled` boolean.

---

# 4. Preserve the four distinct authority questions

These must remain independent:

```text
archive admission:
    Is this root and identity safely admitted?

composition eligibility/activation:
    May this official app identity someday use AppCzar, and is that route
    explicitly enabled for this build?

mutation authority:
    Does the exact operation hold its required typed Ball and resource scope?

AppCzar disposition:
    What current bounded evidence selects one jurisdiction?
```

The composition policy must not:

- admit an archive;
- examine a physical root or archive UUID to choose global architecture;
- create/open/migrate any database;
- restore a marker, bookmark, or archive location;
- grant a Ball or attachment-adoption capability;
- run the AppCzar evaluator;
- schedule a process restart;
- start an ambient source monitor.

---

# 5. Add an exact typed official-production eligibility predicate

Implement the smallest pure predicate/policy suitable for current source conventions, conceptually:

```text
productionAppCzarEligible(ArchiveAccessAuthority? authority)
```

It returns TRUE **only** for an already-admitted immutable authority whose trusted identity proves *all* of:

```text
archive environment: production
build identity: productionRelease
bundle identifier: com.bigbenchsoftware.MessageLens
product name: MessageLens
required official production-signature condition: satisfied through existing
    trusted admission contract
```

Use the repository's authoritative enums/constants. Do not compare a `toString()` label when a typed identity is available.

Require FALSE for:

- null / absent authority;
- development identities in any build mode;
- test/FDA-experiment/unsupported build identities;
- production identity with wrong bundle identifier;
- production identity with wrong product name;
- production identity with wrong environment/build combination;
- incomplete or inconclusive signature/admission facts;
- any inconsistent or malformed identity that existing types can represent.

This predicate must be **pure**, side-effect-free, and independent of root path and archive UUID. Do not collapse it into the existing development policy or alter the existing development admission predicate's meaning.

---

# 6. Add a separately typed, default-OFF production activation decision

Production *eligibility* is not production *activation*.

Add the narrowest explicit production activation input, preferably a source-controlled/compile-time policy with the current production value **unconditionally disabled**.

Requirements:

- production activation is `false` in every ordinary current build configuration;
- it cannot be enabled by user preferences, overlay state, marker contents, startup logs, launch arguments, environment variables, remote config, archive root spelling, archive UUID, or an existing development adoption gate;
- no production startup is routed to AppCzar by this change;
- tests can evaluate eligibility and the hypothetical selector truth table **without** enabling the route in any shipped or runnable product composition;
- no new persisted mode flag or durable feature-state record is added.

Prefer a descriptive type (for example `ProductionAppCzarActivation.disabled`) over an unlabeled boolean that may be reused as mutation authority. Follow local style without inventing a framework.

Do not add a public runtime mechanism to flip this value. Later stages must add their own explicitly reviewed activation/authorization gate.

---

# 7. Extend startup composition selection, but leave actual production behavior identical

The conceptual selector contract is:

```text
when archive is not admitted:
    composition selection cannot run or admit anything

when admitted official development identity:
    AppCzarStartupHarness (unchanged)

when admitted exact official production identity:
    production eligibility TRUE
    production activation FALSE
    StartupApp (unchanged)

when any other admitted identity:
    StartupApp (unchanged)
```

Keep the existing `StartupApp(admittedChild: App)` production graph intact, including its current router and legacy presentation. Do not mount the AppCzar host, instantiate AppCzar coordinator providers, or run the AppCzar evaluator from actual production startup.

If tests exercise the hypothetical `eligible && active` branch, they must do so as a pure selector/model test only. **No code path in the current production app should be able to activate the incomplete production AppCzar runtime.**

Do not add a generic enum coordinator dispatcher.

---

# 8. Do not generalize development-only capability consumers yet

Response 85 explicitly identified a development-only restarter and other composition consumers.

This prompt must NOT:

- authorize `MacosDevelopmentProcessRestarter` in production;
- instantiate or implement a production restarter;
- change the `appCzarProcessRestarterProvider` resource policy;
- modify navigation/session restoration;
- enable Journey-dependent Start Fresh for a production AppCzar shell;
- change Operating currentness ownership;
- mount a neutral production AppCzar workspace;
- modify source access, attachment, Onboarding, Local Data Repair, or Diagnostic Review coordinators;
- remove or demote any legacy Journey provider;
- add or remove any mutation operation.

Retain the current WD-root/UUID-specific `attachmentArchiveAdoptionExecutionEnabledProvider` unchanged and absent from composition selection.

---

# 9. Production-inactive and development-preservation test matrix

Create focused tests with constructed **in-memory immutable authority identities**, not real archives or installed apps.

At minimum verify:

1. exact official production identity is eligible;
2. that same identity has production activation OFF;
3. its actual startup selection remains `StartupApp`;
4. production root path variations do not change eligibility;
5. production archive UUID variations do not change eligibility;
6. null/unadmitted identity cannot enable AppCzar;
7. wrong production bundle ID rejects eligibility;
8. wrong production product name rejects eligibility;
9. wrong build environment rejects eligibility;
10. development build identities are not production eligible;
11. FDA experiment and test identity do not become AppCzar-production eligible;
12. official development debug/profile/release continue to select the existing AppCzar development composition;
13. incorrect/missing development identity continues to select its pre-existing route;
14. no production setting/env/marker/root override can turn activation ON;
15. production override remains forbidden by existing archive admission;
16. no archive-claim root or UUID is a global selector;
17. WD attachment-adoption gate remains exact and independent;
18. hypothetical active production selector truth table can be reasoned about without actually mounting incomplete production AppCzar;
19. no persistent provider, database, archive, observer, restarter, or worker is constructed merely by evaluating eligibility;
20. production `StartupApp` / `MacosAppShell` / Journey route remains reachable exactly as before.

When a test cannot construct malformed identities because trusted immutable types reject them, test the relevant existing admission predicate's rejection instead. Do not weaken production identity types merely to add tests.

---

# 10. Architecture tripwires

Strengthen the existing test suite to enforce:

- archive admission must precede composition selection;
- the production eligibility predicate is pure and reads only trusted identity;
- separate production eligibility versus activation;
- activation default is OFF in every actual product path;
- no external or persisted activation toggles;
- official development semantics remain unchanged;
- production still constructs the legacy path;
- no production AppCzar coordinator/controller/restart path is reachable;
- no root/UUID global selector;
- no attachment-adoption gate or Ball used as eligibility input;
- no Journey/Environment/new ambient worker added to an AppCzar composition;
- no changes to the six coordinator execution predicates or Operating admission;
- no generic dispatcher or second semantic owner.

Avoid brittle text-search assertions when an executable policy/host-construction test can prove the behavior. Retain the existing static forbidden-import coverage.

---

# 11. Scope control and project conformance

This stage should change only the source files needed for eligibility, inactive activation, startup selection wiring, and focused tests/architecture assertions.

It must NOT change:

- native macOS claim/lock/signature code;
- bundle identifier/product name/signing/entitlements/notarization;
- production or development archive root selection;
- archive marker/environment/instance UUID;
- database schemas, migrations, providers, or stored user state;
- attachment location/bookmark/coverage/repair/adoption;
- any mutation Ball;
- coordinator host execution semantics;
- process restarter;
- legacy Journey behavior or UI;
- release version/build, `pubspec.yaml` release metadata, changelog/release packaging;
- installer, installed app, or real resources.

If repository convention would mandate a version bump/build for this narrowly inactive policy step, STOP AND REPORT the conflict rather than silently broadening the scope.

Require:

```text
PROJECT CONFORMANCE: PASS
BLOCKER: 0
SHOULD FIX: 0
```

The verdict must specifically confirm that production activation remains false and unchanged product behavior is proven, not merely assumed.

---

# 12. Automated validation

Run the relevant source-only suites:

1. exact production eligibility matrix;
2. inactive activation/selector matrix;
3. development composition regressions;
4. production legacy startup/installation classifier/Journey regressions;
5. archive authority and independent native/Dart admission tests that do not require running a real app;
6. attachment-adoption-gate independence tests;
7. all AppCzar coordinator/Operating composition regressions;
8. complete architecture suite;
9. Flutter analyzer;
10. full deterministic Flutter suite;
11. formatting and generated-code consistency;
12. `git diff --check` and staged diff check.

Do not build, launch, notarize, sign, install, run an emulator, or interact with any real user archive/database. If the only way to validate a proposed source seam is a real app launch or real-data read, STOP AND REPORT.

---

# 13. Checkpoints and handoff

If all gates pass:

1. create a narrow source/test implementation commit;
2. write Response 86 with exact evidence and results;
3. checkpoint Prompt 86 / Response 86 documentation separately;
4. push normally;
5. confirm branch/upstream `0/0`, clean tracked worktree/index and shared submodule.

Suggested implementation commit subject:

`feat(startup): add inactive production AppCzar eligibility`

Do not merge to main. Do not change production activation. Do not create or launch a new artifact.

The next separately reviewed milestone is **Stage 2: production-safe shell dependency closure**, not activation. Its design must preserve settings, support/export, Start Fresh, historical-source controls, and Operating-owned currentness while excluding legacy semantic authority. It is not part of Prompt 86.

---

# 14. Mandatory stop gates

STOP and report, without source workarounds, if:

- official production signature eligibility cannot be grounded in admitted trusted authority;
- eligibility needs to execute before archive admission;
- selector needs root/UUID or attachment-adoption identity to decide architecture;
- activation could become true in any ordinary production build;
- the current production route would change;
- a test accidentally mounts production AppCzar or starts its coordinator;
- production restarter/neutral shell must be implemented to make this compile;
- a developer identity gains any production-specific capability;
- a malformed/UNKNOWN identity becomes eligible by inference;
- an archive, database, marker, user preference, production installation, or TCC state would be touched;
- release metadata, native identity, signing, or mutation policies would change;
- project conformance cannot reach PASS.

---

# 15. Required Response 86

Create Response 86 documenting:

1. exact starting HEAD/upstream, worktree/index/submodule, and merge ancestry;
2. Prompt 85/Response 85 documentation checkpoint and pushed recovery anchor;
3. source-grounded native/Dart archive-admission-to-selector call graph;
4. exact trusted identity fields and signing/admission invariant;
5. existing development-policy uses, especially restarter/navigation/reset;
6. new production eligibility predicate and complete truth table;
7. production activation input and why it is OFF in all current builds;
8. exact startup selector wiring;
9. proof ordinary production still selects `StartupApp`;
10. proof official development still selects `AppCzarStartupHarness`;
11. proof no production AppCzar coordinator/provider/restarter is constructed;
12. proof eligibility is independent of root and UUID;
13. proof adoption mutation gate remains unchanged and separate;
14. proof production root override is still prohibited;
15. proof no migration, database, marker, archive, or persistent preference read/write happens for eligibility;
16. exact source/test/architecture file diff;
17. focused eligibility/activation test results;
18. legacy startup and development regressions;
19. coordinator/Operating regressions;
20. architecture-suite result;
21. analyzer result;
22. full Flutter-suite result;
23. generated/format/diff hygiene;
24. project conformance verdict;
25. BLOCKER findings;
26. SHOULD FIX findings;
27. source implementation commit;
28. documentation checkpoint commit;
29. pushed recovery anchor and final Git/worktree/index/submodule state;
30. explicit production behavior before/after comparison;
31. readiness for Stage 2 shell dependency closure;
32. readiness for production-identity rehearsal;
33. readiness for actual production cutover.

Conclude exactly:

```text
OFFICIAL PRODUCTION IDENTITY CAN BE RECOGNIZED AS APPCZAR-ELIGIBLE: YES / NO
PRODUCTION APPCZAR ACTIVATION IS UNCONDITIONALLY OFF: YES / NO
PRODUCTION STILL USES LEGACY STARTUPAPP: YES / NO
DEVELOPMENT APPCZAR COMPOSITION IS UNCHANGED: YES / NO
ARCHIVE ADMISSION STILL PRECEDES COMPOSITION SELECTION: YES / NO
PRODUCTION ROOT/UUID AND ADOPTION MUTATION GATE ARE NOT GLOBAL SELECTORS: YES / NO
NO PRODUCTION APP, DATA, RELEASE, SIGNING, OR RESTART BEHAVIOR CHANGED: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR STAGE 2 PRODUCTION-SAFE SHELL WORK: YES / NO
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP.
