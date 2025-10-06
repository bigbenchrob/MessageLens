import 'package:drift/drift.dart';

part 'import_database.g.dart';

/// Drift representation of the immutable ingest ledger (import.db).
@DriftDatabase(
  tables: [
    ImportSchemaMigrations,
    ImportBatches,
    ImportSourceFiles,
    ImportLogs,
    ImportContacts,
    ImportContactPhoneEmail,
    ImportHandles,
    ImportChats,
    ImportChatToHandle,
    ImportMessages,
    ImportChatToMessage,
    ImportAttachments,
    ImportMessageAttachments,
    ImportReactions,
    ImportMessageLinks,
    ImportContactToChatHandle,
  ],
)
class ImportDatabase extends _$ImportDatabase {
  ImportDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
      await _createExpandedMessagesView();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      await _createIndexes();
      await _createExpandedMessagesView();
    },
  );

  Future<void> _createIndexes() async {
    for (final statement in _indexStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _createExpandedMessagesView() async {
    await customStatement(_messagesExpandedViewSql);
  }
}

const String _messagesExpandedViewSql = '''
CREATE VIEW IF NOT EXISTS v_messages_expanded AS
SELECT
  m.id               AS message_id,
  m.guid             AS message_guid,
  m.chat_id,
  c.guid             AS chat_guid,
  m.date_utc,
  m.is_from_me,
  m.text,
  m.item_type,
  m.associated_message_guid,
  h.id               AS sender_handle_id,
  h.normalized_address AS sender_address
FROM messages m
JOIN chats c           ON c.id = m.chat_id
LEFT JOIN handles h    ON h.id = m.sender_handle_id;
''';

const List<String> _indexStatements = [
  'CREATE INDEX IF NOT EXISTS idx_handles_norm ON handles(normalized_identifier)',
  'CREATE INDEX IF NOT EXISTS idx_participants_handle ON chat_to_handle(handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_messages_chat_date ON messages(chat_id, date_utc)',
  'CREATE INDEX IF NOT EXISTS idx_messages_assoc ON messages(associated_message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_handle_id)',
  'CREATE INDEX IF NOT EXISTS idx_attach_created ON attachments(created_at_utc)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(target_message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_reactor ON reactions(reactor_handle_id)',
];

class ImportSchemaMigrations extends Table {
  @override
  String get tableName => 'schema_migrations';

  IntColumn get version => integer().named('version')();
  TextColumn get appliedAtUtc => text().named('applied_at_utc')();
}

class ImportBatches extends Table {
  @override
  String get tableName => 'import_batches';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get startedAtUtc => text().named('started_at_utc')();
  TextColumn get finishedAtUtc => text().named('finished_at_utc').nullable()();
  TextColumn get sourceChatDb => text().named('source_chat_db').nullable()();
  TextColumn get sourceAddressbook =>
      text().named('source_addressbook').nullable()();
  TextColumn get hostInfoJson => text().named('host_info_json').nullable()();
  TextColumn get notes => text().named('notes').nullable()();
}

class ImportSourceFiles extends Table {
  @override
  String get tableName => 'source_files';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.cascade)();
  TextColumn get path => text().named('path')();
  TextColumn get sha256Hex => text().named('sha256_hex').nullable()();
  IntColumn get sizeBytes => integer().named('size_bytes').nullable()();
  TextColumn get mtimeUtc => text().named('mtime_utc').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {path, sha256Hex},
  ];
}

class ImportLogs extends Table {
  @override
  String get tableName => 'import_logs';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get batchId => integer()
      .named('batch_id')
      .nullable()
      .references(ImportBatches, #id, onDelete: KeyAction.setNull)();
  TextColumn get atUtc => text().named('at_utc')();
  TextColumn get level => text()
      .named('level')
      .customConstraint(
        "NOT NULL CHECK(level IN ('debug','info','warn','error'))",
      )();
  TextColumn get message => text().named('message')();
  TextColumn get contextJson => text().named('context_json').nullable()();
}

class ImportContacts extends Table {
  @override
  String get tableName => 'contacts';

  IntColumn get zPk => integer().named('Z_PK')();
  TextColumn get displayName => text().named('display_name').nullable()();
  TextColumn get givenName => text().named('given_name').nullable()();
  TextColumn get familyName => text().named('family_name').nullable()();
  TextColumn get organization => text().named('organization').nullable()();
  BoolColumn get isOrganization =>
      boolean().named('is_organization').withDefault(const Constant(false))();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.restrict)();

