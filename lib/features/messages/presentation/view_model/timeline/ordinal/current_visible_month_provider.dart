import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/value_objects/message_timeline_scope.dart';
import '../hydration/message_by_ordinal_provider.dart';
import 'message_timeline_ordinal_provider.dart';

part 'current_visible_month_provider.g.dart';

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
@riverpod
Future<String?> currentVisibleMonthForScope(
  CurrentVisibleMonthForScopeRef ref, {
  required MessageTimelineScope scope,
}) async {
  final ordinalAsync = ref.watch(messageTimelineOrdinalProvider(scope: scope));

  final ordinalState = ordinalAsync.valueOrNull;
  if (ordinalState == null || ordinalState.totalCount == 0) {
    return null;
  }

  // Get the currently visible positions
  final positions = ordinalState.itemPositionsListener.itemPositions.value;
  if (positions.isEmpty) {
    return null;
  }

  // Find the topmost visible item
  final topPosition = positions.reduce(
    (a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b,
  );
  final topOrdinal = topPosition.index;

  // Use the hydration provider to get the message and its date
  final messageItem = await ref.watch(
    messageByTimelineOrdinalProvider(scope: scope, ordinal: topOrdinal).future,
  );
  if (messageItem == null || messageItem.sentAt == null) {
    return null;
  }

  // Format as 'yyyy-MM'
  return DateFormat('yyyy-MM').format(messageItem.sentAt!);
}
