import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/db/app_database_schema_versions.dart';
import '../../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../application/environment_evidence_repository.dart';
import '../../domain/entities/environment_summary.dart';

typedef EnvironmentSqlObserver = void Function(String sql);

final class SqliteEnvironmentEvidenceRepository
    implements EnvironmentEvidenceRepository {
  const SqliteEnvironmentEvidenceRepository({
    EnvironmentSqlObserver? sqlObserver,
    bool useBackgroundIsolate = true,
  }) : _sqlObserver = sqlObserver,
       _useBackgroundIsolate = useBackgroundIsolate;

  final EnvironmentSqlObserver? _sqlObserver;
  final bool _useBackgroundIsolate;

  @override
  Future<EnvironmentRootEvidence> inspectDataRoot(String canonicalRootPath) {
    return _run(
      () => _inspectDataRoot(canonicalRootPath),
      () => _inspectDataRoot(canonicalRootPath),
    );
  }

  @override
  Future<List<EnvironmentDatabaseSummary>> inspectDatabases(
    String canonicalRootPath,
  ) {
    return _run(
      () => _inspectDatabases(canonicalRootPath, null),
      () => _inspectDatabases(canonicalRootPath, _sqlObserver),
    );
  }

  @override
  Future<EnvironmentMessageEvidence> readMessageEvidence(
    String canonicalRootPath,
  ) {
    return _run(
      () => _readMessageEvidence(canonicalRootPath, null),
      () => _readMessageEvidence(canonicalRootPath, _sqlObserver),
    );
  }

  @override
  Future<List<EnvironmentMessageDateRangeEvidence>> readMessageDateRanges(
    String canonicalRootPath,
    Iterable<int> sourceIds,
  ) {
    final ids = List<int>.unmodifiable(sourceIds);
    return _run(
      () => _readMessageDateRanges(canonicalRootPath, ids, null),
      () => _readMessageDateRanges(canonicalRootPath, ids, _sqlObserver),
    );
  }

  @override
  Future<EnvironmentContactsEvidence> readContactsEvidence(
    String canonicalRootPath,
  ) {
    return _run(
      () => _readContactsEvidence(canonicalRootPath, null),
      () => _readContactsEvidence(canonicalRootPath, _sqlObserver),
    );
  }

  @override
  Future<EnvironmentFtsEvidence> readFtsEvidence(String canonicalRootPath) {
    return _run(
      () => _readFtsEvidence(canonicalRootPath, null),
      () => _readFtsEvidence(canonicalRootPath, _sqlObserver),
    );
  }

  Future<T> _run<T>(T Function() isolated, T Function() observed) {
    if (_useBackgroundIsolate && _sqlObserver == null) {
      return Isolate.run(isolated);
    }
    return Future<T>.sync(observed);
  }
}

EnvironmentRootEvidence _inspectDataRoot(String canonicalRootPath) {
  final displayVolumeName = environmentDisplayVolumeName(canonicalRootPath);
  try {
    final type = FileSystemEntity.typeSync(
      canonicalRootPath,
      followLinks: true,
    );
    return switch (type) {
      FileSystemEntityType.directory => EnvironmentRootEvidence(
        availability: EnvironmentAvailability.connected,
        displayVolumeName: displayVolumeName,
      ),
      FileSystemEntityType.notFound => EnvironmentRootEvidence(
        availability: environmentPathUsesExternalVolume(canonicalRootPath)
            ? EnvironmentAvailability.disconnected
            : EnvironmentAvailability.missing,
        displayVolumeName: displayVolumeName,
        issue: 'The admitted data folder is not currently available.',
      ),
      _ => EnvironmentRootEvidence(
        availability: EnvironmentAvailability.invalid,
        displayVolumeName: displayVolumeName,
        issue: 'The admitted data root is not a directory.',
      ),
    };
  } on FileSystemException catch (error) {
    return EnvironmentRootEvidence(
      availability: EnvironmentAvailability.permissionRequired,
      displayVolumeName: displayVolumeName,
      issue: error.message,
    );
  }
}

