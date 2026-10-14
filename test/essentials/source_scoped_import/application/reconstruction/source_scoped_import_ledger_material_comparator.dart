import 'dart:convert';
import 'dart:typed_data';

import 'package:remember_this_text/essentials/db/app_database_schema_versions.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';

typedef LedgerMaterialSnapshot = Map<String, List<Map<String, Object?>>>;

enum LedgerColumnTreatment { materialValue, operationalUtcProvenance }

final class LedgerColumnSpec {
  const LedgerColumnSpec(
    this.name,
    this.sqliteType, {
    this.notNull = false,
    this.primaryKeyPosition = 0,
    this.defaultValue,
    this.treatment = LedgerColumnTreatment.materialValue,
  });

  final String name;
  final String sqliteType;
  final bool notNull;
  final int primaryKeyPosition;
  final String? defaultValue;
  final LedgerColumnTreatment treatment;
}

final class LedgerIndexSpec {
  const LedgerIndexSpec({
    this.name,
    required this.columns,
    required this.unique,
    required this.origin,
  });

  final String? name;
  final List<String> columns;
  final bool unique;
  final String origin;

  String get signature =>
      '${name ?? '<automatic>'}|${unique ? 1 : 0}|$origin|'
      '${columns.join(',')}';
}

final class LedgerForeignKeySpec {
  const LedgerForeignKeySpec({
    required this.from,
    required this.table,
    required this.to,
  });

  final String from;
  final String table;
  final String to;

  String get signature => '$from->$table.$to|NO ACTION|NO ACTION|NONE';
}

final class LedgerTableSpec {
  const LedgerTableSpec({
    required this.name,
    required this.identityColumns,
    required this.uniqueIdentities,
    required this.columns,
    required this.indexes,
    this.foreignKeys = const <LedgerForeignKeySpec>[],
  });

  final String name;
  final List<String> identityColumns;
  final List<List<String>> uniqueIdentities;
  final List<LedgerColumnSpec> columns;
  final List<LedgerIndexSpec> indexes;
  final List<LedgerForeignKeySpec> foreignKeys;

  List<String> get columnNames => <String>[
    for (final column in columns) column.name,
  ];
}

const _sourceForeignKey = LedgerForeignKeySpec(
  from: 'source_id',
  table: 'source_registry',
  to: 'source_id',
);
const _batchForeignKey = LedgerForeignKeySpec(
  from: 'batch_id',
  table: 'import_batches',
  to: 'batch_id',
);

