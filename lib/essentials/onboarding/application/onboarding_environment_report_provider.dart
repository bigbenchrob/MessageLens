import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import '../../../features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import '../../../features/address_book_folders/feature_level_providers.dart'
    show futureGetFolderAggregateProvider;
import '../../../features/attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocationAvailability,
        AttachmentArchiveLocationState,
        attachmentArchiveLocationProvider,
        readAttachmentArchiveLocationEvidenceWithAdmission;
import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCapability,
        archiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import '../../conversation_graph/feature_level_providers.dart'
    show
        ChatDbChangeMonitorState,
        ConversationGraphBuildState,
        chatDbChangeMonitorProvider,
        conversationGraphBuildControllerProvider;
import '../../db/app_database_files.dart';
import '../../db/application/conversation_graph_readiness.dart';
import '../../db/feature_level_providers.dart' show dbMaintenanceLockProvider;
import '../domain/onboarding_environment_report.dart';
import 'full_disk_access_provider.dart';
import 'messages_source_history_sufficiency_policy.dart';
import 'onboarding_database_probe_reader.dart';
import 'onboarding_database_probe_reader_provider.dart';
import 'onboarding_failure_storage_provider.dart';
import 'onboarding_failure_store.dart';

part 'onboarding_environment_report_provider.g.dart';

const int _automaticRecoveryMinimumImportRows = 25;
const double _automaticRecoveryGraphToImportRatio = 0.5;
const int _maximumAdmittedMaterialEvidenceAttempts = 2;

class OnboardingDevOverridesState {
  const OnboardingDevOverridesState({
    this.simulateFullDiskAccessBlocked = false,
    this.simulateMessagesDatabaseMissing = false,
    this.simulateAddressBookUnavailable = false,
    this.simulateSparseSourceHistory = false,
    this.simulateImportFailure = false,
    this.simulateGraphProjectionFailure = false,
  });

  final bool simulateFullDiskAccessBlocked;
  final bool simulateMessagesDatabaseMissing;
  final bool simulateAddressBookUnavailable;
  final bool simulateSparseSourceHistory;
  final bool simulateImportFailure;
  final bool simulateGraphProjectionFailure;

  bool get hasAnyOverride {
    return simulateFullDiskAccessBlocked ||
        simulateMessagesDatabaseMissing ||
        simulateAddressBookUnavailable ||
        simulateSparseSourceHistory ||
        simulateImportFailure ||
        simulateGraphProjectionFailure;
  }

  OnboardingDevOverridesState copyWith({
    bool? simulateFullDiskAccessBlocked,
    bool? simulateMessagesDatabaseMissing,
    bool? simulateAddressBookUnavailable,
    bool? simulateSparseSourceHistory,
    bool? simulateImportFailure,
    bool? simulateGraphProjectionFailure,
  }) {
    return OnboardingDevOverridesState(
      simulateFullDiskAccessBlocked:
          simulateFullDiskAccessBlocked ?? this.simulateFullDiskAccessBlocked,
      simulateMessagesDatabaseMissing:
          simulateMessagesDatabaseMissing ??
          this.simulateMessagesDatabaseMissing,
      simulateAddressBookUnavailable:
          simulateAddressBookUnavailable ?? this.simulateAddressBookUnavailable,
      simulateSparseSourceHistory:
          simulateSparseSourceHistory ?? this.simulateSparseSourceHistory,
      simulateImportFailure:
          simulateImportFailure ?? this.simulateImportFailure,
      simulateGraphProjectionFailure:
          simulateGraphProjectionFailure ?? this.simulateGraphProjectionFailure,
    );
  }
}

@Riverpod(keepAlive: true)
class OnboardingDevOverrides extends _$OnboardingDevOverrides {
  @override
  OnboardingDevOverridesState build() {
    return const OnboardingDevOverridesState();
  }

  void setFullDiskAccessBlocked({required bool enabled}) {
    state = state.copyWith(simulateFullDiskAccessBlocked: enabled);
  }

  void setMessagesDatabaseMissing({required bool enabled}) {
    state = state.copyWith(simulateMessagesDatabaseMissing: enabled);
  }

  void setAddressBookUnavailable({required bool enabled}) {
    state = state.copyWith(simulateAddressBookUnavailable: enabled);
  }

