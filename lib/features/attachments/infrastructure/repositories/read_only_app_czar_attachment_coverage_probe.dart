import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/app_czar/domain/app_czar_models.dart';
import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/archive_environment/domain/archive_access_authority.dart';
import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/db/application/read_only_sql_guard.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_sql.dart';
import '../../application/attachment_archive_settings_store.dart';

/// Reconstructs current required attachment coverage without operation history.
///
/// The required universe mirrors automatic live preservation: conventional
/// live graph relationships with nonblank filenames and MIME types. Coverage
/// is proven from durable overlay object records and targeted current-root
/// file metadata. Payload bytes are deliberately not read at startup.
final class ReadOnlyAppCzarAttachmentCoverageProbe {
  const ReadOnlyAppCzarAttachmentCoverageProbe({
    required ArchiveAccessAuthority archiveAccessAuthority,
  }) : _archiveAccessAuthority = archiveAccessAuthority;

  final ArchiveAccessAuthority _archiveAccessAuthority;

  static const int _archiveEvidenceBatchSize = 400;

  Future<AppCzarAttachmentCoverageObservation> readCurrent({
    required String archiveRootPath,
    required String archiveScopeIdentity,
    required int archiveGeneration,
  }) {
    final admittedRootPath = _archiveAccessAuthority.rootPath;
    return Isolate.run(
      () => _readSynchronously(
        admittedRootPath: admittedRootPath,
        archiveRootPath: archiveRootPath,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      ),
    );
  }

  static AppCzarAttachmentCoverageObservation _readSynchronously({
    required String admittedRootPath,
    required String archiveRootPath,
    required String archiveScopeIdentity,
    required int archiveGeneration,
  }) {
    try {
      final first = _readEvidence(admittedRootPath);
      final firstResult = _classifyCoverage(
        evidence: first,
        archiveRootPath: archiveRootPath,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
      final second = _readEvidence(admittedRootPath);
      final secondResult = _classifyCoverage(
        evidence: second,
        archiveRootPath: archiveRootPath,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
      if (first.fingerprint != second.fingerprint ||
          !_sameMaterialResult(firstResult, secondResult)) {
        return AppCzarAttachmentCoverageObservation.unknown(
          issue:
              'Attachment graph, archive metadata, or payload state changed during the bounded coverage read.',
          archiveScopeIdentity: archiveScopeIdentity,
          archiveGeneration: archiveGeneration,
          requiredCount: second.requiredKeys.length,
          coveredCount: secondResult.coveredCount,
          missingCount: secondResult.missingCount,
          unverifiableCount: secondResult.unverifiableCount,
        );
      }
      return secondResult;
    } on _CoverageUnknown catch (error) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue: error.issue,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    } on Object {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue: 'Attachment coverage could not be established.',
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    }
  }

  static _CoverageEvidence _readEvidence(String admittedRootPath) {
    if (!_readArchiveEnabled(admittedRootPath)) {
      return _CoverageEvidence(
        requiredKeys: const <ArchiveCompatibilityKey>[],
        records: <ArchiveCompatibilityKey, _ArchiveRecord>{},
      );
    }

    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: admittedRootPath,
    );
    if (!File(graphPath).existsSync()) {
      throw const _CoverageUnknown(
        'Attachment coverage cannot be established because the conversation graph is absent.',
      );
    }

    final graph = _openReadOnly(graphPath, 'conversation graph');
    late final List<ArchiveCompatibilityKey> requiredKeys;
    try {
      final requiredSql =
          '''
SELECT DISTINCT
  m.guid AS message_guid,
  a.ss_id AS attachment_ss_id
FROM messages m
JOIN message_to_attachment mta ON mta.message_ss_id = m.ss_id
JOIN attachments a ON a.ss_id = mta.attachment_ss_id
WHERE ${SourceScopedRowSql.sourceId('m.ss_id')} = ?
  AND ${SourceScopedRowSql.sourceId('a.ss_id')} = ?
  AND a.filename IS NOT NULL
  AND LENGTH(TRIM(a.filename)) > 0
  AND NULLIF(TRIM(a.mime_type), '') IS NOT NULL
ORDER BY m.guid, a.ss_id;
''';
      assertReadOnlySql(
        requiredSql,
        boundary: 'AppCzar required attachment coverage set',
      );
      final rows = graph.select(requiredSql, <Object?>[
        liveChatDbSourceId,
        liveChatDbSourceId,
      ]);
      final keys = <ArchiveCompatibilityKey>[];
      final seen = <ArchiveCompatibilityKey>{};
      for (final row in rows) {
        final messageGuid = row['message_guid'];
        final attachmentSsId = row['attachment_ss_id'];
        if (messageGuid is! String ||
            messageGuid.trim().isEmpty ||
            attachmentSsId is! int ||
            SourceScopedRowKey.unpackSourceId(attachmentSsId) !=
                liveChatDbSourceId) {
          throw const _CoverageUnknown(
            'The current graph contains incoherent required attachment identity evidence.',
          );
        }
        final key = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
          messageGuid: messageGuid,
          attachmentSsId: attachmentSsId,
        );
        if (seen.add(key)) {
          keys.add(key);
        }
      }
      requiredKeys = List<ArchiveCompatibilityKey>.unmodifiable(keys);
    } finally {
      graph.dispose();
    }

