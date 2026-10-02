# MessageLens Feature 34
## Response 32 — Correct Advanced Start Fresh Currentness and Reset UX

## Executive result

The bounded correction is complete and remains unstaged for review.

Advanced Start Fresh no longer treats the terminal startup classification as
current reset eligibility. Every request now performs a fresh, read-only
bounded evidence read and applies the existing canonical
`MessageLensInstallationStateClassifier`. A current `completed` result reaches
authorization once. A legitimate ineligible result or current-state read
failure becomes typed, visible Advanced Start Fresh presentation rather than an
uncaught `PlatformDispatcher` error.

The Settings top menu now receives an explicit presentation fact describing
whether an unselected inline menu should expand. An active ephemeral Settings
projection makes that fact false, so selecting `Reset message data…` once
dispatches once, shows the reset panel, and leaves the menu closed even if its
widget is remounted.

No Start Fresh destructive semantics, Journey authority, Feature 35 authority,
schema, persistence, archive, favourites, Contacts, import, or release metadata
changed.

---

## 1. Baseline verification

The required baseline passed before editing:

- worktree:
  `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- tracked worktree: clean;
- index: empty;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- untracked leaf paths: 50 known paths, including Prompt 32 and the earlier
  qualification records.

A fresh external baseline manifest was created before editing:

`/private/tmp/messagelens-prompt32-baseline.Dms3zl`

- lines: 5,696;
- SHA-256:
  `19bd25065c8d543eb86fb5f55bbd6e4fdae5a0da84cea5affc4246617105a96b`.

The canonical clean-slate records, Responses 30 and 31, onboarding/archive
invariants, Advanced Start Fresh implementation, current installation
classifier, Settings transient projection path, and existing tests were read
before editing.

## 2. Exact stale-classification source trace

The confirmed pre-correction path was:

```text
SettingsActionListActions.selectActionCallback
-> SidebarActionDispatcher.dispatch(ResetMessageDataRequested)
-> advancedStartFreshActionProvider
-> AdvancedStartFreshActionImpl.request
-> authorization/presentation
-> StartFreshService
```

The stale boundary was entirely in
`advanced_start_fresh_action_provider.dart`:

1. the keep-alive provider listened to
   `messageLensInstallationStateProvider`;
2. it retained the first terminal `StartupInstallationValidationState` in a
   local field/completer;
3. the action's `readInstallationState` callback returned that retained startup
   result on every later request;
4. startup had classified the old operation as `resumable`;
5. the subsequent successful import changed durable evidence to `completed`,
   but did not replace the captured startup value;
6. `AdvancedStartFreshActionImpl.request()` threw before authorization and
   before its `_execute` failure/presentation boundary.

The startup stream remains valid and unchanged for startup routing. It is no
longer an Advanced Start Fresh eligibility dependency.

## 3. Selected current-classification mechanism

A narrow internal seam was added:

`AdvancedStartFreshCurrentStateReader`

Its production implementation,
`BoundedAdvancedStartFreshCurrentStateReader`, performs this operation on every
call:

```text
current admitted ArchiveAccessAuthority.rootPath
-> SqliteMessageLensInstallationEvidenceReader.readBounded
-> MessageLensInstallationStateClassifier.classify
-> current MessageLensInstallationState
```

This is read-only current durable evidence. It reuses the existing evidence
reader and the existing singular classifier; it adds no second policy or
classification authority. The keep-alive action may retain the reader object,
but the reader retains no classification result and performs a new bounded
read for each invocation.

`StartFreshService` still performs its existing full validation at the mutation
boundary. Startup validation, invocation-time bounded classification, and
mutation-boundary full validation therefore remain distinct.

## 4. Advanced Start Fresh currentness correction

`advancedStartFreshActionProvider` now watches only the scoped current-state
reader for eligibility and injects `readCurrentState` into the action. It no
longer imports, listens to, invalidates, or caches
`messageLensInstallationStateProvider`.

At each request:

1. current durable evidence is read and classified;
2. only current `completed` proceeds to authorization;
3. authorization occurs once;
4. accepted authorization begins the existing presentation occurrence once;
5. the existing service and advanced-reset entry point execute unchanged.

## 5. Visible ineligibility and failure handling

Two typed presentation failure kinds were added:

- `installationIneligible`;
- `installationStateUnavailable`.

A legitimate current non-completed state now produces an immediate visible
failure occurrence with human-readable state-specific copy, no retry button,
no authorization, and no mutation. A current-evidence read failure is logged
and produces visible unavailable-state feedback with the explicit guarantee
that no data changed.

Authorization-presentation setup failure is also contained in the same visible
failure mechanism. None of these ordinary pre-mutation failures escapes to
`PlatformDispatcher`.

The overlay title for these two typed cases is now:

`Reset Message Data is unavailable`

Post-authorization execution failures retain the existing
`MessageLens couldn't start fresh` presentation and retry behavior.

