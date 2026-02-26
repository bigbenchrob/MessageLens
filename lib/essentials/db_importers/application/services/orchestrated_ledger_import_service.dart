import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../features/address_book_folders/feature_level_providers.dart';
import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/i_importers.dart/table_importer.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/states/db_import_progress.dart';
import '../../domain/states/table_import_progress.dart';
import '../../domain/value_objects/db_import_stage.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import '../debug_settings_provider.dart';
import '../importers/attachments_importer.dart';
import '../importers/chat_to_handle_importer.dart';
import '../importers/chat_to_message_importer.dart';
import '../importers/chats_importer.dart';
import '../importers/contact_channels_importer.dart';
import '../importers/contact_to_chat_handle_importer.dart';
import '../importers/contacts_importer.dart';
import '../importers/handles_importer.dart';
import '../importers/message_attachments_importer.dart';
import '../importers/message_rich_text_importer.dart';
import '../importers/messages_importer.dart';
import '../orchestrator/import_orchestrator.dart';

typedef DbImportProgressCallback = void Function(DbImportProgress progress);

class OrchestratedLedgerImportService {
  OrchestratedLedgerImportService({
    required this.ref,
    required MessageExtractorPort extractor,
    this.rustExtractionLimit = 200000,
  }) : _extractor = extractor;

  final Ref ref;
  // ignore: unused_field
  final MessageExtractorPort _extractor;
  final int rustExtractionLimit;

  static const String _logContext = 'OrchestratedLedgerImportService';

