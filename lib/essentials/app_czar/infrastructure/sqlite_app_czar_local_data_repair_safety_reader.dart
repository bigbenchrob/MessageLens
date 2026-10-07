import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../db/app_database_files.dart';
import '../../db/app_database_schema_versions.dart';
import '../../db/application/read_only_sql_guard.dart';
import '../../source_scoped_import/application/contacts/contact_source_projection.dart';
import '../../source_scoped_import/domain/known_sources.dart';
import '../domain/app_czar_models.dart';

const _pageSize = 200;

final class SqliteAppCzarLocalDataRepairSafetyReader {
  const SqliteAppCzarLocalDataRepairSafetyReader({
    required this.archiveRootPath,
    required this.archiveInstanceId,
    required this.messagesDatabasePath,
    required this.contactsDatabasePath,
    this.stabilityObservationInterval = Duration.zero,
  });

  final String archiveRootPath;
  final String archiveInstanceId;
  final String messagesDatabasePath;
  final String? contactsDatabasePath;
  final Duration stabilityObservationInterval;

  Future<AppCzarLocalDataRepairSafetyObservation> read({
    required AppCzarArchiveObservation attachmentArchive,
    required AppCzarContactsPrerequisiteObservation contactsPrerequisite,
  }) {
    final input = _SafetyReadInput(
      archiveRootPath: archiveRootPath,
      archiveInstanceId: archiveInstanceId,
      messagesDatabasePath: messagesDatabasePath,
      contactsDatabasePath: contactsDatabasePath,
      archiveScopeIdentity: attachmentArchive.archiveScopeIdentity,
      archiveGeneration: attachmentArchive.archiveGeneration,
      archiveBindingComplete: attachmentArchive.hasCompleteArchiveBinding,
      contactsCondition: contactsPrerequisite.condition,
      stabilityObservationInterval: stabilityObservationInterval,
    );
    return Isolate.run(() => _readSynchronously(input));
  }
}

