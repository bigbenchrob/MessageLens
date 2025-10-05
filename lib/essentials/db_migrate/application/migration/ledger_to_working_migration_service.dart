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
import '../application_providers/supabase_mirror_sync_service_provider.dart';

typedef DbMigrationProgressCallback =
    void Function(DbMigrationProgress progress);

typedef _StageProgressEmitter =
    void Function({
      required String label,
      required int processed,
      required int total,
    });

class _LedgerMaxIds {
  const _LedgerMaxIds({required this.messageId, required this.attachmentId});

  final int? messageId;
  final int? attachmentId;
}

/// Orchestrates the projection of data from the Sqflite ledger database into
/// the Drift-powered working database used by the UI layer.
class LedgerToWorkingMigrationService {
  LedgerToWorkingMigrationService({required this.ref});

  final Ref ref;

  static const String _logContext = 'LedgerToWorkingMigrationService';

  Future<DbMigrationResult> runMigration({
    DbMigrationProgressCallback? onProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledger = await ref.watch(sqfliteImportDatabaseProvider.future);
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

    final importDb = await ledger.database;
    var activeBatchId = -1;
    final resultBuilder = _DbMigrationResultBuilder(batchId: activeBatchId);

    void emit(
      DbMigrationStage stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    }) {
      onProgress?.call(
        DbMigrationProgress(
          stage: stage,
          overallProgress: progress,
          message: message,
          stageProgress: stageProgress,
          stageCurrent: stageCurrent,
          stageTotal: stageTotal,
        ),
      );
      debugSettings.logProgress('$_logContext: $message');
    }

    try {
      emit(
        DbMigrationStage.preparingSources,
        0.02,
        'Locating latest import batch',
      );

      final batchId = await _fetchLatestBatchId(importDb);
      if (batchId == null) {
        const message = 'Ledger contains no import batches to project';
        debugSettings.logError('$_logContext: $message');
        return resultBuilder
            .copyWith(batchId: -1, error: message)
            .build(success: false);
      }

      activeBatchId = batchId;
      resultBuilder.batchId = batchId;

      emit(
        DbMigrationStage.preparingSources,
        0.06,
        'Aligning ledger batches with import batch $batchId',
      );
      await ledger.assignExistingRecordsToBatch(batchId: batchId);

      final projectionState = await workingDb.projectionState
          .select()
          .getSingleOrNull();
      final previousProjectedMessageId =
          projectionState?.lastProjectedMessageId;
      final previousProjectedAttachmentId =
          projectionState?.lastProjectedAttachmentId;
      var shouldResetWorking = false;
      if (previousProjectedMessageId != null ||
          previousProjectedAttachmentId != null) {
        emit(
          DbMigrationStage.preparingSources,
          0.07,
          'Validating ledger continuity against working projection',
        );
        final ledgerMaxIds = await _fetchLedgerMaxIds(
          importDb: importDb,
          batchId: batchId,
        );
        final ledgerMessageId = ledgerMaxIds.messageId ?? -1;
        final ledgerAttachmentId = ledgerMaxIds.attachmentId ?? -1;
        final workingMessageId = previousProjectedMessageId ?? -1;
        final workingAttachmentId = previousProjectedAttachmentId ?? -1;
        if (ledgerMessageId < workingMessageId ||
            ledgerAttachmentId < workingAttachmentId) {
          shouldResetWorking = true;
          debugSettings.logProgress(
            '$_logContext: Detected ledger reset (ledger max: $ledgerMessageId/$ledgerAttachmentId, '
            'working last: $workingMessageId/$workingAttachmentId). Resetting working projection.',
          );
        }
      }

      if (shouldResetWorking) {
        emit(
          DbMigrationStage.clearingWorking,
          0.08,
          'Clearing existing working projections',
        );
        await _clearWorkingDatabase(workingDb: workingDb);
      } else {
        emit(
          DbMigrationStage.clearingWorking,
          0.08,
          'Retaining working projection for incremental update',
        );
      }

      final minMessageIdExclusive = shouldResetWorking
          ? null
          : previousProjectedMessageId;
      final minAttachmentIdExclusive = shouldResetWorking
          ? null
          : previousProjectedAttachmentId;

      emit(
        DbMigrationStage.loadingContacts,
        0.12,
        'Loading contact metadata from ledger batch $batchId',
      );
      final contactIndex = await _loadContacts(
        importDb: importDb,
        batchId: batchId,
      );

      emit(
        DbMigrationStage.migratingIdentities,
        0.25,
        'Projecting participants and handle links',
      );
      final participantProjection = await _projectParticipants(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        contactIndex: contactIndex,
      );
      resultBuilder.identitiesProjected =
          participantProjection.participantCount;
      resultBuilder.identityHandleLinksProjected =
          participantProjection.handleLinkCount;

      emit(
        DbMigrationStage.migratingChats,
        0.45,
        'Projecting chats and participants',
      );
      final chatProjection = await _projectChats(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        handleToParticipant: participantProjection.handleToParticipantId,
        handleToContact: participantProjection.handleToContactId,
      );
      resultBuilder.chatsProjected = chatProjection.chatCount;
      resultBuilder.participantsProjected = chatProjection.participantCount;

      emit(
        DbMigrationStage.migratingMessages,
        0.68,
        'Projecting messages',
        stageProgress: 0,
      );
      final messageProjection = await _projectMessages(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        chatIdMap: chatProjection.chatIdMap,
        handleToParticipant: participantProjection.handleToParticipantId,
        minImportMessageIdExclusive: minMessageIdExclusive,
        emitProgress:
            ({
              required String label,
              required int processed,
              required int total,
            }) {
              emit(
                DbMigrationStage.migratingMessages,
                0.74,
                label,
                stageProgress: total == 0 ? 1 : processed / total,
                stageCurrent: processed,
                stageTotal: total,
              );
            },
      );
      resultBuilder.messagesProjected = messageProjection.messageCount;

      emit(
        DbMigrationStage.migratingAttachments,
        0.82,
        'Projecting attachments',
        stageProgress: 0,
      );
      final attachmentsIndex = await _loadAttachments(
        importDb: importDb,
        batchId: batchId,
        messageIds: messageProjection.importMessageIds,
        minAttachmentIdExclusive: minAttachmentIdExclusive,
      );
      final attachmentProjection = await _projectAttachments(
        workingDb: workingDb,
        attachmentsIndex: attachmentsIndex,
        messageGuidByImportId: messageProjection.messageGuidByImportId,
        emitProgress:
            ({
              required String label,
              required int processed,
              required int total,
            }) {
              emit(
                DbMigrationStage.migratingAttachments,
                0.86,
                label,
                stageProgress: total == 0 ? 1 : processed / total,
                stageCurrent: processed,
                stageTotal: total,
              );
            },
      );
      resultBuilder.attachmentsProjected = attachmentProjection.insertedCount;

      emit(DbMigrationStage.migratingReactions, 0.9, 'Projecting reactions');
      final reactionsInserted = await _projectReactions(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        handleToParticipant: participantProjection.handleToParticipantId,
        migratedMessageGuids: messageProjection.migratedMessageGuids,
      );
      resultBuilder.reactionsProjected = reactionsInserted;

      emit(
        DbMigrationStage.updatingProjectionState,
        0.96,
        'Updating projection state metadata',
      );
      final nextProjectedMessageId =
          messageProjection.maxImportMessageId ??
          (shouldResetWorking ? null : previousProjectedMessageId);
      final nextProjectedAttachmentId =
          attachmentProjection.maxImportAttachmentId ??
          (shouldResetWorking ? null : previousProjectedAttachmentId);
      await _updateProjectionState(
        workingDb: workingDb,
        batchId: batchId,
        maxMessageId: nextProjectedMessageId,
        maxAttachmentId: nextProjectedAttachmentId,
      );

      emit(
        DbMigrationStage.mirroringSupabase,
        0.98,
        'Mirroring working projection to Supabase',
      );
      final mirrorService = await ref.watch(
        supabaseMirrorSyncServiceProvider.future,
      );
      await mirrorService.syncAllPendingBatches();

      emit(
        DbMigrationStage.completed,
        1.0,
        'Projection completed for ledger batch $batchId',
      );

      return resultBuilder.build(success: true);
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: migration failed: $error');
      debugSettings.logError('$stackTrace');
      final message = 'Projection failed: $error';
      onProgress?.call(
        DbMigrationProgress(
          stage: DbMigrationStage.completed,
          overallProgress: 1.0,
          message: message,
        ),
      );
      return resultBuilder
          .copyWith(batchId: activeBatchId, error: message)
          .build(success: false);
    }
  }

