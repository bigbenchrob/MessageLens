import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/graph_attachment_archive_lookup.dart';
import '../../domain/constants/attachment_archive_payload_status.dart';
import '../../domain/entities/attachment_archive_location_state.dart';

/// Resolves graph attachment identity against existing archive overlay rows.
///
/// The current archive table is still keyed by the overlay archive tuple
/// `(message_guid, import_attachment_id)`. For live `chat.db` rows,
/// `import_attachment_id` is the source attachment ROWID and can be derived
/// from `attachment_ss_id`.
///
/// This is an explicit compatibility bridge. It must not become the model for
/// non-live sources because the overlay archive tuple does not carry source
/// scope.
class OverlayArchiveCompatibilityLookup
    implements GraphAttachmentArchiveLookup {
  OverlayArchiveCompatibilityLookup({
    required this.graphDatabase,
    required this.overlayDatabase,
    AttachmentArchiveLocationState? location,
    String? archiveDirectory,
  }) : location = _resolveLocation(location, archiveDirectory);

  final ConversationGraphDatabase graphDatabase;
  final OverlayDatabase overlayDatabase;
  final AttachmentArchiveLocationState location;

  @override
  Future<GraphAttachmentArchiveRecord?> readArchiveRecord({
    required int messageSsId,
    required int attachmentSsId,
  }) async {
    if (!ArchiveCompatibilityKey.supportsLiveGraphEndpoints(
      messageSsId: messageSsId,
      attachmentSsId: attachmentSsId,
    )) {
      return null;
    }

    final messageRows = await graphDatabase.selectRows(
      '''
      SELECT m.guid AS message_guid
      FROM message_to_attachment mta
      JOIN messages m ON m.ss_id = mta.message_ss_id
      WHERE mta.message_ss_id = ?
        AND mta.attachment_ss_id = ?
      LIMIT 1
      ''',
      <Object?>[messageSsId, attachmentSsId],
    );
    if (messageRows.isEmpty) {
      return null;
    }

    final messageGuid = messageRows.single['message_guid'];
    if (messageGuid is! String || messageGuid.isEmpty) {
      return null;
    }

    final archiveKey = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
      messageGuid: messageGuid,
      attachmentSsId: attachmentSsId,
    );
    final archiveRows = await overlayDatabase
        .customSelect(
          '''
          SELECT archive_relative_path
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

    final relativePath = archiveRows.single.read<String>(
      'archive_relative_path',
    );
    if (!_isSafeRelativePath(relativePath)) {
      return GraphAttachmentArchiveRecord(
        archiveRelativePath: relativePath,
        archiveAbsolutePath: null,
        payloadStatus: AttachmentArchivePayloadStatus.invalidMetadataPath,
        locationAvailability: location.availability,
        locationGeneration: location.generation,
        rootIssue: location.issue,
      );
    }
    if (!location.isAvailable) {
      return GraphAttachmentArchiveRecord(
        archiveRelativePath: relativePath,
        archiveAbsolutePath: null,
        payloadStatus: AttachmentArchivePayloadStatus.rootUnavailable,
        locationAvailability: location.availability,
        locationGeneration: location.generation,
        rootIssue: location.issue,
      );
    }

    final archiveDirectory = location.requireArchiveRootPath();
    final archiveRoot = path.normalize(path.absolute(archiveDirectory));
    final absolutePath = path.normalize(path.join(archiveRoot, relativePath));
    if (!path.isWithin(archiveRoot, absolutePath)) {
      return null;
    }

    return GraphAttachmentArchiveRecord(
      archiveRelativePath: relativePath,
      archiveAbsolutePath: absolutePath,
      payloadStatus: _payloadStatus(absolutePath),
      locationAvailability: location.availability,
      locationGeneration: location.generation,
      rootIssue: location.issue,
    );
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

  static AttachmentArchivePayloadStatus _payloadStatus(String filePath) {
    return switch (FileSystemEntity.typeSync(filePath, followLinks: false)) {
      FileSystemEntityType.file => AttachmentArchivePayloadStatus.available,
      FileSystemEntityType.notFound => AttachmentArchivePayloadStatus.missing,
      _ => AttachmentArchivePayloadStatus.unexpectedFileType,
    };
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