AppCzarLocalDataRepairSafetyObservation _readSynchronously(
  _SafetyReadInput input,
) {
  final bindingIssue = _validateBinding(input);
  if (bindingIssue != null) {
    return _unknown(input, bindingIssue);
  }

  if (_retiredArtifactsExist(input.archiveRootPath)) {
    return _knownUnsafe(
      input,
      AppCzarLocalDataRepairSafetyCondition.retiredArtifactsPresent,
      'Retired derived database artifacts require separate review.',
    );
  }

  final graphResult = _inspectGraph(input.archiveRootPath);
  if (graphResult.issue != null) {
    return _knownUnsafe(
      input,
      AppCzarLocalDataRepairSafetyCondition.unsupportedOrCorrupt,
      graphResult.issue!,
    );
  }
  if (graphResult.consequentialRowCount > 0) {
    return _knownUnsafe(
      input,
      AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent,
      'The current graph contains consequential facts that Stage One does not delete automatically.',
    );
  }

  final importPath = appDatabasePath(
    AppDatabaseFile.sourceScopedImport,
    databaseDirectory: input.archiveRootPath,
  );
  Database? importDatabase;
  Database? sourceDatabase;
  Database? contactsDatabase;
  try {
    importDatabase = sqlite3.open(importPath, mode: OpenMode.readOnly);
    sourceDatabase = sqlite3.open(
      input.messagesDatabasePath,
      mode: OpenMode.readOnly,
    );
    _configureReadOnly(importDatabase);
    _configureReadOnly(sourceDatabase);
    importDatabase.execute('BEGIN;');
    sourceDatabase.execute('BEGIN;');

    final firstImportFileEvidence = _sqliteFamilyFileEvidence(importPath);

    final schemaIssue = _validateImportSchema(importDatabase);
    if (schemaIssue != null) {
      return _knownUnsafe(
        input,
        AppCzarLocalDataRepairSafetyCondition.unsupportedOrCorrupt,
        schemaIssue,
      );
    }
    final sourceSchemaIssue = _validateMessagesSourceSchema(sourceDatabase);
    if (sourceSchemaIssue != null) {
      return _unknown(input, sourceSchemaIssue);
    }

    final firstSourceFingerprint = _sourceFingerprint(
      sourceDatabase,
      input.messagesDatabasePath,
    );
    if (input.stabilityObservationInterval > Duration.zero) {
      sleep(input.stabilityObservationInterval);
    }
    final rowCounts = _importRowCounts(importDatabase);
    if (!_hasConsequentialImportFacts(rowCounts)) {
      return _knownUnsafe(
        input,
        AppCzarLocalDataRepairSafetyCondition.unsupportedOrCorrupt,
        'No consequential source-scoped import facts require repair.',
        rowCounts: rowCounts,
      );
    }

    final inventoryIssue = _validateLiveOnlyInventory(importDatabase);
    if (inventoryIssue != null) {
      return _knownUnsafe(
        input,
        AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent,
        inventoryIssue,
        rowCounts: rowCounts,
      );
    }
    final integrityIssue = _validateImportIntegrity(importDatabase);
    if (integrityIssue != null) {
      return _knownUnsafe(
        input,
        AppCzarLocalDataRepairSafetyCondition.unsupportedOrCorrupt,
        integrityIssue,
        rowCounts: rowCounts,
      );
    }

    final hasContactFacts =
        (rowCounts['contacts'] ?? 0) > 0 ||
        (rowCounts['contact_channels'] ?? 0) > 0;
    if (hasContactFacts && !_contactsSourceIsViable(input.contactsCondition)) {
      return _unknown(
        input,
        'Current Contacts evidence cannot prove deterministic enrichment reconstruction.',
      );
    }
    String? contactsFingerprint;
    if (hasContactFacts) {
      final contactsPath = input.contactsDatabasePath;
      if (contactsPath == null || contactsPath.isEmpty) {
        return _unknown(
          input,
          'The exact current Contacts database identity is unavailable.',
        );
      }
      contactsDatabase = sqlite3.open(contactsPath, mode: OpenMode.readOnly);
      _configureReadOnly(contactsDatabase);
      contactsDatabase.execute('BEGIN;');
      final contactsSchemaIssue = _validateContactsSourceSchema(
        contactsDatabase,
      );
      if (contactsSchemaIssue != null) {
        return _unknown(input, contactsSchemaIssue);
      }
      contactsFingerprint = _contactsSourceFingerprint(
        contactsDatabase,
        contactsPath,
      );
      final contactsDifference = _firstContactsSourceDifference(
        importDatabase,
        contactsDatabase,
      );
      if (contactsDifference != null) {
        return _knownUnsafe(
          input,
          AppCzarLocalDataRepairSafetyCondition.sourceFactMissing,
          contactsDifference,
          rowCounts: rowCounts,
        );
      }
    }

    final difference = _firstSourceDifference(importDatabase, sourceDatabase);
    if (difference != null) {
      return _knownUnsafe(
        input,
        AppCzarLocalDataRepairSafetyCondition.sourceFactMissing,
        difference,
        rowCounts: rowCounts,
      );
    }

    final secondSourceFingerprint = _sourceFingerprint(
      sourceDatabase,
      input.messagesDatabasePath,
    );
    if (firstSourceFingerprint != secondSourceFingerprint) {
      return _unknown(
        input,
        'The Messages source changed during repair-safety inspection.',
      );
    }
    if (contactsDatabase != null &&
        contactsFingerprint !=
            _contactsSourceFingerprint(
              contactsDatabase,
              input.contactsDatabasePath!,
            )) {
      return _unknown(
        input,
        'The Contacts source changed during repair-safety inspection.',
      );
    }
    if (!_sameStrings(
      firstImportFileEvidence,
      _sqliteFamilyFileEvidence(importPath),
    )) {
      return _unknown(
        input,
        'The source-scoped import evidence changed during repair-safety inspection.',
      );
    }
    final finalGraphResult = _inspectGraph(input.archiveRootPath);
    if (finalGraphResult.issue != null ||
        finalGraphResult.consequentialRowCount > 0) {
      return _unknown(
        input,
        'The conversation graph changed during repair-safety inspection.',
      );
    }

    final footprint = <String>[
      appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      appDatabaseFileName(AppDatabaseFile.conversationGraph),
    ];
    final evidenceFingerprint = sha256
        .convert(
          utf8.encode(
            <String>[
              input.archiveRootPath,
              input.archiveInstanceId,
              input.archiveScopeIdentity!,
              '${input.archiveGeneration}',
              firstSourceFingerprint,
              contactsFingerprint ?? 'contacts:not-required',
              ...footprint,
              for (final entry in rowCounts.entries)
                '${entry.key}:${entry.value}',
            ].join('|'),
          ),
        )
        .toString();
    return AppCzarLocalDataRepairSafetyObservation(
      condition:
          AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial,
      archiveRootPath: input.archiveRootPath,
      archiveInstanceId: input.archiveInstanceId,
      archiveScopeIdentity: input.archiveScopeIdentity,
      archiveGeneration: input.archiveGeneration,
      sourceFingerprint: firstSourceFingerprint,
      evidenceFingerprint: evidenceFingerprint,
      resetFootprint: footprint,
      consequentialRowCounts: rowCounts,
      issue: null,
    );
  } on SqliteException catch (error) {
    return _unknown(input, 'Repair-safety SQLite inspection failed: $error');
  } on FileSystemException catch (error) {
    return _unknown(input, 'Repair-safety file inspection failed: $error');
  } on Object catch (error) {
    return _unknown(input, 'Repair safety could not be established: $error');
  } finally {
    contactsDatabase?.dispose();
    sourceDatabase?.dispose();
    importDatabase?.dispose();
  }
}

