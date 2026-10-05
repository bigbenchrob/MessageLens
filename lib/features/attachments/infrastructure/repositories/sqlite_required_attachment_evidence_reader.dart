import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/db/application/read_only_sql_guard.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_sql.dart';
import '../../application/attachment_archive_settings_store.dart';
import '../../application/required_attachment_evidence_reader.dart';

/// Reads the one current, conventional live-attachment coverage universe.
///
/// Both item pages and aggregate startup coverage pass through the same SQL,
/// decoders, durable-record checks, and filesystem classifier in this class.
/// The graph and overlay are opened read-only. The overlay is attached to the
/// graph connection with SQLite's `mode=ro` URI so same-path conflicts can be
/// restricted to records whose keys are in the required graph universe.
final class SqliteRequiredAttachmentEvidenceReader
    implements RequiredAttachmentEvidenceReader {
  const SqliteRequiredAttachmentEvidenceReader({
    required String admittedRootPath,
  }) : _admittedRootPath = admittedRootPath;

  final String _admittedRootPath;

  @override
  Future<RequiredAttachmentEvidencePage> readPage({
    required RequiredAttachmentEvidenceBinding binding,
    RequiredAttachmentEvidenceCursor? after,
    int limit = 75,
  }) {
    _validateLimit(limit);
    final admittedRootPath = _admittedRootPath;
    final normalizedBinding = _normalizeBinding(binding);
    return Isolate.run(
      () => _withReadSession(
        admittedRootPath: admittedRootPath,
        operation: (session) => session.readPage(
          binding: normalizedBinding,
          after: after,
          limit: limit,
        ),
      ),
    );
  }

  @override
  Future<RequiredAttachmentEvidenceSummary> readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    int pageSize = 75,
  }) {
    _validateLimit(pageSize);
    final admittedRootPath = _admittedRootPath;
    final normalizedBinding = _normalizeBinding(binding);
    return Isolate.run(
      () => _withReadSession(
        admittedRootPath: admittedRootPath,
        operation: (session) =>
            session.readSummary(binding: normalizedBinding, pageSize: pageSize),
      ),
    );
  }

  static T _withReadSession<T>({
    required String admittedRootPath,
    required T Function(_RequiredAttachmentReadSession session) operation,
  }) {
    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: admittedRootPath,
    );
    if (!File(graphPath).existsSync()) {
      throw const RequiredAttachmentEvidenceReadException(
        'Attachment coverage cannot be established because the conversation graph is absent.',
      );
    }

    Database graph;
    try {
      graph = sqlite3.open(graphPath, mode: OpenMode.readOnly);
    } on Object {
      throw const RequiredAttachmentEvidenceReadException(
        'Attachment coverage could not open the conversation graph read-only.',
      );
    }

    try {
      graph.execute('PRAGMA busy_timeout = 3000;');
      final overlayPath = appDatabasePath(
        AppDatabaseFile.overlay,
        databaseDirectory: admittedRootPath,
      );
      var overlayAttached = false;
      if (File(overlayPath).existsSync()) {
        try {
          final overlayUri = Uri.file(
            overlayPath,
          ).replace(queryParameters: const <String, String>{'mode': 'ro'});
          graph.execute('ATTACH DATABASE ? AS attachment_overlay;', <Object?>[
            overlayUri.toString(),
          ]);
          overlayAttached = true;
        } on Object {
          throw const RequiredAttachmentEvidenceReadException(
            'Attachment coverage could not open the attachment evidence store read-only.',
          );
        }
      }
      graph.execute('PRAGMA query_only = ON;');
      graph.execute('BEGIN DEFERRED TRANSACTION;');
      try {
        return operation(
          _RequiredAttachmentReadSession(
            database: graph,
            overlayAttached: overlayAttached,
          ),
        );
      } finally {
        graph.execute('ROLLBACK;');
      }
    } on RequiredAttachmentEvidenceReadException {
      rethrow;
    } on Object {
      throw const RequiredAttachmentEvidenceReadException(
        'Attachment coverage evidence could not be read.',
      );
    } finally {
      graph.dispose();
    }
  }

  static RequiredAttachmentEvidenceBinding _normalizeBinding(
    RequiredAttachmentEvidenceBinding binding,
  ) {
    if (binding.archiveRootPath.trim().isEmpty ||
        binding.archiveScopeIdentity.trim().isEmpty ||
        binding.archiveGeneration < 0) {
      throw const RequiredAttachmentEvidenceReadException(
        'Attachment coverage requires a coherent archive binding.',
      );
    }
    return RequiredAttachmentEvidenceBinding(
      archiveRootPath: path.normalize(path.absolute(binding.archiveRootPath)),
      archiveScopeIdentity: binding.archiveScopeIdentity,
      archiveGeneration: binding.archiveGeneration,
    );
  }

  static void _validateLimit(int limit) {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Required attachment evidence page size must be between 1 and 100.',
      );
    }
  }
}

