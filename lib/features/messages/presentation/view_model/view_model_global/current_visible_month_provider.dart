import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../infrastructure/data_sources/global_message_index_data_source.dart';
import 'jump/global_messages_ordinal_provider.dart';

part 'current_visible_month_provider.g.dart';

/// Tracks the currently visible month based on scroll position
/// Returns monthKey in format "YYYY-MM" (e.g., "2025-12")
@riverpod
Stream<String?> currentVisibleMonth(CurrentVisibleMonthRef ref) async* {
  final ordinalState = await ref.watch(globalMessagesOrdinalProvider.future);

  if (ordinalState.totalCount == 0) {
    yield null;
    return;
  }

  final listener = ordinalState.itemPositionsListener;
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final dataSource = GlobalMessageIndexDataSource(db);

  // Listen to position changes
  await for (final positions in Stream.periodic(
    const Duration(milliseconds: 300),
    (_) => listener.itemPositions.value,
  )) {
    if (positions.isEmpty) {
      continue;
    }

    // Get the first visible item (closest to top)
    final topItem = positions
        .where((pos) => pos.itemLeadingEdge < 1.0)
        .reduce((a, b) => a.itemLeadingEdge > b.itemLeadingEdge ? a : b);

    try {
      final entry = await dataSource.getByOrdinal(topItem.index);
      if (entry != null) {
        yield entry.monthKey;
      }
    } catch (e) {
      debugPrint('Error fetching month for ordinal ${topItem.index}: $e');
    }
  }
}
