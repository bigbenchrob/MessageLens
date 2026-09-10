import 'graph_message_search.dart';
import 'message_text_search_query.dart';

enum SearchMode { allTerms, anyTerm }

class SearchService {
  SearchService({required this.readRepository});

  final Future<GraphSearchRepository> Function() readRepository;

  /// Search graph messages, returning canonical source-scoped message IDs.
  Future<List<int>> searchGraphMessageIds({
    required GraphMessageSearchScope scope,
    required String query,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final parsedQuery = MessageTextSearchQuery.parse(query);
    if (parsedQuery.tokens.isEmpty && !parsedQuery.filterSaved) {
      return const [];
    }

    final repository = await readRepository();
    return repository.searchMessageIds(
      scope: scope,
      textTokens: parsedQuery.tokens,
      matchAnyTerm: mode == SearchMode.anyTerm,
      filterSaved: parsedQuery.filterSaved,
    );
  }
}
