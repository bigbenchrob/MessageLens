import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_controller.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_observer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_live_update_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_currentness_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_session_state.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/live_graph_update_worker.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_navigation_restoration_policy_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  test('production observation cadence is exactly fifteen seconds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(appCzarOperatingCurrentnessCadenceProvider),
      const Duration(seconds: 15),
    );
  });

  test(
    'service is inert until the admitted shell explicitly starts it',
    () async {
      final observer = _ScriptedObserver();
      final harness = _Harness(
        observer: observer,
        cadence: const Duration(seconds: 15),
      );
      addTearDown(harness.dispose);

      expect(
        harness.container.read(appCzarOperatingCurrentnessCadenceProvider),
        const Duration(seconds: 15),
      );
      await Future<void>.delayed(Duration.zero);
      expect(observer.coverageCalls, 0);
      expect(observer.currentnessCalls, 0);

      harness.notifier.start();
      await _waitFor(() => observer.currentnessCalls == 1);

      expect(observer.coverageCalls, 1);
      expect(harness.state.phase, AppCzarOperatingCurrentnessPhase.idle);
    },
  );

  test('no-change stays silent and observes without a mutation Ball', () async {
    final observer = _ScriptedObserver();
    final executor = _ControlledExecutor();
    final harness = _Harness(observer: observer, executor: executor);
    addTearDown(harness.dispose);
    final messageDataGenerationBefore = harness.container.read(
      messageDataVersionProvider,
    );

    harness.notifier.start();
    await _waitFor(() => observer.currentnessCalls == 1);

    expect(executor.calls, 0);
    expect(harness.state.hasVisibleStatus, isFalse);
    expect(
      harness.container.read(archiveMutationCoordinatorProvider).isLocked,
      isFalse,
    );
    expect(
      harness.container.read(messageDataVersionProvider),
      messageDataGenerationBefore,
    );
  });

  test(
    'stop is synchronous and drain waits for an admitted observation',
    () async {
      final coverage = Completer<AppCzarOperatingCoverageObservation>();
      final observer = _ScriptedObserver(
        coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
          () => coverage.future,
        ],
      );
      final harness = _Harness(observer: observer);
      addTearDown(harness.dispose);

      harness.notifier.start();
      await _waitFor(() => observer.coverageCalls == 1);
      var drained = false;
      final drain = harness.notifier.stopAndDrain().then((_) {
        drained = true;
      });

      expect(harness.notifier.triggerObservationNow(), isFalse);
      expect(drained, isFalse);
      coverage.complete(_coverageObservation());
      await drain;
      expect(drained, isTrue);
      expect(observer.currentnessCalls, 0);
    },
  );

  test(
    'source-ahead owns one flight and verifies fresh post-coverage',
    () async {
      final release = Completer<void>();
      final executor = _ControlledExecutor(release: release);
      final observer = _ScriptedObserver(
        currentnessReads:
            <Future<AppCzarOperatingCurrentnessObservation> Function()>[
              () async =>
                  _currentnessObservation(sourceCount: 101, sourceMax: 201),
            ],
      );
      final harness = _Harness(observer: observer, executor: executor);
      addTearDown(harness.dispose);

      harness.notifier.start();
      await executor.started.future;

      expect(harness.notifier.triggerObservationNow(), isFalse);
      expect(executor.calls, 1);
      expect(observer.coverageCalls, 2);
      release.complete();
      await _waitFor(
        () =>
            observer.coverageCalls == 3 &&
            harness.state.phase == AppCzarOperatingCurrentnessPhase.idle,
      );

      expect(executor.calls, 1);
      expect(harness.state.occurrence, _occurrence);
      expect(harness.restarter.calls, 0);
    },
  );

  test('successful same-session update preserves navigation state', () async {
    final observer = _ScriptedObserver(
      coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
        () async => _coverageObservation(
          coverage: _incompleteCoverage,
          repairability: _sourceAbsentRepairability,
        ),
        () async => _coverageObservation(
          coverage: _incompleteCoverage,
          repairability: _sourceAbsentRepairability,
        ),
        () async => _coverageObservation(
          coverage: _incompleteCoverage,
          repairability: _sourceAbsentRepairability,
        ),
      ],
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async =>
                _currentnessObservation(sourceCount: 101, sourceMax: 201),
          ],
    );
    final harness = _Harness(
      observer: observer,
      additionalOverrides: <Override>[
        sidebarNavigationRestorationEnabledProvider.overrideWithValue(false),
        sidebarFlowPreferenceStoreProvider.overrideWith(
          (ref) async => const _MemorySidebarPreferenceStore(),
        ),
      ],
    );
    addTearDown(harness.dispose);
    final flowSubscription = harness.container.listen(
      sidebarFlowProvider,
      (_, _) {},
      fireImmediately: true,
    );
    final panelsSubscription = harness.container.listen(
      panelsViewStateProvider(SidebarMode.messages),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(flowSubscription.close);
    addTearDown(panelsSubscription.close);

    harness.container
        .read(sidebarFlowProvider.notifier)
        .selectContactConversation(
          contactId: 42,
          conversationId: 77,
          anchorMessageId: 901,
          searchQuery: 'retained query',
        );
    harness.container
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
        );
    harness.container
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.right,
          spec: const ViewSpec.conversations(
            ConversationsSpec.conversationMessages(conversationId: 77),
          ),
        );
    final flowBefore = harness.container.read(sidebarFlowProvider);
    final panelsBefore = harness.container.read(
      panelsViewStateProvider(SidebarMode.messages),
    );

    harness.notifier.start();
    await _waitFor(
      () =>
          observer.coverageCalls == 3 &&
          harness.state.phase == AppCzarOperatingCurrentnessPhase.idle,
    );

    expect(harness.container.read(sidebarFlowProvider), flowBefore);
    expect(
      harness.container.read(panelsViewStateProvider(SidebarMode.messages)),
      panelsBefore,
    );
    expect(harness.state.attachmentDebtCount, 1);
    expect(harness.state.attachmentSourceAbsentCount, 1);
    expect(harness.restarter.calls, 0);
  });

  test('retains real attachment counts through post-coverage read', () async {
    final postCoverage = Completer<AppCzarOperatingCoverageObservation>();
    final observer = _ScriptedObserver(
      coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
        () async => _coverageObservation(),
        () async => _coverageObservation(),
        () => postCoverage.future,
      ],
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async =>
                _currentnessObservation(sourceCount: 101, sourceMax: 201),
          ],
    );
    final harness = _Harness(observer: observer);
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(
      () =>
          observer.coverageCalls == 3 &&
          harness.state.phase ==
              AppCzarOperatingCurrentnessPhase.verifyingCoverage,
    );

    expect(harness.state.attachmentsExamined, 4);
    expect(harness.state.attachmentsPreserved, 2);
    expect(harness.state.attachmentsSkipped, 1);
    expect(harness.state.attachmentsFailed, 1);

    postCoverage.complete(_coverageObservation());
    await _waitFor(
      () => harness.state.phase == AppCzarOperatingCurrentnessPhase.idle,
    );
  });

  test('stopAndDrain waits for the admitted update flight to return', () async {
    final release = Completer<void>();
    final executor = _ControlledExecutor(release: release);
    final observer = _ScriptedObserver(
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async =>
                _currentnessObservation(sourceCount: 101, sourceMax: 201),
          ],
    );
    final harness = _Harness(observer: observer, executor: executor);
    addTearDown(harness.dispose);

    harness.notifier.start();
    await executor.started.future;
    var drained = false;
    final drain = harness.notifier.stopAndDrain().then((_) {
      drained = true;
    });
    expect(drained, isFalse);
    expect(harness.notifier.triggerObservationNow(), isFalse);

    release.complete();
    await drain;
    expect(drained, isTrue);
    expect(observer.coverageCalls, 2);
  });

  test('stopAndDrain waits for the real live-update Ball to release', () async {
    final workerStarted = Completer<void>();
    final releaseWorker = Completer<void>();
    final observer = _ScriptedObserver(
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async =>
                _currentnessObservation(sourceCount: 101, sourceMax: 201),
          ],
    );
    final worker = LiveGraphUpdateWorker(
      readPrerequisites: () async {
        workerStarted.complete();
        await releaseWorker.future;
        return const LiveGraphUpdatePrerequisiteSnapshot(
          appDataReady: true,
          liveMaxRowId: 201,
          importedMaxSourceRowId: 200,
          liveImportableMessageCount: 101,
          importedMessageCount: 100,
        );
      },
      runGraphBuild: (_) async => _testGraphBuildReport,
      preserveAttachments: (_) async => const AttachmentArchiveResult(
        totalScanned: 1,
        newlyArchived: 1,
        skipped: 0,
        failed: 0,
      ),
    );
    final container = ProviderContainer(
      overrides: <Override>[
        appCzarOperatingCurrentnessObserverProvider.overrideWithValue(observer),
        appCzarOperatingCurrentnessCadenceProvider.overrideWithValue(
          const Duration(hours: 1),
        ),
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          _testArchiveAuthority(),
        ),
        liveGraphUpdateWorkerProvider.overrideWith((ref) async => worker),
      ],
    );
    addTearDown(container.dispose);
    final provider = appCzarOperatingCurrentnessControllerProvider(_occurrence);
    final subscription = container.listen(
      provider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final notifier = container.read(provider.notifier);

    notifier.start();
    await workerStarted.future;
    expect(container.read(archiveMutationCoordinatorProvider).isLocked, isTrue);

    var drained = false;
    final drain = notifier.stopAndDrain().then((_) {
      drained = true;
    });
    expect(drained, isFalse);
    expect(container.read(archiveMutationCoordinatorProvider).isLocked, isTrue);

    releaseWorker.complete();
    await drain;

    expect(drained, isTrue);
    expect(
      container.read(archiveMutationCoordinatorProvider).isLocked,
      isFalse,
    );
    expect(
      container.read(provider).phase,
      AppCzarOperatingCurrentnessPhase.stopped,
    );
  });

  test('stale completion cannot publish after occurrence drain', () async {
    final currentness = Completer<AppCzarOperatingCurrentnessObservation>();
    final observer = _ScriptedObserver(
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () => currentness.future,
          ],
    );
    final harness = _Harness(
      observer: observer,
      cadence: const Duration(seconds: 15),
    );
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(() => observer.currentnessCalls == 1);
    final drain = harness.notifier.stopAndDrain();
    currentness.complete(
      _currentnessObservation(sourceCount: 101, sourceMax: 201),
    );
    await drain;

    expect(harness.state.phase, AppCzarOperatingCurrentnessPhase.stopped);
    expect(harness.executor.calls, 0);
  });

  test('one-shot cadence cannot overlap or queue an observation', () async {
    final secondRead = Completer<AppCzarOperatingCurrentnessObservation>();
    final observer = _ScriptedObserver(
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async => _currentnessObservation(),
            () => secondRead.future,
          ],
    );
    final harness = _Harness(
      observer: observer,
      cadence: const Duration(milliseconds: 2),
    );
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(() => observer.currentnessCalls == 2);
    await Future<void>.delayed(const Duration(milliseconds: 15));
    expect(observer.currentnessCalls, 2);
    expect(harness.notifier.triggerObservationNow(), isFalse);

    final drain = harness.notifier.stopAndDrain();
    secondRead.complete(_currentnessObservation());
    await drain;
  });

  test('post-update source-available uncovered payload fails closed', () async {
    final observer = _ScriptedObserver(
      coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
        () async => _coverageObservation(),
        () async => _coverageObservation(),
        () async => _coverageObservation(
          coverage: _incompleteCoverage,
          repairability: _availableRepairability,
        ),
      ],
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async =>
                _currentnessObservation(sourceCount: 101, sourceMax: 201),
          ],
    );
    final harness = _Harness(observer: observer);
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(
      () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
    );

    expect(
      harness.state.issueKind,
      AppCzarOperatingCurrentnessIssueKind.coverageIncomplete,
    );
    expect(harness.state.issue, contains('fresh AppCzar jurisdiction'));
    expect(harness.notifier.triggerObservationNow(), isFalse);
  });

  test(
    'attachment-bearing update returns to the same occurrence with source-absent debt',
    () async {
      final postCoverage = Completer<AppCzarOperatingCoverageObservation>();
      final observer = _ScriptedObserver(
        coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
          () async => _coverageObservation(
            coverage: _incompleteCoverage,
            repairability: _sourceAbsentRepairability,
          ),
          () async => _coverageObservation(
            coverage: _incompleteCoverage,
            repairability: _sourceAbsentRepairability,
          ),
          () => postCoverage.future,
        ],
        currentnessReads:
            <Future<AppCzarOperatingCurrentnessObservation> Function()>[
              () async =>
                  _currentnessObservation(sourceCount: 101, sourceMax: 201),
            ],
      );
      final harness = _Harness(observer: observer);
      addTearDown(harness.dispose);

      harness.notifier.start();
      await _waitFor(
        () =>
            observer.coverageCalls == 3 &&
            harness.state.phase ==
                AppCzarOperatingCurrentnessPhase.verifyingCoverage,
      );

      expect(harness.state.attachmentsExamined, 4);
      expect(harness.state.attachmentsPreserved, 2);
      expect(harness.state.occurrence, _occurrence);

      postCoverage.complete(
        _coverageObservation(
          coverage: _incompleteCoverage,
          repairability: _sourceAbsentRepairability,
        ),
      );
      await _waitFor(
        () => harness.state.phase == AppCzarOperatingCurrentnessPhase.idle,
      );

      expect(harness.state.occurrence, _occurrence);
      expect(harness.state.attachmentDebtCount, 1);
      expect(harness.state.attachmentSourceAbsentCount, 1);
      expect(harness.state.hasVisibleStatus, isTrue);
      expect(harness.restarter.calls, 0);
    },
  );

  test(
    'post-update UNKNOWN coverage is not called incomplete or denied',
    () async {
      final observer = _ScriptedObserver(
        coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
          () async => _coverageObservation(),
          () async => _coverageObservation(),
          () async => _coverageObservation(
            coverage: _unknownCoverage,
            repairability: _unknownRepairability,
          ),
        ],
        currentnessReads:
            <Future<AppCzarOperatingCurrentnessObservation> Function()>[
              () async =>
                  _currentnessObservation(sourceCount: 101, sourceMax: 201),
            ],
      );
      final harness = _Harness(observer: observer);
      addTearDown(harness.dispose);

      harness.notifier.start();
      await _waitFor(
        () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
      );

      expect(
        harness.state.issueKind,
        AppCzarOperatingCurrentnessIssueKind.coverageUnknown,
      );
      final issue = harness.state.issue!.toLowerCase();
      expect(issue, isNot(contains('incomplete')));
      expect(issue, isNot(contains('denied')));
    },
  );

  test(
    'source FALSE and UNKNOWN stop, drain, and restart distinctly',
    () async {
      for (final source in <AppCzarSourceObservation>[
        const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'The source read was rejected.',
        ),
        const AppCzarSourceObservation.unknown(
          'The source read was inconclusive.',
        ),
      ]) {
        final observer = _ScriptedObserver(
          currentnessReads:
              <Future<AppCzarOperatingCurrentnessObservation> Function()>[
                () async => _currentnessObservation(source: source),
              ],
        );
        final harness = _Harness(observer: observer);
        addTearDown(harness.dispose);

        harness.notifier.start();
        await _waitFor(
          () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
        );
        expect(harness.executor.calls, 0);
        if (source.condition == AppCzarSourceCondition.unknown) {
          expect(
            harness.state.issueKind,
            AppCzarOperatingCurrentnessIssueKind.sourceUnknown,
          );
          expect(harness.state.issue!.toLowerCase(), isNot(contains('denied')));
        } else {
          expect(
            harness.state.issueKind,
            AppCzarOperatingCurrentnessIssueKind.sourceUnreadable,
          );
        }

        await harness.notifier.restartAfterIssuePresented();
        expect(harness.restarter.calls, 1);
        expect(
          harness.state.phase,
          AppCzarOperatingCurrentnessPhase.restarting,
        );
      }
    },
  );

  test(
    'archive revision/unavailability and local contradiction never mutate',
    () async {
      final cases =
          <
            ({
              AppCzarOperatingCurrentnessObservation observation,
              AppCzarOperatingCurrentnessIssueKind issue,
            })
          >[
            (
              observation: _currentnessObservation(locationGeneration: 8),
              issue: AppCzarOperatingCurrentnessIssueKind.archiveChanged,
            ),
            (
              observation: _currentnessObservation(locationReadable: false),
              issue: AppCzarOperatingCurrentnessIssueKind.archiveUnavailable,
            ),
            (
              observation: _currentnessObservation(sourceCount: 99),
              issue: AppCzarOperatingCurrentnessIssueKind
                  .localDatasetContradiction,
            ),
          ];

      for (final testCase in cases) {
        final observer = _ScriptedObserver(
          currentnessReads:
              <Future<AppCzarOperatingCurrentnessObservation> Function()>[
                () async => testCase.observation,
              ],
        );
        final harness = _Harness(observer: observer);
        addTearDown(harness.dispose);
        harness.notifier.start();
        await _waitFor(
          () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
        );

        expect(harness.state.issueKind, testCase.issue);
        expect(harness.executor.calls, 0);
        await harness.notifier.restartAfterIssuePresented();
        expect(harness.restarter.calls, 1);
        expect(
          harness.state.phase,
          AppCzarOperatingCurrentnessPhase.restarting,
        );
      }
    },
  );

  test(
    'unknown archive evidence is not mislabeled as an identity change',
    () async {
      final observer = _ScriptedObserver(
        coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
          () async => _coverageObservation(
            archive: AppCzarArchiveObservation.unknown(
              'The archive observation was inconclusive.',
            ),
          ),
        ],
      );
      final harness = _Harness(observer: observer);
      addTearDown(harness.dispose);

      harness.notifier.start();
      await _waitFor(
        () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
      );

      expect(
        harness.state.issueKind,
        AppCzarOperatingCurrentnessIssueKind.coverageUnknown,
      );
      expect(
        harness.state.issueKind,
        isNot(AppCzarOperatingCurrentnessIssueKind.archiveChanged),
      );
      expect(harness.executor.calls, 0);
    },
  );

  test('unavailable archive evidence fails closed without mutation', () async {
    final observer = _ScriptedObserver(
      coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
        () async => _coverageObservation(
          archive: const AppCzarArchiveObservation(
            condition: AppCzarArchiveCondition.unavailable,
            label: 'Disconnected archive',
            coverage: _unknownCoverage,
            issue: 'The archive is disconnected.',
          ),
        ),
      ],
    );
    final harness = _Harness(observer: observer);
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(
      () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
    );

    expect(
      harness.state.issueKind,
      AppCzarOperatingCurrentnessIssueKind.archiveUnavailable,
    );
    expect(harness.executor.calls, 0);
  });

  test('source-ahead does not mutate a freshly read-only archive', () async {
    final observer = _ScriptedObserver(
      coverageReads: <Future<AppCzarOperatingCoverageObservation> Function()>[
        () async => _coverageObservation(),
        () async => _coverageObservation(
          archive: _archiveObservation(
            condition: AppCzarArchiveCondition.readOnly,
          ),
          locationWritable: false,
        ),
      ],
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async =>
                _currentnessObservation(sourceCount: 101, sourceMax: 201),
          ],
    );
    final harness = _Harness(observer: observer);
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(
      () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
    );

    expect(
      harness.state.issueKind,
      AppCzarOperatingCurrentnessIssueKind.archiveUnavailable,
    );
    expect(harness.executor.calls, 0);
  });

  test(
    'fresh scope, probe-generation, or resolved-path mismatch fails closed',
    () async {
      final mismatches = <AppCzarArchiveObservation>[
        _archiveObservation(scopeIdentity: 'different-scope'),
        _archiveObservation(probeGeneration: 1),
        _archiveObservation(resolvedPath: '/different/archive'),
      ];

      for (final mismatch in mismatches) {
        final observer = _ScriptedObserver(
          coverageReads:
              <Future<AppCzarOperatingCoverageObservation> Function()>[
                () async => _coverageObservation(),
                () async => _coverageObservation(archive: mismatch),
              ],
          currentnessReads:
              <Future<AppCzarOperatingCurrentnessObservation> Function()>[
                () async =>
                    _currentnessObservation(sourceCount: 101, sourceMax: 201),
              ],
        );
        final harness = _Harness(observer: observer);
        addTearDown(harness.dispose);

        harness.notifier.start();
        await _waitFor(
          () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
        );

        expect(
          harness.state.issueKind,
          AppCzarOperatingCurrentnessIssueKind.archiveChanged,
        );
        expect(harness.executor.calls, 0);
        await harness.notifier.restartAfterIssuePresented();
        expect(harness.restarter.calls, 1);
      }
    },
  );

  test('one unstable sample retries once; a second fails closed', () async {
    final observer = _ScriptedObserver(
      currentnessReads:
          <Future<AppCzarOperatingCurrentnessObservation> Function()>[
            () async => _currentnessObservation(sampleStable: false),
            () async => _currentnessObservation(sampleStable: false),
          ],
    );
    final harness = _Harness(observer: observer);
    addTearDown(harness.dispose);

    harness.notifier.start();
    await _waitFor(
      () => harness.state.phase == AppCzarOperatingCurrentnessPhase.issue,
    );

    expect(observer.currentnessCalls, 2);
    expect(
      harness.state.issueKind,
      AppCzarOperatingCurrentnessIssueKind.sourceUnstable,
    );
    expect(harness.executor.calls, 0);
  });
}