  void setSparseSourceHistory({required bool enabled}) {
    state = state.copyWith(simulateSparseSourceHistory: enabled);
  }

  void setImportFailure({required bool enabled}) {
    state = state.copyWith(simulateImportFailure: enabled);
  }

  void setGraphProjectionFailure({required bool enabled}) {
    state = state.copyWith(simulateGraphProjectionFailure: enabled);
  }

  void clearAll() {
    state = const OnboardingDevOverridesState();
  }
}

@Riverpod(keepAlive: true)
bool onboardingFullDiskAccess(Ref ref) {
  return ref.watch(fullDiskAccessProvider).canReadMessagesDatabase();
}

@Riverpod(keepAlive: true)
String onboardingMessagesDatabasePath(Ref ref) {
  return ref.watch(fullDiskAccessProvider).messagesDatabasePath;
}

@Riverpod(keepAlive: true)
String onboardingDatabaseDirectoryPath(Ref ref) {
  return ref.watch(archiveAccessAuthorityProvider).rootPath;
}

@Riverpod(keepAlive: true)
Future<OnboardingEnvironmentReport> onboardingEnvironmentReport(Ref ref) async {
  final failureEvidence = await _readPersistedFailureEvidence(
    ref.watch(onboardingFailureStorageProvider),
  );
  await _readMaterialOnboardingEvidence(
    read: () => ref.watch(attachmentArchiveLocationProvider.future),
  );
  await _readMaterialOnboardingEvidence(
    read: () => ref.watch(futureGetFolderAggregateProvider.future),
  );
  final inputs = _readOnboardingEnvironmentInputs(
    ref,
    reactive: true,
    addressBookEither: ref.watch(futureGetFolderAggregateProvider).requireValue,
    attachmentArchiveLocation: ref
        .watch(attachmentArchiveLocationProvider)
        .requireValue,
    failureEvidence: failureEvidence,
    // Readiness is an unrelated observer of the derived stores. Suppress its
    // database reads for every admitted archive mutation, including onboarding
    // import, even when that operation does not globally block its own graph
    // connection from reopening.
    isMaintenanceLocked:
        ref.watch(dbMaintenanceLockProvider) ||
        ref.watch(
          archiveMutationCoordinatorProvider.select((state) => state.isLocked),
        ),
  );
  final evaluator = _OnboardingEnvironmentEvaluator(inputs);
  return evaluator.evaluate();
}

/// Recomputes current onboarding environment evidence for one admitted owner.
///
/// This is deliberately a one-shot read rather than a provider: the aggregate
/// environment report remains owner-agnostic, while the Journey coordinator
/// may inspect its own derived stores without treating its exact mutation
/// scope as foreign maintenance. Both the capability and each derived-resource
/// admission are checked before and after every awaited evidence boundary.
Future<OnboardingEnvironmentReport> readAdmittedOnboardingEnvironmentEvidence(
  Ref ref, {
  required ArchiveMutationCapability capability,
  required ArchiveMutationOperation expectedOperation,
}) async {
  void requireExactCapability() {
    capability.requireOperation(expectedOperation);
  }

  void requireResourceAdmission(ArchiveMutationResourceAction action) {
    requireExactCapability();
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    final admission = coordinator.resourceAdmissionForCurrentCaller(action);
    if (!admission.isAllowed) {
      throw StateError(
        'The current archive-mutation owner is not admitted for '
        '${action.name}.',
      );
    }
  }

  void requirePersistentArchiveStoreAdmission() {
    requireResourceAdmission(
      ArchiveMutationResourceAction.openPersistentArchiveStore,
    );
  }

  void requireAllReportResourceAdmissions() {
    requirePersistentArchiveStoreAdmission();
    requireResourceAdmission(
      ArchiveMutationResourceAction.openConversationGraphConnection,
    );
  }

  _OnboardingMaterialEvidence? coherentEvidence;
  for (
    var attempt = 0;
    attempt < _maximumAdmittedMaterialEvidenceAttempts;
    attempt += 1
  ) {
    final first = await _readAdmittedMaterialOnboardingEvidence(
      ref,
      requireExactCapability: requireExactCapability,
      requirePersistentArchiveStoreAdmission:
          requirePersistentArchiveStoreAdmission,
    );
    final second = await _readAdmittedMaterialOnboardingEvidence(
      ref,
      requireExactCapability: requireExactCapability,
      requirePersistentArchiveStoreAdmission:
          requirePersistentArchiveStoreAdmission,
    );
    if (first.hasSameRevisionAs(second)) {
      coherentEvidence = second;
      break;
    }
  }
  if (coherentEvidence == null) {
    throw StateError(
      'Onboarding material evidence did not stabilize after one bounded '
      'retry.',
    );
  }

  // Every asynchronous evidence dependency is settled and admission has just
  // been re-proven. Re-read mutable prerequisites now so the returned report
  // cannot silently carry the values that existed before an internal await.
  final inputs = _readOnboardingEnvironmentInputs(
    ref,
    reactive: false,
    addressBookEither: coherentEvidence.addressBookEither,
    attachmentArchiveLocation: coherentEvidence.attachmentArchiveLocation,
    failureEvidence: coherentEvidence.failureEvidence,
    // The exact admitted owner does not classify its own non-blocking lock as
    // maintenance. A stronger database-reopen policy was already checked via
    // both resource admissions above and is checked again before evaluation.
    isMaintenanceLocked: ref.read(dbMaintenanceLockProvider),
  );
  requireAllReportResourceAdmissions();
  return _OnboardingEnvironmentEvaluator(inputs).evaluate();
}

