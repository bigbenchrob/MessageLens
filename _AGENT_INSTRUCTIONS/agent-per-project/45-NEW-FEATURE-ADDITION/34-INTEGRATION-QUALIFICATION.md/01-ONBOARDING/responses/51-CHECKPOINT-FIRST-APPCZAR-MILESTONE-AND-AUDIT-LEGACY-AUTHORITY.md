# MessageLens Feature 34
## Response 51 — Checkpoint the First AppCzar Milestone and Audit Legacy Semantic Authority

## 1. Baseline verification

The pre-checkpoint baseline matched Prompt 51:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD and upstream: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- tracked modifications: 38 paths;
- untracked status entries: 75, representing 118 individual files after expansion;
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`;
- qualified build metadata: `0.2.131+149`;
- qualified source/test tree: accumulated Prompt 32, 35, 44, 46, and 48 work;
- Prompt 49 and 50: human experiments only, with no additional source mutation.

The external baseline manifest is:

`/private/tmp/messagelens-prompt51-baseline-20261002.txt`

The captured baseline hashes were:

- porcelain-v1 `--untracked-files=all`: `a69ba016ec87cf8b4ebf9afe4c70289d3a4b35b13b8fd1b61d1763829b419477`;
- tracked diff: `3ce2ec01ca857c72106272632972869941f0f55a5f8fb7a4456c4a52a9ad3ead`.

The qualified development executable and embedded app framework hashes were also retained in that manifest:

- executable: `faf6d1f...`;
- `App.framework`: `418be669...`.

Production MessageLens was running as PID 801 and was not touched. No MessageLens Development process was running. No development-root launch override was present in `launchctl`.

## 2. Exact accumulated-diff inventory

The source/test/release-metadata checkpoint contains exactly the following 76 paths. Each path is listed once under its primary classification; several integration paths necessarily participate in more than one prompt.

### Prompt 32 — reset eligibility and invocation-time currentness

- `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.g.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider.g.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_presentation_provider.g.dart`
- `lib/essentials/onboarding/domain/advanced_start_fresh_presentation.dart`
- `lib/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart`
- `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`
- `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.g.dart`
- `lib/features/settings/application/sidebar_cassette_spec/actions/settings_action_list_actions_provider.dart`
- `lib/features/settings/application/sidebar_cassette_spec/actions/settings_action_list_actions_provider.g.dart`
- `lib/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/coordinators/cassette_coordinator.g.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver.g.dart`
- `lib/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_action_provider_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_action_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_current_state_reader_provider_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_presentation_provider_test.dart`
- `test/essentials/onboarding/presentation/advanced_start_fresh_overlay_test.dart`
- `test/essentials/sidebar/application/cassette_widget_coordinator_provider_test.dart`
- `test/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list_test.dart`
- `test/features/sidebar_utilities/application/sidebar_cassette_spec/resolvers/settings_root_resolver_test.dart`
- `test/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget_test.dart`

### Prompt 35 — reset single-flight and feedback

- `lib/essentials/onboarding/presentation/start_fresh_authorization_dialog.dart`
- `test/essentials/onboarding/presentation/start_fresh_authorization_dialog_test.dart`
- `test/architecture/onboarding_start_fresh_architecture_test.dart`

The Prompt 35 implementation also refined the Prompt 32 action, provider, presentation, overlay, and Settings paths listed above; they were checkpointed as one already-qualified tree rather than split by hunks.

### Prompt 44 and Prompt 46 — visible Fair-Witness AppCzar and corrected testimony

- `lib/essentials/app_czar/application/app_czar_assessment_provider.dart`
- `lib/essentials/app_czar/application/app_czar_assessment_provider.g.dart`
- `lib/essentials/app_czar/application/app_czar_evaluator.dart`
- `lib/essentials/app_czar/application/app_czar_observation_reader.dart`
- `lib/essentials/app_czar/application/app_czar_presentation_projector.dart`
- `lib/essentials/app_czar/domain/app_czar_models.dart`
- `lib/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader.dart`
- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`
- `lib/features/attachments/infrastructure/repositories/read_only_app_czar_attachment_archive_probe.dart`
- `test/app_czar_startup_composition_test.dart`
- `test/architecture/app_czar_architecture_test.dart`
- `test/essentials/app_czar/application/app_czar_assessment_provider_test.dart`
- `test/essentials/app_czar/application/app_czar_evaluator_test.dart`
- `test/essentials/app_czar/application/app_czar_presentation_projector_test.dart`
- `test/essentials/app_czar/infrastructure/read_only_app_czar_attachment_archive_probe_test.dart`
- `test/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`