  Future<void> clearWorkingProjection() async {
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
    await _clearWorkingDatabase(workingDb: workingDb);
    await workingDb.customStatement('''
      UPDATE projection_state
      SET last_import_batch_id = NULL,
          last_projected_at_utc = NULL,
          last_projected_message_id = NULL,
          last_projected_attachment_id = NULL
      WHERE id = 1
      ''');
  }

  Future<int?> _fetchLatestBatchId(Database importDb) async {
    final rows = await importDb.rawQuery(
      'SELECT id FROM import_batches ORDER BY id DESC LIMIT 1',
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['id'];
    return value is int ? value : int.tryParse('$value');
  }

  Future<_LedgerMaxIds> _fetchLedgerMaxIds({
    required Database importDb,
    required int batchId,
  }) async {
    final messageRows = await importDb.rawQuery(
      'SELECT MAX(id) AS max_id FROM messages WHERE batch_id = ?',
      <Object>[batchId],
    );
    final attachmentRows = await importDb.rawQuery(
      'SELECT MAX(id) AS max_id FROM attachments WHERE batch_id = ?',
      <Object>[batchId],
    );

    int? parseMaxId(List<Map<String, Object?>> rows) {
      if (rows.isEmpty) {
        return null;
      }
      final value = rows.first['max_id'];
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      return int.tryParse('$value');
    }

    return _LedgerMaxIds(
      messageId: parseMaxId(messageRows),
      attachmentId: parseMaxId(attachmentRows),
    );
  }

  Future<void> _clearWorkingDatabase({
    required WorkingDatabase workingDb,
  }) async {
    await workingDb.transaction(() async {
      const tablesInDeleteOrder = <String>[
        'message_read_marks',
        'read_state',
        'reaction_counts',
        'reactions',
        'attachments',
        'messages',
        'chat_to_participant',
        'chats',
        'participant_handle_links',
        'participants',
      ];

      for (final table in tablesInDeleteOrder) {
        await workingDb.customStatement('DELETE FROM $table');
      }
    });
  }

  Future<_ContactIndex> _loadContacts({
    required Database importDb,
    required int batchId,
  }) async {
    final contactRows = await importDb.query(
      'contacts',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final contactsById = <int, _LedgerContact>{};
    for (final row in contactRows) {
      final id = row['id'] as int?;
      if (id == null) {
        continue;
      }
      contactsById[id] = _LedgerContact(
        id: id,
        displayName:
            (row['display_name'] as String?) ??
            _composeDisplayName(
              first: row['given_name'] as String?,
              last: row['family_name'] as String?,
              company: row['organization'] as String?,
            ),
      );
    }

    final channelRows = await importDb.query(
      'contact_channels',
      columns: <String>['contact_id', 'kind', 'value'],
    );

    final normalizedChannelToContactId = <String, int>{};

    for (final row in channelRows) {
      final contactId = row['contact_id'] as int?;
      final kind = row['kind'] as String?;
      final value = row['value'] as String?;
      if (contactId == null || kind == null || value == null) {
        continue;
      }
      if (!contactsById.containsKey(contactId)) {
        continue;
      }
      final keys = _normalizedChannelKeys(kind: kind, value: value);
      for (final key in keys) {
        normalizedChannelToContactId.putIfAbsent(key, () => contactId);
      }
      contactsById[contactId]!.channels.add(
        _ContactChannel(kind: kind, value: value),
      );
    }

    return _ContactIndex(
      contactsById: contactsById,
      normalizedChannelToContactId: normalizedChannelToContactId,
    );
  }

  /// Phase 1: Import handles from chat.db to working.db handles table
  /// Following new architecture: handles exist independently of participants
  Future<_HandleProjection> _projectHandles({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final rows = await importDb.query(
      'handles',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final importHandleToWorkingHandle = <int, int>{};
    var handlesInserted = 0;

    for (final row in rows) {
      final importHandleId = row['id'] as int?;
      if (importHandleId == null) {
        continue;
      }

      final service = (row['service'] as String?) ?? 'Unknown';
      final rawIdentifier = row['raw_identifier'] as String?;
      final normalizedAddressRaw = row['normalized_address'] as String?;

      final normalized = _normalizeHandleIdentifier(
        rawIdentifier: rawIdentifier,
        normalizedAddress: normalizedAddressRaw,
      );

      final handleId = normalized.canonical ?? rawIdentifier ?? 'unknown';

      // Insert handle into working database (preserving chat.db ROWID)
      await workingDb.into(workingDb.workingHandles).insert(
        WorkingHandlesCompanion.insert(
          id: Value(importHandleId), // Preserve chat.db ROWID
          handleId: handleId,
          service: Value(service),
          isValid: const Value(true), // Will be validated in Phase 3
          isBlacklisted: const Value(false),
        ),
        mode: InsertMode.insertOrReplace,
      );

      importHandleToWorkingHandle[importHandleId] = importHandleId;
      handlesInserted++;
    }

    return _HandleProjection(
      importHandleToWorkingHandle: importHandleToWorkingHandle,
      handleCount: handlesInserted,
    );
  }

  /// Phase 2: Match handles to AddressBook contacts and create participants
  /// Only creates participants when AddressBook matches exist
  Future<_ParticipantProjection> _projectParticipants({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required _ContactIndex contactIndex,
    required Map<int, int> importHandleToWorkingHandle,
  }) async {
    final handleToParticipant = <int, int>{};
    final participantDisplayNames = <int, String>{};
    final createdParticipants = <int>{}; // Track AddressBook Z_PKs used

    var participantsInserted = 0;
    var linksInserted = 0;

    // Get all handles from working database
    final workingHandles = await workingDb.select(workingDb.workingHandles).get();

    for (final handle in workingHandles) {
      final handleId = handle.handleId;
      
      // Try to match handle to AddressBook contact
      int? matchedContactId;
      final normalized = _normalizeHandleIdentifier(
        rawIdentifier: handleId,
        normalizedAddress: handleId,
      );

      for (final key in normalized.matchingKeys) {
        final contactId = contactIndex.normalizedChannelToContactId[key];
        if (contactId != null) {
          matchedContactId = contactId;
          break;
        }
      }

      // Only create participant if AddressBook match found
      if (matchedContactId != null && !createdParticipants.contains(matchedContactId)) {
        final contact = contactIndex.contactsById[matchedContactId];
        if (contact != null) {
          // Create participant using AddressBook Z_PK as ID
          await workingDb.into(workingDb.workingParticipants).insert(
            WorkingParticipantsCompanion.insert(
              id: Value(matchedContactId), // Use AddressBook Z_PK
              originalName: contact.displayName,
              displayName: contact.displayName,
              shortName: contact.displayName, // Could be enhanced later
            ),
            mode: InsertMode.insertOrIgnore,
          );

          createdParticipants.add(matchedContactId);
          participantDisplayNames[matchedContactId] = contact.displayName;
          participantsInserted++;
        }
      }

      // Create handle_to_participant link if participant exists
      if (matchedContactId != null && createdParticipants.contains(matchedContactId)) {
        await workingDb.into(workingDb.handleToParticipant).insert(
          HandleToParticipantCompanion.insert(
            handleId: handle.id,
            participantId: matchedContactId,
            confidence: const Value(1.0), // AddressBook match = high confidence
            source: const Value('addressbook'),
          ),
          mode: InsertMode.insertOrIgnore,
        );

        handleToParticipant[handle.id] = matchedContactId;
        linksInserted++;
      }
    }

    return _ParticipantProjection(
      handleToParticipantId: handleToParticipant,
      handleToContactId: {}, // Not needed in new architecture
      participantDisplayNames: participantDisplayNames,
      participantCount: participantsInserted,
      handleLinkCount: linksInserted,
    );
  }

  Future<_ChatProjection> _projectChats({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, int> handleToParticipant,
    required Map<int, int> handleToContact,
  }) async {
    final chatRows = await importDb.query(
      'chats',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final participantsByChat = await _loadChatParticipants(
      importDb: importDb,
      chatIds: chatRows
          .map((Map<String, Object?> e) => e['id'])
          .whereType<int>()
          .toList(growable: false),
    );

    final chatIdMap = <int, int>{};
    var chatsInserted = 0;
    var participantsInserted = 0;

    for (final row in chatRows) {
      final importChatId = row['id'] as int?;
      if (importChatId == null) {
        continue;
      }
      final guid = (row['guid'] as String?) ?? 'chat-$importChatId';
      final isGroup = ((row['is_group'] as int?) ?? 0) == 1;
      final createdAtUtc = row['created_at_utc'] as String?;
      final updatedAtUtc = row['updated_at_utc'] as String?;
      final service = row['service'] as String?;

      final participants =
          participantsByChat[importChatId] ?? const <_LedgerChatParticipant>[];

      final existingChat =
          await (workingDb.select(workingDb.workingChats)
                ..where((tbl) => tbl.guid.equals(guid))
                ..limit(1))
              .getSingleOrNull();

      int newChatId;
      if (existingChat != null) {
        newChatId = existingChat.id;
        chatIdMap[importChatId] = newChatId;

        final shouldUpdateService =
            service != null && existingChat.service != service;
        final shouldUpdateIsGroup = existingChat.isGroup != isGroup;
        final shouldUpdateUpdatedAt =
            updatedAtUtc != null && existingChat.updatedAtUtc != updatedAtUtc;

        if (shouldUpdateService ||
            shouldUpdateIsGroup ||
            shouldUpdateUpdatedAt) {
          await (workingDb.update(
            workingDb.workingChats,
          )..where((tbl) => tbl.id.equals(existingChat.id))).write(
            WorkingChatsCompanion(
              service: shouldUpdateService
                  ? Value(service)
                  : const Value.absent(),
              isGroup: shouldUpdateIsGroup
                  ? Value(isGroup)
                  : const Value.absent(),
              updatedAtUtc: shouldUpdateUpdatedAt
                  ? Value(updatedAtUtc)
                  : const Value.absent(),
            ),
          );
        }
      } else {
        newChatId = await workingDb
            .into(workingDb.workingChats)
            .insert(
              WorkingChatsCompanion.insert(
                guid: guid,
                service: Value(service ?? 'Unknown'),
                isGroup: Value(isGroup),
                createdAtUtc: Value(createdAtUtc),
                updatedAtUtc: Value(updatedAtUtc),
              ),
            );
        chatsInserted++;
        chatIdMap[importChatId] = newChatId;
      }

      var sortIndex = 0;
      for (final participant in participants) {
        final handleId = participant.handleId;
        if (handleId == null) {
          continue;
        }
        final participantId = handleToParticipant[handleId];
        if (participantId == null) {
          continue;
        }
        await workingDb
            .into(workingDb.chatToParticipant)
            .insert(
              ChatToParticipantCompanion.insert(
                chatId: newChatId,
                participantId: participantId,
                role: Value(participant.role ?? 'member'),
                sortKey: Value(sortIndex),
              ),
              mode: InsertMode.insertOrReplace,
            );
        participantsInserted++;
        sortIndex++;
      }
    }

    return _ChatProjection(
      chatIdMap: chatIdMap,
      chatCount: chatsInserted,
      participantCount: participantsInserted,
    );
  }

  Future<_MessageProjection> _projectMessages({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, int> chatIdMap,
    required Map<int, int> handleToParticipant,
    required int? minImportMessageIdExclusive,
    required _StageProgressEmitter emitProgress,
  }) async {
    final whereClauses = <String>['batch_id = ?'];
    final whereArgs = <Object>[batchId];
    if (minImportMessageIdExclusive != null) {
      whereClauses.add('id > ?');
      whereArgs.add(minImportMessageIdExclusive);
    }

    final messageRows = await importDb.query(
      'messages',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'id ASC',
    );

    final totalCandidates = messageRows.length;
    if (totalCandidates == 0) {
      emitProgress(label: 'No new messages to project', processed: 0, total: 0);
      return _MessageProjection.empty(
        maxImportMessageId: minImportMessageIdExclusive,
      );
    }

    emitProgress(
      label: 'Projecting $totalCandidates messages',
      processed: 0,
      total: totalCandidates,
    );

    final messageIds = messageRows
        .map((Map<String, Object?> row) => row['id'])
        .whereType<int>()
        .toList(growable: false);
    final messagesWithAttachments = await _loadMessageAttachmentPresence(
      importDb: importDb,
      batchId: batchId,
      messageIds: messageIds,
    );

    final messageGuidById = <int, String>{};
    final migratedGuids = <String>{};
    final importMessageIds = <int>{};
    var messagesInserted = 0;
    var processed = 0;
    var maxImportMessageId = minImportMessageIdExclusive;

    for (final row in messageRows) {
      final messageId = row['id'] as int?;
      final chatId = row['chat_id'] as int?;
      final guid = row['guid'] as String?;
      if (messageId == null || chatId == null || guid == null) {
        processed++;
        continue;
      }
      final workingChatId = chatIdMap[chatId];
      if (workingChatId == null) {
        processed++;
        continue;
      }

      final senderHandleId = row['sender_handle_id'] as int?;
      final senderParticipantId = senderHandleId == null
          ? null
          : handleToParticipant[senderHandleId];
      final isFromMe = ((row['is_from_me'] as int?) ?? 0) == 1;
      final sentAtUtc = row['date_utc'] as String?;
      final deliveredAtUtc = row['date_delivered_utc'] as String?;
      final readAtUtc = row['date_read_utc'] as String?;
      final text = row['text'] as String?;
      final threadOriginatorGuid = row['thread_originator_guid'] as String?;
      final associatedMessageGuid = row['associated_message_guid'] as String?;
      final balloonBundleId = row['balloon_bundle_id'] as String?;
      final isSystemMessage = ((row['is_system_message'] as int?) ?? 0) == 1;
      final itemType = row['item_type'] as String?;
      final errorCode = row['error_code'] as int?;

      final status = _deriveMessageStatus(
        isFromMe: isFromMe,
        deliveredAtUtc: deliveredAtUtc,
        readAtUtc: readAtUtc,
        errorCode: errorCode,
      );

      await workingDb
          .into(workingDb.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: guid,
              chatId: workingChatId,
              senderParticipantId: Value(senderParticipantId),
              isFromMe: Value(isFromMe),
              sentAtUtc: Value(sentAtUtc),
              deliveredAtUtc: Value(deliveredAtUtc),
              readAtUtc: Value(readAtUtc),
              status: Value(status),
              textContent: Value(text),
              hasAttachments: Value(
                messagesWithAttachments.contains(messageId),
              ),
              replyToGuid: Value(threadOriginatorGuid ?? associatedMessageGuid),
              systemType: Value(isSystemMessage ? 'system' : null),
              reactionCarrier: Value(itemType == 'reaction-carrier'),
              balloonBundleId: Value(balloonBundleId),
              updatedAtUtc: Value(sentAtUtc ?? deliveredAtUtc ?? readAtUtc),
            ),
            mode: InsertMode.insertOrReplace,
          );

      messageGuidById[messageId] = guid;
      migratedGuids.add(guid);
      importMessageIds.add(messageId);
      messagesInserted++;
      if (maxImportMessageId == null || messageId > maxImportMessageId) {
        maxImportMessageId = messageId;
      }

      processed++;
      if (processed % 200 == 0 || processed == totalCandidates) {
        emitProgress(
          label:
              'Projected $processed/$totalCandidates messages ($messagesInserted inserted)',
          processed: processed,
          total: totalCandidates,
        );
      }
    }

    return _MessageProjection(
      messageGuidByImportId: messageGuidById,
      migratedMessageGuids: migratedGuids,
      messageCount: messagesInserted,
      maxImportMessageId: maxImportMessageId,
      importMessageIds: importMessageIds,
    );
  }

  Future<_AttachmentProjection> _projectAttachments({
    required WorkingDatabase workingDb,
    required _AttachmentsIndex attachmentsIndex,
    required Map<int, String> messageGuidByImportId,
    required _StageProgressEmitter emitProgress,
  }) async {
    final attachments = attachmentsIndex.byId.values.toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));
    final totalAttachments = attachments.length;
    if (totalAttachments == 0) {
      emitProgress(
        label: 'No new attachments to project',
        processed: 0,
        total: 0,
      );
      return _AttachmentProjection(
        insertedCount: 0,
        maxImportAttachmentId: attachmentsIndex.maxImportAttachmentId,
      );
    }

    emitProgress(
      label: 'Projecting $totalAttachments attachments',
      processed: 0,
      total: totalAttachments,
    );

    var processed = 0;
    var inserted = 0;
    for (final attachment in attachments) {
      final messageId = attachment.messageId;
      if (messageId == null) {
        processed++;
        continue;
      }
      final messageGuid =
          messageGuidByImportId[messageId] ??
          attachmentsIndex.messageGuidByMessageId[messageId];
      if (messageGuid == null) {
        processed++;
        continue;
      }
      final insertResult = await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: messageGuid,
              importAttachmentId: Value(attachment.id),
              localPath: Value(attachment.localPath),
              mimeType: Value(attachment.mimeType),
              uti: Value(attachment.uti),
              transferName: Value(attachment.transferName),
              sizeBytes: Value(attachment.totalBytes),
              isSticker: Value(attachment.isSticker),
              createdAtUtc: Value(attachment.createdAtUtc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (insertResult > 0) {
        inserted++;
      }

      processed++;
      if (processed % 200 == 0 || processed == totalAttachments) {
        emitProgress(
          label:
              'Projected $processed/$totalAttachments attachments ($inserted inserted)',
          processed: processed,
          total: totalAttachments,
        );
      }
    }

    return _AttachmentProjection(
      insertedCount: inserted,
      maxImportAttachmentId: attachmentsIndex.maxImportAttachmentId,
    );
  }

  Future<int> _projectReactions({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, int> handleToParticipant,
    required Set<String> migratedMessageGuids,
  }) async {
    final rows = await importDb.query('reactions');
    var reactionsInserted = 0;
    for (final row in rows) {
      final carrierMessageId = row['carrier_message_id'] as int?;
      final targetMessageGuid = row['target_message_guid'] as String?;
      if (carrierMessageId == null || targetMessageGuid == null) {
        continue;
      }
      if (!migratedMessageGuids.contains(targetMessageGuid)) {
        continue;
      }

      final reactorHandleId = row['reactor_handle_id'] as int?;
      final reactorParticipantId = reactorHandleId == null
          ? null
          : handleToParticipant[reactorHandleId];
      final action = row['action'] as String?;
      final kind = (row['kind'] as String?) ?? 'unknown';
      final reactedAtUtc = row['reacted_at_utc'] as String?;

      await workingDb
          .into(workingDb.workingReactions)
          .insert(
            WorkingReactionsCompanion.insert(
              messageGuid: targetMessageGuid,
              kind: kind,
              action: action ?? 'add',
              reactorParticipantId: Value(reactorParticipantId),
              reactedAtUtc: Value(reactedAtUtc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      reactionsInserted++;
    }
    return reactionsInserted;
  }

  Future<void> _updateProjectionState({
    required WorkingDatabase workingDb,
    required int batchId,
    required int? maxMessageId,
    required int? maxAttachmentId,
  }) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    await workingDb
        .into(workingDb.projectionState)
        .insertOnConflictUpdate(
          ProjectionStateCompanion(
            id: const Value(1),
            lastImportBatchId: Value(batchId),
            lastProjectedAtUtc: Value(timestamp),
            lastProjectedMessageId: Value(maxMessageId),
            lastProjectedAttachmentId: Value(maxAttachmentId),
          ),
        );
  }

  Future<Map<int, List<_LedgerChatParticipant>>> _loadChatParticipants({
    required Database importDb,
    required List<int> chatIds,
  }) async {
    if (chatIds.isEmpty) {
      return <int, List<_LedgerChatParticipant>>{};
    }
    final placeholders = List<String>.filled(chatIds.length, '?').join(',');
    final rows = await importDb.rawQuery(
      'SELECT chat_id, handle_id, role FROM chat_participants '
      'WHERE chat_id IN ($placeholders)',
      chatIds,
    );

    final byChat = <int, List<_LedgerChatParticipant>>{};
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      if (chatId == null) {
        continue;
      }
      byChat
          .putIfAbsent(chatId, () => <_LedgerChatParticipant>[])
          .add(
            _LedgerChatParticipant(
              chatId: chatId,
              handleId: row['handle_id'] as int?,
              role: row['role'] as String?,
            ),
          );
    }
    return byChat;
  }

  Future<_AttachmentsIndex> _loadAttachments({
    required Database importDb,
    required int batchId,
    required Set<int> messageIds,
    int? minAttachmentIdExclusive,
  }) async {
    final shouldScanByAttachmentId = minAttachmentIdExclusive != null;
    if (messageIds.isEmpty && !shouldScanByAttachmentId) {
      return _AttachmentsIndex.empty();
    }

    const chunkSize = 400;
    final candidateAttachmentIds = <int>{};
    final messageToAttachmentIds = <int, List<int>>{};
    final affectedMessageIds = <int>{}..addAll(messageIds);

    Future<void> collectJoinRows({
      required String condition,
      required List<Object> args,
    }) async {
      final rows = await importDb.rawQuery(
        'SELECT ma.message_id, ma.attachment_id '
        'FROM message_attachments ma '
        'INNER JOIN attachments a ON a.id = ma.attachment_id '
        'WHERE a.batch_id = ? AND ($condition)',
        <Object>[batchId, ...args],
      );
      for (final row in rows) {
        final messageId = row['message_id'] as int?;
        final attachmentId = row['attachment_id'] as int?;
        if (messageId == null || attachmentId == null) {
          continue;
        }
        candidateAttachmentIds.add(attachmentId);
        messageToAttachmentIds
            .putIfAbsent(messageId, () => <int>[])
            .add(attachmentId);
        affectedMessageIds.add(messageId);
      }
    }

    if (messageIds.isNotEmpty) {
      final messageIdList = messageIds.toList(growable: false);
      var messageIndex = 0;
      while (messageIndex < messageIdList.length) {
        final end = (messageIndex + chunkSize > messageIdList.length)
            ? messageIdList.length
            : messageIndex + chunkSize;
        final chunk = messageIdList.sublist(messageIndex, end);
        final placeholders = List<String>.filled(chunk.length, '?').join(', ');
        await collectJoinRows(
          condition: 'ma.message_id IN ($placeholders)',
          args: chunk.map<Object>((int id) => id).toList(growable: false),
        );
        messageIndex = end;
      }
    }

    if (minAttachmentIdExclusive != null) {
      await collectJoinRows(
        condition: 'ma.attachment_id > ?',
        args: <Object>[minAttachmentIdExclusive],
      );
    }

    if (candidateAttachmentIds.isEmpty) {
      return _AttachmentsIndex.empty(
        maxImportAttachmentId: minAttachmentIdExclusive,
      );
    }

    final attachmentsById = <int, _LedgerAttachment>{};
    final attachmentIdList = candidateAttachmentIds.toList(growable: false)
      ..sort();
    var attachmentIndex = 0;
    while (attachmentIndex < attachmentIdList.length) {
      final end = (attachmentIndex + chunkSize > attachmentIdList.length)
          ? attachmentIdList.length
          : attachmentIndex + chunkSize;
      final chunk = attachmentIdList.sublist(attachmentIndex, end);
      final placeholders = List<String>.filled(chunk.length, '?').join(', ');
      final rows = await importDb.rawQuery(
        'SELECT id, guid, transfer_name, uti, mime_type, total_bytes, '
        'is_sticker, created_at_utc, local_path '
        'FROM attachments '
        'WHERE batch_id = ? AND id IN ($placeholders)',
        <Object>[batchId, ...chunk],
      );
      for (final row in rows) {
        final id = row['id'] as int?;
        if (id == null) {
          continue;
        }
        attachmentsById[id] = _LedgerAttachment(
          id: id,
          messageId: null,
          guid: row['guid'] as String?,
          transferName: row['transfer_name'] as String?,
          uti: row['uti'] as String?,
          mimeType: row['mime_type'] as String?,
          totalBytes: row['total_bytes'] as int?,
          isSticker: ((row['is_sticker'] as int?) ?? 0) == 1,
          createdAtUtc: row['created_at_utc'] as String?,
          localPath: row['local_path'] as String?,
        );
      }
      attachmentIndex = end;
    }

    final attachmentsByMessage = <int, List<_LedgerAttachment>>{};
    for (final entry in messageToAttachmentIds.entries) {
      final messageId = entry.key;
      final ids = entry.value;
      final attachments = <_LedgerAttachment>[];
      for (final attachmentId in ids) {
        final attachment = attachmentsById[attachmentId];
        if (attachment == null) {
          continue;
        }
        final attachmentWithMessageId = attachment.copyWith(
          messageId: messageId,
        );
        attachments.add(attachmentWithMessageId);
        // Update the attachmentsById map so the messageId is set
        attachmentsById[attachmentId] = attachmentWithMessageId;
      }
      if (attachments.isNotEmpty) {
        attachmentsByMessage[messageId] = attachments;
      }
    }

    final messageGuidByMessageId = await _loadMessageGuids(
      importDb: importDb,
      messageIds: affectedMessageIds,
    );

    final maxAttachmentId = attachmentIdList.isEmpty
        ? minAttachmentIdExclusive
        : attachmentIdList.last;

    return _AttachmentsIndex(
      byId: attachmentsById,
      byMessage: attachmentsByMessage,
      messageGuidByMessageId: messageGuidByMessageId,
      maxImportAttachmentId: maxAttachmentId,
    );
  }

  Future<Set<int>> _loadMessageAttachmentPresence({
    required Database importDb,
    required int batchId,
    required List<int> messageIds,
  }) async {
    if (messageIds.isEmpty) {
      return const <int>{};
    }

    const chunkSize = 400;
    final result = <int>{};
    var index = 0;
    while (index < messageIds.length) {
      final end = (index + chunkSize > messageIds.length)
          ? messageIds.length
          : index + chunkSize;
      final chunk = messageIds.sublist(index, end);
      final placeholders = List<String>.filled(chunk.length, '?').join(', ');
      final rows = await importDb.rawQuery(
        'SELECT DISTINCT ma.message_id '
        'FROM message_attachments ma '
        'INNER JOIN attachments a ON a.id = ma.attachment_id '
        'WHERE a.batch_id = ? AND ma.message_id IN ($placeholders)',
        <Object>[batchId, ...chunk],
      );
      for (final row in rows) {
        final messageId = row['message_id'] as int?;
        if (messageId != null) {
          result.add(messageId);
        }
      }
      index = end;
    }
    return result;
  }

  Future<Map<int, String>> _loadMessageGuids({
    required Database importDb,
    required Set<int> messageIds,
  }) async {
    if (messageIds.isEmpty) {
      return const <int, String>{};
    }

    const chunkSize = 400;
    final result = <int, String>{};
    final ids = messageIds.toList(growable: false)..sort();
    var index = 0;
    while (index < ids.length) {
      final end = (index + chunkSize > ids.length)
          ? ids.length
          : index + chunkSize;
      final chunk = ids.sublist(index, end);
      final placeholders = List<String>.filled(chunk.length, '?').join(', ');
      final rows = await importDb.rawQuery(
        'SELECT id, guid FROM messages WHERE id IN ($placeholders)',
        chunk,
      );
      for (final row in rows) {
        final id = row['id'] as int?;
        final guid = row['guid'] as String?;
        if (id != null && guid != null) {
          result[id] = guid;
        }
      }
      index = end;
    }
    return result;
  }

  String _deriveMessageStatus({
    required bool isFromMe,
    required String? deliveredAtUtc,
    required String? readAtUtc,
    required int? errorCode,
  }) {
    if (errorCode != null && errorCode != 0) {
      return 'failed';
    }
    if (readAtUtc != null) {
      return 'read';
    }
    if (deliveredAtUtc != null) {
      return 'delivered';
    }
    if (isFromMe) {
      return 'sent';
    }
    return 'unknown';
  }

  String _composeDisplayName({
    required String? first,
    required String? last,
    required String? company,
  }) {
    if (first != null && first.isNotEmpty || last != null && last.isNotEmpty) {
      final firstPart = first?.trim() ?? '';
      final lastPart = last?.trim() ?? '';
      return '$firstPart $lastPart'.trim().isNotEmpty
          ? '$firstPart $lastPart'.trim()
          : (company ?? '').trim();
    }
    if (company != null && company.trim().isNotEmpty) {
      return company.trim();
    }
    return 'Unknown contact';
  }

  Iterable<String> _normalizedChannelKeys({
    required String kind,
    required String value,
  }) {
    final keys = <String>{};
    if (kind == 'phone') {
      final digitsOnly = value.replaceAll(RegExp(r'[^0-9+]'), '');
      final trimmed = digitsOnly.trim();
      if (trimmed.isEmpty) {
        return <String>{value.trim()};
      }
      final canonical = _normalizePhoneNumber(trimmed);
      keys.add(canonical);
      keys.add(trimmed);
      if (!trimmed.startsWith('+')) {
        keys.add('+$trimmed');
      }
    } else if (kind == 'email') {
      keys.add(value.trim().toLowerCase());
    } else {
      keys.add(value.trim());
    }
    return keys.where((String element) => element.isNotEmpty);
  }

  _NormalizedIdentifier _normalizeHandleIdentifier({
    required String? rawIdentifier,
    required String? normalizedAddress,
  }) {
    final canonical = normalizedAddress?.trim().isNotEmpty == true
        ? normalizedAddress!.trim()
        : rawIdentifier?.trim();
    final keys = <String>{};
    if (canonical != null && canonical.isNotEmpty) {
      keys.add(canonical);
    }
    if (canonical != null && RegExp(r'[0-9]').hasMatch(canonical)) {
      keys.add(_normalizePhoneNumber(canonical));
    }
    if (rawIdentifier != null) {
      keys.add(rawIdentifier.trim());
    }
    return _NormalizedIdentifier(
      canonical: canonical,
      matchingKeys: keys.where((String element) => element.isNotEmpty).toSet(),
    );
  }

  String _normalizePhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return input;
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return digits.substring(1);
    }
    return digits;
  }

  Future<int> _upsertParticipant({
    required WorkingDatabase workingDb,
    required Map<_ParticipantKey, int> participantLookup,
    required _ParticipantKey key,
    required String displayName,
    required int? contactId,
    required bool isSystem,
    required void Function() participantsInserted,
  }) async {
    final existingId = participantLookup[key];
    if (existingId != null) {
      return existingId;
    }

    final existingRow =
        await (workingDb.select(workingDb.workingParticipants)
              ..where((tbl) {
                final serviceMatches = tbl.service.equals(key.service);
                final normalized = key.normalizedAddress;
                if (normalized == null) {
                  return serviceMatches & tbl.normalizedAddress.isNull();
                }
                return serviceMatches &
                    tbl.normalizedAddress.equals(normalized);
              })
              ..limit(1))
            .getSingleOrNull();

    if (existingRow != null) {
      participantLookup[key] = existingRow.id;

      final desiredContactRef = contactId == null ? null : 'contact:$contactId';
      final shouldUpdateDisplayName =
          displayName.isNotEmpty && existingRow.displayName != displayName;
      final shouldUpdateContactRef =
          existingRow.contactRef != desiredContactRef;
      final shouldUpdateSystem = existingRow.isSystem != isSystem;

      if (shouldUpdateDisplayName ||
          shouldUpdateContactRef ||
          shouldUpdateSystem) {
        await (workingDb.update(
          workingDb.workingParticipants,
        )..where((tbl) => tbl.id.equals(existingRow.id))).write(
          WorkingParticipantsCompanion(
            displayName: shouldUpdateDisplayName
                ? Value(displayName)
                : const Value.absent(),
            contactRef: shouldUpdateContactRef
                ? Value(desiredContactRef)
                : const Value.absent(),
            isSystem: shouldUpdateSystem
                ? Value(isSystem)
                : const Value.absent(),
          ),
        );
      }

      return existingRow.id;
    }

    final newId = await workingDb
        .into(workingDb.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            normalizedAddress: Value(key.normalizedAddress),
            service: Value(key.service),
            displayName: Value(displayName),
            contactRef: contactId == null
                ? const Value.absent()
                : Value('contact:$contactId'),
            isSystem: Value(isSystem),
          ),
        );
    participantLookup[key] = newId;
    participantsInserted();
    return newId;
  }
}

class _ContactIndex {
  _ContactIndex({
    required this.contactsById,
    required this.normalizedChannelToContactId,
  });

