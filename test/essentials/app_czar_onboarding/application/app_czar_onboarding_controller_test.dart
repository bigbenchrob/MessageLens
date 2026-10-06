import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter.dart';
import 'package:remember_this_text/essentials/app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_build_executor_provider.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart';
import 'package:remember_this_text/essentials/app_czar_onboarding/domain/app_czar_onboarding_state.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/onboarding/application/fda_settings_opening_adapter.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/real_fda_settings_opening_authority_provider.dart';

void main() {
  test('safe empty viable occurrence builds once and restarts once', () async {
    final reader = _OnboardingReader();
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);

    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await restarter.called.future.timeout(const Duration(seconds: 2));

    expect(executor.calls, 1);
    expect(restarter.calls, 1);
    expect(
      container.read(appCzarOnboardingControllerProvider).phase,
      AppCzarOnboardingPhase.restarting,
    );
  });

  test(
    'source denial stays in Onboarding and Check Again reuses reader',
    () async {
      final reader = _OnboardingReader(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.accessDenied,
          issue: 'denied',
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await _waitForPhase(container, AppCzarOnboardingPhase.sourceNeedsHuman);
      expect(executor.calls, 0);
      expect(restarter.calls, 0);

      reader.source = _readableSource;
      await container
          .read(appCzarOnboardingControllerProvider.notifier)
          .checkAgain();
      await restarter.called.future.timeout(const Duration(seconds: 2));
      expect(reader.sourceReads, greaterThanOrEqualTo(2));
      expect(executor.calls, 1);
    },
  );

  test(
    'unavailable source remains a literal Onboarding prerequisite',
    () async {
      final reader = _OnboardingReader(
        source: const AppCzarSourceObservation(
          condition: AppCzarSourceCondition.unavailable,
          issue: 'The Messages database does not exist.',
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await _waitForPhase(container, AppCzarOnboardingPhase.sourceNeedsHuman);
      expect(executor.calls, 0);
      expect(restarter.calls, 0);
      expect(
        container.read(appCzarOnboardingControllerProvider).sourceCondition,
        AppCzarSourceCondition.unavailable,
      );

      await container
          .read(appCzarOnboardingControllerProvider.notifier)
          .openSystemSettings();
      expect(
        container.read(realFdaSettingsOpeningAuthorityProvider),
        isA<FdaSettingsOpeningAdapter>(),
      );
      expect(_fullDiskAccess.openSettingsCalls, 0);
    },
  );

  test('ordinary stop drains the active build without restarting', () async {
    final executor = _BuildExecutor(block: true);
    final restarter = _Restarter();
    final container = _container(_OnboardingReader(), executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await executor.started.future.timeout(const Duration(seconds: 2));

    var drained = false;
    final drain = container
        .read(appCzarOnboardingControllerProvider.notifier)
        .stopAndDrain()
        .then((_) => drained = true);
    await Future<void>.delayed(Duration.zero);
    expect(drained, isFalse);
    executor.release.complete();
    await drain;

    expect(restarter.calls, 0);
  });

  test(
    'assessment generation change drains active build before restart',
    () async {
      final executor = _BuildExecutor(block: true);
      final restarter = _Restarter();
      final container = _container(_OnboardingReader(), executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await executor.started.future.timeout(const Duration(seconds: 2));

      final reassessment = container
          .read(appCzarAssessmentControllerProvider.notifier)
          .runAgain();
      await reassessment;
      await Future<void>.delayed(Duration.zero);
      expect(restarter.calls, 0);

      executor.release.complete();
      await restarter.called.future.timeout(const Duration(seconds: 2));

      expect(executor.calls, 1);
      expect(restarter.calls, 1);
    },
  );

  test('source UNKNOWN after admission drains and restarts', () async {
    final reader = _OnboardingReader(
      sourceAfterAssessment: const AppCzarSourceObservation.unknown(
        'inconclusive',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test('Contacts human condition remains inside Onboarding', () async {
    final reader = _OnboardingReader(
      contacts: const AppCzarContactsPrerequisiteObservation(
        condition: AppCzarContactsPrerequisiteCondition.accessDenied,
        issue: 'current read denied',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await _waitForPhase(container, AppCzarOnboardingPhase.contactsNeedHuman);
    expect(executor.calls, 0);
    expect(restarter.calls, 0);
  });

  test(
    'unavailable Contacts remains a literal Onboarding prerequisite',
    () async {
      final reader = _OnboardingReader(
        contacts: const AppCzarContactsPrerequisiteObservation(
          condition: AppCzarContactsPrerequisiteCondition.unavailable,
          issue: 'No viable current Contacts database exists.',
        ),
      );
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await _waitForPhase(container, AppCzarOnboardingPhase.contactsNeedHuman);
      expect(executor.calls, 0);
      expect(restarter.calls, 0);
    },
  );

  test('invalid Contacts evidence restarts without building', () async {
    final reader = _OnboardingReader(
      contactsAfterAssessment: const AppCzarContactsPrerequisiteObservation(
        condition: AppCzarContactsPrerequisiteCondition.invalidOrCorrupt,
        issue: 'The selected database is invalid.',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test('Contacts UNKNOWN after admission restarts without building', () async {
    final reader = _OnboardingReader(
      contactsAfterAssessment:
          const AppCzarContactsPrerequisiteObservation.unknown('changed'),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test('changed physical scope invalidates the admitted occurrence', () async {
    final reader = _OnboardingReader(
      scopeAfterAssessment: const AppCzarInitialConstructionScopeObservation(
        condition: AppCzarInitialConstructionScopeCondition.consequentialData,
        importMessageCount: 1,
        graphMessageCount: 0,
        graphChatCount: 0,
        graphEdgeCount: 0,
        nonLiveSourceCount: 0,
        hasRetiredDerivedArtifacts: false,
        issue: 'A row appeared after admission.',
      ),
    );
    final executor = _BuildExecutor();
    final restarter = _Restarter();
    final container = _container(reader, executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(reader.scopeReads, greaterThanOrEqualTo(2));
    expect(executor.calls, 0);
    expect(restarter.calls, 1);
  });

  test(
    'prerequisite read failure restarts instead of remaining pending',
    () async {
      final reader = _OnboardingReader(throwOnSecondSourceRead: true);
      final executor = _BuildExecutor();
      final restarter = _Restarter();
      final container = _container(reader, executor, restarter);
      addTearDown(container.dispose);
      container.listen(
        appCzarOnboardingControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await restarter.called.future.timeout(const Duration(seconds: 2));
      expect(executor.calls, 0);
      expect(restarter.calls, 1);
    },
  );

  test('build failure restarts once for fresh classification', () async {
    final executor = _BuildExecutor(fail: true);
    final restarter = _Restarter();
    final container = _container(_OnboardingReader(), executor, restarter);
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );

    await restarter.called.future.timeout(const Duration(seconds: 2));
    expect(executor.calls, 1);
    expect(restarter.calls, 1);
  });

  test('stale build progress cannot publish after stop begins', () async {
    final executor = _BuildExecutor(block: true);
    final container = _container(_OnboardingReader(), executor, _Restarter());
    addTearDown(container.dispose);
    container.listen(
      appCzarOnboardingControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await executor.started.future.timeout(const Duration(seconds: 2));
    final beforeStop = container.read(appCzarOnboardingControllerProvider);

    final drain = container
        .read(appCzarOnboardingControllerProvider.notifier)
        .stopAndDrain();
    executor.publishProgress(completed: 2);
    expect(
      container.read(appCzarOnboardingControllerProvider).completedWorkCount,
      beforeStop.completedWorkCount,
    );
    executor.release.complete();
    await drain;
  });

  test(
    'only the exact Onboarding disposition satisfies execution predicate',
    () {
      for (final coordinator in AppCzarVirtualCoordinator.values) {
        expect(
          shouldExecuteAppCzarOnboarding(
            _assessmentState(coordinator: coordinator),
          ),
          coordinator == AppCzarVirtualCoordinator.onboarding,
          reason: coordinator.name,
        );
      }
    },
  );
}

ProviderContainer _container(
  _OnboardingReader reader,
  _BuildExecutor executor,
  _Restarter restarter,
) {
  _fullDiskAccess = _RecordingFullDiskAccess();
  return ProviderContainer(
    overrides: [
      appCzarObservationReaderProvider.overrideWithValue(reader),
      appCzarOnboardingBuildExecutorProvider.overrideWithValue(executor),
      appCzarProcessRestarterProvider.overrideWithValue(restarter),
      realFdaSettingsOpeningAuthorityProvider.overrideWithValue(
        FdaSettingsOpeningAdapter(fullDiskAccess: _fullDiskAccess),
      ),
    ],
  );
}

late _RecordingFullDiskAccess _fullDiskAccess;

final class _RecordingFullDiskAccess implements FullDiskAccess {
  var openSettingsCalls = 0;

  @override
  String get messagesDatabasePath => '/tmp/chat.db';

  @override
  bool canReadMessagesDatabase() => false;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() {
    return MessagesSourceAccessResult.unavailable;
  }

  @override
  Future<void> openSettings() async {
    openSettingsCalls += 1;
  }
}

Future<void> _waitForPhase(
  ProviderContainer container,
  AppCzarOnboardingPhase phase,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (container.read(appCzarOnboardingControllerProvider).phase == phase) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Did not reach ${phase.name}.');
}

final class _OnboardingReader
    implements
        AppCzarObservationReader,
        AppCzarInitialConstructionScopeReader,
        AppCzarContactsPrerequisiteReader {
  _OnboardingReader({
    this.source = _readableSource,
    this.sourceAfterAssessment,
    this.throwOnSecondSourceRead = false,
    this.scopeAfterAssessment,
    this.contacts = _viableContacts,
    this.contactsAfterAssessment,
  });

  AppCzarSourceObservation source;
  final AppCzarSourceObservation? sourceAfterAssessment;
  final bool throwOnSecondSourceRead;
  final AppCzarInitialConstructionScopeObservation? scopeAfterAssessment;
  AppCzarContactsPrerequisiteObservation contacts;
  final AppCzarContactsPrerequisiteObservation? contactsAfterAssessment;
  int scopeReads = 0;
  int sourceReads = 0;
  int contactsReads = 0;

  @override
  Future<AppCzarInitialConstructionScopeObservation>
  readInitialConstructionScope() async {
    scopeReads += 1;
    if (scopeReads > 1 && scopeAfterAssessment != null) {
      return scopeAfterAssessment!;
    }
    return _safeEmptyScope;
  }

  @override
  Future<AppCzarContactsPrerequisiteObservation>
  readContactsPrerequisite() async {
    contactsReads += 1;
    if (contactsReads > 1 && contactsAfterAssessment != null) {
      return contactsAfterAssessment!;
    }
    return contacts;
  }

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    return _archive;
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    return const AppCzarDatabaseObservation.absent();
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return const AppCzarRootObservation(admitted: true, path: '/tmp/root');
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    sourceReads += 1;
    if (sourceReads > 1 && throwOnSecondSourceRead) {
      throw StateError('source read failed');
    }
    if (sourceReads > 1 && sourceAfterAssessment != null) {
      return sourceAfterAssessment!;
    }
    return source;
  }
}

final class _BuildExecutor implements AppCzarOnboardingBuildExecutor {
  _BuildExecutor({this.block = false, this.fail = false});

  final bool block;
  final bool fail;
  final Completer<void> started = Completer<void>();
  final Completer<void> release = Completer<void>();
  int calls = 0;
  ConversationGraphBuildObserver? _observer;

  void publishProgress({required int completed}) {
    _observer?.call(
      ConversationGraphBuildObservation(
        suboperation: ConversationGraphBuildSuboperation.importMessages,
        kind: ConversationGraphBuildObservationKind.progress,
        completedWorkCount: completed,
        totalWorkCount: 2,
      ),
    );
  }

  @override
  Future<void> run({
    required ConversationGraphBuildObserver onObservation,
  }) async {
    calls += 1;
    if (!started.isCompleted) {
      started.complete();
    }
    _observer = onObservation;
    onObservation(
      const ConversationGraphBuildObservation(
        suboperation: ConversationGraphBuildSuboperation.importMessages,
        kind: ConversationGraphBuildObservationKind.progress,
        completedWorkCount: 1,
        totalWorkCount: 2,
      ),
    );
    if (block) {
      await release.future;
    }
    if (fail) {
      throw StateError('build failed after admission');
    }
  }
}

final class _Restarter implements AppCzarProcessRestarter {
  final Completer<void> called = Completer<void>();
  int calls = 0;

  @override
  Future<void> restartAndReassess() async {
    calls += 1;
    if (!called.isCompleted) {
      called.complete();
    }
  }
}

const _readableSource = AppCzarSourceObservation(
  condition: AppCzarSourceCondition.readable,
  messageCount: 10,
  maxRowId: 10,
  sampleStable: true,
);

const _safeEmptyScope = AppCzarInitialConstructionScopeObservation(
  condition: AppCzarInitialConstructionScopeCondition.safeEmpty,
  importMessageCount: 0,
  graphMessageCount: 0,
  graphChatCount: 0,
  graphEdgeCount: 0,
  nonLiveSourceCount: 0,
  hasRetiredDerivedArtifacts: false,
  issue: null,
);

const _viableContacts = AppCzarContactsPrerequisiteObservation(
  condition: AppCzarContactsPrerequisiteCondition.viableEmpty,
  contactCount: 0,
  viableStoreCount: 1,
);

const _archive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.notCreated,
  label: 'Default archive',
  archiveScopeIdentity: 'scope',
  archiveGeneration: 0,
  resolvedPath: '/tmp/root/attachment_archive',
  coverage: AppCzarAttachmentCoverageObservation(
    condition: AppCzarAttachmentCoverageCondition.complete,
    requiredCount: 0,
    coveredCount: 0,
    missingCount: 0,
    unverifiableCount: 0,
    archiveScopeIdentity: 'scope',
    archiveGeneration: 0,
  ),
  repairability: AppCzarAttachmentRepairabilityObservation(
    condition: AppCzarAttachmentRepairOpportunityCondition.absent,
    availableFromMessagesCount: 0,
    sourceAbsentCount: 0,
    sourceUnknownCount: 0,
    recordBackedRecoveryCount: 0,
    unsafeOrConflictingCount: 0,
    archiveScopeIdentity: 'scope',
    archiveGeneration: 0,
  ),
);

AppCzarAssessmentState _assessmentState({
  required AppCzarVirtualCoordinator coordinator,
}) {
  return AppCzarAssessmentState(
    generation: 1,
    root: const AppCzarRootObservation(admitted: true, path: '/tmp/root'),
    initialConstructionScope: _safeEmptyScope,
    source: _readableSource,
    contactsPrerequisite: _viableContacts,
    importStore: const AppCzarDatabaseObservation.absent(),
    graphStore: const AppCzarDatabaseObservation.absent(),
    overlay: const AppCzarDatabaseObservation.absent(),
    attachmentArchive: _archive,
    assessment: AppCzarAssessment(
      facts: const <AppCzarFact>[
        AppCzarFact(
          id: AppCzarFactId.developmentRootAdmitted,
          label: 'root',
          truth: AppCzarTruth.trueValue,
          detail: 'admitted',
        ),
        AppCzarFact(
          id: AppCzarFactId.initialConstructionScopeSafe,
          label: 'scope',
          truth: AppCzarTruth.trueValue,
          detail: 'safe',
        ),
        AppCzarFact(
          id: AppCzarFactId.messagesSourceReadable,
          label: 'source',
          truth: AppCzarTruth.trueValue,
          detail: 'readable',
        ),
        AppCzarFact(
          id: AppCzarFactId.attachmentArchiveAvailable,
          label: 'archive',
          truth: AppCzarTruth.trueValue,
          detail: 'available',
        ),
      ],
      diagnosisKind: AppCzarDiagnosisKind.incompleteLocalDataset,
      diagnosis: 'test',
      virtualCoordinator: coordinator,
    ),
  );
}