### Prompt 48 — first executable Data Update coordinator

- `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart`
- `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart`
- `lib/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider.dart`
- `lib/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider.g.dart`
- `lib/essentials/app_czar_data_update/application/app_czar_process_restarter.dart`
- `lib/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart`
- `lib/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.g.dart`
- `lib/essentials/app_czar_data_update/domain/app_czar_data_update_state.dart`
- `lib/essentials/app_czar_data_update/infrastructure/macos_development_process_restarter.dart`
- `lib/essentials/app_czar_data_update/presentation/app_czar_data_update_screen.dart`
- `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart`
- `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.g.dart`
- `lib/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart`
- `lib/essentials/conversation_graph/application/monitor/live_graph_update_worker.g.dart`
- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar_data_update/application/app_czar_data_update_executor_provider_test.dart`
- `test/essentials/app_czar_data_update/infrastructure/macos_development_process_restarter_test.dart`
- `test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart`
- `test/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider_test.dart`
- `test/essentials/conversation_graph/application/monitor/live_graph_update_worker_test.dart`

### Shared integration, generated, architecture, and release metadata

- `CHANGELOG.md`
- `pubspec.yaml`
- `lib/main.dart`
- `lib/essentials/onboarding/application/onboarding_environment_report_provider.g.dart`
- `lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.g.dart`
- `lib/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.g.dart`
- `test/architecture/forbidden_imports_test.dart`

The separate documentation checkpoint contains exactly these 36 files under the
Feature 34 `01-ONBOARDING/` directory:

### Prompt/response documentation

Prompts:

- `prompts/30-RESUME-FEATURE-34-CLEAN-SLATE-ONBOARDING-QUALIFICATION.md`
- `prompts/31-FORENSIC-AUDIT-POST-ONBOARDING-RESET-AND-FAVOURITES.md`
- `prompts/32-CORRECT-ADVANCED-START-FRESH-CURRENTNESS-AND-RESET-UX.md`
- `prompts/33-BOUNDED-HUMAN-RESET-REVIEW-AND-CORRECT-BUILD-HANDOFF.md`
- `prompts/34-FORENSIC-AUDIT-START-FRESH-NO-VISIBLE-COMPLETION.md`
- `prompts/35-CORRECT-ADVANCED-START-FRESH-SINGLE-FLIGHT-AND-FEEDBACK.md`
- `prompts/36-BUILD-AND-RUN-CORRECTED-CLEAN-SLATE-ONBOARDING-QUALIFICATION.md`
- `prompts/38-FORENSIC-AUDIT-MECHANICAL-IMPOSSIBILITY-AND-LAZY-CONTACT-RESOLUTION.md`
- `prompts/40-APPCZAR-ARCHITECTURE-AUDIT-AND-SIMPLIFICATION-DESIGN.md`
- `prompts/41-REFINE-APPCZAR-AS-DEPENDENCY-ORDERED-FAIR-WITNESS-RECONCILER.md`
- `prompts/42-HUMAN-ARCHITECTURE-REVIEW-OF-APPCZAR-FACT-DAG.md`
- `prompts/44-IMPLEMENT-VISIBLE-APPCZAR-STARTUP-HARNESS.md`
- `prompts/45-BUILD-DIRECT-LAUNCH-APPCZAR-FDA-EXPERIMENT.md`
- `prompts/46-CORRECT-APPCZAR-FAIR-WITNESS-TESTIMONY-AND-STATUS-SEMANTICS.md`
- `prompts/47-REPEAT-DIRECT-LAUNCH-FAIR-WITNESS-OFF-ON-EXPERIMENT.md`
- `prompts/48-IMPLEMENT-FIRST-LIVE-APPCZAR-DATA-UPDATE-COORDINATOR.md`
- `prompts/49-RUN-FIRST-LIVE-APPCZAR-SELF-HEALING-DATA-UPDATE-EXPERIMENT.md`
- `prompts/50-RESTORE-DIRECT-LAUNCH-SOURCE-ACCESS-AND-RERUN-SELF-HEALING-EXPERIMENT.md`
- `prompts/51-CHECKPOINT-FIRST-APPCZAR-MILESTONE-AND-AUDIT-LEGACY-AUTHORITY.md`

Responses:

- `responses/29-CHECKPOINT-ACCUMULATED-ONBOARDING-CORRECTION.md`
- `responses/30-RESUME-FEATURE-34-CLEAN-SLATE-ONBOARDING-QUALIFICATION.md`
- `responses/31-FORENSIC-AUDIT-POST-ONBOARDING-RESET-AND-FAVOURITES.md`
- `responses/32-CORRECT-ADVANCED-START-FRESH-CURRENTNESS-AND-RESET-UX.md`
- `responses/34-FORENSIC-AUDIT-START-FRESH-NO-VISIBLE-COMPLETION.md`
- `responses/35-CORRECT-ADVANCED-START-FRESH-SINGLE-FLIGHT-AND-FEEDBACK.md`
- `responses/38-FORENSIC-AUDIT-MECHANICAL-IMPOSSIBILITY-AND-LAZY-CONTACT-RESOLUTION.md`
- `responses/40-APPCZAR-ARCHITECTURE-AUDIT-AND-SIMPLIFICATION-DESIGN.md`
- `responses/41-REFINE-APPCZAR-AS-DEPENDENCY-ORDERED-FAIR-WITNESS-RECONCILER.md`
- `responses/42-HUMAN-ARCHITECTURE-REVIEW-OF-APPCZAR-FACT-DAG.md`
- `responses/44-IMPLEMENT-VISIBLE-APPCZAR-STARTUP-HARNESS.md`
- `responses/45-BUILD-DIRECT-LAUNCH-APPCZAR-FDA-EXPERIMENT.md`
- `responses/46-CORRECT-APPCZAR-FAIR-WITNESS-TESTIMONY-AND-STATUS-SEMANTICS.md`
- `responses/47-REPEAT-DIRECT-LAUNCH-FAIR-WITNESS-OFF-ON-EXPERIMENT.md`
- `responses/48-IMPLEMENT-FIRST-LIVE-APPCZAR-DATA-UPDATE-COORDINATOR.md`
- `responses/49-RUN-FIRST-LIVE-APPCZAR-SELF-HEALING-DATA-UPDATE-EXPERIMENT.md`
- `responses/50-RESTORE-DIRECT-LAUNCH-SOURCE-ACCESS-AND-RERUN-SELF-HEALING-EXPERIMENT.md`

There are no renames, substitutions, or additional documentation paths in
commit `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`.

## 3. Intended versus unrelated files

Only the 76 implementation paths and 36 documentation paths in Section 2 were staged.

The following pre-existing untracked material was explicitly left untouched:

- `.vscode/settings.json`;
- Feature 26 Prompt 01;
- Feature 30 Prompt 16;
- Feature 31 prompts 02 through 21 and its untracked `responses/` directory;
- all untracked material below Feature 34 `00-PREPARATION/`.

No broad `git add .` was used. There was no unstaged tracked source/test residue after staging, so the staged implementation was the qualified implementation tree.

## 4. Checkpoint strategy chosen

The accumulated source changes overlap at shared integration points, especially `main.dart`, reset presentation/actions, generated providers, and architecture tests. Splitting them by prompt would have required partial-file/hunk surgery against the already-qualified tree.

The safe strategy was therefore:

1. one complete milestone implementation commit containing all qualified source, test, generated, and release-metadata changes;
2. one documentation commit containing only the established Feature 34 prompt/response history;
3. a normal push of the existing branch as a recovery anchor.

No source hunk was reconstructed, dropped, or altered to create prettier history.

## 5. Exact validation results

Validation was run against the exact staged implementation:

- build generation consistency: `dart run build_runner build --delete-conflicting-outputs` completed with zero generated outputs;
- formatting: all 74 staged Dart paths checked, zero files changed;
- focused AppCzar, Data Update, reset eligibility/single-flight, and mutation-authority tests: 127 passed, 0 failed;
- complete architecture suite: 565 passed, 0 failed;
- `flutter analyze`: no issues;
- full serialized Flutter suite: 2,817 passed, 1 intentional qualification skip, 0 failed;
- `git diff --check`: passed;
- `git diff --cached --check`: passed;
- staged implementation diff SHA-256: `7a75b96d6b84fe17e89482fdec8e9b8c0a861400e0975bf3d79bf61faa425dc7`.

The full-suite log is retained at:

`/tmp/messagelens_prompt51_full_test.log`

## 6. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

- BLOCKER: 0
- SHOULD FIX: 0

The current evaluator's `UNKNOWN` source-readability mapping is a deliberately audited next-step design issue required by Prompt 51. It is not an undisclosed defect in the checkpointed and human-qualified Data Update path, and this prompt expressly defaults its correction to report-only.

## 7. BLOCKER findings

None.

## 8. SHOULD FIX findings

None in the checkpointed milestone.

The report-only future correction in Section 21 remains required before Source Access Repair is made executable.

## 9. Exact local checkpoint commits

Implementation checkpoint:

`ddcbeb64fc17eac817ce2b8c802ae1c7e0530ac7`

`feat(startup): establish AppCzar fair-witness self-healing loop`

Documentation checkpoint and branch tip:

`f013388a3a28809a82dd04d97f1ab6a9fb39ef13`

`docs(feature-34): record AppCzar milestone qualification`

## 10. Exact remote recovery-anchor commit

The branch was pushed normally to:

`origin/fix/onboarding-import-stuck-state`

Remote recovery-anchor commit:

`f013388a3a28809a82dd04d97f1ab6a9fb39ef13`

Push range:

`9171c9c2..f013388a`

No force push, rebase, merge, PR merge, or branch deletion occurred.

## 11. Branch/upstream status after push

- local branch: `fix/onboarding-import-stuck-state`;
- local HEAD: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`;
- upstream: `origin/fix/onboarding-import-stuck-state`;
- upstream commit: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`;
- ahead/behind: `0/0`.

## 12. Complete legacy semantic-authority census

The census below classifies each inspected mechanism exactly once. A classifying row covers the named mechanism as currently composed; narrower raw readers or worker components are separated where their meaning differs.

| Mechanism | Principal readers / writers / caller chain | Current meaning | Classification |
|---|---|---|---|
| Admitted `ArchiveAccessAuthority`, data-root identity, archive location/bookmark identity | startup authority construction; archive/environment providers; AppCzar observation reader | Current physical/configuration identity, not a remembered disposition | KEEP AS FACT SOURCE |
| `SqliteAppCzarObservationReader` source/import/graph/overlay observations | `appCzarAssessmentProvider` -> `AppCzarEvaluator` | Fresh bounded observations of current stores and source | KEEP AS FACT SOURCE |
| `OnboardingDatabaseProbeReader`, SQLite probe implementations, and raw `MessageLensInstallationEvidence` | installation validation, environment report, durable completion verifier | File existence, readability, schema, integrity, row counts | KEEP AS FACT SOURCE |
| Source-scoped import ledger/cursor and imported source rows | live update worker, AppCzar source/local comparison, graph build | Durable record of what source rows were imported | KEEP AS FACT SOURCE |
| `SqliteConversationGraphReadinessChecker` / `ConversationGraphReadiness` result | graph readiness provider, environment report, recovered-message evidence | Bounded graph schema/count/topology observation | KEEP AS FACT SOURCE |
| Attachment archive configuration, instance identity, generation, and read-only availability probe | attachment providers and AppCzar reader | Current configuration and current availability | KEEP AS FACT SOURCE |
| Current-launch `StartupFlags`, including Option-launch reset request | `main.dart` legacy startup | Current launch input, not cross-launch remembered state | KEEP AS FACT SOURCE |
| Startup validation telemetry and diagnostic evidence | telemetry sink / log exporter | Historical observations for diagnosis only | KEEP AS FACT SOURCE |
| `SidebarFlowState` plus contact/navigation preference restoration | sidebar actions write; overlay preference store persists; `SidebarFlow.build` proposes restoration; cassette rack and projected center spec read | User navigation preference and UI selection, never startup/readiness disposition | KEEP AS SAME-SESSION UI STATE |
| `PanelsViewState`, cassette rack state, active sidebar mode | navigation actions and presentation | Current rendered workspace state | KEEP AS SAME-SESSION UI STATE |
| Advanced Start Fresh single-flight/presentation state | Settings action -> advanced action provider -> overlay/dialog | One invocation's UI/action state | KEEP AS SAME-SESSION UI STATE |
| AppCzar Data Update controller state | harness starts controller; update screen observes it | One executable coordinator's current progress/outcome before restart | KEEP AS SAME-SESSION UI STATE |
| Dev-only readiness overrides | dev panel/readiness provider | Current process simulation input | KEEP AS SAME-SESSION UI STATE |
| Import pages, frozen source bounds, graph-build observations, SQLite transactions | source importer / graph builder | Bounded execution mechanics | KEEP AS WORKER-INTERNAL MECHANISM |
| `LiveGraphUpdateWorker` and process-local `ChatDbChangeMonitorState` | monitor schedules worker; worker invokes graph build and attachment preservation | Incremental worker decision/progress and polling cursor | KEEP AS WORKER-INTERNAL MECHANISM |
| Archive mutation coordinator, DB maintenance lock, mutation journals | admitted workers | Exclusive physical-operation tenure and exact recovery mechanics | KEEP AS WORKER-INTERNAL MECHANISM |
| `messageDataVersionProvider` | graph/read providers | Process-local cache invalidation | KEEP AS WORKER-INTERNAL MECHANISM |
| `OnboardingOperationSnapshot` identity/stage/substage/progress/failure detail and its controller/store | legacy onboarding executor reports; presentation projects progress; overlay persists | Operation-scoped evidence; valid only as worker evidence, never a launch disposition | KEEP AS WORKER-INTERNAL MECHANISM |
| Persisted onboarding import/graph failure records | Journey writes; overlay failure store persists; environment report reads and converts to current failure state | Useful historical diagnostic record currently promoted into a current conclusion | DEMOTE — no longer semantic authority |
| `conversationGraphPopulatedProvider` when used to admit startup or global operation | top menu/cassette rack and chat monitor consume it | Useful feature-local availability guard, but not an application disposition | DEMOTE — no longer semantic authority |
| Graph-build/live-monitor status fields copied into `OnboardingEnvironmentReport` | report provider reads worker states; dev/readiness panels display | Historical/process observations that must not choose the next launch | DEMOTE — no longer semantic authority |
| Pipeline incident history/report records | incident tracker -> center-panel sync/pipeline panel | Diagnostic history may remain; it must not supersede fresh AppCzar facts | DEMOTE — no longer semantic authority |
| `MessageLensInstallationState`, classifier, validation service, and `messageLensInstallationStateProvider` | SQLite evidence -> classifier/provider -> `StartupApp` -> startup dialog/admission/window restore | A second whole-application startup disposition reconstructed outside AppCzar | DELETE CANDIDATE — replaced by AppCzar model |
| Aggregate semantic parts of `OnboardingEnvironmentReport` (`state`, `blockerKind`, reset recommendation, sync plausibility) and `_OnboardingEnvironmentEvaluator` | raw probes/failures -> report -> Journey/readiness surfaces/reconciliation | A second global readiness/disposition evaluator | DELETE CANDIDATE — replaced by AppCzar model |
| Journey coordinator, Journey/Trip/Step episodes, compatibility `OnboardingStatus`, action context, and automatic-recovery transitions | report + snapshot -> Journey -> shell, overlays, readiness, actions | Cross-launch application-level semantic authority | DELETE CANDIDATE — replaced by AppCzar model |
| Snapshot resume/reconciliation and `OnboardingDurableReconciliationEvidence` | new process interrupts old snapshot; Journey combines snapshot with environment report; controller resumes/fails/completes | Reconstructs an app-level journey from remembered operation conclusions | DELETE CANDIDATE — replaced by AppCzar model |
| `OnboardingDurableCompletionVerifier` / `OnboardingInstallationReadyProof` as terminal app disposition | Journey verifies populated stores, marks snapshot complete, then publishes completion | Old in-process semantic completion; AppCzar requires stop/restart/fresh reassessment | DELETE CANDIDATE — replaced by AppCzar model |
| `onboardingGateProvider` and compatibility status forwarding | readiness/overlay/actions -> gate -> Journey | Compatibility façade over obsolete global Journey authority | DELETE CANDIDATE — replaced by AppCzar model |
| Environment Readiness surface provider, view model, panel, and action bridge | Journey/report -> surface -> center panel; actions -> gate/Journey | Presentation and commands chosen from old Journey semantics | DELETE CANDIDATE — replaced by AppCzar model |
| `OnboardingCenterPanelSyncObserver` and controller | Journey compatibility status + incident report -> panel mutation | Publishes old semantics into navigation | DELETE CANDIDATE — replaced by AppCzar model |
| Legacy `StartupApp`, startup dialog, `_continueStartup`, and post-classification initialization handoff | installation provider -> classifier -> initialization -> admitted `App` | Legacy startup admission authority and terminal handoff | DELETE CANDIDATE — replaced by AppCzar model |
| Legacy onboarding overlay terminal completion/dismissal | Journey episode -> overlay -> dismissal -> normal shell | Old same-process completion handoff, contrary to stop/reassess | DELETE CANDIDATE — replaced by AppCzar model |

No inspected item remains `UNKNOWN — requires additional source trace` after tracing its readers, writers, and callers.

## 13. KEEP AS FACT SOURCE items

Keep the following current or immutable evidence:

- admitted data-root and archive access authority;
- archive-location configuration, bookmark/identity, instance UUID, and generation;
- read-only source readability/count/high-water samples;
- import/graph/overlay file existence, schema, integrity, and row-count probes;
- source-scoped import rows and ledger cursor;
- raw conversation-graph structure/count/topology observations;
- attachment archive current availability and preservation identity;
- current-launch user input such as Option-reset;
- diagnostic telemetry and historical evidence when displayed explicitly as history.

These values answer factual questions. They do not answer the application-level question “what should run now?”

## 14. KEEP AS SAME-SESSION UI STATE items

Keep:

- SidebarFlow's current navigation/contact/conversation selection;
- panel stack, cassette rack, and active sidebar mode;
- Start Fresh single-flight progress and feedback;
- one AppCzar coordinator's in-memory progress/outcome;
- current-process development simulation controls.

SidebarFlow's serialized preference is durable, but its meaning remains a user preference. On restore it is only a proposed navigation state, is ignored after a local mutation, and does not classify the installation.

## 15. KEEP AS WORKER-INTERNAL MECHANISM items

Keep:

- bounded importer pages and frozen source bounds;
- source import ledger/cursor and graph-build execution details;
- transaction boundaries;
- exclusive mutation tenure and exact physical-operation journals;
- live-update worker observations and monitor cursor;
- `messageDataVersionProvider` process-local invalidation;
- operation-ID-scoped Onboarding snapshot fields that report stage, substage, progress, and failure detail.

The last item is retained only as worker evidence. It must not be read directly by presentation to choose application state, and its `completed`, `interrupted`, or recovery fields cannot authorize a later launch.

## 16. DEMOTE items

Demote, without necessarily deleting their historical/feature-local value:

- persisted import and graph failure entries: retain as dated diagnostics, never as present failure disposition;
- `conversationGraphPopulatedProvider`: retain as a feature-local safety/availability guard where needed, never as startup admission;
- graph-build and live-monitor fields: retain as worker telemetry, not global readiness;
- pipeline incident reports: retain as incident history/presentation evidence, not a substitute for fresh AppCzar assessment.

## 17. DELETE CANDIDATE items

The deletion candidates are:

- `MessageLensInstallationState` semantic classifier/provider/validation-to-admission chain;
- the aggregate semantic evaluator and conclusion fields of `OnboardingEnvironmentReport`;
- Journey coordinator, Trip/Step/Episode semantics, action context, compatibility status, and automatic recovery;
- snapshot resume/reconciliation and app-level completion proof;
- Onboarding gate/status compatibility providers;
- Environment Readiness semantic projection/action bridge;
- onboarding center-panel synchronization controller/observer;
- legacy `StartupApp` admission, dialogs, completion callbacks, and handoffs;
- legacy onboarding completion/dismissal overlay.

The underlying probes, workers, mutation boundaries, user preferences, and preservation data are not deletion candidates.

## 18. UNKNOWN items

None after the completed source trace.

This does not mean every future replacement design is decided. It means each audited current mechanism now has a grounded disposition. Source Access Repair remains a design task, not an untraced legacy item.

## 19. Historical-intent caller chains

### Legitimate historical preference: SidebarFlow

```text
sidebar/contact/navigation action
-> SidebarFlow._setState
-> SidebarFlowNavigationPreference / SidebarContactContextPreference
-> OverlaySidebarFlowPreferenceStore
-> overlay setting

