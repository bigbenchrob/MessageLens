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
import '../../domain/entities/db_import_result.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/states/db_import_progress.dart';
import '../../domain/value_objects/db_import_stage.dart';
import '../debug_settings_provider.dart';

typedef DbImportProgressCallback = void Function(DbImportProgress progress);

/// Coordinates a full ingest from macOS `chat.db` and AddressBook into the
/// Sqflite ledger database (`macos_import.db`).
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

    emit(DbImportStage.preparingSources, 0.02, 'Preparing source metadata');

    emit(
      DbImportStage.clearingLedger,
      0.05,
      hasExistingLedgerData
          ? 'Preparing ledger for incremental append'
          : 'Initializing ledger import tables',
    );
    if (!hasExistingLedgerData) {
      await ledgerDb.clearAllData();
    }

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

      resultBuilder.handlesImported = await _importHandles(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
        minSourceRowIdExclusive: previousMaxHandleRowId,
      );

      resultBuilder.chatsImported = await _importChats(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
        minSourceRowIdExclusive: previousMaxChatRowId,
      );

      resultBuilder.participantsImported = await _importChatParticipants(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
      );

      final chatJoinCache = await _buildChatMessageJoinCache(
        messagesDb: messagesDb,
        cachingEnabled: debugSettings.ledgerRowCachingEnabled,
        debugSettings: debugSettings,
      );

      final extraction = await _extractRichText(
        extractor: extractor,
        messagesDbPath: messagesDbPath,
        messagesDb: messagesDb,
      );

      final messageImportResult = await _importMessages(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        chatJoinCache: chatJoinCache,
        extraction: extraction,
        emit: emit,
        minSourceRowIdExclusive: previousMaxMessageRowId,
      );
      resultBuilder.messagesImported = messageImportResult.insertedCount;

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
        'No new handles detected',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return 0;
    }

    emit(
      DbImportStage.importingHandles,
      0.1,
      'Importing ${rows.length} new handles',
      stageProgress: 0,
      stageTotal: rows.length,
    );

    var processed = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final rawIdentifier = (row['id'] as String?)?.trim();
      final normalizedAddress = _normalizeIdentifier(rawIdentifier);
      final service = (row['service'] as String?)?.trim();
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
        service: service ?? 'Unknown',
        rawIdentifier: rawIdentifier ?? 'unknown',
        normalizedIdentifier: normalizedAddress,
        country: country,
        lastSeenUtc: lastSeenUtc,
        batchId: batchId,
      );

      processed++;
      if (processed % 200 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingHandles,
          0.12,
          'Imported $processed/${rows.length} handles',
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
        'No new chats detected',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return 0;
    }

    emit(
      DbImportStage.importingChats,
      0.18,
      'Importing ${rows.length} new chats',
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
          'Imported $processed/${rows.length} new chats',
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
      'Importing chat participants',
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
            'Linked $inserted/${rows.length} participants',
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
          'Linked $inserted/${rows.length} participants',
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
  }) async {
    final rows = await messagesDb.query('message');
    final blobMessageIds = <int>[];
    for (final row in rows) {
      final rowId = row['ROWID'] as int?;
      if (rowId == null) {
        continue;
      }
      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      if ((text == null || text.isEmpty) && attributed != null) {
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
      return _RichTextExtraction(messages: extracted);
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
    required _RichTextExtraction extraction,
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
      'Scanning for new messages',
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
        'No new messages to import',
        stageProgress: 1,
        stageCurrent: 0,
        stageTotal: 0,
      );
      return const _MessageImportResult.empty();
    }

    emit(
      DbImportStage.importingMessages,
      0.4,
      'Importing ${rows.length} messages',
      stageProgress: 0,
      stageTotal: rows.length,
    );
    var processed = 0;
    var inserted = 0;
    final insertedSourceRowIds = <int>{};

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
      final extractedText = extraction.messages[sourceRowId];
      final resolvedText = (text == null || text.isEmpty)
          ? extractedText
          : text;

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
        await ledgerDb.insertChatMessageJoinSource(
          chatId: chatId,
          messageId: sourceRowId,
          sourceRowid: sourceRowId,
        );
      }

      processed++;
      if (processed % 500 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingMessages,
          0.52,
          'Processed $processed/${rows.length} messages'
          ' ($inserted inserted)',
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
    );
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
      0.6,
      'Scanning for new attachments',
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
        0.6,
        'No new attachments detected',
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
          0.66,
          'Processed $processedAttachments/${attachments.length} attachments'
          ' ($insertedAttachments inserted)',
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
        0.7,
        'No new message attachments to link',
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
        'No new message attachments to link',
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
      0.7,
      'Linking $totalPairs message attachments',
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
          0.72,
          'Linked $linkedPairs/$totalPairs message attachments',
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
    emit(DbImportStage.importingAddressBook, 0.78, 'Importing contacts');
    final rows = await addressBookDb.query('ZABCDRECORD');
    var processed = 0;
    var inserted = 0;
    for (final row in rows) {
      final recordId = row['Z_PK'] as int?;
      if (recordId == null) {
        processed++;
        continue;
      }
      final first = row['ZFIRSTNAME'] as String?;
      final last = row['ZLASTNAME'] as String?;
      final company = row['ZORGANIZATION'] as String?;
      final isCompany = (row['ZISCOMPANY'] as int? ?? 0) == 1;

      processed++;
      final alreadyImported = await ledgerDb.contactExists(recordId);
      if (alreadyImported) {
        if (processed % 200 == 0 || processed == rows.length) {
          emit(
            DbImportStage.importingAddressBook,
            0.82,
            'Imported $inserted/${rows.length} contacts',
            stageProgress: rows.isEmpty ? 1 : processed / rows.length,
            stageCurrent: inserted,
            stageTotal: rows.length,
          );
        }
        continue;
      }

      await ledgerDb.insertContact(
        id: recordId,
        sourceRecordId: recordId,
        displayName: _buildDisplayName(first, last, company, isCompany),
        givenName: first,
        familyName: last,
        organization: company,
        isOrganization: isCompany,
        createdAtUtc: DateConverter.appleToIsoString(row['ZCREATIONDATE']),
        updatedAtUtc: DateConverter.appleToIsoString(row['ZMODIFICATIONDATE']),
        batchId: batchId,
      );
      inserted++;
      if (processed % 200 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingAddressBook,
          0.82,
          'Imported $inserted/${rows.length} contacts',
          stageProgress: rows.isEmpty ? 1 : processed / rows.length,
          stageCurrent: inserted,
          stageTotal: rows.length,
        );
      }
    }
    return inserted;
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
      'Importing contact channels',
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
        contactId: recordId,
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
      final value = (row['ZFULLNUMBER'] as String?)?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      final normalizedValue = _normalizeIdentifier(value) ?? value;
      final alreadyImported = await ledgerDb.contactChannelExists(
        kind: 'phone',
        value: normalizedValue,
      );
      if (alreadyImported) {
        continue;
      }
      await ledgerDb.insertContactChannel(
        contactId: recordId,
        kind: 'phone',
        value: normalizedValue,
        label: row['ZLABEL'] as String?,
      );
      insertedChannels++;
    }

    emit(
      DbImportStage.importingAddressBook,
      0.9,
      'Imported $insertedChannels contact channels',
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

  String? _buildDisplayName(
    String? first,
    String? last,
    String? company,
    bool isCompany,
  ) {
    if (isCompany) {
      return company ?? 'Unknown';
    }
    if (first != null && last != null) {
      return '$first $last'.trim();
    }
    return first ?? last ?? company ?? 'Unknown';
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
  });

  const _MessageImportResult.empty()
    : scannedCount = 0,
      insertedCount = 0,
      insertedSourceRowIds = const <int>[];

  final int scannedCount;
  final int insertedCount;
  final List<int> insertedSourceRowIds;
}

class _AttachmentCounts {
  const _AttachmentCounts({
    required this.attachments,
    required this.messageAttachments,
  });

  final int attachments;
  final int messageAttachments;
}
