import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../application/strategies/chat_ordinal_strategy.dart';
import '../application/strategies/contact_ordinal_strategy.dart';
import '../application/strategies/filtered_contact_ordinal_strategy.dart';
import '../application/strategies/global_ordinal_strategy.dart';
import '../application/strategies/ordinal_strategy.dart';
import 'value_objects/message_timeline_scope.dart';

/// Extension to create the appropriate ordinal strategy for a scope.
extension MessageTimelineScopeOrdinal on MessageTimelineScope {
  /// Creates the ordinal strategy appropriate for this scope.
  ///
  /// The strategy provides access to ordinal-based queries for the
  /// scope's message set.
  OrdinalStrategy toOrdinalStrategy(WorkingDatabase db) {
    return switch (this) {
      GlobalTimelineScope() => GlobalOrdinalStrategy(db),
      ContactTimelineScope(:final contactId, :final filterHandleId) =>
        filterHandleId != null
            ? FilteredContactOrdinalStrategy(db, contactId, filterHandleId)
            : ContactOrdinalStrategy(db, contactId),
      ChatTimelineScope(:final chatId) => ChatOrdinalStrategy(db, chatId),
    };
  }
}
