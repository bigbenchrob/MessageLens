# MessageLens — Feature 34
## Prompt 115 — Checkpoint Observation Correction and Audit Non-Destructive AppCzar Cutover Feasibility

**Task type: Read-only, decision-oriented architectural feasibility audit. No implementation, launch, or production activation.**

### 0. Why the direction changes

Prompt 114 corrected the Response 113 post-cleanup publication blocker in the *test-only* coherent-observation envelope. We must not automatically resume Prompt 113 or build further populated reconstruction-witness infrastructure. The engineering goal is to safely bring AppCzar into service, not to establish the reconstructibility of every historically populated installation as a prerequisite unless current code actually requires it.

**Question to answer:** Can MessageLens complete a safe development-to-production AppCzar cutover while **permanently withholding Operating-owned destructive Start Fresh for populated installations**, preserving all existing ledger, graph, overlay, Presence, historical-source provenance, archived attachments, and user-authored material? If not, what exact executable or composition dependencies prevent it?

This is a feasibility audit only. A positive finding does **not** authorize production activation, a destructive reset, a release, an app launch, or a migration. Seven jurisdictions remain the design. Production AppCzar activation stays unconditionally OFF.

### 1. Baseline and legitimate documentation checkpoint

1. Inspect actual Git HEAD, branch, upstream, worktree map, clean index/tracked status, shared-instructions submodule, and the complete unrelated untracked inventory. The Response 114 source checkpoint was `28449d2f7457f9c751b0a683d7012dc3812c62d0` and Prompt/Response 113 checkpoint `29edb8977e63ab87893e0f1415f32c89317cde50`. **Verify current ancestry; never assume that those are HEAD.** Preserve the other three worktrees and every untracked item. No clean, stash, reset, rebase, force push, sweeping staging, or branch switch.
2. Determine whether Prompt 114 and Response 114 were already documented and pushed separately. If yes, verify and do not duplicate. If they remain untracked, verify their exact completed content and checkpoint **only that pair**, with a dedicated documentation commit and normal push. If an unexpected discrepancy exists, STOP and report it.
3. Read the governing `AGENTS.md`, shared global guardrails, project README/architecture instructions, exact canonical Feature 34 `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`, and current source. Read prior cutover audit Response 85, production eligibility Response 86, dependency audit Response 87, neutral source/environment extraction Responses 88–89, destructive Start Fresh audit Response 90 and Stage 2C STOP Responses 91–92 where available. The current code and checked-in documents outrank recalled summaries; distinguish historical evidence from fresh inspection.
4. Establish the exact current seven jurisdictions, six executable coordinators and admitted Operating Session; the lower exclusive archive-mutation authority boundary; production activation policy; legacy startup composition; and the actual build/identity distinctions. Record evidence paths and methods, not speculative descriptions.

### 2. Strict prohibition and audit scope

- **Read-only source, Git and instruction/document inspection only.** Do not edit `lib/`, tests, generated/native/Rust code, schemas, migrations, settings, dependency files, release metadata, or actual app databases.
- Do not build, install, sign, notarize, launch, debug or deploy either development or production app.
- Do not inspect or touch live Apple Messages/Contacts or real MessageLens ledger/graph/overlay/Presence databases, admitted WD or Toshiba roots, attachments, archive payloads, user data, bookmarks, FDA/TCC, or external cloud backups. An exact literal path may be examined as a source-code string; no filesystem access to those roots.
- Do not run destructive, repair, migration, import, archive-mutation, reset or production-activation methods, even in a proposed experiment. No temporary production enablement.
- No AppCzar jurisdiction eighth branch, no parallel evaluator, no implicit root lease/authority, no reusing legacy destructive reset semantics, no new state model or code.
- Only this Prompt/Response 115 audit documentation may be created/checkpointed after any required Prompt/Response 114 checkpoint. No new implementation code, tests or fixtures.
- Do not resume Prompt 113's FTS binding adapter, implement a populated reconstruction witness, or claim that finite FTS equivalence proves exhaustive index identity.

