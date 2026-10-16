# MessageLens — Feature 34
## Prompt 117 — Checkpoint Operating Characterization and Design Composition-Bound Start Fresh Denial

**Mode:** Focused, read-only production-code design review, followed by one concrete implementation specification. **No production implementation under this prompt.** Do not resume the populated reconstruction witness or FTS binding.

### 0. Objective and priority

Our explicit release strategy is **non-destructive AppCzar cutover**, with Operating-owned populated Start Fresh entirely unavailable. Response 115 established architectural feasibility without a populated reconstruction witness; Response 116 proved that hiding the Settings reset row does **not** stop the real `ResetMessageDataRequested` dispatcher from resolving the legacy advanced action. Response 116's spy intercepted execution before real service construction; it is not proof of lower-layer safety.

The task is to define the **smallest complete, auditable denial cut** at existing command, service-construction, and lower archive-mutation admission boundaries, tied to the **actually selected startup composition**, not production eligibility, an environment label, menu visibility, or `appCzarDevelopmentCompositionEnabled` alone. Preserve separately selected legacy behavior and the exact existing `localDataRepair` safety contract. Produce one implementable Prompt 118 scope with a finite file allowlist, specific red/green tests, and stop gates. Avoid expanding into a new policy framework or auxiliary witness infrastructure.

Absolute prohibitions: no `lib/`, test, native/Rust, schema, migration, generated, dependency, release or application configuration edit; no app build/launch; no real source, Messages, Contacts, graph, ledger, overlay, Presence, WD/Toshiba archive or payload access; no FDA/TCC/bookmark, installed binary, background service, cloud action or filesystem mutation. Read source and Git only; create the two exact documentation files for Prompt/Response 117 as authorized here. No startFresh service construction or capability acquisition in any test. **Production AppCzar activation remains disabled.** No reset execution, no new jurisdiction, no second evaluator, no automatic legacy fallback.

Fair Witness: label every conclusion **verified source fact**, **historically qualified test**, **proposed design**, or **UNKNOWN**. Stop and report if real code contradicts the design premise; never assume a source-level denial is an actual runtime admission test.

### 1. Recover and checkpoint legitimate provenance

1. Inspect branch, HEAD, upstream, tracked/index cleanliness, all four worktrees, shared-instructions submodule, and manifest of pre-existing untracked files. Verify the latest Prompt/Response 116 documentation checkpoint and implementation `6b90bea234f074a3ae641401f2e8b686406a132f`; do not assume their Git disposition from Response 116 alone.
2. If Prompt 116 and Response 116 are untracked and complete, checkpoint **only those two** as a separate docs commit and push normally before audit. If already committed, verify ancestry and do not duplicate. If unexpected modifications/commits exist, STOP for reconciliation.
3. Preserve the user-authorized untracked `01-ONBOARDING/README.md` navigation index, three `_ARCHIVED` scripts, restored 218 documentation paths, and all unrelated material. Do not stage the index/scripts, reorganize directories, clean, reset, stash, rebase, squash, or force-push.
4. Read current project `AGENTS.md`, shared guardrails, architecture, database/overlay/preservation invariants, canonical Feature 34 Project Conformance standard, Responses 85–92 and 115–116 as relevant. Use current source as authority for APIs.

### 2. Trace the *complete* reachable Start Fresh chain

Establish exact source paths/method signatures and dependency construction effects for:

- Selection: `main.dart` admission, selected startup presentation/composition, development harness versus production legacy, production eligibility versus disabled activation; any root provider override keys. Distinguish selected composition from mere eligible identity.
- UI: Settings reset availability, resolver, stale action specs, navigation/restoration and deep-link/programmatic intent entry.
- Command: `SidebarActionDispatcher` branch for `ResetMessageDataRequested`; when `advancedStartFreshActionProvider` is read, cached, or invoked.
- Provider: `advanced_start_fresh_action.dart` and `start_fresh_service_provider.dart`; identify constructor-time reads/writes and the earliest safe denial point before the service, Presence and operation controller graph are constructed.
- Service: `StartFreshService` including voluntary/legacy call sites, typed request/authorization and any alternate entry points outside the sidebar.
- Lower boundary: `ArchiveMutationCoordinator` and `ArchiveMutationOperation.startFresh`; identify all callback-local capabilities, source of operation admission, race/reentry rules, request identity and lower gate dependencies. Explain whether selected-composition evidence can be supplied without circular provider dependencies or mutable global state.
- Independent `ArchiveMutationOperation.localDataRepair` admission and its existing exact live-only partial/empty-derived-store safety, binding, footprint and tenure guards. Verify it does not become a synonym for startFresh.
- Selected automatic coordinators and any screen/provider side effects relevant to installing the denial. Do not construct or invoke them.

Search for other direct/indirect `.startFresh()`, `runWithCapability(startFresh)`, action/service providers, reset intent types, and alternate archive reset/teardown paths. Report **positive findings and search limitations**, not an unjustified exhaustive claim.

### 3. Design one coherent denial contract

Choose the **minimum existing seam(s)** needed to establish all these invariants simultaneously:

