# MessageLens Clean-Slate Integrated Qualification
## 09 — Repeated Human Architectural Review After Prompt 08 Corrections

Date: 2026-09-25

## Executive finding

The Prompt 08 corrections resolve the two original Prompt 07 authority
defects: external prerequisites now outrank retained failed/interrupted work,
and unbound durable evidence is adoptable only during one bounded startup
window. The one-way authority relationship also remains intact in the current
production source:

```text
operation/environment evidence -> OnboardingJourneyCoordinator -> presentation
```

The repeated review nevertheless found one remaining concurrency BLOCKER.
Retry/Continue paths revalidate prerequisites inside mutation admission, but
then await `onboardingOperationControllerProvider.future` and call
`begin`/`resume` without rechecking the latest coherent prerequisite report.
An environment report arriving during that await updates `_latestReport` while
the active command deliberately prevents the visible Journey occurrence from
changing. The action-context check therefore still passes and destructive work
may start against newly blocked prerequisite truth.

The implementation is not yet safe to proceed to final validation.

## 1. Baseline/diff identity — NO ISSUE

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty
- Tracked delta: 46 modified files and two deleted files
- Intended new implementation/test files:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch: present outside the worktree and unapplied at
  `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`;
  21,137 bytes; SHA-256
  `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`

The tracked file inventory remains the Prompt 06 implementation plus Prompt 08
corrections. Prompt 08 introduced no unrelated tracked file. This review added
only this requested response.

## 2. Coordinator lifetime verdict — NO ISSUE

`OnboardingJourneyCoordinator` remains a generated keep-alive notifier. Its
`build` method installs listeners for environment reports, operation evidence,
and the archive-mutation lock; it uses `ref.read` for initial values, does not
derive Journey state through `ref.watch`, and never invalidates itself. Later
evidence is ingested into the same coordinator instance, so the original stale
Riverpod `ref` failure mode is not reintroduced.

## 3. Operation identity-chain verdict — NO ISSUE

The durable controller allocates one UUID in `begin`, persists it before
publication, and returns that exact ID. The coordinator binds the controller's
current snapshot, passes the same ID through executor/progress/verification,
and accepts later evidence only when occurrence, operation ID, kind, process
session, revision, legal status transition, stage/substage order, and progress
bounds agree.

Retry creates a new operation/UUID. Explicit continuation calls `resume` with
the exact interrupted UUID and updates the bound process session. UUID-less
admission/begin failures remain genuinely unbound.

## 4. Prerequisite-precedence verdict — NO ISSUE

The original Prompt 07 precedence BLOCKER is resolved for visible Journey
state.

- Initial reconstruction retains failed/interrupted evidence privately when a
  current FDA/Messages/history/Contacts blocker exists.
- Later environment ingestion publishes the typed prerequisite Episode ahead
  of a failed/interrupted binding.
- Compatible evidence can resurface the retained operation under a current
  occurrence; an earlier rendered action is then stale.
- Tests assert the actual typed Episodes for FDA, missing Messages, local
  history, and Contacts, and cover displacement plus resurfacing.

Thus the implemented visible priority is:

```text
current prerequisite blocker
        >
retained app-owned operation failure/interruption
```

This verdict does not cure the execution-time race reported in section 6.

## 5. Startup-only unbound-adoption verdict — NO ISSUE

The coordinator owns `_startupAdoptionOpen` plus separate initial report and
snapshot settlement flags. Unbound failed/interrupted evidence may be adopted
only while that bounded window is open; the window closes permanently once
both channels settle. After closure, unbound emissions are treated as durable
history and cannot invent a Journey occurrence.

The hostile-noise tests cover replay after terminal acknowledgement, replay of
operation A after operation B begins, legitimate one-time startup adoption,
and repeated startup evidence. No second provider/state-machine authority was
introduced.

## 6. Retry/Continue prerequisite-currentness verdict — BLOCKER

Occurrence/Episode/operation provenance is checked, and prerequisites are
checked before admission and once inside the admitted callback. The required
second check is not performed after the callback's next await and immediately
before operational mutation:

- First import awaits the controller at coordinator lines 987–989, then checks
  only command/action provenance at lines 990–992 before `begin` at line 993.
- Reimport awaits the controller at lines 1066–1068, then checks only
  command/action provenance at lines 1069–1071 before `begin` at line 1072.
- Continue Setup awaits the controller at lines 1196–1198, then checks
  command/action provenance and snapshot identity/status at lines 1199–1203,
  but not current prerequisites, before `resume` at line 1205.
- Automatic-recovery Retry reaches `_runAutomaticRecovery`; inside admission it
  has no coherent-report prerequisite check either before or after controller
  acquisition (lines 1650–1660).

