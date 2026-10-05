# MessageLens Feature 34
## Response 60 — Attachment Coverage Checkpoint and Operating-Owned Live Currentness

Date: 2026-10-04

Prompt 59 is checkpointed and pushed as a recovery anchor. Operating Session
Stage Two is implemented and fully validated, but remains entirely unstaged for
human qualification. The development artifact was built and inspected without
being launched. No real MessageLens database, source, archive, archive
configuration, or attachment payload was accessed or modified.

## 1. Baseline verification

The fresh external baseline manifest is:

`/private/tmp/messagelens-prompt60-baseline-20261004.md`

It records the required pre-checkpoint state:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`;
- ahead/behind: `0/0`;
- index: empty;
- Prompt 59 present and unstaged;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- tracked Prompt 59 modifications: 23 files;
- new Prompt 59 implementation/test files: 2;
- tracked binary-diff SHA-256:
  `a2021911583ed832e06829eecd412b1a4f68dabc45edde9387590d935c006a3d`;
- complete porcelain SHA-256:
  `7054e8fe8e5592ac8df97ab7c7bc2d6b63d3e34811fa0440921777995a9e733e`;
- both diff checks: pass.

The human's last explicit app state was `quit`; Prompt 60 did not launch the
app.

## 2. Executable-disposition source audit

The audit traced `AppCzarStartupHarness`, every production
`shouldExecuteAppCzar...` predicate, all three execution packages, Operating
admission, and the architecture census.

The development host has exactly these execution branches:

1. `AppCzarDataUpdateController` / `AppCzarDataUpdateScreen`;
2. `AppCzarSourceAccessController` / `AppCzarSourceAccessScreen`;
3. `AppCzarOperatingSessionController` / `AppCzarOperatingSessionApp`.

There are exactly three production execution predicates:

- `shouldExecuteAppCzarDataUpdate`;
- `shouldExecuteAppCzarSourceAccessRepair`;
- `shouldExecuteAppCzarOperatingSession`.

There is no Onboarding, Attachment Repair, Local Data Repair, or Diagnostic
Review execution predicate, host branch, constructor seam, enum dispatcher, or
generic `execute(coordinator)` path.

## 3. Resolution of the Response 59 Section 30 discrepancy

The source confirmed the prior qualified architecture: Onboarding remains
virtual and Operating Session is the admitted executable session. The original
Response 59 wording was a documentation census error, not a source change.

Before the documentation checkpoint, Response 59 Section 30 was corrected to
name Data Update, Source Access Repair, and Operating Session. No production
source was changed to fit the report.

## 4. Exact Prompt 59 diff inventory

The attachment-coverage implementation checkpoint contains 25 files:

1. observation/domain and fact-DAG integration in AppCzar models, evaluator,
   and presentation projection;
2. the new read-only coverage probe plus the existing outer archive probe;
3. exact Operating admission requiring complete authentic coverage;
4. archive settings/store composition needed by the probe;
5. 14 focused, regression, and architecture test files;
6. the intended `archive_settings_provider.g.dart` generation change;
7. `pubspec.yaml` and `CHANGELOG.md` release metadata.

The documentation checkpoint contains exactly five records: Prompts 58–60 and
Responses 58–59. Known `.vscode`, Feature 26, Feature 30, Feature 31, and
Feature 34 `00-PREPARATION` untracked material was excluded and untouched.

## 5. Prompt 59 validation results

The exact Prompt 59 staged tree passed:

- attachment-coverage probe: **10/10**;
- impacted AppCzar/Data Update/Operating/Source Access matrix: **205/205**;
- complete architecture suite: **576/576**;
- analyzer: **No issues found**;
- formatting: 30 Dart files, 0 changes;
- build generation: successful and limited to the intended generated change;
- both staged and unstaged diff checks: pass;
- debug development build: success without launch.

The first complete-suite run exposed one timing-sensitive failure at
`attachment_resolver_provider_test.dart:201`. It was investigated rather than
ignored; the complete deterministic suite was rerun from the beginning and
passed **2,872 tests plus 1 intentional skip, 0 failures**. This chronology is
preserved here rather than reporting only the successful rerun.

## 6. Attachment-coverage implementation checkpoint

Created:

`ae337b872b59092999017af017bdbbf148e89b90`

Subject:

`feat(startup): add reconstructible attachment coverage`

## 7. Documentation checkpoint

Created:

`ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`

Subject:

`docs(feature-34): record attachment coverage qualification`

## 8. Remote recovery-anchor commit

The branch was pushed normally. The remote recovery anchor is:

`origin/fix/onboarding-import-stuck-state` at
`ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`.

No force push, rebase, merge, or PR merge occurred.

## 9. Branch/upstream state before Stage Two edits

Immediately before Stage Two editing:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- upstream: `origin/fix/onboarding-import-stuck-state` at the same commit;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared submodule: clean at the required commit;
- only the 44 known unrelated physical untracked files remained.

## 10. Old monitor non-reuse proof

The Operating package contains no `ChatDbChangeMonitor` or
`chatDbChangeMonitorProvider` reference. Its legacy provider file is unchanged,
and the neutral Operating workspace does not mount an owner of that monitor.

The old monitor remains only on the unchanged legacy production route and its
existing diagnostic/status consumers. Stage Two did not edit `lib/main.dart`,
the production shell, or the legacy monitor.

## 11. Operating currentness service architecture

One subordinate Operating service now follows this one-way path:

```text
Operating status host
-> occurrence-bound currentness controller
-> read-only fenced observer
-> pure currentness classifier
-> occurrence-bound live-update executor, only when source-ahead
-> existing LiveGraphUpdateWorker
```

It is internal to Operating. It is not an `AppCzarVirtualCoordinator`, does not
instantiate the full evaluator as a mini-Czar, and imports no Journey or
Environment Readiness authority.

The observer fences each material read with the message-data generation,
archive location generation/path/readability/write eligibility, and archive
mutation revision. An active mutation or changed before/after fence is
transient evidence, not an authorization to act.

## 12. Occurrence/generation lifetime

`AppCzarOperatingSessionOccurrence` binds:

- a unique process-local sequence;
- the exact assessment generation;
- admitted archive scope identity;
- admitted archive probe generation;
- admitted resolved archive path.

The service starts only after the admitted Operating shell has painted. A
generation replacement or same-generation admission loss retains the exact old
shell in `draining` while its service settles; only then may a new occurrence
be admitted. Epoch and occurrence checks prevent an old callback from
publishing or mutating a replacement occurrence.

## 13. `stopAndDrain()` implementation

`stopAndDrain()` synchronously:

1. suppresses new observation/update admission;
2. cancels the next one-shot timer;
3. advances the publication epoch;
4. publishes the bounded stopped state where the provider is still live;
5. returns the exact active-flight future.

That future includes observation, mutation admission, worker completion,
attachment preservation, capability/Ball release, and completion cleanup.
Assessment replacement uses the explicit session `draining` phase. Normal
macOS exit awaits the exact occurrence drain before returning
`AppExitResponse.exit`. An issue-triggered process restart drains directly
before calling the existing restarter.

## 14. Observation cadence

The production cadence is an injectable exact **15 seconds**. The first read is
started only after shell admission; every later read uses a rescheduled
one-shot `Timer` created only after the previous flight completes. There is no
`Timer.periodic`, overlap, hidden queue, or post-stop scheduling.

## 15. No-change behavior

Conclusive equality of source/local count and high-water remains silent and
idle. It starts no executor, Ball, worker, progress surface, or semantic state,
and does not bump `messageDataVersionProvider`. The next bounded observation is
scheduled normally.

## 16. Source-ahead behavior

Ordinary source-ahead requires:

- coherent before/after fences;
- a readable, stable source sample;
- healthy, mutually coherent import and graph evidence;
- monotonic source count/high-water ahead of the local live ledger;
- the exact admitted archive scope/generations/path;
- fresh complete and write-eligible pre-update coverage.

Only then does the service start one internal update occurrence. It never calls
`AppCzarDataUpdateController`.

## 17. Single-flight behavior

The controller stores `_activeFlight` before the first asynchronous dispatch.
Ticks while it is non-null are rejected and do not queue work. The next timer
is armed only in the admitted flight's completion path. Tests cover manual
duplicate ticks, timer ticks, mutation flight overlap, and stale completion.

## 18. Mutation-tenure path

The only mutation path is:

```text
Operating occurrence
-> AppCzarOperatingLiveUpdateExecutor
-> ArchiveMutationCoordinator.runWithCapability(liveGraphUpdate)
-> one ExclusiveAuthority Ball
-> LiveGraphUpdateWorker
-> capability/Ball release
```

The executor revalidates the exact occurrence and current fenced precondition
before Ball admission and again inside the capability callback. The capability
never escapes that callback. Observation acquires no Ball.

## 19. Post-worker attachment-coverage verification

Fresh complete coverage is checked before mutation. After the worker returns
and the Ball has released, the controller performs a new fenced archive and
coverage read against the now-current graph.

Only coherent evidence with the same archive scope, probe generation, location
generation/path, and coverage condition `complete` may return the service to
idle. FALSE publishes `coverageIncomplete`; UNKNOWN publishes
`coverageUnknown`. Neither is called successful, and neither invokes repair
in-process.

## 20. Interim message-data generation semantics

The existing worker may bump `messageDataVersionProvider` after graph build and
before attachment preservation completes. Stage Two does not conceal this.
During that interval the live occurrence remains factually `updating`,
`preservingAttachments`, or `verifyingCoverage`; it never publishes `Current`
or operation success. Graph-backed consumers may refresh while the status
continues to withhold a completed-currentness claim until post-update coverage
is TRUE.

## 21. Success semantics

Post-update coverage TRUE clears the transient status to silent idle and arms
the next observation. The process, Operating occurrence, router, provider
container, and workspace remain the same. Success does not restart, call
AppCzar, or reapply fresh-entry neutralization.

## 22. Progress presentation

One compact, non-blocking Operating center overlay reports only real worker
evidence:

- `Updating MessageLens…` or actual `N / M` graph progress;
- actual graph suboperation wording;
- `Preserving attachments…`;
- `Verifying attachment coverage…` with real examined/preserved/skipped/failed
  counts when available;
- `Update could not be completed` with the bounded factual issue;
- `Restarting MessageLens…` only after the issue-bearing frame.

No-change checks are invisible. The ordinary workspace is never replaced.

## 23. Navigation preservation

The successful-update regression captures a selected contact, conversation,
anchor message, search query, center `ViewSpec`, and right-panel `ViewSpec`,
runs the source-ahead worker plus coverage-TRUE path, and proves exact state
equality afterward. No restart occurs and the same occurrence remains active.

## 24. Display-identity behavior

The Stage One display-identity generation dependency remains intact. The
existing graph worker bumps the established message-data generation; Stage Two
adds an explicit worker regression asserting a successful graph build advances
that generation exactly once. The retained resolver therefore rebuilds from
the new graph automatically, with no navigation click, shell re-entry, or
fallback-cache override.

## 25. Source access FALSE behavior

A conclusively denied/unavailable source becomes a distinct
`sourceUnreadable` issue. Scheduling stops, the issue is allowed to paint,
the exact occurrence drains, and the existing real process restarter is
called. Only the fresh AppCzar process may then select Source Access Repair.

## 26. Source UNKNOWN behavior

UNKNOWN remains `sourceUnknown`; the copy does not claim denial or Full Disk
Access state. It follows the same issue-frame, drain, and restart boundary, and
fresh AppCzar may select Diagnostic Review. It never invokes Source Access
Repair in-process.

## 27. Archive identity/generation behavior

Scope identity, probe generation, resolved path, and live location generation
are checked during initial binding, every fenced currentness read, fresh
precoverage, Ball admission, and fresh postcoverage. A positive mismatch is
`archiveChanged`; incomplete binding is UNKNOWN. Stale authority cannot start
or continue a new mutation.

## 28. Archive unavailable behavior

Unavailable archive evidence, unreadable location, lost write eligibility, or
a freshly read-only root fails closed without mutation. The service records a
distinct archive issue, stops scheduling, presents it, drains, and requests a
fresh-process reassessment. It does not invoke Attachment Archive Repair.

## 29. Graph/local contradiction behavior

Incomplete/incoherent local stores, a source behind either local boundary, or
a worker prerequisite that no longer matches become a bounded
`localDatasetContradiction`. Operating neither repairs nor onboards in-process;
it drains and restarts for fresh AppCzar classification.

## 30. Proof no top-level coordinator chaining exists

The Operating implementation imports neither the Data Update controller nor
the Source Access Repair controller. It has no virtual-coordinator switch,
generic dispatcher, or coordinator constructor. Its only cross-process action
is the already-qualified restarter, called after drain. The fresh process owns
the next top-level classification.

## 31. Exact top-level disposition classification after Stage Two

| Disposition | Category |
| --- | --- |
| Data Update | EXECUTABLE TOP-LEVEL COORDINATOR |
| Source Access Repair | EXECUTABLE TOP-LEVEL COORDINATOR |
| Operating Session | EXECUTABLE ADMITTED SESSION |
| Onboarding | VIRTUAL ONLY |
| Attachment Archive Repair | VIRTUAL ONLY |
| Local Data Repair | VIRTUAL ONLY |
| Diagnostic Review | VIRTUAL ONLY |

The internal currentness service is not an AppCzar disposition. The categorical
architecture census covers all seven enum values and separately asserts two
top-level coordinators, one admitted session, and exactly three predicates.

## 32. Focused Stage Two tests

Complete `test/essentials/app_czar_operating_session`: **47/47 passed**.

This includes classifier taxonomy, fenced observation, exact admission,
cadence, no-change, source-ahead, duplicate-tick rejection, one-Ball execution,
fresh pre/post coverage, FALSE/UNKNOWN distinctions, archive changes,
contradictions, progress/status presentation, and issue-before-restart behavior.

## 33. Drain/lifecycle tests

The same **47/47** Operating matrix directly proves:

- synchronous stop plus admitted-observation drain;
- admitted update-flight drain;
- real production executor/worker Ball release before drain completes;
- stale completion cannot publish;
- replacement keeps the old shell until exact drain;
- same-generation admission loss drains before shell release;
- macOS exit permission waits for the exact occurrence.

## 34. Worker/coverage/mutation regressions

The focused LiveGraphUpdateWorker, coverage probe, archive mutation
coordinator, attachment mutation authority, ExclusiveAuthority registry, and
ExclusiveAuthority architecture matrix passed **105/105**.

Prompt 59 coverage regressions are included, and the complete suite also
retains every worker, archive, attachment resolver, and tenure test.

## 35. Stage One regression result

The focused startup harness plus Operating session controller/application
matrix passed **13/13**. Neutral entry, one top-level router, exact visual
admission, and the fresh-entry boundary remain intact.

## 36. Data Update regression result

Complete `test/essentials/app_czar_data_update`: **11/11 passed**. Startup Data
Update retains its own exact mutation/restart contract and is never invoked by
Operating currentness.

## 37. Source Access Repair regression result

Complete `test/essentials/app_czar_source_access`: **7/7 passed**. FALSE and
UNKNOWN remain distinct, settings navigation remains non-semantic, and no
Operating in-process handoff was introduced.

## 38. Architecture result

- focused `app_czar_architecture_test.dart`: **23/23 passed**;
- complete `test/architecture`: **579/579 passed**.

The first complete architecture run correctly detected four new lifecycle
owners missing from the explicit inventories: the currentness monitor's
`catchError`/`unawaited`/`Timer`, the session controller's drain future, and the
status host's post-frame/restart future. Each call site was independently
audited as the exact monitor/session/presentation lifecycle boundary. Narrow
file entries with explanatory comments were added; no scanner or policy was
weakened. The complete rerun passed.

## 39. Analyzer result

`flutter analyze`: **No issues found**.

## 40. Full Flutter-suite result

Complete deterministic Flutter suite:

**2,915 passed, 1 intentional qualification-harness skip, 0 failed**.

## 41. Diff, format, and generated hygiene

Stage Two before this response comprises exactly 32 files:

- 12 hand-authored production files;
- 4 Riverpod generated files;
- 14 test/architecture files;
- `pubspec.yaml` and `CHANGELOG.md`.

This response is the 33rd intended Stage Two path. Additional hygiene:

- exact Dart format check: 30 files, 0 changes;
- final build_runner: success; only 2 already-derived outputs were written and
  Git status gained no unexpected path;
- `git diff --check`: pass;
- `git diff --cached --check`: pass;
- index: empty;
- all Stage Two work: unstaged.

## 42. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

The implementation was reviewed against the global guardrails, project README,
Dart/Flutter/Riverpod rules, database boundaries, attachment-preservation
invariant, ExclusiveAuthority tenure contract, Feature 34 Project Conformance
standard, and every Prompt 60 stop gate.

Operating remains the sole long-lived jurisdiction. The service is internal and
occurrence-bound; observation holds no Ball; mutation holds one Ball; shutdown
awaits its release; post-update coverage TRUE is mandatory; no historical
failure/status flag exists; navigation and generation-current identity are
preserved; and production startup is unchanged.

## 43. BLOCKER findings

`BLOCKER: 0`

No Prompt 60 stop gate was encountered.

## 44. SHOULD FIX findings

`SHOULD FIX: 0`

No deferred correctness, lifecycle, architecture, testing, documentation, or
scope finding remains.

## 45. Exact Stage Two build identity, path, and hashes

Debug development build: succeeded without launching.

- bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- product: `MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- version/build: `0.2.135 (153)`;
- executable SHA-256:
  `47f2358cd6dbe4aab1581e95ed466a4dac1c13b51dca73a4a3abd072f8ca12a6`;
