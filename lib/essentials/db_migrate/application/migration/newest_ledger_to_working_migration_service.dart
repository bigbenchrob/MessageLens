import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../db_import/application/debug_settings_provider.dart';
import '../../domain/entities/db_migration_result.dart';
import '../../domain/states/db_migration_progress.dart';
import '../../domain/value_objects/db_migration_stage.dart';

typedef DbMigrationProgressCallback =
    void Function(DbMigrationProgress progress);

/// Projects the most recent ledger batch into the Drift working database by
/// copying rows directly from the import ledger. No re-indexing or
/// recomputation is performed – this service simply mirrors the ledger into the
/// projection schema.
class NewestLedgerToWorkingMigrationService {
  NewestLedgerToWorkingMigrationService({required this.ref});

  final Ref ref;

  static const String _logContext = 'NewestLedgerToWorkingMigrationService';
  static const int _batchChunkSize = 250;

  Future<void> clearWorkingProjection() async {
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
    await _clearWorkingDatabase(workingDb);
  }

  Future<DbMigrationResult> runMigration({
    DbMigrationProgressCallback? onProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledger = await ref.watch(sqfliteImportDatabaseProvider.future);
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

    final importDb = await ledger.database;
    final stats = _MigrationStatsBuilder();
    final warnings = <String>[];

    void emit(DbMigrationStage stage, double overall, String message) {
      onProgress?.call(
        DbMigrationProgress(
          stage: stage,
          overallProgress: overall,
          message: message,
        ),
      );
      debugSettings.logProgress('$_logContext: $message');
    }

    try {
      emit(
        DbMigrationStage.preparingSources,
        0.02,
        'Locating latest ledger batch',
      );
      final batchId = await _fetchLatestBatchId(importDb);
      if (batchId == null) {
        const message = 'Ledger contains no batches to project';
        debugSettings.logError('$_logContext: $message');
        return stats.buildFailure(message);
      }

      emit(
        DbMigrationStage.clearingWorking,
        0.08,
        'Clearing working projections',
      );
      await _clearWorkingDatabase(workingDb);

      emit(DbMigrationStage.migratingIdentities, 0.18, 'Copying handles');
      final handleSummary = await _copyHandles(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
      );
      stats.identitiesProjected = handleSummary.copied;

      emit(DbMigrationStage.migratingIdentities, 0.26, 'Copying participants');
      final participantSummary = await _copyParticipants(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
      );
      stats.participantsProjected = participantSummary.copied;

      emit(DbMigrationStage.migratingIdentities, 0.31, 'Copying handle links');
      final linkCount = await _copyHandleLinks(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        participantIds: participantSummary.participantIds,
      );
      stats.identityHandleLinksProjected = linkCount.copied;
      warnings.addAll(linkCount.warnings);

      emit(DbMigrationStage.migratingChats, 0.40, 'Copying chats');
      final chatSummary = await _copyChats(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
      );
      stats.chatsProjected = chatSummary.copied;

      emit(DbMigrationStage.migratingChats, 0.46, 'Copying chat memberships');
      await _copyChatMemberships(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        chatIgnored: chatSummary.isIgnoredById,
        handleIgnored: handleSummary.isIgnoredById,
      );

      emit(
        DbMigrationStage.migratingMessages,
        0.54,
        'Preparing message metadata',
      );
      final messagesWithAttachments = await _loadMessagesWithAttachments(
        importDb: importDb,
        batchId: batchId,
      );

      emit(DbMigrationStage.migratingMessages, 0.62, 'Copying messages');
      final messageSummary = await _copyMessages(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        messagesWithAttachments: messagesWithAttachments,
        handleExists: handleSummary.isIgnoredById.keys.toSet(),
      );
      stats.messagesProjected = messageSummary.copied;
      warnings.addAll(messageSummary.warnings);

      emit(DbMigrationStage.migratingMessages, 0.68, 'Updating chat summaries');
      await _applyChatSummaries(
        workingDb: workingDb,
        summaries: messageSummary.chatSummaries,
      );

      emit(DbMigrationStage.migratingAttachments, 0.76, 'Copying attachments');
      final attachmentCount = await _copyAttachments(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        messageGuidById: messageSummary.messageGuidById,
      );
      stats.attachmentsProjected = attachmentCount;

      emit(DbMigrationStage.migratingReactions, 0.82, 'Copying reactions');
      final reactionSummary = await _copyReactions(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        messageGuidById: messageSummary.messageGuidById,
      );
      stats.reactionsProjected = reactionSummary.copied;

      emit(
        DbMigrationStage.migratingReactions,
        0.88,
        'Updating reaction counts',
      );
      await _updateReactionCounts(
        workingDb: workingDb,
        tallies: reactionSummary.tallies,
      );

      emit(
        DbMigrationStage.updatingProjectionState,
        0.94,
        'Writing projection state',
      );
      await _updateProjectionState(workingDb: workingDb, batchId: batchId);

      emit(
        DbMigrationStage.completed,
        1.0,
        'Ledger batch $batchId projected successfully',
      );
      return stats.buildSuccess(batchId: batchId, warnings: warnings);
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: Migration failed: $error');
      debugPrint(stackTrace.toString());
      return stats.buildFailure('Migration failed: $error');
    }
  }

  Future<int?> _fetchLatestBatchId(Database importDb) async {
    final rows = await importDb.query(
      'import_batches',
      columns: <String>['id'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['id'] as int?;
  }

  Future<void> _clearWorkingDatabase(WorkingDatabase workingDb) async {
    await workingDb.transaction(() async {
      await workingDb.customStatement('DELETE FROM reaction_counts');
      await workingDb.customStatement('DELETE FROM reactions');
      await workingDb.customStatement('DELETE FROM attachments');
      await workingDb.customStatement('DELETE FROM messages');
      await workingDb.customStatement('DELETE FROM message_read_marks');
      await workingDb.customStatement('DELETE FROM read_state');
      await workingDb.customStatement('DELETE FROM chat_to_handle');
      await workingDb.customStatement('DELETE FROM handle_to_participant');
      await workingDb.customStatement('DELETE FROM participants');
      await workingDb.customStatement('DELETE FROM chats');
      await workingDb.customStatement('DELETE FROM handles');
      await workingDb.customStatement('DELETE FROM projection_state');
      await workingDb.customStatement('DELETE FROM supabase_sync_state');
      await workingDb.customStatement('DELETE FROM supabase_sync_logs');
    });
  }

  Future<_HandleCopySummary> _copyHandles({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'handles',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final isIgnoredById = <int, bool>{};
    var copied = 0;

    await workingDb.batch((batch) {
      for (final row in rows) {
        final id = row['id'] as int?;
        final rawIdentifier = row['raw_identifier'] as String?;
        if (id == null || rawIdentifier == null || rawIdentifier.isEmpty) {
          continue;
        }

        final normalizedIdentifier = row['normalized_identifier'] as String?;
        final service = (row['service'] as String?) ?? 'Unknown';
        final isIgnored = (row['is_ignored'] as int?) == 1;
        final country = row['country'] as String?;
        final lastSeenUtc = row['last_seen_utc'] as String?;
        final batchValue = row['batch_id'] as int?;

        isIgnoredById[id] = isIgnored;
        copied += 1;

        batch.insert(
          workingDb.workingHandles,
          WorkingHandlesCompanion.insert(
            id: Value(id),
            handleId: rawIdentifier,
            normalizedIdentifier: Value(normalizedIdentifier),
            service: Value(service),
            isIgnored: Value(isIgnored),
            isValid: Value(!isIgnored),
            isBlacklisted: Value(isIgnored),
            country: Value(country),
            lastSeenUtc: Value(lastSeenUtc),
            batchId: Value(batchValue),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    return _HandleCopySummary(copied: copied, isIgnoredById: isIgnoredById);
  }

  Future<_ParticipantCopySummary> _copyParticipants({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'contacts',
      where: 'batch_id = ? AND is_ignored = 0',
      whereArgs: <Object>[batchId],
    );

    final participantIds = <int>{};
    var copied = 0;

    await workingDb.batch((batch) {
      for (final row in rows) {
        final zPk = row['Z_PK'] as int?;
        if (zPk == null) {
          continue;
        }

        final displayNameRaw = row['display_name'] as String?;
        var displayName = displayNameRaw?.trim();
        if (displayName == null || displayName.isEmpty) {
          displayName = 'Unknown Contact';
        }

        final shortNameRaw = row['short_name'] as String?;
        var shortName = shortNameRaw?.trim();
        if (shortName == null || shortName.isEmpty) {
          shortName = displayName;
        }

        final firstName = row['first_name'] as String?;
        final lastName = row['last_name'] as String?;
        final organization = row['organization'] as String?;
        final createdAtUtc = row['created_at_utc'] as String?;
        final ledgerRowId = row['id'] as int?;
        final isOrganization =
            organization != null &&
            organization.isNotEmpty &&
            (firstName == null || firstName.isEmpty);

        participantIds.add(zPk);
        copied += 1;

        batch.insert(
          workingDb.workingParticipants,
          WorkingParticipantsCompanion.insert(
            id: Value(zPk),
            originalName: displayName,
            displayName: displayName,
            shortName: shortName,
            givenName: Value(firstName),
            familyName: Value(lastName),
            organization: Value(organization),
            isOrganization: Value(isOrganization),
            createdAtUtc: Value(createdAtUtc),
            sourceRecordId: Value(ledgerRowId),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    return _ParticipantCopySummary(
      copied: copied,
      participantIds: participantIds,
    );
  }

  Future<_HandleLinkCopySummary> _copyHandleLinks({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Set<int> participantIds,
  }) async {
    final rows = await importDb.query(
      'contact_to_chat_handle',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    var copied = 0;
    final warnings = <String>[];

    final entries = <HandleToParticipantCompanion>[];
    for (final row in rows) {
      final participantId = row['contact_Z_PK'] as int?;
      final handleId = row['chat_handle_id'] as int?;
      if (participantId == null || handleId == null) {
        continue;
      }

      if (!participantIds.contains(participantId)) {
        warnings.add('Skipping handle link for ignored contact $participantId');
        continue;
      }

      copied += 1;
      entries.add(
        HandleToParticipantCompanion.insert(
          handleId: handleId,
          participantId: participantId,
          confidence: const Value(1.0),
          source: const Value('addressbook'),
        ),
      );
    }

    if (entries.isNotEmpty) {
      await workingDb.batch((batch) {
        for (final entry in entries) {
          batch.insert(
            workingDb.handleToParticipant,
            entry,
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    }

    return _HandleLinkCopySummary(copied: copied, warnings: warnings);
  }

  Future<_ChatCopySummary> _copyChats({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'chats',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final isIgnoredById = <int, bool>{};
    var copied = 0;

    await workingDb.batch((batch) {
      for (final row in rows) {
        final chatId = row['id'] as int?;
        final guid = row['guid'] as String?;
        if (chatId == null || guid == null || guid.isEmpty) {
          continue;
        }

        final service = row['service'] as String?;
        final isGroup = (row['is_group'] as int?) == 1;
        final createdAtUtc = row['created_at_utc'] as String?;
        final updatedAtUtc = row['updated_at_utc'] as String?;
        final isIgnored = (row['is_ignored'] as int?) == 1;

        isIgnoredById[chatId] = isIgnored;
        copied += 1;

        batch.insert(
          workingDb.workingChats,
          WorkingChatsCompanion.insert(
            id: Value(chatId),
            guid: guid,
            service: Value(service ?? 'Unknown'),
            isGroup: Value(isGroup),
            createdAtUtc: Value(createdAtUtc),
            updatedAtUtc: Value(updatedAtUtc),
            isIgnored: Value(isIgnored),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    return _ChatCopySummary(copied: copied, isIgnoredById: isIgnoredById);
  }

  Future<void> _copyChatMemberships({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, bool> chatIgnored,
    required Map<int, bool> handleIgnored,
  }) async {
    final rows = await importDb.rawQuery(
      'SELECT cth.chat_id AS chat_id, '
      'cth.handle_id AS handle_id, '
      'cth.role AS role, '
      'cth.added_at_utc AS added_at_utc '
      'FROM chat_to_handle cth '
      'JOIN chats c ON c.id = cth.chat_id '
      'WHERE c.batch_id = ?',
      <Object>[batchId],
    );

    final entries = <ChatToHandleCompanion>[];
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final handleId = row['handle_id'] as int?;
      if (chatId == null || handleId == null) {
        continue;
      }

      final role = row['role'] as String?;
      final addedAtUtc = row['added_at_utc'] as String?;
      final chatIsIgnored = chatIgnored[chatId] == true;
      final handleIsIgnored = handleIgnored[handleId] == true;
      final linkIgnored = chatIsIgnored || handleIsIgnored;

      entries.add(
        ChatToHandleCompanion.insert(
          chatId: chatId,
          handleId: handleId,
          role: Value(role ?? 'member'),
          addedAtUtc: Value(addedAtUtc),
          isIgnored: Value(linkIgnored),
        ),
      );
    }

    if (entries.isEmpty) {
      return;
    }

    await workingDb.batch((batch) {
      for (final entry in entries) {
        batch.insert(
          workingDb.chatToHandle,
          entry,
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<Set<int>> _loadMessagesWithAttachments({
    required Database importDb,
    required int batchId,
  }) async {
    final rows = await importDb.rawQuery(
      'SELECT DISTINCT ma.message_id AS message_id '
      'FROM message_attachments ma '
      'JOIN messages m ON m.id = ma.message_id '
      'WHERE m.batch_id = ?',
      <Object>[batchId],
    );

    final messageIds = <int>{};
    for (final row in rows) {
      final messageId = row['message_id'] as int?;
      if (messageId == null) {
        continue;
      }
      messageIds.add(messageId);
    }
    return messageIds;
  }

  Future<_MessageCopySummary> _copyMessages({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Set<int> messagesWithAttachments,
    required Set<int> handleExists,
  }) async {
    final rows = await importDb.query(
      'messages',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
      orderBy: 'id ASC',
    );

    final messageGuidById = <int, String>{};
    final chatSummaries = <int, _ChatSummary>{};
    final warnings = <String>[];
    var copied = 0;

    final entries = <Insertable<WorkingMessage>>[];

    for (final row in rows) {
      final messageId = row['id'] as int?;
      final chatId = row['chat_id'] as int?;
      final guid = row['guid'] as String?;
      if (messageId == null || chatId == null || guid == null || guid.isEmpty) {
        continue;
      }

      messageGuidById[messageId] = guid;

      final senderHandleIdRaw = row['sender_handle_id'] as int?;
      final hasSender =
          senderHandleIdRaw != null && handleExists.contains(senderHandleIdRaw);
      final senderHandleId = hasSender ? senderHandleIdRaw : null;
      if (senderHandleIdRaw != null && !hasSender) {
        warnings.add(
          'Message $messageId references missing handle $senderHandleIdRaw',
        );
      }

      final textContent = row['text'] as String?;
      final sentAtUtc = row['date_utc'] as String?;
      final deliveredAtUtc = row['date_delivered_utc'] as String?;
      final readAtUtc = row['date_read_utc'] as String?;
      final isFromMe = (row['is_from_me'] as int?) == 1;
      final itemType = row['item_type'] as String?;
      final isSystemMessage = (row['is_system_message'] as int?) == 1;
      final errorCode = row['error_code'] as int?;
      final associatedMessageGuid = row['associated_message_guid'] as String?;
      final threadOriginatorGuid = row['thread_originator_guid'] as String?;
      final payloadJson = row['payload_json'] as String?;
      final batchValue = row['batch_id'] as int?;
      final balloonBundleId = row['balloon_bundle_id'] as String?;

      copied += 1;
      entries.add(
        WorkingMessagesCompanion.insert(
          id: Value(messageId),
          chatId: chatId,
          guid: guid,
          senderHandleId: Value(senderHandleId),
          isFromMe: Value(isFromMe),
          sentAtUtc: Value(sentAtUtc),
          deliveredAtUtc: Value(deliveredAtUtc),
          readAtUtc: Value(readAtUtc),
          status: const Value('unknown'),
          textContent: Value(textContent),
          itemType: Value(itemType),
          isSystemMessage: Value(isSystemMessage),
          errorCode: Value(errorCode),
          hasAttachments: Value(messagesWithAttachments.contains(messageId)),
          replyToGuid: Value(associatedMessageGuid),
          associatedMessageGuid: Value(associatedMessageGuid),
          threadOriginatorGuid: Value(threadOriginatorGuid),
          reactionCarrier: Value(itemType == 'reaction-carrier'),
          balloonBundleId: Value(balloonBundleId),
          payloadJson: Value(payloadJson),
          isStarred: const Value(false),
          isDeletedLocal: const Value(false),
          batchId: Value(batchValue),
        ),
      );

      _updateChatSummary(
        summaries: chatSummaries,
        chatId: chatId,
        messageId: messageId,
        senderHandleId: senderHandleId,
        sentAtUtc: sentAtUtc,
        deliveredAtUtc: deliveredAtUtc,
        readAtUtc: readAtUtc,
        preview: textContent,
      );

      if (entries.length >= _batchChunkSize) {
        await _insertMessagesBatch(workingDb, entries);
        entries.clear();
      }
    }

    if (entries.isNotEmpty) {
      await _insertMessagesBatch(workingDb, entries);
      entries.clear();
    }

    return _MessageCopySummary(
      copied: copied,
      messageGuidById: messageGuidById,
      chatSummaries: chatSummaries,
      warnings: warnings,
    );
  }

  Future<void> _insertMessagesBatch(
    WorkingDatabase workingDb,
    List<Insertable<WorkingMessage>> items,
  ) async {
    await workingDb.batch((batch) {
      for (final item in items) {
        batch.insert(
          workingDb.workingMessages,
          item,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  void _updateChatSummary({
    required Map<int, _ChatSummary> summaries,
    required int chatId,
    required int messageId,
    required int? senderHandleId,
    required String? sentAtUtc,
    required String? deliveredAtUtc,
    required String? readAtUtc,
    required String? preview,
  }) {
    final existing = summaries[chatId];
    final candidate = _ChatSummaryCandidate(
      messageId: messageId,
      senderHandleId: senderHandleId,
      sentAtUtc: sentAtUtc,
      deliveredAtUtc: deliveredAtUtc,
      readAtUtc: readAtUtc,
      preview: preview,
    );

    if (existing == null) {
      summaries[chatId] = _ChatSummary.fromCandidate(candidate);
      return;
    }

    if (candidate.isMoreRecentThan(existing)) {
      summaries[chatId] = _ChatSummary.fromCandidate(candidate);
    }
  }

  Future<void> _applyChatSummaries({
    required WorkingDatabase workingDb,
    required Map<int, _ChatSummary> summaries,
  }) async {
    if (summaries.isEmpty) {
      return;
    }

    await workingDb.batch((batch) {
      summaries.forEach((chatId, summary) {
        batch.update(
          workingDb.workingChats,
          WorkingChatsCompanion(
            lastMessageAtUtc: Value(summary.lastMessageAtUtc),
            lastSenderHandleId: Value(summary.lastSenderHandleId),
            lastMessagePreview: Value(summary.preview),
          ),
          where: (tbl) => tbl.id.equals(chatId),
        );
      });
    });
  }

  Future<int> _copyAttachments({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, String> messageGuidById,
  }) async {
    final rows = await importDb.rawQuery(
      'SELECT ma.message_id AS message_id, '
      'a.id AS attachment_id, '
      'a.local_path AS local_path, '
      'a.mime_type AS mime_type, '
      'a.uti AS uti, '
      'a.transfer_name AS transfer_name, '
      'a.total_bytes AS total_bytes, '
      'a.is_sticker AS is_sticker, '
      'a.is_outgoing AS is_outgoing, '
      'a.created_at_utc AS created_at_utc, '
      'a.sha256_hex AS sha256_hex, '
      'a.batch_id AS batch_id '
      'FROM message_attachments ma '
      'JOIN attachments a ON a.id = ma.attachment_id '
      'JOIN messages m ON m.id = ma.message_id '
      'WHERE m.batch_id = ?',
      <Object>[batchId],
    );

    var copied = 0;
    final entries = <Insertable<WorkingAttachment>>[];

    for (final row in rows) {
      final messageId = row['message_id'] as int?;
      final attachmentId = row['attachment_id'] as int?;
      if (messageId == null || attachmentId == null) {
        continue;
      }

      final messageGuid = messageGuidById[messageId];
      if (messageGuid == null) {
        continue;
      }

      final localPath = row['local_path'] as String?;
      final mimeType = row['mime_type'] as String?;
      final uti = row['uti'] as String?;
      final transferName = row['transfer_name'] as String?;
      final totalBytes = row['total_bytes'] as int?;
      final isSticker = (row['is_sticker'] as int?) == 1;
      final isOutgoingValue = row['is_outgoing'] as int?;
      final createdAtUtc = row['created_at_utc'] as String?;
      final sha256Hex = row['sha256_hex'] as String?;
      final batchValue = row['batch_id'] as int?;
      final isOutgoing = isOutgoingValue == null ? null : isOutgoingValue == 1;

      copied += 1;
      var companion = WorkingAttachmentsCompanion.insert(
        messageGuid: messageGuid,
        importAttachmentId: Value(attachmentId),
        localPath: Value(localPath),
        mimeType: Value(mimeType),
        uti: Value(uti),
        transferName: Value(transferName),
        sizeBytes: Value(totalBytes),
        isSticker: Value(isSticker),
        createdAtUtc: Value(createdAtUtc),
        sha256Hex: Value(sha256Hex),
        batchId: Value(batchValue),
      );
      if (isOutgoing != null) {
        companion = companion.copyWith(isOutgoing: Value(isOutgoing));
      }
      entries.add(companion);

      if (entries.length >= _batchChunkSize) {
        await _insertAttachmentsBatch(workingDb, entries);
        entries.clear();
      }
    }

    if (entries.isNotEmpty) {
      await _insertAttachmentsBatch(workingDb, entries);
      entries.clear();
    }

    return copied;
  }

  Future<void> _insertAttachmentsBatch(
    WorkingDatabase workingDb,
    List<Insertable<WorkingAttachment>> items,
  ) async {
    await workingDb.batch((batch) {
      for (final item in items) {
        batch.insert(
          workingDb.workingAttachments,
          item,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<_ReactionCopySummary> _copyReactions({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, String> messageGuidById,
  }) async {
    final rows = await importDb.rawQuery(
      'SELECT r.id AS id, '
      'r.carrier_message_id AS carrier_message_id, '
      'r.target_message_guid AS target_message_guid, '
      'r.action AS action, '
      'r.kind AS kind, '
      'r.reactor_handle_id AS reactor_handle_id, '
      'r.reacted_at_utc AS reacted_at_utc, '
      'r.parse_confidence AS parse_confidence '
      'FROM reactions r '
      'JOIN messages carrier ON carrier.id = r.carrier_message_id '
      'WHERE carrier.batch_id = ?',
      <Object>[batchId],
    );

    var copied = 0;
    final tallies = <String, _ReactionTally>{};

    final entries = <Insertable<WorkingReaction>>[];
    for (final row in rows) {
      final reactionId = row['id'] as int?;
      final carrierId = row['carrier_message_id'] as int?;
      final targetGuid = row['target_message_guid'] as String?;
      final action = row['action'] as String?;
      final kind = row['kind'] as String?;
      if (reactionId == null ||
          carrierId == null ||
          targetGuid == null ||
          action == null ||
          kind == null) {
        continue;
      }

      final carrierGuid = messageGuidById[carrierId];
      if (carrierGuid == null) {
        continue;
      }

      final reactorHandleId = row['reactor_handle_id'] as int?;
      final reactedAtUtc = row['reacted_at_utc'] as String?;
      final parseConfidence =
          (row['parse_confidence'] as num?)?.toDouble() ?? 1.0;

      copied += 1;
      entries.add(
        WorkingReactionsCompanion.insert(
          id: Value(reactionId),
          messageGuid: carrierGuid,
          kind: kind,
          reactorHandleId: Value(reactorHandleId),
          action: action,
          reactedAtUtc: Value(reactedAtUtc),
          carrierMessageId: Value(carrierId),
          targetMessageGuid: Value(targetGuid),
          parseConfidence: Value(parseConfidence),
        ),
      );

      if (action == 'add') {
        tallies.putIfAbsent(targetGuid, _ReactionTally.new).increment(kind);
      } else if (action == 'remove') {
        tallies.putIfAbsent(targetGuid, _ReactionTally.new).decrement(kind);
      }

      if (entries.length >= _batchChunkSize) {
        await _insertReactionsBatch(workingDb, entries);
        entries.clear();
      }
    }

    if (entries.isNotEmpty) {
      await _insertReactionsBatch(workingDb, entries);
      entries.clear();
    }

    return _ReactionCopySummary(copied: copied, tallies: tallies);
  }

  Future<void> _insertReactionsBatch(
    WorkingDatabase workingDb,
    List<Insertable<WorkingReaction>> items,
  ) async {
    await workingDb.batch((batch) {
      for (final item in items) {
        batch.insert(
          workingDb.workingReactions,
          item,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _updateReactionCounts({
    required WorkingDatabase workingDb,
    required Map<String, _ReactionTally> tallies,
  }) async {
    await workingDb.batch((batch) {
      batch.deleteWhere(
        workingDb.reactionCounts,
        (tbl) => const Constant(true),
      );
      tallies.forEach((messageGuid, tally) {
        batch.insert(
          workingDb.reactionCounts,
          ReactionCountsCompanion.insert(
            messageGuid: messageGuid,
            love: Value(tally.love),
            like: Value(tally.like),
            dislike: Value(tally.dislike),
            laugh: Value(tally.laugh),
            emphasize: Value(tally.emphasize),
            question: Value(tally.question),
          ),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> _updateProjectionState({
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    await workingDb
        .into(workingDb.projectionState)
        .insert(
          ProjectionStateCompanion.insert(
            id: const Value(1),
            lastImportBatchId: Value(batchId),
            lastProjectedAtUtc: Value(DateTime.now().toUtc().toIso8601String()),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}

class _MigrationStatsBuilder {
  int identitiesProjected = 0;
  int identityHandleLinksProjected = 0;
  int chatsProjected = 0;
  int participantsProjected = 0;
  int messagesProjected = 0;
  int attachmentsProjected = 0;
  int reactionsProjected = 0;

  DbMigrationResult buildFailure(String error) {
    return DbMigrationResult(
      batchId: 0,
      success: false,
      error: error,
      identitiesProjected: identitiesProjected,
      identityHandleLinksProjected: identityHandleLinksProjected,
      chatsProjected: chatsProjected,
      participantsProjected: participantsProjected,
      messagesProjected: messagesProjected,
      attachmentsProjected: attachmentsProjected,
      reactionsProjected: reactionsProjected,
    );
  }

  DbMigrationResult buildSuccess({
    required int batchId,
    required List<String> warnings,
  }) {
    return DbMigrationResult(
      batchId: batchId,
      success: true,
      identitiesProjected: identitiesProjected,
      identityHandleLinksProjected: identityHandleLinksProjected,
      chatsProjected: chatsProjected,
      participantsProjected: participantsProjected,
      messagesProjected: messagesProjected,
      attachmentsProjected: attachmentsProjected,
      reactionsProjected: reactionsProjected,
      warnings: warnings,
    );
  }
}

class _HandleCopySummary {
  const _HandleCopySummary({required this.copied, required this.isIgnoredById});

  final int copied;
  final Map<int, bool> isIgnoredById;
}

class _ParticipantCopySummary {
  const _ParticipantCopySummary({
    required this.copied,
    required this.participantIds,
  });

  final int copied;
  final Set<int> participantIds;
}

class _HandleLinkCopySummary {
  const _HandleLinkCopySummary({required this.copied, required this.warnings});

  final int copied;
  final List<String> warnings;
}

class _ChatCopySummary {
  const _ChatCopySummary({required this.copied, required this.isIgnoredById});

  final int copied;
  final Map<int, bool> isIgnoredById;
}

class _MessageCopySummary {
  const _MessageCopySummary({
    required this.copied,
    required this.messageGuidById,
    required this.chatSummaries,
    required this.warnings,
  });

  final int copied;
  final Map<int, String> messageGuidById;
  final Map<int, _ChatSummary> chatSummaries;
  final List<String> warnings;
}

class _ReactionCopySummary {
  const _ReactionCopySummary({required this.copied, required this.tallies});

  final int copied;
  final Map<String, _ReactionTally> tallies;
}

class _ChatSummary {
  _ChatSummary({
    required this.lastMessageAtUtc,
    required this.lastMessageEpoch,
    required this.messageId,
    required this.lastSenderHandleId,
    required this.preview,
  });

  final String? lastMessageAtUtc;
  final int lastMessageEpoch;
  final int messageId;
  final int? lastSenderHandleId;
  final String? preview;

  factory _ChatSummary.fromCandidate(_ChatSummaryCandidate candidate) {
    return _ChatSummary(
      lastMessageAtUtc: candidate.resolvedTimestampUtc,
      lastMessageEpoch: candidate.resolvedEpoch,
      messageId: candidate.messageId,
      lastSenderHandleId: candidate.senderHandleId,
      preview: _buildPreview(candidate.preview),
    );
  }

  static String? _buildPreview(String? text) {
    if (text == null) {
      return null;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length <= 160) {
      return trimmed;
    }
    return '${trimmed.substring(0, 157)}…';
  }
}

class _ChatSummaryCandidate {
  const _ChatSummaryCandidate({
    required this.messageId,
    required this.senderHandleId,
    required this.sentAtUtc,
    required this.deliveredAtUtc,
    required this.readAtUtc,
    required this.preview,
  });

  final int messageId;
  final int? senderHandleId;
  final String? sentAtUtc;
  final String? deliveredAtUtc;
  final String? readAtUtc;
  final String? preview;

  String? get resolvedTimestampUtc {
    if (sentAtUtc != null && sentAtUtc!.isNotEmpty) {
      return sentAtUtc;
    }
    if (deliveredAtUtc != null && deliveredAtUtc!.isNotEmpty) {
      return deliveredAtUtc;
    }
    if (readAtUtc != null && readAtUtc!.isNotEmpty) {
      return readAtUtc;
    }
    return null;
  }

  int get resolvedEpoch {
    final timestamp = resolvedTimestampUtc;
    if (timestamp != null) {
      final parsed = DateTime.tryParse(timestamp);
      if (parsed != null) {
        return parsed.millisecondsSinceEpoch;
      }
    }
    return messageId;
  }

  bool isMoreRecentThan(_ChatSummary other) {
    if (resolvedEpoch > other.lastMessageEpoch) {
      return true;
    }
    if (resolvedEpoch < other.lastMessageEpoch) {
      return false;
    }
    return messageId > other.messageId;
  }
}

class _ReactionTally {
  _ReactionTally()
    : love = 0,
      like = 0,
      dislike = 0,
      laugh = 0,
      emphasize = 0,
      question = 0;

  int love;
  int like;
  int dislike;
  int laugh;
  int emphasize;
  int question;

  void increment(String kind) {
    _delta(kind, 1);
  }

  void decrement(String kind) {
    _delta(kind, -1);
  }

  void _delta(String kind, int change) {
    switch (kind) {
      case 'love':
        love = _clamp(love + change);
        break;
      case 'like':
        like = _clamp(like + change);
        break;
      case 'dislike':
        dislike = _clamp(dislike + change);
        break;
      case 'laugh':
        laugh = _clamp(laugh + change);
        break;
      case 'emphasize':
        emphasize = _clamp(emphasize + change);
        break;
      case 'question':
        question = _clamp(question + change);
        break;
      default:
        break;
    }
  }

  int _clamp(int value) {
    if (value < 0) {
      return 0;
    }
    return value;
  }
}
