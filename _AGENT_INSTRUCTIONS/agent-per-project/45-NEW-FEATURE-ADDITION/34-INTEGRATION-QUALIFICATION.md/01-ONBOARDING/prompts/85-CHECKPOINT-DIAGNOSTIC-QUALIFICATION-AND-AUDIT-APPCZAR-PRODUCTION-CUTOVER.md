# MessageLens Feature 34
## 85 — Checkpoint Diagnostic Review Qualification and Audit the Whole-Repository AppCzar Production Cutover

Response 84 completed **PASS — REVISED BOUNDED HUMAN SCOPE** for executable AppCzar Diagnostic Review. All six executable top-level coordinators and the admitted Operating Session have now been implemented and qualified in their respective development-only milestones. The remaining limitation is explicit: genuinely `UNKNOWN` Messages-source evidence is **automated-qualified, not human-live-qualified**. It must not be represented otherwise.

The next task is a **whole-repository, source-grounded PRODUCTION-CUTOVER AUDIT AND DESIGN ONLY**.

This prompt does **not** authorize production cutover, development-app reconfiguration, production data inspection, an installer, a binary, an app launch, or any code/test modification. It must identify every route, authority, migration, presentation, data-safety, lifecycle, and packaging dependency that would matter if the existing production legacy Journey route were eventually replaced by AppCzar. It must deliver a dependency-ordered cutover plan and a defensible readiness verdict, not implement that plan.

The governing principle remains:

> **Every statement MessageLens makes about current reality is literally true, presently supported by current evidence, and no stronger than its evidence. Only fresh AppCzar assessment selects top-level jurisdiction; a coordinator owns its own bounded actions; mutation still requires its independent typed Ball authority.**

---

# 1. Baseline and recovery anchor

Repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expect:

- branch `fix/onboarding-import-stuck-state`;
- Response 84 initial HEAD/upstream `33cd9ecd42cab137cab84aab54d81521519526de` before its checkpoint, but **resolve the actual current HEAD from Git** rather than assuming it is unchanged;
- ahead/behind `0/0`;
- clean tracked worktree and index;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree;
- known unrelated untracked artifacts untouched.

Create a fresh external read-only baseline manifest outside the repository. Resolve exact commit ancestry and topology against `main`, including parallel worktrees, without switching branches or merging.

Read Response 84 in full, Responses 40, 41, 51, 55, 69–82, the failed Response 83, the revised Prompt 84, the canonical Project Conformance standard, architecture safety policies, current development/production data-location guidance, release/signing documentation, and all relevant current source.

Never infer live production data facts from a prior development fixture result.

---

# 2. Checkpoint Prompt 84 / Response 84 FIRST

Prompt 84 and Response 84 are presently untracked/unstaged for review. Create a **narrow documentation-only checkpoint** of exactly those two records if still untracked, verify the staged diff, commit, and push normally before starting the audit. Do not include the new Prompt 85, fixtures, temporary manifests, unrelated untracked files, or incidental generated output. If already checkpointed, record the actual commit without duplicating it.

Checkpoint text must preserve exactly:

```text
Diagnostic Review human live qualification:
    PASS — REVISED BOUNDED SCOPE

Observed live:
    A: corrupt active import, stable 96 seconds, no repair
    B: required source fact missing, known reconstructibility FALSE
    C: protected non-live material, no removal/reset
    R: one human restart, distinct old/new PIDs, no retry loop
    Q: Quit, no relaunch during 98-second observation
    protected fixture files unchanged

Not observed live:
    genuine Messages-source UNKNOWN
    all original Prompt 83 classes

Previously automated:
    all 22 Diagnostic frontiers

Production AppCzar cutover:
    NOT AUTHORIZED
```

Do not claim the app is production-ready merely because the bounded human test passed. No force push, squash, rebase, merge, or broad staging.

---

# 3. Hard safety scope for the audit

**Allowed:** Read source code, tests, tracked documentation, Git metadata, architecture configuration, and existing qualification reports. Create an external baseline/audit manifest and a Response 85 Markdown record. Run read-only commands that cannot launch the app or touch real data. Any static inspection of build scripts must not execute them.