  final Map<int, _LedgerContact> contactsById;
  final Map<String, int> normalizedChannelToContactId;
}

class _LedgerContact {
  _LedgerContact({required this.id, required this.displayName});

  final int id;
  final String displayName;
  final List<_ContactChannel> channels = <_ContactChannel>[];
}

class _ContactChannel {
  _ContactChannel({required this.kind, required this.value});

  final String kind;
  final String value;

  Iterable<String> get normalizedKeys => kind == 'email'
      ? <String>[value.trim().toLowerCase()]
      : <String>[_normalize(value)];

  String _normalize(String input) {
    if (kind == 'phone') {
      final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length == 11 && digits.startsWith('1')) {
        return digits.substring(1);
      }
      return digits;
    }
    return input.trim();
  }
}

class _LedgerChatParticipant {
  const _LedgerChatParticipant({
    required this.chatId,
    required this.handleId,
    required this.role,
  });

  final int chatId;
  final int? handleId;
  final String? role;
}

class _LedgerAttachment {
  _LedgerAttachment({
    required this.id,
    required this.messageId,
    required this.guid,
    required this.transferName,
    required this.uti,
    required this.mimeType,
    required this.totalBytes,
    required this.isSticker,
    required this.createdAtUtc,
    required this.localPath,
  });

