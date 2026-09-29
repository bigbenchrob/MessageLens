# MessageLens Clean-Slate Integrated Qualification
## 11 — Repeated Human Architectural Review After Prompt 10

Date: 2026-09-25

## Executive finding

Prompt 10 correctly placed a latest-report check after the relevant awaits and immediately before `begin`, `resume`, and automatic reset. It also preserved the one-way authority relationship and the retained operation identities.

The implementation is nevertheless **not yet safe for final validation**. The new helper answers a narrower question than its name and Prompt 10 require. For initial import, reimport, and automatic recovery it treats every report without an external prerequisite blocker as permission to execute. For continuation it uses a similarly broad predicate. It does not prove that the latest coherent report still authorizes the **exact command**.

This leaves a deterministic destructive race. If automatic recovery begins from a `shouldResetAppDatabasesBeforeImport == true` report, then the latest report becomes `ready` or otherwise clears that reset requirement while controller acquisition or progress persistence is held, `_latestPrerequisitesPermitCommand` still returns true and the obsolete reset proceeds. Likewise, a late `ready` report still permits interrupted continuation even though the coordinator's ordinary no-command path treats readiness as superseding that interruption.

The semantic-census correction also remains incomplete as a future-proof architecture tripwire: the application shell is explicitly skipped by the transitive traversal, root discovery remains limited to selected directories/files, configuration leaves are only shallow-scanned, and the mechanically checked action stops do not exclude all raw graph/reconciliation evidence. Current production source has no competing semantic side door, so this is a test-quality **SHOULD FIX**, not a second present production authority.

## 1. Baseline and diff identity — NO ISSUE

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty
- Tracked worktree: 46 modified files and 2 deleted files
- Intended untracked implementation/test files remain present:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch: `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`, 21,137 bytes, SHA-256 `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`; unchanged and unapplied

The tracked inventory remains the reviewed Prompt 06 + 08 implementation delta. Prompt 10 changed only the intended coordinator, coordinator test, and authority-architecture test already within that delta. No unrelated tracked file, database schema, attachment/archive implementation, data-root path, or native source is mixed in.

## 2. Sole-authority and lifetime verdict — NO ISSUE

`OnboardingJourneyCoordinator` remains the sole production writer of `OnboardingJourneyState`.

- The generated provider is a non-auto-dispose `NotifierProvider` produced from `@Riverpod(keepAlive: true)`.
- `build()` installs `ref.listen` ingestion for environment evidence, operation evidence, and mutation-lock changes.
- `build()` uses `ref.read` for initial evidence and does not `ref.watch` changing evidence.
- The coordinator does not call `ref.invalidateSelf()`.
- No production source invalidates `onboardingJourneyCoordinatorProvider`.
- `_latestReport` is the coordinator's one current coherent prerequisite report; Prompt 10 did not introduce a parallel report cache or another Journey state machine.

The original stale-`ref` reconstruction failure remains corrected. Evidence producers can reconstruct independently without reconstructing the Journey owner mid-command.

## 3. Post-await prerequisite-currentness verdict — BLOCKER

### Correct structural ordering

The actual production traces now place the helper after the relevant await:

- Initial import and its Retry: controller acquisition at lines 1029–1031; command/action and latest-report check at 1032–1037; `begin` is called at 1041. No await intervenes between the final check and the call to `begin`.
- Reimport and its Retry: controller acquisition at 1117–1119; command/action and latest-report check at 1120–1125; `begin` is called at 1129. No await intervenes.
- Continue Setup: controller acquisition at 1243–1245; command/action plus exact operation ID, process session, and interrupted status at 1246–1251; latest-report check at 1254–1259; `resume` is called at 1261. No await intervenes.
- Automatic recovery before begin: controller acquisition at 1721–1723; command check at 1724–1726; latest-report check at 1727–1733; `begin` is called at 1736. No await intervenes.
- Automatic reset: progress persistence is awaited at 1748–1750; command/binding and latest-report checks occur at 1751–1756; reset is called at 1759–1761. No await intervenes.