### 3. Reconstruct the actual production cutover dependency graph

For each current startup stage, composition root, provider, app shell, navigation surface, settings/support view, migration, background observer and Coordinator/Operating Session transition:

1. Locate the current production execution path (including `StartupApp`) and the development AppCzar path, with exact call sites and flag/policy gates.
2. Trace *direct and transitive* dependencies on legacy Journey orchestration, legacy startup status, ambient database listeners such as `chatDbChangeMonitorProvider`, import/cursor state, repair services, archive authority, and user-intent stores. Identify services created by DI/provider construction even if no button is pressed.
3. Identify whether Operating-owned **Start Fresh** is invoked implicitly by startup, onboarding, local repair, environment switching, diagnostics, or recovery; distinguish a visible UI action from an underlying implicit behavior.
4. Map each of the seven jurisdictions to its present code owner, necessary transitions, known development-human qualification and production-specific missing gates. Keep executable but only development-qualified capabilities separate from production-eligible composition.
5. Account for process-exit jurisdiction handoffs: `stopAndDrain` → actual process termination/new PID → fresh native/Dart archive admission → new neutral AppCzar assessment. Do not equate in-process navigation with a qualified restart.
6. Identify legacy and AppCzar side effects that might occur simply upon production shell construction. Include archive movement/repair, schema opening or migrations, import, graph reproject, source access prompts, background observers, overlay writes and persistent registration.
7. Determine the smallest dependency cut needed to compose a **non-destructive Operating Session** under AppCzar without enabling populated Start Fresh. Show which work is mandatory for production cutover and which belongs to the optional deferred reset capability.

### 4. Explicitly isolate populated Start Fresh

Audit the actual UI entry points, callbacks, provider wiring, coordinator APIs, reset services and fallback paths.

- Specify whether populated Operating-owned Start Fresh can be **entirely absent/disabled** in the production AppCzar composition, not merely greyed out while a callable destructive route remains.
- Propose a *fail-closed, capability-absent* design at the composition/service layer: no authorized reset invocation, no legacy reset fallback, no mutation Ball, no silent destructive reset in any background path. A disabled user control alone is insufficient.
- Preserve the proven, separately scoped **Local Data Repair** jurisdiction for exact live-only partial/empty graph cases, but inspect its precise preconditions and distinguish it from voluntary populated Start Fresh. Do not broaden its authority.
- Distinguish safe empty-installation onboarding from existing populated installation admission, historical/non-live provenance and archive-reference protection.
- Identify how Settings, diagnostics and support surfaces would represent Start Fresh as unavailable without claiming reconstruction readiness; no new UI implementation yet.
- Inventory any user-facing feature that currently assumes Start Fresh exists and whether removing it leaves a functional or safety hole. Provide an exact evidence-backed YES/NO/UNKNOWN, rather than assuming omission is safe.

### 5. Other production-readiness blockers must not be waived

Re-audit Response 85's blockers and any newer source changes. At minimum, separately examine:

- Production identity / bundle signing / notarization / sandbox / entitlements / FDA / permissions / app build and admission policy.
- Existing user-data migration and rollback/recovery, protected overlays/Presence/archive continuity, schema and runtime alignment.
- Production-safe startup shell, Settings, Data Update, Source Access Repair, Attachment Archive Repair, Onboarding, Local Data Repair, Diagnostic Review and Operating Session.
- Authority, capability tenure, graph/currentness observers, timers and process handoffs under the admitted environment.
- Existing development-only human qualifications versus missing signed production-staged and human-in-the-loop rehearsals.
- Production release gating and a separate human decision for activation.

For each, say **already qualified**, **requires implementation**, **requires human qualification**, **blocked by unavailable proof**, or **not relevant to non-destructive cutover**, with exact current evidence. Reusing a historical PASS without source verification must be labelled as historical only.

### 6. Decision matrix and critical path

