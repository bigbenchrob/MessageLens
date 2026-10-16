# MessageLens — Feature 34
## Response 119 — Stage 1 composition lifetime and pre-tenure denial

Stage 1 is qualified within the inert and denied-entry scope below. Stage 2 is not implemented. Production AppCzar remains disabled.

## Recovered checkpoint and preservation

**FACT:** Work began on `fix/onboarding-import-stuck-state` at `f08e91141db0ca330dba1ae563ed668ae14e55fb`, with clean tracked/index state and upstream 0/0. Prompt/Response 118 were already committed and pushed there; no duplicate prerequisite checkpoint was needed. Prompt/Response 117 checkpoint `d7de9fbb650298583516eded229d965383b6e1b2` was verified in ancestry. Response 116 docs/source checkpoints are `5120999325ab34fbca4ae47d58f022686923a0a3` / `6b90bea234f074a3ae641401f2e8b686406a132f`.

The source checkpoint is `e21334de96c2ab1484acbb8f3378ccad2cc49972`, normally pushed. The exact Prompt/Response 119 pair receives a separate documentation checkpoint; its actual hash is reported at handoff (a document cannot embed its own commit hash). No archival moves, navigation index or unrelated files are staged.

Baseline inventory: 6,007 tracked and 50 untracked files, including Prompt 119 and 49 unrelated files. Local SHA-256 evidence is `/private/tmp/messagelens-prompt119-baseline.json`; exact implementation allowlist is `/private/tmp/prompt119-allowed.json`; final source hashes are `/private/tmp/prompt119-implementation-hashes.json`. These local evidence files are not repository artifacts. Outside the 14 implementation paths all baseline bytes were preserved, including the onboarding README, three archived backup scripts and restored historical documents. Prompt 119 remains byte-identical. After its docs checkpoint, 49 unrelated untracked files are expected to remain.

Exactly one worktree uses this branch. Other worktree tips remain Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Shared instructions remain clean at `95326f515ef4719f155ce6e223990398daad6311`. Final post-documentation upstream, tracked/index, inventory and submodule verification is reported at handoff.

## Baseline characterization and exact changes

**FACT — source-inspected baseline:** Final presentation selection was root-overridden in main, but the raw provider default startupApp did not prove explicit selection. Activation was disabled. Both coordinator APIs converged on `_run`, which selected ordinary/reentrant registry execution without the new composition veto. Start Fresh and message-data reset retained different checkpoint requirements. Local Data Repair was a separate operation with its own unchanged safety/execution contract. No allowed real reset was executed to demonstrate the missing gate.

The only source/test/generated changes are:

- `lib/essentials/archive_environment/domain/archive_reset_admission.dart`
- `lib/essentials/archive_environment/application/archive_reset_admission_provider.dart`
- `lib/main.dart`
- `lib/essentials/archive_environment/feature_level_providers.dart`
- `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`
- `lib/essentials/archive_environment/application/archive_mutation_admission_test_support.dart`
- `lib/essentials/archive_environment/application/archive_reset_admission_provider.g.dart` — normal generator output.
- `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart` — normal generator output.
- `test/essentials/archive_environment/application/archive_reset_admission_test.dart`
- `test/essentials/archive_environment/application/archive_mutation_pre_tenure_admission_test.dart`
- `test/app_czar_startup_composition_test.dart`
- `test/architecture/app_czar_architecture_test.dart`
- `test/architecture/exclusive_authority_architecture_test.dart`
- `test/architecture/forbidden_imports_test.dart`

This is eight modified and six new files. The new generated provider and the coordinator generated hash were produced by the normal generator; no generated file was hand-edited. No dependency, entitlement, architecture allowlist, selector, local-repair model/safety/executor or reset-service file changed.

## Implemented contract

**FACT:** `ArchiveResetAdmission` reuses the neutral `StartupPresentationComposition` enum. Each object has immutable selection and a unique object epoch, with monotonic revocation. State distinguishes startupApp, AppCzar, unavailable and revoked. Only explicitly selected live startupApp permits the two operations to continue to existing admission gates. This is permission to continue checking, not reset authority. One domain policy owns exactly `startFresh` and `messageDataReset`; all other operations bypass provider resolution entirely.

