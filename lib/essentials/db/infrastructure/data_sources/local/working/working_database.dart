import 'package:drift/drift.dart';

import '../../../../shared/handle_identifier_utils.dart';

part 'working_database.g.dart';

/// Drift projection database used by the application UI (working.db).
@DriftDatabase(
  tables: [
    WorkingSchemaMigrations,
    ProjectionState,
    AppSettings,
    // WorkingHandles, // Removed in v17
    HandlesCanonical, // New table - will replace WorkingHandles
    WorkingParticipants,
    HandleToParticipant,
    HandlesCanonicalToAlias, // New table - replaces legacy HandleCanonicalMap
    ChatToHandle,
    WorkingChats,
    WorkingMessages,
    GlobalMessageIndex, // Stable ordinal index across all messages
    MessageIndex, // Stable ordinal index for large chat virtualization
    ContactMessageIndex, // Ordinal index for all messages with a contact
    WorkingAttachments,
    WorkingReactions,
    ReactionCounts,
    ReadState,
    MessageReadMarks,
    SupabaseSyncState,
    SupabaseSyncLogs,
  ],
)
class WorkingDatabase extends _$WorkingDatabase {
  WorkingDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 17;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
      await _createVirtualTablesAndTriggers();
      await _seedProjectionState();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await _ensureMessageReadMarksTable(m);
      }
      if (from < 3) {
        await m.addColumn(
          projectionState,
          projectionState.lastProjectedMessageId as GeneratedColumn,
        );
        await m.addColumn(
          projectionState,
          projectionState.lastProjectedAttachmentId as GeneratedColumn,
        );
      }
      if (from < 6) {
        await _alignWithLedgerSchema(m);
      }
      if (from < 7) {
        await _addIgnoredFlags(m);
      }
      if (from < 8) {
        await _renameHandleVisibilityFlag();
      }
      if (from < 9) {
        await _addCompoundIdentifierColumn(m);
      }
      if (from < 10) {
        await _removeNormalizedIdentifierColumn(m);
      }
      if (from < 11) {
        await _addHandleDisplayNameColumn(m);
      }
      if (from < 13) {
        await _dropLegacyHandleCanonicalMapTable();
      }
      if (from < 14) {
        await _addMessageIndexTable(m);
      }
      if (from < 15) {
        await _addContactMessageIndexTable(m);
      }
      if (from < 16) {
        await _addGlobalMessageIndexTable(m);
      }
      if (from < 17) {
        // Create new canonical handles tables
        await m.createTable(handlesCanonical);
        await m.createTable(handlesCanonicalToAlias);

        // Migrate existing handles to canonical table
        // Note: We assume schema compatibility as previous migrations (v6-v11)
        // have aligned 'handles' with 'handles_canonical' structure.
        await customStatement('''
          INSERT INTO handles_canonical (
            id, raw_identifier, display_name, compound_identifier, service,
            is_ignored, is_visible, is_blacklisted, country, last_seen_utc, batch_id
          )
          SELECT 
            id, raw_identifier, display_name, compound_identifier, service,
            is_ignored, is_visible, is_blacklisted, country, last_seen_utc, batch_id
          FROM handles
        ''');

        await customStatement('DROP TABLE IF EXISTS handles');
      }
      // Note: contact_message_index population deferred to HandlesMigrationService
      // to avoid O(N²) trigger overhead during bulk message insert
      await _createIndexes();
      await _createVirtualTablesAndTriggers();
      await _seedProjectionState();
    },
  );

  Future<void> _createIndexes() async {
    for (final statement in _workingIndexStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _createVirtualTablesAndTriggers() async {
    for (final statement in _workingVirtualAndTriggerStatements) {
      await customStatement(statement);
    }
    // Note: Message index triggers are NOT created here to avoid O(N²) during migration
    // They will be created by createMessageIndexTriggers() AFTER messages are migrated
  }

  /// Creates message index maintenance triggers.
  /// Should be called AFTER rebuildGlobalMessageIndex(), rebuildMessageIndex(),
  /// and rebuildContactMessageIndex()
  /// to avoid O(N²) behavior during bulk message insertion.
  Future<void> createMessageIndexTriggers() async {
    for (final statement in _messageIndexTriggerStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _seedProjectionState() async {
    await customStatement('''
      INSERT OR IGNORE INTO projection_state (
        id, last_import_batch_id, last_projected_at_utc,
        last_projected_message_id, last_projected_attachment_id
      ) VALUES (1, NULL, NULL, NULL, NULL)
      ''');
  }

  Future<void> _ensureMessageReadMarksTable(Migrator migrator) async {
    final existing = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'message_read_marks'",
    ).getSingleOrNull();

    if (existing == null) {
      await migrator.createTable(messageReadMarks);
    }
  }

  Future<void> _alignWithLedgerSchema(Migrator migrator) async {
    // Handles metadata - Replaced with raw SQL since WorkingHandles is removed
    await customStatement(
      'ALTER TABLE handles ADD COLUMN is_ignored INTEGER DEFAULT 0',
    );
    await customStatement('ALTER TABLE handles ADD COLUMN country TEXT');
    await customStatement('ALTER TABLE handles ADD COLUMN last_seen_utc TEXT');
    await customStatement('ALTER TABLE handles ADD COLUMN batch_id INTEGER');

    // Participant metadata
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.givenName as GeneratedColumn,
    );
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.familyName as GeneratedColumn,
    );
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.organization as GeneratedColumn,
    );
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.isOrganization as GeneratedColumn,
    );
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.createdAtUtc as GeneratedColumn,
    );
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.updatedAtUtc as GeneratedColumn,
    );
    await migrator.addColumn(
      workingParticipants,
      workingParticipants.sourceRecordId as GeneratedColumn,
    );

    // Chat membership metadata
    await migrator.addColumn(
      chatToHandle,
      chatToHandle.role as GeneratedColumn,
    );
    await migrator.addColumn(
      chatToHandle,
      chatToHandle.addedAtUtc as GeneratedColumn,
    );

    // Message provenance
    await migrator.addColumn(
      workingMessages,
      workingMessages.itemType as GeneratedColumn,
    );
    await migrator.addColumn(
      workingMessages,
      workingMessages.isSystemMessage as GeneratedColumn,
    );
    await migrator.addColumn(
      workingMessages,
      workingMessages.errorCode as GeneratedColumn,
    );
    await migrator.addColumn(
      workingMessages,
      workingMessages.associatedMessageGuid as GeneratedColumn,
    );
    await migrator.addColumn(
      workingMessages,
      workingMessages.threadOriginatorGuid as GeneratedColumn,
    );
    await migrator.addColumn(
      workingMessages,
      workingMessages.payloadJson as GeneratedColumn,
    );
    await migrator.addColumn(
      workingMessages,
      workingMessages.batchId as GeneratedColumn,
    );

    // Attachment provenance
    await migrator.addColumn(
      workingAttachments,
      workingAttachments.isOutgoing as GeneratedColumn,
    );
    await migrator.addColumn(
      workingAttachments,
      workingAttachments.sha256Hex as GeneratedColumn,
    );
    await migrator.addColumn(
      workingAttachments,
      workingAttachments.batchId as GeneratedColumn,
    );

    // Reaction provenance
    await migrator.addColumn(
      workingReactions,
      workingReactions.carrierMessageId as GeneratedColumn,
    );
    await migrator.addColumn(
      workingReactions,
      workingReactions.targetMessageGuid as GeneratedColumn,
    );
    await migrator.addColumn(
      workingReactions,
      workingReactions.parseConfidence as GeneratedColumn,
    );

    // Backfill sensible defaults for migrated rows
    await customStatement(
      'UPDATE handles SET is_ignored = 0 WHERE is_ignored IS NULL',
    );
    await customStatement(
      "UPDATE chat_to_handle SET role = COALESCE(role, 'member')",
    );
    await customStatement(
      'UPDATE attachments SET is_outgoing = COALESCE(is_outgoing, 0)',
    );

    // Refresh dependent view with updated join structure
    await customStatement('DROP VIEW IF EXISTS v_message_expanded');
  }

  Future<void> _addIgnoredFlags(Migrator migrator) async {
    await migrator.addColumn(
      workingChats,
      workingChats.isIgnored as GeneratedColumn,
    );
    await migrator.addColumn(
      chatToHandle,
      chatToHandle.isIgnored as GeneratedColumn,
    );

    await customStatement('''
      UPDATE chat_to_handle
         SET is_ignored = 1
       WHERE handle_id IN (
         SELECT id FROM handles WHERE is_ignored = 1
       )
    ''');

    await customStatement('''
      UPDATE chats
         SET is_ignored = 1
       WHERE id IN (
         SELECT DISTINCT chat_id FROM chat_to_handle WHERE is_ignored = 1
       )
    ''');
  }

  Future<void> _renameHandleVisibilityFlag() async {
    final columns = await customSelect("PRAGMA table_info('handles')").get();
    var hasIsVisible = false;
    var hasIsValid = false;

    for (final row in columns) {
      final name = row.data['name'] as String?;
      if (name == 'is_visible') {
        hasIsVisible = true;
      }
      if (name == 'is_valid') {
        hasIsValid = true;
      }
    }

    if (hasIsValid && !hasIsVisible) {
      await customStatement(
        'ALTER TABLE handles RENAME COLUMN is_valid TO is_visible',
      );
    }
  }

  Future<void> _addCompoundIdentifierColumn(Migrator migrator) async {
    final columns = await customSelect("PRAGMA table_info('handles')").get();
    var hasCompound = false;
    var hasNormalized = false;

    for (final row in columns) {
      final name = row.data['name'] as String?;
      if (name == 'compound_identifier') {
        hasCompound = true;
      }
      if (name == 'normalized_identifier') {
        hasNormalized = true;
      }
    }

    if (!hasCompound) {
      // Replaced with raw SQL since WorkingHandles is removed
      await customStatement(
        'ALTER TABLE handles ADD COLUMN compound_identifier TEXT',
      );
    }

    final selectSql = hasNormalized
        ? 'SELECT id, raw_identifier, normalized_identifier, service, compound_identifier FROM handles'
        : 'SELECT id, raw_identifier, NULL AS normalized_identifier, service, compound_identifier FROM handles';
    final existing = await customSelect(selectSql).get();

    for (final row in existing) {
      final data = row.data;
      final id = data['id'] as int?;
      if (id == null) {
        continue;
      }

      final rawIdentifier = data['raw_identifier'] as String?;
      final normalizedIdentifier = data['normalized_identifier'] as String?;
      final service = sanitizeHandleService(data['service'] as String?);
      final compoundFromRow = (data['compound_identifier'] as String?)?.trim();
      final compoundIdentifier =
          (compoundFromRow != null && compoundFromRow.isNotEmpty)
          ? compoundFromRow
          : buildCompoundIdentifier(
              normalizedIdentifier: normalizedIdentifier,
              rawIdentifier: rawIdentifier,
              service: service,
            );

      await customStatement(
        'UPDATE handles SET compound_identifier = ? WHERE id = ?',
        <Object?>[compoundIdentifier, id],
      );
    }
  }

  Future<void> _removeNormalizedIdentifierColumn(Migrator migrator) async {
    // This migration step is skipped because 'handles' table is dropped in v17 anyway.
    // Recreating the table here would require defining the schema which we are deleting.
    return;
  }

  Future<void> _addHandleDisplayNameColumn(Migrator migrator) async {
    final columns = await customSelect("PRAGMA table_info('handles')").get();
    var hasDisplayColumn = false;

    for (final row in columns) {
      final name = row.data['name'] as String?;
      if (name == 'display_name') {
        hasDisplayColumn = true;
        break;
      }
    }

    if (!hasDisplayColumn) {
      // Replaced with raw SQL since WorkingHandles is removed
      await customStatement('ALTER TABLE handles ADD COLUMN display_name TEXT');
    }

    // Read all handles and format phone numbers for display_name
    final handles = await customSelect(
      'SELECT id, raw_identifier FROM handles',
    ).get();

    for (final row in handles) {
      final id = row.data['id'] as int?;
      final rawIdentifier = row.data['raw_identifier'] as String?;

      if (id == null || rawIdentifier == null || rawIdentifier.trim().isEmpty) {
        continue;
      }

      // Format phone numbers into human-friendly display
      final displayName = formatPhoneNumberForDisplay(rawIdentifier);

      await customStatement(
        'UPDATE handles SET display_name = ? WHERE id = ?',
        [displayName, id],
      );
    }

    // Fallback for any remaining null display_name values
    await customStatement('''
      UPDATE handles
         SET display_name = CASE
           WHEN TRIM(raw_identifier) <> '' THEN TRIM(raw_identifier)
           WHEN TRIM(compound_identifier) <> '' THEN TRIM(compound_identifier)
           ELSE 'Unknown Contact'
         END
       WHERE display_name IS NULL OR TRIM(display_name) = ''
      ''');
  }

  Future<void> _dropLegacyHandleCanonicalMapTable() async {
    await customStatement(
      'DROP INDEX IF EXISTS idx_handle_canonical_map_canonical',
    );
    await customStatement('DROP TABLE IF EXISTS handle_canonical_map');
  }

  Future<void> _addGlobalMessageIndexTable(Migrator m) async {
    // Table is populated via rebuildGlobalMessageIndex() after migrations complete.
    await m.createTable(globalMessageIndex);
  }

  Future<void> _addMessageIndexTable(Migrator m) async {
    // Create the table only - DO NOT populate yet
    // Triggers will be created later by _createVirtualTablesAndTriggers()
    // Data will be populated by rebuildMessageIndex() AFTER MessagesMigrator runs
    await m.createTable(messageIndex);
  }

  Future<void> _addContactMessageIndexTable(Migrator m) async {
    // Create the table only - DO NOT populate yet
    // Triggers will be created later by _createVirtualTablesAndTriggers()
    // Data will be populated by rebuildContactMessageIndex() AFTER MessagesMigrator runs
    await m.createTable(contactMessageIndex);
  }

  /// Rebuilds the message_index table from scratch.
  /// Should be called AFTER all messages are migrated to avoid O(N²) trigger overhead.
  /// This is public so HandlesMigrationService can call it after MessagesMigrator completes.
  Future<void> rebuildGlobalMessageIndex() async {
    await customStatement(
      'DROP TRIGGER IF EXISTS trg_global_message_index_insert',
    );
    await customStatement(
      'DROP TRIGGER IF EXISTS trg_global_message_index_update',
    );
    await customStatement(
      'DROP TRIGGER IF EXISTS trg_global_message_index_delete',
    );

    await customStatement('DELETE FROM global_message_index');

    await customStatement('''
      INSERT INTO global_message_index (ordinal, message_id, chat_id, sent_at_utc, month_key)
      SELECT
        (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
        id AS message_id,
        chat_id,
        sent_at_utc,
        STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
      FROM messages
      WHERE chat_id IS NOT NULL
      ORDER BY sent_at_utc, id
    ''');
  }

  Future<void> rebuildMessageIndex() async {
    // Drop existing triggers to prevent O(N²) behavior during bulk insert
    await customStatement('DROP TRIGGER IF EXISTS trg_message_index_insert');
    await customStatement('DROP TRIGGER IF EXISTS trg_message_index_update');
    await customStatement('DROP TRIGGER IF EXISTS trg_message_index_delete');

    // Clear any partial data
    await customStatement('DELETE FROM message_index');

    // Populate ordinals for existing messages using ROW_NUMBER()
    await customStatement('''
      INSERT INTO message_index (chat_id, ordinal, message_id, sent_at_utc, month_key)
      SELECT 
        chat_id,
        (ROW_NUMBER() OVER (PARTITION BY chat_id ORDER BY sent_at_utc, id) - 1) AS ordinal,
        id AS message_id,
        sent_at_utc,
        STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
      FROM messages
      WHERE chat_id IS NOT NULL
      ORDER BY chat_id, sent_at_utc, id
    ''');

    // Triggers will be recreated by _createVirtualTablesAndTriggers() after this
  }

  /// Rebuilds the contact_message_index table from scratch.
  /// Should be called AFTER all messages are migrated to avoid O(N²) trigger overhead.
  /// This is public so HandlesMigrationService can call it after MessagesMigrator completes.
  Future<void> rebuildContactMessageIndex() async {
    // Drop existing triggers to prevent O(N²) behavior during bulk insert
    await customStatement(
      'DROP TRIGGER IF EXISTS trg_contact_message_index_insert',
    );
    await customStatement(
      'DROP TRIGGER IF EXISTS trg_contact_message_index_update',
    );
    await customStatement(
      'DROP TRIGGER IF EXISTS trg_contact_message_index_delete',
    );

    // Clear any partial data
    await customStatement('DELETE FROM contact_message_index');

    // Populate ordinals for existing messages, indexed by contact (participant)
    // Each message appears once per contact they communicated with:
    // - For outgoing messages (is_from_me=1): One entry per recipient participant in the chat
    // - For incoming messages (is_from_me=0): One entry for the sender participant
    // This ensures all messages with a contact appear in their timeline
    // Note: Using GROUP BY to deduplicate (message_id, contact_id) pairs that might appear
    // from both UNION branches (e.g., sending to yourself in a group chat)
    await customStatement('''
      WITH contact_messages_raw AS (
        -- Outgoing messages: Index under each recipient participant
        SELECT 
          m.id AS message_id,
          m.sent_at_utc,
          htp_recip.participant_id AS contact_id
        FROM messages m
        JOIN chat_to_handle cth ON m.chat_id = cth.chat_id
        JOIN handle_to_participant htp_recip ON cth.handle_id = htp_recip.handle_id
        WHERE m.is_from_me = 1 
          AND htp_recip.participant_id IS NOT NULL
        
        UNION ALL
        
        -- Incoming messages: Index under sender participant
        SELECT 
          m.id AS message_id,
          m.sent_at_utc,
          htp_sender.participant_id AS contact_id
        FROM messages m
        JOIN handles_canonical h_sender ON m.sender_handle_id = h_sender.id
        JOIN handle_to_participant htp_sender ON h_sender.id = htp_sender.handle_id
        WHERE m.is_from_me = 0
          AND htp_sender.participant_id IS NOT NULL
      ),
      contact_messages_deduped AS (
        -- Deduplicate (message_id, contact_id) pairs
        SELECT 
          message_id,
          MAX(sent_at_utc) AS sent_at_utc,
          contact_id
        FROM contact_messages_raw
        WHERE contact_id IS NOT NULL
        GROUP BY message_id, contact_id
      )
      INSERT INTO contact_message_index (contact_id, ordinal, message_id, sent_at_utc, month_key)
      SELECT 
        contact_id,
        (ROW_NUMBER() OVER (PARTITION BY contact_id ORDER BY sent_at_utc, message_id) - 1) AS ordinal,
        message_id,
        sent_at_utc,
        STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
      FROM contact_messages_deduped
      ORDER BY contact_id, sent_at_utc, message_id
    ''');

    // Triggers will be recreated by _createVirtualTablesAndTriggers() after this
  }

  /// Rebuild contact message index for a specific participant only
  ///
  /// More efficient than full rebuild when only one contact's links changed.
  /// Used after manual handle-to-participant linking.
  Future<void> rebuildContactMessageIndexForParticipant(
    int participantId,
  ) async {
    // Delete existing entries for this participant
    await (delete(
      contactMessageIndex,
    )..where((tbl) => tbl.contactId.equals(participantId))).go();

    // Rebuild for this participant only using the same logic as full rebuild
    await customStatement(
      '''
      WITH contact_messages_raw AS (
        -- Outgoing messages: Index under recipient participant (filtered to target participant)
        SELECT 
          m.id AS message_id,
          m.sent_at_utc,
          htp_recip.participant_id AS contact_id
        FROM messages m
        JOIN chat_to_handle cth ON m.chat_id = cth.chat_id
        JOIN handle_to_participant htp_recip ON cth.handle_id = htp_recip.handle_id
        WHERE m.is_from_me = 1 
          AND htp_recip.participant_id = ?
        
        UNION ALL
        
        -- Incoming messages: Index under sender participant (filtered to target participant)
        SELECT 
          m.id AS message_id,
          m.sent_at_utc,
          htp_sender.participant_id AS contact_id
        FROM messages m
        JOIN handles_canonical h_sender ON m.sender_handle_id = h_sender.id
        JOIN handle_to_participant htp_sender ON h_sender.id = htp_sender.handle_id
        WHERE m.is_from_me = 0
          AND htp_sender.participant_id = ?
      ),
      contact_messages_deduped AS (
        -- Deduplicate (message_id, contact_id) pairs
        SELECT 
          message_id,
          MAX(sent_at_utc) AS sent_at_utc,
          contact_id
        FROM contact_messages_raw
        WHERE contact_id IS NOT NULL
        GROUP BY message_id, contact_id
      )
      INSERT INTO contact_message_index (contact_id, ordinal, message_id, sent_at_utc, month_key)
      SELECT 
        contact_id,
        (ROW_NUMBER() OVER (PARTITION BY contact_id ORDER BY sent_at_utc, message_id) - 1) AS ordinal,
        message_id,
        sent_at_utc,
        STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
      FROM contact_messages_deduped
      ORDER BY contact_id, sent_at_utc, message_id
    ''',
      [participantId, participantId],
    );
  }
}