Future<_OnboardingMaterialEvidence> _readAdmittedMaterialOnboardingEvidence(
  Ref ref, {
  required void Function() requireExactCapability,
  required void Function() requirePersistentArchiveStoreAdmission,
}) async {
  final failureEvidence = await _readPersistedFailureEvidence(
    ref.read(onboardingFailureStorageProvider),
    requirePersistentArchiveStoreAdmission:
        requirePersistentArchiveStoreAdmission,
  );
  final attachmentArchiveLocation =
      await readAttachmentArchiveLocationEvidenceWithAdmission(
        ref,
        requirePersistentArchiveStoreAdmission:
            requirePersistentArchiveStoreAdmission,
      );
  final addressBookEither = await _readMaterialOnboardingEvidence(
    requireCurrentAdmission: requireExactCapability,
    read: () => ref.read(futureGetFolderAggregateProvider.future),
  );
  return _OnboardingMaterialEvidence(
    failureEvidence: failureEvidence,
    attachmentArchiveLocation: attachmentArchiveLocation,
    addressBookEither: addressBookEither,
  );
}

Future<T> _readMaterialOnboardingEvidence<T>({
  required Future<T> Function() read,
  void Function()? requireCurrentAdmission,
}) async {
  requireCurrentAdmission?.call();
  final evidence = await read();
  requireCurrentAdmission?.call();
  return evidence;
}

Future<_OnboardingPersistedFailureEvidence> _readPersistedFailureEvidence(
  OnboardingFailureStore failureStorage, {
  void Function()? requirePersistentArchiveStoreAdmission,
}) async {
  final sourceImport = await _readMaterialOnboardingEvidence(
    requireCurrentAdmission: requirePersistentArchiveStoreAdmission,
    read: () => failureStorage.loadSourceImportFailureEntry(
      requirePersistentArchiveStoreAdmission:
          requirePersistentArchiveStoreAdmission,
    ),
  );
  final graphProjection = await _readMaterialOnboardingEvidence(
    requireCurrentAdmission: requirePersistentArchiveStoreAdmission,
    read: () => failureStorage.loadGraphProjectionFailureEntry(
      requirePersistentArchiveStoreAdmission:
          requirePersistentArchiveStoreAdmission,
    ),
  );
  return _OnboardingPersistedFailureEvidence(
    sourceImport: sourceImport,
    graphProjection: graphProjection,
  );
}