next process
-> SidebarFlow.build
-> scheduled best-effort preference read
-> ignored if local mutation already occurred
-> restored SidebarFlowState and cassette rack
-> projected center spec
```

This chain restores what the user last selected. It does not infer readiness and remains valid.

### Obsolete remembered operation conclusion

```text
Journey starts admitted Onboarding operation
-> OnboardingOperationSnapshotController begin/stage/progress/fail/complete
-> OverlayOnboardingOperationSnapshotStore
-> durable JSON snapshot

next process
-> new processSessionId
-> old running snapshot becomes interrupted
-> Journey reads environment report + snapshot
-> onboardingReconciliationEvidenceFrom
-> resume / fail / complete
-> Journey episode/status
-> overlay and Environment Readiness presentation
```

The stage/progress evidence may remain worker-internal. The cross-launch semantic reconstruction is obsolete under fresh AppCzar reassessment.

### Obsolete persisted failure promotion

```text
Journey/import or graph operation failure
-> OnboardingFailureStore save*
-> OverlayOnboardingFailureStorage
-> onboarding_last_* setting

later report/process
-> OnboardingEnvironmentReportProvider load*Entry
-> usingPersisted*Failure
-> _OnboardingEnvironmentEvaluator state/blocker
-> Journey
-> Environment Readiness / center panel
```

The dated failure can remain diagnostic history. It cannot prove that the current installation still needs that recovery path.

### Duplicate installation classification

```text
archive-root SQLite probes + operation snapshot evidence
-> MessageLensInstallationValidationService
-> MessageLensInstallationStateClassifier
-> messageLensInstallationStateProvider
-> StartupApp
-> post-classification initialization/window restoration
-> automatic admission or startup dialog
```

This recomputes current evidence, but it still publishes a second global disposition parallel to AppCzar and is therefore a deletion candidate.

### Old center-panel publication

```text
OnboardingEnvironmentReport + operation snapshot
-> Journey compatibilityStatus
-> OnboardingCenterPanelSyncObserver
-> OnboardingCenterPanelSyncController
-> PanelsViewState
-> Environment Readiness or pipeline-incident panel
```

This is the presentation edge of the old semantic authority.

### Graph-admission references

```text
SqliteConversationGraphReadinessChecker
-> conversationGraphReadinessProvider
-> conversationGraphPopulatedProvider
-> cassette rack/top-menu enablement