bool _hasConsequentialImportFacts(Map<String, int> rowCounts) {
  return rowCounts.entries.any(
    (entry) =>
        entry.key != 'source_registry' &&
        entry.key != 'import_batches' &&
        entry.value > 0,
  );
}

String? _validateBinding(_SafetyReadInput input) {
  if (!input.archiveBindingComplete ||
      input.archiveScopeIdentity == null ||
      input.archiveScopeIdentity!.isEmpty ||
      input.archiveGeneration == null ||
      input.archiveGeneration! < 0 ||
      input.archiveInstanceId.isEmpty) {
    return 'The admitted archive occurrence is not completely bound.';
  }
  return null;
}

bool _retiredArtifactsExist(String root) {
  for (final databaseFile in <AppDatabaseFile>[
    AppDatabaseFile.retiredMacosImport,
    AppDatabaseFile.retiredWorking,
  ]) {
    final base = appDatabasePath(databaseFile, databaseDirectory: root);
    for (final candidate in <String>[base, '$base-wal', '$base-shm']) {
      if (FileSystemEntity.typeSync(candidate, followLinks: false) !=
          FileSystemEntityType.notFound) {
        return true;
      }
    }
  }
  return false;
}

_GraphInspection _inspectGraph(String root) {
  final graphPath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: root,
  );
  if (!File(graphPath).existsSync()) {
    return const _GraphInspection(consequentialRowCount: 0);
  }
  Database? database;
  try {
    database = sqlite3.open(graphPath, mode: OpenMode.readOnly);
    _configureReadOnly(database);
    if (_pragmaInt(database, 'user_version') !=
        conversationGraphSchemaVersion) {
      return const _GraphInspection(
        consequentialRowCount: 0,
        issue: 'The graph schema is unsupported for automatic repair.',
      );
    }
    const tables = <String>[
      'messages',
      'handles',
      'canonical_handles',
      'handle_aliases',
      'chats',
      'chat_to_message',
      'chat_to_handle',
      'contacts',
      'contact_to_handle',
      'attachments',
      'message_to_attachment',
    ];
    var count = 0;
    for (final table in tables) {
      count += _tableCount(database, table);
    }
    return _GraphInspection(consequentialRowCount: count);
  } on Object catch (error) {
    return _GraphInspection(
      consequentialRowCount: 0,
      issue: 'The graph could not be proved empty and derived: $error',
    );
  } finally {
    database?.dispose();
  }
}

String? _validateImportSchema(Database database) {
  if (_pragmaInt(database, 'user_version') != sourceScopedImportSchemaVersion) {
    return 'The source-scoped import schema is unsupported.';
  }
  const expectedTables = <String>{
    'source_registry',
    'import_batches',
    'messages',
    'handles',
    'chats',
    'chat_to_message',
    'chat_to_handle',
    'contacts',
    'contact_channels',
    'attachments',
    'message_to_attachment',
  };
  const inventorySql =
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'";
  assertReadOnlySql(
    inventorySql,
    boundary: 'Local Data Repair table inventory',
  );
  final actual = <String>{
    for (final row in database.select(inventorySql)) row['name'] as String,
  };
  if (!_setEquals(actual, expectedTables)) {
    return 'The source-scoped import table inventory is not the exact current schema.';
  }
  return null;
}

String? _validateMessagesSourceSchema(Database database) {
  const requiredColumns = <String, Set<String>>{
    'message': {'ROWID', 'guid', 'attributedBody'},
    'handle': {'ROWID', 'id'},
    'chat': {'ROWID', 'guid'},
    'attachment': {'ROWID', 'guid'},
    'chat_message_join': {'ROWID', 'chat_id', 'message_id'},
    'chat_handle_join': {'chat_id', 'handle_id'},
    'message_attachment_join': {'message_id', 'attachment_id'},
  };
  for (final entry in requiredColumns.entries) {
    final columns = _tableColumns(database, entry.key);
    if (!entry.value.every(columns.contains)) {
      return 'The current Messages source lacks required ${entry.key} reconstruction columns.';
    }
  }
  return null;
}