This is exploitable within the coordinator's own intended behavior:
`_ingestEnvironmentReport` assigns `_latestReport` at line 157, but returns at
lines 160–163 when a command token is active. Consequently, a blocker arriving
while controller acquisition is pending does not change Journey occurrence or
its action context. `_commandAndActionAreCurrent` can still return true even
though `_latestReport` now says FDA, Messages, history, or Contacts is blocked.

The existing tests do not exercise this interval. They publish the blocker and
wait for the prerequisite Episode before invoking the stale action (coordinator
test lines 86–108 and 510–588). The fixture's controller provider resolves
immediately (lines 1015–1017), so no test holds controller acquisition open,
injects a prerequisite regression, and proves `begin`/`resume` remains
untouched.

The fix must revalidate the latest coherent prerequisite report after every
relevant await and immediately before `begin`/`resume`/automatic reset. A
completer-controlled test must cover Retry and Continue Setup in that exact
window.

## 7. UUID-less failure/action verdict — NO ISSUE

`OnboardingOperationFailed` carries coordinator-owned
`OnboardingJourneyFailureAction`, independently of the optional operation
projection. No UUID is fabricated.

- Initial-import admission/begin failure maps to `retryInitialImport`.
- Reimport admission/begin failure maps to `retryReimport`.
- Automatic recovery maps to `retryAutomaticRecovery`.
- Environment-only failure maps to truthful re-check behavior.
- Manual/nonrecoverable failure maps to no action.

Presentation derives copy and actions from that typed Journey intent. Focused
tests execute initial-import and reimport UUID-less retries and confirm the
intended command is run. Stale action-context validation remains present.

## 8. Semantic side-door verdict — NO ISSUE in current production source

Current production Onboarding and Environment Readiness presentation, the app
shell, and center-panel synchronization consume Journey state/projections.
Direct raw environment/graph evidence is confined to the explicitly bounded
development-only diagnostic panel. No current production presentation wrapper
publishes competing Journey semantics.

The architecture test's future-proofing limitation is reported separately as a
SHOULD FIX in sections 14 and 17.

## 9. Operation-projection verdict — NO ISSUE

`OnboardingJourneyOperationProjection` is immutable and data-only. It carries
the Journey-approved operation identity, phase, stage/substage, progress,
failure, and an unmodifiable action set; it has no persistence, process,
recovery, or mutation capability. Active/terminal operation Episodes require a
bound projection. Raw snapshots do not select presentation state.

Unknown/nonpositive totals are not converted to a false fraction; the
projection remains indeterminate.

## 10. Failure-order source verdict — NO ISSUE

`_publishFailureBeforeSideEffects` constructs and publishes the authoritative
Journey failure before attempting snapshot failure persistence, graph-failure
storage, logger acquisition/write, or environment invalidation. Each secondary
boundary is best effort and cannot replace the primary failure. A subsequently
current external prerequisite may correctly displace the visible failure while
retaining it privately.

The snapshot controller itself serializes persistence and only assigns/publishes
`_current` after the store save succeeds.

## 11. Failure-order test-proof verdict — NO ISSUE

The corrected tests observe live Journey state from callbacks inside each
secondary boundary, not merely after command completion. Separate cases cover:

- snapshot failure persistence;
- graph/import failure-store persistence;
- logger acquisition;
- logger write; and
- evidence refresh/invalidation.

Each callback sees the primary graph failure already published, then the
secondary boundary fails, and the primary failure remains authoritative.

## 12. Restart/reconciliation verdict — NO ISSUE

Prior-process running evidence is interrupted durably. Ordinary interrupted
user onboarding never auto-resumes: compatible exact safe-boundary evidence
produces an explicit Continue Setup Episode, incompatible prerequisites take
visible precedence, and inconsistent/nonresumable evidence becomes failure.
Completed unbound historical evidence does not replay terminal UI. Historical
completion reconciliation is diagnostic after durable readiness and cannot
become a second Journey authority.

## 13. Specialist-boundary verdict — NO ISSUE

The coordinator selects user-visible Journey meaning and orchestrates intent;
specialists retain their existing responsibilities for archive mutation
admission, import execution, graph construction, snapshot persistence, derived
reset, environment probes, failure diagnostics, and durable completion proof.
No archive, database schema, overlay, source-import ownership, or attachment
preservation boundary is widened by this delta.

## 14. Tripwire/test-quality verdict — SHOULD FIX

Behavioral tests are primarily principle-based: they assert typed Journey
outcomes, operation identity, hostile evidence rejection, one-shot startup
adoption, actual UUID-less commands, and mechanical failure ordering. The
missing execution-window test described in section 6 is part of the BLOCKER.