_OnboardingEnvironmentInputs _readOnboardingEnvironmentInputs(
  Ref ref, {
  required bool reactive,
  required Either<FolderRetrievalFailure, AddressBookFolderAggregate>
  addressBookEither,
  required AttachmentArchiveLocationState attachmentArchiveLocation,
  required _OnboardingPersistedFailureEvidence failureEvidence,
  required bool isMaintenanceLocked,
}) {
  T observe<T>(ProviderListenable<T> provider) {
    if (reactive) {
      return ref.watch(provider);
    }
    return ref.read(provider);
  }

  return _OnboardingEnvironmentInputs(
    devOverrides: observe(onboardingDevOverridesProvider),
    databaseProbeReader: observe(onboardingDatabaseProbeReaderProvider),
    hasFullDiskAccess: observe(onboardingFullDiskAccessProvider),
    messagesDatabasePath: observe(onboardingMessagesDatabasePathProvider),
    addressBookEither: addressBookEither,
    archiveRootPath: observe(onboardingDatabaseDirectoryPathProvider),
    attachmentArchiveLocation: attachmentArchiveLocation,
    failureEvidence: failureEvidence,
    isMaintenanceLocked: isMaintenanceLocked,
    graphBuildState: observe(conversationGraphBuildControllerProvider),
    liveUpdateMonitorState: observe(chatDbChangeMonitorProvider),
  );
}

class _OnboardingPersistedFailureEvidence {
  const _OnboardingPersistedFailureEvidence({
    required this.sourceImport,
    required this.graphProjection,
  });

  final PersistedOnboardingSourceImportFailure? sourceImport;
  final PersistedOnboardingGraphProjectionFailure? graphProjection;

  bool hasSameRevisionAs(_OnboardingPersistedFailureEvidence other) {
    return _hasSameSourceFailure(sourceImport, other.sourceImport) &&
        _hasSameGraphFailure(graphProjection, other.graphProjection);
  }

  static bool _hasSameSourceFailure(
    PersistedOnboardingSourceImportFailure? left,
    PersistedOnboardingSourceImportFailure? right,
  ) {
    return left?.recordedAt == right?.recordedAt &&
        left?.failure.phase == right?.failure.phase &&
        left?.failure.batchId == right?.failure.batchId &&
        left?.failure.message == right?.failure.message;
  }

  static bool _hasSameGraphFailure(
    PersistedOnboardingGraphProjectionFailure? left,
    PersistedOnboardingGraphProjectionFailure? right,
  ) {
    return left?.recordedAt == right?.recordedAt &&
        left?.failure.phase == right?.failure.phase &&
        left?.failure.batchId == right?.failure.batchId &&
        left?.failure.message == right?.failure.message;
  }
}

class _OnboardingMaterialEvidence {
  _OnboardingMaterialEvidence({
    required this.failureEvidence,
    required this.attachmentArchiveLocation,
    required this.addressBookEither,
  }) : addressBookFingerprint = _addressBookFingerprint(addressBookEither);

  final _OnboardingPersistedFailureEvidence failureEvidence;
  final AttachmentArchiveLocationState attachmentArchiveLocation;
  final Either<FolderRetrievalFailure, AddressBookFolderAggregate>
  addressBookEither;
  final (bool isAvailable, String value) addressBookFingerprint;

  bool hasSameRevisionAs(_OnboardingMaterialEvidence other) {
    return failureEvidence.hasSameRevisionAs(other.failureEvidence) &&
        attachmentArchiveLocation == other.attachmentArchiveLocation &&
        addressBookFingerprint == other.addressBookFingerprint;
  }

  static (bool isAvailable, String value) _addressBookFingerprint(
    Either<FolderRetrievalFailure, AddressBookFolderAggregate> evidence,
  ) {
    return evidence.fold(
      (failure) => (false, failure.message),
      (aggregate) => (true, aggregate.mostRecentFolderPath),
    );
  }
}

class _OnboardingEnvironmentInputs {
  const _OnboardingEnvironmentInputs({
    required this.devOverrides,
    required this.databaseProbeReader,
    required this.hasFullDiskAccess,
    required this.messagesDatabasePath,
    required this.addressBookEither,
    required this.archiveRootPath,
    required this.attachmentArchiveLocation,
    required this.failureEvidence,
    required this.isMaintenanceLocked,
    required this.graphBuildState,
    required this.liveUpdateMonitorState,
  });

  final OnboardingDevOverridesState devOverrides;
  final OnboardingDatabaseProbeReader databaseProbeReader;
  final bool hasFullDiskAccess;
  final String messagesDatabasePath;
  final Either<FolderRetrievalFailure, AddressBookFolderAggregate>
  addressBookEither;
  final String archiveRootPath;
  final AttachmentArchiveLocationState attachmentArchiveLocation;
  final _OnboardingPersistedFailureEvidence failureEvidence;
  final bool isMaintenanceLocked;
  final ConversationGraphBuildState graphBuildState;
  final ChatDbChangeMonitorState liveUpdateMonitorState;
}

