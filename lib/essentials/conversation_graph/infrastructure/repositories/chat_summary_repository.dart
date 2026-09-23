import 'dart:io';

import '../../../../features/attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocationAvailability,
        AttachmentArchivePayloadStatus,
        GraphAttachmentArchiveLookup;
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../application/chat_summaries/chat_summary.dart';
import '../../application/chat_summaries/chat_summary_repository.dart';

class SqliteChatSummaryRepository implements ChatSummaryRepository {
  const SqliteChatSummaryRepository({
    required this.graphDatabase,
    this.archiveLookup,
  });

  final ConversationGraphDatabase graphDatabase;
  final GraphAttachmentArchiveLookup? archiveLookup;

  @override
  Future<List<ChatSummary>> readSummaries({
    ChatSummaryFilter filter = ChatSummaryFilter.all,
    ChatSummarySort sort = ChatSummarySort.mostRecentMessage,
    int? limit = 50,
  }) async {
    final rows = await graphDatabase.selectRows('''
      SELECT
        c.ss_id AS chat_ss_id,
        COUNT(DISTINCT COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id))
          AS participant_count,
        COUNT(DISTINCT ctm.message_ss_id) AS message_count,
        MAX(m.date_utc) AS last_message_at_utc,
        (
          SELECT m2.text
          FROM chat_to_message ctm2
          JOIN messages m2 ON m2.ss_id = ctm2.message_ss_id
          WHERE ctm2.chat_ss_id = c.ss_id
            AND m2.text IS NOT NULL
          ORDER BY m2.date_utc DESC, m2.ss_id DESC
          LIMIT 1
        ) AS last_message_text
      FROM chats c
      LEFT JOIN chat_to_handle cth ON cth.chat_ss_id = c.ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      LEFT JOIN chat_to_message ctm ON ctm.chat_ss_id = c.ss_id
      LEFT JOIN messages m ON m.ss_id = ctm.message_ss_id
      GROUP BY c.ss_id
      ORDER BY COALESCE(last_message_at_utc, '') DESC, c.ss_id ASC
      ''');

    final summaries = <ChatSummary>[];
    for (final row in rows) {
      final chatSsId = _readInt(row['chat_ss_id']);
      final participantHandles = await _readParticipantHandles(chatSsId);
      final participantCount = _readInt(row['participant_count']);
      summaries.add(
        ChatSummary(
          chatSsId: chatSsId,
          participantHandles: participantHandles,
          participantCount: participantCount,
          isGroup: participantCount > 1,
          messageCount: _readInt(row['message_count']),
          lastMessageAtUtc: row['last_message_at_utc'] as String?,
          lastMessageText: row['last_message_text'] as String?,
        ),
      );
    }

    final filtered = _applyFilter(summaries, filter);
    _applySort(filtered, sort);
    return (limit == null ? filtered : filtered.take(limit)).toList(
      growable: false,
    );
  }

  @override
  Future<ChatSummarySanityCounts> readSanityCounts() async {
    final summaries = await readSummaries(limit: null);
    var groupChatCount = 0;
    var singleParticipantChatCount = 0;
    var orphanChatCount = 0;
    var zeroHandleChatCount = 0;
    var zeroMessageChatCount = 0;
    var largestParticipantCount = 0;
    var largestMessageCount = 0;

    for (final summary in summaries) {
      if (summary.isGroup) {
        groupChatCount += 1;
      }
      if (summary.participantCount == 1) {
        singleParticipantChatCount += 1;
      }
      if (summary.participantCount == 0 && summary.messageCount == 0) {
        orphanChatCount += 1;
      }
      if (summary.participantCount == 0) {
        zeroHandleChatCount += 1;
      }
      if (summary.messageCount == 0) {
        zeroMessageChatCount += 1;
      }
      if (summary.participantCount > largestParticipantCount) {
        largestParticipantCount = summary.participantCount;
      }
      if (summary.messageCount > largestMessageCount) {
        largestMessageCount = summary.messageCount;
      }
    }

    return ChatSummarySanityCounts(
      groupChatCount: groupChatCount,
      singleParticipantChatCount: singleParticipantChatCount,
      orphanChatCount: orphanChatCount,
      zeroHandleChatCount: zeroHandleChatCount,
      zeroMessageChatCount: zeroMessageChatCount,
      largestParticipantCount: largestParticipantCount,
      largestMessageCount: largestMessageCount,
    );
  }