Main creates one instance after final selection. The root override registers revocation on that same instance and is eagerly read so disposal is installed even when no reset is requested. Invalidation returns that same, now revoked object rather than selecting legacy again. The unoverridden provider defaults to unavailable. Read failures become bounded typed denial, never legacy fallback. Consumer bindings retain their parent epoch and have independent monotonic closure; closing one does not revoke its siblings. Revoked L1 remains denied even if live same-composition L2 exists.

**EXECUTED TEST:** Synthetic Riverpod containers exercised the actual override/dispose pattern, including invalidation. One callback occurs for the first realized provider lifetime; rebuilding and finally disposing invokes a second callback for the next realized provider lifetime, always on the same root object. Root revocation remains monotonic, with no revival. Default-provider invalidation creates another unavailable object. This is executable provider-lifecycle evidence; native main/container startup was not executed. Main wiring was source-asserted.

## Gate dominance and evidence limits

**FACT:** Both production APIs call `_run`, which calls the same private `_dispatchBeforeTenure` helper used by the source-local test friend. For reset operations it captures the input/binding and checks it before reading the private candidate/Zone fact, then checks again before selecting exactly one original continuation. There is no await between the initial successful check and branch selection. Binding closure occurs in finally. Original registry algorithms and Zone identity predicates remain intact.

The admitted-scope path checks the same binding before activation, after awaited checkpoint work before capability creation, before callback invocation, and in capability currentness. These later production placements were source-inspected; actual nested tenure and post-tenure timing remain **UNKNOWN**, not executable passes.

The friend explicitly rejects non-debug execution, accepts only operation/lifetime/candidate-branch facts, and constructs its own inert counters/continuations. It exposes no arbitrary callback, container, archive identity, authority, claim, Ball, lease or capability. It is hidden from the public barrel. Architecture checks restrict its invocation to the exact test. The release guard was source-asserted, not executed in a release process.

**EXECUTED TEST:** 75 focused tests comprise:

- Nine domain/provider cases: explicit states, epoch distinction/ABA, independent binding closure, default and overridden provider disposal/invalidation, bounded typed denial and unchanged non-reset/checkpoint rules.
- Sixteen actual denied front doors: two reset operations × both run APIs × AppCzar/missing/throwing/revoked input. Registry factory, authority/checkpoint/validator and callback spies remain untouched; registry does not exist, authority stays unlocked, and no tenure denial counter or mutation callback is entered.
- Twenty private-helper cases: both reset operations × both candidate branches × five input states. Denial enters neither continuation; explicit legacy selects exactly one inert continuation.
- Four late-revocation inert cases: both reset operations × both branches. Revocation during the internally suspended inert continuation prevents completion using the same currentness-check primitive. Entry count is one, completion false; this is not post-tenure evidence.
- Twenty-six non-reset cases: all 13 remaining operations × both candidate branches. Throwing/unavailable reset input is never resolved and exactly one inert sentinel is selected, including Local Data Repair.

No real allowed reset, genuine nested Zone, tenure, Ball or writable lease was created. Existing coordinator fixtures were screened and excluded because they acquire real tenure, including cases whose later archive admission fails. No broad/full test suite was run. No real local repair, SQL/source/data access, app/native launch, import, build, migration or cleanup was performed.

## Attributable validation

All paths below are local logs under `/private/tmp/`.

