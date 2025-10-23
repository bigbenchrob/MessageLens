import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/features/chats_spec.dart';
import 'recent_chats_provider.dart';

part 'chat_list_header_provider.g.dart';

@riverpod
String chatListHeader(
  Ref ref, {
  required ChatsSpec spec,
  int? limit,
  int? selectedChatId,
}) {
  final baseTitle = spec.when(
    list: () => 'Chats',
    forContact: (_) => 'Chats',
    recent: (value) => 'Recent Chats',
    byAgeOldest: (value) => 'Oldest Chats',
    byAgeNewest: (value) => 'Newest Chats',
    unmatched: (value) => 'Unmatched Numbers',
    forParticipant: (_) => 'Chats for Contact',
  );

  if (selectedChatId == null) {
    return baseTitle;
  }

  final chatsAsync = ref.watch(recentChatsProvider(limit: limit));
  return chatsAsync.maybeWhen(
    data: (chats) {
      for (final chat in chats) {
        if (chat.chatId == selectedChatId) {
          final label = _describeChat(chat);
          return 'Chats by $label';
        }
      }
      return baseTitle;
    },
    orElse: () => baseTitle,
  );
}

String _describeChat(RecentChatSummary chat) {
  if (chat.participants.isEmpty) {
    return chat.title;
  }

  if (!chat.isGroup && chat.participants.isNotEmpty) {
    return chat.participants.first;
  }

  final summary = chat.participants.take(3).join(', ');
  if (summary.isNotEmpty) {
    return summary;
  }

  return chat.title;
}
