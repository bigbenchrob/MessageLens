import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../view_model/recovered_evidence_presentation.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class RecoveredMessagesEvidenceView extends ConsumerStatefulWidget {
  const RecoveredMessagesEvidenceView({
    this.contactId,
    this.scrollToDate,
    this.onlyNoHandleFromMe = false,
    super.key,
  });

  final int? contactId;
  final DateTime? scrollToDate;
  final bool onlyNoHandleFromMe;

  @override
  ConsumerState<RecoveredMessagesEvidenceView> createState() =>
      _RecoveredMessagesEvidenceViewState();
}

class _RecoveredMessagesEvidenceViewState
    extends ConsumerState<RecoveredMessagesEvidenceView> {
  late final TextEditingController _searchController = TextEditingController();
  String _query = '';
  MessageEvidenceSearchMode _searchMode = MessageEvidenceSearchMode.allTerms;

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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final scope = RecoveredMessagesEvidenceScope(
      contactId: widget.contactId,
      onlyNoHandleFromMe: widget.onlyNoHandleFromMe,
    );
    final parsedQuery = MessageTextSearchQuery.parse(_query);
    final searchIntent = parsedQuery.executionIntent;
    final displayQuery = searchIntent.isExecutable ? _query.trim() : '';
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: scope),
    );
    final matchingIdsAsync = !searchIntent.isExecutable
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: scope,
              searchIntent: searchIntent,
              mode: _searchMode,
            ),
          );
    final presentation = RecoveredEvidencePresentation.from(
      contactId: widget.contactId,
      onlyNoHandleFromMe: widget.onlyNoHandleFromMe,
    );

    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: skeletonAsync.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        data: (skeleton) {
          final visibleSkeleton = _visibleSkeleton(
            skeleton: skeleton,
            matchingIds: matchingIdsAsync?.valueOrNull,
            query: displayQuery,
          );
          return MessageEvidenceTimelineView(
            evidenceScope: scope,
            skeleton: visibleSkeleton,
            headerData: MessageEvidenceHeaderModel(
              title: presentation.title,
              scopeContextLine: presentation.description,
              dateRangeLabel: _dateSpan(visibleSkeleton.entries),
              countLabel: _countLabel(
                visibleCount: visibleSkeleton.totalCount,
                totalCount: skeleton.totalCount,
                query: displayQuery,
                isMatching: matchingIdsAsync?.hasValue ?? false,
              ),
              activeScopeLabel: displayQuery.isEmpty
                  ? null
                  : 'Message text contains "$displayQuery"',
              activeScopeIndicator: widget.scrollToDate == null
                  ? null
                  : _RecoveredScrollIndicator(
                      scrollToDate: widget.scrollToDate!,
                    ),
              searchConfig: MessageEvidenceHeaderSearchConfig(
                controller: _searchController,
                placeholder: 'Search recovered messages',
                mode: _searchMode,
                onModeChanged: (mode) {
                  setState(() {
                    _searchMode = mode;
                  });
                },
              ),
            ),
            emptyMessage: displayQuery.isEmpty
                ? presentation.emptyMessage
                : 'No recovered messages match "$displayQuery".',
            monthAnchor: widget.scrollToDate,
            highlightQuery: _query,
            useFixedPanelFrame: true,
            continueHeaderInNativeFlowAfterTracks: true,
          );
        },
        loading: () => Center(
          child: Text(
            'Loading recovered messages...',
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load recovered messages: $error',
            style: typography.body,
          ),
        ),
      ),
    );
  }
}

MessageEvidenceTimelineSkeleton _visibleSkeleton({
  required MessageEvidenceTimelineSkeleton skeleton,
  required List<int>? matchingIds,
  required String query,
}) {
  if (query.isEmpty) {
    return skeleton;
  }
  final matchingIdSet = (matchingIds ?? const <int>[]).toSet();
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in skeleton.entries)
        if (matchingIdSet.contains(entry.messageId)) entry,
    ],
    initialAnchorMessageId: skeleton.initialAnchorMessageId,
  );
}

String _countLabel({
  required int visibleCount,
  required int totalCount,
  required String query,
  required bool isMatching,
}) {
  if (query.isEmpty) {
    return CountLabelFormatter.recoveredMessages(totalCount);
  }
  if (!isMatching) {
    return 'matching recovered messages...';
  }
  return '${CountLabelFormatter.formatCount(visibleCount)} of '
      '${CountLabelFormatter.recoveredMessages(totalCount)} match "$query"';
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

class _RecoveredScrollIndicator extends StatelessWidget {
  const _RecoveredScrollIndicator({required this.scrollToDate});

  final DateTime scrollToDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Text(DateLabelFormatter.monthKey(scrollToDate)),
    );
  }
}
