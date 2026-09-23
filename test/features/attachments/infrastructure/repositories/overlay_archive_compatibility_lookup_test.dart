import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_archive_payload_status.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'graph_archive_lookup_test_',
    );
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    await archiveDir.create(recursive: true);
    graphDatabase = ConversationGraphDatabase(NativeDatabase.memory());
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await graphDatabase.close();
    await overlayDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'resolves existing archive row from graph attachment identity',
    () async {
      final messageSsId = _ss(100);
      final attachmentSsId = _ss(200);
      final archivedFile = File(path.join(archiveDir.path, 'ab/archived.jpg'));
      await archivedFile.parent.create(recursive: true);
      await archivedFile.writeAsString('image');

      await _insertGraphAttachment(
        graphDatabase,
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
        messageGuid: 'message-guid-1',
      );
      await _insertArchiveRow(
        overlayDatabase,
        messageGuid: 'message-guid-1',
        importAttachmentId: 200,
        archiveRelativePath: 'ab/archived.jpg',
      );

      final lookup = OverlayArchiveCompatibilityLookup(
        graphDatabase: graphDatabase,
        overlayDatabase: overlayDatabase,
        archiveDirectory: archiveDir.path,
      );

      final record = await lookup.readArchiveRecord(
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
      );

      expect(record, isNotNull);
      expect(record!.archiveRelativePath, 'ab/archived.jpg');
      expect(record.archiveAbsolutePath, archivedFile.path);
      expect(record.archiveFileExists, isTrue);
    },
  );

  test(
    'does not resolve compatibility-key archive rows for non-live source ids',
    () async {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: 2,
        sourceRowId: 100,
      );
      final attachmentSsId = SourceScopedRowKey.pack(
        sourceId: 2,
        sourceRowId: 200,
      );

      await _insertGraphAttachment(
        graphDatabase,
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
        messageGuid: 'message-guid-1',
      );
      await _insertArchiveRow(
        overlayDatabase,
        messageGuid: 'message-guid-1',
        importAttachmentId: 200,
        archiveRelativePath: 'ab/archived.jpg',
      );

      final lookup = OverlayArchiveCompatibilityLookup(
        graphDatabase: graphDatabase,
        overlayDatabase: overlayDatabase,
        archiveDirectory: archiveDir.path,
      );

      final record = await lookup.readArchiveRecord(
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
      );

      expect(record, isNull);
    },
  );

  test('does not report symlinked archive paths as available files', () async {
    final messageSsId = _ss(100);
    final attachmentSsId = _ss(200);
    final protectedFile = File(path.join(tempDir.path, 'protected.jpg'));
    await protectedFile.writeAsString('outside archive');
    final archiveLink = Link(path.join(archiveDir.path, 'linked.jpg'));
    await archiveLink.create(protectedFile.path);

    await _insertGraphAttachment(
      graphDatabase,
      messageSsId: messageSsId,
      attachmentSsId: attachmentSsId,
      messageGuid: 'message-guid-1',
    );
    await _insertArchiveRow(
      overlayDatabase,
      messageGuid: 'message-guid-1',
      importAttachmentId: 200,
      archiveRelativePath: 'linked.jpg',
    );

    final lookup = OverlayArchiveCompatibilityLookup(
      graphDatabase: graphDatabase,
      overlayDatabase: overlayDatabase,
      archiveDirectory: archiveDir.path,
    );

    final record = await lookup.readArchiveRecord(
      messageSsId: messageSsId,
      attachmentSsId: attachmentSsId,
    );

    expect(record, isNotNull);
    expect(record!.archiveRelativePath, 'linked.jpg');
    expect(record.archiveFileExists, isFalse);
    expect(await protectedFile.readAsString(), 'outside archive');
  });

  test(
    'does not resolve compatibility-key archive rows for mixed-source endpoints',
    () async {
      final messageSsId = SourceScopedRowKey.pack(
        sourceId: 2,
        sourceRowId: 100,
      );
      final attachmentSsId = _ss(200);

      await _insertGraphAttachment(
        graphDatabase,
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
        messageGuid: 'message-guid-1',
      );
      await _insertArchiveRow(
        overlayDatabase,
        messageGuid: 'message-guid-1',
        importAttachmentId: 200,
        archiveRelativePath: 'ab/archived.jpg',
      );

      final lookup = OverlayArchiveCompatibilityLookup(
        graphDatabase: graphDatabase,
        overlayDatabase: overlayDatabase,
        archiveDirectory: archiveDir.path,
      );

      final record = await lookup.readArchiveRecord(
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
      );

      expect(record, isNull);
    },
  );

  test(
    'returns null when graph topology does not link the endpoints',
    () async {
      final lookup = OverlayArchiveCompatibilityLookup(
        graphDatabase: graphDatabase,
        overlayDatabase: overlayDatabase,
        archiveDirectory: archiveDir.path,
      );

      final record = await lookup.readArchiveRecord(
        messageSsId: _ss(100),
        attachmentSsId: _ss(200),
      );

      expect(record, isNull);
    },
  );

  test(
    'returns null when archive relative path escapes archive root',
    () async {
      final messageSsId = _ss(100);
      final attachmentSsId = _ss(200);
      final escapedFile = File(path.join(tempDir.path, 'escaped.jpg'));
      await escapedFile.writeAsString('outside');

      await _insertGraphAttachment(
        graphDatabase,
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
        messageGuid: 'message-guid-1',
      );
      await _insertArchiveRow(
        overlayDatabase,
        messageGuid: 'message-guid-1',
        importAttachmentId: 200,
        archiveRelativePath: '../escaped.jpg',
      );

      final lookup = OverlayArchiveCompatibilityLookup(
        graphDatabase: graphDatabase,
        overlayDatabase: overlayDatabase,
        archiveDirectory: archiveDir.path,
      );

      final record = await lookup.readArchiveRecord(
        messageSsId: messageSsId,
        attachmentSsId: attachmentSsId,
      );

      expect(
        record?.payloadStatus,
        AttachmentArchivePayloadStatus.invalidMetadataPath,
      );
      expect(record?.archiveAbsolutePath, isNull);
    },
  );
}

Future<void> _insertGraphAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int messageSsId,
  required int attachmentSsId,
  required String messageGuid,
}) async {
  await graphDatabase.executeSql(
    '''
    INSERT INTO messages (ss_id, guid, is_from_me)
    VALUES (?, ?, 0)
    ''',
    <Object?>[messageSsId, messageGuid],
  );
  await graphDatabase.executeSql(
    '''
    INSERT INTO attachments (ss_id, guid, filename)
    VALUES (?, ?, ?)
    ''',
    <Object?>[attachmentSsId, 'attachment-guid', 'photo.jpg'],
  );
  await graphDatabase.executeSql(
    '''
    INSERT INTO message_to_attachment (message_ss_id, attachment_ss_id)
    VALUES (?, ?)
    ''',
    <Object?>[messageSsId, attachmentSsId],
  );
}

Future<void> _insertArchiveRow(
  OverlayDatabase overlayDatabase, {
  required String messageGuid,
  required int importAttachmentId,
  required String archiveRelativePath,
}) async {
  await overlayDatabase.customStatement(
    '''
    INSERT INTO archived_attachments (
      message_guid,
      import_attachment_id,
      archive_relative_path,
      archived_at_utc,
      file_size_bytes,
      content_hash,
      provenance
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
    <Object?>[
      messageGuid,
      importAttachmentId,
      archiveRelativePath,
      '2026-05-31T10:00:00.000Z',
      5,
      'hash',
      'archived',
    ],
  );
}

int _ss(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}
