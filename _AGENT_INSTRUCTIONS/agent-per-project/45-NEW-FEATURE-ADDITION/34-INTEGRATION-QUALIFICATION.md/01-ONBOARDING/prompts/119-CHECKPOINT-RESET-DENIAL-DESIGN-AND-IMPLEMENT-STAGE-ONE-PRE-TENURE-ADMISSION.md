# MessageLens — Feature 34
## Prompt 119 — Checkpoint Resolved Reset-Denial Design and Implement Stage 1: Composition Lifetime and Pre-Tenure Denial

**Task type:** Bounded production implementation plus synthetic/inert qualification. **Stage 1 only.** This is not a production cutover or complete Start Fresh exclusion.

### 0. Purpose, authority, and Fair Witness

Response 118 resolved the previously stopped composition-bound reset-denial design into two stages. Implement **only Stage 1**: a root-established, revocable, explicitly selected composition/lifetime input; a shared **pre-tenure** veto for `ArchiveMutationOperation.startFresh` and `ArchiveMutationOperation.messageDataReset`; and a narrowly constrained inert test port that exercises the **same private branch helper** as production. Do not implement Stage 2 dispatcher, action, service, or cached-object guards in this prompt.

Use verified current source over previous narratives. Separate FACT, EXECUTED TEST, PROPOSAL, and UNKNOWN. A passing Stage 1 protects the lower admission front door for the two named operations under its qualified conditions; it **does not** mean that AppCzar reset command/action/service construction is blocked, that legacy reset is tested live, or that production AppCzar can be activated. Do not claim actual nested-tenure or post-tenure timing qualification from inert continuations.

**Absolutely prohibited:** changing `ProductionAppCzarActivation.disabled` or its semantics; selecting production AppCzar at runtime; adding a jurisdiction/evaluator; running real Start Fresh, general data reset, local data repair, import, migration, archive writes, or cleanup; acquiring a real Ball/exclusive tenure/writable lease during Stage 1 qualification; opening real Messages, Contacts, MessageLens database files, active development/production archive roots, WD/Toshiba drives, payloads, TCC/FDA/bookmark resources; launching the app or signed build; FTS or populated reconstruction-witness work. Preserve the seven AppCzar jurisdictions, the legacy selector's existing result, all independent protected state, and the specific Local Data Repair safety/execution contract.

### 1. Checkpoints and baseline discipline

1. Read Prompt/Response 117 and 118, Response 116, the canonical Feature 34 Project Conformance standard, current architectural/SQLite/overlay/preservation guardrails, and the actual source/test seams named in Response 118. Verify repository branch `fix/onboarding-import-stuck-state`, actual HEAD/upstream status, index/tracked cleanliness, exactly one worktree using this branch, and clean shared-instructions submodule at its current hash (historically `95326f515ef4719f155ce6e223990398daad6311`). Verify, do not assume, history or path existence.
2. Verify Response 118's prerequisite Prompt/Response 117 documentation commit `d7de9fbb650298583516eded229d965383b6e1b2` in ancestry. Determine whether **Prompt 118 and Response 118** are already committed and pushed. If complete but untracked, commit **only those two exact documents** as a separate docs checkpoint, whitespace-check and push normally before implementation. If tracked already, do not duplicate. On unexpected changes or conflicting versions STOP rather than rewriting.
3. Inventory all tracked and untracked file paths/hashes outside the authorized changes, the three archived backup scripts, the `01-ONBOARDING/README.md` navigation index and restored historical documents; preserve all unchanged. Record other worktree tips. Never use broad `git add`, `clean`, stash, hard reset, rebase, squash or force push.
4. Before editing, inspect generated provider conventions and existing tests for `main.dart`, `startupPresentationCompositionProvider`, `ArchiveMutationCoordinator`, `ExclusiveAuthorityRegistry`, private Zone/reentrant dispatch, `ArchiveMutationOperation` and existing test-support patterns. Capture actual pre-edit behavior; do not run an existing nested test if it acquires a real tenure or mutation capability. Record file hashes and exact generator footprint.
5. Work only on the verified active Feature 34 worktree. No simultaneous change to Feature 35, `main`, or Gradle worktrees.

### 2. Exact Stage 1 implementation allowlist

**Hand-authored production/test-support files (six):**

1. NEW `lib/essentials/archive_environment/domain/archive_reset_admission.dart`
2. NEW `lib/essentials/archive_environment/application/archive_reset_admission_provider.dart`
3. EXISTING `lib/main.dart`
4. EXISTING `lib/essentials/archive_environment/feature_level_providers.dart`
5. EXISTING `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`
6. NEW `lib/essentials/archive_environment/application/archive_mutation_admission_test_support.dart` (source-local `part` friend, **not** publicly exported).

**Generated outputs only if produced by the repository's normal generator:**

