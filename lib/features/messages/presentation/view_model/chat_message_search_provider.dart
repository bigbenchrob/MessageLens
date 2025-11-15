import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../search/search_feature_providers.dart';
import 'messages_for_chat_provider.dart';

part 'chat_message_search_provider.g.dart';

@riverpod
Future<List<ChatMessageListItem>> chatMessageSearchResults(
  ChatMessageSearchResultsRef ref, {
  required int chatId,
  required String query,
}) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchChatMessages(chatId: chatId, query: query);
}
