import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/logging/application/app_logger.dart';
import 'package:remember_this_text/essentials/logging/domain/log_entry.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/derived_message_data_file_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/derived_message_data_file_store_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_validation_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_storage_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_store.dart';
import 'package:remember_this_text/essentials/onboarding/application/required_sources_readiness_scheduler_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/presence/domain/repositories/presence_schedule_repository.dart';
import 'package:remember_this_text/essentials/presence/domain/repositories/presence_schedule_run_maintenance.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/startup_presentation_evidence/domain/startup_presentation_evidence.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/resolver_tools/settings_reset_message_data_action_availability_provider.dart';

const _completed = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.completed,
  reason: 'synthetic',
);
ArchiveResetAdmission _live() =>
    ArchiveResetAdmission.selected(StartupPresentationComposition.startupApp);
ArchiveResetAdmission _input(String kind) => switch (kind) {
  'appCzar' => ArchiveResetAdmission.selected(
    StartupPresentationComposition.appCzar,
  ),
  'revoked' => _live()..revoke(),
  _ => ArchiveResetAdmission.unavailable(),
};
Override _override(String kind) =>
    archiveResetAdmissionProvider.overrideWith((ref) {
      if (kind == 'throwing') {
        throw StateError('synthetic unavailable');
      }
      return _input(kind);
    });
final _denied = throwsA(isA<ArchiveResetDenied>());