final class _Harness {
  _Harness({
    required AppCzarOperatingCurrentnessObserver observer,
    _ControlledExecutor? executor,
    Duration cadence = const Duration(hours: 1),
    List<Override> additionalOverrides = const <Override>[],
  }) {
    this.executor = executor ?? _ControlledExecutor();
    restarter = _RecordingRestarter();
    container = ProviderContainer(
      overrides: <Override>[
        appCzarOperatingCurrentnessObserverProvider.overrideWithValue(observer),
        appCzarOperatingLiveUpdateExecutorProvider.overrideWithValue(
          this.executor,
        ),
        appCzarOperatingCurrentnessCadenceProvider.overrideWithValue(cadence),
        appCzarProcessRestarterProvider.overrideWithValue(restarter),
        ...additionalOverrides,
      ],
    );
    subscription = container.listen(provider, (_, _) {}, fireImmediately: true);
  }

  late final _ControlledExecutor executor;
  late final _RecordingRestarter restarter;
  late final ProviderContainer container;
  late final ProviderSubscription<AppCzarOperatingCurrentnessState>
  subscription;

  AppCzarOperatingCurrentnessControllerProvider get provider =>
      appCzarOperatingCurrentnessControllerProvider(_occurrence);

  AppCzarOperatingCurrentnessController get notifier =>
      container.read(provider.notifier);