The placement and command/identity currentness are therefore correct.

### Incorrect authorization predicate

`_latestPrerequisitesPermitCommand` at lines 621–645 does not actually answer whether the latest report permits the exact command:

- `initialImport`, `reimport`, and `automaticRecovery` all use the identical condition `!_reportHasExternalPrerequisiteBlocker(report)`.
- Automatic recovery does not revalidate `report.shouldResetAppDatabasesBeforeImport` or an equivalent recovery predicate.
- Initial import does not require current `readyToImport`/accepted-local-history semantics and therefore remains executable if the current report changes to an app-owned failure requiring a reset or to already-ready installation state.
- Interrupted continuation delegates to `_reportAllowsInterruptedContinuation`, which rejects selected blockers but returns true for `OnboardingEnvironmentState.ready`. That contradicts `_publishRetainedBinding`, where `ready` explicitly supersedes a retained interruption and triggers historical reconciliation rather than resume.

The active command token intentionally suppresses Journey replacement while updating `_latestReport`. Consequently, action-context currentness remains true in exactly these windows. A late non-external semantic change therefore reaches the underspecified helper and can still authorize stale mutation.

The clearest destructive trace is:

```text
graphProjectionFailed + shouldReset == true
-> automatic recovery command claimed
-> controller acquisition or progress persistence held
-> latest coherent report becomes ready / shouldReset == false
-> visible occurrence remains held by the active command
-> helper sees no external blocker and returns true
-> begin/reset executes despite the reset predicate having disappeared
```

The equivalent continuation trace resumes an interrupted operation after a late `ready` report even though readiness should supersede that interruption.

This violates the required property that the latest coherent report authorize the **exact** command after the last await. Correct placement around an insufficient predicate does not close the race.

## 4. Retained failed/interrupted evidence race verdict — NO ISSUE for the covered external-blocker cases

The Prompt 10 retention mechanics are otherwise coherent:

- `_takeRetainedRetryEvidence` privately removes the prior failed binding/unbound failure while a replacement attempt is being admitted.
- If an external blocker prevents replacement `begin`, the prior binding is restored without assigning a new UUID.
- The blocker Episode remains visible; a later compatible report resurfaces the same failed UUID under a fresh Journey occurrence.
- A genuine new admission/begin failure does not inherit that UUID and remains UUID-less.
- Continue Setup held before `resume` preserves the exact interrupted operation ID, prior process session, and interrupted status.
- Automatic recovery stopped after `begin` but before reset leaves reset untouched and converts the bound operation into retryable failed evidence, while the current prerequisite Episode remains visible.
- No covered stopped command is promoted to success merely because prerequisite presentation displaced it.

These properties are proven for external FDA/Contacts regressions. They do not cure the exact-command predicate blocker in section 3.

## 5. Prerequisite-precedence verdict — NO ISSUE

The visible priority remains:

```text
current external prerequisite truth
        >
retained app-owned failed/interrupted evidence
```

At startup and during live changes, FDA/Messages, local Messages/history, and Contacts blockers displace retained operation presentation while retaining its identity privately. Retry/Continue actions from the displaced occurrence become stale. Compatible prerequisites can resurface the retained evidence only through the coordinator under a new occurrence.

Prompt 10 did not weaken this Prompt 08 correction. The blocker in section 3 concerns non-external changes that revoke the exact command policy, not the established external-prerequisite display precedence.

## 6. Startup-only adoption verdict — NO ISSUE

The one-shot startup adoption boundary remains intact:

- `_startupAdoptionOpen` starts true.
- Independent report/snapshot settlement flags close the window permanently when both initial channels settle.
- Only that window may adopt unbound failed/interrupted evidence.
- Once closed, unbound snapshot emissions are durable history and cannot create an operation-backed Journey occurrence.
- Normal `begin`/`resume` binds the exact durable result directly rather than relying on listener adoption.
- Terminal acknowledgement retires the binding; replayed operation-A failure/interruption cannot move normal application.
- Operation-A evidence cannot replace operation B.
- A legitimate startup interruption is adopted once; replay after closure does not produce a second occurrence.

