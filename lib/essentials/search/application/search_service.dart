import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/messages/presentation/view_model/shared/message_row_mapper.dart';
import '../../../features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart';
import '../../db/feature_level_providers.dart';
import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../feature_level_providers.dart';

const _searchResultLimit = 100;
const _recencyWeight = 0.15;

enum SearchMode { allTerms, anyTerm }

class SearchService {
  SearchService({required this.ref});

  final Ref ref;

  Future<List<MessageListItem>> searchChatMessages({
    required int chatId,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final tokens = _tokenize(trimmed);
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearch(
        tokens: tokens,
        chatId: chatId,
        contactId: null,
      );
      if (ftsResults.isNotEmpty) {
        return ftsResults;
      }
    }

    return _legacyChatSearch(chatId: chatId, query: trimmed);
  }

  Future<List<MessageListItem>> searchContactMessages({
    required int contactId,
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final tokens = _tokenize(trimmed);
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearch(
        tokens: tokens,
        chatId: null,
        contactId: contactId,
      );
      if (ftsResults.isNotEmpty) {
        return ftsResults;
      }
    }

    return _legacyContactSearch(contactId: contactId, query: trimmed);
  }

  Future<List<MessageListItem>> searchGlobalMessages({
    required String query,
    SearchMode mode = SearchMode.allTerms,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final tokens = _tokenize(trimmed);
    if (_shouldUseFts(tokens)) {
      final ftsResults = await _ftsSearch(
        tokens: tokens,
        chatId: null,
        contactId: null,
        mode: mode,
      );
      if (ftsResults.isNotEmpty) {
        return ftsResults;
      }
    }

    return _legacyGlobalSearch(query: trimmed);
  }

  bool _shouldUseFts(List<String> tokens) {
    if (!ref.read(useFtsSearchByDefaultProvider)) {
      return false;
    }
    return tokens.isNotEmpty;
  }

  Future<List<MessageListItem>> _legacyChatSearch({
    required int chatId,
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final mapper = MessageRowMapper(db);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder = _baseMessageJoin(db)
      ..where(db.workingMessages.chatId.equals(chatId))
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
    if (rows.isEmpty) {
      return const [];
    }

    return mapper.mapRows(rows);
  }

  Future<List<MessageListItem>> _legacyContactSearch({
    required int contactId,
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final mapper = MessageRowMapper(db);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder =
        _baseMessageJoin(
            db,
            extraJoins: [
              drift.innerJoin(
                db.contactMessageIndex,
                db.contactMessageIndex.messageId.equalsExp(
                  db.workingMessages.id,
                ),
              ),
            ],
          )
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
    if (rows.isEmpty) {
      return const [];
    }

    return mapper.mapRows(rows);
  }

  Future<List<MessageListItem>> _legacyGlobalSearch({
    required String query,
  }) async {
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final mapper = MessageRowMapper(db);
    final lowerQuery = query.toLowerCase();
    final pattern = '%$lowerQuery%';

    final queryBuilder = _baseMessageJoin(db)
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
    if (rows.isEmpty) {
      return const [];
    }

    return mapper.mapRows(rows);
  }

  drift.JoinedSelectStatement _baseMessageJoin(
    WorkingDatabase db, {
    List<drift.Join> extraJoins = const [],
  }) {
    return db.select(db.workingMessages).join([
      drift.leftOuterJoin(
        db.handlesCanonical,
        db.handlesCanonical.id.equalsExp(db.workingMessages.senderHandleId),
      ),
      drift.leftOuterJoin(
        db.handleToParticipant,
        db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
      ),
      drift.leftOuterJoin(
        db.workingParticipants,
        db.workingParticipants.id.equalsExp(
          db.handleToParticipant.participantId,
        ),
      ),
      ...extraJoins,
    ]);
  }

  Future<List<MessageListItem>> _ftsSearch({
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

    return _hydrateRankedMessages(ranked);
  }

  Future<List<MessageListItem>> _hydrateRankedMessages(
    List<_RankedMessage> ranked,
  ) async {
    final messageIds = ranked.map((e) => e.messageId).toSet().toList();
    if (messageIds.isEmpty) {
      return const [];
    }
    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final mapper = MessageRowMapper(db);
    final baseQuery = _baseMessageJoin(db)
      ..where(db.workingMessages.id.isIn(messageIds));
    final rows = await baseQuery.get();
    if (rows.isEmpty) {
      return const [];
    }

    final mapped = await mapper.mapRows(rows);
    final byId = {for (final item in mapped) item.id: item};

    return ranked
        .map((entry) => byId[entry.messageId])
        .whereType<MessageListItem>()
        .toList();
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
