import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import 'contact_timeline_calculator.dart';

part 'contact_timeline_provider.g.dart';

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
///
/// This is a resolver tool: a data-fetching provider used by resolvers and
/// widget builders. It queries date bounds from `contact_message_index` then
/// delegates computation to [calculateContactCalendarHeatmapTimeline].
@riverpod
Future<CalendarHeatmapTimelineData?> contactTimeline(
  Ref ref, {
  required int contactId,
}) async {
  // Watch message data version so we rebuild when new messages are imported.
  ref.watch(messageDataVersionProvider);

  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  final datesQuery = await db
      .customSelect(
        '''
    SELECT
      MIN(sent_at_utc) as first_date,
      MAX(sent_at_utc) as last_date
    FROM contact_message_index
    WHERE contact_id = ?
      AND sent_at_utc IS NOT NULL
      AND sent_at_utc != ''
    ''',
        variables: [drift.Variable.withInt(contactId)],
        readsFrom: {db.contactMessageIndex},
      )
      .getSingleOrNull();

  if (datesQuery == null) {
    return null;
  }

  final firstUtc = datesQuery.read<String?>('first_date');
  final lastUtc = datesQuery.read<String?>('last_date');

  final firstDate = (firstUtc != null && firstUtc.isNotEmpty)
      ? DateTime.tryParse(firstUtc)
      : null;
  final lastDate = (lastUtc != null && lastUtc.isNotEmpty)
      ? DateTime.tryParse(lastUtc)
      : null;

  if (firstDate == null || lastDate == null) {
    return null;
  }

  return calculateContactCalendarHeatmapTimeline(
    db,
    contactId,
    firstDate,
    lastDate,
  );
}
