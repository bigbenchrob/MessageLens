import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../core/util/date_converter.dart';
import '../../../../features/address_book_folders/feature_level_providers.dart';
import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/states/db_import_progress.dart';
import '../../domain/value_objects/db_import_stage.dart';
import '../debug_settings_provider.dart';

typedef DbImportProgressCallback = void Function(DbImportProgress progress);

/// Coordinates a full ingest from macOS `chat.db` and AddressBook into the
/// Sqflite ledger database (`macos_import.db`).
///
/// Chat DB stages:
/// 1. Preparing import sources
/// 2. Clearing existing ledger data
/// 3. Importing message handles
/// 4. Importing chats
/// 5. Linking chats to handles
/// 6. Importing messages
/// 7. Extracting rich message content
/// 8. Linking chats to messages
/// 9. Importing attachments
///
/// AddressBook stages:
/// 10. Importing contacts, phone numbers, and emails
/// 11. Linking contacts to chat handles
class LedgerImportService {
  LedgerImportService({
    required this.ref,
    required this.extractor,
    this.rustExtractionLimit = 200000,
  });

  final Ref ref;
  final MessageExtractorPort extractor;
  final int rustExtractionLimit;

  static const String _importLogContext = 'LedgerImportService';

  Future<DbImportResult> runImport({
    DbImportProgressCallback? onProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledgerDb = await ref.watch(sqfliteImportDatabaseProvider.future);
    final pathsHelper = await ref.watch(pathsHelperProvider.future);

    var previousMaxMessageRowId = await ledgerDb.maxMessageSourceRowId();
    var previousMaxAttachmentRowId = await ledgerDb.maxAttachmentSourceRowId();
    var previousMaxMessageAttachmentRowId = await ledgerDb
        .maxMessageAttachmentSourceRowId();
    var previousMaxHandleRowId = await ledgerDb.maxHandleSourceRowId();
    var previousMaxChatRowId = await ledgerDb.maxChatSourceRowId();
    var hasExistingLedgerData =
        previousMaxMessageRowId != null ||
        previousMaxHandleRowId != null ||
        previousMaxChatRowId != null ||
        previousMaxAttachmentRowId != null ||
        previousMaxMessageAttachmentRowId != null;

    if (hasExistingLedgerData && previousMaxMessageRowId != null) {
      const messageCountFloor = 50;
      const rowIdGapThreshold = 500;
      final existingMessageCount = await ledgerDb.countRows('messages');
      final detectedTruncatedMessages =
          existingMessageCount > 0 &&
          existingMessageCount < messageCountFloor &&
          previousMaxMessageRowId - existingMessageCount > rowIdGapThreshold;

      if (detectedTruncatedMessages) {
        debugSettings.logProgress(
          '$_importLogContext: Detected truncated message set '
          '(count=$existingMessageCount, maxRowId=$previousMaxMessageRowId). '
          'Forcing full reimport.',
        );

        previousMaxMessageRowId = null;
        previousMaxAttachmentRowId = null;
        previousMaxMessageAttachmentRowId = null;
        previousMaxHandleRowId = null;
        previousMaxChatRowId = null;
        hasExistingLedgerData = false;
      }
    }

    /// 1. Preparing import sources
    final messagesDbPath = pathsHelper.chatDBPath;
    final addressBookEither = await ref.watch(
      futureGetFolderAggregateProvider.future,
    );
    String? addressBookPath;
    String? addressBookFailure;
    addressBookEither.fold(
      (failure) => addressBookFailure = failure.message,
      (aggregate) => addressBookPath = aggregate.mostRecentFolderPath,
    );

    if (addressBookPath == null) {
      final failureMessage =
          addressBookFailure ??
          'AddressBook path could not be resolved via getFolderAggregateEitherProvider';
      debugSettings.logError('$_importLogContext: $failureMessage');
      return DbImportResult(batchId: -1, success: false, error: failureMessage);
    }

    final resolvedAddressBookPath = addressBookPath!;

    final messagesFile = File(messagesDbPath);
    final addressBookFile = File(resolvedAddressBookPath);

    if (!messagesFile.existsSync()) {
      final message = 'Messages database not found at $messagesDbPath';
      debugSettings.logError('$_importLogContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    if (!addressBookFile.existsSync()) {
      final message =
          'AddressBook database not found at $resolvedAddressBookPath';
      debugSettings.logError('$_importLogContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    /// DONE (Preparing import sources)

    final now = DateTime.now().toUtc();
    final startedAtUtc = now.toIso8601String();

    void emit(
      DbImportStage stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    }) {
      onProgress?.call(
        DbImportProgress(
          stage: stage,
          overallProgress: progress,
          message: message,
          stageProgress: stageProgress,
          stageCurrent: stageCurrent,
          stageTotal: stageTotal,
        ),
      );
      if (stage == DbImportStage.completed) {
        debugSettings.logProgress('$_importLogContext: $message');
      }
    }

    emit(DbImportStage.preparingSources, 0.02, 'Preparing import sources');

    /// 2. Clearing existing ledger data
    emit(
      DbImportStage.clearingLedger,
      0.05,
      hasExistingLedgerData
          ? 'Clearing existing ledger data (incremental append)'
          : 'Clearing existing ledger data (fresh import)',
    );
    if (!hasExistingLedgerData) {
      await ledgerDb.clearAllData();
    }

    /// DONE (Clearing existing ledger data)

    // Create batch AFTER clearing data to prevent it from being deleted
    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: messagesDbPath,
      sourceAddressbook: resolvedAddressBookPath,
      hostInfoJson: await _buildHostInfoJson(),
      notes: 'Automated import run ${now.toIso8601String()}',
    );

    if (hasExistingLedgerData) {
      await ledgerDb.assignExistingRecordsToBatch(batchId: batchId);
    }

    debugSettings.logDatabase(
      '$_importLogContext: created import batch $batchId',
    );

    final resultBuilder = _DbImportResultBuilder(batchId: batchId);

    await _recordSourceFile(
      ledgerDb: ledgerDb,
      batchId: batchId,
      file: messagesFile,
    );
    await _recordSourceFile(
      ledgerDb: ledgerDb,
      batchId: batchId,
      file: addressBookFile,
    );

    Database? messagesDb;
    Database? addressBookDb;

    try {
      messagesDb = await openDatabase(messagesDbPath, readOnly: true);
      addressBookDb = await openDatabase(
        resolvedAddressBookPath,
        readOnly: true,
      );

      /// 3. Importing message handles
      resultBuilder.handlesImported = await _importHandles(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
        minSourceRowIdExclusive: previousMaxHandleRowId,
      );

      /// DONE (Importing message handles)

      /// 4. Importing chats
      resultBuilder.chatsImported = await _importChats(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
        minSourceRowIdExclusive: previousMaxChatRowId,
      );

      /// DONE (Importing chats)

      /// 5. Linking chats to handles
      resultBuilder.participantsImported = await _importChatParticipants(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
      );

      /// DONE (Linking chats to handles)

      final chatJoinCache = await _buildChatMessageJoinCache(
        messagesDb: messagesDb,
        cachingEnabled: debugSettings.ledgerRowCachingEnabled,
        debugSettings: debugSettings,
      );

      /// 6. Importing messages
      final messageImportResult = await _importMessages(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        chatJoinCache: chatJoinCache,
        emit: emit,
        minSourceRowIdExclusive: previousMaxMessageRowId,
      );
      resultBuilder.messagesImported = messageImportResult.insertedCount;

      /// 7. Extracting rich message content
      emit(
        DbImportStage.extractingRichContent,
        0.6,
        'Extracting rich message content',
        stageProgress: 0,
        stageTotal: messageImportResult.extractionCandidates.length,
      );
      final extraction = await _extractRichText(
        extractor: extractor,
        messagesDbPath: messagesDbPath,
        messagesDb: messagesDb,
        targetMessageIds: messageImportResult.extractionCandidates,
      );
      final appliedRichText = await _applyExtractedMessageText(
        ledgerDb: ledgerDb,
        extractionCandidates: messageImportResult.extractionCandidates,
        extraction: extraction,
      );
      emit(
        DbImportStage.extractingRichContent,
        0.62,
        'Extracting rich message content: applied '
        '$appliedRichText/${messageImportResult.extractionCandidates.length}',
        stageProgress: 1,
      );

      /// DONE (Extracting rich message content)

      /// 8. Linking chats to messages
      await _linkMessagesToChats(
        ledgerDb: ledgerDb,
        messageToChat: messageImportResult.messageToChat,
        emit: emit,
      );

      /// DONE (Linking chats to messages)
      /// DONE (Importing messages)

      /// 9. Importing attachments
      final attachmentsCounts = await _importAttachments(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
        minAttachmentSourceRowIdExclusive: previousMaxAttachmentRowId,
        minMessageAttachmentSourceRowIdExclusive:
            previousMaxMessageAttachmentRowId,
        newMessageSourceRowIds: messageImportResult.insertedSourceRowIds,
      );
      resultBuilder.attachmentsImported = attachmentsCounts.attachments;
      resultBuilder.messageAttachmentsImported =
          attachmentsCounts.messageAttachments;

      /// DONE (Importing attachments)

      /// 10. Importing contacts, phone numbers, and emails
      resultBuilder.contactsImported = await _importContacts(
        ledgerDb: ledgerDb,
        batchId: batchId,
        addressBookDb: addressBookDb,
        emit: emit,
      );
      resultBuilder.contactChannelsImported = await _importContactChannels(
        ledgerDb: ledgerDb,
        batchId: batchId,
        addressBookDb: addressBookDb,
        emit: emit,
      );

      /// DONE (Importing contacts, phone numbers, and emails)

      /// 11. Linking contacts to chat handles
      await _linkContactsToHandles(
        ledgerDb: ledgerDb,
        batchId: batchId,
        emit: emit,
      );

      /// DONE (Linking contacts to chat handles)

      emit(DbImportStage.completed, 0.95, 'Applying spam filters...');

      // Apply ignore flags to spam handles, chats, and messages
      await _applySpamIgnoreFlags(ledgerDb: ledgerDb, emit: emit);

      emit(DbImportStage.completed, 1.0, 'Import completed successfully');

      await ledgerDb.updateImportBatch(
        id: batchId,
        finishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        notes: 'Completed import run with spam filtering',
      );

      return resultBuilder.build(success: true);
    } catch (error, stackTrace) {
      debugSettings.logError(
        '$_importLogContext: import failed with $error\n$stackTrace',
      );
      resultBuilder.error = error.toString();
      return resultBuilder.build(success: false);
    } finally {
      await messagesDb?.close();
      await addressBookDb?.close();
    }
  }

  Future<void> _recordSourceFile({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required File file,
  }) async {
    try {
      final stat = file.statSync();
      await ledgerDb.insertSourceFile(
        batchId: batchId,
        path: p.normalize(file.path),
        sizeBytes: stat.size,
        mtimeUtc: stat.modified.toUtc().toIso8601String(),
      );
    } catch (_) {
      // Ignore failures here; they are not fatal to the import.
    }
  }

  Future<int> _importHandles({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
    int? minSourceRowIdExclusive,
  }) async {
    final rows = await messagesDb.query(
      'handle',
      where: minSourceRowIdExclusive == null ? null : 'ROWID > ?',
      whereArgs: minSourceRowIdExclusive == null
          ? null
          : <Object>[minSourceRowIdExclusive],
    );

    if (rows.isEmpty) {
      emit(
        DbImportStage.importingHandles,
        0.1,
        'Importing message handles (no new handles detected)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return 0;
    }

    emit(
      DbImportStage.importingHandles,
      0.1,
      'Importing message handles (${rows.length} detected)',
      stageProgress: 0,
      stageTotal: rows.length,
    );

    var processed = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final rawIdentifier = (row['id'] as String?)?.trim();
      final normalizedAddress = _normalizeIdentifier(rawIdentifier);
      final service = sanitizeHandleService(row['service'] as String?);
      final compoundIdentifier = buildCompoundIdentifier(
        normalizedIdentifier: normalizedAddress,
        rawIdentifier: rawIdentifier,
        service: service,
      );
      final country = (row['country'] as String?)?.trim();
      final lastSeen =
          DateConverter.toIntSafe(row['last_read_date']) ??
          DateConverter.toIntSafe(row['last_use']);
      final lastSeenUtc = DateConverter.appleToIsoString(lastSeen);

      // Import ALL handles - no spam filtering during import
      // Spam detection will be handled post-import with ignore flags
      await ledgerDb.insertHandle(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        service: service,
        rawIdentifier: rawIdentifier ?? 'unknown',
        normalizedIdentifier: normalizedAddress,
        compoundIdentifier: compoundIdentifier,
        country: country,
        lastSeenUtc: lastSeenUtc,
        batchId: batchId,
      );

      processed++;
      if (processed % 200 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingHandles,
          0.12,
          'Importing message handles: processed $processed/${rows.length}',
          stageProgress: rows.isEmpty ? 1 : processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }

    return rows.length;
  }

  Future<int> _importChats({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
    int? minSourceRowIdExclusive,
  }) async {
    final rows = await messagesDb.query(
      'chat',
      where: minSourceRowIdExclusive == null ? null : 'ROWID > ?',
      whereArgs: minSourceRowIdExclusive == null
          ? null
          : <Object>[minSourceRowIdExclusive],
    );

    if (rows.isEmpty) {
      emit(
        DbImportStage.importingChats,
        0.18,
        'Importing chats (no new chats detected)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return 0;
    }

    emit(
      DbImportStage.importingChats,
      0.18,
      'Importing chats (${rows.length} detected)',
      stageProgress: 0,
      stageTotal: rows.length,
    );
    var processed = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = (row['guid'] as String?)?.trim();
      if (guid == null || guid.isEmpty) {
        continue;
      }
      final isGroup = (row['is_group'] as int? ?? 0) == 1;
      final created = DateConverter.toIntSafe(row['creation_date']);
      final updated = DateConverter.toIntSafe(
        row['last_read_message_timestamp'],
      );

      await ledgerDb.insertChat(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: guid,
        service: (row['service_name'] as String?)?.trim() ?? 'Unknown',
        displayName: (row['display_name'] as String?)?.trim(),
        isGroup: isGroup,
        createdAtUtc: DateConverter.appleToIsoString(created),
        updatedAtUtc: DateConverter.appleToIsoString(updated),
        batchId: batchId,
      );

      processed++;
      if (processed % 100 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingChats,
          0.24,
          'Importing chats: processed $processed/${rows.length}',
          stageProgress: rows.isEmpty ? 1 : processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }
    return rows.length;
  }

  Future<int> _importChatParticipants({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingParticipants,
      0.28,
      'Linking chats to handles',
      stageProgress: 0,
    );

    // Import ALL chat-handle relationships since we now import all handles
    final rows = await messagesDb.query('chat_handle_join');
    var processed = 0;
    var inserted = 0;

    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final handleId = row['handle_id'] as int?;
      if (chatId == null || handleId == null) {
        processed++;
        continue;
      }

      final alreadyLinked = await ledgerDb.chatParticipantExists(
        chatId: chatId,
        handleId: handleId,
      );
      processed++;
      if (alreadyLinked) {
        if (processed % 500 == 0 || processed == rows.length) {
          emit(
            DbImportStage.importingParticipants,
            0.32,
            'Linking chats to handles: processed $processed/${rows.length}'
            ' (linked $inserted)',
            stageProgress: rows.isEmpty ? 1 : processed / rows.length,
            stageCurrent: inserted,
            stageTotal: rows.length,
          );
        }
        continue;
      }

      // All handles and chats exist now, so this should always succeed
      final insertResult = await ledgerDb.insertChatParticipant(
        chatId: chatId,
        handleId: handleId,
      );
      if (insertResult > 0) {
        inserted++;
      }

      if (processed % 500 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingParticipants,
          0.32,
          'Linking chats to handles: processed $processed/${rows.length}'
          ' (linked $inserted)',
          stageProgress: rows.isEmpty ? 1 : processed / rows.length,
          stageCurrent: inserted,
          stageTotal: rows.length,
        );
      }
    }
    return inserted;
  }

  Future<_ChatMessageJoinCache> _buildChatMessageJoinCache({
    required Database messagesDb,
    required bool cachingEnabled,
    required ImportDebugSettingsState debugSettings,
  }) async {
    if (!cachingEnabled) {
      debugSettings.logProgress(
        'LedgerImportService: ledger row caching disabled; using per-message lookups',
      );
      return _ChatMessageJoinCache.disabled();
    }

    final rows = await messagesDb.query('chat_message_join');
    final messageToChat = <int, int>{};
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final messageId = row['message_id'] as int?;
      if (chatId == null || messageId == null) {
        continue;
      }
      messageToChat.putIfAbsent(messageId, () => chatId);
    }

    debugSettings.logProgress(
      'LedgerImportService: cached ${messageToChat.length} chat-message joins',
    );
    return _ChatMessageJoinCache.enabled(messageToChat);
  }

  Future<_RichTextExtraction> _extractRichText({
    required MessageExtractorPort extractor,
    required String messagesDbPath,
    required Database messagesDb,
    Set<int>? targetMessageIds,
  }) async {
    final targets = targetMessageIds?.where((id) => id > 0).toSet();
    if (targets != null && targets.isEmpty) {
      return const _RichTextExtraction(messages: <int, String>{});
    }

    final rows = <Map<String, Object?>>[];
    if (targets == null) {
      rows.addAll(await messagesDb.query('message'));
    } else {
      const chunkSize = 200;
      final orderedTargets = targets.toList()..sort();
      var index = 0;
      while (index < orderedTargets.length) {
        final end = (index + chunkSize > orderedTargets.length)
            ? orderedTargets.length
            : index + chunkSize;
        final chunk = orderedTargets.sublist(index, end);
        final placeholders = List<String>.filled(chunk.length, '?').join(', ');
        final chunkRows = await messagesDb.query(
          'message',
          where: 'ROWID IN ($placeholders)',
          whereArgs: chunk.map<Object>((id) => id).toList(),
        );
        rows.addAll(chunkRows);
        index = end;
      }
    }
    final blobMessageIds = <int>[];
    for (final row in rows) {
      final rowId = row['ROWID'] as int?;
      if (rowId == null) {
        continue;
      }
      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      if ((text == null || text.isEmpty) && attributed != null) {
        if (targets != null && !targets.contains(rowId)) {
          continue;
        }
        blobMessageIds.add(rowId);
      }
    }

    if (blobMessageIds.isEmpty) {
      return const _RichTextExtraction(messages: <int, String>{});
    }

    // Check if the Rust extractor is available
    final debugSettings = ref.watch(importDebugSettingsProvider);
    debugSettings.logDatabase(
      '$_importLogContext: Checking Rust extractor availability for ${blobMessageIds.length} messages with attributed bodies',
    );

    final isExtractorAvailable = await extractor.isAvailable();
    debugSettings.logDatabase(
      '$_importLogContext: Rust extractor available: $isExtractorAvailable',
    );

    if (!isExtractorAvailable) {
      debugSettings.logDatabase(
        '$_importLogContext: Rust extractor not available, skipping rich text extraction for ${blobMessageIds.length} messages',
      );
      return const _RichTextExtraction(messages: <int, String>{});
    }

    try {
      final extracted = await extractor.extractAllMessageTexts(
        limit: rustExtractionLimit,
        dbPath: messagesDbPath,
      );
      if (targets == null) {
        return _RichTextExtraction(messages: extracted);
      }
      final filtered = <int, String>{};
      for (final entry in extracted.entries) {
        if (targets.contains(entry.key)) {
          filtered[entry.key] = entry.value;
        }
      }
      return _RichTextExtraction(messages: filtered);
    } catch (e) {
      final debugSettings = ref.watch(importDebugSettingsProvider);
      debugSettings.logDatabase(
        '$_importLogContext: Rich text extraction failed: $e',
      );
      // Return empty extraction to continue import without rich text
      return const _RichTextExtraction(messages: <int, String>{});
    }
  }

  Future<_MessageImportResult> _importMessages({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required _ChatMessageJoinCache chatJoinCache,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
    int? minSourceRowIdExclusive,
  }) async {
    emit(
      DbImportStage.importingMessages,
      0.36,
      'Importing messages (scanning for new messages)',
      stageProgress: 0,
    );

    final rows = await messagesDb.query(
      'message',
      where: minSourceRowIdExclusive == null ? null : 'ROWID > ?',
      whereArgs: minSourceRowIdExclusive == null
          ? null
          : <Object>[minSourceRowIdExclusive],
    );

    if (rows.isEmpty) {
      emit(
        DbImportStage.importingMessages,
        0.36,
        'Importing messages (no new messages detected)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return const _MessageImportResult.empty();
    }

    emit(
      DbImportStage.importingMessages,
      0.4,
      'Importing messages (${rows.length} detected)',
      stageProgress: 0,
      stageTotal: rows.length,
    );
    var processed = 0;
    var inserted = 0;
    final insertedSourceRowIds = <int>{};
    final extractionCandidates = <int>{};
    final messageToChat = <int, int>{};

    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = row['guid'] as String?;
      if (sourceRowId == null || guid == null || guid.isEmpty) {
        continue;
      }

      final chatId = await chatJoinCache.resolveChatId(
        messagesDb: messagesDb,
        messageId: sourceRowId,
      );
      if (chatId == null) {
        continue;
      }

      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      final resolvedText = (text == null || text.isEmpty) ? null : text;
      final needsExtraction =
          (resolvedText == null || resolvedText.isEmpty) && attributed != null;
      if (needsExtraction) {
        extractionCandidates.add(sourceRowId);
      }

      final messageInserted = await ledgerDb.insertMessage(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: guid,
        chatId: chatId,
        senderHandleId: row['handle_id'] as int?,
        service: (row['service'] as String?)?.trim() ?? 'Unknown',
        isFromMe: (row['is_from_me'] as int? ?? 0) == 1,
        dateUtc: DateConverter.appleToIsoString(row['date']),
        dateReadUtc: DateConverter.appleToIsoString(row['date_read']),
        dateDeliveredUtc: DateConverter.appleToIsoString(row['date_delivered']),
        subject: (row['subject'] as String?)?.trim(),
        text: resolvedText,
        attributedBodyBlob: attributed,
        itemType: _inferItemType(row),
        errorCode: row['error'] as int?,
        isSystemMessage: (row['is_system_message'] as int? ?? 0) == 1,
        threadOriginatorGuid: row['thread_originator_guid'] as String?,
        associatedMessageGuid: row['associated_message_guid'] as String?,
        balloonBundleId: row['balloon_bundle_id'] as String?,
        payloadJson: _decodeOptionalBlob(row['payload_data']),
        batchId: batchId,
      );

      if (messageInserted > 0) {
        inserted++;
        insertedSourceRowIds.add(sourceRowId);
        messageToChat[sourceRowId] = chatId;
      }

      processed++;
      if (processed % 500 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingMessages,
          0.52,
          'Importing messages: processed $processed/${rows.length} '
          '($inserted inserted)',
          stageProgress: processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }

    return _MessageImportResult(
      scannedCount: rows.length,
      insertedCount: inserted,
      insertedSourceRowIds: List<int>.unmodifiable(insertedSourceRowIds),
      extractionCandidates: extractionCandidates,
      messageToChat: messageToChat,
    );
  }

  Future<int> _applyExtractedMessageText({
    required SqfliteImportDatabase ledgerDb,
    required Set<int> extractionCandidates,
    required _RichTextExtraction extraction,
  }) async {
    if (extractionCandidates.isEmpty || extraction.messages.isEmpty) {
      return 0;
    }

    var applied = 0;
    for (final messageId in extractionCandidates) {
      final text = extraction.messages[messageId];
      final normalized = text?.trim();
      if (normalized == null || normalized.isEmpty) {
        continue;
      }
      await ledgerDb.updateMessageText(messageId: messageId, text: normalized);
      applied += 1;
    }

    return applied;
  }

  Future<void> _linkMessagesToChats({
    required SqfliteImportDatabase ledgerDb,
    required Map<int, int> messageToChat,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    if (messageToChat.isEmpty) {
      emit(
        DbImportStage.linkingMessageArtifacts,
        0.64,
        'Linking chats to messages (no new messages to link)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return;
    }

    final orderedEntries = messageToChat.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final total = orderedEntries.length;
    var processed = 0;
    var linked = 0;

    emit(
      DbImportStage.linkingMessageArtifacts,
      0.64,
      'Linking chats to messages ($total entries)',
      stageProgress: 0,
      stageTotal: total,
    );

    for (final entry in orderedEntries) {
      final messageId = entry.key;
      final chatId = entry.value;
      final result = await ledgerDb.insertChatMessageJoinSource(
        chatId: chatId,
        messageId: messageId,
        sourceRowid: messageId,
      );
      if (result != -1) {
        linked += 1;
      }

      processed += 1;
      if (processed % 200 == 0 || processed == total) {
        emit(
          DbImportStage.linkingMessageArtifacts,
          0.66,
          'Linking chats to messages: processed $processed/$total '
          '($linked linked)',
          stageProgress: total == 0 ? 1 : processed / total,
          stageCurrent: processed,
          stageTotal: total,
        );
      }
    }
  }

  Future<_AttachmentCounts> _importAttachments({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
    int? minAttachmentSourceRowIdExclusive,
    int? minMessageAttachmentSourceRowIdExclusive,
    Iterable<int>? newMessageSourceRowIds,
  }) async {
    emit(
      DbImportStage.importingAttachments,
      0.7,
      'Importing attachments (scanning for new attachments)',
      stageProgress: 0,
    );

    final attachmentsSql = StringBuffer('''
SELECT
  attachment.ROWID AS source_rowid,
  attachment.guid,
  attachment.transfer_name,
  attachment.uti,
  attachment.mime_type,
  attachment.total_bytes,
  attachment.is_sticker,
  attachment.is_outgoing,
  attachment.created_date,
  attachment.filename
FROM attachment
''');
    final attachmentsArgs = <Object>[];
    if (minAttachmentSourceRowIdExclusive != null) {
      attachmentsSql.write('WHERE attachment.ROWID > ?');
      attachmentsArgs.add(minAttachmentSourceRowIdExclusive);
    }

    final attachments = await messagesDb.rawQuery(
      attachmentsSql.toString(),
      attachmentsArgs,
    );

    if (attachments.isEmpty) {
      emit(
        DbImportStage.importingAttachments,
        0.7,
        'Importing attachments (no new attachments detected)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
    }

    var processedAttachments = 0;
    var insertedAttachments = 0;
    final newAttachmentIds = <int>{};

    for (final row in attachments) {
      final sourceRowId = row['source_rowid'] as int?;
      final insertResult = await ledgerDb.insertAttachment(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: row['guid'] as String?,
        transferName: row['transfer_name'] as String?,
        uti: row['uti'] as String?,
        mimeType: row['mime_type'] as String?,
        totalBytes: (row['total_bytes'] as num?)?.toInt(),
        isSticker: (row['is_sticker'] as int? ?? 0) == 1,
        isOutgoing: _nullableBool(row['is_outgoing'] as int?),
        createdAtUtc: DateConverter.appleToIsoString(row['created_date']),
        localPath: row['filename'] as String?,
        batchId: batchId,
      );

      if (insertResult > 0 && sourceRowId != null) {
        insertedAttachments++;
        newAttachmentIds.add(sourceRowId);
      }

      processedAttachments++;
      if (processedAttachments % 200 == 0 ||
          processedAttachments == attachments.length) {
        emit(
          DbImportStage.importingAttachments,
          0.76,
          'Importing attachments: processed '
          '$processedAttachments/${attachments.length} '
          '($insertedAttachments inserted)',
          stageProgress: attachments.isEmpty
              ? 1
              : processedAttachments / attachments.length,
          stageCurrent: processedAttachments,
          stageTotal: attachments.length,
        );
      }
    }

    if (newAttachmentIds.isEmpty &&
        minMessageAttachmentSourceRowIdExclusive != null) {
      final fallbackRows = await messagesDb.rawQuery(
        'SELECT DISTINCT attachment_id FROM message_attachment_join '
        'WHERE attachment_id > ?',
        <Object>[minMessageAttachmentSourceRowIdExclusive],
      );
      for (final row in fallbackRows) {
        final attachmentId = row['attachment_id'] as int?;
        if (attachmentId != null) {
          newAttachmentIds.add(attachmentId);
        }
      }
    }

    final messageIds = <int>{
      if (newMessageSourceRowIds != null) ...newMessageSourceRowIds,
    };

    if (attachments.isEmpty && messageIds.isEmpty && newAttachmentIds.isEmpty) {
      emit(
        DbImportStage.linkingMessageArtifacts,
        0.78,
        'Importing attachments (no message attachments to link)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return _AttachmentCounts(
        attachments: insertedAttachments,
        messageAttachments: 0,
      );
    }

    final joinPairs = <({int messageId, int attachmentId})>{};

    Future<void> collectJoinPairs({
      required Set<int> ids,
      required String column,
    }) async {
      if (ids.isEmpty) {
        return;
      }
      final ordered = ids.toList()..sort();
      const chunkSize = 200;
      var index = 0;
      while (index < ordered.length) {
        final end = (index + chunkSize > ordered.length)
            ? ordered.length
            : index + chunkSize;
        final chunk = ordered.sublist(index, end);
        final placeholders = List<String>.filled(chunk.length, '?').join(', ');
        final rows = await messagesDb.rawQuery(
          'SELECT message_id, attachment_id FROM message_attachment_join '
          'WHERE $column IN ($placeholders)',
          chunk.map<Object>((id) => id).toList(),
        );
        for (final row in rows) {
          final messageId = row['message_id'] as int?;
          final attachmentId = row['attachment_id'] as int?;
          if (messageId == null || attachmentId == null) {
            continue;
          }
          joinPairs.add((messageId: messageId, attachmentId: attachmentId));
        }
        index = end;
      }
    }

    await collectJoinPairs(ids: messageIds, column: 'message_id');
    await collectJoinPairs(ids: newAttachmentIds, column: 'attachment_id');

    if (joinPairs.isEmpty) {
      emit(
        DbImportStage.linkingMessageArtifacts,
        0.7,
        'Importing attachments (no message attachments to link)',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return _AttachmentCounts(
        attachments: insertedAttachments,
        messageAttachments: 0,
      );
    }

    final totalPairs = joinPairs.length;
    var processedPairs = 0;
    var linkedPairs = 0;

    emit(
      DbImportStage.linkingMessageArtifacts,
      0.78,
      'Importing attachments (linking $totalPairs message attachments)',
      stageProgress: 0,
      stageTotal: totalPairs,
    );

    for (final pair in joinPairs) {
      final insertResult = await ledgerDb.insertMessageAttachment(
        messageId: pair.messageId,
        attachmentId: pair.attachmentId,
        sourceRowid: pair.attachmentId,
      );

      if (insertResult != -1) {
        linkedPairs++;
      }

      processedPairs++;
      if (processedPairs % 200 == 0 || processedPairs == totalPairs) {
        emit(
          DbImportStage.linkingMessageArtifacts,
          0.8,
          'Importing attachments: linked '
          '$linkedPairs/$totalPairs message attachments',
          stageProgress: totalPairs == 0 ? 1 : processedPairs / totalPairs,
          stageCurrent: processedPairs,
          stageTotal: totalPairs,
        );
      }
    }

    return _AttachmentCounts(
      attachments: insertedAttachments,
      messageAttachments: linkedPairs,
    );
  }

  Future<int> _importContacts({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database addressBookDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingAddressBook,
      0.82,
      'Importing contacts, phone numbers, and emails',
    );
    final rows = await addressBookDb.query('ZABCDRECORD');
    var processed = 0;
    var inserted = 0;
    for (final row in rows) {
      final recordId = row['Z_PK'] as int?;
      if (recordId == null) {
        processed++;
        continue;
      }
      var first = (row['ZFIRSTNAME'] as String?)?.trim();
      if (first?.isEmpty == true) {
        first = null;
      }
      var last = (row['ZLASTNAME'] as String?)?.trim();
      if (last?.isEmpty == true) {
        last = null;
      }
      var company = (row['ZORGANIZATION'] as String?)?.trim();
      if (company?.isEmpty == true) {
        company = null;
      }

      final displayName = _buildContactDisplayName(
        firstName: first,
        lastName: last,
        organization: company,
      );

      processed++;
      final alreadyImported = await ledgerDb.contactExists(recordId);
      if (alreadyImported) {
        if (processed % 200 == 0 || processed == rows.length) {
          emit(
            DbImportStage.importingAddressBook,
            0.86,
            'Importing contacts, phone numbers, and emails: processed '
            '$processed/${rows.length}',
            stageProgress: rows.isEmpty ? 1 : processed / rows.length,
            stageCurrent: inserted,
            stageTotal: rows.length,
          );
        }
        continue;
      }

      await ledgerDb.insertContact(
        zPk: recordId,
        firstName: first,
        lastName: last,
        organization: company,
        displayName: displayName,
        createdAtUtc: DateConverter.appleToIsoString(row['ZCREATIONDATE']),
        batchId: batchId,
      );
      inserted++;
      if (processed % 200 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingAddressBook,
          0.86,
          'Importing contacts, phone numbers, and emails: processed '
          '$processed/${rows.length}',
          stageProgress: rows.isEmpty ? 1 : processed / rows.length,
          stageCurrent: inserted,
          stageTotal: rows.length,
        );
      }
    }
    return inserted;
  }

  Future<void> _linkContactsToHandles({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingAddressBook,
      0.9,
      'Linking contacts to chat handles',
    );

    await ledgerDb.clearContactHandleLinksForBatch(batchId: batchId);

    final handles = await ledgerDb.handlesForBatch(batchId);
    final channels = await ledgerDb.contactChannelsForBatch(batchId);

    final normalizedHandleMap = <String, int>{};
    for (final handle in handles) {
      final handleId = handle['id'] as int?;
      if (handleId == null) {
        continue;
      }
      final raw = handle['raw_identifier'] as String?;
      final normalized = handle['normalized_identifier'] as String?;
      final normalizedKey = (normalized?.isNotEmpty == true)
          ? normalized!.trim().toLowerCase()
          : _normalizeIdentifier(raw)?.toLowerCase();
      if (normalizedKey != null && normalizedKey.isNotEmpty) {
        normalizedHandleMap[normalizedKey] = handleId;
      }
      if (raw != null && raw.isNotEmpty) {
        final rawKey = raw.trim().toLowerCase();
        normalizedHandleMap.putIfAbsent(rawKey, () => handleId);
      }
    }

    var linksCreated = 0;
    var channelsProcessed = 0;
    for (final channel in channels) {
      final contactZpk = channel['contact_Z_PK'] as int?;
      final kind = channel['kind'] as String?;
      final value = channel['value'] as String?;
      if (contactZpk == null || value == null || value.isEmpty) {
        continue;
      }

      channelsProcessed++;

      final normalizedKey = kind == 'phone'
          ? _normalizeIdentifier(value)?.toLowerCase()
          : value.trim().toLowerCase();
      final rawKey = value.trim().toLowerCase();

      String? resolvedKey;
      if (normalizedKey != null && normalizedKey.isNotEmpty) {
        resolvedKey = normalizedKey;
      } else if (rawKey.isNotEmpty) {
        resolvedKey = rawKey;
      }

      if (resolvedKey == null || resolvedKey.isEmpty) {
        continue;
      }

      final handleId =
          normalizedHandleMap[resolvedKey] ?? normalizedHandleMap[rawKey];
      if (handleId == null) {
        continue;
      }

      await ledgerDb.insertContactHandleLink(
        contactZpk: contactZpk,
        handleId: handleId,
        batchId: batchId,
      );
      linksCreated++;
    }

    await ledgerDb.updateContactIgnoreFlags(batchId: batchId);

    emit(
      DbImportStage.importingAddressBook,
      0.92,
      'Linking contacts to chat handles '
      '(linked $linksCreated from $channelsProcessed channels)',
      stageProgress: 1,
    );
  }

  Future<int> _importContactChannels({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database addressBookDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingAddressBook,
      0.86,
      'Importing contacts, phone numbers, and emails (channels)',
    );
    var insertedChannels = 0;

    final emailRows = await addressBookDb.query('ZABCDEMAILADDRESS');
    for (final row in emailRows) {
      final recordId = row['ZOWNER'] as int?;
      if (recordId == null) {
        continue;
      }
      final value = (row['ZADDRESS'] as String?)?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      final normalizedValue = value.toLowerCase();
      final alreadyImported = await ledgerDb.contactChannelExists(
        kind: 'email',
        value: normalizedValue,
      );
      if (alreadyImported) {
        continue;
      }
      await ledgerDb.insertContactChannel(
        zOwner: recordId,
        kind: 'email',
        value: normalizedValue,
        label: row['ZLABEL'] as String?,
      );
      insertedChannels++;
    }

    final phoneRows = await addressBookDb.query('ZABCDPHONENUMBER');
    for (final row in phoneRows) {
      final recordId = row['ZOWNER'] as int?;
      if (recordId == null) {
        continue;
      }
      final rawValue = (row['ZFULLNUMBER'] as String?)?.trim();
      if (rawValue == null || rawValue.isEmpty) {
        continue;
      }
      final normalizedValue = _normalizeIdentifier(rawValue) ?? rawValue;
      final alreadyImported = await ledgerDb.contactChannelExists(
        kind: 'phone',
        value: normalizedValue,
      );
      if (alreadyImported) {
        continue;
      }
      await ledgerDb.insertContactChannel(
        zOwner: recordId,
        kind: 'phone',
        value: normalizedValue,
        label: row['ZLABEL'] as String?,
      );
      insertedChannels++;
    }

    emit(
      DbImportStage.importingAddressBook,
      0.88,
      'Importing contacts, phone numbers, and emails: '
      'imported $insertedChannels contact channels',
      stageProgress: 1,
    );

    return insertedChannels;
  }

  Future<String?> _buildHostInfoJson() async {
    try {
      final info = <String, Object?>{
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
      };
      return jsonEncode(info);
    } catch (_) {
      return null;
    }
  }

  String? _normalizeIdentifier(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) {
      return null;
    }
    final normalized = digits.startsWith('+') ? digits.substring(1) : digits;
    if (normalized.length == 11 && normalized.startsWith('1')) {
      return normalized.substring(1);
    }
    return normalized;
  }

  String _buildContactDisplayName({
    String? firstName,
    String? lastName,
    String? organization,
  }) {
    final trimmedFirst = firstName?.trim();
    final trimmedLast = lastName?.trim();
    final trimmedOrganization = organization?.trim();

    final hasFirst = trimmedFirst?.isNotEmpty == true;
    final hasLast = trimmedLast?.isNotEmpty == true;
    final hasOrganization = trimmedOrganization?.isNotEmpty == true;

    if (hasFirst && hasLast) {
      return '$trimmedFirst $trimmedLast';
    }
    if (hasFirst) {
      return trimmedFirst!;
    }
    if (hasLast) {
      return trimmedLast!;
    }
    if (hasOrganization) {
      return trimmedOrganization!;
    }
    return 'Unknown Contact';
  }

  bool? _nullableBool(int? value) {
    if (value == null) {
      return null;
    }
    if (value == 1) {
      return true;
    }
    if (value == 0) {
      return false;
    }
    return null;
  }

  String? _decodeOptionalBlob(Object? blob) {
    if (blob is Uint8List) {
      try {
        return utf8.decode(blob, allowMalformed: true);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _inferItemType(Map<String, Object?> row) {
    final text = row['text'] as String?;
    final associated = row['associated_message_guid'] as String?;
    final balloonId = row['balloon_bundle_id'] as String?;
    if (associated != null && associated.isNotEmpty) {
      return 'reaction-carrier';
    }
    if (balloonId != null && balloonId.isNotEmpty) {
      return 'sticker';
    }
    if (text == null || text.isEmpty) {
      return 'attachment-only';
    }
    return 'text';
  }

  /// Apply ignore flags to spam handles, chats, and messages post-import
  Future<void> _applySpamIgnoreFlags({
    required SqfliteImportDatabase ledgerDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);

    // Step 1: Flag spam handles
    emit(DbImportStage.completed, 0.96, 'Flagging spam handles...');
    final spamHandleIds = await _flagSpamHandles(ledgerDb, debugSettings);

    // Step 2: Flag chats associated with spam handles
    emit(DbImportStage.completed, 0.97, 'Flagging spam chats...');
    final spamChatIds = await _flagSpamChats(
      ledgerDb,
      spamHandleIds,
      debugSettings,
    );

    // Step 3: Flag messages in spam chats
    emit(DbImportStage.completed, 0.98, 'Flagging spam messages...');
    await _flagSpamMessages(ledgerDb, spamChatIds, debugSettings);

    debugSettings.logProgress(
      '$_importLogContext: Applied ignore flags - ${spamHandleIds.length} handles, ${spamChatIds.length} chats flagged as spam',
    );
  }

  /// Flag handles that appear to be spam (short codes, suspicious identifiers)
  Future<List<int>> _flagSpamHandles(
    SqfliteImportDatabase ledgerDb,
    ImportDebugSettingsState debugSettings,
  ) async {
    // Get all handles and check for spam patterns
    final handles = await ledgerDb.getAllHandles();
    final spamHandleIds = <int>[];

    for (final handle in handles) {
      final id = handle['id'] as int?;
      final rawIdentifier = handle['raw_identifier'] as String?;
      final normalizedIdentifier = handle['normalized_identifier'] as String?;

      if (id == null) {
        continue;
      }

      if (_isSpamIdentifier(normalizedIdentifier, rawIdentifier)) {
        spamHandleIds.add(id);
        await ledgerDb.flagHandleAsIgnored(id);
      }
    }

    return spamHandleIds;
  }

  /// Flag chats that only involve spam handles
  Future<List<int>> _flagSpamChats(
    SqfliteImportDatabase ledgerDb,
    List<int> spamHandleIds,
    ImportDebugSettingsState debugSettings,
  ) async {
    if (spamHandleIds.isEmpty) {
      return <int>[];
    }

    // Find chats that only have spam handles as participants
    final spamChatIds = await ledgerDb.getChatsWithOnlySpamHandles(
      spamHandleIds,
    );

    for (final chatId in spamChatIds) {
      await ledgerDb.flagChatAsIgnored(chatId);
    }

    return spamChatIds;
  }

  /// Flag messages in spam chats
  Future<void> _flagSpamMessages(
    SqfliteImportDatabase ledgerDb,
    List<int> spamChatIds,
    ImportDebugSettingsState debugSettings,
  ) async {
    if (spamChatIds.isEmpty) {
      return;
    }

    await ledgerDb.flagMessagesInChatsAsIgnored(spamChatIds);
  }

  /// Check if an identifier appears to be spam
  bool _isSpamIdentifier(String? normalizedIdentifier, String? rawIdentifier) {
    if (normalizedIdentifier == null || normalizedIdentifier.isEmpty) {
      return false;
    }

    // If it has @ symbol, it's an email - not spam
    if (rawIdentifier?.contains('@') ?? false) {
      return false;
    }

    // Check for suspicious patterns:
    // 1. Short numeric codes (4-9 digits) - typical spam short codes
    // 2. Single words without numbers (like "claiee")
    final digitsOnly = normalizedIdentifier.replaceAll(RegExp(r'[^0-9]'), '');

    // Spam pattern 1: Short codes (4-9 digit numbers)
    if (digitsOnly.length >= 4 &&
        digitsOnly.length <= 9 &&
        digitsOnly == normalizedIdentifier) {
      return true;
    }

    // Spam pattern 2: Single word identifiers (no @ symbol, no digits, short length)
    if (digitsOnly.isEmpty &&
        !normalizedIdentifier.contains('@') &&
        normalizedIdentifier.length <= 8 &&
        normalizedIdentifier.isNotEmpty) {
      return true;
    }

    return false;
  }
}

class _DbImportResultBuilder {
  _DbImportResultBuilder({required this.batchId});

  final int batchId;
  int handlesImported = 0;
  int chatsImported = 0;
  int participantsImported = 0;
  int messagesImported = 0;
  int attachmentsImported = 0;
  int messageAttachmentsImported = 0;
  int reactionsImported = 0;
  int contactChannelsImported = 0;
  int contactsImported = 0;
  String? error;
  final List<String> warnings = <String>[];

  DbImportResult build({required bool success}) {
    return DbImportResult(
      batchId: batchId,
      success: success,
      error: error,
      handlesImported: handlesImported,
      chatsImported: chatsImported,
      participantsImported: participantsImported,
      messagesImported: messagesImported,
      attachmentsImported: attachmentsImported,
      messageAttachmentsImported: messageAttachmentsImported,
      reactionsImported: reactionsImported,
      contactChannelsImported: contactChannelsImported,
      contactsImported: contactsImported,
      warnings: warnings,
    );
  }
}

class _ChatMessageJoinCache {
  _ChatMessageJoinCache.enabled(Map<int, int> cache) : _messageToChat = cache;

  _ChatMessageJoinCache.disabled() : _messageToChat = <int, int>{};

  final Map<int, int> _messageToChat;

  bool get isEnabled => _messageToChat.isNotEmpty;

  Future<int?> resolveChatId({
    required Database messagesDb,
    required int messageId,
  }) async {
    final cached = _messageToChat[messageId];
    if (cached != null) {
      return cached;
    }

    if (isEnabled) {
      return null;
    }

    final rows = await messagesDb.query(
      'chat_message_join',
      columns: <String>['chat_id'],
      where: 'message_id = ?',
      whereArgs: <Object>[messageId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final value = rows.first['chat_id'];
    final chatId = value is int
        ? value
        : value is num
        ? value.toInt()
        : int.tryParse('$value');
    if (chatId != null) {
      _messageToChat[messageId] = chatId;
    }
    return chatId;
  }
}

class _RichTextExtraction {
  const _RichTextExtraction({required this.messages});

  final Map<int, String> messages;
}

class _MessageImportResult {
  const _MessageImportResult({
    required this.scannedCount,
    required this.insertedCount,
    required this.insertedSourceRowIds,
    required this.extractionCandidates,
    required this.messageToChat,
  });

  const _MessageImportResult.empty()
    : scannedCount = 0,
      insertedCount = 0,
      insertedSourceRowIds = const <int>[],
      extractionCandidates = const <int>{},
      messageToChat = const <int, int>{};

  final int scannedCount;
  final int insertedCount;
  final List<int> insertedSourceRowIds;
  final Set<int> extractionCandidates;
  final Map<int, int> messageToChat;
}

class _AttachmentCounts {
  const _AttachmentCounts({
    required this.attachments,
    required this.messageAttachments,
  });

  final int attachments;
  final int messageAttachments;
}
