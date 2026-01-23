part of '../../cassette_spec.dart';

CassetteSpec contactsToMessagesHeatMap(int contactId) {
  return CassetteSpec.messages(
    MessagesCassetteSpec.heatMap(contactId: contactId),
  );
}