List<EnvironmentDatabaseSummary> _inspectDatabases(
  String canonicalRootPath,
  EnvironmentSqlObserver? observer,
) {
  const specifications = <(EnvironmentDatabaseRole, AppDatabaseFile, int)>[
    (
      EnvironmentDatabaseRole.sourceImport,
      AppDatabaseFile.sourceScopedImport,
      sourceScopedImportSchemaVersion,
    ),
    (
      EnvironmentDatabaseRole.conversationGraph,
      AppDatabaseFile.conversationGraph,
      conversationGraphSchemaVersion,
    ),
    (
      EnvironmentDatabaseRole.userOverlay,
      AppDatabaseFile.overlay,
      overlaySchemaVersion,
    ),
    (
      EnvironmentDatabaseRole.presence,
      AppDatabaseFile.presence,
      presenceSchemaVersion,
    ),
  ];

  return <EnvironmentDatabaseSummary>[
    for (final specification in specifications)
      _inspectDatabase(
        databasePath: appDatabasePath(
          specification.$2,
          databaseDirectory: canonicalRootPath,
        ),
        role: specification.$1,
        expectedVersion: specification.$3,
        observer: observer,
      ),
  ];
}

EnvironmentDatabaseSummary _inspectDatabase({
  required String databasePath,
  required EnvironmentDatabaseRole role,
  required int expectedVersion,
  required EnvironmentSqlObserver? observer,
}) {
  final file = File(databasePath);
  if (!file.existsSync()) {
    return EnvironmentDatabaseSummary(
      role: role,
      path: databasePath,
      exists: false,
      readable: false,
      expectedVersion: expectedVersion,
      issue: role == EnvironmentDatabaseRole.presence
          ? null
          : 'Database is not present.',
    );
  }

  int? sizeBytes;
  try {
    sizeBytes = file.statSync().size;
    final userVersion = _withReadOnlyDatabase(
      databasePath,
      observer,
      (database) =>
          _readScalarInt(database, 'PRAGMA user_version;', observer: observer),
    );
    return EnvironmentDatabaseSummary(
      role: role,
      path: databasePath,
      exists: true,
      readable: true,
      sizeBytes: sizeBytes,
      userVersion: userVersion,
      expectedVersion: expectedVersion,
    );
  } on Object catch (error) {
    return EnvironmentDatabaseSummary(
      role: role,
      path: databasePath,
      exists: true,
      readable: false,
      sizeBytes: sizeBytes,
      expectedVersion: expectedVersion,
      issue: 'Database could not be read: $error',
    );
  }
}