  AppCzarOperatingCurrentnessState get state => container.read(provider);

  void dispose() {
    subscription.close();
    container.dispose();
  }
}

final class _MemorySidebarPreferenceStore
    implements SidebarFlowPreferenceStore {
  const _MemorySidebarPreferenceStore();

  @override
  Future<String?> readContactContextPreference() async => null;

  @override
  Future<String?> readNavigationPreference() async => null;

  @override
  Future<void> writeContactContextPreference(String value) async {}

  @override
  Future<void> writeNavigationPreference(String value) async {}
}

final class _ScriptedObserver implements AppCzarOperatingCurrentnessObserver {
  _ScriptedObserver({
    List<Future<AppCzarOperatingCoverageObservation> Function()>? coverageReads,
    List<Future<AppCzarOperatingCurrentnessObservation> Function()>?
    currentnessReads,
    List<Future<AppCzarOperatingReadFence> Function()>? fenceReads,
  }) : _coverageReads =
           coverageReads ??
           <Future<AppCzarOperatingCoverageObservation> Function()>[],
       _currentnessReads =
           currentnessReads ??
           <Future<AppCzarOperatingCurrentnessObservation> Function()>[],
       _fenceReads =
           fenceReads ?? <Future<AppCzarOperatingReadFence> Function()>[];