No second adoption authority or provider-driven reconstruction path was introduced.

## 7. Operation identity and Journey projection verdict — NO ISSUE

The current identity chain is coherent:

```text
typed action context
-> coordinator admission token
-> durable begin/resume
-> one operation UUID
-> Journey binding
-> executor/progress using that UUID
-> validated snapshot evidence
-> immutable Journey projection
-> presentation
```

- A new attempt obtains one new UUID from `begin`.
- Retry obtains a new UUID only after a replacement begin succeeds.
- Explicit continuation validates and retains the interrupted UUID, then adopts the current process session only through persisted `resume`.
- Evidence acceptance checks Journey occurrence, operation ID, kind, process session, legal status/stage/substage, non-regressing revision, duplicate fingerprint, and progress bounds.
- `OnboardingJourneyOperationProjection` is immutable/data-only and exposes no provider, controller, store, process session, snapshot history, recovery disposition, or mutation capability.
- Active and terminal operation Episodes require a bound projection; pre-UUID failures remain unbound.
- Nonpositive/unknown totals project to null and remain indeterminate; no raw graph-success or `1.0` fallback reconstructs progress meaning.

## 8. UUID-less failure/action verdict — NO ISSUE

UUID-less failures remain explicitly UUID-less. `OnboardingJourneyFailureAction` preserves coordinator-owned failed-command intent independently of durable operation evidence:

- first-import admission/begin failure -> `retryInitialImport`;
- reimport admission/begin failure -> `retryReimport`;
- automatic recovery -> `retryAutomaticRecovery`;
- environment-only failure -> `recheckEnvironment`;
- manual/nonrecoverable failure -> `none`.

Presentation derives copy/actions from that Journey intent. A new admission failure after a retained failed attempt is not assigned the retained UUID.

## 9. Failure-publication ordering verdict — NO ISSUE

`_publishFailureBeforeSideEffects` synchronously publishes the coordinator-owned failure before it attempts snapshot failure persistence, graph/import failure storage, logger acquisition/write, or evidence invalidation. Each secondary boundary is independently contained, and the original error remains the primary diagnostic.

The boundary-spy tests inspect live Journey state from inside each secondary callback and cover snapshot persistence, failure-store persistence, logger acquisition, logger write, and environment refresh. `OnboardingOperationSnapshotController.runStage` no longer publishes a competing failure. Prompt 10 did not move a provider access or other fallible operation ahead of the primary failure publication.

## 10. Semantic-census reach verdict — SHOULD FIX

Prompt 10 improved dependency traversal itself: `_transitiveLocalDependencies` now follows every resolved local Dart dependency under `lib/`, excluding generated files, external packages, and declared stops. The virtual `lib/shared/...` wrapper test demonstrates that the traversal algorithm can cross arbitrary directories.

The full production guarantee is still incomplete:

1. `MacosAppShell` is added to `productionSurfaces` but explicitly skipped at lines 67–69. Its separate source-shape assertion checks only direct `ref.watch(onboarding...Provider)` spelling. A shell-imported wrapper elsewhere under `lib/` can therefore hide raw semantic evidence from the transitive census.
2. Root discovery remains selected-directory based: Onboarding presentation, Environment Readiness presentation/resolver tools, shell, and one center-panel observer. A new production Onboarding semantic consumer in another feature/presentation directory is not automatically discovered unless already reachable from one of those roots.
3. `lib/config/` is a traversal leaf. Its scan checks direct raw/Journey spellings but does not prove that a config file cannot import an arbitrary wrapper that reaches raw evidence.
4. Actual allowlisted action providers are traversal stops. Their mechanical check prohibits `ref.watch`, `state =`, and direct reads/watches of only environment-report and operation-snapshot providers. It does not prohibit a `ref.read` of raw graph/controller or reconciliation evidence, nor a transitive raw dependency behind another local adapter.
5. The virtual action-adapter test does not test an actual stopped action boundary: its virtual stop set contains only the coordinator, so the adapter is traversed. It therefore proves the traversal algorithm, not that the production action-stop exemption is mechanically safe.

