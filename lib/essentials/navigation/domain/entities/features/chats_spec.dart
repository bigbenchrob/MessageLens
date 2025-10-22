import 'package:freezed_annotation/freezed_annotation.dart';

part 'chats_spec.freezed.dart';

@freezed
class ChatsSpec with _$ChatsSpec {
  const factory ChatsSpec.list() = _ChatsList;

  const factory ChatsSpec.forContact({required String contactId}) =
      _ChatsForContact;

  const factory ChatsSpec.recent({int? limit}) = _RecentChats;

  const factory ChatsSpec.byAgeOldest({int? limit}) = _ByAgeOldest;

  const factory ChatsSpec.byAgeNewest({int? limit}) = _ByAgeNewest;

  const factory ChatsSpec.unmatched({int? limit}) = _Unmatched;
}
