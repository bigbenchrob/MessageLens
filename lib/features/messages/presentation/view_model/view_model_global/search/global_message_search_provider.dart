import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:remember_this_text/features/search/application/search_service.dart';
import 'package:remember_this_text/features/search/search_feature_providers.dart';
import '../../shared/hydration/messages_for_handle_provider.dart';

part 'global_message_search_provider.g.dart';

@riverpod
Future<List<MessageListItem>> globalMessageSearchResults(
  GlobalMessageSearchResultsRef ref, {
  required String query,
  required SearchMode mode,
}) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchGlobalMessages(query: query, mode: mode);
}
