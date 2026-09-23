import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:remember_this_text/essentials/conversation_graph/application/health/graph_health_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/health/graph_health_report.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/graph_health_repository.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  test('reports graph row counts and structural health issues', () async {
    final database = await openConversationGraphTestDatabase();
    addTearDown(database.close);
    final reader = GraphHealthReader(
      repository: SqliteGraphHealthRepository(graphDatabase: database),
    );

    await database.database.insert('messages', {
      'ss_id': 1,
      'guid': 'message-1',
      'sender_handle_ss_id': 10,
      'sender_canonical_handle_ss_id': null,
      'is_from_me': 0,
    });
    await database.database.insert('messages', {
      'ss_id': 2,
      'guid': 'message-2',
      'is_from_me': 1,
    });
    await database.database.insert('chats', {
      'ss_id': 100,
      'guid': 'chat-100',
      'is_group': 0,
    });
    await database.database.insert('chats', {
      'ss_id': 101,
      'guid': 'chat-101',
      'is_group': 0,
    });
    await database.database.insert('handles', {
      'ss_id': 10,
      'id': '+16045550100',
    });
    await database.database.insert('handles', {
      'ss_id': 11,
      'id': '+16045550101',
    });
    await database.database.insert('canonical_handles', {
      'canonical_handle_ss_id': 10,
      'display_handle': '+16045550100',
      'normalized_identifier': '16045550100',
      'alias_count': 1,
    });
    await database.database.insert('handle_aliases', {
      'handle_ss_id': 10,
      'canonical_handle_ss_id': 10,
      'raw_identifier': '+16045550100',
      'normalized_identifier': '16045550100',
      'alias_kind': 'phone',
    });
    await database.database.insert('contacts', {
      'contact_id': 1,
      'display_name': 'Known Contact',
    });
    await database.database.insert('contacts', {
      'contact_id': 2,
      'display_name': 'Unlinked Contact',
    });
    await database.database.insert('attachments', {
      'ss_id': 200,
      'guid': 'attachment-200',
    });
    await database.database.insert('attachments', {
      'ss_id': 201,
      'guid': 'attachment-201',
    });
    await database.database.insert('chat_to_message', {
      'chat_ss_id': 100,
      'message_ss_id': 1,
    });
    await database.database.insert('chat_to_message', {
      'chat_ss_id': 999,
      'message_ss_id': 999,
    });
    await database.database.insert('chat_to_handle', {
      'chat_ss_id': 100,
      'handle_ss_id': 10,
    });
    await database.database.insert('chat_to_handle', {
      'chat_ss_id': 999,
      'handle_ss_id': 999,
    });
    await database.database.insert('message_to_attachment', {
      'message_ss_id': 1,
      'attachment_ss_id': 200,
    });
    await database.database.insert('message_to_attachment', {
      'message_ss_id': 999,
      'attachment_ss_id': 999,
    });
    await database.database.insert('contact_to_handle', {
      'contact_id': 1,
      'handle_ss_id': 10,
      'handle_value': '+16045550100',
    });
    await database.database.insert('contact_to_handle', {
      'contact_id': 999,
      'handle_ss_id': 999,
      'handle_value': '+16045550999',
    });

    final report = await reader.readHealthReport();

    expect(report.messageCount, 2);
    expect(report.chatCount, 2);
    expect(report.handleCount, 2);
    expect(report.canonicalHandleCount, 1);
    expect(report.handleAliasCount, 1);
    expect(report.contactCount, 2);
    expect(report.attachmentCount, 2);
    expect(report.chatToMessageEdgeCount, 2);
    expect(report.chatToHandleEdgeCount, 2);
    expect(report.messageToAttachmentEdgeCount, 2);
    expect(report.contactToHandleEdgeCount, 2);
    expect(report.orphanMessageCount, 1);
    expect(report.chatsWithZeroMessagesCount, 1);
    expect(report.chatsWithZeroHandlesCount, 1);
    expect(report.attachmentsWithoutMessageEdgeCount, 1);
    expect(report.messagesMissingSenderCanonicalHandleCount, 0);
    expect(report.handlesWithoutCanonicalAliasCount, 1);
    expect(report.contactsWithoutHandlesCount, 1);
    expect(report.chatToMessageEdgesMissingChatCount, 1);
    expect(report.chatToMessageEdgesMissingMessageCount, 1);
    expect(report.chatToHandleEdgesMissingChatCount, 1);
    expect(report.chatToHandleEdgesMissingHandleCount, 1);
    expect(report.messageToAttachmentEdgesMissingMessageCount, 1);
    expect(report.messageToAttachmentEdgesMissingAttachmentCount, 1);
    expect(report.contactToHandleEdgesMissingContactCount, 1);
    expect(report.contactToHandleEdgesMissingHandleCount, 1);
    expect(report.archiveFileAuditIncluded, isFalse);
    expect(report.attachmentRecoveryAuditIncluded, isFalse);
  });

  test(
    'recovery audit uses unavailable defaults without external sources',
    () async {
      final database = await openConversationGraphTestDatabase();
      addTearDown(database.close);
      final reader = GraphHealthReader(
        repository: SqliteGraphHealthRepository(graphDatabase: database),
      );

      final report = await reader.readHealthReport(includeRecoveryAudit: true);

      expect(report.attachmentRecoveryAuditIncluded, isTrue);
      expect(report.historicalArchiveAvailable, isFalse);
      expect(report.historicalArchiveRecordCount, 0);
      expect(report.historicalArchiveFilesAvailableCount, 0);
      expect(report.historicalArchiveFilesMissingCount, 0);
      expect(report.attachmentsRecoverableFromHistoricalArchiveCount, 0);
      expect(report.recoveredMessagesSourceAvailable, isFalse);
      expect(report.recoveredMessagesAttachmentKeyCount, 0);
      expect(report.attachmentsRecoverableFromRecoveredMessagesCount, 0);
      expect(report.attachmentsRecoverableFromBothRecoverySourcesCount, 0);
      expect(report.attachmentsStillMissingFromKnownRecoverySourcesCount, 0);
    },
  );

  test('reports archive record and archive file readiness', () async {
    final database = await openConversationGraphTestDatabase();
    final overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    final tempDir = await Directory.systemTemp.createTemp(
      'graph_health_archive_test_',
    );
    addTearDown(database.close);
    addTearDown(overlayDatabase.close);
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    final archiveFile = File('${tempDir.path}/ab/archived-image.jpg');
    archiveFile.parent.createSync(recursive: true);
    archiveFile.writeAsStringSync('archived bytes');
    final symlinkTarget = File('${tempDir.path}/outside-linked-image.jpg');
    symlinkTarget.writeAsStringSync('outside bytes');
    final symlinkedArchivePath = Link('${tempDir.path}/ab/linked-image.jpg');
    symlinkedArchivePath.createSync(symlinkTarget.path);
    final escapedArchiveFile = File(
      p.join(tempDir.parent.path, '${p.basename(tempDir.path)}_escaped.jpg'),
    );
    final escapedArchiveRelativePath = p.relative(
      escapedArchiveFile.path,
      from: tempDir.path,
    );
    escapedArchiveFile.writeAsStringSync('escaped bytes');
    addTearDown(() {
      if (escapedArchiveFile.existsSync()) {
        escapedArchiveFile.deleteSync();
      }
    });
    final reader = GraphHealthReader(
      repository: SqliteGraphHealthRepository(
        graphDatabase: database,
        overlayDatabase: overlayDatabase,
        attachmentArchiveDirectory: tempDir.path,
      ),
    );

    await database.database.insert('messages', {
      'ss_id': 1,
      'guid': 'message-1',
      'is_from_me': 0,
    });
    await database.database.insert('attachments', {
      'ss_id': 8796093022209,
      'guid': 'attachment-1',
    });
    await database.database.insert('attachments', {
      'ss_id': 8796093022210,
      'guid': 'attachment-2',
    });
    await database.database.insert('message_to_attachment', {
      'message_ss_id': 1,
      'attachment_ss_id': 8796093022209,
    });
    await database.database.insert('message_to_attachment', {
      'message_ss_id': 1,
      'attachment_ss_id': 8796093022210,
    });
    await overlayDatabase.customStatement(
      '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        'message-1',
        1,
        'ab/archived-image.jpg',
        '2026-05-23T00:00:00.000Z',
        14,
        'archived',
      ],
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        'message-2',
        99,
        'zz/missing.jpg',
        '2026-05-23T00:00:00.000Z',
        20,
        'archived',
      ],
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        'message-3',
        100,
        'ab/linked-image.jpg',
        '2026-05-23T00:00:00.000Z',
        20,
        'archived',
      ],
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        'message-4',
        101,
        escapedArchiveRelativePath,
        '2026-05-23T00:00:00.000Z',
        20,
        'archived',
      ],
    );

    final report = await reader.readHealthReport(includeFileAudits: true);

    expect(report.archiveFileAuditIncluded, isTrue);
    expect(report.archiveRecordCount, 4);
    expect(report.attachmentsWithArchiveRecordCount, 1);
    expect(report.attachmentsMissingArchiveRecordCount, 1);
    expect(report.archiveFilesAvailableCount, 1);
    expect(report.archiveFilesMissingCount, 3);
    expect(report.archiveRecordsWithoutGraphAttachmentCount, 3);
  });

  test(
    'unavailable archive defers physical audit without mass missing findings',
    () async {
      final database = await openConversationGraphTestDatabase();
      final overlayDatabase = OverlayDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      addTearDown(overlayDatabase.close);
      await database.database.insert('messages', {
        'ss_id': 1,
        'guid': 'message-1',
        'is_from_me': 1,
      });
      for (var index = 0; index < 3; index++) {
        await overlayDatabase.customStatement(
          '''
          INSERT INTO archived_attachments (
            message_guid,
            import_attachment_id,
            archive_relative_path,
            archived_at_utc,
            file_size_bytes,
            provenance
          ) VALUES (?, ?, ?, ?, ?, ?)
          ''',
          <Object?>[
            'message-$index',
            index,
            'payload-$index.jpg',
            '2026-09-15T00:00:00.000Z',
            10,
            'archived',
          ],
        );
      }
      final reader = GraphHealthReader(
        repository: SqliteGraphHealthRepository(
          graphDatabase: database,
          overlayDatabase: overlayDatabase,
          attachmentArchiveUnavailableReason: 'Volume is disconnected.',
        ),
      );

      final report = await reader.readHealthReport(includeRecoveryAudit: true);

      expect(report.messageCount, 1);
      expect(report.archiveRecordCount, 3);
      expect(
        report.archivePhysicalAuditStatus,
        GraphArchivePhysicalAuditStatus.deferredRootUnavailable,
      );
      expect(report.archivePhysicalAuditIssue, 'Volume is disconnected.');
      expect(report.archiveFilesAvailableCount, 0);
      expect(report.archiveFilesMissingCount, 0);
      expect(report.dryRunStillMissingEverywhereCount, 0);
    },
  );
}