Current-source scans find no production presentation side door: raw report/snapshot/graph presentation remains confined to the explicitly diagnostic development panel, and production surfaces consume Journey state/projections. The finding is therefore about the claimed future-wrapper guarantee and is classified SHOULD FIX rather than a current authority BLOCKER.

## 11. Semantic-census false-positive/overfitting verdict — SHOULD FIX

Excluding generated files and package imports is sound: generated provider glue does not define independent semantic policy, and external packages are outside this repository-local authority census.

The test nevertheless mixes principle checks with exact path/private-symbol allowlists:

- root directories and boundary filenames are enumerated;
- provider-barrel permissions are exact symbol lists;
- several safe-boundary assertions depend on exact method/class/source spellings;
- conforming movement of a semantic surface to another feature directory can silently remove it from the census, while conforming renaming of an allowed seam requires test edits.

This creates both underreach and layout coupling. The tripwire should discover semantic consumers repository-wide and either traverse a stop or prove the complete transitive property that makes it safe, without relying on a growing set of private file/symbol spellings.

## 12. Specialist-boundary verdict — NO ISSUE

The coordinator owns Journey occurrence/Episode, coherent report retention, operation binding/currentness, evidence interpretation, action policy, orchestration, and next-state choice. It still delegates:

- FDA/Contacts/source probing;
- import and graph construction;
- snapshot persistence;
- derived-data reset mechanics;
- archive mutation admission;
- durable completion proof;
- failure storage/logging; and
- safe-boundary reconciliation.

The new helper interprets typed environment classifications and does not reimplement platform probes. No SQL, filesystem/archive mutation mechanics, database construction, or attachment authority moved into the coordinator.

## 13. Test-quality verdict — BLOCKER for exact-command currentness; otherwise NO ISSUE

The completer-based race tests genuinely reach the claimed external-blocker windows:

- controller-provider acquisition is held after invoking the real Retry, Continue, and reimport actions;
- initial automatic-recovery acquisition is held;
- automatic reset is held inside persistence of `resettingDerivedData` progress;
- reports regress while the await remains blocked;
- release is explicit and no timing sleep is used as the critical race mechanism;
- begin/resume/reset and retained identities are asserted afterward.

However, every new regression is an external FDA/Contacts blocker. No test changes the latest report to a non-external state that withdraws the exact command predicate—for example:

- automatic recovery `shouldReset: true` -> `ready`/`shouldReset: false` during controller acquisition;
- the same change during progress persistence before reset; or
- interrupted continuation -> `ready` during controller acquisition.

Those cases pass the current helper and expose the blocker. The architecture test's virtual-wrapper/action-adapter coverage has the gaps described in sections 10–11.

The pre-existing prerequisite precedence, startup adoption, hostile-noise, operation identity, UUID-less retry, and mechanical failure-order tests remain strong. No timing-based test was accepted as proof of Prompt 10's critical boundary.

## 14. Deletion, compatibility, and diff-shape verdict — NO ISSUE

- The obsolete reconciliation provider and generated sibling are deleted; no production reference remains.
- Pure reconciliation remains a specialist called by the coordinator.
- Removing operation snapshot data from `OnboardingEnvironmentReport` is an in-memory authority cleanup, not a persisted-format migration.
- Version-1 snapshot JSON retains the same durable fields. Resume updates existing process-session/status/revision fields without a schema bump.
- Generated Riverpod changes match the changed annotations/provider signatures.
- Compatibility Gate/action seams project or forward Journey-owned state and cannot assign Journey state.
- The tracked delta contains the planned coordinator, evidence, projection, presentation, compatibility, generated, and test changes only.
- No attachment archive, overlay-intent ownership, database schema, production path, native code, or real-data safety boundary changed.

## 15. Concrete BLOCKER findings

### BLOCKER 1 — Latest-report guard does not authorize the exact command

