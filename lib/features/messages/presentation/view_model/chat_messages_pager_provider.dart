import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'chat_message_row_mapper.dart';
import 'messages_for_chat_provider.dart';

part 'chat_messages_pager_provider.g.dart';

const _pageSize = 300;

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

  List<ChatMessageListItem> _sortedChronologically(
    Iterable<ChatMessageListItem> items,
  ) {
    final sorted = items.toList(growable: true)
      ..sort((a, b) {
        final aSent = a.sentAt;
        final bSent = b.sentAt;

        if (aSent != null && bSent != null) {
          final dateCompare = aSent.compareTo(bSent);
          if (dateCompare != 0) {
            return dateCompare;
          }
        } else if (aSent != null) {
          return 1;
        } else if (bSent != null) {
          return -1;
        }

        return a.id.compareTo(b.id);
      });
    return List<ChatMessageListItem>.unmodifiable(sorted);
  }

  @override
  FutureOr<MessagesPagerState> build({required int chatId}) async {
    _chatId = chatId;
    _db = await ref.watch(driftWorkingDatabaseProvider.future);
    _rowMapper = ChatMessageRowMapper(_db);
    ref.onDispose(() {
      _latestMessagesSubscription?.cancel();
    });

    final result = await _fetchPage(limit: _pageSize);
    final initialMessages = _sortedChronologically(result.messages);

    if (initialMessages.isNotEmpty) {
      _oldestFetchedId = initialMessages.first.id;
    }
    _hasMore = result.hasMore;
    _listenToLatestPage();

    return MessagesPagerState(
      messages: initialMessages,
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

      _hasMore = result.hasMore;

      final combinedMessages = <ChatMessageListItem>[
        ...result.messages,
        ...currentState.messages,
      ];
      final sortedMessages = _sortedChronologically(combinedMessages);

      if (sortedMessages.isNotEmpty) {
        _oldestFetchedId = sortedMessages.first.id;
      }

      state = AsyncValue.data(
        currentState.copyWith(
          messages: sortedMessages,
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
              db.handlesCanonical,
              db.handlesCanonical.id.equalsExp(
                db.workingMessages.senderHandleId,
              ),
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

    final mapped = await _rowMapper.mapRows(rows);
    final orderedMessages = _sortedChronologically(mapped);
    final hasMore = rows.length == limit;

    return _FetchPageResult(messages: orderedMessages, hasMore: hasMore);
  }

  void _listenToLatestPage() {
    _latestMessagesSubscription?.cancel();
    final db = _db;

    final query =
        db.select(db.workingMessages).join([
            drift.leftOuterJoin(
              db.handlesCanonical,
              db.handlesCanonical.id.equalsExp(
                db.workingMessages.senderHandleId,
              ),
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
          .toList();

      final mergedMessages = <ChatMessageListItem>[
        ...retainedOlder,
        ...latestMessages,
      ];
      final sortedMessages = _sortedChronologically(mergedMessages);

      if (sortedMessages.isNotEmpty) {
        _oldestFetchedId = sortedMessages.first.id;
      }

      state = AsyncValue.data(
        currentState.copyWith(
          messages: sortedMessages,
          hasMore: currentState.hasMore,
          isLoadingOlder: currentState.isLoadingOlder,
        ),
      );
    });
  }

  Future<void> ensureMonthLoaded(DateTime targetDate) async {
    final normalized = DateTime(targetDate.year, targetDate.month);
    print(
      '[ENSURE_MONTH] Starting: target=$normalized '
      '(${normalized.year}-${normalized.month.toString().padLeft(2, '0')})',
    );

    // Wait for initial state to be ready
    var waitAttempts = 0;
    while (state.isLoading && waitAttempts < 50) {
      waitAttempts++;
      print('[ENSURE_MONTH] Waiting for initial state (attempt $waitAttempts)');
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (state.isLoading) {
      print('[ENSURE_MONTH] Timed out waiting for initial state');
      return;
    }

    var attempts = 0;

    while (true) {
      attempts += 1;
      if (attempts > 32) {
        print('[ENSURE_MONTH] Exceeded 32 attempts, giving up');
        return;
      }

      if (state.isLoading) {
        print('[ENSURE_MONTH] Attempt $attempts: State is loading, waiting...');
        await Future<void>.delayed(const Duration(milliseconds: 32));
        continue;
      }

      final currentState = state.valueOrNull;
      if (currentState == null) {
        print('[ENSURE_MONTH] State is null, aborting');
        return;
      }

      final messages = currentState.messages;
      print(
        '[ENSURE_MONTH] Attempt $attempts: Checking ${messages.length} messages, '
        'isLoadingOlder=${currentState.isLoadingOlder}, hasMore=$_hasMore',
      );
      final monthFound = messages.any((message) {
        final sentAt = message.sentAt;
        if (sentAt == null) {
          return false;
        }
        return sentAt.year == normalized.year &&
            sentAt.month == normalized.month;
      });

      if (monthFound) {
        print(
          '[ENSURE_MONTH] Found target month in loaded messages '
          '(attempt $attempts)',
        );
        return;
      }

      if (!_hasMore) {
        print('[ENSURE_MONTH] No more messages to load, target not found');
        return;
      }

      if (currentState.isLoadingOlder) {
        print(
          '[ENSURE_MONTH] Attempt $attempts: Already loading older, waiting...',
        );
        await Future<void>.delayed(const Duration(milliseconds: 32));
        continue;
      }

      final earliest = _firstNonNullSentAt(messages);
      if (earliest == null) {
        print('[ENSURE_MONTH] No messages with sentAt found');
        return;
      }

      final earliestMonth = DateTime(earliest.year, earliest.month);
      final targetMonth = DateTime(normalized.year, normalized.month);

      // Debug: Show a sample of message dates around the boundary
      if (attempts <= 3 || attempts == 16) {
        final sampleDates = messages
            .where((m) => m.sentAt != null)
            .take(5)
            .map((m) => m.sentAt.toString())
            .join(', ');
        print('[ENSURE_MONTH] Sample earliest dates: $sampleDates');
      }

      print(
        '[ENSURE_MONTH] Attempt $attempts: '
        'earliest=$earliestMonth, target=$targetMonth, '
        'isAfter=${earliestMonth.isAfter(targetMonth)}',
      );

      if (!earliestMonth.isAfter(targetMonth)) {
        print(
          '[ENSURE_MONTH] Earliest month ($earliestMonth) '
          'is not after target ($targetMonth), stopping',
        );

        // Debug: Check if target month exists but with lower IDs
        final targetCheck = await _db
            .customSelect(
              '''
          SELECT COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id
          FROM messages
          WHERE chat_id = ?
            AND strftime('%Y-%m', sent_at_utc) = ?
          ''',
              variables: [
                drift.Variable.withInt(_chatId),
                drift.Variable.withString(
                  '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}',
                ),
              ],
              readsFrom: {_db.workingMessages},
            )
            .get();

        if (targetCheck.isNotEmpty) {
          final count = targetCheck.first.read<int>('count');
          final minId = targetCheck.first.read<int?>('min_id');
          final maxId = targetCheck.first.read<int?>('max_id');
          print(
            '[ENSURE_MONTH] Target month check: $count messages exist, '
            'ID range: $minId-$maxId',
          );
          if (count > 0 && messages.isNotEmpty) {
            final loadedMinId = messages
                .map((m) => m.id)
                .reduce((a, b) => a < b ? a : b);
            final loadedMaxId = messages
                .map((m) => m.id)
                .reduce((a, b) => a > b ? a : b);
            print(
              '[ENSURE_MONTH] Currently loaded ID range: $loadedMinId-$loadedMaxId',
            );
          }
        }

        return;
      }

      final previousCount = messages.length;
      print(
        '[ENSURE_MONTH] Loading older messages (current count: $previousCount)',
      );
      await loadOlder();
      final updatedState = state.valueOrNull;
      if (updatedState == null ||
          updatedState.messages.length == previousCount) {
        print('[ENSURE_MONTH] No new messages loaded, stopping');
        return;
      }
      print(
        '[ENSURE_MONTH] Loaded ${updatedState.messages.length - previousCount} more messages',
      );
    }
  }

  DateTime? _firstNonNullSentAt(List<ChatMessageListItem> messages) {
    for (final message in messages) {
      final sentAt = message.sentAt;
      if (sentAt != null) {
        return sentAt;
      }
    }
    return null;
  }
}
