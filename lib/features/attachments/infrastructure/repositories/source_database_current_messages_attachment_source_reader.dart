import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/source_scoped_import/domain/ports/source_database_port.dart';
import '../../application/attachment_archive_file_store.dart';
import '../../application/current_messages_attachment_source_reader.dart';

typedef _EntityTypeReader =
    Future<FileSystemEntityType> Function(String path, {bool followLinks});
typedef _FileStatReader = Future<FileStat> Function(String path);
typedef _ReadabilityVerifier = Future<void> Function(String path);

/// Reads exact live attachments from the current Messages source.
///
/// Both halves of [ArchiveCompatibilityKey] are proved in `chat.db`. The
/// imported graph's retained filename is intentionally not consulted.
final class SourceDatabaseCurrentMessagesAttachmentSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  SourceDatabaseCurrentMessagesAttachmentSourceReader({
    required String databasePath,
    required SourceDatabaseOpener sourceDatabaseOpener,
    String? homeDirectory,
    Future<FileSystemEntityType> Function(String path, {bool followLinks})?
    entityTypeReader,
    Future<FileStat> Function(String path)? fileStatReader,
    Future<void> Function(String path)? readabilityVerifier,
  }) : _databasePath = databasePath,
       _sourceDatabaseOpener = sourceDatabaseOpener,
       _homeDirectory = homeDirectory ?? Platform.environment['HOME'],
       _entityTypeReader = entityTypeReader ?? FileSystemEntity.type,
       _fileStatReader = fileStatReader ?? FileStat.stat,
       _readabilityVerifier = readabilityVerifier ?? _verifyReadable;

  final String _databasePath;
  final SourceDatabaseOpener _sourceDatabaseOpener;
  final String? _homeDirectory;
  final _EntityTypeReader _entityTypeReader;
  final _FileStatReader _fileStatReader;
  final _ReadabilityVerifier _readabilityVerifier;

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return (await observeCurrentPage(<ArchiveCompatibilityKey>[
      archiveKey,
    ])).single;
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    if (archiveKeys.length >
        currentMessagesAttachmentSourceObservationPageLimit) {
      throw ArgumentError.value(
        archiveKeys.length,
        'archiveKeys',
        'must not exceed '
            '$currentMessagesAttachmentSourceObservationPageLimit keys',
      );
    }
    if (archiveKeys.isEmpty) {
      return const <CurrentMessagesAttachmentSourceObservation>[];
    }
    if (!File(_databasePath).existsSync()) {
      return _globalObservations(
        archiveKeys,
        condition: CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
        issue: 'The current Messages database is unavailable.',
      );
    }

    final rowsResult = await _readSourceRows(archiveKeys);
    if (rowsResult case _SourceRowsUnavailable(:final issue)) {
      return _globalObservations(
        archiveKeys,
        condition: CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
        issue: issue,
      );
    }
    if (rowsResult case _SourceRowsUnknown(:final issue)) {
      return _globalObservations(
        archiveKeys,
        condition: CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
        issue: issue,
      );
    }

    final rowsByIndex = <int, List<Map<String, Object?>>>{};
    for (final row in (rowsResult as _SourceRowsAvailable).rows) {
      final requestIndex = row['request_index'];
      if (requestIndex is! int ||
          requestIndex < 0 ||
          requestIndex >= archiveKeys.length) {
        return _globalObservations(
          archiveKeys,
          condition:
              CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
          issue: 'The current source returned incoherent request identity.',
        );
      }
      rowsByIndex.putIfAbsent(requestIndex, () => []).add(row);
    }

    final observations = <CurrentMessagesAttachmentSourceObservation>[];
    for (var index = 0; index < archiveKeys.length; index++) {
      final archiveKey = archiveKeys[index];
      final rows = rowsByIndex[index];
      if (rows == null || rows.length != 1) {
        observations.add(
          CurrentMessagesAttachmentSourceObservation.sourceInconclusive(
            archiveKey: archiveKey,
            issue: 'The current source returned non-unique key evidence.',
          ),
        );
        continue;
      }
      observations.add(await _observePayload(archiveKey, rows.single));
    }
    return observations;
  }

  Future<CurrentMessagesAttachmentSourceObservation> _observePayload(
    ArchiveCompatibilityKey archiveKey,
    Map<String, Object?> row,
  ) async {
    final sourceRowId = row['source_attachment_rowid'];
    if (sourceRowId == null) {
      return CurrentMessagesAttachmentSourceObservation.absent(
        archiveKey: archiveKey,
        issue: 'No current attachment matches the exact message and row key.',
      );
    }
    if (sourceRowId is! int ||
        sourceRowId != archiveKey.liveSourceAttachmentRowId) {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue: 'The current source returned incoherent attachment identity.',
      );
    }

    final rawPath = _trimmedString(row['filename']);
    if (rawPath == null) {
      return CurrentMessagesAttachmentSourceObservation.absent(
        archiveKey: archiveKey,
        issue: 'The current attachment has no payload path.',
      );
    }
    final mimeType = _trimmedString(row['mime_type']);
    if (mimeType == null) {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue: 'The current attachment has no MIME type.',
      );
    }
    final sourcePath = _expandHomePath(rawPath);
    if (sourcePath == null) {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue: 'The current attachment path could not be resolved.',
      );
    }

    final FileSystemEntityType entityType;
    try {
      entityType = await _entityTypeReader(sourcePath, followLinks: false);
    } on FileSystemException catch (error) {
      return _fileAccessFailure(archiveKey, error);
    } on Object catch (error) {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue: 'The current payload type could not be inspected: $error',
      );
    }
    if (entityType == FileSystemEntityType.notFound) {
      return CurrentMessagesAttachmentSourceObservation.absent(
        archiveKey: archiveKey,
        issue: 'The current attachment payload is absent.',
      );
    }
    if (entityType != FileSystemEntityType.file) {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue: 'The current attachment payload is not a regular file.',
      );
    }

    try {
      normalizeAttachmentArchiveSourceExtension(path.extension(sourcePath));
    } on ArgumentError {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue:
            'The current payload filename cannot be represented safely in '
            'the attachment archive.',
      );
    }

    try {
      await _readabilityVerifier(sourcePath);
      final stat = await _fileStatReader(sourcePath);
      if (stat.type == FileSystemEntityType.notFound) {
        return CurrentMessagesAttachmentSourceObservation.absent(
          archiveKey: archiveKey,
          issue: 'The current attachment payload is absent.',
        );
      }
      if (stat.type != FileSystemEntityType.file || stat.size < 0) {
        return CurrentMessagesAttachmentSourceObservation.unknown(
          archiveKey: archiveKey,
          issue: 'The current payload metadata is incoherent.',
        );
      }
      return CurrentMessagesAttachmentSourceObservation.available(
        archiveKey: archiveKey,
        sourcePath: sourcePath,
        mimeType: mimeType,
        fileSizeBytes: stat.size,
        modifiedAtMicrosecondsSinceEpoch: stat.modified.microsecondsSinceEpoch,
      );
    } on FileSystemException catch (error) {
      return _fileAccessFailure(archiveKey, error);
    } on Object catch (error) {
      return CurrentMessagesAttachmentSourceObservation.unknown(
        archiveKey: archiveKey,
        issue: 'The current payload could not be inspected: $error',
      );
    }
  }

  Future<_SourceRowsResult> _readSourceRows(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    final values = List<String>.filled(
      archiveKeys.length,
      '(?, ?, ?)',
    ).join(', ');
    final arguments = <Object?>[];
    for (var index = 0; index < archiveKeys.length; index++) {
      final archiveKey = archiveKeys[index];
      arguments.addAll(<Object?>[
        index,
        archiveKey.liveSourceAttachmentRowId,
        archiveKey.messageGuid,
      ]);
    }
    final query =
        '''
WITH requested(
  request_index,
  requested_attachment_rowid,
  requested_message_guid
) AS (
  VALUES $values
)
SELECT
  requested.request_index AS request_index,
  attachment.ROWID AS source_attachment_rowid,
  attachment.filename AS filename,
  attachment.mime_type AS mime_type
FROM requested
LEFT JOIN attachment
  ON attachment.ROWID = requested.requested_attachment_rowid
 AND EXISTS (
   SELECT 1
   FROM message_attachment_join AS message_attachment
   JOIN message
     ON message.ROWID = message_attachment.message_id
   WHERE message_attachment.attachment_id = attachment.ROWID
     AND message.guid = requested.requested_message_guid
 )
ORDER BY requested.request_index;
''';

    try {
      final database = await _sourceDatabaseOpener.openReadOnly(_databasePath);
      try {
        return _SourceRowsAvailable(await database.rawQuery(query, arguments));
      } finally {
        await database.close();
      }
    } on FileSystemException catch (error) {
      if (_isAccessDenied(error) || error.osError?.errorCode == 2) {
        return _SourceRowsUnavailable(
          'The current Messages database could not be read: $error',
        );
      }
      return _SourceRowsUnknown(
        'The current Messages database read was inconclusive: $error',
      );
    } on DatabaseException catch (error) {
      if (_isDatabaseAccessUnavailable(error)) {
        return _SourceRowsUnavailable(
          'The current Messages database could not be read: $error',
        );
      }
      return _SourceRowsUnknown(
        'The current Messages attachment lookup was inconclusive: $error',
      );
    } on Object catch (error) {
      return _SourceRowsUnknown(
        'The current Messages attachment lookup was inconclusive: $error',
      );
    }
  }

  String? _expandHomePath(String rawPath) {
    if (!rawPath.startsWith('~/')) {
      return rawPath;
    }
    final homeDirectory = _homeDirectory?.trim();
    if (homeDirectory == null || homeDirectory.isEmpty) {
      return null;
    }
    return '$homeDirectory/${rawPath.substring(2)}';
  }

  CurrentMessagesAttachmentSourceObservation _fileAccessFailure(
    ArchiveCompatibilityKey archiveKey,
    FileSystemException error,
  ) {
    if (error.osError?.errorCode == 2) {
      return CurrentMessagesAttachmentSourceObservation.absent(
        archiveKey: archiveKey,
        issue: 'The current attachment payload is absent.',
      );
    }
    if (_isAccessDenied(error)) {
      return CurrentMessagesAttachmentSourceObservation.unreadable(
        archiveKey: archiveKey,
        issue: 'The current attachment payload cannot be read.',
      );
    }
    return CurrentMessagesAttachmentSourceObservation.unknown(
      archiveKey: archiveKey,
      issue: 'The current attachment payload could not be inspected: $error',
    );
  }

  static List<CurrentMessagesAttachmentSourceObservation> _globalObservations(
    List<ArchiveCompatibilityKey> archiveKeys, {
    required CurrentMessagesAttachmentSourceCondition condition,
    required String issue,
  }) {
    return <CurrentMessagesAttachmentSourceObservation>[
      for (final archiveKey in archiveKeys)
        switch (condition) {
          CurrentMessagesAttachmentSourceCondition.sourceUnavailable =>
            CurrentMessagesAttachmentSourceObservation.sourceUnavailable(
              archiveKey: archiveKey,
              issue: issue,
            ),
          CurrentMessagesAttachmentSourceCondition.sourceInconclusive =>
            CurrentMessagesAttachmentSourceObservation.sourceInconclusive(
              archiveKey: archiveKey,
              issue: issue,
            ),
          _ => throw StateError(
            'Global source observation must be unavailable or inconclusive.',
          ),
        },
    ];
  }

  static String? _trimmedString(Object? value) {
    if (value == null) {
      return null;
    }
    final normalized = '$value'.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static bool _isAccessDenied(FileSystemException error) {
    final code = error.osError?.errorCode;
    return code == 1 || code == 13;
  }

  static bool _isDatabaseAccessUnavailable(DatabaseException error) {
    final resultCode = error.getResultCode();
    final primaryResultCode = resultCode == null ? null : resultCode & 0xff;
    if (primaryResultCode == 3 ||
        primaryResultCode == 14 ||
        primaryResultCode == 23) {
      return true;
    }
    final message = error.toString().toLowerCase();
    return message.contains('permission denied') ||
        message.contains('operation not permitted') ||
        message.contains('not authorized') ||
        message.contains('authorization denied') ||
        message.contains('access denied');
  }

  static Future<void> _verifyReadable(String path) async {
    final file = await File(path).open(mode: FileMode.read);
    await file.close();
  }
}

sealed class _SourceRowsResult {
  const _SourceRowsResult();
}

final class _SourceRowsAvailable extends _SourceRowsResult {
  const _SourceRowsAvailable(this.rows);

  final List<Map<String, Object?>> rows;
}

final class _SourceRowsUnavailable extends _SourceRowsResult {
  const _SourceRowsUnavailable(this.issue);

  final String issue;
}

final class _SourceRowsUnknown extends _SourceRowsResult {
  const _SourceRowsUnknown(this.issue);

  final String issue;
}
