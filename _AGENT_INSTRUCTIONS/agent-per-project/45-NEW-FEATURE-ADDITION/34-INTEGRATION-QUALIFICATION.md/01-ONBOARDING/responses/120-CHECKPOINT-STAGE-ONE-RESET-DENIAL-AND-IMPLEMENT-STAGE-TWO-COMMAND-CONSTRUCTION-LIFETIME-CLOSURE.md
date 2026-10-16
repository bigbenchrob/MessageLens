# Feature 34 — Response 120

## STOP before implementation: capability-taking method qualification conflict

**FACT:** Stage 1 is present and unchanged. Stage 2 was not implemented. No source, test, generated, dependency, platform, selector or release files were edited. This response records an unresolved qualification requirement, not a success checkpoint.

## Verified baseline

- Branch: `fix/onboarding-import-stuck-state`; HEAD `2c95f9a20bf162a67b2827ab04aab49054263a77`; upstream 0/0.
- Stage 1 source: `e21334de96c2ab1484acbb8f3378ccad2cc49972`. Prompt/Response 119 are already tracked in HEAD, which contains exactly those two documents. No duplicate prerequisite checkpoint is needed. `git diff e21334de HEAD -- lib test` is empty.
- Tracked tree and index are clean. Shared instructions submodule is clean at `95326f515ef4719f155ce6e223990398daad6311`.
- Exactly one of four worktrees uses the active branch. Other tips are Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`.
- Baseline regular-file SHA-256 inventory: `/private/tmp/prompt120-baseline.json`, 6,015 tracked files and 50 untracked files. Fifty includes Prompt 120 and 49 unrelated files. All baseline bytes are preserved, including the restored historical documents, onboarding navigation README and archived scripts. This response is the sole added repository file; final untracked count is 51.
- No staging, commit or push was performed in Prompt 120. The prompt and STOP response remain untracked. No success implementation checkpoint exists.

## Blocking evidence

Prompt 120 §5 requires executable adversarial qualification of both general shared reset methods and requires the local-repair route to remain usable with a throwing reset input. Its safety rules prohibit acquiring real mutation tenure/capabilities and its allowlist prohibits changing Stage 1. Section 6 says: “If an unsafe constructor or async path cannot be qualified inside this allowlist, STOP without success checkpoint.” Response 118's Stage 2 completion rule also requires stopping if fixtures force a new public production helper or reset API.

**BLOCKER 1 — no authorized executable seam for capability-taking method-entry proof.**

1. `message_data_reset_service.dart:69` declares `resetDerivedDataForStartFresh(ArchiveMutationCapability capability)`. The local-repair method at line 77 has the same non-nullable capability parameter. Tests must supply that argument before either method body can run.
2. `archive_mutation_coordinator_provider.dart:50` declares `final class ArchiveMutationCapability`. Its sole constructor at line 51 is private to that library. Tests in the allowed onboarding files cannot construct, subclass or implement it.
3. Repository search finds exactly one capability construction expression, at coordinator line 223. It occurs inside `_runAdmittedArchiveScope`, reached via `runExclusive`/`runReentrant`, after scope activation and checkpoint checking. Even retaining an expired capability first requires prohibited admitted execution. An empty callback does not make tenure acquisition inert.
4. The existing `ArchiveMutationAdmissionTestSupport.inspect` returns counters and a denial reason only. It deliberately does not create or expose capabilities. Modifying that Stage 1 file is outside Prompt 120's allowlist and would contradict its reviewed no-capability port contract.
5. `message_data_reset_service.dart` has no existing source-local test friend or no-authority method-entry continuation seam; its only part is its generated provider. Existing fake `MessageDataResetService` implementations in service/Journey/local-repair tests exercise caller delegation, not the real implementation's method-entry denial.

A null/dynamic argument would fail Dart's parameter type check before entering the real method and would not prove the new reset veto. A mock of the reset service would prove only the mock. Making the capability nullable, forging one, widening the authority API, or introducing an unreviewed public test helper is not an acceptable workaround. No such workaround was attempted.

**Scope of this finding:** The high-level guard implementation appears feasible in the six permitted production files. The blocker is the requested executable evidence for the capability-taking real method and analogous local-repair use, under the simultaneous no-capability constraints. This is not a claim that the production architecture cannot support Stage 2, nor a newly discovered reset alias. It is not a reason to broaden destructive testing.

## Source characterization and call-site census

These are fresh source observations, not new runtime tests.

- Stage 1 root selection in `main.dart` occurs after final composition selection; the exact override registers revocation of the same object and is eagerly resolved. Default provider input is unavailable. Root revocation and binding closure are monotonic, and bindings retain their original parent/epoch. Only startFresh and messageDataReset are vetoed. Both lower APIs still converge on the same pre-tenure helper. Production activation remains disabled.
- Dispatcher `ResetMessageDataRequested` currently reads the advanced action provider and calls request without a higher-level reset binding. Show-reset-flow is presentation routing, not an additional deletion method.
- Advanced action provider constructs presentation/action dependencies without a binding. Its sole production constructor call is in that provider; twelve test constructor calls are in the allowed advanced action test file. Retained request/retry/dismiss, lifecycle logging, state/auth/frame/service/outcome awaits have no Stage 2 lifetime checks.
- Start Fresh service provider awaits operation and Presence dependencies before constructing the plain service. Its sole production constructor call is there; five test calls are in the allowed service test file. The plain service reads current state before requesting lower startFresh authority.
- Shared reset implementation has one production constructor call, in its own provider, and a private dependency type. Its factory is shared with Local Data Repair and cannot be globally denied. Both general methods and the distinct local-repair method exist as recorded in Response 118.
- Production general reset call sites: Journey coordinator (four `resetDerivedData` calls), development panel (one), and StartFreshServiceImpl (`resetDerivedDataForStartFresh`). Direct Start Fresh requests occur in main and the advanced action. Overlay retry/dismiss resolves the advanced action provider. The local-repair executor calls the separate local-repair method. No new alias was found in the bounded search for these symbols.
- Existing service tests include real archive fixtures and real coordinator admission. They were inspected and not run. Interface fakes do not solve the real shared-method entry proof gap.

Historical Response 116's hidden-menu reachability remains the red baseline; its counts are historical, not rerun here. Stage 1's 75 focused, 23 regression and 478 architecture passes are also historical Response 119 evidence. No Stage 2 red/green result, factory/continuation count or runtime ABA result is claimed.

## Exact relevant source hashes (unchanged)

- `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`: `caa48dd2e7f55b37b6b838054d37b7145ac9fa81911ece39d249ea357ecb61a2`
- `lib/essentials/archive_environment/application/archive_mutation_admission_test_support.dart`: `61c29e87b9305933cdf5bc1480c0dcfc913f82860e810a7b0f172d1f157e8bd6`
- `lib/essentials/archive_environment/domain/archive_reset_admission.dart`: `a58bc6c494e22a2a53503eba66c4d06b51d7e60b0f1036c5ec4bee899df1e15d`
- `lib/essentials/archive_environment/application/archive_reset_admission_provider.dart`: `49133e5e551bd699933fa4cba70e266ba7ca2fe05622c6ce41da734d8558ae39`
- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`: `840b3604502cf26213f6de236f4c586e109dc78391759871bc5c14e6489d3bf7`
- `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`: `7e7b1c49baf90eb13784a6f7ddc4649fae09fccbec41ae0e6541614d4bdebaa5`
- `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`: `e877e1ae75e744fe1dda0371cb4ec1486ed604bfea05f37e3c049baa14dee21d`
- `lib/essentials/onboarding/application/start_fresh_service_provider.dart`: `a17f827b69c80a0dc6d86be3d83c0db44bcce9f4e1bdf6cdf39611923846d154`
- `lib/essentials/onboarding/application/start_fresh_service.dart`: `b3b6a6bf2ba3d8f05f57ecd81651def0b6f99f4941fd8504e985a092eac91509`
- `lib/essentials/onboarding/application/message_data_reset_service.dart`: `1cc14d46366fdee8ec473f9f4f7d583adc858e0bd64758e0eb571f98c81bffdd`

