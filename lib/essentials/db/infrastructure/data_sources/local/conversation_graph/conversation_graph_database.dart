import 'package:drift/drift.dart';

import '../../../../application/read_only_sql_guard.dart';

part 'conversation_graph_database.g.dart';

/// Drift-backed source-scoped conversation graph projection database.
@DriftDatabase(tables: [])
class ConversationGraphDatabase extends _$ConversationGraphDatabase {
  ConversationGraphDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      await _createSchema();
    },
    onUpgrade: (_, from, to) async {
      await _createSchema();
      if (from < 3 && to >= 3) {
        await _rebuildMessageTextSearchIndex();
      }
    },
  );

  Future<List<Map<String, Object?>>> selectRows(
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) async {
    assertReadOnlySql(sql, boundary: 'Conversation graph selectRows');
    final rows = await customSelect(sql, variables: _variables(args)).get();
    return [for (final row in rows) row.data];
  }

  Future<void> executeSql(
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) {
    return customStatement(sql, args);
  }

  Future<int> executeAndReadChanges(
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) async {
    await executeSql(sql, args);
    final rows = await selectRows('SELECT changes() AS change_count');
    final value = rows.single['change_count'];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return 0;
  }

  Future<void> clearProjectionRows() async {
    await transaction(() async {
      await executeSql('DELETE FROM message_to_attachment');
      await executeSql('DELETE FROM chat_to_message');
      await executeSql('DELETE FROM chat_to_handle');
      await executeSql('DELETE FROM contact_to_handle');
      await executeSql('DELETE FROM handle_aliases');
      await executeSql('DELETE FROM canonical_handles');
      await executeSql('DELETE FROM messages');
      await executeSql('DELETE FROM attachments');
      await executeSql('DELETE FROM chats');
      await executeSql('DELETE FROM contacts');
      await executeSql('DELETE FROM handles');
    });
  }

  Future<void> _createSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS messages (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT,
        sender_handle_ss_id INTEGER,
        is_from_me INTEGER NOT NULL CHECK (is_from_me IN (0, 1)),
        date_utc TEXT,
        text TEXT,
        associated_message_ss_id INTEGER,
        sender_canonical_handle_ss_id INTEGER,
        semantic_kind TEXT,
        item_kind TEXT,
        is_system_message INTEGER NOT NULL DEFAULT 0 CHECK (is_system_message IN (0, 1)),
        is_sparse_artifact INTEGER NOT NULL DEFAULT 0 CHECK (is_sparse_artifact IN (0, 1)),
        has_attributed_body_source INTEGER NOT NULL DEFAULT 0 CHECK (has_attributed_body_source IN (0, 1)),
        has_message_summary_info INTEGER NOT NULL DEFAULT 0 CHECK (has_message_summary_info IN (0, 1)),
        has_payload_data_source INTEGER NOT NULL DEFAULT 0 CHECK (has_payload_data_source IN (0, 1)),
        error_code INTEGER
      )
    ''');
    await _addColumnIfMissing('messages', 'text TEXT');
    await _createMessageTextSearchSchema();
    await _createHandleSchema();
    await _createHandleAliasSchema();
    await _createChatSchema();
    await _createChatToMessageSchema();
    await _createChatToHandleSchema();
    await _createContactSchema();
    await _createContactToHandleSchema();
    await _createAttachmentSchema();
    await _createMessageToAttachmentSchema();
  }

  Future<void> _createMessageTextSearchSchema() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS message_text_fts USING fts5(
        text,
        content='messages',
        content_rowid='ss_id',
        tokenize='unicode61 remove_diacritics 2',
        prefix='2 3 4'
      )
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS message_text_fts_after_insert
      AFTER INSERT ON messages
      BEGIN
        INSERT INTO message_text_fts(rowid, text)
        VALUES (new.ss_id, new.text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS message_text_fts_after_delete
      AFTER DELETE ON messages
      BEGIN
        INSERT INTO message_text_fts(message_text_fts, rowid, text)
        VALUES ('delete', old.ss_id, old.text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS message_text_fts_after_text_update
      AFTER UPDATE OF text ON messages
      BEGIN
        INSERT INTO message_text_fts(message_text_fts, rowid, text)
        VALUES ('delete', old.ss_id, old.text);
        INSERT INTO message_text_fts(rowid, text)
        VALUES (new.ss_id, new.text);
      END
    ''');
  }

  Future<void> _rebuildMessageTextSearchIndex() {
    return customStatement(
      "INSERT INTO message_text_fts(message_text_fts) VALUES ('rebuild')",
    );
  }

  static List<Variable> _variables(List<Object?> args) {
    return [
      for (final arg in args)
        if (arg is Variable)
          arg
        else if (arg == null)
          throw StateError('Null customSelect arguments are not supported')
        else
          Variable<Object>(arg),
    ];
  }

  Future<void> _createHandleSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS handles (
        ss_id INTEGER PRIMARY KEY,
        id TEXT NOT NULL,
        service TEXT,
        is_me INTEGER NOT NULL DEFAULT 0 CHECK (is_me IN (0, 1))
      )
    ''');
    await _addColumnIfMissing(
      'handles',
      'is_me INTEGER NOT NULL DEFAULT 0 CHECK (is_me IN (0, 1))',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_working_handles_id ON handles(id)',
    );
  }

  Future<void> _createHandleAliasSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS canonical_handles (
        canonical_handle_ss_id INTEGER PRIMARY KEY,
        display_handle TEXT NOT NULL,
        normalized_identifier TEXT NOT NULL,
        service TEXT,
        alias_count INTEGER NOT NULL
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_canonical_handles_normalized '
      'ON canonical_handles(normalized_identifier)',
    );
    await customStatement('''
      CREATE TABLE IF NOT EXISTS handle_aliases (
        handle_ss_id INTEGER PRIMARY KEY,
        canonical_handle_ss_id INTEGER NOT NULL,
        raw_identifier TEXT NOT NULL,
        normalized_identifier TEXT NOT NULL,
        alias_kind TEXT NOT NULL
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_handle_aliases_canonical '
      'ON handle_aliases(canonical_handle_ss_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_handle_aliases_normalized '
      'ON handle_aliases(normalized_identifier)',
    );
  }

  Future<void> _createChatSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS chats (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT,
        service TEXT,
        is_group INTEGER NOT NULL CHECK (is_group IN (0, 1)),
        last_read_message_at_utc TEXT
      )
    ''');
  }

  Future<void> _addColumnIfMissing(
    String table,
    String columnDefinition,
  ) async {
    final columnName = columnDefinition.split(' ').first;
    final columns = await selectRows('PRAGMA table_info($table)');
    final columnNames = columns.map((row) => row['name']).toSet();
    if (columnNames.contains(columnName)) {
      return;
    }
    await customStatement('ALTER TABLE $table ADD COLUMN $columnDefinition');
  }

  Future<void> _createChatToMessageSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS chat_to_message (
        chat_ss_id INTEGER NOT NULL,
        message_ss_id INTEGER NOT NULL,
        PRIMARY KEY (chat_ss_id, message_ss_id)
      )
    ''');
  }

  Future<void> _createChatToHandleSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS chat_to_handle (
        chat_ss_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL,
        UNIQUE(chat_ss_id, handle_ss_id)
      )
    ''');
  }

  Future<void> _createContactSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS contacts (
        contact_id INTEGER PRIMARY KEY,
        display_name TEXT NOT NULL,
        given_name TEXT,
        family_name TEXT,
        organization TEXT
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_working_contacts_display_name '
      'ON contacts(display_name)',
    );
  }

  Future<void> _createContactToHandleSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS contact_to_handle (
        contact_id INTEGER NOT NULL,
        handle_ss_id INTEGER NOT NULL,
        handle_value TEXT NOT NULL,
        UNIQUE(contact_id, handle_ss_id)
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_to_handle_handle '
      'ON contact_to_handle(handle_ss_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_contact_to_handle_contact '
      'ON contact_to_handle(contact_id)',
    );
  }

  Future<void> _createAttachmentSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS attachments (
        ss_id INTEGER PRIMARY KEY,
        guid TEXT,
        filename TEXT,
        transfer_name TEXT,
        uti TEXT,
        mime_type TEXT,
        total_bytes INTEGER,
        created_at_utc TEXT
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_working_attachments_guid '
      'ON attachments(guid)',
    );
  }

  Future<void> _createMessageToAttachmentSchema() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS message_to_attachment (
        message_ss_id INTEGER NOT NULL,
        attachment_ss_id INTEGER NOT NULL,
        UNIQUE(message_ss_id, attachment_ss_id)
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_working_message_to_attachment_message '
      'ON message_to_attachment(message_ss_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_working_message_to_attachment_attachment '
      'ON message_to_attachment(attachment_ss_id)',
    );
  }
}
