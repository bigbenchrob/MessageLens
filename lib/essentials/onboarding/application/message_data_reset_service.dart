import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain/archive_mutation_operation.dart';
import '../../archive_environment/feature_level_providers.dart'
    show ArchiveMutationCapability, archiveMutationCoordinatorProvider;
import '../../db/app_database_files.dart';
import '../../db/feature_level_providers.dart'
    show
        conversationGraphConnectionLifecycleProvider,
        driftConversationGraphDatabaseProvider,
        sourceScopedImportDatabaseProvider;
import '../../db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import 'derived_message_data_file_store.dart';
import 'derived_message_data_file_store_provider.dart';

part 'message_data_reset_service.g.dart';

const _retiredDatabaseCleanupFiles = <AppDatabaseFile>[
  AppDatabaseFile.retiredMacosImport,
  AppDatabaseFile.retiredWorking,
];

const _activeGraphDerivedDatabaseFiles = <AppDatabaseFile>[
  AppDatabaseFile.sourceScopedImport,
  AppDatabaseFile.conversationGraph,
];

List<String> get _retiredDatabaseCleanupBaseNames =>
    appDatabaseFileNames(_retiredDatabaseCleanupFiles);

List<String> get _activeGraphDerivedDatabaseBaseNames =>
    appDatabaseFileNames(_activeGraphDerivedDatabaseFiles);

List<String> get _messageDataResetPostCleanupCheckBaseNames =>
    appDatabaseFileNames(<AppDatabaseFile>[
      ..._activeGraphDerivedDatabaseFiles,
      ..._retiredDatabaseCleanupFiles,
    ]);

abstract interface class MessageDataResetService {
  Future<void> resetDerivedData();

  Future<void> resetDerivedDataForStartFresh(
    ArchiveMutationCapability capability,
  );

  Future<void> resetActiveDerivedDataForLocalDataRepair(
    ArchiveMutationCapability capability,
  );
}

final class MessageDataResetServiceImpl implements MessageDataResetService {
  MessageDataResetServiceImpl(this._dependencies);

  final _MessageDataResetDependencies _dependencies;

  @override
  Future<void> resetDerivedData() {
    return _dependencies.runWithMutationAuthority(
      operation: ArchiveMutationOperation.messageDataReset,
      action: _resetDerivedData,
    );
  }

  @override
  Future<void> resetDerivedDataForStartFresh(
    ArchiveMutationCapability capability,
  ) {
    capability.requireOperation(ArchiveMutationOperation.startFresh);
    return _resetDerivedData(capability, includeRetired: true);
  }

  @override
  Future<void> resetActiveDerivedDataForLocalDataRepair(
    ArchiveMutationCapability capability,
  ) {
    capability.requireOperation(ArchiveMutationOperation.localDataRepair);
    return _resetDerivedData(capability, includeRetired: false);
  }

