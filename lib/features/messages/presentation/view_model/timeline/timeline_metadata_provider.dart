import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart';
import '../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';

part 'timeline_metadata_provider.g.dart';

/// Lightweight metadata about a message timeline scope.
///
/// Used by the timeline view header to show descriptive information
/// without loading the full heatmap data structure.
class TimelineMetadata {
  const TimelineMetadata({
    required this.totalMessages,
    required this.firstMessageDate,
    required this.lastMessageDate,
  });

  /// Total message count in this scope.
  final int totalMessages;

  /// Date of the earliest message.
  final DateTime? firstMessageDate;

  /// Date of the most recent message.
  final DateTime? lastMessageDate;

  /// Human-readable duration span (e.g., "7 years, 2 months").
  String get durationSpan {
    if (firstMessageDate == null || lastMessageDate == null) {
      return '';
    }

    final months = _monthsBetween(firstMessageDate!, lastMessageDate!);
    if (months < 1) {
      return 'less than a month';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return remainingMonths == 1 ? '1 month' : '$remainingMonths months';
    }

    final yearPart = years == 1 ? '1 year' : '$years years';
    if (remainingMonths == 0) {
      return yearPart;
    }

    final monthPart =
        remainingMonths == 1 ? '1 month' : '$remainingMonths months';
    return '$yearPart, $monthPart';
  }

  int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month);
  }
}

/// Provides lightweight metadata about a timeline scope.
///
/// Fetches only the count and date bounds without computing full heatmap data.
@riverpod
Future<TimelineMetadata> timelineMetadata(
  TimelineMetadataRef ref, {
  required MessageTimelineScope scope,
}) async {
  // Watch message data version so we rebuild when new messages are imported.
  ref.watch(messageDataVersionProvider);

  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  return switch (scope) {
    GlobalTimelineScope() => _fetchGlobalMetadata(db),
    ContactTimelineScope(:final contactId) =>
      _fetchContactMetadata(db, contactId),
    ChatTimelineScope(:final chatId) => _fetchChatMetadata(db, chatId),
  };
}

Future<TimelineMetadata> _fetchGlobalMetadata(WorkingDatabase db) async {
  final result = await db
      .customSelect(
        '''
        SELECT 
          COUNT(*) as total_count,
          MIN(sent_at_utc) as first_date,
          MAX(sent_at_utc) as last_date
        FROM global_message_index
        WHERE sent_at_utc IS NOT NULL AND sent_at_utc != ''
        ''',
        readsFrom: {db.globalMessageIndex},
      )
      .getSingleOrNull();

  if (result == null) {
    return const TimelineMetadata(
      totalMessages: 0,
      firstMessageDate: null,
      lastMessageDate: null,
    );
  }

  final count = result.read<int?>('total_count') ?? 0;
  final firstUtc = result.read<String?>('first_date');
  final lastUtc = result.read<String?>('last_date');

  return TimelineMetadata(
    totalMessages: count,
    firstMessageDate: firstUtc != null ? DateTime.tryParse(firstUtc) : null,
    lastMessageDate: lastUtc != null ? DateTime.tryParse(lastUtc) : null,
  );
}

Future<TimelineMetadata> _fetchContactMetadata(
  WorkingDatabase db,
  int contactId,
) async {
  final result = await db
      .customSelect(
        '''
        SELECT 
          COUNT(*) as total_count,
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

  if (result == null) {
    return const TimelineMetadata(
      totalMessages: 0,
      firstMessageDate: null,
      lastMessageDate: null,
    );
  }

  final count = result.read<int?>('total_count') ?? 0;
  final firstUtc = result.read<String?>('first_date');
  final lastUtc = result.read<String?>('last_date');

  return TimelineMetadata(
    totalMessages: count,
    firstMessageDate: firstUtc != null ? DateTime.tryParse(firstUtc) : null,
    lastMessageDate: lastUtc != null ? DateTime.tryParse(lastUtc) : null,
  );
}

Future<TimelineMetadata> _fetchChatMetadata(
  WorkingDatabase db,
  int chatId,
) async {
  final result = await db
      .customSelect(
        '''
        SELECT 
          COUNT(*) as total_count,
          MIN(sent_at_utc) as first_date,
          MAX(sent_at_utc) as last_date
        FROM message_index
        WHERE chat_id = ?
          AND sent_at_utc IS NOT NULL 
          AND sent_at_utc != ''
        ''',
        variables: [drift.Variable.withInt(chatId)],
        readsFrom: {db.messageIndex},
      )
      .getSingleOrNull();

  if (result == null) {
    return const TimelineMetadata(
      totalMessages: 0,
      firstMessageDate: null,
      lastMessageDate: null,
    );
  }

  final count = result.read<int?>('total_count') ?? 0;
  final firstUtc = result.read<String?>('first_date');
  final lastUtc = result.read<String?>('last_date');

  return TimelineMetadata(
    totalMessages: count,
    firstMessageDate: firstUtc != null ? DateTime.tryParse(firstUtc) : null,
    lastMessageDate: lastUtc != null ? DateTime.tryParse(lastUtc) : null,
  );
}
