import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../infrastructure/data_sources/global_message_index_data_source.dart';

part 'global_message_timeline_provider.g.dart';

class GlobalMessageTimelineItem {
  const GlobalMessageTimelineItem({
    required this.ordinal,
    required this.messageId,
    required this.chatId,
    required this.sentAt,
    required this.monthKey,
  });

  final int ordinal;
  final int messageId;
  final int chatId;
  final DateTime? sentAt;
  final String monthKey;
}

class GlobalMessageTimelinePage {
  const GlobalMessageTimelinePage({
    required this.items,
    required this.totalCount,
    required this.hasMoreBefore,
    required this.hasMoreAfter,
  });

  const GlobalMessageTimelinePage.empty()
    : items = const [],
      totalCount = 0,
      hasMoreBefore = false,
      hasMoreAfter = false;

  final List<GlobalMessageTimelineItem> items;
  final int totalCount;
  final bool hasMoreBefore;
  final bool hasMoreAfter;
}

@riverpod
class GlobalMessageTimeline extends _$GlobalMessageTimeline {
  static const int _defaultPageSize = 100;

  @override
  Future<GlobalMessageTimelinePage> build({
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
    int? pageSize,
  }) async {
    if (startAfterOrdinal != null && endBeforeOrdinal != null) {
      throw ArgumentError(
        'startAfterOrdinal and endBeforeOrdinal cannot both be provided.',
      );
    }

    final effectiveLimit = pageSize ?? _defaultPageSize;
    if (effectiveLimit <= 0) {
      throw ArgumentError.value(effectiveLimit, 'pageSize', 'Must be positive');
    }

    final db = await ref.watch(driftWorkingDatabaseProvider.future);
    final dataSource = GlobalMessageIndexDataSource(db);

    final totalCount = await dataSource.getTotalCount();
    if (totalCount == 0) {
      return const GlobalMessageTimelinePage.empty();
    }

    final entries = await _fetchEntries(
      dataSource: dataSource,
      startAfterOrdinal: startAfterOrdinal,
      endBeforeOrdinal: endBeforeOrdinal,
      limit: effectiveLimit,
    );

    if (entries.isEmpty) {
      return GlobalMessageTimelinePage(
        items: const [],
        totalCount: totalCount,
        hasMoreBefore: startAfterOrdinal != null,
        hasMoreAfter: endBeforeOrdinal != null,
      );
    }

    final items = entries
        .map(
          (entry) => GlobalMessageTimelineItem(
            ordinal: entry.ordinal,
            messageId: entry.messageId,
            chatId: entry.chatId,
            sentAt: entry.sentAtUtc == null
                ? null
                : DateTime.tryParse(entry.sentAtUtc!),
            monthKey: entry.monthKey,
          ),
        )
        .toList(growable: false);

    final hasMoreBefore = items.first.ordinal > 0;
    final hasMoreAfter = items.last.ordinal < totalCount - 1;

    return GlobalMessageTimelinePage(
      items: items,
      totalCount: totalCount,
      hasMoreBefore: hasMoreBefore,
      hasMoreAfter: hasMoreAfter,
    );
  }

  Future<List<GlobalMessageIndexEntry>> _fetchEntries({
    required GlobalMessageIndexDataSource dataSource,
    required int limit,
    int? startAfterOrdinal,
    int? endBeforeOrdinal,
  }) async {
    if (startAfterOrdinal != null) {
      return dataSource.fetchAfterOrdinal(
        startExclusiveOrdinal: startAfterOrdinal,
        limit: limit,
      );
    }

    if (endBeforeOrdinal != null) {
      return dataSource.fetchBeforeOrdinal(
        endExclusiveOrdinal: endBeforeOrdinal,
        limit: limit,
      );
    }

    return dataSource.fetchFirstPage(limit);
  }
}

class GlobalTimelineBounds {
  const GlobalTimelineBounds({this.earliest, this.latest});

  final DateTime? earliest;
  final DateTime? latest;
}

@riverpod
Future<GlobalTimelineBounds> globalTimelineBounds(
  GlobalTimelineBoundsRef ref,
) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final sentAtMin = db.globalMessageIndex.sentAtUtc.min();
  final sentAtMax = db.globalMessageIndex.sentAtUtc.max();

  final result = await (db.selectOnly(
    db.globalMessageIndex,
  )..addColumns([sentAtMin, sentAtMax])).getSingleOrNull();

  DateTime? parse(String? value) {
    if (value == null) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  return GlobalTimelineBounds(
    earliest: parse(result?.read(sentAtMin)),
    latest: parse(result?.read(sentAtMax)),
  );
}

@riverpod
Future<int?> globalTimelineOrdinalForDate(
  GlobalTimelineOrdinalForDateRef ref,
  DateTime date,
) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final dataSource = GlobalMessageIndexDataSource(db);
  return dataSource.firstOrdinalOnOrAfter(date);
}
