# 10 — CORRECT POST-AWAIT PREREQUISITE CURRENTNESS AND SEMANTIC-CENSUS FINDINGS — RESPONSE

## A. Baseline identity

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty before the correction and still empty after it.
- Reviewed tracked baseline: 46 modified files and 2 deleted files. Prompt 10 changed only:
  - `lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart`
  - `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- The two intended new implementation/test files remain untracked:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Prompt 09's review response remains present. This response is the only new review artifact created by Prompt 10.
- The unrelated untracked prompts, responses, `00-PREPARATION/`, and `.vscode/settings.json` were not changed.
- Shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`.
- Parked patch: `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`
  - Size: 21,137 bytes
  - SHA-256: `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`
  - It remains unchanged, unapplied, and outside the working tree.
- No application was launched. No real database or archive was accessed or mutated.

## B. BLOCKER correction

### Coordinator-owned currentness decision

`OnboardingJourneyCoordinator` now has one private prerequisite-currentness decision, `_latestPrerequisitesPermitCommand`, parameterized by the intended `_OnboardingPrerequisiteCommand`:

- initial import;
- reimport;
- interrupted continuation;
- automatic recovery.

It evaluates `_latestReport`, the coordinator's already-coherent and current prerequisite/environment truth. It does not cache a second report, infer permission from rendered Journey state, or introduce another state machine. Initial import, reimport, and automatic recovery require the absence of an external prerequisite blocker. Continuation additionally uses the coordinator's existing interrupted-continuation compatibility semantics. If the current report contains a typed external blocker, the coordinator publishes the corresponding typed Journey Episode from that same report. The authority flow remains:

`operation/environment evidence → OnboardingJourneyCoordinator → presentation`

If no coherent report is available, the helper requests a refresh and denies mutation; it does not guess.

### Invocation and final mutation ordering

- **Initial import / Retry:** prerequisites are checked at command admission, inside admitted execution, after awaited controller acquisition, and immediately before `controller.begin`. The command token and action context must also remain current. There is no `await` between the final prerequisite check and `begin`.
- **Reimport / Retry:** the equivalent checks occur at admission, inside admitted execution, after controller acquisition, and immediately before `controller.begin`. There is no `await` between the final prerequisite check and `begin`.
- **Continue Setup:** prerequisites are checked before admission, inside admitted execution, and after controller acquisition. Immediately before `controller.resume`, the coordinator also revalidates the exact operation UUID, process-session identity, interrupted status, command token, and action context. There is no `await` between the final prerequisite check and `resume`.
- **Automatic recovery:** prerequisites are checked inside admitted execution, after controller acquisition and immediately before `begin`, then checked again after the awaited progress-evidence persistence and immediately before derived-data reset. There is no `await` between the final prerequisite check and either `begin` or reset.

### Late-regression behavior

When a prerequisite regresses during an awaited acquisition/persistence window, the pending stale command cannot call `begin`, `resume`, or reset. The coordinator publishes the current typed prerequisite Episode (`OnboardingNeedsMessagesAccess` or `OnboardingNeedsContactsAccess` in the tests). It neither fabricates a UUID nor discards truthful retained evidence.

For a Retry stopped before a replacement `begin`, the previous failed binding and UUID are retained privately and restored after the command unwinds; a later compatible report resurfaces that same failed operation. A genuine new admission/begin failure is not misattributed to the retained UUID and remains UUID-less. For automatic recovery stopped after a new operation has begun but before reset, the bound operation becomes retained retryable failed evidence; the typed prerequisite Episode remains presentation truth, and reset is not performed.

This is race-safe because every operational mutation is guarded by the latest coordinator-owned report after the last relevant await, while action/command and operation-generation checks still reject stale intent and stale evidence.

## C. Deterministic race proof

All race tests use completers; none uses timing sleeps.

1. **Actual Retry / initial-import `begin`**
   - A graph failure first establishes a Retry-capable failed Episode and bound operation UUID.
   - The test invokes the Episode's real Retry action and suspends execution in the next `onboardingOperationControllerProvider.future` acquisition.
   - While acquisition is held, it publishes a Full Disk Access regression. The active command intentionally keeps the old rendered Episode in place during the window, proving action-context appearance cannot be the safety check.
   - Releasing acquisition completes the await. `begin` is not called, the graph executor remains at one invocation, and no reset/import mutation occurs.
   - The Journey becomes `OnboardingNeedsMessagesAccess`. The original failed UUID/status remain retained and resurface unchanged after compatible prerequisites return.

2. **Continue Setup / `resume`**
   - A valid interrupted resumable operation exposes the real Continue Setup action.
   - Controller acquisition is held after the action is invoked.
   - An Address Book/Contacts regression is published while held.
   - Releasing acquisition does not call `resume`.
   - The original interrupted operation UUID, process-session ID, and interrupted status remain unchanged. The Journey becomes `OnboardingNeedsContactsAccess`.

3. **Reimport / `begin`**
   - A normal-application Episode invokes reimport and is held during controller acquisition.
   - An Address Book/Contacts regression is injected, then acquisition is released.
   - The controller remains idle, no new `begin` occurs, and reset count remains zero.
   - The Journey becomes `OnboardingNeedsContactsAccess`.

4. **Automatic recovery / `begin`**
   - A graph-projection-failed report requests automatic reset/recovery, with initial controller acquisition deliberately held.
   - Full Disk Access is removed while held, then acquisition is released.
   - The controller remains idle, automatic `begin` does not occur, and reset count remains zero.
   - The Journey becomes `OnboardingNeedsMessagesAccess`.