  final List<Future<AppCzarOperatingCoverageObservation> Function()>
  _coverageReads;
  final List<Future<AppCzarOperatingCurrentnessObservation> Function()>
  _currentnessReads;
  final List<Future<AppCzarOperatingReadFence> Function()> _fenceReads;
  int coverageCalls = 0;
  int currentnessCalls = 0;
  int fenceCalls = 0;

  @override
  Future<AppCzarOperatingCoverageObservation> readCoverage() {
    coverageCalls++;
    if (_coverageReads.isNotEmpty) {
      return _coverageReads.removeAt(0)();
    }
    return Future<AppCzarOperatingCoverageObservation>.value(
      _coverageObservation(),
    );
  }

  @override
  Future<AppCzarOperatingCurrentnessObservation> readCurrentness() {
    currentnessCalls++;
    if (_currentnessReads.isNotEmpty) {
      return _currentnessReads.removeAt(0)();
    }
    return Future<AppCzarOperatingCurrentnessObservation>.value(
      _currentnessObservation(),
    );
  }

  @override
  Future<AppCzarOperatingReadFence> readFence() {
    fenceCalls++;
    if (_fenceReads.isNotEmpty) {
      return _fenceReads.removeAt(0)();
    }
    return Future<AppCzarOperatingReadFence>.value(_fence());
  }
}

