import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import '../../../features/address_book_folders/infrastructure/data_sources/local/address_book_folder_path_finder.dart';
import '../../../features/address_book_folders/infrastructure/repositories/address_book_folder_repository.dart';
import '../../db/app_database_files.dart';
import '../../db/app_database_schema_versions.dart';
import '../../db/application/read_only_sql_guard.dart';
import '../../installation_evidence/application/message_lens_physical_installation_evidence_reader.dart';
import '../../installation_evidence/domain/message_lens_physical_installation_evidence.dart';
import '../../source_scoped_import/domain/known_sources.dart';
import '../application/app_czar_observation_reader.dart';
import '../domain/app_czar_models.dart';
import 'sqlite_app_czar_local_data_repair_safety_reader.dart';

final class SqliteAppCzarObservationReader
    implements
        AppCzarObservationReader,
        AppCzarInitialConstructionScopeReader,
        AppCzarContactsPrerequisiteReader,
        AppCzarLocalDataRepairSafetyReader {
  SqliteAppCzarObservationReader({
    required String archiveRootPath,
    required String messagesDatabasePath,
    required AppCzarAttachmentArchiveProbe attachmentArchiveProbe,
    String? archiveInstanceId,
    String? contactsSourcesRootPath,
    required MessageLensPhysicalInstallationEvidenceReader
    physicalEvidenceReader,
    bool developmentRootAdmitted = true,
  }) : _archiveRootPath = archiveRootPath,
       _messagesDatabasePath = messagesDatabasePath,
       _contactsSourcesRootPath =
           contactsSourcesRootPath ?? defaultMacosContactsSourcesRootPath(),
       _physicalEvidenceReader = physicalEvidenceReader,
       _attachmentArchiveProbe = attachmentArchiveProbe,
       _archiveInstanceId = archiveInstanceId,
       _developmentRootAdmitted = developmentRootAdmitted;

  final String _archiveRootPath;
  final String _messagesDatabasePath;
  final String _contactsSourcesRootPath;
  final MessageLensPhysicalInstallationEvidenceReader _physicalEvidenceReader;
  final AppCzarAttachmentArchiveProbe _attachmentArchiveProbe;
  final String? _archiveInstanceId;
  final bool _developmentRootAdmitted;

  static String defaultMacosMessagesDatabasePath() {
    final homeDirectory = Platform.environment['HOME']?.trim();
    if (homeDirectory == null || homeDirectory.isEmpty) {
      throw StateError('The current macOS home directory is unavailable.');
    }
    return path.join(homeDirectory, 'Library', 'Messages', 'chat.db');
  }

  static String defaultMacosContactsSourcesRootPath() {
    final homeDirectory = Platform.environment['HOME']?.trim();
    if (homeDirectory == null || homeDirectory.isEmpty) {
      throw StateError('The current macOS home directory is unavailable.');
    }
    return path.join(
      homeDirectory,
      'Library',
      'Application Support',
      'AddressBook',
      'Sources',
    );
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return AppCzarRootObservation(
      admitted: _developmentRootAdmitted,
      path: _archiveRootPath,
    );
  }

  @override
  Future<AppCzarInitialConstructionScopeObservation>
  readInitialConstructionScope() async {
    final evidence = await _physicalEvidenceReader.readPhysicalBounded(
      archiveRootPath: _archiveRootPath,
    );
    return classifyInitialConstructionScopeEvidence(evidence);
  }

  @override
  Future<AppCzarSourceObservation> readSource() {
    final sourcePath = _messagesDatabasePath;
    return Isolate.run(() => _readSourceSynchronously(sourcePath));
  }

  @override
  Future<AppCzarContactsPrerequisiteObservation>
  readContactsPrerequisite() async {
    final repository = AddressBookFolderRepository(
      folderPathsFinder: AddressBookFolderPathsFinder.atSourcesRoot(
        sourcesRootPath: _contactsSourcesRootPath,
      ),
    );
    final result = await repository.getFinalFolderAggregate();
    return result.fold(
      (failure) => AppCzarContactsPrerequisiteObservation(
        condition: switch (failure.kind) {
          FolderRetrievalFailureKind.accessDenied =>
            AppCzarContactsPrerequisiteCondition.accessDenied,
          FolderRetrievalFailureKind.sourceUnavailable =>
            AppCzarContactsPrerequisiteCondition.unavailable,
          FolderRetrievalFailureKind.invalidOrCorrupt =>
            AppCzarContactsPrerequisiteCondition.invalidOrCorrupt,
          FolderRetrievalFailureKind.unknown =>
            AppCzarContactsPrerequisiteCondition.unknown,
        },
        issue: failure.message,
      ),
      (aggregate) {
        final count = aggregate.folders.fold<int>(
          0,
          (sum, folder) => sum + folder.recordCount.getOrElse(0),
        );
        return AppCzarContactsPrerequisiteObservation(
          condition: count == 0
              ? AppCzarContactsPrerequisiteCondition.viableEmpty
              : AppCzarContactsPrerequisiteCondition.viableWithContacts,
          contactCount: count,
          viableStoreCount: aggregate.folders.length,
          sourceDatabasePath: aggregate.mostRecentFolderPath,
        );
      },
    );
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() {
    final databasePath = appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: _archiveRootPath,
    );
    return Isolate.run(() => _readImportSynchronously(databasePath));
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() {
    final databasePath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: _archiveRootPath,
    );
    return Isolate.run(() => _readGraphSynchronously(databasePath));
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() {
    final databasePath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: _archiveRootPath,
    );
    return Isolate.run(() => _readOverlaySynchronously(databasePath));
  }

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() {
    return _attachmentArchiveProbe.readCurrent();
  }

  @override
  Future<AppCzarLocalDataRepairSafetyObservation> readLocalDataRepairSafety({
    required AppCzarArchiveObservation attachmentArchive,
  }) async {
    final archiveInstanceId = _archiveInstanceId;
    if (archiveInstanceId == null || archiveInstanceId.isEmpty) {
      return AppCzarLocalDataRepairSafetyObservation.unknown(
        issue: 'The admitted archive instance identity was not supplied.',
        archiveRootPath: _archiveRootPath,
        archiveScopeIdentity: attachmentArchive.archiveScopeIdentity,
        archiveGeneration: attachmentArchive.archiveGeneration,
      );
    }
    final contacts = await readContactsPrerequisite();
    return SqliteAppCzarLocalDataRepairSafetyReader(
      archiveRootPath: _archiveRootPath,
      archiveInstanceId: archiveInstanceId,
      messagesDatabasePath: _messagesDatabasePath,
      contactsDatabasePath: contacts.sourceDatabasePath,
    ).read(
      attachmentArchive: attachmentArchive,
      contactsPrerequisite: contacts,
    );
  }

  static AppCzarSourceObservation _readSourceSynchronously(
    String databasePath,
  ) {
    try {
      final first = _readSourceSample(databasePath);
      final second = _readSourceSample(databasePath);
      final stable =
          first.messageCount == second.messageCount &&
          first.maxRowId == second.maxRowId;
      return AppCzarSourceObservation(
        condition: AppCzarSourceCondition.readable,
        messageCount: second.messageCount,
        maxRowId: second.maxRowId,
        sampleStable: stable,
        issue: stable ? null : 'The Messages source changed between samples.',
      );
    } on _SourceReadFailure catch (failure) {
      return AppCzarSourceObservation(
        condition: failure.accessDenied
            ? AppCzarSourceCondition.accessDenied
            : AppCzarSourceCondition.unavailable,
        issue: failure.message,
      );
    } on Object catch (error) {
      return AppCzarSourceObservation.unknown(
        'The Messages source could not be inspected: $error',
      );
    }
  }

  static _SourceSample _readSourceSample(String databasePath) {
    try {
      final handle = File(databasePath).openSync(mode: FileMode.read);
      handle.closeSync();
    } on FileSystemException catch (error) {
      final errorCode = error.osError?.errorCode;
      throw _SourceReadFailure(
        accessDenied: errorCode == 1 || errorCode == 13,
        message: errorCode == 1 || errorCode == 13
            ? 'macOS denied access to the Messages database.'
            : 'The Messages database is unavailable: $error',
      );
    }

    Database database;
    try {
      database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
    } on Object catch (error) {
      final normalized = '$error'.toLowerCase();
      final accessDenied =
          normalized.contains('permission') ||
          normalized.contains('authorization') ||
          normalized.contains('not authorized');
      throw _SourceReadFailure(
        accessDenied: accessDenied,
        message: accessDenied
            ? 'macOS denied access to the Messages database.'
            : 'The Messages database could not be opened read-only: $error',
      );
    }

    try {
      _configureReadOnly(database);
      const sql = '''
SELECT
  COUNT(*) AS message_count,
  COALESCE(MAX(ROWID), 0) AS max_rowid
FROM message;
''';
      assertReadOnlySql(sql, boundary: 'AppCzar Messages source sample');
      final row = database.select(sql).single;
      return _SourceSample(
        messageCount: _requiredInt(row['message_count']),
        maxRowId: _requiredInt(row['max_rowid']),
      );
    } on Object catch (error) {
      throw _SourceReadFailure(
        accessDenied: false,
        message: 'The Messages database could not be queried: $error',
      );
    } finally {
      database.dispose();
    }
  }

  static AppCzarDatabaseObservation _readImportSynchronously(
    String databasePath,
  ) {
    final opened = _openAppDatabase(
      databasePath,
      expectedSchemaVersion: sourceScopedImportSchemaVersion,
      requiredTables: const <String>['source_registry', 'messages'],
    );
    if (opened.observation != null) {
      return opened.observation!;
    }
    final database = opened.database!;
    try {
      const sourceSql =
          'SELECT source_id FROM source_registry WHERE source_kind = ? '
          'ORDER BY source_id ASC';
      assertReadOnlySql(sourceSql, boundary: 'AppCzar live source identity');
      final sourceRows = database.select(sourceSql, <Object?>[
        liveChatDbSourceKind,
      ]);
      if (sourceRows.length > 1) {
        return const AppCzarDatabaseObservation(
          condition: AppCzarDatabaseCondition.unhealthy,
          issue: 'More than one current Messages source is registered.',
        );
      }

      const totalSql = 'SELECT COUNT(*) AS row_count FROM messages';
      assertReadOnlySql(totalSql, boundary: 'AppCzar import message count');
      final totalCount = _requiredInt(
        database.select(totalSql).single['row_count'],
      );
      if (sourceRows.isEmpty) {
        return AppCzarDatabaseObservation(
          condition: AppCzarDatabaseCondition.healthy,
          schemaVersion: sourceScopedImportSchemaVersion,
          messageCount: totalCount,
          liveMessageCount: 0,
          liveMaxSourceRowId: 0,
        );
      }

      final sourceId = _requiredInt(sourceRows.single['source_id']);
      const liveSql = '''
SELECT
  COUNT(*) AS row_count,
  COALESCE(MAX(source_rowid), 0) AS max_source_rowid
FROM messages
WHERE source_id = ?;
''';
      assertReadOnlySql(liveSql, boundary: 'AppCzar live import evidence');
      final liveRow = database.select(liveSql, <Object?>[sourceId]).single;
      return AppCzarDatabaseObservation(
        condition: AppCzarDatabaseCondition.healthy,
        schemaVersion: sourceScopedImportSchemaVersion,
        messageCount: totalCount,
        liveMessageCount: _requiredInt(liveRow['row_count']),
        liveMaxSourceRowId: _requiredInt(liveRow['max_source_rowid']),
      );
    } on Object catch (error) {
      return AppCzarDatabaseObservation(
        condition: AppCzarDatabaseCondition.unhealthy,
        issue: 'The import store could not be read coherently: $error',
      );
    } finally {
      database.dispose();
    }
  }

  static AppCzarDatabaseObservation _readGraphSynchronously(
    String databasePath,
  ) {
    final opened = _openAppDatabase(
      databasePath,
      expectedSchemaVersion: conversationGraphSchemaVersion,
      requiredTables: const <String>['messages', 'chats', 'chat_to_message'],
    );
    if (opened.observation != null) {
      return opened.observation!;
    }
    final database = opened.database!;
    try {
      return AppCzarDatabaseObservation(
        condition: AppCzarDatabaseCondition.healthy,
        schemaVersion: conversationGraphSchemaVersion,
        messageCount: _tableCount(database, 'messages'),
        chatCount: _tableCount(database, 'chats'),
        chatMessageEdgeCount: _tableCount(database, 'chat_to_message'),
      );
    } on Object catch (error) {
      return AppCzarDatabaseObservation(
        condition: AppCzarDatabaseCondition.unhealthy,
        issue: 'The conversation graph could not be read coherently: $error',
      );
    } finally {
      database.dispose();
    }
  }

  static AppCzarDatabaseObservation _readOverlaySynchronously(
    String databasePath,
  ) {
    final opened = _openAppDatabase(
      databasePath,
      expectedSchemaVersion: overlaySchemaVersion,
      requiredTables: const <String>['overlay_settings'],
    );
    if (opened.observation != null) {
      return opened.observation!;
    }
    final database = opened.database!;
    database.dispose();
    return const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: overlaySchemaVersion,
    );
  }

  static _OpenedAppDatabase _openAppDatabase(
    String databasePath, {
    required int expectedSchemaVersion,
    required List<String> requiredTables,
  }) {
    final file = File(databasePath);
    try {
      if (!file.existsSync()) {
        return const _OpenedAppDatabase.observation(
          AppCzarDatabaseObservation.absent(),
        );
      }
      if (file.lengthSync() == 0) {
        return const _OpenedAppDatabase.observation(
          AppCzarDatabaseObservation(
            condition: AppCzarDatabaseCondition.unhealthy,
            issue: 'The database file is empty.',
          ),
        );
      }
    } on FileSystemException catch (error) {
      return _OpenedAppDatabase.observation(
        AppCzarDatabaseObservation.unknown(
          'The database file could not be inspected: $error',
        ),
      );
    }

    Database? database;
    try {
      database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
      _configureReadOnly(database);
    } on Object catch (error) {
      database?.dispose();
      return _OpenedAppDatabase.observation(
        AppCzarDatabaseObservation.unknown(
          'The database could not be opened read-only: $error',
        ),
      );
    }

    try {
      final schemaVersion = _pragmaInt(database, 'user_version');
      if (schemaVersion != expectedSchemaVersion) {
        database.dispose();
        return _OpenedAppDatabase.observation(
          AppCzarDatabaseObservation(
            condition: AppCzarDatabaseCondition.unhealthy,
            schemaVersion: schemaVersion,
            issue:
                'Schema $schemaVersion does not match expected schema '
                '$expectedSchemaVersion.',
          ),
        );
      }

      const inventorySql =
          "SELECT name FROM sqlite_master WHERE type = 'table'";
      assertReadOnlySql(
        inventorySql,
        boundary: 'AppCzar database table inventory',
      );
      final tables = <String>{
        for (final row in database.select(inventorySql))
          if (row['name'] case final String name) name,
      };
      final missing = requiredTables
          .where((table) => !tables.contains(table))
          .toList(growable: false);
      if (missing.isNotEmpty) {
        database.dispose();
        return _OpenedAppDatabase.observation(
          AppCzarDatabaseObservation(
            condition: AppCzarDatabaseCondition.unhealthy,
            schemaVersion: schemaVersion,
            issue: 'Required tables are missing: ${missing.join(', ')}.',
          ),
        );
      }
      for (final table in requiredTables) {
        final sql = 'SELECT 1 FROM ${_quoted(table)} LIMIT 1';
        assertReadOnlySql(sql, boundary: 'AppCzar table readability probe');
        database.select(sql);
      }
      return _OpenedAppDatabase.database(database);
    } on Object catch (error) {
      database.dispose();
      return _OpenedAppDatabase.observation(
        AppCzarDatabaseObservation(
          condition: AppCzarDatabaseCondition.unhealthy,
          issue: 'The database failed its bounded health read: $error',
        ),
      );
    }
  }

  static void _configureReadOnly(Database database) {
    database.execute('PRAGMA query_only = ON;');
    database.execute('PRAGMA busy_timeout = 3000;');
  }

  static int _pragmaInt(Database database, String pragma) {
    final sql = 'PRAGMA $pragma';
    assertReadOnlySql(sql, boundary: 'AppCzar schema inspection');
    final row = database.select(sql).single;
    return _requiredInt(row.values.first);
  }

  static int _tableCount(Database database, String table) {
    final sql = 'SELECT COUNT(*) AS row_count FROM ${_quoted(table)}';
    assertReadOnlySql(sql, boundary: 'AppCzar table count');
    return _requiredInt(database.select(sql).single['row_count']);
  }

  static String _quoted(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
  }

  static int _requiredInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw FormatException('Expected an integer but found $value.');
  }
}

