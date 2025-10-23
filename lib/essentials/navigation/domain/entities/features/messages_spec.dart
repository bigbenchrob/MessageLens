import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_spec.freezed.dart';

@freezed
class MessagesSpec with _$MessagesSpec {
  const factory MessagesSpec.forChat({required int chatId}) = _MessagesForChat;

  const factory MessagesSpec.forContact({required String contactId}) =
      _MessagesForContact;

  const factory MessagesSpec.recent({required int limit}) = _RecentMessages;

  /// Show ALL messages from a handle across all chats chronologically
  const factory MessagesSpec.forHandle({required int handleId}) =
      _MessagesForHandle;
}
