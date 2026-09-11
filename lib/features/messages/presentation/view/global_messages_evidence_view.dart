import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart'
    show effectiveRightPanelSpecProvider;
import '../../../conversations/feature_level_providers.dart'
    show conversationExcerptNavigationActionsProvider;
import '../../application/message_evidence/current_search_investigation_provider.dart';
import '../../application/message_evidence/current_visible_month_provider.dart';
import '../../application/message_evidence/global_messages_search_session_provider.dart';
import '../../domain/message_evidence/message_evidence_row_data.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../view_model/global_messages_evidence_presentation_provider.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class GlobalMessagesEvidenceView extends ConsumerStatefulWidget {
  const GlobalMessagesEvidenceView({this.monthAnchor, super.key});

  final DateTime? monthAnchor;

  @override
  ConsumerState<GlobalMessagesEvidenceView> createState() =>
      _GlobalMessagesEvidenceViewState();
}

class _GlobalMessagesEvidenceViewState
    extends ConsumerState<GlobalMessagesEvidenceView> {
  late final TextEditingController _searchController = TextEditingController();

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
    ref
        .read(
          globalMessagesSearchSessionProvider(
            monthAnchor: widget.monthAnchor,
          ).notifier,
        )
        .setQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final activeContextMessageId = _activeContextMessageId(ref);
    final presentation = ref.watch(
      globalMessagesEvidencePresentationProvider(
        monthAnchor: widget.monthAnchor,
      ),
    );
    if (_searchController.text != presentation.query) {
      _searchController.value = TextEditingValue(
        text: presentation.query,
        selection: TextSelection.collapsed(offset: presentation.query.length),
      );
    }
    final rawQuery = presentation.query;
    final evidenceScope = presentation.evidenceScope;
    final allMessagesSkeletonAsync = presentation.allMessagesSkeleton;
    final visibleSkeletonAsync = presentation.visibleSkeleton;

    return allMessagesSkeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (allMessagesSkeleton) {
        final visibleSkeleton = !presentation.hasExecutableSearch
            ? allMessagesSkeleton
            : visibleSkeletonAsync.valueOrNull ??
                  const MessageEvidenceTimelineSkeleton(entries: []);
        final labels = presentation.labels;
        if (labels == null) {
          return const Center(child: Text('Loading message timeline...'));
        }

        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: visibleSkeleton,
          headerData: MessageEvidenceHeaderModel(
            title: 'All messages',
            dateRangeLabel: labels.dateRange,
            countLabel: labels.count,
            activeScopeLabel: presentation.investigationStatus?.description,
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: _searchController,
              placeholder: 'Search these messages',
              mode: presentation.mode,
              onModeChanged: (mode) {
                ref
                    .read(
                      globalMessagesSearchSessionProvider(
                        monthAnchor: widget.monthAnchor,
                      ).notifier,
                    )
                    .setMode(mode);
              },
            ),
          ),
          emptyMessage: _emptyMessage(
            query: presentation.hasExecutableSearch ? rawQuery.trim() : '',
            hasMatchesLoaded:
                !presentation.hasExecutableSearch ||
                visibleSkeletonAsync.hasValue,
            error: visibleSkeletonAsync.error,
          ),
          monthAnchor: widget.monthAnchor,
          anchorMessageId: activeContextMessageId,
          highlightQuery: rawQuery,
          useFixedPanelFrame: true,
          resolveRowAction: _resolveConversationContextAction,
          onVisibleMonthChanged: (monthKey) {
            ref
                .read(
                  currentVisibleMonthForScopeProvider(
                    scope: const GlobalMessagesEvidenceScope(),
                  ).notifier,
                )
                .setVisibleMonthKey(monthKey);
          },
        );
      },
      loading: () => const Center(child: Text('Loading message timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Evidence timeline failed: $error')),
    );
  }

  int? _activeContextMessageId(WidgetRef ref) {
    final rightSpec = ref.watch(
      effectiveRightPanelSpecProvider(SidebarMode.messages),
    );
    return rightSpec?.when(
      messages: (_) => null,
      conversations: (conversationsSpec) {
        return conversationsSpec.anchorMessageId;
      },
      settings: (_) => null,
      environmentReadiness: (_) => null,
      onboarding: (_) => null,
    );
  }

  VoidCallback? _resolveConversationContextAction(
    MessageEvidenceScope _,
    MessageEvidenceRowData message,
    String __,
  ) {
    final conversationId = message.sourceConversationId;
    if (conversationId == null) {
      return null;
    }

    final actions = ref.read(
      conversationExcerptNavigationActionsProvider.notifier,
    );
    final investigationId = ref.read(currentSearchInvestigationProvider);
    if (actions.isActive(
      conversationId: conversationId,
      anchorMessageId: message.messageId,
      originatingInvestigationId: investigationId,
    )) {
      return null;
    }

    return () {
      actions.open(
        conversationId: conversationId,
        anchorMessageId: message.messageId,
        originatingInvestigationId: investigationId,
      );
    };
  }
}

String _emptyMessage({
  required String query,
  required bool hasMatchesLoaded,
  required Object? error,
}) {
  if (query.isEmpty) {
    return 'No messages found.';
  }
  if (error != null) {
    return 'Message search failed: $error';
  }
  if (!hasMatchesLoaded) {
    return 'Matching messages...';
  }
  return 'No messages match "$query".';
}