void main() {
  for (final kind in ['appCzar', 'missing', 'throwing', 'revoked']) {
    for (final visible in [false, true]) {
      test(
        'dispatcher $kind visible=$visible denies before action factory',
        () async {
          var factories = 0;
          final c = ProviderContainer(
            overrides: [
              if (kind != 'missing') _override(kind),
              settingsResetMessageDataActionAvailableProvider.overrideWith(
                (ref) => visible,
              ),
              advancedStartFreshActionProvider.overrideWith((ref) {
                factories++;
                throw StateError('forbidden factory');
              }),
            ],
          );
          addTearDown(c.dispose);
          final dispatcher = c.read(sidebarActionDispatcherProvider.notifier);
          for (var i = 0; i < 2; i++) {
            await expectLater(
              dispatcher.dispatch(
                intent: const ResetMessageDataRequested(),
                context: const SidebarActionDispatchContext(
                  sidebarMode: SidebarMode.settings,
                ),
              ),
              _denied,
            );
          }
          expect(factories, 0);
          expect(c.exists(startFreshServiceProvider), isFalse);
        },
      );
    }
    test('real action provider $kind denies before presentation', () {
      var presentations = 0;
      final c = ProviderContainer(
        overrides: [
          if (kind != 'missing') _override(kind),
          advancedStartFreshPresentationControllerProvider.overrideWith(
            () => _ForbiddenPresentation(() => presentations++),
          ),
        ],
      );
      addTearDown(c.dispose);
      expect(() => c.read(advancedStartFreshActionProvider), _denied);
      expect(presentations, 0);
      expect(c.exists(startFreshServiceProvider), isFalse);
    });
    test('real service provider $kind denies before dependencies', () async {
      var operations = 0;
      var presence = 0;
      var authority = 0;
      final c = ProviderContainer(
        overrides: [
          if (kind != 'missing') _override(kind),
          onboardingOperationControllerProvider.overrideWith((ref) {
            operations++;
            throw StateError('forbidden operation');
          }),
          requiredSourcesReadinessRepositoryProvider.overrideWith((ref) {
            presence++;
            throw StateError('forbidden Presence');
          }),
          archiveAccessAuthorityProvider.overrideWith((ref) {
            authority++;
            throw StateError('forbidden authority');
          }),
        ],
      );
      addTearDown(c.dispose);
      await expectLater(c.read(startFreshServiceProvider.future), _denied);
      expect([operations, presence, authority], [0, 0, 0]);
      expect(c.exists(messageDataResetServiceProvider), isFalse);
    });
    test(
      'shared service $kind constructs but real parameterless method denies',
      () async {
        var inputReads = 0;
        final c = ProviderContainer(
          overrides: [
            archiveResetAdmissionProvider.overrideWith((ref) {
              inputReads++;
              if (kind == 'throwing') {
                throw StateError('synthetic');
              }
              return _input(kind);
            }),
            appLoggerProvider.overrideWith(_InertLogger.new),
            derivedMessageDataFileStoreProvider.overrideWith(
              (ref) => _NeverFileStore(),
            ),
          ],
        );
        addTearDown(c.dispose);
        final sub = c.listen(messageDataResetServiceProvider, (_, _) {});
        addTearDown(sub.close);
        final service = c.read(messageDataResetServiceProvider);
        expect(
          inputReads,
          0,
        ); // Constructor stays independent for local repair.
        expect(service.resetDerivedData, _denied);
        expect(inputReads, 1);
        expect(c.exists(archiveMutationCoordinatorProvider), isFalse);
      },
    );
  }

  for (final boundary in [
    'state',
    'authorization',
    'frame',
    'service',
    'outcome',
    'dismissal',
    'retry',
    'failure',
  ]) {
    for (final exceptional in [false, true]) {
      test(
        'action revokes during $boundary exceptional=$exceptional without later effects',
        () async {
          final lifetime = _live();
          final entered = Completer<void>();
          final resume = Completer<void>();
          final trace = <String>[];
          Future<void> pause(String at) async {
            trace.add(at);
            if (at == boundary) {
              entered.complete();
              await resume.future;
              if (exceptional) {
                throw StateError('synthetic delayed failure');
              }
            }
          }

          final port = _Presentation(trace, () => pause('dismissal'));
          var reads = 0;
          final action = AdvancedStartFreshActionImpl(
            resetBinding: lifetime.bind(),
            readInstallationState: () async {
              reads++;
              await pause(
                boundary == 'retry'
                    ? 'retry'
                    : reads > 1
                    ? 'failure'
                    : 'state',
              );
              return _completed;
            },
            requestAuthorization: () async {
              await pause('authorization');
              return true;
            },
            waitForPresentationFrame: () => pause('frame'),
            readStartFreshService: () async {
              await pause('service');
              return _InertService(() async {
                await pause('outcome');
                if (boundary == 'failure') {
                  throw StateError('synthetic service failure');
                }
              });
            },
            presentation: port,
            reportFailure: (_, _) => trace.add('failure-log'),
            reportLifecycle: (event, {required requestId, detail}) =>
                trace.add('log:${event.name}'),
          );
          final result = boundary == 'retry'
              ? action.retry(occurrence: 1)
              : action.request();
          final check = expectLater(result, _denied);
          await entered.future;
          final before = List<String>.of(trace);
          lifetime.revoke();
          final replacement = _live();
          expect(identical(replacement.epoch, lifetime.epoch), isFalse);
          resume.complete();
          await check;
          expect(trace, before);
          expect(action.request, _denied);
          expect(() => action.retry(occurrence: 1), _denied);
          expect(() => action.dismissFailure(occurrence: 1), _denied);
          expect(trace, before);
        },
      );
    }
  }

  for (final event in [
    AdvancedStartFreshLifecycleEvent.requestReceived,
    AdvancedStartFreshLifecycleEvent.requestClaimed,
  ]) {
    test('synchronous claim revocation at $event stops state read', () async {
      final lifetime = _live();
      var reads = 0;
      final action = AdvancedStartFreshActionImpl(
        resetBinding: lifetime.bind(),
        readInstallationState: () async {
          reads++;
          return _completed;
        },
        requestAuthorization: () async => false,
        readStartFreshService: () async => throw StateError('forbidden'),
        presentation: _Presentation([], () async {}),
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) => fail('stale log'),
        reportLifecycle: (value, {required requestId, detail}) {
          if (value == event) {
            lifetime.revoke();
          }
        },
      );
      await expectLater(Future.sync(action.request), _denied);
      expect(reads, 0);
    });
  }

  test(
    'provider consumer invalidation closes old action, not sibling/root',
    () {
      final root = _live();
      final sibling = root.bind();
      final c = ProviderContainer(
        overrides: [archiveResetAdmissionProvider.overrideWithValue(root)],
      );
      final action = c.read(advancedStartFreshActionProvider);
      c.invalidate(advancedStartFreshActionProvider);
      expect(action.request, _denied);
      expect(() => action.dismissFailure(occurrence: 0), _denied);
      sibling.requireAllowed(ArchiveMutationOperation.startFresh);
      final next = c.read(advancedStartFreshActionProvider);
      expect(identical(action, next), isFalse);
      c.dispose();
      // Container disposal must close the newly realized consumer as well.
      expect(next.request, _denied);
    },
  );

  for (final boundary in ['operation', 'presence']) {
    for (final close in ['revoke', 'invalidate', 'dispose']) {
      test(
        'service construction paused at $boundary then $close publishes nothing',
        () async {
          final root = _live();
          final op = Completer<OnboardingOperationSnapshotController>();
          final presence = Completer<PresenceScheduleRepository>();
          final reachedPresence = Completer<void>();
          var presenceReads = 0;
          var authorityReads = 0;
          late Future<StartFreshService> construction;
          final c = ProviderContainer(
            overrides: [
              archiveResetAdmissionProvider.overrideWithValue(root),
              startFreshServiceProvider.overrideWith((ref) {
                construction = startFreshService(ref);
                return construction;
              }),
              onboardingOperationControllerProvider.overrideWith(
                (ref) => op.future,
              ),
              requiredSourcesReadinessRepositoryProvider.overrideWith((ref) {
                presenceReads++;
                reachedPresence.complete();
                return presence.future;
              }),
              archiveAccessAuthorityProvider.overrideWith((ref) {
                authorityReads++;
                throw StateError('forbidden authority');
              }),
            ],
          );
          c.read(startFreshServiceProvider.future).ignore();
          final future = construction;
          // Direct factory Future remains observable even when Riverpod discards a generation.
          final check = expectLater(future, _denied);
          final controller = _controller();
          addTearDown(controller.dispose);
          if (boundary == 'presence') {
            op.complete(controller);
            await reachedPresence.future;
          }
          if (close == 'revoke') {
            root.revoke();
          }
          if (close == 'invalidate') {
            c.invalidate(startFreshServiceProvider);
          }
          if (close == 'dispose') {
            c.dispose();
          }
          if (!op.isCompleted) {
            op.complete(controller);
          }
          presence.complete(_NeverPresence());
          await check;
          expect(presenceReads, boundary == 'presence' ? 1 : 0);
          expect(authorityReads, 0);
          if (close != 'dispose') {
            c.dispose();
          }
        },
      );
    }
  }

  for (final kind in ['appCzar', 'missing', 'revoked', 'live']) {
    test('plain service $kind checks before state and lower request', () async {
      var reads = 0;
      var lower = 0;
      final lifetime = kind == 'live' ? _live() : _input(kind);
      final service = _service(
        lifetime.bind(),
        read: () async {
          reads++;
          return _completed;
        },
        lower: () {
          lower++;
          throw StateError('inert lower sentinel');
        },
      );
      await expectLater(
        service.startFresh(
          entryPoint: StartFreshEntryPoint.completedInstallationAdvancedReset,
        ),
        kind == 'live' ? throwsA(isA<StateError>()) : _denied,
      );
      expect(reads, kind == 'live' ? 1 : 0);
      expect(lower, kind == 'live' ? 1 : 0);
    });
  }
  for (final exceptional in [false, true]) {
    test(
      'plain service awaited state revocation exceptional=$exceptional',
      () async {
        final root = _live();
        final pending = Completer<MessageLensInstallationState>();
        var lower = 0;
        final service = _service(
          root.bind(),
          read: () => pending.future,
          lower: () {
            lower++;
            throw StateError('forbidden lower');
          },
        );
        final result = service.startFresh(
          entryPoint: StartFreshEntryPoint.completedInstallationAdvancedReset,
        );
        final check = expectLater(result, _denied);
        root.revoke();
        _live();
        if (exceptional) {
          pending.completeError(StateError('synthetic'));
        } else {
          pending.complete(_completed);
        }
        await check;
        expect(lower, 0);
      },
    );
  }

  test(
    'shared cached general-reset binding cannot revive after invalidation',
    () {
      final root = _live();
      final c = ProviderContainer(
        overrides: [
          archiveResetAdmissionProvider.overrideWithValue(root),
          appLoggerProvider.overrideWith(_InertLogger.new),
          derivedMessageDataFileStoreProvider.overrideWith(
            (ref) => _NeverFileStore(),
          ),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(messageDataResetServiceProvider, (_, _) {});
      addTearDown(sub.close);
      final old = c.read(messageDataResetServiceProvider);
      c.invalidate(messageDataResetServiceProvider);
      expect(old.resetDerivedData, _denied);
      expect(c.exists(archiveMutationCoordinatorProvider), isFalse);
    },
  );
  for (final kind in ['appCzar', 'missing', 'revoked']) {
    test(
      'plain action $kind rejects request retry dismiss before callbacks',
      () {
        final trace = <String>[];
        final action = AdvancedStartFreshActionImpl(
          resetBinding: _input(kind).bind(),
          readInstallationState: () async {
            trace.add('read');
            return _completed;
          },
          requestAuthorization: () async {
            trace.add('auth');
            return false;
          },
          readStartFreshService: () async => throw StateError('forbidden'),
          presentation: _Presentation(trace, () async {}),
          waitForPresentationFrame: () async {
            trace.add('frame');
          },
          reportFailure: (_, _) => trace.add('error'),
          reportLifecycle: (event, {required requestId, detail}) =>
              trace.add('log'),
        );
        expect(action.request, _denied);
        expect(() => action.retry(occurrence: 1), _denied);
        expect(() => action.dismissFailure(occurrence: 1), _denied);
        expect(trace, isEmpty);
      },
    );
  }
  test(
    'shared parameterless live entry stops at inert lower spy; cached root stays revoked',
    () async {
      final root = _live();
      var lower = 0;
      final c = ProviderContainer(
        overrides: [
          archiveResetAdmissionProvider.overrideWithValue(root),
          appLoggerProvider.overrideWith(_InertLogger.new),
          derivedMessageDataFileStoreProvider.overrideWith(
            (ref) => _NeverFileStore(),
          ),
          archiveMutationCoordinatorProvider.overrideWith(
            () => _InertCoordinator(() => lower++),
          ),
        ],
      );
      addTearDown(c.dispose);
      final sub = c.listen(messageDataResetServiceProvider, (_, _) {});
      addTearDown(sub.close);
      final service = c.read(messageDataResetServiceProvider);
      await expectLater(service.resetDerivedData(), throwsA(isA<StateError>()));
      expect(lower, 1);
      root.revoke();
      final l2 = _live();
      expect(identical(root.epoch, l2.epoch), isFalse);
      expect(service.resetDerivedData, _denied);
      expect(lower, 1);
    },
  );
  for (final boundary in ['operation', 'presence']) {
    test(
      'service provider delayed $boundary exception after revocation is typed denial',
      () async {
        final root = _live();
        final pending = Completer<void>();
        final entered = Completer<void>();
        var authority = 0;
        final controller = _controller();
        addTearDown(controller.dispose);
        final c = ProviderContainer(
          overrides: [
            archiveResetAdmissionProvider.overrideWithValue(root),
            onboardingOperationControllerProvider.overrideWith((ref) async {
              if (boundary == 'operation') {
                entered.complete();
                await pending.future;
              }
              return controller;
            }),
            requiredSourcesReadinessRepositoryProvider.overrideWith((
              ref,
            ) async {
              entered.complete();
              await pending.future;
              return _NeverPresence();
            }),
            archiveAccessAuthorityProvider.overrideWith((ref) {
              authority++;
              throw StateError('forbidden');
            }),
          ],
        );
        addTearDown(c.dispose);
        final check = expectLater(
          c.read(startFreshServiceProvider.future),
          _denied,
        );
        await entered.future;
        root.revoke();
        pending.completeError(StateError('synthetic failure'));
        await check;
        expect(authority, 0);
      },
    );
  }
  test(
    'live real service factory constructs inert dependencies; disposal closes cached service only',
    () async {
      final root = _live();
      final trace = <String>[];
      final controller = _controller();
      addTearDown(controller.dispose);
      final c = ProviderContainer(
        overrides: [
          archiveResetAdmissionProvider.overrideWithValue(root),
          onboardingOperationControllerProvider.overrideWith((ref) {
            trace.add('operation');
            return controller;
          }),
          requiredSourcesReadinessRepositoryProvider.overrideWith((ref) {
            trace.add('presence');
            return _NeverPresence();
          }),
          archiveAccessAuthorityProvider.overrideWith((ref) {
            trace.add('authority');
            return ArchiveAccessAuthority(
              identity: ResolvedArchiveIdentity(
                environment: ArchiveEnvironment.development,
                buildIdentity: ArchiveBuildIdentity.developmentDebug,
                archiveInstanceId: ArchiveInstanceId(
                  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                ),
                canonicalRootPath: '/synthetic-unopened',
                bundleIdentifier: 'synthetic',
                productName: 'synthetic',
              ),
            );
          }),
          messageDataResetServiceProvider.overrideWith((ref) {
            trace.add('reset');
            return _NeverReset();
          }),
          onboardingFailureStorageProvider.overrideWith((ref) {
            trace.add('failure');
            return _NeverFailure();
          }),
        ],
      );
      final service = await c.read(startFreshServiceProvider.future);
      expect(trace, ['operation', 'presence', 'authority', 'reset', 'failure']);
      final sibling = root.bind();
      c.dispose();
      await expectLater(service.startFresh(), _denied);
      sibling.requireAllowed(ArchiveMutationOperation.startFresh);
      expect(trace, ['operation', 'presence', 'authority', 'reset', 'failure']);
    },
  );
  test(
    'old action and plain service do not adopt replacement container L2',
    () async {
      final l1 = _live();
      final c1 = ProviderContainer(
        overrides: [archiveResetAdmissionProvider.overrideWithValue(l1)],
      );
      final oldAction = c1.read(advancedStartFreshActionProvider);
      final oldService = _service(
        l1.bind(),
        read: () async => throw StateError('forbidden read'),
        lower: () => throw StateError('forbidden lower'),
      );
      l1.revoke();
      c1.dispose();
      final l2 = _live();
      final c2 = ProviderContainer(
        overrides: [archiveResetAdmissionProvider.overrideWithValue(l2)],
      );
      addTearDown(c2.dispose);
      final newAction = c2.read(advancedStartFreshActionProvider);
      expect(identical(oldAction, newAction), isFalse);
      expect(oldAction.request, _denied);
      await expectLater(oldService.startFresh(), _denied);
      c2
          .read(archiveResetAdmissionProvider)
          .bind()
          .requireAllowed(ArchiveMutationOperation.startFresh);
    },
  );
}

final class _ForbiddenPresentation
    extends AdvancedStartFreshPresentationController {
  _ForbiddenPresentation(this.enter);
  final void Function() enter;
  @override
  AdvancedStartFreshPresentation build() {
    enter();
    throw StateError('forbidden presentation');
  }
}

final class _InertLogger extends AppLogger {
  @override
  List<LogEntry> build() => [];
}

final class _NeverFileStore implements DerivedMessageDataFileStore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('forbidden filesystem');
}