const List<String> _workingIndexStatements = [
  'CREATE INDEX IF NOT EXISTS idx_chats_sort ON chats(pinned DESC, last_message_at_utc DESC)',
  'CREATE INDEX IF NOT EXISTS idx_messages_chat_time ON messages(chat_id, sent_at_utc)',
  'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_messages_reply ON messages(reply_to_guid)',
  'CREATE INDEX IF NOT EXISTS idx_messages_associated ON messages(associated_message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_messages_batch ON messages(batch_id)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_global_message_index_ordinal ON global_message_index(ordinal)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_global_message_index_message ON global_message_index(message_id)',
  'CREATE INDEX IF NOT EXISTS idx_global_message_index_month ON global_message_index(month_key, ordinal)',
  'CREATE INDEX IF NOT EXISTS idx_global_message_index_chat ON global_message_index(chat_id)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_message_index_ordinal ON message_index(chat_id, ordinal)',
  'CREATE INDEX IF NOT EXISTS idx_message_index_month ON message_index(chat_id, month_key, ordinal)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_message_index_message ON message_index(message_id)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_contact_message_index_ordinal ON contact_message_index(contact_id, ordinal)',
  'CREATE INDEX IF NOT EXISTS idx_contact_message_index_month ON contact_message_index(contact_id, month_key, ordinal)',
  'CREATE INDEX IF NOT EXISTS idx_contact_message_index_message_contact ON contact_message_index(message_id, contact_id)',
  'CREATE INDEX IF NOT EXISTS idx_attachments_msg ON attachments(message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_attachments_batch ON attachments(batch_id)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(target_message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_carrier ON reactions(carrier_message_id)',
  'CREATE INDEX IF NOT EXISTS idx_handle_to_participant_handle ON handle_to_participant(handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_handle_to_participant_participant ON handle_to_participant(participant_id)',
  'CREATE INDEX IF NOT EXISTS idx_handles_compound ON handles_canonical(compound_identifier)',
  'CREATE INDEX IF NOT EXISTS idx_handles_blacklist ON handles_canonical(is_blacklisted, service)',
  'CREATE INDEX IF NOT EXISTS idx_handles_batch ON handles_canonical(batch_id)',
  'CREATE INDEX IF NOT EXISTS idx_chat_to_handle_handle ON chat_to_handle(handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_handles_canonical_to_alias_canonical ON handles_canonical_to_alias(canonical_handle_id)',
];