  @override
  Future<List<RecentChatMessage>> readRecentMessages({
    required int chatSsId,
    int limit = 20,
  }) async {
    final rows = await graphDatabase.selectRows(
      '''
      SELECT
        m.ss_id AS message_ss_id,
        m.date_utc,
        m.is_from_me,
        m.text,
        (
          SELECT COUNT(*)
          FROM message_to_attachment mta
          WHERE mta.message_ss_id = m.ss_id
        ) AS attachment_count
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE ctm.chat_ss_id = ?
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[chatSsId, limit],
    );

    return [
      for (final row in rows)
        RecentChatMessage(
          messageSsId: _readInt(row['message_ss_id']),
          dateUtc: row['date_utc'] as String?,
          isFromMe: _readInt(row['is_from_me']) == 1,
          text: row['text'] as String?,
          attachmentCount: _readInt(row['attachment_count']),
        ),
    ];
  }

  @override
  Future<List<RecentChatMessage>> readRecentTextMessages({
    required int chatSsId,
    int limit = 20,
  }) async {
    final rows = await graphDatabase.selectRows(
      '''
      SELECT
        m.ss_id AS message_ss_id,
        m.date_utc,
        m.is_from_me,
        m.text,
        (
          SELECT COUNT(*)
          FROM message_to_attachment mta
          WHERE mta.message_ss_id = m.ss_id
        ) AS attachment_count
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE ctm.chat_ss_id = ?
        AND m.text IS NOT NULL
        AND m.text != ''
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[chatSsId, limit],
    );

    return [
      for (final row in rows)
        RecentChatMessage(
          messageSsId: _readInt(row['message_ss_id']),
          dateUtc: row['date_utc'] as String?,
          isFromMe: _readInt(row['is_from_me']) == 1,
          text: row['text'] as String?,
          attachmentCount: _readInt(row['attachment_count']),
        ),
    ];
  }

  @override
  Future<ChatMessageTextStats> readMessageTextStats({
    required int chatSsId,
  }) async {
    final rows = await graphDatabase.selectRows(
      '''
      SELECT
        COUNT(*) AS total_message_count,
        SUM(CASE WHEN m.text IS NOT NULL AND m.text != '' THEN 1 ELSE 0 END)
          AS text_message_count
      FROM chat_to_message ctm
      JOIN messages m ON m.ss_id = ctm.message_ss_id
      WHERE ctm.chat_ss_id = ?
      ''',
      <Object?>[chatSsId],
    );
    final row = rows.single;
    final totalMessageCount = _readInt(row['total_message_count']);
    final textMessageCount = _readInt(row['text_message_count']);
    return ChatMessageTextStats(
      totalMessageCount: totalMessageCount,
      textMessageCount: textMessageCount,
      noTextMessageCount: totalMessageCount - textMessageCount,
    );
  }

