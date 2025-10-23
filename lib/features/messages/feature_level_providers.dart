import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/navigation/domain/entities/features/messages_spec.dart';
import 'application/use_cases/messages_for_chat_view_builder_provider.dart';
import 'application/use_cases/messages_for_handle_view_builder_provider.dart';
import 'infrastructure/repositories/sqlite_messages_repository.dart';

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
      forContact: (contactId) =>
          _buildComingSoon('Messages for contact $contactId are coming soon.'),
      recent: (limit) =>
          _buildComingSoon('Recent $limit messages view is coming soon.'),
      forHandle: (handleId) =>
          ref.read(messagesForHandleViewBuilderProvider(handleId)),
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
