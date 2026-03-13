import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../features/address_book_folders/feature_level_providers.dart';
import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../logging/application/import_audit_writer.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/i_importers.dart/table_importer.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/states/table_import_progress.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import '../debug_settings_provider.dart';
import '../importers/attachments_importer.dart';
import '../importers/chat_to_handle_importer.dart';
import '../importers/chat_to_message_importer.dart';
import '../importers/chats_importer.dart';
import '../importers/clear_ledger_importer.dart';
import '../importers/contact_channels_importer.dart';
import '../importers/contact_to_chat_handle_importer.dart';
import '../importers/contacts_importer.dart';
import '../importers/handles_importer.dart';
import '../importers/message_attachments_importer.dart';
import '../importers/message_rich_text_importer.dart';
import '../importers/messages_importer.dart';
import '../importers/prepare_sources_importer.dart';
import '../orchestrator/import_orchestrator.dart';

typedef ExecutionPlanCallback = void Function(List<ImporterStep> steps);

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
    ExecutionPlanCallback? onExecutionPlan,
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
      final message = 'Messages database not found at $messagesDbPath';
      debugSettings.logError('$_logContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }
    if (!addressBookFile.existsSync()) {
      final message =
          'AddressBook database not found at ${addressBookFile.path}';
      debugSettings.logError('$_logContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    final startedAtUtc = DateTime.now().toUtc().toIso8601String();

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
        const PrepareSourcesImporter(),
        const ClearLedgerImporter(),
        HandlesImporter(),
        ChatsImporter(),
        ChatToHandleImporter(),
        ContactsImporter(),
        ContactChannelsImporter(),
        ContactToChatHandleImporter(),
        MessagesImporter(),
        MessageRichTextImporter(),
        ChatToMessageImporter(),
        AttachmentsImporter(),
        MessageAttachmentsImporter(),
      ];

      final orchestrator = ImportOrchestrator(importers);

      // Communicate the execution plan to the UI before running.
      onExecutionPlan?.call(orchestrator.executionOrder());

      await orchestrator.run(context, onTableProgress: onTableProgress);

      debugSettings.logProgress(
        '$_logContext: Ledger import completed successfully',
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

      // Write detailed audit log
      try {
        await const ImportAuditWriter().writeReport(
          messagesDb: messagesDb,
          addressBookDb: addressBookDb,
          importDb: ledgerDb,
          scratchpad: scratchpad,
          batchId: batchId,
          startedAt: startedAtUtc,
          success: true,
          hasExistingLedgerData: hasExistingLedgerData,
          previousMaxMessageRowId: previousMaxMessageRowId,
        );
      } catch (auditError) {
        debugSettings.logProgress(
          '$_logContext: audit log write failed (non-fatal): $auditError',
        );
      }

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

      // Write audit log even on failure — source DBs may already be closed
      if (messagesDb != null && addressBookDb != null) {
        try {
          await const ImportAuditWriter().writeReport(
            messagesDb: messagesDb,
            addressBookDb: addressBookDb,
            importDb: ledgerDb,
            scratchpad: scratchpad,
            batchId: batchId,
            startedAt: startedAtUtc,
            success: false,
            errorMessage: '$error',
            hasExistingLedgerData: hasExistingLedgerData,
            previousMaxMessageRowId: previousMaxMessageRowId,
          );
        } catch (_) {
          // Audit logging is best-effort; don't mask the real error.
        }
      }

      return DbImportResult(batchId: batchId, success: false, error: '$error');
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
