import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../application/message_evidence/contact_evidence_header_context_provider.dart';
import '../../application/message_evidence/current_visible_month_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_row_data.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../view_model/contact_messages_evidence_presentation.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class ContactMessagesEvidenceView extends ConsumerStatefulWidget {
  const ContactMessagesEvidenceView({
    required this.contactId,
    this.monthAnchor,
    this.filterHandleId,
    super.key,
  });

  final int contactId;
  final DateTime? monthAnchor;
  final int? filterHandleId;

  @override
  ConsumerState<ContactMessagesEvidenceView> createState() =>
      _ContactMessagesEvidenceViewState();
}

class _ContactMessagesEvidenceViewState
    extends ConsumerState<ContactMessagesEvidenceView> {
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
    final evidenceScope = widget.filterHandleId == null
        ? ContactAllMessagesEvidenceScope(contactId: widget.contactId)
        : ContactHandleMessagesEvidenceScope(
            contactId: widget.contactId,
            handleId: widget.filterHandleId!,
          );
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final initialRowsAsync = ref.watch(
      messageEvidenceInitialRowsProvider(
        scope: evidenceScope,
        monthAnchor: widget.monthAnchor,
        hydrationLimit: widget.monthAnchor == null ? 80 : 500,
      ),
    );
    final headerContextAsync = ref.watch(
      contactEvidenceHeaderContextProvider(
        contactId: widget.contactId,
        filterHandleId: widget.filterHandleId,
      ),
    );
    final parsedQuery = MessageTextSearchQuery.parse(_query);
    final searchIntent = parsedQuery.executionIntent;
    final displayQuery = searchIntent.isExecutable ? _query.trim() : '';
    final matchingIdsAsync = !searchIntent.isExecutable
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              searchIntent: searchIntent,
              mode: _searchMode,
            ),
          );
    final headerPresentation = ContactMessagesEvidencePresentation.from(
      headerContext: headerContextAsync.valueOrNull,
      filterHandleId: widget.filterHandleId,
      isHeaderLoading:
          headerContextAsync.isLoading && !headerContextAsync.hasValue,
    );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        if (headerContextAsync.isLoading && !headerContextAsync.hasValue) {
          return MessageEvidenceTimelineView(
            evidenceScope: evidenceScope,
            skeleton: skeleton,
            isInitialRowsLoading: true,
            headerData: MessageEvidenceHeaderModel(
              title: headerPresentation.title,
              countLabel: CountLabelFormatter.messages(skeleton.totalCount),
            ),
            emptyMessage: 'No messages found for this contact.',
            monthAnchor: widget.monthAnchor,
            useFixedPanelFrame: true,
            continueHeaderInNativeFlowAfterTracks: true,
          );
        }

        return _ContactMessagesEvidenceTimeline(
          contactId: widget.contactId,
          headerContext: headerContextAsync.valueOrNull,
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          initialRows: initialRowsAsync.valueOrNull ?? const {},
          isInitialRowsLoading:
              initialRowsAsync.isLoading && !initialRowsAsync.hasValue,
          monthAnchor: widget.monthAnchor,
          filterHandleId: widget.filterHandleId,
          searchQuery: displayQuery,
          rawSearchQuery: _query,
          matchingMessageIds: matchingIdsAsync?.valueOrNull,
          isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
          searchController: _searchController,
          searchMode: _searchMode,
          onSearchModeChanged: (mode) {
            setState(() {
              _searchMode = mode;
            });
          },
        );
      },
      loading: () => MessageEvidenceTimelineView(
        evidenceScope: evidenceScope,
        skeleton: const MessageEvidenceTimelineSkeleton(entries: []),
        headerData: MessageEvidenceHeaderModel(title: headerPresentation.title),
        emptyMessage: 'Loading contact timeline...',
        monthAnchor: widget.monthAnchor,
        useFixedPanelFrame: true,
        continueHeaderInNativeFlowAfterTracks: true,
      ),
      error: (error, stackTrace) => MessageEvidenceTimelineView(
        evidenceScope: evidenceScope,
        skeleton: const MessageEvidenceTimelineSkeleton(entries: []),
        headerData: MessageEvidenceHeaderModel(title: headerPresentation.title),
        emptyMessage: 'Contact message timeline failed: $error',
        monthAnchor: widget.monthAnchor,
        useFixedPanelFrame: true,
        continueHeaderInNativeFlowAfterTracks: true,
      ),
    );
  }
}

class _ContactMessagesEvidenceTimeline extends ConsumerWidget {
  const _ContactMessagesEvidenceTimeline({
    required this.contactId,
    required this.headerContext,
    required this.evidenceScope,
    required this.skeleton,
    required this.initialRows,
    required this.isInitialRowsLoading,
    required this.monthAnchor,
    required this.filterHandleId,
    required this.searchQuery,
    required this.rawSearchQuery,
    required this.matchingMessageIds,
    required this.isMatchingLoaded,
    required this.searchController,
    required this.searchMode,
    required this.onSearchModeChanged,
  });