final class _ControlledExecutor implements AppCzarOperatingLiveUpdateExecutor {
  _ControlledExecutor({this.release});

  final Completer<void>? release;
  final Completer<void> started = Completer<void>();
  int calls = 0;

  @override
  Future<LiveGraphUpdateResult> run({
    required AppCzarOperatingSessionOccurrence occurrence,
    required void Function() requireCurrentOccurrence,
    required Future<void> Function() requireCurrentPrecondition,
    LiveGraphUpdateObserver? onObservation,
  }) async {
    calls++;
    expect(occurrence, _occurrence);
    requireCurrentOccurrence();
    await requireCurrentPrecondition();
    if (!started.isCompleted) {
      started.complete();
    }
    onObservation?.call(
      const LiveGraphUpdateObservation.preservingAttachments(),
    );
    await (release?.future ?? Future<void>.value());
    onObservation?.call(
      const LiveGraphUpdateObservation.attachmentsPreserved(
        AttachmentArchiveResult(
          totalScanned: 4,
          newlyArchived: 2,
          skipped: 1,
          failed: 1,
        ),
      ),
    );
    requireCurrentOccurrence();
    return LiveGraphUpdateResult(
      prerequisites: const LiveGraphUpdatePrerequisiteSnapshot(
        appDataReady: true,
        liveMaxRowId: 201,
        importedMaxSourceRowId: 200,
        liveImportableMessageCount: 101,
        importedMessageCount: 100,
      ),
      decision: const StartupProbeDecision(
        shouldSchedule: true,
        reason: 'source is ahead',
        trigger: StartupProbeTrigger.rowIdAdvanced,
      ),
      graphBuildReport: _testGraphBuildReport,
    );
  }
}

