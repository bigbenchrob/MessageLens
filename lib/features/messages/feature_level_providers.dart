import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../essentials/sidebar/domain/entities/features/messages_cassette_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import 'application/cassette_builders/global_timeline_view_builder_provider.dart';
import 'application/cassette_builders/messages_for_chat_view_builder_provider.dart';
import 'application/cassette_builders/messages_for_handle_view_builder_provider.dart';
import 'infrastructure/repositories/sqlite_messages_repository.dart';
import 'presentation/cassettes/messages_heatmap_cassette.dart';
import 'presentation/view/messages_for_chat_view.dart';
import 'presentation/view/messages_for_contact_view.dart';

part 'feature_level_providers.g.dart';

@riverpod
class MessageRepository extends _$MessageRepository {
  /// Build and return the concrete MessagesRepository.
  /// Wire real dependencies with ref.watch(...) as you implement infra.
  @override
  SqliteMessagesRepository build() {
    // final db = ref.watch(workingDbProvider);
    // return SqliteMessagesRepository(db: db);
    return SqliteMessagesRepository();
  }
}

/// Coordinator that maps [MessagesCassetteSpec] to rendered cassette widgets for the sidebar.

@riverpod
class MessagesCassetteCoordinator extends _$MessagesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  CassetteCardView buildForSpec(MessagesCassetteSpec spec) {
    return spec.when(
      heatMap: (contactId) {
        final isContactScoped = contactId != null;
        return CassetteCardView(
          title: isContactScoped
              ? 'Click on a square to see messages for that month'
              : 'All messages heatmap',
          subtitle: isContactScoped
              ? null
              : 'Discover peaks and gaps across your entire archive.',
          child: MessagesHeatmapCassette(contactId: contactId),
        );
      },
    );
  }
}

/// Coordinator that maps [MessagesSpec] to rendered widgets for the center panel.
@riverpod
class MessagesCoordinator extends _$MessagesCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forChat: (chatId) => ref.read(messagesForChatViewBuilderProvider(chatId)),
      forContact: (contactId, scrollToDate) => MessagesForContactView(
        contactId: contactId,
        scrollToDate: scrollToDate,
      ),
      recent: (limit) =>
          _buildComingSoon('Recent $limit messages view is coming soon.'),
      globalTimeline: () => ref.read(globalTimelineViewBuilderProvider),
      forHandle: (handleId) =>
          ref.read(messagesForHandleViewBuilderProvider(handleId)),
      forChatInDateRange: (chatId, startDate, endDate) {
        // Directly construct widget to allow scrollToDate changes without full rebuild
        return MessagesForChatView(chatId: chatId, scrollToDate: startDate);
      },
    );
  }

  Widget _buildComingSoon(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
