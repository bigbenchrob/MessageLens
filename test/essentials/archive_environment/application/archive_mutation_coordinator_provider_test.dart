import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application.dart'
    show ArchiveCheckpointReceiptValidator;
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/exclusive_authority/application/exclusive_authority_registry_provider.dart'
    show ExclusiveAuthorityRegistryTestSupport;
import 'package:remember_this_text/essentials/exclusive_authority/feature_level_providers.dart'
    show ExclusiveAuthorityKey, exclusiveAuthorityRegistryProvider;

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test('fails closed before archive admission', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.graphBuild,
            ownerLabel: 'test-graph-build',
            action: () async {},
          ),
      throwsA(isA<StateError>()),
    );
  });

  test('admits one owner and records denied competing work', () async {
    final harness = await _CoordinatorHarness.create();
    addTearDown(harness.dispose);
    final releaseFirstOwner = Completer<void>();

    final firstOperation = harness.coordinator.run<void>(
      operation: ArchiveMutationOperation.liveGraphUpdate,
      ownerLabel: 'live-monitor',
      action: () => releaseFirstOwner.future,
    );

    final activeState = harness.state;
    expect(activeState.operation, ArchiveMutationOperation.liveGraphUpdate);
    expect(activeState.ownerLabel, 'live-monitor');
    expect(activeState.environment, ArchiveEnvironment.test);
    expect(
      activeState.archiveInstanceId,
      harness.fixture.authority.identity.archiveInstanceId,
    );
    expect(activeState.holdCount, 1);
    expect(activeState.acquiredAtUtc, isNotNull);

    await expectLater(
      harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.historicalArchiveImport,
        ownerLabel: 'historical-import',
        action: () async {},
      ),
      throwsA(
        isA<ArchiveMutationDeniedException>()
            .having(
              (error) => error.requestedOperation,
              'requested operation',
              ArchiveMutationOperation.historicalArchiveImport,
            )
            .having(
              (error) => error.currentOperation,
              'current operation',
              ArchiveMutationOperation.liveGraphUpdate,
            ),
      ),
    );

    final deniedState = harness.state;
    expect(deniedState.deniedRequests, 1);
    expect(
      deniedState.lastDeniedOperation,
      ArchiveMutationOperation.historicalArchiveImport,
    );
    expect(deniedState.lastDeniedOwner, 'historical-import');
    expect(deniedState.lastDeniedAtUtc, isNotNull);

    releaseFirstOwner.complete();
    await firstOperation;
    expect(harness.state.isLocked, isFalse);
    expect(harness.state.lastReleasedAtUtc, isNotNull);
  });

  test('same async owner may re-enter for a nested stage', () async {
    final harness = await _CoordinatorHarness.create();
    addTearDown(harness.dispose);

    await harness.coordinator.run<void>(
      operation: ArchiveMutationOperation.liveGraphUpdate,
      ownerLabel: 'live-monitor',
      action: () async {
        expect(harness.state.holdCount, 1);
        await harness.coordinator.run<void>(
          operation: ArchiveMutationOperation.graphBuild,
          ownerLabel: 'graph-build-stage',
          action: () async {
            expect(harness.state.ownerLabel, 'live-monitor');
            expect(harness.state.holdCount, 2);
            expect(harness.state.activeOperations, <ArchiveMutationOperation>[
              ArchiveMutationOperation.liveGraphUpdate,
              ArchiveMutationOperation.graphBuild,
            ]);
          },
        );
        expect(harness.state.holdCount, 1);
      },
    );

    expect(harness.state.isLocked, isFalse);
  });

  test(
    'capability is valid only in its exact active operation scope',
    () async {
      final harness = await _CoordinatorHarness.create();
      addTearDown(harness.dispose);
      late ArchiveMutationCapability outerCapability;

      await harness.coordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        ownerLabel: 'outer-attachment-reconciliation',
        action: (capability) async {
          outerCapability = capability;
          capability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );

          await harness.coordinator.runWithCapability<void>(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            ownerLabel: 'nested-attachment-reconciliation',
            action: (nestedCapability) async {
              expect(
                () => outerCapability.requireOperation(
                  ArchiveMutationOperation.attachmentReconciliation,
                ),
                throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
              );
              nestedCapability.requireOperation(
                ArchiveMutationOperation.attachmentReconciliation,
              );
            },
          );

          outerCapability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
        },
      );

      expect(
        () => outerCapability.requireOperation(
          ArchiveMutationOperation.attachmentReconciliation,
        ),
        throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
      );
    },
  );

  test(
    'retained Ball-1 Zone capability stays invalid while Ball 2 is live',
    () async {
      final harness = await _CoordinatorHarness.create();
      addTearDown(harness.dispose);
      final invokeStaleCallback = Completer<void>();
      late Future<Object?> staleCallbackResult;

      await harness.coordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        ownerLabel: 'reused-owner-label',
        action: (capability) async {
          capability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
          staleCallbackResult = invokeStaleCallback.future.then<Object?>((_) {
            try {
              capability.requireOperation(
                ArchiveMutationOperation.attachmentReconciliation,
              );
              return null;
            } on Object catch (error) {
              return error;
            }
          });
        },
      );

      await harness.coordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        ownerLabel: 'reused-owner-label',
        action: (currentCapability) async {
          final currentOwnerId = harness.state.ownerId;
          invokeStaleCallback.complete();
          expect(
            await staleCallbackResult,
            isA<ArchiveMutationCapabilityDeniedException>(),
          );
          expect(harness.state.ownerId, currentOwnerId);
          expect(harness.state.holdCount, 1);
          currentCapability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
        },
      );
    },
  );

  test(
    'capability rejects revoked generic tenure while archive scope stays active',
    () async {
      final harness = await _CoordinatorHarness.create();
      addTearDown(harness.dispose);

      await harness.coordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        ownerLabel: 'generic-tenure-grounding',
        action: (capability) async {
          capability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
          final registry = harness.container.read(
            exclusiveAuthorityRegistryProvider.notifier,
          );
          final cleanup = ExclusiveAuthorityRegistryTestSupport.instance
              .captureOnlyActiveScope(
                registry: registry,
                authority: ExclusiveAuthorityKey.archiveMutation,
              );

          ExclusiveAuthorityRegistryTestSupport.instance.replayCleanup(cleanup);

          expect(harness.state.isLocked, isTrue);
          expect(harness.state.holdCount, 1);
          expect(
            () => capability.requireOperation(
              ArchiveMutationOperation.attachmentReconciliation,
            ),
            throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
          );
        },
      );

      expect(harness.state.isLocked, isFalse);
    },
  );

  test(
    'nested scopes preserve stronger reopen policy and restore it',
    () async {
      final harness = await _CoordinatorHarness.create();
      addTearDown(harness.dispose);

      await harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.graphBuild,
        ownerLabel: 'graph-build',
        action: () async {
          expect(harness.state.blocksDatabaseReopen, isFalse);

          await harness.coordinator.run<void>(
            operation: ArchiveMutationOperation.messageDataReset,
            ownerLabel: 'nested-reset',
            action: () async {
              expect(harness.state.blocksDatabaseReopen, isTrue);
              expect(
                harness.state.activeOperations,
                contains(ArchiveMutationOperation.messageDataReset),
              );
            },
          );

          expect(harness.state.blocksDatabaseReopen, isFalse);
          expect(harness.state.activeOperations, <ArchiveMutationOperation>[
            ArchiveMutationOperation.graphBuild,
          ]);
        },
      );
    },
  );

  test(
    'Start Fresh blocks unrelated archive mutation and database reopen',
    () async {
      final harness = await _CoordinatorHarness.create();
      addTearDown(harness.dispose);
      final release = Completer<void>();

      final startFresh = harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.startFresh,
        ownerLabel: 'start-fresh',
        action: () => release.future,
      );
      expect(harness.state.blocksDatabaseReopen, isTrue);

      await expectLater(
        harness.coordinator.run<void>(
          operation: ArchiveMutationOperation.historicalArchiveImport,
          ownerLabel: 'historical-import',
          action: () async {},
        ),
        throwsA(isA<ArchiveMutationDeniedException>()),
      );

      release.complete();
      await startFresh;
      expect(harness.state.blocksDatabaseReopen, isFalse);
    },
  );

  test(
    'resource admission uses the requesting caller operation scope',
    () async {
      final harness = await _CoordinatorHarness.create();
      addTearDown(harness.dispose);

      await harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.historicalArchiveImport,
        ownerLabel: 'historical-import',
        action: () async {
          expect(
            harness.coordinator.resourceAdmissionForCurrentCaller(
              ArchiveMutationResourceAction.openConversationGraphConnection,
            ),
            ArchiveMutationResourceAdmission.admittedOwner,
          );

          await harness.coordinator.run<void>(
            operation: ArchiveMutationOperation.graphBuild,
            ownerLabel: 'nested-graph-build',
            action: () async {
              expect(
                harness.coordinator.resourceAdmissionForCurrentCaller(
                  ArchiveMutationResourceAction.openConversationGraphConnection,
                ),
                ArchiveMutationResourceAdmission.deniedByActiveMutation,
              );
            },
          );

          expect(
            harness.coordinator.resourceAdmissionForCurrentCaller(
              ArchiveMutationResourceAction.openConversationGraphConnection,
            ),
            ArchiveMutationResourceAdmission.admittedOwner,
          );
        },
      );
    },
  );

  test('exceptions release operation authority', () async {
    final harness = await _CoordinatorHarness.create();
    addTearDown(harness.dispose);

    await expectLater(
      harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.automaticRecovery,
        ownerLabel: 'recovery',
        action: () async {
          throw StateError('synthetic failure');
        },
      ),
      throwsStateError,
    );

    expect(harness.state.isLocked, isFalse);
    expect(harness.state.lastReleasedAtUtc, isNotNull);
  });

  test('message-data reset cannot overlap a live graph update', () async {
    final harness = await _CoordinatorHarness.create();
    addTearDown(harness.dispose);
    final releaseLiveUpdate = Completer<void>();

    final liveUpdate = harness.coordinator.run<void>(
      operation: ArchiveMutationOperation.liveGraphUpdate,
      ownerLabel: 'live-monitor',
      action: () => releaseLiveUpdate.future,
    );

    await expectLater(
      harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.messageDataReset,
        ownerLabel: 'message-data-reset',
        action: () async {},
      ),
      throwsA(isA<ArchiveMutationDeniedException>()),
    );

    releaseLiveUpdate.complete();
    await liveUpdate;
  });

  test('historical import cannot overlap a graph build', () async {
    final harness = await _CoordinatorHarness.create();
    addTearDown(harness.dispose);
    final releaseGraphBuild = Completer<void>();

    final graphBuild = harness.coordinator.run<void>(
      operation: ArchiveMutationOperation.graphBuild,
      ownerLabel: 'graph-build',
      action: () => releaseGraphBuild.future,
    );

    await expectLater(
      harness.coordinator.run<void>(
        operation: ArchiveMutationOperation.historicalArchiveImport,
        ownerLabel: 'historical-import',
        action: () async {},
      ),
      throwsA(isA<ArchiveMutationDeniedException>()),
    );

    releaseGraphBuild.complete();
    await graphBuild;
  });

  test('provider disposal does not strand a completing operation', () async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'mutation_coordinator_disposal_test_',
    );
    addTearDown(fixture.dispose);
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
      ],
    );
    final releaseOperation = Completer<void>();
    final operation = container
        .read(archiveMutationCoordinatorProvider.notifier)
        .run<void>(
          operation: ArchiveMutationOperation.graphBuild,
          ownerLabel: 'disposing-owner',
          action: () => releaseOperation.future,
        );

    expect(container.read(archiveMutationCoordinatorProvider).isLocked, isTrue);
    container.dispose();
    releaseOperation.complete();

    await expectLater(operation, completes);
  });

  test(
    'provider disposal invalidates capability in its retained Zone',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'mutation_capability_disposal_test_',
      );
      addTearDown(fixture.dispose);
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      final capabilityReady = Completer<void>();
      final probeAfterDisposal = Completer<void>();
      final observedFailure = Completer<Object>();

      final operation = container
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability<void>(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            ownerLabel: 'disposing-capability-owner',
            action: (capability) async {
              capabilityReady.complete();
              await probeAfterDisposal.future;
              try {
                capability.requireOperation(
                  ArchiveMutationOperation.attachmentReconciliation,
                );
              } on Object catch (error) {
                observedFailure.complete(error);
              }
            },
          );

      await capabilityReady.future;
      container.dispose();
      probeAfterDisposal.complete();

      await expectLater(
        observedFailure.future,
        completion(isA<ArchiveMutationCapabilityDeniedException>()),
      );
      await expectLater(operation, completes);
    },
  );

  test('database reopen state derives from the admitted operation', () async {
    final harness = await _CoordinatorHarness.create();
    addTearDown(harness.dispose);

    await harness.coordinator.run<void>(
      operation: ArchiveMutationOperation.liveGraphUpdate,
      ownerLabel: 'live-monitor',
      action: () async {
        expect(
          harness.container.read(archiveDatabaseReopenBlockedProvider),
          isFalse,
        );
      },
    );

    await harness.coordinator.run<void>(
      operation: ArchiveMutationOperation.messageDataReset,
      ownerLabel: 'reset',
      action: () async {
        expect(
          harness.container.read(archiveDatabaseReopenBlockedProvider),
          isTrue,
        );
      },
    );

    expect(
      harness.container.read(archiveDatabaseReopenBlockedProvider),
      isFalse,
    );
  });

  test(
    'production high-risk operations require verified recovery evidence',
    () async {
      final authority = ArchiveAccessAuthority(
        identity: ResolvedArchiveIdentity(
          environment: ArchiveEnvironment.production,
          buildIdentity: ArchiveBuildIdentity.productionRelease,
          archiveInstanceId: ArchiveInstanceId(
            'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
          ),
          canonicalRootPath: '/disposable/production-clone',
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
          productName: 'MessageLens',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
          archiveCheckpointReceiptValidatorProvider.overrideWithValue(
            const _AlwaysValidCheckpointReceiptValidator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(archiveMutationCoordinatorProvider.notifier)
            .run<void>(
              operation: ArchiveMutationOperation.messageDataReset,
              ownerLabel: 'production-reset',
              action: () async {},
            ),
        throwsA(isA<ArchiveCheckpointRequiredException>()),
      );

      container
          .read(verifiedArchiveCheckpointProvider.notifier)
          .record(
            ArchiveCheckpointReceipt(
              checkpointId: 'checkpoint-1',
              sourceEnvironment: ArchiveEnvironment.production,
              sourceArchiveInstanceId: authority.identity.archiveInstanceId,
              sourceRootPath: authority.rootPath,
              checkpointRootPath: '/disposable/checkpoint',
              manifestDigest: 'digest',
              verifiedAtUtc: DateTime.utc(2026, 7, 27),
            ),
          );

      await container
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.messageDataReset,
            ownerLabel: 'production-reset',
            action: () async {},
          );
    },
  );

  test(
    'nested production operations enforce stronger checkpoint policy',
    () async {
      final authority = ArchiveAccessAuthority(
        identity: ResolvedArchiveIdentity(
          environment: ArchiveEnvironment.production,
          buildIdentity: ArchiveBuildIdentity.productionRelease,
          archiveInstanceId: ArchiveInstanceId(
            'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
          ),
          canonicalRootPath: '/disposable/nested-production-clone',
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
          productName: 'MessageLens',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
        ],
      );
      addTearDown(container.dispose);
      final coordinator = container.read(
        archiveMutationCoordinatorProvider.notifier,
      );

      await coordinator.run<void>(
        operation: ArchiveMutationOperation.graphBuild,
        ownerLabel: 'outer-graph-build',
        action: () async {
          await expectLater(
            coordinator.run<void>(
              operation: ArchiveMutationOperation.messageDataReset,
              ownerLabel: 'nested-production-reset',
              action: () async {},
            ),
            throwsA(isA<ArchiveCheckpointRequiredException>()),
          );
          expect(
            container.read(archiveMutationCoordinatorProvider).activeOperations,
            <ArchiveMutationOperation>[ArchiveMutationOperation.graphBuild],
          );
        },
      );
    },
  );
}

final class _AlwaysValidCheckpointReceiptValidator
    implements ArchiveCheckpointReceiptValidator {
  const _AlwaysValidCheckpointReceiptValidator();

  @override
  Future<bool> validates({
    required ArchiveCheckpointReceipt receipt,
    required ArchiveAccessAuthority authority,
  }) async {
    return receipt.matches(authority);
  }
}

final class _CoordinatorHarness {
  const _CoordinatorHarness({required this.fixture, required this.container});

  final TestArchiveFixture fixture;
  final ProviderContainer container;

  ArchiveMutationCoordinator get coordinator =>
      container.read(archiveMutationCoordinatorProvider.notifier);

  ArchiveMutationCoordinatorState get state =>
      container.read(archiveMutationCoordinatorProvider);

  static Future<_CoordinatorHarness> create() async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'mutation_coordinator_test_',
    );
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
      ],
    );
    return _CoordinatorHarness(fixture: fixture, container: container);
  }

  Future<void> dispose() async {
    container.dispose();
    await fixture.dispose();
  }
}