final _testStartedAt = DateTime.utc(2026, 10, 4, 12);

final _testGraphBuildReport = ConversationGraphBuildReport(
  startedAt: _testStartedAt,
  finishedAt: _testStartedAt.add(const Duration(seconds: 1)),
  completedStageNames: const <String>['import_messages', 'project_messages'],
  stageTimings: const <ConversationGraphBuildStageTiming>[],
  messageImportResult: const MessageImportResult(
    startedAfterSourceRowId: 200,
    insertedMessageCount: 1,
    lastImportedSourceRowId: 201,
  ),
  richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
    candidateMessageCount: 1,
    enrichedMessageCount: 1,
    missingExtractionCount: 0,
    extractorAvailable: true,
  ),
  messageProjectionResult: const MessageProjectionResult(
    examinedMessageCount: 1,
    insertedMessageCount: 1,
  ),
);

final class _RecordingRestarter implements AppCzarProcessRestarter {
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls++;
  }
}

const _occurrence = AppCzarOperatingSessionOccurrence(
  processSequence: 61,
  assessmentGeneration: 12,
  admittedArchiveScopeIdentity: 'operating-scope',
  admittedArchiveProbeGeneration: 0,
  admittedArchiveResolvedPath: '/test/archive',
);

ArchiveAccessAuthority _testArchiveAuthority() {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        '22222222-2222-4222-8222-222222222222',
      ),
      canonicalRootPath: '/tmp/app-czar-operating-drain-test',
      bundleIdentifier: 'test.bundle',
      productName: 'MessageLens Test',
    ),
  );
}

