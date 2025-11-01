import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../infrastructure/data_sources/message_index_data_source.dart';

part 'chat_messages_ordinal_provider.g.dart';

/// Simplified state for ordinal-based message list.
/// No placeholders, no hydration state - just total count and scroll controller.
class MessagesOrdinalState {
  const MessagesOrdinalState({
    required this.totalCount,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  /// Total message count for this chat
  final int totalCount;

  /// Controller for jumping to specific ordinal positions
  final ItemScrollController itemScrollController;

  /// Listener for tracking visible ordinals
  final ItemPositionsListener itemPositionsListener;

  MessagesOrdinalState copyWith({int? totalCount}) {
    return MessagesOrdinalState(
      totalCount: totalCount ?? this.totalCount,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }
}

@riverpod
class ChatMessagesOrdinal extends _$ChatMessagesOrdinal {
  late int _chatId;
  late MessageIndexDataSource _indexSource;

  @override
  Future<MessagesOrdinalState> build({required int chatId}) async {
    _chatId = chatId;

    final db = await ref.watch(driftWorkingDatabaseProvider.future);
    _indexSource = MessageIndexDataSource(db);

    // Get total count
    final totalCount = await _indexSource.getTotalCount(chatId);

    // Create scroll controllers
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();

    return MessagesOrdinalState(
      totalCount: totalCount,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }

  /// Jump to a specific month in the timeline.
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<void> jumpToMonth(String monthKey) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    // Find first ordinal for this month
    final ordinal = await _indexSource.getFirstOrdinalForMonth(
      _chatId,
      monthKey,
    );

    if (ordinal == null) {
      // Month not found, no messages in that period
      return;
    }

    // Jump to the ordinal
    currentState.itemScrollController.jumpTo(index: ordinal);
  }

  /// Jump to the latest (most recent) message.
  Future<void> jumpToLatest() async {
    final currentState = state.value;
    if (currentState == null || currentState.totalCount == 0) {
      return;
    }

    // Jump to last ordinal (count - 1 since 0-indexed)
    currentState.itemScrollController.jumpTo(
      index: currentState.totalCount - 1,
    );
  }

  /// Scroll to a specific ordinal with animation.
  Future<void> scrollTo(int ordinal, {Duration? duration}) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    await currentState.itemScrollController.scrollTo(
      index: ordinal,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