and

conversationGraphReadinessProvider
-> ChatDbChangeMonitor / LiveGraphUpdateWorker prerequisite gate
```

The checker result is current fact. Feature-local disabled UI and worker preconditions may remain. Treating the boolean as whole-application startup admission must be removed.

### Legacy startup handoff

```text
StartupFlags + messageLensInstallationStateProvider
-> StartupApp._buildResolvedInstallationState
-> _initializePersistentStartup
-> optional startup dialog
-> _continueStartup
-> admitted App
```

This handoff is bypassed by the exact-development AppCzar harness today, but it still owns production startup and cannot be deleted until production is deliberately routed through AppCzar.

## 20. Dependency-ordered deletion/demotion map

No deletion was performed. A safe later sequence is:

1. **Correct and complete AppCzar/coordinator coverage first.** Preserve production legacy startup until Source Access Repair, Onboarding, Local Data Repair, Attachment Archive Repair, Operating Session, and Diagnostic Review have explicit bounded contracts and qualification.
2. **Replace presentation consumers.** Move shell/center-panel/overlay presentation to AppCzar-selected coordinator state. Remove `OnboardingCenterPanelSyncObserver`, its controller, and Journey-derived Environment Readiness projection only after replacements exist.
3. **Replace action bridges.** Route current commands to the selected bounded coordinator rather than `onboardingGateProvider` or Journey.
4. **Delete compatibility status/gate.** Once no presentation or action reader remains, remove `OnboardingStatus`, `onboardingGateProvider`, and the compatibility projection.
5. **Delete Journey semantic authority.** Remove Journey/Trip/Step/Episode transitions and automatic recovery after its consumers and command writers are gone.
6. **Delete cross-launch reconciliation.** Remove snapshot-to-Journey resume/reconciliation and terminal installation-ready proof. Retain only operation-scoped progress/failure evidence still required by the Onboarding worker; otherwise remove that residue with the worker's redesign.
7. **Split and remove `OnboardingEnvironmentReport` semantics.** Preserve reusable raw readers/probes, replace callers with current AppCzar fact readers, then remove `state`, `blockerKind`, reset recommendation, and evaluator logic.
8. **Demote historical failure/incident records.** Make their APIs explicitly diagnostic/history-only and remove all use in current disposition selection.
9. **Demote graph-populated gating.** Keep bounded graph facts for feature/worker preconditions; remove any global startup-admission interpretation.
10. **Route production startup through AppCzar under a separately approved checkpoint.** Only then remove `MessageLensInstallationState`, `StartupApp`, startup dialog/admission callbacks, and classification-gated initialization. Window-state restoration becomes an Operating Session concern driven after fresh current assessment.

This order removes outer semantic readers before their inner evidence sources and avoids deleting worker facts merely because legacy semantic layers currently consume them.

## 21. UNKNOWN-source-readability evaluator review

The issue is confirmed in `lib/essentials/app_czar/application/app_czar_evaluator.dart`.

`_sourceReadableFact` correctly maps:

```text
readable                 -> TRUE
accessDenied/unavailable -> FALSE
unknown                  -> UNKNOWN
```

But `_select` currently uses:

```text
messagesSourceReadable.truth != TRUE
    -> Source Access Repair
