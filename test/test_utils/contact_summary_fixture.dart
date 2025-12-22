import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contacts_list_repository.dart';

ContactSummary buildContactSummary({
  int participantId = 1,
  String displayName = 'Ada Lovelace',
  String shortName = 'Ada',
  int totalChats = 3,
  int totalMessages = 42,
  DateTime? lastMessageDate,
  ParticipantOrigin origin = ParticipantOrigin.working,
  int handleCount = 1,
}) {
  return ContactSummary(
    participantId: participantId,
    displayName: displayName,
    shortName: shortName,
    totalChats: totalChats,
    totalMessages: totalMessages,
    lastMessageDate: lastMessageDate,
    origin: origin,
    handleCount: handleCount,
  );
}