const List<String> _workingVirtualAndTriggerStatements = [
  // FTS table
  '''
  CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
    guid UNINDEXED,
    chat_id UNINDEXED,
    text,
    tokenize='unicode61 remove_diacritics 2'
  )
  ''',
  // FTS triggers
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_fts_insert
  AFTER INSERT ON messages BEGIN
    INSERT INTO messages_fts (rowid, guid, chat_id, text)
    VALUES (new.id, new.guid, new.chat_id, COALESCE(new.text,''));
  END;
  ''',
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_fts_update
  AFTER UPDATE OF text ON messages BEGIN
    UPDATE messages_fts SET text = COALESCE(new.text,'') WHERE rowid = new.id;
  END;
  ''',
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_fts_delete
  AFTER DELETE ON messages BEGIN
    DELETE FROM messages_fts WHERE rowid = old.id;
  END;
  ''',

  // Projection helper views
  '''
  CREATE VIEW IF NOT EXISTS v_chat_latest AS
  SELECT
    c.id           AS chat_id,
    c.guid         AS chat_guid,
    c.last_message_at_utc,
    c.unread_count,
    m.guid         AS last_message_guid,
    m.text         AS last_message_text,
    m.sender_handle_id
  FROM chats c
  LEFT JOIN messages m
    ON m.chat_id = c.id
   AND m.sent_at_utc = c.last_message_at_utc;
  ''',

  '''
  CREATE VIEW IF NOT EXISTS v_message_expanded AS
  SELECT
    m.guid,
    m.chat_id,
    m.sent_at_utc,
    m.text,
    m.item_type,
    m.is_from_me,
  m.sender_handle_id,
  h.raw_identifier AS sender_handle,
    h.compound_identifier AS sender_handle_compound,
    p.id AS sender_participant_id,
    p.display_name AS sender_name,
    rc.love, rc.like, rc.dislike, rc.laugh, rc.emphasize, rc.question
  FROM messages m
  LEFT JOIN handles_canonical h ON h.id = m.sender_handle_id
  LEFT JOIN handle_to_participant htp ON htp.handle_id = m.sender_handle_id
  LEFT JOIN participants p ON p.id = htp.participant_id
  LEFT JOIN reaction_counts rc ON rc.message_guid = m.guid;
  ''',

  // Reaction maintenance triggers
  '''
  CREATE TRIGGER IF NOT EXISTS trg_reactions_after_change
  AFTER INSERT ON reactions
  BEGIN
    INSERT INTO reaction_counts(message_guid, love, like, dislike, laugh, emphasize, question)
    VALUES (new.message_guid, 0,0,0,0,0,0)
    ON CONFLICT(message_guid) DO NOTHING;

    UPDATE reaction_counts
       SET
         love      = love      + CASE WHEN new.kind='love'      AND new.action='add' THEN 1 WHEN new.kind='love'      AND new.action='remove' THEN -1 ELSE 0 END,
         like      = like      + CASE WHEN new.kind='like'      AND new.action='add' THEN 1 WHEN new.kind='like'      AND new.action='remove' THEN -1 ELSE 0 END,
         dislike   = dislike   + CASE WHEN new.kind='dislike'   AND new.action='add' THEN 1 WHEN new.kind='dislike'   AND new.action='remove' THEN -1 ELSE 0 END,
         laugh     = laugh     + CASE WHEN new.kind='laugh'     AND new.action='add' THEN 1 WHEN new.kind='laugh'     AND new.action='remove' THEN -1 ELSE 0 END,
         emphasize = emphasize + CASE WHEN new.kind='emphasize' AND new.action='add' THEN 1 WHEN new.kind='emphasize' AND new.action='remove' THEN -1 ELSE 0 END,
         question  = question  + CASE WHEN new.kind='question'  AND new.action='add' THEN 1 WHEN new.kind='question'  AND new.action='remove' THEN -1 ELSE 0 END;

    UPDATE messages
       SET reaction_summary_json = (
         SELECT json_object(
           'love',      love,
           'like',      like,
           'dislike',   dislike,
           'laugh',     laugh,
           'emphasize', emphasize,
           'question',  question
         )
         FROM reaction_counts WHERE message_guid = NEW.message_guid
       ),
           updated_at_utc = strftime('%Y-%m-%dT%H:%M:%fZ','now')
     WHERE guid = NEW.message_guid;
  END;
  ''',
  // Message insert trigger for chat metadata and unread counts
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_after_insert
  AFTER INSERT ON messages
  BEGIN
    UPDATE chats
       SET last_message_at_utc = CASE
             WHEN last_message_at_utc IS NULL OR new.sent_at_utc > last_message_at_utc
             THEN new.sent_at_utc ELSE last_message_at_utc END,
           last_sender_handle_id = CASE
             WHEN last_message_at_utc IS NULL OR new.sent_at_utc >= last_message_at_utc
             THEN new.sender_handle_id ELSE last_sender_handle_id END,
           last_message_preview = CASE
             WHEN last_message_at_utc IS NULL OR new.sent_at_utc >= last_message_at_utc
             THEN substr(COALESCE(new.text,''), 1, 120) ELSE last_message_preview END
     WHERE id = new.chat_id;

    UPDATE chats
       SET unread_count = unread_count + CASE
           WHEN new.is_from_me = 0 AND (new.read_at_utc IS NULL) THEN 1 ELSE 0 END
     WHERE id = new.chat_id;
  END;
  ''',
  // Message read trigger for unread decrement
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_mark_read
  AFTER UPDATE OF read_at_utc ON messages
  WHEN new.read_at_utc IS NOT NULL AND old.read_at_utc IS NULL
  BEGIN
    UPDATE chats
       SET unread_count = MAX(unread_count - 1, 0)
     WHERE id = new.chat_id;
  END;
  ''',
];

// Message index maintenance triggers - created AFTER bulk migration to avoid O(N²)
// These triggers are NOT included in _workingVirtualAndTriggerStatements
// Instead, they are created by createMessageIndexTriggers() after rebuildMessageIndex()
const List<String> _messageIndexTriggerStatements = [
  // Global message index: Insert trigger
  '''
  CREATE TRIGGER IF NOT EXISTS trg_global_message_index_insert
  AFTER INSERT ON messages 
  WHEN new.chat_id IS NOT NULL
  BEGIN
    DELETE FROM global_message_index;
    INSERT INTO global_message_index (ordinal, message_id, chat_id, sent_at_utc, month_key)
    SELECT 
      (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
      id AS message_id,
      chat_id,
      sent_at_utc,
      STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
    FROM messages
    WHERE chat_id IS NOT NULL
    ORDER BY sent_at_utc, id;
  END;
  ''',

  // Global message index: Update trigger
  '''
  CREATE TRIGGER IF NOT EXISTS trg_global_message_index_update
  AFTER UPDATE OF sent_at_utc ON messages
  WHEN new.chat_id IS NOT NULL AND new.sent_at_utc != old.sent_at_utc
  BEGIN
    DELETE FROM global_message_index;
    INSERT INTO global_message_index (ordinal, message_id, chat_id, sent_at_utc, month_key)
    SELECT 
      (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
      id AS message_id,
      chat_id,
      sent_at_utc,
      STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
    FROM messages
    WHERE chat_id IS NOT NULL
    ORDER BY sent_at_utc, id;
  END;
  ''',

  // Global message index: Delete trigger
  '''
  CREATE TRIGGER IF NOT EXISTS trg_global_message_index_delete
  AFTER DELETE ON messages
  WHEN old.chat_id IS NOT NULL
  BEGIN
    DELETE FROM global_message_index;
    INSERT INTO global_message_index (ordinal, message_id, chat_id, sent_at_utc, month_key)
    SELECT 
      (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
      id AS message_id,
      chat_id,
      sent_at_utc,
      STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
    FROM messages
    WHERE chat_id IS NOT NULL
    ORDER BY sent_at_utc, id;
  END;
  ''',

  // Message index: Insert trigger
  '''
  CREATE TRIGGER IF NOT EXISTS trg_message_index_insert
  AFTER INSERT ON messages 
  WHEN new.chat_id IS NOT NULL
  BEGIN
    DELETE FROM message_index WHERE chat_id = new.chat_id;
    INSERT INTO message_index (chat_id, ordinal, message_id, sent_at_utc, month_key)
    SELECT 
      chat_id,
      (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
      id AS message_id,
      sent_at_utc,
      STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
    FROM messages
    WHERE chat_id = new.chat_id
    ORDER BY sent_at_utc, id;
  END;
  ''',

  // Message index: Update trigger
  '''
  CREATE TRIGGER IF NOT EXISTS trg_message_index_update
  AFTER UPDATE OF sent_at_utc ON messages
  WHEN old.chat_id IS NOT NULL AND new.sent_at_utc != old.sent_at_utc
  BEGIN
    DELETE FROM message_index WHERE chat_id = old.chat_id;
    INSERT INTO message_index (chat_id, ordinal, message_id, sent_at_utc, month_key)
    SELECT 
      chat_id,
      (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
      id AS message_id,
      sent_at_utc,
      STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
    FROM messages
    WHERE chat_id = old.chat_id
    ORDER BY sent_at_utc, id;
  END;
  ''',

  // Message index: Delete trigger
  '''
  CREATE TRIGGER IF NOT EXISTS trg_message_index_delete
  AFTER DELETE ON messages
  WHEN old.chat_id IS NOT NULL
  BEGIN
    DELETE FROM message_index WHERE chat_id = old.chat_id;
    INSERT INTO message_index (chat_id, ordinal, message_id, sent_at_utc, month_key)
    SELECT 
      chat_id,
      (ROW_NUMBER() OVER (ORDER BY sent_at_utc, id) - 1) AS ordinal,
      id AS message_id,
      sent_at_utc,
      STRFTIME('%Y-%m', COALESCE(sent_at_utc, '1970-01-01')) AS month_key
    FROM messages
    WHERE chat_id = old.chat_id
    ORDER BY sent_at_utc, id;
  END;
  ''',

  // Contact message index triggers omitted here for brevity
  // They follow the same pattern but are more complex
  // See rebuildContactMessageIndex() method which temporarily drops them
];

class WorkingSchemaMigrations extends Table {
  @override
  String get tableName => 'schema_migrations';

  IntColumn get version => integer().named('version')();
  TextColumn get appliedAtUtc => text().named('applied_at_utc')();

  @override
  Set<Column> get primaryKey => {version};
}

/// Singleton table to track projection state. (Ensured to have only one row with id=1 by constraint)
class ProjectionState extends Table {
  @override
  String get tableName => 'projection_state';

  IntColumn get id => integer()
      .named('id')
      .clientDefault(() => 1)
      .customConstraint('NOT NULL CHECK(id=1)')(); // removed PRIMARY KEY here
  IntColumn get lastImportBatchId =>
      integer().named('last_import_batch_id').nullable()();
  TextColumn get lastProjectedAtUtc =>
      text().named('last_projected_at_utc').nullable()();
  IntColumn get lastProjectedMessageId =>
      integer().named('last_projected_message_id').nullable()();
  IntColumn get lastProjectedAttachmentId =>
      integer().named('last_projected_attachment_id').nullable()();

  @override
  Set<Column> get primaryKey => {id}; // single source of truth for PK
}

class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text().named('key')();
  TextColumn get value => text().named('value')();

  @override
  Set<Column> get primaryKey => {key};
}

// WorkingHandles table removed in v17
// class WorkingHandles extends Table {
//   @override
//   String get tableName => 'handles';
//
//   IntColumn get id => integer().named('id')();
//   TextColumn get rawIdentifier => text().named('raw_identifier')();
//   TextColumn get displayName => text().named('display_name')();
//   TextColumn get compoundIdentifier => text().named('compound_identifier')();
//   TextColumn get service => text()
//       .named('service')
//       .customConstraint(
//         "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))",
//       )();
//   BoolColumn get isIgnored =>
//       boolean().named('is_ignored').withDefault(const Constant(false))();
//   BoolColumn get isVisible =>
//       boolean().named('is_visible').withDefault(const Constant(true))();
//   BoolColumn get isBlacklisted =>
//       boolean().named('is_blacklisted').withDefault(const Constant(false))();
//   TextColumn get country => text().named('country').nullable()();
//   TextColumn get lastSeenUtc => text().named('last_seen_utc').nullable()();
//   IntColumn get batchId => integer().named('batch_id').nullable()();
//
//   @override
//   Set<Column> get primaryKey => {id};
//
//   @override
//   List<Set<Column>> get uniqueKeys => [
//     {compoundIdentifier},
//     {rawIdentifier, service},
//   ];
// }

/// New canonical handles table - will replace WorkingHandles
/// This table stores only canonical handles (one per real-world communication endpoint)
/// All handle variants (SMS/iMessage/etc of same phone) are collapsed to one canonical
class HandlesCanonical extends Table {
  @override
  String get tableName => 'handles_canonical';

  IntColumn get id => integer().named('id')();
  TextColumn get rawIdentifier => text().named('raw_identifier')();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get compoundIdentifier => text().named('compound_identifier')();
  TextColumn get service => text()
      .named('service')
      .customConstraint(
        "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))",
      )();
  BoolColumn get isIgnored =>
      boolean().named('is_ignored').withDefault(const Constant(false))();
  BoolColumn get isVisible =>
      boolean().named('is_visible').withDefault(const Constant(true))();
  BoolColumn get isBlacklisted =>
      boolean().named('is_blacklisted').withDefault(const Constant(false))();
  TextColumn get country => text().named('country').nullable()();
  TextColumn get lastSeenUtc => text().named('last_seen_utc').nullable()();
  IntColumn get batchId => integer().named('batch_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {compoundIdentifier},
    {rawIdentifier, service},
  ];
}

class WorkingParticipants extends Table {
  @override
  String get tableName => 'participants';

  IntColumn get id => integer().named('id')(); // Preserves AddressBook Z_PK
  TextColumn get originalName => text().named('original_name')();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get shortName => text().named('short_name')();
  TextColumn get avatarRef => text().named('avatar_ref').nullable()();
  TextColumn get givenName => text().named('given_name').nullable()();
  TextColumn get familyName => text().named('family_name').nullable()();
  TextColumn get organization => text().named('organization').nullable()();
  BoolColumn get isOrganization =>
      boolean().named('is_organization').withDefault(const Constant(false))();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();
  IntColumn get sourceRecordId =>
      integer().named('source_record_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class HandleToParticipant extends Table {
  @override
  String get tableName => 'handle_to_participant';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get handleId => integer()
      .named('handle_id')
      .references(HandlesCanonical, #id, onDelete: KeyAction.cascade)();
  IntColumn get participantId => integer()
      .named('participant_id')
      .references(WorkingParticipants, #id, onDelete: KeyAction.cascade)();
  RealColumn get confidence =>
      real().named('confidence').withDefault(const Constant(1.0))();
  TextColumn get source =>
      text().named('source').withDefault(const Constant('addressbook'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {handleId, participantId},
  ];
}

class HandlesCanonicalToAlias extends Table {
  @override
  String get tableName => 'handles_canonical_to_alias';

  IntColumn get sourceHandleId => integer().named('source_handle_id')();
  IntColumn get canonicalHandleId => integer()
      .named('canonical_handle_id')
      .references(HandlesCanonical, #id, onDelete: KeyAction.cascade)();
  TextColumn get rawIdentifier => text().named('raw_identifier')();
  TextColumn get compoundIdentifier => text().named('compound_identifier')();
  TextColumn get normalizedIdentifier =>
      text().named('normalized_identifier')();
  TextColumn get service => text()
      .named('service')
      .customConstraint(
        "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))",
      )();
  TextColumn get aliasKind =>
      text().named('alias_kind').withDefault(const Constant('variant'))();

  @override
  Set<Column> get primaryKey => {sourceHandleId};

  // No additional unique constraints needed - source_handle_id PK is sufficient
  // Removed: {canonicalHandleId, rawIdentifier} which incorrectly prevented
  // multiple source handles with same raw_identifier from mapping to same canonical
}

class ChatToHandle extends Table {
  @override
  String get tableName => 'chat_to_handle';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get handleId => integer()
      .named('handle_id')
      .references(HandlesCanonical, #id, onDelete: KeyAction.cascade)();
  TextColumn get role =>
      text().named('role').withDefault(const Constant('member'))();
  TextColumn get addedAtUtc => text().named('added_at_utc').nullable()();
  BoolColumn get isIgnored =>
      boolean().named('is_ignored').withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {chatId, handleId},
  ];
}

class WorkingChats extends Table {
  @override
  String get tableName => 'chats';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get guid => text().named('guid')();
  TextColumn get service => text()
      .named('service')
      .customConstraint(
        "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))",
      )();
  BoolColumn get isGroup =>
      boolean().named('is_group').withDefault(const Constant(false))();
  TextColumn get lastMessageAtUtc =>
      text().named('last_message_at_utc').nullable()();
  IntColumn get lastSenderHandleId => integer()
      .named('last_sender_handle_id')
      .nullable()
      .references(HandlesCanonical, #id, onDelete: KeyAction.setNull)();
  TextColumn get lastMessagePreview =>
      text().named('last_message_preview').nullable()();
  IntColumn get unreadCount =>
      integer().named('unread_count').withDefault(const Constant(0))();
  BoolColumn get pinned =>
      boolean().named('pinned').withDefault(const Constant(false))();
  BoolColumn get archived =>
      boolean().named('archived').withDefault(const Constant(false))();
  TextColumn get mutedUntilUtc => text().named('muted_until_utc').nullable()();
  BoolColumn get favourite =>
      boolean().named('favourite').withDefault(const Constant(false))();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();
  BoolColumn get isIgnored =>
      boolean().named('is_ignored').withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

class WorkingMessages extends Table {
  @override
  String get tableName => 'messages';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get guid => text().named('guid')();
  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get senderHandleId => integer()
      .named('sender_handle_id')
      .nullable()
      .references(HandlesCanonical, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isFromMe =>
      boolean().named('is_from_me').withDefault(const Constant(false))();
  TextColumn get sentAtUtc => text().named('sent_at_utc').nullable()();
  TextColumn get deliveredAtUtc =>
      text().named('delivered_at_utc').nullable()();
  TextColumn get readAtUtc => text().named('read_at_utc').nullable()();
  TextColumn get status => text()
      .named('status')
      .customConstraint(
        "NOT NULL DEFAULT 'unknown' CHECK(status IN ('unknown','sent','delivered','read','failed'))",
      )();
  TextColumn get textContent => text().named('text').nullable()();
  TextColumn get itemType => text()
      .named('item_type')
      .nullable()
      .customConstraint(
        "CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown') OR item_type IS NULL)",
      )();
  BoolColumn get isSystemMessage =>
      boolean().named('is_system_message').withDefault(const Constant(false))();
  IntColumn get errorCode => integer().named('error_code').nullable()();
  BoolColumn get hasAttachments =>
      boolean().named('has_attachments').withDefault(const Constant(false))();
  TextColumn get replyToGuid => text().named('reply_to_guid').nullable()();
  TextColumn get associatedMessageGuid =>
      text().named('associated_message_guid').nullable()();
  TextColumn get threadOriginatorGuid =>
      text().named('thread_originator_guid').nullable()();
  TextColumn get systemType => text().named('system_type').nullable()();
  BoolColumn get reactionCarrier =>
      boolean().named('reaction_carrier').withDefault(const Constant(false))();
  TextColumn get balloonBundleId =>
      text().named('balloon_bundle_id').nullable()();
  TextColumn get payloadJson => text().named('payload_json').nullable()();
  TextColumn get reactionSummaryJson =>
      text().named('reaction_summary_json').nullable()();
  BoolColumn get isStarred =>
      boolean().named('is_starred').withDefault(const Constant(false))();
  BoolColumn get isDeletedLocal =>
      boolean().named('is_deleted_local').withDefault(const Constant(false))();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();
  IntColumn get batchId => integer().named('batch_id').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

/// Ordinal index for stable message ordering in large chats.
/// Maps each message to a zero-based sequential position within its chat.
/// Enables O(1) lookups and instant timeline jumps without loading all messages.
class GlobalMessageIndex extends Table {
  @override
  String get tableName => 'global_message_index';

  IntColumn get ordinal => integer().named('ordinal')();
  IntColumn get messageId => integer()
      .named('message_id')
      .references(WorkingMessages, #id, onDelete: KeyAction.cascade)();
  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentAtUtc => text().named('sent_at_utc').nullable()();
  TextColumn get monthKey =>
      text().named('month_key')(); // Format: 'YYYY-MM' for timeline buckets

  @override
  Set<Column> get primaryKey => {ordinal};

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId},
  ];
}

class MessageIndex extends Table {
  @override
  String get tableName => 'message_index';

  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordinal => integer().named('ordinal')();
  IntColumn get messageId => integer()
      .named('message_id')
      .references(WorkingMessages, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentAtUtc => text().named('sent_at_utc').nullable()();
  TextColumn get monthKey =>
      text().named('month_key')(); // Format: 'YYYY-MM' for timeline

  @override
  Set<Column> get primaryKey => {chatId, ordinal};

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId},
  ];
}

/// Ordinal index for all messages exchanged with a contact (participant).
/// Enables unified chronological view across multiple chats/handles.
/// Partitioned by contact_id, ordered by sent_at_utc.
class ContactMessageIndex extends Table {
  @override
  String get tableName => 'contact_message_index';

  IntColumn get contactId => integer()
      .named('contact_id')
      .references(WorkingParticipants, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordinal => integer().named('ordinal')();
  IntColumn get messageId => integer()
      .named('message_id')
      .references(WorkingMessages, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentAtUtc => text().named('sent_at_utc').nullable()();
  TextColumn get monthKey =>
      text().named('month_key')(); // Format: 'YYYY-MM' for timeline

  @override
  Set<Column> get primaryKey => {contactId, ordinal};

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId, contactId}, // Message can appear once per contact
  ];
}

class WorkingAttachments extends Table {
  @override
  String get tableName => 'attachments';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get messageGuid => text().named('message_guid')();
  IntColumn get importAttachmentId =>
      integer().named('import_attachment_id').nullable()();
  TextColumn get localPath => text().named('local_path').nullable()();
  TextColumn get mimeType => text().named('mime_type').nullable()();
  TextColumn get uti => text().named('uti').nullable()();
  TextColumn get transferName => text().named('transfer_name').nullable()();
  IntColumn get sizeBytes => integer().named('size_bytes').nullable()();
  BoolColumn get isSticker =>
      boolean().named('is_sticker').withDefault(const Constant(false))();
  TextColumn get thumbPath => text().named('thumb_path').nullable()();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  BoolColumn get isOutgoing =>
      boolean().named('is_outgoing').withDefault(const Constant(false))();
  TextColumn get sha256Hex => text().named('sha256_hex').nullable()();
  IntColumn get batchId => integer().named('batch_id').nullable()();
}

class WorkingReactions extends Table {
  @override
  String get tableName => 'reactions';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get messageGuid => text().named('message_guid')();
  TextColumn get kind => text()
      .named('kind')
      .customConstraint(
        "NOT NULL CHECK(kind IN ('love','like','dislike','laugh','emphasize','question','unknown'))",
      )();
  IntColumn get reactorHandleId => integer()
      .named('reactor_handle_id')
      .nullable()
      .references(HandlesCanonical, #id, onDelete: KeyAction.setNull)();
  TextColumn get action => text()
      .named('action')
      .customConstraint("NOT NULL CHECK(\"action\" IN ('add','remove'))")();
  TextColumn get reactedAtUtc => text().named('reacted_at_utc').nullable()();
  IntColumn get carrierMessageId => integer()
      .named('carrier_message_id')
      .nullable()
      .references(WorkingMessages, #id, onDelete: KeyAction.cascade)();
  TextColumn get targetMessageGuid =>
      text().named('target_message_guid').nullable()();
  RealColumn get parseConfidence =>
      real().named('parse_confidence').withDefault(const Constant(1.0))();
}

class ReactionCounts extends Table {
  @override
  String get tableName => 'reaction_counts';

  TextColumn get messageGuid => text().named('message_guid')();
  IntColumn get love =>
      integer().named('love').withDefault(const Constant(0))();
  IntColumn get like =>
      integer().named('like').withDefault(const Constant(0))();
  IntColumn get dislike =>
      integer().named('dislike').withDefault(const Constant(0))();
  IntColumn get laugh =>
      integer().named('laugh').withDefault(const Constant(0))();
  IntColumn get emphasize =>
      integer().named('emphasize').withDefault(const Constant(0))();
  IntColumn get question =>
      integer().named('question').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {messageGuid};
}

class ReadState extends Table {
  @override
  String get tableName => 'read_state';

  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  TextColumn get lastReadAtUtc => text().named('last_read_at_utc').nullable()();

  @override
  Set<Column> get primaryKey => {chatId};
}

class MessageReadMarks extends Table {
  @override
  String get tableName => 'message_read_marks';

  TextColumn get messageGuid => text().named('message_guid')();
  TextColumn get markedAtUtc => text().named('marked_at_utc')();

  @override
  Set<Column> get primaryKey => {messageGuid};
}

class SupabaseSyncState extends Table {
  @override
  String get tableName => 'supabase_sync_state';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get targetTable => text().named('target_table')();
  IntColumn get lastBatchId => integer().named('last_batch_id').nullable()();
  IntColumn get lastSyncedRowId =>
      integer().named('last_synced_row_id').nullable()();
  TextColumn get lastSyncedGuid =>
      text().named('last_synced_guid').nullable()();
  DateTimeColumn get lastSyncedAt =>
      dateTime().named('last_synced_at').nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {targetTable},
  ];
}

class SupabaseSyncLogs extends Table {
  @override
  String get tableName => 'supabase_sync_logs';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get batchId => integer().named('batch_id').nullable()();
  TextColumn get targetTable => text().named('target_table').nullable()();
  TextColumn get status => text().named('status').nullable()();
  IntColumn get attempt =>
      integer().named('attempt').withDefault(const Constant(1))();
  TextColumn get requestId => text().named('request_id').nullable()();
  TextColumn get message => text().named('message').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}