  final int id;
  final int? messageId;
  final String? guid;
  final String? transferName;
  final String? uti;
  final String? mimeType;
  final int? totalBytes;
  final bool isSticker;
  final String? createdAtUtc;
  final String? localPath;

  _LedgerAttachment copyWith({int? messageId}) {
    return _LedgerAttachment(
      id: id,
      messageId: messageId ?? this.messageId,
      guid: guid,
      transferName: transferName,
      uti: uti,
      mimeType: mimeType,
      totalBytes: totalBytes,
      isSticker: isSticker,
      createdAtUtc: createdAtUtc,
      localPath: localPath,
    );
  }
}

class _AttachmentsIndex {
  _AttachmentsIndex({
    required this.byId,
    required this.byMessage,
    required this.messageGuidByMessageId,
    required this.maxImportAttachmentId,
  });

  _AttachmentsIndex.empty({this.maxImportAttachmentId})
    : byId = <int, _LedgerAttachment>{},
      byMessage = <int, List<_LedgerAttachment>>{},
      messageGuidByMessageId = <int, String>{};

  final Map<int, _LedgerAttachment> byId;
  final Map<int, List<_LedgerAttachment>> byMessage;
  final Map<int, String> messageGuidByMessageId;
  final int? maxImportAttachmentId;
}