The new semantic census is materially better than the prior fixed consumer
list, but its guarantee remains incomplete:

- recursion proceeds only for dependencies under
  `lib/essentials/onboarding/` and
  `lib/features/environment_readiness/` (architecture test lines 50–53 and
  243–248); a semantic wrapper placed in another local package area is recorded
  but not traversed to its raw dependency;
- traversal stops at the provider barrel and several action providers (lines
  41–49) without mechanically asserting that those boundaries remain
  intent-only.

Therefore a future wrapper/read-model outside the two prefixes, or semantic
state added behind an allowlisted action boundary, could consume raw evidence
without the claimed transitive failure. Current source has no such side door,
so this is a SHOULD FIX tripwire gap rather than a present authority BLOCKER.

## 15. Deletion/compatibility/diff-shape verdict — NO ISSUE

The obsolete reconciliation provider and its generated sibling are deleted,
and no remaining reference requires them. Compatibility gate/action seams now
project or forward Journey-owned state rather than becoming authorities.
Generated provider changes match the annotation/signature delta reported by
the clean analyzer run.

The 48-file tracked diff plus the two intended new files contains the planned
coordinator, evidence, projection, presentation, compatibility, tests, and
generated updates. No unrelated tracked formatting/refactor, archive mover,
attachment archive, database schema, real-data path, or safety-boundary change
is mixed in. No temporary Prompt 08 authority machinery or contradictory
production comment was found.

## 16. Concrete BLOCKER findings

### BLOCKER 1 — Prerequisites can regress after the admitted check and before execution

- **Affected paths:** initial import/Retry, reimport/Retry, Continue Setup, and
  automatic-recovery Retry.
- **Cause:** controller acquisition is awaited after prerequisite validation;
  environment ingestion updates `_latestReport` but suppresses Journey
  replacement while the command token is active; the post-await guard checks
  only the still-current action context (plus snapshot identity for Continue).
- **Impact:** `begin`, `resume`, or automatic derived-data reset can start after
  FDA/Messages/history/Contacts became blocked.
- **Required correction:** use one coordinator-owned helper to validate the
  latest coherent report for the intended command both inside admission and
  immediately before operational mutation, then add deterministic held-await
  tests for Retry and Continue Setup. The stale action must become a no-op or
  publish the current typed prerequisite Episode without beginning/resuming.

## 17. Concrete SHOULD FIX findings

### SHOULD FIX 1 — Semantic dependency census has traversal/allowlist blind spots

Extend the census so all relevant local dependency chains are traversed until
an explicitly verified authority/diagnostic boundary. If action adapters remain
stop boundaries, mechanically assert that they are intent-only and cannot
publish/read Journey-semantic evidence. This makes the “future wrapper” claim a
property of the test rather than a convention about file placement.

## 18. OPTIONAL findings

- `onboardingJourneyAllowsCommandedTransition` remains unused as explicitly
  permitted by Prompt 09; it causes no current architecture defect.
- The deferred documentation tranche should correct the stale paragraph in
  canonical `20-environment-readiness.md` saying the environment report carries
  and presentation renders the persisted operation snapshot. Current source
  correctly separates report evidence from Journey-owned operation projection,
  but that paragraph no longer describes it accurately.

## 19. Narrow tests rerun

None. Source inspection conclusively establishes the post-controller-await
currentness gap, and the fixture/test inspection conclusively shows that the
window is not covered. Prompt 09 directed that the full suite not be rerun; the
reported Prompt 08 results remain 295 scoped tests passed, 493 architecture
tests passed, analyzer clean, and `git diff --check` passed. Those successful
results do not exercise the identified race.

## 20. Exact Git status

At review completion before adding this response:

- branch/HEAD: `fix/onboarding-import-stuck-state` /
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- index: empty;
- tracked worktree: 46 modified and two deleted files;
- intended new implementation/test files: untracked;
- all known unrelated prompts, responses, `00-PREPARATION`, and
  `.vscode/settings.json`: untouched and untracked;
- shared-instructions submodule: clean and unchanged;
- parked patch: unchanged and unapplied;
- staging/commit/push/merge: none.

This response is the only new file created by Prompt 09 and remains untracked
inside the already-untracked `01-ONBOARDING/responses/` tree. No implementation,
test, generated, canonical documentation, archive, database, or application
state was modified.

## 21. Final architectural recommendation

Do not proceed to final validation or checkpoint. Correct BLOCKER 1 with
post-await/immediate-pre-mutation prerequisite checks and deterministic race
tests, then repeat the focused architectural review. The semantic-census
SHOULD FIX should be closed in the same correction so the review can rely on
its future-wrapper guarantee.

REPEATED HUMAN ARCHITECTURAL REVIEW: FAIL
