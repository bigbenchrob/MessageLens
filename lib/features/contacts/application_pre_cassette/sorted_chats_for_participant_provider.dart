import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/navigation/domain/entities/features/chat_view_mode.dart';
import '../../chats/presentation/view_model/recent_chats_provider.dart';
import 'chats_for_participant_provider.dart';

part 'sorted_chats_for_participant_provider.g.dart';

/// Provides sorted chats for a participant based on the selected view mode
@riverpod
Future<List<RecentChatSummary>> sortedChatsForParticipant(
  Ref ref, {
  required int participantId,
  required ChatViewMode viewMode,
}) async {
  // Get the unsorted list from the base provider
  final chats = await ref.watch(
    chatsForParticipantProvider(participantId: participantId).future,
  );

  // Create a mutable copy for sorting
  final sortedChats = List<RecentChatSummary>.from(chats);

  // Sort based on view mode
  switch (viewMode) {
    case ChatViewMode.recentActivity:
      // Sort by last message date, most recent first
      sortedChats.sort((a, b) {
        final aDate = a.lastMessageDate;
        final bDate = b.lastMessageDate;

        if (aDate == null && bDate == null) {
          return 0;
        }
        if (aDate == null) {
          return 1; // null dates go to end
        }
        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate); // Most recent first
      });

    case ChatViewMode.newestFirst:
      // Sort by first message date, newest first
      sortedChats.sort((a, b) {
        final aDate = a.firstMessageDate;
        final bDate = b.firstMessageDate;

        if (aDate == null && bDate == null) {
          return 0;
        }
        if (aDate == null) {
          return 1; // null dates go to end
        }
        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate); // Newest first
      });

    case ChatViewMode.oldestFirst:
      // Sort by first message date, oldest first
      sortedChats.sort((a, b) {
        final aDate = a.firstMessageDate;
        final bDate = b.firstMessageDate;

        if (aDate == null && bDate == null) {
          return 0;
        }
        if (aDate == null) {
          return 1; // null dates go to end
        }
        if (bDate == null) {
          return -1;
        }

        return aDate.compareTo(bDate); // Oldest first
      });
  }

  return sortedChats;
}