@immutable
class _ParticipantKey {
  const _ParticipantKey({
    required this.service,
    required this.normalizedAddress,
  });

  final String service;
  final String? normalizedAddress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! _ParticipantKey) {
      return false;
    }
    return other.service == service &&
        other.normalizedAddress == normalizedAddress;
  }

  @override
  int get hashCode => Object.hash(service, normalizedAddress);
}

class _NormalizedIdentifier {
  const _NormalizedIdentifier({
    required this.canonical,
    required this.matchingKeys,
  });

  final String? canonical;
  final Set<String> matchingKeys;
}

class _HandleProjection {
  const _HandleProjection({
    required this.importHandleToWorkingHandle,
    required this.handleCount,
  });

  final Map<int, int> importHandleToWorkingHandle;
  final int handleCount;
}

class _ParticipantProjection {
  const _ParticipantProjection({
    required this.handleToParticipantId,
    required this.handleToContactId,
    required this.participantDisplayNames,
    required this.participantCount,
    required this.handleLinkCount,
  });

  final Map<int, int> handleToParticipantId;
  final Map<int, int> handleToContactId;
  final Map<int, String> participantDisplayNames;
  final int participantCount;
  final int handleLinkCount;
}

class _ChatProjection {
  const _ChatProjection({
    required this.chatIdMap,
    required this.chatCount,
    required this.participantCount,
  });

