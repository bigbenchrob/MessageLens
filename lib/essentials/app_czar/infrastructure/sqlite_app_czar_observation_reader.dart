import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../db/app_database_files.dart';
import '../../db/app_database_schema_versions.dart';
import '../../db/application/read_only_sql_guard.dart';
import '../../source_scoped_import/domain/known_sources.dart';
import '../application/app_czar_observation_reader.dart';
import '../domain/app_czar_models.dart';

final class SqliteAppCzarObservationReader implements AppCzarObservationReader {
  const SqliteAppCzarObservationReader({
    required String archiveRootPath,
    required String messagesDatabasePath,
    required AppCzarAttachmentArchiveProbe attachmentArchiveProbe,
    bool developmentRootAdmitted = true,
  }) : _archiveRootPath = archiveRootPath,
       _messagesDatabasePath = messagesDatabasePath,
       _attachmentArchiveProbe = attachmentArchiveProbe,
       _developmentRootAdmitted = developmentRootAdmitted;

  final String _archiveRootPath;
  final String _messagesDatabasePath;
  final AppCzarAttachmentArchiveProbe _attachmentArchiveProbe;
  final bool _developmentRootAdmitted;

  static String defaultMacosMessagesDatabasePath() {
    final homeDirectory = Platform.environment['HOME']?.trim();
    if (homeDirectory == null || homeDirectory.isEmpty) {
      throw StateError('The current macOS home directory is unavailable.');
    }
    return path.join(homeDirectory, 'Library', 'Messages', 'chat.db');
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    return AppCzarRootObservation(
      admitted: _developmentRootAdmitted,
      path: _archiveRootPath,
    );
  }

  @override
  Future<AppCzarSourceObservation> readSource() {
    final sourcePath = _messagesDatabasePath;
    return Isolate.run(() => _readSourceSynchronously(sourcePath));
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
