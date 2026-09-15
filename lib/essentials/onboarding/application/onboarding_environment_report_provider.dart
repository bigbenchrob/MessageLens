import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import '../../../features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import '../../../features/address_book_folders/feature_level_providers.dart'
    show futureGetFolderAggregateProvider;
import '../../../features/attachments/feature_level_providers.dart'
    show attachmentArchiveLocationProvider;
import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
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
  final attachmentArchiveLocation = await ref.watch(
    attachmentArchiveLocationProvider.future,
  );
  final inputs = _OnboardingEnvironmentInputs(
    devOverrides: ref.watch(onboardingDevOverridesProvider),
    failureStorage: ref.watch(onboardingFailureStorageProvider),
    databaseProbeReader: ref.watch(onboardingDatabaseProbeReaderProvider),
    hasFullDiskAccess: ref.watch(onboardingFullDiskAccessProvider),
    messagesDatabasePath: ref.watch(onboardingMessagesDatabasePathProvider),
    addressBookEither: await ref.watch(futureGetFolderAggregateProvider.future),
    archiveRootPath: ref.watch(onboardingDatabaseDirectoryPathProvider),
    attachmentArchiveDirectoryPath: attachmentArchiveLocation
        .requireArchiveRootPath(),
    // Readiness is an unrelated observer of the derived stores. Suppress its
    // database reads for every admitted archive mutation, including onboarding
    // import, even when that operation does not globally block its own graph
    // connection from reopening.
    isMaintenanceLocked:
        ref.watch(dbMaintenanceLockProvider) ||
        ref.watch(
          archiveMutationCoordinatorProvider.select((state) => state.isLocked),
        ),
    graphBuildState: ref.watch(conversationGraphBuildControllerProvider),
    liveUpdateMonitorState: ref.watch(chatDbChangeMonitorProvider),
  );
  final evaluator = _OnboardingEnvironmentEvaluator(inputs);
  return evaluator.evaluate();
}

class _OnboardingEnvironmentInputs {
  const _OnboardingEnvironmentInputs({
    required this.devOverrides,
    required this.failureStorage,
    required this.databaseProbeReader,
    required this.hasFullDiskAccess,
    required this.messagesDatabasePath,
    required this.addressBookEither,
    required this.archiveRootPath,
    required this.attachmentArchiveDirectoryPath,
    required this.isMaintenanceLocked,
    required this.graphBuildState,
    required this.liveUpdateMonitorState,
  });

  final OnboardingDevOverridesState devOverrides;
  final OnboardingFailureStore failureStorage;
  final OnboardingDatabaseProbeReader databaseProbeReader;
  final bool hasFullDiskAccess;
  final String messagesDatabasePath;
  final Either<FolderRetrievalFailure, AddressBookFolderAggregate>
  addressBookEither;
  final String archiveRootPath;
  final String attachmentArchiveDirectoryPath;
  final bool isMaintenanceLocked;
  final ConversationGraphBuildState graphBuildState;
  final ChatDbChangeMonitorState liveUpdateMonitorState;
}

class _OnboardingEnvironmentEvaluator {
  const _OnboardingEnvironmentEvaluator(this.inputs);

  final _OnboardingEnvironmentInputs inputs;

  Future<OnboardingEnvironmentReport> evaluate() async {
    final devOverrides = inputs.devOverrides;
    final failureStorage = inputs.failureStorage;
    final databaseProbeReader = inputs.databaseProbeReader;
    final persistedImportEntry = await failureStorage
        .loadSourceImportFailureEntry();
    final persistedGraphProjectionEntry = await failureStorage
        .loadGraphProjectionFailureEntry();
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
    final attachmentArchiveProbe = databaseProbeReader.probeDirectory(
      inputs.attachmentArchiveDirectoryPath,
    );
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