## Validation and conformance

Executed repository-only inspection: Git status/log/show/diff/upstream/worktree/submodule checks, regular-file SHA-256 inventory, source reads and bounded `rg` constructor/call-site/private-constructor searches. One search named a nonexistent `message_data_reset_service_test.dart`; the subsequent repository-wide search established the actual test locations. This search miss is not test evidence.

No tests, analyzer, formatter, code generator, app build/launch, SQL, source/archive/volume/native/permission access, reset, local repair or real authority execution ran. There are no new test counts or generated outputs. Final integrity checks compare every baseline file and confirm tracked/index/submodule cleanliness and upstream 0/0. Whitespace is checked for this new document. No unrelated files are staged or moved.

**Reviewed against:** repository AGENTS.md; global agent guardrails; project README; Dart and Riverpod rules; project architecture overview; database INVIOLATE_RULES and overlay independence; attachment-preservation invariant; environment experimental-workflow restrictions; canonical `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompt 120; prior design/evidence in Responses 116–119; current constructor/provider/capability source. No skill or delegation was used. No live-data experiment or snapshot was required or attempted.

**BLOCKER: 1. SHOULD FIX: 0 identified in this bounded feasibility review.** This is not a completed implementation audit. Reuse/ownership, dependency direction, source preservation, privacy and authority boundaries have no new changes. Stage 2 lifecycle/error behavior, generated hygiene after implementation and executable qualification are not yet evaluated; they are not marked NO ISSUE. UI/performance behavior is unchanged. No dead-code cleanup or architecture exception was introduced.

PROJECT CONFORMANCE: FAIL

This verdict concerns incomplete Stage 2 qualification, not a failure of the preserved Stage 1 checkpoint.

## Smallest recommended resolution — proposal only

Revise the qualification contract explicitly to permit **source-level guard-ordering proof** for the real non-nullable capability-taking shared-service methods, coupled with executable lifetime/binding tests and executable denied-entry tests for the safely callable parameterless method, dispatcher, action and service providers/instances. Keep the capability final/private and Stage 1 unchanged. Label real capability-taking method invocation and local-repair execution UNKNOWN, rather than describing source checks as runtime proof.

If direct executable invocation of both capability-taking methods is indispensable, first design and explicitly authorize an exact restricted seam that cannot mint or expose real authority; do not invent it during this implementation task. No such seam or revised test requirement has been adopted here. A later instruction must resolve this conflict before Stage 2 can receive a success checkpoint.

Production process drain/replacement, in-place schema/data continuity, shell/provider closure, signing/FDA/specialist human rehearsal, verified backup/restore/rollback and activation approval remain separate blockers. Real nested tenure, post-tenure timing and signed-runtime behavior remain unqualified. No populated reconstruction or FTS work is required by this STOP or resumed here.

For the flags below, Stage 1 preservation is source/hash evidence; Stage 2 FAIL/NO means not implemented or qualified, not a failed executed test. General-message-reset NO refers to the requested higher-level Stage 2 method exclusion; Stage 1 lower denial remains present.

STAGE 1 LOWER RESET DENIAL PRESERVED: YES

STAGE 2 COMMAND/CONSTRUCTION DENIAL: FAIL

CACHED ACTION/SERVICE REVOCATION: FAIL

GENERAL MESSAGE DATA RESET DENIED IN APPCZAR: NO

LOCAL DATA REPAIR SEMANTICS CHANGED: NO

ENUMERATED GENERAL RESET REACHABILITY CLOSED IN APPCZAR: NO

SEVEN JURISDICTIONS UNCHANGED: YES

PRODUCTION APPCZAR ACTIVATION: OFF

COMPLETE POPULATED RECONSTRUCTION WITNESS: NOT REQUIRED FOR CUTOVER TRACK

PROJECT CONFORMANCE (STAGE 2): FAIL

READY FOR SEPARATE PRODUCTION-LIFECYCLE MILESTONE: NO
