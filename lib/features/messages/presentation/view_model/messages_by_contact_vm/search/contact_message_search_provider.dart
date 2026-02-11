import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/search/feature_level_providers.dart';
import '../../shared/hydration/messages_for_handle_provider.dart';

part 'contact_message_search_provider.g.dart';

@riverpod
Future<List<MessageListItem>> contactMessageSearchResults(
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
