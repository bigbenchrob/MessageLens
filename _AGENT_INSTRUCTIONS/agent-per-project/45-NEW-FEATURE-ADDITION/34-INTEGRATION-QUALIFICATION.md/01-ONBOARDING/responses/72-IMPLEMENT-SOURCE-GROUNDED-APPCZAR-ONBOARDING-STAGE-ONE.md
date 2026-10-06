# MessageLens Feature 34
## Response 72 — Source-Grounded AppCzar Onboarding Stage One

### 1. Baseline verification

The required pre-checkpoint baseline was verified on `fix/onboarding-import-stuck-state` at `f56bf3ae7bb5e1244a856125e0c6ddb9c604ca11`, synchronized `0/0`, with a clean tracked worktree/index and the shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`. There was exactly one Feature 34 worktree. A fresh external manifest was written to `/tmp/messagelens-prompt72-baseline-20261006.md`.

### 2. Prompt 71 / Response 71 documentation checkpoint

Prompt 71 and Response 71 were checkpointed and pushed before source edits as `5f694a710215d5af6658c9ac69a1c2bafa60ee0d` (`docs(feature-34): audit AppCzar onboarding`). It preserves Operating Stage Two PASS, executable AppCzar Onboarding not yet implemented, the reusable initial-build pipeline, and the three audited fact gaps.

### 3. Pre-change execution census

Before Prompt 72, Data Update, Source Access Repair, and Attachment Archive Repair were executable top-level coordinators; Operating Session was an executable admitted session. Onboarding, Local Data Repair, and Diagnostic Review were virtual only.

### 4. Shared physical-evidence extraction

Snapshot-free physical store evidence now lives under `essentials/installation_evidence`. `SqliteMessageLensInstallationEvidenceReader` implements both the legacy semantic reader and the neutral physical reader while reusing its one bounded SQLite inspection implementation. The physical entry point does not read the durable Onboarding operation snapshot.

### 5. InitialConstructionScopeObservation design

`AppCzarInitialConstructionScopeObservation` records a typed current condition plus import/graph/non-live counts, retired-artifact presence, and a literal issue. Its conditions are `safeEmpty`, `consequentialData`, `protectedNonLiveData`, `retiredOrUnsupportedMaterial`, `unhealthy`, and `unknown`.

### 6. Exact safe Stage One predicate

Stage One is safe only when import and graph stores are absent or bounded-healthy and empty, non-live source count is zero, retired derived artifacts are absent, store evidence is not failed/contended/unsupported, the development root is admitted, and the archive binding is current and coherent. Presence is observed but not required merely because the architecture supports it; overlay evidence is never treated as disposable.

### 7. Partial/protected/retired classification behavior

Any import message, graph message/chat/edge, or other consequential partial row produces `consequentialData`; non-live imported material produces `protectedNonLiveData`; retired files or unsupported schemas produce `retiredOrUnsupportedMaterial`; failed inspection produces `unhealthy`; contention or inconclusive inspection produces `unknown`. None can enter Onboarding Stage One.

### 8. Typed Contacts observation design

AppCzar now reads the existing `AddressBookFolderRepository` through `AppCzarContactsPrerequisiteReader`. Repository failures carry `FolderRetrievalFailureKind`, and successful evidence reports current contact count and viable-store count. The existing Contacts importer remains unchanged.

### 9. Contacts taxonomy and literal semantics

The taxonomy is `viableWithContacts`, `viableEmpty`, `accessDenied`, `unavailable`, `invalidOrCorrupt`, and `unknown` (plus `notRequiredForCurrentScope` outside initial construction). Zero contacts is viable. Access denial and unavailable source remain distinct. Copy claims denial only for typed denial evidence.

### 10. Evaluator ordering correction

AppCzar now evaluates admitted root, physical initial-construction scope, local store health, and archive safety before applying source-access jurisdiction. Safe empty scope reaches Onboarding for conclusive source TRUE or FALSE; source UNKNOWN reaches Diagnostic Review. Established complete data keeps the previously qualified Source Access and ordinary downstream ordering.

### 11. Onboarding versus Source Access distinction

Conclusive source unreadability in an affirmatively safe empty installation selects Onboarding, where the prerequisite can be checked again. The same evidence in a complete established installation selects Source Access Repair. Scope, not historical intent, determines the distinction.

### 12. Onboarding versus Local Data Repair distinction

Onboarding accepts only safe empty physical scope. Consequential partial data, protected non-live material, retired/unsupported material, and unhealthy local stores select virtual Local Data Repair rather than being cleaned or rebuilt in place.

### 13. Onboarding versus Diagnostic Review distinction

Unknown physical scope, unknown source readability, unstable readable-source sampling, invalid/corrupt or unknown Contacts evidence, and incoherent archive binding fail closed to virtual Diagnostic Review.

### 14. Exact Onboarding executable predicate

`shouldExecuteAppCzarOnboarding` requires the exact AppCzar Onboarding disposition, admitted development root, TRUE safe-scope and archive-availability facts, a complete current archive binding, `safeEmpty` physical scope, conclusive source truth, and an admissible typed Contacts branch. No generic coordinator dispatcher was added.

### 15. New Onboarding package architecture

`lib/essentials/app_czar_onboarding/` contains domain state, an application controller, a narrow build executor, and presentation. It imports no Journey coordinator/state, Trip/Step/Episode, Onboarding status/gate/report, durable operation snapshot, completion verifier, reset service, or legacy `StartupApp`.

### 16. Minimum occurrence state

The controller is memory-only and generation-bound. Its phases are `dormant`, `checkingPrerequisites`, `sourceNeedsHuman`, `contactsNeedHuman`, `building`, `restarting`, and `failed`. It publishes no installation-ready, ready-to-start, normal-application, or durable-resume state.

### 17. Self-location behavior

Entry performs fresh reads of root, physical scope, Messages, typed Contacts, and archive binding. Before build admission it verifies the same root and archive scope identity/generation/path. Any changed binding or lost safe scope drains and restarts for a fresh AppCzar assessment.

### 18. Source FALSE behavior

Typed `accessDenied` and `unavailable` remain inside Onboarding with literal copy and a single-flight `Check Again`. System Settings is exposed and method-guarded only for proven access denial. A later TRUE read continues prerequisite location within the same Onboarding occurrence.

### 19. Source UNKNOWN behavior

UNKNOWN or unstable source evidence is not interpreted. Onboarding rejects further actions, invalidates stale publication, drains, and requests one real restart for fresh AppCzar classification.

### 20. Contacts prerequisite behavior

Viable populated and viable zero-contact sources satisfy the prerequisite. Access denial and no viable current database remain literal human prerequisite states with `Check Again`; only proven access denial exposes System Settings. Invalid/corrupt and UNKNOWN evidence drain and restart.

### 21. Ready-to-build policy decision

No independent current product choice was found beyond legacy Journey ceremony. Once all current prerequisites are satisfied, Stage One automatically admits one bounded initial graph build.

### 22. Exact reused initial-build worker path

The only build path is AppCzar Onboarding executor → `ConversationGraphBuildController.runOnce(owner: 'app-czar-onboarding')` → existing graph-build mutation tenure → existing service/orchestrator/importers/source-scoped ledger/projectors and message-data-version publication.

### 23. Proof no second pipeline exists

The new package constructs no importer, projector, graph-build service, Contacts importer, rich-text decoder, mutation coordinator, or database. Architecture checks assert one `.runOnce(...)` delegation and forbid a second `onboardingImport` path.

### 24. Rich-text and bounded import preservation

Because Stage One delegates directly to the existing graph-build controller, frozen source bounds, 500-row message pages, bounded transactions, exact page progress, frozen-total verification, 500-row rich-text candidate pages, the 8 MiB blob bound, and anomaly reporting remain unchanged.

### 25. Attachment payload semantics

The initial build continues to import/project attachment metadata and relationships only. It does not claim full payload preservation and does not invoke Attachment Archive Repair. Fresh AppCzar chooses any subsequent archive jurisdiction after restart.

### 26. No-cleanup proof

The new package contains no reset, deletion, retired-file cleanup, Start Fresh, import/graph removal, or archive mutation call. Architecture searches and tests enforce that absence. Prompt 72 did not access or mutate a real archive or real database.

### 27. Build-success terminal

Successful worker completion publishes no Operating outcome. After the admitted worker Future and mutation tenure complete, the controller requests one real restart so fresh AppCzar owns the next decision.

### 28. Build-failure terminal

Any terminal failure after build admission is treated as potentially durable partial evidence. The controller waits for the worker boundary, suppresses stale publication, and restarts once; it does not retry or clean in-process.

### 29. Onboarding stopAndDrain behavior

`stopAndDrain()` synchronously rejects new actions, advances the occurrence generation, ignores stale observations/progress, awaits the active prerequisite/build Future and its normal tenure release, and restarts only when explicitly required. Ordinary application exit drains without scheduling a restart. Assessment-generation replacement during active work queues exactly one restart after the active worker drains.

### 30. Development host integration

The development AppCzar harness has one explicit Onboarding branch and a lifecycle host that awaits `stopAndDrain()` on exit. `main.dart` injects the neutral physical reader into the development observation reader. Production `StartupApp` and production routing are unchanged.

### 31. Post-change execution census

Data Update, Source Access Repair, Attachment Archive Repair, and Onboarding are executable top-level coordinators. Operating Session remains the executable admitted session. Local Data Repair and Diagnostic Review remain virtual.

### 32. Presentation semantics

Presentation is bound only to the new controller state and shared actual graph-worker stage labels. It distinguishes denied from unavailable sources, reports current evidence and bounded progress, and contains no Journey episode, environment-readiness conclusion, installation-ready claim, prior-import resume claim, or in-process Operating handoff.

### 33. Initial-scope focused tests

Tests cover absent and healthy-empty safe shapes; consequential import and graph material; protected non-live data; retired artifacts; unsupported/unhealthy stores; contention/unknown evidence; non-disposable overlay state; snapshot-free physical reads; and no file creation during read-only inspection.

### 34. Contacts focused tests

Tests cover populated viability, zero-contact viability, access-denied, unavailable, invalid/corrupt, and unknown taxonomy. They also verify path-discovery completion safety and ensure typed outcomes are not collapsed to a Boolean.

### 35. Evaluator/jurisdiction tests

Tests prove safe empty + source TRUE/FALSE selects Onboarding; safe empty + source UNKNOWN selects Diagnostic Review; established complete + source FALSE selects Source Access Repair; consequential/protected/unhealthy/unknown scope cannot select Onboarding; and archive/attachment priority semantics remain intact.

### 36. Onboarding controller/executor tests

Tests cover exact predicate census, entry self-location, source and Contacts branches, in-process Check Again, one build invocation, build success/failure restart, changed scope/binding behavior, prerequisite-read failure, assessment-generation replacement, ordinary drain, stale-progress suppression, unavailable-source method-level System Settings guard, and no in-process Operating transition.

### 37. Worker/regression results

The focused evidence/Onboarding set passed 67 tests. The broader AppCzar, graph-build, source-scoped import, rich-text-through-worker, and exclusive-authority regression command passed 457 tests.

### 38. Existing qualified coordinator regressions

The 457-test regression set includes Data Update, Source Access Repair, Attachment Archive Repair, Operating Session/Stage Two, AppCzar host, graph worker, and mutation-tenure coverage. All passed without changing their qualified jurisdiction predicates.

### 39. Architecture result

Complete architecture suite: PASS, 600 tests. New tripwires prove the neutral physical seam, absence of Journey authority/cursor/reset paths, one graph-build delegation, one explicit development host branch, and no production import of the new package.

### 40. Analyzer result

`flutter analyze`: PASS, no issues found.

### 41. Full Flutter-suite result

Full deterministic Flutter suite: PASS, 3,056 tests passed with one intentional qualification-worker skip.

### 42. Diff/format/generated hygiene

`dart format` reported 39 files already formatted. `build_runner build --delete-conflicting-outputs` completed successfully and regenerated current Riverpod outputs. `git diff --check` and `git diff --cached --check` passed. No unrelated untracked artifact was staged.

### 43. Project Conformance verdict

PROJECT CONFORMANCE: PASS. One present-tense fact graph owns selection, the physical read is shared, Contacts evidence is typed, new Onboarding is memory-only, the existing worker and single mutation-tenure path are reused, terminal build outcomes restart, and production remains unchanged.

### 44. BLOCKER findings

BLOCKER: 0.

### 45. SHOULD FIX findings

SHOULD FIX: 0. A review-found controller-level System Settings guard gap was corrected before validation and is regression-tested.

### 46. Implementation checkpoint commit

`5435e803b55ba0362a5c8f1e08cfac2bbc43ea72` — `feat(startup): add source-grounded AppCzar onboarding`.

### 47. Documentation checkpoint commit

Prompt 72 and this Response 72 are the only intended records in the immediately following documentation checkpoint. Its resulting hash is reported in the final handoff after the commit exists.

### 48. Pushed recovery anchor

The pre-implementation recovery anchor `5f694a710215d5af6658c9ac69a1c2bafa60ee0d` was pushed before source edits. The implementation and documentation checkpoints are pushed normally after this record is committed; no force push, rebase, or squash is used.

### 49. Exact build identity/path/hashes

- Bundle: `build/macos/Build/Products/Debug/MessageLens Development.app`
- Product/display/executable: `MessageLens Development`
- Bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- Version/build: `0.2.139 (157)`
- Executable SHA-256: `dc457ebd321a5962ea3e42dc733cc9aae7a08ba644dc7104eff0592ab5fcd26e`
- `App.framework/App` SHA-256: `ae6b311a95fccd76c1b8734e16def9c50dac3857f43ecd5b0a53a726c5972f8c`

The build succeeded and was not launched.

### 50. Final Git/worktree/index/submodule state

At implementation checkpoint, tracked worktree and index were clean; only Prompt 72 and the known unrelated untracked artifacts remained. The shared-instructions submodule remained clean at `95326f515ef4719f155ce6e223990398daad6311`. The final post-documentation/push state is reported in the final handoff.

### 51. Readiness for isolated Onboarding human qualification

YES. Automated implementation and conformance gates pass. The next prompt must use a disposable safe-empty development fixture plus a deliberately unsafe partial fixture. Human live qualification remains pending.

### 52. Readiness for Local Data Repair milestone

YES, as the next separate implementation milestone: Stage One now mechanically refuses consequential partial/protected/retired/unhealthy data and routes it to the still-virtual Local Data Repair disposition. Local Data Repair itself is not implemented here.

### 53. Readiness for production AppCzar cutover

NO. Local Data Repair and Diagnostic Review remain virtual, legacy production startup remains intentionally unchanged, and this development-only Stage One has not yet completed isolated human qualification.

SAFE INITIAL-CONSTRUCTION SCOPE IS A CURRENT TYPED FACT: YES

CONTACTS PREREQUISITE IS FAIR-WITNESS TYPED: YES

SAFE NO-DATASET + SOURCE FALSE SELECTS ONBOARDING: YES

CONSEQUENTIAL PARTIAL DATA CANNOT ENTER ONBOARDING STAGE ONE: YES

APPCZAR ONBOARDING REUSES THE EXISTING INITIAL-BUILD PIPELINE: YES

APPCZAR ONBOARDING USES A DURABLE JOURNEY CURSOR: NO

EXECUTABLE APPCZAR ONBOARDING IMPLEMENTED: YES

PROJECT CONFORMANCE: PASS

READY FOR ISOLATED ONBOARDING HUMAN QUALIFICATION: YES

READY FOR PRODUCTION APPCZAR CUTOVER: NO
