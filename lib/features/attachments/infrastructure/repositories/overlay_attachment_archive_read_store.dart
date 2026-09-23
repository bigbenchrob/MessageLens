import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/attachment_archive_read_store.dart';
import '../../application/attachment_recovery_hint_storage.dart';
import '../../domain/constants/attachment_archive_payload_status.dart';
import '../../domain/entities/attachment_archive_location_state.dart';
import '../../domain/entities/attachment_recovery_metadata.dart';

class OverlayAttachmentArchiveReadStore implements AttachmentArchiveReadStore {
  OverlayAttachmentArchiveReadStore({
    required OverlayDatabase overlayDb,
    AttachmentArchiveLocationState? location,
    String? archiveDirectory,
    FileSystemEntityType Function(String path)? entryTypeReader,
  }) : _overlayDb = overlayDb,
       location = _resolveLocation(location, archiveDirectory),
       _entryTypeReader = entryTypeReader ?? _defaultEntryTypeReader;

  final OverlayDatabase _overlayDb;
  final FileSystemEntityType Function(String path) _entryTypeReader;

  @override
  final AttachmentArchiveLocationState location;

  @override
  Future<Map<ArchiveCompatibilityKey, AttachmentArchiveMetadataRecord>>
  readAllArchiveMetadata() async {
    final rows = await _overlayDb.customSelect('''
          SELECT message_guid, import_attachment_id, archive_relative_path,
                 file_size_bytes, content_hash, provenance
          FROM archived_attachments
          ''').get();
    final records =
        <ArchiveCompatibilityKey, AttachmentArchiveMetadataRecord>{};
    for (final row in rows) {
      final key = ArchiveCompatibilityKey.fromStoredTuple(
        messageGuid: row.read<String>('message_guid'),
        importAttachmentId: row.read<int>('import_attachment_id'),
      );
      final relativePath = row.read<String>('archive_relative_path');
      if (!_isSafeRelativePath(relativePath)) {
        continue;
      }
      records[key] = AttachmentArchiveMetadataRecord(
        archiveRelativePath: relativePath,
        fileSizeBytes: row.read<int>('file_size_bytes'),
        contentHash: row.readNullable<String>('content_hash'),
      );
    }
    return records;
  }

  @override
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    final archiveRows = await _overlayDb
        .customSelect(
          '''
          SELECT archive_relative_path, file_size_bytes, content_hash,
                 provenance
          FROM archived_attachments
          WHERE message_guid = ? AND import_attachment_id = ?
          LIMIT 1
          ''',
          variables: [
            Variable<String>(archiveKey.messageGuid),
            Variable<int>(archiveKey.importAttachmentId),
          ],
        )
        .get();

    if (archiveRows.isEmpty) {
      return null;
    }

    final row = archiveRows.single;
    final relativePath = row.read<String>('archive_relative_path');
    if (!_isSafeRelativePath(relativePath)) {
      return AttachmentArchiveLookupRecord(
        archiveRelativePath: relativePath,
        archiveAbsolutePath: null,
        payloadStatus: AttachmentArchivePayloadStatus.invalidMetadataPath,
        locationAvailability: location.availability,
        locationGeneration: location.generation,
        rootIssue: location.issue,
        fileSizeBytes: row.read<int>('file_size_bytes'),
        contentHash: row.readNullable<String>('content_hash'),
        provenance: row.readNullable<String>('provenance'),
      );
    }

    if (!location.isAvailable) {
      return AttachmentArchiveLookupRecord(
        archiveRelativePath: relativePath,
        archiveAbsolutePath: null,
        payloadStatus: AttachmentArchivePayloadStatus.rootUnavailable,
        locationAvailability: location.availability,
        locationGeneration: location.generation,
        rootIssue: location.issue,
        fileSizeBytes: row.read<int>('file_size_bytes'),
        contentHash: row.readNullable<String>('content_hash'),
        provenance: row.readNullable<String>('provenance'),
      );
    }

    final absolutePath = _boundedArchivePath(
      archiveDirectory: location.requireArchiveRootPath(),
      relativePath: relativePath,
    );
    if (absolutePath == null) {
      throw StateError('A validated archive-relative path escaped its root.');
    }

    return AttachmentArchiveLookupRecord(
      archiveRelativePath: relativePath,
      archiveAbsolutePath: absolutePath,
      payloadStatus: _payloadStatus(absolutePath),
      locationAvailability: location.availability,
      locationGeneration: location.generation,
      rootIssue: location.issue,
      fileSizeBytes: row.read<int>('file_size_bytes'),
      contentHash: row.readNullable<String>('content_hash'),
      provenance: row.readNullable<String>('provenance'),
    );
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return decodeAttachmentRecoveryHint(
      await _overlayDb.readOverlaySetting(
        attachmentRecoveryHintSettingKey(archiveKey: archiveKey),
      ),
    );
  }

  static String? _boundedArchivePath({
    required String archiveDirectory,
    required String relativePath,
  }) {
    if (archiveDirectory.isEmpty ||
        relativePath.isEmpty ||
        path.isAbsolute(relativePath)) {
      return null;
    }

    final archiveRoot = path.normalize(path.absolute(archiveDirectory));
    final absolutePath = path.normalize(path.join(archiveRoot, relativePath));
    if (!path.isWithin(archiveRoot, absolutePath)) {
      return null;
    }

    return absolutePath;
  }

  static bool _isSafeRelativePath(String relativePath) {
    if (relativePath.isEmpty || path.isAbsolute(relativePath)) {
      return false;
    }
    final normalized = path.normalize(relativePath);
    return normalized != '.' &&
        normalized != '..' &&
        !normalized.startsWith('../');
  }

  AttachmentArchivePayloadStatus _payloadStatus(String filePath) {
    return switch (_entryTypeReader(filePath)) {
      FileSystemEntityType.file => AttachmentArchivePayloadStatus.available,
      FileSystemEntityType.notFound => AttachmentArchivePayloadStatus.missing,
      _ => AttachmentArchivePayloadStatus.unexpectedFileType,
    };
  }

  static FileSystemEntityType _defaultEntryTypeReader(String filePath) {
    return FileSystemEntity.typeSync(filePath, followLinks: false);
  }

  static AttachmentArchiveLocationState _resolveLocation(
    AttachmentArchiveLocationState? location,
    String? archiveDirectory,
  ) {
    if (location != null) {
      return location;
    }
    if (archiveDirectory == null || archiveDirectory.isEmpty) {
      throw ArgumentError(
        'Either location or archiveDirectory must identify the archive root.',
      );
    }
    return AttachmentArchiveLocationState.defaultAvailable(
      archiveRootPath: archiveDirectory,
    );
  }
}