  @override
  Set<Column> get primaryKey => {zPk};
}

class ImportContactPhoneEmail extends Table {
  @override
  String get tableName => 'contact_phone_email';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get ownerZPk => integer()
      .named('OWNER_Z_PK')
      .references(ImportContacts, #zPk, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()
      .named('kind')
      .customConstraint("NOT NULL CHECK(kind IN ('email','phone'))")();
  TextColumn get value => text().named('value')();
  TextColumn get label => text().named('label').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {kind, value},
  ];
}

class ImportHandles extends Table {
  @override
  String get tableName => 'handles';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get sourceRowid => integer().named('source_rowid').nullable()();
  TextColumn get service => text()
      .named('service')
      .customConstraint(
        "NOT NULL CHECK(service IN ('iMessage','SMS','Unknown'))",
      )();
  TextColumn get rawIdentifier => text().named('raw_identifier')();
  TextColumn get normalizedIdentifier =>
      text().named('normalized_identifier').nullable()();
  TextColumn get country => text().named('country').nullable()();
  TextColumn get lastSeenUtc => text().named('last_seen_utc').nullable()();
  BoolColumn get isIgnored =>
      boolean().named('is_ignored').withDefault(const Constant(false))();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.restrict)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {service, rawIdentifier},
  ];
}

class ImportChats extends Table {
  @override
  String get tableName => 'chats';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get sourceRowid => integer().named('source_rowid').nullable()();
  TextColumn get guid => text().named('guid')();
  TextColumn get service => text()
      .named('service')
      .nullable()
      .customConstraint(
        "CHECK(service IN ('iMessage','SMS','Unknown') OR service IS NULL)",
      )();
  TextColumn get displayName => text().named('display_name').nullable()();
  BoolColumn get isGroup =>
      boolean().named('is_group').withDefault(const Constant(false))();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();
  BoolColumn get isIgnored =>
      boolean().named('is_ignored').withDefault(const Constant(false))();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.restrict)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

class ImportChatToHandle extends Table {
  @override
  String get tableName => 'chat_to_handle';