Produce a single coherent matrix with columns:

`Capability / Dependency | Current owner and source | Development evidence | Production requirement | Start Fresh dependency? | Status TRUE/FALSE/UNKNOWN | Smallest next evidence or change | STOP gate`.

Cover all jurisdictions plus shell/composition, state migration, restart identity, Settings/support, background observers, archive/Persistence/overlay, test/release gates and destructive-reset availability.

Then compare three options:

**A. Non-destructive AppCzar cutover, Start Fresh permanently unavailable for populated installations.**

**B. Delay all AppCzar production cutover until complete populated reconstruction-equivalence witness exists.**

**C. Hybrid staged production cutover with explicit feature-gated jurisdictions/abilities (only if consistent with single-owner authority and not a disguised parallel/legacy fallback).**

For each: executable feasibility; exact blockers; preservation risk; dependency count; necessary qualification; potential unintended side effects; and what can be safely released. Do **not** provide invented timelines or unverified estimates. Choose one recommendation if evidence warrants it, otherwise report exactly why UNKNOWN prevents choosing.

### 7. Staged qualification and stop conditions

If A or C appears feasible, propose a minimal ordered cutover plan with independently reviewable milestones, each with its own PASS/STOP gate. Prefer an audit or narrowly scoped code characterization before any implementation. Require at least:

1. Production composition/shell dependency characterization on source or disposable fixtures (no real app launch in this audit).
2. Strict compile-time/composition or typed capability exclusion of populated destructive reset, with adversarial tests showing no back door.
3. Historical and user-authored data continuity/in-place admission evidence without rebuilding populated stores.
4. Separate signed/staged runtime identity and FDA/permission qualification with explicit human approval in a future prompt.
5. No production activation until independent conformance, release, backup/recovery and actual user authorization.

Identify **exactly one** smallest next Prompt 116 task with proposed file scope, characterization-first assertions, validations, and stop conditions. If the best next step is another audit, say so. **Avoid a sprawling implementation prompt.** Do not implement Prompt 116.

### 8. Output and conformance

Write one complete factual Markdown response:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/responses/115-CHECKPOINT-OBSERVATION-CORRECTION-AND-AUDIT-NONDESTRUCTIVE-APPCZAR-CUTOVER-FEASIBILITY.md`

Clearly separate observed source facts, past qualification claims, proposed designs and unresolved UNKNOWN. Include baseline/final Git integrity, path/line/method evidence, dependency graph, decision matrix, exact cutover recommendation and one next milestone. Record whether Prompt/Response 114 checkpoint was completed or already existed. No new tests/analyzer are expected for a strict read-only audit; do not claim them executed if not. Apply the canonical Project Conformance audit in **audit/design scope** (`BLOCKER: 0`, `SHOULD FIX: 0` within the audit to claim PASS, while remaining production-cutover blockers stay explicit). Commit/push only explicitly allowed audit documentation separately and preserve unrelated work.

End with exact literal outcomes:

- `PROMPT 114 OBSERVATION CORRECTION CHECKPOINTED: YES/NO/UNKNOWN`
- `NON-DESTRUCTIVE PRODUCTION APPCZAR CUTOVER FEASIBLE WITHOUT POPULATED START FRESH: YES/NO/UNKNOWN`
- `POPULATED OPERATING START FRESH ENABLED OR AUTHORIZED: NO`
- `PRODUCTION APPCZAR ACTIVATED: NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `COMPLETE POPULATED RECONSTRUCTION WITNESS REQUIRED ON CRITICAL PATH: YES/NO/UNKNOWN`
- `REMAINING PRODUCTION BLOCKERS INVENTORIED: YES/NO`
- `PROJECT CONFORMANCE (AUDIT/DESIGN): PASS/FAIL`
- `READY FOR ONE NARROW PROMPT 116: YES/NO`

**STOP.** Do not resume FTS integration, populated reconstruction, destructive Stage 2C or activate production AppCzar under this prompt.