- `App.framework` executable SHA-256:
  `ab1a92c090ff168f736ab0e9dde17979449fecff2630f971fc2fe259e0ad1c12`.

The build emitted the existing Xcode empty-device-build-number diagnostic and
`volume_controller` PrivacyInfo processing warning; neither failed the build.
No app was launched.

## 46. Exact final Git/worktree/index/submodule state

- branch: `fix/onboarding-import-stuck-state`;
- HEAD:
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- upstream: `origin/fix/onboarding-import-stuck-state` at the same commit;
- ahead/behind: `0/0`;
- index: empty;
- tracked Stage Two modifications: 18 files, all unstaged;
- new Stage Two production/generated/test/response files: 15, all untracked;
- total physical untracked files: 59;
- known unrelated physical untracked files: 44, untouched;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.

No Stage Two staging, commit, push, merge, or rebase occurred. Neither a real
archive nor a real MessageLens/source database was accessed or modified.

## 47. Readiness for human live-currentness qualification

The exact development artifact is ready for the later bounded human experiment.
That experiment should direct-launch with the admitted development-root
environment, reach Operating, retain a selected conversation while a new
message arrives, verify same-PID live update and identity refresh, optionally
exercise an attachment-bearing message, and separately qualify source-access
loss and the drained real restart.

Prompt 60 intentionally stops before that experiment. The build has not been
launched.

ATTACHMENT COVERAGE MILESTONE CHECKPOINTED: YES

RESPONSE 59 EXECUTABLE-DISPOSITION CENSUS RECONCILED: YES

OPERATING-OWNED LIVE CURRENTNESS IMPLEMENTED: YES

OPERATING SHUTDOWN DRAINS ACTIVE MUTATION TENURE: YES

POST-UPDATE COVERAGE TRUE IS REQUIRED FOR LIVE-UPDATE SUCCESS: YES

SUCCESSFUL LIVE UPDATE PRESERVES SAME-SESSION NAVIGATION: YES

READY FOR HUMAN OPERATING LIVE-CURRENTNESS QUALIFICATION: YES