final class _RequiredAttachmentReadSession {
  const _RequiredAttachmentReadSession({
    required Database database,
    required bool overlayAttached,
  }) : _database = database,
       _overlayAttached = overlayAttached;

  final Database _database;
  final bool _overlayAttached;

  static final String _requiredKeysSelect =
      '''
SELECT DISTINCT
  m.guid AS message_guid,
  ${SourceScopedRowSql.sourceRowId('a.ss_id')} AS live_attachment_rowid
FROM messages m
JOIN message_to_attachment mta ON mta.message_ss_id = m.ss_id
JOIN attachments a ON a.ss_id = mta.attachment_ss_id
WHERE ${SourceScopedRowSql.sourceId('m.ss_id')} = $liveChatDbSourceId
  AND ${SourceScopedRowSql.sourceId('a.ss_id')} = $liveChatDbSourceId
  AND NULLIF(TRIM(m.guid), '') IS NOT NULL
  AND NULLIF(TRIM(a.filename), '') IS NOT NULL
  AND NULLIF(TRIM(a.mime_type), '') IS NOT NULL
''';

  RequiredAttachmentEvidencePage readPage({
    required RequiredAttachmentEvidenceBinding binding,
    required RequiredAttachmentEvidenceCursor? after,
    required int limit,
  }) {
    if (!_readArchiveEnabled()) {
      return RequiredAttachmentEvidencePage(
        items: const <RequiredAttachmentEvidenceItem>[],
        nextCursor: null,
        hasMore: false,
        binding: binding,
      );
    }

    final requiredRows = _readRequiredRows(after: after, limit: limit + 1);
    final hasMore = requiredRows.length > limit;
    final selectedRows = hasMore
        ? requiredRows.take(limit).toList(growable: false)
        : requiredRows;
    if (selectedRows.isEmpty) {
      return RequiredAttachmentEvidencePage(
        items: const <RequiredAttachmentEvidenceItem>[],
        nextCursor: null,
        hasMore: false,
        binding: binding,
      );
    }

    final requiredItems = selectedRows
        .map(_decodeRequiredIdentity)
        .toList(growable: false);
    final records = _readRecordsFor(
      requiredItems.map((item) => item.archiveKey).whereType(),
    );
    final paths = records.values
        .where((matches) => matches.length == 1)
        .map((matches) => matches.single.relativePath)
        .whereType<String>()
        .toSet();
    final conflictingPaths = _readConflictingRequiredPaths(paths);

    final items = requiredItems
        .map(
          (required) => _classify(
            required: required,
            matchingRecords: required.archiveKey == null
                ? const <_ArchiveRecordEvidence>[]
                : records[required.archiveKey] ??
                      const <_ArchiveRecordEvidence>[],
            conflictingPaths: conflictingPaths,
            archiveRootPath: binding.archiveRootPath,
          ),
        )
        .toList(growable: false);
    return RequiredAttachmentEvidencePage(
      items: items,
      nextCursor: requiredItems.last.cursor,
      hasMore: hasMore,
      binding: binding,
    );
  }

