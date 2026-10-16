# MessageLens — Feature 34 — Prompt 116
## Checkpoint Non-Destructive Cutover Audit and Characterize Operating Composition / Reset Reachability

**Task:** One narrowly bounded, characterization-only, test-only milestone. **Do not implement reset exclusion, enable production AppCzar, or return to the populated reconstruction witness.**

### 0. Objective and evidence discipline

Response 115 establishes an architectural finding, not production readiness: a supported healthy populated installation can be admitted to an AppCzar Operating Session without populated Start Fresh or a complete populated reconstruction witness. However, the current shared sidebar dispatcher can resolve legacy Start Fresh despite UI hiding, production activation is OFF, production process restarting is not qualified, and some coordinator/provider construction can start real work. The immediate goal is to **characterize the existing composition and every relevant reset-reachability seam with inert synthetic spies**, as a prerequisite to a separate capability-absent denial cut.

Use literal Fair Witness semantics. Differentiate (a) current source contracts, (b) executable characterization observations, (c) old qualification records, and (d) proposed future changes. Expected unsafe *current* behavior is a successful characterization of a missing safeguard, **not** a passed safety guarantee. STOP rather than silently making an unsafe current result appear safe.

Absolutely no production activation, migration, SQLite data access, MessageLens launch, native claim, data-root discovery, real Messages/Contacts/overlay/Presence/ledger/graph or archive reads, external drive access, mutation or StartFreshService execution. No actual network/cloud, FDA/TCC, signing or process restart. Never acquire a mutation Ball, callback-local mutation capability or writable-root lease. Seven jurisdictions remain unchanged. No eighth reset jurisdiction.

### 1. Verify and checkpoint the legitimate baseline

1. Inspect HEAD, branch, upstream ahead/behind, tracked index/worktree, four worktrees, shared-instructions submodule, and pre-existing untracked inventory and hashes. Response 115 source-audit baseline was `fix/onboarding-import-stuck-state` at `ddc5c85e767cb2b1d6d147c60b005ad700a168a5`, upstream 0/0; submodule `95326f515ef4719f155ce6e223990398daad6311`. **These are expectations, not facts about today's state.** Reconcile before acting.
2. Response 115 describes a separate user-authorized documentation reorganization: 218 tracked documents were restored to their original byte-identical locations, an untracked `01-ONBOARDING/README.md` navigation index was created, and three shell scripts were preserved under `prompts/_ARCHIVED`. Preserve this arrangement and all unrelated untracked files verbatim. Do not stage/commit the index or scripts; do not move/delete/sweep docs. STOP for unexpected tracked modifications unless user authorization and exact preservation are independently established.
3. Locate the exact Prompt 115 and Response 115 under `_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/{prompts,responses}/`. Verify the pair's content and disposition. If still untracked and complete, commit **only the exact pair** in a separate documentation checkpoint and push normally; if already tracked in a matching checkpoint, verify ancestry and do not duplicate. If mismatched, STOP.
4. Verify ancestry for the existing AppCzar selector, Operating shell/currentness, the Response 114 test-only correction `28449d2f7457f9c751b0a683d7012dc3812c62d0`, and relevant production code under inspection. Capture a pre-edit source/test hash manifest. Do not treat old test counts as fresh.

### 2. Exact allowed implementation file

Create **only**:

`test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart`

Use current production classes, selectors, policies, router/host structures and providers *only through already available safe injection seams*. All side-effecting dependencies must be overridden with nonexecuting spies/fakes. Do **not** modify existing tests, helpers, `lib/`, platform/Rust code, providers, generated files, schemas, dependencies, build/release metadata or production startup wiring. Do not create a second evaluator, alter the single semantic owner, change policy, or add runtime configuration. If the exact tests cannot be built without additional files, STOP with the missing seam identified. Existing production code is read-only for this task.

Documentation only: exact `prompts/115-...md` and `responses/115-...md` as prerequisite if needed, then separately `prompts/116-CHECKPOINT-NONDESTRUCTIVE-CUTOVER-AUDIT-AND-CHARACTERIZE-OPERATING-COMPOSITION-RESET-REACHABILITY.md` and matching Response 116. Do not stage any other untracked material.

