import 'package:drift/drift.dart';

part 'working_database.g.dart';

/// Drift projection database used by the application UI (working.db).
@DriftDatabase(
  tables: [
    WorkingSchemaMigrations,
    ProjectionState,
    AppSettings,
    WorkingHandles,
    WorkingParticipants,
    HandleToParticipant,
    ChatToHandle,
    WorkingChats,
    WorkingMessages,
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
  int get schemaVersion => 8;

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
    // Handles metadata
    await migrator.addColumn(
      workingHandles,
      workingHandles.normalizedIdentifier as GeneratedColumn,
    );
    await migrator.addColumn(
      workingHandles,
      workingHandles.isIgnored as GeneratedColumn,
    );
    await migrator.addColumn(
      workingHandles,
      workingHandles.country as GeneratedColumn,
    );
    await migrator.addColumn(
      workingHandles,
      workingHandles.lastSeenUtc as GeneratedColumn,
    );
    await migrator.addColumn(
      workingHandles,
      workingHandles.batchId as GeneratedColumn,
    );

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
      'UPDATE handles SET normalized_identifier = COALESCE(normalized_identifier, raw_identifier)',
    );
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
}

const List<String> _workingIndexStatements = [
  'CREATE INDEX IF NOT EXISTS idx_chats_sort ON chats(pinned DESC, last_message_at_utc DESC)',
  'CREATE INDEX IF NOT EXISTS idx_messages_chat_time ON messages(chat_id, sent_at_utc)',
  'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_messages_reply ON messages(reply_to_guid)',
  'CREATE INDEX IF NOT EXISTS idx_messages_associated ON messages(associated_message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_messages_batch ON messages(batch_id)',
  'CREATE INDEX IF NOT EXISTS idx_attachments_msg ON attachments(message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_attachments_batch ON attachments(batch_id)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(target_message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_carrier ON reactions(carrier_message_id)',
  'CREATE INDEX IF NOT EXISTS idx_handle_to_participant_handle ON handle_to_participant(handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_handle_to_participant_participant ON handle_to_participant(participant_id)',
  'CREATE INDEX IF NOT EXISTS idx_handles_normalized ON handles(normalized_identifier)',
  'CREATE INDEX IF NOT EXISTS idx_handles_blacklist ON handles(is_blacklisted, service)',
  'CREATE INDEX IF NOT EXISTS idx_handles_batch ON handles(batch_id)',
  'CREATE INDEX IF NOT EXISTS idx_chat_to_handle_handle ON chat_to_handle(handle_id)',
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
    h.normalized_identifier AS sender_handle_normalized,
    p.id AS sender_participant_id,
    p.display_name AS sender_name,
    rc.love, rc.like, rc.dislike, rc.laugh, rc.emphasize, rc.question
  FROM messages m
  LEFT JOIN handles h ON h.id = m.sender_handle_id
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

class WorkingHandles extends Table {
  @override
  String get tableName => 'handles';

  IntColumn get id => integer().named('id')();
  TextColumn get rawIdentifier => text().named('raw_identifier')();
  TextColumn get normalizedIdentifier =>
      text().named('normalized_identifier').nullable()();
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
    {rawIdentifier, service},
    {service, normalizedIdentifier},
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
      .references(WorkingHandles, #id, onDelete: KeyAction.cascade)();
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

class ChatToHandle extends Table {
  @override
  String get tableName => 'chat_to_handle';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get handleId => integer()
      .named('handle_id')
      .references(WorkingHandles, #id, onDelete: KeyAction.cascade)();
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
      .references(WorkingHandles, #id, onDelete: KeyAction.setNull)();
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
      .references(WorkingHandles, #id, onDelete: KeyAction.setNull)();
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
      .references(WorkingHandles, #id, onDelete: KeyAction.setNull)();
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
