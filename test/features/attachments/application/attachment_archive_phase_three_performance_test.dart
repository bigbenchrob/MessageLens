import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart';
import 'package:remember_this_text/features/attachments/application/graph_attachment_archive_lookup.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_archive_payload_status.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

import '../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  test('text search has no attachment payload I/O dependencies', () {
    final offenders = <String>[];
    for (final entry in Directory(
      'lib/essentials/search',
    ).listSync(recursive: true)) {
      if (entry is! File ||
          !entry.path.endsWith('.dart') ||
          entry.path.endsWith('.g.dart')) {
        continue;
      }
      final source = entry.readAsStringSync();
      if (source.contains('features/attachments') ||
          source.contains('readArchiveRecord') ||
          source.contains('FileSystemEntity') ||
          source.contains('attachmentArchive')) {
        offenders.add(entry.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Text search must remain database-only and must not scan or stat '
          'attachment archive payloads.',
    );
  });

  test(
    'recursive archive statistics have no implicit production consumers',
    () {
      final offenders = <String>[];
      for (final entry in Directory('lib').listSync(recursive: true)) {
        if (entry is! File ||
            !entry.path.endsWith('.dart') ||
            entry.path.endsWith('.g.dart') ||
            entry.path.endsWith('.freezed.dart') ||
            entry.path.endsWith('attachment_archive_runtime_providers.dart')) {
          continue;
        }
        final source = entry.readAsStringSync();
        if (source.contains('attachmentArchiveStatsReaderProvider') ||
            source.contains('attachmentArchiveStatisticsProvider')) {
          offenders.add(entry.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Recursive inventory must remain explicit and must not enter '
            'startup, search, settings status, or attachment resolution.',
      );
    },
  );

  test(
    'conversation list reads perform no attachment payload lookup',
    () async {
      final database = await openConversationGraphTestDatabase();
      addTearDown(database.close);
      await database.database.insert('chats', {
        'ss_id': 1,
        'guid': 'chat-1',
        'is_group': 0,
      });
      final lookup = _CountingGraphAttachmentArchiveLookup();
      final repository = SqliteChatSummaryRepository(
        graphDatabase: database,
        archiveLookup: lookup,
      );

      final summaries = await repository.readSummaries();

      expect(summaries, hasLength(1));
      expect(lookup.readCount, 0);
    },
  );

  test('chat hydration does not count unavailable root as missing', () async {
    final database = await openConversationGraphTestDatabase();
    addTearDown(database.close);
    await database.database.insert('chats', {
      'ss_id': 1,
      'guid': 'chat-1',
      'is_group': 0,
    });
    await database.database.insert('messages', {
      'ss_id': 10,
      'guid': 'message-10',
      'is_from_me': 1,
    });
    await database.database.insert('attachments', {
      'ss_id': 20,
      'guid': 'attachment-20',
      'filename': '/source/photo.jpg',
      'mime_type': 'image/jpeg',
    });
    await database.database.insert('chat_to_message', {
      'chat_ss_id': 1,
      'message_ss_id': 10,
    });
    await database.database.insert('message_to_attachment', {
      'message_ss_id': 10,
      'attachment_ss_id': 20,
    });
    final lookup = _CountingGraphAttachmentArchiveLookup(
      record: const GraphAttachmentArchiveRecord(
        archiveRelativePath: 'aa/photo.jpg',
        archiveAbsolutePath: null,
        payloadStatus: AttachmentArchivePayloadStatus.rootUnavailable,
        locationAvailability:
            AttachmentArchiveLocationAvailability.customUnavailable,
        locationGeneration: 5,
        rootIssue: 'Volume disconnected.',
      ),
    );
    final repository = SqliteChatSummaryRepository(
      graphDatabase: database,
      archiveLookup: lookup,
    );

    final stats = await repository.readAttachmentStats(chatSsId: 1);
    final attachments = await repository.readMessageAttachments(
      messageSsId: 10,
    );

    expect(stats.archiveRecordCount, 1);
    expect(stats.archiveFileAvailableCount, 0);
    expect(stats.archiveFileMissingCount, 0);
    expect(stats.archiveFileUnavailableCount, 1);
    expect(attachments.single.archiveAbsolutePath, isNull);
    expect(
      attachments.single.archivePayloadStatus,
      AttachmentArchivePayloadStatus.rootUnavailable,
    );
    expect(attachments.single.archiveLocationGeneration, 5);
  });
}

final class _CountingGraphAttachmentArchiveLookup
    implements GraphAttachmentArchiveLookup {
  _CountingGraphAttachmentArchiveLookup({this.record});

  final GraphAttachmentArchiveRecord? record;
  var readCount = 0;

  @override
  Future<GraphAttachmentArchiveRecord?> readArchiveRecord({
    required int messageSsId,
    required int attachmentSsId,
  }) async {
    readCount += 1;
    return record;
  }
}