const sourceScopedImportLedgerTableSpecs = <LedgerTableSpec>[
  LedgerTableSpec(
    name: 'source_registry',
    identityColumns: <String>['source_id'],
    uniqueIdentities: <List<String>>[
      <String>['source_id'],
      <String>['source_key'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('source_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_key', 'TEXT', notNull: true),
      LedgerColumnSpec('source_kind', 'TEXT', notNull: true),
      LedgerColumnSpec('source_label', 'TEXT'),
      LedgerColumnSpec(
        'created_at_utc',
        'TEXT',
        notNull: true,
        treatment: LedgerColumnTreatment.operationalUtcProvenance,
      ),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_key'],
        unique: true,
        origin: 'u',
      ),
    ],
  ),
  LedgerTableSpec(
    name: 'import_batches',
    identityColumns: <String>['batch_id'],
    uniqueIdentities: <List<String>>[
      <String>['batch_id'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('batch_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec(
        'started_at_utc',
        'TEXT',
        notNull: true,
        treatment: LedgerColumnTreatment.operationalUtcProvenance,
      ),
      LedgerColumnSpec(
        'finished_at_utc',
        'TEXT',
        treatment: LedgerColumnTreatment.operationalUtcProvenance,
      ),
      LedgerColumnSpec('notes', 'TEXT'),
    ],
    indexes: <LedgerIndexSpec>[],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey],
  ),
  LedgerTableSpec(
    name: 'messages',
    identityColumns: <String>['ss_id'],
    uniqueIdentities: <List<String>>[
      <String>['ss_id'],
      <String>['source_id', 'source_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('ss_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('guid', 'TEXT', notNull: true),
      LedgerColumnSpec('sender_handle_ss_id', 'INTEGER'),
      LedgerColumnSpec('is_from_me', 'INTEGER', notNull: true),
      LedgerColumnSpec('date_utc', 'TEXT'),
      LedgerColumnSpec('date_read_utc', 'TEXT'),
      LedgerColumnSpec('date_delivered_utc', 'TEXT'),
      LedgerColumnSpec('text', 'TEXT'),
      LedgerColumnSpec('attributed_body_blob', 'BLOB'),
      LedgerColumnSpec('associated_message_guid', 'TEXT'),
      LedgerColumnSpec('raw_item_type', 'INTEGER'),
      LedgerColumnSpec('raw_associated_message_type', 'INTEGER'),
      LedgerColumnSpec('thread_originator_guid', 'TEXT'),
      LedgerColumnSpec('error_code', 'INTEGER'),
      LedgerColumnSpec(
        'is_system_message',
        'INTEGER',
        notNull: true,
        defaultValue: '0',
      ),
      LedgerColumnSpec(
        'has_attributed_body_source',
        'INTEGER',
        notNull: true,
        defaultValue: '0',
      ),
      LedgerColumnSpec(
        'has_message_summary_info',
        'INTEGER',
        notNull: true,
        defaultValue: '0',
      ),
      LedgerColumnSpec(
        'has_payload_data_source',
        'INTEGER',
        notNull: true,
        defaultValue: '0',
      ),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_rowid'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_messages_source_cursor',
        columns: <String>['source_id', 'source_rowid'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_messages_guid',
        columns: <String>['guid'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'handles',
    identityColumns: <String>['ss_id'],
    uniqueIdentities: <List<String>>[
      <String>['ss_id'],
      <String>['source_id', 'source_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('ss_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('id', 'TEXT', notNull: true),
      LedgerColumnSpec('service', 'TEXT'),
      LedgerColumnSpec('is_me', 'INTEGER', notNull: true, defaultValue: '0'),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_rowid'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_handles_source_cursor',
        columns: <String>['source_id', 'source_rowid'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_handles_id',
        columns: <String>['id'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'chats',
    identityColumns: <String>['ss_id'],
    uniqueIdentities: <List<String>>[
      <String>['ss_id'],
      <String>['source_id', 'source_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('ss_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('guid', 'TEXT', notNull: true),
      LedgerColumnSpec('service', 'TEXT'),
      LedgerColumnSpec('group_id', 'TEXT'),
      LedgerColumnSpec('original_group_id', 'TEXT'),
      LedgerColumnSpec('last_read_message_at_utc', 'TEXT'),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_rowid'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_chats_source_cursor',
        columns: <String>['source_id', 'source_rowid'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_chats_guid',
        columns: <String>['guid'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'chat_to_message',
    identityColumns: <String>['ss_id'],
    uniqueIdentities: <List<String>>[
      <String>['ss_id'],
      <String>['source_id', 'source_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('ss_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_chat_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_message_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('chat_ss_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('message_ss_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_rowid'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_chat_to_message_chat',
        columns: <String>['chat_ss_id'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_chat_to_message_message',
        columns: <String>['message_ss_id'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_chat_to_message_source_message_cursor',
        columns: <String>['source_id', 'source_message_rowid'],
        unique: false,
        origin: 'c',
      ),
    ],
  ),
  LedgerTableSpec(
    name: 'chat_to_handle',
    identityColumns: <String>[
      'source_id',
      'source_chat_rowid',
      'source_handle_rowid',
    ],
    uniqueIdentities: <List<String>>[
      <String>['source_id', 'source_chat_rowid', 'source_handle_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_chat_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_handle_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('chat_ss_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('handle_ss_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>[
          'source_id',
          'source_chat_rowid',
          'source_handle_rowid',
        ],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_chat_to_handle_chat',
        columns: <String>['chat_ss_id'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_chat_to_handle_handle',
        columns: <String>['handle_ss_id'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'contacts',
    identityColumns: <String>['ss_id'],
    uniqueIdentities: <List<String>>[
      <String>['ss_id'],
      <String>['source_id', 'source_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('ss_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('display_name', 'TEXT', notNull: true),
      LedgerColumnSpec('first_name', 'TEXT'),
      LedgerColumnSpec('last_name', 'TEXT'),
      LedgerColumnSpec('organization', 'TEXT'),
      LedgerColumnSpec('created_at_utc', 'TEXT'),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_rowid'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_contacts_source_cursor',
        columns: <String>['source_id', 'source_rowid'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_contacts_display_name',
        columns: <String>['display_name'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'contact_channels',
    identityColumns: <String>[
      'source_id',
      'source_contact_rowid',
      'kind',
      'value',
    ],
    uniqueIdentities: <List<String>>[
      <String>['source_id', 'source_contact_rowid', 'kind', 'value'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_contact_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('contact_ss_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('kind', 'TEXT', notNull: true),
      LedgerColumnSpec('value', 'TEXT', notNull: true),
      LedgerColumnSpec('label', 'TEXT'),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_contact_rowid', 'kind', 'value'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_contact_channels_contact',
        columns: <String>['contact_ss_id'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_contact_channels_value',
        columns: <String>['value'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'attachments',
    identityColumns: <String>['ss_id'],
    uniqueIdentities: <List<String>>[
      <String>['ss_id'],
      <String>['source_id', 'source_rowid'],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('ss_id', 'INTEGER', primaryKeyPosition: 1),
      LedgerColumnSpec('source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('guid', 'TEXT'),
      LedgerColumnSpec('filename', 'TEXT'),
      LedgerColumnSpec('transfer_name', 'TEXT'),
      LedgerColumnSpec('uti', 'TEXT'),
      LedgerColumnSpec('mime_type', 'TEXT'),
      LedgerColumnSpec('total_bytes', 'INTEGER'),
      LedgerColumnSpec('created_at_utc', 'TEXT'),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>['source_id', 'source_rowid'],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_attachments_source_cursor',
        columns: <String>['source_id', 'source_rowid'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_attachments_guid',
        columns: <String>['guid'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[_sourceForeignKey, _batchForeignKey],
  ),
  LedgerTableSpec(
    name: 'message_to_attachment',
    identityColumns: <String>[
      'message_source_id',
      'source_message_rowid',
      'attachment_source_id',
      'source_attachment_rowid',
    ],
    uniqueIdentities: <List<String>>[
      <String>[
        'message_source_id',
        'source_message_rowid',
        'attachment_source_id',
        'source_attachment_rowid',
      ],
    ],
    columns: <LedgerColumnSpec>[
      LedgerColumnSpec('message_source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('attachment_source_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_message_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('source_attachment_rowid', 'INTEGER', notNull: true),
      LedgerColumnSpec('message_ss_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('attachment_ss_id', 'INTEGER', notNull: true),
      LedgerColumnSpec('batch_id', 'INTEGER', notNull: true),
    ],
    indexes: <LedgerIndexSpec>[
      LedgerIndexSpec(
        columns: <String>[
          'message_source_id',
          'source_message_rowid',
          'attachment_source_id',
          'source_attachment_rowid',
        ],
        unique: true,
        origin: 'u',
      ),
      LedgerIndexSpec(
        name: 'idx_message_to_attachment_message',
        columns: <String>['message_ss_id'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_message_to_attachment_attachment',
        columns: <String>['attachment_ss_id'],
        unique: false,
        origin: 'c',
      ),
      LedgerIndexSpec(
        name: 'idx_message_to_attachment_source_message_cursor',
        columns: <String>['message_source_id', 'source_message_rowid'],
        unique: false,
        origin: 'c',
      ),
    ],
    foreignKeys: <LedgerForeignKeySpec>[
      LedgerForeignKeySpec(
        from: 'message_source_id',
        table: 'source_registry',
        to: 'source_id',
      ),
      LedgerForeignKeySpec(
        from: 'attachment_source_id',
        table: 'source_registry',
        to: 'source_id',
      ),
      _batchForeignKey,
    ],
  ),
];

final class LedgerMaterialComparison {
  const LedgerMaterialComparison({
    required this.totalDifferenceCount,
    required this.diagnostics,
    required this.diagnosticLimit,
  });

  final int totalDifferenceCount;
  final List<String> diagnostics;
  final int diagnosticLimit;

  bool get isEquivalent => totalDifferenceCount == 0;

  String get description {
    final omitted = totalDifferenceCount - diagnostics.length;
    final omittedSummary = '... $omitted additional difference(s) omitted';
    final limitSummary = 'limit $diagnosticLimit';
    return <String>[
      ...diagnostics,
      if (omitted > 0) '$omittedSummary ($limitSummary)',
    ].join('\n');
  }
}

Future<LedgerMaterialSnapshot> captureSourceScopedImportLedgerSnapshot(
  ImportDatabase ledger, {
  int maximumRowsPerTable = 10000,
}) async {
  if (maximumRowsPerTable < 1) {
    throw ArgumentError.value(
      maximumRowsPerTable,
      'maximumRowsPerTable',
      'must be positive',
    );
  }
  final snapshot = <String, List<Map<String, Object?>>>{};
  for (final spec in sourceScopedImportLedgerTableSpecs) {
    final rows = await ledger.database.query(
      spec.name,
      columns: spec.columnNames,
      orderBy: '${spec.identityColumns.join(', ')} ASC',
      limit: maximumRowsPerTable + 1,
    );
    if (rows.length > maximumRowsPerTable) {
      throw StateError(
        '${spec.name} exceeds the disposable snapshot bound of '
        '$maximumRowsPerTable rows',
      );
    }
    snapshot[spec.name] = rows;
  }
  return snapshot;
}

LedgerMaterialComparison compareSourceScopedImportLedgerMaterial({
  required LedgerMaterialSnapshot expected,
  required LedgerMaterialSnapshot observed,
  int diagnosticLimit = 64,
}) {
  if (diagnosticLimit < 1) {
    throw ArgumentError.value(
      diagnosticLimit,
      'diagnosticLimit',
      'must be positive',
    );
  }
  var differenceCount = 0;
  final diagnostics = <String>[];

  void record(String diagnostic) {
    differenceCount += 1;
    if (diagnostics.length < diagnosticLimit) {
      diagnostics.add(diagnostic);
    }
  }

  _validateSnapshot('expected', expected, record);
  _validateSnapshot('observed', observed, record);

  final declaredTables = <String>{
    for (final spec in sourceScopedImportLedgerTableSpecs) spec.name,
  };
  for (final table in <String>{
    ...expected.keys,
    ...observed.keys,
  }.toList()..sort()) {
    if (!declaredTables.contains(table)) {
      record('snapshot contains unclassified table $table');
    }
  }

  for (final spec in sourceScopedImportLedgerTableSpecs) {
    if (!expected.containsKey(spec.name)) {
      record('${spec.name}: expected table evidence is absent');
    }
    if (!observed.containsKey(spec.name)) {
      record('${spec.name}: observed table evidence is absent');
    }
    if (!expected.containsKey(spec.name) || !observed.containsKey(spec.name)) {
      continue;
    }
    final expectedRows = _indexRows(spec, expected[spec.name]!);
    final observedRows = _indexRows(spec, observed[spec.name]!);
    final allKeys = <String>{
      ...expectedRows.keys,
      ...observedRows.keys,
    }.toList()..sort();
    for (final key in allKeys) {
      final expectedRow = expectedRows[key];
      final observedRow = observedRows[key];
      if (expectedRow == null) {
        record('${spec.name} $key: extra observed row');
        continue;
      }
      if (observedRow == null) {
        record(
          '${spec.name} $key: expected row missing from observed snapshot',
        );
        continue;
      }
      for (final column in spec.columns) {
        final expectedPresent = expectedRow.containsKey(column.name);
        final observedPresent = observedRow.containsKey(column.name);
        final expectedValue = expectedRow[column.name];
        final observedValue = observedRow[column.name];
        final same =
            column.treatment == LedgerColumnTreatment.operationalUtcProvenance
            ? expectedPresent == observedPresent &&
                  (expectedValue == null) == (observedValue == null)
            : expectedPresent == observedPresent &&
                  _valuesEqual(expectedValue, observedValue);
        if (!same) {
          record(
            '${spec.name} $key field{${column.name}}: expected '
            '${_diagnosticValue(expectedPresent, expectedValue)}, observed '
            '${_diagnosticValue(observedPresent, observedValue)}',
          );
        }
      }
    }
  }

  return LedgerMaterialComparison(
    totalDifferenceCount: differenceCount,
    diagnostics: List<String>.unmodifiable(diagnostics),
    diagnosticLimit: diagnosticLimit,
  );
}

Future<List<String>> sourceScopedImportLedgerSchemaDifferences(
  ImportDatabase ledger,
) async {
  final differences = <String>[];
  final versions = await ledger.database.rawQuery('PRAGMA user_version');
  final actualVersion = versions.single['user_version'];
  if (actualVersion != sourceScopedImportSchemaVersion) {
    differences.add(
      'schema version: expected $sourceScopedImportSchemaVersion, '
      'observed $actualVersion',
    );
  }

  final tableRows = await ledger.database.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name ASC",
  );
  final actualTables = tableRows.map((row) => row['name']).toList();
  final expectedTables =
      sourceScopedImportLedgerTableSpecs.map((spec) => spec.name).toList()
        ..sort();
  if (!_listEquals(actualTables, expectedTables)) {
    differences.add(
      'tables: expected ${jsonEncode(expectedTables)}, '
      'observed ${jsonEncode(actualTables)}',
    );
  }

  for (final spec in sourceScopedImportLedgerTableSpecs) {
    final tableInfo = await ledger.database.rawQuery(
      'PRAGMA table_info(${spec.name})',
    );
    if (tableInfo.length != spec.columns.length) {
      differences.add(
        '${spec.name} columns: expected ${spec.columns.length}, '
        'observed ${tableInfo.length}',
      );
    }
    final maximum = tableInfo.length < spec.columns.length
        ? tableInfo.length
        : spec.columns.length;
    for (var index = 0; index < maximum; index += 1) {
      final actual = tableInfo[index];
      final expected = spec.columns[index];
      final actualDefault = actual['dflt_value']?.toString();
      if (actual['name'] != expected.name ||
          actual['type'] != expected.sqliteType ||
          actual['notnull'] != (expected.notNull ? 1 : 0) ||
          actual['pk'] != expected.primaryKeyPosition ||
          actualDefault != expected.defaultValue) {
        differences.add(
          '${spec.name} column[$index]: expected '
          '${expected.name}|${expected.sqliteType}|'
          '${expected.notNull ? 1 : 0}|${expected.primaryKeyPosition}|'
          '${expected.defaultValue}, observed ${actual['name']}|'
          '${actual['type']}|${actual['notnull']}|${actual['pk']}|'
          '$actualDefault',
        );
      }
    }

    final actualIndexes = <String>[];
    final indexRows = await ledger.database.rawQuery(
      'PRAGMA index_list(${spec.name})',
    );
    for (final indexRow in indexRows) {
      final indexName = indexRow['name'].toString();
      final indexInfo = await ledger.database.rawQuery(
        "PRAGMA index_info('$indexName')",
      );
      final columns = indexInfo.map((row) => row['name'].toString()).toList();
      final origin = indexRow['origin'].toString();
      final isAutomatic = origin == 'u';
      actualIndexes.add(
        LedgerIndexSpec(
          name: isAutomatic ? null : indexName,
          columns: columns,
          unique: indexRow['unique'] == 1,
          origin: origin,
        ).signature,
      );
      if (indexRow['partial'] != 0) {
        differences.add('$indexName unexpectedly became a partial index');
      }
    }
    final expectedIndexes =
        spec.indexes.map((index) => index.signature).toList()..sort();
    actualIndexes.sort();
    if (!_listEquals(actualIndexes, expectedIndexes)) {
      differences.add(
        '${spec.name} indexes: expected ${jsonEncode(expectedIndexes)}, '
        'observed ${jsonEncode(actualIndexes)}',
      );
    }

    final foreignKeyRows = await ledger.database.rawQuery(
      'PRAGMA foreign_key_list(${spec.name})',
    );
    final actualForeignKeys = foreignKeyRows.map((row) {
      return '${row['from']}->${row['table']}.${row['to']}|'
          '${row['on_update']}|${row['on_delete']}|${row['match']}';
    }).toList()..sort();
    final expectedForeignKeys =
        spec.foreignKeys.map((foreignKey) => foreignKey.signature).toList()
          ..sort();
    if (!_listEquals(actualForeignKeys, expectedForeignKeys)) {
      differences.add(
        '${spec.name} foreign keys: expected '
        '${jsonEncode(expectedForeignKeys)}, observed '
        '${jsonEncode(actualForeignKeys)}',
      );
    }
  }
  return List<String>.unmodifiable(differences);
}

Map<String, Map<String, Object?>> _indexRows(
  LedgerTableSpec spec,
  List<Map<String, Object?>> rows,
) {
  final indexed = <String, Map<String, Object?>>{};
  for (final row in rows) {
    final key = _identity(spec.identityColumns, row);
    indexed.putIfAbsent(key, () => row);
  }
  return indexed;
}

void _validateSnapshot(
  String side,
  LedgerMaterialSnapshot snapshot,
  void Function(String diagnostic) record,
) {
  final specByName = <String, LedgerTableSpec>{
    for (final spec in sourceScopedImportLedgerTableSpecs) spec.name: spec,
  };
  for (final spec in sourceScopedImportLedgerTableSpecs) {
    final rows = snapshot[spec.name];
    if (rows == null) {
      continue;
    }
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) {
      final row = rows[rowIndex];
      final rowKey = _identity(spec.identityColumns, row);
      final declaredColumns = spec.columnNames.toSet();
      for (final unexpectedColumn
          in row.keys
              .where((column) => !declaredColumns.contains(column))
              .toList()
            ..sort()) {
        record(
          '$side ${spec.name} $rowKey: unclassified field {$unexpectedColumn}',
        );
      }
      for (final column in spec.columns) {
        if (!row.containsKey(column.name)) {
          record('$side ${spec.name} $rowKey: field{${column.name}} absent');
          continue;
        }
        final value = row[column.name];
        if (column.notNull && value == null) {
          record('$side ${spec.name} $rowKey: field{${column.name}} is null');
        }
        if (value != null && !_hasSqliteType(value, column.sqliteType)) {
          record(
            '$side ${spec.name} $rowKey: field{${column.name}} has invalid '
            '${column.sqliteType} evidence ${_diagnosticValue(true, value)}',
          );
        }
        if (column.treatment ==
                LedgerColumnTreatment.operationalUtcProvenance &&
            value != null &&
            !_isUtcTimestamp(value)) {
          record(
            '$side ${spec.name} $rowKey: field{${column.name}} is not '
            'coherent UTC provenance',
          );
        }
      }
      for (final identity in spec.uniqueIdentities) {
        if (identity.any(
          (column) => !row.containsKey(column) || row[column] == null,
        )) {
          record(
            '$side ${spec.name} row[$rowIndex]: invalid identity '
            '${identity.join(',')}',
          );
        }
      }
    }
    for (final identityColumns in spec.uniqueIdentities) {
      final seen = <String>{};
      for (final row in rows) {
        final identity = _identity(identityColumns, row);
        if (!seen.add(identity)) {
          record(
            '$side ${spec.name} $identity: duplicate identity '
            '${identityColumns.join(',')}',
          );
        }
      }
    }
  }

  final sourceRows =
      snapshot['source_registry'] ?? const <Map<String, Object?>>[];
  final sourceIds = <int>{
    for (final row in sourceRows)
      if (row['source_id'] is int) row['source_id']! as int,
  };
  final batchRows =
      snapshot['import_batches'] ?? const <Map<String, Object?>>[];
  final batches = <int, Map<String, Object?>>{
    for (final row in batchRows)
      if (row['batch_id'] is int) row['batch_id']! as int: row,
  };

  for (final row in batchRows) {
    final key = _identity(const <String>['batch_id'], row);
    final sourceId = row['source_id'];
    if (sourceId is int && !sourceIds.contains(sourceId)) {
      record('$side import_batches $key: source_id=$sourceId is unregistered');
    }
    final started = _utcDate(row['started_at_utc']);
    final finished = _utcDate(row['finished_at_utc']);
    if (started != null && finished != null && finished.isBefore(started)) {
      record('$side import_batches $key: finished_at_utc precedes start');
    }
  }

  for (final spec in sourceScopedImportLedgerTableSpecs) {
    if (spec.name == 'source_registry' || spec.name == 'import_batches') {
      continue;
    }
    for (final row in snapshot[spec.name] ?? const <Map<String, Object?>>[]) {
      final key = _identity(spec.identityColumns, row);
      for (final sourceColumn in <String>[
        if (row.containsKey('source_id')) 'source_id',
        if (row.containsKey('message_source_id')) 'message_source_id',
        if (row.containsKey('attachment_source_id')) 'attachment_source_id',
      ]) {
        final sourceId = row[sourceColumn];
        if (sourceId is int && !sourceIds.contains(sourceId)) {
          record(
            '$side ${spec.name} $key: $sourceColumn=$sourceId is '
            'unregistered',
          );
        }
      }
      final batchId = row['batch_id'];
      if (batchId is int) {
        final batch = batches[batchId];
        if (batch == null) {
          record('$side ${spec.name} $key: batch_id=$batchId is missing');
        } else {
          final rowSourceId = row['source_id'] ?? row['message_source_id'];
          if (rowSourceId is int && batch['source_id'] != rowSourceId) {
            record(
              '$side ${spec.name} $key: batch_id=$batchId belongs to '
              'source_id=${batch['source_id']}, not $rowSourceId',
            );
          }
          if (spec.name == 'message_to_attachment') {
            final attachmentSourceId = row['attachment_source_id'];
            if (attachmentSourceId is int &&
                batch['source_id'] != attachmentSourceId) {
              record(
                '$side ${spec.name} $key: batch_id=$batchId belongs to '
                'source_id=${batch['source_id']}, not attachment source '
                '$attachmentSourceId',
              );
            }
          }
        }
      }
      _validatePackedIdentities(side, spec.name, key, row, record);
    }
  }

  final entityIds = <String, Set<int>>{
    for (final table in const <String>[
      'messages',
      'handles',
      'chats',
      'contacts',
      'attachments',
    ])
      table: <int>{
        for (final row in snapshot[table] ?? const <Map<String, Object?>>[])
          if (row['ss_id'] is int) row['ss_id']! as int,
      },
  };
  void requireEndpoint(
    String table,
    Map<String, Object?> row,
    List<String> identity,
    String column,
    String target,
  ) {
    final value = row[column];
    if (value is int && !entityIds[target]!.contains(value)) {
      record(
        '$side $table ${_identity(identity, row)}: '
        '$column=$value has no $target endpoint',
      );
    }
  }

  for (final row
      in snapshot['chat_to_message'] ?? const <Map<String, Object?>>[]) {
    requireEndpoint(
      'chat_to_message',
      row,
      specByName['chat_to_message']!.identityColumns,
      'chat_ss_id',
      'chats',
    );
    requireEndpoint(
      'chat_to_message',
      row,
      specByName['chat_to_message']!.identityColumns,
      'message_ss_id',
      'messages',
    );
  }
  for (final row
      in snapshot['chat_to_handle'] ?? const <Map<String, Object?>>[]) {
    requireEndpoint(
      'chat_to_handle',
      row,
      specByName['chat_to_handle']!.identityColumns,
      'chat_ss_id',
      'chats',
    );
    requireEndpoint(
      'chat_to_handle',
      row,
      specByName['chat_to_handle']!.identityColumns,
      'handle_ss_id',
      'handles',
    );
  }
  for (final row
      in snapshot['contact_channels'] ?? const <Map<String, Object?>>[]) {
    requireEndpoint(
      'contact_channels',
      row,
      specByName['contact_channels']!.identityColumns,
      'contact_ss_id',
      'contacts',
    );
  }
  for (final row
      in snapshot['message_to_attachment'] ?? const <Map<String, Object?>>[]) {
    requireEndpoint(
      'message_to_attachment',
      row,
      specByName['message_to_attachment']!.identityColumns,
      'message_ss_id',
      'messages',
    );
    requireEndpoint(
      'message_to_attachment',
      row,
      specByName['message_to_attachment']!.identityColumns,
      'attachment_ss_id',
      'attachments',
    );
  }
}

void _validatePackedIdentities(
  String side,
  String table,
  String key,
  Map<String, Object?> row,
  void Function(String diagnostic) record,
) {
  void expectPacked(
    String packedColumn,
    String sourceColumn,
    String rowColumn,
  ) {
    final packed = row[packedColumn];
    final sourceId = row[sourceColumn];
    final sourceRowId = row[rowColumn];
    if (packed is! int || sourceId is! int || sourceRowId is! int) {
      return;
    }
    try {
      final expected = SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceRowId,
      );
      if (packed != expected) {
        record(
          '$side $table $key: $packedColumn=$packed does not encode '
          '$sourceColumn=$sourceId/$rowColumn=$sourceRowId',
        );
      }
    } on RangeError {
      record(
        '$side $table $key: $sourceColumn/$rowColumn exceeds packed '
        'identity bounds',
      );
    }
  }

  if (row.containsKey('ss_id') &&
      row.containsKey('source_id') &&
      row.containsKey('source_rowid')) {
    expectPacked('ss_id', 'source_id', 'source_rowid');
  }
  if (table == 'chat_to_message') {
    expectPacked('chat_ss_id', 'source_id', 'source_chat_rowid');
    expectPacked('message_ss_id', 'source_id', 'source_message_rowid');
  } else if (table == 'chat_to_handle') {
    expectPacked('chat_ss_id', 'source_id', 'source_chat_rowid');
    expectPacked('handle_ss_id', 'source_id', 'source_handle_rowid');
  } else if (table == 'contact_channels') {
    expectPacked('contact_ss_id', 'source_id', 'source_contact_rowid');
  } else if (table == 'message_to_attachment') {
    expectPacked('message_ss_id', 'message_source_id', 'source_message_rowid');
    expectPacked(
      'attachment_ss_id',
      'attachment_source_id',
      'source_attachment_rowid',
    );
  } else if (table == 'messages' && row['sender_handle_ss_id'] is int) {
    final sender = row['sender_handle_ss_id']! as int;
    final sourceId = row['source_id'];
    try {
      if (sourceId is int &&
          SourceScopedRowKey.unpackSourceId(sender) != sourceId) {
        record(
          '$side messages $key: sender_handle_ss_id=$sender belongs to a '
          'different source',
        );
      }
    } on RangeError {
      record(
        '$side messages $key: sender_handle_ss_id=$sender is not a valid '
        'packed identity',
      );
    }
  }
}

String _identity(List<String> columns, Map<String, Object?> row) {
  return 'key{${columns.map((column) {
    return '$column=${_diagnosticValue(row.containsKey(column), row[column])}';
  }).join(',')}}';
}

bool _valuesEqual(Object? left, Object? right) {
  if (left is List<int> && right is List<int>) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}

bool _hasSqliteType(Object value, String sqliteType) {
  return switch (sqliteType) {
    'INTEGER' => value is int,
    'TEXT' => value is String,
    'BLOB' => value is Uint8List || value is List<int>,
    _ => false,
  };
}

bool _isUtcTimestamp(Object value) {
  if (value is! String) {
    return false;
  }
  final parsed = DateTime.tryParse(value);
  return parsed != null &&
      parsed.isUtc &&
      (value.endsWith('Z') || value.endsWith('+00:00'));
}

DateTime? _utcDate(Object? value) {
  if (value is! String || !_isUtcTimestamp(value)) {
    return null;
  }
  return DateTime.tryParse(value);
}

String _diagnosticValue(bool present, Object? value) {
  if (!present) {
    return '<absent>';
  }
  if (value == null) {
    return '<null>';
  }
  if (value is List<int>) {
    final prefix = value.take(24).map((byte) {
      return byte.toRadixString(16).padLeft(2, '0');
    }).join();
    return '<blob length=${value.length} hex=$prefix'
        '${value.length > 24 ? '…' : ''}>';
  }
  final encoded = jsonEncode(value);
  const maximumLength = 160;
  return encoded.length <= maximumLength
      ? encoded
      : '${encoded.substring(0, maximumLength)}…';
}

bool _listEquals(List<Object?> left, List<Object?> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
