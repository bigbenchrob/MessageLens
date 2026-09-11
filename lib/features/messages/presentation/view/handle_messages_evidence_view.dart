import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../../handles/feature_level_providers.dart'
    show handleDisplayNameProvider;
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class HandleMessagesEvidenceView extends ConsumerStatefulWidget {
  const HandleMessagesEvidenceView({required this.handleId, super.key});

  final int handleId;

  @override
  ConsumerState<HandleMessagesEvidenceView> createState() =>
      _HandleMessagesEvidenceViewState();
}

class _HandleMessagesEvidenceViewState
    extends ConsumerState<HandleMessagesEvidenceView> {
  late final TextEditingController _searchController = TextEditingController();
  var _query = '';
  var _searchMode = MessageEvidenceSearchMode.allTerms;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final evidenceScope = HandleMessagesEvidenceScope(
      handleId: widget.handleId,
    );
    final parsedQuery = MessageTextSearchQuery.parse(_query);
    final searchIntent = parsedQuery.executionIntent;
    final displayQuery = searchIntent.isExecutable ? _query.trim() : '';
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final displayNameAsync = ref.watch(
      handleDisplayNameProvider(handleId: widget.handleId),
    );
    final matchingIdsAsync = !searchIntent.isExecutable
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              searchIntent: searchIntent,
              mode: _searchMode,
            ),
          );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          headerData: MessageEvidenceHeaderModel(
            title: 'Messages for ${_handleLabel(displayNameAsync.valueOrNull)}',
            dateRangeLabel: _dateSpan(skeleton.entries),
            countLabel: _countLabel(
              totalCount: skeleton.totalCount,
              query: displayQuery,
              matchingIds: matchingIdsAsync?.valueOrNull,
              isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
            ),
            scopeContextLine: 'Handle scope',
            activeScopeLabel: displayQuery.isEmpty
                ? null
                : 'Message text contains "$displayQuery"',
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: _searchController,
              placeholder: 'Search messages from this handle',
              mode: _searchMode,
              onModeChanged: (mode) {
                setState(() {
                  _searchMode = mode;
                });
              },
            ),
          ),
          emptyMessage: 'No messages found for this handle.',
          highlightQuery: _query,
        );
      },
      loading: () => const Center(child: Text('Loading handle messages...')),
      error: (error, stackTrace) =>
          Center(child: Text('Handle messages failed: $error')),
    );
  }
}

String _handleLabel(String? value) {
  final label = value?.trim();
  if (label == null || label.isEmpty) {
    return 'this handle';
  }
  return label;
}

String _countLabel({
  required int totalCount,
  required String query,
  required List<int>? matchingIds,
  required bool isMatchingLoaded,
}) {
  if (query.isNotEmpty) {
    if (isMatchingLoaded) {
      return '${_formatCount(matchingIds?.length ?? 0)} of '
          '${CountLabelFormatter.messages(totalCount)} match "$query"';
    }
    return 'matching messages...';
  }
  return CountLabelFormatter.messages(totalCount);
}

String _dateSpan(List<MessageEvidenceSkeletonEntry> entries) {
  final dates = [
    for (final entry in entries)
      if (_parseDate(entry.dateUtc) case final DateTime date) date,
  ];
  if (dates.isEmpty) {
    return 'No dated messages';
  }
  dates.sort();
  return DateRangeFormatter.formatMessageEvidenceRange(
    start: dates.first,
    end: dates.last,
    itemCount: entries.length,
    emptyLabel: 'No dated messages',
  );
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String _formatCount(int count) {
  return CountLabelFormatter.formatCount(count);
}
