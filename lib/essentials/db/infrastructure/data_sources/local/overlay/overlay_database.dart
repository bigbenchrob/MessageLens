import 'package:characters/characters.dart';
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
    VirtualParticipants,
    OverlaySettings,
    FavoriteContacts,
    DismissedHandles,
  ],
)
class OverlayDatabase extends _$OverlayDatabase {
  OverlayDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 5) {
        // Add is_favorited column; existing rows become non-favorited recents.
        await m.addColumn(favoriteContacts, favoriteContacts.isFavorited);
      }
      if (from < 6) {
        // Recreate handle_to_participant_overrides with new schema:
        // - participant_id becomes nullable
        // - add virtual_participant_id (nullable)
        // - add reviewed_at (nullable)
        // - remove source and confidence (redundant for overlay)
        await customStatement('''
          CREATE TABLE handle_to_participant_overrides_new (
            handle_id INTEGER NOT NULL PRIMARY KEY,
            participant_id INTEGER,
            virtual_participant_id INTEGER,
            reviewed_at TEXT,
            created_at_utc TEXT NOT NULL,
            updated_at_utc TEXT NOT NULL
          )
        ''');
        await customStatement('''
          INSERT INTO handle_to_participant_overrides_new
            (handle_id, participant_id, created_at_utc, updated_at_utc)
          SELECT handle_id, participant_id, created_at_utc, updated_at_utc
          FROM handle_to_participant_overrides
        ''');
        await customStatement('DROP TABLE handle_to_participant_overrides');
        await customStatement('''
          ALTER TABLE handle_to_participant_overrides_new
          RENAME TO handle_to_participant_overrides
        ''');
      }
      if (from < 7) {
        // Add dismissed_handles table for strong dismissal semantics.
        await m.createTable(dismissedHandles);
      }
    },
  );

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

  /// Get all nicknames as a map (contact key -> nickname).
  /// Useful for fast in-memory merge (similar to your prior shortName flow).
  Future<Map<String, String>> getAllNicknamesByKey() async {
    final rows = await select(participantOverrides).get();
    return {
      for (final row in rows)
        if (row.nickname != null)
          'participant:${row.participantId}': row.nickname!,
    };
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

  /// Link a handle to a real (working-DB) participant.
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
      final shortName = _deriveShortName(trimmedName);

      await into(virtualParticipants).insert(
        VirtualParticipantsCompanion.insert(
          id: Value(newId),
          displayName: trimmedName,
          shortName: shortName,
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

  String _deriveShortName(String name) {
    final tokens = name
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    if (tokens.length >= 2) {
      final first = _firstCharacter(tokens[0]);
      final second = _firstCharacter(tokens[1]);
      return '${first ?? ''}${second ?? ''}'.toUpperCase().padRight(2, '?');
    }

    if (tokens.length == 1) {
      final chars = tokens.first.characters
          .take(2)
          .toList(growable: false)
          .join();
      if (chars.isNotEmpty) {
        return chars.toUpperCase();
      }
    }

    final fallback = name.characters.take(1).toList(growable: false).join();
    if (fallback.isNotEmpty) {
      return fallback.toUpperCase();
    }

    return '?';
  }

  String? _firstCharacter(String value) {
    final iterator = value.characters.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
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

  /// Get recently accessed contacts (top N by lastInteractionUtc).
  /// This returns all contacts that have been accessed, sorted by recency.
  Future<List<FavoriteContact>> getRecentContacts({int limit = 10}) async {
    return (select(favoriteContacts)
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

/// User-defined short names and preferences for participants
/// User-defined naming overrides for participants.
///
/// Naming is intentionally kept separate from the working.db projection.
/// If a column is null, the UI resolver should fall back to global settings
/// and/or working participant fields.
class ParticipantOverrides extends Table {
  @override
  String get tableName => 'participant_overrides';

  /// Matches working.participants.id
  IntColumn get participantId => integer().named('participant_id')();

  /// Nullable: when null, this participant inherits global default.
  ///
  /// Stored values map to ParticipantNameMode.dbValue (except we recommend
  /// storing null for inherit).
  IntColumn get nameMode => integer().named('name_mode').nullable()();

  /// User's nickname, e.g. "Westy"
  TextColumn get nickname => text().named('nickname').nullable()();

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

/// User-defined manual links from handles to participants or virtual participants.
///
/// Each row links a handle to either a real participant (from working DB) or a
/// virtual participant (from overlay DB). A row with both IDs null means the
/// handle has been reviewed but intentionally left unlinked ("dismissed").
class HandleToParticipantOverrides extends Table {
  @override
  String get tableName => 'handle_to_participant_overrides';

  /// Matches working.handles_canonical.id
  IntColumn get handleId => integer().named('handle_id')();

  /// Matches working.participants.id (null when linking to a virtual participant
  /// or when the handle is dismissed).
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

  TextColumn get shortName => text().named('short_name')();

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

/// User's pinned/favorite contacts
class FavoriteContacts extends Table {
  @override
  String get tableName => 'favorite_contacts';

  /// Matches working.participants.id
  IntColumn get participantId => integer().named('participant_id')();

  /// Order position (lower = higher priority, auto-managed)
  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();

  /// ISO8601 timestamp when contact was pinned/created
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
