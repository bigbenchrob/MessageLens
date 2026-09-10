import 'message_text_search_query.dart';

const int graphSearchResultLimit = 500;

enum GraphMessageSearchScopeType { global, conversation, handle, contact }

class GraphMessageSearchScope {
  const GraphMessageSearchScope._({
    required this.type,
    this.id,
    this.ids = const <int>[],
  });

  const GraphMessageSearchScope.global()
    : this._(type: GraphMessageSearchScopeType.global);

  const GraphMessageSearchScope.conversation(int conversationId)
    : this._(
        type: GraphMessageSearchScopeType.conversation,
        id: conversationId,
      );

  const GraphMessageSearchScope.handle(int canonicalHandleId)
    : this._(type: GraphMessageSearchScopeType.handle, id: canonicalHandleId);

  const GraphMessageSearchScope.contactCanonicalHandles(
    List<int> canonicalHandleIds,
  ) : this._(
        type: GraphMessageSearchScopeType.contact,
        ids: canonicalHandleIds,
      );

  final GraphMessageSearchScopeType type;
  final int? id;
  final List<int> ids;
}

abstract interface class GraphSearchRepository {
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  });
}