const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 2,
  coveredCount: 2,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'operating-scope',
  archiveGeneration: 0,
);

const _incompleteCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.incomplete,
  requiredCount: 2,
  coveredCount: 1,
  missingCount: 1,
  unverifiableCount: 0,
  archiveScopeIdentity: 'operating-scope',
  archiveGeneration: 0,
);

const _unknownCoverage = AppCzarAttachmentCoverageObservation.unknown(
  issue: 'The current coverage probe was inconclusive.',
  archiveScopeIdentity: 'operating-scope',
  archiveGeneration: 0,
);

const _availableRepairability = AppCzarAttachmentRepairabilityObservation(
  condition: AppCzarAttachmentRepairOpportunityCondition.present,
  availableFromMessagesCount: 1,
  sourceAbsentCount: 0,
  sourceUnknownCount: 0,
  recordBackedRecoveryCount: 0,
  unsafeOrConflictingCount: 0,
  archiveScopeIdentity: 'operating-scope',
  archiveGeneration: 0,
);

const _sourceAbsentRepairability = AppCzarAttachmentRepairabilityObservation(
  condition: AppCzarAttachmentRepairOpportunityCondition.absent,
  availableFromMessagesCount: 0,
  sourceAbsentCount: 1,
  sourceUnknownCount: 0,
  recordBackedRecoveryCount: 0,
  unsafeOrConflictingCount: 0,
  archiveScopeIdentity: 'operating-scope',
  archiveGeneration: 0,
);