  @override
  Future<ChatAttachmentStats> readAttachmentStats({
    required int chatSsId,
  }) async {
    final rows = await graphDatabase.selectRows(
      '''
      SELECT
        a.ss_id AS attachment_ss_id,
        m.guid AS message_guid,
        mta.message_ss_id,
        a.filename,
        a.mime_type,
        a.uti
      FROM chat_to_message ctm
      JOIN message_to_attachment mta ON mta.message_ss_id = ctm.message_ss_id
      JOIN messages m ON m.ss_id = mta.message_ss_id
      JOIN attachments a ON a.ss_id = mta.attachment_ss_id
      WHERE ctm.chat_ss_id = ?
      ''',
      <Object?>[chatSsId],
    );

    final messageIds = <int>{};
    var imageAttachmentCount = 0;
    var videoAttachmentCount = 0;
    var documentAttachmentCount = 0;
    var sourcePathHintCount = 0;
    var localFileAvailableCount = 0;
    var localFileMissingCount = 0;
    var archiveRecordCount = 0;
    var archiveFileAvailableCount = 0;
    var archiveFileMissingCount = 0;
    var archiveFileUnavailableCount = 0;
    var archiveUnexpectedTypeCount = 0;

    for (final row in rows) {
      messageIds.add(_readInt(row['message_ss_id']));
      final typeText = '${row['mime_type'] ?? ''} ${row['uti'] ?? ''}'
          .toLowerCase();
      if (typeText.contains('image') || typeText.startsWith('image/')) {
        imageAttachmentCount += 1;
      }
      if (typeText.contains('video') || typeText.contains('movie')) {
        videoAttachmentCount += 1;
      }
      if (typeText.contains('application/') ||
          typeText.contains('pdf') ||
          typeText.contains('text')) {
        documentAttachmentCount += 1;
      }

      final filename = row['filename'];
      if (filename is String && filename.isNotEmpty) {
        sourcePathHintCount += 1;
        if (_localFileExists(filename)) {
          localFileAvailableCount += 1;
        } else {
          localFileMissingCount += 1;
        }
      }

      final archiveAvailability = await _readArchiveAvailability(
        messageSsId: _readInt(row['message_ss_id']),
        attachmentSsId: _readInt(row['attachment_ss_id']),
      );
      if (archiveAvailability.hasArchiveRecord) {
        archiveRecordCount += 1;
        switch (archiveAvailability.archivePayloadStatus) {
          case AttachmentArchivePayloadStatus.available:
            archiveFileAvailableCount += 1;
          case AttachmentArchivePayloadStatus.missing:
            archiveFileMissingCount += 1;
          case AttachmentArchivePayloadStatus.rootUnavailable:
            archiveFileUnavailableCount += 1;
          case AttachmentArchivePayloadStatus.unexpectedFileType:
          case AttachmentArchivePayloadStatus.invalidMetadataPath:
          case AttachmentArchivePayloadStatus.verifiedCorrupt:
            archiveUnexpectedTypeCount += 1;
          case null:
            break;
        }
      }
    }

    return ChatAttachmentStats(
      messageWithAttachmentCount: messageIds.length,
      attachmentCount: rows.length,
      imageAttachmentCount: imageAttachmentCount,
      videoAttachmentCount: videoAttachmentCount,
      documentAttachmentCount: documentAttachmentCount,
      sourcePathHintCount: sourcePathHintCount,
      localFileAvailableCount: localFileAvailableCount,
      localFileMissingCount: localFileMissingCount,
      archiveRecordCount: archiveRecordCount,
      archiveFileAvailableCount: archiveFileAvailableCount,
      archiveFileMissingCount: archiveFileMissingCount,
      archiveFileUnavailableCount: archiveFileUnavailableCount,
      archiveUnexpectedTypeCount: archiveUnexpectedTypeCount,
    );
  }

  @override
  Future<List<MessageAttachment>> readMessageAttachments({
    required int messageSsId,
  }) async {
    final rows = await graphDatabase.selectRows(
      '''
      SELECT
        a.ss_id AS attachment_ss_id,
        mta.message_ss_id,
        m.guid AS message_guid,
        a.guid,
        a.filename,
        a.transfer_name,
        a.uti,
        a.mime_type,
        a.total_bytes,
        a.created_at_utc
      FROM message_to_attachment mta
      JOIN messages m ON m.ss_id = mta.message_ss_id
      JOIN attachments a ON a.ss_id = mta.attachment_ss_id
      WHERE mta.message_ss_id = ?
      ORDER BY a.ss_id ASC
      ''',
      <Object?>[messageSsId],
    );

    return [for (final row in rows) await _attachmentFromRow(row)];
  }

  Future<MessageAttachment> _attachmentFromRow(Map<String, Object?> row) async {
    final attachmentSsId = _readInt(row['attachment_ss_id']);
    final messageSsId = _readInt(row['message_ss_id']);
    final archiveAvailability = await _readArchiveAvailability(
      messageSsId: messageSsId,
      attachmentSsId: attachmentSsId,
    );
    return MessageAttachment(
      attachmentSsId: attachmentSsId,
      guid: row['guid'] as String?,
      filename: row['filename'] as String?,
      transferName: row['transfer_name'] as String?,
      uti: row['uti'] as String?,
      mimeType: row['mime_type'] as String?,
      totalBytes: _readNullableInt(row['total_bytes']),
      createdAtUtc: row['created_at_utc'] as String?,
      localFileExists: _localFileExists(row['filename'] as String?),
      archiveRelativePath: archiveAvailability.archiveRelativePath,
      archiveAbsolutePath: archiveAvailability.archiveAbsolutePath,
      archivePayloadStatus: archiveAvailability.archivePayloadStatus,
      archiveLocationAvailability:
          archiveAvailability.archiveLocationAvailability,
      archiveLocationGeneration: archiveAvailability.archiveLocationGeneration,
      archiveRootIssue: archiveAvailability.archiveRootIssue,
    );
  }

