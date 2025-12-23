import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../infrastructure/data_sources/contact_message_index_data_source.dart';

part 'contact_messages_ordinal_provider.g.dart';

/// Simplified state for ordinal-based contact message list.
/// Shows all messages with a contact across multiple chats/handles.
/// No placeholders, no hydration state - just total count and scroll controller.
class ContactMessagesOrdinalState {
  const ContactMessagesOrdinalState({
    required this.totalCount,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  /// Total message count for this contact across all chats
  final int totalCount;

  /// Controller for jumping to specific ordinal positions
  final ItemScrollController itemScrollController;

  /// Listener for tracking visible ordinals
  final ItemPositionsListener itemPositionsListener;

  ContactMessagesOrdinalState copyWith({int? totalCount}) {
    return ContactMessagesOrdinalState(
      totalCount: totalCount ?? this.totalCount,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }
}

@riverpod
class ContactMessagesOrdinal extends _$ContactMessagesOrdinal {
  late int _contactId;
  late ContactMessageIndexDataSource _indexSource;

  @override
  Future<ContactMessagesOrdinalState> build({required int contactId}) async {
    _contactId = contactId;

    final isMaintenance = ref.watch(dbMaintenanceLockProvider);

    // During destructive maintenance operations we intentionally avoid opening
    // the DB. Returning an empty state prevents the UI from getting stuck in a
    // long-lived loading state.
    if (isMaintenance) {
      return ContactMessagesOrdinalState(
        totalCount: 0,
        itemScrollController: ItemScrollController(),
        itemPositionsListener: ItemPositionsListener.create(),
      );
    }

    final db = await ref.watch(driftWorkingDatabaseProvider.future);
    _indexSource = ContactMessageIndexDataSource(db);

    // Get total count across all chats with this contact
    final totalCount = await _indexSource.getTotalCount(contactId);

    // Create scroll controllers
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();

    return ContactMessagesOrdinalState(
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
      _contactId,
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