  Future<DbImportResult> runImport({
    DbImportProgressCallback? onProgress,
    TableImportProgressCallback? onTableProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledgerDb = await ref.watch(sqfliteImportDatabaseProvider.future);
    final pathsHelper = await ref.watch(pathsHelperProvider.future);

    var previousMaxHandleRowId = await ledgerDb.maxHandleSourceRowId();
    var previousMaxChatRowId = await ledgerDb.maxChatSourceRowId();
    var previousMaxMessageRowId = await ledgerDb.maxMessageSourceRowId();
    var previousMaxAttachmentRowId = await ledgerDb.maxAttachmentSourceRowId();
    var previousMaxMessageAttachmentRowId = await ledgerDb
        .maxMessageAttachmentSourceRowId();

    var hasExistingLedgerData =
        previousMaxHandleRowId != null ||
        previousMaxChatRowId != null ||
        previousMaxMessageRowId != null ||
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
          '$_logContext: Detected truncated message set, forcing full reimport.',
        );
        previousMaxHandleRowId = null;
        previousMaxChatRowId = null;
        previousMaxMessageRowId = null;
        previousMaxAttachmentRowId = null;
        previousMaxMessageAttachmentRowId = null;
        hasExistingLedgerData = false;
      }
    }

    final messagesDbPath = pathsHelper.chatDBPath;
    final addressBookEither = await ref.watch(
      futureGetFolderAggregateProvider.future,
    );
    String? addressBookPath;
    addressBookEither.fold(
      (_) {},
      (aggregate) => addressBookPath = aggregate.mostRecentFolderPath,
    );
    if (addressBookPath == null) {
      onProgress?.call(
        const DbImportProgress(
          stage: DbImportStage.preparingSources,
          overallProgress: 0.0,
          message: 'AddressBook path resolution failed',
        ),
      );
      const failureMessage =
          'AddressBook path could not be resolved via getFolderAggregateEitherProvider';
      debugSettings.logError('$_logContext: $failureMessage');
      return const DbImportResult(
        batchId: -1,
        success: false,
        error: 'AddressBook path resolution failed',
      );
    }

    final messagesFile = File(messagesDbPath);
    final addressBookFile = File(addressBookPath!);
    if (!messagesFile.existsSync()) {
      onProgress?.call(
        DbImportProgress(
          stage: DbImportStage.preparingSources,
          overallProgress: 0.0,
          message: 'Messages database not found at $messagesDbPath',
        ),
      );
      final message = 'Messages database not found at $messagesDbPath';
      debugSettings.logError('$_logContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }
    if (!addressBookFile.existsSync()) {
      onProgress?.call(
        DbImportProgress(
          stage: DbImportStage.preparingSources,
          overallProgress: 0.0,
          message: 'AddressBook database not found at ${addressBookFile.path}',
        ),
      );
      final message =
          'AddressBook database not found at ${addressBookFile.path}';
      debugSettings.logError('$_logContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
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
          overallProgress: progress.clamp(0.0, 1.0),
          message: message,
          stageProgress: stageProgress,
          stageCurrent: stageCurrent,
          stageTotal: stageTotal,
        ),
      );
      if (stage == DbImportStage.completed) {
        debugSettings.logProgress('$_logContext: $message');
      }
    }

    emit(DbImportStage.preparingSources, 0.02, 'Preparing import sources');

    if (!hasExistingLedgerData) {
      emit(
        DbImportStage.clearingLedger,
        0.05,
        'Clearing existing ledger data (fresh import)',
      );
      await ledgerDb.clearAllData();
    } else {
      emit(
        DbImportStage.clearingLedger,
        0.05,
        'Preparing ledger for incremental append',
      );
    }

    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: messagesDbPath,
      sourceAddressbook: addressBookFile.path,
      hostInfoJson: await _buildHostInfoJson(),
      notes: 'Orchestrated import ${DateTime.now().toIso8601String()}',
    );
    if (hasExistingLedgerData) {
      await ledgerDb.assignExistingRecordsToBatch(batchId: batchId);
    }

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

    final scratchpad = <String, Object?>{};

    try {
      messagesDb = await openDatabase(messagesFile.path, readOnly: true);
      addressBookDb = await openDatabase(addressBookFile.path, readOnly: true);

      final context = ImportContextSqlite(
        importDb: ledgerDb,
        messagesDb: messagesDb,
        messagesDbPath: messagesFile.path,
        addressBookDb: addressBookDb,
        batchId: batchId,
        log: debugSettings.logProgress,
        extractor: _extractor,
        rustExtractionLimit: rustExtractionLimit,
        previousMaxHandleRowId: previousMaxHandleRowId,
        previousMaxChatRowId: previousMaxChatRowId,
        previousMaxMessageRowId: previousMaxMessageRowId,
        previousMaxAttachmentRowId: previousMaxAttachmentRowId,
        previousMaxMessageAttachmentRowId: previousMaxMessageAttachmentRowId,
        hasExistingLedgerData: hasExistingLedgerData,
        scratchpad: scratchpad,
      );

      final importers = <TableImporter>[
        const HandlesImporter(),
        const ChatsImporter(),
        const ChatToHandleImporter(),
        const ContactsImporter(),
        const ContactChannelsImporter(),
        const ContactToChatHandleImporter(),
        MessagesImporter(),
        const MessageRichTextImporter(),
        const ChatToMessageImporter(),
        const AttachmentsImporter(),
        const MessageAttachmentsImporter(),
      ];

      final orchestrator = ImportOrchestrator(importers);
      final phaseWeights = _phaseWeights(importers.length);
      var completedWeight = 0.15;

      void handleTableEvent(TableImportProgressEvent event) {
        final stage = _stageForImporter(event.importerName);
        final phaseWeight = phaseWeights[event.phase] ?? 0.0;
        final message = _messageForPhase(event);
        var progressValue = completedWeight;

        switch (event.status) {
          case TableImportStatus.started:
          case TableImportStatus.inProgress:
            progressValue += phaseWeight * 0.1;
            break;
          case TableImportStatus.succeeded:
            completedWeight += phaseWeight;
            progressValue = completedWeight;
            break;
          case TableImportStatus.failed:
            break;
        }

        final normalized = min(progressValue, 0.9);
        emit(stage, normalized, message);
        onTableProgress?.call(event);
      }

      await orchestrator.run(context, onTableProgress: handleTableEvent);

      emit(
        DbImportStage.completed,
        1.0,
        'Ledger import completed successfully',
      );

      await ledgerDb.updateImportBatch(
        id: batchId,
        finishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        notes: 'Completed orchestrated import',
      );

      final handlesImported = context.readScratch<int>('handles.inserted') ?? 0;
      final chatsImported = context.readScratch<int>('chats.inserted') ?? 0;
      final chatMembershipsImported =
          context.readScratch<int>('chatMemberships.inserted') ?? 0;
      final contactsImported =
          context.readScratch<int>('contacts.inserted') ?? 0;
      final contactChannelsImported =
          context.readScratch<int>('contactChannels.inserted') ?? 0;
      final contactLinksImported =
          context.readScratch<int>('contactHandleLinks.inserted') ?? 0;
      final messagesImported =
          context.readScratch<int>('messages.inserted') ?? 0;
      final richTextApplied =
          context.readScratch<int>('messages.richTextApplied') ?? 0;
      final chatMessageLinks =
          context.readScratch<int>('chatToMessage.inserted') ?? 0;
      final attachmentsImported =
          context.readScratch<int>('attachments.inserted') ?? 0;
      final messageAttachmentLinks =
          context.readScratch<int>('messageAttachments.inserted') ?? 0;

      final handlesCount = await ledgerDb.countRows('handles');
      final chatsCount = await ledgerDb.countRows('chats');
      final membershipsCount = await ledgerDb.countRows('chat_to_handle');
      final messagesCount = await ledgerDb.countRows('messages');
      final chatMessageJoinCount = await ledgerDb.countRows('chat_to_message');
      final attachmentsCount = await ledgerDb.countRows('attachments');
      final messageAttachmentsCount = await ledgerDb.countRows(
        'message_attachments',
      );
      final contactsCount = await ledgerDb.countRows('contacts');
      final contactChannelsCount = await ledgerDb.countRows(
        'contact_phone_email',
      );
      final contactLinksCount = await ledgerDb.countRows(
        'contact_to_chat_handle',
      );

      return DbImportResult(
        batchId: batchId,
        success: true,
        handlesImported: handlesImported,
        chatsImported: chatsImported,
        participantsImported: chatMembershipsImported,
        messagesImported: messagesImported,
        attachmentsImported: attachmentsImported,
        messageAttachmentsImported: messageAttachmentLinks,
        contactsImported: contactsImported,
        contactChannelsImported: contactChannelsImported,
        warnings: <String>[
          'Handles table row count: $handlesCount',
          'Chats table row count: $chatsCount',
          'Chat memberships row count: $membershipsCount',
          'Messages table row count: $messagesCount',
          'Chat/message links row count: $chatMessageJoinCount',
          'Attachments table row count: $attachmentsCount',
          'Message/attachment links row count: $messageAttachmentsCount',
          'Contacts table row count: $contactsCount',
          'Contact channels row count: $contactChannelsCount',
          'Contact-to-handle links row count: $contactLinksCount',
          'Messages inserted this run: $messagesImported (rich text applied: $richTextApplied)',
          'Chat/message links inserted this run: $chatMessageLinks',
          'Attachments inserted this run: $attachmentsImported',
          'Message/attachment links inserted this run: $messageAttachmentLinks',
          'Contact links inserted this run: $contactLinksImported',
        ],
      );
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: import failed: $error');
      debugSettings.logProgress(stackTrace.toString());
      emit(DbImportStage.completed, 1.0, 'Ledger import failed: $error');
      return DbImportResult(batchId: batchId, success: false, error: '$error');
    } finally {
      await messagesDb?.close();
      await addressBookDb?.close();
    }
  }

  Map<TableImportPhase, double> _phaseWeights(int importerCount) {
    if (importerCount == 0) {
      return const <TableImportPhase, double>{};
    }
    const base = <TableImportPhase, double>{
      TableImportPhase.validatePrereqs: 0.2,
      TableImportPhase.copy: 0.5,
      TableImportPhase.postValidate: 0.15,
    };
    return {
      for (final entry in base.entries)
        entry.key: (entry.value / importerCount),
    };
  }

  DbImportStage _stageForImporter(String importerName) {
    switch (importerName) {
      case 'handles':
        return DbImportStage.importingHandles;
      case 'chats':
        return DbImportStage.importingChats;
      case 'chat_to_handle':
        return DbImportStage.importingParticipants;
      case 'messages':
        return DbImportStage.importingMessages;
      case 'message_rich_text':
        return DbImportStage.extractingRichContent;
      case 'chat_to_message':
        return DbImportStage.linkingMessageArtifacts;
      case 'attachments':
        return DbImportStage.importingAttachments;
      case 'message_attachments':
        return DbImportStage.linkingMessageArtifacts;
      case 'contacts':
        return DbImportStage.importingAddressBook;
      case 'contact_phone_email':
        return DbImportStage.importingAddressBook;
      case 'contact_to_chat_handle':
        return DbImportStage.linkingContacts;
      default:
        return DbImportStage.importingMessages;
    }
  }

  String _messageForPhase(TableImportProgressEvent event) {
    final displayName = event.displayName;
    switch (event.phase) {
      case TableImportPhase.validatePrereqs:
        return 'Validating $displayName prerequisites';
      case TableImportPhase.copy:
        return 'Copying $displayName';
      case TableImportPhase.postValidate:
        return 'Verifying $displayName';
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
    } catch (_) {}
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
}