- NEW `lib/essentials/archive_environment/application/archive_reset_admission_provider.g.dart`
- EXISTING `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart` **only if actual regeneration changes it**.

Never hand-edit generated sources. If the generator changes unrelated paths, STOP, report the exact diff, and seek scope review; do not silently stage or reset generated churn.

**Test allowlist (six):**

1. NEW `test/essentials/archive_environment/application/archive_reset_admission_test.dart`
2. NEW `test/essentials/archive_environment/application/archive_mutation_pre_tenure_admission_test.dart`
3. EXISTING `test/app_czar_startup_composition_test.dart`
4. EXISTING `test/architecture/app_czar_architecture_test.dart`
5. EXISTING `test/architecture/exclusive_authority_architecture_test.dart`
6. EXISTING `test/architecture/forbidden_imports_test.dart`

**Documentation:** only the exact existing Feature 34 `01-ONBOARDING/prompts/119-CHECKPOINT-RESET-DENIAL-DESIGN-AND-IMPLEMENT-STAGE-ONE-PRE-TENURE-ADMISSION.md` and matching `responses/119-CHECKPOINT-RESET-DENIAL-DESIGN-AND-IMPLEMENT-STAGE-ONE-PRE-TENURE-ADMISSION.md`, plus prerequisite Prompt/Response 118 checkpoint when necessary.

No other source/test/generated/dependency/entitlement/architecture-allowlist file is authorized. Stop if an essential interface cannot be implemented within these files, rather than introducing an ambient policy service or smuggling Stage 2 changes into Stage 1.

### 3. Characterize before edits and state precise contracts

Record a characterization matrix and, where safely executable, baseline tests for:

- The final presentation composition is chosen in `main.dart` and root-overridden, but the existing raw provider's default `.startupApp` is **not evidence of explicit legacy selection**.
- Production activation is unconditionally disabled; eligibility is not selection. No test may inject a fake enabled activation into real startup or claim official native admission.
- `run` and `runWithCapability` converge on one `_run`; the coordinator currently chooses ordinary/reentrant private registry paths before any new composition veto; `startFresh` and `messageDataReset` are separate operation types with different existing checkpoint rules.
- `localDataRepair` is a distinct operation with existing exact rebuildability/binding safety. Its executor and reset-service code are **unchanged** in Stage 1.
- Existing generated providers, root override disposal and source-local `part` syntax permit the proposed lifetime/friend structure. If not, STOP with a precise explanation, not a different pattern.

No actual reset or real-authority test is needed to characterize absence of a gate. Source tracing plus inert preflight checks must be labeled appropriately; avoid running previously known real-tenure fixtures.

### 4. Implement one reset-admission lifetime contract

Implement the minimal immutable-selection/revocable-lifetime design grounded in Response 118:

1. One root-owned instance is created **only after final selected composition** in `main.dart`; it reuses the exact existing `StartupPresentationComposition` enum (import the neutral domain type, not the display/support projection). It contains the explicit selection, an unforgeable per-object identity/epoch (e.g., object identity), and monotonically revoked state. No environment-label shortcut, mutable global/static allow flag, public reselection or hot toggle. Do not alter existing raw presentation-input default or support adapters.
2. The new provider's absent/default value must be **unavailable**, not implicitly legacy. Missing, rejected, throwing, disposed and revoked selection fail closed with one typed, non-content-bearing denial. A provider error must never be caught and converted to legacy. Distinguish **explicit live legacy** from absence even if both would otherwise present the legacy UI.
3. The domain contract owns the only new two-operation veto: `startFresh` and `messageDataReset` may **proceed to existing gates** only for an explicitly selected, currently live legacy lifetime. Explicit AppCzar, missing or revoked selection denies. Proceeding is not authorization to reset, mint a Ball, or bypass checkpoint/consent. For every non-reset operation, **do not even resolve the new reset provider**; existing rules are unaffected.
4. Register root revocation/disposal for the actual overridden instance; remember that overriding the provider bypasses its default factory/dispose lifecycle. Demonstrate revocation on root disposal and on explicit test invalidation, as supported. Root and consumer lifetimes are distinct: a consumer binding carries immutable parent identity plus a local monotonic closed flag, and closing one consumer must not revoke unrelated live consumers.
5. An instance captured from legacy lifetime L1 must fail after L1 revocation, even if a different new legacy lifetime L2 exists (ABA). It must never replace its parent binding with the newer token. There is no successful implicit reselection on same-container invalidation.
6. Keep API surface deliberately small: no public mutation capability or authorization bool provider, no I/O, no archive admission or AppCzar evaluator dependency. Stage 2 will consume bindings in command/action/service constructors later; do **not** modify those classes now.
7. Characterize any unavoidable provider scope/lifecycle limitation literally; if root disposal cannot safely revoke the original overridden object under actual Riverpod semantics, STOP rather than relying on undocumented disposal behavior.