## 6. Startup-resumable to current-completed regression

The provider/widget regression establishes the exact observed sequence:

```text
startup provider resolves resumable
-> current-state reader initially represents resumable evidence
-> durable current state changes to completed
-> user invokes Advanced Start Fresh
-> action calls current-state reader once
-> authorization appears once
-> accepted authorization starts service once
```

Assertions prove:

- the startup provider was read once and remained `resumable`;
- the current reader was not consulted while startup resolved;
- the current reader was consulted once at invocation;
- the authorization dialog was singular;
- the operation presentation became visible before service execution;
- the service received exactly one
  `completedInstallationAdvancedReset` entry point.

The concrete reader also has a deterministic sequence test proving that two
calls classify two fresh evidence samples (`resumable`, then `completed`) from
the same admitted root rather than returning a cached classification.

## 7. Other currentness regressions

Added coverage proves:

- startup `resumable` plus current `resumable` presents typed ineligibility,
  requests no authorization, performs no mutation, and throws no widget/error
  exception;
- startup `completed` plus current `abandoned` treats the current state as
  authoritative and performs no mutation;
- current-state reader failure becomes typed visible feedback;
- post-authorization reset and virgin-verification failures preserve their
  previous typed behavior;
- stale async operation completion still cannot replace a newer presentation
  occurrence.

## 8. Exactly-once action result

PASS.

One eligible request performs one current classification, one authorization
request, one presentation occurrence, and at most one service start. One
ineligible request performs one current classification and zero authorization
or service starts. The menu regression independently proves one row selection
dispatches once.

## 9. Settings transient-menu root cause

The inline Settings menu previously derived openness solely from:

```text
persistentContextActionId == null
```

Transient actions intentionally clear persistent Settings context. The
dispatcher then replaces the stable menu cassette and installs an ephemeral
reset-panel projection. A rebuild/remount therefore saw a null persistent
selection and initialized/forced the menu open even though the selection
handler had just closed it.

The first selection did dispatch correctly; the menu's rebuilt presentation
made it appear that a second selection was required.

## 10. Settings menu closure correction

The existing stable/ephemeral projection model now supplies the missing fact:

```text
active ephemeral Settings projection
-> SettingsTopMenuCassettePayload.expandInlineMenuWhenUnselected = false
```

With no ephemeral projection, the unselected inline Settings root retains its
normal expanded presentation. With an ephemeral projection, the menu
initializes and remains closed even though no persistent selection exists.

The widget still closes synchronously before dispatch. There is no delay,
post-frame close, timer, or other timing workaround.

## 11. Menu regression tests

Focused coverage proves:

- unselected Settings root still begins expanded;
- one `Reset message data…` selection dispatches exactly once;
- the menu closes immediately;
- a simulated projection-driven widget remount with no persistent selection
  remains closed;
- an active ephemeral projection resolves the menu payload with expansion
  disabled;
- persistent Environment/Historical Archives navigation still opens, selects
  once, and closes normally.

## 12. Start Fresh destructive-scope non-change

No Start Fresh service, reset service, file-store, database allow-list,
operation/failure persistence, Presence maintenance, or archive code changed.

The existing service regression suite still proves that Start Fresh:

- runs under the existing mutation authority;
- permits the advanced entry point only for a completed installation;
- resets only enumerated rebuildable message data;
- verifies virgin state;
- releases authority on failure;
- fails closed when post-reset full verification does not establish virgin
  state.

`user_overlays.db`, favourites, archive configuration/identity, and attachment
archives remain outside reset scope.

## 13. Journey and Feature 35 non-change

No Journey coordinator, Journey state, command predicate, operation snapshot,
restart reconciliation, Environment evidence, Feature 35 tenure/capability, or
archive mutation policy source changed.

Journey remains the sole semantic Onboarding authority. The new reader answers
only the Advanced Start Fresh action's invocation-time eligibility question.

## 14. Exact changed-file census

### Modified production/generated files — 13