**Forbidden:**

- editing production, development, test, generated, native, release metadata, entitlement, or packaging source;
- modifying any app settings or application permissions;
- building, running, debugging, or terminating production or development MessageLens;
- opening or querying real production/development MessageLens SQLite files;
- scanning the WD development archive or the Toshiba attachment archive;
- reading real Apple Messages or Contacts databases for this audit;
- making a production checkpoint, restore, migration, reset, or archive relocation;
- replacing, renaming, or copying the currently installed production app;
- changing bundle identifiers, TCC settings, FDA, launchd variables, archive markers, bookmarks, or archive UUIDs;
- using fixture data as evidence of the actual production installation's current state;
- merging into `main`, releasing, notarizing, publishing, or cutting over.

If a requested factual answer requires opening a live archive or launching a binary, mark it **NOT VERIFIED / REQUIRES SEPARATELY AUTHORIZED CONTROLLED QUALIFICATION**. Do not cross the boundary.

---

# 4. Establish the exhaustive runtime execution census

Verify the current development-only AppCzar route has exactly:

```text
Data Update                EXECUTABLE TOP-LEVEL COORDINATOR
Source Access Repair       EXECUTABLE TOP-LEVEL COORDINATOR
Attachment Archive Repair  EXECUTABLE TOP-LEVEL COORDINATOR
Onboarding                 EXECUTABLE TOP-LEVEL COORDINATOR
Local Data Repair          EXECUTABLE TOP-LEVEL COORDINATOR
Diagnostic Review          EXECUTABLE TOP-LEVEL COORDINATOR
Operating Session          EXECUTABLE ADMITTED SESSION
```

There must be no virtual-only coordinator, generic dispatcher, second semantic router, legacy Journey authority inside AppCzar, or ambiguous disposition-to-host mapping. Count exact predicates and explicit host branches, not merely enum values. Record test coverage and the remaining genuine-source-UNKNOWN live gap.

Also source-trace the unchanged current production path:

```text
archive admission
-> production app identity
-> StartupApp
-> App / production router
-> MacosAppShell
-> legacy Journey / Environment Readiness / related handoffs
```

Show precisely why production does not yet enter the AppCzar route.

---

# 5. Full startup call graph — native to user-visible owner

Trace with file/function references:

1. native bootstrap, bundle/product/build/environment identity and root claim;
2. native process lock and single-instance behavior;
3. Dart independent canonical-root agreement and marker/UUID validation;
4. archive-admission failure surface **before** AppCzar;
5. immutable `ArchiveAccessAuthority` and provider-container construction;
6. official-development `AppCzarDevelopmentCompositionPolicy`;
7. current production legacy selector and `StartupApp` construction;
8. `AppCzarStartupHarness` assessment/selection/controller host hierarchy;
9. selected coordinator/Operating window/app lifecycle;
10. after-restart admission and fresh assessment.

Distinguish **policy deciding which composition mounts** from **archive-root admission**, **individual operation authorization**, and **the final AppCzar disposition**. Do not collapse these questions into one boolean.

Identify the minimal proposed seam for a future production AppCzar composition choice. The cutover may not broaden the WD-root/UUID-specific attachment-adoption capability.

---

# 6. Production application identity, data roots, and migration safety

From source/documentation, establish:

- production bundle ID, product and build identity;
- production Application Support default root and native/Dart agreement contract;
- development roots and development-only override rules;
- production prohibition on development-root overrides;
- existing marker/environment/UUID behavior on first run and existing installs;
- admitted historical or legacy root possibilities;
- exact data-root/resource consumers that derive authority from the admitted root;
- process lock, multiple app processes, and open SQLite handle safety;
- archive-generation and external bookmark / location binding semantics;
- whether a production AppCzar composition may be selected with **zero physical archive re-identity, move, adoption, replacement, or reset**;
- whether first install, established install, disconnected external archive, and old/retired material are all handled without destructive inference.

Explicitly reject reusing or broadening `attachmentArchiveAdoptionExecutionEnabledProvider` as the global production composition gate.

