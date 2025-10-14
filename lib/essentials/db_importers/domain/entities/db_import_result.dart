/// Final outcome of a ledger import run, including inserted row counts and
/// emitted warnings.
class DbImportResult {
  const DbImportResult({
    required this.batchId,
    required this.success,
    this.error,
    this.handlesImported = 0,
    this.chatsImported = 0,
    this.participantsImported = 0,
    this.messagesImported = 0,
    this.attachmentsImported = 0,
    this.messageAttachmentsImported = 0,
    this.reactionsImported = 0,
    this.contactChannelsImported = 0,
    this.contactsImported = 0,
    this.warnings = const <String>[],
  });

  /// Identifier of the `import_batches` row backing this run.
  final int batchId;

  /// Overall success flag.
  final bool success;

  /// Optional fatal error string.
  final String? error;

  final int handlesImported;
  final int chatsImported;
  final int participantsImported;
  final int messagesImported;
  final int attachmentsImported;
  final int messageAttachmentsImported;
  final int reactionsImported;
  final int contactChannelsImported;
  final int contactsImported;

  final List<String> warnings;

  DbImportResult copyWith({
    bool? success,
    String? error,
    int? handlesImported,
    int? chatsImported,
    int? participantsImported,
    int? messagesImported,
    int? attachmentsImported,
    int? messageAttachmentsImported,
    int? reactionsImported,
    int? contactChannelsImported,
    int? contactsImported,
    List<String>? warnings,
  }) {
    return DbImportResult(
      batchId: batchId,
      success: success ?? this.success,
      error: error ?? this.error,
      handlesImported: handlesImported ?? this.handlesImported,
      chatsImported: chatsImported ?? this.chatsImported,
      participantsImported: participantsImported ?? this.participantsImported,
      messagesImported: messagesImported ?? this.messagesImported,
      attachmentsImported: attachmentsImported ?? this.attachmentsImported,
      messageAttachmentsImported:
          messageAttachmentsImported ?? this.messageAttachmentsImported,
      reactionsImported: reactionsImported ?? this.reactionsImported,
      contactChannelsImported:
          contactChannelsImported ?? this.contactChannelsImported,
      contactsImported: contactsImported ?? this.contactsImported,
      warnings: warnings ?? this.warnings,
    );
  }

  Map<String, Object?> toSummaryMap() {
    return <String, Object?>{
      'batch_id': batchId,
      'success': success,
      'error': error,
      'warnings': warnings,
      'handles_imported': handlesImported,
      'chats_imported': chatsImported,
      'participants_imported': participantsImported,
      'messages_imported': messagesImported,
      'attachments_imported': attachmentsImported,
      'message_attachments_imported': messageAttachmentsImported,
      'reactions_imported': reactionsImported,
      'contact_channels_imported': contactChannelsImported,
      'contacts_imported': contactsImported,
    };
  }
}
