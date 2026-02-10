import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';

part 'global_messages_ordinal_provider.g.dart';

class GlobalMessagesOrdinalState {
  const GlobalMessagesOrdinalState({
    required this.totalCount,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  final int totalCount;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  GlobalMessagesOrdinalState copyWith({int? totalCount}) {
    return GlobalMessagesOrdinalState(
      totalCount: totalCount ?? this.totalCount,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }
}

@riverpod
class GlobalMessagesOrdinal extends _$GlobalMessagesOrdinal {
  @override
  Future<GlobalMessagesOrdinalState> build() async {
    final isMaintenance = ref.watch(dbMaintenanceLockProvider);

    if (isMaintenance) {
      return GlobalMessagesOrdinalState(
        totalCount: 0,
        itemScrollController: ItemScrollController(),
        itemPositionsListener: ItemPositionsListener.create(),
      );
    }

    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    final maxOrdinalExpression = db.globalMessageIndex.ordinal.max();
    final result = await (db.selectOnly(
      db.globalMessageIndex,
    )..addColumns([maxOrdinalExpression])).getSingleOrNull();

    final maxOrdinal = result?.read(maxOrdinalExpression);
    final totalCount = maxOrdinal == null ? 0 : maxOrdinal + 1;

    return GlobalMessagesOrdinalState(
      totalCount: totalCount,
      itemScrollController: ItemScrollController(),
      itemPositionsListener: ItemPositionsListener.create(),
    );
  }

  Future<void> jumpToLatest() async {
    final currentState = state.value;
    if (currentState == null || currentState.totalCount == 0) {
      debugPrint(
        '⚠️ GlobalMessagesOrdinal.jumpToLatest: state is null or empty',
      );
      return;
    }

    debugPrint(
      '🔍 GlobalMessagesOrdinal.jumpToLatest: jumping to index ${currentState.totalCount - 1}',
    );
    currentState.itemScrollController.jumpTo(
      index: currentState.totalCount - 1,
    );
  }

  Future<void> scrollTo(int ordinal, {Duration? duration}) async {
    final currentState = state.value;
    if (currentState == null) {
      debugPrint('⚠️ GlobalMessagesOrdinal.scrollTo: state is null');
      return;
    }

    debugPrint(
      '🔍 GlobalMessagesOrdinal.scrollTo: scrolling to index $ordinal',
    );
    await currentState.itemScrollController.scrollTo(
      index: ordinal,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