  Future<void> _resetDerivedData(
    ArchiveMutationCapability capability, {
    bool includeRetired = true,
  }) async {
    final operation = capability.operation;
    if (operation != ArchiveMutationOperation.messageDataReset &&
        operation != ArchiveMutationOperation.startFresh) {
      if (operation != ArchiveMutationOperation.localDataRepair) {
        throw StateError('$operation cannot reset derived message data.');
      }
    }
    capability.requireOperation(operation);
    final logger = _dependencies.logger;
    logger.warn(
      'Reset Message Data requested',
      source: 'MessageDataResetService',
    );

    try {
      logger.info(
        'Closing source-scoped import database before reset',
        source: 'MessageDataResetService',
      );
      final sourceScopedImportWasOpen =
          await _closeSourceScopedImportDatabase();
      logger.info(
        'Closing source-scoped graph database before reset',
        source: 'MessageDataResetService',
      );
      final conversationGraphWasOpen = await _closeConversationGraphDatabase();

      final fileStore = _dependencies.fileStore;
      final physicalStore = fileStore is LocalDataRepairPhysicalFileStore
          ? fileStore as LocalDataRepairPhysicalFileStore
          : null;
      final physicalSnapshot =
          operation == ArchiveMutationOperation.localDataRepair
          ? await physicalStore?.captureLocalDataRepairSnapshot(
              _activeGraphDerivedDatabaseBaseNames,
            )
          : null;
      if (operation == ArchiveMutationOperation.localDataRepair &&
          (physicalStore == null || physicalSnapshot == null)) {
        throw StateError(
          'Local Data Repair requires the physical postcondition boundary.',
        );
      }
      final deletedActiveGraphFilePaths = await fileStore
          .deleteDatabaseBaseFiles(_activeGraphDerivedDatabaseBaseNames);
      logger.info(
        'Deleted active graph derived database files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedActiveGraphFilePaths.length,
          'deletedFiles': deletedActiveGraphFilePaths,
        },
      );
      final deletedRetiredCleanupFilePaths = includeRetired
          ? await fileStore.deleteDatabaseBaseFiles(
              _retiredDatabaseCleanupBaseNames,
            )
          : const <String>[];
      logger.info(
        'Deleted retired database cleanup files',
        source: 'MessageDataResetService',
        context: {
          'deletedCount': deletedRetiredCleanupFilePaths.length,
          'deletedFiles': deletedRetiredCleanupFilePaths,
        },
      );

      _dependencies.invalidateDerivedMessageDataProviders(
        invalidateSourceScopedImport: sourceScopedImportWasOpen,
        invalidateConversationGraph: conversationGraphWasOpen,
      );
      _dependencies.bumpMessageDataVersion();

      final databaseExistsAfterReset = fileStore.databaseExistenceByBaseName(
        includeRetired
            ? _messageDataResetPostCleanupCheckBaseNames
            : _activeGraphDerivedDatabaseBaseNames,
      );
      if (physicalStore != null && physicalSnapshot != null) {
        await physicalStore.requireLocalDataRepairPostcondition(
          before: physicalSnapshot,
          resetBaseNames: _activeGraphDerivedDatabaseBaseNames,
        );
      }

      logger.info(
        'Invalidated graph database providers and checked retired file cleanup',
        source: 'MessageDataResetService',
        context: {
          'retiredMacosImportCleanupFileExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.retiredMacosImport,
              )],
          'retiredWorkingCleanupFileExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.retiredWorking,
              )],
          'sourceScopedImportDbExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.sourceScopedImport,
              )],
          'conversationGraphDbExistsAfterReset':
              databaseExistsAfterReset[appDatabaseFileName(
                AppDatabaseFile.conversationGraph,
              )],
        },
      );

      logger.warn(
        'Derived message data reset complete',
        source: 'MessageDataResetService',
        context: {
          'preserved': 'overlay database, preferences, attachment archive',
        },
      );
    } catch (error, stackTrace) {
      logger.error(
        'Reset Message Data failed',
        source: 'MessageDataResetService',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(10).join('\n'),
        },
      );
      rethrow;
    }
  }

  Future<bool> _closeSourceScopedImportDatabase() async {
    final fileStore = _dependencies.fileStore;
    if (!fileStore.databaseBaseFileExists(
      appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
    )) {
      return false;
    }
    try {
      await _dependencies.closeSourceScopedImportDatabase();
      return true;
    } catch (error, stackTrace) {
      _logResetCloseWarning(
        message: 'Failed to close source-scoped import database before reset',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    }
  }

  Future<bool> _closeConversationGraphDatabase() async {
    final fileStore = _dependencies.fileStore;
    if (!fileStore.databaseBaseFileExists(
      appDatabaseFileName(AppDatabaseFile.conversationGraph),
    )) {
      return false;
    }
    try {
      return await _dependencies.closeConversationGraphDatabase();
    } catch (error, stackTrace) {
      _logResetCloseWarning(
        message: 'Failed to close conversation graph database before reset',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    }
  }

  void _logResetCloseWarning({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) {
    _dependencies.logger.warn(
      message,
      source: 'MessageDataResetService',
      context: {
        'error': error.toString(),
        'stack': stackTrace.toString().split('\n').take(5).join('\n'),
      },
    );
  }
}

final class _MessageDataResetDependencies {
  const _MessageDataResetDependencies({
    required this.logger,
    required this.fileStore,
    required this.runWithMutationAuthority,
    required this.bumpMessageDataVersion,
    required this.invalidateDerivedMessageDataProviders,
    required this.closeSourceScopedImportDatabase,
    required this.closeConversationGraphDatabase,
  });

  final _MessageDataResetLogSink logger;
  final DerivedMessageDataFileStore fileStore;
  final Future<void> Function({
    required ArchiveMutationOperation operation,
    required Future<void> Function(ArchiveMutationCapability capability) action,
  })
  runWithMutationAuthority;
  final void Function() bumpMessageDataVersion;
  final void Function({
    required bool invalidateSourceScopedImport,
    required bool invalidateConversationGraph,
  })
  invalidateDerivedMessageDataProviders;
  final Future<void> Function() closeSourceScopedImportDatabase;
  final Future<bool> Function() closeConversationGraphDatabase;
}

final class _MessageDataResetLogSink {
  const _MessageDataResetLogSink({
    required this.info,
    required this.warn,
    required this.error,
  });

  final void Function(
    String message, {
    String? source,
    Map<String, dynamic>? context,
  })
  info;

  final void Function(
    String message, {
    String? source,
    Map<String, dynamic>? context,
  })
  warn;

  final void Function(
    String message, {
    String? source,
    Map<String, dynamic>? context,
  })
  error;
}

@riverpod
MessageDataResetService messageDataResetService(Ref ref) {
  final logger = ref.read(appLoggerProvider.notifier);
  return MessageDataResetServiceImpl(
    _MessageDataResetDependencies(
      logger: _MessageDataResetLogSink(
        info: logger.info,
        warn: logger.warn,
        error: logger.error,
      ),
      fileStore: ref.read(derivedMessageDataFileStoreProvider),
      runWithMutationAuthority: ({required operation, required action}) {
        return ref
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability(
              operation: operation,
              ownerLabel: 'message-data-reset',
              action: action,
            );
      },
      bumpMessageDataVersion: ref
          .read(messageDataVersionProvider.notifier)
          .bump,
      invalidateDerivedMessageDataProviders:
          ({
            required bool invalidateSourceScopedImport,
            required bool invalidateConversationGraph,
          }) {
            if (invalidateSourceScopedImport) {
              ref.invalidate(sourceScopedImportDatabaseProvider);
            }
            if (invalidateConversationGraph) {
              ref.invalidate(driftConversationGraphDatabaseProvider);
            }
          },
      closeSourceScopedImportDatabase: () async {
        final ledgerDb = await ref.read(
          sourceScopedImportDatabaseProvider.future,
        );
        await ledgerDb.close();
      },
      closeConversationGraphDatabase: () {
        return ref
            .read(conversationGraphConnectionLifecycleProvider)
            .closeIfActive();
      },
    ),
  );
}
