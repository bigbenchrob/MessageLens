import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';

/// Prepared labels shared by the global evidence view and its Track occupants.
final class GlobalMessagesEvidenceHeaderLabels {
  const GlobalMessagesEvidenceHeaderLabels({
    required this.dateRange,
    required this.count,
  });

  final String dateRange;
  final String count;

  String get metadata {
    return [dateRange, count].where((part) => part.isNotEmpty).join('   ');
  }
}

/// Prepared semantic state for the current Search investigation status row.
final class SearchInvestigationStatusPresentationModel {
  const SearchInvestigationStatusPresentationModel({
    required this.description,
    required this.isSearching,
  });

  final String description;
  final bool isSearching;
}

GlobalMessagesEvidenceHeaderLabels globalMessagesEvidenceHeaderLabels({
  required MessageEvidenceTimelineSkeleton allMessagesSkeleton,
  required MessageEvidenceTimelineSkeleton visibleSkeleton,
  required String query,
  required bool hasMatchesLoaded,
  required DateTime? monthAnchor,
}) {
  return GlobalMessagesEvidenceHeaderLabels(
    dateRange: _dateRangeLabel(
      skeleton: allMessagesSkeleton,
      visibleSkeleton: visibleSkeleton,
      query: query,
      monthAnchor: monthAnchor,
    ),
    count: _countLabel(
      skeleton: allMessagesSkeleton,
      visibleSkeleton: visibleSkeleton,
      query: query,
      hasMatchesLoaded: hasMatchesLoaded,
      monthAnchor: monthAnchor,
    ),
  );
}

SearchInvestigationStatusPresentationModel?
searchInvestigationStatusPresentationModel({
  required String query,
  required DateTime? monthAnchor,
  required bool isSearching,
}) {
  if (query.isNotEmpty) {
    return SearchInvestigationStatusPresentationModel(
      description: 'Messages matching "$query"',
      isSearching: isSearching,
    );
  }
  if (monthAnchor != null) {
    return const SearchInvestigationStatusPresentationModel(
      description: 'Selected month',
      isSearching: false,
    );
  }
  return null;
}

String _dateRangeLabel({
  required MessageEvidenceTimelineSkeleton skeleton,
  required MessageEvidenceTimelineSkeleton visibleSkeleton,
  required String query,
  required DateTime? monthAnchor,
}) {
  if (query.isNotEmpty) {
    return _dateSpan(visibleSkeleton.entries);
  }

  final monthLabel = _monthLabel(monthAnchor);
  if (monthLabel != null) {
    return monthLabel;
  }

  return _dateSpan(skeleton.entries);
}

String _countLabel({
  required MessageEvidenceTimelineSkeleton skeleton,
  required MessageEvidenceTimelineSkeleton visibleSkeleton,
  required String query,
  required bool hasMatchesLoaded,
  required DateTime? monthAnchor,
}) {
  if (query.isNotEmpty) {
    if (hasMatchesLoaded) {
      return '${CountLabelFormatter.formatCount(visibleSkeleton.totalCount)} '
          'of ${CountLabelFormatter.messages(skeleton.totalCount)} '
          'match "$query"';
    }
    return 'matching messages...';
  }

  if (monthAnchor != null) {
    final monthKey = DateLabelFormatter.monthKey(monthAnchor);
    final count = skeleton.entries.where((entry) {
      return entry.monthKey == monthKey;
    }).length;
    return '${CountLabelFormatter.messages(count)} this month';
  }

  return CountLabelFormatter.messages(skeleton.totalCount);
}

String _dateSpan(List<MessageEvidenceSkeletonEntry> entries) {
  final dates = [
    for (final entry in entries)
      if (DateLabelFormatter.parseIso(entry.dateUtc) case final DateTime date)
        date,
  ]..sort();
  if (dates.isEmpty) {
    return 'No dated messages';
  }
  return DateRangeFormatter.formatMessageEvidenceRange(
    start: dates.first,
    end: dates.last,
    itemCount: entries.length,
    emptyLabel: 'No dated messages',
  );
}

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateLabelFormatter.longMonthYear(value);
}