String? _validateContactsSourceSchema(Database database) {
  const requiredColumns = <String, Set<String>>{
    'ZABCDRECORD': {
      'Z_PK',
      'ZFIRSTNAME',
      'ZMIDDLENAME',
      'ZLASTNAME',
      'ZORGANIZATION',
      'ZCREATIONDATE',
    },
    'ZABCDEMAILADDRESS': {'ZOWNER', 'ZADDRESS', 'ZADDRESSNORMALIZED', 'ZLABEL'},
    'ZABCDPHONENUMBER': {'ZOWNER', 'ZFULLNUMBER', 'ZVALUE', 'ZLABEL'},
  };
  for (final entry in requiredColumns.entries) {
    final columns = _tableColumns(database, entry.key);
    if (!entry.value.every(columns.contains)) {
      return 'The current Contacts source lacks required ${entry.key} reconstruction columns.';
    }
  }
  return null;
}

Map<String, int> _importRowCounts(Database database) {
  const tables = <String>[
    'source_registry',
    'import_batches',
    'messages',
    'handles',
    'chats',
    'chat_to_message',
    'chat_to_handle',
    'contacts',
    'contact_channels',
    'attachments',
    'message_to_attachment',
  ];
  return <String, int>{
    for (final table in tables) table: _tableCount(database, table),
  };
}

String? _validateLiveOnlyInventory(Database database) {
  const sql = '''
SELECT source_id, source_key, source_kind
FROM source_registry
ORDER BY source_id;
''';
  assertReadOnlySql(sql, boundary: 'Local Data Repair source inventory');
  final rows = database.select(sql);
  if (rows.length != 2) {
    return 'The import ledger does not contain exactly the two canonical live sources.';
  }
  final expected = <int, (String, String)>{
    liveChatDbSourceId: (liveChatDbSourceKey, liveChatDbSourceKind),
    liveAddressBookSourceId: (
      liveAddressBookSourceKey,
      liveAddressBookSourceKind,
    ),
  };
  for (final row in rows) {
    final sourceId = _requiredInt(row['source_id']);
    final identity = expected[sourceId];
    if (identity == null ||
        row['source_key'] != identity.$1 ||
        row['source_kind'] != identity.$2) {
      return 'The import ledger contains non-live or non-canonical source identity.';
    }
  }
  return null;
}