class _OnboardingEnvironmentEvaluator {
  const _OnboardingEnvironmentEvaluator(this.inputs);

  final _OnboardingEnvironmentInputs inputs;

  OnboardingEnvironmentReport evaluate() {
    final devOverrides = inputs.devOverrides;
    final databaseProbeReader = inputs.databaseProbeReader;
    final persistedImportEntry = inputs.failureEvidence.sourceImport;
    final persistedGraphProjectionEntry =
        inputs.failureEvidence.graphProjection;
    final persistedImportFailure = persistedImportEntry?.failure;
    final persistedGraphProjectionFailure =
        persistedGraphProjectionEntry?.failure;
    final simulatedPipelineFailureActive =
        devOverrides.simulateImportFailure ||
        devOverrides.simulateGraphProjectionFailure;
    final lastImportFailure = devOverrides.simulateImportFailure
        ? const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            batchId: -1,
            message: 'Simulated import failure from onboarding dev panel',
          )
        : simulatedPipelineFailureActive
        ? null
        : persistedImportFailure;
    final lastGraphProjectionFailure =
        devOverrides.simulateGraphProjectionFailure
        ? const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.graphProjection,
            batchId: -1,
            message:
                'Simulated graph projection failure from onboarding dev panel',
          )
        : simulatedPipelineFailureActive
        ? null
        : persistedGraphProjectionFailure;
    var hasFullDiskAccess = inputs.hasFullDiskAccess;
    if (devOverrides.simulateFullDiskAccessBlocked) {
      hasFullDiskAccess = false;
    }
    final messagesDatabasePath = inputs.messagesDatabasePath;
    final messagesProbe = devOverrides.simulateMessagesDatabaseMissing
        ? OnboardingDatabaseProbe(
            path: messagesDatabasePath,
            exists: false,
            readable: false,
          )
        : databaseProbeReader.probeFile(messagesDatabasePath);

    final addressBookProbe = devOverrides.simulateAddressBookUnavailable
        ? const _AddressBookProbeResult(
            probe: null,
            failureMessage:
                'Simulated unavailable Contacts source from onboarding dev panel',
          )
        : _probeAddressBook(databaseProbeReader, inputs.addressBookEither);

    final sourceScopedImportDbPath = appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: inputs.archiveRootPath,
    );
    final overlayDbPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: inputs.archiveRootPath,
    );
    final graphDbPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: inputs.archiveRootPath,
    );
    final attachmentArchiveLocation = inputs.attachmentArchiveLocation;
    final attachmentArchiveProbe = attachmentArchiveLocation.isAvailable
        ? databaseProbeReader.probeDirectory(
            attachmentArchiveLocation.requireArchiveRootPath(),
          )
        : OnboardingDatabaseProbe(
            path: attachmentArchiveLocation.lastKnownDisplayPath ?? '',
            exists: false,
            readable: false,
            failureMessage:
                attachmentArchiveLocation.issue ??
                'The configured external attachment archive is unavailable.',
          );
    final attachmentArchiveStatus =
        switch (attachmentArchiveLocation.availability) {
          AttachmentArchiveLocationAvailability.defaultAvailable ||
          AttachmentArchiveLocationAvailability.customAvailable =>
            OnboardingAttachmentArchiveStatus.available,
          AttachmentArchiveLocationAvailability.customReadOnly =>
            OnboardingAttachmentArchiveStatus.readOnly,
          _ => OnboardingAttachmentArchiveStatus.unavailable,
        };
    final isMaintenanceLocked = inputs.isMaintenanceLocked;

    final sourceMessageCount = devOverrides.simulateSparseSourceHistory
        ? 0
        : databaseProbeReader.readTableCount(
            dbPath: messagesDatabasePath,
            tableName: 'message',
            queryOnly: true,
          );
    final sourceAttachmentCount = databaseProbeReader.readTableCount(
      dbPath: messagesDatabasePath,
      tableName: 'attachment',
      queryOnly: true,
    );

    // Maintenance owns the derived stores. Readiness reports that truthful
    // state without opening either store for unrelated observational counts.
    final importRowCount = isMaintenanceLocked
        ? null
        : databaseProbeReader.readTableCount(
            dbPath: sourceScopedImportDbPath,
            tableName: 'messages',
          );
    final graphRowCount = isMaintenanceLocked
        ? null
        : databaseProbeReader.readTableCount(
            dbPath: graphDbPath,
            tableName: 'messages',
          );
    final graphReadiness = isMaintenanceLocked
        ? const ConversationGraphReadiness(
            isReady: false,
            reason: 'database maintenance is active',
            messageCount: 0,
            chatCount: 0,
            chatToMessageEdgeCount: 0,
          )
        : databaseProbeReader.readConversationGraphReadiness(graphDbPath);

    final importProbe = databaseProbeReader.probeFile(
      sourceScopedImportDbPath,
      rowCount: importRowCount,
    );
    final overlayProbe = databaseProbeReader.probeFile(overlayDbPath);
    final graphProbe = databaseProbeReader.probeFile(
      graphDbPath,
      rowCount: graphRowCount,
    );
    final usingPersistedImportFailure =
        !devOverrides.simulateImportFailure &&
        !simulatedPipelineFailureActive &&
        persistedImportEntry != null;
    final usingPersistedGraphProjectionFailure =
        !devOverrides.simulateGraphProjectionFailure &&
        !simulatedPipelineFailureActive &&
        persistedGraphProjectionEntry != null;
    final resetAppDatabasesReason = _detectResetAppDatabasesReason(
      isMaintenanceLocked: isMaintenanceLocked,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      sourceMessageCount: sourceMessageCount,
      importProbe: importProbe,
      graphProbe: graphProbe,
    );

    final state = _classifyState(
      hasFullDiskAccess: hasFullDiskAccess,
      messagesProbe: messagesProbe,
      addressBookProbe: addressBookProbe,
      sourceMessageCount: sourceMessageCount,
      isMaintenanceLocked: isMaintenanceLocked,
      forceImportFailure: devOverrides.simulateImportFailure,
      forceGraphProjectionFailure: devOverrides.simulateGraphProjectionFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      resetAppDatabasesReason: resetAppDatabasesReason,
      graphProjectionReady: graphReadiness.isReady,
      importProbe: importProbe,
      graphProbe: graphProbe,
    );

    final blockerKind = _classifyBlocker(
      state: state,
      hasFullDiskAccess: hasFullDiskAccess,
      messagesProbe: messagesProbe,
      addressBookProbe: addressBookProbe,
      sourceMessageCount: sourceMessageCount,
      isMaintenanceLocked: isMaintenanceLocked,
      forceImportFailure: devOverrides.simulateImportFailure,
      forceGraphProjectionFailure: devOverrides.simulateGraphProjectionFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      resetAppDatabasesReason: resetAppDatabasesReason,
      graphProjectionReady: graphReadiness.isReady,
      importProbe: importProbe,
      graphProbe: graphProbe,
    );

    final syncPlausibility = _classifySyncPlausibility(
      hasFullDiskAccess: hasFullDiskAccess,
      sourceMessageCount: sourceMessageCount,
    );

    return OnboardingEnvironmentReport(
      state: state,
      blockerKind: blockerKind,
      syncPlausibility: syncPlausibility,
      messagesDatabase: messagesProbe.copyWith(rowCount: sourceMessageCount),
      addressBookDatabase: addressBookProbe.probe,
      overlayDatabase: overlayProbe,
      sourceScopedImportDatabase: importProbe,
      conversationGraph: graphProbe,
      attachmentArchiveDirectory: attachmentArchiveProbe,
      hasFullDiskAccess: hasFullDiskAccess,
      sourceAttachmentCount: sourceAttachmentCount,
      addressBookFailureMessage: addressBookProbe.failureMessage,
      lastImportFailure: lastImportFailure,
      lastGraphProjectionFailure: lastGraphProjectionFailure,
      lastImportFailureRecordedAt: persistedImportEntry?.recordedAt,
      lastGraphProjectionFailureRecordedAt:
          persistedGraphProjectionEntry?.recordedAt,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      shouldResetAppDatabasesBeforeImport: resetAppDatabasesReason != null,
      resetAppDatabasesReason: resetAppDatabasesReason,
      graphBuildStatusLabel: inputs.graphBuildState.status.name,
      graphBuildFinishedAt: inputs.graphBuildState.finishedAt,
      graphBuildLastError: inputs.graphBuildState.lastError,
      liveUpdateCursorRowId: inputs.liveUpdateMonitorState.lastMaxRowId,
      liveUpdateLastChangeDetectedAt:
          inputs.liveUpdateMonitorState.lastChangeDetected,
      liveUpdateLastError: inputs.liveUpdateMonitorState.lastError,
      attachmentArchiveStatus: attachmentArchiveStatus,
      attachmentArchiveIssue: attachmentArchiveLocation.issue,
      attachmentArchiveLocationGeneration: attachmentArchiveLocation.generation,
    );
  }

  OnboardingEnvironmentState _classifyState({
    required bool hasFullDiskAccess,
    required OnboardingDatabaseProbe messagesProbe,
    required _AddressBookProbeResult addressBookProbe,
    required int? sourceMessageCount,
    required bool isMaintenanceLocked,
    required bool forceImportFailure,
    required bool forceGraphProjectionFailure,
    required bool usingPersistedImportFailure,
    required bool usingPersistedGraphProjectionFailure,
    required String? resetAppDatabasesReason,
    required bool graphProjectionReady,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (!hasFullDiskAccess || !messagesProbe.readable) {
      return OnboardingEnvironmentState.permissionBlocked;
    }

    if (!messagesProbe.exists || !addressBookProbe.isAvailable) {
      return OnboardingEnvironmentState.sourceUnavailable;
    }

    if (sourceMessageCount != null &&
        !isMessagesSourceHistorySufficient(sourceMessageCount)) {
      return OnboardingEnvironmentState.sourceSparseOrUnsynced;
    }

    if (isMaintenanceLocked) {
      return OnboardingEnvironmentState.maintenanceInProgress;
    }

    if (forceGraphProjectionFailure) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (forceImportFailure) {
      return OnboardingEnvironmentState.importFailed;
    }

    if (resetAppDatabasesReason != null) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (importProbe.hasData && graphProjectionReady) {
      return OnboardingEnvironmentState.ready;
    }

    if (importProbe.hasData && graphProbe.exists && !graphProjectionReady) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (_shouldSurfaceGraphProjectionFailure(
      forceGraphProjectionFailure: forceGraphProjectionFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (_shouldSurfaceImportFailure(
      forceImportFailure: forceImportFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingEnvironmentState.importFailed;
    }

    return OnboardingEnvironmentState.readyToImport;
  }

  OnboardingBlockerKind _classifyBlocker({
    required OnboardingEnvironmentState state,
    required bool hasFullDiskAccess,
    required OnboardingDatabaseProbe messagesProbe,
    required _AddressBookProbeResult addressBookProbe,
    required int? sourceMessageCount,
    required bool isMaintenanceLocked,
    required bool forceImportFailure,
    required bool forceGraphProjectionFailure,
    required bool usingPersistedImportFailure,
    required bool usingPersistedGraphProjectionFailure,
    required String? resetAppDatabasesReason,
    required bool graphProjectionReady,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (!hasFullDiskAccess || !messagesProbe.readable) {
      return OnboardingBlockerKind.fullDiskAccessMissing;
    }

    if (!messagesProbe.exists) {
      return OnboardingBlockerKind.messagesDatabaseMissing;
    }

    if (!addressBookProbe.isAvailable) {
      return OnboardingBlockerKind.addressBookUnavailable;
    }

    if (state == OnboardingEnvironmentState.sourceSparseOrUnsynced ||
        (sourceMessageCount != null &&
            !isMessagesSourceHistorySufficient(sourceMessageCount))) {
      return OnboardingBlockerKind.sourceDataSparseOrUnsynced;
    }

    if (isMaintenanceLocked) {
      return OnboardingBlockerKind.none;
    }

    if (forceGraphProjectionFailure) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (forceImportFailure) {
      return OnboardingBlockerKind.importFailed;
    }

    if (resetAppDatabasesReason != null) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (state == OnboardingEnvironmentState.ready) {
      return OnboardingBlockerKind.none;
    }

    if (importProbe.hasData && graphProbe.exists && !graphProjectionReady) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (_shouldSurfaceGraphProjectionFailure(
      forceGraphProjectionFailure: forceGraphProjectionFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (_shouldSurfaceImportFailure(
      forceImportFailure: forceImportFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingBlockerKind.importFailed;
    }

    if (!importProbe.exists) {
      return OnboardingBlockerKind.sourceScopedImportDatabaseMissing;
    }

    if (!graphProbe.exists) {
      return OnboardingBlockerKind.conversationGraphMissing;
    }

    if (!importProbe.hasData) {
      return OnboardingBlockerKind.sourceScopedImportDatabaseEmpty;
    }

    if (!graphProbe.hasData) {
      return OnboardingBlockerKind.conversationGraphEmpty;
    }

    return OnboardingBlockerKind.none;
  }

  bool _shouldSurfaceImportFailure({
    required bool forceImportFailure,
    required bool usingPersistedImportFailure,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (forceImportFailure) {
      return true;
    }

    if (!usingPersistedImportFailure) {
      return false;
    }

    return importProbe.hasData || graphProbe.hasData;
  }

  bool _shouldSurfaceGraphProjectionFailure({
    required bool forceGraphProjectionFailure,
    required bool usingPersistedGraphProjectionFailure,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (forceGraphProjectionFailure) {
      return true;
    }

    if (!usingPersistedGraphProjectionFailure) {
      return false;
    }

    return importProbe.hasData || graphProbe.hasData;
  }

  OnboardingSyncPlausibility _classifySyncPlausibility({
    required bool hasFullDiskAccess,
    required int? sourceMessageCount,
  }) {
    if (!hasFullDiskAccess || sourceMessageCount == null) {
      return OnboardingSyncPlausibility.unknown;
    }

    if (!isMessagesSourceHistorySufficient(sourceMessageCount)) {
      return OnboardingSyncPlausibility.likelySparseOrUnsynced;
    }

    return OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable;
  }

  _AddressBookProbeResult _probeAddressBook(
    OnboardingDatabaseProbeReader databaseProbeReader,
    Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    addressBookEither,
  ) {
    return addressBookEither.fold(
      (failure) =>
          _AddressBookProbeResult(probe: null, failureMessage: failure.message),
      (aggregate) {
        final filePath = aggregate.mostRecentFolderPath;
        return _AddressBookProbeResult(
          probe: databaseProbeReader.probeFile(filePath),
        );
      },
    );
  }

  String? _detectResetAppDatabasesReason({
    required bool isMaintenanceLocked,
    required bool usingPersistedImportFailure,
    required bool usingPersistedGraphProjectionFailure,
    required int? sourceMessageCount,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (isMaintenanceLocked || !importProbe.hasData) {
      return null;
    }

    final importCount = importProbe.rowCount;
    if (importCount == null ||
        importCount < _automaticRecoveryMinimumImportRows) {
      return null;
    }

    final graphCount = graphProbe.rowCount ?? 0;
    final hasRecordedFailure =
        usingPersistedImportFailure || usingPersistedGraphProjectionFailure;
    final importTracksSource =
        sourceMessageCount == null ||
        !isMessagesSourceHistorySufficient(sourceMessageCount) ||
        importCount >=
            (sourceMessageCount * _automaticRecoveryGraphToImportRatio).round();
    final graphClearlyIncomplete =
        !graphProbe.hasData ||
        graphCount <
            (importCount * _automaticRecoveryGraphToImportRatio).round();

    if (!importTracksSource || !graphClearlyIncomplete) {
      return null;
    }

    if (hasRecordedFailure) {
      return 'A previous import or graph projection failure left a populated import ledger but an incomplete conversation graph.';
    }

    if (graphProbe.hasData) {
      return 'The conversation graph contains far fewer messages than the import ledger, which strongly suggests an incomplete graph projection.';
    }

    return null;
  }
}

class _AddressBookProbeResult {
  const _AddressBookProbeResult({required this.probe, this.failureMessage});

  final OnboardingDatabaseProbe? probe;
  final String? failureMessage;

  bool get isAvailable => probe != null && probe!.exists && probe!.readable;
}

extension on OnboardingDatabaseProbe {
  OnboardingDatabaseProbe copyWith({int? rowCount}) {
    return OnboardingDatabaseProbe(
      path: path,
      exists: exists,
      readable: readable,
      sizeBytes: sizeBytes,
      lastModified: lastModified,
      rowCount: rowCount ?? this.rowCount,
      failureMessage: failureMessage,
    );
  }
}