const _unknownRepairability = AppCzarAttachmentRepairabilityObservation.unknown(
  issue: 'The current repairability probe was inconclusive.',
  archiveScopeIdentity: 'operating-scope',
  archiveGeneration: 0,
);

AppCzarOperatingCoverageObservation _coverageObservation({
  AppCzarAttachmentCoverageObservation coverage = _completeCoverage,
  AppCzarAttachmentRepairabilityObservation? repairability,
  AppCzarArchiveObservation? archive,
  bool locationWritable = true,
}) {
  final token = Object();
  final fence = _fence(
    revisionToken: token,
    locationWritable: locationWritable,
  );
  return AppCzarOperatingCoverageObservation(
    before: fence,
    after: fence,
    archive:
        archive ??
        _archiveObservation(coverage: coverage, repairability: repairability),
  );
}

AppCzarArchiveObservation _archiveObservation({
  AppCzarArchiveCondition condition = AppCzarArchiveCondition.available,
  AppCzarAttachmentCoverageObservation? coverage,
  AppCzarAttachmentRepairabilityObservation? repairability,
  String scopeIdentity = 'operating-scope',
  int probeGeneration = 0,
  String resolvedPath = '/test/archive',
}) {
  final resolvedCoverage =
      coverage ??
      AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.complete,
        requiredCount: 2,
        coveredCount: 2,
        missingCount: 0,
        unverifiableCount: 0,
        archiveScopeIdentity: scopeIdentity,
        archiveGeneration: probeGeneration,
      );
  return AppCzarArchiveObservation(
    condition: condition,
    label: 'Test archive',
    coverage: resolvedCoverage,
    repairability:
        repairability ??
        AppCzarAttachmentRepairabilityObservation(
          condition: AppCzarAttachmentRepairOpportunityCondition.absent,
          availableFromMessagesCount: 0,
          sourceAbsentCount: 0,
          sourceUnknownCount: 0,
          recordBackedRecoveryCount: 0,
          unsafeOrConflictingCount: 0,
          archiveScopeIdentity: scopeIdentity,
          archiveGeneration: probeGeneration,
        ),
    archiveScopeIdentity: scopeIdentity,
    archiveGeneration: probeGeneration,
    resolvedPath: resolvedPath,
  );
}

AppCzarOperatingCurrentnessObservation _currentnessObservation({
  AppCzarSourceObservation? source,
  int sourceCount = 100,
  int sourceMax = 200,
  bool? sampleStable = true,
  int locationGeneration = 7,
  bool locationReadable = true,
}) {
  final token = Object();
  final fence = _fence(
    revisionToken: token,
    locationGeneration: locationGeneration,
    locationReadable: locationReadable,
  );
  return AppCzarOperatingCurrentnessObservation(
    before: fence,
    after: fence,
    source:
        source ??
        AppCzarSourceObservation(
          condition: AppCzarSourceCondition.readable,
          messageCount: sourceCount,
          maxRowId: sourceMax,
          sampleStable: sampleStable,
        ),
    importStore: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 10,
      messageCount: 100,
      liveMessageCount: 100,
      liveMaxSourceRowId: 200,
    ),
    graphStore: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 3,
      messageCount: 100,
      chatCount: 4,
      chatMessageEdgeCount: 100,
    ),
  );
}

AppCzarOperatingReadFence _fence({
  Object? revisionToken,
  int locationGeneration = 7,
  bool locationReadable = true,
  bool? locationWritable,
}) {
  return AppCzarOperatingReadFence(
    messageDataGeneration: 9,
    archiveLocation: AppCzarOperatingArchiveLocationEvidence(
      generation: locationGeneration,
      isReadable: locationReadable,
      isWritableMutationEligible: locationWritable ?? locationReadable,
      resolvedPath: '/test/archive',
      issue: locationReadable ? null : 'The archive is disconnected.',
    ),
    mutation: AppCzarOperatingMutationFence(
      isActive: false,
      revisionToken: revisionToken ?? Object(),
      lastReleasedAtMicroseconds: 22,
    ),
  );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 500; attempt++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out waiting for the expected Operating currentness state.');
}
