import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../../../db/app_database_files.dart';
import '../../../db/app_database_schema_versions.dart';
import '../../../db/application/read_only_sql_guard.dart';
import '../../../source_scoped_import/domain/known_sources.dart';
import '../../application/message_lens_installation_evidence_reader.dart';
import '../../application/onboarding_operation_snapshot_store.dart';
import '../../domain/message_lens_installation_state.dart';
import '../../domain/onboarding_operation_snapshot.dart';

final class SqliteMessageLensInstallationEvidenceReader
    implements MessageLensInstallationEvidenceReader {
  const SqliteMessageLensInstallationEvidenceReader();

  static const int _currentImportSchemaVersion = 10;
  static const int _currentOverlaySchemaVersion = 8;
  static const int _currentPresenceSchemaVersion = 9;

  @override
  Future<MessageLensInstallationEvidence> read({
    required String archiveRootPath,
  }) {
    return Isolate.run(
      () => _readSynchronously(archiveRootPath: archiveRootPath),
    );
  }

  MessageLensInstallationEvidence _readSynchronously({
    required String archiveRootPath,
  }) {
    final overlayPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: archiveRootPath,
    );
    final overlay = _readDatabase(
      overlayPath,
      maximumSupportedVersion: _currentOverlaySchemaVersion,
      requiredTables: const <String>['overlay_settings'],
    );
    final sourceScopedImport = _readDatabase(
      appDatabasePath(
        AppDatabaseFile.sourceScopedImport,
        databaseDirectory: archiveRootPath,
      ),
      maximumSupportedVersion: _currentImportSchemaVersion,
      requiredTables: const <String>['messages', 'source_registry'],
      includeImportEvidence: true,
    );
    final conversationGraph = _readDatabase(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: archiveRootPath,
      ),
      maximumSupportedVersion: conversationGraphSchemaVersion,
      requiredTables: const <String>['messages', 'chats', 'chat_to_message'],
      includeGraphEvidence: true,
    );

    return MessageLensInstallationEvidence(
      sourceScopedImport: sourceScopedImport,
      conversationGraph: conversationGraph,
      overlay: overlay,
      presence: _readDatabase(
        appDatabasePath(
          AppDatabaseFile.presence,
          databaseDirectory: archiveRootPath,
        ),
        maximumSupportedVersion: _currentPresenceSchemaVersion,
        requiredTables: const <String>['schedule_definitions', 'schedule_runs'],
      ),
      hasRetiredDerivedArtifacts:
          <AppDatabaseFile>[
            AppDatabaseFile.retiredMacosImport,
            AppDatabaseFile.retiredWorking,
          ].any(
            (databaseFile) => File(
              appDatabasePath(databaseFile, databaseDirectory: archiveRootPath),
            ).existsSync(),
          ),
      operationSnapshot: _readOperationSnapshot(
        databasePath: overlayPath,
        overlayEvidence: overlay,
      ),
    );
  }

  OnboardingOperationSnapshot _readOperationSnapshot({
    required String databasePath,
    required InstallationDatabaseEvidence overlayEvidence,
  }) {
    if (!overlayEvidence.isUsable) {
      return const OnboardingOperationSnapshot.idle();
    }

    final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');
      const sql = 'SELECT value FROM overlay_settings WHERE key = ? LIMIT 1';
      assertReadOnlySql(
        sql,
        boundary: 'Installation-state operation snapshot inspection',
      );
      final rows = database.select(sql, <Object?>[
        onboardingOperationSnapshotSettingKey,
      ]);
      if (rows.isEmpty) {
        return const OnboardingOperationSnapshot.idle();
      }
      final raw = rows.single['value'];
      if (raw is! String || raw.isEmpty) {
        return const OnboardingOperationSnapshot.idle();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Invalid onboarding operation snapshot.');
      }
      return OnboardingOperationSnapshot.fromJson(decoded);
    } finally {
      database.dispose();
    }
  }

  InstallationDatabaseEvidence _readDatabase(
    String databasePath, {
    required int maximumSupportedVersion,
    required List<String> requiredTables,
    bool includeImportEvidence = false,
    bool includeGraphEvidence = false,
  }) {
    final file = File(databasePath);
    if (!file.existsSync()) {
      return const InstallationDatabaseEvidence.absent();
    }
    if (file.lengthSync() == 0) {
      return const InstallationDatabaseEvidence(
        exists: true,
        readable: false,
        integrityOk: false,
        schemaVersionSupported: false,
        failure: 'Database file is empty.',
      );
    }

    try {
      final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
      try {
        database.execute('PRAGMA query_only = ON;');
        database.execute('PRAGMA busy_timeout = 3000;');
        const userVersionSql = 'PRAGMA user_version';
        assertReadOnlySql(
          userVersionSql,
          boundary: 'Installation-state schema inspection',
        );
        final userVersion = _firstInt(database, userVersionSql);
        const quickCheckSql = 'PRAGMA quick_check(1)';
        assertReadOnlySql(
          quickCheckSql,
          boundary: 'Installation-state integrity inspection',
        );
        final quickCheck = database.select(quickCheckSql).single;
        final integrityOk = quickCheck.values.single == 'ok';
        const tableInventorySql =
            "SELECT name FROM sqlite_master WHERE type = 'table'";
        assertReadOnlySql(
          tableInventorySql,
          boundary: 'Installation-state table inventory',
        );
        final existingTables = <String>{
          for (final row in database.select(tableInventorySql))
            if (row['name'] is String) row['name'] as String,
        };
        final requiredTablesPresent = requiredTables.every(
          existingTables.contains,
        );
        final schemaVersionSupported =
            userVersion != null &&
            userVersion >= 1 &&
            userVersion <= maximumSupportedVersion &&
            requiredTablesPresent;

        return InstallationDatabaseEvidence(
          exists: true,
          readable: true,
          integrityOk: integrityOk,
          schemaVersionSupported: schemaVersionSupported,
          userVersion: userVersion,
          messageCount: includeImportEvidence || includeGraphEvidence
              ? _tableCount(database, 'messages')
              : null,
          chatCount: includeGraphEvidence
              ? _tableCount(database, 'chats')
              : null,
          chatMessageEdgeCount: includeGraphEvidence
              ? _tableCount(database, 'chat_to_message')
              : null,
          nonLiveSourceCount: includeImportEvidence
              ? _firstInt(
                  database,
                  'SELECT COUNT(*) FROM source_registry '
                  'WHERE source_id NOT IN (?, ?)',
                  <Object?>[liveChatDbSourceId, liveAddressBookSourceId],
                )
              : null,
          failure: requiredTablesPresent
              ? null
              : 'Required database tables are missing.',
        );
      } finally {
        database.dispose();
      }
    } catch (error) {
      return InstallationDatabaseEvidence(
        exists: true,
        readable: false,
        integrityOk: false,
        schemaVersionSupported: false,
        failure: '$error',
      );
    }
  }

  int _tableCount(Database database, String tableName) {
    final sql = 'SELECT COUNT(*) FROM "$tableName"';
    assertReadOnlySql(sql, boundary: 'Installation-state table count');
    return _firstInt(database, sql) ?? 0;
  }

  int? _firstInt(
    Database database,
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    assertReadOnlySql(sql, boundary: 'Installation-state scalar query');
    final rows = database.select(sql, parameters);
    if (rows.isEmpty || rows.first.values.isEmpty) {
      return null;
    }
    final value = rows.first.values.first;
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }
}