Do not assume a test fixture's marker or root is representative of production.

---

# 7. Audit production first-run / existing-install / upgrades as separate cases

Build a source-grounded table for at least:

- genuinely virgin production root;
- valid healthy empty current derived stores;
- complete coherent/current local dataset;
- established dataset with source currently unreadable;
- source ahead and ordinary Data Update;
- attachment archive unavailable, read-only, incoherent, or moving;
- complete data with known source-absent attachment debt;
- source-available uncovered attachments;
- consequential partial live-only reconstructible data;
- consequential partial data not provably reconstructible;
- protected historical/non-live sources;
- retired/unsupported/corrupt stores;
- overlay, Presence, preferences, bookmark/configuration preservation;
- source UNKNOWN and unstable/conflicting observations;
- native/Dart admission error occurring before AppCzar.

For each identify which evidence AppCzar can actually obtain **before** coordinator admission, expected selected jurisdiction, permitted mutation or human action, and any production-specific untested assumption. No new disposition should be invented just to make the table close.

---

# 8. Persistence and user-intent preservation audit

Inventory the production data families and their owners:

```text
macos_import_ss.db + sidecars
working_ss.db + sidecars
user_overlays.db + sidecars
presence.db + sidecars when present
archive marker/UUID and location configuration
attachment_archive and external payload root
bookmarks / leases / relocation journal / receipts
logs, preferences, settings, migration/retired files
historical-source registry / identity / donor relationships
```

For each, identify whether AppCzar assessment only reads it, a coordinator writes it, or it is protected user/authenticity state. Identify all startup-open/create/migrate operations that could occur **before** AppCzar classifies facts.

Audit schema-version compatibility, migrations, FTS projection, presence of legacy records, and user-intent/attachment metadata separation. Require positive evidence that production first launch would not auto-erase, reset, replace, reinterpret, or silently discard user-authored or historical state.

Do not propose automatic cleanup of legacy state merely because it is obsolete as semantic authority.

---

# 9. Legacy startup/Journey dependency and eventual retirement map

Produce an exact file/provider/action inventory of:

- `StartupApp` and installation classification;
- Journey Trip/Step/Episode and compatibility status/gate;
- Environment Readiness reports/projectors/action bridge;
- `OnboardingOverlay`, sidebar-visibility owner, center-sync observer/controller;
- durable operation snapshots, recovery/reconciliation, failure/status history;
- pipeline incident center takeover and old completion handoffs;
- Start Fresh/reimport/reset user commands;
- Presence schedule and any consumer of historical Journey semantics;
- persistent navigation preferences and normal Operating shell;
- support/export features coupled to old Journey providers;
- generic `App` ambient workers/monitors;
- launch flags, FDA experiment, dev route, and production route differences.

Classify each as **KEEP FACT/WORKER**, **DEMOTE TO HISTORY**, **REWIRE**, **REMOVE ONLY AFTER QUALIFICATION**, or **KEEP PRODUCTION FOR NOW**. Demonstrate each consumer's authority edge; do not delete any source in this audit.

Especially examine whether old legacy semantic providers remain reachable through a shared production workspace after any future cutover, even if the Journey UI is hidden.

---

# 10. Every coordinator's production admissibility and process lifecycle

For each of six coordinators plus Operating, document:

- selection predicate and source evidence;
- host construction and scope identity;
- allowed actions/worker contracts;
- exact mutation Ball type, if any, and nested tenure rules;
- drain, quit, failure, and restart semantics;
- which process restart implementation is used;
- source of restart authorization;
- whether currently development-only path/build guard would fail in production;
- stale callback/assessment generation behavior;
- read-only vs destructive behavior;
- degree of real human evidence currently qualified.

The current restarter is guarded by development composition: audit production compatibility **without removing that guard now**. Design a future production-capable restarter policy only if an already admitted production AppCzar route authorizes it. It must preserve a true old-PID-exits-before-new-assessment boundary and avoid duplicate processes/restart loops.

---

# 11. Data Update / Operating currentness interplay

