import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../../core/util/message_tag_normalizer.dart';
import '../../../../app_database_schema_versions.dart';

part 'overlay_database.g.dart';

/// Overlay database for user preferences and customizations.
/// This database stores user-specific overrides that enhance graph/source data
/// without polluting derived databases with UI-specific state.
@DriftDatabase(
  tables: [
    ParticipantOverrides,
    ChatOverrides,
    MessageAnnotations,
    MessageUserFlags,
    MessageUserTags,
    HandleToParticipantOverrides,
    VirtualParticipants,
    OverlaySettings,
    FavoriteContacts,
    DismissedHandles,
    HandleVisibilityOverrides,
    ArchivedAttachments,
    ConversationTags,
    ConversationTagAssignments,
  ],
)
class OverlayDatabase extends _$OverlayDatabase {
  OverlayDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => overlaySchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createOverlayIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(archivedAttachments);
      }
      if (from < 3) {
        await m.createTable(messageUserFlags);
        await m.createTable(messageUserTags);
      }
      if (from < 4) {
        await _dropColumnIfPresent(m, participantOverrides, 'nickname');
      }
      if (from < 5) {
        await _createGraphMessageIntentTables();
      }
      if (from < 6) {
        await _dropColumnIfPresent(m, participantOverrides, 'name_mode');
        await _dropColumnIfPresent(m, virtualParticipants, 'short_name');
      }
      if (from < 7) {
        await m.createTable(conversationTags);
        await m.createTable(conversationTagAssignments);
      }
      if (from >= 7 && from < 8) {
        await m.addColumn(conversationTags, conversationTags.visibilityPolicy);
      }
      await _createOverlayIndexes();
    },
  );

  Future<void> _dropColumnIfPresent<T extends Table, D>(
    Migrator migrator,
    TableInfo<T, D> table,
    String columnName,
  ) async {
    final escapedTableName = table.actualTableName.replaceAll('"', '""');
    final columns = await customSelect(
      'PRAGMA table_info("$escapedTableName")',
    ).get();
    final isPresent = columns.any(
      (column) => column.read<String>('name') == columnName,
    );

    if (isPresent) {
      await migrator.dropColumn(table, columnName);
    }
  }

  Future<void> _createOverlayIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_user_tags_message_guid ON message_user_tags(message_guid)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_user_tags_tag_normalized ON message_user_tags(tag_normalized)',
    );
    await _createGraphMessageIntentTables();
    await _createConversationTagIndexes();
  }

  Future<void> _createGraphMessageIntentTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS message_intent_overlays (
        message_ss_id INTEGER PRIMARY KEY,
        is_saved INTEGER NOT NULL DEFAULT 0 CHECK (is_saved IN (0, 1)),
        is_starred INTEGER NOT NULL DEFAULT 0 CHECK (is_starred IN (0, 1)),
        is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1)),
        user_notes TEXT,
        priority INTEGER CHECK (priority IS NULL OR (priority BETWEEN 1 AND 5)),
        remind_at TEXT,
        created_at_utc TEXT NOT NULL,
        updated_at_utc TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS message_intent_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message_ss_id INTEGER NOT NULL,
        tag_display TEXT NOT NULL,
        tag_normalized TEXT NOT NULL,
        created_at_utc TEXT NOT NULL,
        updated_at_utc TEXT NOT NULL,
        UNIQUE(message_ss_id, tag_normalized)
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_intent_tags_message '
      'ON message_intent_tags(message_ss_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_message_intent_tags_normalized '
      'ON message_intent_tags(tag_normalized)',
    );
  }

  Future<void> _createConversationTagIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_conversation_tags_normalized '
      'ON conversation_tags(normalized_name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversation_tag_assignments_conversation '
      'ON conversation_tag_assignments(conversation_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_conversation_tag_assignments_tag '
      'ON conversation_tag_assignments(tag_id)',
    );
  }

  // Helper methods for participant overrides

  // ────────────────────────────────────────────────────────────────────────────
  // Participant naming overrides
  // ────────────────────────────────────────────────────────────────────────────

  /// Fetch a participant override row (or null if none exists).
  Future<ParticipantOverride?> getParticipantOverride(int participantId) {
    return (select(
      participantOverrides,
    )..where((t) => t.participantId.equals(participantId))).getSingleOrNull();
  }

  Future<List<ParticipantOverride>> getAllParticipantOverrides() {
    return select(participantOverrides).get();
  }

  /// Upsert helper for setting display name override.
  ///
  /// - Writes createdAtUtc only when creating a new row
  /// - Always updates updatedAtUtc
  Future<void> _upsertParticipantOverride({
    required int participantId,
    required Value<String?> displayNameOverride,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final existing = await (select(
      participantOverrides,
    )..where((t) => t.participantId.equals(participantId))).getSingleOrNull();

    final createdAt = existing?.createdAtUtc ?? now;

    await into(participantOverrides).insertOnConflictUpdate(
      ParticipantOverridesCompanion(
        participantId: Value(participantId),
        displayNameOverride: displayNameOverride,
        createdAtUtc: Value(createdAt),
        updatedAtUtc: Value(now),
      ),
    );
  }

  /// Set custom display name override. Pass null to clear.
  Future<void> setParticipantDisplayNameOverride(
    int participantId,
    String? displayName,
  ) async {
    final trimmed = displayName?.trim();
    await _upsertParticipantOverride(
      participantId: participantId,
      displayNameOverride: Value(
        (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      ),
    );
  }

  /// Convenience: clear all naming overrides for a participant (deletes the row).
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
      return _decodeMessageAnnotationTags(annotation.tags).contains(tag);
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

    final currentTags = _decodeMessageAnnotationTags(existing?.tags);

    // Add new tags (avoid duplicates)
    for (final tag in tagsToAdd) {
      if (!currentTags.contains(tag)) {
        currentTags.add(tag);
      }
    }

    await into(messageAnnotations).insertOnConflictUpdate(
      MessageAnnotationsCompanion.insert(
        messageId: Value(messageId),
        tags: Value(_encodeMessageAnnotationTags(currentTags)),
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

    final currentTags = _decodeMessageAnnotationTags(existing.tags);
    if (currentTags.isEmpty) {
      return;
    }

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
      await (update(
        messageAnnotations,
      )..where((tbl) => tbl.messageId.equals(messageId))).write(
        MessageAnnotationsCompanion(
          tags: Value(_encodeMessageAnnotationTags(currentTags)),
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

  List<String> _decodeMessageAnnotationTags(String? tagsJson) {
    if (tagsJson == null || tagsJson.trim().isEmpty) {
      return <String>[];
    }

    try {
      final decoded = jsonDecode(tagsJson);
      if (decoded is! List) {
        return <String>[];
      }
      return decoded.whereType<String>().toList();
    } on FormatException {
      return <String>[];
    }
  }

  String _encodeMessageAnnotationTags(List<String> tags) {
    return jsonEncode(tags);
  }

  Future<MessageUserFlag?> getMessageUserFlag(String messageGuid) {
    return (select(messageUserFlags)..where((tbl) {
          return tbl.messageGuid.equals(messageGuid);
        }))
        .getSingleOrNull();
  }

  Future<List<MessageUserTag>> getMessageUserTags(String messageGuid) {
    return (select(messageUserTags)
          ..where((tbl) => tbl.messageGuid.equals(messageGuid))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.tagDisplay)]))
        .get();
  }

  Future<Map<String, bool>> getSavedFlagsByGuids(
    Iterable<String> messageGuids,
  ) async {
    final guidList = messageGuids.where((guid) => guid.isNotEmpty).toList();
    if (guidList.isEmpty) {
      return const <String, bool>{};
    }

    final rows =
        await (select(messageUserFlags)..where((tbl) {
              return tbl.messageGuid.isIn(guidList);
            }))
            .get();

    return {for (final row in rows) row.messageGuid: row.isSaved};
  }

  Future<List<String>> getAllSavedMessageGuids() async {
    final rows =
        await (select(messageUserFlags)..where((tbl) {
              return tbl.isSaved.equals(true);
            }))
            .get();

    return rows.map((row) => row.messageGuid).toList(growable: false);
  }

  Future<Map<String, List<MessageUserTag>>> getTagsByGuids(
    Iterable<String> messageGuids,
  ) async {
    final guidList = messageGuids.where((guid) => guid.isNotEmpty).toList();
    if (guidList.isEmpty) {
      return const <String, List<MessageUserTag>>{};
    }

    final rows =
        await (select(messageUserTags)
              ..where((tbl) => tbl.messageGuid.isIn(guidList))
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.messageGuid),
                (tbl) => OrderingTerm.asc(tbl.tagDisplay),
              ]))
            .get();

    final byGuid = <String, List<MessageUserTag>>{};
    for (final row in rows) {
      byGuid.putIfAbsent(row.messageGuid, () => <MessageUserTag>[]).add(row);
    }
    return byGuid;
  }

  Future<void> setMessageSaved({
    required String messageGuid,
    required bool isSaved,
  }) async {
    final normalizedGuid = messageGuid.trim();
    if (normalizedGuid.isEmpty) {
      return;
    }

    if (!isSaved) {
      await (delete(messageUserFlags)..where((tbl) {
            return tbl.messageGuid.equals(normalizedGuid);
          }))
          .go();
      return;
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final existing = await getMessageUserFlag(normalizedGuid);

    await into(messageUserFlags).insertOnConflictUpdate(
      MessageUserFlagsCompanion.insert(
        messageGuid: normalizedGuid,
        isSaved: const Value(true),
        createdAtUtc: existing?.createdAtUtc ?? now,
        updatedAtUtc: now,
      ),
    );
  }

  Future<bool> toggleMessageSaved(String messageGuid) async {
    final existing = await getMessageUserFlag(messageGuid);
    final nextValue = !(existing?.isSaved ?? false);
    await setMessageSaved(messageGuid: messageGuid, isSaved: nextValue);
    return nextValue;
  }

  Future<void> addMessageUserTags({
    required String messageGuid,
    required Iterable<String> tags,
  }) async {
    final normalizedGuid = messageGuid.trim();
    if (normalizedGuid.isEmpty) {
      return;
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final uniqueTags = <String, String>{};
    for (final rawTag in tags) {
      final display = normalizeMessageTagDisplay(rawTag);
      final normalized = normalizeMessageTagValue(rawTag);
      if (display.isEmpty || normalized.isEmpty) {
        continue;
      }
      uniqueTags.putIfAbsent(normalized, () => display);
    }

    if (uniqueTags.isEmpty) {
      return;
    }

    for (final entry in uniqueTags.entries) {
      final existing =
          await (select(messageUserTags)..where((tbl) {
                return tbl.messageGuid.equals(normalizedGuid) &
                    tbl.tagNormalized.equals(entry.key);
              }))
              .getSingleOrNull();

      await into(messageUserTags).insertOnConflictUpdate(
        MessageUserTagsCompanion.insert(
          messageGuid: normalizedGuid,
          tagDisplay: existing?.tagDisplay ?? entry.value,
          tagNormalized: entry.key,
          createdAtUtc: existing?.createdAtUtc ?? now,
          updatedAtUtc: now,
        ),
      );
    }
  }

  Future<void> removeMessageUserTag({
    required String messageGuid,
    required String normalizedTag,
  }) async {
    final normalizedGuid = messageGuid.trim();
    final normalizedValue = normalizeMessageTagValue(normalizedTag);
    if (normalizedGuid.isEmpty || normalizedValue.isEmpty) {
      return;
    }

    await (delete(messageUserTags)..where((tbl) {
          return tbl.messageGuid.equals(normalizedGuid) &
              tbl.tagNormalized.equals(normalizedValue);
        }))
        .go();
  }

  Future<void> removeMessageUserTags({
    required String messageGuid,
    required Iterable<String> tags,
  }) async {
    for (final tag in tags) {
      await removeMessageUserTag(messageGuid: messageGuid, normalizedTag: tag);
    }
  }

  Future<List<MessageUserTag>> getAllMessageUserTags() {
    return (select(
      messageUserTags,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.tagDisplay)])).get();
  }

  Future<List<String>> getMessageTagSuggestions({String query = ''}) async {
    final normalizedQuery = normalizeMessageTagValue(query);
    final allTags = await getAllMessageUserTags();
    final suggestions = allTags
        .where((tag) {
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return tag.tagNormalized.contains(normalizedQuery);
        })
        .map((tag) {
          return tag.tagDisplay;
        })
        .toSet()
        .toList(growable: false);
    suggestions.sort((left, right) {
      return left.toLowerCase().compareTo(right.toLowerCase());
    });
    return suggestions;
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

  // ────────────────────────────────────────────────────────────────────────────
  // Handle-to-participant overrides
  // ────────────────────────────────────────────────────────────────────────────

  /// Get override for a specific handle.
  Future<HandleToParticipantOverride?> getHandleOverride(int handleId) {
    return (select(
      handleToParticipantOverrides,
    )..where((tbl) => tbl.handleId.equals(handleId))).getSingleOrNull();
  }

  /// Get all handle overrides, ordered by creation time.
  Future<List<HandleToParticipantOverride>> getAllHandleOverrides() {
    return (select(
      handleToParticipantOverrides,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAtUtc)])).get();
  }

  /// Get the set of all handle IDs that have an overlay override row.
  Future<Set<int>> getAllOverriddenHandleIds() async {
    final rows = await select(handleToParticipantOverrides).get();
    return {for (final row in rows) row.handleId};
  }

  /// Link a handle to a graph contact/participant identity.
  Future<void> setHandleOverride(int handleId, int participantId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(handleToParticipantOverrides).insertOnConflictUpdate(
      HandleToParticipantOverridesCompanion(
        handleId: Value(handleId),
        participantId: Value(participantId),
        virtualParticipantId: const Value(null),
        reviewedAt: Value(now),
        createdAtUtc: Value(now),
        updatedAtUtc: Value(now),
      ),
    );
  }

  /// Link a handle to a virtual participant (overlay-DB).
  Future<void> setHandleVirtualParticipantOverride(
    int handleId,
    int virtualParticipantId,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(handleToParticipantOverrides).insertOnConflictUpdate(
      HandleToParticipantOverridesCompanion(
        handleId: Value(handleId),
        participantId: const Value(null),
        virtualParticipantId: Value(virtualParticipantId),
        reviewedAt: Value(now),
        createdAtUtc: Value(now),
        updatedAtUtc: Value(now),
      ),
    );
  }

  /// Mark a handle as reviewed without linking it ("dismiss").
  Future<void> setHandleReviewed(int handleId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final existing = await getHandleOverride(handleId);
    if (existing != null) {
      // Update reviewed_at on existing row, preserving any link.
      await (update(
        handleToParticipantOverrides,
      )..where((tbl) => tbl.handleId.equals(handleId))).write(
        HandleToParticipantOverridesCompanion(
          reviewedAt: Value(now),
          updatedAtUtc: Value(now),
        ),
      );
    } else {
      // Insert a "reviewed but unlinked" row.
      await into(handleToParticipantOverrides).insert(
        HandleToParticipantOverridesCompanion(
          handleId: Value(handleId),
          participantId: const Value(null),
          virtualParticipantId: const Value(null),
          reviewedAt: Value(now),
          createdAtUtc: Value(now),
          updatedAtUtc: Value(now),
        ),
      );
    }
  }

  /// Delete handle override (reverts to automatic linking or unlinked state).
  Future<void> deleteHandleOverride(int handleId) async {
    await (delete(
      handleToParticipantOverrides,
    )..where((tbl) => tbl.handleId.equals(handleId))).go();
  }

  /// Get all overrides pointing to a specific real participant.
  Future<List<HandleToParticipantOverride>> getOverridesForParticipant(
    int participantId,
  ) {
    return (select(
      handleToParticipantOverrides,
    )..where((tbl) => tbl.participantId.equals(participantId))).get();
  }

  /// Get all overrides pointing to a specific virtual participant.
  Future<List<HandleToParticipantOverride>> getOverridesForVirtualParticipant(
    int virtualParticipantId,
  ) {
    return (select(handleToParticipantOverrides)..where(
          (tbl) => tbl.virtualParticipantId.equals(virtualParticipantId),
        ))
        .get();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Handle visibility overrides
  // ────────────────────────────────────────────────────────────────────────────

  /// Get the visibility override for a single handle, or null if none exists.
  Future<HandleVisibilityOverride?> getHandleVisibility(int handleId) {
    return (select(
      handleVisibilityOverrides,
    )..where((tbl) => tbl.handleId.equals(handleId))).getSingleOrNull();
  }

  /// Get all handle visibility overrides.
  Future<List<HandleVisibilityOverride>> getAllHandleVisibilities() {
    return select(handleVisibilityOverrides).get();
  }

  /// Set (upsert) the visibility/blacklist state for a handle.
  Future<void> setHandleVisibility(
    int handleId, {
    required bool isVisible,
    required bool isBlacklisted,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await into(handleVisibilityOverrides).insertOnConflictUpdate(
      HandleVisibilityOverridesCompanion(
        handleId: Value(handleId),
        isVisible: Value(isVisible),
        isBlacklisted: Value(isBlacklisted),
        updatedAtUtc: Value(now),
      ),
    );
  }

  /// Remove the visibility override for a handle (reverts to graph defaults).
  Future<void> deleteHandleVisibility(int handleId) async {
    await (delete(
      handleVisibilityOverrides,
    )..where((tbl) => tbl.handleId.equals(handleId))).go();
  }

  // Helper methods for virtual participants

  static const _virtualParticipantCounterKey = 'virtual_participant_id_counter';
  static const _virtualParticipantIdFloor = 1000000000;

  Future<VirtualParticipant> createVirtualParticipant({
    required String displayName,
    String? notes,
  }) async {
    final trimmedName = displayName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('displayName cannot be empty');
    }

    return transaction(() async {
      final newId = await _nextVirtualParticipantId();
      final now = DateTime.now().toUtc().toIso8601String();

      await into(virtualParticipants).insert(
        VirtualParticipantsCompanion.insert(
          id: Value(newId),
          displayName: trimmedName,
          notes: Value(notes),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      return (select(
        virtualParticipants,
      )..where((tbl) => tbl.id.equals(newId))).getSingle();
    });
  }

  Future<List<VirtualParticipant>> getVirtualParticipants() {
    return (select(
      virtualParticipants,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.displayName)])).get();
  }

  /// Get a single virtual participant by ID.
  Future<VirtualParticipant?> getVirtualParticipant(int id) {
    return (select(
      virtualParticipants,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> deleteVirtualParticipant(int id) async {
    return (delete(
      virtualParticipants,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> _nextVirtualParticipantId() async {
    final existingSetting =
        await (select(overlaySettings)
              ..where((tbl) => tbl.key.equals(_virtualParticipantCounterKey)))
            .getSingleOrNull();

    final current = existingSetting == null
        ? _virtualParticipantIdFloor - 1
        : int.tryParse(existingSetting.value) ?? _virtualParticipantIdFloor - 1;
    final next = current + 1;

    if (existingSetting == null) {
      await into(overlaySettings).insert(
        OverlaySettingsCompanion.insert(
          key: _virtualParticipantCounterKey,
          value: next.toString(),
        ),
      );
    } else {
      await (update(overlaySettings)
            ..where((tbl) => tbl.key.equals(_virtualParticipantCounterKey)))
          .write(OverlaySettingsCompanion(value: Value(next.toString())));
    }

    return next;
  }

  Future<String?> readOverlaySetting(String settingKey) async {
    final existing = await (select(
      overlaySettings,
    )..where((tbl) => tbl.key.equals(settingKey))).getSingleOrNull();
    return existing?.value;
  }

  Future<void> writeOverlaySetting({
    required String settingKey,
    required String settingValue,
  }) async {
    final existing = await (select(
      overlaySettings,
    )..where((tbl) => tbl.key.equals(settingKey))).getSingleOrNull();

    if (existing == null) {
      await into(overlaySettings).insert(
        OverlaySettingsCompanion.insert(key: settingKey, value: settingValue),
      );
      return;
    }

    await (update(overlaySettings)..where((tbl) => tbl.key.equals(settingKey)))
        .write(OverlaySettingsCompanion(value: Value(settingValue)));
  }

  // Helper methods for favorite contacts

  /// Get all user-designated favorite contacts, ordered by when they were
  /// favorited (most recent first).
  Future<List<FavoriteContact>> getAllFavorites() async {
    return (select(favoriteContacts)
          ..where((tbl) => tbl.isFavorited.equals(true))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.createdAtUtc,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Get count of user-designated favorites (for limit enforcement)
  Future<int> getFavoriteCount() async {
    final countQuery = selectOnly(favoriteContacts)
      ..where(favoriteContacts.isFavorited.equals(true))
      ..addColumns([favoriteContacts.participantId.count()]);
    final result = await countQuery.getSingleOrNull();
    return result?.read(favoriteContacts.participantId.count()) ?? 0;
  }

  /// Check if a participant is explicitly favorited by the user.
  Future<bool> isFavorite(int participantId) async {
    final result =
        await (select(favoriteContacts)
              ..where((tbl) => tbl.participantId.equals(participantId)))
            .getSingleOrNull();
    return result?.isFavorited ?? false;
  }

  /// Mark a contact as a user-designated favorite.
  ///
  /// Uses upsert so this works whether or not a recents-only row already
  /// exists for the participant.
  Future<void> addFavorite(
    int participantId,
    DateTime? lastInteractionUtc,
  ) async {
    final now = DateTime.now().toUtc();

    await into(favoriteContacts).insertOnConflictUpdate(
      FavoriteContactsCompanion.insert(
        participantId: Value(participantId),
        createdAtUtc: now.toIso8601String(),
        isFavorited: const Value(true),
        lastInteractionUtc: lastInteractionUtc != null
            ? Value(lastInteractionUtc.toUtc().toIso8601String())
            : const Value.absent(),
        updatedAtUtc: Value(now.toIso8601String()),
      ),
    );
  }

  /// Remove the favorite designation from a contact.
  ///
  /// Clears the `isFavorited` flag rather than deleting the row, because
  /// the row may still be needed for recents tracking.
  Future<void> removeFavorite(int participantId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await (update(
      favoriteContacts,
    )..where((tbl) => tbl.participantId.equals(participantId))).write(
      FavoriteContactsCompanion(
        isFavorited: const Value(false),
        updatedAtUtc: Value(now),
      ),
    );
  }

  /// Update mutable attributes for a favorite contact.
  Future<void> updateFavorite({
    required int participantId,
    DateTime? lastInteractionUtc,
    int? sortOrder,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final companion = FavoriteContactsCompanion(
      updatedAtUtc: Value(now),
      lastInteractionUtc: lastInteractionUtc != null
          ? Value(lastInteractionUtc.toUtc().toIso8601String())
          : const Value.absent(),
      sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
    );

    await (update(favoriteContacts)
          ..where((tbl) => tbl.participantId.equals(participantId)))
        .write(companion);
  }

  /// Bulk reorder favorites by setting sort_order
  /// (Currently not used since we auto-sort by lastInteractionUtc)
  Future<void> reorderFavorites(List<int> participantIds) async {
    await transaction(() async {
      for (var i = 0; i < participantIds.length; i++) {
        await updateFavorite(participantId: participantIds[i], sortOrder: i);
      }
    });
  }

  /// Track that a contact was recently accessed.
  ///
  /// Creates or updates a row with the current timestamp for recency sorting.
  /// Does **not** touch `isFavorited` — that flag is user-controlled only.
  Future<void> trackContactAccess(int participantId) async {
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();

    final existing =
        await (select(favoriteContacts)
              ..where((tbl) => tbl.participantId.equals(participantId)))
            .getSingleOrNull();

    if (existing != null) {
      // Update last interaction time; preserve isFavorited.
      await (update(
        favoriteContacts,
      )..where((tbl) => tbl.participantId.equals(participantId))).write(
        FavoriteContactsCompanion(
          lastInteractionUtc: Value(nowIso),
          updatedAtUtc: Value(nowIso),
        ),
      );
    } else {
      // Insert a recents-only row (isFavorited defaults to false).
      await into(favoriteContacts).insert(
        FavoriteContactsCompanion.insert(
          participantId: Value(participantId),
          createdAtUtc: nowIso,
          lastInteractionUtc: Value(nowIso),
          updatedAtUtc: Value(nowIso),
        ),
      );
    }
  }

  /// Clear only the recency marker for a contact row.
  ///
  /// This preserves favourite intent because favourites and recents share this
  /// table during the overlay transition.
  Future<void> clearContactAccess(int participantId) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    await (update(
      favoriteContacts,
    )..where((tbl) => tbl.participantId.equals(participantId))).write(
      FavoriteContactsCompanion(
        lastInteractionUtc: const Value(null),
        updatedAtUtc: Value(nowIso),
      ),
    );
  }

  /// Get recently accessed contacts (top N by lastInteractionUtc).
  /// This returns all contacts that have been accessed, sorted by recency.
  Future<List<FavoriteContact>> getRecentContacts({int limit = 10}) async {
    return (select(favoriteContacts)
          ..where((tbl) => tbl.lastInteractionUtc.isNotNull())
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.lastInteractionUtc,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Dismissed handles
  // ────────────────────────────────────────────────────────────────────────────

  /// Dismiss a handle by its normalized identifier.
  ///
  /// Dismissal excludes all messages from this handle from search, All Messages,
  /// analytics, and aggregate surfaces. The handle will only appear in the
  /// "Dismissed" escape hatch view.
  Future<void> dismissHandle(String normalizedHandle) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(dismissedHandles).insertOnConflictUpdate(
      DismissedHandlesCompanion(
        normalizedHandle: Value(normalizedHandle),
        dismissedAtUtc: Value(now),
      ),
    );
  }

  /// Restore a dismissed handle, re-including its messages in circulation.
  ///
  /// Labeling a handle implicitly calls this method.
  Future<void> restoreHandle(String normalizedHandle) async {
    await (delete(
      dismissedHandles,
    )..where((tbl) => tbl.normalizedHandle.equals(normalizedHandle))).go();
  }

  /// Check if a handle is currently dismissed.
  Future<bool> isHandleDismissed(String normalizedHandle) async {
    final result =
        await (select(dismissedHandles)
              ..where((tbl) => tbl.normalizedHandle.equals(normalizedHandle)))
            .getSingleOrNull();
    return result != null;
  }

  /// Get all dismissed handle identifiers.
  ///
  /// Returns normalized values, not handle IDs (which are transient).
  Future<Set<String>> getAllDismissedHandles() async {
    final rows = await select(dismissedHandles).get();
    return {for (final row in rows) row.normalizedHandle};
  }

  /// Get detailed info about all dismissed handles.
  Future<List<DismissedHandle>> getDismissedHandleDetails() async {
    return (select(
      dismissedHandles,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.dismissedAtUtc)])).get();
  }
}

/// User-defined naming overrides for participants.
///
/// Naming is intentionally kept separate from graph/import projection.
/// If a column is null, the UI resolver should fall back to global settings
/// and/or graph contact fields.
class ParticipantOverrides extends Table {
  @override
  String get tableName => 'participant_overrides';

  /// Matches the graph-era contact/participant identity.
  IntColumn get participantId => integer().named('participant_id')();

  /// User's custom display name override, e.g. "Dad (Mobile)"
  TextColumn get displayNameOverride =>
      text().named('display_name_override').nullable()();

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

class MessageUserFlags extends Table {
  @override
  String get tableName => 'message_user_flags';

  TextColumn get messageGuid => text().named('message_guid')();

  BoolColumn get isSaved =>
      boolean().named('is_saved').withDefault(const Constant(false))();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {messageGuid};
}

class MessageUserTags extends Table {
  @override
  String get tableName => 'message_user_tags';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get messageGuid => text().named('message_guid')();

  TextColumn get tagDisplay => text().named('tag_display')();

  TextColumn get tagNormalized => text().named('tag_normalized')();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageGuid, tagNormalized},
  ];
}

/// User-authored semantic labels attached to canonical Conversation identity.
///
/// Conversation tags are overlay intent. They are not graph projection data and
/// must be merged with graph facts at read time.
class ConversationTags extends Table {
  @override
  String get tableName => 'conversation_tags';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get displayName => text().named('display_name')();

  TextColumn get normalizedName => text().named('normalized_name')();

  TextColumn get visibilityPolicy => text()
      .named('visibility_policy')
      .withDefault(const Constant('ordinary'))();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  List<Set<Column>> get uniqueKeys => [
    {normalizedName},
  ];
}

/// Assignment of a user-authored tag to one canonical Conversation.
class ConversationTagAssignments extends Table {
  @override
  String get tableName => 'conversation_tag_assignments';

  IntColumn get conversationId => integer().named('conversation_id')();

  IntColumn get tagId => integer().named('tag_id')();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {conversationId, tagId};
}

/// User-defined manual links from handles to participants or virtual participants.
///
/// Each row links a graph handle to either a graph contact/participant identity
/// or a virtual participant from overlay DB. A row with both IDs null means the
/// handle has been reviewed but intentionally left unlinked ("dismissed").
class HandleToParticipantOverrides extends Table {
  @override
  String get tableName => 'handle_to_participant_overrides';

  /// Matches graph canonical handle identity.
  IntColumn get handleId => integer().named('handle_id')();

  /// Matches graph contact/participant identity (null when linking to a virtual
  /// participant or when the handle is dismissed).
  IntColumn get participantId => integer().named('participant_id').nullable()();

  /// Matches overlay virtual_participants.id (null when linking to a real
  /// participant or when the handle is dismissed).
  IntColumn get virtualParticipantId =>
      integer().named('virtual_participant_id').nullable()();

  /// ISO 8601 timestamp of when the user last reviewed this handle in the
  /// Handle Lens. Auto-set on review; semantics may be refined later.
  TextColumn get reviewedAt => text().named('reviewed_at').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {handleId};
}

/// Overlay-scoped virtual contacts created by the user
class VirtualParticipants extends Table {
  @override
  String get tableName => 'virtual_participants';

  IntColumn get id => integer().named('id')();

  TextColumn get displayName => text().named('display_name')();

  TextColumn get notes => text().named('notes').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();

  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => const ['CHECK (id >= 1000000000)'];
}

/// Key-value storage for overlay-scoped counters and preferences
class OverlaySettings extends Table {
  @override
  String get tableName => 'overlay_settings';

  TextColumn get key => text().named('key')();

  TextColumn get value => text().named('value')();

  @override
  Set<Column> get primaryKey => {key};
}

/// User's favorited contacts.
class FavoriteContacts extends Table {
  @override
  String get tableName => 'favorite_contacts';

  /// Matches graph-era contact/participant identity.
  IntColumn get participantId => integer().named('participant_id')();

  /// Order position (lower = higher priority, auto-managed)
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();

  /// ISO8601 timestamp when contact was favorited/created.
  TextColumn get createdAtUtc => text().named('created_at_utc')();

  /// ISO8601 timestamp of last user interaction (for auto-sorting)
  TextColumn get lastInteractionUtc =>
      text().named('last_interaction_utc').nullable()();

  /// Whether this contact has been explicitly favorited by the user.
  /// Rows exist for both favorites (true) and mere recents (false).
  BoolColumn get isFavorited =>
      boolean().named('is_favorited').withDefault(const Constant(false))();

  /// ISO8601 timestamp of the last mutation for bookkeeping
  TextColumn get updatedAtUtc => text()
      .named('updated_at_utc')
      .withDefault(const Constant('1970-01-01T00:00:00Z'))();

  @override
  Set<Column> get primaryKey => {participantId};
}

/// Dismissed handles — keyed by normalized handle value for persistence across
/// re-imports.
///
/// When a user dismisses a handle, all messages from that handle are excluded
/// from search, All Messages, analytics, and aggregate surfaces. Dismissal is
/// reversible via restore or by labeling the handle.
/// User overrides for handle visibility and blacklist state.
///
/// When present, these values take precedence over graph defaults at the
/// provider merge layer. Handles without a row here use the graph default
/// values (visible=true, blacklisted=false).
class HandleVisibilityOverrides extends Table {
  @override
  String get tableName => 'handle_visibility_overrides';

  /// The graph canonical handle identity.
  IntColumn get handleId => integer().named('handle_id')();

  /// Whether the handle is visible in the UI.
  BoolColumn get isVisible =>
      boolean().named('is_visible').withDefault(const Constant(true))();

  /// Whether the handle has been blacklisted by the user.
  BoolColumn get isBlacklisted =>
      boolean().named('is_blacklisted').withDefault(const Constant(false))();

  /// ISO 8601 timestamp of last update.
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {handleId};
}

class DismissedHandles extends Table {
  @override
  String get tableName => 'dismissed_handles';

  /// Normalized handle identifier (phone: digits only with optional leading +;
  /// email: lowercase). This is the PRIMARY KEY, not the transient handle ID.
  TextColumn get normalizedHandle => text().named('normalized_handle')();

  /// ISO 8601 timestamp of when this handle was dismissed.
  TextColumn get dismissedAtUtc => text().named('dismissed_at_utc')();

  @override
  Set<Column> get primaryKey => {normalizedHandle};
}

/// Tracks attachment files that MessageLens has archived locally.
///
/// When macOS evicts files from ~/Library/Messages/Attachments, the archive
/// retains the copy. Resolution providers merge graph attachment records with
/// this overlay table at read time to locate the file.
class ArchivedAttachments extends Table {
  @override
  String get tableName => 'archived_attachments';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().named('id').autoIncrement()();

  /// The GUID of the parent message. Together with [importAttachmentId],
  /// forms the stable archive compatibility key.
  TextColumn get messageGuid => text().named('message_guid')();

  /// The attachment's ROWID from chat.db, carried through import.
  /// Together with [messageGuid], forms the stable composite key.
  IntColumn get importAttachmentId => integer().named('import_attachment_id')();

  /// Path within the attachment_archive/ directory (relative, not absolute).
  TextColumn get archiveRelativePath => text().named('archive_relative_path')();

  /// ISO 8601 timestamp of when the file was archived.
  TextColumn get archivedAtUtc => text().named('archived_at_utc')();

  /// Size of the archived file in bytes.
  IntColumn get fileSizeBytes => integer().named('file_size_bytes')();

  /// SHA-256 hex digest of the file contents. Also used as the archive
  /// filename for content-addressable storage.
  TextColumn get contentHash => text().named('content_hash').nullable()();

  /// How the file entered the archive: 'archived' (import-time copy) or
  /// 'imported_historical' (user-supplied backup like Time Machine).
  TextColumn get provenance =>
      text().named('provenance').withDefault(const Constant('archived'))();

  /// The Messages local_path at the time of archiving, for audit purposes.
  TextColumn get originalLocalPath =>
      text().named('original_local_path').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageGuid, importAttachmentId},
  ];
}
