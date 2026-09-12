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

  static const _overlayBaselineTables = <String>['overlay_settings'];
  static const _overlayCurrentTables = <String>[
    'participant_overrides',
    'chat_overrides',
    'message_annotations',
    'message_user_flags',
    'message_user_tags',
    'handle_to_participant_overrides',
    'virtual_participants',
    'overlay_settings',
    'favorite_contacts',
    'dismissed_handles',
    'handle_visibility_overrides',
    'archived_attachments',
    'conversation_tags',
    'conversation_tag_assignments',
    'message_intent_overlays',
    'message_intent_tags',
  ];
  static const _importRequiredTables = <String>['messages', 'source_registry'];
  static const _graphBaselineTables = <String>[
    'messages',
    'chats',
    'chat_to_message',
  ];
  static const _graphCurrentTables = <String>[
    ..._graphBaselineTables,
    'message_text_fts',
  ];
  static const _graphCurrentTriggers = <String>[
    'message_text_fts_after_insert',
    'message_text_fts_after_delete',
    'message_text_fts_after_text_update',
  ];
  static const _presenceRequiredTables = <String>[
    'schedule_definitions',
    'schedule_runs',
  ];

  @override
  Future<MessageLensInstallationEvidence> readBounded({
    required String archiveRootPath,
  }) {
    return Isolate.run(
      () => _readSynchronously(archiveRootPath: archiveRootPath),
    );
  }

  MessageLensInstallationEvidence _readSynchronously({
    required String archiveRootPath,
  }) {
    final overlayRead = _readDatabase(
      appDatabasePath(
        AppDatabaseFile.overlay,
        databaseDirectory: archiveRootPath,
      ),
      currentSchemaVersion: _currentOverlaySchemaVersion,
      baselineRequiredTables: _overlayBaselineTables,
      currentRequiredTables: _overlayCurrentTables,
      readOperationSnapshot: true,
    );
    final sourceScopedImport = _readDatabase(
      appDatabasePath(
        AppDatabaseFile.sourceScopedImport,
        databaseDirectory: archiveRootPath,
      ),
      currentSchemaVersion: _currentImportSchemaVersion,
      baselineRequiredTables: _importRequiredTables,
      currentRequiredTables: _importRequiredTables,
      includeImportEvidence: true,
    );
    final conversationGraph = _readDatabase(
      appDatabasePath(
        AppDatabaseFile.conversationGraph,
        databaseDirectory: archiveRootPath,
      ),
      currentSchemaVersion: conversationGraphSchemaVersion,
      baselineRequiredTables: _graphBaselineTables,
      currentRequiredTables: _graphCurrentTables,
      currentRequiredTriggers: _graphCurrentTriggers,
      includeGraphEvidence: true,
      probeFts: true,
    );
    final presence = _readDatabase(
      appDatabasePath(
        AppDatabaseFile.presence,
        databaseDirectory: archiveRootPath,
      ),
      currentSchemaVersion: _currentPresenceSchemaVersion,
      baselineRequiredTables: _presenceRequiredTables,
      currentRequiredTables: _presenceRequiredTables,
    );

    return MessageLensInstallationEvidence(
      sourceScopedImport: sourceScopedImport.evidence,
      conversationGraph: conversationGraph.evidence,
      overlay: overlayRead.evidence,
      presence: presence.evidence,
      hasRetiredDerivedArtifacts:
          <AppDatabaseFile>[
            AppDatabaseFile.retiredMacosImport,
            AppDatabaseFile.retiredWorking,
          ].any(
            (databaseFile) => File(
              appDatabasePath(databaseFile, databaseDirectory: archiveRootPath),
            ).existsSync(),
          ),
      operationSnapshot:
          overlayRead.operationSnapshot ??
          const OnboardingOperationSnapshot.idle(),
      operationSnapshotFailure: overlayRead.operationSnapshotFailure,
    );
  }

  _BoundedDatabaseRead _readDatabase(
    String databasePath, {
    required int currentSchemaVersion,
    required List<String> baselineRequiredTables,
    required List<String> currentRequiredTables,
    List<String> currentRequiredTriggers = const <String>[],
    bool includeImportEvidence = false,
    bool includeGraphEvidence = false,
    bool readOperationSnapshot = false,
    bool probeFts = false,
  }) {
    final file = File(databasePath);
    try {
      if (!file.existsSync()) {
        return const _BoundedDatabaseRead(
          evidence: InstallationDatabaseEvidence.absent(),
        );
      }
      if (file.lengthSync() == 0) {
        return const _BoundedDatabaseRead(
          evidence: InstallationDatabaseEvidence(
            boundedInspectionStatus: InstallationBoundedInspectionStatus.failed,
            failure: InstallationBoundedInspectionFailure(
              kind: InstallationBoundedInspectionFailureKind.zeroByteDatabase,
              message: 'Database file is empty.',
            ),
          ),
        );
      }
    } on FileSystemException catch (error) {
      return _failedRead(
        InstallationBoundedInspectionFailureKind.ioFailure,
        '$error',
      );
    }

    var phase = _BoundedReadPhase.open;
    try {
      final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
      try {
        phase = _BoundedReadPhase.configure;
        database.execute('PRAGMA query_only = ON;');
        database.execute('PRAGMA busy_timeout = 3000;');

        phase = _BoundedReadPhase.schema;
        const userVersionSql = 'PRAGMA user_version';
        assertReadOnlySql(
          userVersionSql,
          boundary: 'Installation-state schema inspection',
        );
        final userVersion = _firstInt(database, userVersionSql);
        if (userVersion == null ||
            userVersion < 1 ||
            userVersion > currentSchemaVersion) {
          return _BoundedDatabaseRead(
            evidence: InstallationDatabaseEvidence(
              boundedInspectionStatus:
                  InstallationBoundedInspectionStatus.unsupportedSchema,
              userVersion: userVersion,
              currentSchemaVersion: currentSchemaVersion,
              failure: InstallationBoundedInspectionFailure(
                kind: InstallationBoundedInspectionFailureKind.unknown,
                message:
                    'Database schema version ${userVersion ?? 'unknown'} is '
                    'not supported; maximum supported version is '
                    '$currentSchemaVersion.',
              ),
            ),
          );
        }

        phase = _BoundedReadPhase.inventory;
        const objectInventorySql =
            'SELECT type, name FROM sqlite_master '
            "WHERE type IN ('table', 'trigger')";
        assertReadOnlySql(
          objectInventorySql,
          boundary: 'Installation-state schema-object inventory',
        );
        final objectsByType = <String, Set<String>>{};
        for (final row in database.select(objectInventorySql)) {
          final type = row['type'];
          final name = row['name'];
          if (type is String && name is String) {
            objectsByType.putIfAbsent(type, () => <String>{}).add(name);
          }
        }
        final requiredTables = userVersion == currentSchemaVersion
            ? currentRequiredTables
            : baselineRequiredTables;
        final requiredTriggers = userVersion == currentSchemaVersion
            ? currentRequiredTriggers
            : const <String>[];
        final existingTables = objectsByType['table'] ?? const <String>{};
        final existingTriggers = objectsByType['trigger'] ?? const <String>{};
        final missingObjects = <String>[
          for (final table in requiredTables)
            if (!existingTables.contains(table)) 'table:$table',
          for (final trigger in requiredTriggers)
            if (!existingTriggers.contains(trigger)) 'trigger:$trigger',
        ];
        if (missingObjects.isNotEmpty) {
          return _BoundedDatabaseRead(
            evidence: InstallationDatabaseEvidence(
              boundedInspectionStatus:
                  InstallationBoundedInspectionStatus.failed,
              userVersion: userVersion,
              currentSchemaVersion: currentSchemaVersion,
              failure: InstallationBoundedInspectionFailure(
                kind: InstallationBoundedInspectionFailureKind
                    .missingRequiredObject,
                message:
                    'Required database objects are missing: '
                    '${missingObjects.join(', ')}.',
              ),
            ),
          );
        }

        phase = _BoundedReadPhase.targetedRead;
        for (final table in requiredTables) {
          _probeTable(database, table);
        }
        if (probeFts && userVersion == currentSchemaVersion) {
          const ftsProbeSql = 'SELECT rowid FROM message_text_fts LIMIT 1';
          assertReadOnlySql(
            ftsProbeSql,
            boundary: 'Installation-state FTS readability probe',
          );
          database.select(ftsProbeSql);
        }

        OnboardingOperationSnapshot? operationSnapshot;
        InstallationBoundedInspectionFailure? operationSnapshotFailure;
        if (readOperationSnapshot) {
          try {
            operationSnapshot = _readOperationSnapshot(database);
          } on Object catch (error) {
            operationSnapshotFailure = InstallationBoundedInspectionFailure(
              kind: InstallationBoundedInspectionFailureKind
                  .malformedOnboardingSnapshot,
              message: '$error',
            );
          }
        }

        return _BoundedDatabaseRead(
          evidence: InstallationDatabaseEvidence.passed(
            userVersion: userVersion,
            currentSchemaVersion: currentSchemaVersion,
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
                    'SELECT EXISTS( '
                    'SELECT 1 FROM source_registry '
                    'WHERE source_id NOT IN (?, ?) LIMIT 1)',
                    <Object?>[liveChatDbSourceId, liveAddressBookSourceId],
                  )
                : null,
          ),
          operationSnapshot: operationSnapshot,
          operationSnapshotFailure: operationSnapshotFailure,
        );
      } finally {
        database.dispose();
      }
    } on Object catch (error) {
      return _readFailureFor(error, phase);
    }
  }

  OnboardingOperationSnapshot _readOperationSnapshot(Database database) {
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
  }

  _BoundedDatabaseRead _readFailureFor(Object error, _BoundedReadPhase phase) {
    if (error is SqliteException) {
      final status = switch (error.resultCode) {
        SqlError.SQLITE_BUSY || SqlError.SQLITE_LOCKED =>
          InstallationBoundedInspectionStatus.contention,
        _ => InstallationBoundedInspectionStatus.failed,
      };
      final kind = switch (error.resultCode) {
        SqlError.SQLITE_NOTADB =>
          InstallationBoundedInspectionFailureKind.invalidSqlite,
        SqlError.SQLITE_CORRUPT =>
          InstallationBoundedInspectionFailureKind.sqliteCorrupt,
        SqlError.SQLITE_IOERR || SqlError.SQLITE_CANTOPEN =>
          InstallationBoundedInspectionFailureKind.ioFailure,
        SqlError.SQLITE_BUSY || SqlError.SQLITE_LOCKED =>
          InstallationBoundedInspectionFailureKind.unknown,
        _ when phase == _BoundedReadPhase.targetedRead =>
          InstallationBoundedInspectionFailureKind.targetedReadFailure,
        _ => InstallationBoundedInspectionFailureKind.unknown,
      };
      return _BoundedDatabaseRead(
        evidence: InstallationDatabaseEvidence(
          boundedInspectionStatus: status,
          failure: InstallationBoundedInspectionFailure(
            kind: kind,
            message: '$error',
            sqliteResultCode: error.resultCode,
          ),
        ),
      );
    }
    return _failedRead(
      phase == _BoundedReadPhase.targetedRead
          ? InstallationBoundedInspectionFailureKind.targetedReadFailure
          : InstallationBoundedInspectionFailureKind.unknown,
      '$error',
    );
  }

  _BoundedDatabaseRead _failedRead(
    InstallationBoundedInspectionFailureKind kind,
    String message,
  ) {
    return _BoundedDatabaseRead(
      evidence: InstallationDatabaseEvidence(
        boundedInspectionStatus: InstallationBoundedInspectionStatus.failed,
        failure: InstallationBoundedInspectionFailure(
          kind: kind,
          message: message,
        ),
      ),
    );
  }

  void _probeTable(Database database, String tableName) {
    final sql = 'SELECT 1 FROM ${_quotedIdentifier(tableName)} LIMIT 1';
    assertReadOnlySql(sql, boundary: 'Installation-state bounded table probe');
    database.select(sql);
  }

  int _tableCount(Database database, String tableName) {
    final sql = 'SELECT COUNT(*) FROM ${_quotedIdentifier(tableName)}';
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

  String _quotedIdentifier(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}

enum _BoundedReadPhase { open, configure, schema, inventory, targetedRead }

final class _BoundedDatabaseRead {
  const _BoundedDatabaseRead({
    required this.evidence,
    this.operationSnapshot,
    this.operationSnapshotFailure,
  });

  final InstallationDatabaseEvidence evidence;
  final OnboardingOperationSnapshot? operationSnapshot;
  final InstallationBoundedInspectionFailure? operationSnapshotFailure;
}