  Future<_ArchiveAvailability> _readArchiveAvailability({
    required int messageSsId,
    required int attachmentSsId,
  }) async {
    final lookup = archiveLookup;
    if (lookup == null) {
      return const _ArchiveAvailability.none();
    }

    final record = await lookup.readArchiveRecord(
      messageSsId: messageSsId,
      attachmentSsId: attachmentSsId,
    );
    if (record == null) {
      return const _ArchiveAvailability.none();
    }

    return _ArchiveAvailability(
      archiveRelativePath: record.archiveRelativePath,
      archiveAbsolutePath: record.archiveAbsolutePath,
      archivePayloadStatus: record.payloadStatus,
      archiveLocationAvailability: record.locationAvailability,
      archiveLocationGeneration: record.locationGeneration,
      archiveRootIssue: record.rootIssue,
    );
  }

  Future<List<String>> _readParticipantHandles(int chatSsId) async {
    final rows = await graphDatabase.selectRows(
      '''
      SELECT DISTINCT
        COALESCE(ch.display_handle, h.id) AS handle_id,
        COALESCE(ha.canonical_handle_ss_id, h.ss_id) AS sort_id
      FROM chat_to_handle cth
      JOIN handles h ON h.ss_id = cth.handle_ss_id
      LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
      LEFT JOIN canonical_handles ch
        ON ch.canonical_handle_ss_id = ha.canonical_handle_ss_id
      WHERE cth.chat_ss_id = ?
      ORDER BY sort_id ASC, handle_id ASC
      ''',
      <Object?>[chatSsId],
    );

    return [
      for (final row in rows)
        if (row['handle_id'] case final String handle) handle,
    ];
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return 0;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return _readInt(value);
  }

  static bool _localFileExists(String? pathHint) {
    if (pathHint == null || pathHint.isEmpty) {
      return false;
    }
    final path = _expandHome(pathHint);
    return File(path).existsSync();
  }

  static String _expandHome(String path) {
    if (!path.startsWith('~/')) {
      return path;
    }
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return path;
    }
    return '$home/${path.substring(2)}';
  }

  static List<ChatSummary> _applyFilter(
    List<ChatSummary> summaries,
    ChatSummaryFilter filter,
  ) {
    return switch (filter) {
      ChatSummaryFilter.all => summaries,
      ChatSummaryFilter.groupOnly =>
        summaries.where((summary) => summary.isGroup).toList(growable: false),
      ChatSummaryFilter.singleParticipantOnly =>
        summaries
            .where((summary) => summary.participantCount == 1)
            .toList(growable: false),
    };
  }

  static void _applySort(List<ChatSummary> summaries, ChatSummarySort sort) {
    summaries.sort((left, right) {
      final comparison = switch (sort) {
        ChatSummarySort.mostRecentMessage => _compareNullableTextDescending(
          left.lastMessageAtUtc,
          right.lastMessageAtUtc,
        ),
        ChatSummarySort.largestMessageCount => right.messageCount.compareTo(
          left.messageCount,
        ),
        ChatSummarySort.largestParticipantCount =>
          right.participantCount.compareTo(left.participantCount),
      };
      if (comparison != 0) {
        return comparison;
      }
      return left.chatSsId.compareTo(right.chatSsId);
    });
  }

  static int _compareNullableTextDescending(String? left, String? right) {
    final leftValue = left ?? '';
    final rightValue = right ?? '';
    return rightValue.compareTo(leftValue);
  }
}

class _ArchiveAvailability {
  const _ArchiveAvailability({
    required this.archiveRelativePath,
    required this.archiveAbsolutePath,
    required this.archivePayloadStatus,
    required this.archiveLocationAvailability,
    required this.archiveLocationGeneration,
    required this.archiveRootIssue,
  });

  const _ArchiveAvailability.none()
    : archiveRelativePath = null,
      archiveAbsolutePath = null,
      archivePayloadStatus = null,
      archiveLocationAvailability = null,
      archiveLocationGeneration = null,
      archiveRootIssue = null;

  final String? archiveRelativePath;
  final String? archiveAbsolutePath;
  final AttachmentArchivePayloadStatus? archivePayloadStatus;
  final AttachmentArchiveLocationAvailability? archiveLocationAvailability;
  final int? archiveLocationGeneration;
  final String? archiveRootIssue;

  bool get hasArchiveRecord =>
      archiveRelativePath != null && archiveRelativePath!.isNotEmpty;
}
