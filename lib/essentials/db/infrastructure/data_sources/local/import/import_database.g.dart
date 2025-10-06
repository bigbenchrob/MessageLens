// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_database.dart';

// ignore_for_file: type=lint
class $ImportSchemaMigrationsTable extends ImportSchemaMigrations
    with TableInfo<$ImportSchemaMigrationsTable, ImportSchemaMigration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportSchemaMigrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtUtcMeta = const VerificationMeta(
    'appliedAtUtc',
  );
  @override
  late final GeneratedColumn<String> appliedAtUtc = GeneratedColumn<String>(
    'applied_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [version, appliedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_migrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportSchemaMigration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('applied_at_utc')) {
      context.handle(
        _appliedAtUtcMeta,
        appliedAtUtc.isAcceptableOrUnknown(
          data['applied_at_utc']!,
          _appliedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ImportSchemaMigration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportSchemaMigration(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      appliedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applied_at_utc'],
      )!,
    );
  }

  @override
  $ImportSchemaMigrationsTable createAlias(String alias) {
    return $ImportSchemaMigrationsTable(attachedDatabase, alias);
  }
}

class ImportSchemaMigration extends DataClass
    implements Insertable<ImportSchemaMigration> {
  final int version;
  final String appliedAtUtc;
  const ImportSchemaMigration({
    required this.version,
    required this.appliedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version'] = Variable<int>(version);
    map['applied_at_utc'] = Variable<String>(appliedAtUtc);
    return map;
  }

  ImportSchemaMigrationsCompanion toCompanion(bool nullToAbsent) {
    return ImportSchemaMigrationsCompanion(
      version: Value(version),
      appliedAtUtc: Value(appliedAtUtc),
    );
  }

  factory ImportSchemaMigration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportSchemaMigration(
      version: serializer.fromJson<int>(json['version']),
      appliedAtUtc: serializer.fromJson<String>(json['appliedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int>(version),
      'appliedAtUtc': serializer.toJson<String>(appliedAtUtc),
    };
  }

  ImportSchemaMigration copyWith({int? version, String? appliedAtUtc}) =>
      ImportSchemaMigration(
        version: version ?? this.version,
        appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
      );
  ImportSchemaMigration copyWithCompanion(
    ImportSchemaMigrationsCompanion data,
  ) {
    return ImportSchemaMigration(
      version: data.version.present ? data.version.value : this.version,
      appliedAtUtc: data.appliedAtUtc.present
          ? data.appliedAtUtc.value
          : this.appliedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportSchemaMigration(')
          ..write('version: $version, ')
          ..write('appliedAtUtc: $appliedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, appliedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportSchemaMigration &&
          other.version == this.version &&
          other.appliedAtUtc == this.appliedAtUtc);
}

class ImportSchemaMigrationsCompanion
    extends UpdateCompanion<ImportSchemaMigration> {
  final Value<int> version;
  final Value<String> appliedAtUtc;
  final Value<int> rowid;
  const ImportSchemaMigrationsCompanion({
    this.version = const Value.absent(),
    this.appliedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportSchemaMigrationsCompanion.insert({
    required int version,
    required String appliedAtUtc,
    this.rowid = const Value.absent(),
  }) : version = Value(version),
       appliedAtUtc = Value(appliedAtUtc);
  static Insertable<ImportSchemaMigration> custom({
    Expression<int>? version,
    Expression<String>? appliedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (appliedAtUtc != null) 'applied_at_utc': appliedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportSchemaMigrationsCompanion copyWith({
    Value<int>? version,
    Value<String>? appliedAtUtc,
    Value<int>? rowid,
  }) {
    return ImportSchemaMigrationsCompanion(
      version: version ?? this.version,
      appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (appliedAtUtc.present) {
      map['applied_at_utc'] = Variable<String>(appliedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportSchemaMigrationsCompanion(')
          ..write('version: $version, ')
          ..write('appliedAtUtc: $appliedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<String> startedAtUtc = GeneratedColumn<String>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtUtcMeta = const VerificationMeta(
    'finishedAtUtc',
  );
  @override
  late final GeneratedColumn<String> finishedAtUtc = GeneratedColumn<String>(
    'finished_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceChatDbMeta = const VerificationMeta(
    'sourceChatDb',
  );
  @override
  late final GeneratedColumn<String> sourceChatDb = GeneratedColumn<String>(
    'source_chat_db',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceAddressbookMeta = const VerificationMeta(
    'sourceAddressbook',
  );
  @override
  late final GeneratedColumn<String> sourceAddressbook =
      GeneratedColumn<String>(
        'source_addressbook',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hostInfoJsonMeta = const VerificationMeta(
    'hostInfoJson',
  );
  @override
  late final GeneratedColumn<String> hostInfoJson = GeneratedColumn<String>(
    'host_info_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAtUtc,
    finishedAtUtc,
    sourceChatDb,
    sourceAddressbook,
    hostInfoJson,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('finished_at_utc')) {
      context.handle(
        _finishedAtUtcMeta,
        finishedAtUtc.isAcceptableOrUnknown(
          data['finished_at_utc']!,
          _finishedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('source_chat_db')) {
      context.handle(
        _sourceChatDbMeta,
        sourceChatDb.isAcceptableOrUnknown(
          data['source_chat_db']!,
          _sourceChatDbMeta,
        ),
      );
    }
    if (data.containsKey('source_addressbook')) {
      context.handle(
        _sourceAddressbookMeta,
        sourceAddressbook.isAcceptableOrUnknown(
          data['source_addressbook']!,
          _sourceAddressbookMeta,
        ),
      );
    }
    if (data.containsKey('host_info_json')) {
      context.handle(
        _hostInfoJsonMeta,
        hostInfoJson.isAcceptableOrUnknown(
          data['host_info_json']!,
          _hostInfoJsonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at_utc'],
      )!,
      finishedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finished_at_utc'],
      ),
      sourceChatDb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_chat_db'],
      ),
      sourceAddressbook: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_addressbook'],
      ),
      hostInfoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_info_json'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatche extends DataClass implements Insertable<ImportBatche> {
  final int id;
  final String startedAtUtc;
  final String? finishedAtUtc;
  final String? sourceChatDb;
  final String? sourceAddressbook;
  final String? hostInfoJson;
  final String? notes;
  const ImportBatche({
    required this.id,
    required this.startedAtUtc,
    this.finishedAtUtc,
    this.sourceChatDb,
    this.sourceAddressbook,
    this.hostInfoJson,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at_utc'] = Variable<String>(startedAtUtc);
    if (!nullToAbsent || finishedAtUtc != null) {
      map['finished_at_utc'] = Variable<String>(finishedAtUtc);
    }
    if (!nullToAbsent || sourceChatDb != null) {
      map['source_chat_db'] = Variable<String>(sourceChatDb);
    }
    if (!nullToAbsent || sourceAddressbook != null) {
      map['source_addressbook'] = Variable<String>(sourceAddressbook);
    }
    if (!nullToAbsent || hostInfoJson != null) {
      map['host_info_json'] = Variable<String>(hostInfoJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      startedAtUtc: Value(startedAtUtc),
      finishedAtUtc: finishedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAtUtc),
      sourceChatDb: sourceChatDb == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceChatDb),
      sourceAddressbook: sourceAddressbook == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAddressbook),
      hostInfoJson: hostInfoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(hostInfoJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ImportBatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatche(
      id: serializer.fromJson<int>(json['id']),
      startedAtUtc: serializer.fromJson<String>(json['startedAtUtc']),
      finishedAtUtc: serializer.fromJson<String?>(json['finishedAtUtc']),
      sourceChatDb: serializer.fromJson<String?>(json['sourceChatDb']),
      sourceAddressbook: serializer.fromJson<String?>(
        json['sourceAddressbook'],
      ),
      hostInfoJson: serializer.fromJson<String?>(json['hostInfoJson']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAtUtc': serializer.toJson<String>(startedAtUtc),
      'finishedAtUtc': serializer.toJson<String?>(finishedAtUtc),
      'sourceChatDb': serializer.toJson<String?>(sourceChatDb),
      'sourceAddressbook': serializer.toJson<String?>(sourceAddressbook),
      'hostInfoJson': serializer.toJson<String?>(hostInfoJson),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ImportBatche copyWith({
    int? id,
    String? startedAtUtc,
    Value<String?> finishedAtUtc = const Value.absent(),
    Value<String?> sourceChatDb = const Value.absent(),
    Value<String?> sourceAddressbook = const Value.absent(),
    Value<String?> hostInfoJson = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ImportBatche(
    id: id ?? this.id,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    finishedAtUtc: finishedAtUtc.present
        ? finishedAtUtc.value
        : this.finishedAtUtc,
    sourceChatDb: sourceChatDb.present ? sourceChatDb.value : this.sourceChatDb,
    sourceAddressbook: sourceAddressbook.present
        ? sourceAddressbook.value
        : this.sourceAddressbook,
    hostInfoJson: hostInfoJson.present ? hostInfoJson.value : this.hostInfoJson,
    notes: notes.present ? notes.value : this.notes,
  );
  ImportBatche copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatche(
      id: data.id.present ? data.id.value : this.id,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      finishedAtUtc: data.finishedAtUtc.present
          ? data.finishedAtUtc.value
          : this.finishedAtUtc,
      sourceChatDb: data.sourceChatDb.present
          ? data.sourceChatDb.value
          : this.sourceChatDb,
      sourceAddressbook: data.sourceAddressbook.present
          ? data.sourceAddressbook.value
          : this.sourceAddressbook,
      hostInfoJson: data.hostInfoJson.present
          ? data.hostInfoJson.value
          : this.hostInfoJson,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatche(')
          ..write('id: $id, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('finishedAtUtc: $finishedAtUtc, ')
          ..write('sourceChatDb: $sourceChatDb, ')
          ..write('sourceAddressbook: $sourceAddressbook, ')
          ..write('hostInfoJson: $hostInfoJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAtUtc,
    finishedAtUtc,
    sourceChatDb,
    sourceAddressbook,
    hostInfoJson,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatche &&
          other.id == this.id &&
          other.startedAtUtc == this.startedAtUtc &&
          other.finishedAtUtc == this.finishedAtUtc &&
          other.sourceChatDb == this.sourceChatDb &&
          other.sourceAddressbook == this.sourceAddressbook &&
          other.hostInfoJson == this.hostInfoJson &&
          other.notes == this.notes);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatche> {
  final Value<int> id;
  final Value<String> startedAtUtc;
  final Value<String?> finishedAtUtc;
  final Value<String?> sourceChatDb;
  final Value<String?> sourceAddressbook;
  final Value<String?> hostInfoJson;
  final Value<String?> notes;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.finishedAtUtc = const Value.absent(),
    this.sourceChatDb = const Value.absent(),
    this.sourceAddressbook = const Value.absent(),
    this.hostInfoJson = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    this.id = const Value.absent(),
    required String startedAtUtc,
    this.finishedAtUtc = const Value.absent(),
    this.sourceChatDb = const Value.absent(),
    this.sourceAddressbook = const Value.absent(),
    this.hostInfoJson = const Value.absent(),
    this.notes = const Value.absent(),
  }) : startedAtUtc = Value(startedAtUtc);
  static Insertable<ImportBatche> custom({
    Expression<int>? id,
    Expression<String>? startedAtUtc,
    Expression<String>? finishedAtUtc,
    Expression<String>? sourceChatDb,
    Expression<String>? sourceAddressbook,
    Expression<String>? hostInfoJson,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (finishedAtUtc != null) 'finished_at_utc': finishedAtUtc,
      if (sourceChatDb != null) 'source_chat_db': sourceChatDb,
      if (sourceAddressbook != null) 'source_addressbook': sourceAddressbook,
      if (hostInfoJson != null) 'host_info_json': hostInfoJson,
      if (notes != null) 'notes': notes,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<int>? id,
    Value<String>? startedAtUtc,
    Value<String?>? finishedAtUtc,
    Value<String?>? sourceChatDb,
    Value<String?>? sourceAddressbook,
    Value<String?>? hostInfoJson,
    Value<String?>? notes,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      finishedAtUtc: finishedAtUtc ?? this.finishedAtUtc,
      sourceChatDb: sourceChatDb ?? this.sourceChatDb,
      sourceAddressbook: sourceAddressbook ?? this.sourceAddressbook,
      hostInfoJson: hostInfoJson ?? this.hostInfoJson,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<String>(startedAtUtc.value);
    }
    if (finishedAtUtc.present) {
      map['finished_at_utc'] = Variable<String>(finishedAtUtc.value);
    }
    if (sourceChatDb.present) {
      map['source_chat_db'] = Variable<String>(sourceChatDb.value);
    }
    if (sourceAddressbook.present) {
      map['source_addressbook'] = Variable<String>(sourceAddressbook.value);
    }
    if (hostInfoJson.present) {
      map['host_info_json'] = Variable<String>(hostInfoJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('finishedAtUtc: $finishedAtUtc, ')
          ..write('sourceChatDb: $sourceChatDb, ')
          ..write('sourceAddressbook: $sourceAddressbook, ')
          ..write('hostInfoJson: $hostInfoJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ImportSourceFilesTable extends ImportSourceFiles
    with TableInfo<$ImportSourceFilesTable, ImportSourceFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportSourceFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256HexMeta = const VerificationMeta(
    'sha256Hex',
  );
  @override
  late final GeneratedColumn<String> sha256Hex = GeneratedColumn<String>(
    'sha256_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtimeUtcMeta = const VerificationMeta(
    'mtimeUtc',
  );
  @override
  late final GeneratedColumn<String> mtimeUtc = GeneratedColumn<String>(
    'mtime_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    path,
    sha256Hex,
    sizeBytes,
    mtimeUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportSourceFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('sha256_hex')) {
      context.handle(
        _sha256HexMeta,
        sha256Hex.isAcceptableOrUnknown(data['sha256_hex']!, _sha256HexMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('mtime_utc')) {
      context.handle(
        _mtimeUtcMeta,
        mtimeUtc.isAcceptableOrUnknown(data['mtime_utc']!, _mtimeUtcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {path, sha256Hex},
  ];
  @override
  ImportSourceFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportSourceFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sha256Hex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256_hex'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      mtimeUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mtime_utc'],
      ),
    );
  }

  @override
  $ImportSourceFilesTable createAlias(String alias) {
    return $ImportSourceFilesTable(attachedDatabase, alias);
  }
}

class ImportSourceFile extends DataClass
    implements Insertable<ImportSourceFile> {
  final int id;
  final int batchId;
  final String path;
  final String? sha256Hex;
  final int? sizeBytes;
  final String? mtimeUtc;
  const ImportSourceFile({
    required this.id,
    required this.batchId,
    required this.path,
    this.sha256Hex,
    this.sizeBytes,
    this.mtimeUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<int>(batchId);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || sha256Hex != null) {
      map['sha256_hex'] = Variable<String>(sha256Hex);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || mtimeUtc != null) {
      map['mtime_utc'] = Variable<String>(mtimeUtc);
    }
    return map;
  }

  ImportSourceFilesCompanion toCompanion(bool nullToAbsent) {
    return ImportSourceFilesCompanion(
      id: Value(id),
      batchId: Value(batchId),
      path: Value(path),
      sha256Hex: sha256Hex == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256Hex),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      mtimeUtc: mtimeUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(mtimeUtc),
    );
  }

  factory ImportSourceFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportSourceFile(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int>(json['batchId']),
      path: serializer.fromJson<String>(json['path']),
      sha256Hex: serializer.fromJson<String?>(json['sha256Hex']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      mtimeUtc: serializer.fromJson<String?>(json['mtimeUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int>(batchId),
      'path': serializer.toJson<String>(path),
      'sha256Hex': serializer.toJson<String?>(sha256Hex),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'mtimeUtc': serializer.toJson<String?>(mtimeUtc),
    };
  }

  ImportSourceFile copyWith({
    int? id,
    int? batchId,
    String? path,
    Value<String?> sha256Hex = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> mtimeUtc = const Value.absent(),
  }) => ImportSourceFile(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    path: path ?? this.path,
    sha256Hex: sha256Hex.present ? sha256Hex.value : this.sha256Hex,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    mtimeUtc: mtimeUtc.present ? mtimeUtc.value : this.mtimeUtc,
  );
  ImportSourceFile copyWithCompanion(ImportSourceFilesCompanion data) {
    return ImportSourceFile(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      path: data.path.present ? data.path.value : this.path,
      sha256Hex: data.sha256Hex.present ? data.sha256Hex.value : this.sha256Hex,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      mtimeUtc: data.mtimeUtc.present ? data.mtimeUtc.value : this.mtimeUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportSourceFile(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('path: $path, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mtimeUtc: $mtimeUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, batchId, path, sha256Hex, sizeBytes, mtimeUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportSourceFile &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.path == this.path &&
          other.sha256Hex == this.sha256Hex &&
          other.sizeBytes == this.sizeBytes &&
          other.mtimeUtc == this.mtimeUtc);
}

class ImportSourceFilesCompanion extends UpdateCompanion<ImportSourceFile> {
  final Value<int> id;
  final Value<int> batchId;
  final Value<String> path;
  final Value<String?> sha256Hex;
  final Value<int?> sizeBytes;
  final Value<String?> mtimeUtc;
  const ImportSourceFilesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.path = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.mtimeUtc = const Value.absent(),
  });
  ImportSourceFilesCompanion.insert({
    this.id = const Value.absent(),
    required int batchId,
    required String path,
    this.sha256Hex = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.mtimeUtc = const Value.absent(),
  }) : batchId = Value(batchId),
       path = Value(path);
  static Insertable<ImportSourceFile> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<String>? path,
    Expression<String>? sha256Hex,
    Expression<int>? sizeBytes,
    Expression<String>? mtimeUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (path != null) 'path': path,
      if (sha256Hex != null) 'sha256_hex': sha256Hex,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (mtimeUtc != null) 'mtime_utc': mtimeUtc,
    });
  }

  ImportSourceFilesCompanion copyWith({
    Value<int>? id,
    Value<int>? batchId,
    Value<String>? path,
    Value<String?>? sha256Hex,
    Value<int?>? sizeBytes,
    Value<String?>? mtimeUtc,
  }) {
    return ImportSourceFilesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      path: path ?? this.path,
      sha256Hex: sha256Hex ?? this.sha256Hex,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      mtimeUtc: mtimeUtc ?? this.mtimeUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sha256Hex.present) {
      map['sha256_hex'] = Variable<String>(sha256Hex.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (mtimeUtc.present) {
      map['mtime_utc'] = Variable<String>(mtimeUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportSourceFilesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('path: $path, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('mtimeUtc: $mtimeUtc')
          ..write(')'))
        .toString();
  }
}

class $ImportLogsTable extends ImportLogs
    with TableInfo<$ImportLogsTable, ImportLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<String> atUtc = GeneratedColumn<String>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK(level IN (\'debug\',\'info\',\'warn\',\'error\'))',
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextJsonMeta = const VerificationMeta(
    'contextJson',
  );
  @override
  late final GeneratedColumn<String> contextJson = GeneratedColumn<String>(
    'context_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    atUtc,
    level,
    message,
    contextJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('context_json')) {
      context.handle(
        _contextJsonMeta,
        contextJson.isAcceptableOrUnknown(
          data['context_json']!,
          _contextJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at_utc'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      contextJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_json'],
      ),
    );
  }

  @override
  $ImportLogsTable createAlias(String alias) {
    return $ImportLogsTable(attachedDatabase, alias);
  }
}

class ImportLog extends DataClass implements Insertable<ImportLog> {
  final int id;
  final int? batchId;
  final String atUtc;
  final String level;
  final String message;
  final String? contextJson;
  const ImportLog({
    required this.id,
    this.batchId,
    required this.atUtc,
    required this.level,
    required this.message,
    this.contextJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    map['at_utc'] = Variable<String>(atUtc);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || contextJson != null) {
      map['context_json'] = Variable<String>(contextJson);
    }
    return map;
  }

  ImportLogsCompanion toCompanion(bool nullToAbsent) {
    return ImportLogsCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      atUtc: Value(atUtc),
      level: Value(level),
      message: Value(message),
      contextJson: contextJson == null && nullToAbsent
          ? const Value.absent()
          : Value(contextJson),
    );
  }

  factory ImportLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportLog(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      atUtc: serializer.fromJson<String>(json['atUtc']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      contextJson: serializer.fromJson<String?>(json['contextJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int?>(batchId),
      'atUtc': serializer.toJson<String>(atUtc),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'contextJson': serializer.toJson<String?>(contextJson),
    };
  }

  ImportLog copyWith({
    int? id,
    Value<int?> batchId = const Value.absent(),
    String? atUtc,
    String? level,
    String? message,
    Value<String?> contextJson = const Value.absent(),
  }) => ImportLog(
    id: id ?? this.id,
    batchId: batchId.present ? batchId.value : this.batchId,
    atUtc: atUtc ?? this.atUtc,
    level: level ?? this.level,
    message: message ?? this.message,
    contextJson: contextJson.present ? contextJson.value : this.contextJson,
  );
  ImportLog copyWithCompanion(ImportLogsCompanion data) {
    return ImportLog(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      contextJson: data.contextJson.present
          ? data.contextJson.value
          : this.contextJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportLog(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('atUtc: $atUtc, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('contextJson: $contextJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, batchId, atUtc, level, message, contextJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportLog &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.atUtc == this.atUtc &&
          other.level == this.level &&
          other.message == this.message &&
          other.contextJson == this.contextJson);
}

class ImportLogsCompanion extends UpdateCompanion<ImportLog> {
  final Value<int> id;
  final Value<int?> batchId;
  final Value<String> atUtc;
  final Value<String> level;
  final Value<String> message;
  final Value<String?> contextJson;
  const ImportLogsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.atUtc = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.contextJson = const Value.absent(),
  });
  ImportLogsCompanion.insert({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    required String atUtc,
    required String level,
    required String message,
    this.contextJson = const Value.absent(),
  }) : atUtc = Value(atUtc),
       level = Value(level),
       message = Value(message);
  static Insertable<ImportLog> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<String>? atUtc,
    Expression<String>? level,
    Expression<String>? message,
    Expression<String>? contextJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (atUtc != null) 'at_utc': atUtc,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (contextJson != null) 'context_json': contextJson,
    });
  }

  ImportLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? batchId,
    Value<String>? atUtc,
    Value<String>? level,
    Value<String>? message,
    Value<String?>? contextJson,
  }) {
    return ImportLogsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      atUtc: atUtc ?? this.atUtc,
      level: level ?? this.level,
      message: message ?? this.message,
      contextJson: contextJson ?? this.contextJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<String>(atUtc.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (contextJson.present) {
      map['context_json'] = Variable<String>(contextJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportLogsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('atUtc: $atUtc, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('contextJson: $contextJson')
          ..write(')'))
        .toString();
  }
}

class $ImportContactsTable extends ImportContacts
    with TableInfo<$ImportContactsTable, ImportContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _zPkMeta = const VerificationMeta('zPk');
  @override
  late final GeneratedColumn<int> zPk = GeneratedColumn<int>(
    'Z_PK',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _givenNameMeta = const VerificationMeta(
    'givenName',
  );
  @override
  late final GeneratedColumn<String> givenName = GeneratedColumn<String>(
    'given_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyNameMeta = const VerificationMeta(
    'familyName',
  );
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
    'family_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  @override
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOrganizationMeta = const VerificationMeta(
    'isOrganization',
  );
  @override
  late final GeneratedColumn<bool> isOrganization = GeneratedColumn<bool>(
    'is_organization',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_organization" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    zPk,
    displayName,
    givenName,
    familyName,
    organization,
    isOrganization,
    createdAtUtc,
    updatedAtUtc,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Z_PK')) {
      context.handle(
        _zPkMeta,
        zPk.isAcceptableOrUnknown(data['Z_PK']!, _zPkMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('given_name')) {
      context.handle(
        _givenNameMeta,
        givenName.isAcceptableOrUnknown(data['given_name']!, _givenNameMeta),
      );
    }
    if (data.containsKey('family_name')) {
      context.handle(
        _familyNameMeta,
        familyName.isAcceptableOrUnknown(data['family_name']!, _familyNameMeta),
      );
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    }
    if (data.containsKey('is_organization')) {
      context.handle(
        _isOrganizationMeta,
        isOrganization.isAcceptableOrUnknown(
          data['is_organization']!,
          _isOrganizationMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {zPk};
  @override
  ImportContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportContact(
      zPk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}Z_PK'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      givenName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}given_name'],
      ),
      familyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_name'],
      ),
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      ),
      isOrganization: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_organization'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
    );
  }

  @override
  $ImportContactsTable createAlias(String alias) {
    return $ImportContactsTable(attachedDatabase, alias);
  }
}

class ImportContact extends DataClass implements Insertable<ImportContact> {
  final int zPk;
  final String? displayName;
  final String? givenName;
  final String? familyName;
  final String? organization;
  final bool isOrganization;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  final int batchId;
  const ImportContact({
    required this.zPk,
    this.displayName,
    this.givenName,
    this.familyName,
    this.organization,
    required this.isOrganization,
    this.createdAtUtc,
    this.updatedAtUtc,
    required this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Z_PK'] = Variable<int>(zPk);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || givenName != null) {
      map['given_name'] = Variable<String>(givenName);
    }
    if (!nullToAbsent || familyName != null) {
      map['family_name'] = Variable<String>(familyName);
    }
    if (!nullToAbsent || organization != null) {
      map['organization'] = Variable<String>(organization);
    }
    map['is_organization'] = Variable<bool>(isOrganization);
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    }
    map['batch_id'] = Variable<int>(batchId);
    return map;
  }

  ImportContactsCompanion toCompanion(bool nullToAbsent) {
    return ImportContactsCompanion(
      zPk: Value(zPk),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      givenName: givenName == null && nullToAbsent
          ? const Value.absent()
          : Value(givenName),
      familyName: familyName == null && nullToAbsent
          ? const Value.absent()
          : Value(familyName),
      organization: organization == null && nullToAbsent
          ? const Value.absent()
          : Value(organization),
      isOrganization: Value(isOrganization),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtUtc),
      batchId: Value(batchId),
    );
  }

  factory ImportContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportContact(
      zPk: serializer.fromJson<int>(json['zPk']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      givenName: serializer.fromJson<String?>(json['givenName']),
      familyName: serializer.fromJson<String?>(json['familyName']),
      organization: serializer.fromJson<String?>(json['organization']),
      isOrganization: serializer.fromJson<bool>(json['isOrganization']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
      batchId: serializer.fromJson<int>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'zPk': serializer.toJson<int>(zPk),
      'displayName': serializer.toJson<String?>(displayName),
      'givenName': serializer.toJson<String?>(givenName),
      'familyName': serializer.toJson<String?>(familyName),
      'organization': serializer.toJson<String?>(organization),
      'isOrganization': serializer.toJson<bool>(isOrganization),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
      'batchId': serializer.toJson<int>(batchId),
    };
  }

  ImportContact copyWith({
    int? zPk,
    Value<String?> displayName = const Value.absent(),
    Value<String?> givenName = const Value.absent(),
    Value<String?> familyName = const Value.absent(),
    Value<String?> organization = const Value.absent(),
    bool? isOrganization,
    Value<String?> createdAtUtc = const Value.absent(),
    Value<String?> updatedAtUtc = const Value.absent(),
    int? batchId,
  }) => ImportContact(
    zPk: zPk ?? this.zPk,
    displayName: displayName.present ? displayName.value : this.displayName,
    givenName: givenName.present ? givenName.value : this.givenName,
    familyName: familyName.present ? familyName.value : this.familyName,
    organization: organization.present ? organization.value : this.organization,
    isOrganization: isOrganization ?? this.isOrganization,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
    batchId: batchId ?? this.batchId,
  );
  ImportContact copyWithCompanion(ImportContactsCompanion data) {
    return ImportContact(
      zPk: data.zPk.present ? data.zPk.value : this.zPk,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      givenName: data.givenName.present ? data.givenName.value : this.givenName,
      familyName: data.familyName.present
          ? data.familyName.value
          : this.familyName,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      isOrganization: data.isOrganization.present
          ? data.isOrganization.value
          : this.isOrganization,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportContact(')
          ..write('zPk: $zPk, ')
          ..write('displayName: $displayName, ')
          ..write('givenName: $givenName, ')
          ..write('familyName: $familyName, ')
          ..write('organization: $organization, ')
          ..write('isOrganization: $isOrganization, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    zPk,
    displayName,
    givenName,
    familyName,
    organization,
    isOrganization,
    createdAtUtc,
    updatedAtUtc,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportContact &&
          other.zPk == this.zPk &&
          other.displayName == this.displayName &&
          other.givenName == this.givenName &&
          other.familyName == this.familyName &&
          other.organization == this.organization &&
          other.isOrganization == this.isOrganization &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.batchId == this.batchId);
}

class ImportContactsCompanion extends UpdateCompanion<ImportContact> {
  final Value<int> zPk;
  final Value<String?> displayName;
  final Value<String?> givenName;
  final Value<String?> familyName;
  final Value<String?> organization;
  final Value<bool> isOrganization;
  final Value<String?> createdAtUtc;
  final Value<String?> updatedAtUtc;
  final Value<int> batchId;
  const ImportContactsCompanion({
    this.zPk = const Value.absent(),
    this.displayName = const Value.absent(),
    this.givenName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.organization = const Value.absent(),
    this.isOrganization = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  ImportContactsCompanion.insert({
    this.zPk = const Value.absent(),
    this.displayName = const Value.absent(),
    this.givenName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.organization = const Value.absent(),
    this.isOrganization = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    required int batchId,
  }) : batchId = Value(batchId);
  static Insertable<ImportContact> custom({
    Expression<int>? zPk,
    Expression<String>? displayName,
    Expression<String>? givenName,
    Expression<String>? familyName,
    Expression<String>? organization,
    Expression<bool>? isOrganization,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (zPk != null) 'Z_PK': zPk,
      if (displayName != null) 'display_name': displayName,
      if (givenName != null) 'given_name': givenName,
      if (familyName != null) 'family_name': familyName,
      if (organization != null) 'organization': organization,
      if (isOrganization != null) 'is_organization': isOrganization,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  ImportContactsCompanion copyWith({
    Value<int>? zPk,
    Value<String?>? displayName,
    Value<String?>? givenName,
    Value<String?>? familyName,
    Value<String?>? organization,
    Value<bool>? isOrganization,
    Value<String?>? createdAtUtc,
    Value<String?>? updatedAtUtc,
    Value<int>? batchId,
  }) {
    return ImportContactsCompanion(
      zPk: zPk ?? this.zPk,
      displayName: displayName ?? this.displayName,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      organization: organization ?? this.organization,
      isOrganization: isOrganization ?? this.isOrganization,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (zPk.present) {
      map['Z_PK'] = Variable<int>(zPk.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (givenName.present) {
      map['given_name'] = Variable<String>(givenName.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (isOrganization.present) {
      map['is_organization'] = Variable<bool>(isOrganization.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportContactsCompanion(')
          ..write('zPk: $zPk, ')
          ..write('displayName: $displayName, ')
          ..write('givenName: $givenName, ')
          ..write('familyName: $familyName, ')
          ..write('organization: $organization, ')
          ..write('isOrganization: $isOrganization, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $ImportContactPhoneEmailTable extends ImportContactPhoneEmail
    with TableInfo<$ImportContactPhoneEmailTable, ImportContactPhoneEmailData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportContactPhoneEmailTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ownerZPkMeta = const VerificationMeta(
    'ownerZPk',
  );
  @override
  late final GeneratedColumn<int> ownerZPk = GeneratedColumn<int>(
    'OWNER_Z_PK',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (Z_PK) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK(kind IN (\'email\',\'phone\'))',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerZPk, kind, value, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_phone_email';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportContactPhoneEmailData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('OWNER_Z_PK')) {
      context.handle(
        _ownerZPkMeta,
        ownerZPk.isAcceptableOrUnknown(data['OWNER_Z_PK']!, _ownerZPkMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerZPkMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, value},
  ];
  @override
  ImportContactPhoneEmailData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportContactPhoneEmailData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ownerZPk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}OWNER_Z_PK'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $ImportContactPhoneEmailTable createAlias(String alias) {
    return $ImportContactPhoneEmailTable(attachedDatabase, alias);
  }
}

class ImportContactPhoneEmailData extends DataClass
    implements Insertable<ImportContactPhoneEmailData> {
  final int id;
  final int ownerZPk;
  final String kind;
  final String value;
  final String? label;
  const ImportContactPhoneEmailData({
    required this.id,
    required this.ownerZPk,
    required this.kind,
    required this.value,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['OWNER_Z_PK'] = Variable<int>(ownerZPk);
    map['kind'] = Variable<String>(kind);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  ImportContactPhoneEmailCompanion toCompanion(bool nullToAbsent) {
    return ImportContactPhoneEmailCompanion(
      id: Value(id),
      ownerZPk: Value(ownerZPk),
      kind: Value(kind),
      value: Value(value),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory ImportContactPhoneEmailData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportContactPhoneEmailData(
      id: serializer.fromJson<int>(json['id']),
      ownerZPk: serializer.fromJson<int>(json['ownerZPk']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<String>(json['value']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ownerZPk': serializer.toJson<int>(ownerZPk),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<String>(value),
      'label': serializer.toJson<String?>(label),
    };
  }

  ImportContactPhoneEmailData copyWith({
    int? id,
    int? ownerZPk,
    String? kind,
    String? value,
    Value<String?> label = const Value.absent(),
  }) => ImportContactPhoneEmailData(
    id: id ?? this.id,
    ownerZPk: ownerZPk ?? this.ownerZPk,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    label: label.present ? label.value : this.label,
  );
  ImportContactPhoneEmailData copyWithCompanion(
    ImportContactPhoneEmailCompanion data,
  ) {
    return ImportContactPhoneEmailData(
      id: data.id.present ? data.id.value : this.id,
      ownerZPk: data.ownerZPk.present ? data.ownerZPk.value : this.ownerZPk,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportContactPhoneEmailData(')
          ..write('id: $id, ')
          ..write('ownerZPk: $ownerZPk, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerZPk, kind, value, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportContactPhoneEmailData &&
          other.id == this.id &&
          other.ownerZPk == this.ownerZPk &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.label == this.label);
}

class ImportContactPhoneEmailCompanion
    extends UpdateCompanion<ImportContactPhoneEmailData> {
  final Value<int> id;
  final Value<int> ownerZPk;
  final Value<String> kind;
  final Value<String> value;
  final Value<String?> label;
  const ImportContactPhoneEmailCompanion({
    this.id = const Value.absent(),
    this.ownerZPk = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.label = const Value.absent(),
  });
  ImportContactPhoneEmailCompanion.insert({
    this.id = const Value.absent(),
    required int ownerZPk,
    required String kind,
    required String value,
    this.label = const Value.absent(),
  }) : ownerZPk = Value(ownerZPk),
       kind = Value(kind),
       value = Value(value);
  static Insertable<ImportContactPhoneEmailData> custom({
    Expression<int>? id,
    Expression<int>? ownerZPk,
    Expression<String>? kind,
    Expression<String>? value,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerZPk != null) 'OWNER_Z_PK': ownerZPk,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (label != null) 'label': label,
    });
  }

  ImportContactPhoneEmailCompanion copyWith({
    Value<int>? id,
    Value<int>? ownerZPk,
    Value<String>? kind,
    Value<String>? value,
    Value<String?>? label,
  }) {
    return ImportContactPhoneEmailCompanion(
      id: id ?? this.id,
      ownerZPk: ownerZPk ?? this.ownerZPk,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerZPk.present) {
      map['OWNER_Z_PK'] = Variable<int>(ownerZPk.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportContactPhoneEmailCompanion(')
          ..write('id: $id, ')
          ..write('ownerZPk: $ownerZPk, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $ImportHandlesTable extends ImportHandles
    with TableInfo<$ImportHandlesTable, ImportHandle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportHandlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceRowidMeta = const VerificationMeta(
    'sourceRowid',
  );
  @override
  late final GeneratedColumn<int> sourceRowid = GeneratedColumn<int>(
    'source_rowid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK(service IN (\'iMessage\',\'SMS\',\'Unknown\'))',
  );
  static const VerificationMeta _rawIdentifierMeta = const VerificationMeta(
    'rawIdentifier',
  );
  @override
  late final GeneratedColumn<String> rawIdentifier = GeneratedColumn<String>(
    'raw_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedIdentifierMeta =
      const VerificationMeta('normalizedIdentifier');
  @override
  late final GeneratedColumn<String> normalizedIdentifier =
      GeneratedColumn<String>(
        'normalized_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenUtcMeta = const VerificationMeta(
    'lastSeenUtc',
  );
  @override
  late final GeneratedColumn<String> lastSeenUtc = GeneratedColumn<String>(
    'last_seen_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIgnoredMeta = const VerificationMeta(
    'isIgnored',
  );
  @override
  late final GeneratedColumn<bool> isIgnored = GeneratedColumn<bool>(
    'is_ignored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ignored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceRowid,
    service,
    rawIdentifier,
    normalizedIdentifier,
    country,
    lastSeenUtc,
    isIgnored,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportHandle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_rowid')) {
      context.handle(
        _sourceRowidMeta,
        sourceRowid.isAcceptableOrUnknown(
          data['source_rowid']!,
          _sourceRowidMeta,
        ),
      );
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('raw_identifier')) {
      context.handle(
        _rawIdentifierMeta,
        rawIdentifier.isAcceptableOrUnknown(
          data['raw_identifier']!,
          _rawIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawIdentifierMeta);
    }
    if (data.containsKey('normalized_identifier')) {
      context.handle(
        _normalizedIdentifierMeta,
        normalizedIdentifier.isAcceptableOrUnknown(
          data['normalized_identifier']!,
          _normalizedIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('last_seen_utc')) {
      context.handle(
        _lastSeenUtcMeta,
        lastSeenUtc.isAcceptableOrUnknown(
          data['last_seen_utc']!,
          _lastSeenUtcMeta,
        ),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {service, rawIdentifier},
  ];
  @override
  ImportHandle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportHandle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_rowid'],
      ),
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      rawIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_identifier'],
      )!,
      normalizedIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_identifier'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      lastSeenUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_utc'],
      ),
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
    );
  }

  @override
  $ImportHandlesTable createAlias(String alias) {
    return $ImportHandlesTable(attachedDatabase, alias);
  }
}

class ImportHandle extends DataClass implements Insertable<ImportHandle> {
  final int id;
  final int? sourceRowid;
  final String service;
  final String rawIdentifier;
  final String? normalizedIdentifier;
  final String? country;
  final String? lastSeenUtc;
  final bool isIgnored;
  final int batchId;
  const ImportHandle({
    required this.id,
    this.sourceRowid,
    required this.service,
    required this.rawIdentifier,
    this.normalizedIdentifier,
    this.country,
    this.lastSeenUtc,
    required this.isIgnored,
    required this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceRowid != null) {
      map['source_rowid'] = Variable<int>(sourceRowid);
    }
    map['service'] = Variable<String>(service);
    map['raw_identifier'] = Variable<String>(rawIdentifier);
    if (!nullToAbsent || normalizedIdentifier != null) {
      map['normalized_identifier'] = Variable<String>(normalizedIdentifier);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || lastSeenUtc != null) {
      map['last_seen_utc'] = Variable<String>(lastSeenUtc);
    }
    map['is_ignored'] = Variable<bool>(isIgnored);
    map['batch_id'] = Variable<int>(batchId);
    return map;
  }

  ImportHandlesCompanion toCompanion(bool nullToAbsent) {
    return ImportHandlesCompanion(
      id: Value(id),
      sourceRowid: sourceRowid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRowid),
      service: Value(service),
      rawIdentifier: Value(rawIdentifier),
      normalizedIdentifier: normalizedIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedIdentifier),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      lastSeenUtc: lastSeenUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenUtc),
      isIgnored: Value(isIgnored),
      batchId: Value(batchId),
    );
  }

  factory ImportHandle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportHandle(
      id: serializer.fromJson<int>(json['id']),
      sourceRowid: serializer.fromJson<int?>(json['sourceRowid']),
      service: serializer.fromJson<String>(json['service']),
      rawIdentifier: serializer.fromJson<String>(json['rawIdentifier']),
      normalizedIdentifier: serializer.fromJson<String?>(
        json['normalizedIdentifier'],
      ),
      country: serializer.fromJson<String?>(json['country']),
      lastSeenUtc: serializer.fromJson<String?>(json['lastSeenUtc']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      batchId: serializer.fromJson<int>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceRowid': serializer.toJson<int?>(sourceRowid),
      'service': serializer.toJson<String>(service),
      'rawIdentifier': serializer.toJson<String>(rawIdentifier),
      'normalizedIdentifier': serializer.toJson<String?>(normalizedIdentifier),
      'country': serializer.toJson<String?>(country),
      'lastSeenUtc': serializer.toJson<String?>(lastSeenUtc),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'batchId': serializer.toJson<int>(batchId),
    };
  }

  ImportHandle copyWith({
    int? id,
    Value<int?> sourceRowid = const Value.absent(),
    String? service,
    String? rawIdentifier,
    Value<String?> normalizedIdentifier = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> lastSeenUtc = const Value.absent(),
    bool? isIgnored,
    int? batchId,
  }) => ImportHandle(
    id: id ?? this.id,
    sourceRowid: sourceRowid.present ? sourceRowid.value : this.sourceRowid,
    service: service ?? this.service,
    rawIdentifier: rawIdentifier ?? this.rawIdentifier,
    normalizedIdentifier: normalizedIdentifier.present
        ? normalizedIdentifier.value
        : this.normalizedIdentifier,
    country: country.present ? country.value : this.country,
    lastSeenUtc: lastSeenUtc.present ? lastSeenUtc.value : this.lastSeenUtc,
    isIgnored: isIgnored ?? this.isIgnored,
    batchId: batchId ?? this.batchId,
  );
  ImportHandle copyWithCompanion(ImportHandlesCompanion data) {
    return ImportHandle(
      id: data.id.present ? data.id.value : this.id,
      sourceRowid: data.sourceRowid.present
          ? data.sourceRowid.value
          : this.sourceRowid,
      service: data.service.present ? data.service.value : this.service,
      rawIdentifier: data.rawIdentifier.present
          ? data.rawIdentifier.value
          : this.rawIdentifier,
      normalizedIdentifier: data.normalizedIdentifier.present
          ? data.normalizedIdentifier.value
          : this.normalizedIdentifier,
      country: data.country.present ? data.country.value : this.country,
      lastSeenUtc: data.lastSeenUtc.present
          ? data.lastSeenUtc.value
          : this.lastSeenUtc,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportHandle(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('service: $service, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('normalizedIdentifier: $normalizedIdentifier, ')
          ..write('country: $country, ')
          ..write('lastSeenUtc: $lastSeenUtc, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceRowid,
    service,
    rawIdentifier,
    normalizedIdentifier,
    country,
    lastSeenUtc,
    isIgnored,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportHandle &&
          other.id == this.id &&
          other.sourceRowid == this.sourceRowid &&
          other.service == this.service &&
          other.rawIdentifier == this.rawIdentifier &&
          other.normalizedIdentifier == this.normalizedIdentifier &&
          other.country == this.country &&
          other.lastSeenUtc == this.lastSeenUtc &&
          other.isIgnored == this.isIgnored &&
          other.batchId == this.batchId);
}

class ImportHandlesCompanion extends UpdateCompanion<ImportHandle> {
  final Value<int> id;
  final Value<int?> sourceRowid;
  final Value<String> service;
  final Value<String> rawIdentifier;
  final Value<String?> normalizedIdentifier;
  final Value<String?> country;
  final Value<String?> lastSeenUtc;
  final Value<bool> isIgnored;
  final Value<int> batchId;
  const ImportHandlesCompanion({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.service = const Value.absent(),
    this.rawIdentifier = const Value.absent(),
    this.normalizedIdentifier = const Value.absent(),
    this.country = const Value.absent(),
    this.lastSeenUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  ImportHandlesCompanion.insert({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    required String service,
    required String rawIdentifier,
    this.normalizedIdentifier = const Value.absent(),
    this.country = const Value.absent(),
    this.lastSeenUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
    required int batchId,
  }) : service = Value(service),
       rawIdentifier = Value(rawIdentifier),
       batchId = Value(batchId);
  static Insertable<ImportHandle> custom({
    Expression<int>? id,
    Expression<int>? sourceRowid,
    Expression<String>? service,
    Expression<String>? rawIdentifier,
    Expression<String>? normalizedIdentifier,
    Expression<String>? country,
    Expression<String>? lastSeenUtc,
    Expression<bool>? isIgnored,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceRowid != null) 'source_rowid': sourceRowid,
      if (service != null) 'service': service,
      if (rawIdentifier != null) 'raw_identifier': rawIdentifier,
      if (normalizedIdentifier != null)
        'normalized_identifier': normalizedIdentifier,
      if (country != null) 'country': country,
      if (lastSeenUtc != null) 'last_seen_utc': lastSeenUtc,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  ImportHandlesCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceRowid,
    Value<String>? service,
    Value<String>? rawIdentifier,
    Value<String?>? normalizedIdentifier,
    Value<String?>? country,
    Value<String?>? lastSeenUtc,
    Value<bool>? isIgnored,
    Value<int>? batchId,
  }) {
    return ImportHandlesCompanion(
      id: id ?? this.id,
      sourceRowid: sourceRowid ?? this.sourceRowid,
      service: service ?? this.service,
      rawIdentifier: rawIdentifier ?? this.rawIdentifier,
      normalizedIdentifier: normalizedIdentifier ?? this.normalizedIdentifier,
      country: country ?? this.country,
      lastSeenUtc: lastSeenUtc ?? this.lastSeenUtc,
      isIgnored: isIgnored ?? this.isIgnored,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceRowid.present) {
      map['source_rowid'] = Variable<int>(sourceRowid.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (rawIdentifier.present) {
      map['raw_identifier'] = Variable<String>(rawIdentifier.value);
    }
    if (normalizedIdentifier.present) {
      map['normalized_identifier'] = Variable<String>(
        normalizedIdentifier.value,
      );
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (lastSeenUtc.present) {
      map['last_seen_utc'] = Variable<String>(lastSeenUtc.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportHandlesCompanion(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('service: $service, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('normalizedIdentifier: $normalizedIdentifier, ')
          ..write('country: $country, ')
          ..write('lastSeenUtc: $lastSeenUtc, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $ImportChatsTable extends ImportChats
    with TableInfo<$ImportChatsTable, ImportChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceRowidMeta = const VerificationMeta(
    'sourceRowid',
  );
  @override
  late final GeneratedColumn<int> sourceRowid = GeneratedColumn<int>(
    'source_rowid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK(service IN (\'iMessage\',\'SMS\',\'Unknown\') OR service IS NULL)',
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGroupMeta = const VerificationMeta(
    'isGroup',
  );
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
    'is_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIgnoredMeta = const VerificationMeta(
    'isIgnored',
  );
  @override
  late final GeneratedColumn<bool> isIgnored = GeneratedColumn<bool>(
    'is_ignored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ignored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceRowid,
    guid,
    service,
    displayName,
    isGroup,
    createdAtUtc,
    updatedAtUtc,
    isIgnored,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_rowid')) {
      context.handle(
        _sourceRowidMeta,
        sourceRowid.isAcceptableOrUnknown(
          data['source_rowid']!,
          _sourceRowidMeta,
        ),
      );
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {guid},
  ];
  @override
  ImportChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportChat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_rowid'],
      ),
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      isGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_group'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      ),
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
    );
  }

  @override
  $ImportChatsTable createAlias(String alias) {
    return $ImportChatsTable(attachedDatabase, alias);
  }
}

class ImportChat extends DataClass implements Insertable<ImportChat> {
  final int id;
  final int? sourceRowid;
  final String guid;
  final String? service;
  final String? displayName;
  final bool isGroup;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  final bool isIgnored;
  final int batchId;
  const ImportChat({
    required this.id,
    this.sourceRowid,
    required this.guid,
    this.service,
    this.displayName,
    required this.isGroup,
    this.createdAtUtc,
    this.updatedAtUtc,
    required this.isIgnored,
    required this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceRowid != null) {
      map['source_rowid'] = Variable<int>(sourceRowid);
    }
    map['guid'] = Variable<String>(guid);
    if (!nullToAbsent || service != null) {
      map['service'] = Variable<String>(service);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    }
    map['is_ignored'] = Variable<bool>(isIgnored);
    map['batch_id'] = Variable<int>(batchId);
    return map;
  }

  ImportChatsCompanion toCompanion(bool nullToAbsent) {
    return ImportChatsCompanion(
      id: Value(id),
      sourceRowid: sourceRowid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRowid),
      guid: Value(guid),
      service: service == null && nullToAbsent
          ? const Value.absent()
          : Value(service),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      isGroup: Value(isGroup),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtUtc),
      isIgnored: Value(isIgnored),
      batchId: Value(batchId),
    );
  }

  factory ImportChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportChat(
      id: serializer.fromJson<int>(json['id']),
      sourceRowid: serializer.fromJson<int?>(json['sourceRowid']),
      guid: serializer.fromJson<String>(json['guid']),
      service: serializer.fromJson<String?>(json['service']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      batchId: serializer.fromJson<int>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceRowid': serializer.toJson<int?>(sourceRowid),
      'guid': serializer.toJson<String>(guid),
      'service': serializer.toJson<String?>(service),
      'displayName': serializer.toJson<String?>(displayName),
      'isGroup': serializer.toJson<bool>(isGroup),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'batchId': serializer.toJson<int>(batchId),
    };
  }

  ImportChat copyWith({
    int? id,
    Value<int?> sourceRowid = const Value.absent(),
    String? guid,
    Value<String?> service = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    bool? isGroup,
    Value<String?> createdAtUtc = const Value.absent(),
    Value<String?> updatedAtUtc = const Value.absent(),
    bool? isIgnored,
    int? batchId,
  }) => ImportChat(
    id: id ?? this.id,
    sourceRowid: sourceRowid.present ? sourceRowid.value : this.sourceRowid,
    guid: guid ?? this.guid,
    service: service.present ? service.value : this.service,
    displayName: displayName.present ? displayName.value : this.displayName,
    isGroup: isGroup ?? this.isGroup,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
    isIgnored: isIgnored ?? this.isIgnored,
    batchId: batchId ?? this.batchId,
  );
  ImportChat copyWithCompanion(ImportChatsCompanion data) {
    return ImportChat(
      id: data.id.present ? data.id.value : this.id,
      sourceRowid: data.sourceRowid.present
          ? data.sourceRowid.value
          : this.sourceRowid,
      guid: data.guid.present ? data.guid.value : this.guid,
      service: data.service.present ? data.service.value : this.service,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportChat(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('guid: $guid, ')
          ..write('service: $service, ')
          ..write('displayName: $displayName, ')
          ..write('isGroup: $isGroup, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceRowid,
    guid,
    service,
    displayName,
    isGroup,
    createdAtUtc,
    updatedAtUtc,
    isIgnored,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportChat &&
          other.id == this.id &&
          other.sourceRowid == this.sourceRowid &&
          other.guid == this.guid &&
          other.service == this.service &&
          other.displayName == this.displayName &&
          other.isGroup == this.isGroup &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.isIgnored == this.isIgnored &&
          other.batchId == this.batchId);
}

class ImportChatsCompanion extends UpdateCompanion<ImportChat> {
  final Value<int> id;
  final Value<int?> sourceRowid;
  final Value<String> guid;
  final Value<String?> service;
  final Value<String?> displayName;
  final Value<bool> isGroup;
  final Value<String?> createdAtUtc;
  final Value<String?> updatedAtUtc;
  final Value<bool> isIgnored;
  final Value<int> batchId;
  const ImportChatsCompanion({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.guid = const Value.absent(),
    this.service = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  ImportChatsCompanion.insert({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    required String guid,
    this.service = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
    required int batchId,
  }) : guid = Value(guid),
       batchId = Value(batchId);
  static Insertable<ImportChat> custom({
    Expression<int>? id,
    Expression<int>? sourceRowid,
    Expression<String>? guid,
    Expression<String>? service,
    Expression<String>? displayName,
    Expression<bool>? isGroup,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
    Expression<bool>? isIgnored,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceRowid != null) 'source_rowid': sourceRowid,
      if (guid != null) 'guid': guid,
      if (service != null) 'service': service,
      if (displayName != null) 'display_name': displayName,
      if (isGroup != null) 'is_group': isGroup,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  ImportChatsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceRowid,
    Value<String>? guid,
    Value<String?>? service,
    Value<String?>? displayName,
    Value<bool>? isGroup,
    Value<String?>? createdAtUtc,
    Value<String?>? updatedAtUtc,
    Value<bool>? isIgnored,
    Value<int>? batchId,
  }) {
    return ImportChatsCompanion(
      id: id ?? this.id,
      sourceRowid: sourceRowid ?? this.sourceRowid,
      guid: guid ?? this.guid,
      service: service ?? this.service,
      displayName: displayName ?? this.displayName,
      isGroup: isGroup ?? this.isGroup,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isIgnored: isIgnored ?? this.isIgnored,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceRowid.present) {
      map['source_rowid'] = Variable<int>(sourceRowid.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportChatsCompanion(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('guid: $guid, ')
          ..write('service: $service, ')
          ..write('displayName: $displayName, ')
          ..write('isGroup: $isGroup, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $ImportChatToHandleTable extends ImportChatToHandle
    with TableInfo<$ImportChatToHandleTable, ImportChatToHandleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportChatToHandleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _handleIdMeta = const VerificationMeta(
    'handleId',
  );
  @override
  late final GeneratedColumn<int> handleId = GeneratedColumn<int>(
    'handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK(role IN (\'member\',\'owner\',\'unknown\') OR role IS NULL)',
  );
  static const VerificationMeta _addedAtUtcMeta = const VerificationMeta(
    'addedAtUtc',
  );
  @override
  late final GeneratedColumn<String> addedAtUtc = GeneratedColumn<String>(
    'added_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, handleId, role, addedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_to_handle';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportChatToHandleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('handle_id')) {
      context.handle(
        _handleIdMeta,
        handleId.isAcceptableOrUnknown(data['handle_id']!, _handleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_handleIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('added_at_utc')) {
      context.handle(
        _addedAtUtcMeta,
        addedAtUtc.isAcceptableOrUnknown(
          data['added_at_utc']!,
          _addedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, handleId};
  @override
  ImportChatToHandleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportChatToHandleData(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      handleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handle_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      addedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_at_utc'],
      ),
    );
  }

  @override
  $ImportChatToHandleTable createAlias(String alias) {
    return $ImportChatToHandleTable(attachedDatabase, alias);
  }
}

class ImportChatToHandleData extends DataClass
    implements Insertable<ImportChatToHandleData> {
  final int chatId;
  final int handleId;
  final String? role;
  final String? addedAtUtc;
  const ImportChatToHandleData({
    required this.chatId,
    required this.handleId,
    this.role,
    this.addedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    map['handle_id'] = Variable<int>(handleId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || addedAtUtc != null) {
      map['added_at_utc'] = Variable<String>(addedAtUtc);
    }
    return map;
  }

  ImportChatToHandleCompanion toCompanion(bool nullToAbsent) {
    return ImportChatToHandleCompanion(
      chatId: Value(chatId),
      handleId: Value(handleId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      addedAtUtc: addedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAtUtc),
    );
  }

  factory ImportChatToHandleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportChatToHandleData(
      chatId: serializer.fromJson<int>(json['chatId']),
      handleId: serializer.fromJson<int>(json['handleId']),
      role: serializer.fromJson<String?>(json['role']),
      addedAtUtc: serializer.fromJson<String?>(json['addedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'handleId': serializer.toJson<int>(handleId),
      'role': serializer.toJson<String?>(role),
      'addedAtUtc': serializer.toJson<String?>(addedAtUtc),
    };
  }

  ImportChatToHandleData copyWith({
    int? chatId,
    int? handleId,
    Value<String?> role = const Value.absent(),
    Value<String?> addedAtUtc = const Value.absent(),
  }) => ImportChatToHandleData(
    chatId: chatId ?? this.chatId,
    handleId: handleId ?? this.handleId,
    role: role.present ? role.value : this.role,
    addedAtUtc: addedAtUtc.present ? addedAtUtc.value : this.addedAtUtc,
  );
  ImportChatToHandleData copyWithCompanion(ImportChatToHandleCompanion data) {
    return ImportChatToHandleData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      handleId: data.handleId.present ? data.handleId.value : this.handleId,
      role: data.role.present ? data.role.value : this.role,
      addedAtUtc: data.addedAtUtc.present
          ? data.addedAtUtc.value
          : this.addedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportChatToHandleData(')
          ..write('chatId: $chatId, ')
          ..write('handleId: $handleId, ')
          ..write('role: $role, ')
          ..write('addedAtUtc: $addedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, handleId, role, addedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportChatToHandleData &&
          other.chatId == this.chatId &&
          other.handleId == this.handleId &&
          other.role == this.role &&
          other.addedAtUtc == this.addedAtUtc);
}

class ImportChatToHandleCompanion
    extends UpdateCompanion<ImportChatToHandleData> {
  final Value<int> chatId;
  final Value<int> handleId;
  final Value<String?> role;
  final Value<String?> addedAtUtc;
  final Value<int> rowid;
  const ImportChatToHandleCompanion({
    this.chatId = const Value.absent(),
    this.handleId = const Value.absent(),
    this.role = const Value.absent(),
    this.addedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportChatToHandleCompanion.insert({
    required int chatId,
    required int handleId,
    this.role = const Value.absent(),
    this.addedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       handleId = Value(handleId);
  static Insertable<ImportChatToHandleData> custom({
    Expression<int>? chatId,
    Expression<int>? handleId,
    Expression<String>? role,
    Expression<String>? addedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (handleId != null) 'handle_id': handleId,
      if (role != null) 'role': role,
      if (addedAtUtc != null) 'added_at_utc': addedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportChatToHandleCompanion copyWith({
    Value<int>? chatId,
    Value<int>? handleId,
    Value<String?>? role,
    Value<String?>? addedAtUtc,
    Value<int>? rowid,
  }) {
    return ImportChatToHandleCompanion(
      chatId: chatId ?? this.chatId,
      handleId: handleId ?? this.handleId,
      role: role ?? this.role,
      addedAtUtc: addedAtUtc ?? this.addedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (handleId.present) {
      map['handle_id'] = Variable<int>(handleId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (addedAtUtc.present) {
      map['added_at_utc'] = Variable<String>(addedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportChatToHandleCompanion(')
          ..write('chatId: $chatId, ')
          ..write('handleId: $handleId, ')
          ..write('role: $role, ')
          ..write('addedAtUtc: $addedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportMessagesTable extends ImportMessages
    with TableInfo<$ImportMessagesTable, ImportMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceRowidMeta = const VerificationMeta(
    'sourceRowid',
  );
  @override
  late final GeneratedColumn<int> sourceRowid = GeneratedColumn<int>(
    'source_rowid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _senderHandleIdMeta = const VerificationMeta(
    'senderHandleId',
  );
  @override
  late final GeneratedColumn<int> senderHandleId = GeneratedColumn<int>(
    'sender_handle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK(service IN (\'iMessage\',\'SMS\',\'Unknown\') OR service IS NULL)',
  );
  static const VerificationMeta _isFromMeMeta = const VerificationMeta(
    'isFromMe',
  );
  @override
  late final GeneratedColumn<bool> isFromMe = GeneratedColumn<bool>(
    'is_from_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_from_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateUtcMeta = const VerificationMeta(
    'dateUtc',
  );
  @override
  late final GeneratedColumn<String> dateUtc = GeneratedColumn<String>(
    'date_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateReadUtcMeta = const VerificationMeta(
    'dateReadUtc',
  );
  @override
  late final GeneratedColumn<String> dateReadUtc = GeneratedColumn<String>(
    'date_read_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateDeliveredUtcMeta = const VerificationMeta(
    'dateDeliveredUtc',
  );
  @override
  late final GeneratedColumn<String> dateDeliveredUtc = GeneratedColumn<String>(
    'date_delivered_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributedBodyBlobMeta =
      const VerificationMeta('attributedBodyBlob');
  @override
  late final GeneratedColumn<Uint8List> attributedBodyBlob =
      GeneratedColumn<Uint8List>(
        'attributed_body_blob',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK(item_type IN (\'text\',\'attachment-only\',\'sticker\',\'reaction-carrier\',\'system\',\'unknown\') OR item_type IS NULL)',
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<int> errorCode = GeneratedColumn<int>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMessageMeta = const VerificationMeta(
    'isSystemMessage',
  );
  @override
  late final GeneratedColumn<bool> isSystemMessage = GeneratedColumn<bool>(
    'is_system_message',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_message" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _threadOriginatorGuidMeta =
      const VerificationMeta('threadOriginatorGuid');
  @override
  late final GeneratedColumn<String> threadOriginatorGuid =
      GeneratedColumn<String>(
        'thread_originator_guid',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _associatedMessageGuidMeta =
      const VerificationMeta('associatedMessageGuid');
  @override
  late final GeneratedColumn<String> associatedMessageGuid =
      GeneratedColumn<String>(
        'associated_message_guid',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _balloonBundleIdMeta = const VerificationMeta(
    'balloonBundleId',
  );
  @override
  late final GeneratedColumn<String> balloonBundleId = GeneratedColumn<String>(
    'balloon_bundle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIgnoredMeta = const VerificationMeta(
    'isIgnored',
  );
  @override
  late final GeneratedColumn<bool> isIgnored = GeneratedColumn<bool>(
    'is_ignored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ignored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceRowid,
    guid,
    chatId,
    senderHandleId,
    service,
    isFromMe,
    dateUtc,
    dateReadUtc,
    dateDeliveredUtc,
    subject,
    textContent,
    attributedBodyBlob,
    itemType,
    errorCode,
    isSystemMessage,
    threadOriginatorGuid,
    associatedMessageGuid,
    balloonBundleId,
    payloadJson,
    isIgnored,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_rowid')) {
      context.handle(
        _sourceRowidMeta,
        sourceRowid.isAcceptableOrUnknown(
          data['source_rowid']!,
          _sourceRowidMeta,
        ),
      );
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_handle_id')) {
      context.handle(
        _senderHandleIdMeta,
        senderHandleId.isAcceptableOrUnknown(
          data['sender_handle_id']!,
          _senderHandleIdMeta,
        ),
      );
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('is_from_me')) {
      context.handle(
        _isFromMeMeta,
        isFromMe.isAcceptableOrUnknown(data['is_from_me']!, _isFromMeMeta),
      );
    }
    if (data.containsKey('date_utc')) {
      context.handle(
        _dateUtcMeta,
        dateUtc.isAcceptableOrUnknown(data['date_utc']!, _dateUtcMeta),
      );
    }
    if (data.containsKey('date_read_utc')) {
      context.handle(
        _dateReadUtcMeta,
        dateReadUtc.isAcceptableOrUnknown(
          data['date_read_utc']!,
          _dateReadUtcMeta,
        ),
      );
    }
    if (data.containsKey('date_delivered_utc')) {
      context.handle(
        _dateDeliveredUtcMeta,
        dateDeliveredUtc.isAcceptableOrUnknown(
          data['date_delivered_utc']!,
          _dateDeliveredUtcMeta,
        ),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    }
    if (data.containsKey('attributed_body_blob')) {
      context.handle(
        _attributedBodyBlobMeta,
        attributedBodyBlob.isAcceptableOrUnknown(
          data['attributed_body_blob']!,
          _attributedBodyBlobMeta,
        ),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('is_system_message')) {
      context.handle(
        _isSystemMessageMeta,
        isSystemMessage.isAcceptableOrUnknown(
          data['is_system_message']!,
          _isSystemMessageMeta,
        ),
      );
    }
    if (data.containsKey('thread_originator_guid')) {
      context.handle(
        _threadOriginatorGuidMeta,
        threadOriginatorGuid.isAcceptableOrUnknown(
          data['thread_originator_guid']!,
          _threadOriginatorGuidMeta,
        ),
      );
    }
    if (data.containsKey('associated_message_guid')) {
      context.handle(
        _associatedMessageGuidMeta,
        associatedMessageGuid.isAcceptableOrUnknown(
          data['associated_message_guid']!,
          _associatedMessageGuidMeta,
        ),
      );
    }
    if (data.containsKey('balloon_bundle_id')) {
      context.handle(
        _balloonBundleIdMeta,
        balloonBundleId.isAcceptableOrUnknown(
          data['balloon_bundle_id']!,
          _balloonBundleIdMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {guid},
  ];
  @override
  ImportMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_rowid'],
      ),
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      senderHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_handle_id'],
      ),
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      ),
      isFromMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_from_me'],
      )!,
      dateUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_utc'],
      ),
      dateReadUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_read_utc'],
      ),
      dateDeliveredUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_delivered_utc'],
      ),
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      ),
      attributedBodyBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}attributed_body_blob'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      ),
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_code'],
      ),
      isSystemMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_message'],
      )!,
      threadOriginatorGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_originator_guid'],
      ),
      associatedMessageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}associated_message_guid'],
      ),
      balloonBundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balloon_bundle_id'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
    );
  }

  @override
  $ImportMessagesTable createAlias(String alias) {
    return $ImportMessagesTable(attachedDatabase, alias);
  }
}

class ImportMessage extends DataClass implements Insertable<ImportMessage> {
  final int id;
  final int? sourceRowid;
  final String guid;
  final int chatId;
  final int? senderHandleId;
  final String? service;
  final bool isFromMe;
  final String? dateUtc;
  final String? dateReadUtc;
  final String? dateDeliveredUtc;
  final String? subject;
  final String? textContent;
  final Uint8List? attributedBodyBlob;
  final String? itemType;
  final int? errorCode;
  final bool isSystemMessage;
  final String? threadOriginatorGuid;
  final String? associatedMessageGuid;
  final String? balloonBundleId;
  final String? payloadJson;
  final bool isIgnored;
  final int batchId;
  const ImportMessage({
    required this.id,
    this.sourceRowid,
    required this.guid,
    required this.chatId,
    this.senderHandleId,
    this.service,
    required this.isFromMe,
    this.dateUtc,
    this.dateReadUtc,
    this.dateDeliveredUtc,
    this.subject,
    this.textContent,
    this.attributedBodyBlob,
    this.itemType,
    this.errorCode,
    required this.isSystemMessage,
    this.threadOriginatorGuid,
    this.associatedMessageGuid,
    this.balloonBundleId,
    this.payloadJson,
    required this.isIgnored,
    required this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceRowid != null) {
      map['source_rowid'] = Variable<int>(sourceRowid);
    }
    map['guid'] = Variable<String>(guid);
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || senderHandleId != null) {
      map['sender_handle_id'] = Variable<int>(senderHandleId);
    }
    if (!nullToAbsent || service != null) {
      map['service'] = Variable<String>(service);
    }
    map['is_from_me'] = Variable<bool>(isFromMe);
    if (!nullToAbsent || dateUtc != null) {
      map['date_utc'] = Variable<String>(dateUtc);
    }
    if (!nullToAbsent || dateReadUtc != null) {
      map['date_read_utc'] = Variable<String>(dateReadUtc);
    }
    if (!nullToAbsent || dateDeliveredUtc != null) {
      map['date_delivered_utc'] = Variable<String>(dateDeliveredUtc);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || textContent != null) {
      map['text'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || attributedBodyBlob != null) {
      map['attributed_body_blob'] = Variable<Uint8List>(attributedBodyBlob);
    }
    if (!nullToAbsent || itemType != null) {
      map['item_type'] = Variable<String>(itemType);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<int>(errorCode);
    }
    map['is_system_message'] = Variable<bool>(isSystemMessage);
    if (!nullToAbsent || threadOriginatorGuid != null) {
      map['thread_originator_guid'] = Variable<String>(threadOriginatorGuid);
    }
    if (!nullToAbsent || associatedMessageGuid != null) {
      map['associated_message_guid'] = Variable<String>(associatedMessageGuid);
    }
    if (!nullToAbsent || balloonBundleId != null) {
      map['balloon_bundle_id'] = Variable<String>(balloonBundleId);
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['is_ignored'] = Variable<bool>(isIgnored);
    map['batch_id'] = Variable<int>(batchId);
    return map;
  }

  ImportMessagesCompanion toCompanion(bool nullToAbsent) {
    return ImportMessagesCompanion(
      id: Value(id),
      sourceRowid: sourceRowid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRowid),
      guid: Value(guid),
      chatId: Value(chatId),
      senderHandleId: senderHandleId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderHandleId),
      service: service == null && nullToAbsent
          ? const Value.absent()
          : Value(service),
      isFromMe: Value(isFromMe),
      dateUtc: dateUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(dateUtc),
      dateReadUtc: dateReadUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(dateReadUtc),
      dateDeliveredUtc: dateDeliveredUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDeliveredUtc),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      attributedBodyBlob: attributedBodyBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(attributedBodyBlob),
      itemType: itemType == null && nullToAbsent
          ? const Value.absent()
          : Value(itemType),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      isSystemMessage: Value(isSystemMessage),
      threadOriginatorGuid: threadOriginatorGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(threadOriginatorGuid),
      associatedMessageGuid: associatedMessageGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(associatedMessageGuid),
      balloonBundleId: balloonBundleId == null && nullToAbsent
          ? const Value.absent()
          : Value(balloonBundleId),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      isIgnored: Value(isIgnored),
      batchId: Value(batchId),
    );
  }

  factory ImportMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportMessage(
      id: serializer.fromJson<int>(json['id']),
      sourceRowid: serializer.fromJson<int?>(json['sourceRowid']),
      guid: serializer.fromJson<String>(json['guid']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderHandleId: serializer.fromJson<int?>(json['senderHandleId']),
      service: serializer.fromJson<String?>(json['service']),
      isFromMe: serializer.fromJson<bool>(json['isFromMe']),
      dateUtc: serializer.fromJson<String?>(json['dateUtc']),
      dateReadUtc: serializer.fromJson<String?>(json['dateReadUtc']),
      dateDeliveredUtc: serializer.fromJson<String?>(json['dateDeliveredUtc']),
      subject: serializer.fromJson<String?>(json['subject']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      attributedBodyBlob: serializer.fromJson<Uint8List?>(
        json['attributedBodyBlob'],
      ),
      itemType: serializer.fromJson<String?>(json['itemType']),
      errorCode: serializer.fromJson<int?>(json['errorCode']),
      isSystemMessage: serializer.fromJson<bool>(json['isSystemMessage']),
      threadOriginatorGuid: serializer.fromJson<String?>(
        json['threadOriginatorGuid'],
      ),
      associatedMessageGuid: serializer.fromJson<String?>(
        json['associatedMessageGuid'],
      ),
      balloonBundleId: serializer.fromJson<String?>(json['balloonBundleId']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      batchId: serializer.fromJson<int>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceRowid': serializer.toJson<int?>(sourceRowid),
      'guid': serializer.toJson<String>(guid),
      'chatId': serializer.toJson<int>(chatId),
      'senderHandleId': serializer.toJson<int?>(senderHandleId),
      'service': serializer.toJson<String?>(service),
      'isFromMe': serializer.toJson<bool>(isFromMe),
      'dateUtc': serializer.toJson<String?>(dateUtc),
      'dateReadUtc': serializer.toJson<String?>(dateReadUtc),
      'dateDeliveredUtc': serializer.toJson<String?>(dateDeliveredUtc),
      'subject': serializer.toJson<String?>(subject),
      'textContent': serializer.toJson<String?>(textContent),
      'attributedBodyBlob': serializer.toJson<Uint8List?>(attributedBodyBlob),
      'itemType': serializer.toJson<String?>(itemType),
      'errorCode': serializer.toJson<int?>(errorCode),
      'isSystemMessage': serializer.toJson<bool>(isSystemMessage),
      'threadOriginatorGuid': serializer.toJson<String?>(threadOriginatorGuid),
      'associatedMessageGuid': serializer.toJson<String?>(
        associatedMessageGuid,
      ),
      'balloonBundleId': serializer.toJson<String?>(balloonBundleId),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'batchId': serializer.toJson<int>(batchId),
    };
  }

  ImportMessage copyWith({
    int? id,
    Value<int?> sourceRowid = const Value.absent(),
    String? guid,
    int? chatId,
    Value<int?> senderHandleId = const Value.absent(),
    Value<String?> service = const Value.absent(),
    bool? isFromMe,
    Value<String?> dateUtc = const Value.absent(),
    Value<String?> dateReadUtc = const Value.absent(),
    Value<String?> dateDeliveredUtc = const Value.absent(),
    Value<String?> subject = const Value.absent(),
    Value<String?> textContent = const Value.absent(),
    Value<Uint8List?> attributedBodyBlob = const Value.absent(),
    Value<String?> itemType = const Value.absent(),
    Value<int?> errorCode = const Value.absent(),
    bool? isSystemMessage,
    Value<String?> threadOriginatorGuid = const Value.absent(),
    Value<String?> associatedMessageGuid = const Value.absent(),
    Value<String?> balloonBundleId = const Value.absent(),
    Value<String?> payloadJson = const Value.absent(),
    bool? isIgnored,
    int? batchId,
  }) => ImportMessage(
    id: id ?? this.id,
    sourceRowid: sourceRowid.present ? sourceRowid.value : this.sourceRowid,
    guid: guid ?? this.guid,
    chatId: chatId ?? this.chatId,
    senderHandleId: senderHandleId.present
        ? senderHandleId.value
        : this.senderHandleId,
    service: service.present ? service.value : this.service,
    isFromMe: isFromMe ?? this.isFromMe,
    dateUtc: dateUtc.present ? dateUtc.value : this.dateUtc,
    dateReadUtc: dateReadUtc.present ? dateReadUtc.value : this.dateReadUtc,
    dateDeliveredUtc: dateDeliveredUtc.present
        ? dateDeliveredUtc.value
        : this.dateDeliveredUtc,
    subject: subject.present ? subject.value : this.subject,
    textContent: textContent.present ? textContent.value : this.textContent,
    attributedBodyBlob: attributedBodyBlob.present
        ? attributedBodyBlob.value
        : this.attributedBodyBlob,
    itemType: itemType.present ? itemType.value : this.itemType,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    threadOriginatorGuid: threadOriginatorGuid.present
        ? threadOriginatorGuid.value
        : this.threadOriginatorGuid,
    associatedMessageGuid: associatedMessageGuid.present
        ? associatedMessageGuid.value
        : this.associatedMessageGuid,
    balloonBundleId: balloonBundleId.present
        ? balloonBundleId.value
        : this.balloonBundleId,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    isIgnored: isIgnored ?? this.isIgnored,
    batchId: batchId ?? this.batchId,
  );
  ImportMessage copyWithCompanion(ImportMessagesCompanion data) {
    return ImportMessage(
      id: data.id.present ? data.id.value : this.id,
      sourceRowid: data.sourceRowid.present
          ? data.sourceRowid.value
          : this.sourceRowid,
      guid: data.guid.present ? data.guid.value : this.guid,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderHandleId: data.senderHandleId.present
          ? data.senderHandleId.value
          : this.senderHandleId,
      service: data.service.present ? data.service.value : this.service,
      isFromMe: data.isFromMe.present ? data.isFromMe.value : this.isFromMe,
      dateUtc: data.dateUtc.present ? data.dateUtc.value : this.dateUtc,
      dateReadUtc: data.dateReadUtc.present
          ? data.dateReadUtc.value
          : this.dateReadUtc,
      dateDeliveredUtc: data.dateDeliveredUtc.present
          ? data.dateDeliveredUtc.value
          : this.dateDeliveredUtc,
      subject: data.subject.present ? data.subject.value : this.subject,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      attributedBodyBlob: data.attributedBodyBlob.present
          ? data.attributedBodyBlob.value
          : this.attributedBodyBlob,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      isSystemMessage: data.isSystemMessage.present
          ? data.isSystemMessage.value
          : this.isSystemMessage,
      threadOriginatorGuid: data.threadOriginatorGuid.present
          ? data.threadOriginatorGuid.value
          : this.threadOriginatorGuid,
      associatedMessageGuid: data.associatedMessageGuid.present
          ? data.associatedMessageGuid.value
          : this.associatedMessageGuid,
      balloonBundleId: data.balloonBundleId.present
          ? data.balloonBundleId.value
          : this.balloonBundleId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportMessage(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('guid: $guid, ')
          ..write('chatId: $chatId, ')
          ..write('senderHandleId: $senderHandleId, ')
          ..write('service: $service, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('dateUtc: $dateUtc, ')
          ..write('dateReadUtc: $dateReadUtc, ')
          ..write('dateDeliveredUtc: $dateDeliveredUtc, ')
          ..write('subject: $subject, ')
          ..write('textContent: $textContent, ')
          ..write('attributedBodyBlob: $attributedBodyBlob, ')
          ..write('itemType: $itemType, ')
          ..write('errorCode: $errorCode, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('threadOriginatorGuid: $threadOriginatorGuid, ')
          ..write('associatedMessageGuid: $associatedMessageGuid, ')
          ..write('balloonBundleId: $balloonBundleId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sourceRowid,
    guid,
    chatId,
    senderHandleId,
    service,
    isFromMe,
    dateUtc,
    dateReadUtc,
    dateDeliveredUtc,
    subject,
    textContent,
    $driftBlobEquality.hash(attributedBodyBlob),
    itemType,
    errorCode,
    isSystemMessage,
    threadOriginatorGuid,
    associatedMessageGuid,
    balloonBundleId,
    payloadJson,
    isIgnored,
    batchId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportMessage &&
          other.id == this.id &&
          other.sourceRowid == this.sourceRowid &&
          other.guid == this.guid &&
          other.chatId == this.chatId &&
          other.senderHandleId == this.senderHandleId &&
          other.service == this.service &&
          other.isFromMe == this.isFromMe &&
          other.dateUtc == this.dateUtc &&
          other.dateReadUtc == this.dateReadUtc &&
          other.dateDeliveredUtc == this.dateDeliveredUtc &&
          other.subject == this.subject &&
          other.textContent == this.textContent &&
          $driftBlobEquality.equals(
            other.attributedBodyBlob,
            this.attributedBodyBlob,
          ) &&
          other.itemType == this.itemType &&
          other.errorCode == this.errorCode &&
          other.isSystemMessage == this.isSystemMessage &&
          other.threadOriginatorGuid == this.threadOriginatorGuid &&
          other.associatedMessageGuid == this.associatedMessageGuid &&
          other.balloonBundleId == this.balloonBundleId &&
          other.payloadJson == this.payloadJson &&
          other.isIgnored == this.isIgnored &&
          other.batchId == this.batchId);
}

class ImportMessagesCompanion extends UpdateCompanion<ImportMessage> {
  final Value<int> id;
  final Value<int?> sourceRowid;
  final Value<String> guid;
  final Value<int> chatId;
  final Value<int?> senderHandleId;
  final Value<String?> service;
  final Value<bool> isFromMe;
  final Value<String?> dateUtc;
  final Value<String?> dateReadUtc;
  final Value<String?> dateDeliveredUtc;
  final Value<String?> subject;
  final Value<String?> textContent;
  final Value<Uint8List?> attributedBodyBlob;
  final Value<String?> itemType;
  final Value<int?> errorCode;
  final Value<bool> isSystemMessage;
  final Value<String?> threadOriginatorGuid;
  final Value<String?> associatedMessageGuid;
  final Value<String?> balloonBundleId;
  final Value<String?> payloadJson;
  final Value<bool> isIgnored;
  final Value<int> batchId;
  const ImportMessagesCompanion({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.guid = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderHandleId = const Value.absent(),
    this.service = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.dateUtc = const Value.absent(),
    this.dateReadUtc = const Value.absent(),
    this.dateDeliveredUtc = const Value.absent(),
    this.subject = const Value.absent(),
    this.textContent = const Value.absent(),
    this.attributedBodyBlob = const Value.absent(),
    this.itemType = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.isSystemMessage = const Value.absent(),
    this.threadOriginatorGuid = const Value.absent(),
    this.associatedMessageGuid = const Value.absent(),
    this.balloonBundleId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  ImportMessagesCompanion.insert({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    required String guid,
    required int chatId,
    this.senderHandleId = const Value.absent(),
    this.service = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.dateUtc = const Value.absent(),
    this.dateReadUtc = const Value.absent(),
    this.dateDeliveredUtc = const Value.absent(),
    this.subject = const Value.absent(),
    this.textContent = const Value.absent(),
    this.attributedBodyBlob = const Value.absent(),
    this.itemType = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.isSystemMessage = const Value.absent(),
    this.threadOriginatorGuid = const Value.absent(),
    this.associatedMessageGuid = const Value.absent(),
    this.balloonBundleId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.isIgnored = const Value.absent(),
    required int batchId,
  }) : guid = Value(guid),
       chatId = Value(chatId),
       batchId = Value(batchId);
  static Insertable<ImportMessage> custom({
    Expression<int>? id,
    Expression<int>? sourceRowid,
    Expression<String>? guid,
    Expression<int>? chatId,
    Expression<int>? senderHandleId,
    Expression<String>? service,
    Expression<bool>? isFromMe,
    Expression<String>? dateUtc,
    Expression<String>? dateReadUtc,
    Expression<String>? dateDeliveredUtc,
    Expression<String>? subject,
    Expression<String>? textContent,
    Expression<Uint8List>? attributedBodyBlob,
    Expression<String>? itemType,
    Expression<int>? errorCode,
    Expression<bool>? isSystemMessage,
    Expression<String>? threadOriginatorGuid,
    Expression<String>? associatedMessageGuid,
    Expression<String>? balloonBundleId,
    Expression<String>? payloadJson,
    Expression<bool>? isIgnored,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceRowid != null) 'source_rowid': sourceRowid,
      if (guid != null) 'guid': guid,
      if (chatId != null) 'chat_id': chatId,
      if (senderHandleId != null) 'sender_handle_id': senderHandleId,
      if (service != null) 'service': service,
      if (isFromMe != null) 'is_from_me': isFromMe,
      if (dateUtc != null) 'date_utc': dateUtc,
      if (dateReadUtc != null) 'date_read_utc': dateReadUtc,
      if (dateDeliveredUtc != null) 'date_delivered_utc': dateDeliveredUtc,
      if (subject != null) 'subject': subject,
      if (textContent != null) 'text': textContent,
      if (attributedBodyBlob != null)
        'attributed_body_blob': attributedBodyBlob,
      if (itemType != null) 'item_type': itemType,
      if (errorCode != null) 'error_code': errorCode,
      if (isSystemMessage != null) 'is_system_message': isSystemMessage,
      if (threadOriginatorGuid != null)
        'thread_originator_guid': threadOriginatorGuid,
      if (associatedMessageGuid != null)
        'associated_message_guid': associatedMessageGuid,
      if (balloonBundleId != null) 'balloon_bundle_id': balloonBundleId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  ImportMessagesCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceRowid,
    Value<String>? guid,
    Value<int>? chatId,
    Value<int?>? senderHandleId,
    Value<String?>? service,
    Value<bool>? isFromMe,
    Value<String?>? dateUtc,
    Value<String?>? dateReadUtc,
    Value<String?>? dateDeliveredUtc,
    Value<String?>? subject,
    Value<String?>? textContent,
    Value<Uint8List?>? attributedBodyBlob,
    Value<String?>? itemType,
    Value<int?>? errorCode,
    Value<bool>? isSystemMessage,
    Value<String?>? threadOriginatorGuid,
    Value<String?>? associatedMessageGuid,
    Value<String?>? balloonBundleId,
    Value<String?>? payloadJson,
    Value<bool>? isIgnored,
    Value<int>? batchId,
  }) {
    return ImportMessagesCompanion(
      id: id ?? this.id,
      sourceRowid: sourceRowid ?? this.sourceRowid,
      guid: guid ?? this.guid,
      chatId: chatId ?? this.chatId,
      senderHandleId: senderHandleId ?? this.senderHandleId,
      service: service ?? this.service,
      isFromMe: isFromMe ?? this.isFromMe,
      dateUtc: dateUtc ?? this.dateUtc,
      dateReadUtc: dateReadUtc ?? this.dateReadUtc,
      dateDeliveredUtc: dateDeliveredUtc ?? this.dateDeliveredUtc,
      subject: subject ?? this.subject,
      textContent: textContent ?? this.textContent,
      attributedBodyBlob: attributedBodyBlob ?? this.attributedBodyBlob,
      itemType: itemType ?? this.itemType,
      errorCode: errorCode ?? this.errorCode,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      threadOriginatorGuid: threadOriginatorGuid ?? this.threadOriginatorGuid,
      associatedMessageGuid:
          associatedMessageGuid ?? this.associatedMessageGuid,
      balloonBundleId: balloonBundleId ?? this.balloonBundleId,
      payloadJson: payloadJson ?? this.payloadJson,
      isIgnored: isIgnored ?? this.isIgnored,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceRowid.present) {
      map['source_rowid'] = Variable<int>(sourceRowid.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderHandleId.present) {
      map['sender_handle_id'] = Variable<int>(senderHandleId.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (isFromMe.present) {
      map['is_from_me'] = Variable<bool>(isFromMe.value);
    }
    if (dateUtc.present) {
      map['date_utc'] = Variable<String>(dateUtc.value);
    }
    if (dateReadUtc.present) {
      map['date_read_utc'] = Variable<String>(dateReadUtc.value);
    }
    if (dateDeliveredUtc.present) {
      map['date_delivered_utc'] = Variable<String>(dateDeliveredUtc.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (attributedBodyBlob.present) {
      map['attributed_body_blob'] = Variable<Uint8List>(
        attributedBodyBlob.value,
      );
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<int>(errorCode.value);
    }
    if (isSystemMessage.present) {
      map['is_system_message'] = Variable<bool>(isSystemMessage.value);
    }
    if (threadOriginatorGuid.present) {
      map['thread_originator_guid'] = Variable<String>(
        threadOriginatorGuid.value,
      );
    }
    if (associatedMessageGuid.present) {
      map['associated_message_guid'] = Variable<String>(
        associatedMessageGuid.value,
      );
    }
    if (balloonBundleId.present) {
      map['balloon_bundle_id'] = Variable<String>(balloonBundleId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('guid: $guid, ')
          ..write('chatId: $chatId, ')
          ..write('senderHandleId: $senderHandleId, ')
          ..write('service: $service, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('dateUtc: $dateUtc, ')
          ..write('dateReadUtc: $dateReadUtc, ')
          ..write('dateDeliveredUtc: $dateDeliveredUtc, ')
          ..write('subject: $subject, ')
          ..write('textContent: $textContent, ')
          ..write('attributedBodyBlob: $attributedBodyBlob, ')
          ..write('itemType: $itemType, ')
          ..write('errorCode: $errorCode, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('threadOriginatorGuid: $threadOriginatorGuid, ')
          ..write('associatedMessageGuid: $associatedMessageGuid, ')
          ..write('balloonBundleId: $balloonBundleId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $ImportChatToMessageTable extends ImportChatToMessage
    with TableInfo<$ImportChatToMessageTable, ImportChatToMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportChatToMessageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceRowidMeta = const VerificationMeta(
    'sourceRowid',
  );
  @override
  late final GeneratedColumn<int> sourceRowid = GeneratedColumn<int>(
    'source_rowid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, messageId, sourceRowid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_to_message';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportChatToMessageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('source_rowid')) {
      context.handle(
        _sourceRowidMeta,
        sourceRowid.isAcceptableOrUnknown(
          data['source_rowid']!,
          _sourceRowidMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, messageId};
  @override
  ImportChatToMessageData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportChatToMessageData(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      sourceRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_rowid'],
      ),
    );
  }

  @override
  $ImportChatToMessageTable createAlias(String alias) {
    return $ImportChatToMessageTable(attachedDatabase, alias);
  }
}

class ImportChatToMessageData extends DataClass
    implements Insertable<ImportChatToMessageData> {
  final int chatId;
  final int messageId;
  final int? sourceRowid;
  const ImportChatToMessageData({
    required this.chatId,
    required this.messageId,
    this.sourceRowid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || sourceRowid != null) {
      map['source_rowid'] = Variable<int>(sourceRowid);
    }
    return map;
  }

  ImportChatToMessageCompanion toCompanion(bool nullToAbsent) {
    return ImportChatToMessageCompanion(
      chatId: Value(chatId),
      messageId: Value(messageId),
      sourceRowid: sourceRowid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRowid),
    );
  }

  factory ImportChatToMessageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportChatToMessageData(
      chatId: serializer.fromJson<int>(json['chatId']),
      messageId: serializer.fromJson<int>(json['messageId']),
      sourceRowid: serializer.fromJson<int?>(json['sourceRowid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'messageId': serializer.toJson<int>(messageId),
      'sourceRowid': serializer.toJson<int?>(sourceRowid),
    };
  }

  ImportChatToMessageData copyWith({
    int? chatId,
    int? messageId,
    Value<int?> sourceRowid = const Value.absent(),
  }) => ImportChatToMessageData(
    chatId: chatId ?? this.chatId,
    messageId: messageId ?? this.messageId,
    sourceRowid: sourceRowid.present ? sourceRowid.value : this.sourceRowid,
  );
  ImportChatToMessageData copyWithCompanion(ImportChatToMessageCompanion data) {
    return ImportChatToMessageData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      sourceRowid: data.sourceRowid.present
          ? data.sourceRowid.value
          : this.sourceRowid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportChatToMessageData(')
          ..write('chatId: $chatId, ')
          ..write('messageId: $messageId, ')
          ..write('sourceRowid: $sourceRowid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, messageId, sourceRowid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportChatToMessageData &&
          other.chatId == this.chatId &&
          other.messageId == this.messageId &&
          other.sourceRowid == this.sourceRowid);
}

class ImportChatToMessageCompanion
    extends UpdateCompanion<ImportChatToMessageData> {
  final Value<int> chatId;
  final Value<int> messageId;
  final Value<int?> sourceRowid;
  final Value<int> rowid;
  const ImportChatToMessageCompanion({
    this.chatId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportChatToMessageCompanion.insert({
    required int chatId,
    required int messageId,
    this.sourceRowid = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       messageId = Value(messageId);
  static Insertable<ImportChatToMessageData> custom({
    Expression<int>? chatId,
    Expression<int>? messageId,
    Expression<int>? sourceRowid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (messageId != null) 'message_id': messageId,
      if (sourceRowid != null) 'source_rowid': sourceRowid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportChatToMessageCompanion copyWith({
    Value<int>? chatId,
    Value<int>? messageId,
    Value<int?>? sourceRowid,
    Value<int>? rowid,
  }) {
    return ImportChatToMessageCompanion(
      chatId: chatId ?? this.chatId,
      messageId: messageId ?? this.messageId,
      sourceRowid: sourceRowid ?? this.sourceRowid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (sourceRowid.present) {
      map['source_rowid'] = Variable<int>(sourceRowid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportChatToMessageCompanion(')
          ..write('chatId: $chatId, ')
          ..write('messageId: $messageId, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportAttachmentsTable extends ImportAttachments
    with TableInfo<$ImportAttachmentsTable, ImportAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceRowidMeta = const VerificationMeta(
    'sourceRowid',
  );
  @override
  late final GeneratedColumn<int> sourceRowid = GeneratedColumn<int>(
    'source_rowid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferNameMeta = const VerificationMeta(
    'transferName',
  );
  @override
  late final GeneratedColumn<String> transferName = GeneratedColumn<String>(
    'transfer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _utiMeta = const VerificationMeta('uti');
  @override
  late final GeneratedColumn<String> uti = GeneratedColumn<String>(
    'uti',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStickerMeta = const VerificationMeta(
    'isSticker',
  );
  @override
  late final GeneratedColumn<bool> isSticker = GeneratedColumn<bool>(
    'is_sticker',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sticker" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isOutgoingMeta = const VerificationMeta(
    'isOutgoing',
  );
  @override
  late final GeneratedColumn<bool> isOutgoing = GeneratedColumn<bool>(
    'is_outgoing',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_outgoing" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha256HexMeta = const VerificationMeta(
    'sha256Hex',
  );
  @override
  late final GeneratedColumn<String> sha256Hex = GeneratedColumn<String>(
    'sha256_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceRowid,
    guid,
    transferName,
    uti,
    mimeType,
    totalBytes,
    isSticker,
    isOutgoing,
    createdAtUtc,
    localPath,
    sha256Hex,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_rowid')) {
      context.handle(
        _sourceRowidMeta,
        sourceRowid.isAcceptableOrUnknown(
          data['source_rowid']!,
          _sourceRowidMeta,
        ),
      );
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    }
    if (data.containsKey('transfer_name')) {
      context.handle(
        _transferNameMeta,
        transferName.isAcceptableOrUnknown(
          data['transfer_name']!,
          _transferNameMeta,
        ),
      );
    }
    if (data.containsKey('uti')) {
      context.handle(
        _utiMeta,
        uti.isAcceptableOrUnknown(data['uti']!, _utiMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('is_sticker')) {
      context.handle(
        _isStickerMeta,
        isSticker.isAcceptableOrUnknown(data['is_sticker']!, _isStickerMeta),
      );
    }
    if (data.containsKey('is_outgoing')) {
      context.handle(
        _isOutgoingMeta,
        isOutgoing.isAcceptableOrUnknown(data['is_outgoing']!, _isOutgoingMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('sha256_hex')) {
      context.handle(
        _sha256HexMeta,
        sha256Hex.isAcceptableOrUnknown(data['sha256_hex']!, _sha256HexMeta),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_rowid'],
      ),
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      ),
      transferName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_name'],
      ),
      uti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uti'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      isSticker: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sticker'],
      )!,
      isOutgoing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_outgoing'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      sha256Hex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256_hex'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
    );
  }

  @override
  $ImportAttachmentsTable createAlias(String alias) {
    return $ImportAttachmentsTable(attachedDatabase, alias);
  }
}

class ImportAttachment extends DataClass
    implements Insertable<ImportAttachment> {
  final int id;
  final int? sourceRowid;
  final String? guid;
  final String? transferName;
  final String? uti;
  final String? mimeType;
  final int? totalBytes;
  final bool isSticker;
  final bool? isOutgoing;
  final String? createdAtUtc;
  final String? localPath;
  final String? sha256Hex;
  final int batchId;
  const ImportAttachment({
    required this.id,
    this.sourceRowid,
    this.guid,
    this.transferName,
    this.uti,
    this.mimeType,
    this.totalBytes,
    required this.isSticker,
    this.isOutgoing,
    this.createdAtUtc,
    this.localPath,
    this.sha256Hex,
    required this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sourceRowid != null) {
      map['source_rowid'] = Variable<int>(sourceRowid);
    }
    if (!nullToAbsent || guid != null) {
      map['guid'] = Variable<String>(guid);
    }
    if (!nullToAbsent || transferName != null) {
      map['transfer_name'] = Variable<String>(transferName);
    }
    if (!nullToAbsent || uti != null) {
      map['uti'] = Variable<String>(uti);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    map['is_sticker'] = Variable<bool>(isSticker);
    if (!nullToAbsent || isOutgoing != null) {
      map['is_outgoing'] = Variable<bool>(isOutgoing);
    }
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || sha256Hex != null) {
      map['sha256_hex'] = Variable<String>(sha256Hex);
    }
    map['batch_id'] = Variable<int>(batchId);
    return map;
  }

  ImportAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return ImportAttachmentsCompanion(
      id: Value(id),
      sourceRowid: sourceRowid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRowid),
      guid: guid == null && nullToAbsent ? const Value.absent() : Value(guid),
      transferName: transferName == null && nullToAbsent
          ? const Value.absent()
          : Value(transferName),
      uti: uti == null && nullToAbsent ? const Value.absent() : Value(uti),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      isSticker: Value(isSticker),
      isOutgoing: isOutgoing == null && nullToAbsent
          ? const Value.absent()
          : Value(isOutgoing),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      sha256Hex: sha256Hex == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256Hex),
      batchId: Value(batchId),
    );
  }

  factory ImportAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportAttachment(
      id: serializer.fromJson<int>(json['id']),
      sourceRowid: serializer.fromJson<int?>(json['sourceRowid']),
      guid: serializer.fromJson<String?>(json['guid']),
      transferName: serializer.fromJson<String?>(json['transferName']),
      uti: serializer.fromJson<String?>(json['uti']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      isSticker: serializer.fromJson<bool>(json['isSticker']),
      isOutgoing: serializer.fromJson<bool?>(json['isOutgoing']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      sha256Hex: serializer.fromJson<String?>(json['sha256Hex']),
      batchId: serializer.fromJson<int>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceRowid': serializer.toJson<int?>(sourceRowid),
      'guid': serializer.toJson<String?>(guid),
      'transferName': serializer.toJson<String?>(transferName),
      'uti': serializer.toJson<String?>(uti),
      'mimeType': serializer.toJson<String?>(mimeType),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'isSticker': serializer.toJson<bool>(isSticker),
      'isOutgoing': serializer.toJson<bool?>(isOutgoing),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'localPath': serializer.toJson<String?>(localPath),
      'sha256Hex': serializer.toJson<String?>(sha256Hex),
      'batchId': serializer.toJson<int>(batchId),
    };
  }

  ImportAttachment copyWith({
    int? id,
    Value<int?> sourceRowid = const Value.absent(),
    Value<String?> guid = const Value.absent(),
    Value<String?> transferName = const Value.absent(),
    Value<String?> uti = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<int?> totalBytes = const Value.absent(),
    bool? isSticker,
    Value<bool?> isOutgoing = const Value.absent(),
    Value<String?> createdAtUtc = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> sha256Hex = const Value.absent(),
    int? batchId,
  }) => ImportAttachment(
    id: id ?? this.id,
    sourceRowid: sourceRowid.present ? sourceRowid.value : this.sourceRowid,
    guid: guid.present ? guid.value : this.guid,
    transferName: transferName.present ? transferName.value : this.transferName,
    uti: uti.present ? uti.value : this.uti,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    isSticker: isSticker ?? this.isSticker,
    isOutgoing: isOutgoing.present ? isOutgoing.value : this.isOutgoing,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    localPath: localPath.present ? localPath.value : this.localPath,
    sha256Hex: sha256Hex.present ? sha256Hex.value : this.sha256Hex,
    batchId: batchId ?? this.batchId,
  );
  ImportAttachment copyWithCompanion(ImportAttachmentsCompanion data) {
    return ImportAttachment(
      id: data.id.present ? data.id.value : this.id,
      sourceRowid: data.sourceRowid.present
          ? data.sourceRowid.value
          : this.sourceRowid,
      guid: data.guid.present ? data.guid.value : this.guid,
      transferName: data.transferName.present
          ? data.transferName.value
          : this.transferName,
      uti: data.uti.present ? data.uti.value : this.uti,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      isSticker: data.isSticker.present ? data.isSticker.value : this.isSticker,
      isOutgoing: data.isOutgoing.present
          ? data.isOutgoing.value
          : this.isOutgoing,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sha256Hex: data.sha256Hex.present ? data.sha256Hex.value : this.sha256Hex,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportAttachment(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('guid: $guid, ')
          ..write('transferName: $transferName, ')
          ..write('uti: $uti, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('isSticker: $isSticker, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('localPath: $localPath, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceRowid,
    guid,
    transferName,
    uti,
    mimeType,
    totalBytes,
    isSticker,
    isOutgoing,
    createdAtUtc,
    localPath,
    sha256Hex,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportAttachment &&
          other.id == this.id &&
          other.sourceRowid == this.sourceRowid &&
          other.guid == this.guid &&
          other.transferName == this.transferName &&
          other.uti == this.uti &&
          other.mimeType == this.mimeType &&
          other.totalBytes == this.totalBytes &&
          other.isSticker == this.isSticker &&
          other.isOutgoing == this.isOutgoing &&
          other.createdAtUtc == this.createdAtUtc &&
          other.localPath == this.localPath &&
          other.sha256Hex == this.sha256Hex &&
          other.batchId == this.batchId);
}

class ImportAttachmentsCompanion extends UpdateCompanion<ImportAttachment> {
  final Value<int> id;
  final Value<int?> sourceRowid;
  final Value<String?> guid;
  final Value<String?> transferName;
  final Value<String?> uti;
  final Value<String?> mimeType;
  final Value<int?> totalBytes;
  final Value<bool> isSticker;
  final Value<bool?> isOutgoing;
  final Value<String?> createdAtUtc;
  final Value<String?> localPath;
  final Value<String?> sha256Hex;
  final Value<int> batchId;
  const ImportAttachmentsCompanion({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.guid = const Value.absent(),
    this.transferName = const Value.absent(),
    this.uti = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.isSticker = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  ImportAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.guid = const Value.absent(),
    this.transferName = const Value.absent(),
    this.uti = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.isSticker = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    required int batchId,
  }) : batchId = Value(batchId);
  static Insertable<ImportAttachment> custom({
    Expression<int>? id,
    Expression<int>? sourceRowid,
    Expression<String>? guid,
    Expression<String>? transferName,
    Expression<String>? uti,
    Expression<String>? mimeType,
    Expression<int>? totalBytes,
    Expression<bool>? isSticker,
    Expression<bool>? isOutgoing,
    Expression<String>? createdAtUtc,
    Expression<String>? localPath,
    Expression<String>? sha256Hex,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceRowid != null) 'source_rowid': sourceRowid,
      if (guid != null) 'guid': guid,
      if (transferName != null) 'transfer_name': transferName,
      if (uti != null) 'uti': uti,
      if (mimeType != null) 'mime_type': mimeType,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (isSticker != null) 'is_sticker': isSticker,
      if (isOutgoing != null) 'is_outgoing': isOutgoing,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (localPath != null) 'local_path': localPath,
      if (sha256Hex != null) 'sha256_hex': sha256Hex,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  ImportAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sourceRowid,
    Value<String?>? guid,
    Value<String?>? transferName,
    Value<String?>? uti,
    Value<String?>? mimeType,
    Value<int?>? totalBytes,
    Value<bool>? isSticker,
    Value<bool?>? isOutgoing,
    Value<String?>? createdAtUtc,
    Value<String?>? localPath,
    Value<String?>? sha256Hex,
    Value<int>? batchId,
  }) {
    return ImportAttachmentsCompanion(
      id: id ?? this.id,
      sourceRowid: sourceRowid ?? this.sourceRowid,
      guid: guid ?? this.guid,
      transferName: transferName ?? this.transferName,
      uti: uti ?? this.uti,
      mimeType: mimeType ?? this.mimeType,
      totalBytes: totalBytes ?? this.totalBytes,
      isSticker: isSticker ?? this.isSticker,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      localPath: localPath ?? this.localPath,
      sha256Hex: sha256Hex ?? this.sha256Hex,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceRowid.present) {
      map['source_rowid'] = Variable<int>(sourceRowid.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (transferName.present) {
      map['transfer_name'] = Variable<String>(transferName.value);
    }
    if (uti.present) {
      map['uti'] = Variable<String>(uti.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (isSticker.present) {
      map['is_sticker'] = Variable<bool>(isSticker.value);
    }
    if (isOutgoing.present) {
      map['is_outgoing'] = Variable<bool>(isOutgoing.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sha256Hex.present) {
      map['sha256_hex'] = Variable<String>(sha256Hex.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('guid: $guid, ')
          ..write('transferName: $transferName, ')
          ..write('uti: $uti, ')
          ..write('mimeType: $mimeType, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('isSticker: $isSticker, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('localPath: $localPath, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $ImportMessageAttachmentsTable extends ImportMessageAttachments
    with TableInfo<$ImportMessageAttachmentsTable, ImportMessageAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportMessageAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<int> attachmentId = GeneratedColumn<int>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attachments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceRowidMeta = const VerificationMeta(
    'sourceRowid',
  );
  @override
  late final GeneratedColumn<int> sourceRowid = GeneratedColumn<int>(
    'source_rowid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [messageId, attachmentId, sourceRowid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportMessageAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('source_rowid')) {
      context.handle(
        _sourceRowidMeta,
        sourceRowid.isAcceptableOrUnknown(
          data['source_rowid']!,
          _sourceRowidMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, attachmentId};
  @override
  ImportMessageAttachment map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportMessageAttachment(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attachment_id'],
      )!,
      sourceRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_rowid'],
      ),
    );
  }

  @override
  $ImportMessageAttachmentsTable createAlias(String alias) {
    return $ImportMessageAttachmentsTable(attachedDatabase, alias);
  }
}

class ImportMessageAttachment extends DataClass
    implements Insertable<ImportMessageAttachment> {
  final int messageId;
  final int attachmentId;
  final int? sourceRowid;
  const ImportMessageAttachment({
    required this.messageId,
    required this.attachmentId,
    this.sourceRowid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<int>(messageId);
    map['attachment_id'] = Variable<int>(attachmentId);
    if (!nullToAbsent || sourceRowid != null) {
      map['source_rowid'] = Variable<int>(sourceRowid);
    }
    return map;
  }

  ImportMessageAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return ImportMessageAttachmentsCompanion(
      messageId: Value(messageId),
      attachmentId: Value(attachmentId),
      sourceRowid: sourceRowid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRowid),
    );
  }

  factory ImportMessageAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportMessageAttachment(
      messageId: serializer.fromJson<int>(json['messageId']),
      attachmentId: serializer.fromJson<int>(json['attachmentId']),
      sourceRowid: serializer.fromJson<int?>(json['sourceRowid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'attachmentId': serializer.toJson<int>(attachmentId),
      'sourceRowid': serializer.toJson<int?>(sourceRowid),
    };
  }

  ImportMessageAttachment copyWith({
    int? messageId,
    int? attachmentId,
    Value<int?> sourceRowid = const Value.absent(),
  }) => ImportMessageAttachment(
    messageId: messageId ?? this.messageId,
    attachmentId: attachmentId ?? this.attachmentId,
    sourceRowid: sourceRowid.present ? sourceRowid.value : this.sourceRowid,
  );
  ImportMessageAttachment copyWithCompanion(
    ImportMessageAttachmentsCompanion data,
  ) {
    return ImportMessageAttachment(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      sourceRowid: data.sourceRowid.present
          ? data.sourceRowid.value
          : this.sourceRowid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportMessageAttachment(')
          ..write('messageId: $messageId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('sourceRowid: $sourceRowid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, attachmentId, sourceRowid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportMessageAttachment &&
          other.messageId == this.messageId &&
          other.attachmentId == this.attachmentId &&
          other.sourceRowid == this.sourceRowid);
}

class ImportMessageAttachmentsCompanion
    extends UpdateCompanion<ImportMessageAttachment> {
  final Value<int> messageId;
  final Value<int> attachmentId;
  final Value<int?> sourceRowid;
  final Value<int> rowid;
  const ImportMessageAttachmentsCompanion({
    this.messageId = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.sourceRowid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportMessageAttachmentsCompanion.insert({
    required int messageId,
    required int attachmentId,
    this.sourceRowid = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       attachmentId = Value(attachmentId);
  static Insertable<ImportMessageAttachment> custom({
    Expression<int>? messageId,
    Expression<int>? attachmentId,
    Expression<int>? sourceRowid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (sourceRowid != null) 'source_rowid': sourceRowid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportMessageAttachmentsCompanion copyWith({
    Value<int>? messageId,
    Value<int>? attachmentId,
    Value<int?>? sourceRowid,
    Value<int>? rowid,
  }) {
    return ImportMessageAttachmentsCompanion(
      messageId: messageId ?? this.messageId,
      attachmentId: attachmentId ?? this.attachmentId,
      sourceRowid: sourceRowid ?? this.sourceRowid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<int>(attachmentId.value);
    }
    if (sourceRowid.present) {
      map['source_rowid'] = Variable<int>(sourceRowid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportMessageAttachmentsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('sourceRowid: $sourceRowid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportReactionsTable extends ImportReactions
    with TableInfo<$ImportReactionsTable, ImportReaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportReactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _carrierMessageIdMeta = const VerificationMeta(
    'carrierMessageId',
  );
  @override
  late final GeneratedColumn<int> carrierMessageId = GeneratedColumn<int>(
    'carrier_message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetMessageGuidMeta = const VerificationMeta(
    'targetMessageGuid',
  );
  @override
  late final GeneratedColumn<String> targetMessageGuid =
      GeneratedColumn<String>(
        'target_message_guid',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK("action" IN (\'add\',\'remove\'))',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK(kind IN (\'love\',\'like\',\'dislike\',\'laugh\',\'emphasize\',\'question\',\'unknown\'))',
  );
  static const VerificationMeta _reactorHandleIdMeta = const VerificationMeta(
    'reactorHandleId',
  );
  @override
  late final GeneratedColumn<int> reactorHandleId = GeneratedColumn<int>(
    'reactor_handle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _reactedAtUtcMeta = const VerificationMeta(
    'reactedAtUtc',
  );
  @override
  late final GeneratedColumn<String> reactedAtUtc = GeneratedColumn<String>(
    'reacted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parseConfidenceMeta = const VerificationMeta(
    'parseConfidence',
  );
  @override
  late final GeneratedColumn<double> parseConfidence = GeneratedColumn<double>(
    'parse_confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 1.0 CHECK(parse_confidence >= 0.0 AND parse_confidence <= 1.0)',
    defaultValue: const CustomExpression('1.0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    carrierMessageId,
    targetMessageGuid,
    action,
    kind,
    reactorHandleId,
    reactedAtUtc,
    parseConfidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportReaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('carrier_message_id')) {
      context.handle(
        _carrierMessageIdMeta,
        carrierMessageId.isAcceptableOrUnknown(
          data['carrier_message_id']!,
          _carrierMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carrierMessageIdMeta);
    }
    if (data.containsKey('target_message_guid')) {
      context.handle(
        _targetMessageGuidMeta,
        targetMessageGuid.isAcceptableOrUnknown(
          data['target_message_guid']!,
          _targetMessageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMessageGuidMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('reactor_handle_id')) {
      context.handle(
        _reactorHandleIdMeta,
        reactorHandleId.isAcceptableOrUnknown(
          data['reactor_handle_id']!,
          _reactorHandleIdMeta,
        ),
      );
    }
    if (data.containsKey('reacted_at_utc')) {
      context.handle(
        _reactedAtUtcMeta,
        reactedAtUtc.isAcceptableOrUnknown(
          data['reacted_at_utc']!,
          _reactedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('parse_confidence')) {
      context.handle(
        _parseConfidenceMeta,
        parseConfidence.isAcceptableOrUnknown(
          data['parse_confidence']!,
          _parseConfidenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportReaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportReaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      carrierMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carrier_message_id'],
      )!,
      targetMessageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_message_guid'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      reactorHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reactor_handle_id'],
      ),
      reactedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reacted_at_utc'],
      ),
      parseConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}parse_confidence'],
      )!,
    );
  }

  @override
  $ImportReactionsTable createAlias(String alias) {
    return $ImportReactionsTable(attachedDatabase, alias);
  }
}

class ImportReaction extends DataClass implements Insertable<ImportReaction> {
  final int id;
  final int carrierMessageId;
  final String targetMessageGuid;
  final String action;
  final String kind;
  final int? reactorHandleId;
  final String? reactedAtUtc;
  final double parseConfidence;
  const ImportReaction({
    required this.id,
    required this.carrierMessageId,
    required this.targetMessageGuid,
    required this.action,
    required this.kind,
    this.reactorHandleId,
    this.reactedAtUtc,
    required this.parseConfidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['carrier_message_id'] = Variable<int>(carrierMessageId);
    map['target_message_guid'] = Variable<String>(targetMessageGuid);
    map['action'] = Variable<String>(action);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || reactorHandleId != null) {
      map['reactor_handle_id'] = Variable<int>(reactorHandleId);
    }
    if (!nullToAbsent || reactedAtUtc != null) {
      map['reacted_at_utc'] = Variable<String>(reactedAtUtc);
    }
    map['parse_confidence'] = Variable<double>(parseConfidence);
    return map;
  }

  ImportReactionsCompanion toCompanion(bool nullToAbsent) {
    return ImportReactionsCompanion(
      id: Value(id),
      carrierMessageId: Value(carrierMessageId),
      targetMessageGuid: Value(targetMessageGuid),
      action: Value(action),
      kind: Value(kind),
      reactorHandleId: reactorHandleId == null && nullToAbsent
          ? const Value.absent()
          : Value(reactorHandleId),
      reactedAtUtc: reactedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(reactedAtUtc),
      parseConfidence: Value(parseConfidence),
    );
  }

  factory ImportReaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportReaction(
      id: serializer.fromJson<int>(json['id']),
      carrierMessageId: serializer.fromJson<int>(json['carrierMessageId']),
      targetMessageGuid: serializer.fromJson<String>(json['targetMessageGuid']),
      action: serializer.fromJson<String>(json['action']),
      kind: serializer.fromJson<String>(json['kind']),
      reactorHandleId: serializer.fromJson<int?>(json['reactorHandleId']),
      reactedAtUtc: serializer.fromJson<String?>(json['reactedAtUtc']),
      parseConfidence: serializer.fromJson<double>(json['parseConfidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'carrierMessageId': serializer.toJson<int>(carrierMessageId),
      'targetMessageGuid': serializer.toJson<String>(targetMessageGuid),
      'action': serializer.toJson<String>(action),
      'kind': serializer.toJson<String>(kind),
      'reactorHandleId': serializer.toJson<int?>(reactorHandleId),
      'reactedAtUtc': serializer.toJson<String?>(reactedAtUtc),
      'parseConfidence': serializer.toJson<double>(parseConfidence),
    };
  }

  ImportReaction copyWith({
    int? id,
    int? carrierMessageId,
    String? targetMessageGuid,
    String? action,
    String? kind,
    Value<int?> reactorHandleId = const Value.absent(),
    Value<String?> reactedAtUtc = const Value.absent(),
    double? parseConfidence,
  }) => ImportReaction(
    id: id ?? this.id,
    carrierMessageId: carrierMessageId ?? this.carrierMessageId,
    targetMessageGuid: targetMessageGuid ?? this.targetMessageGuid,
    action: action ?? this.action,
    kind: kind ?? this.kind,
    reactorHandleId: reactorHandleId.present
        ? reactorHandleId.value
        : this.reactorHandleId,
    reactedAtUtc: reactedAtUtc.present ? reactedAtUtc.value : this.reactedAtUtc,
    parseConfidence: parseConfidence ?? this.parseConfidence,
  );
  ImportReaction copyWithCompanion(ImportReactionsCompanion data) {
    return ImportReaction(
      id: data.id.present ? data.id.value : this.id,
      carrierMessageId: data.carrierMessageId.present
          ? data.carrierMessageId.value
          : this.carrierMessageId,
      targetMessageGuid: data.targetMessageGuid.present
          ? data.targetMessageGuid.value
          : this.targetMessageGuid,
      action: data.action.present ? data.action.value : this.action,
      kind: data.kind.present ? data.kind.value : this.kind,
      reactorHandleId: data.reactorHandleId.present
          ? data.reactorHandleId.value
          : this.reactorHandleId,
      reactedAtUtc: data.reactedAtUtc.present
          ? data.reactedAtUtc.value
          : this.reactedAtUtc,
      parseConfidence: data.parseConfidence.present
          ? data.parseConfidence.value
          : this.parseConfidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportReaction(')
          ..write('id: $id, ')
          ..write('carrierMessageId: $carrierMessageId, ')
          ..write('targetMessageGuid: $targetMessageGuid, ')
          ..write('action: $action, ')
          ..write('kind: $kind, ')
          ..write('reactorHandleId: $reactorHandleId, ')
          ..write('reactedAtUtc: $reactedAtUtc, ')
          ..write('parseConfidence: $parseConfidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    carrierMessageId,
    targetMessageGuid,
    action,
    kind,
    reactorHandleId,
    reactedAtUtc,
    parseConfidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportReaction &&
          other.id == this.id &&
          other.carrierMessageId == this.carrierMessageId &&
          other.targetMessageGuid == this.targetMessageGuid &&
          other.action == this.action &&
          other.kind == this.kind &&
          other.reactorHandleId == this.reactorHandleId &&
          other.reactedAtUtc == this.reactedAtUtc &&
          other.parseConfidence == this.parseConfidence);
}

class ImportReactionsCompanion extends UpdateCompanion<ImportReaction> {
  final Value<int> id;
  final Value<int> carrierMessageId;
  final Value<String> targetMessageGuid;
  final Value<String> action;
  final Value<String> kind;
  final Value<int?> reactorHandleId;
  final Value<String?> reactedAtUtc;
  final Value<double> parseConfidence;
  const ImportReactionsCompanion({
    this.id = const Value.absent(),
    this.carrierMessageId = const Value.absent(),
    this.targetMessageGuid = const Value.absent(),
    this.action = const Value.absent(),
    this.kind = const Value.absent(),
    this.reactorHandleId = const Value.absent(),
    this.reactedAtUtc = const Value.absent(),
    this.parseConfidence = const Value.absent(),
  });
  ImportReactionsCompanion.insert({
    this.id = const Value.absent(),
    required int carrierMessageId,
    required String targetMessageGuid,
    required String action,
    required String kind,
    this.reactorHandleId = const Value.absent(),
    this.reactedAtUtc = const Value.absent(),
    this.parseConfidence = const Value.absent(),
  }) : carrierMessageId = Value(carrierMessageId),
       targetMessageGuid = Value(targetMessageGuid),
       action = Value(action),
       kind = Value(kind);
  static Insertable<ImportReaction> custom({
    Expression<int>? id,
    Expression<int>? carrierMessageId,
    Expression<String>? targetMessageGuid,
    Expression<String>? action,
    Expression<String>? kind,
    Expression<int>? reactorHandleId,
    Expression<String>? reactedAtUtc,
    Expression<double>? parseConfidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carrierMessageId != null) 'carrier_message_id': carrierMessageId,
      if (targetMessageGuid != null) 'target_message_guid': targetMessageGuid,
      if (action != null) 'action': action,
      if (kind != null) 'kind': kind,
      if (reactorHandleId != null) 'reactor_handle_id': reactorHandleId,
      if (reactedAtUtc != null) 'reacted_at_utc': reactedAtUtc,
      if (parseConfidence != null) 'parse_confidence': parseConfidence,
    });
  }

  ImportReactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? carrierMessageId,
    Value<String>? targetMessageGuid,
    Value<String>? action,
    Value<String>? kind,
    Value<int?>? reactorHandleId,
    Value<String?>? reactedAtUtc,
    Value<double>? parseConfidence,
  }) {
    return ImportReactionsCompanion(
      id: id ?? this.id,
      carrierMessageId: carrierMessageId ?? this.carrierMessageId,
      targetMessageGuid: targetMessageGuid ?? this.targetMessageGuid,
      action: action ?? this.action,
      kind: kind ?? this.kind,
      reactorHandleId: reactorHandleId ?? this.reactorHandleId,
      reactedAtUtc: reactedAtUtc ?? this.reactedAtUtc,
      parseConfidence: parseConfidence ?? this.parseConfidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (carrierMessageId.present) {
      map['carrier_message_id'] = Variable<int>(carrierMessageId.value);
    }
    if (targetMessageGuid.present) {
      map['target_message_guid'] = Variable<String>(targetMessageGuid.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (reactorHandleId.present) {
      map['reactor_handle_id'] = Variable<int>(reactorHandleId.value);
    }
    if (reactedAtUtc.present) {
      map['reacted_at_utc'] = Variable<String>(reactedAtUtc.value);
    }
    if (parseConfidence.present) {
      map['parse_confidence'] = Variable<double>(parseConfidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportReactionsCompanion(')
          ..write('id: $id, ')
          ..write('carrierMessageId: $carrierMessageId, ')
          ..write('targetMessageGuid: $targetMessageGuid, ')
          ..write('action: $action, ')
          ..write('kind: $kind, ')
          ..write('reactorHandleId: $reactorHandleId, ')
          ..write('reactedAtUtc: $reactedAtUtc, ')
          ..write('parseConfidence: $parseConfidence')
          ..write(')'))
        .toString();
  }
}

class $ImportMessageLinksTable extends ImportMessageLinks
    with TableInfo<$ImportMessageLinksTable, ImportMessageLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportMessageLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<int> start = GeneratedColumn<int>(
    'start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<int> end = GeneratedColumn<int>(
    'end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, messageId, url, start, end];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportMessageLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportMessageLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportMessageLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start'],
      ),
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end'],
      ),
    );
  }

  @override
  $ImportMessageLinksTable createAlias(String alias) {
    return $ImportMessageLinksTable(attachedDatabase, alias);
  }
}

class ImportMessageLink extends DataClass
    implements Insertable<ImportMessageLink> {
  final int id;
  final int messageId;
  final String url;
  final int? start;
  final int? end;
  const ImportMessageLink({
    required this.id,
    required this.messageId,
    required this.url,
    this.start,
    this.end,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<int>(messageId);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || start != null) {
      map['start'] = Variable<int>(start);
    }
    if (!nullToAbsent || end != null) {
      map['end'] = Variable<int>(end);
    }
    return map;
  }

  ImportMessageLinksCompanion toCompanion(bool nullToAbsent) {
    return ImportMessageLinksCompanion(
      id: Value(id),
      messageId: Value(messageId),
      url: Value(url),
      start: start == null && nullToAbsent
          ? const Value.absent()
          : Value(start),
      end: end == null && nullToAbsent ? const Value.absent() : Value(end),
    );
  }

  factory ImportMessageLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportMessageLink(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<int>(json['messageId']),
      url: serializer.fromJson<String>(json['url']),
      start: serializer.fromJson<int?>(json['start']),
      end: serializer.fromJson<int?>(json['end']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<int>(messageId),
      'url': serializer.toJson<String>(url),
      'start': serializer.toJson<int?>(start),
      'end': serializer.toJson<int?>(end),
    };
  }

  ImportMessageLink copyWith({
    int? id,
    int? messageId,
    String? url,
    Value<int?> start = const Value.absent(),
    Value<int?> end = const Value.absent(),
  }) => ImportMessageLink(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    url: url ?? this.url,
    start: start.present ? start.value : this.start,
    end: end.present ? end.value : this.end,
  );
  ImportMessageLink copyWithCompanion(ImportMessageLinksCompanion data) {
    return ImportMessageLink(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      url: data.url.present ? data.url.value : this.url,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportMessageLink(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('url: $url, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, url, start, end);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportMessageLink &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.url == this.url &&
          other.start == this.start &&
          other.end == this.end);
}

class ImportMessageLinksCompanion extends UpdateCompanion<ImportMessageLink> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<String> url;
  final Value<int?> start;
  final Value<int?> end;
  const ImportMessageLinksCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.url = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
  });
  ImportMessageLinksCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    required String url,
    this.start = const Value.absent(),
    this.end = const Value.absent(),
  }) : messageId = Value(messageId),
       url = Value(url);
  static Insertable<ImportMessageLink> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? url,
    Expression<int>? start,
    Expression<int>? end,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (url != null) 'url': url,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
    });
  }

  ImportMessageLinksCompanion copyWith({
    Value<int>? id,
    Value<int>? messageId,
    Value<String>? url,
    Value<int?>? start,
    Value<int?>? end,
  }) {
    return ImportMessageLinksCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      url: url ?? this.url,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (start.present) {
      map['start'] = Variable<int>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<int>(end.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportMessageLinksCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('url: $url, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }
}

class $ImportContactToChatHandleTable extends ImportContactToChatHandle
    with
        TableInfo<
          $ImportContactToChatHandleTable,
          ImportContactToChatHandleData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportContactToChatHandleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactZPkMeta = const VerificationMeta(
    'contactZPk',
  );
  @override
  late final GeneratedColumn<int> contactZPk = GeneratedColumn<int>(
    'contact_Z_PK',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (Z_PK) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _chatHandleIdMeta = const VerificationMeta(
    'chatHandleId',
  );
  @override
  late final GeneratedColumn<int> chatHandleId = GeneratedColumn<int>(
    'chat_handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES import_batches (id) ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, contactZPk, chatHandleId, batchId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_to_chat_handle';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportContactToChatHandleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_Z_PK')) {
      context.handle(
        _contactZPkMeta,
        contactZPk.isAcceptableOrUnknown(
          data['contact_Z_PK']!,
          _contactZPkMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactZPkMeta);
    }
    if (data.containsKey('chat_handle_id')) {
      context.handle(
        _chatHandleIdMeta,
        chatHandleId.isAcceptableOrUnknown(
          data['chat_handle_id']!,
          _chatHandleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatHandleIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {contactZPk, chatHandleId},
  ];
  @override
  ImportContactToChatHandleData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportContactToChatHandleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactZPk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_Z_PK'],
      )!,
      chatHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_handle_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      )!,
    );
  }

  @override
  $ImportContactToChatHandleTable createAlias(String alias) {
    return $ImportContactToChatHandleTable(attachedDatabase, alias);
  }
}

class ImportContactToChatHandleData extends DataClass
    implements Insertable<ImportContactToChatHandleData> {
  final int id;
  final int contactZPk;
  final int chatHandleId;
  final int batchId;
  const ImportContactToChatHandleData({
    required this.id,
    required this.contactZPk,
    required this.chatHandleId,
    required this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_Z_PK'] = Variable<int>(contactZPk);
    map['chat_handle_id'] = Variable<int>(chatHandleId);
    map['batch_id'] = Variable<int>(batchId);
    return map;
  }

  ImportContactToChatHandleCompanion toCompanion(bool nullToAbsent) {
    return ImportContactToChatHandleCompanion(
      id: Value(id),
      contactZPk: Value(contactZPk),
      chatHandleId: Value(chatHandleId),
      batchId: Value(batchId),
    );
  }

  factory ImportContactToChatHandleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportContactToChatHandleData(
      id: serializer.fromJson<int>(json['id']),
      contactZPk: serializer.fromJson<int>(json['contactZPk']),
      chatHandleId: serializer.fromJson<int>(json['chatHandleId']),
      batchId: serializer.fromJson<int>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactZPk': serializer.toJson<int>(contactZPk),
      'chatHandleId': serializer.toJson<int>(chatHandleId),
      'batchId': serializer.toJson<int>(batchId),
    };
  }

  ImportContactToChatHandleData copyWith({
    int? id,
    int? contactZPk,
    int? chatHandleId,
    int? batchId,
  }) => ImportContactToChatHandleData(
    id: id ?? this.id,
    contactZPk: contactZPk ?? this.contactZPk,
    chatHandleId: chatHandleId ?? this.chatHandleId,
    batchId: batchId ?? this.batchId,
  );
  ImportContactToChatHandleData copyWithCompanion(
    ImportContactToChatHandleCompanion data,
  ) {
    return ImportContactToChatHandleData(
      id: data.id.present ? data.id.value : this.id,
      contactZPk: data.contactZPk.present
          ? data.contactZPk.value
          : this.contactZPk,
      chatHandleId: data.chatHandleId.present
          ? data.chatHandleId.value
          : this.chatHandleId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportContactToChatHandleData(')
          ..write('id: $id, ')
          ..write('contactZPk: $contactZPk, ')
          ..write('chatHandleId: $chatHandleId, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactZPk, chatHandleId, batchId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportContactToChatHandleData &&
          other.id == this.id &&
          other.contactZPk == this.contactZPk &&
          other.chatHandleId == this.chatHandleId &&
          other.batchId == this.batchId);
}

class ImportContactToChatHandleCompanion
    extends UpdateCompanion<ImportContactToChatHandleData> {
  final Value<int> id;
  final Value<int> contactZPk;
  final Value<int> chatHandleId;
  final Value<int> batchId;
  const ImportContactToChatHandleCompanion({
    this.id = const Value.absent(),
    this.contactZPk = const Value.absent(),
    this.chatHandleId = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  ImportContactToChatHandleCompanion.insert({
    this.id = const Value.absent(),
    required int contactZPk,
    required int chatHandleId,
    required int batchId,
  }) : contactZPk = Value(contactZPk),
       chatHandleId = Value(chatHandleId),
       batchId = Value(batchId);
  static Insertable<ImportContactToChatHandleData> custom({
    Expression<int>? id,
    Expression<int>? contactZPk,
    Expression<int>? chatHandleId,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactZPk != null) 'contact_Z_PK': contactZPk,
      if (chatHandleId != null) 'chat_handle_id': chatHandleId,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  ImportContactToChatHandleCompanion copyWith({
    Value<int>? id,
    Value<int>? contactZPk,
    Value<int>? chatHandleId,
    Value<int>? batchId,
  }) {
    return ImportContactToChatHandleCompanion(
      id: id ?? this.id,
      contactZPk: contactZPk ?? this.contactZPk,
      chatHandleId: chatHandleId ?? this.chatHandleId,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactZPk.present) {
      map['contact_Z_PK'] = Variable<int>(contactZPk.value);
    }
    if (chatHandleId.present) {
      map['chat_handle_id'] = Variable<int>(chatHandleId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportContactToChatHandleCompanion(')
          ..write('id: $id, ')
          ..write('contactZPk: $contactZPk, ')
          ..write('chatHandleId: $chatHandleId, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

abstract class _$ImportDatabase extends GeneratedDatabase {
  _$ImportDatabase(QueryExecutor e) : super(e);
  $ImportDatabaseManager get managers => $ImportDatabaseManager(this);
  late final $ImportSchemaMigrationsTable importSchemaMigrations =
      $ImportSchemaMigrationsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $ImportSourceFilesTable importSourceFiles =
      $ImportSourceFilesTable(this);
  late final $ImportLogsTable importLogs = $ImportLogsTable(this);
  late final $ImportContactsTable importContacts = $ImportContactsTable(this);
  late final $ImportContactPhoneEmailTable importContactPhoneEmail =
      $ImportContactPhoneEmailTable(this);
  late final $ImportHandlesTable importHandles = $ImportHandlesTable(this);
  late final $ImportChatsTable importChats = $ImportChatsTable(this);
  late final $ImportChatToHandleTable importChatToHandle =
      $ImportChatToHandleTable(this);
  late final $ImportMessagesTable importMessages = $ImportMessagesTable(this);
  late final $ImportChatToMessageTable importChatToMessage =
      $ImportChatToMessageTable(this);
  late final $ImportAttachmentsTable importAttachments =
      $ImportAttachmentsTable(this);
  late final $ImportMessageAttachmentsTable importMessageAttachments =
      $ImportMessageAttachmentsTable(this);
  late final $ImportReactionsTable importReactions = $ImportReactionsTable(
    this,
  );
  late final $ImportMessageLinksTable importMessageLinks =
      $ImportMessageLinksTable(this);
  late final $ImportContactToChatHandleTable importContactToChatHandle =
      $ImportContactToChatHandleTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    importSchemaMigrations,
    importBatches,
    importSourceFiles,
    importLogs,
    importContacts,
    importContactPhoneEmail,
    importHandles,
    importChats,
    importChatToHandle,
    importMessages,
    importChatToMessage,
    importAttachments,
    importMessageAttachments,
    importReactions,
    importMessageLinks,
    importContactToChatHandle,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('source_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'import_batches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('import_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_phone_email', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_to_handle', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_to_handle', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_to_message', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_to_message', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'attachments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_to_chat_handle', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_to_chat_handle', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ImportSchemaMigrationsTableCreateCompanionBuilder =
    ImportSchemaMigrationsCompanion Function({
      required int version,
      required String appliedAtUtc,
      Value<int> rowid,
    });
typedef $$ImportSchemaMigrationsTableUpdateCompanionBuilder =
    ImportSchemaMigrationsCompanion Function({
      Value<int> version,
      Value<String> appliedAtUtc,
      Value<int> rowid,
    });

class $$ImportSchemaMigrationsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportSchemaMigrationsTable> {
  $$ImportSchemaMigrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportSchemaMigrationsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportSchemaMigrationsTable> {
  $$ImportSchemaMigrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportSchemaMigrationsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportSchemaMigrationsTable> {
  $$ImportSchemaMigrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => column,
  );
}

class $$ImportSchemaMigrationsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportSchemaMigrationsTable,
          ImportSchemaMigration,
          $$ImportSchemaMigrationsTableFilterComposer,
          $$ImportSchemaMigrationsTableOrderingComposer,
          $$ImportSchemaMigrationsTableAnnotationComposer,
          $$ImportSchemaMigrationsTableCreateCompanionBuilder,
          $$ImportSchemaMigrationsTableUpdateCompanionBuilder,
          (
            ImportSchemaMigration,
            BaseReferences<
              _$ImportDatabase,
              $ImportSchemaMigrationsTable,
              ImportSchemaMigration
            >,
          ),
          ImportSchemaMigration,
          PrefetchHooks Function()
        > {
  $$ImportSchemaMigrationsTableTableManager(
    _$ImportDatabase db,
    $ImportSchemaMigrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportSchemaMigrationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportSchemaMigrationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportSchemaMigrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                Value<String> appliedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportSchemaMigrationsCompanion(
                version: version,
                appliedAtUtc: appliedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int version,
                required String appliedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ImportSchemaMigrationsCompanion.insert(
                version: version,
                appliedAtUtc: appliedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportSchemaMigrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportSchemaMigrationsTable,
      ImportSchemaMigration,
      $$ImportSchemaMigrationsTableFilterComposer,
      $$ImportSchemaMigrationsTableOrderingComposer,
      $$ImportSchemaMigrationsTableAnnotationComposer,
      $$ImportSchemaMigrationsTableCreateCompanionBuilder,
      $$ImportSchemaMigrationsTableUpdateCompanionBuilder,
      (
        ImportSchemaMigration,
        BaseReferences<
          _$ImportDatabase,
          $ImportSchemaMigrationsTable,
          ImportSchemaMigration
        >,
      ),
      ImportSchemaMigration,
      PrefetchHooks Function()
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<int> id,
      required String startedAtUtc,
      Value<String?> finishedAtUtc,
      Value<String?> sourceChatDb,
      Value<String?> sourceAddressbook,
      Value<String?> hostInfoJson,
      Value<String?> notes,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<int> id,
      Value<String> startedAtUtc,
      Value<String?> finishedAtUtc,
      Value<String?> sourceChatDb,
      Value<String?> sourceAddressbook,
      Value<String?> hostInfoJson,
      Value<String?> notes,
    });

final class $$ImportBatchesTableReferences
    extends
        BaseReferences<_$ImportDatabase, $ImportBatchesTable, ImportBatche> {
  $$ImportBatchesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ImportSourceFilesTable, List<ImportSourceFile>>
  _importSourceFilesRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importSourceFiles,
        aliasName: $_aliasNameGenerator(
          db.importBatches.id,
          db.importSourceFiles.batchId,
        ),
      );

  $$ImportSourceFilesTableProcessedTableManager get importSourceFilesRefs {
    final manager = $$ImportSourceFilesTableTableManager(
      $_db,
      $_db.importSourceFiles,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importSourceFilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportLogsTable, List<ImportLog>>
  _importLogsRefsTable(_$ImportDatabase db) => MultiTypedResultKey.fromTable(
    db.importLogs,
    aliasName: $_aliasNameGenerator(db.importBatches.id, db.importLogs.batchId),
  );

  $$ImportLogsTableProcessedTableManager get importLogsRefs {
    final manager = $$ImportLogsTableTableManager(
      $_db,
      $_db.importLogs,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportContactsTable, List<ImportContact>>
  _importContactsRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importContacts,
        aliasName: $_aliasNameGenerator(
          db.importBatches.id,
          db.importContacts.batchId,
        ),
      );

  $$ImportContactsTableProcessedTableManager get importContactsRefs {
    final manager = $$ImportContactsTableTableManager(
      $_db,
      $_db.importContacts,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importContactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportHandlesTable, List<ImportHandle>>
  _importHandlesRefsTable(_$ImportDatabase db) => MultiTypedResultKey.fromTable(
    db.importHandles,
    aliasName: $_aliasNameGenerator(
      db.importBatches.id,
      db.importHandles.batchId,
    ),
  );

  $$ImportHandlesTableProcessedTableManager get importHandlesRefs {
    final manager = $$ImportHandlesTableTableManager(
      $_db,
      $_db.importHandles,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importHandlesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportChatsTable, List<ImportChat>>
  _importChatsRefsTable(_$ImportDatabase db) => MultiTypedResultKey.fromTable(
    db.importChats,
    aliasName: $_aliasNameGenerator(
      db.importBatches.id,
      db.importChats.batchId,
    ),
  );

  $$ImportChatsTableProcessedTableManager get importChatsRefs {
    final manager = $$ImportChatsTableTableManager(
      $_db,
      $_db.importChats,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importChatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportMessagesTable, List<ImportMessage>>
  _importMessagesRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importMessages,
        aliasName: $_aliasNameGenerator(
          db.importBatches.id,
          db.importMessages.batchId,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get importMessagesRefs {
    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportAttachmentsTable, List<ImportAttachment>>
  _importAttachmentsRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importAttachments,
        aliasName: $_aliasNameGenerator(
          db.importBatches.id,
          db.importAttachments.batchId,
        ),
      );

  $$ImportAttachmentsTableProcessedTableManager get importAttachmentsRefs {
    final manager = $$ImportAttachmentsTableTableManager(
      $_db,
      $_db.importAttachments,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImportContactToChatHandleTable,
    List<ImportContactToChatHandleData>
  >
  _importContactToChatHandleRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importContactToChatHandle,
        aliasName: $_aliasNameGenerator(
          db.importBatches.id,
          db.importContactToChatHandle.batchId,
        ),
      );

  $$ImportContactToChatHandleTableProcessedTableManager
  get importContactToChatHandleRefs {
    final manager = $$ImportContactToChatHandleTableTableManager(
      $_db,
      $_db.importContactToChatHandle,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importContactToChatHandleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportBatchesTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finishedAtUtc => $composableBuilder(
    column: $table.finishedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceChatDb => $composableBuilder(
    column: $table.sourceChatDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceAddressbook => $composableBuilder(
    column: $table.sourceAddressbook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostInfoJson => $composableBuilder(
    column: $table.hostInfoJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> importSourceFilesRefs(
    Expression<bool> Function($$ImportSourceFilesTableFilterComposer f) f,
  ) {
    final $$ImportSourceFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importSourceFiles,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportSourceFilesTableFilterComposer(
            $db: $db,
            $table: $db.importSourceFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importLogsRefs(
    Expression<bool> Function($$ImportLogsTableFilterComposer f) f,
  ) {
    final $$ImportLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importLogs,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportLogsTableFilterComposer(
            $db: $db,
            $table: $db.importLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importContactsRefs(
    Expression<bool> Function($$ImportContactsTableFilterComposer f) f,
  ) {
    final $$ImportContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableFilterComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importHandlesRefs(
    Expression<bool> Function($$ImportHandlesTableFilterComposer f) f,
  ) {
    final $$ImportHandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableFilterComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importChatsRefs(
    Expression<bool> Function($$ImportChatsTableFilterComposer f) f,
  ) {
    final $$ImportChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableFilterComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importMessagesRefs(
    Expression<bool> Function($$ImportMessagesTableFilterComposer f) f,
  ) {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importAttachmentsRefs(
    Expression<bool> Function($$ImportAttachmentsTableFilterComposer f) f,
  ) {
    final $$ImportAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importAttachments,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.importAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importContactToChatHandleRefs(
    Expression<bool> Function($$ImportContactToChatHandleTableFilterComposer f)
    f,
  ) {
    final $$ImportContactToChatHandleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importContactToChatHandle,
          getReferencedColumn: (t) => t.batchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactToChatHandleTableFilterComposer(
                $db: $db,
                $table: $db.importContactToChatHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishedAtUtc => $composableBuilder(
    column: $table.finishedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceChatDb => $composableBuilder(
    column: $table.sourceChatDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceAddressbook => $composableBuilder(
    column: $table.sourceAddressbook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostInfoJson => $composableBuilder(
    column: $table.hostInfoJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finishedAtUtc => $composableBuilder(
    column: $table.finishedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceChatDb => $composableBuilder(
    column: $table.sourceChatDb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceAddressbook => $composableBuilder(
    column: $table.sourceAddressbook,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hostInfoJson => $composableBuilder(
    column: $table.hostInfoJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> importSourceFilesRefs<T extends Object>(
    Expression<T> Function($$ImportSourceFilesTableAnnotationComposer a) f,
  ) {
    final $$ImportSourceFilesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importSourceFiles,
          getReferencedColumn: (t) => t.batchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportSourceFilesTableAnnotationComposer(
                $db: $db,
                $table: $db.importSourceFiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importLogsRefs<T extends Object>(
    Expression<T> Function($$ImportLogsTableAnnotationComposer a) f,
  ) {
    final $$ImportLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importLogs,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.importLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importContactsRefs<T extends Object>(
    Expression<T> Function($$ImportContactsTableAnnotationComposer a) f,
  ) {
    final $$ImportContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importHandlesRefs<T extends Object>(
    Expression<T> Function($$ImportHandlesTableAnnotationComposer a) f,
  ) {
    final $$ImportHandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importChatsRefs<T extends Object>(
    Expression<T> Function($$ImportChatsTableAnnotationComposer a) f,
  ) {
    final $$ImportChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importMessagesRefs<T extends Object>(
    Expression<T> Function($$ImportMessagesTableAnnotationComposer a) f,
  ) {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importAttachmentsRefs<T extends Object>(
    Expression<T> Function($$ImportAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$ImportAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importAttachments,
          getReferencedColumn: (t) => t.batchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.importAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importContactToChatHandleRefs<T extends Object>(
    Expression<T> Function($$ImportContactToChatHandleTableAnnotationComposer a)
    f,
  ) {
    final $$ImportContactToChatHandleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importContactToChatHandle,
          getReferencedColumn: (t) => t.batchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactToChatHandleTableAnnotationComposer(
                $db: $db,
                $table: $db.importContactToChatHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportBatchesTable,
          ImportBatche,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (ImportBatche, $$ImportBatchesTableReferences),
          ImportBatche,
          PrefetchHooks Function({
            bool importSourceFilesRefs,
            bool importLogsRefs,
            bool importContactsRefs,
            bool importHandlesRefs,
            bool importChatsRefs,
            bool importMessagesRefs,
            bool importAttachmentsRefs,
            bool importContactToChatHandleRefs,
          })
        > {
  $$ImportBatchesTableTableManager(
    _$ImportDatabase db,
    $ImportBatchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startedAtUtc = const Value.absent(),
                Value<String?> finishedAtUtc = const Value.absent(),
                Value<String?> sourceChatDb = const Value.absent(),
                Value<String?> sourceAddressbook = const Value.absent(),
                Value<String?> hostInfoJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                startedAtUtc: startedAtUtc,
                finishedAtUtc: finishedAtUtc,
                sourceChatDb: sourceChatDb,
                sourceAddressbook: sourceAddressbook,
                hostInfoJson: hostInfoJson,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startedAtUtc,
                Value<String?> finishedAtUtc = const Value.absent(),
                Value<String?> sourceChatDb = const Value.absent(),
                Value<String?> sourceAddressbook = const Value.absent(),
                Value<String?> hostInfoJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                startedAtUtc: startedAtUtc,
                finishedAtUtc: finishedAtUtc,
                sourceChatDb: sourceChatDb,
                sourceAddressbook: sourceAddressbook,
                hostInfoJson: hostInfoJson,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                importSourceFilesRefs = false,
                importLogsRefs = false,
                importContactsRefs = false,
                importHandlesRefs = false,
                importChatsRefs = false,
                importMessagesRefs = false,
                importAttachmentsRefs = false,
                importContactToChatHandleRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importSourceFilesRefs) db.importSourceFiles,
                    if (importLogsRefs) db.importLogs,
                    if (importContactsRefs) db.importContacts,
                    if (importHandlesRefs) db.importHandles,
                    if (importChatsRefs) db.importChats,
                    if (importMessagesRefs) db.importMessages,
                    if (importAttachmentsRefs) db.importAttachments,
                    if (importContactToChatHandleRefs)
                      db.importContactToChatHandle,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importSourceFilesRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportSourceFile
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importSourceFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importSourceFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importLogsRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportLog
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importContactsRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportContact
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importContactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importContactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importHandlesRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportHandle
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importHandlesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importHandlesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importChatsRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportChat
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importChatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importChatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importMessagesRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importAttachmentsRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importContactToChatHandleRefs)
                        await $_getPrefetchedData<
                          ImportBatche,
                          $ImportBatchesTable,
                          ImportContactToChatHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportBatchesTableReferences
                              ._importContactToChatHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).importContactToChatHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportBatchesTable,
      ImportBatche,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (ImportBatche, $$ImportBatchesTableReferences),
      ImportBatche,
      PrefetchHooks Function({
        bool importSourceFilesRefs,
        bool importLogsRefs,
        bool importContactsRefs,
        bool importHandlesRefs,
        bool importChatsRefs,
        bool importMessagesRefs,
        bool importAttachmentsRefs,
        bool importContactToChatHandleRefs,
      })
    >;
typedef $$ImportSourceFilesTableCreateCompanionBuilder =
    ImportSourceFilesCompanion Function({
      Value<int> id,
      required int batchId,
      required String path,
      Value<String?> sha256Hex,
      Value<int?> sizeBytes,
      Value<String?> mtimeUtc,
    });
typedef $$ImportSourceFilesTableUpdateCompanionBuilder =
    ImportSourceFilesCompanion Function({
      Value<int> id,
      Value<int> batchId,
      Value<String> path,
      Value<String?> sha256Hex,
      Value<int?> sizeBytes,
      Value<String?> mtimeUtc,
    });

final class $$ImportSourceFilesTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportSourceFilesTable,
          ImportSourceFile
        > {
  $$ImportSourceFilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importSourceFiles.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportSourceFilesTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportSourceFilesTable> {
  $$ImportSourceFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mtimeUtc => $composableBuilder(
    column: $table.mtimeUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportSourceFilesTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportSourceFilesTable> {
  $$ImportSourceFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mtimeUtc => $composableBuilder(
    column: $table.mtimeUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportSourceFilesTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportSourceFilesTable> {
  $$ImportSourceFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get sha256Hex =>
      $composableBuilder(column: $table.sha256Hex, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get mtimeUtc =>
      $composableBuilder(column: $table.mtimeUtc, builder: (column) => column);

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportSourceFilesTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportSourceFilesTable,
          ImportSourceFile,
          $$ImportSourceFilesTableFilterComposer,
          $$ImportSourceFilesTableOrderingComposer,
          $$ImportSourceFilesTableAnnotationComposer,
          $$ImportSourceFilesTableCreateCompanionBuilder,
          $$ImportSourceFilesTableUpdateCompanionBuilder,
          (ImportSourceFile, $$ImportSourceFilesTableReferences),
          ImportSourceFile,
          PrefetchHooks Function({bool batchId})
        > {
  $$ImportSourceFilesTableTableManager(
    _$ImportDatabase db,
    $ImportSourceFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportSourceFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportSourceFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportSourceFilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> batchId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> sha256Hex = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> mtimeUtc = const Value.absent(),
              }) => ImportSourceFilesCompanion(
                id: id,
                batchId: batchId,
                path: path,
                sha256Hex: sha256Hex,
                sizeBytes: sizeBytes,
                mtimeUtc: mtimeUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int batchId,
                required String path,
                Value<String?> sha256Hex = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> mtimeUtc = const Value.absent(),
              }) => ImportSourceFilesCompanion.insert(
                id: id,
                batchId: batchId,
                path: path,
                sha256Hex: sha256Hex,
                sizeBytes: sizeBytes,
                mtimeUtc: mtimeUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportSourceFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({batchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (batchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.batchId,
                                referencedTable:
                                    $$ImportSourceFilesTableReferences
                                        ._batchIdTable(db),
                                referencedColumn:
                                    $$ImportSourceFilesTableReferences
                                        ._batchIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportSourceFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportSourceFilesTable,
      ImportSourceFile,
      $$ImportSourceFilesTableFilterComposer,
      $$ImportSourceFilesTableOrderingComposer,
      $$ImportSourceFilesTableAnnotationComposer,
      $$ImportSourceFilesTableCreateCompanionBuilder,
      $$ImportSourceFilesTableUpdateCompanionBuilder,
      (ImportSourceFile, $$ImportSourceFilesTableReferences),
      ImportSourceFile,
      PrefetchHooks Function({bool batchId})
    >;
typedef $$ImportLogsTableCreateCompanionBuilder =
    ImportLogsCompanion Function({
      Value<int> id,
      Value<int?> batchId,
      required String atUtc,
      required String level,
      required String message,
      Value<String?> contextJson,
    });
typedef $$ImportLogsTableUpdateCompanionBuilder =
    ImportLogsCompanion Function({
      Value<int> id,
      Value<int?> batchId,
      Value<String> atUtc,
      Value<String> level,
      Value<String> message,
      Value<String?> contextJson,
    });

final class $$ImportLogsTableReferences
    extends BaseReferences<_$ImportDatabase, $ImportLogsTable, ImportLog> {
  $$ImportLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importLogs.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager? get batchId {
    final $_column = $_itemColumn<int>('batch_id');
    if ($_column == null) return null;
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportLogsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportLogsTable> {
  $$ImportLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportLogsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportLogsTable> {
  $$ImportLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportLogsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportLogsTable> {
  $$ImportLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => column,
  );

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportLogsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportLogsTable,
          ImportLog,
          $$ImportLogsTableFilterComposer,
          $$ImportLogsTableOrderingComposer,
          $$ImportLogsTableAnnotationComposer,
          $$ImportLogsTableCreateCompanionBuilder,
          $$ImportLogsTableUpdateCompanionBuilder,
          (ImportLog, $$ImportLogsTableReferences),
          ImportLog,
          PrefetchHooks Function({bool batchId})
        > {
  $$ImportLogsTableTableManager(_$ImportDatabase db, $ImportLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<String> atUtc = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> contextJson = const Value.absent(),
              }) => ImportLogsCompanion(
                id: id,
                batchId: batchId,
                atUtc: atUtc,
                level: level,
                message: message,
                contextJson: contextJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                required String atUtc,
                required String level,
                required String message,
                Value<String?> contextJson = const Value.absent(),
              }) => ImportLogsCompanion.insert(
                id: id,
                batchId: batchId,
                atUtc: atUtc,
                level: level,
                message: message,
                contextJson: contextJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({batchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (batchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.batchId,
                                referencedTable: $$ImportLogsTableReferences
                                    ._batchIdTable(db),
                                referencedColumn: $$ImportLogsTableReferences
                                    ._batchIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportLogsTable,
      ImportLog,
      $$ImportLogsTableFilterComposer,
      $$ImportLogsTableOrderingComposer,
      $$ImportLogsTableAnnotationComposer,
      $$ImportLogsTableCreateCompanionBuilder,
      $$ImportLogsTableUpdateCompanionBuilder,
      (ImportLog, $$ImportLogsTableReferences),
      ImportLog,
      PrefetchHooks Function({bool batchId})
    >;
typedef $$ImportContactsTableCreateCompanionBuilder =
    ImportContactsCompanion Function({
      Value<int> zPk,
      Value<String?> displayName,
      Value<String?> givenName,
      Value<String?> familyName,
      Value<String?> organization,
      Value<bool> isOrganization,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      required int batchId,
    });
typedef $$ImportContactsTableUpdateCompanionBuilder =
    ImportContactsCompanion Function({
      Value<int> zPk,
      Value<String?> displayName,
      Value<String?> givenName,
      Value<String?> familyName,
      Value<String?> organization,
      Value<bool> isOrganization,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<int> batchId,
    });

final class $$ImportContactsTableReferences
    extends
        BaseReferences<_$ImportDatabase, $ImportContactsTable, ImportContact> {
  $$ImportContactsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importContacts.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ImportContactPhoneEmailTable,
    List<ImportContactPhoneEmailData>
  >
  _importContactPhoneEmailRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importContactPhoneEmail,
        aliasName: $_aliasNameGenerator(
          db.importContacts.zPk,
          db.importContactPhoneEmail.ownerZPk,
        ),
      );

  $$ImportContactPhoneEmailTableProcessedTableManager
  get importContactPhoneEmailRefs {
    final manager = $$ImportContactPhoneEmailTableTableManager(
      $_db,
      $_db.importContactPhoneEmail,
    ).filter((f) => f.ownerZPk.zPk.sqlEquals($_itemColumn<int>('Z_PK')!));

    final cache = $_typedResult.readTableOrNull(
      _importContactPhoneEmailRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImportContactToChatHandleTable,
    List<ImportContactToChatHandleData>
  >
  _importContactToChatHandleRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importContactToChatHandle,
        aliasName: $_aliasNameGenerator(
          db.importContacts.zPk,
          db.importContactToChatHandle.contactZPk,
        ),
      );

  $$ImportContactToChatHandleTableProcessedTableManager
  get importContactToChatHandleRefs {
    final manager = $$ImportContactToChatHandleTableTableManager(
      $_db,
      $_db.importContactToChatHandle,
    ).filter((f) => f.contactZPk.zPk.sqlEquals($_itemColumn<int>('Z_PK')!));

    final cache = $_typedResult.readTableOrNull(
      _importContactToChatHandleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportContactsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportContactsTable> {
  $$ImportContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get zPk => $composableBuilder(
    column: $table.zPk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get givenName => $composableBuilder(
    column: $table.givenName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOrganization => $composableBuilder(
    column: $table.isOrganization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importContactPhoneEmailRefs(
    Expression<bool> Function($$ImportContactPhoneEmailTableFilterComposer f) f,
  ) {
    final $$ImportContactPhoneEmailTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.zPk,
          referencedTable: $db.importContactPhoneEmail,
          getReferencedColumn: (t) => t.ownerZPk,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactPhoneEmailTableFilterComposer(
                $db: $db,
                $table: $db.importContactPhoneEmail,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> importContactToChatHandleRefs(
    Expression<bool> Function($$ImportContactToChatHandleTableFilterComposer f)
    f,
  ) {
    final $$ImportContactToChatHandleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.zPk,
          referencedTable: $db.importContactToChatHandle,
          getReferencedColumn: (t) => t.contactZPk,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactToChatHandleTableFilterComposer(
                $db: $db,
                $table: $db.importContactToChatHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportContactsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportContactsTable> {
  $$ImportContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get zPk => $composableBuilder(
    column: $table.zPk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenName => $composableBuilder(
    column: $table.givenName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOrganization => $composableBuilder(
    column: $table.isOrganization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportContactsTable> {
  $$ImportContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get zPk =>
      $composableBuilder(column: $table.zPk, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get givenName =>
      $composableBuilder(column: $table.givenName, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOrganization => $composableBuilder(
    column: $table.isOrganization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importContactPhoneEmailRefs<T extends Object>(
    Expression<T> Function($$ImportContactPhoneEmailTableAnnotationComposer a)
    f,
  ) {
    final $$ImportContactPhoneEmailTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.zPk,
          referencedTable: $db.importContactPhoneEmail,
          getReferencedColumn: (t) => t.ownerZPk,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactPhoneEmailTableAnnotationComposer(
                $db: $db,
                $table: $db.importContactPhoneEmail,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importContactToChatHandleRefs<T extends Object>(
    Expression<T> Function($$ImportContactToChatHandleTableAnnotationComposer a)
    f,
  ) {
    final $$ImportContactToChatHandleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.zPk,
          referencedTable: $db.importContactToChatHandle,
          getReferencedColumn: (t) => t.contactZPk,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactToChatHandleTableAnnotationComposer(
                $db: $db,
                $table: $db.importContactToChatHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportContactsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportContactsTable,
          ImportContact,
          $$ImportContactsTableFilterComposer,
          $$ImportContactsTableOrderingComposer,
          $$ImportContactsTableAnnotationComposer,
          $$ImportContactsTableCreateCompanionBuilder,
          $$ImportContactsTableUpdateCompanionBuilder,
          (ImportContact, $$ImportContactsTableReferences),
          ImportContact,
          PrefetchHooks Function({
            bool batchId,
            bool importContactPhoneEmailRefs,
            bool importContactToChatHandleRefs,
          })
        > {
  $$ImportContactsTableTableManager(
    _$ImportDatabase db,
    $ImportContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> zPk = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> givenName = const Value.absent(),
                Value<String?> familyName = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<bool> isOrganization = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<int> batchId = const Value.absent(),
              }) => ImportContactsCompanion(
                zPk: zPk,
                displayName: displayName,
                givenName: givenName,
                familyName: familyName,
                organization: organization,
                isOrganization: isOrganization,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> zPk = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> givenName = const Value.absent(),
                Value<String?> familyName = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<bool> isOrganization = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                required int batchId,
              }) => ImportContactsCompanion.insert(
                zPk: zPk,
                displayName: displayName,
                givenName: givenName,
                familyName: familyName,
                organization: organization,
                isOrganization: isOrganization,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                batchId = false,
                importContactPhoneEmailRefs = false,
                importContactToChatHandleRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importContactPhoneEmailRefs) db.importContactPhoneEmail,
                    if (importContactToChatHandleRefs)
                      db.importContactToChatHandle,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable:
                                        $$ImportContactsTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$ImportContactsTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importContactPhoneEmailRefs)
                        await $_getPrefetchedData<
                          ImportContact,
                          $ImportContactsTable,
                          ImportContactPhoneEmailData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportContactsTableReferences
                              ._importContactPhoneEmailRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).importContactPhoneEmailRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerZPk == item.zPk,
                              ),
                          typedResults: items,
                        ),
                      if (importContactToChatHandleRefs)
                        await $_getPrefetchedData<
                          ImportContact,
                          $ImportContactsTable,
                          ImportContactToChatHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportContactsTableReferences
                              ._importContactToChatHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).importContactToChatHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contactZPk == item.zPk,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportContactsTable,
      ImportContact,
      $$ImportContactsTableFilterComposer,
      $$ImportContactsTableOrderingComposer,
      $$ImportContactsTableAnnotationComposer,
      $$ImportContactsTableCreateCompanionBuilder,
      $$ImportContactsTableUpdateCompanionBuilder,
      (ImportContact, $$ImportContactsTableReferences),
      ImportContact,
      PrefetchHooks Function({
        bool batchId,
        bool importContactPhoneEmailRefs,
        bool importContactToChatHandleRefs,
      })
    >;
typedef $$ImportContactPhoneEmailTableCreateCompanionBuilder =
    ImportContactPhoneEmailCompanion Function({
      Value<int> id,
      required int ownerZPk,
      required String kind,
      required String value,
      Value<String?> label,
    });
typedef $$ImportContactPhoneEmailTableUpdateCompanionBuilder =
    ImportContactPhoneEmailCompanion Function({
      Value<int> id,
      Value<int> ownerZPk,
      Value<String> kind,
      Value<String> value,
      Value<String?> label,
    });

final class $$ImportContactPhoneEmailTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportContactPhoneEmailTable,
          ImportContactPhoneEmailData
        > {
  $$ImportContactPhoneEmailTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportContactsTable _ownerZPkTable(_$ImportDatabase db) =>
      db.importContacts.createAlias(
        $_aliasNameGenerator(
          db.importContactPhoneEmail.ownerZPk,
          db.importContacts.zPk,
        ),
      );

  $$ImportContactsTableProcessedTableManager get ownerZPk {
    final $_column = $_itemColumn<int>('OWNER_Z_PK')!;

    final manager = $$ImportContactsTableTableManager(
      $_db,
      $_db.importContacts,
    ).filter((f) => f.zPk.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerZPkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportContactPhoneEmailTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportContactPhoneEmailTable> {
  $$ImportContactPhoneEmailTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportContactsTableFilterComposer get ownerZPk {
    final $$ImportContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerZPk,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.zPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableFilterComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactPhoneEmailTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportContactPhoneEmailTable> {
  $$ImportContactPhoneEmailTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportContactsTableOrderingComposer get ownerZPk {
    final $$ImportContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerZPk,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.zPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableOrderingComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactPhoneEmailTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportContactPhoneEmailTable> {
  $$ImportContactPhoneEmailTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$ImportContactsTableAnnotationComposer get ownerZPk {
    final $$ImportContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerZPk,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.zPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactPhoneEmailTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportContactPhoneEmailTable,
          ImportContactPhoneEmailData,
          $$ImportContactPhoneEmailTableFilterComposer,
          $$ImportContactPhoneEmailTableOrderingComposer,
          $$ImportContactPhoneEmailTableAnnotationComposer,
          $$ImportContactPhoneEmailTableCreateCompanionBuilder,
          $$ImportContactPhoneEmailTableUpdateCompanionBuilder,
          (
            ImportContactPhoneEmailData,
            $$ImportContactPhoneEmailTableReferences,
          ),
          ImportContactPhoneEmailData,
          PrefetchHooks Function({bool ownerZPk})
        > {
  $$ImportContactPhoneEmailTableTableManager(
    _$ImportDatabase db,
    $ImportContactPhoneEmailTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportContactPhoneEmailTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportContactPhoneEmailTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportContactPhoneEmailTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ownerZPk = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> label = const Value.absent(),
              }) => ImportContactPhoneEmailCompanion(
                id: id,
                ownerZPk: ownerZPk,
                kind: kind,
                value: value,
                label: label,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ownerZPk,
                required String kind,
                required String value,
                Value<String?> label = const Value.absent(),
              }) => ImportContactPhoneEmailCompanion.insert(
                id: id,
                ownerZPk: ownerZPk,
                kind: kind,
                value: value,
                label: label,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportContactPhoneEmailTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerZPk = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ownerZPk) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerZPk,
                                referencedTable:
                                    $$ImportContactPhoneEmailTableReferences
                                        ._ownerZPkTable(db),
                                referencedColumn:
                                    $$ImportContactPhoneEmailTableReferences
                                        ._ownerZPkTable(db)
                                        .zPk,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportContactPhoneEmailTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportContactPhoneEmailTable,
      ImportContactPhoneEmailData,
      $$ImportContactPhoneEmailTableFilterComposer,
      $$ImportContactPhoneEmailTableOrderingComposer,
      $$ImportContactPhoneEmailTableAnnotationComposer,
      $$ImportContactPhoneEmailTableCreateCompanionBuilder,
      $$ImportContactPhoneEmailTableUpdateCompanionBuilder,
      (ImportContactPhoneEmailData, $$ImportContactPhoneEmailTableReferences),
      ImportContactPhoneEmailData,
      PrefetchHooks Function({bool ownerZPk})
    >;
typedef $$ImportHandlesTableCreateCompanionBuilder =
    ImportHandlesCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      required String service,
      required String rawIdentifier,
      Value<String?> normalizedIdentifier,
      Value<String?> country,
      Value<String?> lastSeenUtc,
      Value<bool> isIgnored,
      required int batchId,
    });
typedef $$ImportHandlesTableUpdateCompanionBuilder =
    ImportHandlesCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      Value<String> service,
      Value<String> rawIdentifier,
      Value<String?> normalizedIdentifier,
      Value<String?> country,
      Value<String?> lastSeenUtc,
      Value<bool> isIgnored,
      Value<int> batchId,
    });

final class $$ImportHandlesTableReferences
    extends
        BaseReferences<_$ImportDatabase, $ImportHandlesTable, ImportHandle> {
  $$ImportHandlesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importHandles.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ImportChatToHandleTable,
    List<ImportChatToHandleData>
  >
  _importChatToHandleRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importChatToHandle,
        aliasName: $_aliasNameGenerator(
          db.importHandles.id,
          db.importChatToHandle.handleId,
        ),
      );

  $$ImportChatToHandleTableProcessedTableManager get importChatToHandleRefs {
    final manager = $$ImportChatToHandleTableTableManager(
      $_db,
      $_db.importChatToHandle,
    ).filter((f) => f.handleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importChatToHandleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportMessagesTable, List<ImportMessage>>
  _importMessagesRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importMessages,
        aliasName: $_aliasNameGenerator(
          db.importHandles.id,
          db.importMessages.senderHandleId,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get importMessagesRefs {
    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.senderHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportReactionsTable, List<ImportReaction>>
  _importReactionsRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importReactions,
        aliasName: $_aliasNameGenerator(
          db.importHandles.id,
          db.importReactions.reactorHandleId,
        ),
      );

  $$ImportReactionsTableProcessedTableManager get importReactionsRefs {
    final manager = $$ImportReactionsTableTableManager(
      $_db,
      $_db.importReactions,
    ).filter((f) => f.reactorHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importReactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImportContactToChatHandleTable,
    List<ImportContactToChatHandleData>
  >
  _importContactToChatHandleRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importContactToChatHandle,
        aliasName: $_aliasNameGenerator(
          db.importHandles.id,
          db.importContactToChatHandle.chatHandleId,
        ),
      );

  $$ImportContactToChatHandleTableProcessedTableManager
  get importContactToChatHandleRefs {
    final manager = $$ImportContactToChatHandleTableTableManager(
      $_db,
      $_db.importContactToChatHandle,
    ).filter((f) => f.chatHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importContactToChatHandleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportHandlesTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportHandlesTable> {
  $$ImportHandlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedIdentifier => $composableBuilder(
    column: $table.normalizedIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSeenUtc => $composableBuilder(
    column: $table.lastSeenUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importChatToHandleRefs(
    Expression<bool> Function($$ImportChatToHandleTableFilterComposer f) f,
  ) {
    final $$ImportChatToHandleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importChatToHandle,
      getReferencedColumn: (t) => t.handleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatToHandleTableFilterComposer(
            $db: $db,
            $table: $db.importChatToHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importMessagesRefs(
    Expression<bool> Function($$ImportMessagesTableFilterComposer f) f,
  ) {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.senderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importReactionsRefs(
    Expression<bool> Function($$ImportReactionsTableFilterComposer f) f,
  ) {
    final $$ImportReactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importReactions,
      getReferencedColumn: (t) => t.reactorHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportReactionsTableFilterComposer(
            $db: $db,
            $table: $db.importReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importContactToChatHandleRefs(
    Expression<bool> Function($$ImportContactToChatHandleTableFilterComposer f)
    f,
  ) {
    final $$ImportContactToChatHandleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importContactToChatHandle,
          getReferencedColumn: (t) => t.chatHandleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactToChatHandleTableFilterComposer(
                $db: $db,
                $table: $db.importContactToChatHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportHandlesTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportHandlesTable> {
  $$ImportHandlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedIdentifier => $composableBuilder(
    column: $table.normalizedIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSeenUtc => $composableBuilder(
    column: $table.lastSeenUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportHandlesTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportHandlesTable> {
  $$ImportHandlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedIdentifier => $composableBuilder(
    column: $table.normalizedIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get lastSeenUtc => $composableBuilder(
    column: $table.lastSeenUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importChatToHandleRefs<T extends Object>(
    Expression<T> Function($$ImportChatToHandleTableAnnotationComposer a) f,
  ) {
    final $$ImportChatToHandleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importChatToHandle,
          getReferencedColumn: (t) => t.handleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportChatToHandleTableAnnotationComposer(
                $db: $db,
                $table: $db.importChatToHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importMessagesRefs<T extends Object>(
    Expression<T> Function($$ImportMessagesTableAnnotationComposer a) f,
  ) {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.senderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importReactionsRefs<T extends Object>(
    Expression<T> Function($$ImportReactionsTableAnnotationComposer a) f,
  ) {
    final $$ImportReactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importReactions,
      getReferencedColumn: (t) => t.reactorHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportReactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.importReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importContactToChatHandleRefs<T extends Object>(
    Expression<T> Function($$ImportContactToChatHandleTableAnnotationComposer a)
    f,
  ) {
    final $$ImportContactToChatHandleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importContactToChatHandle,
          getReferencedColumn: (t) => t.chatHandleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportContactToChatHandleTableAnnotationComposer(
                $db: $db,
                $table: $db.importContactToChatHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportHandlesTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportHandlesTable,
          ImportHandle,
          $$ImportHandlesTableFilterComposer,
          $$ImportHandlesTableOrderingComposer,
          $$ImportHandlesTableAnnotationComposer,
          $$ImportHandlesTableCreateCompanionBuilder,
          $$ImportHandlesTableUpdateCompanionBuilder,
          (ImportHandle, $$ImportHandlesTableReferences),
          ImportHandle,
          PrefetchHooks Function({
            bool batchId,
            bool importChatToHandleRefs,
            bool importMessagesRefs,
            bool importReactionsRefs,
            bool importContactToChatHandleRefs,
          })
        > {
  $$ImportHandlesTableTableManager(
    _$ImportDatabase db,
    $ImportHandlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportHandlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportHandlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportHandlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<String> rawIdentifier = const Value.absent(),
                Value<String?> normalizedIdentifier = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> lastSeenUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<int> batchId = const Value.absent(),
              }) => ImportHandlesCompanion(
                id: id,
                sourceRowid: sourceRowid,
                service: service,
                rawIdentifier: rawIdentifier,
                normalizedIdentifier: normalizedIdentifier,
                country: country,
                lastSeenUtc: lastSeenUtc,
                isIgnored: isIgnored,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                required String service,
                required String rawIdentifier,
                Value<String?> normalizedIdentifier = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> lastSeenUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                required int batchId,
              }) => ImportHandlesCompanion.insert(
                id: id,
                sourceRowid: sourceRowid,
                service: service,
                rawIdentifier: rawIdentifier,
                normalizedIdentifier: normalizedIdentifier,
                country: country,
                lastSeenUtc: lastSeenUtc,
                isIgnored: isIgnored,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportHandlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                batchId = false,
                importChatToHandleRefs = false,
                importMessagesRefs = false,
                importReactionsRefs = false,
                importContactToChatHandleRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importChatToHandleRefs) db.importChatToHandle,
                    if (importMessagesRefs) db.importMessages,
                    if (importReactionsRefs) db.importReactions,
                    if (importContactToChatHandleRefs)
                      db.importContactToChatHandle,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable:
                                        $$ImportHandlesTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$ImportHandlesTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importChatToHandleRefs)
                        await $_getPrefetchedData<
                          ImportHandle,
                          $ImportHandlesTable,
                          ImportChatToHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportHandlesTableReferences
                              ._importChatToHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportHandlesTableReferences(
                                db,
                                table,
                                p0,
                              ).importChatToHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.handleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importMessagesRefs)
                        await $_getPrefetchedData<
                          ImportHandle,
                          $ImportHandlesTable,
                          ImportMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ImportHandlesTableReferences
                              ._importMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportHandlesTableReferences(
                                db,
                                table,
                                p0,
                              ).importMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.senderHandleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importReactionsRefs)
                        await $_getPrefetchedData<
                          ImportHandle,
                          $ImportHandlesTable,
                          ImportReaction
                        >(
                          currentTable: table,
                          referencedTable: $$ImportHandlesTableReferences
                              ._importReactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportHandlesTableReferences(
                                db,
                                table,
                                p0,
                              ).importReactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reactorHandleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importContactToChatHandleRefs)
                        await $_getPrefetchedData<
                          ImportHandle,
                          $ImportHandlesTable,
                          ImportContactToChatHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportHandlesTableReferences
                              ._importContactToChatHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportHandlesTableReferences(
                                db,
                                table,
                                p0,
                              ).importContactToChatHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatHandleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportHandlesTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportHandlesTable,
      ImportHandle,
      $$ImportHandlesTableFilterComposer,
      $$ImportHandlesTableOrderingComposer,
      $$ImportHandlesTableAnnotationComposer,
      $$ImportHandlesTableCreateCompanionBuilder,
      $$ImportHandlesTableUpdateCompanionBuilder,
      (ImportHandle, $$ImportHandlesTableReferences),
      ImportHandle,
      PrefetchHooks Function({
        bool batchId,
        bool importChatToHandleRefs,
        bool importMessagesRefs,
        bool importReactionsRefs,
        bool importContactToChatHandleRefs,
      })
    >;
typedef $$ImportChatsTableCreateCompanionBuilder =
    ImportChatsCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      required String guid,
      Value<String?> service,
      Value<String?> displayName,
      Value<bool> isGroup,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<bool> isIgnored,
      required int batchId,
    });
typedef $$ImportChatsTableUpdateCompanionBuilder =
    ImportChatsCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      Value<String> guid,
      Value<String?> service,
      Value<String?> displayName,
      Value<bool> isGroup,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<bool> isIgnored,
      Value<int> batchId,
    });

final class $$ImportChatsTableReferences
    extends BaseReferences<_$ImportDatabase, $ImportChatsTable, ImportChat> {
  $$ImportChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importChats.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ImportChatToHandleTable,
    List<ImportChatToHandleData>
  >
  _importChatToHandleRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importChatToHandle,
        aliasName: $_aliasNameGenerator(
          db.importChats.id,
          db.importChatToHandle.chatId,
        ),
      );

  $$ImportChatToHandleTableProcessedTableManager get importChatToHandleRefs {
    final manager = $$ImportChatToHandleTableTableManager(
      $_db,
      $_db.importChatToHandle,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importChatToHandleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportMessagesTable, List<ImportMessage>>
  _importMessagesRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importMessages,
        aliasName: $_aliasNameGenerator(
          db.importChats.id,
          db.importMessages.chatId,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get importMessagesRefs {
    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImportChatToMessageTable,
    List<ImportChatToMessageData>
  >
  _importChatToMessageRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importChatToMessage,
        aliasName: $_aliasNameGenerator(
          db.importChats.id,
          db.importChatToMessage.chatId,
        ),
      );

  $$ImportChatToMessageTableProcessedTableManager get importChatToMessageRefs {
    final manager = $$ImportChatToMessageTableTableManager(
      $_db,
      $_db.importChatToMessage,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importChatToMessageRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportChatsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportChatsTable> {
  $$ImportChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importChatToHandleRefs(
    Expression<bool> Function($$ImportChatToHandleTableFilterComposer f) f,
  ) {
    final $$ImportChatToHandleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importChatToHandle,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatToHandleTableFilterComposer(
            $db: $db,
            $table: $db.importChatToHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importMessagesRefs(
    Expression<bool> Function($$ImportMessagesTableFilterComposer f) f,
  ) {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importChatToMessageRefs(
    Expression<bool> Function($$ImportChatToMessageTableFilterComposer f) f,
  ) {
    final $$ImportChatToMessageTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importChatToMessage,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatToMessageTableFilterComposer(
            $db: $db,
            $table: $db.importChatToMessage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportChatsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportChatsTable> {
  $$ImportChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportChatsTable> {
  $$ImportChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importChatToHandleRefs<T extends Object>(
    Expression<T> Function($$ImportChatToHandleTableAnnotationComposer a) f,
  ) {
    final $$ImportChatToHandleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importChatToHandle,
          getReferencedColumn: (t) => t.chatId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportChatToHandleTableAnnotationComposer(
                $db: $db,
                $table: $db.importChatToHandle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importMessagesRefs<T extends Object>(
    Expression<T> Function($$ImportMessagesTableAnnotationComposer a) f,
  ) {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importChatToMessageRefs<T extends Object>(
    Expression<T> Function($$ImportChatToMessageTableAnnotationComposer a) f,
  ) {
    final $$ImportChatToMessageTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importChatToMessage,
          getReferencedColumn: (t) => t.chatId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportChatToMessageTableAnnotationComposer(
                $db: $db,
                $table: $db.importChatToMessage,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportChatsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportChatsTable,
          ImportChat,
          $$ImportChatsTableFilterComposer,
          $$ImportChatsTableOrderingComposer,
          $$ImportChatsTableAnnotationComposer,
          $$ImportChatsTableCreateCompanionBuilder,
          $$ImportChatsTableUpdateCompanionBuilder,
          (ImportChat, $$ImportChatsTableReferences),
          ImportChat,
          PrefetchHooks Function({
            bool batchId,
            bool importChatToHandleRefs,
            bool importMessagesRefs,
            bool importChatToMessageRefs,
          })
        > {
  $$ImportChatsTableTableManager(_$ImportDatabase db, $ImportChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String?> service = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<int> batchId = const Value.absent(),
              }) => ImportChatsCompanion(
                id: id,
                sourceRowid: sourceRowid,
                guid: guid,
                service: service,
                displayName: displayName,
                isGroup: isGroup,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isIgnored: isIgnored,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                required String guid,
                Value<String?> service = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                required int batchId,
              }) => ImportChatsCompanion.insert(
                id: id,
                sourceRowid: sourceRowid,
                guid: guid,
                service: service,
                displayName: displayName,
                isGroup: isGroup,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isIgnored: isIgnored,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportChatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                batchId = false,
                importChatToHandleRefs = false,
                importMessagesRefs = false,
                importChatToMessageRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importChatToHandleRefs) db.importChatToHandle,
                    if (importMessagesRefs) db.importMessages,
                    if (importChatToMessageRefs) db.importChatToMessage,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable:
                                        $$ImportChatsTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$ImportChatsTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importChatToHandleRefs)
                        await $_getPrefetchedData<
                          ImportChat,
                          $ImportChatsTable,
                          ImportChatToHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportChatsTableReferences
                              ._importChatToHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).importChatToHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importMessagesRefs)
                        await $_getPrefetchedData<
                          ImportChat,
                          $ImportChatsTable,
                          ImportMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ImportChatsTableReferences
                              ._importMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).importMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importChatToMessageRefs)
                        await $_getPrefetchedData<
                          ImportChat,
                          $ImportChatsTable,
                          ImportChatToMessageData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportChatsTableReferences
                              ._importChatToMessageRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).importChatToMessageRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportChatsTable,
      ImportChat,
      $$ImportChatsTableFilterComposer,
      $$ImportChatsTableOrderingComposer,
      $$ImportChatsTableAnnotationComposer,
      $$ImportChatsTableCreateCompanionBuilder,
      $$ImportChatsTableUpdateCompanionBuilder,
      (ImportChat, $$ImportChatsTableReferences),
      ImportChat,
      PrefetchHooks Function({
        bool batchId,
        bool importChatToHandleRefs,
        bool importMessagesRefs,
        bool importChatToMessageRefs,
      })
    >;
typedef $$ImportChatToHandleTableCreateCompanionBuilder =
    ImportChatToHandleCompanion Function({
      required int chatId,
      required int handleId,
      Value<String?> role,
      Value<String?> addedAtUtc,
      Value<int> rowid,
    });
typedef $$ImportChatToHandleTableUpdateCompanionBuilder =
    ImportChatToHandleCompanion Function({
      Value<int> chatId,
      Value<int> handleId,
      Value<String?> role,
      Value<String?> addedAtUtc,
      Value<int> rowid,
    });

final class $$ImportChatToHandleTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportChatToHandleTable,
          ImportChatToHandleData
        > {
  $$ImportChatToHandleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportChatsTable _chatIdTable(_$ImportDatabase db) =>
      db.importChats.createAlias(
        $_aliasNameGenerator(db.importChatToHandle.chatId, db.importChats.id),
      );

  $$ImportChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ImportChatsTableTableManager(
      $_db,
      $_db.importChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportHandlesTable _handleIdTable(_$ImportDatabase db) =>
      db.importHandles.createAlias(
        $_aliasNameGenerator(
          db.importChatToHandle.handleId,
          db.importHandles.id,
        ),
      );

  $$ImportHandlesTableProcessedTableManager get handleId {
    final $_column = $_itemColumn<int>('handle_id')!;

    final manager = $$ImportHandlesTableTableManager(
      $_db,
      $_db.importHandles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_handleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportChatToHandleTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportChatToHandleTable> {
  $$ImportChatToHandleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportChatsTableFilterComposer get chatId {
    final $$ImportChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableFilterComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableFilterComposer get handleId {
    final $$ImportHandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableFilterComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatToHandleTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportChatToHandleTable> {
  $$ImportChatToHandleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportChatsTableOrderingComposer get chatId {
    final $$ImportChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableOrderingComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableOrderingComposer get handleId {
    final $$ImportHandlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableOrderingComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatToHandleTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportChatToHandleTable> {
  $$ImportChatToHandleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => column,
  );

  $$ImportChatsTableAnnotationComposer get chatId {
    final $$ImportChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableAnnotationComposer get handleId {
    final $$ImportHandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatToHandleTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportChatToHandleTable,
          ImportChatToHandleData,
          $$ImportChatToHandleTableFilterComposer,
          $$ImportChatToHandleTableOrderingComposer,
          $$ImportChatToHandleTableAnnotationComposer,
          $$ImportChatToHandleTableCreateCompanionBuilder,
          $$ImportChatToHandleTableUpdateCompanionBuilder,
          (ImportChatToHandleData, $$ImportChatToHandleTableReferences),
          ImportChatToHandleData,
          PrefetchHooks Function({bool chatId, bool handleId})
        > {
  $$ImportChatToHandleTableTableManager(
    _$ImportDatabase db,
    $ImportChatToHandleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportChatToHandleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportChatToHandleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportChatToHandleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<int> handleId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> addedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportChatToHandleCompanion(
                chatId: chatId,
                handleId: handleId,
                role: role,
                addedAtUtc: addedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chatId,
                required int handleId,
                Value<String?> role = const Value.absent(),
                Value<String?> addedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportChatToHandleCompanion.insert(
                chatId: chatId,
                handleId: handleId,
                role: role,
                addedAtUtc: addedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportChatToHandleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false, handleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatId,
                                referencedTable:
                                    $$ImportChatToHandleTableReferences
                                        ._chatIdTable(db),
                                referencedColumn:
                                    $$ImportChatToHandleTableReferences
                                        ._chatIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (handleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.handleId,
                                referencedTable:
                                    $$ImportChatToHandleTableReferences
                                        ._handleIdTable(db),
                                referencedColumn:
                                    $$ImportChatToHandleTableReferences
                                        ._handleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportChatToHandleTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportChatToHandleTable,
      ImportChatToHandleData,
      $$ImportChatToHandleTableFilterComposer,
      $$ImportChatToHandleTableOrderingComposer,
      $$ImportChatToHandleTableAnnotationComposer,
      $$ImportChatToHandleTableCreateCompanionBuilder,
      $$ImportChatToHandleTableUpdateCompanionBuilder,
      (ImportChatToHandleData, $$ImportChatToHandleTableReferences),
      ImportChatToHandleData,
      PrefetchHooks Function({bool chatId, bool handleId})
    >;
typedef $$ImportMessagesTableCreateCompanionBuilder =
    ImportMessagesCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      required String guid,
      required int chatId,
      Value<int?> senderHandleId,
      Value<String?> service,
      Value<bool> isFromMe,
      Value<String?> dateUtc,
      Value<String?> dateReadUtc,
      Value<String?> dateDeliveredUtc,
      Value<String?> subject,
      Value<String?> textContent,
      Value<Uint8List?> attributedBodyBlob,
      Value<String?> itemType,
      Value<int?> errorCode,
      Value<bool> isSystemMessage,
      Value<String?> threadOriginatorGuid,
      Value<String?> associatedMessageGuid,
      Value<String?> balloonBundleId,
      Value<String?> payloadJson,
      Value<bool> isIgnored,
      required int batchId,
    });
typedef $$ImportMessagesTableUpdateCompanionBuilder =
    ImportMessagesCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      Value<String> guid,
      Value<int> chatId,
      Value<int?> senderHandleId,
      Value<String?> service,
      Value<bool> isFromMe,
      Value<String?> dateUtc,
      Value<String?> dateReadUtc,
      Value<String?> dateDeliveredUtc,
      Value<String?> subject,
      Value<String?> textContent,
      Value<Uint8List?> attributedBodyBlob,
      Value<String?> itemType,
      Value<int?> errorCode,
      Value<bool> isSystemMessage,
      Value<String?> threadOriginatorGuid,
      Value<String?> associatedMessageGuid,
      Value<String?> balloonBundleId,
      Value<String?> payloadJson,
      Value<bool> isIgnored,
      Value<int> batchId,
    });

final class $$ImportMessagesTableReferences
    extends
        BaseReferences<_$ImportDatabase, $ImportMessagesTable, ImportMessage> {
  $$ImportMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportChatsTable _chatIdTable(_$ImportDatabase db) =>
      db.importChats.createAlias(
        $_aliasNameGenerator(db.importMessages.chatId, db.importChats.id),
      );

  $$ImportChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ImportChatsTableTableManager(
      $_db,
      $_db.importChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportHandlesTable _senderHandleIdTable(_$ImportDatabase db) =>
      db.importHandles.createAlias(
        $_aliasNameGenerator(
          db.importMessages.senderHandleId,
          db.importHandles.id,
        ),
      );

  $$ImportHandlesTableProcessedTableManager? get senderHandleId {
    final $_column = $_itemColumn<int>('sender_handle_id');
    if ($_column == null) return null;
    final manager = $$ImportHandlesTableTableManager(
      $_db,
      $_db.importHandles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_senderHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importMessages.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ImportChatToMessageTable,
    List<ImportChatToMessageData>
  >
  _importChatToMessageRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importChatToMessage,
        aliasName: $_aliasNameGenerator(
          db.importMessages.id,
          db.importChatToMessage.messageId,
        ),
      );

  $$ImportChatToMessageTableProcessedTableManager get importChatToMessageRefs {
    final manager = $$ImportChatToMessageTableTableManager(
      $_db,
      $_db.importChatToMessage,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importChatToMessageRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImportMessageAttachmentsTable,
    List<ImportMessageAttachment>
  >
  _importMessageAttachmentsRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importMessageAttachments,
        aliasName: $_aliasNameGenerator(
          db.importMessages.id,
          db.importMessageAttachments.messageId,
        ),
      );

  $$ImportMessageAttachmentsTableProcessedTableManager
  get importMessageAttachmentsRefs {
    final manager = $$ImportMessageAttachmentsTableTableManager(
      $_db,
      $_db.importMessageAttachments,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importMessageAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportReactionsTable, List<ImportReaction>>
  _importReactionsRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importReactions,
        aliasName: $_aliasNameGenerator(
          db.importMessages.id,
          db.importReactions.carrierMessageId,
        ),
      );

  $$ImportReactionsTableProcessedTableManager get importReactionsRefs {
    final manager = $$ImportReactionsTableTableManager(
      $_db,
      $_db.importReactions,
    ).filter((f) => f.carrierMessageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importReactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportMessageLinksTable, List<ImportMessageLink>>
  _importMessageLinksRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importMessageLinks,
        aliasName: $_aliasNameGenerator(
          db.importMessages.id,
          db.importMessageLinks.messageId,
        ),
      );

  $$ImportMessageLinksTableProcessedTableManager get importMessageLinksRefs {
    final manager = $$ImportMessageLinksTableTableManager(
      $_db,
      $_db.importMessageLinks,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importMessageLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportMessagesTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportMessagesTable> {
  $$ImportMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateUtc => $composableBuilder(
    column: $table.dateUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateReadUtc => $composableBuilder(
    column: $table.dateReadUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateDeliveredUtc => $composableBuilder(
    column: $table.dateDeliveredUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get attributedBodyBlob => $composableBuilder(
    column: $table.attributedBodyBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadOriginatorGuid => $composableBuilder(
    column: $table.threadOriginatorGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associatedMessageGuid => $composableBuilder(
    column: $table.associatedMessageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balloonBundleId => $composableBuilder(
    column: $table.balloonBundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportChatsTableFilterComposer get chatId {
    final $$ImportChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableFilterComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableFilterComposer get senderHandleId {
    final $$ImportHandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableFilterComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importChatToMessageRefs(
    Expression<bool> Function($$ImportChatToMessageTableFilterComposer f) f,
  ) {
    final $$ImportChatToMessageTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importChatToMessage,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatToMessageTableFilterComposer(
            $db: $db,
            $table: $db.importChatToMessage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importMessageAttachmentsRefs(
    Expression<bool> Function($$ImportMessageAttachmentsTableFilterComposer f)
    f,
  ) {
    final $$ImportMessageAttachmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importMessageAttachments,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportMessageAttachmentsTableFilterComposer(
                $db: $db,
                $table: $db.importMessageAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> importReactionsRefs(
    Expression<bool> Function($$ImportReactionsTableFilterComposer f) f,
  ) {
    final $$ImportReactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importReactions,
      getReferencedColumn: (t) => t.carrierMessageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportReactionsTableFilterComposer(
            $db: $db,
            $table: $db.importReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importMessageLinksRefs(
    Expression<bool> Function($$ImportMessageLinksTableFilterComposer f) f,
  ) {
    final $$ImportMessageLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importMessageLinks,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessageLinksTableFilterComposer(
            $db: $db,
            $table: $db.importMessageLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportMessagesTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportMessagesTable> {
  $$ImportMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateUtc => $composableBuilder(
    column: $table.dateUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateReadUtc => $composableBuilder(
    column: $table.dateReadUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateDeliveredUtc => $composableBuilder(
    column: $table.dateDeliveredUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get attributedBodyBlob => $composableBuilder(
    column: $table.attributedBodyBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadOriginatorGuid => $composableBuilder(
    column: $table.threadOriginatorGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associatedMessageGuid => $composableBuilder(
    column: $table.associatedMessageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balloonBundleId => $composableBuilder(
    column: $table.balloonBundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportChatsTableOrderingComposer get chatId {
    final $$ImportChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableOrderingComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableOrderingComposer get senderHandleId {
    final $$ImportHandlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableOrderingComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportMessagesTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportMessagesTable> {
  $$ImportMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<bool> get isFromMe =>
      $composableBuilder(column: $table.isFromMe, builder: (column) => column);

  GeneratedColumn<String> get dateUtc =>
      $composableBuilder(column: $table.dateUtc, builder: (column) => column);

  GeneratedColumn<String> get dateReadUtc => $composableBuilder(
    column: $table.dateReadUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateDeliveredUtc => $composableBuilder(
    column: $table.dateDeliveredUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get attributedBodyBlob => $composableBuilder(
    column: $table.attributedBodyBlob,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get threadOriginatorGuid => $composableBuilder(
    column: $table.threadOriginatorGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get associatedMessageGuid => $composableBuilder(
    column: $table.associatedMessageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get balloonBundleId => $composableBuilder(
    column: $table.balloonBundleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  $$ImportChatsTableAnnotationComposer get chatId {
    final $$ImportChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableAnnotationComposer get senderHandleId {
    final $$ImportHandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importChatToMessageRefs<T extends Object>(
    Expression<T> Function($$ImportChatToMessageTableAnnotationComposer a) f,
  ) {
    final $$ImportChatToMessageTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importChatToMessage,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportChatToMessageTableAnnotationComposer(
                $db: $db,
                $table: $db.importChatToMessage,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importMessageAttachmentsRefs<T extends Object>(
    Expression<T> Function($$ImportMessageAttachmentsTableAnnotationComposer a)
    f,
  ) {
    final $$ImportMessageAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importMessageAttachments,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportMessageAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.importMessageAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importReactionsRefs<T extends Object>(
    Expression<T> Function($$ImportReactionsTableAnnotationComposer a) f,
  ) {
    final $$ImportReactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importReactions,
      getReferencedColumn: (t) => t.carrierMessageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportReactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.importReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importMessageLinksRefs<T extends Object>(
    Expression<T> Function($$ImportMessageLinksTableAnnotationComposer a) f,
  ) {
    final $$ImportMessageLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importMessageLinks,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportMessageLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.importMessageLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportMessagesTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportMessagesTable,
          ImportMessage,
          $$ImportMessagesTableFilterComposer,
          $$ImportMessagesTableOrderingComposer,
          $$ImportMessagesTableAnnotationComposer,
          $$ImportMessagesTableCreateCompanionBuilder,
          $$ImportMessagesTableUpdateCompanionBuilder,
          (ImportMessage, $$ImportMessagesTableReferences),
          ImportMessage,
          PrefetchHooks Function({
            bool chatId,
            bool senderHandleId,
            bool batchId,
            bool importChatToMessageRefs,
            bool importMessageAttachmentsRefs,
            bool importReactionsRefs,
            bool importMessageLinksRefs,
          })
        > {
  $$ImportMessagesTableTableManager(
    _$ImportDatabase db,
    $ImportMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int?> senderHandleId = const Value.absent(),
                Value<String?> service = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<String?> dateUtc = const Value.absent(),
                Value<String?> dateReadUtc = const Value.absent(),
                Value<String?> dateDeliveredUtc = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<Uint8List?> attributedBodyBlob = const Value.absent(),
                Value<String?> itemType = const Value.absent(),
                Value<int?> errorCode = const Value.absent(),
                Value<bool> isSystemMessage = const Value.absent(),
                Value<String?> threadOriginatorGuid = const Value.absent(),
                Value<String?> associatedMessageGuid = const Value.absent(),
                Value<String?> balloonBundleId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<int> batchId = const Value.absent(),
              }) => ImportMessagesCompanion(
                id: id,
                sourceRowid: sourceRowid,
                guid: guid,
                chatId: chatId,
                senderHandleId: senderHandleId,
                service: service,
                isFromMe: isFromMe,
                dateUtc: dateUtc,
                dateReadUtc: dateReadUtc,
                dateDeliveredUtc: dateDeliveredUtc,
                subject: subject,
                textContent: textContent,
                attributedBodyBlob: attributedBodyBlob,
                itemType: itemType,
                errorCode: errorCode,
                isSystemMessage: isSystemMessage,
                threadOriginatorGuid: threadOriginatorGuid,
                associatedMessageGuid: associatedMessageGuid,
                balloonBundleId: balloonBundleId,
                payloadJson: payloadJson,
                isIgnored: isIgnored,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                required String guid,
                required int chatId,
                Value<int?> senderHandleId = const Value.absent(),
                Value<String?> service = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<String?> dateUtc = const Value.absent(),
                Value<String?> dateReadUtc = const Value.absent(),
                Value<String?> dateDeliveredUtc = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<Uint8List?> attributedBodyBlob = const Value.absent(),
                Value<String?> itemType = const Value.absent(),
                Value<int?> errorCode = const Value.absent(),
                Value<bool> isSystemMessage = const Value.absent(),
                Value<String?> threadOriginatorGuid = const Value.absent(),
                Value<String?> associatedMessageGuid = const Value.absent(),
                Value<String?> balloonBundleId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                required int batchId,
              }) => ImportMessagesCompanion.insert(
                id: id,
                sourceRowid: sourceRowid,
                guid: guid,
                chatId: chatId,
                senderHandleId: senderHandleId,
                service: service,
                isFromMe: isFromMe,
                dateUtc: dateUtc,
                dateReadUtc: dateReadUtc,
                dateDeliveredUtc: dateDeliveredUtc,
                subject: subject,
                textContent: textContent,
                attributedBodyBlob: attributedBodyBlob,
                itemType: itemType,
                errorCode: errorCode,
                isSystemMessage: isSystemMessage,
                threadOriginatorGuid: threadOriginatorGuid,
                associatedMessageGuid: associatedMessageGuid,
                balloonBundleId: balloonBundleId,
                payloadJson: payloadJson,
                isIgnored: isIgnored,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                chatId = false,
                senderHandleId = false,
                batchId = false,
                importChatToMessageRefs = false,
                importMessageAttachmentsRefs = false,
                importReactionsRefs = false,
                importMessageLinksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importChatToMessageRefs) db.importChatToMessage,
                    if (importMessageAttachmentsRefs)
                      db.importMessageAttachments,
                    if (importReactionsRefs) db.importReactions,
                    if (importMessageLinksRefs) db.importMessageLinks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (chatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chatId,
                                    referencedTable:
                                        $$ImportMessagesTableReferences
                                            ._chatIdTable(db),
                                    referencedColumn:
                                        $$ImportMessagesTableReferences
                                            ._chatIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (senderHandleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.senderHandleId,
                                    referencedTable:
                                        $$ImportMessagesTableReferences
                                            ._senderHandleIdTable(db),
                                    referencedColumn:
                                        $$ImportMessagesTableReferences
                                            ._senderHandleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable:
                                        $$ImportMessagesTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$ImportMessagesTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importChatToMessageRefs)
                        await $_getPrefetchedData<
                          ImportMessage,
                          $ImportMessagesTable,
                          ImportChatToMessageData
                        >(
                          currentTable: table,
                          referencedTable: $$ImportMessagesTableReferences
                              ._importChatToMessageRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).importChatToMessageRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importMessageAttachmentsRefs)
                        await $_getPrefetchedData<
                          ImportMessage,
                          $ImportMessagesTable,
                          ImportMessageAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$ImportMessagesTableReferences
                              ._importMessageAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).importMessageAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importReactionsRefs)
                        await $_getPrefetchedData<
                          ImportMessage,
                          $ImportMessagesTable,
                          ImportReaction
                        >(
                          currentTable: table,
                          referencedTable: $$ImportMessagesTableReferences
                              ._importReactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).importReactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carrierMessageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importMessageLinksRefs)
                        await $_getPrefetchedData<
                          ImportMessage,
                          $ImportMessagesTable,
                          ImportMessageLink
                        >(
                          currentTable: table,
                          referencedTable: $$ImportMessagesTableReferences
                              ._importMessageLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).importMessageLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportMessagesTable,
      ImportMessage,
      $$ImportMessagesTableFilterComposer,
      $$ImportMessagesTableOrderingComposer,
      $$ImportMessagesTableAnnotationComposer,
      $$ImportMessagesTableCreateCompanionBuilder,
      $$ImportMessagesTableUpdateCompanionBuilder,
      (ImportMessage, $$ImportMessagesTableReferences),
      ImportMessage,
      PrefetchHooks Function({
        bool chatId,
        bool senderHandleId,
        bool batchId,
        bool importChatToMessageRefs,
        bool importMessageAttachmentsRefs,
        bool importReactionsRefs,
        bool importMessageLinksRefs,
      })
    >;
typedef $$ImportChatToMessageTableCreateCompanionBuilder =
    ImportChatToMessageCompanion Function({
      required int chatId,
      required int messageId,
      Value<int?> sourceRowid,
      Value<int> rowid,
    });
typedef $$ImportChatToMessageTableUpdateCompanionBuilder =
    ImportChatToMessageCompanion Function({
      Value<int> chatId,
      Value<int> messageId,
      Value<int?> sourceRowid,
      Value<int> rowid,
    });

final class $$ImportChatToMessageTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportChatToMessageTable,
          ImportChatToMessageData
        > {
  $$ImportChatToMessageTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportChatsTable _chatIdTable(_$ImportDatabase db) =>
      db.importChats.createAlias(
        $_aliasNameGenerator(db.importChatToMessage.chatId, db.importChats.id),
      );

  $$ImportChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ImportChatsTableTableManager(
      $_db,
      $_db.importChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportMessagesTable _messageIdTable(_$ImportDatabase db) =>
      db.importMessages.createAlias(
        $_aliasNameGenerator(
          db.importChatToMessage.messageId,
          db.importMessages.id,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportChatToMessageTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportChatToMessageTable> {
  $$ImportChatToMessageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportChatsTableFilterComposer get chatId {
    final $$ImportChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableFilterComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportMessagesTableFilterComposer get messageId {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatToMessageTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportChatToMessageTable> {
  $$ImportChatToMessageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportChatsTableOrderingComposer get chatId {
    final $$ImportChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableOrderingComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportMessagesTableOrderingComposer get messageId {
    final $$ImportMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatToMessageTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportChatToMessageTable> {
  $$ImportChatToMessageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => column,
  );

  $$ImportChatsTableAnnotationComposer get chatId {
    final $$ImportChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.importChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.importChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportMessagesTableAnnotationComposer get messageId {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportChatToMessageTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportChatToMessageTable,
          ImportChatToMessageData,
          $$ImportChatToMessageTableFilterComposer,
          $$ImportChatToMessageTableOrderingComposer,
          $$ImportChatToMessageTableAnnotationComposer,
          $$ImportChatToMessageTableCreateCompanionBuilder,
          $$ImportChatToMessageTableUpdateCompanionBuilder,
          (ImportChatToMessageData, $$ImportChatToMessageTableReferences),
          ImportChatToMessageData,
          PrefetchHooks Function({bool chatId, bool messageId})
        > {
  $$ImportChatToMessageTableTableManager(
    _$ImportDatabase db,
    $ImportChatToMessageTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportChatToMessageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportChatToMessageTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportChatToMessageTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportChatToMessageCompanion(
                chatId: chatId,
                messageId: messageId,
                sourceRowid: sourceRowid,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chatId,
                required int messageId,
                Value<int?> sourceRowid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportChatToMessageCompanion.insert(
                chatId: chatId,
                messageId: messageId,
                sourceRowid: sourceRowid,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportChatToMessageTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false, messageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatId,
                                referencedTable:
                                    $$ImportChatToMessageTableReferences
                                        ._chatIdTable(db),
                                referencedColumn:
                                    $$ImportChatToMessageTableReferences
                                        ._chatIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable:
                                    $$ImportChatToMessageTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$ImportChatToMessageTableReferences
                                        ._messageIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportChatToMessageTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportChatToMessageTable,
      ImportChatToMessageData,
      $$ImportChatToMessageTableFilterComposer,
      $$ImportChatToMessageTableOrderingComposer,
      $$ImportChatToMessageTableAnnotationComposer,
      $$ImportChatToMessageTableCreateCompanionBuilder,
      $$ImportChatToMessageTableUpdateCompanionBuilder,
      (ImportChatToMessageData, $$ImportChatToMessageTableReferences),
      ImportChatToMessageData,
      PrefetchHooks Function({bool chatId, bool messageId})
    >;
typedef $$ImportAttachmentsTableCreateCompanionBuilder =
    ImportAttachmentsCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      Value<String?> guid,
      Value<String?> transferName,
      Value<String?> uti,
      Value<String?> mimeType,
      Value<int?> totalBytes,
      Value<bool> isSticker,
      Value<bool?> isOutgoing,
      Value<String?> createdAtUtc,
      Value<String?> localPath,
      Value<String?> sha256Hex,
      required int batchId,
    });
typedef $$ImportAttachmentsTableUpdateCompanionBuilder =
    ImportAttachmentsCompanion Function({
      Value<int> id,
      Value<int?> sourceRowid,
      Value<String?> guid,
      Value<String?> transferName,
      Value<String?> uti,
      Value<String?> mimeType,
      Value<int?> totalBytes,
      Value<bool> isSticker,
      Value<bool?> isOutgoing,
      Value<String?> createdAtUtc,
      Value<String?> localPath,
      Value<String?> sha256Hex,
      Value<int> batchId,
    });

final class $$ImportAttachmentsTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportAttachmentsTable,
          ImportAttachment
        > {
  $$ImportAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(db.importAttachments.batchId, db.importBatches.id),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ImportMessageAttachmentsTable,
    List<ImportMessageAttachment>
  >
  _importMessageAttachmentsRefsTable(_$ImportDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.importMessageAttachments,
        aliasName: $_aliasNameGenerator(
          db.importAttachments.id,
          db.importMessageAttachments.attachmentId,
        ),
      );

  $$ImportMessageAttachmentsTableProcessedTableManager
  get importMessageAttachmentsRefs {
    final manager = $$ImportMessageAttachmentsTableTableManager(
      $_db,
      $_db.importMessageAttachments,
    ).filter((f) => f.attachmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _importMessageAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportAttachmentsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportAttachmentsTable> {
  $$ImportAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uti => $composableBuilder(
    column: $table.uti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSticker => $composableBuilder(
    column: $table.isSticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importMessageAttachmentsRefs(
    Expression<bool> Function($$ImportMessageAttachmentsTableFilterComposer f)
    f,
  ) {
    final $$ImportMessageAttachmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importMessageAttachments,
          getReferencedColumn: (t) => t.attachmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportMessageAttachmentsTableFilterComposer(
                $db: $db,
                $table: $db.importMessageAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportAttachmentsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportAttachmentsTable> {
  $$ImportAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uti => $composableBuilder(
    column: $table.uti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSticker => $composableBuilder(
    column: $table.isSticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportAttachmentsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportAttachmentsTable> {
  $$ImportAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uti =>
      $composableBuilder(column: $table.uti, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSticker =>
      $composableBuilder(column: $table.isSticker, builder: (column) => column);

  GeneratedColumn<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get sha256Hex =>
      $composableBuilder(column: $table.sha256Hex, builder: (column) => column);

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importMessageAttachmentsRefs<T extends Object>(
    Expression<T> Function($$ImportMessageAttachmentsTableAnnotationComposer a)
    f,
  ) {
    final $$ImportMessageAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.importMessageAttachments,
          getReferencedColumn: (t) => t.attachmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportMessageAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.importMessageAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ImportAttachmentsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportAttachmentsTable,
          ImportAttachment,
          $$ImportAttachmentsTableFilterComposer,
          $$ImportAttachmentsTableOrderingComposer,
          $$ImportAttachmentsTableAnnotationComposer,
          $$ImportAttachmentsTableCreateCompanionBuilder,
          $$ImportAttachmentsTableUpdateCompanionBuilder,
          (ImportAttachment, $$ImportAttachmentsTableReferences),
          ImportAttachment,
          PrefetchHooks Function({
            bool batchId,
            bool importMessageAttachmentsRefs,
          })
        > {
  $$ImportAttachmentsTableTableManager(
    _$ImportDatabase db,
    $ImportAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<String?> guid = const Value.absent(),
                Value<String?> transferName = const Value.absent(),
                Value<String?> uti = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<bool> isSticker = const Value.absent(),
                Value<bool?> isOutgoing = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> sha256Hex = const Value.absent(),
                Value<int> batchId = const Value.absent(),
              }) => ImportAttachmentsCompanion(
                id: id,
                sourceRowid: sourceRowid,
                guid: guid,
                transferName: transferName,
                uti: uti,
                mimeType: mimeType,
                totalBytes: totalBytes,
                isSticker: isSticker,
                isOutgoing: isOutgoing,
                createdAtUtc: createdAtUtc,
                localPath: localPath,
                sha256Hex: sha256Hex,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<String?> guid = const Value.absent(),
                Value<String?> transferName = const Value.absent(),
                Value<String?> uti = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<bool> isSticker = const Value.absent(),
                Value<bool?> isOutgoing = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> sha256Hex = const Value.absent(),
                required int batchId,
              }) => ImportAttachmentsCompanion.insert(
                id: id,
                sourceRowid: sourceRowid,
                guid: guid,
                transferName: transferName,
                uti: uti,
                mimeType: mimeType,
                totalBytes: totalBytes,
                isSticker: isSticker,
                isOutgoing: isOutgoing,
                createdAtUtc: createdAtUtc,
                localPath: localPath,
                sha256Hex: sha256Hex,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({batchId = false, importMessageAttachmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importMessageAttachmentsRefs)
                      db.importMessageAttachments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable:
                                        $$ImportAttachmentsTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$ImportAttachmentsTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importMessageAttachmentsRefs)
                        await $_getPrefetchedData<
                          ImportAttachment,
                          $ImportAttachmentsTable,
                          ImportMessageAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$ImportAttachmentsTableReferences
                              ._importMessageAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportAttachmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).importMessageAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attachmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportAttachmentsTable,
      ImportAttachment,
      $$ImportAttachmentsTableFilterComposer,
      $$ImportAttachmentsTableOrderingComposer,
      $$ImportAttachmentsTableAnnotationComposer,
      $$ImportAttachmentsTableCreateCompanionBuilder,
      $$ImportAttachmentsTableUpdateCompanionBuilder,
      (ImportAttachment, $$ImportAttachmentsTableReferences),
      ImportAttachment,
      PrefetchHooks Function({bool batchId, bool importMessageAttachmentsRefs})
    >;
typedef $$ImportMessageAttachmentsTableCreateCompanionBuilder =
    ImportMessageAttachmentsCompanion Function({
      required int messageId,
      required int attachmentId,
      Value<int?> sourceRowid,
      Value<int> rowid,
    });
typedef $$ImportMessageAttachmentsTableUpdateCompanionBuilder =
    ImportMessageAttachmentsCompanion Function({
      Value<int> messageId,
      Value<int> attachmentId,
      Value<int?> sourceRowid,
      Value<int> rowid,
    });

final class $$ImportMessageAttachmentsTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportMessageAttachmentsTable,
          ImportMessageAttachment
        > {
  $$ImportMessageAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportMessagesTable _messageIdTable(_$ImportDatabase db) =>
      db.importMessages.createAlias(
        $_aliasNameGenerator(
          db.importMessageAttachments.messageId,
          db.importMessages.id,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportAttachmentsTable _attachmentIdTable(_$ImportDatabase db) =>
      db.importAttachments.createAlias(
        $_aliasNameGenerator(
          db.importMessageAttachments.attachmentId,
          db.importAttachments.id,
        ),
      );

  $$ImportAttachmentsTableProcessedTableManager get attachmentId {
    final $_column = $_itemColumn<int>('attachment_id')!;

    final manager = $$ImportAttachmentsTableTableManager(
      $_db,
      $_db.importAttachments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attachmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportMessageAttachmentsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportMessageAttachmentsTable> {
  $$ImportMessageAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportMessagesTableFilterComposer get messageId {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportAttachmentsTableFilterComposer get attachmentId {
    final $$ImportAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.importAttachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.importAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportMessageAttachmentsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportMessageAttachmentsTable> {
  $$ImportMessageAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportMessagesTableOrderingComposer get messageId {
    final $$ImportMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportAttachmentsTableOrderingComposer get attachmentId {
    final $$ImportAttachmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attachmentId,
      referencedTable: $db.importAttachments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportAttachmentsTableOrderingComposer(
            $db: $db,
            $table: $db.importAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportMessageAttachmentsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportMessageAttachmentsTable> {
  $$ImportMessageAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sourceRowid => $composableBuilder(
    column: $table.sourceRowid,
    builder: (column) => column,
  );

  $$ImportMessagesTableAnnotationComposer get messageId {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportAttachmentsTableAnnotationComposer get attachmentId {
    final $$ImportAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.attachmentId,
          referencedTable: $db.importAttachments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImportAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.importAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ImportMessageAttachmentsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportMessageAttachmentsTable,
          ImportMessageAttachment,
          $$ImportMessageAttachmentsTableFilterComposer,
          $$ImportMessageAttachmentsTableOrderingComposer,
          $$ImportMessageAttachmentsTableAnnotationComposer,
          $$ImportMessageAttachmentsTableCreateCompanionBuilder,
          $$ImportMessageAttachmentsTableUpdateCompanionBuilder,
          (ImportMessageAttachment, $$ImportMessageAttachmentsTableReferences),
          ImportMessageAttachment,
          PrefetchHooks Function({bool messageId, bool attachmentId})
        > {
  $$ImportMessageAttachmentsTableTableManager(
    _$ImportDatabase db,
    $ImportMessageAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportMessageAttachmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportMessageAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportMessageAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> messageId = const Value.absent(),
                Value<int> attachmentId = const Value.absent(),
                Value<int?> sourceRowid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportMessageAttachmentsCompanion(
                messageId: messageId,
                attachmentId: attachmentId,
                sourceRowid: sourceRowid,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int messageId,
                required int attachmentId,
                Value<int?> sourceRowid = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportMessageAttachmentsCompanion.insert(
                messageId: messageId,
                attachmentId: attachmentId,
                sourceRowid: sourceRowid,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportMessageAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false, attachmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable:
                                    $$ImportMessageAttachmentsTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$ImportMessageAttachmentsTableReferences
                                        ._messageIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (attachmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attachmentId,
                                referencedTable:
                                    $$ImportMessageAttachmentsTableReferences
                                        ._attachmentIdTable(db),
                                referencedColumn:
                                    $$ImportMessageAttachmentsTableReferences
                                        ._attachmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportMessageAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportMessageAttachmentsTable,
      ImportMessageAttachment,
      $$ImportMessageAttachmentsTableFilterComposer,
      $$ImportMessageAttachmentsTableOrderingComposer,
      $$ImportMessageAttachmentsTableAnnotationComposer,
      $$ImportMessageAttachmentsTableCreateCompanionBuilder,
      $$ImportMessageAttachmentsTableUpdateCompanionBuilder,
      (ImportMessageAttachment, $$ImportMessageAttachmentsTableReferences),
      ImportMessageAttachment,
      PrefetchHooks Function({bool messageId, bool attachmentId})
    >;
typedef $$ImportReactionsTableCreateCompanionBuilder =
    ImportReactionsCompanion Function({
      Value<int> id,
      required int carrierMessageId,
      required String targetMessageGuid,
      required String action,
      required String kind,
      Value<int?> reactorHandleId,
      Value<String?> reactedAtUtc,
      Value<double> parseConfidence,
    });
typedef $$ImportReactionsTableUpdateCompanionBuilder =
    ImportReactionsCompanion Function({
      Value<int> id,
      Value<int> carrierMessageId,
      Value<String> targetMessageGuid,
      Value<String> action,
      Value<String> kind,
      Value<int?> reactorHandleId,
      Value<String?> reactedAtUtc,
      Value<double> parseConfidence,
    });

final class $$ImportReactionsTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportReactionsTable,
          ImportReaction
        > {
  $$ImportReactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportMessagesTable _carrierMessageIdTable(_$ImportDatabase db) =>
      db.importMessages.createAlias(
        $_aliasNameGenerator(
          db.importReactions.carrierMessageId,
          db.importMessages.id,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get carrierMessageId {
    final $_column = $_itemColumn<int>('carrier_message_id')!;

    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carrierMessageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportHandlesTable _reactorHandleIdTable(_$ImportDatabase db) =>
      db.importHandles.createAlias(
        $_aliasNameGenerator(
          db.importReactions.reactorHandleId,
          db.importHandles.id,
        ),
      );

  $$ImportHandlesTableProcessedTableManager? get reactorHandleId {
    final $_column = $_itemColumn<int>('reactor_handle_id');
    if ($_column == null) return null;
    final manager = $$ImportHandlesTableTableManager(
      $_db,
      $_db.importHandles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reactorHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportReactionsTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportReactionsTable> {
  $$ImportReactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetMessageGuid => $composableBuilder(
    column: $table.targetMessageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get parseConfidence => $composableBuilder(
    column: $table.parseConfidence,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportMessagesTableFilterComposer get carrierMessageId {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carrierMessageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableFilterComposer get reactorHandleId {
    final $$ImportHandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableFilterComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportReactionsTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportReactionsTable> {
  $$ImportReactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetMessageGuid => $composableBuilder(
    column: $table.targetMessageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get parseConfidence => $composableBuilder(
    column: $table.parseConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportMessagesTableOrderingComposer get carrierMessageId {
    final $$ImportMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carrierMessageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableOrderingComposer get reactorHandleId {
    final $$ImportHandlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableOrderingComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportReactionsTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportReactionsTable> {
  $$ImportReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetMessageGuid => $composableBuilder(
    column: $table.targetMessageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get parseConfidence => $composableBuilder(
    column: $table.parseConfidence,
    builder: (column) => column,
  );

  $$ImportMessagesTableAnnotationComposer get carrierMessageId {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carrierMessageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableAnnotationComposer get reactorHandleId {
    final $$ImportHandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportReactionsTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportReactionsTable,
          ImportReaction,
          $$ImportReactionsTableFilterComposer,
          $$ImportReactionsTableOrderingComposer,
          $$ImportReactionsTableAnnotationComposer,
          $$ImportReactionsTableCreateCompanionBuilder,
          $$ImportReactionsTableUpdateCompanionBuilder,
          (ImportReaction, $$ImportReactionsTableReferences),
          ImportReaction,
          PrefetchHooks Function({bool carrierMessageId, bool reactorHandleId})
        > {
  $$ImportReactionsTableTableManager(
    _$ImportDatabase db,
    $ImportReactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> carrierMessageId = const Value.absent(),
                Value<String> targetMessageGuid = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> reactorHandleId = const Value.absent(),
                Value<String?> reactedAtUtc = const Value.absent(),
                Value<double> parseConfidence = const Value.absent(),
              }) => ImportReactionsCompanion(
                id: id,
                carrierMessageId: carrierMessageId,
                targetMessageGuid: targetMessageGuid,
                action: action,
                kind: kind,
                reactorHandleId: reactorHandleId,
                reactedAtUtc: reactedAtUtc,
                parseConfidence: parseConfidence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int carrierMessageId,
                required String targetMessageGuid,
                required String action,
                required String kind,
                Value<int?> reactorHandleId = const Value.absent(),
                Value<String?> reactedAtUtc = const Value.absent(),
                Value<double> parseConfidence = const Value.absent(),
              }) => ImportReactionsCompanion.insert(
                id: id,
                carrierMessageId: carrierMessageId,
                targetMessageGuid: targetMessageGuid,
                action: action,
                kind: kind,
                reactorHandleId: reactorHandleId,
                reactedAtUtc: reactedAtUtc,
                parseConfidence: parseConfidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportReactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({carrierMessageId = false, reactorHandleId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (carrierMessageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carrierMessageId,
                                    referencedTable:
                                        $$ImportReactionsTableReferences
                                            ._carrierMessageIdTable(db),
                                    referencedColumn:
                                        $$ImportReactionsTableReferences
                                            ._carrierMessageIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (reactorHandleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reactorHandleId,
                                    referencedTable:
                                        $$ImportReactionsTableReferences
                                            ._reactorHandleIdTable(db),
                                    referencedColumn:
                                        $$ImportReactionsTableReferences
                                            ._reactorHandleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ImportReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportReactionsTable,
      ImportReaction,
      $$ImportReactionsTableFilterComposer,
      $$ImportReactionsTableOrderingComposer,
      $$ImportReactionsTableAnnotationComposer,
      $$ImportReactionsTableCreateCompanionBuilder,
      $$ImportReactionsTableUpdateCompanionBuilder,
      (ImportReaction, $$ImportReactionsTableReferences),
      ImportReaction,
      PrefetchHooks Function({bool carrierMessageId, bool reactorHandleId})
    >;
typedef $$ImportMessageLinksTableCreateCompanionBuilder =
    ImportMessageLinksCompanion Function({
      Value<int> id,
      required int messageId,
      required String url,
      Value<int?> start,
      Value<int?> end,
    });
typedef $$ImportMessageLinksTableUpdateCompanionBuilder =
    ImportMessageLinksCompanion Function({
      Value<int> id,
      Value<int> messageId,
      Value<String> url,
      Value<int?> start,
      Value<int?> end,
    });

final class $$ImportMessageLinksTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportMessageLinksTable,
          ImportMessageLink
        > {
  $$ImportMessageLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportMessagesTable _messageIdTable(_$ImportDatabase db) =>
      db.importMessages.createAlias(
        $_aliasNameGenerator(
          db.importMessageLinks.messageId,
          db.importMessages.id,
        ),
      );

  $$ImportMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$ImportMessagesTableTableManager(
      $_db,
      $_db.importMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportMessageLinksTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportMessageLinksTable> {
  $$ImportMessageLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportMessagesTableFilterComposer get messageId {
    final $$ImportMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableFilterComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportMessageLinksTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportMessageLinksTable> {
  $$ImportMessageLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportMessagesTableOrderingComposer get messageId {
    final $$ImportMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportMessageLinksTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportMessageLinksTable> {
  $$ImportMessageLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<int> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  $$ImportMessagesTableAnnotationComposer get messageId {
    final $$ImportMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.importMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.importMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportMessageLinksTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportMessageLinksTable,
          ImportMessageLink,
          $$ImportMessageLinksTableFilterComposer,
          $$ImportMessageLinksTableOrderingComposer,
          $$ImportMessageLinksTableAnnotationComposer,
          $$ImportMessageLinksTableCreateCompanionBuilder,
          $$ImportMessageLinksTableUpdateCompanionBuilder,
          (ImportMessageLink, $$ImportMessageLinksTableReferences),
          ImportMessageLink,
          PrefetchHooks Function({bool messageId})
        > {
  $$ImportMessageLinksTableTableManager(
    _$ImportDatabase db,
    $ImportMessageLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportMessageLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportMessageLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportMessageLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int?> start = const Value.absent(),
                Value<int?> end = const Value.absent(),
              }) => ImportMessageLinksCompanion(
                id: id,
                messageId: messageId,
                url: url,
                start: start,
                end: end,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int messageId,
                required String url,
                Value<int?> start = const Value.absent(),
                Value<int?> end = const Value.absent(),
              }) => ImportMessageLinksCompanion.insert(
                id: id,
                messageId: messageId,
                url: url,
                start: start,
                end: end,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportMessageLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable:
                                    $$ImportMessageLinksTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$ImportMessageLinksTableReferences
                                        ._messageIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportMessageLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportMessageLinksTable,
      ImportMessageLink,
      $$ImportMessageLinksTableFilterComposer,
      $$ImportMessageLinksTableOrderingComposer,
      $$ImportMessageLinksTableAnnotationComposer,
      $$ImportMessageLinksTableCreateCompanionBuilder,
      $$ImportMessageLinksTableUpdateCompanionBuilder,
      (ImportMessageLink, $$ImportMessageLinksTableReferences),
      ImportMessageLink,
      PrefetchHooks Function({bool messageId})
    >;
typedef $$ImportContactToChatHandleTableCreateCompanionBuilder =
    ImportContactToChatHandleCompanion Function({
      Value<int> id,
      required int contactZPk,
      required int chatHandleId,
      required int batchId,
    });
typedef $$ImportContactToChatHandleTableUpdateCompanionBuilder =
    ImportContactToChatHandleCompanion Function({
      Value<int> id,
      Value<int> contactZPk,
      Value<int> chatHandleId,
      Value<int> batchId,
    });

final class $$ImportContactToChatHandleTableReferences
    extends
        BaseReferences<
          _$ImportDatabase,
          $ImportContactToChatHandleTable,
          ImportContactToChatHandleData
        > {
  $$ImportContactToChatHandleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportContactsTable _contactZPkTable(_$ImportDatabase db) =>
      db.importContacts.createAlias(
        $_aliasNameGenerator(
          db.importContactToChatHandle.contactZPk,
          db.importContacts.zPk,
        ),
      );

  $$ImportContactsTableProcessedTableManager get contactZPk {
    final $_column = $_itemColumn<int>('contact_Z_PK')!;

    final manager = $$ImportContactsTableTableManager(
      $_db,
      $_db.importContacts,
    ).filter((f) => f.zPk.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactZPkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportHandlesTable _chatHandleIdTable(_$ImportDatabase db) =>
      db.importHandles.createAlias(
        $_aliasNameGenerator(
          db.importContactToChatHandle.chatHandleId,
          db.importHandles.id,
        ),
      );

  $$ImportHandlesTableProcessedTableManager get chatHandleId {
    final $_column = $_itemColumn<int>('chat_handle_id')!;

    final manager = $$ImportHandlesTableTableManager(
      $_db,
      $_db.importHandles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportBatchesTable _batchIdTable(_$ImportDatabase db) =>
      db.importBatches.createAlias(
        $_aliasNameGenerator(
          db.importContactToChatHandle.batchId,
          db.importBatches.id,
        ),
      );

  $$ImportBatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<int>('batch_id')!;

    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportContactToChatHandleTableFilterComposer
    extends Composer<_$ImportDatabase, $ImportContactToChatHandleTable> {
  $$ImportContactToChatHandleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportContactsTableFilterComposer get contactZPk {
    final $$ImportContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactZPk,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.zPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableFilterComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableFilterComposer get chatHandleId {
    final $$ImportHandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableFilterComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableFilterComposer get batchId {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactToChatHandleTableOrderingComposer
    extends Composer<_$ImportDatabase, $ImportContactToChatHandleTable> {
  $$ImportContactToChatHandleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportContactsTableOrderingComposer get contactZPk {
    final $$ImportContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactZPk,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.zPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableOrderingComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableOrderingComposer get chatHandleId {
    final $$ImportHandlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableOrderingComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableOrderingComposer get batchId {
    final $$ImportBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactToChatHandleTableAnnotationComposer
    extends Composer<_$ImportDatabase, $ImportContactToChatHandleTable> {
  $$ImportContactToChatHandleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ImportContactsTableAnnotationComposer get contactZPk {
    final $$ImportContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactZPk,
      referencedTable: $db.importContacts,
      getReferencedColumn: (t) => t.zPk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.importContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportHandlesTableAnnotationComposer get chatHandleId {
    final $$ImportHandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatHandleId,
      referencedTable: $db.importHandles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportHandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.importHandles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportBatchesTableAnnotationComposer get batchId {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportContactToChatHandleTableTableManager
    extends
        RootTableManager<
          _$ImportDatabase,
          $ImportContactToChatHandleTable,
          ImportContactToChatHandleData,
          $$ImportContactToChatHandleTableFilterComposer,
          $$ImportContactToChatHandleTableOrderingComposer,
          $$ImportContactToChatHandleTableAnnotationComposer,
          $$ImportContactToChatHandleTableCreateCompanionBuilder,
          $$ImportContactToChatHandleTableUpdateCompanionBuilder,
          (
            ImportContactToChatHandleData,
            $$ImportContactToChatHandleTableReferences,
          ),
          ImportContactToChatHandleData,
          PrefetchHooks Function({
            bool contactZPk,
            bool chatHandleId,
            bool batchId,
          })
        > {
  $$ImportContactToChatHandleTableTableManager(
    _$ImportDatabase db,
    $ImportContactToChatHandleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportContactToChatHandleTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ImportContactToChatHandleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImportContactToChatHandleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> contactZPk = const Value.absent(),
                Value<int> chatHandleId = const Value.absent(),
                Value<int> batchId = const Value.absent(),
              }) => ImportContactToChatHandleCompanion(
                id: id,
                contactZPk: contactZPk,
                chatHandleId: chatHandleId,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int contactZPk,
                required int chatHandleId,
                required int batchId,
              }) => ImportContactToChatHandleCompanion.insert(
                id: id,
                contactZPk: contactZPk,
                chatHandleId: chatHandleId,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportContactToChatHandleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({contactZPk = false, chatHandleId = false, batchId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contactZPk) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contactZPk,
                                    referencedTable:
                                        $$ImportContactToChatHandleTableReferences
                                            ._contactZPkTable(db),
                                    referencedColumn:
                                        $$ImportContactToChatHandleTableReferences
                                            ._contactZPkTable(db)
                                            .zPk,
                                  )
                                  as T;
                        }
                        if (chatHandleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chatHandleId,
                                    referencedTable:
                                        $$ImportContactToChatHandleTableReferences
                                            ._chatHandleIdTable(db),
                                    referencedColumn:
                                        $$ImportContactToChatHandleTableReferences
                                            ._chatHandleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable:
                                        $$ImportContactToChatHandleTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$ImportContactToChatHandleTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ImportContactToChatHandleTableProcessedTableManager =
    ProcessedTableManager<
      _$ImportDatabase,
      $ImportContactToChatHandleTable,
      ImportContactToChatHandleData,
      $$ImportContactToChatHandleTableFilterComposer,
      $$ImportContactToChatHandleTableOrderingComposer,
      $$ImportContactToChatHandleTableAnnotationComposer,
      $$ImportContactToChatHandleTableCreateCompanionBuilder,
      $$ImportContactToChatHandleTableUpdateCompanionBuilder,
      (
        ImportContactToChatHandleData,
        $$ImportContactToChatHandleTableReferences,
      ),
      ImportContactToChatHandleData,
      PrefetchHooks Function({bool contactZPk, bool chatHandleId, bool batchId})
    >;

class $ImportDatabaseManager {
  final _$ImportDatabase _db;
  $ImportDatabaseManager(this._db);
  $$ImportSchemaMigrationsTableTableManager get importSchemaMigrations =>
      $$ImportSchemaMigrationsTableTableManager(
        _db,
        _db.importSchemaMigrations,
      );
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$ImportSourceFilesTableTableManager get importSourceFiles =>
      $$ImportSourceFilesTableTableManager(_db, _db.importSourceFiles);
  $$ImportLogsTableTableManager get importLogs =>
      $$ImportLogsTableTableManager(_db, _db.importLogs);
  $$ImportContactsTableTableManager get importContacts =>
      $$ImportContactsTableTableManager(_db, _db.importContacts);
  $$ImportContactPhoneEmailTableTableManager get importContactPhoneEmail =>
      $$ImportContactPhoneEmailTableTableManager(
        _db,
        _db.importContactPhoneEmail,
      );
  $$ImportHandlesTableTableManager get importHandles =>
      $$ImportHandlesTableTableManager(_db, _db.importHandles);
  $$ImportChatsTableTableManager get importChats =>
      $$ImportChatsTableTableManager(_db, _db.importChats);
  $$ImportChatToHandleTableTableManager get importChatToHandle =>
      $$ImportChatToHandleTableTableManager(_db, _db.importChatToHandle);
  $$ImportMessagesTableTableManager get importMessages =>
      $$ImportMessagesTableTableManager(_db, _db.importMessages);
  $$ImportChatToMessageTableTableManager get importChatToMessage =>
      $$ImportChatToMessageTableTableManager(_db, _db.importChatToMessage);
  $$ImportAttachmentsTableTableManager get importAttachments =>
      $$ImportAttachmentsTableTableManager(_db, _db.importAttachments);
  $$ImportMessageAttachmentsTableTableManager get importMessageAttachments =>
      $$ImportMessageAttachmentsTableTableManager(
        _db,
        _db.importMessageAttachments,
      );
  $$ImportReactionsTableTableManager get importReactions =>
      $$ImportReactionsTableTableManager(_db, _db.importReactions);
  $$ImportMessageLinksTableTableManager get importMessageLinks =>
      $$ImportMessageLinksTableTableManager(_db, _db.importMessageLinks);
  $$ImportContactToChatHandleTableTableManager get importContactToChatHandle =>
      $$ImportContactToChatHandleTableTableManager(
        _db,
        _db.importContactToChatHandle,
      );
}
