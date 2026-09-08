import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../../../messages/feature_level_providers.dart'
    show ConversationEvidenceScope, messageEvidenceTimelineSkeletonProvider;
import '../../../../sidebar_utilities/feature_level_providers.dart'
    show TopChatMenuChoice;

part 'conversation_navigation_actions_provider.g.dart';

@riverpod
class ConversationNavigationActions extends _$ConversationNavigationActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectConversation({
    required int conversationId,
    int? anchorMessageId,
    String? searchQuery,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ConversationSelected(
            conversationId: conversationId,
            anchorMessageId: anchorMessageId,
            searchQuery: searchQuery,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }

  Future<void> selectConversationMonth({
    required int conversationId,
    required DateTime monthAnchor,
  }) async {
    final requestedMonthKey = DateLabelFormatter.monthKey(monthAnchor);
    try {
      final skeleton = await ref.read(
        messageEvidenceTimelineSkeletonProvider(
          scope: ConversationEvidenceScope(conversationId: conversationId),
        ).future,
      );
      if (skeleton.isEmpty) {
        _warnInertMonthNavigation(
          conversationId: conversationId,
          requestedMonthKey: requestedMonthKey,
          reason: 'empty skeleton',
        );
        return;
      }

      final targetIndex = skeleton.indexForMonth(monthAnchor);
      final targetEntry = skeleton.entries[targetIndex];
      if (targetEntry.monthKey != requestedMonthKey) {
        _warnInertMonthNavigation(
          conversationId: conversationId,
          requestedMonthKey: requestedMonthKey,
          reason: 'no exact month match',
        );
        return;
      }

      final flowState = ref.read(sidebarFlowProvider);
      if (flowState.topMenuChoice != TopChatMenuChoice.conversations ||
          flowState.selectedConversationId != conversationId) {
        _warnInertMonthNavigation(
          conversationId: conversationId,
          requestedMonthKey: requestedMonthKey,
          reason: 'selection changed while resolving skeleton',
        );
        return;
      }

      await selectConversation(
        conversationId: conversationId,
        anchorMessageId: targetEntry.messageId,
      );
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Conversation month navigation failed',
            source: 'ConversationNavigationActions',
            context: <String, Object?>{
              'conversationId': conversationId,
              'requestedMonthKey': requestedMonthKey,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }

  void _warnInertMonthNavigation({
    required int conversationId,
    required String requestedMonthKey,
    required String reason,
  }) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Conversation month navigation remained inert',
          source: 'ConversationNavigationActions',
          context: <String, Object?>{
            'conversationId': conversationId,
            'requestedMonthKey': requestedMonthKey,
            'reason': reason,
          },
        );
  }
}