  IntColumn get chatId => integer()
      .named('chat_id')
      .references(ImportChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get handleId => integer()
      .named('handle_id')
      .references(ImportHandles, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()
      .named('role')
      .nullable()
      .customConstraint(
        "CHECK(role IN ('member','owner','unknown') OR role IS NULL)",
      )();
  TextColumn get addedAtUtc => text().named('added_at_utc').nullable()();

  @override
  Set<Column> get primaryKey => {chatId, handleId};
}

class ImportMessages extends Table {
  @override
  String get tableName => 'messages';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get sourceRowid => integer().named('source_rowid').nullable()();
  TextColumn get guid => text().named('guid')();
  IntColumn get chatId => integer()
      .named('chat_id')
      .references(ImportChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get senderHandleId => integer()
      .named('sender_handle_id')
      .nullable()
      .references(ImportHandles, #id, onDelete: KeyAction.setNull)();
  TextColumn get service => text()
      .named('service')
      .nullable()
      .customConstraint(
        "CHECK(service IN ('iMessage','SMS','Unknown') OR service IS NULL)",
      )();
  BoolColumn get isFromMe =>
      boolean().named('is_from_me').withDefault(const Constant(false))();
  TextColumn get dateUtc => text().named('date_utc').nullable()();
  TextColumn get dateReadUtc => text().named('date_read_utc').nullable()();
  TextColumn get dateDeliveredUtc =>
      text().named('date_delivered_utc').nullable()();
  TextColumn get subject => text().named('subject').nullable()();
  TextColumn get textContent => text().named('text').nullable()();
  BlobColumn get attributedBodyBlob =>
      blob().named('attributed_body_blob').nullable()();
  TextColumn get itemType => text()
      .named('item_type')
      .nullable()
      .customConstraint(
        "CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown') OR item_type IS NULL)",
      )();
  IntColumn get errorCode => integer().named('error_code').nullable()();
  BoolColumn get isSystemMessage =>
      boolean().named('is_system_message').withDefault(const Constant(false))();
  TextColumn get threadOriginatorGuid =>
      text().named('thread_originator_guid').nullable()();
  TextColumn get associatedMessageGuid =>
      text().named('associated_message_guid').nullable()();
  TextColumn get balloonBundleId =>
      text().named('balloon_bundle_id').nullable()();
  TextColumn get payloadJson => text().named('payload_json').nullable()();
  BoolColumn get isIgnored =>
      boolean().named('is_ignored').withDefault(const Constant(false))();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.restrict)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

class ImportChatToMessage extends Table {
  @override
  String get tableName => 'chat_to_message';

  IntColumn get chatId => integer()
      .named('chat_id')
      .references(ImportChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get messageId => integer()
      .named('message_id')
      .references(ImportMessages, #id, onDelete: KeyAction.cascade)();
  IntColumn get sourceRowid => integer().named('source_rowid').nullable()();

  @override
  Set<Column> get primaryKey => {chatId, messageId};
}

class ImportAttachments extends Table {
  @override
  String get tableName => 'attachments';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get sourceRowid => integer().named('source_rowid').nullable()();
  TextColumn get guid => text().named('guid').nullable()();
  TextColumn get transferName => text().named('transfer_name').nullable()();
  TextColumn get uti => text().named('uti').nullable()();
  TextColumn get mimeType => text().named('mime_type').nullable()();
  IntColumn get totalBytes => integer().named('total_bytes').nullable()();
  BoolColumn get isSticker =>
      boolean().named('is_sticker').withDefault(const Constant(false))();
  BoolColumn get isOutgoing => boolean().named('is_outgoing').nullable()();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  TextColumn get localPath => text().named('local_path').nullable()();
  TextColumn get sha256Hex => text().named('sha256_hex').nullable()();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.restrict)();
}

class ImportMessageAttachments extends Table {
  @override
  String get tableName => 'message_attachments';

  IntColumn get messageId => integer()
      .named('message_id')
      .references(ImportMessages, #id, onDelete: KeyAction.cascade)();
  IntColumn get attachmentId => integer()
      .named('attachment_id')
      .references(ImportAttachments, #id, onDelete: KeyAction.cascade)();
  IntColumn get sourceRowid => integer().named('source_rowid').nullable()();

  @override
  Set<Column> get primaryKey => {messageId, attachmentId};
}

class ImportReactions extends Table {
  @override
  String get tableName => 'reactions';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get carrierMessageId => integer()
      .named('carrier_message_id')
      .references(ImportMessages, #id, onDelete: KeyAction.cascade)();
  TextColumn get targetMessageGuid => text().named('target_message_guid')();
  TextColumn get action => text()
      .named('action')
      .customConstraint("NOT NULL CHECK(\"action\" IN ('add','remove'))")();
  TextColumn get kind => text()
      .named('kind')
      .customConstraint(
        "NOT NULL CHECK(kind IN ('love','like','dislike','laugh','emphasize','question','unknown'))",
      )();
  IntColumn get reactorHandleId => integer()
      .named('reactor_handle_id')
      .nullable()
      .references(ImportHandles, #id, onDelete: KeyAction.setNull)();
  TextColumn get reactedAtUtc => text().named('reacted_at_utc').nullable()();
  RealColumn get parseConfidence => real()
      .named('parse_confidence')
      .customConstraint(
        'NOT NULL DEFAULT 1.0 CHECK(parse_confidence >= 0.0 AND parse_confidence <= 1.0)',
      )();
}

class ImportMessageLinks extends Table {
  @override
  String get tableName => 'message_links';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get messageId => integer()
      .named('message_id')
      .references(ImportMessages, #id, onDelete: KeyAction.cascade)();
  TextColumn get url => text().named('url')();
  IntColumn get start => integer().named('start').nullable()();
  IntColumn get end => integer().named('end').nullable()();
}

class ImportContactToChatHandle extends Table {
  @override
  String get tableName => 'contact_to_chat_handle';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get contactZPk => integer()
      .named('contact_Z_PK')
      .references(ImportContacts, #zPk, onDelete: KeyAction.cascade)();
  IntColumn get chatHandleId => integer()
      .named('chat_handle_id')
      .references(ImportHandles, #id, onDelete: KeyAction.cascade)();
  IntColumn get batchId => integer()
      .named('batch_id')
      .references(ImportBatches, #id, onDelete: KeyAction.restrict)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {contactZPk, chatHandleId},
  ];
}