final class _NeverPresence
    implements PresenceScheduleRepository, PresenceScheduleRunMaintenance {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('forbidden Presence method');
}

final class _NeverReset implements MessageDataResetService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('forbidden reset');
}

final class _NeverFailure implements OnboardingFailureStore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('forbidden failure store');
}

final class _NeverValidator implements MessageLensInstallationFullValidator {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('forbidden validator');
}

final class _NeverSnapshot implements OnboardingOperationSnapshotStore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('forbidden snapshot');
}

OnboardingOperationSnapshotController _controller() =>
    OnboardingOperationSnapshotController(
      store: _NeverSnapshot(),
      processSessionId: OnboardingProcessSessionId(
        '123e4567-e89b-42d3-a456-426614174020',
      ),
    );
StartFreshService _service(
  ArchiveResetAdmissionBinding binding, {
  required Future<MessageLensInstallationState> Function() read,
  required void Function() lower,
}) {
  final controller = _controller();
  addTearDown(controller.dispose);
  return StartFreshServiceImpl(
    resetBinding: binding,
    archiveRootPath: '/synthetic-unopened',
    requiredSourcesScheduleId: 1,
    readCurrentState: read,
    runWithMutationAuthority: (_) async {
      lower();
      throw StateError('lower returned unexpectedly');
    },
    messageDataResetService: _NeverReset(),
    operationController: controller,
    failureStore: _NeverFailure(),
    presenceRepository: _NeverPresence(),
    fullValidator: _NeverValidator(),
    refreshAfterReset: () => throw StateError('forbidden refresh'),
  );
}