EnvironmentMessageEvidence _readMessageEvidence(
  String canonicalRootPath,
  EnvironmentSqlObserver? observer,
) {
  final importPath = appDatabasePath(
    AppDatabaseFile.sourceScopedImport,
    databaseDirectory: canonicalRootPath,
  );
  final graphPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: canonicalRootPath,
  );
  _requireDatabase(importPath, 'Source import database');
  _requireDatabase(graphPath, 'Conversation Graph database');

  final registrySources = _withReadOnlyDatabase(importPath, observer, (
    database,
  ) {
    const sql = '''
SELECT source_id, source_key, source_kind, source_label
FROM source_registry
WHERE source_kind IN (?, ?)
ORDER BY source_id
''';
    return _select(
      database,
      sql,
      parameters: <Object?>[
        liveChatDbSourceKind,
        historicalMessagesArchiveSourceKind,
      ],
      observer: observer,
    );
  });

  return _withReadOnlyDatabase(graphPath, observer, (database) {
    const totalSql = '''
SELECT
  (SELECT COUNT(*) FROM messages) AS message_count,
  (SELECT COUNT(*) FROM chats) AS conversation_count,
  (SELECT COUNT(*) FROM message_to_attachment) AS attachment_reference_count
''';
    final totalRow = _select(database, totalSql, observer: observer).single;
    final sources = <EnvironmentMessageSourceEvidence>[];
    for (final row in registrySources) {
      final sourceId = _readRequiredInt(row, 'source_id');
      final sourceKey = _readRequiredString(row, 'source_key');
      final sourceKind = _readRequiredString(row, 'source_kind');
      final registryLabel = _readNullableString(row, 'source_label')?.trim();
      final bounds = _packedBounds(sourceId);
      const sourceCountSql = '''
SELECT COUNT(*) AS message_count
FROM messages
WHERE ss_id BETWEEN ? AND ?
''';
      final sourceCount = _readRequiredInt(
        _select(
          database,
          sourceCountSql,
          parameters: <Object?>[bounds.$1, bounds.$2],
          observer: observer,
        ).single,
        'message_count',
      );
      if (sourceCount == 0) {
        continue;
      }

      final normalizedLabel = registryLabel == null || registryLabel.isEmpty
          ? null
          : registryLabel;
      if (sourceKind == liveChatDbSourceKind) {
        sources.add(
          EnvironmentMessageSourceEvidence(
            sourceId: sourceId,
            sourceKey: sourceKey,
            kind: EnvironmentMessageSourceKind.currentMacMessages,
            displayLabel: normalizedLabel ?? 'Current Mac Messages',
            registryLabel: normalizedLabel,
            projectedMessageCount: sourceCount,
          ),
        );
        continue;
      }
      final identity = HistoricalArchiveSourceIdentity.fromPersistedValue(
        sourceKey,
      );
      sources.add(
        EnvironmentMessageSourceEvidence(
          sourceId: sourceId,
          sourceKey: sourceKey,
          kind: EnvironmentMessageSourceKind.historicalMessagesArchive,
          displayLabel: normalizedLabel ?? 'Historical Messages Archive',
          registryLabel: normalizedLabel,
          canonicalSourcePath: identity.canonicalSourcePath,
          projectedMessageCount: sourceCount,
        ),
      );
    }

    return EnvironmentMessageEvidence(
      projectedMessageCount: _readRequiredInt(totalRow, 'message_count'),
      conversationCount: _readRequiredInt(totalRow, 'conversation_count'),
      attachmentReferenceCount: _readRequiredInt(
        totalRow,
        'attachment_reference_count',
      ),
      sources: sources,
    );
  });
}

List<EnvironmentMessageDateRangeEvidence> _readMessageDateRanges(
  String canonicalRootPath,
  List<int> sourceIds,
  EnvironmentSqlObserver? observer,
) {
  if (sourceIds.isEmpty) {
    return const <EnvironmentMessageDateRangeEvidence>[];
  }
  final graphPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: canonicalRootPath,
  );
  _requireDatabase(graphPath, 'Conversation Graph database');
  return _withReadOnlyDatabase(graphPath, observer, (database) {
    const sql = '''
SELECT MIN(date_utc) AS earliest_utc, MAX(date_utc) AS latest_utc
FROM messages
WHERE ss_id BETWEEN ? AND ?
''';
    return <EnvironmentMessageDateRangeEvidence>[
      for (final sourceId in sourceIds)
        _dateRangeEvidence(
          database: database,
          sql: sql,
          sourceId: sourceId,
          observer: observer,
        ),
    ];
  });
}

EnvironmentMessageDateRangeEvidence _dateRangeEvidence({
  required Database database,
  required String sql,
  required int sourceId,
  required EnvironmentSqlObserver? observer,
}) {
  final bounds = _packedBounds(sourceId);
  final row = _select(
    database,
    sql,
    parameters: <Object?>[bounds.$1, bounds.$2],
    observer: observer,
  ).single;
  return EnvironmentMessageDateRangeEvidence(
    sourceId: sourceId,
    earliestMessageUtc: _readUtcDate(row, 'earliest_utc'),
    latestMessageUtc: _readUtcDate(row, 'latest_utc'),
  );
}

