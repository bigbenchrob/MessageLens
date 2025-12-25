// import 'package:drift/drift.dart' as drift;

// import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
// import '../../../presentation/domain/entities/message_list_item.dart';
// import '../../../presentation/presentation/view_model/attachment_info.dart';
// import '../../../presentation/view_model/view_model_contact/process_message_list/load_attachments_for_messages.dart';

// class MessageRowMapper {
//   MessageRowMapper(this._db);

//   final WorkingDatabase _db;

//   Future<List<MessageListItem>> mapRows(List<drift.TypedResult> rows) async {
//     if (rows.isEmpty) {
//       return const [];
//     }

//     final messages = <MessageListItem>[];
//     final messageData = <WorkingMessage>[];
//     final participants = <WorkingParticipant?>[];
//     final guidWithAttachments = <String>[];

//     for (final row in rows) {
//       final message = row.readTable(_db.workingMessages);
//       messageData.add(message);
//       participants.add(row.readTableOrNull(_db.workingParticipants));
//       if (message.hasAttachments) {
//         guidWithAttachments.add(message.guid);
//       }
//     }

//     final attachmentsByGuid = <String, List<AttachmentInfo>>{};
//     if (guidWithAttachments.isNotEmpty) {
//       final attachmentRows = await (_db.select(
//         _db.workingAttachments,
//       )..where((a) => a.messageGuid.isIn(guidWithAttachments))).get();

//       for (final attachment in attachmentRows) {
//         final info = await loadAttachment(attachment);
//         final list = attachmentsByGuid.putIfAbsent(
//           attachment.messageGuid,
//           () => <AttachmentInfo>[],
//         );
//         list.add(info);
//       }
//     }

//     for (var index = 0; index < messageData.length; index += 1) {
//       final message = messageData[index];
//       final participant = participants[index];

//       messages.add(
//         MessageListItem(
//           id: message.id,
//           guid: message.guid,
//           isFromMe: message.isFromMe,
//           senderName: _senderNameForMessage(
//             isFromMe: message.isFromMe,
//             participant: participant,
//           ),
//           text: message.textContent ?? '[No text content]',
//           sentAt: _parseUtc(message.sentAtUtc),
//           hasAttachments: message.hasAttachments,
//           attachments:
//               attachmentsByGuid[message.guid] ?? const <AttachmentInfo>[],
//         ),
//       );
//     }

//     return messages.reversed.toList(growable: false);
//   }

//   DateTime? _parseUtc(String? value) {
//     if (value == null || value.isEmpty) {
//       return null;
//     }
//     final parsed = DateTime.tryParse(value);
//     return parsed?.toLocal();
//   }

//   String _senderNameForMessage({
//     required bool isFromMe,
//     required WorkingParticipant? participant,
//   }) {
//     if (isFromMe) {
//       return 'You';
//     }
//     if (participant == null) {
//       return 'Unknown sender';
//     }
//     return participant.displayName;
//   }
// }
