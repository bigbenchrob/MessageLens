import '../../domain/ports/message_extractor_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../attachments/attachment_importer.dart';
import '../chat_handle_joins/chat_handle_join_importer.dart';
import '../chat_message_joins/chat_message_join_importer.dart';
import '../chats/chat_importer.dart';
import '../handles/handle_importer.dart';
import '../message_attachment_joins/message_attachment_join_importer.dart';
import '../messages/message_importer.dart';
import '../messages/message_rich_text_enricher.dart';
import '../source_import_page_metric.dart';
import 'historical_messages_archive_source_registrar.dart';

final class SourceScopedArchiveImportResult {
  const SourceScopedArchiveImportResult({
    required this.registration,
    required this.messages,
    required this.chats,
    required this.handles,
    required this.attachments,
    required this.chatMessageEdges,
    required this.chatHandleEdges,
    required this.messageAttachmentEdges,
    required this.textEnrichment,
  });

  final HistoricalMessagesArchiveSourceRegistration registration;
  final MessageImportResult messages;
  final ChatImportResult chats;
  final HandleImportResult handles;
  final AttachmentImportResult attachments;
  final ChatMessageJoinImportResult chatMessageEdges;
  final ChatHandleJoinImportResult chatHandleEdges;
  final MessageAttachmentJoinImportResult messageAttachmentEdges;
  final MessageRichTextEnrichmentResult textEnrichment;

  int get insertedSourceFactCount {
    return messages.insertedMessageCount +
        chats.insertedChatCount +
        handles.insertedHandleCount +
        attachments.insertedAttachmentCount;
  }

  int get insertedTopologyEdgeCount {
    return chatMessageEdges.insertedJoinCount +
        chatHandleEdges.insertedJoinCount +
        messageAttachmentEdges.insertedJoinCount;
  }
}

class SourceScopedArchiveImportService {
  const SourceScopedArchiveImportService({
    required this.registrar,
    required this.richTextExtractor,
    required this.sourceDatabaseOpener,
    this.onPageMetric,
  });

  final HistoricalMessagesArchiveSourceRegistrar registrar;
  final MessageExtractorPort richTextExtractor;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final SourceImportPageMetricObserver? onPageMetric;

  Future<SourceScopedArchiveImportResult> importSourceFacts({
    required String folderPath,
    String? sourceLabel,
  }) async {
    final registration = await registrar.registerFolder(
      folderPath: folderPath,
      sourceLabel: sourceLabel,
    );
    final sourceId = registration.sourceId;
    final chatDbPath = registration.chatDbPath;
    final importLedger = registrar.importLedger;

    final handles = await HandleImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
    ).importNewHandles();
    final chats = await ChatImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
    ).importChats();
    final messages = await MessageImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
      onPageMetric: onPageMetric,
    ).importNewMessages();
    final attachments = await AttachmentImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
    ).importAttachments();
    final chatHandleEdges = await ChatHandleJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
    ).importJoins();
    final chatMessageEdges = await ChatMessageJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
    ).importJoins();
    final messageAttachmentEdges = await MessageAttachmentJoinImporter(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      sourceDatabaseOpener: sourceDatabaseOpener,
      sourceId: sourceId,
    ).importJoins();
    final textEnrichment = await MessageRichTextEnricher(
      chatDbPath: chatDbPath,
      importLedger: importLedger,
      extractor: richTextExtractor,
      onPageMetric: onPageMetric,
    ).enrichMissingTextForSource(sourceId: sourceId);

    return SourceScopedArchiveImportResult(
      registration: registration,
      messages: messages,
      chats: chats,
      handles: handles,
      attachments: attachments,
      chatMessageEdges: chatMessageEdges,
      chatHandleEdges: chatHandleEdges,
      messageAttachmentEdges: messageAttachmentEdges,
      textEnrichment: textEnrichment,
    );
  }
}