### 3. Characterization-first source map

Before writing substantive assertions, inspect and record precise production source anchors for:

- `main.dart` startup selection: already-admitted identity, official production eligibility, unconditionally disabled activation, development selection, Settings/reset and restoration overrides.
- `AppCzarStartupHarness`, `AppCzarOperatingSessionApp`, neutral workspace shell, Operating controller and currentness observer, including **construction** and first-watch side effects.
- Generic legacy `App`, `StartupApp`, `ProductionMacosAppShell`, `chatDbChangeMonitorProvider`, Journey controller/wrappers, advanced reset overlay, Settings reset availability and navigation restoration.
- `ResetMessageDataRequested` -> `SidebarActionDispatcher` -> `advancedStartFreshActionProvider` -> `StartFreshService` -> `ArchiveMutationOperation.startFresh` -> lower coordinator. Distinguish menu visibility, dispatcher admission, provider construction, service construction, and actual mutation-capability acquisition.
- Six coordinator hosts plus Operating as seventh jurisdiction; identify which controllers begin source/graph or mutation-related work when constructed/watched (Data Update, Onboarding, Local Data Repair especially). Do not instantiate them with real ports.
- Exact Local Data Repair typed gate, separate lower `localDataRepair` operation, and lack of dependency on the voluntary populated reset.

For each seam mark whether a safe existing fake/override makes executable characterization possible. If not, mark SOURCE-INSPECTED ONLY or STOP where the absence prevents this milestone. Never use a fake that bypasses an admission rule and then describe the result as production admission.

### 4. Required bounded characterization tests

Add deterministic focused cases as supported by existing safe seams, covering at least:

1. **Selector:** an exact admitted official production identity can be eligible while production activation remains disabled; selected composition is therefore the legacy branch. A development-admitted identity selects the qualified development harness. Do not construct an enabled production activation object or edit the activation constant.
2. **Operating admission:** source-inspect and, where safely testable, demonstrate that Operating controller admission/currentness does not require a complete populated reconstruction proof or Start Fresh capability. A construction-free pure-policy test is preferable to any live provider build.
3. **Neutral shell ownership:** verify Operating's declared composition excludes generic `App`, `StartupApp`, legacy Journey overlays and ambient chat monitor. Where actual widget/provider construction is safe with inert overrides, assert that the legacy monitor is never constructed. If these cannot be proven by a safe test, preserve explicit UNKNOWN and report the precise isolation seam; do not launch application code or real observers.
4. **Development-keyed overrides:** establish from actual selector/override source that reset visibility or navigation restoration is keyed to development selection rather than selected AppCzar composition. Characterize current behavior; do not repair it.
5. **Hidden reset is not denied reset:** use inert provider-access spies to characterize that `ResetMessageDataRequested` reaches legacy action resolution independently of UI availability, **without constructing or executing a real StartFreshService, opening Presence, accessing archives, or requesting an operation Ball**. If existing provider APIs make even provider-resolution unsafe to observe, STOP; rely on source evidence and name the missing injectable seam instead of invoking it.
6. **Construction-time side effects:** distinguish presentation-only construction from selected controller builds that schedule automatic execution. Use pure source assertions or fully overridden inert spies; do not let Data Update, Onboarding, Local Data Repair, source reader, graph builder, archive repair or currentness pollers run. Capture the difference between an explicit command and automatic selected-jurisdiction work.
7. **Capability distinctness:** establish that Local Data Repair's exact live-only partial/empty graph operation is not `startFresh` and is not permission to erase populated or protected historical material. No destructive test execution.
8. **No reset dependency in normal features:** characterize the existing dependencies for normal browsing/search/tags/favourites/support as far as safe source seams permit, reporting any unknown interaction paths rather than claiming an exhaustive absence.

All spy assertions must count provider resolutions/construction and callable invocations separately. A spy recording a request is not evidence of a real mutation. Any assertions that would require staging a signed production app, live database, process relaunch or archive permissions belong to future gated milestones.

### 5. Safety and reporting rules