String? _validateImportIntegrity(Database database) {
  const foreignKeySql = 'PRAGMA foreign_key_check';
  assertReadOnlySql(
    foreignKeySql,
    boundary: 'Local Data Repair foreign-key integrity',
  );
  if (database.select(foreignKeySql).isNotEmpty) {
    return 'The source-scoped import ledger has foreign-key violations.';
  }
  const batchSourceSql = '''
SELECT 1
FROM import_batches
WHERE source_id NOT IN (?, ?)
LIMIT 1;
''';
  assertReadOnlySql(
    batchSourceSql,
    boundary: 'Local Data Repair batch lineage',
  );
  if (database.select(batchSourceSql, <Object?>[
    liveChatDbSourceId,
    liveAddressBookSourceId,
  ]).isNotEmpty) {
    return 'An import batch belongs to a protected non-live source.';
  }
  const lineageChecks = <String>[
    'SELECT 1 FROM messages WHERE source_id != 1 LIMIT 1',
    'SELECT 1 FROM handles WHERE source_id != 1 LIMIT 1',
    'SELECT 1 FROM chats WHERE source_id != 1 LIMIT 1',
    'SELECT 1 FROM chat_to_message WHERE source_id != 1 LIMIT 1',
    'SELECT 1 FROM chat_to_handle WHERE source_id != 1 LIMIT 1',
    'SELECT 1 FROM attachments WHERE source_id != 1 LIMIT 1',
    'SELECT 1 FROM contacts WHERE source_id != 2 LIMIT 1',
    'SELECT 1 FROM contact_channels WHERE source_id != 2 LIMIT 1',
    'SELECT 1 FROM message_to_attachment WHERE message_source_id != 1 OR attachment_source_id != 1 LIMIT 1',
  ];
  for (final sql in lineageChecks) {
    assertReadOnlySql(sql, boundary: 'Local Data Repair row lineage');
    if (database.select(sql).isNotEmpty) {
      return 'A destructive-domain row has protected or contradictory lineage.';
    }
  }

  const packedIdentityChecks = <String>[
    'SELECT 1 FROM messages WHERE ss_id != ((source_id << 43) | source_rowid) LIMIT 1',
    'SELECT 1 FROM handles WHERE ss_id != ((source_id << 43) | source_rowid) LIMIT 1',
    'SELECT 1 FROM chats WHERE ss_id != ((source_id << 43) | source_rowid) LIMIT 1',
    'SELECT 1 FROM attachments WHERE ss_id != ((source_id << 43) | source_rowid) LIMIT 1',
    'SELECT 1 FROM contacts WHERE ss_id != ((source_id << 43) | source_rowid) LIMIT 1',
    '''
SELECT 1 FROM chat_to_message WHERE
ss_id != ((source_id << 43) | source_rowid) OR
chat_ss_id != ((source_id << 43) | source_chat_rowid) OR
message_ss_id != ((source_id << 43) | source_message_rowid) LIMIT 1''',
    '''
SELECT 1 FROM chat_to_handle WHERE
chat_ss_id != ((source_id << 43) | source_chat_rowid) OR
handle_ss_id != ((source_id << 43) | source_handle_rowid) LIMIT 1''',
    '''
SELECT 1 FROM contact_channels WHERE
contact_ss_id != ((source_id << 43) | source_contact_rowid) LIMIT 1''',
    '''
SELECT 1 FROM message_to_attachment WHERE
message_ss_id != ((message_source_id << 43) | source_message_rowid) OR
attachment_ss_id != ((attachment_source_id << 43) | source_attachment_rowid) LIMIT 1''',
  ];
  for (final sql in packedIdentityChecks) {
    assertReadOnlySql(sql, boundary: 'Local Data Repair packed identity');
    if (database.select(sql).isNotEmpty) {
      return 'A destructive-domain row has contradictory packed identity.';
    }
  }

  const relationshipTargetChecks = <String>[
    '''
SELECT 1 FROM chat_to_message edge
LEFT JOIN chats chat ON chat.ss_id = edge.chat_ss_id
LEFT JOIN messages message ON message.ss_id = edge.message_ss_id
WHERE chat.ss_id IS NULL OR message.ss_id IS NULL LIMIT 1''',
    '''
SELECT 1 FROM chat_to_handle edge
LEFT JOIN chats chat ON chat.ss_id = edge.chat_ss_id
LEFT JOIN handles handle ON handle.ss_id = edge.handle_ss_id
WHERE chat.ss_id IS NULL OR handle.ss_id IS NULL LIMIT 1''',
    '''
SELECT 1 FROM contact_channels channel
LEFT JOIN contacts contact ON contact.ss_id = channel.contact_ss_id
WHERE contact.ss_id IS NULL LIMIT 1''',
    '''
SELECT 1 FROM message_to_attachment edge
LEFT JOIN messages message ON message.ss_id = edge.message_ss_id
LEFT JOIN attachments attachment ON attachment.ss_id = edge.attachment_ss_id
WHERE message.ss_id IS NULL OR attachment.ss_id IS NULL LIMIT 1''',
  ];
  for (final sql in relationshipTargetChecks) {
    assertReadOnlySql(sql, boundary: 'Local Data Repair relationship target');
    if (database.select(sql).isNotEmpty) {
      return 'A destructive-domain relationship has a missing local target.';
    }
  }
  return null;
}

String? _firstSourceDifference(Database local, Database source) {
  final checks = <_RowDifferenceCheck>[
    const _RowDifferenceCheck(
      localTable: 'messages',
      sourceTable: 'message',
      localColumns: <String>['source_rowid', 'guid'],
      sourceColumns: <String>['ROWID', 'guid'],
    ),
    const _RowDifferenceCheck(
      localTable: 'handles',
      sourceTable: 'handle',
      localColumns: <String>['source_rowid', 'id'],
      sourceColumns: <String>['ROWID', 'id'],
    ),
    const _RowDifferenceCheck(
      localTable: 'chats',
      sourceTable: 'chat',
      localColumns: <String>['source_rowid', 'guid'],
      sourceColumns: <String>['ROWID', 'guid'],
    ),
    const _RowDifferenceCheck(
      localTable: 'attachments',
      sourceTable: 'attachment',
      localColumns: <String>['source_rowid', 'guid'],
      sourceColumns: <String>['ROWID', 'guid'],
    ),
    const _RowDifferenceCheck(
      localTable: 'chat_to_message',
      sourceTable: 'chat_message_join',
      localColumns: <String>[
        'source_rowid',
        'source_chat_rowid',
        'source_message_rowid',
      ],
      sourceColumns: <String>['ROWID', 'chat_id', 'message_id'],
    ),
  ];
  for (final check in checks) {
    final issue = _compareRowsBySourceRowId(local, source, check);
    if (issue != null) {
      return issue;
    }
  }
  final chatHandleIssue = _compareRelationshipPairs(
    local,
    source,
    localTable: 'chat_to_handle',
    sourceTable: 'chat_handle_join',
    localLeft: 'source_chat_rowid',
    localRight: 'source_handle_rowid',
    sourceLeft: 'chat_id',
    sourceRight: 'handle_id',
  );
  if (chatHandleIssue != null) {
    return chatHandleIssue;
  }
  return _compareRelationshipPairs(
    local,
    source,
    localTable: 'message_to_attachment',
    sourceTable: 'message_attachment_join',
    localLeft: 'source_message_rowid',
    localRight: 'source_attachment_rowid',
    sourceLeft: 'message_id',
    sourceRight: 'attachment_id',
  );
}