- **Files/symbols:** `onboarding_journey_coordinator_provider.dart`; `_latestPrerequisitesPermitCommand`, `_reportAllowsInterruptedContinuation`, `_runNewInitialImport`, `_runNewReimport`, `continueInterruptedOperation`, and `_runAutomaticRecovery`.
- **Rule:** after the last relevant await, the coordinator must prove that the latest coherent report still permits the exact intended command and that command/action/operation identity is current.
- **Cause:** initial import, reimport, and automatic recovery share only a “no external blocker” predicate; continuation's predicate also accepts `ready`.
- **Impact:** automatic derived-data reset can execute after its reset requirement disappears; interrupted work can resume after durable readiness supersedes it; initial import can begin after the report changes to a state requiring a different coordinator decision.
- **Required correction:** define command-specific current-report predicates. At minimum, automatic recovery must require the current reset/recovery predicate; continuation must reject readiness and use the same compatibility decision as retained-interruption reconciliation; initial import must require current import eligibility. Preserve any intentionally broad explicit-reimport policy explicitly rather than obtaining it accidentally from a shared negative check.
- **Required proof:** add completer-held tests for non-external semantic withdrawal at controller acquisition and at the automatic pre-reset persistence boundary. Prove `begin`/`resume`/reset are untouched and the coordinator publishes or later derives the truthful current Episode.

## 16. Concrete SHOULD FIX findings

### SHOULD FIX 1 — The repository-wide semantic census still has unverified leaves/stops

Remove the shell skip, discover all relevant semantic consumers rather than only selected directories, and make config/action/provider stops transitive or mechanically complete. The current virtual action test must exercise the same stop semantics used for real allowlisted adapters.

### SHOULD FIX 2 — The census is coupled to exact layout and private spellings

Retain narrow named authority/diagnostic seams where necessary, but base consumer discovery and stop safety on semantic properties so a conforming refactor does not silently leave the census or require an expanding filename/symbol allowlist.

## 17. OPTIONAL findings

- `onboardingJourneyAllowsCommandedTransition` remains unused, as explicitly deferred by Prompt 10. It is not a current authority defect.
- Canonical `20-environment-readiness.md` still says `OnboardingEnvironmentReport` carries the persisted operation snapshot and that presentation should render that exact snapshot. Current source correctly removed that field and renders the Journey-owned projection. This remains deferred documentation work.
- `OnboardingOverlay` retains stale comments referring to a production prerequisite Presence runner and `OnboardingGate.build`; current production presentation uses Environment Readiness plus the Journey coordinator. This is documentation/comment drift, not runtime authority.

## 18. Narrow tests rerun

None. Source inspection conclusively establishes both the command-policy predicate and the missing test cases. Prompt 10's reported results remain:

- wider focused Journey/Onboarding tests: 83 passed;
- focused authority architecture tests: 9 passed;
- complete architecture suite: 496 passed;
- analyzer: clean;
- `git diff --check`: clean.

Those green results exercise external prerequisite regression but not withdrawal of the exact automatic-recovery/continuation command predicate.

## 19. Exact Git status

- Branch/HEAD: `fix/onboarding-import-stuck-state` / `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty
- Tracked worktree: 46 modified files and 2 deleted files
- Untracked worktree: 69 files total after adding this response
- Intended untracked implementation/test files: the Journey operation projection and Journey authority architecture test
- This Prompt 11 response is the only file created by this review and remains untracked in `01-ONBOARDING/responses/`
- All known unrelated prompt/response trees, `00-PREPARATION/`, and `.vscode/settings.json` remain untouched
- Shared-instructions submodule: clean and unchanged at `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch: unchanged, unapplied, 21,137 bytes, SHA-256 `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`
- Staging/commit/push/merge: none
- MessageLens Development: not launched
- Real databases/archives/application state: not accessed or modified

## 20. Final architectural recommendation

Do not proceed to final full validation or checkpoint. Correct the command-specific latest-report predicates and add deterministic non-external predicate-withdrawal races. Harden the remaining semantic-census stops/root discovery in the same correction, then repeat this human architectural gate against the complete unstaged source.

`POST-PROMPT-10 HUMAN ARCHITECTURAL REVIEW: FAIL`
