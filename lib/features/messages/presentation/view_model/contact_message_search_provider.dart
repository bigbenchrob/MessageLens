import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../search/search_feature_providers.dart';
import 'messages_for_chat_provider.dart';

part 'contact_message_search_provider.g.dart';

@riverpod
Future<List<ChatMessageListItem>> contactMessageSearchResults(
  ContactMessageSearchResultsRef ref, {
  required int contactId,
  required String query,
}) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchContactMessages(
    contactId: contactId,
    query: query,
  );
}