String? _firstContactsSourceDifference(Database local, Database source) {
  var lastContactRowId = -1;
  while (true) {
    const localSql = '''
SELECT source_rowid, display_name, first_name, last_name, organization,
       created_at_utc
FROM contacts
WHERE source_rowid > ?
ORDER BY source_rowid
LIMIT ?;
''';
    assertReadOnlySql(
      localSql,
      boundary: 'Local Data Repair paged contact facts',
    );
    final localRows = local.select(localSql, <Object?>[
      lastContactRowId,
      _pageSize,
    ]);
    if (localRows.isEmpty) {
      break;
    }
    final rowIds = <int>[
      for (final row in localRows) _requiredInt(row['source_rowid']),
    ];
    final placeholders = List<String>.filled(rowIds.length, '?').join(',');
    final sourceSql =
        '''
SELECT Z_PK, ZFIRSTNAME, ZMIDDLENAME, ZLASTNAME, ZORGANIZATION, ZCREATIONDATE
FROM ZABCDRECORD
WHERE Z_PK IN ($placeholders);
''';
    assertReadOnlySql(
      sourceSql,
      boundary: 'Local Data Repair current contact facts',
    );
    final sourceRows = source.select(sourceSql, rowIds.cast<Object?>());
    final sourceByRowId = <int, Row>{
      for (final row in sourceRows) _requiredInt(row['Z_PK']): row,
    };
    for (final localRow in localRows) {
      final rowId = _requiredInt(localRow['source_rowid']);
      final sourceRow = sourceByRowId[rowId];
      if (sourceRow == null) {
        return 'contacts row $rowId is absent from the current Contacts source.';
      }
      final first = readTrimmedContactSourceText(sourceRow['ZFIRSTNAME']);
      final middle = readTrimmedContactSourceText(sourceRow['ZMIDDLENAME']);
      final last = readTrimmedContactSourceText(sourceRow['ZLASTNAME']);
      final organization = readTrimmedContactSourceText(
        sourceRow['ZORGANIZATION'],
      );
      final expected = <String, Object?>{
        'display_name':
            buildContactDisplayName(
              firstName: first,
              middleName: middle,
              lastName: last,
              organization: organization,
            ) ??
            'Unknown Contact',
        'first_name': first,
        'last_name': last,
        'organization': organization,
        'created_at_utc': projectContactCreatedAtUtc(
          sourceRow['ZCREATIONDATE'],
        ),
      };
      for (final entry in expected.entries) {
        if (localRow[entry.key] != entry.value) {
          return 'contacts row $rowId no longer matches its current source projection.';
        }
      }
    }
    lastContactRowId = rowIds.last;
  }

  var offset = 0;
  while (true) {
    const localSql = '''
SELECT source_contact_rowid, kind, value, label
FROM contact_channels
ORDER BY source_contact_rowid, kind, value
LIMIT ? OFFSET ?;
''';
    assertReadOnlySql(
      localSql,
      boundary: 'Local Data Repair paged contact-channel facts',
    );
    final rows = local.select(localSql, <Object?>[_pageSize, offset]);
    if (rows.isEmpty) {
      return null;
    }
    for (final row in rows) {
      final owner = _requiredInt(row['source_contact_rowid']);
      final kind = row['kind'];
      final sourceTable = kind == 'email'
          ? 'ZABCDEMAILADDRESS'
          : 'ZABCDPHONENUMBER';
      final sourceSql = 'SELECT * FROM $sourceTable WHERE ZOWNER = ?';
      assertReadOnlySql(
        sourceSql,
        boundary: 'Local Data Repair current contact-channel facts',
      );
      final matchingSourceFact = source.select(sourceSql, <Object?>[owner]).any(
        (sourceRow) {
          final projectedValue = kind == 'email'
              ? projectContactEmailAddress(sourceRow)
              : projectContactPhoneNumber(sourceRow);
          return projectedValue == row['value'] &&
              readTrimmedContactSourceText(sourceRow['ZLABEL']) == row['label'];
        },
      );
      if (!matchingSourceFact) {
        return 'contact_channels contains a fact absent from the current Contacts source.';
      }
    }
    offset += rows.length;
  }
}