5. **Automatic recovery / reset after progress persistence**
   - Automatic recovery is allowed to begin, then persistence of the `resettingDerivedData` progress evidence is held.
   - Full Disk Access is removed during that exact post-begin/pre-reset await.
   - Releasing persistence reaches the final currentness guard; reset count remains zero.
   - The bound operation is retained as retryable failed evidence while the visible Journey truth is `OnboardingNeedsMessagesAccess`.

An additional regression test proves that if a later Retry reaches archive admission and that new admission fails, the new failure remains UUID-less rather than inheriting the retained operation UUID.

## D. Semantic-census correction

### Previous limitation

The Prompt 09 census recursively traversed only local dependencies below `lib/essentials/onboarding/` and `lib/features/environment_readiness/`. A wrapper elsewhere under `lib/` could therefore conceal a transitive dependency on raw environment, snapshot, or graph evidence. Several terminal provider/action seams were also trusted by name/comment rather than proven mechanically.

### New traversal rule

The census now recursively traverses every resolved local Dart dependency under `lib/`, regardless of the intermediate directory. Generated `.g.dart` files and external/package imports are excluded as non-semantic edges. `lib/config/` is treated as a leaf only in conjunction with a mechanical scan proving that it contains no raw onboarding evidence or Journey-state dependency. Failure output includes the complete dependency chain to the forbidden evidence source.

### Explicit stops and their mechanical proofs

- **Journey coordinator:** remains the sole authority seam; existing architecture checks prove listener-driven ownership, prohibit production invalidation, and prohibit independent shell reconciliation.
- **Onboarding provider barrel:** each import must use an explicit `show` list restricted to approved Journey-state and intent symbols; complete/unbounded barrel imports fail.
- **Logging provider barrel:** each import is similarly restricted to approved diagnostic/action symbols and cannot become an onboarding semantic read seam.
- **Intent action providers:** source-shape assertions require `FutureOr<void> build()`, prohibit `ref.watch`, prohibit state publication, and prohibit raw environment/snapshot reads or watches.
- **Development panel:** source and whole-presentation-tree scans prove it is explicitly diagnostic and the unique permitted presentation consumer of raw onboarding evidence.
- **Advanced Start Fresh action, presentation provider, and authorization dialog:** assertions prove their separate action/presentation types and absence of Journey/raw onboarding semantic models.
- **Panel widget provider seam:** the exact effective-center-spec method may watch only the effective center-panel stack and contains no onboarding/graph dependency.
- **Center-panel synchronization controller:** accepts typed `OnboardingStatus` and contains no Journey coordinator, environment-report, or operation-snapshot provider dependency.
- **Configuration leaves:** the entire `lib/config/` tree is scanned for raw report, snapshot, graph, or Journey semantics before it is allowed to remain a traversal leaf.

### Census tripwire proofs

Two virtual dependency-graph tests prove the census behavior without adding fake production files:

- a semantic wrapper placed at `lib/shared/read_models/...` is traversed and its path to raw environment evidence is reported;
- an arbitrary action adapter under another feature is traversed and cannot conceal a raw operation-snapshot dependency.

The future-wrapper guarantee is therefore based on a repository-wide local-dependency property, not the previous two-directory convention or an expanding wrapper allowlist.

## E. Regression preservation

The complete diff was inspected after implementation. Prompt 10 is limited to the coordinator, its focused tests, the authority architecture census, and this report. The accepted Prompt 08 behavior remains intact:

- generated keep-alive coordinator lifetime;
- one coordinator authority and one-way evidence-to-Journey-to-presentation flow;
- operation UUID identity chain;
- process-session, revision, status, stage, and progress validation;
- prerequisite precedence over retained failed/interrupted work;
- bounded startup-only adoption of unbound durable evidence;
- hostile-noise rejection;
- UUID-less failure/action truthfulness;
- failure publication before secondary side effects;
- restart and reconciliation behavior;
- explicit user continuation rather than auto-resume;
- specialist ownership boundaries;
- immutable/data-only Journey operation projection;
- indeterminate progress when totals are unknown or nonpositive;
- current production Journey semantic ownership.

No second prerequisite authority was introduced. The deferred optional cleanup/documentation work remains untouched.

## F. Validation

- Focused coordinator suite: **43 passed** during the initial correction pass.
- Coordinator plus focused Journey-authority architecture test: **53 passed**.
- Wider focused Journey/onboarding bundle (coordinator, gate, Journey path, overlay failure/progress, center-panel observer, and environment-readiness surface): **83 passed**.
- Focused Journey-authority architecture file after census hardening: **9 passed**.
- Complete architecture suite: **496 passed**.
- `flutter analyze --no-pub`: **No issues found** (5.8 seconds).
- `git diff --check`: **passed**, no output.
- Formatting: the three Prompt 10 code/test files were formatted with the workspace Flutter SDK's Dart formatter.
- Code generation: **not run**; Prompt 10 changed no annotated/generated-source input.
- Native tests: **not run**; no native code changed.
- Full repository test suite: **not run**, as Prompt 10 explicitly requested deterministic focused proof plus architecture validation rather than a compensating full-suite run.

## G. Exact Git status

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty; no files staged.
- Tracked worktree: 46 modified files and 2 deleted files, matching the reviewed pre-correction Prompt 08 baseline. Prompt 10 edited three files already within that intended set; it added no unrelated tracked path.
- Intended untracked implementation/test files:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Intended untracked review records include the existing Prompt 09 response and this Prompt 10 response under `01-ONBOARDING/responses/`.
- All unrelated untracked prompt/response trees, `00-PREPARATION/`, and `.vscode/settings.json` remain untouched.
- Shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`.
- Parked patch: still 21,137 bytes with SHA-256 `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`; unchanged and unapplied.
- Staging/commit/push/merge: none performed.

**Prompt 10 correction complete; ready for repeated human architectural review.**
