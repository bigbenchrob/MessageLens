import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain/archive_access_authority.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_checkpoint_exception.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/resolved_archive_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_checkpoint_service.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_production_archive_adoption_service.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_path_lookup.dart';
import 'package:remember_this_text/features/attachments/application/graph_attachment_archive_providers.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
    'adopted production clone imports catch-up and preserves attachment',
    () async {
      final tempRoot = await Directory.systemTemp.createTemp(
        'production-adoption-preservation-rehearsal-',
      );
      final sourceArchive = Directory(
        path.join(tempRoot.path, 'unmarked-source'),
      );
      final checkpointRoot = path.join(tempRoot.path, 'checkpoint');
      final adoptedRoot = path.join(tempRoot.path, 'adopted-clone');
      final appleSourceRoot = Directory(
        path.join(tempRoot.path, 'apple-source'),
      );
      await sourceArchive.create(recursive: true);
      await appleSourceRoot.create(recursive: true);

      ImportDatabase? importDatabase;
      ConversationGraphDatabase? graphDatabase;
      OverlayDatabase? overlayDatabase;
      ProviderContainer? container;

      try {
        importDatabase = await ImportDatabase.open(
          databaseDirectory: sourceArchive.path,
          databaseName: 'macos_import_ss.db',
        );
        await importDatabase.close();
        importDatabase = null;
        await File(
              path.join(
                sourceArchive.path,
                'attachment_archive',
                'baseline.bin',
              ),
            )
            .create(recursive: true)
            .then((file) => file.writeAsString('preserved-before-adoption'));

        const checkpointService = FileSystemArchiveCheckpointService();
        final adoptionService = FileSystemProductionArchiveAdoptionService(
          checkpointService: checkpointService,
        );
        await adoptionService.prepareCheckpoint(
          sourceRootPath: sourceArchive.path,
          checkpointRootPath: checkpointRoot,
        );
        await checkpointService.restoreAndVerify(
          checkpointRootPath: checkpointRoot,
          disposableRestoreRootPath: adoptedRoot,
        );
        final marker = await adoptionService.adopt(
          rootPath: adoptedRoot,
          checkpointRootPath: checkpointRoot,
        );

        final authority = ArchiveAccessAuthority(
          identity: ResolvedArchiveIdentity(
            environment: ArchiveEnvironment.production,
            buildIdentity: ArchiveBuildIdentity.productionRelease,
            archiveInstanceId: marker.archiveInstanceId,
            canonicalRootPath: Directory(
              adoptedRoot,
            ).resolveSymbolicLinksSync(),
            bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
            productName: 'MessageLens',
          ),
        );

        final chatDbPath = path.join(appleSourceRoot.path, 'chat.db');
        await _createSourceMessageTable(chatDbPath);
        await _insertSourceMessage(
          chatDbPath,
          rowId: 100,
          guid: 'message-100',
          text: 'present before startup',
        );

        importDatabase = await ImportDatabase.open(
          databaseDirectory: adoptedRoot,
          databaseName: 'macos_import_ss.db',
        );
        final importer = MessageImporter(
          chatDbPath: chatDbPath,
          importLedger: importDatabase,
          sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
        );
        final startupImport = await importer.importNewMessages();
        expect(startupImport.insertedMessageCount, 1);
        expect(startupImport.lastImportedSourceRowId, 100);

        await _insertSourceMessage(
          chatDbPath,
          rowId: 101,
          guid: 'message-101',
          text: 'arrived while production was offline',
        );
        final catchUpImport = await importer.importNewMessages();
        expect(catchUpImport.startedAfterSourceRowId, 100);
        expect(catchUpImport.insertedMessageCount, 1);
        expect(catchUpImport.lastImportedSourceRowId, 101);
        expect(await importDatabase.database.query('messages'), hasLength(2));

        final sourceAttachment = File(
          path.join(appleSourceRoot.path, 'Attachments', 'catch-up.png'),
        );
        await sourceAttachment.create(recursive: true);
        await sourceAttachment.writeAsString('catch-up-attachment');

        graphDatabase = ConversationGraphDatabase(
          NativeDatabase(
            File(path.join(adoptedRoot, 'working_ss.db')),
            logStatements: false,
          ),
        );
        overlayDatabase = OverlayDatabase(
          NativeDatabase(
            File(path.join(adoptedRoot, 'user_overlays.db')),
            logStatements: false,
          ),
        );
        await overlayDatabase.writeOverlaySetting(
          settingKey: 'attachment_archive_enabled',
          settingValue: 'true',
        );
        await _insertGraphAttachment(
          graphDatabase,
          messageSourceRowId: 101,
          messageGuid: 'message-101',
          attachmentSourceRowId: 700,
          localPath: sourceAttachment.path,
        );

        final attachmentPathLookup = _AttachmentPathLookup({
          700: sourceAttachment.path,
        });
        container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(authority),
            driftConversationGraphDatabaseProvider.overrideWith(
              (ref) async => graphDatabase!,
            ),
            overlayDatabaseProvider.overrideWith(
              (ref) async => overlayDatabase!,
            ),
            currentMessagesAttachmentPathLookupProvider.overrideWith(
              (ref) async => attachmentPathLookup,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              (ref) async => AttachmentArchiveLocationState.defaultAvailable(
                archiveRootPath: authority.resolvePath('attachment_archive'),
              ),
            ),
          ],
        );

        final archiveResult = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveGraphMessageSourceRange(
              sourceId: liveChatDbSourceId,
              startedAfterSourceRowId: 100,
              lastImportedSourceRowId: 101,
            );
        expect(archiveResult.totalScanned, 1);
        expect(archiveResult.newlyArchived, 1);
        expect(archiveResult.failed, 0);

        final archivedRow =
            await (overlayDatabase.select(overlayDatabase.archivedAttachments)
                  ..where(
                    (table) =>
                        table.messageGuid.equals('message-101') &
                        table.importAttachmentId.equals(700),
                  ))
                .getSingle();
        expect(
          File(
            path.join(
              adoptedRoot,
              'attachment_archive',
              archivedRow.archiveRelativePath,
            ),
          ).readAsStringSync(),
          'catch-up-attachment',
        );
        expect(
          File(
            path.join(adoptedRoot, 'attachment_archive', 'baseline.bin'),
          ).readAsStringSync(),
          'preserved-before-adoption',
        );

        await expectLater(
          adoptionService.rollback(
            rootPath: adoptedRoot,
            checkpointRootPath: checkpointRoot,
          ),
          throwsA(isA<ArchiveCheckpointException>()),
        );
        expect(
          await FileSystemArchiveMarkerStore(rootPath: adoptedRoot).read(),
          isNotNull,
        );
      } finally {
        container?.dispose();
        await overlayDatabase?.close();
        await graphDatabase?.close();
        await importDatabase?.close();
        if (tempRoot.existsSync()) {
          await tempRoot.delete(recursive: true);
        }
      }
    },
  );
}

