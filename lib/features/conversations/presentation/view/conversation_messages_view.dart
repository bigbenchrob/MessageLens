import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../../messages/application/message_evidence/message_evidence_spine_provider.dart';
import '../../../messages/domain/message_evidence/message_evidence_scope.dart';
import '../../../messages/domain/message_evidence/message_evidence_search_mode.dart';
import '../../../messages/domain/message_evidence/message_evidence_skeleton.dart';
import '../../../messages/presentation/widgets/message_evidence/message_evidence_header.dart';
import '../../../messages/presentation/widgets/message_evidence/message_evidence_timeline_view.dart';
import '../../application/message_evidence/conversation_evidence_header_context_provider.dart';
import '../view_model/conversation_messages_evidence_presentation.dart';

class ConversationMessagesView extends ConsumerStatefulWidget {
  const ConversationMessagesView({
    required this.conversationId,
    this.anchorMessageId,
    this.searchQuery,
    super.key,
  });

  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;

  @override
  ConsumerState<ConversationMessagesView> createState() =>
      _ConversationMessagesViewState();
}

class _ConversationMessagesViewState
    extends ConsumerState<ConversationMessagesView> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.searchQuery ?? '',
  );
  var _query = '';
  var _searchMode = MessageEvidenceSearchMode.allTerms;

  @override
  void initState() {
    super.initState();
    _query = _searchController.text;
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
    final evidenceScope = ConversationEvidenceScope(
      conversationId: widget.conversationId,
    );
    final parsedQuery = MessageTextSearchQuery.parse(_query);
    final searchIntent = parsedQuery.executionIntent;
    final displayQuery = searchIntent.isExecutable ? _query.trim() : '';
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
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
    final headerContextAsync = ref.watch(
      conversationEvidenceHeaderContextProvider(
        conversationId: widget.conversationId,
      ),
    );
    final headerPresentation = ConversationMessagesEvidencePresentation.from(
      headerContext: headerContextAsync.valueOrNull,
    );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        final headerContext = headerContextAsync.valueOrNull;
        final matchingIds = matchingIdsAsync?.valueOrNull;
        final isMatchingLoaded = matchingIdsAsync?.hasValue ?? false;
        final visibleSkeleton = _visibleSkeleton(
          skeleton: skeleton,
          query: displayQuery,
          matchingIds: matchingIds,
          isMatchingLoaded: isMatchingLoaded,
        );
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: visibleSkeleton,
          headerData: MessageEvidenceHeaderModel(
            title: ConversationMessagesEvidencePresentation.from(
              headerContext: headerContext,
            ).title,
            dateRangeLabel: _dateRangeLabel(headerContext),
            countLabel: _countLabel(
              headerContext,
              skeleton.totalCount,
              displayQuery,
              matchingIds,
              isMatchingLoaded,
            ),
            activeScopeLabel: _activeScopeLabel(displayQuery),
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: _searchController,
              placeholder: 'Search this conversation',
              mode: _searchMode,
              onModeChanged: (mode) {
                setState(() {
                  _searchMode = mode;
                });
              },
            ),
          ),
          emptyMessage: _emptyMessage(
            query: displayQuery,
            isMatchingLoaded: isMatchingLoaded,
          ),
          anchorMessageId: widget.anchorMessageId,
          highlightQuery: _query,
          useFixedPanelFrame: true,
          continueHeaderInNativeFlowAfterTracks: true,
        );
      },
      loading: () => MessageEvidenceTimelineView(
        evidenceScope: evidenceScope,
        skeleton: const MessageEvidenceTimelineSkeleton(entries: []),
        headerData: MessageEvidenceHeaderModel(title: headerPresentation.title),
        emptyMessage: 'Loading conversation graph timeline...',
        anchorMessageId: widget.anchorMessageId,
        highlightQuery: _query,
        useFixedPanelFrame: true,
        continueHeaderInNativeFlowAfterTracks: true,
      ),
      error: (error, stackTrace) => MessageEvidenceTimelineView(
        evidenceScope: evidenceScope,
        skeleton: const MessageEvidenceTimelineSkeleton(entries: []),
        headerData: MessageEvidenceHeaderModel(title: headerPresentation.title),
        emptyMessage: 'Conversation graph timeline failed: $error',
        anchorMessageId: widget.anchorMessageId,
        highlightQuery: _query,
        useFixedPanelFrame: true,
        continueHeaderInNativeFlowAfterTracks: true,
      ),
    );
  }

  String? _dateRangeLabel(ConversationEvidenceHeaderContext? headerContext) {
    final dateSpan = _conversationDateSpan(headerContext);
    if (dateSpan.isEmpty) {
      return null;
    }
    return dateSpan;
  }

  String _countLabel(
    ConversationEvidenceHeaderContext? headerContext,
    int skeletonCount,
    String query,
    List<int>? matchingIds,
    bool isMatchingLoaded,
  ) {
    final messageCount = headerContext?.messageCount ?? skeletonCount;
    if (query.isNotEmpty) {
      if (isMatchingLoaded) {
        return '${_formatCount(matchingIds?.length ?? 0)} of '
            '${CountLabelFormatter.messages(messageCount)} match "$query"';
      }
      return 'matching messages...';
    }
    return CountLabelFormatter.messages(messageCount);
  }

  String? _activeScopeLabel(String query) {
    final parts = <String>[];
    if (query.isNotEmpty) {
      parts.add('Message text contains "$query"');
    }
    if (widget.anchorMessageId != null) {
      parts.add('Anchored at message ${widget.anchorMessageId}');
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' • ');
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

String _emptyMessage({required String query, required bool isMatchingLoaded}) {
  if (query.isEmpty) {
    return 'No messages found for this conversation.';
  }
  if (!isMatchingLoaded) {
    return 'Matching conversation messages...';
  }
  return 'No conversation messages match "$query".';
}

String _conversationDateSpan(ConversationEvidenceHeaderContext? headerContext) {
  return DateRangeFormatter.formatMessageEvidenceRangeFromIsoStrings(
    startIso: headerContext?.firstMessageAtUtc,
    endIso: headerContext?.lastMessageAtUtc,
    itemCount: headerContext?.messageCount,
    emptyLabel: '',
  );
}

String _formatCount(int count) {
  return CountLabelFormatter.formatCount(count);
}