AppCzarInitialConstructionScopeObservation
classifyInitialConstructionScopeEvidence(
  MessageLensPhysicalInstallationEvidence evidence,
) {
  final stores = <InstallationDatabaseEvidence>[
    evidence.sourceScopedImport,
    evidence.conversationGraph,
    evidence.overlay,
    evidence.presence,
  ];
  if (stores.any(
    (store) =>
        store.boundedInspectionStatus ==
        InstallationBoundedInspectionStatus.contention,
  )) {
    return const AppCzarInitialConstructionScopeObservation.unknown(
      'A current MessageLens store was contended during bounded inspection.',
    );
  }
  if (stores.any(
    (store) =>
        store.boundedInspectionStatus ==
            InstallationBoundedInspectionStatus.unsupportedSchema ||
        (store.passedBoundedInspection &&
            store.userVersion != store.currentSchemaVersion),
  )) {
    return AppCzarInitialConstructionScopeObservation(
      condition:
          AppCzarInitialConstructionScopeCondition.retiredOrUnsupportedMaterial,
      importMessageCount: evidence.sourceScopedImport.messageCount,
      graphMessageCount: evidence.conversationGraph.messageCount,
      graphChatCount: evidence.conversationGraph.chatCount,
      graphEdgeCount: evidence.conversationGraph.chatMessageEdgeCount,
      nonLiveSourceCount: evidence.sourceScopedImport.nonLiveSourceCount,
      hasRetiredDerivedArtifacts: evidence.hasRetiredDerivedArtifacts,
      issue: 'A retired or unsupported MessageLens store requires review.',
    );
  }
  if (stores.any(
    (store) =>
        store.boundedInspectionStatus ==
        InstallationBoundedInspectionStatus.failed,
  )) {
    return AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.unhealthy,
      importMessageCount: evidence.sourceScopedImport.messageCount,
      graphMessageCount: evidence.conversationGraph.messageCount,
      graphChatCount: evidence.conversationGraph.chatCount,
      graphEdgeCount: evidence.conversationGraph.chatMessageEdgeCount,
      nonLiveSourceCount: evidence.sourceScopedImport.nonLiveSourceCount,
      hasRetiredDerivedArtifacts: evidence.hasRetiredDerivedArtifacts,
      issue: 'A required MessageLens store failed bounded inspection.',
    );
  }
  if (evidence.hasRetiredDerivedArtifacts) {
    return AppCzarInitialConstructionScopeObservation(
      condition:
          AppCzarInitialConstructionScopeCondition.retiredOrUnsupportedMaterial,
      importMessageCount: evidence.sourceScopedImport.messageCount,
      graphMessageCount: evidence.conversationGraph.messageCount,
      graphChatCount: evidence.conversationGraph.chatCount,
      graphEdgeCount: evidence.conversationGraph.chatMessageEdgeCount,
      nonLiveSourceCount: evidence.sourceScopedImport.nonLiveSourceCount,
      hasRetiredDerivedArtifacts: true,
      issue: 'Retired derived database artifacts are present.',
    );
  }
  final nonLiveCount = evidence.sourceScopedImport.nonLiveSourceCount ?? 0;
  if (nonLiveCount > 0) {
    return AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.protectedNonLiveData,
      importMessageCount: evidence.sourceScopedImport.messageCount,
      graphMessageCount: evidence.conversationGraph.messageCount,
      graphChatCount: evidence.conversationGraph.chatCount,
      graphEdgeCount: evidence.conversationGraph.chatMessageEdgeCount,
      nonLiveSourceCount: nonLiveCount,
      hasRetiredDerivedArtifacts: false,
      issue: 'Protected non-live source data is present.',
    );
  }
  final counts = <int>[
    evidence.sourceScopedImport.messageCount ?? 0,
    evidence.conversationGraph.messageCount ?? 0,
    evidence.conversationGraph.chatCount ?? 0,
    evidence.conversationGraph.chatMessageEdgeCount ?? 0,
  ];
  if (counts.any((count) => count > 0)) {
    return AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.consequentialData,
      importMessageCount: counts[0],
      graphMessageCount: counts[1],
      graphChatCount: counts[2],
      graphEdgeCount: counts[3],
      nonLiveSourceCount: nonLiveCount,
      hasRetiredDerivedArtifacts: false,
      issue: 'Consequential local import or graph data is present.',
    );
  }
  return AppCzarInitialConstructionScopeObservation(
    condition: AppCzarInitialConstructionScopeCondition.safeEmpty,
    importMessageCount: counts[0],
    graphMessageCount: counts[1],
    graphChatCount: counts[2],
    graphEdgeCount: counts[3],
    nonLiveSourceCount: nonLiveCount,
    hasRetiredDerivedArtifacts: false,
    issue: null,
  );
}

final class _SourceSample {
  const _SourceSample({required this.messageCount, required this.maxRowId});

  final int messageCount;
  final int maxRowId;
}

final class _SourceReadFailure implements Exception {
  const _SourceReadFailure({required this.accessDenied, required this.message});

  final bool accessDenied;
  final String message;
}

final class _OpenedAppDatabase {
  const _OpenedAppDatabase.database(Database this.database)
    : observation = null;

  const _OpenedAppDatabase.observation(
    AppCzarDatabaseObservation this.observation,
  ) : database = null;

  final Database? database;
  final AppCzarDatabaseObservation? observation;
}