  final int contactId;
  final ContactEvidenceHeaderContext? headerContext;
  final MessageEvidenceScope evidenceScope;
  final MessageEvidenceTimelineSkeleton skeleton;
  final Map<int, MessageEvidenceRowData> initialRows;
  final bool isInitialRowsLoading;
  final DateTime? monthAnchor;
  final int? filterHandleId;
  final String searchQuery;
  final String rawSearchQuery;
  final List<int>? matchingMessageIds;
  final bool isMatchingLoaded;
  final TextEditingController searchController;
  final MessageEvidenceSearchMode searchMode;
  final ValueChanged<MessageEvidenceSearchMode> onSearchModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleSkeleton = _visibleSkeleton(
      skeleton: skeleton,
      query: searchQuery,
      matchingIds: matchingMessageIds,
      isMatchingLoaded: isMatchingLoaded,
    );
    return MessageEvidenceTimelineView(
      evidenceScope: evidenceScope,
      skeleton: visibleSkeleton,
      initialRows: initialRows,
      isInitialRowsLoading: isInitialRowsLoading,
      headerData: MessageEvidenceHeaderModel(
        title: _title(),
        identityContextLine: _selectedHandleContextLine(),
        dateRangeLabel: _dateRangeLabel(),
        countLabel: _countLabel(),
        activeScopeLabel: _activeScopeLabel(),
        searchConfig: MessageEvidenceHeaderSearchConfig(
          controller: searchController,
          placeholder: 'Search messages from ${_contactLabel()}',
          mode: searchMode,
          onModeChanged: onSearchModeChanged,
        ),
      ),
      emptyMessage: _emptyMessage(),
      monthAnchor: monthAnchor,
      highlightQuery: rawSearchQuery,
      useFixedPanelFrame: true,
      continueHeaderInNativeFlowAfterTracks: true,
      onVisibleMonthChanged: (monthKey) {
        ref
            .read(
              currentVisibleMonthForScopeProvider(
                scope: evidenceScope,
              ).notifier,
            )
            .setVisibleMonthKey(monthKey);
      },
    );
  }

  String? _dateRangeLabel() {
    if (searchQuery.isNotEmpty) {
      return _dateSpanForSkeleton();
    }

    final monthLabel = _monthLabel(monthAnchor);
    if (monthLabel != null) {
      return monthLabel;
    }

    if (filterHandleId != null) {
      return _dateSpanForSkeleton();
    }

    if (headerContext?.firstMessageAtUtc == null &&
        headerContext?.lastMessageAtUtc == null) {
      return null;
    }

    return _dateSpan(
      headerContext?.firstMessageAtUtc,
      headerContext?.lastMessageAtUtc,
      itemCount: headerContext?.totalMessageCount,
    );
  }

  String _countLabel() {
    if (searchQuery.isNotEmpty) {
      if (isMatchingLoaded) {
        return '${_formatCount(matchingMessageIds?.length ?? 0)} of '
            '${CountLabelFormatter.messages(skeleton.totalCount)} match "$searchQuery"';
      }
      return 'matching messages...';
    }

    final monthLabel = _monthLabel(monthAnchor);
    if (monthLabel != null) {
      return '${CountLabelFormatter.messages(_monthMessageCount(_monthKey(monthAnchor!)))} this month';
    }

    if (filterHandleId != null) {
      return CountLabelFormatter.messages(skeleton.totalCount);
    }

    final totalMessageCount = headerContext?.totalMessageCount;
    if (totalMessageCount == null) {
      return CountLabelFormatter.messages(skeleton.totalCount);
    }

    return CountLabelFormatter.messages(totalMessageCount);
  }

  String? _activeScopeLabel() {
    if (searchQuery.isNotEmpty) {
      return 'Message text contains "$searchQuery"';
    }
    if (monthAnchor != null) {
      return 'Selected month';
    }
    return null;
  }

  String _emptyMessage() {
    if (searchQuery.isNotEmpty) {
      if (!isMatchingLoaded) {
        return 'Matching contact messages...';
      }
      return 'No contact messages match "$searchQuery".';
    }
    if (monthAnchor != null) {
      return 'No messages found for this contact in the selected month.';
    }
    if (filterHandleId != null) {
      return 'No messages found for this contact and handle.';
    }
    return 'No messages found for this contact.';
  }

  String _contactLabel() {
    final label = headerContext?.contactName.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return 'this contact';
  }

  String _title() {
    return ContactMessagesEvidencePresentation.from(
      headerContext: headerContext,
      filterHandleId: filterHandleId,
      isHeaderLoading: false,
    ).title;
  }

  String? _selectedHandleContextLine() {
    if (filterHandleId == null) {
      return null;
    }
    return 'Selected handle: ${headerContext?.selectedHandleLabel ?? 'handle $filterHandleId'}';
  }

  int _monthMessageCount(String monthKey) {
    return skeleton.entries.where((entry) {
      return entry.monthKey == monthKey;
    }).length;
  }

  String _dateSpanForSkeleton() {
    if (skeleton.entries.isEmpty) {
      return 'No date range';
    }
    return _dateSpan(
      skeleton.entries.first.dateUtc,
      skeleton.entries.last.dateUtc,
      itemCount: skeleton.entries.length,
    );
  }
}

MessageEvidenceTimelineSkeleton _visibleSkeleton({
  required MessageEvidenceTimelineSkeleton skeleton,
  required String query,
  required List<int>? matchingIds,
  required bool isMatchingLoaded,
}) {
  if (query.isEmpty) {
    return skeleton;
  }
  if (!isMatchingLoaded) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  return skeleton.filteredByMessageIds(matchingIds ?? const <int>[]);
}

String _monthKey(DateTime value) {
  return DateLabelFormatter.monthKey(value);
}

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateLabelFormatter.longMonthYear(value);
}

String _dateSpan(String? first, String? last, {int? itemCount}) {
  return DateRangeFormatter.formatMessageEvidenceRangeFromIsoStrings(
    startIso: first,
    endIso: last,
    itemCount: itemCount,
  );
}

String _formatCount(int count) {
  return CountLabelFormatter.formatCount(count);
}