1. In a selected AppCzar composition, `ResetMessageDataRequested` is denied **before** `advancedStartFreshActionProvider` resolution. Menu state is neither authority nor a fallback.
2. Direct action-provider and direct service-provider resolution cannot construct the legacy service graph in selected AppCzar composition, including requests from a cached provider/action instance or stale command captured before a composition change. If construction-level denial cannot be guaranteed, say precisely why and designate a lower fail-closed barrier; don't claim construction absence from run-time denial alone.
3. `ArchiveMutationOperation.startFresh` is denied before the exclusive Ball/tenure, callback-local capability, writable-root lease or application operation body is obtained in that composition. A direct or reentrant caller cannot bypass the refusal.
4. The **same selected-composition fact** controls all required denials. Prefer an existing typed source of truth; if it cannot reach the lower layer safely, document the unavoidable composition-scoped admission design and its disposal/lifetime guarantees. Do not infer this from `production eligible`, `isDevelopment`, UI visibility or a mutable application-global flag.
5. Preserve the legacy command only in independently selected legacy composition for controlled rollback; no runtime fallthrough from AppCzar into legacy. Preserve actual disabled production activation until separate qualification/authorization.
6. Preserve `localDataRepair` exactly; do not widen allowed graph contents or ignore historical, protected, unreadable or unsupported evidence. No eighth jurisdiction, new reset command, implicit repair, or duplicated AppCzar assessment.
7. The proposed design must cover selected AppCzar **development** and eventual **production** while recognizing today's production activation is OFF. A synthetic selected-production test must not forge an actual admitted native identity or activate the release.
8. Failure/UNKNOWN admission state defaults to deny, with an explicit nonmutating outcome. Include process restart/change-of-composition and stale-provider lifecycle scenarios.

If a boundary has no safe existing injection/admission seam, STOP rather than propose an ambient string or new global toggle. Describe the smallest missing port and who owns it.

### 4. Reviewable implementation plan for Prompt 118

Provide an *exact, short* proposed production/test file allowlist based on inspected source (not guessed filenames), highlighting why each file is unavoidable. Identify the smallest change at each selected seam. **Do not implement here.** If more than approximately four production files or a new general policy package would be needed, first analyze whether the design is overbroad and report this explicitly; do not hide scope to meet an artificial number.

Define an adversarial, disposable/inert red-before/green-after qualification matrix:

- hidden menu + direct/stale dispatcher request: **zero advanced-action factory entries**, zero service factory entries, zero callbacks/mutations when selected AppCzar;
- direct action and direct service access: fail closed before any side-effecting constructor; distinguish requested invocation from creation;
- direct lower `startFresh` admission and nested/reentrant attempt: denied before any Ball, lease, callback, resource open or mutation; spies only, never the real destructive service;
- separately selected legacy composition: preexisting command reachability preserved via inert spies, not real destructive execution;
- selected development AppCzar versus synthetic future eligible-and-selected production AppCzar: identical prohibition; production selector itself still remains disabled;
- no initialized or cached legacy provider leaks across composition/occurrence boundary;
- unknown/missing/rejected composition: denied rather than silently allowed;
- `localDataRepair`: no changed operation policy, binding, safety predicate, capabilities or scope; characterize permitted/denied *inert* admission paths without opening real databases;
- seven jurisdictions, startup selection, single Operating observer, neutral shell and normal browse/search/tag/favourite action graph remain intact.

Identify any tests that **cannot** safely instantiate lower mutation machinery without creating a Ball, opening data or launching native startup, and specify an inert test port or STOP instead of running them. Existing destructive-test cases must be screened and excluded under this review. No tests need execute under Prompt 117; tests above are prospective Prompt 118 requirements.

### 5. Ordered scope after reset denial

Give an updated short critical-path list: reset capability closure, production process handoffs, safe in-place schema/data continuity, shell/provider closure, signed/FDA human rehearsal, backup/rollback and release audit. Preserve separate specialist operation proofs. **Do not** restart FTS, populated reconstruction, or unbounded test infrastructure. Explain remaining differences between "cutover architecturally feasible" and "production ready".

### 6. Deliverable and checkpoint

Create only `01-ONBOARDING/responses/117-...md` with:

- exact baseline, verified provenance and unaffected untracked inventory;
- source call graph and constructor-time effects with file/method anchors;
- selected-composition authority flow and fail-closed operation policy;
- exact Prompt 118 production/test file allowlist and red/green matrix;
- design alternatives rejected and why;
- explicit unknowns, STOP conditions, and the six ordered release groups;
- audit-only Project Conformance verdict; literal flags: `RESET-DENIAL DESIGN COMPLETE: YES/NO`, `PRODUCTION RESET REACHABILITY CLOSED: NO`, `PRODUCTION APPCZAR ACTIVATION: OFF`, `POPULATED RECONSTRUCTION REQUIRED FOR CUTOVER: NO (architectural)`, `PROJECT CONFORMANCE (DESIGN): PASS/FAIL`, `READY FOR PROMPT 118 IMPLEMENTATION: YES/NO`.

Prompt 117 and Response 117 receive a separate docs-only checkpoint once the audit is complete and passes; report the docs commit hash in final handoff rather than guessing inside the committed document. No source/test implementation commit in this prompt. Preserve all unrelated files/worktrees. If an architectural blocker prevents the narrow implementation, write a factual STOP response without a success checkpoint.

**STOP. Do not implement the reset denial, execute Start Fresh, activate AppCzar, or begin the next milestone.**
