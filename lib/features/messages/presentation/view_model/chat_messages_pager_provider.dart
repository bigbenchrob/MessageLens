import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'chat_message_row_mapper.dart';
import 'messages_for_chat_provider.dart';

part 'chat_messages_pager_provider.g.dart';

const _pageSize = 60;

class MessagesPagerState {
  const MessagesPagerState({
    required this.messages,
    required this.hasMore,
    required this.isLoadingOlder,
  });

  final List<ChatMessageListItem> messages;
  final bool hasMore;
  final bool isLoadingOlder;

  MessagesPagerState copyWith({
    List<ChatMessageListItem>? messages,
    bool? hasMore,
    bool? isLoadingOlder,
  }) {
    return MessagesPagerState(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
    );
  }
}

class _FetchPageResult {
  const _FetchPageResult({required this.messages, required this.hasMore});

  final List<ChatMessageListItem> messages;
  final bool hasMore;
}

@riverpod
class ChatMessagesPager extends _$ChatMessagesPager {
  late WorkingDatabase _db;
  late int _chatId;
  int? _oldestFetchedId;
  bool _hasMore = true;
  StreamSubscription<List<drift.TypedResult>>? _latestMessagesSubscription;
  late ChatMessageRowMapper _rowMapper;

  @override
  FutureOr<MessagesPagerState> build({required int chatId}) async {
    _chatId = chatId;
    _db = await ref.watch(driftWorkingDatabaseProvider.future);
    _rowMapper = ChatMessageRowMapper(_db);
    ref.onDispose(() {
      _latestMessagesSubscription?.cancel();
    });

    final result = await _fetchPage(limit: _pageSize);

    if (result.messages.isNotEmpty) {
      _oldestFetchedId = result.messages.first.id;
    }
    _hasMore = result.hasMore;

    _listenToLatestPage();

    return MessagesPagerState(
      messages: result.messages,
      hasMore: result.hasMore,
      isLoadingOlder: false,
    );
  }

  Future<void> loadOlder() async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }
    if (currentState.isLoadingOlder || !_hasMore) {
      return;
    }
    if (_oldestFetchedId == null) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingOlder: true));

    try {
      final result = await _fetchPage(
        limit: _pageSize,
        beforeMessageId: _oldestFetchedId,
      );

      if (result.messages.isNotEmpty) {
        _oldestFetchedId = result.messages.first.id;
      }
      _hasMore = result.hasMore;

      final updatedMessages = <ChatMessageListItem>[
        ...result.messages,
        ...currentState.messages,
      ];

      state = AsyncValue.data(
        currentState.copyWith(
          messages: updatedMessages,
          hasMore: _hasMore,
          isLoadingOlder: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<_FetchPageResult> _fetchPage({
    required int limit,
    int? beforeMessageId,
  }) async {
    final db = _db;

    final query =
        db.select(db.workingMessages).join([
            drift.leftOuterJoin(
              db.workingHandles,
              db.workingHandles.id.equalsExp(db.workingMessages.senderHandleId),
            ),
            drift.leftOuterJoin(
              db.handleToParticipant,
              db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
            ),
            drift.leftOuterJoin(
              db.workingParticipants,
              db.workingParticipants.id.equalsExp(
                db.handleToParticipant.participantId,
              ),
            ),
          ])
          ..where(db.workingMessages.chatId.equals(_chatId))
          ..orderBy([
            drift.OrderingTerm(
              expression: db.workingMessages.id,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(limit);

    if (beforeMessageId != null) {
      query.where(db.workingMessages.id.isSmallerThanValue(beforeMessageId));
    }

    final rows = await query.get();
    if (rows.isEmpty) {
      return const _FetchPageResult(messages: [], hasMore: false);
    }

    final orderedMessages = await _rowMapper.mapRows(rows);
    final hasMore = rows.length == limit;

    return _FetchPageResult(messages: orderedMessages, hasMore: hasMore);
  }

  void _listenToLatestPage() {
    _latestMessagesSubscription?.cancel();
    final db = _db;

    final query =
        db.select(db.workingMessages).join([
            drift.leftOuterJoin(
              db.workingHandles,
              db.workingHandles.id.equalsExp(db.workingMessages.senderHandleId),
            ),
            drift.leftOuterJoin(
              db.handleToParticipant,
              db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
            ),
            drift.leftOuterJoin(
              db.workingParticipants,
              db.workingParticipants.id.equalsExp(
                db.handleToParticipant.participantId,
              ),
            ),
          ])
          ..where(db.workingMessages.chatId.equals(_chatId))
          ..orderBy([
            drift.OrderingTerm(
              expression: db.workingMessages.id,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(_pageSize);

    _latestMessagesSubscription = query.watch().listen((rows) async {
      final currentState = state.value;
      if (currentState == null) {
        return;
      }

      if (rows.isEmpty) {
        state = AsyncValue.data(
          currentState.copyWith(
            messages: const [],
            hasMore: false,
            isLoadingOlder: currentState.isLoadingOlder,
          ),
        );
        _oldestFetchedId = null;
        _hasMore = false;
        return;
      }

      final latestMessages = await _rowMapper.mapRows(rows);

      final latestIds = latestMessages.map((message) => message.id).toSet();
      final retainedOlder = currentState.messages
          .where((message) => !latestIds.contains(message.id))
          .toList(growable: false);

      final mergedMessages = <ChatMessageListItem>[
        ...retainedOlder,
        ...latestMessages,
      ];

      if (mergedMessages.isNotEmpty) {
        _oldestFetchedId = mergedMessages.first.id;
      }

      state = AsyncValue.data(
        currentState.copyWith(
          messages: mergedMessages,
          hasMore: currentState.hasMore,
          isLoadingOlder: currentState.isLoadingOlder,
        ),
      );
    });
  }
}