```

That comparison collapses `FALSE` and `UNKNOWN`, so inconclusive source evidence incorrectly selects an executable diagnosis intended for a conclusive access problem.

The smallest future correction is pure evaluator logic:

```text
messagesSourceReadable == FALSE
    -> Source Access Repair

messagesSourceReadable == UNKNOWN
    -> Diagnostic Review / contradictoryOrInsufficientEvidence
```

Required focused tests should assert both branches and preserve the existing literal testimony: AppCzar may say the source is readable, cannot currently be read, or could not be assessed. It must not infer the macOS Full Disk Access toggle state.

No correction was implemented in Prompt 51.

## 22. Recommendation for the next Source Access Repair design

Source Access Repair is the appropriate next bounded coordinator only after the Section 21 mapping is corrected.

1. **Selecting current fact:** only `AppCzarFactId.messagesSourceReadable == FALSE`, produced by a conclusive current `accessDenied` or `unavailable` source observation. `UNKNOWN` selects Diagnostic Review.
2. **Who can repair:** MessageLens cannot grant or toggle macOS TCC/Full Disk Access. It can explain the problem, open the relevant System Settings pane, and ask the human to act.
3. **Jurisdiction terminator:** a new bounded read-only source probe must successfully open/query the current Messages database and produce current count/high-water evidence; the bounded stability sample must also settle before another coordinator is chosen.
4. **Retest policy:** do not poll indefinitely. Offer an explicit, single-flight “Check Again” bounded retest for feedback if useful, but successful repair still ends at a real process boundary. The conservative minimum is guide, quit, and relaunch.
5. **Unsupported claims:** it would be unsupported to say “Full Disk Access is off/on/granted/revoked,” to claim that MessageLens changed the permission, or to attribute every source-open failure to FDA. The only admissible testimony is the concrete read-only source result and literal error category.
6. **Persistence:** no persisted Journey, resume flag, or remembered repair success is required. Current coordinator UI state can remain memory-only.
7. **Success boundary:** after a conclusive readable retest, stop the coordinator, terminate the old development process, observe a no-development-process interval, launch a new PID, and let fresh AppCzar observations choose the next disposition. No coordinator may chain directly to Data Update or Operating Session.
8. **Proof tests:** require evaluator tests for `FALSE` versus `UNKNOWN`; tests that no TCC-setting mutation API exists; single-flight retest tests; literal-copy tests forbidding permission-state claims; tests that the coordinator does not persist Journey/snapshot state; tests that success requests a real restart and does not invoke another coordinator; stale-generation tests proving old observations cannot finish a new attempt; exact-development-gate tests; and architecture tests preventing a generic permission-wizard dependency from entering the coordinator.

## 23. Exact Git/worktree/index/submodule state after checkpoint

At the end of the checkpoint and before creating this response:

- branch/HEAD: `fix/onboarding-import-stuck-state` at `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`;
- upstream: the same commit;
- ahead/behind: `0/0`;
- tracked worktree: clean;
- index: clean;
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`;
- remaining untracked files: only the known unrelated files enumerated in Section 3.

Creating this required Response 51 adds exactly one intended untracked response file under `01-ONBOARDING/responses/`; it does not alter the checkpoint commit, tracked tree, index, or submodule.

Neither real archive nor any real database was modified by the checkpoint/audit. Production MessageLens was not launched, stopped, or otherwise touched. No further development app launch occurred during Prompt 51.

## 24. Integration confirmation

No integration to `main` occurred.

- no merge;
- no rebase;
- no cherry-pick;
- no pull request merge;
- no branch deletion;
- no production routing through AppCzar.

`FIRST APPCZAR MILESTONE CHECKPOINTED: YES`

`RECOVERY ANCHOR PUSHED: YES`

`LEGACY SEMANTIC-AUTHORITY AUDIT COMPLETE: YES`

`READY TO DESIGN SOURCE ACCESS REPAIR: YES`
