import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart'
    show SidebarFlowContactProjection, sidebarFlowProvider;
import '../../../messages/feature_level_providers.dart'
    show ConversationEvidenceScope, messageEvidenceTimelineSkeletonProvider;
import '../../../sidebar_utilities/feature_level_providers.dart'
    show TopChatMenuChoice;

part 'contact_conversation_navigation_actions_provider.g.dart';

@riverpod
class ContactConversationNavigationActions
    extends _$ContactConversationNavigationActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectContactConversation({
    required int contactId,
    required int conversationId,
    int? anchorMessageId,
    String? searchQuery,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ContactConversationSelected(
            contactId: contactId,
            conversationId: conversationId,
            anchorMessageId: anchorMessageId,
            searchQuery: searchQuery,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );
  }

  Future<void> selectContactConversationMonth({
    required int contactId,
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
          contactId: contactId,
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
          contactId: contactId,
          conversationId: conversationId,
          requestedMonthKey: requestedMonthKey,
          reason: 'no exact month match',
        );
        return;
      }

      final flowState = ref.read(sidebarFlowProvider);
      final selectionIsCurrent =
          flowState.topMenuChoice == TopChatMenuChoice.contacts &&
          flowState.chosenContactId == contactId &&
          flowState.selectedConversationId == conversationId &&
          flowState.contactProjection ==
              SidebarFlowContactProjection.conversations;
      if (!selectionIsCurrent) {
        _warnInertMonthNavigation(
          contactId: contactId,
          conversationId: conversationId,
          requestedMonthKey: requestedMonthKey,
          reason: 'selection changed while resolving skeleton',
        );
        return;
      }

      await selectContactConversation(
        contactId: contactId,
        conversationId: conversationId,
        anchorMessageId: targetEntry.messageId,
      );
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Contact conversation month navigation failed',
            source: 'ContactConversationNavigationActions',
            context: <String, Object?>{
              'contactId': contactId,
              'conversationId': conversationId,
              'requestedMonthKey': requestedMonthKey,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }

  void _warnInertMonthNavigation({
    required int contactId,
    required int conversationId,
    required String requestedMonthKey,
    required String reason,
  }) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Contact conversation month navigation remained inert',
          source: 'ContactConversationNavigationActions',
          context: <String, Object?>{
            'contactId': contactId,
            'conversationId': conversationId,
            'requestedMonthKey': requestedMonthKey,
            'reason': reason,
          },
        );
  }
}
