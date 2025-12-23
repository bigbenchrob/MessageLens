import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../messages/domain/calendar_heatmap_timeline_data.dart';
import 'contact_timeline_calculator.dart';

part 'contact_timeline_provider.g.dart';

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
@riverpod
Future<CalendarHeatmapTimelineData?> contactTimeline(
  ContactTimelineRef ref, {
  required int contactId,
  DateTime? firstMessageDate,
  DateTime? lastMessageDate,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // If dates aren't provided, query them from the database
  var firstDate = firstMessageDate;
  var lastDate = lastMessageDate;

  if (firstDate == null || lastDate == null) {
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

    if (datesQuery != null) {
      final firstUtc = datesQuery.read<String?>('first_date');
      final lastUtc = datesQuery.read<String?>('last_date');

      if (firstUtc != null && firstUtc.isNotEmpty) {
        firstDate = DateTime.tryParse(firstUtc);
      }
      if (lastUtc != null && lastUtc.isNotEmpty) {
        lastDate = DateTime.tryParse(lastUtc);
      }
    }
  }

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
