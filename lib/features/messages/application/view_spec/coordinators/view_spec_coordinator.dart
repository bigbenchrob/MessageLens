import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/messages_view_spec.dart';
import '../resolvers/global_timeline_resolver.dart';
import '../resolvers/handle_lens_resolver.dart';
import '../resolvers/messages_for_contact_resolver.dart';
import '../resolvers/messages_for_handle_resolver.dart';
import '../resolvers/recovered_unlinked_messages_resolver.dart';

part 'view_spec_coordinator.g.dart';

/// Coordinator that maps [MessagesSpec] to rendered widgets for the center panel.
///
/// Each variant is delegated to a dedicated resolver, which in turn calls a
/// widget builder in `../widget_builders/`.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a center-panel widget for the given [MessagesSpec].
  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forChat: (chatId) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Messages for chat view is coming soon.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      forContact: (contactId, scrollToDate, filterHandleId) =>
          MessagesForContactResolver().resolve(
            contactId: contactId,
            scrollToDate: scrollToDate,
            filterHandleId: filterHandleId,
          ),
      globalTimeline: (scrollToDate) =>
          GlobalTimelineResolver().resolve(scrollToDate: scrollToDate),
      forHandle: (handleId) =>
          MessagesForHandleResolver().resolve(handleId: handleId),
      recoveredUnlinkedMessages: (contactId) =>
          RecoveredUnlinkedMessagesResolver().resolve(contactId: contactId),
      recoveredNoHandleFromMeMessages: () =>
          RecoveredUnlinkedMessagesResolver().resolve(onlyNoHandleFromMe: true),
      handleLens: (handleId) =>
          HandleLensResolver().resolve(handleId: handleId),
      forChatInDateRange: (chatId, startDate, endDate) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Messages for chat in date range view is coming soon.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