EnvironmentContactsEvidence _readContactsEvidence(
  String canonicalRootPath,
  EnvironmentSqlObserver? observer,
) {
  final importPath = appDatabasePath(
    AppDatabaseFile.sourceScopedImport,
    databaseDirectory: canonicalRootPath,
  );
  final graphPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: canonicalRootPath,
  );
  _requireDatabase(importPath, 'Source import database');
  _requireDatabase(graphPath, 'Conversation Graph database');

  final importedChannelCount = _withReadOnlyDatabase(
    importPath,
    observer,
    (database) => _readScalarInt(
      database,
      'SELECT COUNT(*) AS count FROM contact_channels;',
      observer: observer,
    ),
  );
  final graphCounts = _withReadOnlyDatabase(graphPath, observer, (database) {
    const sql = '''
SELECT
  (SELECT COUNT(*) FROM contacts) AS contact_count,
  (SELECT COUNT(*) FROM contact_to_handle) AS linked_handle_count
''';
    return _select(database, sql, observer: observer).single;
  });
  return EnvironmentContactsEvidence(
    projectedContactCount: _readRequiredInt(graphCounts, 'contact_count'),
    linkedHandleCount: _readRequiredInt(graphCounts, 'linked_handle_count'),
    importedChannelCount: importedChannelCount,
  );
}

EnvironmentFtsEvidence _readFtsEvidence(
  String canonicalRootPath,
  EnvironmentSqlObserver? observer,
) {
  final graphPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: canonicalRootPath,
  );
  _requireDatabase(graphPath, 'Conversation Graph database');
  return _withReadOnlyDatabase(graphPath, observer, (database) {
    const inventorySql = '''
SELECT COUNT(*) AS count
FROM sqlite_master
WHERE type = 'table' AND name = 'message_text_fts'
''';
    final isAvailable =
        _readScalarInt(database, inventorySql, observer: observer) > 0;
    if (!isAvailable) {
      return const EnvironmentFtsEvidence(isAvailable: false, rowCount: null);
    }
    return EnvironmentFtsEvidence(
      isAvailable: true,
      rowCount: _readScalarInt(
        database,
        'SELECT COUNT(*) AS count FROM message_text_fts;',
        observer: observer,
      ),
    );
  });
}

T _withReadOnlyDatabase<T>(
  String databasePath,
  EnvironmentSqlObserver? observer,
  T Function(Database database) action,
) {
  final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
  try {
    _executeConnectionPragma(database, 'PRAGMA query_only = ON;', observer);
    _executeConnectionPragma(database, 'PRAGMA busy_timeout = 3000;', observer);
    return action(database);
  } finally {
    database.dispose();
  }
}

void _executeConnectionPragma(
  Database database,
  String sql,
  EnvironmentSqlObserver? observer,
) {
  assertEnvironmentSummaryReadOnlySql(sql);
  observer?.call(sql);
  database.execute(sql);
}

ResultSet _select(
  Database database,
  String sql, {
  List<Object?> parameters = const <Object?>[],
  EnvironmentSqlObserver? observer,
}) {
  assertEnvironmentSummaryReadOnlySql(sql);
  observer?.call(sql);
  return database.select(sql, parameters);
}

int _readScalarInt(
  Database database,
  String sql, {
  required EnvironmentSqlObserver? observer,
}) {
  final rows = _select(database, sql, observer: observer);
  if (rows.isEmpty || rows.first.values.isEmpty) {
    throw StateError('Environment evidence query returned no scalar value.');
  }
  final value = rows.first.values.first;
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw StateError('Environment evidence scalar must be an integer.');
}

void _requireDatabase(String databasePath, String label) {
  if (!File(databasePath).existsSync()) {
    throw EnvironmentEvidenceUnavailableException(
      '$label is not currently available.',
    );
  }
}

(int, int) _packedBounds(int sourceId) {
  return (
    SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: 1),
    SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: SourceScopedRowKey.maxSourceRowId,
    ),
  );
}

int _readRequiredInt(Row row, String key) {
  final value = row[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw StateError('Missing required integer column $key');
}

String _readRequiredString(Row row, String key) {
  final value = _readNullableString(row, key);
  if (value == null) {
    throw StateError('Missing required string column $key');
  }
  return value;
}

String? _readNullableString(Row row, String key) {
  final value = row[key];
  return value is String ? value : null;
}

DateTime? _readUtcDate(Row row, String key) {
  final value = _readNullableString(row, key);
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return DateTime.parse(value).toUtc();
}
