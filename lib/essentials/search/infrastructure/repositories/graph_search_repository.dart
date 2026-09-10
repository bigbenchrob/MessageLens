import 'package:collection/collection.dart';

import '../../../../core/util/message_tag_normalizer.dart';
import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/graph_message_search.dart';
import '../../application/message_text_search_query.dart';

class SqliteGraphSearchRepository implements GraphSearchRepository {
  const SqliteGraphSearchRepository({
    required this.graphDatabase,
    required this.overlayDatabase,
  });

  final ConversationGraphDatabase graphDatabase;
  final OverlayDatabase overlayDatabase;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  }) async {
    if (textTokens.isEmpty && !filterSaved) {
      return const <int>[];
    }

    final textResultIds = textTokens.isEmpty
        ? const <int>[]
        : await _searchMessageTextIds(
            scope: scope,
            textTokens: textTokens,
            matchAnyTerm: matchAnyTerm,
            limit: limit,
          );

    final tagResultIds = textTokens.isEmpty
        ? const <int>[]
        : await _searchTagMessageIds(
            scope: scope,
            textTokens: textTokens,
            matchAnyTerm: matchAnyTerm,
            limit: limit,
          );

    var resultIds = _mergeIds(tagResultIds, textResultIds, limit: limit);

    if (filterSaved) {
      final savedIds = await _readSavedMessageIds(scope: scope, limit: limit);
      if (textTokens.isEmpty) {
        resultIds = savedIds;
      } else {
        final savedSet = savedIds.toSet();
        resultIds = resultIds
            .where(savedSet.contains)
            .take(limit)
            .toList(growable: false);
      }
    }

    return resultIds.take(limit).toList(growable: false);
  }

  Future<List<int>> _searchMessageTextIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required int limit,
  }) async {
    final scoped = _scopeSql(scope);
    if (scoped == null) {
      return const <int>[];
    }
    final matchExpression = _messageTextFtsExpression(
      textTokens: textTokens,
      matchAnyTerm: matchAnyTerm,
    );

    final rows = await graphDatabase.selectRows(
      '''
      SELECT DISTINCT m.ss_id AS message_id
      FROM message_text_fts
      JOIN messages m ON m.ss_id = message_text_fts.rowid
      ${scoped.joinSql}
      WHERE message_text_fts MATCH ?
        AND ${scoped.whereSql}
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[matchExpression, ...scoped.args, limit],
    );

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  Future<List<int>> _searchTagMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required int limit,
  }) async {
    final graphTagIds = await _searchGraphNativeTagIds(
      textTokens: textTokens,
      matchAnyTerm: matchAnyTerm,
    );
    final guidKeyedTagIds = await _searchGuidKeyedTagIds(
      textTokens: textTokens,
      matchAnyTerm: matchAnyTerm,
    );

    final merged = _mergeIds(graphTagIds, guidKeyedTagIds, limit: limit);
    return _filterIdsToScope(scope: scope, messageIds: merged, limit: limit);
  }

  Future<List<int>> _searchGraphNativeTagIds({
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
  }) async {
    final rows = await overlayDatabase.customSelect('''
      SELECT message_ss_id, tag_display, tag_normalized
      FROM message_intent_tags
      ORDER BY tag_display ASC
      ''').get();

    final scored = <_ScoredMessageId>[];
    for (final row in rows) {
      final normalizedTag = row.data['tag_normalized'] as String? ?? '';
      final score = _tagMatchScore(
        normalizedTag: normalizedTag,
        textTokens: textTokens,
        matchAnyTerm: matchAnyTerm,
      );
      if (score == 0) {
        continue;
      }
      scored.add(
        _ScoredMessageId(
          messageId: _readInt(row.data['message_ss_id']),
          score: score,
        ),
      );
    }

    return _rankScoredIds(scored);
  }

  Future<List<int>> _searchGuidKeyedTagIds({
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
  }) async {
    final guidKeyedTags = await overlayDatabase.getAllMessageUserTags();
    final matchingGuids = <String, int>{};
    for (final tag in guidKeyedTags) {
      final score = _tagMatchScore(
        normalizedTag: tag.tagNormalized,
        textTokens: textTokens,
        matchAnyTerm: matchAnyTerm,
      );
      if (score == 0) {
        continue;
      }
      matchingGuids.update(
        tag.messageGuid,
        (current) => current > score ? current : score,
        ifAbsent: () => score,
      );
    }

    final resolved = await _resolveUniqueGuidMessageIds(matchingGuids.keys);
    final scored = <_ScoredMessageId>[
      for (final entry in resolved.entries)
        _ScoredMessageId(
          messageId: entry.value,
          score: matchingGuids[entry.key] ?? 0,
        ),
    ];
    return _rankScoredIds(scored);
  }

  Future<List<int>> _readSavedMessageIds({
    required GraphMessageSearchScope scope,
    required int limit,
  }) async {
    final graphNativeRows = await overlayDatabase.customSelect('''
      SELECT message_ss_id
      FROM message_intent_overlays
      WHERE is_saved = 1
      ''').get();

    final graphNativeIds = [
      for (final row in graphNativeRows) _readInt(row.data['message_ss_id']),
    ];

    final guidKeyedSavedGuids = await overlayDatabase.getAllSavedMessageGuids();
    final guidKeyedIds = await _resolveUniqueGuidMessageIds(
      guidKeyedSavedGuids,
    ).then((idsByGuid) => idsByGuid.values.toList(growable: false));

    final merged = _mergeIds(graphNativeIds, guidKeyedIds, limit: limit);
    return _filterIdsToScope(scope: scope, messageIds: merged, limit: limit);
  }

  Future<Map<String, int>> _resolveUniqueGuidMessageIds(
    Iterable<String> guids,
  ) async {
    final guidList = guids
        .map((guid) => guid.trim())
        .where((guid) => guid.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (guidList.isEmpty) {
      return const <String, int>{};
    }

    final rows = await graphDatabase.selectRows('''
      SELECT guid, MIN(ss_id) AS message_id, COUNT(*) AS message_count
      FROM messages
      WHERE guid IN (${_placeholders(guidList.length)})
      GROUP BY guid
      HAVING COUNT(*) = 1
      ''', guidList);

    final idsByGuid = <String, int>{};
    for (final row in rows) {
      final guid = row['guid'];
      if (guid is! String) {
        continue;
      }
      idsByGuid[guid] = _readInt(row['message_id']);
    }
    return idsByGuid;
  }

  Future<List<int>> _filterIdsToScope({
    required GraphMessageSearchScope scope,
    required List<int> messageIds,
    required int limit,
  }) async {
    if (messageIds.isEmpty) {
      return const <int>[];
    }

    final scoped = _scopeSql(scope, messageIds: messageIds);
    if (scoped == null) {
      return const <int>[];
    }

    final rows = await graphDatabase.selectRows(
      '''
      SELECT DISTINCT m.ss_id AS message_id
      FROM messages m
      ${scoped.joinSql}
      WHERE ${scoped.whereSql}
      ORDER BY COALESCE(m.date_utc, '') DESC, m.ss_id DESC
      LIMIT ?
      ''',
      <Object?>[...scoped.args, limit],
    );

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  _GraphScopeSql? _scopeSql(
    GraphMessageSearchScope scope, {
    List<int> messageIds = const <int>[],
  }) {
    final messageFilter = messageIds.isEmpty
        ? ''
        : ' AND m.ss_id IN (${_placeholders(messageIds.length)})';
    final messageArgs = messageIds.cast<Object?>();

    switch (scope.type) {
      case GraphMessageSearchScopeType.global:
        return _GraphScopeSql(
          joinSql: '',
          whereSql: '1 = 1$messageFilter',
          args: messageArgs,
        );
      case GraphMessageSearchScopeType.conversation:
        final conversationId = scope.id;
        if (conversationId == null) {
          return null;
        }
        return _GraphScopeSql(
          joinSql: '''
          JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
          ''',
          whereSql: 'ctm.chat_ss_id = ?$messageFilter',
          args: <Object?>[conversationId, ...messageArgs],
        );
      case GraphMessageSearchScopeType.handle:
        final handleId = scope.id;
        if (handleId == null) {
          return null;
        }
        return _GraphScopeSql(
          joinSql: '''
          LEFT JOIN handle_aliases scope_sender_alias
            ON scope_sender_alias.handle_ss_id = m.sender_handle_ss_id
          ''',
          whereSql:
              '''
          COALESCE(
            m.sender_canonical_handle_ss_id,
            scope_sender_alias.canonical_handle_ss_id,
            m.sender_handle_ss_id
          ) = ?
          $messageFilter
          ''',
          args: <Object?>[handleId, ...messageArgs],
        );
      case GraphMessageSearchScopeType.contact:
        final canonicalHandleIds = scope.ids;
        if (canonicalHandleIds.isEmpty) {
          return null;
        }
        return _GraphScopeSql(
          joinSql: '''
          JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
          JOIN chat_to_handle cth ON cth.chat_ss_id = ctm.chat_ss_id
          LEFT JOIN handle_aliases ha ON ha.handle_ss_id = cth.handle_ss_id
          ''',
          whereSql:
              '''
          COALESCE(ha.canonical_handle_ss_id, cth.handle_ss_id)
            IN (${_placeholders(canonicalHandleIds.length)})
          $messageFilter
          ''',
          args: <Object?>[...canonicalHandleIds, ...messageArgs],
        );
    }
  }
}

String _messageTextFtsExpression({
  required List<MessageTextSearchToken> textTokens,
  required bool matchAnyTerm,
}) {
  final operator = matchAnyTerm ? ' OR ' : ' AND ';
  return textTokens.map(_messageTextFtsClause).join(operator);
}

String _messageTextFtsClause(MessageTextSearchToken token) {
  // FTS5 escapes quotes inside phrase strings by doubling them. Wrapping every
  // application token prevents user text from becoming FTS query syntax.
  final escapedText = token.normalizedText.replaceAll('"', '""');
  final quotedText = '"$escapedText"';
  if (token is PrefixMessageTextSearchToken) {
    return '$quotedText*';
  }
  return quotedText;
}

class _GraphScopeSql {
  const _GraphScopeSql({
    required this.joinSql,
    required this.whereSql,
    required this.args,
  });

  final String joinSql;
  final String whereSql;
  final List<Object?> args;
}

class _ScoredMessageId {
  const _ScoredMessageId({required this.messageId, required this.score});

  final int messageId;
  final int score;
}

int _tagMatchScore({
  required String normalizedTag,
  required List<MessageTextSearchToken> textTokens,
  required bool matchAnyTerm,
}) {
  if (normalizedTag.isEmpty || textTokens.isEmpty) {
    return 0;
  }

  var score = 0;
  var matchedTerms = 0;
  final words = normalizedTag.split(' ');
  for (final token in textTokens) {
    final term = normalizeMessageTagValue(token.normalizedText);
    if (term.isEmpty) {
      continue;
    }
    final strength = _normalizedTagTokenMatchStrength(
      normalizedTag: normalizedTag,
      words: words,
      normalizedToken: term,
      allowPrefix: token is PrefixMessageTextSearchToken,
    );
    if (strength == 0) {
      continue;
    }
    matchedTerms += 1;
    score += strength;
  }

  if (matchAnyTerm) {
    return matchedTerms > 0 ? score : 0;
  }
  return matchedTerms == textTokens.length ? score : 0;
}

int _normalizedTagTokenMatchStrength({
  required String normalizedTag,
  required List<String> words,
  required String normalizedToken,
  required bool allowPrefix,
}) {
  if (normalizedTag == normalizedToken) {
    return 4;
  }
  if (words.contains(normalizedToken)) {
    return 3;
  }
  if (allowPrefix && words.any((word) => word.startsWith(normalizedToken))) {
    return 1;
  }
  return 0;
}

List<int> _rankScoredIds(List<_ScoredMessageId> scored) {
  return scored
      .sorted((left, right) {
        final scoreCompare = right.score.compareTo(left.score);
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return right.messageId.compareTo(left.messageId);
      })
      .map((entry) => entry.messageId)
      .toSet()
      .toList(growable: false);
}

List<int> _mergeIds(
  List<int> primary,
  List<int> secondary, {
  required int limit,
}) {
  final merged = <int>[];
  final seen = <int>{};
  for (final messageId in primary.followedBy(secondary)) {
    if (!seen.add(messageId)) {
      continue;
    }
    merged.add(messageId);
    if (merged.length >= limit) {
      break;
    }
  }
  return merged;
}

String _placeholders(int count) {
  return List.filled(count, '?').join(', ');
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is BigInt) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}