String? _compareRowsBySourceRowId(
  Database local,
  Database source,
  _RowDifferenceCheck check,
) {
  var lastRowId = -1;
  while (true) {
    final localSql =
        'SELECT ${check.localColumns.join(', ')} FROM ${check.localTable} '
        'WHERE source_rowid > ? ORDER BY source_rowid LIMIT ?';
    assertReadOnlySql(localSql, boundary: 'Local Data Repair paged local rows');
    final localRows = local.select(localSql, <Object?>[lastRowId, _pageSize]);
    if (localRows.isEmpty) {
      return null;
    }
    final rowIds = <int>[
      for (final row in localRows) _requiredInt(row['source_rowid']),
    ];
    final placeholders = List<String>.filled(rowIds.length, '?').join(',');
    final projectedSourceColumns = <String>[
      '${check.sourceColumns.first} AS _source_rowid',
      ...check.sourceColumns.skip(1),
    ];
    final sourceSql =
        'SELECT ${projectedSourceColumns.join(', ')} FROM ${check.sourceTable} '
        'WHERE ROWID IN ($placeholders)';
    assertReadOnlySql(
      sourceSql,
      boundary: 'Local Data Repair paged source rows',
    );
    final sourceRows = source.select(sourceSql, rowIds.cast<Object?>());
    final sourceByRowId = <int, Row>{
      for (final row in sourceRows) _requiredInt(row['_source_rowid']): row,
    };
    for (final localRow in localRows) {
      final rowId = _requiredInt(localRow['source_rowid']);
      final sourceRow = sourceByRowId[rowId];
      if (sourceRow == null) {
        return '${check.localTable} row $rowId is absent from the current Messages source.';
      }
      for (var index = 1; index < check.localColumns.length; index += 1) {
        if (localRow[check.localColumns[index]] !=
            sourceRow[check.sourceColumns[index]]) {
          return '${check.localTable} row $rowId no longer matches its current source identity.';
        }
      }
    }
    lastRowId = rowIds.last;
  }
}

String? _compareRelationshipPairs(
  Database local,
  Database source, {
  required String localTable,
  required String sourceTable,
  required String localLeft,
  required String localRight,
  required String sourceLeft,
  required String sourceRight,
}) {
  var offset = 0;
  while (true) {
    final localSql =
        'SELECT $localLeft, $localRight FROM $localTable '
        'ORDER BY $localLeft, $localRight LIMIT ? OFFSET ?';
    assertReadOnlySql(
      localSql,
      boundary: 'Local Data Repair relationship page',
    );
    final rows = local.select(localSql, <Object?>[_pageSize, offset]);
    if (rows.isEmpty) {
      return null;
    }
    for (final row in rows) {
      final sourceSql =
          'SELECT 1 FROM $sourceTable WHERE $sourceLeft = ? AND $sourceRight = ? LIMIT 1';
      assertReadOnlySql(
        sourceSql,
        boundary: 'Local Data Repair relationship source proof',
      );
      if (source.select(sourceSql, <Object?>[
        row[localLeft],
        row[localRight],
      ]).isEmpty) {
        return '$localTable contains a relationship absent from the current Messages source.';
      }
    }
    offset += rows.length;
  }
}

String _sourceFingerprint(Database database, String databasePath) {
  const tables = <String>[
    'message',
    'handle',
    'chat',
    'attachment',
    'chat_message_join',
    'chat_handle_join',
    'message_attachment_join',
  ];
  final evidence = <String>[];
  for (final table in tables) {
    final sql =
        'SELECT COUNT(*) AS row_count, COALESCE(MAX(ROWID), 0) AS max_rowid FROM $table';
    assertReadOnlySql(sql, boundary: 'Local Data Repair source fingerprint');
    final row = database.select(sql).single;
    evidence.add(
      '$table:${_requiredInt(row['row_count'])}:${_requiredInt(row['max_rowid'])}',
    );
  }
  evidence.addAll(_sqliteFamilyFileEvidence(databasePath));
  return sha256.convert(utf8.encode(evidence.join('|'))).toString();
}

String _contactsSourceFingerprint(Database database, String databasePath) {
  const tables = <(String, String)>[
    ('ZABCDRECORD', 'Z_PK'),
    ('ZABCDEMAILADDRESS', 'ROWID'),
    ('ZABCDPHONENUMBER', 'ROWID'),
  ];
  final evidence = <String>[];
  for (final (table, identityColumn) in tables) {
    final sql =
        'SELECT COUNT(*) AS row_count, '
        'COALESCE(MAX($identityColumn), 0) AS max_identity '
        'FROM $table';
    assertReadOnlySql(
      sql,
      boundary: 'Local Data Repair Contacts source fingerprint',
    );
    final row = database.select(sql).single;
    evidence.add(
      '$table:${_requiredInt(row['row_count'])}:${_requiredInt(row['max_identity'])}',
    );
  }
  evidence.addAll(_sqliteFamilyFileEvidence(databasePath));
  return sha256.convert(utf8.encode(evidence.join('|'))).toString();
}

