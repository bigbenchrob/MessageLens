import 'package:drift/drift.dart' as drift;

import '../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../shared/hydration/attachment_info.dart';
import '../shared/hydration/attachment_info_loader.dart';
import '../shared/hydration/messages_for_handle_provider.dart';

class MessageRowMapper {
  MessageRowMapper(this._db, this._displayNameOverrides);

  final WorkingDatabase _db;
  final Map<int, String> _displayNameOverrides;

  Future<List<MessageListItem>> mapRows(List<drift.TypedResult> rows) async {
    if (rows.isEmpty) {
      return const [];
    }

    final results = <MessageListItem>[];

    for (final row in rows) {
      final message = row.readTable(_db.workingMessages);
      final participant = row.readTableOrNull(_db.workingParticipants);

      // Fetch attachments for this message if it has any
      final attachments = message.hasAttachments
          ? await loadAttachmentsForMessage(_db, message.guid)
          : <AttachmentInfo>[];

      results.add(
        MessageListItem(
          id: message.id,
          guid: message.guid,
          isFromMe: message.isFromMe,
          senderName: _senderNameForMessage(
            isFromMe: message.isFromMe,
            participant: participant,
          ),
          text: message.textContent ?? '',
          sentAt: _parseUtc(message.sentAtUtc),
          hasAttachments: message.hasAttachments,
          attachments: attachments,
        ),
      );
    }

    return results;
  }

  DateTime? _parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  String _senderNameForMessage({
    required bool isFromMe,
    required WorkingParticipant? participant,
  }) {
    if (isFromMe) {
      return 'You';
    }
    if (participant == null) {
      return 'Unknown sender';
    }
    final override = _displayNameOverrides[participant.id];
    if (override != null) {
      return override;
    }
    return participant.displayName;
  }
}