### 5. Shared pre-tenure coordinator denial

In the existing `archive_mutation_coordinator_provider.dart` only:

1. Ensure both `run` and `runWithCapability` reach one `_run` and the **same source-local private pre-tenure dispatch helper**. The first operation-specific reset-admission check must occur **before** private Zone/registry ordinary/reentrant branch dispatch, authority/provider construction, checkpoint lookup, exclusive tenure, admitted-scope activation, callback or capability creation. Do not resolve the new provider at all for other operations.
2. The helper then evaluates the existing private candidate-owner/reentrant predicate and chooses exactly one original continuation. Do not change registry algorithms, exclusive-tenure semantics, callback-local capability typing, source/root equality rules or the lower archive admission machinery.
3. For the two reset operations, capture the root lifetime/binding and recheck its currentness at appropriate later continuation boundaries after awaits and before new callback-local capability mint/invocation. Keep those checks tied to the same root-owned contract; do not introduce a second policy. **No await** between initial successful check and choosing the original branch. If a later check would require widening generated/provider signatures or touching other files, STOP and report.
4. The new veto must dominate **both** ordinary and reentrant continuation paths. A retained or rejected reset request must not reach registry factory, `runExclusive`, `runReentrant`, authority read, verified-checkpoint read, or mutation callback. Denied result must be typed and diagnostic-safe.
5. Preserve source/currentness for non-reset operations unchanged, including `localDataRepair`, `automaticRecovery`, `graphBuild`, attachment operations and other specialist operations. Do not accidentally demand a live legacy reset binding for these.
6. Treat actual nested Zone/tenure/post-tenure timing as separately unqualified. The source review should explain the dominance proof and precise recheck locations without describing inert sentinels as genuine reentry qualification.

### 6. Restricted source-local test friend: prove the *real helper*, not a copy

Add the allowed `archive_mutation_admission_test_support.dart` as a `part` of the actual coordinator source, with narrow debug-fenced access to that **same private branch helper**.

- Reject all non-debug execution explicitly (do not rely solely on an `assert` removed from release).
- The callable test entry takes only synthetic operation, reset lifetime and an ordinary/reentrant *candidate branch fact*; any counts/sentinel observations must be built internally with inert continuations.
- Neither args nor results may accept/expose arbitrary production callbacks, tenure, owner Zone, archive root, claim, capability, Ball, registry, writable lease, provider container or real mutation callback. No invented native/archive admission identity.
- It must not be exported by `feature_level_providers.dart`; production files must be forbidden from importing/directly invoking the test friend. Architecture tripwires should enumerate its exact permitted test import; **no broad exemption**.
- A denied call must execute neither continuation. Explicit legacy may choose one inert sentinel on the selected candidate branch; non-reset may select an inert sentinel regardless of reset input. This is an admission/branch structural test, not proof of real nested authority.
- If part visibility or exact helper shape cannot deliver this without broadening the public mutation surface, STOP for design review. Never forge real private tenure or use an existing real-Ball fixture as a substitute.

### 7. Required executable adversarial matrix

All tests use fixed synthetic identities, inert spies, deterministic callbacks and zero real archive/mutation authority.

**Lifetime/input tests:** explicit live legacy versus AppCzar versus missing/default versus failed input; revoked/disposed; two independent root objects with same composition have distinct epochs; ABA stale object remains denied; two consumer bindings are independent; binding disposal invalidates only its own instance; provider override disposal revokes root once; invalidation does not mint implicit legacy; denied error is typed, redacted and nonmutating.

**Direct real-front-door tests:** call actual `run` and `runWithCapability` for both `startFresh` and `messageDataReset` under explicit AppCzar, missing/throwing and revoked selection, with registry factory, authority/checkpoint, callback and any writer replaced by **throwing or counting inert spies**. Assert rejection occurs before all those paths and zero callbacks/Balls/tenures/leases are created. Do not call allowed reset through real registry merely to show historical legacy continuity.

**Private helper friend tests:** for both reset operations, test candidate ordinary and candidate reentrant, denied for all non-legacy states with zero continuation counts; explicit live legacy permits exactly the chosen *inert* branch; ordinary/reentrant sentinel matches injected candidate and neither permits actual registry activity. Test `localDataRepair` and a representative other non-reset operation with unavailable/throwing reset provider: neither consults reset input and exactly one inert continuation is selected.

**Revocation and timing tests:** revoke before initial admission; revoke before the inert branch continuation; test the latest safely injectable pre-capability checkpoint; verify denied callback and no retry or selection fallback. Do not simulate a post-tenure context by fabricating Zone/tenure. A planned late-check that cannot be exercised safely must be marked source-inspected/UNKNOWN, not passed.

