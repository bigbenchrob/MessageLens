import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
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
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef GraphMaterialSnapshot = Map<String, List<Map<String, Object?>>>;

enum GraphReplayStage {
  handles,
  contacts,
  chatHandles,
  chats,
  messages,
  attachments,
  chatMessages,
  messageAttachments,
}

final class GraphReplayInterrupted implements Exception {
  const GraphReplayInterrupted(this.completedStage);

  final GraphReplayStage completedStage;

  @override
  String toString() => 'Graph replay interrupted after $completedStage';
}

final class ProductionGraphReplayHarness {
  ProductionGraphReplayHarness._({
    required this.root,
    required this.importLedgerPath,
    required this.graphPath,
    required this.historicalSourceId,
    required this.historicalIdentity,
    required this.importLedger,
    required this.graph,
  }) : _handles = SqliteHandleProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _contacts = SqliteContactProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _chatHandles = SqliteChatToHandleProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _chats = SqliteChatProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _messages = SqliteMessageProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _attachments = SqliteAttachmentProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _chatMessages = SqliteChatToMessageProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       ),
       _messageAttachments = SqliteMessageToAttachmentProjectionRepository(
         importLedgerDatabase: importLedger,
         graphDatabase: graph,
       );

  static const _graphTableQueries = <String, String>{
    'messages': 'SELECT * FROM messages ORDER BY ss_id ASC',
    'message_text_fts':
        'SELECT rowid, text FROM message_text_fts ORDER BY rowid ASC',
    'handles': 'SELECT * FROM handles ORDER BY ss_id ASC',
    'canonical_handles':
        'SELECT * FROM canonical_handles ORDER BY canonical_handle_ss_id ASC',
    'handle_aliases': 'SELECT * FROM handle_aliases ORDER BY handle_ss_id ASC',
    'chats': 'SELECT * FROM chats ORDER BY ss_id ASC',
    'chat_to_message':
        'SELECT * FROM chat_to_message '
        'ORDER BY chat_ss_id ASC, message_ss_id ASC',
    'chat_to_handle':
        'SELECT * FROM chat_to_handle '
        'ORDER BY chat_ss_id ASC, handle_ss_id ASC',
    'contacts': 'SELECT * FROM contacts ORDER BY contact_id ASC',
    'contact_to_handle':
        'SELECT * FROM contact_to_handle '
        'ORDER BY contact_id ASC, handle_ss_id ASC',
    'attachments': 'SELECT * FROM attachments ORDER BY ss_id ASC',
    'message_to_attachment':
        'SELECT * FROM message_to_attachment '
        'ORDER BY message_ss_id ASC, attachment_ss_id ASC',
  };

  final Directory root;
  final String importLedgerPath;
  final String graphPath;
  final int historicalSourceId;
  final HistoricalArchiveSourceIdentity historicalIdentity;
  final ImportDatabase importLedger;
  final ConversationGraphDatabase graph;
  final SqliteHandleProjectionRepository _handles;
  final SqliteContactProjectionRepository _contacts;
  final SqliteChatToHandleProjectionRepository _chatHandles;
  final SqliteChatProjectionRepository _chats;
  final SqliteMessageProjectionRepository _messages;
  final SqliteAttachmentProjectionRepository _attachments;
  final SqliteChatToMessageProjectionRepository _chatMessages;
  final SqliteMessageToAttachmentProjectionRepository _messageAttachments;

  bool _disposed = false;
  int duplicateChatMessageInsertCount = -1;
  int duplicateMessageAttachmentInsertCount = -1;

  static Future<ProductionGraphReplayHarness> open({
    int historicalSourceId = 3,
  }) async {
    final createdRoot = await Directory.systemTemp.createTemp(
      'messagelens_production_graph_replay_',
    );
    final canonicalRoot = Directory(createdRoot.resolveSymbolicLinksSync());
    ImportDatabase? ledger;
    ConversationGraphDatabase? graph;
    try {
      final ledgerDirectory = Directory(
        path.join(canonicalRoot.path, 'ledger'),
      );
      final graphDirectory = Directory(path.join(canonicalRoot.path, 'graph'));
      await ledgerDirectory.create(recursive: true);
      await graphDirectory.create(recursive: true);
      final ledgerPath = path.join(ledgerDirectory.path, 'import.db');
      final graphPath = path.join(graphDirectory.path, 'conversation.db');
      _verifyDisposablePath(canonicalRoot.path, ledgerPath);
      _verifyDisposablePath(canonicalRoot.path, graphPath);

      ledger = await ImportDatabase.open(
        databaseDirectory: ledgerDirectory.path,
        databaseName: path.basename(ledgerPath),
      );
      graph = ConversationGraphDatabase(NativeDatabase(File(graphPath)));
      await graph.customSelect('SELECT 1').get();
      final identity =
          HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            path.join(canonicalRoot.path, 'synthetic-donor', 'chat.db'),
          );
      return ProductionGraphReplayHarness._(
        root: canonicalRoot,
        importLedgerPath: ledgerPath,
        graphPath: graphPath,
        historicalSourceId: historicalSourceId,
        historicalIdentity: identity,
        importLedger: ledger,
        graph: graph,
      );
    } catch (_) {
      await graph?.close();
      await ledger?.close();
      if (canonicalRoot.existsSync()) {
        await canonicalRoot.delete(recursive: true);
      }
      rethrow;
    }
  }

  List<String> get openedPaths => <String>[importLedgerPath, graphPath];

  Future<void> seedCanonicalFixture() async {
    await _registerHistoricalSource();
    await _insertBatch(liveChatDbSourceId, 1001);
    await _insertBatch(liveAddressBookSourceId, 1002);
    await _insertBatch(historicalSourceId, _historicalBatchId);
    await _seedLiveAndContactFacts();
    await seedHistoricalFacts(insertBatch: false);
  }

  Future<void> seedHistoricalFacts({bool insertBatch = true}) async {
    if (insertBatch) {
      await _insertBatch(historicalSourceId, _historicalBatchId);
    }
    final handleId = ss(historicalSourceId, 10);
    final chatId = ss(historicalSourceId, 30);
    final messageId = ss(historicalSourceId, 40);
    final attachmentId = ss(historicalSourceId, 50);
    final database = importLedger.database;
    await database.insert('handles', <String, Object?>{
      'ss_id': handleId,
      'source_id': historicalSourceId,
      'source_rowid': 10,
      'id': 'archive@example.com',
      'service': 'iMessage',
      'is_me': 0,
      'batch_id': _historicalBatchId,
    });
    await database.insert('chats', <String, Object?>{
      'ss_id': chatId,
      'source_id': historicalSourceId,
      'source_rowid': 30,
      'guid': 'historical-chat',
      'service': 'iMessage',
      'last_read_message_at_utc': '2019-01-01T00:00:00.000Z',
      'batch_id': _historicalBatchId,
    });
    await database.insert('chat_to_handle', <String, Object?>{
      'source_id': historicalSourceId,
      'source_chat_rowid': 30,
      'source_handle_rowid': 10,
      'chat_ss_id': chatId,
      'handle_ss_id': handleId,
      'batch_id': _historicalBatchId,
    });
    await database.insert('messages', <String, Object?>{
      'ss_id': messageId,
      'source_id': historicalSourceId,
      'source_rowid': 40,
      'guid': 'historical-message',
      'sender_handle_ss_id': handleId,
      'is_from_me': 0,
      'date_utc': '2019-01-02T00:00:00.000Z',
      'text': 'Archived Unicode Καλημέρα',
      'batch_id': _historicalBatchId,
    });
    await database.insert('attachments', <String, Object?>{
      'ss_id': attachmentId,
      'source_id': historicalSourceId,
      'source_rowid': 50,
      'guid': 'historical-attachment',
      'filename': 'archive.txt',
      'transfer_name': 'archive.txt',
      'uti': 'public.plain-text',
      'mime_type': 'text/plain',
      'total_bytes': 12,
      'created_at_utc': '2019-01-02T00:00:00.000Z',
      'batch_id': _historicalBatchId,
    });
    await database.insert('chat_to_message', <String, Object?>{
      'ss_id': ss(historicalSourceId, 100),
      'source_id': historicalSourceId,
      'source_rowid': 100,
      'source_chat_rowid': 30,
      'source_message_rowid': 40,
      'chat_ss_id': chatId,
      'message_ss_id': messageId,
    });
    await database.insert('message_to_attachment', <String, Object?>{
      'message_source_id': historicalSourceId,
      'attachment_source_id': historicalSourceId,
      'source_message_rowid': 40,
      'source_attachment_rowid': 50,
      'message_ss_id': messageId,
      'attachment_ss_id': attachmentId,
      'batch_id': _historicalBatchId,
    });
  }

  Future<void> addIncrementalLiveFacts() async {
    final database = importLedger.database;
    final messageId = ss(liveChatDbSourceId, 60);
    final attachmentId = ss(liveChatDbSourceId, 60);
    await database.insert('messages', <String, Object?>{
      'ss_id': messageId,
      'source_id': liveChatDbSourceId,
      'source_rowid': 60,
      'guid': 'live-incremental',
      'sender_handle_ss_id': ss(liveChatDbSourceId, 10),
      'is_from_me': 0,
      'date_utc': '2026-01-02T00:00:00.000Z',
      'text': 'Incremental four prefix',
      'batch_id': 1001,
    });
    await database.insert('attachments', <String, Object?>{
      'ss_id': attachmentId,
      'source_id': liveChatDbSourceId,
      'source_rowid': 60,
      'guid': 'live-incremental-attachment',
      'filename': 'incremental.txt',
      'transfer_name': 'incremental.txt',
      'uti': 'public.plain-text',
      'mime_type': 'text/plain',
      'total_bytes': 4,
      'created_at_utc': '2026-01-02T00:00:00.000Z',
      'batch_id': 1001,
    });
    await database.insert('chat_to_message', <String, Object?>{
      'ss_id': ss(liveChatDbSourceId, 160),
      'source_id': liveChatDbSourceId,
      'source_rowid': 160,
      'source_chat_rowid': 30,
      'source_message_rowid': 60,
      'chat_ss_id': ss(liveChatDbSourceId, 30),
      'message_ss_id': messageId,
    });
    await database.insert('message_to_attachment', <String, Object?>{
      'message_source_id': liveChatDbSourceId,
      'attachment_source_id': liveChatDbSourceId,
      'source_message_rowid': 60,
      'source_attachment_rowid': 60,
      'message_ss_id': messageId,
      'attachment_ss_id': attachmentId,
      'batch_id': 1001,
    });
  }

  Future<void> replayFull({GraphReplayStage? stopAfter}) async {
    await _handles.projectHandles();
    await _handles.projectLocalAccountIdentity();
    _stopIfRequested(stopAfter, GraphReplayStage.handles);
    await _contacts.projectContacts();
    _stopIfRequested(stopAfter, GraphReplayStage.contacts);
    await _chatHandles.projectEdges();
    _stopIfRequested(stopAfter, GraphReplayStage.chatHandles);
    await _chats.projectChats();
    _stopIfRequested(stopAfter, GraphReplayStage.chats);
    await _messages.projectMessages();
    _stopIfRequested(stopAfter, GraphReplayStage.messages);
    await _attachments.projectAttachments();
    _stopIfRequested(stopAfter, GraphReplayStage.attachments);
    await _chatMessages.projectEdges();
    _stopIfRequested(stopAfter, GraphReplayStage.chatMessages);
    await _messageAttachments.projectEdges();
    _stopIfRequested(stopAfter, GraphReplayStage.messageAttachments);
  }

  Future<void> replayIncrementalLive({int startedAfterSourceRowId = 49}) async {
    await _messages.projectMessagesAfterSourceRowId(
      sourceId: liveChatDbSourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
    await _attachments.projectAttachmentsAfterSourceRowId(
      sourceId: liveChatDbSourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
    await _chatMessages.projectEdgesAfterSourceMessageRowId(
      sourceId: liveChatDbSourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
    await _messageAttachments.projectEdgesAfterSourceMessageRowId(
      sourceId: liveChatDbSourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }

  Future<void> makeGraphDeliberatelyStale() async {
    await graph.executeSql(
      'UPDATE contacts SET display_name = ? WHERE contact_id = ?',
      <Object?>['Stale Contact Name', ss(liveAddressBookSourceId, 20)],
    );
    await graph.executeSql(
      'UPDATE chats SET is_group = 0 WHERE ss_id = ?',
      <Object?>[ss(liveChatDbSourceId, 30)],
    );
    await graph.executeSql(
      'INSERT OR IGNORE INTO chat_to_message '
      '(chat_ss_id, message_ss_id) VALUES (?, ?)',
      <Object?>[ss(liveChatDbSourceId, 31), ss(liveChatDbSourceId, 40)],
    );
    await graph.executeSql(
      'INSERT OR IGNORE INTO message_to_attachment '
      '(message_ss_id, attachment_ss_id) VALUES (?, ?)',
      <Object?>[ss(liveChatDbSourceId, 44), ss(liveChatDbSourceId, 50)],
    );
  }

  Future<void> updateLiveMessageText({
    required int sourceRowId,
    required String text,
  }) async {
    await importLedger.database.update(
      'messages',
      <String, Object?>{'text': text},
      where: 'source_id = ? AND source_rowid = ?',
      whereArgs: <Object?>[liveChatDbSourceId, sourceRowId],
    );
  }

  Future<SourceScopedArchiveGraphRemovalResult> removeHistoricalSource() {
    final service = SourceScopedArchiveGraphRemovalService(
      importLedger: importLedger,
      graphProjectionResetter: DriftGraphProjectionResetter(
        graphDatabase: graph,
      ),
      handleProjector: HandleProjector(repository: _handles),
      contactProjector: ContactProjector(repository: _contacts),
      chatToHandleProjector: ChatToHandleProjector(repository: _chatHandles),
      chatProjector: ChatProjector(repository: _chats),
      messageProjector: MessageProjector(repository: _messages),
      attachmentProjector: AttachmentProjector(repository: _attachments),
      chatToMessageProjector: ChatToMessageProjector(repository: _chatMessages),
      messageToAttachmentProjector: MessageToAttachmentProjector(
        repository: _messageAttachments,
      ),
    );
    return service.removeArchiveSource(sourceIdentity: historicalIdentity);
  }

  Future<GraphMaterialSnapshot> snapshot() async {
    return <String, List<Map<String, Object?>>>{
      for (final entry in _graphTableQueries.entries)
        entry.key: await graph.selectRows(entry.value),
    };
  }

  Future<List<int>> searchMessageIds(String expression) async {
    final rows = await graph.selectRows(
      'SELECT rowid FROM message_text_fts '
      'WHERE message_text_fts MATCH ? ORDER BY rowid ASC',
      <Object?>[expression],
    );
    return <int>[
      for (final row in rows)
        if (row['rowid'] case final int value) value,
    ];
  }

  Future<List<Map<String, Object?>>> sourceRegistryRows() {
    return importLedger.database.query(
      'source_registry',
      columns: <String>[
        'source_id',
        'source_key',
        'source_kind',
        'source_label',
      ],
      orderBy: 'source_id ASC',
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    Object? firstFailure;
    StackTrace? firstStackTrace;
    try {
      await graph.close();
    } catch (error, stackTrace) {
      firstFailure = error;
      firstStackTrace = stackTrace;
    }
    try {
      await importLedger.close();
    } catch (error, stackTrace) {
      firstFailure ??= error;
      firstStackTrace ??= stackTrace;
    }
    try {
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
    } catch (error, stackTrace) {
      firstFailure ??= error;
      firstStackTrace ??= stackTrace;
    }
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure, firstStackTrace!);
    }
  }

  int ss(int sourceId, int sourceRowId) {
    return SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    );
  }

  int get _historicalBatchId => 1000 + historicalSourceId;

  Future<void> _registerHistoricalSource() async {
    await importLedger.database.insert('source_registry', <String, Object?>{
      'source_id': historicalSourceId,
      'source_key': historicalIdentity.value,
      'source_kind': historicalIdentity.sourceKind,
      'source_label': 'Synthetic historical source',
      'created_at_utc': '2020-01-01T00:00:00.000Z',
    });
  }

  Future<void> _insertBatch(int sourceId, int batchId) async {
    await importLedger.database.insert('import_batches', <String, Object?>{
      'batch_id': batchId,
      'source_id': sourceId,
      'started_at_utc': '2026-01-01T00:00:00.000Z',
      'finished_at_utc': '2026-01-01T00:01:00.000Z',
      'notes': 'synthetic replay fixture',
    });
  }

  Future<void> _seedLiveAndContactFacts() async {
    final database = importLedger.database;
    final handles = <Map<String, Object?>>[
      _handle(10, '+1 (604) 999-5969', isMe: false),
      _handle(11, '6049995969', isMe: false),
      _handle(12, '*city*', isMe: false),
      _handle(13, 'ME@EXAMPLE.COM', isMe: true),
    ];
    for (final row in handles) {
      await database.insert('handles', row);
    }
    final contacts = <Map<String, Object?>>[
      _contact(20, 'Alice Example', firstName: 'Alice', lastName: 'Example'),
      _contact(21, 'Alicia Competing', firstName: 'Alicia'),
    ];
    for (final row in contacts) {
      await database.insert('contacts', row);
    }
    for (final contactRowId in <int>[20, 21]) {
      await database.insert('contact_channels', <String, Object?>{
        'source_id': liveAddressBookSourceId,
        'source_contact_rowid': contactRowId,
        'contact_ss_id': ss(liveAddressBookSourceId, contactRowId),
        'kind': 'phone',
        'value': '(604) 999-5969',
        'label': 'mobile',
        'batch_id': 1002,
      });
    }
    for (final row in <Map<String, Object?>>[
      _chat(30, 'live-group-chat'),
      _chat(31, 'live-single-chat'),
    ]) {
      await database.insert('chats', row);
    }
    for (final handleRowId in <int>[10, 11, 12]) {
      await database.insert('chat_to_handle', <String, Object?>{
        'source_id': liveChatDbSourceId,
        'source_chat_rowid': 30,
        'source_handle_rowid': handleRowId,
        'chat_ss_id': ss(liveChatDbSourceId, 30),
        'handle_ss_id': ss(liveChatDbSourceId, handleRowId),
        'batch_id': 1001,
      });
    }
    await database.insert('chat_to_handle', <String, Object?>{
      'source_id': liveChatDbSourceId,
      'source_chat_rowid': 31,
      'source_handle_rowid': 13,
      'chat_ss_id': ss(liveChatDbSourceId, 31),
      'handle_ss_id': ss(liveChatDbSourceId, 13),
      'batch_id': 1001,
    });
    final messages = <Map<String, Object?>>[
      _message(40, 'live-target', text: 'Café co-op punctuation'),
      _message(
        41,
        'live-rich-text',
        text: 'Résumé café Καλημέρα',
        senderRowId: 11,
        hasAttributedBodySource: true,
      ),
      _message(
        42,
        'live-associated',
        text: 'Associated reply',
        associatedGuid: 'p:0/live-target',
      ),
      _message(
        43,
        'live-missing-associated',
        text: 'Missing endpoint reply',
        associatedGuid: 'p:0/not-present',
      ),
      _message(44, 'live-null-text', text: null, senderRowId: 12),
    ];
    for (final row in messages) {
      await database.insert('messages', row);
    }
    for (final rowId in <int>[50, 51]) {
      await database.insert('attachments', <String, Object?>{
        'ss_id': ss(liveChatDbSourceId, rowId),
        'source_id': liveChatDbSourceId,
        'source_rowid': rowId,
        'guid': 'live-attachment-$rowId',
        'filename': 'fixture-$rowId.txt',
        'transfer_name': 'fixture-$rowId.txt',
        'uti': 'public.plain-text',
        'mime_type': 'text/plain',
        'total_bytes': rowId,
        'created_at_utc': '2026-01-01T00:00:00.000Z',
        'batch_id': 1001,
      });
    }
    for (final messageRowId in <int>[40, 41, 42, 43, 44]) {
      await database.insert('chat_to_message', <String, Object?>{
        'ss_id': ss(liveChatDbSourceId, 100 + messageRowId),
        'source_id': liveChatDbSourceId,
        'source_rowid': 100 + messageRowId,
        'source_chat_rowid': 30,
        'source_message_rowid': messageRowId,
        'chat_ss_id': ss(liveChatDbSourceId, 30),
        'message_ss_id': ss(liveChatDbSourceId, messageRowId),
      });
    }
    duplicateChatMessageInsertCount = await database
        .insert('chat_to_message', <String, Object?>{
          'ss_id': ss(liveChatDbSourceId, 140),
          'source_id': liveChatDbSourceId,
          'source_rowid': 140,
          'source_chat_rowid': 30,
          'source_message_rowid': 40,
          'chat_ss_id': ss(liveChatDbSourceId, 30),
          'message_ss_id': ss(liveChatDbSourceId, 40),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await database.insert('message_to_attachment', <String, Object?>{
      'message_source_id': liveChatDbSourceId,
      'attachment_source_id': liveChatDbSourceId,
      'source_message_rowid': 40,
      'source_attachment_rowid': 50,
      'message_ss_id': ss(liveChatDbSourceId, 40),
      'attachment_ss_id': ss(liveChatDbSourceId, 50),
      'batch_id': 1001,
    });
    duplicateMessageAttachmentInsertCount = await database
        .insert('message_to_attachment', <String, Object?>{
          'message_source_id': liveChatDbSourceId,
          'attachment_source_id': liveChatDbSourceId,
          'source_message_rowid': 40,
          'source_attachment_rowid': 50,
          'message_ss_id': ss(liveChatDbSourceId, 40),
          'attachment_ss_id': ss(liveChatDbSourceId, 50),
          'batch_id': 1001,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await database.insert('message_to_attachment', <String, Object?>{
      'message_source_id': liveChatDbSourceId,
      'attachment_source_id': liveChatDbSourceId,
      'source_message_rowid': 41,
      'source_attachment_rowid': 51,
      'message_ss_id': ss(liveChatDbSourceId, 41),
      'attachment_ss_id': ss(liveChatDbSourceId, 51),
      'batch_id': 1001,
    });
  }

  Map<String, Object?> _handle(
    int rowId,
    String identifier, {
    required bool isMe,
  }) {
    return <String, Object?>{
      'ss_id': ss(liveChatDbSourceId, rowId),
      'source_id': liveChatDbSourceId,
      'source_rowid': rowId,
      'id': identifier,
      'service': 'iMessage',
      'is_me': isMe ? 1 : 0,
      'batch_id': 1001,
    };
  }

  Map<String, Object?> _contact(
    int rowId,
    String displayName, {
    String? firstName,
    String? lastName,
  }) {
    return <String, Object?>{
      'ss_id': ss(liveAddressBookSourceId, rowId),
      'source_id': liveAddressBookSourceId,
      'source_rowid': rowId,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'created_at_utc': '2026-01-01T00:00:00.000Z',
      'batch_id': 1002,
    };
  }

  Map<String, Object?> _chat(int rowId, String guid) {
    return <String, Object?>{
      'ss_id': ss(liveChatDbSourceId, rowId),
      'source_id': liveChatDbSourceId,
      'source_rowid': rowId,
      'guid': guid,
      'service': 'iMessage',
      'last_read_message_at_utc': '2026-01-01T00:00:00.000Z',
      'batch_id': 1001,
    };
  }

  Map<String, Object?> _message(
    int rowId,
    String guid, {
    required String? text,
    int senderRowId = 10,
    String? associatedGuid,
    bool hasAttributedBodySource = false,
  }) {
    return <String, Object?>{
      'ss_id': ss(liveChatDbSourceId, rowId),
      'source_id': liveChatDbSourceId,
      'source_rowid': rowId,
      'guid': guid,
      'sender_handle_ss_id': ss(liveChatDbSourceId, senderRowId),
      'is_from_me': senderRowId == 13 ? 1 : 0,
      'date_utc': '2026-01-01T00:00:00.000Z',
      'text': text,
      'associated_message_guid': associatedGuid,
      'raw_item_type': 0,
      'raw_associated_message_type': associatedGuid == null ? 0 : 2000,
      'is_system_message': 0,
      'has_attributed_body_source': hasAttributedBodySource ? 1 : 0,
      'has_message_summary_info': 0,
      'has_payload_data_source': 0,
      'batch_id': 1001,
    };
  }

  static void _stopIfRequested(
    GraphReplayStage? requested,
    GraphReplayStage completed,
  ) {
    if (requested == completed) {
      throw GraphReplayInterrupted(completed);
    }
  }

  static void _verifyDisposablePath(String rootPath, String candidatePath) {
    final normalizedRoot = path.normalize(path.absolute(rootPath));
    final normalizedCandidate = path.normalize(path.absolute(candidatePath));
    if (!path.isWithin(normalizedRoot, normalizedCandidate)) {
      throw StateError('Disposable database path escaped its test root.');
    }
    final forbiddenFragments = <String>[
      '${path.separator}Library${path.separator}Messages',
      '${path.separator}Application Support${path.separator}',
      '${path.separator}Volumes${path.separator}',
    ];
    if (forbiddenFragments.any(normalizedCandidate.contains)) {
      throw StateError('Disposable database path overlaps a protected root.');
    }
  }
}