1. `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`
2. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`
3. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.g.dart`
4. `lib/essentials/onboarding/domain/advanced_start_fresh_presentation.dart`
5. `lib/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart`
6. `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`
7. `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.g.dart`
8. `lib/features/sidebar_utilities/application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
9. `lib/features/sidebar_utilities/application/sidebar_cassette_spec/coordinators/cassette_coordinator.g.dart`
10. `lib/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart`
11. `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.dart`
12. `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.g.dart`
13. `lib/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart`

### New production/generated files — 2

14. `lib/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider.dart`
15. `lib/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider.g.dart`

### Modified tests — 8

16. `test/architecture/forbidden_imports_test.dart`
17. `test/architecture/onboarding_start_fresh_architecture_test.dart`
18. `test/essentials/onboarding/application/advanced_start_fresh_action_provider_test.dart`
19. `test/essentials/onboarding/application/advanced_start_fresh_action_test.dart`
20. `test/essentials/onboarding/presentation/advanced_start_fresh_overlay_test.dart`
21. `test/essentials/sidebar/application/cassette_widget_coordinator_provider_test.dart`
22. `test/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver_test.dart`
23. `test/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget_test.dart`

### New test — 1

24. `test/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider_test.dart`

### New response — 1

25. this Response 32.

No other file changed.

## 15. Focused test results

All focused validation passed:

- Advanced Start Fresh action/provider/current-reader/overlay: **18 passed**;
- Start Fresh service regressions: **5 passed**;
- Settings menu/resolver/cassette coordinator: **25 passed**;
- targeted Start Fresh architecture test: **8 passed**.

## 16. Complete architecture result

**PASS — 555 passed, 0 failed.**

The first complete architecture run correctly stopped on the authority-consumer
inventory because the new reader consumes `ArchiveAccessAuthority`. The new
read-only consumer was added to that existing explicit inventory. The complete
suite then passed 555/555.

## 17. Analyzer result

`flutter analyze`: **PASS — no issues found**.

The final run completed in 5.2 seconds after final generation.

## 18. Full Flutter-suite result

`flutter test --reporter expanded`:

**PASS — 2,752 passed, 1 existing skip, 0 failed.**

The skip remains the existing synthetic archive-import memory workload that is
run through its dedicated harness.

## 19. Diff, format, and generated hygiene

- `git diff --check`: PASS;
- index: empty;
- `dart format --output=none --set-exit-if-changed` over all 24 Dart
  implementation/generated/test files: PASS, 0 changed;
- `build_runner build --delete-conflicting-outputs`: PASS;
- intended Riverpod generated files were regenerated, including the new
  current-reader provider and the changed provider hashes;
- the generator also proposed three unrelated, pre-existing hash-only updates
  outside Prompt 32. Those baseline files were restored byte-for-byte so the
  bounded diff does not absorb unrelated generator-version drift;
- no hand-written generated-file edit remains;
- no release metadata change was made or required for this bounded correction;
- no file was staged, committed, or pushed.

## 20. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

- startup classification and invocation-time classification remain distinct:
  PASS;
- Advanced Start Fresh uses current durable classification: PASS;
- ineligibility is visible and typed: PASS;
- no ordinary currentness failure escapes to `PlatformDispatcher`: PASS;
- exactly-once authorization/presentation: PASS;
- transient Settings action closes in one selection: PASS;
- persistent Settings navigation unaffected: PASS;
- Start Fresh destructive scope unchanged: PASS;
- overlays/favourites preserved by reset semantics: PASS;
- Journey/Feature 35 authority unchanged: PASS;
- schema/persistence drift: none;
- unrelated feature changes: none.

## 21. BLOCKER findings

**BLOCKER: 0**

## 22. SHOULD FIX findings

**SHOULD FIX: 0**

The excluded favourites, Contacts/Scrollbar, and rich-text performance topics
remain separate work and were not evaluated or changed here.

## 23. Preservation and baseline comparison

At completion:

- branch and HEAD are unchanged;
- the Git index manifest SHA-256 is still
  `2486da76f3b7ee62452fdc50b29e59ea0811f07619a7722bb731a26006c93f9f`,
  exactly matching the manifest captured before editing;
- none of the 50 baseline untracked leaf paths was removed;
- the only pre-response untracked additions are the two new current-reader
  source/generated files and its new test;
- shared instructions remain clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- no real database or archive was opened or modified;
- no GUI application was launched;
- no production resource was accessed;
- no archive payload was traversed;
- no favourite or user intent was read or changed.

## 24. Exact Git status

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- tracked modifications: the 21 modified files enumerated in section 14;
- intended new untracked implementation/test files: 3;
- intended new untracked Response 32: 1;
- preserved baseline untracked leaf paths: 50;
- total untracked leaf paths after this response: 54;
- shared submodule: clean and unchanged;
- all Prompt 32 implementation changes remain unstaged.

## 25. Readiness for bounded human review

The source correction and automated validation are complete. The next step may
be the explicitly bounded human reset review using the correct freshly built
development application. This response does not authorize a launch, reset,
qualification run, stage, commit, or push.

ADVANCED START FRESH CURRENTNESS DEFECT CORRECTED: YES

RESET MESSAGE DATA ONE-CLICK UX CORRECTED: YES

READY FOR BOUNDED HUMAN RESET REVIEW BEFORE CHECKPOINT: YES