List<String> _sqliteFamilyFileEvidence(String databasePath) {
  return <String>[
    for (final candidate in <String>[
      databasePath,
      '$databasePath-wal',
      '$databasePath-shm',
    ])
      if (File(candidate).existsSync())
        (() {
          final stat = File(candidate).statSync();
          return '${candidate.substring(databasePath.length)}:${stat.size}:${stat.modified.microsecondsSinceEpoch}';
        })()
      else
        '${candidate.substring(databasePath.length)}:absent',
  ];
}

bool _contactsSourceIsViable(AppCzarContactsPrerequisiteCondition condition) {
  return condition == AppCzarContactsPrerequisiteCondition.viableWithContacts ||
      condition == AppCzarContactsPrerequisiteCondition.viableEmpty;
}

Set<String> _tableColumns(Database database, String table) {
  final sql = 'PRAGMA table_info("${table.replaceAll('"', '""')}")';
  assertReadOnlySql(sql, boundary: 'Local Data Repair source schema');
  final columns = <String>{
    for (final row in database.select(sql)) row['name'] as String,
  };
  if (columns.isNotEmpty) {
    columns.add('ROWID');
  }
  return columns;
}

int _tableCount(Database database, String table) {
  final sql = 'SELECT COUNT(*) AS row_count FROM "$table"';
  assertReadOnlySql(sql, boundary: 'Local Data Repair table count');
  return _requiredInt(database.select(sql).single['row_count']);
}

int _pragmaInt(Database database, String pragma) {
  final sql = 'PRAGMA $pragma';
  assertReadOnlySql(sql, boundary: 'Local Data Repair pragma');
  return _requiredInt(database.select(sql).single.values.first);
}

void _configureReadOnly(Database database) {
  database.execute('PRAGMA query_only = ON;');
  database.execute('PRAGMA busy_timeout = 3000;');
}

int _requiredInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected an integer but found $value.');
}

bool _setEquals(Set<String> left, Set<String> right) {
  return left.length == right.length && left.containsAll(right);
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

AppCzarLocalDataRepairSafetyObservation _knownUnsafe(
  _SafetyReadInput input,
  AppCzarLocalDataRepairSafetyCondition condition,
  String issue, {
  Map<String, int> rowCounts = const <String, int>{},
}) {
  return AppCzarLocalDataRepairSafetyObservation(
    condition: condition,
    archiveRootPath: input.archiveRootPath,
    archiveInstanceId: input.archiveInstanceId,
    archiveScopeIdentity: input.archiveScopeIdentity,
    archiveGeneration: input.archiveGeneration,
    sourceFingerprint: null,
    evidenceFingerprint: null,
    resetFootprint: const <String>[],
    consequentialRowCounts: rowCounts,
    issue: issue,
  );
}

AppCzarLocalDataRepairSafetyObservation _unknown(
  _SafetyReadInput input,
  String issue,
) {
  return AppCzarLocalDataRepairSafetyObservation.unknown(
    issue: issue,
    archiveRootPath: input.archiveRootPath,
    archiveInstanceId: input.archiveInstanceId,
    archiveScopeIdentity: input.archiveScopeIdentity,
    archiveGeneration: input.archiveGeneration,
  );
}

final class _SafetyReadInput {
  const _SafetyReadInput({
    required this.archiveRootPath,
    required this.archiveInstanceId,
    required this.messagesDatabasePath,
    required this.contactsDatabasePath,
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
    required this.archiveBindingComplete,
    required this.contactsCondition,
    required this.stabilityObservationInterval,
  });

  final String archiveRootPath;
  final String archiveInstanceId;
  final String messagesDatabasePath;
  final String? contactsDatabasePath;
  final String? archiveScopeIdentity;
  final int? archiveGeneration;
  final bool archiveBindingComplete;
  final AppCzarContactsPrerequisiteCondition contactsCondition;
  final Duration stabilityObservationInterval;
}

final class _GraphInspection {
  const _GraphInspection({required this.consequentialRowCount, this.issue});

  final int consequentialRowCount;
  final String? issue;
}

final class _RowDifferenceCheck {
  const _RowDifferenceCheck({
    required this.localTable,
    required this.sourceTable,
    required this.localColumns,
    required this.sourceColumns,
  });

  final String localTable;
  final String sourceTable;
  final List<String> localColumns;
  final List<String> sourceColumns;
}