Future<void> _createSourceMessageTable(String chatDbPath) async {
  final database = await openDatabase(chatDbPath);
  await database.execute('''
    CREATE TABLE message (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
      handle_id INTEGER,
      is_from_me INTEGER NOT NULL,
      date INTEGER,
      date_read INTEGER,
      date_delivered INTEGER,
      text TEXT,
      attributedBody BLOB,
      associated_message_guid TEXT,
      item_type INTEGER,
      associated_message_type INTEGER,
      thread_originator_guid TEXT,
      error INTEGER,
      is_system_message INTEGER,
      message_summary_info BLOB,
      payload_data BLOB
    )
  ''');
  await database.execute('''
    CREATE TABLE chat_message_join (
      chat_id INTEGER NOT NULL,
      message_id INTEGER NOT NULL
    )
  ''');
  await database.close();
}

Future<void> _insertSourceMessage(
  String chatDbPath, {
  required int rowId,
  required String guid,
  required String text,
}) async {
  final database = await openDatabase(chatDbPath);
  await database.insert('message', <String, Object?>{
    'ROWID': rowId,
    'guid': guid,
    'handle_id': 0,
    'is_from_me': 1,
    'text': text,
  });
  await database.close();
}

Future<void> _insertGraphAttachment(
  ConversationGraphDatabase database, {
  required int messageSourceRowId,
  required String messageGuid,
  required int attachmentSourceRowId,
  required String localPath,
}) async {
  final messageSsId = SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: messageSourceRowId,
  );
  final attachmentSsId = SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: attachmentSourceRowId,
  );
  await database.executeSql(
    '''
    INSERT INTO messages (ss_id, guid, is_from_me)
    VALUES (?, ?, 1)
    ''',
    <Object?>[messageSsId, messageGuid],
  );
  await database.executeSql(
    '''
    INSERT INTO attachments (ss_id, guid, filename, mime_type)
    VALUES (?, ?, ?, ?)
    ''',
    <Object?>[
      attachmentSsId,
      'attachment-$attachmentSourceRowId',
      localPath,
      'image/png',
    ],
  );
  await database.executeSql(
    '''
    INSERT INTO message_to_attachment (message_ss_id, attachment_ss_id)
    VALUES (?, ?)
    ''',
    <Object?>[messageSsId, attachmentSsId],
  );
}

final class _AttachmentPathLookup
    implements CurrentMessagesAttachmentPathLookup {
  const _AttachmentPathLookup(this.pathsBySourceRowId);

  final Map<int, String> pathsBySourceRowId;

  @override
  Future<String?> attachmentPathForSourceRowId(int sourceRowId) async {
    return pathsBySourceRowId[sourceRowId];
  }
}