| Command/scope | Final result | Log |
| --- | --- | --- |
| `dart run build_runner build` with build filters for the two named generated files | Exit 0; only two permitted generated paths changed | `prompt119-generation.log` |
| `flutter test --no-pub --reporter expanded` on the two new Stage 1 test files | 75 passed, exit 0 | `prompt119-focused-final.log` |
| Same test command on startup composition and production eligibility policy tests | 23 passed, exit 0 | `prompt119-regression.log` |
| Same test command on app_czar, exclusive_authority, forbidden_imports, startup_presentation_evidence architecture tests | 478 passed, exit 0 | `prompt119-architecture-final.log` |
| `flutter analyze --no-pub` | No issues, exit 0 | `prompt119-analyze-final.log` |
| `dart format --output=none --set-exit-if-changed` on all 12 touched hand-authored Dart files | 0 changed, exit 0 | Tool output |
| Working and staged `git diff --check`; exact staged source allowlist and SHA comparison | Passed before source commit | Tool output and manifests |

The generator reported 1,702 outputs including intermediate/cached output; repository hash/diff inspection found no unrelated generated or dependency churn. Coordinator generated output changed its hash only. Targeted Dart analysis was unnecessary after the clean full analyzer.

**Literal intermediate failures:** The first analyzer reported two import/export ordering infos; these were corrected. The initial architecture run had 477 passes and one failure because the proposed new state name `legacy` violated the existing active-concept naming rule. The state was renamed `startupApp`, matching the reused composition enum; no architecture exemption or test weakening was introduced. Final focused, architecture, analyzer and format results above follow those corrections. No SDK-blocked or interrupted attempt is counted as passing.

## Canonical Project Conformance — Stage 1 only

Reviewed against the canonical Feature 34 Project Conformance standard, repository/global instructions, architecture, database/SQLite, overlay and preservation rules, and Prompt/Responses 117–118 and Response 116.

**BLOCKER: 0. SHOULD FIX: 0. PASS for Stage 1.** One domain owner supplies the two-operation veto; explicit root selection and monotonic root/consumer lifetimes avoid ambient legacy fallback. The same helper dominates both branch continuations and both public APIs. The friend is debug-fenced, hidden, constrained to inert observations, with no arbitrary callback exposure or production use. The input has no I/O, AppCzar evaluator/display dependency or provider cycle. Existing seven jurisdictions, production selector and disabled activation remain unchanged. Non-reset operations never read the new provider; unchanged source hashes preserve Local Data Repair model/safety/executor/reset footprint and all Stage 2 classes. Diagnostics are typed and bounded. Generated and source scope is exact; no unrelated file changes or user-data/capability access occurred. This bounded internal qualification introduces no production cutover or release metadata change.

**UNKNOWN:** Genuine reentry, actual post-tenure revocation timing, full native startup, real allowed legacy reset completion and full production reset reachability. Command/action/service construction and stale high-level objects still require Stage 2. Passing this gate does not authorize activation or remove other production cutover requirements.

## Recommended next step — proposal only

Use a separate Prompt 120 to implement Response 118's Stage 2 command/construction/stale-object denial using this same lifetime contract, limited to its exact Stage 2 allowlist (Response 118, “Stage 2 — complete command/construction/stale-object denial”). That comprises sidebar dispatcher; advanced Start Fresh action/provider; Start Fresh service/provider; message-data reset service; only their four listed generated outputs; and the enumerated Stage 2 tests. Qualify denied factories and suspended/cached objects with inert dependencies, preserving the specific local-repair route. Do not run real reset bodies or acquire authority. Stage 2 has not started here.

EXPLICIT RESET-ADMISSION LIFETIME QUALIFIED: YES

STARTFRESH AND MESSAGEDATARESET PRE-TENURE DENIAL QUALIFIED: YES

ORDINARY/REENTRANT INERT BRANCH GATE QUALIFIED: YES

ACTUAL NESTED TENURE EXECUTED: NO

LOCAL DATA REPAIR SEMANTICS CHANGED: NO

STAGE 2 COMMAND/CONSTRUCTION DENIAL IMPLEMENTED: NO

PRODUCTION RESET REACHABILITY FULLY CLOSED: NO

PRODUCTION APPCZAR ACTIVATION: OFF

POPULATED RECONSTRUCTION WITNESS REQUIRED FOR CUTOVER: NO (ARCHITECTURAL)

PROJECT CONFORMANCE (STAGE 1): PASS

READY FOR SEPARATE STAGE 2 PROMPT 120: YES