  final Map<int, int> chatIdMap;
  final int chatCount;
  final int participantCount;
}

class _MessageProjection {
  const _MessageProjection({
    required this.messageGuidByImportId,
    required this.migratedMessageGuids,
    required this.messageCount,
    required this.maxImportMessageId,
    required this.importMessageIds,
  });

  const _MessageProjection.empty({this.maxImportMessageId})
    : messageGuidByImportId = const <int, String>{},
      migratedMessageGuids = const <String>{},
      messageCount = 0,
      importMessageIds = const <int>{};

  final Map<int, String> messageGuidByImportId;
  final Set<String> migratedMessageGuids;
  final int messageCount;
  final int? maxImportMessageId;
  final Set<int> importMessageIds;
}

class _AttachmentProjection {
  const _AttachmentProjection({
    required this.insertedCount,
    required this.maxImportAttachmentId,
  });

  final int insertedCount;
  final int? maxImportAttachmentId;
}

class _DbMigrationResultBuilder {
  _DbMigrationResultBuilder({required this.batchId});

  int batchId;
  String? error;
  int identitiesProjected = 0;
  int identityHandleLinksProjected = 0;
  int chatsProjected = 0;
  int participantsProjected = 0;
  int messagesProjected = 0;
  int attachmentsProjected = 0;
  int reactionsProjected = 0;
  final List<String> warnings = <String>[];

  _DbMigrationResultBuilder copyWith({int? batchId, String? error}) {
    this.batchId = batchId ?? this.batchId;
    this.error = error ?? this.error;
    return this;
  }

  DbMigrationResult build({required bool success}) {
    return DbMigrationResult(
      batchId: batchId,
      success: success,
      error: error,
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