    final overlayPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: admittedRootPath,
    );
    final records = <ArchiveCompatibilityKey, _ArchiveRecord>{};
    if (File(overlayPath).existsSync()) {
      final overlay = _openReadOnly(overlayPath, 'attachment evidence store');
      try {
        if (!_tableExists(overlay, 'archived_attachments')) {
          if (requiredKeys.isNotEmpty) {
            return _CoverageEvidence(
              requiredKeys: requiredKeys,
              records: records,
            );
          }
        } else {
          for (
            var offset = 0;
            offset < requiredKeys.length;
            offset += _archiveEvidenceBatchSize
          ) {
            final end = (offset + _archiveEvidenceBatchSize).clamp(
              0,
              requiredKeys.length,
            );
            final batch = requiredKeys.sublist(offset, end);
            final predicates = <String>[];
            final variables = <Object?>[];
            for (final key in batch) {
              predicates.add('(message_guid = ? AND import_attachment_id = ?)');
              variables
                ..add(key.messageGuid)
                ..add(key.archiveCompatibilityAttachmentId);
            }
            final archiveSql =
                '''
SELECT message_guid, import_attachment_id, archive_relative_path,
       file_size_bytes, content_hash
FROM archived_attachments
WHERE ${predicates.join(' OR ')}
ORDER BY message_guid, import_attachment_id;
''';
            assertReadOnlySql(
              archiveSql,
              boundary: 'AppCzar durable attachment coverage evidence',
            );
            for (final row in overlay.select(archiveSql, variables)) {
              final messageGuid = row['message_guid'];
              final attachmentId = row['import_attachment_id'];
              if (messageGuid is! String || attachmentId is! int) {
                throw const _CoverageUnknown(
                  'Durable attachment archive evidence has an unsupported identity.',
                );
              }
              final key = ArchiveCompatibilityKey.fromStoredTuple(
                messageGuid: messageGuid,
                importAttachmentId: attachmentId,
              );
              final relativePath = row['archive_relative_path'];
              final fileSizeBytes = row['file_size_bytes'];
              final contentHash = row['content_hash'];
              if (relativePath is! String || fileSizeBytes is! int) {
                throw const _CoverageUnknown(
                  'Durable attachment archive evidence has an unsupported shape.',
                );
              }
              final normalizedContentHash = switch (contentHash) {
                null => null,
                final String value => value.trim().toLowerCase(),
                _ => throw const _CoverageUnknown(
                  'Durable attachment archive evidence has an unsupported shape.',
                ),
              };
              if (records.containsKey(key)) {
                throw const _CoverageUnknown(
                  'Durable attachment archive evidence contains duplicate object identity.',
                );
              }
              records[key] = _ArchiveRecord(
                relativePath: relativePath,
                fileSizeBytes: fileSizeBytes,
                contentHash: normalizedContentHash,
              );
            }
          }
        }
      } finally {
        overlay.dispose();
      }
    }

    return _CoverageEvidence(requiredKeys: requiredKeys, records: records);
  }

  static AppCzarAttachmentCoverageObservation _classifyCoverage({
    required _CoverageEvidence evidence,
    required String archiveRootPath,
    required String archiveScopeIdentity,
    required int archiveGeneration,
  }) {
    final requiredCount = evidence.requiredKeys.length;
    if (requiredCount == 0) {
      return AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.complete,
        requiredCount: 0,
        coveredCount: 0,
        missingCount: 0,
        unverifiableCount: 0,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
      );
    }

    final recordsByPath = <String, List<_RequiredRecord>>{};
    var missing = 0;
    var unverifiable = 0;
    for (final key in evidence.requiredKeys) {
      final record = evidence.records[key];
      if (record == null) {
        missing += 1;
        continue;
      }
      if (!_isSafeRelativePath(record.relativePath) ||
          record.fileSizeBytes < 0 ||
          !_isValidOptionalHash(record.contentHash)) {
        unverifiable += 1;
        continue;
      }
      recordsByPath
          .putIfAbsent(record.relativePath, () => <_RequiredRecord>[])
          .add(_RequiredRecord(record));
    }

    var covered = 0;
    for (final entry in recordsByPath.entries) {
      final records = entry.value;
      final sizes = records
          .map((record) => record.record.fileSizeBytes)
          .toSet();
      final hashes = records
          .map((record) => record.record.contentHash)
          .whereType<String>()
          .toSet();
      if (sizes.length != 1 || hashes.length > 1) {
        unverifiable += records.length;
        continue;
      }

      final absolutePath = _boundedPath(
        archiveRootPath: archiveRootPath,
        relativePath: entry.key,
      );
      if (absolutePath == null) {
        unverifiable += records.length;
        continue;
      }
      try {
        if (_crossesSymbolicLink(
          archiveRootPath: archiveRootPath,
          relativePath: entry.key,
        )) {
          missing += records.length;
          continue;
        }
        if (FileSystemEntity.typeSync(absolutePath, followLinks: false) !=
            FileSystemEntityType.file) {
          missing += records.length;
          continue;
        }
        final actualSize = File(absolutePath).lengthSync();
        if (actualSize != sizes.single) {
          missing += records.length;
          continue;
        }
        covered += records.length;
      } on FileSystemException {
        unverifiable += records.length;
      }
    }

    final classified = covered + missing + unverifiable;
    if (classified != requiredCount) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue: 'Attachment coverage counts did not reconcile.',
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
        requiredCount: requiredCount,
        coveredCount: covered,
        missingCount: missing,
        unverifiableCount: unverifiable,
      );
    }
    if (missing > 0) {
      return AppCzarAttachmentCoverageObservation(
        condition: AppCzarAttachmentCoverageCondition.incomplete,
        requiredCount: requiredCount,
        coveredCount: covered,
        missingCount: missing,
        unverifiableCount: unverifiable,
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
        issue: unverifiable > 0
            ? 'Some additional required evidence could not be verified.'
            : null,
      );
    }
    if (unverifiable > 0) {
      return AppCzarAttachmentCoverageObservation.unknown(
        issue:
            '$unverifiable required attachment record(s) could not be verified.',
        archiveScopeIdentity: archiveScopeIdentity,
        archiveGeneration: archiveGeneration,
        requiredCount: requiredCount,
        coveredCount: covered,
        missingCount: 0,
        unverifiableCount: unverifiable,
      );
    }
    return AppCzarAttachmentCoverageObservation(
      condition: AppCzarAttachmentCoverageCondition.complete,
      requiredCount: requiredCount,
      coveredCount: covered,
      missingCount: 0,
      unverifiableCount: 0,
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
    );
  }

  static Database _openReadOnly(String databasePath, String label) {
    try {
      final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');
      return database;
    } on Object {
      throw _CoverageUnknown(
        'Attachment coverage could not open the $label read-only.',
      );
    }
  }

  static bool _sameMaterialResult(
    AppCzarAttachmentCoverageObservation first,
    AppCzarAttachmentCoverageObservation second,
  ) {
    return first.condition == second.condition &&
        first.requiredCount == second.requiredCount &&
        first.coveredCount == second.coveredCount &&
        first.missingCount == second.missingCount &&
        first.unverifiableCount == second.unverifiableCount;
  }

  static bool _tableExists(Database database, String tableName) {
    const sql =
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ? LIMIT 1";
    assertReadOnlySql(sql, boundary: 'AppCzar attachment table inspection');
    return database.select(sql, <Object?>[tableName]).isNotEmpty;
  }

  static bool _readArchiveEnabled(String admittedRootPath) {
    final overlayPath = appDatabasePath(
      AppDatabaseFile.overlay,
      databaseDirectory: admittedRootPath,
    );
    if (!File(overlayPath).existsSync()) {
      return true;
    }
    final overlay = _openReadOnly(overlayPath, 'attachment settings store');
    try {
      if (!_tableExists(overlay, 'overlay_settings')) {
        return true;
      }
      const sql = 'SELECT value FROM overlay_settings WHERE key = ? LIMIT 1';
      assertReadOnlySql(
        sql,
        boundary: 'AppCzar attachment preservation policy read',
      );
      final rows = overlay.select(sql, <Object?>[
        attachmentArchiveEnabledSettingKey,
      ]);
      if (rows.isEmpty) {
        return true;
      }
      final value = rows.single['value'];
      if (value is! String) {
        throw const _CoverageUnknown(
          'The attachment preservation preference has an unsupported shape.',
        );
      }
      return value != 'false';
    } finally {
      overlay.dispose();
    }
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

  static bool _isValidOptionalHash(String? contentHash) {
    return contentHash == null ||
        RegExp(r'^[0-9a-f]{64}$').hasMatch(contentHash);
  }

  static String? _boundedPath({
    required String archiveRootPath,
    required String relativePath,
  }) {
    if (!_isSafeRelativePath(relativePath)) {
      return null;
    }
    final normalizedRoot = path.normalize(path.absolute(archiveRootPath));
    final candidate = path.normalize(path.join(normalizedRoot, relativePath));
    return path.isWithin(normalizedRoot, candidate) ? candidate : null;
  }

  static bool _crossesSymbolicLink({
    required String archiveRootPath,
    required String relativePath,
  }) {
    final normalizedRoot = path.normalize(path.absolute(archiveRootPath));
    if (FileSystemEntity.typeSync(normalizedRoot, followLinks: false) ==
        FileSystemEntityType.link) {
      return true;
    }
    var cursor = normalizedRoot;
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

final class _CoverageEvidence {
  _CoverageEvidence({required this.requiredKeys, required this.records});

  final List<ArchiveCompatibilityKey> requiredKeys;
  final Map<ArchiveCompatibilityKey, _ArchiveRecord> records;

  String get fingerprint {
    final buffer = StringBuffer();
    for (final key in requiredKeys) {
      buffer
        ..write('R\u0000')
        ..write(key.messageGuid)
        ..write('\u0000')
        ..write(key.archiveCompatibilityAttachmentId)
        ..write('\n');
    }
    final orderedRecords = records.entries.toList(growable: false)
      ..sort((left, right) {
        final byGuid = left.key.messageGuid.compareTo(right.key.messageGuid);
        return byGuid != 0
            ? byGuid
            : left.key.archiveCompatibilityAttachmentId.compareTo(
                right.key.archiveCompatibilityAttachmentId,
              );
      });
    for (final entry in orderedRecords) {
      final record = entry.value;
      buffer
        ..write('A\u0000')
        ..write(entry.key.messageGuid)
        ..write('\u0000')
        ..write(entry.key.archiveCompatibilityAttachmentId)
        ..write('\u0000')
        ..write(record.relativePath)
        ..write('\u0000')
        ..write(record.fileSizeBytes)
        ..write('\u0000')
        ..write(record.contentHash ?? '')
        ..write('\n');
    }
    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}

final class _ArchiveRecord {
  const _ArchiveRecord({
    required this.relativePath,
    required this.fileSizeBytes,
    required this.contentHash,
  });

  final String relativePath;
  final int fileSizeBytes;
  final String? contentHash;
}

final class _RequiredRecord {
  const _RequiredRecord(this.record);

  final _ArchiveRecord record;
}

final class _CoverageUnknown implements Exception {
  const _CoverageUnknown(this.issue);

  final String issue;
}