**Regression guards:** existing production selector stays disabled; seven jurisdictions unchanged; no dependency on AppCzar facts or display projections; `messageDataReset.requiresVerifiedCheckpoint` and `startFresh`'s differing preexisting checkpoint rule unchanged; `localDataRepair` model/safety/executor/reset-footprint source bytes unchanged; no native root/migration/real data accessed.

If a failed characterization reveals a new independent defect or forces Stage 2 work, STOP; report precise evidence and preserve repo instead of expanding.

### 8. Validation and conformance

Run completed attributable commands and record counts/exit statuses:

- new Stage 1 focused domain and pre-tenure tests;
- existing startup selector/production eligibility and relevant coordinator tests **screened to avoid real tenure or mutation**;
- `test/architecture/app_czar_architecture_test.dart`, `test/architecture/exclusive_authority_architecture_test.dart`, `test/architecture/forbidden_imports_test.dart` and any additional canonically required safe architecture cases;
- full `flutter analyze` and targeted `dart analyze` if meaningful;
- repository-standard code generation only for the named generated files; review generated diff;
- `dart format --output=none --set-exit-if-changed` on every touched hand-authored Dart file;
- `git diff --check`, staged-diff check, full exact allowlist and before/after hash comparison, submodule/worktree/upstream checks.

Respect existing SDK-cache restrictions: an interrupted or sandbox-blocked attempt is not PASS. Do not run a full suite or broad existing coordinator tests if they access a real Ball, source, archive, or invoke a destructive body; instead select inert tests and state the exclusion. Full Flutter suite only if independently required and safe.

Canonical Project Conformance must explicitly confirm: one operation-veto owner, explicit selection and lifetime; root and consumer revocation; direct and reentrant pre-tenure dominance; no production test friend usage; no arbitrary callback exposure; no provider-cycle or implicit legacy fallback; no generated churn outside allowed paths; all non-reset operations and seven jurisdictions unchanged; no user data/real capabilities; privacy and diagnostic boundedness; source-isolated changes. PASS requires **BLOCKER: 0 and SHOULD FIX: 0** within Stage 1, without declaring Stage 2 or production readiness PASS.

### 9. Checkpoint and Response 119

Only after qualifying the entire allowed Stage 1 scope and passing conformance, commit **only permitted production/test/test-support/generated files** in one descriptive source checkpoint, e.g. `feat(archive): deny general reset before mutation tenure by composition lifetime`. Push normally, no history rewrite. Keep Prompt 119 and Response 119 in a separate documentation-only checkpoint once the implementation and report are complete. Never combine unrelated untracked files or the authorized README/scripts reorganization.

Response 119 must give:

1. Exact baseline, prerequisite Response 118 docs disposition, all source/docs checkpoint hashes, final upstream/worktree/submodule state, exact changed/generated paths and preservation of unrelated files.
2. Literal red/baseline observations versus new green evidence, focused/architecture/regression counts, analyzer/format outcomes and attributable logs.
3. Root selection/default/disposal and consumer-binding ABA semantics, including whether Riverpod override lifecycle was actually tested or merely source-inspected.
4. Direct denied `run` and `runWithCapability`, ordinary/reentrant friend counters, zero real tenure/capabilities, currentness recheck scope and what remains UNKNOWN.
5. Demonstration that `localDataRepair` and non-reset operations do not consult the veto and their current admission/footprints are unmodified.
6. Canonical Project Conformance findings, no Stage 2 work, no real data/app access, and no startup selector/activation change.
7. One precise recommended Stage 2 next step if Stage 1 truly passes, referencing the Response 118 Stage 2 allowlist. Do not automatically implement it.

End with literal flags:

- `EXPLICIT RESET-ADMISSION LIFETIME QUALIFIED: YES/NO`
- `STARTFRESH AND MESSAGEDATARESET PRE-TENURE DENIAL QUALIFIED: YES/NO`
- `ORDINARY/REENTRANT INERT BRANCH GATE QUALIFIED: YES/NO`
- `ACTUAL NESTED TENURE EXECUTED: NO`
- `LOCAL DATA REPAIR SEMANTICS CHANGED: NO`
- `STAGE 2 COMMAND/CONSTRUCTION DENIAL IMPLEMENTED: NO`
- `PRODUCTION RESET REACHABILITY FULLY CLOSED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `POPULATED RECONSTRUCTION WITNESS REQUIRED FOR CUTOVER: NO (ARCHITECTURAL)`
- `PROJECT CONFORMANCE (STAGE 1): PASS/FAIL`
- `READY FOR SEPARATE STAGE 2 PROMPT 120: YES/NO`

On any mandatory STOP, do **not** create a success implementation checkpoint. Preserve an exact factual STOP Response 119 and existing source/manifest, including any reproducible test evidence; no speculative scope enlargement. **STOP after Stage 1.**