Trace the boundary between startup Data Update and the same-PID Operating Stage Two currentness service:

- 15-second observation and bounded refresh;
- source/current graph authority;
- messageDataVersion/UI refresh;
- same-session navigation preservation;
- attachment repairability/coverage re-evaluation;
- cross-jurisdiction restart instead of in-process handoff;
- source-UNKNOWN, source-denial, archive loss, and frozen/stale evidence;
- differences for production signing/FDA/TCC/volume availability.

Identify any residual ambient monitor or independent import worker reachable from the production shell that would become a second writer or semantic authority under AppCzar. Do not assume existing Operating qualification proves this absence in the production composition.

---

# 12. External attachment archive and irreplaceable payloads

Source-audit:

- location configuration and external bookmark restoration;
- source absence versus archive coverage;
- coherent archive identity/generation and lease checks;
- 75-item human-consent repair batches;
- automatic work permitted inside Operating;
- record-backed recovery, conflict/UNKNOWN handling;
- relocation interruption/recovery and retained source;
- physical payload/install integrity and no-overwrite semantics;
- archive-adoption restriction specific to the authorized WD root/UUID;
- surviving historical/source-absent attachment debt as a truthful Operating condition.

A production cutover must not implicitly adopt, relocate, or bulk-preserve attachments, nor should it call coverage complete merely because remaining payloads are source-absent. Enumerate every physical mutation path and its typed authority.

---

# 13. Destructive reset, protected historical data, and repair limits

Reconfirm Response 79/80 Local Data Repair's **only executable** safety class:

`rebuildableLiveOnlyPartial`.

Audit the complete source-scoped import-schema anti-difference proof, Contacts reconstruction, graph-empty condition, protected non-live exclusion, source stability, scope/binding equality, one typed `localDataRepair` Ball, and physical reset postcondition. Confirm corrupt, retired, unknown, historical, or missing-source cases remain Diagnostic, without deletion.

Source-trace Start Fresh and historical-source removal separately. Determine whether their existing **legacy presentation** remains the only way to access product commands, and whether future AppCzar Operating needs a newly authorized command surface. Do not import Start Fresh semantics into Local Data Repair or silently remove user controls.

---

# 14. Diagnostic Review production behavior and its human coverage gap

Audit Diagnostic's frozen assessment capture, bounded factual projection, privacy/technical disclosure, no evidence reread, no mutation Ball, no automated retry, explicit one-restart action, ordinary Quit, and absence of legacy support exporter.

Record verbatim the coverage limitation:

```text
Diagnostic Review human live qualification:
    PASS — REVISED BOUNDED SCOPE

Genuine Messages-source UNKNOWN human live qualification:
    NOT EXERCISED

All original Prompt 83 classes human live-qualified:
    NO
```

Decide in the production-cutover risk register whether automated tests plus bounded live qualification are sufficient for an eventual staged production trial, or whether another constrained qualification is necessary. **Do not silently waive the gap or retrofit an unsafe UNKNOWN injector.**

---

# 15. macOS production signing, TCC, installer, update, and process identity

Read—not execute—the exact packaging/release source and documentation. Identify:

- production bundle/product/signing/team identity and entitlements;
- hardened runtime / sandbox assumptions and Full Disk Access behavior;
- production distribution and notarization prerequisites;
- update path preserving bundle identity and existing permissions;
- direct-launch vs VS Code launch differences;
- launcher/restarter targeting current installed `.app` and preventing dev/prod cross-launch;
- existing production process, competing build, process-lock, and replacement concerns;
- safe rollback installation mechanics **without** rolling back or overwriting databases to stale formats;
- OS-specific modal/Quit & Reopen behaviors and restart error states.

Do not invent a rollback guarantee: distinguish source-proven mechanisms from procedures still requiring live human rehearsal. A binary rollback may be incompatible with schema/overlay changes; identify those version gates.

---

# 16. Performance, failure containment, and offline behavior

Inspect source/test evidence for startup probes and their actual bounds, including:

- source count/high-water and stability sampling;
- data/graph/FTS/overlay health;
- archive accessibility/binding and attachment repairability;
- source-scoped reconstructibility on partial datasets;
- UI responsiveness/restricted assessment presentation;
- 15-second Operating currentness and actual observed user-facing latency;
- 18K+ attachment universe qualification scaling;
- source read failure, long queries, volume disconnection, network unavailability, and TCC prompts;
- accidental multiple app instances and process restarter failure.

List performance assumptions which have not been measured under an actual production-root deployment. No performance run on real data is authorized by this prompt.

---

# 17. Test coverage and gaps across the entire repository

Produce a source-grounded matrix of:

- static architecture/import boundaries;
- coordinator selection and host census;
- development-vs-production startup route selection;
- canonical root and identity validation;
- all facts TRUE/FALSE/UNKNOWN;
- each real process-restart boundary;
- currentness/attachment and user-intent protections;
- import/graph/overlays/presence migrations;
- diagnostic frozen evidence and restart/no-retry behavior;
- production signing/packaging/release tests;
- negative/protected/unknown dispositions;
- actual human qualification and unexercised frontiers.

Identify tests that would have to be added **before** production route activation, and tests that require a separately authorized staged rehearsal. Do not imply test names cover runtime semantics without checking assertions.

No test-run/build/launch is required for this audit; do not perform one to claim readiness.

---

# 18. Staged implementation and qualification proposal — NOT AUTHORIZATION

Develop the smallest dependency-ordered future plan. Consider distinct checkpoints for:

1. source/architecture hardening necessary for production composition eligibility;
2. neutral production AppCzar startup selector after native/Dart admission;
3. production-capable but identity-constrained restarter/quit paths;
4. preservation of legacy capabilities that remain needed in normal Operating;
5. removed/demoted legacy semantic authority only when all callers are replaced;
6. tests for fresh production-like roots, established dataset, historical data, corruption, external archive loss, and upgrade/migration;
7. **disposable/staged, production-identity-aware, non-real-data rehearsal** where feasible, without TCC/archive confusion;
8. explicit human review/authorization before touching actual production-installed app or root;
9. verified preflight backup/recovery method and actual release rollout/rollback plan;
10. separate final authorization and go/no-go decision.

For each stage specify:

- exact code/feature scope;
- necessary evidence/preconditions;
- validation and human stop gate;
- permitted resources;
- failure behavior and recovery anchor;
- what remains explicitly forbidden until later stages.

Do not combine this into one giant cutover prompt. The audit should identify the **next narrow implementation prompt** and all later dependent milestones, while making no actual implementation changes.

---

# 19. Unresolved-risk register and Go/No-Go taxonomy

Produce a ranked list of every unresolved production dependency, each with:

- affected authority/data/resource;
- source-grounded observed fact;
- what remains unknown;
- potential irreversible impact;
- minimum safe test or implementation;
- gate classification `BLOCKER`, `SHOULD FIX`, or `FUTURE QUALIFICATION`;
- whether it prevents the first production-identity rehearsal, actual production cutover, or both.

Do not label the audit FAIL merely because cutover requires future work; the audit is successful if it truthfully identifies all blockers. Distinguish:

```text
AUDIT/DESIGN CONFORMANCE: PASS / FAIL
READY TO START A NARROW PRODUCTION-ROUTING IMPLEMENTATION: YES / NO
READY FOR PRODUCTION-IDENTITY STAGED REHEARSAL: YES / NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

---

# 20. Project Conformance — audit scope only

Run the canonical Project Conformance reasoning audit of the proposed architecture and staged plan. Require:

- at most one semantic owner;
- immutable admitted root/identity;
- development/production environment separation;
- root/UUID mutation capabilities remain independently narrow;
- no root move, replacement, adoption, or reset at cutover;
- no hidden migration or semantic history resurrection;
- no protected/historical/overlay/Presence/attachment deletion;
- bounded, current evidence rather than restored Journey conclusions;
- all changes to launch facts cause real process restart and fresh assessment;
- exact Ball mutation tenure, no duplicate worker;
- no production path through unqualified legacy/action providers;
- no immediate production AppCzar routing in this prompt;
- documented Diagnostic genuine-source-UNKNOWN live gap.

Report `PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)` only if the **proposed design itself** has no unresolved contradiction; separately enumerate all implementation blockers that must be closed before rollout.

---

# 21. Exit and Git state

This is audit-only. Do not modify tracked source, tests, generated code, native code, release metadata, or build artifacts. Keep Prompt 85 and Response 85 untracked/unstaged for the next review checkpoint; Prompt 84/Response 84 may have been checkpointed as directed in Section 2.

Report exact final HEAD/upstream, branch, ahead/behind, tracked/index cleanliness, submodule SHA, registered worktrees, unrelated untracked paths untouched, and no app/database/archive access. No production launch or migration occurred.

---

# 22. Required Response 85

Create `85-CHECKPOINT-DIAGNOSTIC-QUALIFICATION-AND-AUDIT-APPCZAR-PRODUCTION-CUTOVER.md` in the feature's `responses` directory, reporting:

1. baseline Git/source provenance and exact HEAD/upstream;
2. Prompt 84/Response 84 qualification checkpoint commit/push;
3. bounded Diagnostic human PASS and genuine-source-UNKNOWN gap;
4. current development/production execution census;
5. exact native/bootstrap → archive admission → startup-composition call graph;
6. root/identity/archive marker and independent canonicalization contract;
7. production vs development composition policy decision;
8. separate WD attachment-adoption mutation gate;
9. complete startup/first-run/existing/upgrade case matrix;
10. production data-family and preservation inventory;
11. migrations, FTS, historical and retired-state consequences;
12. complete legacy Journey/Environment/StartupApp ownership inventory;
13. hidden legacy consumer / ambient worker reachability;
14. seven-jurisdiction host and lifecycle/authority matrix;
15. production process-restarter current limitation and proposed seam;
16. Operating live-currentness and startup Data Update boundary;
17. attachment archive/relocation/coverage/adoption risk inventory;
18. destructive repair and Start Fresh/historical-source distinction;
19. Diagnostic Review frozen evidence/privacy/retry/Quit design and coverage gap;
20. production code signing, bundle/TCC/entitlement/update path;
21. recovery, rollback, backups, and schema compatibility limitations;
22. startup performance and offline/failure containment;
23. repository-wide existing tests and missing test categories;
24. future dependency-ordered implementation stages;
25. future disposable/staged human qualification stages;
26. future actual-production human-authorization gate;
27. unresolved ranked risk register;
28. readiness for narrow next implementation;
29. readiness for staged production-identity rehearsal;
30. readiness for actual production cutover;
31. Project Conformance AUDIT/DESIGN verdict;
32. BLOCKER findings;
33. SHOULD FIX findings;
34. untouched source/build/real-data assertions;
35. final Git/worktree/submodule state;
36. recommended exact next narrow prompt title/scope.

Conclude exactly:

```text
DIAGNOSTIC REVIEW HUMAN QUALIFICATION CHECKPOINTED: YES / NO
DIAGNOSTIC REVIEW GENUINE SOURCE UNKNOWN HUMAN LIVE QUALIFIED: NO
ALL SEVEN APPCZAR JURISDICTIONS HAVE EXECUTABLE DEVELOPMENT OWNERS: YES / NO
PRODUCTION CURRENTLY SELECTS LEGACY STARTUP: YES / NO
PRODUCTION APPCZAR CUTOVER HAS BEEN IMPLEMENTED: NO
PRODUCTION ROOT/IDENTITY AND MUTATION AUTHORITY REMAIN SEPARATE: YES / NO
LEGACY SEMANTIC AUTHORITY ELIMINATION IS FULLY AUDITED: YES / NO
PRODUCTION RESTART/QUIT PATH IS QUALIFIED: YES / NO
PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE) / FAIL
READY FOR NEXT NARROW PRODUCTION-CUTOVER IMPLEMENTATION: YES / NO
READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: YES / NO
PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
```

Then STOP. Do not implement, build, launch, change production settings, or begin cutover.
