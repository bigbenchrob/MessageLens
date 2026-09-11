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

    final termResultIds = <Set<int>>[for (final _ in textTokens) <int>{}];
    for (var index = 0; index < textTokens.length; index++) {
      termResultIds[index].addAll(
        await _searchMessageTextIds(scope: scope, textToken: textTokens[index]),
      );
    }
    final tagResultIds = await _searchTagMessageIdsByToken(
      scope: scope,
      textTokens: textTokens,
    );
    for (var index = 0; index < tagResultIds.length; index++) {
      termResultIds[index].addAll(tagResultIds[index]);
    }

    var resultIds = _combineTermResultIds(
      termResultIds,
      matchAnyTerm: matchAnyTerm,
    );

    if (filterSaved) {
      final savedIds = await _readSavedMessageIds(scope: scope);
      if (textTokens.isEmpty) {
        resultIds = savedIds;
      } else {
        resultIds.retainAll(savedIds);
      }
    }

    return _sortAndLimitMessageIds(messageIds: resultIds, limit: limit);
  }

  Future<List<int>> _searchMessageTextIds({
    required GraphMessageSearchScope scope,
    required MessageTextSearchToken textToken,
  }) async {
    final scoped = _scopeSql(scope);
    if (scoped == null) {
      return const <int>[];
    }

    final rows = await graphDatabase.selectRows(
      '''
      SELECT DISTINCT m.ss_id AS message_id
      FROM message_text_fts
      JOIN messages m ON m.ss_id = message_text_fts.rowid
      ${scoped.joinSql}
      WHERE message_text_fts MATCH ?
        AND ${scoped.whereSql}
      ''',
      <Object?>[_messageTextFtsClause(textToken), ...scoped.args],
    );

    return [for (final row in rows) _readInt(row['message_id'])];
  }

  Future<List<Set<int>>> _searchTagMessageIdsByToken({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
  }) async {
    if (textTokens.isEmpty) {
      return const <Set<int>>[];
    }

    final resultIdsByToken = <Set<int>>[for (final _ in textTokens) <int>{}];
    final graphNativeRows = await overlayDatabase.customSelect('''
      SELECT message_ss_id, tag_normalized
      FROM message_intent_tags
      ''').get();
    for (final row in graphNativeRows) {
      _recordTagMatches(
        messageId: _readInt(row.data['message_ss_id']),
        normalizedTag: row.data['tag_normalized'] as String? ?? '',
        textTokens: textTokens,
        resultIdsByToken: resultIdsByToken,
      );
    }

    final guidKeyedTags = await overlayDatabase.getAllMessageUserTags();
    final tokenIndexesByGuid = <String, Set<int>>{};
    for (final tag in guidKeyedTags) {
      for (var index = 0; index < textTokens.length; index++) {
        if (_tagMatchesToken(tag.tagNormalized, textTokens[index])) {
          tokenIndexesByGuid
              .putIfAbsent(tag.messageGuid, () => <int>{})
              .add(index);
        }
      }
    }

    final resolved = await _resolveUniqueGuidMessageIds(
      tokenIndexesByGuid.keys,
    );
    for (final entry in resolved.entries) {
      for (final index in tokenIndexesByGuid[entry.key] ?? const <int>{}) {
        resultIdsByToken[index].add(entry.value);
      }
    }

    final allTagMessageIds = <int>{};
    resultIdsByToken.forEach(allTagMessageIds.addAll);
    final scopedIds = await _filterIdsToScope(
      scope: scope,
      messageIds: allTagMessageIds,
    );
    return <Set<int>>[
      for (final resultIds in resultIdsByToken)
        resultIds.intersection(scopedIds),
    ];
  }

  Future<Set<int>> _readSavedMessageIds({
    required GraphMessageSearchScope scope,
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
    ).then((idsByGuid) => idsByGuid.values);

    return _filterIdsToScope(
      scope: scope,
      messageIds: <int>{...graphNativeIds, ...guidKeyedIds},
    );
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

    final idsByGuid = <String, int>{};
    for (final guidChunk in _chunks(guidList, _sqlIdChunkSize)) {
      final rows = await graphDatabase.selectRows('''
        SELECT guid, MIN(ss_id) AS message_id, COUNT(*) AS message_count
        FROM messages
        WHERE guid IN (${_placeholders(guidChunk.length)})
        GROUP BY guid
        HAVING COUNT(*) = 1
        ''', guidChunk);

      for (final row in rows) {
        final guid = row['guid'];
        if (guid is! String) {
          continue;
        }
        idsByGuid[guid] = _readInt(row['message_id']);
      }
    }
    return idsByGuid;
  }

  Future<Set<int>> _filterIdsToScope({
    required GraphMessageSearchScope scope,
    required Iterable<int> messageIds,
  }) async {
    final uniqueMessageIds = messageIds.toSet().toList(growable: false);
    if (uniqueMessageIds.isEmpty) {
      return <int>{};
    }

    final resultIds = <int>{};
    for (final idChunk in _chunks(uniqueMessageIds, _sqlIdChunkSize)) {
      final scoped = _scopeSql(scope, messageIds: idChunk);
      if (scoped == null) {
        return <int>{};
      }

      final rows = await graphDatabase.selectRows('''
        SELECT DISTINCT m.ss_id AS message_id
        FROM messages m
        ${scoped.joinSql}
        WHERE ${scoped.whereSql}
        ''', scoped.args);
      for (final row in rows) {
        resultIds.add(_readInt(row['message_id']));
      }
    }
    return resultIds;
  }

  Future<List<int>> _sortAndLimitMessageIds({
    required Set<int> messageIds,
    required int limit,
  }) async {
    if (messageIds.isEmpty || limit <= 0) {
      return const <int>[];
    }

    final datedIds = <_DatedMessageId>[];
    final idList = messageIds.toList(growable: false);
    for (final idChunk in _chunks(idList, _sqlIdChunkSize)) {
      final rows = await graphDatabase.selectRows('''
        SELECT ss_id AS message_id, date_utc
        FROM messages
        WHERE ss_id IN (${_placeholders(idChunk.length)})
        ''', idChunk);
      for (final row in rows) {
        datedIds.add(
          _DatedMessageId(
            messageId: _readInt(row['message_id']),
            dateUtc: row['date_utc'] as String? ?? '',
          ),
        );
      }
    }
    datedIds.sort((left, right) {
      final dateCompare = right.dateUtc.compareTo(left.dateUtc);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return right.messageId.compareTo(left.messageId);
    });
    return datedIds
        .take(limit)
        .map((entry) => entry.messageId)
        .toList(growable: false);
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

Set<int> _combineTermResultIds(
  List<Set<int>> resultIdsByTerm, {
  required bool matchAnyTerm,
}) {
  if (resultIdsByTerm.isEmpty) {
    return <int>{};
  }
  if (matchAnyTerm) {
    return <int>{for (final resultIds in resultIdsByTerm) ...resultIds};
  }

  final combined = resultIdsByTerm.first.toSet();
  for (final resultIds in resultIdsByTerm.skip(1)) {
    combined.retainAll(resultIds);
    if (combined.isEmpty) {
      break;
    }
  }
  return combined;
}

void _recordTagMatches({
  required int messageId,
  required String normalizedTag,
  required List<MessageTextSearchToken> textTokens,
  required List<Set<int>> resultIdsByToken,
}) {
  for (var index = 0; index < textTokens.length; index++) {
    if (_tagMatchesToken(normalizedTag, textTokens[index])) {
      resultIdsByToken[index].add(messageId);
    }
  }
}

bool _tagMatchesToken(String normalizedTag, MessageTextSearchToken textToken) {
  if (normalizedTag.isEmpty) {
    return false;
  }
  final normalizedToken = normalizeMessageTagValue(textToken.normalizedText);
  if (normalizedToken.isEmpty) {
    return false;
  }
  return _normalizedTagTokenMatchStrength(
        normalizedTag: normalizedTag,
        words: normalizedTag.split(' '),
        normalizedToken: normalizedToken,
        allowPrefix: textToken is PrefixMessageTextSearchToken,
      ) >
      0;
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

class _DatedMessageId {
  const _DatedMessageId({required this.messageId, required this.dateUtc});

  final int messageId;
  final String dateUtc;
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

Iterable<List<T>> _chunks<T>(List<T> values, int chunkSize) sync* {
  for (var start = 0; start < values.length; start += chunkSize) {
    final end = start + chunkSize < values.length
        ? start + chunkSize
        : values.length;
    yield values.sublist(start, end);
  }
}

const int _sqlIdChunkSize = 400;

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
