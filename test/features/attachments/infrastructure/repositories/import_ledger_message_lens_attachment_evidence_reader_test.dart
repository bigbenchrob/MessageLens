import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/import_ledger_message_lens_attachment_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryRoot;
  late Directory archiveDirectory;
  late ImportDatabase importDatabase;
  late OverlayDatabase overlayDatabase;
  late ImportLedgerMessageLensAttachmentEvidenceReader reader;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp(
      'current_message_lens_attachment_evidence_reader_test_',
    );
    archiveDirectory = Directory(
      path.join(temporaryRoot.path, 'attachment_archive'),
    );
    importDatabase = await ImportDatabase.open(
      databaseDirectory: temporaryRoot.path,
      databaseName: 'import.db',
    );
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    reader = ImportLedgerMessageLensAttachmentEvidenceReader(
      importLedger: importDatabase,
      archiveReadStore: OverlayAttachmentArchiveReadStore(
        overlayDb: overlayDatabase,
        archiveDirectory: archiveDirectory.path,
      ),
      archiveDirectoryPath: archiveDirectory.path,
    );
    await _insertRelationship(importDatabase);
  });

  tearDown(() async {
    await importDatabase.close();
    await overlayDatabase.close();
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test('reads current identity through canonical import ledger', () async {
    final relationships = await reader.readRelationships(
      sourceId: 1,
      originalMessageRowId: 11,
      originalAttachmentRowId: 22,
    );

    expect(relationships, hasLength(1));
    expect(relationships.single.messageGuid, 'message-guid');
    expect(relationships.single.attachmentGuid, 'attachment-guid');
    expect(relationships.single.sourceScopedIdentityIsCoherent, isTrue);
  });

  test(
    'classifies physical archive evidence through canonical stores',
    () async {
      const archiveKey = ArchiveCompatibilityKey(
        messageGuid: 'message-guid',
        importAttachmentId: 22,
      );
      expect(
        (await reader.readPayloadStatuses(const [archiveKey]))[archiveKey],
        CurrentAttachmentPayloadStatus.missing,
      );

      final bytes = 'current archive payload'.codeUnits;
      final hash = sha256.convert(bytes).toString();
      final relativePath = '${hash.substring(0, 2)}/$hash.bin';
      final file = File(path.join(archiveDirectory.path, relativePath));
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      await overlayDatabase.customStatement(
        '''
      INSERT INTO archived_attachments (
        message_guid, import_attachment_id, archive_relative_path,
        archived_at_utc, file_size_bytes, content_hash
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
        <Object?>[
          'message-guid',
          22,
          relativePath,
          '2026-08-21T00:00:00.000Z',
          bytes.length,
          hash,
        ],
      );

      final progress = <(int, int)>[];
      final presentStatuses = await reader.readPayloadStatuses(
        const [archiveKey],
        onProgress: (completed, total) {
          progress.add((completed, total));
        },
      );
      expect(
        presentStatuses[archiveKey],
        CurrentAttachmentPayloadStatus.presentValid,
      );
      expect(progress, const [(1, 1)]);
      await file.writeAsBytes(List<int>.filled(bytes.length, 120));
      expect(
        (await reader.readPayloadStatuses(const [archiveKey]))[archiveKey],
        CurrentAttachmentPayloadStatus.presentValid,
        reason: 'preflight defers byte hashing to installation revalidation',
      );
      await file.writeAsString('conflicting bytes');
      expect(
        (await reader.readPayloadStatuses(const [archiveKey]))[archiveKey],
        CurrentAttachmentPayloadStatus.presentConflict,
      );
      await file.delete();
      expect(
        (await reader.readPayloadStatuses(const [archiveKey]))[archiveKey],
        CurrentAttachmentPayloadStatus.missing,
        reason: 'overlay metadata alone cannot prove physical presence',
      );
    },
  );

  test('resolves missing metadata without per-item archive queries', () async {
    const archiveKey = ArchiveCompatibilityKey(
      messageGuid: 'message-guid',
      importAttachmentId: 22,
    );
    final progress = <(int, int)>[];

    await reader.readPayloadStatuses(
      List<ArchiveCompatibilityKey>.filled(501, archiveKey),
      onProgress: (completed, total) {
        progress.add((completed, total));
      },
    );

    expect(progress, const [(501, 501)]);
  });

  test(
    'unavailable root reports inaccessible without payload inspection',
    () async {
      const archiveKey = ArchiveCompatibilityKey(
        messageGuid: 'message-guid',
        importAttachmentId: 22,
      );
      final unavailableReader = ImportLedgerMessageLensAttachmentEvidenceReader(
        importLedger: importDatabase,
        archiveReadStore: OverlayAttachmentArchiveReadStore(
          overlayDb: overlayDatabase,
          archiveDirectory: archiveDirectory.path,
        ),
        archiveLocation: AttachmentArchiveLocationState.customUnavailable(
          configuration: AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: 'AQID',
            lastKnownPath: '/Volumes/Offline/Archive',
          ),
          issue: 'Volume disconnected.',
        ),
      );
      final progress = <(int, int)>[];

      final statuses = await unavailableReader.readPayloadStatuses(
        const [archiveKey],
        onProgress: (completed, total) {
          progress.add((completed, total));
        },
      );

      expect(statuses[archiveKey], CurrentAttachmentPayloadStatus.inaccessible);
      expect(progress, const [(1, 1)]);
      expect(archiveDirectory.existsSync(), isFalse);
    },
  );
}

Future<void> _insertRelationship(ImportDatabase database) async {
  final batchId = await database.insertImportBatch(
    sourceId: 1,
    startedAtUtc: '2026-08-21T00:00:00.000Z',
  );
  final messageSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 11);
  final attachmentSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 22);
  await database.database.insert('messages', <String, Object?>{
    'ss_id': messageSsId,
    'source_id': 1,
    'source_rowid': 11,
    'guid': 'message-guid',
    'is_from_me': 0,
    'batch_id': batchId,
  });
  await database.database.insert('attachments', <String, Object?>{
    'ss_id': attachmentSsId,
    'source_id': 1,
    'source_rowid': 22,
    'guid': 'attachment-guid',
    'filename': 'payload.bin',
    'total_bytes': 7,
    'batch_id': batchId,
  });
  await database.database.insert('message_to_attachment', <String, Object?>{
    'message_source_id': 1,
    'attachment_source_id': 1,
    'source_message_rowid': 11,
    'source_attachment_rowid': 22,
    'message_ss_id': messageSsId,
    'attachment_ss_id': attachmentSsId,
    'batch_id': batchId,
  });
}