- Use fixed synthetic identity labels; never log GUIDs, user text, paths to admitted roots, handles or archive payloads. No real filenames or data under fixture paths.
- Before importing or watching any provider, examine whether it starts work in `build()`/initialization. Override **all** potentially side-effecting dependencies before watch. If a background task cannot be quiesced/owned, STOP rather than depending on cancellation after side effects.
- Do not count static-source inspection as a passing runtime test, nor production eligibility as production activation.
- Do not assert that current hidden reset is inaccessible: Response 115 found precisely the opposite reachable edge. A deliberate assertion documenting the unsafe edge may pass as **characterization**, but must be labeled `MISSING SAFEGUARD` in Response 116.
- Preserve exact source/protected data invariants and never make a claim that the 7-jurisdiction production design is qualified by these tests.

### 6. Validate and conduct canonical Project Conformance audit

Run the new focused test with attributable count and exit status; relevant existing selection/Operating/currentness/sidebar reset-availability/dispatcher tests; `test/architecture/forbidden_imports_test.dart` and any additional architecture gate demanded by the canonical standard; full `flutter analyze`; targeted `dart format --output=none --set-exit-if-changed`; `git diff --check`, staged check, and final exact-file/hash preservation. Do not run a full Flutter suite unless required by a concrete failure or governing rules.

Do not report interrupted commands, sandbox SDK-cache failures or test assertions that merely inspect source as successful runtime behavior. The conformance review must address reuse, single evaluator, provider side effects, mutation Ball/lease exclusion, source/ledger/archive privacy, typed honesty about unknown paths, seven-jurisdiction unchanged, generated/dependency hygiene and no production activation. `BLOCKER: 0` and `SHOULD FIX: 0` apply **within the agreed characterization scope**, not production readiness. A safely characterized existing reset hole is a future cutover blocker, not a reason to misrepresent a failing test.

### 7. Git checkpoints, Response 116 and explicit next recommendation

If characterization and required validation PASS, commit/push **only the one new test file** as an implementation checkpoint. Prompt/Response 116 receive a later, separate documentation checkpoint. If a STOP gate occurs, do not commit success; preserve an honest STOP response/reproducer and unchanged pre-edit implementation baseline. Keep pre-existing untracked index, `_ARCHIVED` scripts, and all other unrelated work intact.

Response 116 must include:

1. Verified Git/head/upstream, exact documentation and implementation commits, allowed files and preserved untracked inventory.
2. Source-level dependency/reachability graph and a compact matrix showing **source-inspected**, **executable test demonstrated**, or **unqualified**, for selector, neutral shell, auto-start hosts, reset UI, dispatcher, provider, lower operation and Local Data Repair.
3. Exact spy count/results without ever executing a real StartFreshService, existing dangerous path clearly identified, and any testability blocker.
4. Full command/test outcomes and project conformance results.
5. **One minimally scoped later production change proposal** that denies `startFresh` in AppCzar composition *before* legacy service/provider construction and at the lower operation admission, while retaining exact Local Data Repair behavior. Identify code paths and likely test seams, but DO NOT IMPLEMENT THEM.
6. Remaining independent production blockers: lifecycle/restart, data/migrations/sidecars, signed runtime/FDA, preservation, specialist human qualification and backups/rollback.

End with literal flags:

`NON-DESTRUCTIVE OPERATING COMPOSITION CHARACTERIZATION: PASS/STOP`
`CURRENT RESET REACHABILITY FULLY BLOCKED: NO`
`PRODUCTION START FRESH CAPABILITY EXCLUDED: NO`
`POPULATED RECONSTRUCTION WITNESS REQUIRED FOR CUTOVER: NO (architectural finding; not activation authority)`
`SEVEN JURISDICTIONS UNCHANGED: YES/NO`
`PRODUCTION APPCZAR ACTIVATION: OFF`
`PROJECT CONFORMANCE (CHARACTERIZATION): PASS/FAIL`
`READY FOR NARROW PRODUCTION RESET-DENIAL REVIEW: YES/NO`

**STOP.** Do not begin the denial cut, perform a production rehearsal, resume FTS binding, or activate AppCzar in this prompt.
