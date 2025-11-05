import 'package:drift/drift.dart';

part 'overlay_database.g.dart';

/// Overlay database for user preferences and customizations (user_overlays.db).
/// This database stores user-specific overrides that enhance the working database
/// without polluting it with UI-specific state.
@DriftDatabase(
  tables: [
    ParticipantOverrides,
    ChatOverrides,
    MessageAnnotations,
    HandleToParticipantOverrides,
  ],
)
class OverlayDatabase extends _$OverlayDatabase {
  OverlayDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  // Helper methods for participant overrides

  /// Get all short names as a map (contact key -> short name)
  Future<Map<String, String>> getAllShortNamesByKey() async {
    final overrides = await select(participantOverrides).get();
    return {
      for (final override in overrides)
        if (override.shortName != null)
          'participant:${override.participantId}': override.shortName!,
    };
  }

  /// Set short name for a participant
  Future<void> setParticipantShortName(
    int participantId,
    String? shortName,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(participantOverrides).insertOnConflictUpdate(
      ParticipantOverridesCompanion.insert(
        participantId: Value(participantId),
        shortName: Value(shortName),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Delete participant override
  Future<void> deleteParticipantOverride(int participantId) async {
    await (delete(
      participantOverrides,
    )..where((tbl) => tbl.participantId.equals(participantId))).go();
  }

  // Helper methods for chat overrides

  /// Get override for a specific chat
  Future<ChatOverride?> getChatOverride(int chatId) {
    return (select(
      chatOverrides,
    )..where((tbl) => tbl.chatId.equals(chatId))).getSingleOrNull();
  }

  /// Set custom name for a chat
  Future<void> setChatCustomName(int chatId, String? customName) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(chatOverrides).insertOnConflictUpdate(
      ChatOverridesCompanion.insert(
        chatId: Value(chatId),
        customName: Value(customName),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Delete chat override
  Future<void> deleteChatOverride(int chatId) async {
    await (delete(
      chatOverrides,
    )..where((tbl) => tbl.chatId.equals(chatId))).go();
  }

  // Helper methods for message annotations

  /// Get annotation for a specific message
  Future<MessageAnnotation?> getMessageAnnotation(int messageId) {
    return (select(
      messageAnnotations,
    )..where((tbl) => tbl.messageId.equals(messageId))).getSingleOrNull();
  }

  /// Get all starred messages
  Future<List<MessageAnnotation>> getStarredMessages() {
    return (select(
      messageAnnotations,
    )..where((tbl) => tbl.isStarred.equals(true))).get();
  }

  /// Get all messages with a specific tag
  Future<List<MessageAnnotation>> getMessagesByTag(String tag) async {
    final allAnnotations = await select(messageAnnotations).get();
    return allAnnotations.where((annotation) {
      if (annotation.tags == null) {
        return false;
      }
      // Tags stored as JSON array string: '["tag1","tag2"]'
      return annotation.tags!.contains('"$tag"');
    }).toList();
  }

  /// Toggle starred status for a message
  Future<void> toggleMessageStar(int messageId) async {
    final existing = await getMessageAnnotation(messageId);
    final now = DateTime.now().toUtc().toIso8601String();

    if (existing == null) {
      // Create new annotation with starred = true
      await into(messageAnnotations).insert(
        MessageAnnotationsCompanion.insert(
          messageId: Value(messageId),
          isStarred: const Value(true),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
    } else {
      // Toggle existing starred status
      await (update(
        messageAnnotations,
      )..where((tbl) => tbl.messageId.equals(messageId))).write(
        MessageAnnotationsCompanion(
          isStarred: Value(!existing.isStarred),
          updatedAtUtc: Value(now),
        ),
      );
    }
  }

  /// Set archived status for a message
  Future<void> setMessageArchived({
    required int messageId,
    required bool archived,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(messageAnnotations).insertOnConflictUpdate(
      MessageAnnotationsCompanion.insert(
        messageId: Value(messageId),
        isArchived: Value(archived),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Add tag(s) to a message (tags stored as JSON array)
  Future<void> addMessageTags(int messageId, List<String> tagsToAdd) async {
    final existing = await getMessageAnnotation(messageId);
    final now = DateTime.now().toUtc().toIso8601String();

    // Parse existing tags
    var currentTags = <String>[];
    if (existing?.tags != null) {
      // Parse JSON array: '["tag1","tag2"]'
      final tagsStr = existing!.tags!
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '');
      if (tagsStr.isNotEmpty) {
        currentTags = tagsStr.split(',').map((t) => t.trim()).toList();
      }
    }

    // Add new tags (avoid duplicates)
    for (final tag in tagsToAdd) {
      if (!currentTags.contains(tag)) {
        currentTags.add(tag);
      }
    }

    // Serialize back to JSON array string
    final tagsJson = '[${currentTags.map((t) => '"$t"').join(',')}]';

    await into(messageAnnotations).insertOnConflictUpdate(
      MessageAnnotationsCompanion.insert(
        messageId: Value(messageId),
        tags: Value(tagsJson),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Remove tag(s) from a message
  Future<void> removeMessageTags(
    int messageId,
    List<String> tagsToRemove,
  ) async {
    final existing = await getMessageAnnotation(messageId);
    if (existing == null || existing.tags == null) {
      return;
    }

    // Parse existing tags
    final tagsStr = existing.tags!
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '');
    if (tagsStr.isEmpty) {
      return;
    }

    final currentTags = tagsStr.split(',').map((tag) => tag.trim()).toList();

    // Remove specified tags
    currentTags.removeWhere((tag) => tagsToRemove.contains(tag));

    final now = DateTime.now().toUtc().toIso8601String();

    if (currentTags.isEmpty) {
      // If no tags remain, set to null
      await (update(
        messageAnnotations,
      )..where((tbl) => tbl.messageId.equals(messageId))).write(
        MessageAnnotationsCompanion(
          tags: const Value(null),
          updatedAtUtc: Value(now),
        ),
      );
    } else {
      // Update with remaining tags
      final tagsJson = '[${currentTags.map((t) => '"$t"').join(',')}]';
      await (update(
        messageAnnotations,
      )..where((tbl) => tbl.messageId.equals(messageId))).write(
        MessageAnnotationsCompanion(
          tags: Value(tagsJson),
          updatedAtUtc: Value(now),
        ),
      );
    }
  }

  /// Set user notes for a message
  Future<void> setMessageNotes(int messageId, String? notes) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(messageAnnotations).insertOnConflictUpdate(
      MessageAnnotationsCompanion.insert(
        messageId: Value(messageId),
        userNotes: Value(notes),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Set priority for a message (1-5, where 5 is highest)
  Future<void> setMessagePriority(int messageId, int? priority) async {
    if (priority != null && (priority < 1 || priority > 5)) {
      throw ArgumentError('Priority must be between 1 and 5');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    await into(messageAnnotations).insertOnConflictUpdate(
      MessageAnnotationsCompanion.insert(
        messageId: Value(messageId),
        priority: Value(priority),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Set reminder for a message
  Future<void> setMessageReminder(int messageId, DateTime? remindAt) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(messageAnnotations).insertOnConflictUpdate(
      MessageAnnotationsCompanion.insert(
        messageId: Value(messageId),
        remindAt: Value(remindAt?.toUtc().toIso8601String()),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Delete message annotation
  Future<void> deleteMessageAnnotation(int messageId) async {
    await (delete(
      messageAnnotations,
    )..where((tbl) => tbl.messageId.equals(messageId))).go();
  }

  /// Get messages with reminders due before a given time
  Future<List<MessageAnnotation>> getMessagesDueForReminder(DateTime before) {
    return (select(messageAnnotations)
          ..where((tbl) => tbl.remindAt.isNotNull())
          ..where(
            (tbl) => tbl.remindAt.isSmallerThanValue(
              before.toUtc().toIso8601String(),
            ),
          ))
        .get();
  }

  /// Get high priority messages (priority >= 4)
  Future<List<MessageAnnotation>> getHighPriorityMessages() {
    return (select(
      messageAnnotations,
    )..where((tbl) => tbl.priority.isBiggerOrEqualValue(4))).get();
  }

  // Helper methods for handle-to-participant overrides

  /// Get override for a specific handle
  Future<HandleToParticipantOverride?> getHandleOverride(int handleId) {
    return (select(
      handleToParticipantOverrides,
    )..where((tbl) => tbl.handleId.equals(handleId))).getSingleOrNull();
  }

  /// Get all handle overrides
  Future<List<HandleToParticipantOverride>> getAllHandleOverrides() {
    return (select(
      handleToParticipantOverrides,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAtUtc)])).get();
  }

  /// Set manual link from handle to participant
  Future<void> setHandleOverride(int handleId, int participantId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(handleToParticipantOverrides).insertOnConflictUpdate(
      HandleToParticipantOverridesCompanion.insert(
        handleId: Value(handleId),
        participantId: participantId,
        source: const Value('user_manual'),
        confidence: const Value(1.0),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Delete handle override
  Future<void> deleteHandleOverride(int handleId) async {
    await (delete(
      handleToParticipantOverrides,
    )..where((tbl) => tbl.handleId.equals(handleId))).go();
  }

  /// Get all overrides for a specific participant
  Future<List<HandleToParticipantOverride>> getOverridesForParticipant(
    int participantId,
  ) {
    return (select(
      handleToParticipantOverrides,
    )..where((tbl) => tbl.participantId.equals(participantId))).get();
  }
}

/// User-defined short names and preferences for participants
class ParticipantOverrides extends Table {
  @override
  String get tableName => 'participant_overrides';

  /// Matches working.participants.id
  IntColumn get participantId => integer().named('participant_id')();

  /// User's custom short name for this participant
  TextColumn get shortName => text().named('short_name').nullable()();

  /// Whether user has muted this participant
  BoolColumn get isMuted =>
      boolean().named('is_muted').withDefault(const Constant(false))();

  /// User's custom notes about this participant
  TextColumn get notes => text().named('notes').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {participantId};
}

/// User preferences for specific chats
class ChatOverrides extends Table {
  @override
  String get tableName => 'chat_overrides';

  /// Matches working.chats.id
  IntColumn get chatId => integer().named('chat_id')();

  /// User's custom name for this chat (overrides derived title)
  TextColumn get customName => text().named('custom_name').nullable()();

  /// User's custom color/theme for this chat
  TextColumn get customColor => text().named('custom_color').nullable()();

  /// User's notes about this chat
  TextColumn get notes => text().named('notes').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {chatId};
}

/// User annotations and metadata for individual messages
class MessageAnnotations extends Table {
  @override
  String get tableName => 'message_annotations';

  /// Matches working.messages.id
  IntColumn get messageId => integer().named('message_id')();

  /// User-defined tags as JSON array: '["receipt","important","todo"]'
  TextColumn get tags => text().named('tags').nullable()();

  /// Whether user has starred this message
  BoolColumn get isStarred =>
      boolean().named('is_starred').withDefault(const Constant(false))();

  /// Whether user has archived this message
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();

  /// User's personal notes about this message
  TextColumn get userNotes => text().named('user_notes').nullable()();

  /// Priority level (1-5, where 5 is highest)
  IntColumn get priority => integer().named('priority').nullable()();

  /// ISO8601 timestamp for reminder
  TextColumn get remindAt => text().named('remind_at').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {messageId};
}

/// User-defined manual links from handles to participants
/// Overrides automatic AddressBook matching when user explicitly assigns a handle to a contact
class HandleToParticipantOverrides extends Table {
  @override
  String get tableName => 'handle_to_participant_overrides';

  /// Matches working.handles.id
  IntColumn get handleId => integer().named('handle_id')();

  /// Matches working.participants.id
  IntColumn get participantId => integer().named('participant_id')();

  /// Source of the link (always 'user_manual' for manual overrides)
  TextColumn get source =>
      text().named('source').withDefault(const Constant('user_manual'))();

  /// Confidence level (1.0 for user-confirmed manual links)
  RealColumn get confidence =>
      real().named('confidence').withDefault(const Constant(1.0))();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {handleId};
}
