import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_timeline_scope.freezed.dart';

/// Defines the scope for message timeline queries.
///
/// This sealed class enables a unified view model and provider architecture
/// that works across different message timelines while maintaining type safety.
@freezed
sealed class MessageTimelineScope with _$MessageTimelineScope {
  /// All messages across all contacts/chats in the global timeline.
  const factory MessageTimelineScope.global() = GlobalTimelineScope;

  /// Messages with a specific contact across all their handles/chats.
  /// When [filterHandleId] is provided, only messages involving that handle
  /// are shown.
  const factory MessageTimelineScope.contact({
    required int contactId,
    int? filterHandleId,
  }) = ContactTimelineScope;

  /// Messages from a specific chat (single conversation thread).
  const factory MessageTimelineScope.chat({required int chatId}) =
      ChatTimelineScope;

  const MessageTimelineScope._();
}