final class _InertService implements StartFreshService {
  _InertService(this.run);
  final Future<void> Function() run;
  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) async {
    await run();
    return const StartFreshResult(verifiedState: _completed);
  }
}

final class _Presentation implements AdvancedStartFreshPresentationPort {
  _Presentation(this.trace, this.dismissed);
  final List<String> trace;
  final Future<void> Function() dismissed;
  @override
  int beginPreparing() {
    trace.add('prepare');
    return 1;
  }

  @override
  int? beginRetry({required int expectedOccurrence}) {
    trace.add('retry');
    return 2;
  }

  @override
  bool isCurrent(int occurrence) {
    trace.add('current');
    return true;
  }

  @override
  void showVerifiedVirgin({required int expectedOccurrence}) {
    trace.add('verified');
  }

  @override
  Future<void> waitUntilDismissed({required int expectedOccurrence}) =>
      dismissed();
  @override
  void showFailure({
    required int expectedOccurrence,
    required AdvancedStartFreshFailure failure,
  }) {
    trace.add('failure');
  }

  @override
  void dismiss({required int expectedOccurrence}) {
    trace.add('dismiss');
  }
}

final class _InertCoordinator extends ArchiveMutationCoordinator {
  _InertCoordinator(this.enter);
  final void Function() enter;
  @override
  ArchiveMutationCoordinatorState build() =>
      const ArchiveMutationCoordinatorState();
  @override
  Future<T> runWithCapability<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function(ArchiveMutationCapability capability) action,
  }) async {
    enter();
    throw StateError('inert lower sentinel; callback never invoked');
  }
}
