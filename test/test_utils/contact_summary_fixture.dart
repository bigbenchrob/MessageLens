import 'package:remember_this_text/features/contacts/application/contacts_list_provider.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';

ContactSummary buildContactSummary({
  required int participantId,
  required String displayName,
  String? shortName,
  int totalChats = 1,
  int totalMessages = 10,
  ParticipantOrigin origin = ParticipantOrigin.working,
  int handleCount = 1,
}) {
  return ContactSummary(
    participantId: participantId,
    displayName: displayName,
    shortName: shortName ?? displayName,
    totalChats: totalChats,
    totalMessages: totalMessages,
    lastMessageDate: null,
    origin: origin,
    handleCount: handleCount,
  );
}
