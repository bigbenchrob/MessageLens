import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_projection_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chats/chat_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_to_message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/contact_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/drift_graph_projection_resetter.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/message_to_attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/source_scoped_archive_import_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/filesystem_historical_messages_archive_source_folder_resolver.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late Directory archiveFolder;
  late String chatDbPath;
  late ImportDatabase importLedgerDatabase;
  late ConversationGraphDatabase graphDatabase;
  late SourceScopedArchiveGraphImportService service;
  late SourceScopedArchiveGraphRemovalService removalService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'source_scoped_archive_graph_import_service_test_',
    );
    archiveFolder = Directory(path.join(tempDir.path, 'Archive-2017'));
    await archiveFolder.create(recursive: true);
    chatDbPath = path.join(archiveFolder.path, 'chat.db');
    await _createArchiveChatDb(chatDbPath);
    await _insertArchiveRows(chatDbPath);

    importLedgerDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
    final importService = SourceScopedArchiveImportService(
      registrar: HistoricalMessagesArchiveSourceRegistrar(
        importLedger: importLedgerDatabase,
        folderResolver:
            const FilesystemHistoricalMessagesArchiveSourceFolderResolver(),
      ),
      richTextExtractor: const _FakeExtractor(<int, String>{
        300: 'enriched archive message',
      }),
      sourceDatabaseOpener: const SqfliteSourceDatabaseOpener(),
    );
    service = SourceScopedArchiveGraphImportService(
      importService: importService,
      handleProjector: HandleProjector(
        repository: SqliteHandleProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToHandleProjector: ChatToHandleProjector(
        repository: SqliteChatToHandleProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatProjector: ChatProjector(
        repository: SqliteChatProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageProjector: MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      attachmentProjector: AttachmentProjector(
        repository: SqliteAttachmentProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToMessageProjector: ChatToMessageProjector(
        repository: SqliteChatToMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageToAttachmentProjector: MessageToAttachmentProjector(
        repository: SqliteMessageToAttachmentProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
    );
    removalService = SourceScopedArchiveGraphRemovalService(
      importLedger: importLedgerDatabase,
      graphProjectionResetter: DriftGraphProjectionResetter(
        graphDatabase: graphDatabase,
      ),
      handleProjector: HandleProjector(
        repository: SqliteHandleProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      contactProjector: ContactProjector(
        repository: SqliteContactProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToHandleProjector: ChatToHandleProjector(
        repository: SqliteChatToHandleProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatProjector: ChatProjector(
        repository: SqliteChatProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageProjector: MessageProjector(
        repository: SqliteMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      attachmentProjector: AttachmentProjector(
        repository: SqliteAttachmentProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      chatToMessageProjector: ChatToMessageProjector(
        repository: SqliteChatToMessageProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
      messageToAttachmentProjector: MessageToAttachmentProjector(
        repository: SqliteMessageToAttachmentProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ),
    );
  });

  tearDown(() async {
    await graphDatabase.close();
    await importLedgerDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('imports and projects archive facts into the graph', () async {
    final observations = <SourceScopedArchiveGraphImportObservation>[];
    final firstResult = await service.importAndProject(
      folderPath: archiveFolder.path,
      sourceLabel: 'Archive 2017',
      onObservation: observations.add,
    );
    final secondResult = await service.importAndProject(
      folderPath: archiveFolder.path,
      sourceLabel: 'Archive 2017',
    );
    final sourceId = firstResult.importResult.registration.sourceId;
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 300,
    );
    final chatSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 100,
    );
    final handleSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 200,
    );
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: 400,
    );

    expect(firstResult.projectionResult.insertedGraphNodeCount, 4);
    expect(firstResult.projectionResult.insertedGraphEdgeCount, 3);
    expect(secondResult.projectionResult.insertedGraphNodeCount, 0);
    expect(secondResult.projectionResult.insertedGraphEdgeCount, 0);
    final transitions = observations
        .map((observation) => (observation.stage, observation.transition))
        .toList();
    expect(transitions.take(3), const [
      (
        SourceScopedArchiveGraphImportStage.importingSourceFacts,
        SourceScopedArchiveGraphImportStageTransition.started,
      ),
      (
        SourceScopedArchiveGraphImportStage.importingSourceFacts,
        SourceScopedArchiveGraphImportStageTransition.completed,
      ),
      (
        SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        SourceScopedArchiveGraphImportStageTransition.started,
      ),
    ]);
    expect(transitions.last, const (
      SourceScopedArchiveGraphImportStage.projectingConversationGraph,
      SourceScopedArchiveGraphImportStageTransition.completed,
    ));
    expect(
      transitions.skip(3).take(transitions.length - 4),
      everyElement(const (
        SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        SourceScopedArchiveGraphImportStageTransition.progressed,
      )),
    );
    final projectionProgress = observations
        .map((observation) => observation.projectionProgress)
        .whereType<SourceScopedArchiveGraphProjectionProgress>()
        .toList();
    expect(
      projectionProgress
          .where((progress) => progress.totalWorkCount == null)
          .map(
            (progress) => (
              progress.activeUnit,
              progress.completedUnitCount,
              progress.totalUnitCount,
            ),
          )
          .toList(),
      const [
        (SourceScopedArchiveGraphProjectionUnit.participants, 0, 5),
        (SourceScopedArchiveGraphProjectionUnit.conversations, 1, 5),
        (SourceScopedArchiveGraphProjectionUnit.messages, 2, 5),
        (SourceScopedArchiveGraphProjectionUnit.attachments, 3, 5),
        (SourceScopedArchiveGraphProjectionUnit.relationships, 4, 5),
      ],
    );
    expect(
      projectionProgress
          .where((progress) => progress.totalWorkCount != null)
          .map(
            (progress) => (
              progress.activeUnit,
              progress.completedWorkCount,
              progress.totalWorkCount,
            ),
          ),
      const [
        (SourceScopedArchiveGraphProjectionUnit.conversations, 0, 1),
        (SourceScopedArchiveGraphProjectionUnit.conversations, 1, 1),
        (SourceScopedArchiveGraphProjectionUnit.messages, 0, 1),
        (SourceScopedArchiveGraphProjectionUnit.messages, 1, 1),
        (SourceScopedArchiveGraphProjectionUnit.attachments, 0, 1),
        (SourceScopedArchiveGraphProjectionUnit.attachments, 1, 1),
      ],
    );

    final messages = await graphDatabase.database.query('messages');
    final chats = await graphDatabase.database.query('chats');
    final handles = await graphDatabase.database.query('handles');
    final attachments = await graphDatabase.database.query('attachments');
    final chatMessageEdges = await graphDatabase.database.query(
      'chat_to_message',
    );
    final chatHandleEdges = await graphDatabase.database.query(
      'chat_to_handle',
    );
    final messageAttachmentEdges = await graphDatabase.database.query(
      'message_to_attachment',
    );

    expect(messages, hasLength(1));
    expect(messages.single['ss_id'], messageSsId);
    expect(messages.single['text'], 'enriched archive message');
    expect(messages.single['sender_handle_ss_id'], handleSsId);
    expect(messages.single['sender_canonical_handle_ss_id'], handleSsId);
    expect(chats.single['ss_id'], chatSsId);
    expect(handles.single['ss_id'], handleSsId);
    expect(attachments.single['ss_id'], attachmentSsId);
    expect(chatMessageEdges.single['chat_ss_id'], chatSsId);
    expect(chatMessageEdges.single['message_ss_id'], messageSsId);
    expect(chatHandleEdges.single['chat_ss_id'], chatSsId);
    expect(chatHandleEdges.single['handle_ss_id'], handleSsId);
    expect(messageAttachmentEdges.single['message_ss_id'], messageSsId);
    expect(messageAttachmentEdges.single['attachment_ss_id'], attachmentSsId);
  });

  test(
    'profiles real projector units and reports bounded exact workloads',
    () async {
      await _insertSyntheticArchiveRows(
        chatDbPath,
        additionalChatCount: 60,
        additionalMessageCount: 1000,
        additionalAttachmentCount: 100,
      );
      final stopwatch = Stopwatch()..start();
      final unitStartedAt =
          <SourceScopedArchiveGraphProjectionUnit, Duration>{};
      final unitDurations =
          <SourceScopedArchiveGraphProjectionUnit, Duration>{};
      final workProgress =
          <SourceScopedArchiveGraphProjectionUnit, List<(int, int)>>{};
      SourceScopedArchiveGraphProjectionUnit? activeUnit;

      await service.importAndProject(
        folderPath: archiveFolder.path,
        sourceLabel: 'Archive profile fixture',
        onObservation: (observation) {
          final progress = observation.projectionProgress;
          if (progress != null && activeUnit != progress.activeUnit) {
            if (activeUnit case final previousUnit?) {
              unitDurations[previousUnit] =
                  stopwatch.elapsed - unitStartedAt[previousUnit]!;
            }
            activeUnit = progress.activeUnit;
            unitStartedAt[progress.activeUnit] = stopwatch.elapsed;
          }
          if (progress?.completedWorkCount case final int completed) {
            final total = progress!.totalWorkCount!;
            workProgress
                .putIfAbsent(progress.activeUnit, () => <(int, int)>[])
                .add((completed, total));
          }
          if (observation.transition ==
                  SourceScopedArchiveGraphImportStageTransition.completed &&
              observation.stage ==
                  SourceScopedArchiveGraphImportStage
                      .projectingConversationGraph) {
            final finalUnit = activeUnit;
            if (finalUnit != null) {
              unitDurations[finalUnit] =
                  stopwatch.elapsed - unitStartedAt[finalUnit]!;
            }
          }
        },
      );

      expect(
        unitDurations.keys,
        containsAll(SourceScopedArchiveGraphProjectionUnit.values),
      );
      expect(
        workProgress[SourceScopedArchiveGraphProjectionUnit.conversations],
        [(0, 61), (61, 61)],
      );
      expect(workProgress[SourceScopedArchiveGraphProjectionUnit.messages], [
        (0, 1001),
        (250, 1001),
        (500, 1001),
        (750, 1001),
        (1000, 1001),
        (1001, 1001),
      ]);
      expect(workProgress[SourceScopedArchiveGraphProjectionUnit.attachments], [
        (0, 101),
        (101, 101),
      ]);
      for (final progress in workProgress.values) {
        expect(
          progress.map((entry) => entry.$1),
          orderedEquals(progress.map((entry) => entry.$1).toList()..sort()),
        );
      }
    },
  );

  test(
    'removes one archive source while preserving live facts and donor files',
    () async {
      final donorBytesBefore = await File(chatDbPath).readAsBytes();
      final liveBatchId = await importLedgerDatabase.insertImportBatch(
        sourceId: 1,
        startedAtUtc: '2026-08-19T12:00:00.000Z',
      );
      final liveMessageSsId = SourceScopedRowKey.pack(
        sourceId: 1,
        sourceRowId: 900,
      );
      await importLedgerDatabase.database.insert('messages', <String, Object?>{
        'ss_id': liveMessageSsId,
        'source_id': 1,
        'source_rowid': 900,
        'guid': 'live-message-guid',
        'is_from_me': 0,
        'date_utc': '2026-08-19T12:00:00.000Z',
        'text': 'live current-Mac message',
        'batch_id': liveBatchId,
      });
      final importResult = await service.importAndProject(
        folderPath: archiveFolder.path,
        sourceLabel: 'Archive 2017',
      );
      final sourceId = importResult.importResult.registration.sourceId;

      expect(await _countGraphRows(graphDatabase, 'messages'), 2);
      expect(await _countImportRows(importLedgerDatabase, 'messages'), 2);

      final observations = <SourceScopedArchiveGraphRemovalObservation>[];
      final removalResult = await removalService.removeArchiveSource(
        sourceIdentity:
            HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
              path.join(archiveFolder.path, 'chat.db'),
            ),
        onObservation: observations.add,
      );

      expect(removalResult.sourceId, sourceId);
      expect(removalResult.sourceWasRegistered, isTrue);
      expect(removalResult.deletedSourceFactCount, 4);
      expect(removalResult.deletedTopologyEdgeCount, 3);
      expect(removalResult.graphReprojected, isTrue);
      expect(
        observations
            .where(
              (observation) =>
                  observation.transition !=
                  SourceScopedArchiveGraphRemovalStageTransition.progressed,
            )
            .map((observation) => (observation.stage, observation.transition))
            .toList(),
        const [
          (
            SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
            SourceScopedArchiveGraphRemovalStageTransition.started,
          ),
          (
            SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
            SourceScopedArchiveGraphRemovalStageTransition.completed,
          ),
          (
            SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph,
            SourceScopedArchiveGraphRemovalStageTransition.started,
          ),
          (
            SourceScopedArchiveGraphRemovalStage.rebuildingConversationGraph,
            SourceScopedArchiveGraphRemovalStageTransition.completed,
          ),
        ],
      );
      expect(
        observations
            .where(
              (observation) =>
                  observation.transition ==
                  SourceScopedArchiveGraphRemovalStageTransition.progressed,
            )
            .map((observation) => observation.projectionProgress?.activeUnit)
            .toSet(),
        SourceScopedArchiveGraphProjectionUnit.values.toSet(),
      );
      expect(
        observations.any(
          (observation) =>
              observation.projectionProgress?.completedWorkCount != null &&
              observation.projectionProgress?.totalWorkCount != null,
        ),
        isTrue,
      );

      for (final tableName in <String>[
        'chats',
        'handles',
        'attachments',
        'chat_to_message',
        'chat_to_handle',
        'message_to_attachment',
      ]) {
        expect(await _countGraphRows(graphDatabase, tableName), 0);
        expect(await _countImportRows(importLedgerDatabase, tableName), 0);
      }

      final importMessages = await importLedgerDatabase.database.query(
        'messages',
      );
      final graphMessages = await graphDatabase.database.query('messages');
      expect(importMessages, hasLength(1));
      expect(importMessages.single['ss_id'], liveMessageSsId);
      expect(importMessages.single['source_id'], 1);
      expect(graphMessages, hasLength(1));
      expect(graphMessages.single['ss_id'], liveMessageSsId);
      expect(graphMessages.single['text'], 'live current-Mac message');
      expect(await File(chatDbPath).readAsBytes(), donorBytesBefore);

      final registryRows = await importLedgerDatabase.database.query(
        'source_registry',
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      expect(registryRows, hasLength(1));

      final reimportResult = await service.importAndProject(
        folderPath: archiveFolder.path,
        sourceLabel: 'Archive 2017',
      );
      expect(reimportResult.importResult.registration.sourceId, sourceId);
      expect(await _countGraphRows(graphDatabase, 'messages'), 2);
    },
  );
}

Future<void> _createArchiveChatDb(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.execute('''
    CREATE TABLE chat (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT NOT NULL,
      service_name TEXT,
      group_id TEXT,
      original_group_id TEXT,
      last_read_message_timestamp INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE handle (
      ROWID INTEGER PRIMARY KEY,
      id TEXT NOT NULL,
      service TEXT
    )
  ''');
  await db.execute('''
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
  await db.execute('''
    CREATE TABLE attachment (
      ROWID INTEGER PRIMARY KEY,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      uti TEXT,
      mime_type TEXT,
      total_bytes INTEGER,
      created_date INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_message_join (
      ROWID INTEGER PRIMARY KEY,
      chat_id INTEGER NOT NULL,
      message_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE chat_handle_join (
      chat_id INTEGER NOT NULL,
      handle_id INTEGER NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE message_attachment_join (
      message_id INTEGER NOT NULL,
      attachment_id INTEGER NOT NULL
    )
  ''');
  await db.close();
}

Future<void> _insertArchiveRows(String chatDbPath) async {
  final db = await openDatabase(chatDbPath);
  await db.insert('chat', <String, Object?>{
    'ROWID': 100,
    'guid': 'archive-chat-guid',
    'service_name': 'iMessage',
    'group_id': 'archive-group',
  });
  await db.insert('handle', <String, Object?>{
    'ROWID': 200,
    'id': '+16045550100',
    'service': 'iMessage',
  });
  await db.insert('message', <String, Object?>{
    'ROWID': 300,
    'guid': 'archive-message-guid',
    'handle_id': 200,
    'is_from_me': 0,
    'text': null,
    'attributedBody': Uint8List.fromList(<int>[1, 2, 3]),
  });
  await db.insert('attachment', <String, Object?>{
    'ROWID': 400,
    'guid': 'archive-attachment-guid',
    'filename': 'Attachments/photo.jpg',
    'transfer_name': 'photo.jpg',
    'uti': 'public.jpeg',
    'mime_type': 'image/jpeg',
    'total_bytes': 1234,
  });
  await db.insert('chat_message_join', <String, Object?>{
    'ROWID': 500,
    'chat_id': 100,
    'message_id': 300,
  });
  await db.insert('chat_handle_join', <String, Object?>{
    'chat_id': 100,
    'handle_id': 200,
  });
  await db.insert('message_attachment_join', <String, Object?>{
    'message_id': 300,
    'attachment_id': 400,
  });
  await db.close();
}

Future<void> _insertSyntheticArchiveRows(
  String chatDbPath, {
  required int additionalChatCount,
  required int additionalMessageCount,
  required int additionalAttachmentCount,
}) async {
  final db = await openDatabase(chatDbPath);
  final batch = db.batch();
  for (var index = 0; index < additionalChatCount; index++) {
    final chatRowId = 1000 + index;
    final handleRowId = 2000 + index;
    batch.insert('chat', <String, Object?>{
      'ROWID': chatRowId,
      'guid': 'profile-chat-$index',
      'service_name': 'iMessage',
    });
    batch.insert('handle', <String, Object?>{
      'ROWID': handleRowId,
      'id': '+1604555${index.toString().padLeft(4, '0')}',
      'service': 'iMessage',
    });
    batch.insert('chat_handle_join', <String, Object?>{
      'chat_id': chatRowId,
      'handle_id': handleRowId,
    });
  }
  for (var index = 0; index < additionalMessageCount; index++) {
    final messageRowId = 10000 + index;
    batch.insert('message', <String, Object?>{
      'ROWID': messageRowId,
      'guid': 'profile-message-$index',
      'handle_id': 200,
      'is_from_me': index.isEven ? 1 : 0,
      'text': 'Profile message $index',
    });
    batch.insert('chat_message_join', <String, Object?>{
      'ROWID': 20000 + index,
      'chat_id': 100,
      'message_id': messageRowId,
    });
  }
  for (var index = 0; index < additionalAttachmentCount; index++) {
    final attachmentRowId = 30000 + index;
    batch.insert('attachment', <String, Object?>{
      'ROWID': attachmentRowId,
      'guid': 'profile-attachment-$index',
      'filename': 'Attachments/profile-$index.jpg',
      'transfer_name': 'profile-$index.jpg',
      'uti': 'public.jpeg',
      'mime_type': 'image/jpeg',
      'total_bytes': 1000 + index,
    });
    batch.insert('message_attachment_join', <String, Object?>{
      'message_id': 10000 + index,
      'attachment_id': attachmentRowId,
    });
  }
  await batch.commit(noResult: true);
  await db.close();
}

class _FakeExtractor implements MessageExtractorPort {
  const _FakeExtractor(this.extracted);

  final Map<int, String> extracted;

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    throw StateError('Archive import enrichment must decode import blobs');
  }

  @override
  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByWorkId, {
    MessageExtractionProgressObserver? onProgress,
  }) async {
    return <int, String>{
      for (final workId in attributedBodyBlobsByWorkId.keys)
        if (extracted[workId] ??
                extracted[SourceScopedRowKey.unpackSourceRowId(workId)]
            case final String value)
          workId: value,
    };
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<bool> isBlobExtractionAvailable() async {
    return true;
  }
}

Future<int> _countGraphRows(
  ConversationGraphDatabase graphDatabase,
  String tableName,
) async {
  final rows = await graphDatabase.database.rawQuery(
    'SELECT COUNT(*) AS row_count FROM $tableName',
  );
  return rows.single['row_count'] as int? ?? 0;
}

Future<int> _countImportRows(
  ImportDatabase importLedgerDatabase,
  String tableName,
) async {
  final rows = await importLedgerDatabase.database.rawQuery(
    'SELECT COUNT(*) AS row_count FROM $tableName',
  );
  return rows.single['row_count'] as int? ?? 0;
}
