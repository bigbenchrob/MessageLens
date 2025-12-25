import 'package:drift/drift.dart' as drift;

import '../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../shared/hydration/messages_for_handle_provider.dart';

class MessageRowMapper {
  MessageRowMapper(this._db);

  final WorkingDatabase _db;

  Future<List<MessageListItem>> mapRows(List<drift.TypedResult> rows) async {
    if (rows.isEmpty) {
      return const [];
    }

    final results = <MessageListItem>[];

    for (final row in rows) {
      final message = row.readTable(_db.workingMessages);
      final participant = row.readTableOrNull(_db.workingParticipants);

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
          attachments: const [],
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
    return participant.displayName;
  }
}