  RequiredAttachmentEvidenceSummary readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    required int pageSize,
  }) {
    var required = 0;
    var covered = 0;
    var missing = 0;
    var unverifiable = 0;
    var fingerprint = sha256
        .convert(
          utf8.encode(
            'required-attachment-evidence-v1\u0000'
            '${binding.archiveScopeIdentity}\u0000'
            '${binding.archiveGeneration}\u0000'
            '${binding.archiveRootPath}',
          ),
        )
        .toString();
    RequiredAttachmentEvidenceCursor? cursor;
    while (true) {
      final page = readPage(binding: binding, after: cursor, limit: pageSize);
      for (final item in page.items) {
        required += 1;
        if (item.isCovered) {
          covered += 1;
        } else if (item.isMissing) {
          missing += 1;
        } else {
          unverifiable += 1;
        }
        fingerprint = sha256
            .convert(
              utf8.encode('$fingerprint\u0000${item.materialFingerprint}'),
            )
            .toString();
      }
      if (!page.hasMore) {
        break;
      }
      final nextCursor = page.nextCursor;
      if (nextCursor == null || nextCursor == cursor) {
        throw const RequiredAttachmentEvidenceReadException(
          'Required attachment evidence pagination did not advance.',
        );
      }
      cursor = nextCursor;
    }

    return RequiredAttachmentEvidenceSummary(
      requiredCount: required,
      coveredCount: covered,
      missingCount: missing,
      unverifiableCount: unverifiable,
      materialFingerprint: fingerprint,
      binding: binding,
    );
  }

  List<Row> _readRequiredRows({
    required RequiredAttachmentEvidenceCursor? after,
    required int limit,
  }) {
    final cursorClause = after == null
        ? ''
        : '''
  AND (
    m.guid > ?
    OR (
      m.guid = ?
      AND ${SourceScopedRowSql.sourceRowId('a.ss_id')} > ?
    )
  )
''';
    final sql =
        '''
$_requiredKeysSelect
$cursorClause
ORDER BY m.guid, live_attachment_rowid
LIMIT ?;
''';
    assertReadOnlySql(
      sql,
      boundary: 'Required attachment evidence keyset page',
    );
    final variables = <Object?>[
      if (after != null) ...<Object?>[
        after.messageGuid,
        after.messageGuid,
        after.liveAttachmentRowId,
      ],
      limit,
    ];
    return _database.select(sql, variables).toList(growable: false);
  }

  _RequiredIdentityEvidence _decodeRequiredIdentity(Row row) {
    final messageGuid = row['message_guid'];
    final liveAttachmentRowId = row['live_attachment_rowid'];
    if (messageGuid is! String ||
        messageGuid.trim().isEmpty ||
        liveAttachmentRowId is! int) {
      throw const RequiredAttachmentEvidenceReadException(
        'The current graph contains unsupported required attachment identity evidence.',
      );
    }
    final cursor = RequiredAttachmentEvidenceCursor(
      messageGuid: messageGuid,
      liveAttachmentRowId: liveAttachmentRowId,
    );
    if (liveAttachmentRowId < 1 ||
        liveAttachmentRowId > SourceScopedRowKey.maxSourceRowId) {
      return _RequiredIdentityEvidence(cursor: cursor, archiveKey: null);
    }
    return _RequiredIdentityEvidence(
      cursor: cursor,
      archiveKey: ArchiveCompatibilityKey.fromStoredTuple(
        messageGuid: messageGuid,
        importAttachmentId: liveAttachmentRowId,
      ),
    );
  }

  Map<ArchiveCompatibilityKey, List<_ArchiveRecordEvidence>> _readRecordsFor(
    Iterable<ArchiveCompatibilityKey> keys,
  ) {
    final selectedKeys = keys.toList(growable: false);
    if (!_overlayAttached ||
        selectedKeys.isEmpty ||
        !_tableExists('attachment_overlay', 'archived_attachments')) {
      return <ArchiveCompatibilityKey, List<_ArchiveRecordEvidence>>{};
    }
    final predicates = <String>[];
    final variables = <Object?>[];
    for (final key in selectedKeys) {
      predicates.add('(message_guid = ? AND import_attachment_id = ?)');
      variables
        ..add(key.messageGuid)
        ..add(key.archiveCompatibilityAttachmentId);
    }
    final sql =
        '''
SELECT message_guid, import_attachment_id, archive_relative_path,
       file_size_bytes, content_hash
FROM attachment_overlay.archived_attachments
WHERE ${predicates.join(' OR ')}
ORDER BY message_guid, import_attachment_id;
''';
    assertReadOnlySql(sql, boundary: 'Required attachment durable evidence');
    final records = <ArchiveCompatibilityKey, List<_ArchiveRecordEvidence>>{};
    for (final row in _database.select(sql, variables)) {
      final messageGuid = row['message_guid'];
      final attachmentId = row['import_attachment_id'];
      if (messageGuid is! String || attachmentId is! int) {
        throw const RequiredAttachmentEvidenceReadException(
          'Durable attachment evidence contains unsupported identity evidence.',
        );
      }
      final key = ArchiveCompatibilityKey.fromStoredTuple(
        messageGuid: messageGuid,
        importAttachmentId: attachmentId,
      );
      records
          .putIfAbsent(key, () => <_ArchiveRecordEvidence>[])
          .add(
            _ArchiveRecordEvidence(
              relativePath: row['archive_relative_path'],
              fileSizeBytes: row['file_size_bytes'],
              contentHash: switch (row['content_hash']) {
                final String value => value.trim().toLowerCase(),
                final value => value,
              },
            ),
          );
    }
    return records;
  }

  Set<String> _readConflictingRequiredPaths(Set<String> paths) {
    if (!_overlayAttached || paths.isEmpty) {
      return const <String>{};
    }
    final pathValues = paths.toList(growable: false)..sort();
    final values = List<String>.filled(pathValues.length, '(?)').join(', ');
    final sql =
        '''
WITH required_keys AS (
  $_requiredKeysSelect
),
page_paths(archive_relative_path) AS (
  VALUES $values
),
required_records AS (
  SELECT aa.archive_relative_path, aa.file_size_bytes,
         LOWER(TRIM(aa.content_hash)) AS normalized_content_hash
  FROM attachment_overlay.archived_attachments aa
  JOIN page_paths pp
    ON pp.archive_relative_path = aa.archive_relative_path
  JOIN required_keys rk
    ON rk.message_guid = aa.message_guid
   AND rk.live_attachment_rowid = aa.import_attachment_id
)
SELECT archive_relative_path
FROM required_records
GROUP BY archive_relative_path
HAVING COUNT(DISTINCT file_size_bytes) != 1
    OR COUNT(DISTINCT normalized_content_hash) > 1
ORDER BY archive_relative_path;
''';
    assertReadOnlySql(
      sql,
      boundary: 'Required attachment shared-path conflict evidence',
    );
    return _database
        .select(sql, pathValues)
        .map((row) => row['archive_relative_path'])
        .whereType<String>()
        .toSet();
  }

  RequiredAttachmentEvidenceItem _classify({
    required _RequiredIdentityEvidence required,
    required List<_ArchiveRecordEvidence> matchingRecords,
    required Set<String> conflictingPaths,
    required String archiveRootPath,
  }) {
    final key = required.archiveKey;
    if (key == null) {
      return _item(
        required: required,
        condition:
            RequiredAttachmentEvidenceCondition.ambiguousRequiredIdentity,
        material: 'ambiguous-identity',
      );
    }
    if (matchingRecords.isEmpty) {
      return _item(
        required: required,
        condition: RequiredAttachmentEvidenceCondition.noDurableRecord,
        material: 'no-record',
      );
    }
    if (matchingRecords.length != 1) {
      return _item(
        required: required,
        condition:
            RequiredAttachmentEvidenceCondition.ambiguousRequiredIdentity,
        material: 'duplicate-records:${matchingRecords.length}',
      );
    }

    final record = matchingRecords.single;
    final relativePath = record.relativePath;
    final fileSizeBytes = record.fileSizeBytes;
    final contentHash = record.contentHash;
    final material = <Object?>[
      relativePath,
      fileSizeBytes,
      contentHash,
    ].join('\u0000');
    if (relativePath is! String ||
        fileSizeBytes is! int ||
        fileSizeBytes < 0 ||
        !_isValidOptionalHash(contentHash) ||
        !_isSafeRelativePath(relativePath)) {
      return _item(
        required: required,
        condition: RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
        material: 'unsupported-record\u0000$material',
      );
    }
    if (conflictingPaths.contains(relativePath)) {
      return _item(
        required: required,
        condition:
            RequiredAttachmentEvidenceCondition.conflictingDurableEvidence,
        material: 'conflict\u0000$material',
      );
    }

    final absolutePath = _boundedPath(
      archiveRootPath: archiveRootPath,
      relativePath: relativePath,
    );
    if (absolutePath == null) {
      return _item(
        required: required,
        condition: RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
        material: 'unbounded\u0000$material',
      );
    }
    try {
      if (_crossesSymbolicLink(
        archiveRootPath: archiveRootPath,
        relativePath: relativePath,
      )) {
        return _item(
          required: required,
          condition:
              RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
          material: 'symbolic-link\u0000$material',
        );
      }
      if (FileSystemEntity.typeSync(absolutePath, followLinks: false) !=
          FileSystemEntityType.file) {
        return _item(
          required: required,
          condition: RequiredAttachmentEvidenceCondition.recordPayloadAbsent,
          material: 'absent\u0000$material',
        );
      }
      final actualSize = File(absolutePath).lengthSync();
      if (actualSize != fileSizeBytes) {
        return _item(
          required: required,
          condition: RequiredAttachmentEvidenceCondition.recordWrongSize,
          material: 'wrong-size\u0000$actualSize\u0000$material',
        );
      }
      return _item(
        required: required,
        condition: RequiredAttachmentEvidenceCondition.coveredAndValid,
        material: 'covered\u0000$actualSize\u0000$material',
      );
    } on FileSystemException {
      return _item(
        required: required,
        condition: RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
        material: 'filesystem-unverifiable\u0000$material',
      );
    }
  }

  RequiredAttachmentEvidenceItem _item({
    required _RequiredIdentityEvidence required,
    required RequiredAttachmentEvidenceCondition condition,
    required String material,
  }) {
    final cursor = required.cursor;
    final digest = sha256
        .convert(
          utf8.encode(
            '${cursor.messageGuid}\u0000${cursor.liveAttachmentRowId}\u0000'
            '${condition.name}\u0000$material',
          ),
        )
        .toString();
    return RequiredAttachmentEvidenceItem(
      cursor: cursor,
      archiveKey: required.archiveKey,
      condition: condition,
      materialFingerprint: digest,
    );
  }

  bool _readArchiveEnabled() {
    if (!_overlayAttached ||
        !_tableExists('attachment_overlay', 'overlay_settings')) {
      return true;
    }
    const sql =
        'SELECT value FROM attachment_overlay.overlay_settings '
        'WHERE key = ? LIMIT 1';
    assertReadOnlySql(
      sql,
      boundary: 'Required attachment preservation policy read',
    );
    final rows = _database.select(sql, <Object?>[
      attachmentArchiveEnabledSettingKey,
    ]);
    if (rows.isEmpty) {
      return true;
    }
    final value = rows.single['value'];
    if (value is! String) {
      throw const RequiredAttachmentEvidenceReadException(
        'The attachment preservation preference has an unsupported shape.',
      );
    }
    return value != 'false';
  }

  bool _tableExists(String schema, String tableName) {
    final sql =
        'SELECT 1 FROM $schema.sqlite_master '
        "WHERE type = 'table' AND name = ? LIMIT 1";
    assertReadOnlySql(sql, boundary: 'Required attachment table inspection');
    return _database.select(sql, <Object?>[tableName]).isNotEmpty;
  }

  static bool _isSafeRelativePath(String relativePath) {
    if (relativePath.isEmpty || path.isAbsolute(relativePath)) {
      return false;
    }
    final normalized = path.normalize(relativePath);
    return normalized == relativePath &&
        normalized != '.' &&
        normalized != '..' &&
        !normalized.startsWith('../');
  }

  static bool _isValidOptionalHash(Object? contentHash) {
    return contentHash == null ||
        contentHash is String &&
            RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(contentHash);
  }

  static String? _boundedPath({
    required String archiveRootPath,
    required String relativePath,
  }) {
    if (!_isSafeRelativePath(relativePath)) {
      return null;
    }
    final candidate = path.normalize(path.join(archiveRootPath, relativePath));
    return path.isWithin(archiveRootPath, candidate) ? candidate : null;
  }

  static bool _crossesSymbolicLink({
    required String archiveRootPath,
    required String relativePath,
  }) {
    if (FileSystemEntity.typeSync(archiveRootPath, followLinks: false) ==
        FileSystemEntityType.link) {
      return true;
    }
    var cursor = archiveRootPath;
    for (final component in path.split(relativePath)) {
      cursor = path.join(cursor, component);
      if (FileSystemEntity.typeSync(cursor, followLinks: false) ==
          FileSystemEntityType.link) {
        return true;
      }
    }
    return false;
  }
}

final class _RequiredIdentityEvidence {
  const _RequiredIdentityEvidence({
    required this.cursor,
    required this.archiveKey,
  });

  final RequiredAttachmentEvidenceCursor cursor;
  final ArchiveCompatibilityKey? archiveKey;
}

final class _ArchiveRecordEvidence {
  const _ArchiveRecordEvidence({
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
  });

  final Object? relativePath;
  final Object? fileSizeBytes;
  final Object? contentHash;
}
