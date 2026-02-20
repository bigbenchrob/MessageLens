import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../db/feature_level_providers.dart';
import '../feature_level_providers.dart';

const _searchResultLimit = 500;
const _recencyWeight = 0.15;

enum SearchMode { allTerms, anyTerm }

class SearchService {
  SearchService({required this.ref});

  final Ref ref;

  /// Search chat messages, returning just message IDs for virtual scrolling.
  Future<List<int>> searchChatMessageIds({
    required int chatId,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final tokens = _tokenize(trimmed);
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearchIds(
        tokens: tokens,
        chatId: chatId,
        contactId: null,
      );
      if (ftsResults.isNotEmpty) {
        return ftsResults;
      }
    }

    return _legacyChatSearchIds(chatId: chatId, query: trimmed);
  }

  /// Search contact messages, returning just message IDs for virtual scrolling.
  Future<List<int>> searchContactMessageIds({
    required int contactId,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final tokens = _tokenize(trimmed);
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearchIds(
        tokens: tokens,
        chatId: null,
        contactId: contactId,
      );
      if (ftsResults.isNotEmpty) {
        return ftsResults;
      }
    }

    return _legacyContactSearchIds(contactId: contactId, query: trimmed);
  }

  /// Search global messages, returning just message IDs for virtual scrolling.
  Future<List<int>> searchGlobalMessageIds({
    required String query,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final tokens = _tokenize(trimmed);
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearchIds(
        tokens: tokens,
        chatId: null,
        contactId: null,
        mode: mode,
      );
      if (ftsResults.isNotEmpty) {
        return ftsResults;
      }
    }

    return _legacyGlobalSearchIds(query: trimmed);
  }

  bool _shouldUseFts(List<String> tokens) {
    if (!ref.read(useFtsSearchByDefaultProvider)) {
      return false;
    }
    return tokens.isNotEmpty;
  }

  Future<List<int>> _legacyChatSearchIds({
    required int chatId,
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder = db.select(db.workingMessages)
      ..where((m) => m.chatId.equals(chatId))
      ..where((m) => m.textContent.isNotNull())
      ..where((m) => m.textContent.lower().like(pattern))
      ..orderBy([(m) => drift.OrderingTerm.desc(m.id)])
      ..limit(_searchResultLimit);

    final rows = await queryBuilder.get();
    return rows.map((r) => r.id).toList();
  }

  Future<List<int>> _legacyContactSearchIds({
    required int contactId,
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder =
        db.select(db.workingMessages).join([
            drift.innerJoin(
              db.contactMessageIndex,
              db.contactMessageIndex.messageId.equalsExp(db.workingMessages.id),
            ),
          ])
          ..where(db.contactMessageIndex.contactId.equals(contactId))
          ..where(db.workingMessages.textContent.isNotNull())
          ..where(db.workingMessages.textContent.lower().like(pattern))
          ..orderBy([
            drift.OrderingTerm(
              expression: db.workingMessages.id,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(_searchResultLimit);

    final rows = await queryBuilder.get();
    return rows.map((r) => r.readTable(db.workingMessages).id).toList();
  }

  Future<List<int>> _legacyGlobalSearchIds({required String query}) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder = db.select(db.workingMessages)
      ..where((m) => m.textContent.isNotNull())
      ..where((m) => m.textContent.lower().like(pattern))
      ..orderBy([(m) => drift.OrderingTerm.desc(m.id)])
      ..limit(_searchResultLimit);

    final rows = await queryBuilder.get();
    return rows.map((r) => r.id).toList();
  }

  Future<List<int>> _ftsSearchIds({
    required List<String> tokens,
    required int? chatId,
    required int? contactId,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final matchQuery = _buildMatchExpression(tokens, mode);
    if (matchQuery == null) {
      return const [];
    }
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final now = DateTime.now().toUtc();

    final buffer = StringBuffer('''
SELECT 
  m.id AS message_id,
  m.sent_at_utc AS sent_at_utc,
  bm25(messages_fts) AS bm25_score
FROM messages_fts
JOIN messages m ON m.id = messages_fts.rowid
WHERE messages_fts MATCH ?
''');
    final variables = <drift.Variable>[drift.Variable.withString(matchQuery)];

    if (chatId != null) {
      buffer.write(' AND m.chat_id = ?');
      variables.add(drift.Variable.withInt(chatId));
    }

    if (contactId != null) {
      buffer.write('''
 AND EXISTS (
   SELECT 1 FROM contact_message_index c
   WHERE c.message_id = m.id AND c.contact_id = ?
 )
''');
      variables.add(drift.Variable.withInt(contactId));
    }

    buffer.write(' LIMIT ?');
    variables.add(drift.Variable.withInt(_searchResultLimit));

    final rows = await db
        .customSelect(buffer.toString(), variables: variables)
        .get();

    if (rows.isEmpty) {
      return const [];
    }

    // Rank by BM25 + recency and return sorted IDs
    final ranked = rows
        .map(
          (row) => _RankedMessage(
            messageId: row.data['message_id'] as int,
            bm25: (row.data['bm25_score'] as num?)?.toDouble() ?? 0,
            sentAt: _parseUtc(row.data['sent_at_utc'] as String?),
          ),
        )
        .map((entry) => entry.withFinalScore(now))
        .sorted((a, b) => b.finalScore.compareTo(a.finalScore))
        .toList();

    return ranked.map((e) => e.messageId).toList();
  }
}

List<String> _tokenize(String input) {
  return input
      .split(RegExp(r'\s+'))
      .map((token) => token.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
}

String? _buildMatchExpression(List<String> tokens, SearchMode mode) {
  final sanitized = tokens
      .map((token) => token.replaceAll("'", ''))
      .where((token) => token.isNotEmpty)
      .toList();
  if (sanitized.isEmpty) {
    return null;
  }
  final operator = mode == SearchMode.allTerms ? ' AND ' : ' OR ';
  return sanitized.map((token) => '$token*').join(operator);
}

DateTime? _parseUtc(String? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

class _RankedMessage {
  const _RankedMessage({
    required this.messageId,
    required this.bm25,
    required this.sentAt,
    this.finalScore = 0,
  });

  final int messageId;
  final double bm25;
  final DateTime? sentAt;
  final double finalScore;

  _RankedMessage withFinalScore(DateTime now) {
    final base = -bm25;
    final recencyBoost = _computeRecencyBoost(now, sentAt);
    return _RankedMessage(
      messageId: messageId,
      bm25: bm25,
      sentAt: sentAt,
      finalScore: base + _recencyWeight * recencyBoost,
    );
  }
}

double _computeRecencyBoost(DateTime now, DateTime? sentAt) {
  if (sentAt == null) {
    return 0;
  }
  final ageHours = max(0, now.difference(sentAt).inHours.toDouble());
  return 1 / (1 + ageHours / 24);
}
