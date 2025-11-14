// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_database.dart';

// ignore_for_file: type=lint
class $WorkingSchemaMigrationsTable extends WorkingSchemaMigrations
    with TableInfo<$WorkingSchemaMigrationsTable, WorkingSchemaMigration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingSchemaMigrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    Insertable<WorkingSchemaMigration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {version};
  @override
  WorkingSchemaMigration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingSchemaMigration(
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
  $WorkingSchemaMigrationsTable createAlias(String alias) {
    return $WorkingSchemaMigrationsTable(attachedDatabase, alias);
  }
}

class WorkingSchemaMigration extends DataClass
    implements Insertable<WorkingSchemaMigration> {
  final int version;
  final String appliedAtUtc;
  const WorkingSchemaMigration({
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

  WorkingSchemaMigrationsCompanion toCompanion(bool nullToAbsent) {
    return WorkingSchemaMigrationsCompanion(
      version: Value(version),
      appliedAtUtc: Value(appliedAtUtc),
    );
  }

  factory WorkingSchemaMigration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingSchemaMigration(
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

  WorkingSchemaMigration copyWith({int? version, String? appliedAtUtc}) =>
      WorkingSchemaMigration(
        version: version ?? this.version,
        appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
      );
  WorkingSchemaMigration copyWithCompanion(
    WorkingSchemaMigrationsCompanion data,
  ) {
    return WorkingSchemaMigration(
      version: data.version.present ? data.version.value : this.version,
      appliedAtUtc: data.appliedAtUtc.present
          ? data.appliedAtUtc.value
          : this.appliedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingSchemaMigration(')
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
      (other is WorkingSchemaMigration &&
          other.version == this.version &&
          other.appliedAtUtc == this.appliedAtUtc);
}

class WorkingSchemaMigrationsCompanion
    extends UpdateCompanion<WorkingSchemaMigration> {
  final Value<int> version;
  final Value<String> appliedAtUtc;
  const WorkingSchemaMigrationsCompanion({
    this.version = const Value.absent(),
    this.appliedAtUtc = const Value.absent(),
  });
  WorkingSchemaMigrationsCompanion.insert({
    this.version = const Value.absent(),
    required String appliedAtUtc,
  }) : appliedAtUtc = Value(appliedAtUtc);
  static Insertable<WorkingSchemaMigration> custom({
    Expression<int>? version,
    Expression<String>? appliedAtUtc,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (appliedAtUtc != null) 'applied_at_utc': appliedAtUtc,
    });
  }

  WorkingSchemaMigrationsCompanion copyWith({
    Value<int>? version,
    Value<String>? appliedAtUtc,
  }) {
    return WorkingSchemaMigrationsCompanion(
      version: version ?? this.version,
      appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingSchemaMigrationsCompanion(')
          ..write('version: $version, ')
          ..write('appliedAtUtc: $appliedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ProjectionStateTable extends ProjectionState
    with TableInfo<$ProjectionStateTable, ProjectionStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectionStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK(id=1)',
    clientDefault: () => 1,
  );
  static const VerificationMeta _lastImportBatchIdMeta = const VerificationMeta(
    'lastImportBatchId',
  );
  @override
  late final GeneratedColumn<int> lastImportBatchId = GeneratedColumn<int>(
    'last_import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastProjectedAtUtcMeta =
      const VerificationMeta('lastProjectedAtUtc');
  @override
  late final GeneratedColumn<String> lastProjectedAtUtc =
      GeneratedColumn<String>(
        'last_projected_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastProjectedMessageIdMeta =
      const VerificationMeta('lastProjectedMessageId');
  @override
  late final GeneratedColumn<int> lastProjectedMessageId = GeneratedColumn<int>(
    'last_projected_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastProjectedAttachmentIdMeta =
      const VerificationMeta('lastProjectedAttachmentId');
  @override
  late final GeneratedColumn<int> lastProjectedAttachmentId =
      GeneratedColumn<int>(
        'last_projected_attachment_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastImportBatchId,
    lastProjectedAtUtc,
    lastProjectedMessageId,
    lastProjectedAttachmentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projection_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectionStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_import_batch_id')) {
      context.handle(
        _lastImportBatchIdMeta,
        lastImportBatchId.isAcceptableOrUnknown(
          data['last_import_batch_id']!,
          _lastImportBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('last_projected_at_utc')) {
      context.handle(
        _lastProjectedAtUtcMeta,
        lastProjectedAtUtc.isAcceptableOrUnknown(
          data['last_projected_at_utc']!,
          _lastProjectedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_projected_message_id')) {
      context.handle(
        _lastProjectedMessageIdMeta,
        lastProjectedMessageId.isAcceptableOrUnknown(
          data['last_projected_message_id']!,
          _lastProjectedMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_projected_attachment_id')) {
      context.handle(
        _lastProjectedAttachmentIdMeta,
        lastProjectedAttachmentId.isAcceptableOrUnknown(
          data['last_projected_attachment_id']!,
          _lastProjectedAttachmentIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectionStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectionStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastImportBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_import_batch_id'],
      ),
      lastProjectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_projected_at_utc'],
      ),
      lastProjectedMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_projected_message_id'],
      ),
      lastProjectedAttachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_projected_attachment_id'],
      ),
    );
  }

  @override
  $ProjectionStateTable createAlias(String alias) {
    return $ProjectionStateTable(attachedDatabase, alias);
  }
}

class ProjectionStateData extends DataClass
    implements Insertable<ProjectionStateData> {
  final int id;
  final int? lastImportBatchId;
  final String? lastProjectedAtUtc;
  final int? lastProjectedMessageId;
  final int? lastProjectedAttachmentId;
  const ProjectionStateData({
    required this.id,
    this.lastImportBatchId,
    this.lastProjectedAtUtc,
    this.lastProjectedMessageId,
    this.lastProjectedAttachmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastImportBatchId != null) {
      map['last_import_batch_id'] = Variable<int>(lastImportBatchId);
    }
    if (!nullToAbsent || lastProjectedAtUtc != null) {
      map['last_projected_at_utc'] = Variable<String>(lastProjectedAtUtc);
    }
    if (!nullToAbsent || lastProjectedMessageId != null) {
      map['last_projected_message_id'] = Variable<int>(lastProjectedMessageId);
    }
    if (!nullToAbsent || lastProjectedAttachmentId != null) {
      map['last_projected_attachment_id'] = Variable<int>(
        lastProjectedAttachmentId,
      );
    }
    return map;
  }

  ProjectionStateCompanion toCompanion(bool nullToAbsent) {
    return ProjectionStateCompanion(
      id: Value(id),
      lastImportBatchId: lastImportBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastImportBatchId),
      lastProjectedAtUtc: lastProjectedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProjectedAtUtc),
      lastProjectedMessageId: lastProjectedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProjectedMessageId),
      lastProjectedAttachmentId:
          lastProjectedAttachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProjectedAttachmentId),
    );
  }

  factory ProjectionStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectionStateData(
      id: serializer.fromJson<int>(json['id']),
      lastImportBatchId: serializer.fromJson<int?>(json['lastImportBatchId']),
      lastProjectedAtUtc: serializer.fromJson<String?>(
        json['lastProjectedAtUtc'],
      ),
      lastProjectedMessageId: serializer.fromJson<int?>(
        json['lastProjectedMessageId'],
      ),
      lastProjectedAttachmentId: serializer.fromJson<int?>(
        json['lastProjectedAttachmentId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastImportBatchId': serializer.toJson<int?>(lastImportBatchId),
      'lastProjectedAtUtc': serializer.toJson<String?>(lastProjectedAtUtc),
      'lastProjectedMessageId': serializer.toJson<int?>(lastProjectedMessageId),
      'lastProjectedAttachmentId': serializer.toJson<int?>(
        lastProjectedAttachmentId,
      ),
    };
  }

  ProjectionStateData copyWith({
    int? id,
    Value<int?> lastImportBatchId = const Value.absent(),
    Value<String?> lastProjectedAtUtc = const Value.absent(),
    Value<int?> lastProjectedMessageId = const Value.absent(),
    Value<int?> lastProjectedAttachmentId = const Value.absent(),
  }) => ProjectionStateData(
    id: id ?? this.id,
    lastImportBatchId: lastImportBatchId.present
        ? lastImportBatchId.value
        : this.lastImportBatchId,
    lastProjectedAtUtc: lastProjectedAtUtc.present
        ? lastProjectedAtUtc.value
        : this.lastProjectedAtUtc,
    lastProjectedMessageId: lastProjectedMessageId.present
        ? lastProjectedMessageId.value
        : this.lastProjectedMessageId,
    lastProjectedAttachmentId: lastProjectedAttachmentId.present
        ? lastProjectedAttachmentId.value
        : this.lastProjectedAttachmentId,
  );
  ProjectionStateData copyWithCompanion(ProjectionStateCompanion data) {
    return ProjectionStateData(
      id: data.id.present ? data.id.value : this.id,
      lastImportBatchId: data.lastImportBatchId.present
          ? data.lastImportBatchId.value
          : this.lastImportBatchId,
      lastProjectedAtUtc: data.lastProjectedAtUtc.present
          ? data.lastProjectedAtUtc.value
          : this.lastProjectedAtUtc,
      lastProjectedMessageId: data.lastProjectedMessageId.present
          ? data.lastProjectedMessageId.value
          : this.lastProjectedMessageId,
      lastProjectedAttachmentId: data.lastProjectedAttachmentId.present
          ? data.lastProjectedAttachmentId.value
          : this.lastProjectedAttachmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectionStateData(')
          ..write('id: $id, ')
          ..write('lastImportBatchId: $lastImportBatchId, ')
          ..write('lastProjectedAtUtc: $lastProjectedAtUtc, ')
          ..write('lastProjectedMessageId: $lastProjectedMessageId, ')
          ..write('lastProjectedAttachmentId: $lastProjectedAttachmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastImportBatchId,
    lastProjectedAtUtc,
    lastProjectedMessageId,
    lastProjectedAttachmentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectionStateData &&
          other.id == this.id &&
          other.lastImportBatchId == this.lastImportBatchId &&
          other.lastProjectedAtUtc == this.lastProjectedAtUtc &&
          other.lastProjectedMessageId == this.lastProjectedMessageId &&
          other.lastProjectedAttachmentId == this.lastProjectedAttachmentId);
}

class ProjectionStateCompanion extends UpdateCompanion<ProjectionStateData> {
  final Value<int> id;
  final Value<int?> lastImportBatchId;
  final Value<String?> lastProjectedAtUtc;
  final Value<int?> lastProjectedMessageId;
  final Value<int?> lastProjectedAttachmentId;
  const ProjectionStateCompanion({
    this.id = const Value.absent(),
    this.lastImportBatchId = const Value.absent(),
    this.lastProjectedAtUtc = const Value.absent(),
    this.lastProjectedMessageId = const Value.absent(),
    this.lastProjectedAttachmentId = const Value.absent(),
  });
  ProjectionStateCompanion.insert({
    this.id = const Value.absent(),
    this.lastImportBatchId = const Value.absent(),
    this.lastProjectedAtUtc = const Value.absent(),
    this.lastProjectedMessageId = const Value.absent(),
    this.lastProjectedAttachmentId = const Value.absent(),
  });
  static Insertable<ProjectionStateData> custom({
    Expression<int>? id,
    Expression<int>? lastImportBatchId,
    Expression<String>? lastProjectedAtUtc,
    Expression<int>? lastProjectedMessageId,
    Expression<int>? lastProjectedAttachmentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastImportBatchId != null) 'last_import_batch_id': lastImportBatchId,
      if (lastProjectedAtUtc != null)
        'last_projected_at_utc': lastProjectedAtUtc,
      if (lastProjectedMessageId != null)
        'last_projected_message_id': lastProjectedMessageId,
      if (lastProjectedAttachmentId != null)
        'last_projected_attachment_id': lastProjectedAttachmentId,
    });
  }

  ProjectionStateCompanion copyWith({
    Value<int>? id,
    Value<int?>? lastImportBatchId,
    Value<String?>? lastProjectedAtUtc,
    Value<int?>? lastProjectedMessageId,
    Value<int?>? lastProjectedAttachmentId,
  }) {
    return ProjectionStateCompanion(
      id: id ?? this.id,
      lastImportBatchId: lastImportBatchId ?? this.lastImportBatchId,
      lastProjectedAtUtc: lastProjectedAtUtc ?? this.lastProjectedAtUtc,
      lastProjectedMessageId:
          lastProjectedMessageId ?? this.lastProjectedMessageId,
      lastProjectedAttachmentId:
          lastProjectedAttachmentId ?? this.lastProjectedAttachmentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastImportBatchId.present) {
      map['last_import_batch_id'] = Variable<int>(lastImportBatchId.value);
    }
    if (lastProjectedAtUtc.present) {
      map['last_projected_at_utc'] = Variable<String>(lastProjectedAtUtc.value);
    }
    if (lastProjectedMessageId.present) {
      map['last_projected_message_id'] = Variable<int>(
        lastProjectedMessageId.value,
      );
    }
    if (lastProjectedAttachmentId.present) {
      map['last_projected_attachment_id'] = Variable<int>(
        lastProjectedAttachmentId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectionStateCompanion(')
          ..write('id: $id, ')
          ..write('lastImportBatchId: $lastImportBatchId, ')
          ..write('lastProjectedAtUtc: $lastProjectedAtUtc, ')
          ..write('lastProjectedMessageId: $lastProjectedMessageId, ')
          ..write('lastProjectedAttachmentId: $lastProjectedAttachmentId')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkingHandlesTable extends WorkingHandles
    with TableInfo<$WorkingHandlesTable, WorkingHandle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingHandlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compoundIdentifierMeta =
      const VerificationMeta('compoundIdentifier');
  @override
  late final GeneratedColumn<String> compoundIdentifier =
      GeneratedColumn<String>(
        'compound_identifier',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'Unknown\' CHECK(service IN (\'iMessage\',\'iMessageLite\',\'SMS\',\'RCS\',\'Unknown\'))',
    defaultValue: const CustomExpression('\'Unknown\''),
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
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isBlacklistedMeta = const VerificationMeta(
    'isBlacklisted',
  );
  @override
  late final GeneratedColumn<bool> isBlacklisted = GeneratedColumn<bool>(
    'is_blacklisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_blacklisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawIdentifier,
    displayName,
    compoundIdentifier,
    service,
    isIgnored,
    isVisible,
    isBlacklisted,
    country,
    lastSeenUtc,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handles';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingHandle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('compound_identifier')) {
      context.handle(
        _compoundIdentifierMeta,
        compoundIdentifier.isAcceptableOrUnknown(
          data['compound_identifier']!,
          _compoundIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compoundIdentifierMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('is_blacklisted')) {
      context.handle(
        _isBlacklistedMeta,
        isBlacklisted.isAcceptableOrUnknown(
          data['is_blacklisted']!,
          _isBlacklistedMeta,
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
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {compoundIdentifier},
    {rawIdentifier, service},
  ];
  @override
  WorkingHandle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingHandle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_identifier'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      compoundIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_identifier'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      isBlacklisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_blacklisted'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      lastSeenUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_utc'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
    );
  }

  @override
  $WorkingHandlesTable createAlias(String alias) {
    return $WorkingHandlesTable(attachedDatabase, alias);
  }
}

class WorkingHandle extends DataClass implements Insertable<WorkingHandle> {
  final int id;
  final String rawIdentifier;
  final String displayName;
  final String compoundIdentifier;
  final String service;
  final bool isIgnored;
  final bool isVisible;
  final bool isBlacklisted;
  final String? country;
  final String? lastSeenUtc;
  final int? batchId;
  const WorkingHandle({
    required this.id,
    required this.rawIdentifier,
    required this.displayName,
    required this.compoundIdentifier,
    required this.service,
    required this.isIgnored,
    required this.isVisible,
    required this.isBlacklisted,
    this.country,
    this.lastSeenUtc,
    this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_identifier'] = Variable<String>(rawIdentifier);
    map['display_name'] = Variable<String>(displayName);
    map['compound_identifier'] = Variable<String>(compoundIdentifier);
    map['service'] = Variable<String>(service);
    map['is_ignored'] = Variable<bool>(isIgnored);
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_blacklisted'] = Variable<bool>(isBlacklisted);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || lastSeenUtc != null) {
      map['last_seen_utc'] = Variable<String>(lastSeenUtc);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    return map;
  }

  WorkingHandlesCompanion toCompanion(bool nullToAbsent) {
    return WorkingHandlesCompanion(
      id: Value(id),
      rawIdentifier: Value(rawIdentifier),
      displayName: Value(displayName),
      compoundIdentifier: Value(compoundIdentifier),
      service: Value(service),
      isIgnored: Value(isIgnored),
      isVisible: Value(isVisible),
      isBlacklisted: Value(isBlacklisted),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      lastSeenUtc: lastSeenUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenUtc),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
    );
  }

  factory WorkingHandle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingHandle(
      id: serializer.fromJson<int>(json['id']),
      rawIdentifier: serializer.fromJson<String>(json['rawIdentifier']),
      displayName: serializer.fromJson<String>(json['displayName']),
      compoundIdentifier: serializer.fromJson<String>(
        json['compoundIdentifier'],
      ),
      service: serializer.fromJson<String>(json['service']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isBlacklisted: serializer.fromJson<bool>(json['isBlacklisted']),
      country: serializer.fromJson<String?>(json['country']),
      lastSeenUtc: serializer.fromJson<String?>(json['lastSeenUtc']),
      batchId: serializer.fromJson<int?>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawIdentifier': serializer.toJson<String>(rawIdentifier),
      'displayName': serializer.toJson<String>(displayName),
      'compoundIdentifier': serializer.toJson<String>(compoundIdentifier),
      'service': serializer.toJson<String>(service),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isBlacklisted': serializer.toJson<bool>(isBlacklisted),
      'country': serializer.toJson<String?>(country),
      'lastSeenUtc': serializer.toJson<String?>(lastSeenUtc),
      'batchId': serializer.toJson<int?>(batchId),
    };
  }

  WorkingHandle copyWith({
    int? id,
    String? rawIdentifier,
    String? displayName,
    String? compoundIdentifier,
    String? service,
    bool? isIgnored,
    bool? isVisible,
    bool? isBlacklisted,
    Value<String?> country = const Value.absent(),
    Value<String?> lastSeenUtc = const Value.absent(),
    Value<int?> batchId = const Value.absent(),
  }) => WorkingHandle(
    id: id ?? this.id,
    rawIdentifier: rawIdentifier ?? this.rawIdentifier,
    displayName: displayName ?? this.displayName,
    compoundIdentifier: compoundIdentifier ?? this.compoundIdentifier,
    service: service ?? this.service,
    isIgnored: isIgnored ?? this.isIgnored,
    isVisible: isVisible ?? this.isVisible,
    isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    country: country.present ? country.value : this.country,
    lastSeenUtc: lastSeenUtc.present ? lastSeenUtc.value : this.lastSeenUtc,
    batchId: batchId.present ? batchId.value : this.batchId,
  );
  WorkingHandle copyWithCompanion(WorkingHandlesCompanion data) {
    return WorkingHandle(
      id: data.id.present ? data.id.value : this.id,
      rawIdentifier: data.rawIdentifier.present
          ? data.rawIdentifier.value
          : this.rawIdentifier,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      compoundIdentifier: data.compoundIdentifier.present
          ? data.compoundIdentifier.value
          : this.compoundIdentifier,
      service: data.service.present ? data.service.value : this.service,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isBlacklisted: data.isBlacklisted.present
          ? data.isBlacklisted.value
          : this.isBlacklisted,
      country: data.country.present ? data.country.value : this.country,
      lastSeenUtc: data.lastSeenUtc.present
          ? data.lastSeenUtc.value
          : this.lastSeenUtc,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingHandle(')
          ..write('id: $id, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('displayName: $displayName, ')
          ..write('compoundIdentifier: $compoundIdentifier, ')
          ..write('service: $service, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('isVisible: $isVisible, ')
          ..write('isBlacklisted: $isBlacklisted, ')
          ..write('country: $country, ')
          ..write('lastSeenUtc: $lastSeenUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rawIdentifier,
    displayName,
    compoundIdentifier,
    service,
    isIgnored,
    isVisible,
    isBlacklisted,
    country,
    lastSeenUtc,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingHandle &&
          other.id == this.id &&
          other.rawIdentifier == this.rawIdentifier &&
          other.displayName == this.displayName &&
          other.compoundIdentifier == this.compoundIdentifier &&
          other.service == this.service &&
          other.isIgnored == this.isIgnored &&
          other.isVisible == this.isVisible &&
          other.isBlacklisted == this.isBlacklisted &&
          other.country == this.country &&
          other.lastSeenUtc == this.lastSeenUtc &&
          other.batchId == this.batchId);
}

class WorkingHandlesCompanion extends UpdateCompanion<WorkingHandle> {
  final Value<int> id;
  final Value<String> rawIdentifier;
  final Value<String> displayName;
  final Value<String> compoundIdentifier;
  final Value<String> service;
  final Value<bool> isIgnored;
  final Value<bool> isVisible;
  final Value<bool> isBlacklisted;
  final Value<String?> country;
  final Value<String?> lastSeenUtc;
  final Value<int?> batchId;
  const WorkingHandlesCompanion({
    this.id = const Value.absent(),
    this.rawIdentifier = const Value.absent(),
    this.displayName = const Value.absent(),
    this.compoundIdentifier = const Value.absent(),
    this.service = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isBlacklisted = const Value.absent(),
    this.country = const Value.absent(),
    this.lastSeenUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  WorkingHandlesCompanion.insert({
    this.id = const Value.absent(),
    required String rawIdentifier,
    required String displayName,
    required String compoundIdentifier,
    this.service = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isBlacklisted = const Value.absent(),
    this.country = const Value.absent(),
    this.lastSeenUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  }) : rawIdentifier = Value(rawIdentifier),
       displayName = Value(displayName),
       compoundIdentifier = Value(compoundIdentifier);
  static Insertable<WorkingHandle> custom({
    Expression<int>? id,
    Expression<String>? rawIdentifier,
    Expression<String>? displayName,
    Expression<String>? compoundIdentifier,
    Expression<String>? service,
    Expression<bool>? isIgnored,
    Expression<bool>? isVisible,
    Expression<bool>? isBlacklisted,
    Expression<String>? country,
    Expression<String>? lastSeenUtc,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawIdentifier != null) 'raw_identifier': rawIdentifier,
      if (displayName != null) 'display_name': displayName,
      if (compoundIdentifier != null) 'compound_identifier': compoundIdentifier,
      if (service != null) 'service': service,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (isVisible != null) 'is_visible': isVisible,
      if (isBlacklisted != null) 'is_blacklisted': isBlacklisted,
      if (country != null) 'country': country,
      if (lastSeenUtc != null) 'last_seen_utc': lastSeenUtc,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  WorkingHandlesCompanion copyWith({
    Value<int>? id,
    Value<String>? rawIdentifier,
    Value<String>? displayName,
    Value<String>? compoundIdentifier,
    Value<String>? service,
    Value<bool>? isIgnored,
    Value<bool>? isVisible,
    Value<bool>? isBlacklisted,
    Value<String?>? country,
    Value<String?>? lastSeenUtc,
    Value<int?>? batchId,
  }) {
    return WorkingHandlesCompanion(
      id: id ?? this.id,
      rawIdentifier: rawIdentifier ?? this.rawIdentifier,
      displayName: displayName ?? this.displayName,
      compoundIdentifier: compoundIdentifier ?? this.compoundIdentifier,
      service: service ?? this.service,
      isIgnored: isIgnored ?? this.isIgnored,
      isVisible: isVisible ?? this.isVisible,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      country: country ?? this.country,
      lastSeenUtc: lastSeenUtc ?? this.lastSeenUtc,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawIdentifier.present) {
      map['raw_identifier'] = Variable<String>(rawIdentifier.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (compoundIdentifier.present) {
      map['compound_identifier'] = Variable<String>(compoundIdentifier.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isBlacklisted.present) {
      map['is_blacklisted'] = Variable<bool>(isBlacklisted.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (lastSeenUtc.present) {
      map['last_seen_utc'] = Variable<String>(lastSeenUtc.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingHandlesCompanion(')
          ..write('id: $id, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('displayName: $displayName, ')
          ..write('compoundIdentifier: $compoundIdentifier, ')
          ..write('service: $service, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('isVisible: $isVisible, ')
          ..write('isBlacklisted: $isBlacklisted, ')
          ..write('country: $country, ')
          ..write('lastSeenUtc: $lastSeenUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $HandlesCanonicalTable extends HandlesCanonical
    with TableInfo<$HandlesCanonicalTable, HandlesCanonicalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandlesCanonicalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compoundIdentifierMeta =
      const VerificationMeta('compoundIdentifier');
  @override
  late final GeneratedColumn<String> compoundIdentifier =
      GeneratedColumn<String>(
        'compound_identifier',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'Unknown\' CHECK(service IN (\'iMessage\',\'iMessageLite\',\'SMS\',\'RCS\',\'Unknown\'))',
    defaultValue: const CustomExpression('\'Unknown\''),
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
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isBlacklistedMeta = const VerificationMeta(
    'isBlacklisted',
  );
  @override
  late final GeneratedColumn<bool> isBlacklisted = GeneratedColumn<bool>(
    'is_blacklisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_blacklisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawIdentifier,
    displayName,
    compoundIdentifier,
    service,
    isIgnored,
    isVisible,
    isBlacklisted,
    country,
    lastSeenUtc,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handles_canonical';
  @override
  VerificationContext validateIntegrity(
    Insertable<HandlesCanonicalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('compound_identifier')) {
      context.handle(
        _compoundIdentifierMeta,
        compoundIdentifier.isAcceptableOrUnknown(
          data['compound_identifier']!,
          _compoundIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compoundIdentifierMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('is_blacklisted')) {
      context.handle(
        _isBlacklistedMeta,
        isBlacklisted.isAcceptableOrUnknown(
          data['is_blacklisted']!,
          _isBlacklistedMeta,
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
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {compoundIdentifier},
    {rawIdentifier, service},
  ];
  @override
  HandlesCanonicalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandlesCanonicalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_identifier'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      compoundIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_identifier'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      isBlacklisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_blacklisted'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      lastSeenUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_utc'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
    );
  }

  @override
  $HandlesCanonicalTable createAlias(String alias) {
    return $HandlesCanonicalTable(attachedDatabase, alias);
  }
}

class HandlesCanonicalData extends DataClass
    implements Insertable<HandlesCanonicalData> {
  final int id;
  final String rawIdentifier;
  final String displayName;
  final String compoundIdentifier;
  final String service;
  final bool isIgnored;
  final bool isVisible;
  final bool isBlacklisted;
  final String? country;
  final String? lastSeenUtc;
  final int? batchId;
  const HandlesCanonicalData({
    required this.id,
    required this.rawIdentifier,
    required this.displayName,
    required this.compoundIdentifier,
    required this.service,
    required this.isIgnored,
    required this.isVisible,
    required this.isBlacklisted,
    this.country,
    this.lastSeenUtc,
    this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_identifier'] = Variable<String>(rawIdentifier);
    map['display_name'] = Variable<String>(displayName);
    map['compound_identifier'] = Variable<String>(compoundIdentifier);
    map['service'] = Variable<String>(service);
    map['is_ignored'] = Variable<bool>(isIgnored);
    map['is_visible'] = Variable<bool>(isVisible);
    map['is_blacklisted'] = Variable<bool>(isBlacklisted);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || lastSeenUtc != null) {
      map['last_seen_utc'] = Variable<String>(lastSeenUtc);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    return map;
  }

  HandlesCanonicalCompanion toCompanion(bool nullToAbsent) {
    return HandlesCanonicalCompanion(
      id: Value(id),
      rawIdentifier: Value(rawIdentifier),
      displayName: Value(displayName),
      compoundIdentifier: Value(compoundIdentifier),
      service: Value(service),
      isIgnored: Value(isIgnored),
      isVisible: Value(isVisible),
      isBlacklisted: Value(isBlacklisted),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      lastSeenUtc: lastSeenUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenUtc),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
    );
  }

  factory HandlesCanonicalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandlesCanonicalData(
      id: serializer.fromJson<int>(json['id']),
      rawIdentifier: serializer.fromJson<String>(json['rawIdentifier']),
      displayName: serializer.fromJson<String>(json['displayName']),
      compoundIdentifier: serializer.fromJson<String>(
        json['compoundIdentifier'],
      ),
      service: serializer.fromJson<String>(json['service']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      isBlacklisted: serializer.fromJson<bool>(json['isBlacklisted']),
      country: serializer.fromJson<String?>(json['country']),
      lastSeenUtc: serializer.fromJson<String?>(json['lastSeenUtc']),
      batchId: serializer.fromJson<int?>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawIdentifier': serializer.toJson<String>(rawIdentifier),
      'displayName': serializer.toJson<String>(displayName),
      'compoundIdentifier': serializer.toJson<String>(compoundIdentifier),
      'service': serializer.toJson<String>(service),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'isVisible': serializer.toJson<bool>(isVisible),
      'isBlacklisted': serializer.toJson<bool>(isBlacklisted),
      'country': serializer.toJson<String?>(country),
      'lastSeenUtc': serializer.toJson<String?>(lastSeenUtc),
      'batchId': serializer.toJson<int?>(batchId),
    };
  }

  HandlesCanonicalData copyWith({
    int? id,
    String? rawIdentifier,
    String? displayName,
    String? compoundIdentifier,
    String? service,
    bool? isIgnored,
    bool? isVisible,
    bool? isBlacklisted,
    Value<String?> country = const Value.absent(),
    Value<String?> lastSeenUtc = const Value.absent(),
    Value<int?> batchId = const Value.absent(),
  }) => HandlesCanonicalData(
    id: id ?? this.id,
    rawIdentifier: rawIdentifier ?? this.rawIdentifier,
    displayName: displayName ?? this.displayName,
    compoundIdentifier: compoundIdentifier ?? this.compoundIdentifier,
    service: service ?? this.service,
    isIgnored: isIgnored ?? this.isIgnored,
    isVisible: isVisible ?? this.isVisible,
    isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    country: country.present ? country.value : this.country,
    lastSeenUtc: lastSeenUtc.present ? lastSeenUtc.value : this.lastSeenUtc,
    batchId: batchId.present ? batchId.value : this.batchId,
  );
  HandlesCanonicalData copyWithCompanion(HandlesCanonicalCompanion data) {
    return HandlesCanonicalData(
      id: data.id.present ? data.id.value : this.id,
      rawIdentifier: data.rawIdentifier.present
          ? data.rawIdentifier.value
          : this.rawIdentifier,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      compoundIdentifier: data.compoundIdentifier.present
          ? data.compoundIdentifier.value
          : this.compoundIdentifier,
      service: data.service.present ? data.service.value : this.service,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      isBlacklisted: data.isBlacklisted.present
          ? data.isBlacklisted.value
          : this.isBlacklisted,
      country: data.country.present ? data.country.value : this.country,
      lastSeenUtc: data.lastSeenUtc.present
          ? data.lastSeenUtc.value
          : this.lastSeenUtc,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandlesCanonicalData(')
          ..write('id: $id, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('displayName: $displayName, ')
          ..write('compoundIdentifier: $compoundIdentifier, ')
          ..write('service: $service, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('isVisible: $isVisible, ')
          ..write('isBlacklisted: $isBlacklisted, ')
          ..write('country: $country, ')
          ..write('lastSeenUtc: $lastSeenUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rawIdentifier,
    displayName,
    compoundIdentifier,
    service,
    isIgnored,
    isVisible,
    isBlacklisted,
    country,
    lastSeenUtc,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandlesCanonicalData &&
          other.id == this.id &&
          other.rawIdentifier == this.rawIdentifier &&
          other.displayName == this.displayName &&
          other.compoundIdentifier == this.compoundIdentifier &&
          other.service == this.service &&
          other.isIgnored == this.isIgnored &&
          other.isVisible == this.isVisible &&
          other.isBlacklisted == this.isBlacklisted &&
          other.country == this.country &&
          other.lastSeenUtc == this.lastSeenUtc &&
          other.batchId == this.batchId);
}

class HandlesCanonicalCompanion extends UpdateCompanion<HandlesCanonicalData> {
  final Value<int> id;
  final Value<String> rawIdentifier;
  final Value<String> displayName;
  final Value<String> compoundIdentifier;
  final Value<String> service;
  final Value<bool> isIgnored;
  final Value<bool> isVisible;
  final Value<bool> isBlacklisted;
  final Value<String?> country;
  final Value<String?> lastSeenUtc;
  final Value<int?> batchId;
  const HandlesCanonicalCompanion({
    this.id = const Value.absent(),
    this.rawIdentifier = const Value.absent(),
    this.displayName = const Value.absent(),
    this.compoundIdentifier = const Value.absent(),
    this.service = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isBlacklisted = const Value.absent(),
    this.country = const Value.absent(),
    this.lastSeenUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  HandlesCanonicalCompanion.insert({
    this.id = const Value.absent(),
    required String rawIdentifier,
    required String displayName,
    required String compoundIdentifier,
    this.service = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.isBlacklisted = const Value.absent(),
    this.country = const Value.absent(),
    this.lastSeenUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  }) : rawIdentifier = Value(rawIdentifier),
       displayName = Value(displayName),
       compoundIdentifier = Value(compoundIdentifier);
  static Insertable<HandlesCanonicalData> custom({
    Expression<int>? id,
    Expression<String>? rawIdentifier,
    Expression<String>? displayName,
    Expression<String>? compoundIdentifier,
    Expression<String>? service,
    Expression<bool>? isIgnored,
    Expression<bool>? isVisible,
    Expression<bool>? isBlacklisted,
    Expression<String>? country,
    Expression<String>? lastSeenUtc,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawIdentifier != null) 'raw_identifier': rawIdentifier,
      if (displayName != null) 'display_name': displayName,
      if (compoundIdentifier != null) 'compound_identifier': compoundIdentifier,
      if (service != null) 'service': service,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (isVisible != null) 'is_visible': isVisible,
      if (isBlacklisted != null) 'is_blacklisted': isBlacklisted,
      if (country != null) 'country': country,
      if (lastSeenUtc != null) 'last_seen_utc': lastSeenUtc,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  HandlesCanonicalCompanion copyWith({
    Value<int>? id,
    Value<String>? rawIdentifier,
    Value<String>? displayName,
    Value<String>? compoundIdentifier,
    Value<String>? service,
    Value<bool>? isIgnored,
    Value<bool>? isVisible,
    Value<bool>? isBlacklisted,
    Value<String?>? country,
    Value<String?>? lastSeenUtc,
    Value<int?>? batchId,
  }) {
    return HandlesCanonicalCompanion(
      id: id ?? this.id,
      rawIdentifier: rawIdentifier ?? this.rawIdentifier,
      displayName: displayName ?? this.displayName,
      compoundIdentifier: compoundIdentifier ?? this.compoundIdentifier,
      service: service ?? this.service,
      isIgnored: isIgnored ?? this.isIgnored,
      isVisible: isVisible ?? this.isVisible,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      country: country ?? this.country,
      lastSeenUtc: lastSeenUtc ?? this.lastSeenUtc,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawIdentifier.present) {
      map['raw_identifier'] = Variable<String>(rawIdentifier.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (compoundIdentifier.present) {
      map['compound_identifier'] = Variable<String>(compoundIdentifier.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (isBlacklisted.present) {
      map['is_blacklisted'] = Variable<bool>(isBlacklisted.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (lastSeenUtc.present) {
      map['last_seen_utc'] = Variable<String>(lastSeenUtc.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandlesCanonicalCompanion(')
          ..write('id: $id, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('displayName: $displayName, ')
          ..write('compoundIdentifier: $compoundIdentifier, ')
          ..write('service: $service, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('isVisible: $isVisible, ')
          ..write('isBlacklisted: $isBlacklisted, ')
          ..write('country: $country, ')
          ..write('lastSeenUtc: $lastSeenUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $WorkingParticipantsTable extends WorkingParticipants
    with TableInfo<$WorkingParticipantsTable, WorkingParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarRefMeta = const VerificationMeta(
    'avatarRef',
  );
  @override
  late final GeneratedColumn<String> avatarRef = GeneratedColumn<String>(
    'avatar_ref',
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
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<int> sourceRecordId = GeneratedColumn<int>(
    'source_record_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originalName,
    displayName,
    shortName,
    avatarRef,
    givenName,
    familyName,
    organization,
    isOrganization,
    createdAtUtc,
    updatedAtUtc,
    sourceRecordId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingParticipant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('avatar_ref')) {
      context.handle(
        _avatarRefMeta,
        avatarRef.isAcceptableOrUnknown(data['avatar_ref']!, _avatarRefMeta),
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
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkingParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingParticipant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      avatarRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_ref'],
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
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_record_id'],
      ),
    );
  }

  @override
  $WorkingParticipantsTable createAlias(String alias) {
    return $WorkingParticipantsTable(attachedDatabase, alias);
  }
}

class WorkingParticipant extends DataClass
    implements Insertable<WorkingParticipant> {
  final int id;
  final String originalName;
  final String displayName;
  final String shortName;
  final String? avatarRef;
  final String? givenName;
  final String? familyName;
  final String? organization;
  final bool isOrganization;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  final int? sourceRecordId;
  const WorkingParticipant({
    required this.id,
    required this.originalName,
    required this.displayName,
    required this.shortName,
    this.avatarRef,
    this.givenName,
    this.familyName,
    this.organization,
    required this.isOrganization,
    this.createdAtUtc,
    this.updatedAtUtc,
    this.sourceRecordId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_name'] = Variable<String>(originalName);
    map['display_name'] = Variable<String>(displayName);
    map['short_name'] = Variable<String>(shortName);
    if (!nullToAbsent || avatarRef != null) {
      map['avatar_ref'] = Variable<String>(avatarRef);
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
    if (!nullToAbsent || sourceRecordId != null) {
      map['source_record_id'] = Variable<int>(sourceRecordId);
    }
    return map;
  }

  WorkingParticipantsCompanion toCompanion(bool nullToAbsent) {
    return WorkingParticipantsCompanion(
      id: Value(id),
      originalName: Value(originalName),
      displayName: Value(displayName),
      shortName: Value(shortName),
      avatarRef: avatarRef == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarRef),
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
      sourceRecordId: sourceRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRecordId),
    );
  }

  factory WorkingParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingParticipant(
      id: serializer.fromJson<int>(json['id']),
      originalName: serializer.fromJson<String>(json['originalName']),
      displayName: serializer.fromJson<String>(json['displayName']),
      shortName: serializer.fromJson<String>(json['shortName']),
      avatarRef: serializer.fromJson<String?>(json['avatarRef']),
      givenName: serializer.fromJson<String?>(json['givenName']),
      familyName: serializer.fromJson<String?>(json['familyName']),
      organization: serializer.fromJson<String?>(json['organization']),
      isOrganization: serializer.fromJson<bool>(json['isOrganization']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
      sourceRecordId: serializer.fromJson<int?>(json['sourceRecordId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalName': serializer.toJson<String>(originalName),
      'displayName': serializer.toJson<String>(displayName),
      'shortName': serializer.toJson<String>(shortName),
      'avatarRef': serializer.toJson<String?>(avatarRef),
      'givenName': serializer.toJson<String?>(givenName),
      'familyName': serializer.toJson<String?>(familyName),
      'organization': serializer.toJson<String?>(organization),
      'isOrganization': serializer.toJson<bool>(isOrganization),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
      'sourceRecordId': serializer.toJson<int?>(sourceRecordId),
    };
  }

  WorkingParticipant copyWith({
    int? id,
    String? originalName,
    String? displayName,
    String? shortName,
    Value<String?> avatarRef = const Value.absent(),
    Value<String?> givenName = const Value.absent(),
    Value<String?> familyName = const Value.absent(),
    Value<String?> organization = const Value.absent(),
    bool? isOrganization,
    Value<String?> createdAtUtc = const Value.absent(),
    Value<String?> updatedAtUtc = const Value.absent(),
    Value<int?> sourceRecordId = const Value.absent(),
  }) => WorkingParticipant(
    id: id ?? this.id,
    originalName: originalName ?? this.originalName,
    displayName: displayName ?? this.displayName,
    shortName: shortName ?? this.shortName,
    avatarRef: avatarRef.present ? avatarRef.value : this.avatarRef,
    givenName: givenName.present ? givenName.value : this.givenName,
    familyName: familyName.present ? familyName.value : this.familyName,
    organization: organization.present ? organization.value : this.organization,
    isOrganization: isOrganization ?? this.isOrganization,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
    sourceRecordId: sourceRecordId.present
        ? sourceRecordId.value
        : this.sourceRecordId,
  );
  WorkingParticipant copyWithCompanion(WorkingParticipantsCompanion data) {
    return WorkingParticipant(
      id: data.id.present ? data.id.value : this.id,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      avatarRef: data.avatarRef.present ? data.avatarRef.value : this.avatarRef,
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
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingParticipant(')
          ..write('id: $id, ')
          ..write('originalName: $originalName, ')
          ..write('displayName: $displayName, ')
          ..write('shortName: $shortName, ')
          ..write('avatarRef: $avatarRef, ')
          ..write('givenName: $givenName, ')
          ..write('familyName: $familyName, ')
          ..write('organization: $organization, ')
          ..write('isOrganization: $isOrganization, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('sourceRecordId: $sourceRecordId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    originalName,
    displayName,
    shortName,
    avatarRef,
    givenName,
    familyName,
    organization,
    isOrganization,
    createdAtUtc,
    updatedAtUtc,
    sourceRecordId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingParticipant &&
          other.id == this.id &&
          other.originalName == this.originalName &&
          other.displayName == this.displayName &&
          other.shortName == this.shortName &&
          other.avatarRef == this.avatarRef &&
          other.givenName == this.givenName &&
          other.familyName == this.familyName &&
          other.organization == this.organization &&
          other.isOrganization == this.isOrganization &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.sourceRecordId == this.sourceRecordId);
}

class WorkingParticipantsCompanion extends UpdateCompanion<WorkingParticipant> {
  final Value<int> id;
  final Value<String> originalName;
  final Value<String> displayName;
  final Value<String> shortName;
  final Value<String?> avatarRef;
  final Value<String?> givenName;
  final Value<String?> familyName;
  final Value<String?> organization;
  final Value<bool> isOrganization;
  final Value<String?> createdAtUtc;
  final Value<String?> updatedAtUtc;
  final Value<int?> sourceRecordId;
  const WorkingParticipantsCompanion({
    this.id = const Value.absent(),
    this.originalName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.shortName = const Value.absent(),
    this.avatarRef = const Value.absent(),
    this.givenName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.organization = const Value.absent(),
    this.isOrganization = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
  });
  WorkingParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String originalName,
    required String displayName,
    required String shortName,
    this.avatarRef = const Value.absent(),
    this.givenName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.organization = const Value.absent(),
    this.isOrganization = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
  }) : originalName = Value(originalName),
       displayName = Value(displayName),
       shortName = Value(shortName);
  static Insertable<WorkingParticipant> custom({
    Expression<int>? id,
    Expression<String>? originalName,
    Expression<String>? displayName,
    Expression<String>? shortName,
    Expression<String>? avatarRef,
    Expression<String>? givenName,
    Expression<String>? familyName,
    Expression<String>? organization,
    Expression<bool>? isOrganization,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
    Expression<int>? sourceRecordId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalName != null) 'original_name': originalName,
      if (displayName != null) 'display_name': displayName,
      if (shortName != null) 'short_name': shortName,
      if (avatarRef != null) 'avatar_ref': avatarRef,
      if (givenName != null) 'given_name': givenName,
      if (familyName != null) 'family_name': familyName,
      if (organization != null) 'organization': organization,
      if (isOrganization != null) 'is_organization': isOrganization,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
    });
  }

  WorkingParticipantsCompanion copyWith({
    Value<int>? id,
    Value<String>? originalName,
    Value<String>? displayName,
    Value<String>? shortName,
    Value<String?>? avatarRef,
    Value<String?>? givenName,
    Value<String?>? familyName,
    Value<String?>? organization,
    Value<bool>? isOrganization,
    Value<String?>? createdAtUtc,
    Value<String?>? updatedAtUtc,
    Value<int?>? sourceRecordId,
  }) {
    return WorkingParticipantsCompanion(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      displayName: displayName ?? this.displayName,
      shortName: shortName ?? this.shortName,
      avatarRef: avatarRef ?? this.avatarRef,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      organization: organization ?? this.organization,
      isOrganization: isOrganization ?? this.isOrganization,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (avatarRef.present) {
      map['avatar_ref'] = Variable<String>(avatarRef.value);
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
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<int>(sourceRecordId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('originalName: $originalName, ')
          ..write('displayName: $displayName, ')
          ..write('shortName: $shortName, ')
          ..write('avatarRef: $avatarRef, ')
          ..write('givenName: $givenName, ')
          ..write('familyName: $familyName, ')
          ..write('organization: $organization, ')
          ..write('isOrganization: $isOrganization, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('sourceRecordId: $sourceRecordId')
          ..write(')'))
        .toString();
  }
}

class $HandleToParticipantTable extends HandleToParticipant
    with TableInfo<$HandleToParticipantTable, HandleToParticipantData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandleToParticipantTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES handles_canonical (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('addressbook'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    handleId,
    participantId,
    confidence,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handle_to_participant';
  @override
  VerificationContext validateIntegrity(
    Insertable<HandleToParticipantData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('handle_id')) {
      context.handle(
        _handleIdMeta,
        handleId.isAcceptableOrUnknown(data['handle_id']!, _handleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_handleIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {handleId, participantId},
  ];
  @override
  HandleToParticipantData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandleToParticipantData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      handleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handle_id'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $HandleToParticipantTable createAlias(String alias) {
    return $HandleToParticipantTable(attachedDatabase, alias);
  }
}

class HandleToParticipantData extends DataClass
    implements Insertable<HandleToParticipantData> {
  final int id;
  final int handleId;
  final int participantId;
  final double confidence;
  final String source;
  const HandleToParticipantData({
    required this.id,
    required this.handleId,
    required this.participantId,
    required this.confidence,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['handle_id'] = Variable<int>(handleId);
    map['participant_id'] = Variable<int>(participantId);
    map['confidence'] = Variable<double>(confidence);
    map['source'] = Variable<String>(source);
    return map;
  }

  HandleToParticipantCompanion toCompanion(bool nullToAbsent) {
    return HandleToParticipantCompanion(
      id: Value(id),
      handleId: Value(handleId),
      participantId: Value(participantId),
      confidence: Value(confidence),
      source: Value(source),
    );
  }

  factory HandleToParticipantData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandleToParticipantData(
      id: serializer.fromJson<int>(json['id']),
      handleId: serializer.fromJson<int>(json['handleId']),
      participantId: serializer.fromJson<int>(json['participantId']),
      confidence: serializer.fromJson<double>(json['confidence']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'handleId': serializer.toJson<int>(handleId),
      'participantId': serializer.toJson<int>(participantId),
      'confidence': serializer.toJson<double>(confidence),
      'source': serializer.toJson<String>(source),
    };
  }

  HandleToParticipantData copyWith({
    int? id,
    int? handleId,
    int? participantId,
    double? confidence,
    String? source,
  }) => HandleToParticipantData(
    id: id ?? this.id,
    handleId: handleId ?? this.handleId,
    participantId: participantId ?? this.participantId,
    confidence: confidence ?? this.confidence,
    source: source ?? this.source,
  );
  HandleToParticipantData copyWithCompanion(HandleToParticipantCompanion data) {
    return HandleToParticipantData(
      id: data.id.present ? data.id.value : this.id,
      handleId: data.handleId.present ? data.handleId.value : this.handleId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandleToParticipantData(')
          ..write('id: $id, ')
          ..write('handleId: $handleId, ')
          ..write('participantId: $participantId, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, handleId, participantId, confidence, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandleToParticipantData &&
          other.id == this.id &&
          other.handleId == this.handleId &&
          other.participantId == this.participantId &&
          other.confidence == this.confidence &&
          other.source == this.source);
}

class HandleToParticipantCompanion
    extends UpdateCompanion<HandleToParticipantData> {
  final Value<int> id;
  final Value<int> handleId;
  final Value<int> participantId;
  final Value<double> confidence;
  final Value<String> source;
  const HandleToParticipantCompanion({
    this.id = const Value.absent(),
    this.handleId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
  });
  HandleToParticipantCompanion.insert({
    this.id = const Value.absent(),
    required int handleId,
    required int participantId,
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
  }) : handleId = Value(handleId),
       participantId = Value(participantId);
  static Insertable<HandleToParticipantData> custom({
    Expression<int>? id,
    Expression<int>? handleId,
    Expression<int>? participantId,
    Expression<double>? confidence,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (handleId != null) 'handle_id': handleId,
      if (participantId != null) 'participant_id': participantId,
      if (confidence != null) 'confidence': confidence,
      if (source != null) 'source': source,
    });
  }

  HandleToParticipantCompanion copyWith({
    Value<int>? id,
    Value<int>? handleId,
    Value<int>? participantId,
    Value<double>? confidence,
    Value<String>? source,
  }) {
    return HandleToParticipantCompanion(
      id: id ?? this.id,
      handleId: handleId ?? this.handleId,
      participantId: participantId ?? this.participantId,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (handleId.present) {
      map['handle_id'] = Variable<int>(handleId.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandleToParticipantCompanion(')
          ..write('id: $id, ')
          ..write('handleId: $handleId, ')
          ..write('participantId: $participantId, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $HandlesCanonicalToAliasTable extends HandlesCanonicalToAlias
    with TableInfo<$HandlesCanonicalToAliasTable, HandlesCanonicalToAlia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandlesCanonicalToAliasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceHandleIdMeta = const VerificationMeta(
    'sourceHandleId',
  );
  @override
  late final GeneratedColumn<int> sourceHandleId = GeneratedColumn<int>(
    'source_handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canonicalHandleIdMeta = const VerificationMeta(
    'canonicalHandleId',
  );
  @override
  late final GeneratedColumn<int> canonicalHandleId = GeneratedColumn<int>(
    'canonical_handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles_canonical (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _compoundIdentifierMeta =
      const VerificationMeta('compoundIdentifier');
  @override
  late final GeneratedColumn<String> compoundIdentifier =
      GeneratedColumn<String>(
        'compound_identifier',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'Unknown\' CHECK(service IN (\'iMessage\',\'iMessageLite\',\'SMS\',\'RCS\',\'Unknown\'))',
    defaultValue: const CustomExpression('\'Unknown\''),
  );
  static const VerificationMeta _aliasKindMeta = const VerificationMeta(
    'aliasKind',
  );
  @override
  late final GeneratedColumn<String> aliasKind = GeneratedColumn<String>(
    'alias_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('variant'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceHandleId,
    canonicalHandleId,
    rawIdentifier,
    compoundIdentifier,
    normalizedIdentifier,
    service,
    aliasKind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handles_canonical_to_alias';
  @override
  VerificationContext validateIntegrity(
    Insertable<HandlesCanonicalToAlia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_handle_id')) {
      context.handle(
        _sourceHandleIdMeta,
        sourceHandleId.isAcceptableOrUnknown(
          data['source_handle_id']!,
          _sourceHandleIdMeta,
        ),
      );
    }
    if (data.containsKey('canonical_handle_id')) {
      context.handle(
        _canonicalHandleIdMeta,
        canonicalHandleId.isAcceptableOrUnknown(
          data['canonical_handle_id']!,
          _canonicalHandleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalHandleIdMeta);
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
    if (data.containsKey('compound_identifier')) {
      context.handle(
        _compoundIdentifierMeta,
        compoundIdentifier.isAcceptableOrUnknown(
          data['compound_identifier']!,
          _compoundIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compoundIdentifierMeta);
    }
    if (data.containsKey('normalized_identifier')) {
      context.handle(
        _normalizedIdentifierMeta,
        normalizedIdentifier.isAcceptableOrUnknown(
          data['normalized_identifier']!,
          _normalizedIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedIdentifierMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('alias_kind')) {
      context.handle(
        _aliasKindMeta,
        aliasKind.isAcceptableOrUnknown(data['alias_kind']!, _aliasKindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceHandleId};
  @override
  HandlesCanonicalToAlia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandlesCanonicalToAlia(
      sourceHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_handle_id'],
      )!,
      canonicalHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}canonical_handle_id'],
      )!,
      rawIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_identifier'],
      )!,
      compoundIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_identifier'],
      )!,
      normalizedIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_identifier'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      aliasKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_kind'],
      )!,
    );
  }

  @override
  $HandlesCanonicalToAliasTable createAlias(String alias) {
    return $HandlesCanonicalToAliasTable(attachedDatabase, alias);
  }
}

class HandlesCanonicalToAlia extends DataClass
    implements Insertable<HandlesCanonicalToAlia> {
  final int sourceHandleId;
  final int canonicalHandleId;
  final String rawIdentifier;
  final String compoundIdentifier;
  final String normalizedIdentifier;
  final String service;
  final String aliasKind;
  const HandlesCanonicalToAlia({
    required this.sourceHandleId,
    required this.canonicalHandleId,
    required this.rawIdentifier,
    required this.compoundIdentifier,
    required this.normalizedIdentifier,
    required this.service,
    required this.aliasKind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_handle_id'] = Variable<int>(sourceHandleId);
    map['canonical_handle_id'] = Variable<int>(canonicalHandleId);
    map['raw_identifier'] = Variable<String>(rawIdentifier);
    map['compound_identifier'] = Variable<String>(compoundIdentifier);
    map['normalized_identifier'] = Variable<String>(normalizedIdentifier);
    map['service'] = Variable<String>(service);
    map['alias_kind'] = Variable<String>(aliasKind);
    return map;
  }

  HandlesCanonicalToAliasCompanion toCompanion(bool nullToAbsent) {
    return HandlesCanonicalToAliasCompanion(
      sourceHandleId: Value(sourceHandleId),
      canonicalHandleId: Value(canonicalHandleId),
      rawIdentifier: Value(rawIdentifier),
      compoundIdentifier: Value(compoundIdentifier),
      normalizedIdentifier: Value(normalizedIdentifier),
      service: Value(service),
      aliasKind: Value(aliasKind),
    );
  }

  factory HandlesCanonicalToAlia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandlesCanonicalToAlia(
      sourceHandleId: serializer.fromJson<int>(json['sourceHandleId']),
      canonicalHandleId: serializer.fromJson<int>(json['canonicalHandleId']),
      rawIdentifier: serializer.fromJson<String>(json['rawIdentifier']),
      compoundIdentifier: serializer.fromJson<String>(
        json['compoundIdentifier'],
      ),
      normalizedIdentifier: serializer.fromJson<String>(
        json['normalizedIdentifier'],
      ),
      service: serializer.fromJson<String>(json['service']),
      aliasKind: serializer.fromJson<String>(json['aliasKind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceHandleId': serializer.toJson<int>(sourceHandleId),
      'canonicalHandleId': serializer.toJson<int>(canonicalHandleId),
      'rawIdentifier': serializer.toJson<String>(rawIdentifier),
      'compoundIdentifier': serializer.toJson<String>(compoundIdentifier),
      'normalizedIdentifier': serializer.toJson<String>(normalizedIdentifier),
      'service': serializer.toJson<String>(service),
      'aliasKind': serializer.toJson<String>(aliasKind),
    };
  }

  HandlesCanonicalToAlia copyWith({
    int? sourceHandleId,
    int? canonicalHandleId,
    String? rawIdentifier,
    String? compoundIdentifier,
    String? normalizedIdentifier,
    String? service,
    String? aliasKind,
  }) => HandlesCanonicalToAlia(
    sourceHandleId: sourceHandleId ?? this.sourceHandleId,
    canonicalHandleId: canonicalHandleId ?? this.canonicalHandleId,
    rawIdentifier: rawIdentifier ?? this.rawIdentifier,
    compoundIdentifier: compoundIdentifier ?? this.compoundIdentifier,
    normalizedIdentifier: normalizedIdentifier ?? this.normalizedIdentifier,
    service: service ?? this.service,
    aliasKind: aliasKind ?? this.aliasKind,
  );
  HandlesCanonicalToAlia copyWithCompanion(
    HandlesCanonicalToAliasCompanion data,
  ) {
    return HandlesCanonicalToAlia(
      sourceHandleId: data.sourceHandleId.present
          ? data.sourceHandleId.value
          : this.sourceHandleId,
      canonicalHandleId: data.canonicalHandleId.present
          ? data.canonicalHandleId.value
          : this.canonicalHandleId,
      rawIdentifier: data.rawIdentifier.present
          ? data.rawIdentifier.value
          : this.rawIdentifier,
      compoundIdentifier: data.compoundIdentifier.present
          ? data.compoundIdentifier.value
          : this.compoundIdentifier,
      normalizedIdentifier: data.normalizedIdentifier.present
          ? data.normalizedIdentifier.value
          : this.normalizedIdentifier,
      service: data.service.present ? data.service.value : this.service,
      aliasKind: data.aliasKind.present ? data.aliasKind.value : this.aliasKind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandlesCanonicalToAlia(')
          ..write('sourceHandleId: $sourceHandleId, ')
          ..write('canonicalHandleId: $canonicalHandleId, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('compoundIdentifier: $compoundIdentifier, ')
          ..write('normalizedIdentifier: $normalizedIdentifier, ')
          ..write('service: $service, ')
          ..write('aliasKind: $aliasKind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceHandleId,
    canonicalHandleId,
    rawIdentifier,
    compoundIdentifier,
    normalizedIdentifier,
    service,
    aliasKind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandlesCanonicalToAlia &&
          other.sourceHandleId == this.sourceHandleId &&
          other.canonicalHandleId == this.canonicalHandleId &&
          other.rawIdentifier == this.rawIdentifier &&
          other.compoundIdentifier == this.compoundIdentifier &&
          other.normalizedIdentifier == this.normalizedIdentifier &&
          other.service == this.service &&
          other.aliasKind == this.aliasKind);
}

class HandlesCanonicalToAliasCompanion
    extends UpdateCompanion<HandlesCanonicalToAlia> {
  final Value<int> sourceHandleId;
  final Value<int> canonicalHandleId;
  final Value<String> rawIdentifier;
  final Value<String> compoundIdentifier;
  final Value<String> normalizedIdentifier;
  final Value<String> service;
  final Value<String> aliasKind;
  const HandlesCanonicalToAliasCompanion({
    this.sourceHandleId = const Value.absent(),
    this.canonicalHandleId = const Value.absent(),
    this.rawIdentifier = const Value.absent(),
    this.compoundIdentifier = const Value.absent(),
    this.normalizedIdentifier = const Value.absent(),
    this.service = const Value.absent(),
    this.aliasKind = const Value.absent(),
  });
  HandlesCanonicalToAliasCompanion.insert({
    this.sourceHandleId = const Value.absent(),
    required int canonicalHandleId,
    required String rawIdentifier,
    required String compoundIdentifier,
    required String normalizedIdentifier,
    this.service = const Value.absent(),
    this.aliasKind = const Value.absent(),
  }) : canonicalHandleId = Value(canonicalHandleId),
       rawIdentifier = Value(rawIdentifier),
       compoundIdentifier = Value(compoundIdentifier),
       normalizedIdentifier = Value(normalizedIdentifier);
  static Insertable<HandlesCanonicalToAlia> custom({
    Expression<int>? sourceHandleId,
    Expression<int>? canonicalHandleId,
    Expression<String>? rawIdentifier,
    Expression<String>? compoundIdentifier,
    Expression<String>? normalizedIdentifier,
    Expression<String>? service,
    Expression<String>? aliasKind,
  }) {
    return RawValuesInsertable({
      if (sourceHandleId != null) 'source_handle_id': sourceHandleId,
      if (canonicalHandleId != null) 'canonical_handle_id': canonicalHandleId,
      if (rawIdentifier != null) 'raw_identifier': rawIdentifier,
      if (compoundIdentifier != null) 'compound_identifier': compoundIdentifier,
      if (normalizedIdentifier != null)
        'normalized_identifier': normalizedIdentifier,
      if (service != null) 'service': service,
      if (aliasKind != null) 'alias_kind': aliasKind,
    });
  }

  HandlesCanonicalToAliasCompanion copyWith({
    Value<int>? sourceHandleId,
    Value<int>? canonicalHandleId,
    Value<String>? rawIdentifier,
    Value<String>? compoundIdentifier,
    Value<String>? normalizedIdentifier,
    Value<String>? service,
    Value<String>? aliasKind,
  }) {
    return HandlesCanonicalToAliasCompanion(
      sourceHandleId: sourceHandleId ?? this.sourceHandleId,
      canonicalHandleId: canonicalHandleId ?? this.canonicalHandleId,
      rawIdentifier: rawIdentifier ?? this.rawIdentifier,
      compoundIdentifier: compoundIdentifier ?? this.compoundIdentifier,
      normalizedIdentifier: normalizedIdentifier ?? this.normalizedIdentifier,
      service: service ?? this.service,
      aliasKind: aliasKind ?? this.aliasKind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceHandleId.present) {
      map['source_handle_id'] = Variable<int>(sourceHandleId.value);
    }
    if (canonicalHandleId.present) {
      map['canonical_handle_id'] = Variable<int>(canonicalHandleId.value);
    }
    if (rawIdentifier.present) {
      map['raw_identifier'] = Variable<String>(rawIdentifier.value);
    }
    if (compoundIdentifier.present) {
      map['compound_identifier'] = Variable<String>(compoundIdentifier.value);
    }
    if (normalizedIdentifier.present) {
      map['normalized_identifier'] = Variable<String>(
        normalizedIdentifier.value,
      );
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (aliasKind.present) {
      map['alias_kind'] = Variable<String>(aliasKind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandlesCanonicalToAliasCompanion(')
          ..write('sourceHandleId: $sourceHandleId, ')
          ..write('canonicalHandleId: $canonicalHandleId, ')
          ..write('rawIdentifier: $rawIdentifier, ')
          ..write('compoundIdentifier: $compoundIdentifier, ')
          ..write('normalizedIdentifier: $normalizedIdentifier, ')
          ..write('service: $service, ')
          ..write('aliasKind: $aliasKind')
          ..write(')'))
        .toString();
  }
}

class $WorkingChatsTable extends WorkingChats
    with TableInfo<$WorkingChatsTable, WorkingChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingChatsTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'Unknown\' CHECK(service IN (\'iMessage\',\'iMessageLite\',\'SMS\',\'RCS\',\'Unknown\'))',
    defaultValue: const CustomExpression('\'Unknown\''),
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
  static const VerificationMeta _lastMessageAtUtcMeta = const VerificationMeta(
    'lastMessageAtUtc',
  );
  @override
  late final GeneratedColumn<String> lastMessageAtUtc = GeneratedColumn<String>(
    'last_message_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSenderHandleIdMeta =
      const VerificationMeta('lastSenderHandleId');
  @override
  late final GeneratedColumn<int> lastSenderHandleId = GeneratedColumn<int>(
    'last_sender_handle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles_canonical (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mutedUntilUtcMeta = const VerificationMeta(
    'mutedUntilUtc',
  );
  @override
  late final GeneratedColumn<String> mutedUntilUtc = GeneratedColumn<String>(
    'muted_until_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favouriteMeta = const VerificationMeta(
    'favourite',
  );
  @override
  late final GeneratedColumn<bool> favourite = GeneratedColumn<bool>(
    'favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favourite" IN (0, 1))',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    guid,
    service,
    isGroup,
    lastMessageAtUtc,
    lastSenderHandleId,
    lastMessagePreview,
    unreadCount,
    pinned,
    archived,
    mutedUntilUtc,
    favourite,
    createdAtUtc,
    updatedAtUtc,
    isIgnored,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('last_message_at_utc')) {
      context.handle(
        _lastMessageAtUtcMeta,
        lastMessageAtUtc.isAcceptableOrUnknown(
          data['last_message_at_utc']!,
          _lastMessageAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_sender_handle_id')) {
      context.handle(
        _lastSenderHandleIdMeta,
        lastSenderHandleId.isAcceptableOrUnknown(
          data['last_sender_handle_id']!,
          _lastSenderHandleIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('muted_until_utc')) {
      context.handle(
        _mutedUntilUtcMeta,
        mutedUntilUtc.isAcceptableOrUnknown(
          data['muted_until_utc']!,
          _mutedUntilUtcMeta,
        ),
      );
    }
    if (data.containsKey('favourite')) {
      context.handle(
        _favouriteMeta,
        favourite.isAcceptableOrUnknown(data['favourite']!, _favouriteMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {guid},
  ];
  @override
  WorkingChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingChat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      isGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_group'],
      )!,
      lastMessageAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_at_utc'],
      ),
      lastSenderHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sender_handle_id'],
      ),
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      mutedUntilUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muted_until_utc'],
      ),
      favourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favourite'],
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
    );
  }

  @override
  $WorkingChatsTable createAlias(String alias) {
    return $WorkingChatsTable(attachedDatabase, alias);
  }
}

class WorkingChat extends DataClass implements Insertable<WorkingChat> {
  final int id;
  final String guid;
  final String service;
  final bool isGroup;
  final String? lastMessageAtUtc;
  final int? lastSenderHandleId;
  final String? lastMessagePreview;
  final int unreadCount;
  final bool pinned;
  final bool archived;
  final String? mutedUntilUtc;
  final bool favourite;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  final bool isIgnored;
  const WorkingChat({
    required this.id,
    required this.guid,
    required this.service,
    required this.isGroup,
    this.lastMessageAtUtc,
    this.lastSenderHandleId,
    this.lastMessagePreview,
    required this.unreadCount,
    required this.pinned,
    required this.archived,
    this.mutedUntilUtc,
    required this.favourite,
    this.createdAtUtc,
    this.updatedAtUtc,
    required this.isIgnored,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['guid'] = Variable<String>(guid);
    map['service'] = Variable<String>(service);
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || lastMessageAtUtc != null) {
      map['last_message_at_utc'] = Variable<String>(lastMessageAtUtc);
    }
    if (!nullToAbsent || lastSenderHandleId != null) {
      map['last_sender_handle_id'] = Variable<int>(lastSenderHandleId);
    }
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || mutedUntilUtc != null) {
      map['muted_until_utc'] = Variable<String>(mutedUntilUtc);
    }
    map['favourite'] = Variable<bool>(favourite);
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    }
    map['is_ignored'] = Variable<bool>(isIgnored);
    return map;
  }

  WorkingChatsCompanion toCompanion(bool nullToAbsent) {
    return WorkingChatsCompanion(
      id: Value(id),
      guid: Value(guid),
      service: Value(service),
      isGroup: Value(isGroup),
      lastMessageAtUtc: lastMessageAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAtUtc),
      lastSenderHandleId: lastSenderHandleId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSenderHandleId),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      unreadCount: Value(unreadCount),
      pinned: Value(pinned),
      archived: Value(archived),
      mutedUntilUtc: mutedUntilUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(mutedUntilUtc),
      favourite: Value(favourite),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtUtc),
      isIgnored: Value(isIgnored),
    );
  }

  factory WorkingChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingChat(
      id: serializer.fromJson<int>(json['id']),
      guid: serializer.fromJson<String>(json['guid']),
      service: serializer.fromJson<String>(json['service']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      lastMessageAtUtc: serializer.fromJson<String?>(json['lastMessageAtUtc']),
      lastSenderHandleId: serializer.fromJson<int?>(json['lastSenderHandleId']),
      lastMessagePreview: serializer.fromJson<String?>(
        json['lastMessagePreview'],
      ),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      mutedUntilUtc: serializer.fromJson<String?>(json['mutedUntilUtc']),
      favourite: serializer.fromJson<bool>(json['favourite']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'guid': serializer.toJson<String>(guid),
      'service': serializer.toJson<String>(service),
      'isGroup': serializer.toJson<bool>(isGroup),
      'lastMessageAtUtc': serializer.toJson<String?>(lastMessageAtUtc),
      'lastSenderHandleId': serializer.toJson<int?>(lastSenderHandleId),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'mutedUntilUtc': serializer.toJson<String?>(mutedUntilUtc),
      'favourite': serializer.toJson<bool>(favourite),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
      'isIgnored': serializer.toJson<bool>(isIgnored),
    };
  }

  WorkingChat copyWith({
    int? id,
    String? guid,
    String? service,
    bool? isGroup,
    Value<String?> lastMessageAtUtc = const Value.absent(),
    Value<int?> lastSenderHandleId = const Value.absent(),
    Value<String?> lastMessagePreview = const Value.absent(),
    int? unreadCount,
    bool? pinned,
    bool? archived,
    Value<String?> mutedUntilUtc = const Value.absent(),
    bool? favourite,
    Value<String?> createdAtUtc = const Value.absent(),
    Value<String?> updatedAtUtc = const Value.absent(),
    bool? isIgnored,
  }) => WorkingChat(
    id: id ?? this.id,
    guid: guid ?? this.guid,
    service: service ?? this.service,
    isGroup: isGroup ?? this.isGroup,
    lastMessageAtUtc: lastMessageAtUtc.present
        ? lastMessageAtUtc.value
        : this.lastMessageAtUtc,
    lastSenderHandleId: lastSenderHandleId.present
        ? lastSenderHandleId.value
        : this.lastSenderHandleId,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    unreadCount: unreadCount ?? this.unreadCount,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    mutedUntilUtc: mutedUntilUtc.present
        ? mutedUntilUtc.value
        : this.mutedUntilUtc,
    favourite: favourite ?? this.favourite,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
    isIgnored: isIgnored ?? this.isIgnored,
  );
  WorkingChat copyWithCompanion(WorkingChatsCompanion data) {
    return WorkingChat(
      id: data.id.present ? data.id.value : this.id,
      guid: data.guid.present ? data.guid.value : this.guid,
      service: data.service.present ? data.service.value : this.service,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      lastMessageAtUtc: data.lastMessageAtUtc.present
          ? data.lastMessageAtUtc.value
          : this.lastMessageAtUtc,
      lastSenderHandleId: data.lastSenderHandleId.present
          ? data.lastSenderHandleId.value
          : this.lastSenderHandleId,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      mutedUntilUtc: data.mutedUntilUtc.present
          ? data.mutedUntilUtc.value
          : this.mutedUntilUtc,
      favourite: data.favourite.present ? data.favourite.value : this.favourite,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingChat(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('service: $service, ')
          ..write('isGroup: $isGroup, ')
          ..write('lastMessageAtUtc: $lastMessageAtUtc, ')
          ..write('lastSenderHandleId: $lastSenderHandleId, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('mutedUntilUtc: $mutedUntilUtc, ')
          ..write('favourite: $favourite, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isIgnored: $isIgnored')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    guid,
    service,
    isGroup,
    lastMessageAtUtc,
    lastSenderHandleId,
    lastMessagePreview,
    unreadCount,
    pinned,
    archived,
    mutedUntilUtc,
    favourite,
    createdAtUtc,
    updatedAtUtc,
    isIgnored,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingChat &&
          other.id == this.id &&
          other.guid == this.guid &&
          other.service == this.service &&
          other.isGroup == this.isGroup &&
          other.lastMessageAtUtc == this.lastMessageAtUtc &&
          other.lastSenderHandleId == this.lastSenderHandleId &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.unreadCount == this.unreadCount &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.mutedUntilUtc == this.mutedUntilUtc &&
          other.favourite == this.favourite &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.isIgnored == this.isIgnored);
}

class WorkingChatsCompanion extends UpdateCompanion<WorkingChat> {
  final Value<int> id;
  final Value<String> guid;
  final Value<String> service;
  final Value<bool> isGroup;
  final Value<String?> lastMessageAtUtc;
  final Value<int?> lastSenderHandleId;
  final Value<String?> lastMessagePreview;
  final Value<int> unreadCount;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<String?> mutedUntilUtc;
  final Value<bool> favourite;
  final Value<String?> createdAtUtc;
  final Value<String?> updatedAtUtc;
  final Value<bool> isIgnored;
  const WorkingChatsCompanion({
    this.id = const Value.absent(),
    this.guid = const Value.absent(),
    this.service = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.lastMessageAtUtc = const Value.absent(),
    this.lastSenderHandleId = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.mutedUntilUtc = const Value.absent(),
    this.favourite = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
  });
  WorkingChatsCompanion.insert({
    this.id = const Value.absent(),
    required String guid,
    this.service = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.lastMessageAtUtc = const Value.absent(),
    this.lastSenderHandleId = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.mutedUntilUtc = const Value.absent(),
    this.favourite = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
  }) : guid = Value(guid);
  static Insertable<WorkingChat> custom({
    Expression<int>? id,
    Expression<String>? guid,
    Expression<String>? service,
    Expression<bool>? isGroup,
    Expression<String>? lastMessageAtUtc,
    Expression<int>? lastSenderHandleId,
    Expression<String>? lastMessagePreview,
    Expression<int>? unreadCount,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<String>? mutedUntilUtc,
    Expression<bool>? favourite,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
    Expression<bool>? isIgnored,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (guid != null) 'guid': guid,
      if (service != null) 'service': service,
      if (isGroup != null) 'is_group': isGroup,
      if (lastMessageAtUtc != null) 'last_message_at_utc': lastMessageAtUtc,
      if (lastSenderHandleId != null)
        'last_sender_handle_id': lastSenderHandleId,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (mutedUntilUtc != null) 'muted_until_utc': mutedUntilUtc,
      if (favourite != null) 'favourite': favourite,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (isIgnored != null) 'is_ignored': isIgnored,
    });
  }

  WorkingChatsCompanion copyWith({
    Value<int>? id,
    Value<String>? guid,
    Value<String>? service,
    Value<bool>? isGroup,
    Value<String?>? lastMessageAtUtc,
    Value<int?>? lastSenderHandleId,
    Value<String?>? lastMessagePreview,
    Value<int>? unreadCount,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<String?>? mutedUntilUtc,
    Value<bool>? favourite,
    Value<String?>? createdAtUtc,
    Value<String?>? updatedAtUtc,
    Value<bool>? isIgnored,
  }) {
    return WorkingChatsCompanion(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      service: service ?? this.service,
      isGroup: isGroup ?? this.isGroup,
      lastMessageAtUtc: lastMessageAtUtc ?? this.lastMessageAtUtc,
      lastSenderHandleId: lastSenderHandleId ?? this.lastSenderHandleId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      mutedUntilUtc: mutedUntilUtc ?? this.mutedUntilUtc,
      favourite: favourite ?? this.favourite,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isIgnored: isIgnored ?? this.isIgnored,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (lastMessageAtUtc.present) {
      map['last_message_at_utc'] = Variable<String>(lastMessageAtUtc.value);
    }
    if (lastSenderHandleId.present) {
      map['last_sender_handle_id'] = Variable<int>(lastSenderHandleId.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (mutedUntilUtc.present) {
      map['muted_until_utc'] = Variable<String>(mutedUntilUtc.value);
    }
    if (favourite.present) {
      map['favourite'] = Variable<bool>(favourite.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingChatsCompanion(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('service: $service, ')
          ..write('isGroup: $isGroup, ')
          ..write('lastMessageAtUtc: $lastMessageAtUtc, ')
          ..write('lastSenderHandleId: $lastSenderHandleId, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('mutedUntilUtc: $mutedUntilUtc, ')
          ..write('favourite: $favourite, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isIgnored: $isIgnored')
          ..write(')'))
        .toString();
  }
}

class $ChatToHandleTable extends ChatToHandle
    with TableInfo<$ChatToHandleTable, ChatToHandleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatToHandleTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES handles_canonical (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    handleId,
    role,
    addedAtUtc,
    isIgnored,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_to_handle';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatToHandleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {chatId, handleId},
  ];
  @override
  ChatToHandleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatToHandleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
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
      )!,
      addedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_at_utc'],
      ),
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
    );
  }

  @override
  $ChatToHandleTable createAlias(String alias) {
    return $ChatToHandleTable(attachedDatabase, alias);
  }
}

class ChatToHandleData extends DataClass
    implements Insertable<ChatToHandleData> {
  final int id;
  final int chatId;
  final int handleId;
  final String role;
  final String? addedAtUtc;
  final bool isIgnored;
  const ChatToHandleData({
    required this.id,
    required this.chatId,
    required this.handleId,
    required this.role,
    this.addedAtUtc,
    required this.isIgnored,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<int>(chatId);
    map['handle_id'] = Variable<int>(handleId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || addedAtUtc != null) {
      map['added_at_utc'] = Variable<String>(addedAtUtc);
    }
    map['is_ignored'] = Variable<bool>(isIgnored);
    return map;
  }

  ChatToHandleCompanion toCompanion(bool nullToAbsent) {
    return ChatToHandleCompanion(
      id: Value(id),
      chatId: Value(chatId),
      handleId: Value(handleId),
      role: Value(role),
      addedAtUtc: addedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAtUtc),
      isIgnored: Value(isIgnored),
    );
  }

  factory ChatToHandleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatToHandleData(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      handleId: serializer.fromJson<int>(json['handleId']),
      role: serializer.fromJson<String>(json['role']),
      addedAtUtc: serializer.fromJson<String?>(json['addedAtUtc']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<int>(chatId),
      'handleId': serializer.toJson<int>(handleId),
      'role': serializer.toJson<String>(role),
      'addedAtUtc': serializer.toJson<String?>(addedAtUtc),
      'isIgnored': serializer.toJson<bool>(isIgnored),
    };
  }

  ChatToHandleData copyWith({
    int? id,
    int? chatId,
    int? handleId,
    String? role,
    Value<String?> addedAtUtc = const Value.absent(),
    bool? isIgnored,
  }) => ChatToHandleData(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    handleId: handleId ?? this.handleId,
    role: role ?? this.role,
    addedAtUtc: addedAtUtc.present ? addedAtUtc.value : this.addedAtUtc,
    isIgnored: isIgnored ?? this.isIgnored,
  );
  ChatToHandleData copyWithCompanion(ChatToHandleCompanion data) {
    return ChatToHandleData(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      handleId: data.handleId.present ? data.handleId.value : this.handleId,
      role: data.role.present ? data.role.value : this.role,
      addedAtUtc: data.addedAtUtc.present
          ? data.addedAtUtc.value
          : this.addedAtUtc,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatToHandleData(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('handleId: $handleId, ')
          ..write('role: $role, ')
          ..write('addedAtUtc: $addedAtUtc, ')
          ..write('isIgnored: $isIgnored')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, chatId, handleId, role, addedAtUtc, isIgnored);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatToHandleData &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.handleId == this.handleId &&
          other.role == this.role &&
          other.addedAtUtc == this.addedAtUtc &&
          other.isIgnored == this.isIgnored);
}

class ChatToHandleCompanion extends UpdateCompanion<ChatToHandleData> {
  final Value<int> id;
  final Value<int> chatId;
  final Value<int> handleId;
  final Value<String> role;
  final Value<String?> addedAtUtc;
  final Value<bool> isIgnored;
  const ChatToHandleCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.handleId = const Value.absent(),
    this.role = const Value.absent(),
    this.addedAtUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
  });
  ChatToHandleCompanion.insert({
    this.id = const Value.absent(),
    required int chatId,
    required int handleId,
    this.role = const Value.absent(),
    this.addedAtUtc = const Value.absent(),
    this.isIgnored = const Value.absent(),
  }) : chatId = Value(chatId),
       handleId = Value(handleId);
  static Insertable<ChatToHandleData> custom({
    Expression<int>? id,
    Expression<int>? chatId,
    Expression<int>? handleId,
    Expression<String>? role,
    Expression<String>? addedAtUtc,
    Expression<bool>? isIgnored,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (handleId != null) 'handle_id': handleId,
      if (role != null) 'role': role,
      if (addedAtUtc != null) 'added_at_utc': addedAtUtc,
      if (isIgnored != null) 'is_ignored': isIgnored,
    });
  }

  ChatToHandleCompanion copyWith({
    Value<int>? id,
    Value<int>? chatId,
    Value<int>? handleId,
    Value<String>? role,
    Value<String?>? addedAtUtc,
    Value<bool>? isIgnored,
  }) {
    return ChatToHandleCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      handleId: handleId ?? this.handleId,
      role: role ?? this.role,
      addedAtUtc: addedAtUtc ?? this.addedAtUtc,
      isIgnored: isIgnored ?? this.isIgnored,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
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
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatToHandleCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('handleId: $handleId, ')
          ..write('role: $role, ')
          ..write('addedAtUtc: $addedAtUtc, ')
          ..write('isIgnored: $isIgnored')
          ..write(')'))
        .toString();
  }
}

class $WorkingMessagesTable extends WorkingMessages
    with TableInfo<$WorkingMessagesTable, WorkingMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingMessagesTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES handles_canonical (id) ON DELETE SET NULL',
    ),
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
  static const VerificationMeta _sentAtUtcMeta = const VerificationMeta(
    'sentAtUtc',
  );
  @override
  late final GeneratedColumn<String> sentAtUtc = GeneratedColumn<String>(
    'sent_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtUtcMeta = const VerificationMeta(
    'deliveredAtUtc',
  );
  @override
  late final GeneratedColumn<String> deliveredAtUtc = GeneratedColumn<String>(
    'delivered_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtUtcMeta = const VerificationMeta(
    'readAtUtc',
  );
  @override
  late final GeneratedColumn<String> readAtUtc = GeneratedColumn<String>(
    'read_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'unknown\' CHECK(status IN (\'unknown\',\'sent\',\'delivered\',\'read\',\'failed\'))',
    defaultValue: const CustomExpression('\'unknown\''),
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
  static const VerificationMeta _hasAttachmentsMeta = const VerificationMeta(
    'hasAttachments',
  );
  @override
  late final GeneratedColumn<bool> hasAttachments = GeneratedColumn<bool>(
    'has_attachments',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_attachments" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _replyToGuidMeta = const VerificationMeta(
    'replyToGuid',
  );
  @override
  late final GeneratedColumn<String> replyToGuid = GeneratedColumn<String>(
    'reply_to_guid',
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
  static const VerificationMeta _systemTypeMeta = const VerificationMeta(
    'systemType',
  );
  @override
  late final GeneratedColumn<String> systemType = GeneratedColumn<String>(
    'system_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reactionCarrierMeta = const VerificationMeta(
    'reactionCarrier',
  );
  @override
  late final GeneratedColumn<bool> reactionCarrier = GeneratedColumn<bool>(
    'reaction_carrier',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reaction_carrier" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _reactionSummaryJsonMeta =
      const VerificationMeta('reactionSummaryJson');
  @override
  late final GeneratedColumn<String> reactionSummaryJson =
      GeneratedColumn<String>(
        'reaction_summary_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedLocalMeta = const VerificationMeta(
    'isDeletedLocal',
  );
  @override
  late final GeneratedColumn<bool> isDeletedLocal = GeneratedColumn<bool>(
    'is_deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    guid,
    chatId,
    senderHandleId,
    isFromMe,
    sentAtUtc,
    deliveredAtUtc,
    readAtUtc,
    status,
    textContent,
    itemType,
    isSystemMessage,
    errorCode,
    hasAttachments,
    replyToGuid,
    associatedMessageGuid,
    threadOriginatorGuid,
    systemType,
    reactionCarrier,
    balloonBundleId,
    payloadJson,
    reactionSummaryJson,
    isStarred,
    isDeletedLocal,
    updatedAtUtc,
    batchId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('is_from_me')) {
      context.handle(
        _isFromMeMeta,
        isFromMe.isAcceptableOrUnknown(data['is_from_me']!, _isFromMeMeta),
      );
    }
    if (data.containsKey('sent_at_utc')) {
      context.handle(
        _sentAtUtcMeta,
        sentAtUtc.isAcceptableOrUnknown(data['sent_at_utc']!, _sentAtUtcMeta),
      );
    }
    if (data.containsKey('delivered_at_utc')) {
      context.handle(
        _deliveredAtUtcMeta,
        deliveredAtUtc.isAcceptableOrUnknown(
          data['delivered_at_utc']!,
          _deliveredAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('read_at_utc')) {
      context.handle(
        _readAtUtcMeta,
        readAtUtc.isAcceptableOrUnknown(data['read_at_utc']!, _readAtUtcMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
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
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('has_attachments')) {
      context.handle(
        _hasAttachmentsMeta,
        hasAttachments.isAcceptableOrUnknown(
          data['has_attachments']!,
          _hasAttachmentsMeta,
        ),
      );
    }
    if (data.containsKey('reply_to_guid')) {
      context.handle(
        _replyToGuidMeta,
        replyToGuid.isAcceptableOrUnknown(
          data['reply_to_guid']!,
          _replyToGuidMeta,
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
    if (data.containsKey('thread_originator_guid')) {
      context.handle(
        _threadOriginatorGuidMeta,
        threadOriginatorGuid.isAcceptableOrUnknown(
          data['thread_originator_guid']!,
          _threadOriginatorGuidMeta,
        ),
      );
    }
    if (data.containsKey('system_type')) {
      context.handle(
        _systemTypeMeta,
        systemType.isAcceptableOrUnknown(data['system_type']!, _systemTypeMeta),
      );
    }
    if (data.containsKey('reaction_carrier')) {
      context.handle(
        _reactionCarrierMeta,
        reactionCarrier.isAcceptableOrUnknown(
          data['reaction_carrier']!,
          _reactionCarrierMeta,
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
    if (data.containsKey('reaction_summary_json')) {
      context.handle(
        _reactionSummaryJsonMeta,
        reactionSummaryJson.isAcceptableOrUnknown(
          data['reaction_summary_json']!,
          _reactionSummaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_deleted_local')) {
      context.handle(
        _isDeletedLocalMeta,
        isDeletedLocal.isAcceptableOrUnknown(
          data['is_deleted_local']!,
          _isDeletedLocalMeta,
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
  WorkingMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
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
      isFromMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_from_me'],
      )!,
      sentAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_at_utc'],
      ),
      deliveredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivered_at_utc'],
      ),
      readAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}read_at_utc'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      ),
      isSystemMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_message'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_code'],
      ),
      hasAttachments: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_attachments'],
      )!,
      replyToGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to_guid'],
      ),
      associatedMessageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}associated_message_guid'],
      ),
      threadOriginatorGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_originator_guid'],
      ),
      systemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_type'],
      ),
      reactionCarrier: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reaction_carrier'],
      )!,
      balloonBundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balloon_bundle_id'],
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      reactionSummaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction_summary_json'],
      ),
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isDeletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted_local'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
    );
  }

  @override
  $WorkingMessagesTable createAlias(String alias) {
    return $WorkingMessagesTable(attachedDatabase, alias);
  }
}

class WorkingMessage extends DataClass implements Insertable<WorkingMessage> {
  final int id;
  final String guid;
  final int chatId;
  final int? senderHandleId;
  final bool isFromMe;
  final String? sentAtUtc;
  final String? deliveredAtUtc;
  final String? readAtUtc;
  final String status;
  final String? textContent;
  final String? itemType;
  final bool isSystemMessage;
  final int? errorCode;
  final bool hasAttachments;
  final String? replyToGuid;
  final String? associatedMessageGuid;
  final String? threadOriginatorGuid;
  final String? systemType;
  final bool reactionCarrier;
  final String? balloonBundleId;
  final String? payloadJson;
  final String? reactionSummaryJson;
  final bool isStarred;
  final bool isDeletedLocal;
  final String? updatedAtUtc;
  final int? batchId;
  const WorkingMessage({
    required this.id,
    required this.guid,
    required this.chatId,
    this.senderHandleId,
    required this.isFromMe,
    this.sentAtUtc,
    this.deliveredAtUtc,
    this.readAtUtc,
    required this.status,
    this.textContent,
    this.itemType,
    required this.isSystemMessage,
    this.errorCode,
    required this.hasAttachments,
    this.replyToGuid,
    this.associatedMessageGuid,
    this.threadOriginatorGuid,
    this.systemType,
    required this.reactionCarrier,
    this.balloonBundleId,
    this.payloadJson,
    this.reactionSummaryJson,
    required this.isStarred,
    required this.isDeletedLocal,
    this.updatedAtUtc,
    this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['guid'] = Variable<String>(guid);
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || senderHandleId != null) {
      map['sender_handle_id'] = Variable<int>(senderHandleId);
    }
    map['is_from_me'] = Variable<bool>(isFromMe);
    if (!nullToAbsent || sentAtUtc != null) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc);
    }
    if (!nullToAbsent || deliveredAtUtc != null) {
      map['delivered_at_utc'] = Variable<String>(deliveredAtUtc);
    }
    if (!nullToAbsent || readAtUtc != null) {
      map['read_at_utc'] = Variable<String>(readAtUtc);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || textContent != null) {
      map['text'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || itemType != null) {
      map['item_type'] = Variable<String>(itemType);
    }
    map['is_system_message'] = Variable<bool>(isSystemMessage);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<int>(errorCode);
    }
    map['has_attachments'] = Variable<bool>(hasAttachments);
    if (!nullToAbsent || replyToGuid != null) {
      map['reply_to_guid'] = Variable<String>(replyToGuid);
    }
    if (!nullToAbsent || associatedMessageGuid != null) {
      map['associated_message_guid'] = Variable<String>(associatedMessageGuid);
    }
    if (!nullToAbsent || threadOriginatorGuid != null) {
      map['thread_originator_guid'] = Variable<String>(threadOriginatorGuid);
    }
    if (!nullToAbsent || systemType != null) {
      map['system_type'] = Variable<String>(systemType);
    }
    map['reaction_carrier'] = Variable<bool>(reactionCarrier);
    if (!nullToAbsent || balloonBundleId != null) {
      map['balloon_bundle_id'] = Variable<String>(balloonBundleId);
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    if (!nullToAbsent || reactionSummaryJson != null) {
      map['reaction_summary_json'] = Variable<String>(reactionSummaryJson);
    }
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_deleted_local'] = Variable<bool>(isDeletedLocal);
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    return map;
  }

  WorkingMessagesCompanion toCompanion(bool nullToAbsent) {
    return WorkingMessagesCompanion(
      id: Value(id),
      guid: Value(guid),
      chatId: Value(chatId),
      senderHandleId: senderHandleId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderHandleId),
      isFromMe: Value(isFromMe),
      sentAtUtc: sentAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAtUtc),
      deliveredAtUtc: deliveredAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAtUtc),
      readAtUtc: readAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(readAtUtc),
      status: Value(status),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      itemType: itemType == null && nullToAbsent
          ? const Value.absent()
          : Value(itemType),
      isSystemMessage: Value(isSystemMessage),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      hasAttachments: Value(hasAttachments),
      replyToGuid: replyToGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToGuid),
      associatedMessageGuid: associatedMessageGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(associatedMessageGuid),
      threadOriginatorGuid: threadOriginatorGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(threadOriginatorGuid),
      systemType: systemType == null && nullToAbsent
          ? const Value.absent()
          : Value(systemType),
      reactionCarrier: Value(reactionCarrier),
      balloonBundleId: balloonBundleId == null && nullToAbsent
          ? const Value.absent()
          : Value(balloonBundleId),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      reactionSummaryJson: reactionSummaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(reactionSummaryJson),
      isStarred: Value(isStarred),
      isDeletedLocal: Value(isDeletedLocal),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtUtc),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
    );
  }

  factory WorkingMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingMessage(
      id: serializer.fromJson<int>(json['id']),
      guid: serializer.fromJson<String>(json['guid']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderHandleId: serializer.fromJson<int?>(json['senderHandleId']),
      isFromMe: serializer.fromJson<bool>(json['isFromMe']),
      sentAtUtc: serializer.fromJson<String?>(json['sentAtUtc']),
      deliveredAtUtc: serializer.fromJson<String?>(json['deliveredAtUtc']),
      readAtUtc: serializer.fromJson<String?>(json['readAtUtc']),
      status: serializer.fromJson<String>(json['status']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      itemType: serializer.fromJson<String?>(json['itemType']),
      isSystemMessage: serializer.fromJson<bool>(json['isSystemMessage']),
      errorCode: serializer.fromJson<int?>(json['errorCode']),
      hasAttachments: serializer.fromJson<bool>(json['hasAttachments']),
      replyToGuid: serializer.fromJson<String?>(json['replyToGuid']),
      associatedMessageGuid: serializer.fromJson<String?>(
        json['associatedMessageGuid'],
      ),
      threadOriginatorGuid: serializer.fromJson<String?>(
        json['threadOriginatorGuid'],
      ),
      systemType: serializer.fromJson<String?>(json['systemType']),
      reactionCarrier: serializer.fromJson<bool>(json['reactionCarrier']),
      balloonBundleId: serializer.fromJson<String?>(json['balloonBundleId']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      reactionSummaryJson: serializer.fromJson<String?>(
        json['reactionSummaryJson'],
      ),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isDeletedLocal: serializer.fromJson<bool>(json['isDeletedLocal']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
      batchId: serializer.fromJson<int?>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'guid': serializer.toJson<String>(guid),
      'chatId': serializer.toJson<int>(chatId),
      'senderHandleId': serializer.toJson<int?>(senderHandleId),
      'isFromMe': serializer.toJson<bool>(isFromMe),
      'sentAtUtc': serializer.toJson<String?>(sentAtUtc),
      'deliveredAtUtc': serializer.toJson<String?>(deliveredAtUtc),
      'readAtUtc': serializer.toJson<String?>(readAtUtc),
      'status': serializer.toJson<String>(status),
      'textContent': serializer.toJson<String?>(textContent),
      'itemType': serializer.toJson<String?>(itemType),
      'isSystemMessage': serializer.toJson<bool>(isSystemMessage),
      'errorCode': serializer.toJson<int?>(errorCode),
      'hasAttachments': serializer.toJson<bool>(hasAttachments),
      'replyToGuid': serializer.toJson<String?>(replyToGuid),
      'associatedMessageGuid': serializer.toJson<String?>(
        associatedMessageGuid,
      ),
      'threadOriginatorGuid': serializer.toJson<String?>(threadOriginatorGuid),
      'systemType': serializer.toJson<String?>(systemType),
      'reactionCarrier': serializer.toJson<bool>(reactionCarrier),
      'balloonBundleId': serializer.toJson<String?>(balloonBundleId),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'reactionSummaryJson': serializer.toJson<String?>(reactionSummaryJson),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isDeletedLocal': serializer.toJson<bool>(isDeletedLocal),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
      'batchId': serializer.toJson<int?>(batchId),
    };
  }

  WorkingMessage copyWith({
    int? id,
    String? guid,
    int? chatId,
    Value<int?> senderHandleId = const Value.absent(),
    bool? isFromMe,
    Value<String?> sentAtUtc = const Value.absent(),
    Value<String?> deliveredAtUtc = const Value.absent(),
    Value<String?> readAtUtc = const Value.absent(),
    String? status,
    Value<String?> textContent = const Value.absent(),
    Value<String?> itemType = const Value.absent(),
    bool? isSystemMessage,
    Value<int?> errorCode = const Value.absent(),
    bool? hasAttachments,
    Value<String?> replyToGuid = const Value.absent(),
    Value<String?> associatedMessageGuid = const Value.absent(),
    Value<String?> threadOriginatorGuid = const Value.absent(),
    Value<String?> systemType = const Value.absent(),
    bool? reactionCarrier,
    Value<String?> balloonBundleId = const Value.absent(),
    Value<String?> payloadJson = const Value.absent(),
    Value<String?> reactionSummaryJson = const Value.absent(),
    bool? isStarred,
    bool? isDeletedLocal,
    Value<String?> updatedAtUtc = const Value.absent(),
    Value<int?> batchId = const Value.absent(),
  }) => WorkingMessage(
    id: id ?? this.id,
    guid: guid ?? this.guid,
    chatId: chatId ?? this.chatId,
    senderHandleId: senderHandleId.present
        ? senderHandleId.value
        : this.senderHandleId,
    isFromMe: isFromMe ?? this.isFromMe,
    sentAtUtc: sentAtUtc.present ? sentAtUtc.value : this.sentAtUtc,
    deliveredAtUtc: deliveredAtUtc.present
        ? deliveredAtUtc.value
        : this.deliveredAtUtc,
    readAtUtc: readAtUtc.present ? readAtUtc.value : this.readAtUtc,
    status: status ?? this.status,
    textContent: textContent.present ? textContent.value : this.textContent,
    itemType: itemType.present ? itemType.value : this.itemType,
    isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    hasAttachments: hasAttachments ?? this.hasAttachments,
    replyToGuid: replyToGuid.present ? replyToGuid.value : this.replyToGuid,
    associatedMessageGuid: associatedMessageGuid.present
        ? associatedMessageGuid.value
        : this.associatedMessageGuid,
    threadOriginatorGuid: threadOriginatorGuid.present
        ? threadOriginatorGuid.value
        : this.threadOriginatorGuid,
    systemType: systemType.present ? systemType.value : this.systemType,
    reactionCarrier: reactionCarrier ?? this.reactionCarrier,
    balloonBundleId: balloonBundleId.present
        ? balloonBundleId.value
        : this.balloonBundleId,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    reactionSummaryJson: reactionSummaryJson.present
        ? reactionSummaryJson.value
        : this.reactionSummaryJson,
    isStarred: isStarred ?? this.isStarred,
    isDeletedLocal: isDeletedLocal ?? this.isDeletedLocal,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
    batchId: batchId.present ? batchId.value : this.batchId,
  );
  WorkingMessage copyWithCompanion(WorkingMessagesCompanion data) {
    return WorkingMessage(
      id: data.id.present ? data.id.value : this.id,
      guid: data.guid.present ? data.guid.value : this.guid,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderHandleId: data.senderHandleId.present
          ? data.senderHandleId.value
          : this.senderHandleId,
      isFromMe: data.isFromMe.present ? data.isFromMe.value : this.isFromMe,
      sentAtUtc: data.sentAtUtc.present ? data.sentAtUtc.value : this.sentAtUtc,
      deliveredAtUtc: data.deliveredAtUtc.present
          ? data.deliveredAtUtc.value
          : this.deliveredAtUtc,
      readAtUtc: data.readAtUtc.present ? data.readAtUtc.value : this.readAtUtc,
      status: data.status.present ? data.status.value : this.status,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      isSystemMessage: data.isSystemMessage.present
          ? data.isSystemMessage.value
          : this.isSystemMessage,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      hasAttachments: data.hasAttachments.present
          ? data.hasAttachments.value
          : this.hasAttachments,
      replyToGuid: data.replyToGuid.present
          ? data.replyToGuid.value
          : this.replyToGuid,
      associatedMessageGuid: data.associatedMessageGuid.present
          ? data.associatedMessageGuid.value
          : this.associatedMessageGuid,
      threadOriginatorGuid: data.threadOriginatorGuid.present
          ? data.threadOriginatorGuid.value
          : this.threadOriginatorGuid,
      systemType: data.systemType.present
          ? data.systemType.value
          : this.systemType,
      reactionCarrier: data.reactionCarrier.present
          ? data.reactionCarrier.value
          : this.reactionCarrier,
      balloonBundleId: data.balloonBundleId.present
          ? data.balloonBundleId.value
          : this.balloonBundleId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      reactionSummaryJson: data.reactionSummaryJson.present
          ? data.reactionSummaryJson.value
          : this.reactionSummaryJson,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isDeletedLocal: data.isDeletedLocal.present
          ? data.isDeletedLocal.value
          : this.isDeletedLocal,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingMessage(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('chatId: $chatId, ')
          ..write('senderHandleId: $senderHandleId, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('deliveredAtUtc: $deliveredAtUtc, ')
          ..write('readAtUtc: $readAtUtc, ')
          ..write('status: $status, ')
          ..write('textContent: $textContent, ')
          ..write('itemType: $itemType, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('errorCode: $errorCode, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('replyToGuid: $replyToGuid, ')
          ..write('associatedMessageGuid: $associatedMessageGuid, ')
          ..write('threadOriginatorGuid: $threadOriginatorGuid, ')
          ..write('systemType: $systemType, ')
          ..write('reactionCarrier: $reactionCarrier, ')
          ..write('balloonBundleId: $balloonBundleId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('reactionSummaryJson: $reactionSummaryJson, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeletedLocal: $isDeletedLocal, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    guid,
    chatId,
    senderHandleId,
    isFromMe,
    sentAtUtc,
    deliveredAtUtc,
    readAtUtc,
    status,
    textContent,
    itemType,
    isSystemMessage,
    errorCode,
    hasAttachments,
    replyToGuid,
    associatedMessageGuid,
    threadOriginatorGuid,
    systemType,
    reactionCarrier,
    balloonBundleId,
    payloadJson,
    reactionSummaryJson,
    isStarred,
    isDeletedLocal,
    updatedAtUtc,
    batchId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingMessage &&
          other.id == this.id &&
          other.guid == this.guid &&
          other.chatId == this.chatId &&
          other.senderHandleId == this.senderHandleId &&
          other.isFromMe == this.isFromMe &&
          other.sentAtUtc == this.sentAtUtc &&
          other.deliveredAtUtc == this.deliveredAtUtc &&
          other.readAtUtc == this.readAtUtc &&
          other.status == this.status &&
          other.textContent == this.textContent &&
          other.itemType == this.itemType &&
          other.isSystemMessage == this.isSystemMessage &&
          other.errorCode == this.errorCode &&
          other.hasAttachments == this.hasAttachments &&
          other.replyToGuid == this.replyToGuid &&
          other.associatedMessageGuid == this.associatedMessageGuid &&
          other.threadOriginatorGuid == this.threadOriginatorGuid &&
          other.systemType == this.systemType &&
          other.reactionCarrier == this.reactionCarrier &&
          other.balloonBundleId == this.balloonBundleId &&
          other.payloadJson == this.payloadJson &&
          other.reactionSummaryJson == this.reactionSummaryJson &&
          other.isStarred == this.isStarred &&
          other.isDeletedLocal == this.isDeletedLocal &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.batchId == this.batchId);
}

class WorkingMessagesCompanion extends UpdateCompanion<WorkingMessage> {
  final Value<int> id;
  final Value<String> guid;
  final Value<int> chatId;
  final Value<int?> senderHandleId;
  final Value<bool> isFromMe;
  final Value<String?> sentAtUtc;
  final Value<String?> deliveredAtUtc;
  final Value<String?> readAtUtc;
  final Value<String> status;
  final Value<String?> textContent;
  final Value<String?> itemType;
  final Value<bool> isSystemMessage;
  final Value<int?> errorCode;
  final Value<bool> hasAttachments;
  final Value<String?> replyToGuid;
  final Value<String?> associatedMessageGuid;
  final Value<String?> threadOriginatorGuid;
  final Value<String?> systemType;
  final Value<bool> reactionCarrier;
  final Value<String?> balloonBundleId;
  final Value<String?> payloadJson;
  final Value<String?> reactionSummaryJson;
  final Value<bool> isStarred;
  final Value<bool> isDeletedLocal;
  final Value<String?> updatedAtUtc;
  final Value<int?> batchId;
  const WorkingMessagesCompanion({
    this.id = const Value.absent(),
    this.guid = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderHandleId = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.deliveredAtUtc = const Value.absent(),
    this.readAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.textContent = const Value.absent(),
    this.itemType = const Value.absent(),
    this.isSystemMessage = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.replyToGuid = const Value.absent(),
    this.associatedMessageGuid = const Value.absent(),
    this.threadOriginatorGuid = const Value.absent(),
    this.systemType = const Value.absent(),
    this.reactionCarrier = const Value.absent(),
    this.balloonBundleId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.reactionSummaryJson = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeletedLocal = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  WorkingMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String guid,
    required int chatId,
    this.senderHandleId = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.deliveredAtUtc = const Value.absent(),
    this.readAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.textContent = const Value.absent(),
    this.itemType = const Value.absent(),
    this.isSystemMessage = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.replyToGuid = const Value.absent(),
    this.associatedMessageGuid = const Value.absent(),
    this.threadOriginatorGuid = const Value.absent(),
    this.systemType = const Value.absent(),
    this.reactionCarrier = const Value.absent(),
    this.balloonBundleId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.reactionSummaryJson = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeletedLocal = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.batchId = const Value.absent(),
  }) : guid = Value(guid),
       chatId = Value(chatId);
  static Insertable<WorkingMessage> custom({
    Expression<int>? id,
    Expression<String>? guid,
    Expression<int>? chatId,
    Expression<int>? senderHandleId,
    Expression<bool>? isFromMe,
    Expression<String>? sentAtUtc,
    Expression<String>? deliveredAtUtc,
    Expression<String>? readAtUtc,
    Expression<String>? status,
    Expression<String>? textContent,
    Expression<String>? itemType,
    Expression<bool>? isSystemMessage,
    Expression<int>? errorCode,
    Expression<bool>? hasAttachments,
    Expression<String>? replyToGuid,
    Expression<String>? associatedMessageGuid,
    Expression<String>? threadOriginatorGuid,
    Expression<String>? systemType,
    Expression<bool>? reactionCarrier,
    Expression<String>? balloonBundleId,
    Expression<String>? payloadJson,
    Expression<String>? reactionSummaryJson,
    Expression<bool>? isStarred,
    Expression<bool>? isDeletedLocal,
    Expression<String>? updatedAtUtc,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (guid != null) 'guid': guid,
      if (chatId != null) 'chat_id': chatId,
      if (senderHandleId != null) 'sender_handle_id': senderHandleId,
      if (isFromMe != null) 'is_from_me': isFromMe,
      if (sentAtUtc != null) 'sent_at_utc': sentAtUtc,
      if (deliveredAtUtc != null) 'delivered_at_utc': deliveredAtUtc,
      if (readAtUtc != null) 'read_at_utc': readAtUtc,
      if (status != null) 'status': status,
      if (textContent != null) 'text': textContent,
      if (itemType != null) 'item_type': itemType,
      if (isSystemMessage != null) 'is_system_message': isSystemMessage,
      if (errorCode != null) 'error_code': errorCode,
      if (hasAttachments != null) 'has_attachments': hasAttachments,
      if (replyToGuid != null) 'reply_to_guid': replyToGuid,
      if (associatedMessageGuid != null)
        'associated_message_guid': associatedMessageGuid,
      if (threadOriginatorGuid != null)
        'thread_originator_guid': threadOriginatorGuid,
      if (systemType != null) 'system_type': systemType,
      if (reactionCarrier != null) 'reaction_carrier': reactionCarrier,
      if (balloonBundleId != null) 'balloon_bundle_id': balloonBundleId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (reactionSummaryJson != null)
        'reaction_summary_json': reactionSummaryJson,
      if (isStarred != null) 'is_starred': isStarred,
      if (isDeletedLocal != null) 'is_deleted_local': isDeletedLocal,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  WorkingMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? guid,
    Value<int>? chatId,
    Value<int?>? senderHandleId,
    Value<bool>? isFromMe,
    Value<String?>? sentAtUtc,
    Value<String?>? deliveredAtUtc,
    Value<String?>? readAtUtc,
    Value<String>? status,
    Value<String?>? textContent,
    Value<String?>? itemType,
    Value<bool>? isSystemMessage,
    Value<int?>? errorCode,
    Value<bool>? hasAttachments,
    Value<String?>? replyToGuid,
    Value<String?>? associatedMessageGuid,
    Value<String?>? threadOriginatorGuid,
    Value<String?>? systemType,
    Value<bool>? reactionCarrier,
    Value<String?>? balloonBundleId,
    Value<String?>? payloadJson,
    Value<String?>? reactionSummaryJson,
    Value<bool>? isStarred,
    Value<bool>? isDeletedLocal,
    Value<String?>? updatedAtUtc,
    Value<int?>? batchId,
  }) {
    return WorkingMessagesCompanion(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      chatId: chatId ?? this.chatId,
      senderHandleId: senderHandleId ?? this.senderHandleId,
      isFromMe: isFromMe ?? this.isFromMe,
      sentAtUtc: sentAtUtc ?? this.sentAtUtc,
      deliveredAtUtc: deliveredAtUtc ?? this.deliveredAtUtc,
      readAtUtc: readAtUtc ?? this.readAtUtc,
      status: status ?? this.status,
      textContent: textContent ?? this.textContent,
      itemType: itemType ?? this.itemType,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      errorCode: errorCode ?? this.errorCode,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      replyToGuid: replyToGuid ?? this.replyToGuid,
      associatedMessageGuid:
          associatedMessageGuid ?? this.associatedMessageGuid,
      threadOriginatorGuid: threadOriginatorGuid ?? this.threadOriginatorGuid,
      systemType: systemType ?? this.systemType,
      reactionCarrier: reactionCarrier ?? this.reactionCarrier,
      balloonBundleId: balloonBundleId ?? this.balloonBundleId,
      payloadJson: payloadJson ?? this.payloadJson,
      reactionSummaryJson: reactionSummaryJson ?? this.reactionSummaryJson,
      isStarred: isStarred ?? this.isStarred,
      isDeletedLocal: isDeletedLocal ?? this.isDeletedLocal,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      batchId: batchId ?? this.batchId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (isFromMe.present) {
      map['is_from_me'] = Variable<bool>(isFromMe.value);
    }
    if (sentAtUtc.present) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc.value);
    }
    if (deliveredAtUtc.present) {
      map['delivered_at_utc'] = Variable<String>(deliveredAtUtc.value);
    }
    if (readAtUtc.present) {
      map['read_at_utc'] = Variable<String>(readAtUtc.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (isSystemMessage.present) {
      map['is_system_message'] = Variable<bool>(isSystemMessage.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<int>(errorCode.value);
    }
    if (hasAttachments.present) {
      map['has_attachments'] = Variable<bool>(hasAttachments.value);
    }
    if (replyToGuid.present) {
      map['reply_to_guid'] = Variable<String>(replyToGuid.value);
    }
    if (associatedMessageGuid.present) {
      map['associated_message_guid'] = Variable<String>(
        associatedMessageGuid.value,
      );
    }
    if (threadOriginatorGuid.present) {
      map['thread_originator_guid'] = Variable<String>(
        threadOriginatorGuid.value,
      );
    }
    if (systemType.present) {
      map['system_type'] = Variable<String>(systemType.value);
    }
    if (reactionCarrier.present) {
      map['reaction_carrier'] = Variable<bool>(reactionCarrier.value);
    }
    if (balloonBundleId.present) {
      map['balloon_bundle_id'] = Variable<String>(balloonBundleId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (reactionSummaryJson.present) {
      map['reaction_summary_json'] = Variable<String>(
        reactionSummaryJson.value,
      );
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isDeletedLocal.present) {
      map['is_deleted_local'] = Variable<bool>(isDeletedLocal.value);
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
    return (StringBuffer('WorkingMessagesCompanion(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('chatId: $chatId, ')
          ..write('senderHandleId: $senderHandleId, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('deliveredAtUtc: $deliveredAtUtc, ')
          ..write('readAtUtc: $readAtUtc, ')
          ..write('status: $status, ')
          ..write('textContent: $textContent, ')
          ..write('itemType: $itemType, ')
          ..write('isSystemMessage: $isSystemMessage, ')
          ..write('errorCode: $errorCode, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('replyToGuid: $replyToGuid, ')
          ..write('associatedMessageGuid: $associatedMessageGuid, ')
          ..write('threadOriginatorGuid: $threadOriginatorGuid, ')
          ..write('systemType: $systemType, ')
          ..write('reactionCarrier: $reactionCarrier, ')
          ..write('balloonBundleId: $balloonBundleId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('reactionSummaryJson: $reactionSummaryJson, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeletedLocal: $isDeletedLocal, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $GlobalMessageIndexTable extends GlobalMessageIndex
    with TableInfo<$GlobalMessageIndexTable, GlobalMessageIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlobalMessageIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _sentAtUtcMeta = const VerificationMeta(
    'sentAtUtc',
  );
  @override
  late final GeneratedColumn<String> sentAtUtc = GeneratedColumn<String>(
    'sent_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ordinal,
    messageId,
    chatId,
    sentAtUtc,
    monthKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'global_message_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlobalMessageIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sent_at_utc')) {
      context.handle(
        _sentAtUtcMeta,
        sentAtUtc.isAcceptableOrUnknown(data['sent_at_utc']!, _sentAtUtcMeta),
      );
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ordinal};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId},
  ];
  @override
  GlobalMessageIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlobalMessageIndexData(
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      sentAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_at_utc'],
      ),
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
    );
  }

  @override
  $GlobalMessageIndexTable createAlias(String alias) {
    return $GlobalMessageIndexTable(attachedDatabase, alias);
  }
}

class GlobalMessageIndexData extends DataClass
    implements Insertable<GlobalMessageIndexData> {
  final int ordinal;
  final int messageId;
  final int chatId;
  final String? sentAtUtc;
  final String monthKey;
  const GlobalMessageIndexData({
    required this.ordinal,
    required this.messageId,
    required this.chatId,
    this.sentAtUtc,
    required this.monthKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ordinal'] = Variable<int>(ordinal);
    map['message_id'] = Variable<int>(messageId);
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || sentAtUtc != null) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc);
    }
    map['month_key'] = Variable<String>(monthKey);
    return map;
  }

  GlobalMessageIndexCompanion toCompanion(bool nullToAbsent) {
    return GlobalMessageIndexCompanion(
      ordinal: Value(ordinal),
      messageId: Value(messageId),
      chatId: Value(chatId),
      sentAtUtc: sentAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAtUtc),
      monthKey: Value(monthKey),
    );
  }

  factory GlobalMessageIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlobalMessageIndexData(
      ordinal: serializer.fromJson<int>(json['ordinal']),
      messageId: serializer.fromJson<int>(json['messageId']),
      chatId: serializer.fromJson<int>(json['chatId']),
      sentAtUtc: serializer.fromJson<String?>(json['sentAtUtc']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ordinal': serializer.toJson<int>(ordinal),
      'messageId': serializer.toJson<int>(messageId),
      'chatId': serializer.toJson<int>(chatId),
      'sentAtUtc': serializer.toJson<String?>(sentAtUtc),
      'monthKey': serializer.toJson<String>(monthKey),
    };
  }

  GlobalMessageIndexData copyWith({
    int? ordinal,
    int? messageId,
    int? chatId,
    Value<String?> sentAtUtc = const Value.absent(),
    String? monthKey,
  }) => GlobalMessageIndexData(
    ordinal: ordinal ?? this.ordinal,
    messageId: messageId ?? this.messageId,
    chatId: chatId ?? this.chatId,
    sentAtUtc: sentAtUtc.present ? sentAtUtc.value : this.sentAtUtc,
    monthKey: monthKey ?? this.monthKey,
  );
  GlobalMessageIndexData copyWithCompanion(GlobalMessageIndexCompanion data) {
    return GlobalMessageIndexData(
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      sentAtUtc: data.sentAtUtc.present ? data.sentAtUtc.value : this.sentAtUtc,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlobalMessageIndexData(')
          ..write('ordinal: $ordinal, ')
          ..write('messageId: $messageId, ')
          ..write('chatId: $chatId, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('monthKey: $monthKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ordinal, messageId, chatId, sentAtUtc, monthKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlobalMessageIndexData &&
          other.ordinal == this.ordinal &&
          other.messageId == this.messageId &&
          other.chatId == this.chatId &&
          other.sentAtUtc == this.sentAtUtc &&
          other.monthKey == this.monthKey);
}

class GlobalMessageIndexCompanion
    extends UpdateCompanion<GlobalMessageIndexData> {
  final Value<int> ordinal;
  final Value<int> messageId;
  final Value<int> chatId;
  final Value<String?> sentAtUtc;
  final Value<String> monthKey;
  const GlobalMessageIndexCompanion({
    this.ordinal = const Value.absent(),
    this.messageId = const Value.absent(),
    this.chatId = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.monthKey = const Value.absent(),
  });
  GlobalMessageIndexCompanion.insert({
    this.ordinal = const Value.absent(),
    required int messageId,
    required int chatId,
    this.sentAtUtc = const Value.absent(),
    required String monthKey,
  }) : messageId = Value(messageId),
       chatId = Value(chatId),
       monthKey = Value(monthKey);
  static Insertable<GlobalMessageIndexData> custom({
    Expression<int>? ordinal,
    Expression<int>? messageId,
    Expression<int>? chatId,
    Expression<String>? sentAtUtc,
    Expression<String>? monthKey,
  }) {
    return RawValuesInsertable({
      if (ordinal != null) 'ordinal': ordinal,
      if (messageId != null) 'message_id': messageId,
      if (chatId != null) 'chat_id': chatId,
      if (sentAtUtc != null) 'sent_at_utc': sentAtUtc,
      if (monthKey != null) 'month_key': monthKey,
    });
  }

  GlobalMessageIndexCompanion copyWith({
    Value<int>? ordinal,
    Value<int>? messageId,
    Value<int>? chatId,
    Value<String?>? sentAtUtc,
    Value<String>? monthKey,
  }) {
    return GlobalMessageIndexCompanion(
      ordinal: ordinal ?? this.ordinal,
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      sentAtUtc: sentAtUtc ?? this.sentAtUtc,
      monthKey: monthKey ?? this.monthKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (sentAtUtc.present) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlobalMessageIndexCompanion(')
          ..write('ordinal: $ordinal, ')
          ..write('messageId: $messageId, ')
          ..write('chatId: $chatId, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('monthKey: $monthKey')
          ..write(')'))
        .toString();
  }
}

class $MessageIndexTable extends MessageIndex
    with TableInfo<$MessageIndexTable, MessageIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageIndexTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _sentAtUtcMeta = const VerificationMeta(
    'sentAtUtc',
  );
  @override
  late final GeneratedColumn<String> sentAtUtc = GeneratedColumn<String>(
    'sent_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chatId,
    ordinal,
    messageId,
    sentAtUtc,
    monthKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageIndexData> instance, {
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
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('sent_at_utc')) {
      context.handle(
        _sentAtUtcMeta,
        sentAtUtc.isAcceptableOrUnknown(data['sent_at_utc']!, _sentAtUtcMeta),
      );
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, ordinal};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId},
  ];
  @override
  MessageIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageIndexData(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      sentAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_at_utc'],
      ),
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
    );
  }

  @override
  $MessageIndexTable createAlias(String alias) {
    return $MessageIndexTable(attachedDatabase, alias);
  }
}

class MessageIndexData extends DataClass
    implements Insertable<MessageIndexData> {
  final int chatId;
  final int ordinal;
  final int messageId;
  final String? sentAtUtc;
  final String monthKey;
  const MessageIndexData({
    required this.chatId,
    required this.ordinal,
    required this.messageId,
    this.sentAtUtc,
    required this.monthKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    map['ordinal'] = Variable<int>(ordinal);
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || sentAtUtc != null) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc);
    }
    map['month_key'] = Variable<String>(monthKey);
    return map;
  }

  MessageIndexCompanion toCompanion(bool nullToAbsent) {
    return MessageIndexCompanion(
      chatId: Value(chatId),
      ordinal: Value(ordinal),
      messageId: Value(messageId),
      sentAtUtc: sentAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAtUtc),
      monthKey: Value(monthKey),
    );
  }

  factory MessageIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageIndexData(
      chatId: serializer.fromJson<int>(json['chatId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      messageId: serializer.fromJson<int>(json['messageId']),
      sentAtUtc: serializer.fromJson<String?>(json['sentAtUtc']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'ordinal': serializer.toJson<int>(ordinal),
      'messageId': serializer.toJson<int>(messageId),
      'sentAtUtc': serializer.toJson<String?>(sentAtUtc),
      'monthKey': serializer.toJson<String>(monthKey),
    };
  }

  MessageIndexData copyWith({
    int? chatId,
    int? ordinal,
    int? messageId,
    Value<String?> sentAtUtc = const Value.absent(),
    String? monthKey,
  }) => MessageIndexData(
    chatId: chatId ?? this.chatId,
    ordinal: ordinal ?? this.ordinal,
    messageId: messageId ?? this.messageId,
    sentAtUtc: sentAtUtc.present ? sentAtUtc.value : this.sentAtUtc,
    monthKey: monthKey ?? this.monthKey,
  );
  MessageIndexData copyWithCompanion(MessageIndexCompanion data) {
    return MessageIndexData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      sentAtUtc: data.sentAtUtc.present ? data.sentAtUtc.value : this.sentAtUtc,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageIndexData(')
          ..write('chatId: $chatId, ')
          ..write('ordinal: $ordinal, ')
          ..write('messageId: $messageId, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('monthKey: $monthKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(chatId, ordinal, messageId, sentAtUtc, monthKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageIndexData &&
          other.chatId == this.chatId &&
          other.ordinal == this.ordinal &&
          other.messageId == this.messageId &&
          other.sentAtUtc == this.sentAtUtc &&
          other.monthKey == this.monthKey);
}

class MessageIndexCompanion extends UpdateCompanion<MessageIndexData> {
  final Value<int> chatId;
  final Value<int> ordinal;
  final Value<int> messageId;
  final Value<String?> sentAtUtc;
  final Value<String> monthKey;
  final Value<int> rowid;
  const MessageIndexCompanion({
    this.chatId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.messageId = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageIndexCompanion.insert({
    required int chatId,
    required int ordinal,
    required int messageId,
    this.sentAtUtc = const Value.absent(),
    required String monthKey,
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       ordinal = Value(ordinal),
       messageId = Value(messageId),
       monthKey = Value(monthKey);
  static Insertable<MessageIndexData> custom({
    Expression<int>? chatId,
    Expression<int>? ordinal,
    Expression<int>? messageId,
    Expression<String>? sentAtUtc,
    Expression<String>? monthKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (ordinal != null) 'ordinal': ordinal,
      if (messageId != null) 'message_id': messageId,
      if (sentAtUtc != null) 'sent_at_utc': sentAtUtc,
      if (monthKey != null) 'month_key': monthKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageIndexCompanion copyWith({
    Value<int>? chatId,
    Value<int>? ordinal,
    Value<int>? messageId,
    Value<String?>? sentAtUtc,
    Value<String>? monthKey,
    Value<int>? rowid,
  }) {
    return MessageIndexCompanion(
      chatId: chatId ?? this.chatId,
      ordinal: ordinal ?? this.ordinal,
      messageId: messageId ?? this.messageId,
      sentAtUtc: sentAtUtc ?? this.sentAtUtc,
      monthKey: monthKey ?? this.monthKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (sentAtUtc.present) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageIndexCompanion(')
          ..write('chatId: $chatId, ')
          ..write('ordinal: $ordinal, ')
          ..write('messageId: $messageId, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('monthKey: $monthKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactMessageIndexTable extends ContactMessageIndex
    with TableInfo<$ContactMessageIndexTable, ContactMessageIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactMessageIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _sentAtUtcMeta = const VerificationMeta(
    'sentAtUtc',
  );
  @override
  late final GeneratedColumn<String> sentAtUtc = GeneratedColumn<String>(
    'sent_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    contactId,
    ordinal,
    messageId,
    sentAtUtc,
    monthKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_message_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactMessageIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('sent_at_utc')) {
      context.handle(
        _sentAtUtcMeta,
        sentAtUtc.isAcceptableOrUnknown(data['sent_at_utc']!, _sentAtUtcMeta),
      );
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contactId, ordinal};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, contactId},
  ];
  @override
  ContactMessageIndexData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactMessageIndexData(
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      sentAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_at_utc'],
      ),
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
    );
  }

  @override
  $ContactMessageIndexTable createAlias(String alias) {
    return $ContactMessageIndexTable(attachedDatabase, alias);
  }
}

class ContactMessageIndexData extends DataClass
    implements Insertable<ContactMessageIndexData> {
  final int contactId;
  final int ordinal;
  final int messageId;
  final String? sentAtUtc;
  final String monthKey;
  const ContactMessageIndexData({
    required this.contactId,
    required this.ordinal,
    required this.messageId,
    this.sentAtUtc,
    required this.monthKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['contact_id'] = Variable<int>(contactId);
    map['ordinal'] = Variable<int>(ordinal);
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || sentAtUtc != null) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc);
    }
    map['month_key'] = Variable<String>(monthKey);
    return map;
  }

  ContactMessageIndexCompanion toCompanion(bool nullToAbsent) {
    return ContactMessageIndexCompanion(
      contactId: Value(contactId),
      ordinal: Value(ordinal),
      messageId: Value(messageId),
      sentAtUtc: sentAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAtUtc),
      monthKey: Value(monthKey),
    );
  }

  factory ContactMessageIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactMessageIndexData(
      contactId: serializer.fromJson<int>(json['contactId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      messageId: serializer.fromJson<int>(json['messageId']),
      sentAtUtc: serializer.fromJson<String?>(json['sentAtUtc']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contactId': serializer.toJson<int>(contactId),
      'ordinal': serializer.toJson<int>(ordinal),
      'messageId': serializer.toJson<int>(messageId),
      'sentAtUtc': serializer.toJson<String?>(sentAtUtc),
      'monthKey': serializer.toJson<String>(monthKey),
    };
  }

  ContactMessageIndexData copyWith({
    int? contactId,
    int? ordinal,
    int? messageId,
    Value<String?> sentAtUtc = const Value.absent(),
    String? monthKey,
  }) => ContactMessageIndexData(
    contactId: contactId ?? this.contactId,
    ordinal: ordinal ?? this.ordinal,
    messageId: messageId ?? this.messageId,
    sentAtUtc: sentAtUtc.present ? sentAtUtc.value : this.sentAtUtc,
    monthKey: monthKey ?? this.monthKey,
  );
  ContactMessageIndexData copyWithCompanion(ContactMessageIndexCompanion data) {
    return ContactMessageIndexData(
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      sentAtUtc: data.sentAtUtc.present ? data.sentAtUtc.value : this.sentAtUtc,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactMessageIndexData(')
          ..write('contactId: $contactId, ')
          ..write('ordinal: $ordinal, ')
          ..write('messageId: $messageId, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('monthKey: $monthKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(contactId, ordinal, messageId, sentAtUtc, monthKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactMessageIndexData &&
          other.contactId == this.contactId &&
          other.ordinal == this.ordinal &&
          other.messageId == this.messageId &&
          other.sentAtUtc == this.sentAtUtc &&
          other.monthKey == this.monthKey);
}

class ContactMessageIndexCompanion
    extends UpdateCompanion<ContactMessageIndexData> {
  final Value<int> contactId;
  final Value<int> ordinal;
  final Value<int> messageId;
  final Value<String?> sentAtUtc;
  final Value<String> monthKey;
  final Value<int> rowid;
  const ContactMessageIndexCompanion({
    this.contactId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.messageId = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactMessageIndexCompanion.insert({
    required int contactId,
    required int ordinal,
    required int messageId,
    this.sentAtUtc = const Value.absent(),
    required String monthKey,
    this.rowid = const Value.absent(),
  }) : contactId = Value(contactId),
       ordinal = Value(ordinal),
       messageId = Value(messageId),
       monthKey = Value(monthKey);
  static Insertable<ContactMessageIndexData> custom({
    Expression<int>? contactId,
    Expression<int>? ordinal,
    Expression<int>? messageId,
    Expression<String>? sentAtUtc,
    Expression<String>? monthKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contactId != null) 'contact_id': contactId,
      if (ordinal != null) 'ordinal': ordinal,
      if (messageId != null) 'message_id': messageId,
      if (sentAtUtc != null) 'sent_at_utc': sentAtUtc,
      if (monthKey != null) 'month_key': monthKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactMessageIndexCompanion copyWith({
    Value<int>? contactId,
    Value<int>? ordinal,
    Value<int>? messageId,
    Value<String?>? sentAtUtc,
    Value<String>? monthKey,
    Value<int>? rowid,
  }) {
    return ContactMessageIndexCompanion(
      contactId: contactId ?? this.contactId,
      ordinal: ordinal ?? this.ordinal,
      messageId: messageId ?? this.messageId,
      sentAtUtc: sentAtUtc ?? this.sentAtUtc,
      monthKey: monthKey ?? this.monthKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (sentAtUtc.present) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactMessageIndexCompanion(')
          ..write('contactId: $contactId, ')
          ..write('ordinal: $ordinal, ')
          ..write('messageId: $messageId, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('monthKey: $monthKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkingAttachmentsTable extends WorkingAttachments
    with TableInfo<$WorkingAttachmentsTable, WorkingAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingAttachmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importAttachmentIdMeta =
      const VerificationMeta('importAttachmentId');
  @override
  late final GeneratedColumn<int> importAttachmentId = GeneratedColumn<int>(
    'import_attachment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _utiMeta = const VerificationMeta('uti');
  @override
  late final GeneratedColumn<String> uti = GeneratedColumn<String>(
    'uti',
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
  static const VerificationMeta _thumbPathMeta = const VerificationMeta(
    'thumbPath',
  );
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isOutgoingMeta = const VerificationMeta(
    'isOutgoing',
  );
  @override
  late final GeneratedColumn<bool> isOutgoing = GeneratedColumn<bool>(
    'is_outgoing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_outgoing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageGuid,
    importAttachmentId,
    localPath,
    mimeType,
    uti,
    transferName,
    sizeBytes,
    isSticker,
    thumbPath,
    createdAtUtc,
    isOutgoing,
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
    Insertable<WorkingAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('import_attachment_id')) {
      context.handle(
        _importAttachmentIdMeta,
        importAttachmentId.isAcceptableOrUnknown(
          data['import_attachment_id']!,
          _importAttachmentIdMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('uti')) {
      context.handle(
        _utiMeta,
        uti.isAcceptableOrUnknown(data['uti']!, _utiMeta),
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
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('is_sticker')) {
      context.handle(
        _isStickerMeta,
        isSticker.isAcceptableOrUnknown(data['is_sticker']!, _isStickerMeta),
      );
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
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
    if (data.containsKey('is_outgoing')) {
      context.handle(
        _isOutgoingMeta,
        isOutgoing.isAcceptableOrUnknown(data['is_outgoing']!, _isOutgoingMeta),
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkingAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      importAttachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_attachment_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      uti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uti'],
      ),
      transferName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_name'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      isSticker: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sticker'],
      )!,
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      ),
      isOutgoing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_outgoing'],
      )!,
      sha256Hex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256_hex'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
    );
  }

  @override
  $WorkingAttachmentsTable createAlias(String alias) {
    return $WorkingAttachmentsTable(attachedDatabase, alias);
  }
}

class WorkingAttachment extends DataClass
    implements Insertable<WorkingAttachment> {
  final int id;
  final String messageGuid;
  final int? importAttachmentId;
  final String? localPath;
  final String? mimeType;
  final String? uti;
  final String? transferName;
  final int? sizeBytes;
  final bool isSticker;
  final String? thumbPath;
  final String? createdAtUtc;
  final bool isOutgoing;
  final String? sha256Hex;
  final int? batchId;
  const WorkingAttachment({
    required this.id,
    required this.messageGuid,
    this.importAttachmentId,
    this.localPath,
    this.mimeType,
    this.uti,
    this.transferName,
    this.sizeBytes,
    required this.isSticker,
    this.thumbPath,
    this.createdAtUtc,
    required this.isOutgoing,
    this.sha256Hex,
    this.batchId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_guid'] = Variable<String>(messageGuid);
    if (!nullToAbsent || importAttachmentId != null) {
      map['import_attachment_id'] = Variable<int>(importAttachmentId);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || uti != null) {
      map['uti'] = Variable<String>(uti);
    }
    if (!nullToAbsent || transferName != null) {
      map['transfer_name'] = Variable<String>(transferName);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['is_sticker'] = Variable<bool>(isSticker);
    if (!nullToAbsent || thumbPath != null) {
      map['thumb_path'] = Variable<String>(thumbPath);
    }
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    map['is_outgoing'] = Variable<bool>(isOutgoing);
    if (!nullToAbsent || sha256Hex != null) {
      map['sha256_hex'] = Variable<String>(sha256Hex);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    return map;
  }

  WorkingAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return WorkingAttachmentsCompanion(
      id: Value(id),
      messageGuid: Value(messageGuid),
      importAttachmentId: importAttachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(importAttachmentId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      uti: uti == null && nullToAbsent ? const Value.absent() : Value(uti),
      transferName: transferName == null && nullToAbsent
          ? const Value.absent()
          : Value(transferName),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      isSticker: Value(isSticker),
      thumbPath: thumbPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbPath),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
      isOutgoing: Value(isOutgoing),
      sha256Hex: sha256Hex == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256Hex),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
    );
  }

  factory WorkingAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingAttachment(
      id: serializer.fromJson<int>(json['id']),
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      importAttachmentId: serializer.fromJson<int?>(json['importAttachmentId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      uti: serializer.fromJson<String?>(json['uti']),
      transferName: serializer.fromJson<String?>(json['transferName']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      isSticker: serializer.fromJson<bool>(json['isSticker']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      isOutgoing: serializer.fromJson<bool>(json['isOutgoing']),
      sha256Hex: serializer.fromJson<String?>(json['sha256Hex']),
      batchId: serializer.fromJson<int?>(json['batchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageGuid': serializer.toJson<String>(messageGuid),
      'importAttachmentId': serializer.toJson<int?>(importAttachmentId),
      'localPath': serializer.toJson<String?>(localPath),
      'mimeType': serializer.toJson<String?>(mimeType),
      'uti': serializer.toJson<String?>(uti),
      'transferName': serializer.toJson<String?>(transferName),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'isSticker': serializer.toJson<bool>(isSticker),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'isOutgoing': serializer.toJson<bool>(isOutgoing),
      'sha256Hex': serializer.toJson<String?>(sha256Hex),
      'batchId': serializer.toJson<int?>(batchId),
    };
  }

  WorkingAttachment copyWith({
    int? id,
    String? messageGuid,
    Value<int?> importAttachmentId = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<String?> uti = const Value.absent(),
    Value<String?> transferName = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    bool? isSticker,
    Value<String?> thumbPath = const Value.absent(),
    Value<String?> createdAtUtc = const Value.absent(),
    bool? isOutgoing,
    Value<String?> sha256Hex = const Value.absent(),
    Value<int?> batchId = const Value.absent(),
  }) => WorkingAttachment(
    id: id ?? this.id,
    messageGuid: messageGuid ?? this.messageGuid,
    importAttachmentId: importAttachmentId.present
        ? importAttachmentId.value
        : this.importAttachmentId,
    localPath: localPath.present ? localPath.value : this.localPath,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    uti: uti.present ? uti.value : this.uti,
    transferName: transferName.present ? transferName.value : this.transferName,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    isSticker: isSticker ?? this.isSticker,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    isOutgoing: isOutgoing ?? this.isOutgoing,
    sha256Hex: sha256Hex.present ? sha256Hex.value : this.sha256Hex,
    batchId: batchId.present ? batchId.value : this.batchId,
  );
  WorkingAttachment copyWithCompanion(WorkingAttachmentsCompanion data) {
    return WorkingAttachment(
      id: data.id.present ? data.id.value : this.id,
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      importAttachmentId: data.importAttachmentId.present
          ? data.importAttachmentId.value
          : this.importAttachmentId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      uti: data.uti.present ? data.uti.value : this.uti,
      transferName: data.transferName.present
          ? data.transferName.value
          : this.transferName,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      isSticker: data.isSticker.present ? data.isSticker.value : this.isSticker,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      isOutgoing: data.isOutgoing.present
          ? data.isOutgoing.value
          : this.isOutgoing,
      sha256Hex: data.sha256Hex.present ? data.sha256Hex.value : this.sha256Hex,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingAttachment(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('importAttachmentId: $importAttachmentId, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('uti: $uti, ')
          ..write('transferName: $transferName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isSticker: $isSticker, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageGuid,
    importAttachmentId,
    localPath,
    mimeType,
    uti,
    transferName,
    sizeBytes,
    isSticker,
    thumbPath,
    createdAtUtc,
    isOutgoing,
    sha256Hex,
    batchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingAttachment &&
          other.id == this.id &&
          other.messageGuid == this.messageGuid &&
          other.importAttachmentId == this.importAttachmentId &&
          other.localPath == this.localPath &&
          other.mimeType == this.mimeType &&
          other.uti == this.uti &&
          other.transferName == this.transferName &&
          other.sizeBytes == this.sizeBytes &&
          other.isSticker == this.isSticker &&
          other.thumbPath == this.thumbPath &&
          other.createdAtUtc == this.createdAtUtc &&
          other.isOutgoing == this.isOutgoing &&
          other.sha256Hex == this.sha256Hex &&
          other.batchId == this.batchId);
}

class WorkingAttachmentsCompanion extends UpdateCompanion<WorkingAttachment> {
  final Value<int> id;
  final Value<String> messageGuid;
  final Value<int?> importAttachmentId;
  final Value<String?> localPath;
  final Value<String?> mimeType;
  final Value<String?> uti;
  final Value<String?> transferName;
  final Value<int?> sizeBytes;
  final Value<bool> isSticker;
  final Value<String?> thumbPath;
  final Value<String?> createdAtUtc;
  final Value<bool> isOutgoing;
  final Value<String?> sha256Hex;
  final Value<int?> batchId;
  const WorkingAttachmentsCompanion({
    this.id = const Value.absent(),
    this.messageGuid = const Value.absent(),
    this.importAttachmentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.uti = const Value.absent(),
    this.transferName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.isSticker = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    this.batchId = const Value.absent(),
  });
  WorkingAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required String messageGuid,
    this.importAttachmentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.uti = const Value.absent(),
    this.transferName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.isSticker = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.sha256Hex = const Value.absent(),
    this.batchId = const Value.absent(),
  }) : messageGuid = Value(messageGuid);
  static Insertable<WorkingAttachment> custom({
    Expression<int>? id,
    Expression<String>? messageGuid,
    Expression<int>? importAttachmentId,
    Expression<String>? localPath,
    Expression<String>? mimeType,
    Expression<String>? uti,
    Expression<String>? transferName,
    Expression<int>? sizeBytes,
    Expression<bool>? isSticker,
    Expression<String>? thumbPath,
    Expression<String>? createdAtUtc,
    Expression<bool>? isOutgoing,
    Expression<String>? sha256Hex,
    Expression<int>? batchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageGuid != null) 'message_guid': messageGuid,
      if (importAttachmentId != null)
        'import_attachment_id': importAttachmentId,
      if (localPath != null) 'local_path': localPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (uti != null) 'uti': uti,
      if (transferName != null) 'transfer_name': transferName,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (isSticker != null) 'is_sticker': isSticker,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (isOutgoing != null) 'is_outgoing': isOutgoing,
      if (sha256Hex != null) 'sha256_hex': sha256Hex,
      if (batchId != null) 'batch_id': batchId,
    });
  }

  WorkingAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? messageGuid,
    Value<int?>? importAttachmentId,
    Value<String?>? localPath,
    Value<String?>? mimeType,
    Value<String?>? uti,
    Value<String?>? transferName,
    Value<int?>? sizeBytes,
    Value<bool>? isSticker,
    Value<String?>? thumbPath,
    Value<String?>? createdAtUtc,
    Value<bool>? isOutgoing,
    Value<String?>? sha256Hex,
    Value<int?>? batchId,
  }) {
    return WorkingAttachmentsCompanion(
      id: id ?? this.id,
      messageGuid: messageGuid ?? this.messageGuid,
      importAttachmentId: importAttachmentId ?? this.importAttachmentId,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      uti: uti ?? this.uti,
      transferName: transferName ?? this.transferName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isSticker: isSticker ?? this.isSticker,
      thumbPath: thumbPath ?? this.thumbPath,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      isOutgoing: isOutgoing ?? this.isOutgoing,
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
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (importAttachmentId.present) {
      map['import_attachment_id'] = Variable<int>(importAttachmentId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (uti.present) {
      map['uti'] = Variable<String>(uti.value);
    }
    if (transferName.present) {
      map['transfer_name'] = Variable<String>(transferName.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (isSticker.present) {
      map['is_sticker'] = Variable<bool>(isSticker.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (isOutgoing.present) {
      map['is_outgoing'] = Variable<bool>(isOutgoing.value);
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
    return (StringBuffer('WorkingAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('importAttachmentId: $importAttachmentId, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('uti: $uti, ')
          ..write('transferName: $transferName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isSticker: $isSticker, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('sha256Hex: $sha256Hex, ')
          ..write('batchId: $batchId')
          ..write(')'))
        .toString();
  }
}

class $WorkingReactionsTable extends WorkingReactions
    with TableInfo<$WorkingReactionsTable, WorkingReaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingReactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
      'REFERENCES handles_canonical (id) ON DELETE SET NULL',
    ),
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
  static const VerificationMeta _carrierMessageIdMeta = const VerificationMeta(
    'carrierMessageId',
  );
  @override
  late final GeneratedColumn<int> carrierMessageId = GeneratedColumn<int>(
    'carrier_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageGuid,
    kind,
    reactorHandleId,
    action,
    reactedAtUtc,
    carrierMessageId,
    targetMessageGuid,
    parseConfidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingReaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
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
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
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
    if (data.containsKey('carrier_message_id')) {
      context.handle(
        _carrierMessageIdMeta,
        carrierMessageId.isAcceptableOrUnknown(
          data['carrier_message_id']!,
          _carrierMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('target_message_guid')) {
      context.handle(
        _targetMessageGuidMeta,
        targetMessageGuid.isAcceptableOrUnknown(
          data['target_message_guid']!,
          _targetMessageGuidMeta,
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
  WorkingReaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingReaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      reactorHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reactor_handle_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      reactedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reacted_at_utc'],
      ),
      carrierMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carrier_message_id'],
      ),
      targetMessageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_message_guid'],
      ),
      parseConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}parse_confidence'],
      )!,
    );
  }

  @override
  $WorkingReactionsTable createAlias(String alias) {
    return $WorkingReactionsTable(attachedDatabase, alias);
  }
}

class WorkingReaction extends DataClass implements Insertable<WorkingReaction> {
  final int id;
  final String messageGuid;
  final String kind;
  final int? reactorHandleId;
  final String action;
  final String? reactedAtUtc;
  final int? carrierMessageId;
  final String? targetMessageGuid;
  final double parseConfidence;
  const WorkingReaction({
    required this.id,
    required this.messageGuid,
    required this.kind,
    this.reactorHandleId,
    required this.action,
    this.reactedAtUtc,
    this.carrierMessageId,
    this.targetMessageGuid,
    required this.parseConfidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_guid'] = Variable<String>(messageGuid);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || reactorHandleId != null) {
      map['reactor_handle_id'] = Variable<int>(reactorHandleId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || reactedAtUtc != null) {
      map['reacted_at_utc'] = Variable<String>(reactedAtUtc);
    }
    if (!nullToAbsent || carrierMessageId != null) {
      map['carrier_message_id'] = Variable<int>(carrierMessageId);
    }
    if (!nullToAbsent || targetMessageGuid != null) {
      map['target_message_guid'] = Variable<String>(targetMessageGuid);
    }
    map['parse_confidence'] = Variable<double>(parseConfidence);
    return map;
  }

  WorkingReactionsCompanion toCompanion(bool nullToAbsent) {
    return WorkingReactionsCompanion(
      id: Value(id),
      messageGuid: Value(messageGuid),
      kind: Value(kind),
      reactorHandleId: reactorHandleId == null && nullToAbsent
          ? const Value.absent()
          : Value(reactorHandleId),
      action: Value(action),
      reactedAtUtc: reactedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(reactedAtUtc),
      carrierMessageId: carrierMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(carrierMessageId),
      targetMessageGuid: targetMessageGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMessageGuid),
      parseConfidence: Value(parseConfidence),
    );
  }

  factory WorkingReaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingReaction(
      id: serializer.fromJson<int>(json['id']),
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      kind: serializer.fromJson<String>(json['kind']),
      reactorHandleId: serializer.fromJson<int?>(json['reactorHandleId']),
      action: serializer.fromJson<String>(json['action']),
      reactedAtUtc: serializer.fromJson<String?>(json['reactedAtUtc']),
      carrierMessageId: serializer.fromJson<int?>(json['carrierMessageId']),
      targetMessageGuid: serializer.fromJson<String?>(
        json['targetMessageGuid'],
      ),
      parseConfidence: serializer.fromJson<double>(json['parseConfidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageGuid': serializer.toJson<String>(messageGuid),
      'kind': serializer.toJson<String>(kind),
      'reactorHandleId': serializer.toJson<int?>(reactorHandleId),
      'action': serializer.toJson<String>(action),
      'reactedAtUtc': serializer.toJson<String?>(reactedAtUtc),
      'carrierMessageId': serializer.toJson<int?>(carrierMessageId),
      'targetMessageGuid': serializer.toJson<String?>(targetMessageGuid),
      'parseConfidence': serializer.toJson<double>(parseConfidence),
    };
  }

  WorkingReaction copyWith({
    int? id,
    String? messageGuid,
    String? kind,
    Value<int?> reactorHandleId = const Value.absent(),
    String? action,
    Value<String?> reactedAtUtc = const Value.absent(),
    Value<int?> carrierMessageId = const Value.absent(),
    Value<String?> targetMessageGuid = const Value.absent(),
    double? parseConfidence,
  }) => WorkingReaction(
    id: id ?? this.id,
    messageGuid: messageGuid ?? this.messageGuid,
    kind: kind ?? this.kind,
    reactorHandleId: reactorHandleId.present
        ? reactorHandleId.value
        : this.reactorHandleId,
    action: action ?? this.action,
    reactedAtUtc: reactedAtUtc.present ? reactedAtUtc.value : this.reactedAtUtc,
    carrierMessageId: carrierMessageId.present
        ? carrierMessageId.value
        : this.carrierMessageId,
    targetMessageGuid: targetMessageGuid.present
        ? targetMessageGuid.value
        : this.targetMessageGuid,
    parseConfidence: parseConfidence ?? this.parseConfidence,
  );
  WorkingReaction copyWithCompanion(WorkingReactionsCompanion data) {
    return WorkingReaction(
      id: data.id.present ? data.id.value : this.id,
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      kind: data.kind.present ? data.kind.value : this.kind,
      reactorHandleId: data.reactorHandleId.present
          ? data.reactorHandleId.value
          : this.reactorHandleId,
      action: data.action.present ? data.action.value : this.action,
      reactedAtUtc: data.reactedAtUtc.present
          ? data.reactedAtUtc.value
          : this.reactedAtUtc,
      carrierMessageId: data.carrierMessageId.present
          ? data.carrierMessageId.value
          : this.carrierMessageId,
      targetMessageGuid: data.targetMessageGuid.present
          ? data.targetMessageGuid.value
          : this.targetMessageGuid,
      parseConfidence: data.parseConfidence.present
          ? data.parseConfidence.value
          : this.parseConfidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingReaction(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('kind: $kind, ')
          ..write('reactorHandleId: $reactorHandleId, ')
          ..write('action: $action, ')
          ..write('reactedAtUtc: $reactedAtUtc, ')
          ..write('carrierMessageId: $carrierMessageId, ')
          ..write('targetMessageGuid: $targetMessageGuid, ')
          ..write('parseConfidence: $parseConfidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageGuid,
    kind,
    reactorHandleId,
    action,
    reactedAtUtc,
    carrierMessageId,
    targetMessageGuid,
    parseConfidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingReaction &&
          other.id == this.id &&
          other.messageGuid == this.messageGuid &&
          other.kind == this.kind &&
          other.reactorHandleId == this.reactorHandleId &&
          other.action == this.action &&
          other.reactedAtUtc == this.reactedAtUtc &&
          other.carrierMessageId == this.carrierMessageId &&
          other.targetMessageGuid == this.targetMessageGuid &&
          other.parseConfidence == this.parseConfidence);
}

class WorkingReactionsCompanion extends UpdateCompanion<WorkingReaction> {
  final Value<int> id;
  final Value<String> messageGuid;
  final Value<String> kind;
  final Value<int?> reactorHandleId;
  final Value<String> action;
  final Value<String?> reactedAtUtc;
  final Value<int?> carrierMessageId;
  final Value<String?> targetMessageGuid;
  final Value<double> parseConfidence;
  const WorkingReactionsCompanion({
    this.id = const Value.absent(),
    this.messageGuid = const Value.absent(),
    this.kind = const Value.absent(),
    this.reactorHandleId = const Value.absent(),
    this.action = const Value.absent(),
    this.reactedAtUtc = const Value.absent(),
    this.carrierMessageId = const Value.absent(),
    this.targetMessageGuid = const Value.absent(),
    this.parseConfidence = const Value.absent(),
  });
  WorkingReactionsCompanion.insert({
    this.id = const Value.absent(),
    required String messageGuid,
    required String kind,
    this.reactorHandleId = const Value.absent(),
    required String action,
    this.reactedAtUtc = const Value.absent(),
    this.carrierMessageId = const Value.absent(),
    this.targetMessageGuid = const Value.absent(),
    this.parseConfidence = const Value.absent(),
  }) : messageGuid = Value(messageGuid),
       kind = Value(kind),
       action = Value(action);
  static Insertable<WorkingReaction> custom({
    Expression<int>? id,
    Expression<String>? messageGuid,
    Expression<String>? kind,
    Expression<int>? reactorHandleId,
    Expression<String>? action,
    Expression<String>? reactedAtUtc,
    Expression<int>? carrierMessageId,
    Expression<String>? targetMessageGuid,
    Expression<double>? parseConfidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageGuid != null) 'message_guid': messageGuid,
      if (kind != null) 'kind': kind,
      if (reactorHandleId != null) 'reactor_handle_id': reactorHandleId,
      if (action != null) 'action': action,
      if (reactedAtUtc != null) 'reacted_at_utc': reactedAtUtc,
      if (carrierMessageId != null) 'carrier_message_id': carrierMessageId,
      if (targetMessageGuid != null) 'target_message_guid': targetMessageGuid,
      if (parseConfidence != null) 'parse_confidence': parseConfidence,
    });
  }

  WorkingReactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? messageGuid,
    Value<String>? kind,
    Value<int?>? reactorHandleId,
    Value<String>? action,
    Value<String?>? reactedAtUtc,
    Value<int?>? carrierMessageId,
    Value<String?>? targetMessageGuid,
    Value<double>? parseConfidence,
  }) {
    return WorkingReactionsCompanion(
      id: id ?? this.id,
      messageGuid: messageGuid ?? this.messageGuid,
      kind: kind ?? this.kind,
      reactorHandleId: reactorHandleId ?? this.reactorHandleId,
      action: action ?? this.action,
      reactedAtUtc: reactedAtUtc ?? this.reactedAtUtc,
      carrierMessageId: carrierMessageId ?? this.carrierMessageId,
      targetMessageGuid: targetMessageGuid ?? this.targetMessageGuid,
      parseConfidence: parseConfidence ?? this.parseConfidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (reactorHandleId.present) {
      map['reactor_handle_id'] = Variable<int>(reactorHandleId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (reactedAtUtc.present) {
      map['reacted_at_utc'] = Variable<String>(reactedAtUtc.value);
    }
    if (carrierMessageId.present) {
      map['carrier_message_id'] = Variable<int>(carrierMessageId.value);
    }
    if (targetMessageGuid.present) {
      map['target_message_guid'] = Variable<String>(targetMessageGuid.value);
    }
    if (parseConfidence.present) {
      map['parse_confidence'] = Variable<double>(parseConfidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingReactionsCompanion(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('kind: $kind, ')
          ..write('reactorHandleId: $reactorHandleId, ')
          ..write('action: $action, ')
          ..write('reactedAtUtc: $reactedAtUtc, ')
          ..write('carrierMessageId: $carrierMessageId, ')
          ..write('targetMessageGuid: $targetMessageGuid, ')
          ..write('parseConfidence: $parseConfidence')
          ..write(')'))
        .toString();
  }
}

class $ReactionCountsTable extends ReactionCounts
    with TableInfo<$ReactionCountsTable, ReactionCount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loveMeta = const VerificationMeta('love');
  @override
  late final GeneratedColumn<int> love = GeneratedColumn<int>(
    'love',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeMeta = const VerificationMeta('like');
  @override
  late final GeneratedColumn<int> like = GeneratedColumn<int>(
    'like',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dislikeMeta = const VerificationMeta(
    'dislike',
  );
  @override
  late final GeneratedColumn<int> dislike = GeneratedColumn<int>(
    'dislike',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _laughMeta = const VerificationMeta('laugh');
  @override
  late final GeneratedColumn<int> laugh = GeneratedColumn<int>(
    'laugh',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _emphasizeMeta = const VerificationMeta(
    'emphasize',
  );
  @override
  late final GeneratedColumn<int> emphasize = GeneratedColumn<int>(
    'emphasize',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<int> question = GeneratedColumn<int>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageGuid,
    love,
    like,
    dislike,
    laugh,
    emphasize,
    question,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reaction_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionCount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('love')) {
      context.handle(
        _loveMeta,
        love.isAcceptableOrUnknown(data['love']!, _loveMeta),
      );
    }
    if (data.containsKey('like')) {
      context.handle(
        _likeMeta,
        like.isAcceptableOrUnknown(data['like']!, _likeMeta),
      );
    }
    if (data.containsKey('dislike')) {
      context.handle(
        _dislikeMeta,
        dislike.isAcceptableOrUnknown(data['dislike']!, _dislikeMeta),
      );
    }
    if (data.containsKey('laugh')) {
      context.handle(
        _laughMeta,
        laugh.isAcceptableOrUnknown(data['laugh']!, _laughMeta),
      );
    }
    if (data.containsKey('emphasize')) {
      context.handle(
        _emphasizeMeta,
        emphasize.isAcceptableOrUnknown(data['emphasize']!, _emphasizeMeta),
      );
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageGuid};
  @override
  ReactionCount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionCount(
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      love: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}love'],
      )!,
      like: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like'],
      )!,
      dislike: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dislike'],
      )!,
      laugh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}laugh'],
      )!,
      emphasize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emphasize'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question'],
      )!,
    );
  }

  @override
  $ReactionCountsTable createAlias(String alias) {
    return $ReactionCountsTable(attachedDatabase, alias);
  }
}

class ReactionCount extends DataClass implements Insertable<ReactionCount> {
  final String messageGuid;
  final int love;
  final int like;
  final int dislike;
  final int laugh;
  final int emphasize;
  final int question;
  const ReactionCount({
    required this.messageGuid,
    required this.love,
    required this.like,
    required this.dislike,
    required this.laugh,
    required this.emphasize,
    required this.question,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_guid'] = Variable<String>(messageGuid);
    map['love'] = Variable<int>(love);
    map['like'] = Variable<int>(like);
    map['dislike'] = Variable<int>(dislike);
    map['laugh'] = Variable<int>(laugh);
    map['emphasize'] = Variable<int>(emphasize);
    map['question'] = Variable<int>(question);
    return map;
  }

  ReactionCountsCompanion toCompanion(bool nullToAbsent) {
    return ReactionCountsCompanion(
      messageGuid: Value(messageGuid),
      love: Value(love),
      like: Value(like),
      dislike: Value(dislike),
      laugh: Value(laugh),
      emphasize: Value(emphasize),
      question: Value(question),
    );
  }

  factory ReactionCount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionCount(
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      love: serializer.fromJson<int>(json['love']),
      like: serializer.fromJson<int>(json['like']),
      dislike: serializer.fromJson<int>(json['dislike']),
      laugh: serializer.fromJson<int>(json['laugh']),
      emphasize: serializer.fromJson<int>(json['emphasize']),
      question: serializer.fromJson<int>(json['question']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageGuid': serializer.toJson<String>(messageGuid),
      'love': serializer.toJson<int>(love),
      'like': serializer.toJson<int>(like),
      'dislike': serializer.toJson<int>(dislike),
      'laugh': serializer.toJson<int>(laugh),
      'emphasize': serializer.toJson<int>(emphasize),
      'question': serializer.toJson<int>(question),
    };
  }

  ReactionCount copyWith({
    String? messageGuid,
    int? love,
    int? like,
    int? dislike,
    int? laugh,
    int? emphasize,
    int? question,
  }) => ReactionCount(
    messageGuid: messageGuid ?? this.messageGuid,
    love: love ?? this.love,
    like: like ?? this.like,
    dislike: dislike ?? this.dislike,
    laugh: laugh ?? this.laugh,
    emphasize: emphasize ?? this.emphasize,
    question: question ?? this.question,
  );
  ReactionCount copyWithCompanion(ReactionCountsCompanion data) {
    return ReactionCount(
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      love: data.love.present ? data.love.value : this.love,
      like: data.like.present ? data.like.value : this.like,
      dislike: data.dislike.present ? data.dislike.value : this.dislike,
      laugh: data.laugh.present ? data.laugh.value : this.laugh,
      emphasize: data.emphasize.present ? data.emphasize.value : this.emphasize,
      question: data.question.present ? data.question.value : this.question,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionCount(')
          ..write('messageGuid: $messageGuid, ')
          ..write('love: $love, ')
          ..write('like: $like, ')
          ..write('dislike: $dislike, ')
          ..write('laugh: $laugh, ')
          ..write('emphasize: $emphasize, ')
          ..write('question: $question')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(messageGuid, love, like, dislike, laugh, emphasize, question);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionCount &&
          other.messageGuid == this.messageGuid &&
          other.love == this.love &&
          other.like == this.like &&
          other.dislike == this.dislike &&
          other.laugh == this.laugh &&
          other.emphasize == this.emphasize &&
          other.question == this.question);
}

class ReactionCountsCompanion extends UpdateCompanion<ReactionCount> {
  final Value<String> messageGuid;
  final Value<int> love;
  final Value<int> like;
  final Value<int> dislike;
  final Value<int> laugh;
  final Value<int> emphasize;
  final Value<int> question;
  final Value<int> rowid;
  const ReactionCountsCompanion({
    this.messageGuid = const Value.absent(),
    this.love = const Value.absent(),
    this.like = const Value.absent(),
    this.dislike = const Value.absent(),
    this.laugh = const Value.absent(),
    this.emphasize = const Value.absent(),
    this.question = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionCountsCompanion.insert({
    required String messageGuid,
    this.love = const Value.absent(),
    this.like = const Value.absent(),
    this.dislike = const Value.absent(),
    this.laugh = const Value.absent(),
    this.emphasize = const Value.absent(),
    this.question = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageGuid = Value(messageGuid);
  static Insertable<ReactionCount> custom({
    Expression<String>? messageGuid,
    Expression<int>? love,
    Expression<int>? like,
    Expression<int>? dislike,
    Expression<int>? laugh,
    Expression<int>? emphasize,
    Expression<int>? question,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageGuid != null) 'message_guid': messageGuid,
      if (love != null) 'love': love,
      if (like != null) 'like': like,
      if (dislike != null) 'dislike': dislike,
      if (laugh != null) 'laugh': laugh,
      if (emphasize != null) 'emphasize': emphasize,
      if (question != null) 'question': question,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionCountsCompanion copyWith({
    Value<String>? messageGuid,
    Value<int>? love,
    Value<int>? like,
    Value<int>? dislike,
    Value<int>? laugh,
    Value<int>? emphasize,
    Value<int>? question,
    Value<int>? rowid,
  }) {
    return ReactionCountsCompanion(
      messageGuid: messageGuid ?? this.messageGuid,
      love: love ?? this.love,
      like: like ?? this.like,
      dislike: dislike ?? this.dislike,
      laugh: laugh ?? this.laugh,
      emphasize: emphasize ?? this.emphasize,
      question: question ?? this.question,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (love.present) {
      map['love'] = Variable<int>(love.value);
    }
    if (like.present) {
      map['like'] = Variable<int>(like.value);
    }
    if (dislike.present) {
      map['dislike'] = Variable<int>(dislike.value);
    }
    if (laugh.present) {
      map['laugh'] = Variable<int>(laugh.value);
    }
    if (emphasize.present) {
      map['emphasize'] = Variable<int>(emphasize.value);
    }
    if (question.present) {
      map['question'] = Variable<int>(question.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionCountsCompanion(')
          ..write('messageGuid: $messageGuid, ')
          ..write('love: $love, ')
          ..write('like: $like, ')
          ..write('dislike: $dislike, ')
          ..write('laugh: $laugh, ')
          ..write('emphasize: $emphasize, ')
          ..write('question: $question, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadStateTable extends ReadState
    with TableInfo<$ReadStateTable, ReadStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lastReadAtUtcMeta = const VerificationMeta(
    'lastReadAtUtc',
  );
  @override
  late final GeneratedColumn<String> lastReadAtUtc = GeneratedColumn<String>(
    'last_read_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, lastReadAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    }
    if (data.containsKey('last_read_at_utc')) {
      context.handle(
        _lastReadAtUtcMeta,
        lastReadAtUtc.isAcceptableOrUnknown(
          data['last_read_at_utc']!,
          _lastReadAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  ReadStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadStateData(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      lastReadAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_at_utc'],
      ),
    );
  }

  @override
  $ReadStateTable createAlias(String alias) {
    return $ReadStateTable(attachedDatabase, alias);
  }
}

class ReadStateData extends DataClass implements Insertable<ReadStateData> {
  final int chatId;
  final String? lastReadAtUtc;
  const ReadStateData({required this.chatId, this.lastReadAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || lastReadAtUtc != null) {
      map['last_read_at_utc'] = Variable<String>(lastReadAtUtc);
    }
    return map;
  }

  ReadStateCompanion toCompanion(bool nullToAbsent) {
    return ReadStateCompanion(
      chatId: Value(chatId),
      lastReadAtUtc: lastReadAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAtUtc),
    );
  }

  factory ReadStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadStateData(
      chatId: serializer.fromJson<int>(json['chatId']),
      lastReadAtUtc: serializer.fromJson<String?>(json['lastReadAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'lastReadAtUtc': serializer.toJson<String?>(lastReadAtUtc),
    };
  }

  ReadStateData copyWith({
    int? chatId,
    Value<String?> lastReadAtUtc = const Value.absent(),
  }) => ReadStateData(
    chatId: chatId ?? this.chatId,
    lastReadAtUtc: lastReadAtUtc.present
        ? lastReadAtUtc.value
        : this.lastReadAtUtc,
  );
  ReadStateData copyWithCompanion(ReadStateCompanion data) {
    return ReadStateData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      lastReadAtUtc: data.lastReadAtUtc.present
          ? data.lastReadAtUtc.value
          : this.lastReadAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadStateData(')
          ..write('chatId: $chatId, ')
          ..write('lastReadAtUtc: $lastReadAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, lastReadAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadStateData &&
          other.chatId == this.chatId &&
          other.lastReadAtUtc == this.lastReadAtUtc);
}

class ReadStateCompanion extends UpdateCompanion<ReadStateData> {
  final Value<int> chatId;
  final Value<String?> lastReadAtUtc;
  const ReadStateCompanion({
    this.chatId = const Value.absent(),
    this.lastReadAtUtc = const Value.absent(),
  });
  ReadStateCompanion.insert({
    this.chatId = const Value.absent(),
    this.lastReadAtUtc = const Value.absent(),
  });
  static Insertable<ReadStateData> custom({
    Expression<int>? chatId,
    Expression<String>? lastReadAtUtc,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (lastReadAtUtc != null) 'last_read_at_utc': lastReadAtUtc,
    });
  }

  ReadStateCompanion copyWith({
    Value<int>? chatId,
    Value<String?>? lastReadAtUtc,
  }) {
    return ReadStateCompanion(
      chatId: chatId ?? this.chatId,
      lastReadAtUtc: lastReadAtUtc ?? this.lastReadAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (lastReadAtUtc.present) {
      map['last_read_at_utc'] = Variable<String>(lastReadAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadStateCompanion(')
          ..write('chatId: $chatId, ')
          ..write('lastReadAtUtc: $lastReadAtUtc')
          ..write(')'))
        .toString();
  }
}

class $MessageReadMarksTable extends MessageReadMarks
    with TableInfo<$MessageReadMarksTable, MessageReadMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageReadMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedAtUtcMeta = const VerificationMeta(
    'markedAtUtc',
  );
  @override
  late final GeneratedColumn<String> markedAtUtc = GeneratedColumn<String>(
    'marked_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [messageGuid, markedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_read_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageReadMark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('marked_at_utc')) {
      context.handle(
        _markedAtUtcMeta,
        markedAtUtc.isAcceptableOrUnknown(
          data['marked_at_utc']!,
          _markedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageGuid};
  @override
  MessageReadMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageReadMark(
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      markedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_at_utc'],
      )!,
    );
  }

  @override
  $MessageReadMarksTable createAlias(String alias) {
    return $MessageReadMarksTable(attachedDatabase, alias);
  }
}

class MessageReadMark extends DataClass implements Insertable<MessageReadMark> {
  final String messageGuid;
  final String markedAtUtc;
  const MessageReadMark({required this.messageGuid, required this.markedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_guid'] = Variable<String>(messageGuid);
    map['marked_at_utc'] = Variable<String>(markedAtUtc);
    return map;
  }

  MessageReadMarksCompanion toCompanion(bool nullToAbsent) {
    return MessageReadMarksCompanion(
      messageGuid: Value(messageGuid),
      markedAtUtc: Value(markedAtUtc),
    );
  }

  factory MessageReadMark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageReadMark(
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      markedAtUtc: serializer.fromJson<String>(json['markedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageGuid': serializer.toJson<String>(messageGuid),
      'markedAtUtc': serializer.toJson<String>(markedAtUtc),
    };
  }

  MessageReadMark copyWith({String? messageGuid, String? markedAtUtc}) =>
      MessageReadMark(
        messageGuid: messageGuid ?? this.messageGuid,
        markedAtUtc: markedAtUtc ?? this.markedAtUtc,
      );
  MessageReadMark copyWithCompanion(MessageReadMarksCompanion data) {
    return MessageReadMark(
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      markedAtUtc: data.markedAtUtc.present
          ? data.markedAtUtc.value
          : this.markedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageReadMark(')
          ..write('messageGuid: $messageGuid, ')
          ..write('markedAtUtc: $markedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageGuid, markedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageReadMark &&
          other.messageGuid == this.messageGuid &&
          other.markedAtUtc == this.markedAtUtc);
}

class MessageReadMarksCompanion extends UpdateCompanion<MessageReadMark> {
  final Value<String> messageGuid;
  final Value<String> markedAtUtc;
  final Value<int> rowid;
  const MessageReadMarksCompanion({
    this.messageGuid = const Value.absent(),
    this.markedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageReadMarksCompanion.insert({
    required String messageGuid,
    required String markedAtUtc,
    this.rowid = const Value.absent(),
  }) : messageGuid = Value(messageGuid),
       markedAtUtc = Value(markedAtUtc);
  static Insertable<MessageReadMark> custom({
    Expression<String>? messageGuid,
    Expression<String>? markedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageGuid != null) 'message_guid': messageGuid,
      if (markedAtUtc != null) 'marked_at_utc': markedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageReadMarksCompanion copyWith({
    Value<String>? messageGuid,
    Value<String>? markedAtUtc,
    Value<int>? rowid,
  }) {
    return MessageReadMarksCompanion(
      messageGuid: messageGuid ?? this.messageGuid,
      markedAtUtc: markedAtUtc ?? this.markedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (markedAtUtc.present) {
      map['marked_at_utc'] = Variable<String>(markedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageReadMarksCompanion(')
          ..write('messageGuid: $messageGuid, ')
          ..write('markedAtUtc: $markedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupabaseSyncStateTable extends SupabaseSyncState
    with TableInfo<$SupabaseSyncStateTable, SupabaseSyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupabaseSyncStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastBatchIdMeta = const VerificationMeta(
    'lastBatchId',
  );
  @override
  late final GeneratedColumn<int> lastBatchId = GeneratedColumn<int>(
    'last_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedRowIdMeta = const VerificationMeta(
    'lastSyncedRowId',
  );
  @override
  late final GeneratedColumn<int> lastSyncedRowId = GeneratedColumn<int>(
    'last_synced_row_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedGuidMeta = const VerificationMeta(
    'lastSyncedGuid',
  );
  @override
  late final GeneratedColumn<String> lastSyncedGuid = GeneratedColumn<String>(
    'last_synced_guid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    lastBatchId,
    lastSyncedRowId,
    lastSyncedGuid,
    lastSyncedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supabase_sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupabaseSyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('last_batch_id')) {
      context.handle(
        _lastBatchIdMeta,
        lastBatchId.isAcceptableOrUnknown(
          data['last_batch_id']!,
          _lastBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_row_id')) {
      context.handle(
        _lastSyncedRowIdMeta,
        lastSyncedRowId.isAcceptableOrUnknown(
          data['last_synced_row_id']!,
          _lastSyncedRowIdMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_guid')) {
      context.handle(
        _lastSyncedGuidMeta,
        lastSyncedGuid.isAcceptableOrUnknown(
          data['last_synced_guid']!,
          _lastSyncedGuidMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {targetTable},
  ];
  @override
  SupabaseSyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupabaseSyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      lastBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_batch_id'],
      ),
      lastSyncedRowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_row_id'],
      ),
      lastSyncedGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_guid'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SupabaseSyncStateTable createAlias(String alias) {
    return $SupabaseSyncStateTable(attachedDatabase, alias);
  }
}

class SupabaseSyncStateData extends DataClass
    implements Insertable<SupabaseSyncStateData> {
  final int id;
  final String targetTable;
  final int? lastBatchId;
  final int? lastSyncedRowId;
  final String? lastSyncedGuid;
  final DateTime? lastSyncedAt;
  final DateTime updatedAt;
  const SupabaseSyncStateData({
    required this.id,
    required this.targetTable,
    this.lastBatchId,
    this.lastSyncedRowId,
    this.lastSyncedGuid,
    this.lastSyncedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    if (!nullToAbsent || lastBatchId != null) {
      map['last_batch_id'] = Variable<int>(lastBatchId);
    }
    if (!nullToAbsent || lastSyncedRowId != null) {
      map['last_synced_row_id'] = Variable<int>(lastSyncedRowId);
    }
    if (!nullToAbsent || lastSyncedGuid != null) {
      map['last_synced_guid'] = Variable<String>(lastSyncedGuid);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SupabaseSyncStateCompanion toCompanion(bool nullToAbsent) {
    return SupabaseSyncStateCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      lastBatchId: lastBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBatchId),
      lastSyncedRowId: lastSyncedRowId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedRowId),
      lastSyncedGuid: lastSyncedGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedGuid),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SupabaseSyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupabaseSyncStateData(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      lastBatchId: serializer.fromJson<int?>(json['lastBatchId']),
      lastSyncedRowId: serializer.fromJson<int?>(json['lastSyncedRowId']),
      lastSyncedGuid: serializer.fromJson<String?>(json['lastSyncedGuid']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'lastBatchId': serializer.toJson<int?>(lastBatchId),
      'lastSyncedRowId': serializer.toJson<int?>(lastSyncedRowId),
      'lastSyncedGuid': serializer.toJson<String?>(lastSyncedGuid),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SupabaseSyncStateData copyWith({
    int? id,
    String? targetTable,
    Value<int?> lastBatchId = const Value.absent(),
    Value<int?> lastSyncedRowId = const Value.absent(),
    Value<String?> lastSyncedGuid = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => SupabaseSyncStateData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    lastBatchId: lastBatchId.present ? lastBatchId.value : this.lastBatchId,
    lastSyncedRowId: lastSyncedRowId.present
        ? lastSyncedRowId.value
        : this.lastSyncedRowId,
    lastSyncedGuid: lastSyncedGuid.present
        ? lastSyncedGuid.value
        : this.lastSyncedGuid,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SupabaseSyncStateData copyWithCompanion(SupabaseSyncStateCompanion data) {
    return SupabaseSyncStateData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      lastBatchId: data.lastBatchId.present
          ? data.lastBatchId.value
          : this.lastBatchId,
      lastSyncedRowId: data.lastSyncedRowId.present
          ? data.lastSyncedRowId.value
          : this.lastSyncedRowId,
      lastSyncedGuid: data.lastSyncedGuid.present
          ? data.lastSyncedGuid.value
          : this.lastSyncedGuid,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncStateData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('lastBatchId: $lastBatchId, ')
          ..write('lastSyncedRowId: $lastSyncedRowId, ')
          ..write('lastSyncedGuid: $lastSyncedGuid, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    lastBatchId,
    lastSyncedRowId,
    lastSyncedGuid,
    lastSyncedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupabaseSyncStateData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.lastBatchId == this.lastBatchId &&
          other.lastSyncedRowId == this.lastSyncedRowId &&
          other.lastSyncedGuid == this.lastSyncedGuid &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.updatedAt == this.updatedAt);
}

class SupabaseSyncStateCompanion
    extends UpdateCompanion<SupabaseSyncStateData> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<int?> lastBatchId;
  final Value<int?> lastSyncedRowId;
  final Value<String?> lastSyncedGuid;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> updatedAt;
  const SupabaseSyncStateCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.lastBatchId = const Value.absent(),
    this.lastSyncedRowId = const Value.absent(),
    this.lastSyncedGuid = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SupabaseSyncStateCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    this.lastBatchId = const Value.absent(),
    this.lastSyncedRowId = const Value.absent(),
    this.lastSyncedGuid = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : targetTable = Value(targetTable);
  static Insertable<SupabaseSyncStateData> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<int>? lastBatchId,
    Expression<int>? lastSyncedRowId,
    Expression<String>? lastSyncedGuid,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (lastBatchId != null) 'last_batch_id': lastBatchId,
      if (lastSyncedRowId != null) 'last_synced_row_id': lastSyncedRowId,
      if (lastSyncedGuid != null) 'last_synced_guid': lastSyncedGuid,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SupabaseSyncStateCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<int?>? lastBatchId,
    Value<int?>? lastSyncedRowId,
    Value<String?>? lastSyncedGuid,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? updatedAt,
  }) {
    return SupabaseSyncStateCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      lastBatchId: lastBatchId ?? this.lastBatchId,
      lastSyncedRowId: lastSyncedRowId ?? this.lastSyncedRowId,
      lastSyncedGuid: lastSyncedGuid ?? this.lastSyncedGuid,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (lastBatchId.present) {
      map['last_batch_id'] = Variable<int>(lastBatchId.value);
    }
    if (lastSyncedRowId.present) {
      map['last_synced_row_id'] = Variable<int>(lastSyncedRowId.value);
    }
    if (lastSyncedGuid.present) {
      map['last_synced_guid'] = Variable<String>(lastSyncedGuid.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncStateCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('lastBatchId: $lastBatchId, ')
          ..write('lastSyncedRowId: $lastSyncedRowId, ')
          ..write('lastSyncedGuid: $lastSyncedGuid, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SupabaseSyncLogsTable extends SupabaseSyncLogs
    with TableInfo<$SupabaseSyncLogsTable, SupabaseSyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupabaseSyncLogsTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    targetTable,
    status,
    attempt,
    requestId,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supabase_sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupabaseSyncLog> instance, {
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
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupabaseSyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupabaseSyncLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupabaseSyncLogsTable createAlias(String alias) {
    return $SupabaseSyncLogsTable(attachedDatabase, alias);
  }
}

class SupabaseSyncLog extends DataClass implements Insertable<SupabaseSyncLog> {
  final int id;
  final int? batchId;
  final String? targetTable;
  final String? status;
  final int attempt;
  final String? requestId;
  final String? message;
  final DateTime createdAt;
  const SupabaseSyncLog({
    required this.id,
    this.batchId,
    this.targetTable,
    this.status,
    required this.attempt,
    this.requestId,
    this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    if (!nullToAbsent || targetTable != null) {
      map['target_table'] = Variable<String>(targetTable);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupabaseSyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SupabaseSyncLogsCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      targetTable: targetTable == null && nullToAbsent
          ? const Value.absent()
          : Value(targetTable),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      attempt: Value(attempt),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory SupabaseSyncLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupabaseSyncLog(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      targetTable: serializer.fromJson<String?>(json['targetTable']),
      status: serializer.fromJson<String?>(json['status']),
      attempt: serializer.fromJson<int>(json['attempt']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      message: serializer.fromJson<String?>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int?>(batchId),
      'targetTable': serializer.toJson<String?>(targetTable),
      'status': serializer.toJson<String?>(status),
      'attempt': serializer.toJson<int>(attempt),
      'requestId': serializer.toJson<String?>(requestId),
      'message': serializer.toJson<String?>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupabaseSyncLog copyWith({
    int? id,
    Value<int?> batchId = const Value.absent(),
    Value<String?> targetTable = const Value.absent(),
    Value<String?> status = const Value.absent(),
    int? attempt,
    Value<String?> requestId = const Value.absent(),
    Value<String?> message = const Value.absent(),
    DateTime? createdAt,
  }) => SupabaseSyncLog(
    id: id ?? this.id,
    batchId: batchId.present ? batchId.value : this.batchId,
    targetTable: targetTable.present ? targetTable.value : this.targetTable,
    status: status.present ? status.value : this.status,
    attempt: attempt ?? this.attempt,
    requestId: requestId.present ? requestId.value : this.requestId,
    message: message.present ? message.value : this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  SupabaseSyncLog copyWithCompanion(SupabaseSyncLogsCompanion data) {
    return SupabaseSyncLog(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      status: data.status.present ? data.status.value : this.status,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncLog(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('targetTable: $targetTable, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('requestId: $requestId, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    targetTable,
    status,
    attempt,
    requestId,
    message,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupabaseSyncLog &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.targetTable == this.targetTable &&
          other.status == this.status &&
          other.attempt == this.attempt &&
          other.requestId == this.requestId &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class SupabaseSyncLogsCompanion extends UpdateCompanion<SupabaseSyncLog> {
  final Value<int> id;
  final Value<int?> batchId;
  final Value<String?> targetTable;
  final Value<String?> status;
  final Value<int> attempt;
  final Value<String?> requestId;
  final Value<String?> message;
  final Value<DateTime> createdAt;
  const SupabaseSyncLogsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.requestId = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SupabaseSyncLogsCompanion.insert({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.requestId = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<SupabaseSyncLog> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<String>? targetTable,
    Expression<String>? status,
    Expression<int>? attempt,
    Expression<String>? requestId,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (targetTable != null) 'target_table': targetTable,
      if (status != null) 'status': status,
      if (attempt != null) 'attempt': attempt,
      if (requestId != null) 'request_id': requestId,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SupabaseSyncLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? batchId,
    Value<String?>? targetTable,
    Value<String?>? status,
    Value<int>? attempt,
    Value<String?>? requestId,
    Value<String?>? message,
    Value<DateTime>? createdAt,
  }) {
    return SupabaseSyncLogsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      targetTable: targetTable ?? this.targetTable,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      requestId: requestId ?? this.requestId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
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
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('targetTable: $targetTable, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('requestId: $requestId, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$WorkingDatabase extends GeneratedDatabase {
  _$WorkingDatabase(QueryExecutor e) : super(e);
  $WorkingDatabaseManager get managers => $WorkingDatabaseManager(this);
  late final $WorkingSchemaMigrationsTable workingSchemaMigrations =
      $WorkingSchemaMigrationsTable(this);
  late final $ProjectionStateTable projectionState = $ProjectionStateTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $WorkingHandlesTable workingHandles = $WorkingHandlesTable(this);
  late final $HandlesCanonicalTable handlesCanonical = $HandlesCanonicalTable(
    this,
  );
  late final $WorkingParticipantsTable workingParticipants =
      $WorkingParticipantsTable(this);
  late final $HandleToParticipantTable handleToParticipant =
      $HandleToParticipantTable(this);
  late final $HandlesCanonicalToAliasTable handlesCanonicalToAlias =
      $HandlesCanonicalToAliasTable(this);
  late final $WorkingChatsTable workingChats = $WorkingChatsTable(this);
  late final $ChatToHandleTable chatToHandle = $ChatToHandleTable(this);
  late final $WorkingMessagesTable workingMessages = $WorkingMessagesTable(
    this,
  );
  late final $GlobalMessageIndexTable globalMessageIndex =
      $GlobalMessageIndexTable(this);
  late final $MessageIndexTable messageIndex = $MessageIndexTable(this);
  late final $ContactMessageIndexTable contactMessageIndex =
      $ContactMessageIndexTable(this);
  late final $WorkingAttachmentsTable workingAttachments =
      $WorkingAttachmentsTable(this);
  late final $WorkingReactionsTable workingReactions = $WorkingReactionsTable(
    this,
  );
  late final $ReactionCountsTable reactionCounts = $ReactionCountsTable(this);
  late final $ReadStateTable readState = $ReadStateTable(this);
  late final $MessageReadMarksTable messageReadMarks = $MessageReadMarksTable(
    this,
  );
  late final $SupabaseSyncStateTable supabaseSyncState =
      $SupabaseSyncStateTable(this);
  late final $SupabaseSyncLogsTable supabaseSyncLogs = $SupabaseSyncLogsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workingSchemaMigrations,
    projectionState,
    appSettings,
    workingHandles,
    handlesCanonical,
    workingParticipants,
    handleToParticipant,
    handlesCanonicalToAlias,
    workingChats,
    chatToHandle,
    workingMessages,
    globalMessageIndex,
    messageIndex,
    contactMessageIndex,
    workingAttachments,
    workingReactions,
    reactionCounts,
    readState,
    messageReadMarks,
    supabaseSyncState,
    supabaseSyncLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles_canonical',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('handle_to_participant', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('handle_to_participant', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles_canonical',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('handles_canonical_to_alias', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles_canonical',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chats', kind: UpdateKind.update)],
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
        'handles_canonical',
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
        'handles_canonical',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('global_message_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('global_message_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_message_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_message_index', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'handles_canonical',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reactions', kind: UpdateKind.update)],
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
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('read_state', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WorkingSchemaMigrationsTableCreateCompanionBuilder =
    WorkingSchemaMigrationsCompanion Function({
      Value<int> version,
      required String appliedAtUtc,
    });
typedef $$WorkingSchemaMigrationsTableUpdateCompanionBuilder =
    WorkingSchemaMigrationsCompanion Function({
      Value<int> version,
      Value<String> appliedAtUtc,
    });

class $$WorkingSchemaMigrationsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingSchemaMigrationsTable> {
  $$WorkingSchemaMigrationsTableFilterComposer({
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

class $$WorkingSchemaMigrationsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingSchemaMigrationsTable> {
  $$WorkingSchemaMigrationsTableOrderingComposer({
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

class $$WorkingSchemaMigrationsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingSchemaMigrationsTable> {
  $$WorkingSchemaMigrationsTableAnnotationComposer({
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

class $$WorkingSchemaMigrationsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingSchemaMigrationsTable,
          WorkingSchemaMigration,
          $$WorkingSchemaMigrationsTableFilterComposer,
          $$WorkingSchemaMigrationsTableOrderingComposer,
          $$WorkingSchemaMigrationsTableAnnotationComposer,
          $$WorkingSchemaMigrationsTableCreateCompanionBuilder,
          $$WorkingSchemaMigrationsTableUpdateCompanionBuilder,
          (
            WorkingSchemaMigration,
            BaseReferences<
              _$WorkingDatabase,
              $WorkingSchemaMigrationsTable,
              WorkingSchemaMigration
            >,
          ),
          WorkingSchemaMigration,
          PrefetchHooks Function()
        > {
  $$WorkingSchemaMigrationsTableTableManager(
    _$WorkingDatabase db,
    $WorkingSchemaMigrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingSchemaMigrationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkingSchemaMigrationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkingSchemaMigrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                Value<String> appliedAtUtc = const Value.absent(),
              }) => WorkingSchemaMigrationsCompanion(
                version: version,
                appliedAtUtc: appliedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                required String appliedAtUtc,
              }) => WorkingSchemaMigrationsCompanion.insert(
                version: version,
                appliedAtUtc: appliedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkingSchemaMigrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingSchemaMigrationsTable,
      WorkingSchemaMigration,
      $$WorkingSchemaMigrationsTableFilterComposer,
      $$WorkingSchemaMigrationsTableOrderingComposer,
      $$WorkingSchemaMigrationsTableAnnotationComposer,
      $$WorkingSchemaMigrationsTableCreateCompanionBuilder,
      $$WorkingSchemaMigrationsTableUpdateCompanionBuilder,
      (
        WorkingSchemaMigration,
        BaseReferences<
          _$WorkingDatabase,
          $WorkingSchemaMigrationsTable,
          WorkingSchemaMigration
        >,
      ),
      WorkingSchemaMigration,
      PrefetchHooks Function()
    >;
typedef $$ProjectionStateTableCreateCompanionBuilder =
    ProjectionStateCompanion Function({
      Value<int> id,
      Value<int?> lastImportBatchId,
      Value<String?> lastProjectedAtUtc,
      Value<int?> lastProjectedMessageId,
      Value<int?> lastProjectedAttachmentId,
    });
typedef $$ProjectionStateTableUpdateCompanionBuilder =
    ProjectionStateCompanion Function({
      Value<int> id,
      Value<int?> lastImportBatchId,
      Value<String?> lastProjectedAtUtc,
      Value<int?> lastProjectedMessageId,
      Value<int?> lastProjectedAttachmentId,
    });

class $$ProjectionStateTableFilterComposer
    extends Composer<_$WorkingDatabase, $ProjectionStateTable> {
  $$ProjectionStateTableFilterComposer({
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

  ColumnFilters<int> get lastImportBatchId => $composableBuilder(
    column: $table.lastImportBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastProjectedAtUtc => $composableBuilder(
    column: $table.lastProjectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastProjectedMessageId => $composableBuilder(
    column: $table.lastProjectedMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastProjectedAttachmentId => $composableBuilder(
    column: $table.lastProjectedAttachmentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectionStateTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ProjectionStateTable> {
  $$ProjectionStateTableOrderingComposer({
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

  ColumnOrderings<int> get lastImportBatchId => $composableBuilder(
    column: $table.lastImportBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastProjectedAtUtc => $composableBuilder(
    column: $table.lastProjectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastProjectedMessageId => $composableBuilder(
    column: $table.lastProjectedMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastProjectedAttachmentId => $composableBuilder(
    column: $table.lastProjectedAttachmentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectionStateTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ProjectionStateTable> {
  $$ProjectionStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastImportBatchId => $composableBuilder(
    column: $table.lastImportBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastProjectedAtUtc => $composableBuilder(
    column: $table.lastProjectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastProjectedMessageId => $composableBuilder(
    column: $table.lastProjectedMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastProjectedAttachmentId => $composableBuilder(
    column: $table.lastProjectedAttachmentId,
    builder: (column) => column,
  );
}

class $$ProjectionStateTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ProjectionStateTable,
          ProjectionStateData,
          $$ProjectionStateTableFilterComposer,
          $$ProjectionStateTableOrderingComposer,
          $$ProjectionStateTableAnnotationComposer,
          $$ProjectionStateTableCreateCompanionBuilder,
          $$ProjectionStateTableUpdateCompanionBuilder,
          (
            ProjectionStateData,
            BaseReferences<
              _$WorkingDatabase,
              $ProjectionStateTable,
              ProjectionStateData
            >,
          ),
          ProjectionStateData,
          PrefetchHooks Function()
        > {
  $$ProjectionStateTableTableManager(
    _$WorkingDatabase db,
    $ProjectionStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectionStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectionStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectionStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastImportBatchId = const Value.absent(),
                Value<String?> lastProjectedAtUtc = const Value.absent(),
                Value<int?> lastProjectedMessageId = const Value.absent(),
                Value<int?> lastProjectedAttachmentId = const Value.absent(),
              }) => ProjectionStateCompanion(
                id: id,
                lastImportBatchId: lastImportBatchId,
                lastProjectedAtUtc: lastProjectedAtUtc,
                lastProjectedMessageId: lastProjectedMessageId,
                lastProjectedAttachmentId: lastProjectedAttachmentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastImportBatchId = const Value.absent(),
                Value<String?> lastProjectedAtUtc = const Value.absent(),
                Value<int?> lastProjectedMessageId = const Value.absent(),
                Value<int?> lastProjectedAttachmentId = const Value.absent(),
              }) => ProjectionStateCompanion.insert(
                id: id,
                lastImportBatchId: lastImportBatchId,
                lastProjectedAtUtc: lastProjectedAtUtc,
                lastProjectedMessageId: lastProjectedMessageId,
                lastProjectedAttachmentId: lastProjectedAttachmentId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectionStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ProjectionStateTable,
      ProjectionStateData,
      $$ProjectionStateTableFilterComposer,
      $$ProjectionStateTableOrderingComposer,
      $$ProjectionStateTableAnnotationComposer,
      $$ProjectionStateTableCreateCompanionBuilder,
      $$ProjectionStateTableUpdateCompanionBuilder,
      (
        ProjectionStateData,
        BaseReferences<
          _$WorkingDatabase,
          $ProjectionStateTable,
          ProjectionStateData
        >,
      ),
      ProjectionStateData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$WorkingDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$WorkingDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$WorkingDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$WorkingDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$WorkingHandlesTableCreateCompanionBuilder =
    WorkingHandlesCompanion Function({
      Value<int> id,
      required String rawIdentifier,
      required String displayName,
      required String compoundIdentifier,
      Value<String> service,
      Value<bool> isIgnored,
      Value<bool> isVisible,
      Value<bool> isBlacklisted,
      Value<String?> country,
      Value<String?> lastSeenUtc,
      Value<int?> batchId,
    });
typedef $$WorkingHandlesTableUpdateCompanionBuilder =
    WorkingHandlesCompanion Function({
      Value<int> id,
      Value<String> rawIdentifier,
      Value<String> displayName,
      Value<String> compoundIdentifier,
      Value<String> service,
      Value<bool> isIgnored,
      Value<bool> isVisible,
      Value<bool> isBlacklisted,
      Value<String?> country,
      Value<String?> lastSeenUtc,
      Value<int?> batchId,
    });

class $$WorkingHandlesTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingHandlesTable> {
  $$WorkingHandlesTableFilterComposer({
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

  ColumnFilters<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
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

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkingHandlesTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingHandlesTable> {
  $$WorkingHandlesTableOrderingComposer({
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

  ColumnOrderings<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
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

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkingHandlesTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingHandlesTable> {
  $$WorkingHandlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get lastSeenUtc => $composableBuilder(
    column: $table.lastSeenUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);
}

class $$WorkingHandlesTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingHandlesTable,
          WorkingHandle,
          $$WorkingHandlesTableFilterComposer,
          $$WorkingHandlesTableOrderingComposer,
          $$WorkingHandlesTableAnnotationComposer,
          $$WorkingHandlesTableCreateCompanionBuilder,
          $$WorkingHandlesTableUpdateCompanionBuilder,
          (
            WorkingHandle,
            BaseReferences<
              _$WorkingDatabase,
              $WorkingHandlesTable,
              WorkingHandle
            >,
          ),
          WorkingHandle,
          PrefetchHooks Function()
        > {
  $$WorkingHandlesTableTableManager(
    _$WorkingDatabase db,
    $WorkingHandlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingHandlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingHandlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingHandlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawIdentifier = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> compoundIdentifier = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isBlacklisted = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> lastSeenUtc = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => WorkingHandlesCompanion(
                id: id,
                rawIdentifier: rawIdentifier,
                displayName: displayName,
                compoundIdentifier: compoundIdentifier,
                service: service,
                isIgnored: isIgnored,
                isVisible: isVisible,
                isBlacklisted: isBlacklisted,
                country: country,
                lastSeenUtc: lastSeenUtc,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawIdentifier,
                required String displayName,
                required String compoundIdentifier,
                Value<String> service = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isBlacklisted = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> lastSeenUtc = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => WorkingHandlesCompanion.insert(
                id: id,
                rawIdentifier: rawIdentifier,
                displayName: displayName,
                compoundIdentifier: compoundIdentifier,
                service: service,
                isIgnored: isIgnored,
                isVisible: isVisible,
                isBlacklisted: isBlacklisted,
                country: country,
                lastSeenUtc: lastSeenUtc,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkingHandlesTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingHandlesTable,
      WorkingHandle,
      $$WorkingHandlesTableFilterComposer,
      $$WorkingHandlesTableOrderingComposer,
      $$WorkingHandlesTableAnnotationComposer,
      $$WorkingHandlesTableCreateCompanionBuilder,
      $$WorkingHandlesTableUpdateCompanionBuilder,
      (
        WorkingHandle,
        BaseReferences<_$WorkingDatabase, $WorkingHandlesTable, WorkingHandle>,
      ),
      WorkingHandle,
      PrefetchHooks Function()
    >;
typedef $$HandlesCanonicalTableCreateCompanionBuilder =
    HandlesCanonicalCompanion Function({
      Value<int> id,
      required String rawIdentifier,
      required String displayName,
      required String compoundIdentifier,
      Value<String> service,
      Value<bool> isIgnored,
      Value<bool> isVisible,
      Value<bool> isBlacklisted,
      Value<String?> country,
      Value<String?> lastSeenUtc,
      Value<int?> batchId,
    });
typedef $$HandlesCanonicalTableUpdateCompanionBuilder =
    HandlesCanonicalCompanion Function({
      Value<int> id,
      Value<String> rawIdentifier,
      Value<String> displayName,
      Value<String> compoundIdentifier,
      Value<String> service,
      Value<bool> isIgnored,
      Value<bool> isVisible,
      Value<bool> isBlacklisted,
      Value<String?> country,
      Value<String?> lastSeenUtc,
      Value<int?> batchId,
    });

final class $$HandlesCanonicalTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $HandlesCanonicalTable,
          HandlesCanonicalData
        > {
  $$HandlesCanonicalTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $HandleToParticipantTable,
    List<HandleToParticipantData>
  >
  _handleToParticipantRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.handleToParticipant,
        aliasName: $_aliasNameGenerator(
          db.handlesCanonical.id,
          db.handleToParticipant.handleId,
        ),
      );

  $$HandleToParticipantTableProcessedTableManager get handleToParticipantRefs {
    final manager = $$HandleToParticipantTableTableManager(
      $_db,
      $_db.handleToParticipant,
    ).filter((f) => f.handleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _handleToParticipantRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $HandlesCanonicalToAliasTable,
    List<HandlesCanonicalToAlia>
  >
  _handlesCanonicalToAliasRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.handlesCanonicalToAlias,
        aliasName: $_aliasNameGenerator(
          db.handlesCanonical.id,
          db.handlesCanonicalToAlias.canonicalHandleId,
        ),
      );

  $$HandlesCanonicalToAliasTableProcessedTableManager
  get handlesCanonicalToAliasRefs {
    final manager = $$HandlesCanonicalToAliasTableTableManager(
      $_db,
      $_db.handlesCanonicalToAlias,
    ).filter((f) => f.canonicalHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _handlesCanonicalToAliasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingChatsTable, List<WorkingChat>>
  _workingChatsRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.workingChats,
    aliasName: $_aliasNameGenerator(
      db.handlesCanonical.id,
      db.workingChats.lastSenderHandleId,
    ),
  );

  $$WorkingChatsTableProcessedTableManager get workingChatsRefs {
    final manager = $$WorkingChatsTableTableManager($_db, $_db.workingChats)
        .filter(
          (f) => f.lastSenderHandleId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_workingChatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatToHandleTable, List<ChatToHandleData>>
  _chatToHandleRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.chatToHandle,
    aliasName: $_aliasNameGenerator(
      db.handlesCanonical.id,
      db.chatToHandle.handleId,
    ),
  );

  $$ChatToHandleTableProcessedTableManager get chatToHandleRefs {
    final manager = $$ChatToHandleTableTableManager(
      $_db,
      $_db.chatToHandle,
    ).filter((f) => f.handleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatToHandleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingMessagesTable, List<WorkingMessage>>
  _workingMessagesRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingMessages,
        aliasName: $_aliasNameGenerator(
          db.handlesCanonical.id,
          db.workingMessages.senderHandleId,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager get workingMessagesRefs {
    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.senderHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workingMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingReactionsTable, List<WorkingReaction>>
  _workingReactionsRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingReactions,
        aliasName: $_aliasNameGenerator(
          db.handlesCanonical.id,
          db.workingReactions.reactorHandleId,
        ),
      );

  $$WorkingReactionsTableProcessedTableManager get workingReactionsRefs {
    final manager = $$WorkingReactionsTableTableManager(
      $_db,
      $_db.workingReactions,
    ).filter((f) => f.reactorHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workingReactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HandlesCanonicalTableFilterComposer
    extends Composer<_$WorkingDatabase, $HandlesCanonicalTable> {
  $$HandlesCanonicalTableFilterComposer({
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

  ColumnFilters<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
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

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> handleToParticipantRefs(
    Expression<bool> Function($$HandleToParticipantTableFilterComposer f) f,
  ) {
    final $$HandleToParticipantTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.handleToParticipant,
      getReferencedColumn: (t) => t.handleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandleToParticipantTableFilterComposer(
            $db: $db,
            $table: $db.handleToParticipant,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> handlesCanonicalToAliasRefs(
    Expression<bool> Function($$HandlesCanonicalToAliasTableFilterComposer f) f,
  ) {
    final $$HandlesCanonicalToAliasTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.handlesCanonicalToAlias,
          getReferencedColumn: (t) => t.canonicalHandleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HandlesCanonicalToAliasTableFilterComposer(
                $db: $db,
                $table: $db.handlesCanonicalToAlias,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> workingChatsRefs(
    Expression<bool> Function($$WorkingChatsTableFilterComposer f) f,
  ) {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.lastSenderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatToHandleRefs(
    Expression<bool> Function($$ChatToHandleTableFilterComposer f) f,
  ) {
    final $$ChatToHandleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatToHandle,
      getReferencedColumn: (t) => t.handleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatToHandleTableFilterComposer(
            $db: $db,
            $table: $db.chatToHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingMessagesRefs(
    Expression<bool> Function($$WorkingMessagesTableFilterComposer f) f,
  ) {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.senderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingReactionsRefs(
    Expression<bool> Function($$WorkingReactionsTableFilterComposer f) f,
  ) {
    final $$WorkingReactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingReactions,
      getReferencedColumn: (t) => t.reactorHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingReactionsTableFilterComposer(
            $db: $db,
            $table: $db.workingReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HandlesCanonicalTableOrderingComposer
    extends Composer<_$WorkingDatabase, $HandlesCanonicalTable> {
  $$HandlesCanonicalTableOrderingComposer({
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

  ColumnOrderings<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
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

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HandlesCanonicalTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $HandlesCanonicalTable> {
  $$HandlesCanonicalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get isBlacklisted => $composableBuilder(
    column: $table.isBlacklisted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get lastSeenUtc => $composableBuilder(
    column: $table.lastSeenUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  Expression<T> handleToParticipantRefs<T extends Object>(
    Expression<T> Function($$HandleToParticipantTableAnnotationComposer a) f,
  ) {
    final $$HandleToParticipantTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.handleToParticipant,
          getReferencedColumn: (t) => t.handleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HandleToParticipantTableAnnotationComposer(
                $db: $db,
                $table: $db.handleToParticipant,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> handlesCanonicalToAliasRefs<T extends Object>(
    Expression<T> Function($$HandlesCanonicalToAliasTableAnnotationComposer a)
    f,
  ) {
    final $$HandlesCanonicalToAliasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.handlesCanonicalToAlias,
          getReferencedColumn: (t) => t.canonicalHandleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HandlesCanonicalToAliasTableAnnotationComposer(
                $db: $db,
                $table: $db.handlesCanonicalToAlias,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workingChatsRefs<T extends Object>(
    Expression<T> Function($$WorkingChatsTableAnnotationComposer a) f,
  ) {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.lastSenderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatToHandleRefs<T extends Object>(
    Expression<T> Function($$ChatToHandleTableAnnotationComposer a) f,
  ) {
    final $$ChatToHandleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatToHandle,
      getReferencedColumn: (t) => t.handleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatToHandleTableAnnotationComposer(
            $db: $db,
            $table: $db.chatToHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workingMessagesRefs<T extends Object>(
    Expression<T> Function($$WorkingMessagesTableAnnotationComposer a) f,
  ) {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.senderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workingReactionsRefs<T extends Object>(
    Expression<T> Function($$WorkingReactionsTableAnnotationComposer a) f,
  ) {
    final $$WorkingReactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingReactions,
      getReferencedColumn: (t) => t.reactorHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingReactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HandlesCanonicalTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $HandlesCanonicalTable,
          HandlesCanonicalData,
          $$HandlesCanonicalTableFilterComposer,
          $$HandlesCanonicalTableOrderingComposer,
          $$HandlesCanonicalTableAnnotationComposer,
          $$HandlesCanonicalTableCreateCompanionBuilder,
          $$HandlesCanonicalTableUpdateCompanionBuilder,
          (HandlesCanonicalData, $$HandlesCanonicalTableReferences),
          HandlesCanonicalData,
          PrefetchHooks Function({
            bool handleToParticipantRefs,
            bool handlesCanonicalToAliasRefs,
            bool workingChatsRefs,
            bool chatToHandleRefs,
            bool workingMessagesRefs,
            bool workingReactionsRefs,
          })
        > {
  $$HandlesCanonicalTableTableManager(
    _$WorkingDatabase db,
    $HandlesCanonicalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandlesCanonicalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HandlesCanonicalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HandlesCanonicalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawIdentifier = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> compoundIdentifier = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isBlacklisted = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> lastSeenUtc = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => HandlesCanonicalCompanion(
                id: id,
                rawIdentifier: rawIdentifier,
                displayName: displayName,
                compoundIdentifier: compoundIdentifier,
                service: service,
                isIgnored: isIgnored,
                isVisible: isVisible,
                isBlacklisted: isBlacklisted,
                country: country,
                lastSeenUtc: lastSeenUtc,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawIdentifier,
                required String displayName,
                required String compoundIdentifier,
                Value<String> service = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> isBlacklisted = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> lastSeenUtc = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => HandlesCanonicalCompanion.insert(
                id: id,
                rawIdentifier: rawIdentifier,
                displayName: displayName,
                compoundIdentifier: compoundIdentifier,
                service: service,
                isIgnored: isIgnored,
                isVisible: isVisible,
                isBlacklisted: isBlacklisted,
                country: country,
                lastSeenUtc: lastSeenUtc,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HandlesCanonicalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                handleToParticipantRefs = false,
                handlesCanonicalToAliasRefs = false,
                workingChatsRefs = false,
                chatToHandleRefs = false,
                workingMessagesRefs = false,
                workingReactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (handleToParticipantRefs) db.handleToParticipant,
                    if (handlesCanonicalToAliasRefs) db.handlesCanonicalToAlias,
                    if (workingChatsRefs) db.workingChats,
                    if (chatToHandleRefs) db.chatToHandle,
                    if (workingMessagesRefs) db.workingMessages,
                    if (workingReactionsRefs) db.workingReactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (handleToParticipantRefs)
                        await $_getPrefetchedData<
                          HandlesCanonicalData,
                          $HandlesCanonicalTable,
                          HandleToParticipantData
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesCanonicalTableReferences
                              ._handleToParticipantRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesCanonicalTableReferences(
                                db,
                                table,
                                p0,
                              ).handleToParticipantRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.handleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (handlesCanonicalToAliasRefs)
                        await $_getPrefetchedData<
                          HandlesCanonicalData,
                          $HandlesCanonicalTable,
                          HandlesCanonicalToAlia
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesCanonicalTableReferences
                              ._handlesCanonicalToAliasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesCanonicalTableReferences(
                                db,
                                table,
                                p0,
                              ).handlesCanonicalToAliasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.canonicalHandleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingChatsRefs)
                        await $_getPrefetchedData<
                          HandlesCanonicalData,
                          $HandlesCanonicalTable,
                          WorkingChat
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesCanonicalTableReferences
                              ._workingChatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesCanonicalTableReferences(
                                db,
                                table,
                                p0,
                              ).workingChatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lastSenderHandleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatToHandleRefs)
                        await $_getPrefetchedData<
                          HandlesCanonicalData,
                          $HandlesCanonicalTable,
                          ChatToHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesCanonicalTableReferences
                              ._chatToHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesCanonicalTableReferences(
                                db,
                                table,
                                p0,
                              ).chatToHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.handleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingMessagesRefs)
                        await $_getPrefetchedData<
                          HandlesCanonicalData,
                          $HandlesCanonicalTable,
                          WorkingMessage
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesCanonicalTableReferences
                              ._workingMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesCanonicalTableReferences(
                                db,
                                table,
                                p0,
                              ).workingMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.senderHandleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingReactionsRefs)
                        await $_getPrefetchedData<
                          HandlesCanonicalData,
                          $HandlesCanonicalTable,
                          WorkingReaction
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesCanonicalTableReferences
                              ._workingReactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesCanonicalTableReferences(
                                db,
                                table,
                                p0,
                              ).workingReactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reactorHandleId == item.id,
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

typedef $$HandlesCanonicalTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $HandlesCanonicalTable,
      HandlesCanonicalData,
      $$HandlesCanonicalTableFilterComposer,
      $$HandlesCanonicalTableOrderingComposer,
      $$HandlesCanonicalTableAnnotationComposer,
      $$HandlesCanonicalTableCreateCompanionBuilder,
      $$HandlesCanonicalTableUpdateCompanionBuilder,
      (HandlesCanonicalData, $$HandlesCanonicalTableReferences),
      HandlesCanonicalData,
      PrefetchHooks Function({
        bool handleToParticipantRefs,
        bool handlesCanonicalToAliasRefs,
        bool workingChatsRefs,
        bool chatToHandleRefs,
        bool workingMessagesRefs,
        bool workingReactionsRefs,
      })
    >;
typedef $$WorkingParticipantsTableCreateCompanionBuilder =
    WorkingParticipantsCompanion Function({
      Value<int> id,
      required String originalName,
      required String displayName,
      required String shortName,
      Value<String?> avatarRef,
      Value<String?> givenName,
      Value<String?> familyName,
      Value<String?> organization,
      Value<bool> isOrganization,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<int?> sourceRecordId,
    });
typedef $$WorkingParticipantsTableUpdateCompanionBuilder =
    WorkingParticipantsCompanion Function({
      Value<int> id,
      Value<String> originalName,
      Value<String> displayName,
      Value<String> shortName,
      Value<String?> avatarRef,
      Value<String?> givenName,
      Value<String?> familyName,
      Value<String?> organization,
      Value<bool> isOrganization,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<int?> sourceRecordId,
    });

final class $$WorkingParticipantsTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $WorkingParticipantsTable,
          WorkingParticipant
        > {
  $$WorkingParticipantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $HandleToParticipantTable,
    List<HandleToParticipantData>
  >
  _handleToParticipantRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.handleToParticipant,
        aliasName: $_aliasNameGenerator(
          db.workingParticipants.id,
          db.handleToParticipant.participantId,
        ),
      );

  $$HandleToParticipantTableProcessedTableManager get handleToParticipantRefs {
    final manager = $$HandleToParticipantTableTableManager(
      $_db,
      $_db.handleToParticipant,
    ).filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _handleToParticipantRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ContactMessageIndexTable,
    List<ContactMessageIndexData>
  >
  _contactMessageIndexRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactMessageIndex,
        aliasName: $_aliasNameGenerator(
          db.workingParticipants.id,
          db.contactMessageIndex.contactId,
        ),
      );

  $$ContactMessageIndexTableProcessedTableManager get contactMessageIndexRefs {
    final manager = $$ContactMessageIndexTableTableManager(
      $_db,
      $_db.contactMessageIndex,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contactMessageIndexRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkingParticipantsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingParticipantsTable> {
  $$WorkingParticipantsTableFilterComposer({
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

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarRef => $composableBuilder(
    column: $table.avatarRef,
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

  ColumnFilters<int> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> handleToParticipantRefs(
    Expression<bool> Function($$HandleToParticipantTableFilterComposer f) f,
  ) {
    final $$HandleToParticipantTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.handleToParticipant,
      getReferencedColumn: (t) => t.participantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandleToParticipantTableFilterComposer(
            $db: $db,
            $table: $db.handleToParticipant,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contactMessageIndexRefs(
    Expression<bool> Function($$ContactMessageIndexTableFilterComposer f) f,
  ) {
    final $$ContactMessageIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactMessageIndex,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactMessageIndexTableFilterComposer(
            $db: $db,
            $table: $db.contactMessageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingParticipantsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingParticipantsTable> {
  $$WorkingParticipantsTableOrderingComposer({
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

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarRef => $composableBuilder(
    column: $table.avatarRef,
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

  ColumnOrderings<int> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkingParticipantsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingParticipantsTable> {
  $$WorkingParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get avatarRef =>
      $composableBuilder(column: $table.avatarRef, builder: (column) => column);

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

  GeneratedColumn<int> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => column,
  );

  Expression<T> handleToParticipantRefs<T extends Object>(
    Expression<T> Function($$HandleToParticipantTableAnnotationComposer a) f,
  ) {
    final $$HandleToParticipantTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.handleToParticipant,
          getReferencedColumn: (t) => t.participantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HandleToParticipantTableAnnotationComposer(
                $db: $db,
                $table: $db.handleToParticipant,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> contactMessageIndexRefs<T extends Object>(
    Expression<T> Function($$ContactMessageIndexTableAnnotationComposer a) f,
  ) {
    final $$ContactMessageIndexTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactMessageIndex,
          getReferencedColumn: (t) => t.contactId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactMessageIndexTableAnnotationComposer(
                $db: $db,
                $table: $db.contactMessageIndex,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkingParticipantsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingParticipantsTable,
          WorkingParticipant,
          $$WorkingParticipantsTableFilterComposer,
          $$WorkingParticipantsTableOrderingComposer,
          $$WorkingParticipantsTableAnnotationComposer,
          $$WorkingParticipantsTableCreateCompanionBuilder,
          $$WorkingParticipantsTableUpdateCompanionBuilder,
          (WorkingParticipant, $$WorkingParticipantsTableReferences),
          WorkingParticipant,
          PrefetchHooks Function({
            bool handleToParticipantRefs,
            bool contactMessageIndexRefs,
          })
        > {
  $$WorkingParticipantsTableTableManager(
    _$WorkingDatabase db,
    $WorkingParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingParticipantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkingParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String?> avatarRef = const Value.absent(),
                Value<String?> givenName = const Value.absent(),
                Value<String?> familyName = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<bool> isOrganization = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<int?> sourceRecordId = const Value.absent(),
              }) => WorkingParticipantsCompanion(
                id: id,
                originalName: originalName,
                displayName: displayName,
                shortName: shortName,
                avatarRef: avatarRef,
                givenName: givenName,
                familyName: familyName,
                organization: organization,
                isOrganization: isOrganization,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                sourceRecordId: sourceRecordId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String originalName,
                required String displayName,
                required String shortName,
                Value<String?> avatarRef = const Value.absent(),
                Value<String?> givenName = const Value.absent(),
                Value<String?> familyName = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<bool> isOrganization = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<int?> sourceRecordId = const Value.absent(),
              }) => WorkingParticipantsCompanion.insert(
                id: id,
                originalName: originalName,
                displayName: displayName,
                shortName: shortName,
                avatarRef: avatarRef,
                givenName: givenName,
                familyName: familyName,
                organization: organization,
                isOrganization: isOrganization,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                sourceRecordId: sourceRecordId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                handleToParticipantRefs = false,
                contactMessageIndexRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (handleToParticipantRefs) db.handleToParticipant,
                    if (contactMessageIndexRefs) db.contactMessageIndex,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (handleToParticipantRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          HandleToParticipantData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._handleToParticipantRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).handleToParticipantRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (contactMessageIndexRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          ContactMessageIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._contactMessageIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactMessageIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contactId == item.id,
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

typedef $$WorkingParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingParticipantsTable,
      WorkingParticipant,
      $$WorkingParticipantsTableFilterComposer,
      $$WorkingParticipantsTableOrderingComposer,
      $$WorkingParticipantsTableAnnotationComposer,
      $$WorkingParticipantsTableCreateCompanionBuilder,
      $$WorkingParticipantsTableUpdateCompanionBuilder,
      (WorkingParticipant, $$WorkingParticipantsTableReferences),
      WorkingParticipant,
      PrefetchHooks Function({
        bool handleToParticipantRefs,
        bool contactMessageIndexRefs,
      })
    >;
typedef $$HandleToParticipantTableCreateCompanionBuilder =
    HandleToParticipantCompanion Function({
      Value<int> id,
      required int handleId,
      required int participantId,
      Value<double> confidence,
      Value<String> source,
    });
typedef $$HandleToParticipantTableUpdateCompanionBuilder =
    HandleToParticipantCompanion Function({
      Value<int> id,
      Value<int> handleId,
      Value<int> participantId,
      Value<double> confidence,
      Value<String> source,
    });

final class $$HandleToParticipantTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $HandleToParticipantTable,
          HandleToParticipantData
        > {
  $$HandleToParticipantTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HandlesCanonicalTable _handleIdTable(_$WorkingDatabase db) =>
      db.handlesCanonical.createAlias(
        $_aliasNameGenerator(
          db.handleToParticipant.handleId,
          db.handlesCanonical.id,
        ),
      );

  $$HandlesCanonicalTableProcessedTableManager get handleId {
    final $_column = $_itemColumn<int>('handle_id')!;

    final manager = $$HandlesCanonicalTableTableManager(
      $_db,
      $_db.handlesCanonical,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_handleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingParticipantsTable _participantIdTable(_$WorkingDatabase db) =>
      db.workingParticipants.createAlias(
        $_aliasNameGenerator(
          db.handleToParticipant.participantId,
          db.workingParticipants.id,
        ),
      );

  $$WorkingParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HandleToParticipantTableFilterComposer
    extends Composer<_$WorkingDatabase, $HandleToParticipantTable> {
  $$HandleToParticipantTableFilterComposer({
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

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$HandlesCanonicalTableFilterComposer get handleId {
    final $$HandlesCanonicalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableFilterComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableFilterComposer get participantId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HandleToParticipantTableOrderingComposer
    extends Composer<_$WorkingDatabase, $HandleToParticipantTable> {
  $$HandleToParticipantTableOrderingComposer({
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

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$HandlesCanonicalTableOrderingComposer get handleId {
    final $$HandlesCanonicalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableOrderingComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableOrderingComposer get participantId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.participantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HandleToParticipantTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $HandleToParticipantTable> {
  $$HandleToParticipantTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$HandlesCanonicalTableAnnotationComposer get handleId {
    final $$HandlesCanonicalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableAnnotationComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableAnnotationComposer get participantId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.participantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HandleToParticipantTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $HandleToParticipantTable,
          HandleToParticipantData,
          $$HandleToParticipantTableFilterComposer,
          $$HandleToParticipantTableOrderingComposer,
          $$HandleToParticipantTableAnnotationComposer,
          $$HandleToParticipantTableCreateCompanionBuilder,
          $$HandleToParticipantTableUpdateCompanionBuilder,
          (HandleToParticipantData, $$HandleToParticipantTableReferences),
          HandleToParticipantData,
          PrefetchHooks Function({bool handleId, bool participantId})
        > {
  $$HandleToParticipantTableTableManager(
    _$WorkingDatabase db,
    $HandleToParticipantTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandleToParticipantTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HandleToParticipantTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HandleToParticipantTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> handleId = const Value.absent(),
                Value<int> participantId = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => HandleToParticipantCompanion(
                id: id,
                handleId: handleId,
                participantId: participantId,
                confidence: confidence,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int handleId,
                required int participantId,
                Value<double> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => HandleToParticipantCompanion.insert(
                id: id,
                handleId: handleId,
                participantId: participantId,
                confidence: confidence,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HandleToParticipantTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({handleId = false, participantId = false}) {
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
                    if (handleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.handleId,
                                referencedTable:
                                    $$HandleToParticipantTableReferences
                                        ._handleIdTable(db),
                                referencedColumn:
                                    $$HandleToParticipantTableReferences
                                        ._handleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (participantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.participantId,
                                referencedTable:
                                    $$HandleToParticipantTableReferences
                                        ._participantIdTable(db),
                                referencedColumn:
                                    $$HandleToParticipantTableReferences
                                        ._participantIdTable(db)
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

typedef $$HandleToParticipantTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $HandleToParticipantTable,
      HandleToParticipantData,
      $$HandleToParticipantTableFilterComposer,
      $$HandleToParticipantTableOrderingComposer,
      $$HandleToParticipantTableAnnotationComposer,
      $$HandleToParticipantTableCreateCompanionBuilder,
      $$HandleToParticipantTableUpdateCompanionBuilder,
      (HandleToParticipantData, $$HandleToParticipantTableReferences),
      HandleToParticipantData,
      PrefetchHooks Function({bool handleId, bool participantId})
    >;
typedef $$HandlesCanonicalToAliasTableCreateCompanionBuilder =
    HandlesCanonicalToAliasCompanion Function({
      Value<int> sourceHandleId,
      required int canonicalHandleId,
      required String rawIdentifier,
      required String compoundIdentifier,
      required String normalizedIdentifier,
      Value<String> service,
      Value<String> aliasKind,
    });
typedef $$HandlesCanonicalToAliasTableUpdateCompanionBuilder =
    HandlesCanonicalToAliasCompanion Function({
      Value<int> sourceHandleId,
      Value<int> canonicalHandleId,
      Value<String> rawIdentifier,
      Value<String> compoundIdentifier,
      Value<String> normalizedIdentifier,
      Value<String> service,
      Value<String> aliasKind,
    });

final class $$HandlesCanonicalToAliasTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $HandlesCanonicalToAliasTable,
          HandlesCanonicalToAlia
        > {
  $$HandlesCanonicalToAliasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HandlesCanonicalTable _canonicalHandleIdTable(_$WorkingDatabase db) =>
      db.handlesCanonical.createAlias(
        $_aliasNameGenerator(
          db.handlesCanonicalToAlias.canonicalHandleId,
          db.handlesCanonical.id,
        ),
      );

  $$HandlesCanonicalTableProcessedTableManager get canonicalHandleId {
    final $_column = $_itemColumn<int>('canonical_handle_id')!;

    final manager = $$HandlesCanonicalTableTableManager(
      $_db,
      $_db.handlesCanonical,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_canonicalHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HandlesCanonicalToAliasTableFilterComposer
    extends Composer<_$WorkingDatabase, $HandlesCanonicalToAliasTable> {
  $$HandlesCanonicalToAliasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sourceHandleId => $composableBuilder(
    column: $table.sourceHandleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedIdentifier => $composableBuilder(
    column: $table.normalizedIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasKind => $composableBuilder(
    column: $table.aliasKind,
    builder: (column) => ColumnFilters(column),
  );

  $$HandlesCanonicalTableFilterComposer get canonicalHandleId {
    final $$HandlesCanonicalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.canonicalHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableFilterComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HandlesCanonicalToAliasTableOrderingComposer
    extends Composer<_$WorkingDatabase, $HandlesCanonicalToAliasTable> {
  $$HandlesCanonicalToAliasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sourceHandleId => $composableBuilder(
    column: $table.sourceHandleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedIdentifier => $composableBuilder(
    column: $table.normalizedIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasKind => $composableBuilder(
    column: $table.aliasKind,
    builder: (column) => ColumnOrderings(column),
  );

  $$HandlesCanonicalTableOrderingComposer get canonicalHandleId {
    final $$HandlesCanonicalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.canonicalHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableOrderingComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HandlesCanonicalToAliasTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $HandlesCanonicalToAliasTable> {
  $$HandlesCanonicalToAliasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sourceHandleId => $composableBuilder(
    column: $table.sourceHandleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawIdentifier => $composableBuilder(
    column: $table.rawIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compoundIdentifier => $composableBuilder(
    column: $table.compoundIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedIdentifier => $composableBuilder(
    column: $table.normalizedIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get aliasKind =>
      $composableBuilder(column: $table.aliasKind, builder: (column) => column);

  $$HandlesCanonicalTableAnnotationComposer get canonicalHandleId {
    final $$HandlesCanonicalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.canonicalHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableAnnotationComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HandlesCanonicalToAliasTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $HandlesCanonicalToAliasTable,
          HandlesCanonicalToAlia,
          $$HandlesCanonicalToAliasTableFilterComposer,
          $$HandlesCanonicalToAliasTableOrderingComposer,
          $$HandlesCanonicalToAliasTableAnnotationComposer,
          $$HandlesCanonicalToAliasTableCreateCompanionBuilder,
          $$HandlesCanonicalToAliasTableUpdateCompanionBuilder,
          (HandlesCanonicalToAlia, $$HandlesCanonicalToAliasTableReferences),
          HandlesCanonicalToAlia,
          PrefetchHooks Function({bool canonicalHandleId})
        > {
  $$HandlesCanonicalToAliasTableTableManager(
    _$WorkingDatabase db,
    $HandlesCanonicalToAliasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandlesCanonicalToAliasTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HandlesCanonicalToAliasTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HandlesCanonicalToAliasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sourceHandleId = const Value.absent(),
                Value<int> canonicalHandleId = const Value.absent(),
                Value<String> rawIdentifier = const Value.absent(),
                Value<String> compoundIdentifier = const Value.absent(),
                Value<String> normalizedIdentifier = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<String> aliasKind = const Value.absent(),
              }) => HandlesCanonicalToAliasCompanion(
                sourceHandleId: sourceHandleId,
                canonicalHandleId: canonicalHandleId,
                rawIdentifier: rawIdentifier,
                compoundIdentifier: compoundIdentifier,
                normalizedIdentifier: normalizedIdentifier,
                service: service,
                aliasKind: aliasKind,
              ),
          createCompanionCallback:
              ({
                Value<int> sourceHandleId = const Value.absent(),
                required int canonicalHandleId,
                required String rawIdentifier,
                required String compoundIdentifier,
                required String normalizedIdentifier,
                Value<String> service = const Value.absent(),
                Value<String> aliasKind = const Value.absent(),
              }) => HandlesCanonicalToAliasCompanion.insert(
                sourceHandleId: sourceHandleId,
                canonicalHandleId: canonicalHandleId,
                rawIdentifier: rawIdentifier,
                compoundIdentifier: compoundIdentifier,
                normalizedIdentifier: normalizedIdentifier,
                service: service,
                aliasKind: aliasKind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HandlesCanonicalToAliasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({canonicalHandleId = false}) {
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
                    if (canonicalHandleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.canonicalHandleId,
                                referencedTable:
                                    $$HandlesCanonicalToAliasTableReferences
                                        ._canonicalHandleIdTable(db),
                                referencedColumn:
                                    $$HandlesCanonicalToAliasTableReferences
                                        ._canonicalHandleIdTable(db)
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

typedef $$HandlesCanonicalToAliasTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $HandlesCanonicalToAliasTable,
      HandlesCanonicalToAlia,
      $$HandlesCanonicalToAliasTableFilterComposer,
      $$HandlesCanonicalToAliasTableOrderingComposer,
      $$HandlesCanonicalToAliasTableAnnotationComposer,
      $$HandlesCanonicalToAliasTableCreateCompanionBuilder,
      $$HandlesCanonicalToAliasTableUpdateCompanionBuilder,
      (HandlesCanonicalToAlia, $$HandlesCanonicalToAliasTableReferences),
      HandlesCanonicalToAlia,
      PrefetchHooks Function({bool canonicalHandleId})
    >;
typedef $$WorkingChatsTableCreateCompanionBuilder =
    WorkingChatsCompanion Function({
      Value<int> id,
      required String guid,
      Value<String> service,
      Value<bool> isGroup,
      Value<String?> lastMessageAtUtc,
      Value<int?> lastSenderHandleId,
      Value<String?> lastMessagePreview,
      Value<int> unreadCount,
      Value<bool> pinned,
      Value<bool> archived,
      Value<String?> mutedUntilUtc,
      Value<bool> favourite,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<bool> isIgnored,
    });
typedef $$WorkingChatsTableUpdateCompanionBuilder =
    WorkingChatsCompanion Function({
      Value<int> id,
      Value<String> guid,
      Value<String> service,
      Value<bool> isGroup,
      Value<String?> lastMessageAtUtc,
      Value<int?> lastSenderHandleId,
      Value<String?> lastMessagePreview,
      Value<int> unreadCount,
      Value<bool> pinned,
      Value<bool> archived,
      Value<String?> mutedUntilUtc,
      Value<bool> favourite,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
      Value<bool> isIgnored,
    });

final class $$WorkingChatsTableReferences
    extends BaseReferences<_$WorkingDatabase, $WorkingChatsTable, WorkingChat> {
  $$WorkingChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HandlesCanonicalTable _lastSenderHandleIdTable(
    _$WorkingDatabase db,
  ) => db.handlesCanonical.createAlias(
    $_aliasNameGenerator(
      db.workingChats.lastSenderHandleId,
      db.handlesCanonical.id,
    ),
  );

  $$HandlesCanonicalTableProcessedTableManager? get lastSenderHandleId {
    final $_column = $_itemColumn<int>('last_sender_handle_id');
    if ($_column == null) return null;
    final manager = $$HandlesCanonicalTableTableManager(
      $_db,
      $_db.handlesCanonical,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastSenderHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatToHandleTable, List<ChatToHandleData>>
  _chatToHandleRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.chatToHandle,
    aliasName: $_aliasNameGenerator(db.workingChats.id, db.chatToHandle.chatId),
  );

  $$ChatToHandleTableProcessedTableManager get chatToHandleRefs {
    final manager = $$ChatToHandleTableTableManager(
      $_db,
      $_db.chatToHandle,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatToHandleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingMessagesTable, List<WorkingMessage>>
  _workingMessagesRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingMessages,
        aliasName: $_aliasNameGenerator(
          db.workingChats.id,
          db.workingMessages.chatId,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager get workingMessagesRefs {
    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workingMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GlobalMessageIndexTable,
    List<GlobalMessageIndexData>
  >
  _globalMessageIndexRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.globalMessageIndex,
        aliasName: $_aliasNameGenerator(
          db.workingChats.id,
          db.globalMessageIndex.chatId,
        ),
      );

  $$GlobalMessageIndexTableProcessedTableManager get globalMessageIndexRefs {
    final manager = $$GlobalMessageIndexTableTableManager(
      $_db,
      $_db.globalMessageIndex,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _globalMessageIndexRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessageIndexTable, List<MessageIndexData>>
  _messageIndexRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.messageIndex,
    aliasName: $_aliasNameGenerator(db.workingChats.id, db.messageIndex.chatId),
  );

  $$MessageIndexTableProcessedTableManager get messageIndexRefs {
    final manager = $$MessageIndexTableTableManager(
      $_db,
      $_db.messageIndex,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messageIndexRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadStateTable, List<ReadStateData>>
  _readStateRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.readState,
    aliasName: $_aliasNameGenerator(db.workingChats.id, db.readState.chatId),
  );

  $$ReadStateTableProcessedTableManager get readStateRefs {
    final manager = $$ReadStateTableTableManager(
      $_db,
      $_db.readState,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkingChatsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingChatsTable> {
  $$WorkingChatsTableFilterComposer({
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

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageAtUtc => $composableBuilder(
    column: $table.lastMessageAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutedUntilUtc => $composableBuilder(
    column: $table.mutedUntilUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favourite => $composableBuilder(
    column: $table.favourite,
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

  $$HandlesCanonicalTableFilterComposer get lastSenderHandleId {
    final $$HandlesCanonicalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastSenderHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableFilterComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatToHandleRefs(
    Expression<bool> Function($$ChatToHandleTableFilterComposer f) f,
  ) {
    final $$ChatToHandleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatToHandle,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatToHandleTableFilterComposer(
            $db: $db,
            $table: $db.chatToHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingMessagesRefs(
    Expression<bool> Function($$WorkingMessagesTableFilterComposer f) f,
  ) {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> globalMessageIndexRefs(
    Expression<bool> Function($$GlobalMessageIndexTableFilterComposer f) f,
  ) {
    final $$GlobalMessageIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.globalMessageIndex,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GlobalMessageIndexTableFilterComposer(
            $db: $db,
            $table: $db.globalMessageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messageIndexRefs(
    Expression<bool> Function($$MessageIndexTableFilterComposer f) f,
  ) {
    final $$MessageIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageIndex,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageIndexTableFilterComposer(
            $db: $db,
            $table: $db.messageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readStateRefs(
    Expression<bool> Function($$ReadStateTableFilterComposer f) f,
  ) {
    final $$ReadStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readState,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadStateTableFilterComposer(
            $db: $db,
            $table: $db.readState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingChatsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingChatsTable> {
  $$WorkingChatsTableOrderingComposer({
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

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageAtUtc => $composableBuilder(
    column: $table.lastMessageAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutedUntilUtc => $composableBuilder(
    column: $table.mutedUntilUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favourite => $composableBuilder(
    column: $table.favourite,
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

  $$HandlesCanonicalTableOrderingComposer get lastSenderHandleId {
    final $$HandlesCanonicalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastSenderHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableOrderingComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingChatsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingChatsTable> {
  $$WorkingChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<String> get lastMessageAtUtc => $composableBuilder(
    column: $table.lastMessageAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get mutedUntilUtc => $composableBuilder(
    column: $table.mutedUntilUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favourite =>
      $composableBuilder(column: $table.favourite, builder: (column) => column);

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

  $$HandlesCanonicalTableAnnotationComposer get lastSenderHandleId {
    final $$HandlesCanonicalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastSenderHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableAnnotationComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatToHandleRefs<T extends Object>(
    Expression<T> Function($$ChatToHandleTableAnnotationComposer a) f,
  ) {
    final $$ChatToHandleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatToHandle,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatToHandleTableAnnotationComposer(
            $db: $db,
            $table: $db.chatToHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workingMessagesRefs<T extends Object>(
    Expression<T> Function($$WorkingMessagesTableAnnotationComposer a) f,
  ) {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> globalMessageIndexRefs<T extends Object>(
    Expression<T> Function($$GlobalMessageIndexTableAnnotationComposer a) f,
  ) {
    final $$GlobalMessageIndexTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.globalMessageIndex,
          getReferencedColumn: (t) => t.chatId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GlobalMessageIndexTableAnnotationComposer(
                $db: $db,
                $table: $db.globalMessageIndex,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> messageIndexRefs<T extends Object>(
    Expression<T> Function($$MessageIndexTableAnnotationComposer a) f,
  ) {
    final $$MessageIndexTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageIndex,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageIndexTableAnnotationComposer(
            $db: $db,
            $table: $db.messageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readStateRefs<T extends Object>(
    Expression<T> Function($$ReadStateTableAnnotationComposer a) f,
  ) {
    final $$ReadStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readState,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadStateTableAnnotationComposer(
            $db: $db,
            $table: $db.readState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingChatsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingChatsTable,
          WorkingChat,
          $$WorkingChatsTableFilterComposer,
          $$WorkingChatsTableOrderingComposer,
          $$WorkingChatsTableAnnotationComposer,
          $$WorkingChatsTableCreateCompanionBuilder,
          $$WorkingChatsTableUpdateCompanionBuilder,
          (WorkingChat, $$WorkingChatsTableReferences),
          WorkingChat,
          PrefetchHooks Function({
            bool lastSenderHandleId,
            bool chatToHandleRefs,
            bool workingMessagesRefs,
            bool globalMessageIndexRefs,
            bool messageIndexRefs,
            bool readStateRefs,
          })
        > {
  $$WorkingChatsTableTableManager(
    _$WorkingDatabase db,
    $WorkingChatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> lastMessageAtUtc = const Value.absent(),
                Value<int?> lastSenderHandleId = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> mutedUntilUtc = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
              }) => WorkingChatsCompanion(
                id: id,
                guid: guid,
                service: service,
                isGroup: isGroup,
                lastMessageAtUtc: lastMessageAtUtc,
                lastSenderHandleId: lastSenderHandleId,
                lastMessagePreview: lastMessagePreview,
                unreadCount: unreadCount,
                pinned: pinned,
                archived: archived,
                mutedUntilUtc: mutedUntilUtc,
                favourite: favourite,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isIgnored: isIgnored,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String guid,
                Value<String> service = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> lastMessageAtUtc = const Value.absent(),
                Value<int?> lastSenderHandleId = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> mutedUntilUtc = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
              }) => WorkingChatsCompanion.insert(
                id: id,
                guid: guid,
                service: service,
                isGroup: isGroup,
                lastMessageAtUtc: lastMessageAtUtc,
                lastSenderHandleId: lastSenderHandleId,
                lastMessagePreview: lastMessagePreview,
                unreadCount: unreadCount,
                pinned: pinned,
                archived: archived,
                mutedUntilUtc: mutedUntilUtc,
                favourite: favourite,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isIgnored: isIgnored,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingChatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                lastSenderHandleId = false,
                chatToHandleRefs = false,
                workingMessagesRefs = false,
                globalMessageIndexRefs = false,
                messageIndexRefs = false,
                readStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatToHandleRefs) db.chatToHandle,
                    if (workingMessagesRefs) db.workingMessages,
                    if (globalMessageIndexRefs) db.globalMessageIndex,
                    if (messageIndexRefs) db.messageIndex,
                    if (readStateRefs) db.readState,
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
                        if (lastSenderHandleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.lastSenderHandleId,
                                    referencedTable:
                                        $$WorkingChatsTableReferences
                                            ._lastSenderHandleIdTable(db),
                                    referencedColumn:
                                        $$WorkingChatsTableReferences
                                            ._lastSenderHandleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatToHandleRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          ChatToHandleData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._chatToHandleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatToHandleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingMessagesRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          WorkingMessage
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._workingMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).workingMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (globalMessageIndexRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          GlobalMessageIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._globalMessageIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).globalMessageIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messageIndexRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          MessageIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._messageIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).messageIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readStateRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          ReadStateData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._readStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).readStateRefs,
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

typedef $$WorkingChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingChatsTable,
      WorkingChat,
      $$WorkingChatsTableFilterComposer,
      $$WorkingChatsTableOrderingComposer,
      $$WorkingChatsTableAnnotationComposer,
      $$WorkingChatsTableCreateCompanionBuilder,
      $$WorkingChatsTableUpdateCompanionBuilder,
      (WorkingChat, $$WorkingChatsTableReferences),
      WorkingChat,
      PrefetchHooks Function({
        bool lastSenderHandleId,
        bool chatToHandleRefs,
        bool workingMessagesRefs,
        bool globalMessageIndexRefs,
        bool messageIndexRefs,
        bool readStateRefs,
      })
    >;
typedef $$ChatToHandleTableCreateCompanionBuilder =
    ChatToHandleCompanion Function({
      Value<int> id,
      required int chatId,
      required int handleId,
      Value<String> role,
      Value<String?> addedAtUtc,
      Value<bool> isIgnored,
    });
typedef $$ChatToHandleTableUpdateCompanionBuilder =
    ChatToHandleCompanion Function({
      Value<int> id,
      Value<int> chatId,
      Value<int> handleId,
      Value<String> role,
      Value<String?> addedAtUtc,
      Value<bool> isIgnored,
    });

final class $$ChatToHandleTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $ChatToHandleTable,
          ChatToHandleData
        > {
  $$ChatToHandleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.chatToHandle.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HandlesCanonicalTable _handleIdTable(_$WorkingDatabase db) =>
      db.handlesCanonical.createAlias(
        $_aliasNameGenerator(db.chatToHandle.handleId, db.handlesCanonical.id),
      );

  $$HandlesCanonicalTableProcessedTableManager get handleId {
    final $_column = $_itemColumn<int>('handle_id')!;

    final manager = $$HandlesCanonicalTableTableManager(
      $_db,
      $_db.handlesCanonical,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_handleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatToHandleTableFilterComposer
    extends Composer<_$WorkingDatabase, $ChatToHandleTable> {
  $$ChatToHandleTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesCanonicalTableFilterComposer get handleId {
    final $$HandlesCanonicalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableFilterComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatToHandleTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ChatToHandleTable> {
  $$ChatToHandleTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesCanonicalTableOrderingComposer get handleId {
    final $$HandlesCanonicalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableOrderingComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatToHandleTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ChatToHandleTable> {
  $$ChatToHandleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesCanonicalTableAnnotationComposer get handleId {
    final $$HandlesCanonicalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableAnnotationComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatToHandleTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ChatToHandleTable,
          ChatToHandleData,
          $$ChatToHandleTableFilterComposer,
          $$ChatToHandleTableOrderingComposer,
          $$ChatToHandleTableAnnotationComposer,
          $$ChatToHandleTableCreateCompanionBuilder,
          $$ChatToHandleTableUpdateCompanionBuilder,
          (ChatToHandleData, $$ChatToHandleTableReferences),
          ChatToHandleData,
          PrefetchHooks Function({bool chatId, bool handleId})
        > {
  $$ChatToHandleTableTableManager(
    _$WorkingDatabase db,
    $ChatToHandleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatToHandleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatToHandleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatToHandleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int> handleId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> addedAtUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
              }) => ChatToHandleCompanion(
                id: id,
                chatId: chatId,
                handleId: handleId,
                role: role,
                addedAtUtc: addedAtUtc,
                isIgnored: isIgnored,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chatId,
                required int handleId,
                Value<String> role = const Value.absent(),
                Value<String?> addedAtUtc = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
              }) => ChatToHandleCompanion.insert(
                id: id,
                chatId: chatId,
                handleId: handleId,
                role: role,
                addedAtUtc: addedAtUtc,
                isIgnored: isIgnored,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatToHandleTableReferences(db, table, e),
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
                                referencedTable: $$ChatToHandleTableReferences
                                    ._chatIdTable(db),
                                referencedColumn: $$ChatToHandleTableReferences
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
                                referencedTable: $$ChatToHandleTableReferences
                                    ._handleIdTable(db),
                                referencedColumn: $$ChatToHandleTableReferences
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

typedef $$ChatToHandleTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ChatToHandleTable,
      ChatToHandleData,
      $$ChatToHandleTableFilterComposer,
      $$ChatToHandleTableOrderingComposer,
      $$ChatToHandleTableAnnotationComposer,
      $$ChatToHandleTableCreateCompanionBuilder,
      $$ChatToHandleTableUpdateCompanionBuilder,
      (ChatToHandleData, $$ChatToHandleTableReferences),
      ChatToHandleData,
      PrefetchHooks Function({bool chatId, bool handleId})
    >;
typedef $$WorkingMessagesTableCreateCompanionBuilder =
    WorkingMessagesCompanion Function({
      Value<int> id,
      required String guid,
      required int chatId,
      Value<int?> senderHandleId,
      Value<bool> isFromMe,
      Value<String?> sentAtUtc,
      Value<String?> deliveredAtUtc,
      Value<String?> readAtUtc,
      Value<String> status,
      Value<String?> textContent,
      Value<String?> itemType,
      Value<bool> isSystemMessage,
      Value<int?> errorCode,
      Value<bool> hasAttachments,
      Value<String?> replyToGuid,
      Value<String?> associatedMessageGuid,
      Value<String?> threadOriginatorGuid,
      Value<String?> systemType,
      Value<bool> reactionCarrier,
      Value<String?> balloonBundleId,
      Value<String?> payloadJson,
      Value<String?> reactionSummaryJson,
      Value<bool> isStarred,
      Value<bool> isDeletedLocal,
      Value<String?> updatedAtUtc,
      Value<int?> batchId,
    });
typedef $$WorkingMessagesTableUpdateCompanionBuilder =
    WorkingMessagesCompanion Function({
      Value<int> id,
      Value<String> guid,
      Value<int> chatId,
      Value<int?> senderHandleId,
      Value<bool> isFromMe,
      Value<String?> sentAtUtc,
      Value<String?> deliveredAtUtc,
      Value<String?> readAtUtc,
      Value<String> status,
      Value<String?> textContent,
      Value<String?> itemType,
      Value<bool> isSystemMessage,
      Value<int?> errorCode,
      Value<bool> hasAttachments,
      Value<String?> replyToGuid,
      Value<String?> associatedMessageGuid,
      Value<String?> threadOriginatorGuid,
      Value<String?> systemType,
      Value<bool> reactionCarrier,
      Value<String?> balloonBundleId,
      Value<String?> payloadJson,
      Value<String?> reactionSummaryJson,
      Value<bool> isStarred,
      Value<bool> isDeletedLocal,
      Value<String?> updatedAtUtc,
      Value<int?> batchId,
    });

final class $$WorkingMessagesTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $WorkingMessagesTable,
          WorkingMessage
        > {
  $$WorkingMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.workingMessages.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HandlesCanonicalTable _senderHandleIdTable(_$WorkingDatabase db) =>
      db.handlesCanonical.createAlias(
        $_aliasNameGenerator(
          db.workingMessages.senderHandleId,
          db.handlesCanonical.id,
        ),
      );

  $$HandlesCanonicalTableProcessedTableManager? get senderHandleId {
    final $_column = $_itemColumn<int>('sender_handle_id');
    if ($_column == null) return null;
    final manager = $$HandlesCanonicalTableTableManager(
      $_db,
      $_db.handlesCanonical,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_senderHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $GlobalMessageIndexTable,
    List<GlobalMessageIndexData>
  >
  _globalMessageIndexRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.globalMessageIndex,
        aliasName: $_aliasNameGenerator(
          db.workingMessages.id,
          db.globalMessageIndex.messageId,
        ),
      );

  $$GlobalMessageIndexTableProcessedTableManager get globalMessageIndexRefs {
    final manager = $$GlobalMessageIndexTableTableManager(
      $_db,
      $_db.globalMessageIndex,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _globalMessageIndexRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessageIndexTable, List<MessageIndexData>>
  _messageIndexRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.messageIndex,
    aliasName: $_aliasNameGenerator(
      db.workingMessages.id,
      db.messageIndex.messageId,
    ),
  );

  $$MessageIndexTableProcessedTableManager get messageIndexRefs {
    final manager = $$MessageIndexTableTableManager(
      $_db,
      $_db.messageIndex,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messageIndexRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ContactMessageIndexTable,
    List<ContactMessageIndexData>
  >
  _contactMessageIndexRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactMessageIndex,
        aliasName: $_aliasNameGenerator(
          db.workingMessages.id,
          db.contactMessageIndex.messageId,
        ),
      );

  $$ContactMessageIndexTableProcessedTableManager get contactMessageIndexRefs {
    final manager = $$ContactMessageIndexTableTableManager(
      $_db,
      $_db.contactMessageIndex,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contactMessageIndexRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingReactionsTable, List<WorkingReaction>>
  _workingReactionsRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingReactions,
        aliasName: $_aliasNameGenerator(
          db.workingMessages.id,
          db.workingReactions.carrierMessageId,
        ),
      );

  $$WorkingReactionsTableProcessedTableManager get workingReactionsRefs {
    final manager = $$WorkingReactionsTableTableManager(
      $_db,
      $_db.workingReactions,
    ).filter((f) => f.carrierMessageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workingReactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkingMessagesTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingMessagesTable> {
  $$WorkingMessagesTableFilterComposer({
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

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readAtUtc => $composableBuilder(
    column: $table.readAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyToGuid => $composableBuilder(
    column: $table.replyToGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associatedMessageGuid => $composableBuilder(
    column: $table.associatedMessageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadOriginatorGuid => $composableBuilder(
    column: $table.threadOriginatorGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reactionCarrier => $composableBuilder(
    column: $table.reactionCarrier,
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

  ColumnFilters<String> get reactionSummaryJson => $composableBuilder(
    column: $table.reactionSummaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeletedLocal => $composableBuilder(
    column: $table.isDeletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesCanonicalTableFilterComposer get senderHandleId {
    final $$HandlesCanonicalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableFilterComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> globalMessageIndexRefs(
    Expression<bool> Function($$GlobalMessageIndexTableFilterComposer f) f,
  ) {
    final $$GlobalMessageIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.globalMessageIndex,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GlobalMessageIndexTableFilterComposer(
            $db: $db,
            $table: $db.globalMessageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messageIndexRefs(
    Expression<bool> Function($$MessageIndexTableFilterComposer f) f,
  ) {
    final $$MessageIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageIndex,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageIndexTableFilterComposer(
            $db: $db,
            $table: $db.messageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contactMessageIndexRefs(
    Expression<bool> Function($$ContactMessageIndexTableFilterComposer f) f,
  ) {
    final $$ContactMessageIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactMessageIndex,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactMessageIndexTableFilterComposer(
            $db: $db,
            $table: $db.contactMessageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingReactionsRefs(
    Expression<bool> Function($$WorkingReactionsTableFilterComposer f) f,
  ) {
    final $$WorkingReactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingReactions,
      getReferencedColumn: (t) => t.carrierMessageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingReactionsTableFilterComposer(
            $db: $db,
            $table: $db.workingReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingMessagesTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingMessagesTable> {
  $$WorkingMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readAtUtc => $composableBuilder(
    column: $table.readAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyToGuid => $composableBuilder(
    column: $table.replyToGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associatedMessageGuid => $composableBuilder(
    column: $table.associatedMessageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadOriginatorGuid => $composableBuilder(
    column: $table.threadOriginatorGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reactionCarrier => $composableBuilder(
    column: $table.reactionCarrier,
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

  ColumnOrderings<String> get reactionSummaryJson => $composableBuilder(
    column: $table.reactionSummaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeletedLocal => $composableBuilder(
    column: $table.isDeletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesCanonicalTableOrderingComposer get senderHandleId {
    final $$HandlesCanonicalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableOrderingComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingMessagesTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingMessagesTable> {
  $$WorkingMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<bool> get isFromMe =>
      $composableBuilder(column: $table.isFromMe, builder: (column) => column);

  GeneratedColumn<String> get sentAtUtc =>
      $composableBuilder(column: $table.sentAtUtc, builder: (column) => column);

  GeneratedColumn<String> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readAtUtc =>
      $composableBuilder(column: $table.readAtUtc, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<bool> get isSystemMessage => $composableBuilder(
    column: $table.isSystemMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyToGuid => $composableBuilder(
    column: $table.replyToGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get associatedMessageGuid => $composableBuilder(
    column: $table.associatedMessageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get threadOriginatorGuid => $composableBuilder(
    column: $table.threadOriginatorGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reactionCarrier => $composableBuilder(
    column: $table.reactionCarrier,
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

  GeneratedColumn<String> get reactionSummaryJson => $composableBuilder(
    column: $table.reactionSummaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isDeletedLocal => $composableBuilder(
    column: $table.isDeletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesCanonicalTableAnnotationComposer get senderHandleId {
    final $$HandlesCanonicalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableAnnotationComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> globalMessageIndexRefs<T extends Object>(
    Expression<T> Function($$GlobalMessageIndexTableAnnotationComposer a) f,
  ) {
    final $$GlobalMessageIndexTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.globalMessageIndex,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GlobalMessageIndexTableAnnotationComposer(
                $db: $db,
                $table: $db.globalMessageIndex,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> messageIndexRefs<T extends Object>(
    Expression<T> Function($$MessageIndexTableAnnotationComposer a) f,
  ) {
    final $$MessageIndexTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageIndex,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageIndexTableAnnotationComposer(
            $db: $db,
            $table: $db.messageIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> contactMessageIndexRefs<T extends Object>(
    Expression<T> Function($$ContactMessageIndexTableAnnotationComposer a) f,
  ) {
    final $$ContactMessageIndexTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactMessageIndex,
          getReferencedColumn: (t) => t.messageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactMessageIndexTableAnnotationComposer(
                $db: $db,
                $table: $db.contactMessageIndex,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workingReactionsRefs<T extends Object>(
    Expression<T> Function($$WorkingReactionsTableAnnotationComposer a) f,
  ) {
    final $$WorkingReactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingReactions,
      getReferencedColumn: (t) => t.carrierMessageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingReactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingMessagesTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingMessagesTable,
          WorkingMessage,
          $$WorkingMessagesTableFilterComposer,
          $$WorkingMessagesTableOrderingComposer,
          $$WorkingMessagesTableAnnotationComposer,
          $$WorkingMessagesTableCreateCompanionBuilder,
          $$WorkingMessagesTableUpdateCompanionBuilder,
          (WorkingMessage, $$WorkingMessagesTableReferences),
          WorkingMessage,
          PrefetchHooks Function({
            bool chatId,
            bool senderHandleId,
            bool globalMessageIndexRefs,
            bool messageIndexRefs,
            bool contactMessageIndexRefs,
            bool workingReactionsRefs,
          })
        > {
  $$WorkingMessagesTableTableManager(
    _$WorkingDatabase db,
    $WorkingMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int?> senderHandleId = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String?> deliveredAtUtc = const Value.absent(),
                Value<String?> readAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> itemType = const Value.absent(),
                Value<bool> isSystemMessage = const Value.absent(),
                Value<int?> errorCode = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<String?> replyToGuid = const Value.absent(),
                Value<String?> associatedMessageGuid = const Value.absent(),
                Value<String?> threadOriginatorGuid = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
                Value<bool> reactionCarrier = const Value.absent(),
                Value<String?> balloonBundleId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String?> reactionSummaryJson = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeletedLocal = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => WorkingMessagesCompanion(
                id: id,
                guid: guid,
                chatId: chatId,
                senderHandleId: senderHandleId,
                isFromMe: isFromMe,
                sentAtUtc: sentAtUtc,
                deliveredAtUtc: deliveredAtUtc,
                readAtUtc: readAtUtc,
                status: status,
                textContent: textContent,
                itemType: itemType,
                isSystemMessage: isSystemMessage,
                errorCode: errorCode,
                hasAttachments: hasAttachments,
                replyToGuid: replyToGuid,
                associatedMessageGuid: associatedMessageGuid,
                threadOriginatorGuid: threadOriginatorGuid,
                systemType: systemType,
                reactionCarrier: reactionCarrier,
                balloonBundleId: balloonBundleId,
                payloadJson: payloadJson,
                reactionSummaryJson: reactionSummaryJson,
                isStarred: isStarred,
                isDeletedLocal: isDeletedLocal,
                updatedAtUtc: updatedAtUtc,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String guid,
                required int chatId,
                Value<int?> senderHandleId = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String?> deliveredAtUtc = const Value.absent(),
                Value<String?> readAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> itemType = const Value.absent(),
                Value<bool> isSystemMessage = const Value.absent(),
                Value<int?> errorCode = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<String?> replyToGuid = const Value.absent(),
                Value<String?> associatedMessageGuid = const Value.absent(),
                Value<String?> threadOriginatorGuid = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
                Value<bool> reactionCarrier = const Value.absent(),
                Value<String?> balloonBundleId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String?> reactionSummaryJson = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeletedLocal = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => WorkingMessagesCompanion.insert(
                id: id,
                guid: guid,
                chatId: chatId,
                senderHandleId: senderHandleId,
                isFromMe: isFromMe,
                sentAtUtc: sentAtUtc,
                deliveredAtUtc: deliveredAtUtc,
                readAtUtc: readAtUtc,
                status: status,
                textContent: textContent,
                itemType: itemType,
                isSystemMessage: isSystemMessage,
                errorCode: errorCode,
                hasAttachments: hasAttachments,
                replyToGuid: replyToGuid,
                associatedMessageGuid: associatedMessageGuid,
                threadOriginatorGuid: threadOriginatorGuid,
                systemType: systemType,
                reactionCarrier: reactionCarrier,
                balloonBundleId: balloonBundleId,
                payloadJson: payloadJson,
                reactionSummaryJson: reactionSummaryJson,
                isStarred: isStarred,
                isDeletedLocal: isDeletedLocal,
                updatedAtUtc: updatedAtUtc,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                chatId = false,
                senderHandleId = false,
                globalMessageIndexRefs = false,
                messageIndexRefs = false,
                contactMessageIndexRefs = false,
                workingReactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (globalMessageIndexRefs) db.globalMessageIndex,
                    if (messageIndexRefs) db.messageIndex,
                    if (contactMessageIndexRefs) db.contactMessageIndex,
                    if (workingReactionsRefs) db.workingReactions,
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
                                        $$WorkingMessagesTableReferences
                                            ._chatIdTable(db),
                                    referencedColumn:
                                        $$WorkingMessagesTableReferences
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
                                        $$WorkingMessagesTableReferences
                                            ._senderHandleIdTable(db),
                                    referencedColumn:
                                        $$WorkingMessagesTableReferences
                                            ._senderHandleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (globalMessageIndexRefs)
                        await $_getPrefetchedData<
                          WorkingMessage,
                          $WorkingMessagesTable,
                          GlobalMessageIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingMessagesTableReferences
                              ._globalMessageIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).globalMessageIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messageIndexRefs)
                        await $_getPrefetchedData<
                          WorkingMessage,
                          $WorkingMessagesTable,
                          MessageIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingMessagesTableReferences
                              ._messageIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).messageIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (contactMessageIndexRefs)
                        await $_getPrefetchedData<
                          WorkingMessage,
                          $WorkingMessagesTable,
                          ContactMessageIndexData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingMessagesTableReferences
                              ._contactMessageIndexRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).contactMessageIndexRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingReactionsRefs)
                        await $_getPrefetchedData<
                          WorkingMessage,
                          $WorkingMessagesTable,
                          WorkingReaction
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingMessagesTableReferences
                              ._workingReactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingMessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).workingReactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carrierMessageId == item.id,
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

typedef $$WorkingMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingMessagesTable,
      WorkingMessage,
      $$WorkingMessagesTableFilterComposer,
      $$WorkingMessagesTableOrderingComposer,
      $$WorkingMessagesTableAnnotationComposer,
      $$WorkingMessagesTableCreateCompanionBuilder,
      $$WorkingMessagesTableUpdateCompanionBuilder,
      (WorkingMessage, $$WorkingMessagesTableReferences),
      WorkingMessage,
      PrefetchHooks Function({
        bool chatId,
        bool senderHandleId,
        bool globalMessageIndexRefs,
        bool messageIndexRefs,
        bool contactMessageIndexRefs,
        bool workingReactionsRefs,
      })
    >;
typedef $$GlobalMessageIndexTableCreateCompanionBuilder =
    GlobalMessageIndexCompanion Function({
      Value<int> ordinal,
      required int messageId,
      required int chatId,
      Value<String?> sentAtUtc,
      required String monthKey,
    });
typedef $$GlobalMessageIndexTableUpdateCompanionBuilder =
    GlobalMessageIndexCompanion Function({
      Value<int> ordinal,
      Value<int> messageId,
      Value<int> chatId,
      Value<String?> sentAtUtc,
      Value<String> monthKey,
    });

final class $$GlobalMessageIndexTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $GlobalMessageIndexTable,
          GlobalMessageIndexData
        > {
  $$GlobalMessageIndexTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingMessagesTable _messageIdTable(_$WorkingDatabase db) =>
      db.workingMessages.createAlias(
        $_aliasNameGenerator(
          db.globalMessageIndex.messageId,
          db.workingMessages.id,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.globalMessageIndex.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GlobalMessageIndexTableFilterComposer
    extends Composer<_$WorkingDatabase, $GlobalMessageIndexTable> {
  $$GlobalMessageIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingMessagesTableFilterComposer get messageId {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GlobalMessageIndexTableOrderingComposer
    extends Composer<_$WorkingDatabase, $GlobalMessageIndexTable> {
  $$GlobalMessageIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingMessagesTableOrderingComposer get messageId {
    final $$WorkingMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GlobalMessageIndexTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $GlobalMessageIndexTable> {
  $$GlobalMessageIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get sentAtUtc =>
      $composableBuilder(column: $table.sentAtUtc, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  $$WorkingMessagesTableAnnotationComposer get messageId {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GlobalMessageIndexTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $GlobalMessageIndexTable,
          GlobalMessageIndexData,
          $$GlobalMessageIndexTableFilterComposer,
          $$GlobalMessageIndexTableOrderingComposer,
          $$GlobalMessageIndexTableAnnotationComposer,
          $$GlobalMessageIndexTableCreateCompanionBuilder,
          $$GlobalMessageIndexTableUpdateCompanionBuilder,
          (GlobalMessageIndexData, $$GlobalMessageIndexTableReferences),
          GlobalMessageIndexData,
          PrefetchHooks Function({bool messageId, bool chatId})
        > {
  $$GlobalMessageIndexTableTableManager(
    _$WorkingDatabase db,
    $GlobalMessageIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlobalMessageIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlobalMessageIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlobalMessageIndexTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> ordinal = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
              }) => GlobalMessageIndexCompanion(
                ordinal: ordinal,
                messageId: messageId,
                chatId: chatId,
                sentAtUtc: sentAtUtc,
                monthKey: monthKey,
              ),
          createCompanionCallback:
              ({
                Value<int> ordinal = const Value.absent(),
                required int messageId,
                required int chatId,
                Value<String?> sentAtUtc = const Value.absent(),
                required String monthKey,
              }) => GlobalMessageIndexCompanion.insert(
                ordinal: ordinal,
                messageId: messageId,
                chatId: chatId,
                sentAtUtc: sentAtUtc,
                monthKey: monthKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GlobalMessageIndexTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false, chatId = false}) {
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
                                    $$GlobalMessageIndexTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$GlobalMessageIndexTableReferences
                                        ._messageIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (chatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatId,
                                referencedTable:
                                    $$GlobalMessageIndexTableReferences
                                        ._chatIdTable(db),
                                referencedColumn:
                                    $$GlobalMessageIndexTableReferences
                                        ._chatIdTable(db)
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

typedef $$GlobalMessageIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $GlobalMessageIndexTable,
      GlobalMessageIndexData,
      $$GlobalMessageIndexTableFilterComposer,
      $$GlobalMessageIndexTableOrderingComposer,
      $$GlobalMessageIndexTableAnnotationComposer,
      $$GlobalMessageIndexTableCreateCompanionBuilder,
      $$GlobalMessageIndexTableUpdateCompanionBuilder,
      (GlobalMessageIndexData, $$GlobalMessageIndexTableReferences),
      GlobalMessageIndexData,
      PrefetchHooks Function({bool messageId, bool chatId})
    >;
typedef $$MessageIndexTableCreateCompanionBuilder =
    MessageIndexCompanion Function({
      required int chatId,
      required int ordinal,
      required int messageId,
      Value<String?> sentAtUtc,
      required String monthKey,
      Value<int> rowid,
    });
typedef $$MessageIndexTableUpdateCompanionBuilder =
    MessageIndexCompanion Function({
      Value<int> chatId,
      Value<int> ordinal,
      Value<int> messageId,
      Value<String?> sentAtUtc,
      Value<String> monthKey,
      Value<int> rowid,
    });

final class $$MessageIndexTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $MessageIndexTable,
          MessageIndexData
        > {
  $$MessageIndexTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.messageIndex.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingMessagesTable _messageIdTable(_$WorkingDatabase db) =>
      db.workingMessages.createAlias(
        $_aliasNameGenerator(db.messageIndex.messageId, db.workingMessages.id),
      );

  $$WorkingMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessageIndexTableFilterComposer
    extends Composer<_$WorkingDatabase, $MessageIndexTable> {
  $$MessageIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableFilterComposer get messageId {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageIndexTableOrderingComposer
    extends Composer<_$WorkingDatabase, $MessageIndexTable> {
  $$MessageIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableOrderingComposer get messageId {
    final $$WorkingMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageIndexTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $MessageIndexTable> {
  $$MessageIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get sentAtUtc =>
      $composableBuilder(column: $table.sentAtUtc, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableAnnotationComposer get messageId {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageIndexTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $MessageIndexTable,
          MessageIndexData,
          $$MessageIndexTableFilterComposer,
          $$MessageIndexTableOrderingComposer,
          $$MessageIndexTableAnnotationComposer,
          $$MessageIndexTableCreateCompanionBuilder,
          $$MessageIndexTableUpdateCompanionBuilder,
          (MessageIndexData, $$MessageIndexTableReferences),
          MessageIndexData,
          PrefetchHooks Function({bool chatId, bool messageId})
        > {
  $$MessageIndexTableTableManager(
    _$WorkingDatabase db,
    $MessageIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageIndexTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageIndexCompanion(
                chatId: chatId,
                ordinal: ordinal,
                messageId: messageId,
                sentAtUtc: sentAtUtc,
                monthKey: monthKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chatId,
                required int ordinal,
                required int messageId,
                Value<String?> sentAtUtc = const Value.absent(),
                required String monthKey,
                Value<int> rowid = const Value.absent(),
              }) => MessageIndexCompanion.insert(
                chatId: chatId,
                ordinal: ordinal,
                messageId: messageId,
                sentAtUtc: sentAtUtc,
                monthKey: monthKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessageIndexTableReferences(db, table, e),
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
                                referencedTable: $$MessageIndexTableReferences
                                    ._chatIdTable(db),
                                referencedColumn: $$MessageIndexTableReferences
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
                                referencedTable: $$MessageIndexTableReferences
                                    ._messageIdTable(db),
                                referencedColumn: $$MessageIndexTableReferences
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

typedef $$MessageIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $MessageIndexTable,
      MessageIndexData,
      $$MessageIndexTableFilterComposer,
      $$MessageIndexTableOrderingComposer,
      $$MessageIndexTableAnnotationComposer,
      $$MessageIndexTableCreateCompanionBuilder,
      $$MessageIndexTableUpdateCompanionBuilder,
      (MessageIndexData, $$MessageIndexTableReferences),
      MessageIndexData,
      PrefetchHooks Function({bool chatId, bool messageId})
    >;
typedef $$ContactMessageIndexTableCreateCompanionBuilder =
    ContactMessageIndexCompanion Function({
      required int contactId,
      required int ordinal,
      required int messageId,
      Value<String?> sentAtUtc,
      required String monthKey,
      Value<int> rowid,
    });
typedef $$ContactMessageIndexTableUpdateCompanionBuilder =
    ContactMessageIndexCompanion Function({
      Value<int> contactId,
      Value<int> ordinal,
      Value<int> messageId,
      Value<String?> sentAtUtc,
      Value<String> monthKey,
      Value<int> rowid,
    });

final class $$ContactMessageIndexTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $ContactMessageIndexTable,
          ContactMessageIndexData
        > {
  $$ContactMessageIndexTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingParticipantsTable _contactIdTable(_$WorkingDatabase db) =>
      db.workingParticipants.createAlias(
        $_aliasNameGenerator(
          db.contactMessageIndex.contactId,
          db.workingParticipants.id,
        ),
      );

  $$WorkingParticipantsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<int>('contact_id')!;

    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingMessagesTable _messageIdTable(_$WorkingDatabase db) =>
      db.workingMessages.createAlias(
        $_aliasNameGenerator(
          db.contactMessageIndex.messageId,
          db.workingMessages.id,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactMessageIndexTableFilterComposer
    extends Composer<_$WorkingDatabase, $ContactMessageIndexTable> {
  $$ContactMessageIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingParticipantsTableFilterComposer get contactId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableFilterComposer get messageId {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactMessageIndexTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ContactMessageIndexTable> {
  $$ContactMessageIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingParticipantsTableOrderingComposer get contactId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.contactId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkingMessagesTableOrderingComposer get messageId {
    final $$WorkingMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactMessageIndexTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ContactMessageIndexTable> {
  $$ContactMessageIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get sentAtUtc =>
      $composableBuilder(column: $table.sentAtUtc, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  $$WorkingParticipantsTableAnnotationComposer get contactId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.contactId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkingMessagesTableAnnotationComposer get messageId {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactMessageIndexTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ContactMessageIndexTable,
          ContactMessageIndexData,
          $$ContactMessageIndexTableFilterComposer,
          $$ContactMessageIndexTableOrderingComposer,
          $$ContactMessageIndexTableAnnotationComposer,
          $$ContactMessageIndexTableCreateCompanionBuilder,
          $$ContactMessageIndexTableUpdateCompanionBuilder,
          (ContactMessageIndexData, $$ContactMessageIndexTableReferences),
          ContactMessageIndexData,
          PrefetchHooks Function({bool contactId, bool messageId})
        > {
  $$ContactMessageIndexTableTableManager(
    _$WorkingDatabase db,
    $ContactMessageIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactMessageIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactMessageIndexTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContactMessageIndexTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> contactId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactMessageIndexCompanion(
                contactId: contactId,
                ordinal: ordinal,
                messageId: messageId,
                sentAtUtc: sentAtUtc,
                monthKey: monthKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int contactId,
                required int ordinal,
                required int messageId,
                Value<String?> sentAtUtc = const Value.absent(),
                required String monthKey,
                Value<int> rowid = const Value.absent(),
              }) => ContactMessageIndexCompanion.insert(
                contactId: contactId,
                ordinal: ordinal,
                messageId: messageId,
                sentAtUtc: sentAtUtc,
                monthKey: monthKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactMessageIndexTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false, messageId = false}) {
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
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable:
                                    $$ContactMessageIndexTableReferences
                                        ._contactIdTable(db),
                                referencedColumn:
                                    $$ContactMessageIndexTableReferences
                                        ._contactIdTable(db)
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
                                    $$ContactMessageIndexTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$ContactMessageIndexTableReferences
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

typedef $$ContactMessageIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ContactMessageIndexTable,
      ContactMessageIndexData,
      $$ContactMessageIndexTableFilterComposer,
      $$ContactMessageIndexTableOrderingComposer,
      $$ContactMessageIndexTableAnnotationComposer,
      $$ContactMessageIndexTableCreateCompanionBuilder,
      $$ContactMessageIndexTableUpdateCompanionBuilder,
      (ContactMessageIndexData, $$ContactMessageIndexTableReferences),
      ContactMessageIndexData,
      PrefetchHooks Function({bool contactId, bool messageId})
    >;
typedef $$WorkingAttachmentsTableCreateCompanionBuilder =
    WorkingAttachmentsCompanion Function({
      Value<int> id,
      required String messageGuid,
      Value<int?> importAttachmentId,
      Value<String?> localPath,
      Value<String?> mimeType,
      Value<String?> uti,
      Value<String?> transferName,
      Value<int?> sizeBytes,
      Value<bool> isSticker,
      Value<String?> thumbPath,
      Value<String?> createdAtUtc,
      Value<bool> isOutgoing,
      Value<String?> sha256Hex,
      Value<int?> batchId,
    });
typedef $$WorkingAttachmentsTableUpdateCompanionBuilder =
    WorkingAttachmentsCompanion Function({
      Value<int> id,
      Value<String> messageGuid,
      Value<int?> importAttachmentId,
      Value<String?> localPath,
      Value<String?> mimeType,
      Value<String?> uti,
      Value<String?> transferName,
      Value<int?> sizeBytes,
      Value<bool> isSticker,
      Value<String?> thumbPath,
      Value<String?> createdAtUtc,
      Value<bool> isOutgoing,
      Value<String?> sha256Hex,
      Value<int?> batchId,
    });

class $$WorkingAttachmentsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingAttachmentsTable> {
  $$WorkingAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importAttachmentId => $composableBuilder(
    column: $table.importAttachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uti => $composableBuilder(
    column: $table.uti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSticker => $composableBuilder(
    column: $table.isSticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkingAttachmentsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingAttachmentsTable> {
  $$WorkingAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importAttachmentId => $composableBuilder(
    column: $table.importAttachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uti => $composableBuilder(
    column: $table.uti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSticker => $composableBuilder(
    column: $table.isSticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256Hex => $composableBuilder(
    column: $table.sha256Hex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkingAttachmentsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingAttachmentsTable> {
  $$WorkingAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importAttachmentId => $composableBuilder(
    column: $table.importAttachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get uti =>
      $composableBuilder(column: $table.uti, builder: (column) => column);

  GeneratedColumn<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get isSticker =>
      $composableBuilder(column: $table.isSticker, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256Hex =>
      $composableBuilder(column: $table.sha256Hex, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);
}

class $$WorkingAttachmentsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingAttachmentsTable,
          WorkingAttachment,
          $$WorkingAttachmentsTableFilterComposer,
          $$WorkingAttachmentsTableOrderingComposer,
          $$WorkingAttachmentsTableAnnotationComposer,
          $$WorkingAttachmentsTableCreateCompanionBuilder,
          $$WorkingAttachmentsTableUpdateCompanionBuilder,
          (
            WorkingAttachment,
            BaseReferences<
              _$WorkingDatabase,
              $WorkingAttachmentsTable,
              WorkingAttachment
            >,
          ),
          WorkingAttachment,
          PrefetchHooks Function()
        > {
  $$WorkingAttachmentsTableTableManager(
    _$WorkingDatabase db,
    $WorkingAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageGuid = const Value.absent(),
                Value<int?> importAttachmentId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String?> uti = const Value.absent(),
                Value<String?> transferName = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<bool> isSticker = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<bool> isOutgoing = const Value.absent(),
                Value<String?> sha256Hex = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => WorkingAttachmentsCompanion(
                id: id,
                messageGuid: messageGuid,
                importAttachmentId: importAttachmentId,
                localPath: localPath,
                mimeType: mimeType,
                uti: uti,
                transferName: transferName,
                sizeBytes: sizeBytes,
                isSticker: isSticker,
                thumbPath: thumbPath,
                createdAtUtc: createdAtUtc,
                isOutgoing: isOutgoing,
                sha256Hex: sha256Hex,
                batchId: batchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageGuid,
                Value<int?> importAttachmentId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String?> uti = const Value.absent(),
                Value<String?> transferName = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<bool> isSticker = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<bool> isOutgoing = const Value.absent(),
                Value<String?> sha256Hex = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
              }) => WorkingAttachmentsCompanion.insert(
                id: id,
                messageGuid: messageGuid,
                importAttachmentId: importAttachmentId,
                localPath: localPath,
                mimeType: mimeType,
                uti: uti,
                transferName: transferName,
                sizeBytes: sizeBytes,
                isSticker: isSticker,
                thumbPath: thumbPath,
                createdAtUtc: createdAtUtc,
                isOutgoing: isOutgoing,
                sha256Hex: sha256Hex,
                batchId: batchId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkingAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingAttachmentsTable,
      WorkingAttachment,
      $$WorkingAttachmentsTableFilterComposer,
      $$WorkingAttachmentsTableOrderingComposer,
      $$WorkingAttachmentsTableAnnotationComposer,
      $$WorkingAttachmentsTableCreateCompanionBuilder,
      $$WorkingAttachmentsTableUpdateCompanionBuilder,
      (
        WorkingAttachment,
        BaseReferences<
          _$WorkingDatabase,
          $WorkingAttachmentsTable,
          WorkingAttachment
        >,
      ),
      WorkingAttachment,
      PrefetchHooks Function()
    >;
typedef $$WorkingReactionsTableCreateCompanionBuilder =
    WorkingReactionsCompanion Function({
      Value<int> id,
      required String messageGuid,
      required String kind,
      Value<int?> reactorHandleId,
      required String action,
      Value<String?> reactedAtUtc,
      Value<int?> carrierMessageId,
      Value<String?> targetMessageGuid,
      Value<double> parseConfidence,
    });
typedef $$WorkingReactionsTableUpdateCompanionBuilder =
    WorkingReactionsCompanion Function({
      Value<int> id,
      Value<String> messageGuid,
      Value<String> kind,
      Value<int?> reactorHandleId,
      Value<String> action,
      Value<String?> reactedAtUtc,
      Value<int?> carrierMessageId,
      Value<String?> targetMessageGuid,
      Value<double> parseConfidence,
    });

final class $$WorkingReactionsTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $WorkingReactionsTable,
          WorkingReaction
        > {
  $$WorkingReactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HandlesCanonicalTable _reactorHandleIdTable(_$WorkingDatabase db) =>
      db.handlesCanonical.createAlias(
        $_aliasNameGenerator(
          db.workingReactions.reactorHandleId,
          db.handlesCanonical.id,
        ),
      );

  $$HandlesCanonicalTableProcessedTableManager? get reactorHandleId {
    final $_column = $_itemColumn<int>('reactor_handle_id');
    if ($_column == null) return null;
    final manager = $$HandlesCanonicalTableTableManager(
      $_db,
      $_db.handlesCanonical,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reactorHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingMessagesTable _carrierMessageIdTable(_$WorkingDatabase db) =>
      db.workingMessages.createAlias(
        $_aliasNameGenerator(
          db.workingReactions.carrierMessageId,
          db.workingMessages.id,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager? get carrierMessageId {
    final $_column = $_itemColumn<int>('carrier_message_id');
    if ($_column == null) return null;
    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carrierMessageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkingReactionsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingReactionsTable> {
  $$WorkingReactionsTableFilterComposer({
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

  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetMessageGuid => $composableBuilder(
    column: $table.targetMessageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get parseConfidence => $composableBuilder(
    column: $table.parseConfidence,
    builder: (column) => ColumnFilters(column),
  );

  $$HandlesCanonicalTableFilterComposer get reactorHandleId {
    final $$HandlesCanonicalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableFilterComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableFilterComposer get carrierMessageId {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carrierMessageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingReactionsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingReactionsTable> {
  $$WorkingReactionsTableOrderingComposer({
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

  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetMessageGuid => $composableBuilder(
    column: $table.targetMessageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get parseConfidence => $composableBuilder(
    column: $table.parseConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$HandlesCanonicalTableOrderingComposer get reactorHandleId {
    final $$HandlesCanonicalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableOrderingComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableOrderingComposer get carrierMessageId {
    final $$WorkingMessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carrierMessageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableOrderingComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingReactionsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingReactionsTable> {
  $$WorkingReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetMessageGuid => $composableBuilder(
    column: $table.targetMessageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get parseConfidence => $composableBuilder(
    column: $table.parseConfidence,
    builder: (column) => column,
  );

  $$HandlesCanonicalTableAnnotationComposer get reactorHandleId {
    final $$HandlesCanonicalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorHandleId,
      referencedTable: $db.handlesCanonical,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesCanonicalTableAnnotationComposer(
            $db: $db,
            $table: $db.handlesCanonical,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingMessagesTableAnnotationComposer get carrierMessageId {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carrierMessageId,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingReactionsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingReactionsTable,
          WorkingReaction,
          $$WorkingReactionsTableFilterComposer,
          $$WorkingReactionsTableOrderingComposer,
          $$WorkingReactionsTableAnnotationComposer,
          $$WorkingReactionsTableCreateCompanionBuilder,
          $$WorkingReactionsTableUpdateCompanionBuilder,
          (WorkingReaction, $$WorkingReactionsTableReferences),
          WorkingReaction,
          PrefetchHooks Function({bool reactorHandleId, bool carrierMessageId})
        > {
  $$WorkingReactionsTableTableManager(
    _$WorkingDatabase db,
    $WorkingReactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageGuid = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> reactorHandleId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> reactedAtUtc = const Value.absent(),
                Value<int?> carrierMessageId = const Value.absent(),
                Value<String?> targetMessageGuid = const Value.absent(),
                Value<double> parseConfidence = const Value.absent(),
              }) => WorkingReactionsCompanion(
                id: id,
                messageGuid: messageGuid,
                kind: kind,
                reactorHandleId: reactorHandleId,
                action: action,
                reactedAtUtc: reactedAtUtc,
                carrierMessageId: carrierMessageId,
                targetMessageGuid: targetMessageGuid,
                parseConfidence: parseConfidence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageGuid,
                required String kind,
                Value<int?> reactorHandleId = const Value.absent(),
                required String action,
                Value<String?> reactedAtUtc = const Value.absent(),
                Value<int?> carrierMessageId = const Value.absent(),
                Value<String?> targetMessageGuid = const Value.absent(),
                Value<double> parseConfidence = const Value.absent(),
              }) => WorkingReactionsCompanion.insert(
                id: id,
                messageGuid: messageGuid,
                kind: kind,
                reactorHandleId: reactorHandleId,
                action: action,
                reactedAtUtc: reactedAtUtc,
                carrierMessageId: carrierMessageId,
                targetMessageGuid: targetMessageGuid,
                parseConfidence: parseConfidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingReactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({reactorHandleId = false, carrierMessageId = false}) {
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
                        if (reactorHandleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.reactorHandleId,
                                    referencedTable:
                                        $$WorkingReactionsTableReferences
                                            ._reactorHandleIdTable(db),
                                    referencedColumn:
                                        $$WorkingReactionsTableReferences
                                            ._reactorHandleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (carrierMessageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carrierMessageId,
                                    referencedTable:
                                        $$WorkingReactionsTableReferences
                                            ._carrierMessageIdTable(db),
                                    referencedColumn:
                                        $$WorkingReactionsTableReferences
                                            ._carrierMessageIdTable(db)
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

typedef $$WorkingReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingReactionsTable,
      WorkingReaction,
      $$WorkingReactionsTableFilterComposer,
      $$WorkingReactionsTableOrderingComposer,
      $$WorkingReactionsTableAnnotationComposer,
      $$WorkingReactionsTableCreateCompanionBuilder,
      $$WorkingReactionsTableUpdateCompanionBuilder,
      (WorkingReaction, $$WorkingReactionsTableReferences),
      WorkingReaction,
      PrefetchHooks Function({bool reactorHandleId, bool carrierMessageId})
    >;
typedef $$ReactionCountsTableCreateCompanionBuilder =
    ReactionCountsCompanion Function({
      required String messageGuid,
      Value<int> love,
      Value<int> like,
      Value<int> dislike,
      Value<int> laugh,
      Value<int> emphasize,
      Value<int> question,
      Value<int> rowid,
    });
typedef $$ReactionCountsTableUpdateCompanionBuilder =
    ReactionCountsCompanion Function({
      Value<String> messageGuid,
      Value<int> love,
      Value<int> like,
      Value<int> dislike,
      Value<int> laugh,
      Value<int> emphasize,
      Value<int> question,
      Value<int> rowid,
    });

class $$ReactionCountsTableFilterComposer
    extends Composer<_$WorkingDatabase, $ReactionCountsTable> {
  $$ReactionCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get love => $composableBuilder(
    column: $table.love,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get like => $composableBuilder(
    column: $table.like,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dislike => $composableBuilder(
    column: $table.dislike,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get laugh => $composableBuilder(
    column: $table.laugh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emphasize => $composableBuilder(
    column: $table.emphasize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReactionCountsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ReactionCountsTable> {
  $$ReactionCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get love => $composableBuilder(
    column: $table.love,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get like => $composableBuilder(
    column: $table.like,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dislike => $composableBuilder(
    column: $table.dislike,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get laugh => $composableBuilder(
    column: $table.laugh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emphasize => $composableBuilder(
    column: $table.emphasize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionCountsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ReactionCountsTable> {
  $$ReactionCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get love =>
      $composableBuilder(column: $table.love, builder: (column) => column);

  GeneratedColumn<int> get like =>
      $composableBuilder(column: $table.like, builder: (column) => column);

  GeneratedColumn<int> get dislike =>
      $composableBuilder(column: $table.dislike, builder: (column) => column);

  GeneratedColumn<int> get laugh =>
      $composableBuilder(column: $table.laugh, builder: (column) => column);

  GeneratedColumn<int> get emphasize =>
      $composableBuilder(column: $table.emphasize, builder: (column) => column);

  GeneratedColumn<int> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);
}

class $$ReactionCountsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ReactionCountsTable,
          ReactionCount,
          $$ReactionCountsTableFilterComposer,
          $$ReactionCountsTableOrderingComposer,
          $$ReactionCountsTableAnnotationComposer,
          $$ReactionCountsTableCreateCompanionBuilder,
          $$ReactionCountsTableUpdateCompanionBuilder,
          (
            ReactionCount,
            BaseReferences<
              _$WorkingDatabase,
              $ReactionCountsTable,
              ReactionCount
            >,
          ),
          ReactionCount,
          PrefetchHooks Function()
        > {
  $$ReactionCountsTableTableManager(
    _$WorkingDatabase db,
    $ReactionCountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReactionCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReactionCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageGuid = const Value.absent(),
                Value<int> love = const Value.absent(),
                Value<int> like = const Value.absent(),
                Value<int> dislike = const Value.absent(),
                Value<int> laugh = const Value.absent(),
                Value<int> emphasize = const Value.absent(),
                Value<int> question = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionCountsCompanion(
                messageGuid: messageGuid,
                love: love,
                like: like,
                dislike: dislike,
                laugh: laugh,
                emphasize: emphasize,
                question: question,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageGuid,
                Value<int> love = const Value.absent(),
                Value<int> like = const Value.absent(),
                Value<int> dislike = const Value.absent(),
                Value<int> laugh = const Value.absent(),
                Value<int> emphasize = const Value.absent(),
                Value<int> question = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionCountsCompanion.insert(
                messageGuid: messageGuid,
                love: love,
                like: like,
                dislike: dislike,
                laugh: laugh,
                emphasize: emphasize,
                question: question,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ReactionCountsTable,
      ReactionCount,
      $$ReactionCountsTableFilterComposer,
      $$ReactionCountsTableOrderingComposer,
      $$ReactionCountsTableAnnotationComposer,
      $$ReactionCountsTableCreateCompanionBuilder,
      $$ReactionCountsTableUpdateCompanionBuilder,
      (
        ReactionCount,
        BaseReferences<_$WorkingDatabase, $ReactionCountsTable, ReactionCount>,
      ),
      ReactionCount,
      PrefetchHooks Function()
    >;
typedef $$ReadStateTableCreateCompanionBuilder =
    ReadStateCompanion Function({
      Value<int> chatId,
      Value<String?> lastReadAtUtc,
    });
typedef $$ReadStateTableUpdateCompanionBuilder =
    ReadStateCompanion Function({
      Value<int> chatId,
      Value<String?> lastReadAtUtc,
    });

final class $$ReadStateTableReferences
    extends BaseReferences<_$WorkingDatabase, $ReadStateTable, ReadStateData> {
  $$ReadStateTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.readState.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadStateTableFilterComposer
    extends Composer<_$WorkingDatabase, $ReadStateTable> {
  $$ReadStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastReadAtUtc => $composableBuilder(
    column: $table.lastReadAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadStateTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ReadStateTable> {
  $$ReadStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastReadAtUtc => $composableBuilder(
    column: $table.lastReadAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadStateTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ReadStateTable> {
  $$ReadStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastReadAtUtc => $composableBuilder(
    column: $table.lastReadAtUtc,
    builder: (column) => column,
  );

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadStateTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ReadStateTable,
          ReadStateData,
          $$ReadStateTableFilterComposer,
          $$ReadStateTableOrderingComposer,
          $$ReadStateTableAnnotationComposer,
          $$ReadStateTableCreateCompanionBuilder,
          $$ReadStateTableUpdateCompanionBuilder,
          (ReadStateData, $$ReadStateTableReferences),
          ReadStateData,
          PrefetchHooks Function({bool chatId})
        > {
  $$ReadStateTableTableManager(_$WorkingDatabase db, $ReadStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> lastReadAtUtc = const Value.absent(),
              }) => ReadStateCompanion(
                chatId: chatId,
                lastReadAtUtc: lastReadAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> lastReadAtUtc = const Value.absent(),
              }) => ReadStateCompanion.insert(
                chatId: chatId,
                lastReadAtUtc: lastReadAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false}) {
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
                                referencedTable: $$ReadStateTableReferences
                                    ._chatIdTable(db),
                                referencedColumn: $$ReadStateTableReferences
                                    ._chatIdTable(db)
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

typedef $$ReadStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ReadStateTable,
      ReadStateData,
      $$ReadStateTableFilterComposer,
      $$ReadStateTableOrderingComposer,
      $$ReadStateTableAnnotationComposer,
      $$ReadStateTableCreateCompanionBuilder,
      $$ReadStateTableUpdateCompanionBuilder,
      (ReadStateData, $$ReadStateTableReferences),
      ReadStateData,
      PrefetchHooks Function({bool chatId})
    >;
typedef $$MessageReadMarksTableCreateCompanionBuilder =
    MessageReadMarksCompanion Function({
      required String messageGuid,
      required String markedAtUtc,
      Value<int> rowid,
    });
typedef $$MessageReadMarksTableUpdateCompanionBuilder =
    MessageReadMarksCompanion Function({
      Value<String> messageGuid,
      Value<String> markedAtUtc,
      Value<int> rowid,
    });

class $$MessageReadMarksTableFilterComposer
    extends Composer<_$WorkingDatabase, $MessageReadMarksTable> {
  $$MessageReadMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedAtUtc => $composableBuilder(
    column: $table.markedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageReadMarksTableOrderingComposer
    extends Composer<_$WorkingDatabase, $MessageReadMarksTable> {
  $$MessageReadMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedAtUtc => $composableBuilder(
    column: $table.markedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageReadMarksTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $MessageReadMarksTable> {
  $$MessageReadMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markedAtUtc => $composableBuilder(
    column: $table.markedAtUtc,
    builder: (column) => column,
  );
}

class $$MessageReadMarksTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $MessageReadMarksTable,
          MessageReadMark,
          $$MessageReadMarksTableFilterComposer,
          $$MessageReadMarksTableOrderingComposer,
          $$MessageReadMarksTableAnnotationComposer,
          $$MessageReadMarksTableCreateCompanionBuilder,
          $$MessageReadMarksTableUpdateCompanionBuilder,
          (
            MessageReadMark,
            BaseReferences<
              _$WorkingDatabase,
              $MessageReadMarksTable,
              MessageReadMark
            >,
          ),
          MessageReadMark,
          PrefetchHooks Function()
        > {
  $$MessageReadMarksTableTableManager(
    _$WorkingDatabase db,
    $MessageReadMarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageReadMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageReadMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageReadMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageGuid = const Value.absent(),
                Value<String> markedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageReadMarksCompanion(
                messageGuid: messageGuid,
                markedAtUtc: markedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageGuid,
                required String markedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => MessageReadMarksCompanion.insert(
                messageGuid: messageGuid,
                markedAtUtc: markedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageReadMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $MessageReadMarksTable,
      MessageReadMark,
      $$MessageReadMarksTableFilterComposer,
      $$MessageReadMarksTableOrderingComposer,
      $$MessageReadMarksTableAnnotationComposer,
      $$MessageReadMarksTableCreateCompanionBuilder,
      $$MessageReadMarksTableUpdateCompanionBuilder,
      (
        MessageReadMark,
        BaseReferences<
          _$WorkingDatabase,
          $MessageReadMarksTable,
          MessageReadMark
        >,
      ),
      MessageReadMark,
      PrefetchHooks Function()
    >;
typedef $$SupabaseSyncStateTableCreateCompanionBuilder =
    SupabaseSyncStateCompanion Function({
      Value<int> id,
      required String targetTable,
      Value<int?> lastBatchId,
      Value<int?> lastSyncedRowId,
      Value<String?> lastSyncedGuid,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> updatedAt,
    });
typedef $$SupabaseSyncStateTableUpdateCompanionBuilder =
    SupabaseSyncStateCompanion Function({
      Value<int> id,
      Value<String> targetTable,
      Value<int?> lastBatchId,
      Value<int?> lastSyncedRowId,
      Value<String?> lastSyncedGuid,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> updatedAt,
    });

class $$SupabaseSyncStateTableFilterComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncStateTable> {
  $$SupabaseSyncStateTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastBatchId => $composableBuilder(
    column: $table.lastBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedRowId => $composableBuilder(
    column: $table.lastSyncedRowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncedGuid => $composableBuilder(
    column: $table.lastSyncedGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupabaseSyncStateTableOrderingComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncStateTable> {
  $$SupabaseSyncStateTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastBatchId => $composableBuilder(
    column: $table.lastBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedRowId => $composableBuilder(
    column: $table.lastSyncedRowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncedGuid => $composableBuilder(
    column: $table.lastSyncedGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupabaseSyncStateTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncStateTable> {
  $$SupabaseSyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastBatchId => $composableBuilder(
    column: $table.lastBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedRowId => $composableBuilder(
    column: $table.lastSyncedRowId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedGuid => $composableBuilder(
    column: $table.lastSyncedGuid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SupabaseSyncStateTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $SupabaseSyncStateTable,
          SupabaseSyncStateData,
          $$SupabaseSyncStateTableFilterComposer,
          $$SupabaseSyncStateTableOrderingComposer,
          $$SupabaseSyncStateTableAnnotationComposer,
          $$SupabaseSyncStateTableCreateCompanionBuilder,
          $$SupabaseSyncStateTableUpdateCompanionBuilder,
          (
            SupabaseSyncStateData,
            BaseReferences<
              _$WorkingDatabase,
              $SupabaseSyncStateTable,
              SupabaseSyncStateData
            >,
          ),
          SupabaseSyncStateData,
          PrefetchHooks Function()
        > {
  $$SupabaseSyncStateTableTableManager(
    _$WorkingDatabase db,
    $SupabaseSyncStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupabaseSyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupabaseSyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupabaseSyncStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<int?> lastBatchId = const Value.absent(),
                Value<int?> lastSyncedRowId = const Value.absent(),
                Value<String?> lastSyncedGuid = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SupabaseSyncStateCompanion(
                id: id,
                targetTable: targetTable,
                lastBatchId: lastBatchId,
                lastSyncedRowId: lastSyncedRowId,
                lastSyncedGuid: lastSyncedGuid,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                Value<int?> lastBatchId = const Value.absent(),
                Value<int?> lastSyncedRowId = const Value.absent(),
                Value<String?> lastSyncedGuid = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SupabaseSyncStateCompanion.insert(
                id: id,
                targetTable: targetTable,
                lastBatchId: lastBatchId,
                lastSyncedRowId: lastSyncedRowId,
                lastSyncedGuid: lastSyncedGuid,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupabaseSyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $SupabaseSyncStateTable,
      SupabaseSyncStateData,
      $$SupabaseSyncStateTableFilterComposer,
      $$SupabaseSyncStateTableOrderingComposer,
      $$SupabaseSyncStateTableAnnotationComposer,
      $$SupabaseSyncStateTableCreateCompanionBuilder,
      $$SupabaseSyncStateTableUpdateCompanionBuilder,
      (
        SupabaseSyncStateData,
        BaseReferences<
          _$WorkingDatabase,
          $SupabaseSyncStateTable,
          SupabaseSyncStateData
        >,
      ),
      SupabaseSyncStateData,
      PrefetchHooks Function()
    >;
typedef $$SupabaseSyncLogsTableCreateCompanionBuilder =
    SupabaseSyncLogsCompanion Function({
      Value<int> id,
      Value<int?> batchId,
      Value<String?> targetTable,
      Value<String?> status,
      Value<int> attempt,
      Value<String?> requestId,
      Value<String?> message,
      Value<DateTime> createdAt,
    });
typedef $$SupabaseSyncLogsTableUpdateCompanionBuilder =
    SupabaseSyncLogsCompanion Function({
      Value<int> id,
      Value<int?> batchId,
      Value<String?> targetTable,
      Value<String?> status,
      Value<int> attempt,
      Value<String?> requestId,
      Value<String?> message,
      Value<DateTime> createdAt,
    });

class $$SupabaseSyncLogsTableFilterComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncLogsTable> {
  $$SupabaseSyncLogsTableFilterComposer({
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

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupabaseSyncLogsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncLogsTable> {
  $$SupabaseSyncLogsTableOrderingComposer({
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

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupabaseSyncLogsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncLogsTable> {
  $$SupabaseSyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SupabaseSyncLogsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $SupabaseSyncLogsTable,
          SupabaseSyncLog,
          $$SupabaseSyncLogsTableFilterComposer,
          $$SupabaseSyncLogsTableOrderingComposer,
          $$SupabaseSyncLogsTableAnnotationComposer,
          $$SupabaseSyncLogsTableCreateCompanionBuilder,
          $$SupabaseSyncLogsTableUpdateCompanionBuilder,
          (
            SupabaseSyncLog,
            BaseReferences<
              _$WorkingDatabase,
              $SupabaseSyncLogsTable,
              SupabaseSyncLog
            >,
          ),
          SupabaseSyncLog,
          PrefetchHooks Function()
        > {
  $$SupabaseSyncLogsTableTableManager(
    _$WorkingDatabase db,
    $SupabaseSyncLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupabaseSyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupabaseSyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupabaseSyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<String?> targetTable = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SupabaseSyncLogsCompanion(
                id: id,
                batchId: batchId,
                targetTable: targetTable,
                status: status,
                attempt: attempt,
                requestId: requestId,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<String?> targetTable = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SupabaseSyncLogsCompanion.insert(
                id: id,
                batchId: batchId,
                targetTable: targetTable,
                status: status,
                attempt: attempt,
                requestId: requestId,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupabaseSyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $SupabaseSyncLogsTable,
      SupabaseSyncLog,
      $$SupabaseSyncLogsTableFilterComposer,
      $$SupabaseSyncLogsTableOrderingComposer,
      $$SupabaseSyncLogsTableAnnotationComposer,
      $$SupabaseSyncLogsTableCreateCompanionBuilder,
      $$SupabaseSyncLogsTableUpdateCompanionBuilder,
      (
        SupabaseSyncLog,
        BaseReferences<
          _$WorkingDatabase,
          $SupabaseSyncLogsTable,
          SupabaseSyncLog
        >,
      ),
      SupabaseSyncLog,
      PrefetchHooks Function()
    >;

class $WorkingDatabaseManager {
  final _$WorkingDatabase _db;
  $WorkingDatabaseManager(this._db);
  $$WorkingSchemaMigrationsTableTableManager get workingSchemaMigrations =>
      $$WorkingSchemaMigrationsTableTableManager(
        _db,
        _db.workingSchemaMigrations,
      );
  $$ProjectionStateTableTableManager get projectionState =>
      $$ProjectionStateTableTableManager(_db, _db.projectionState);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$WorkingHandlesTableTableManager get workingHandles =>
      $$WorkingHandlesTableTableManager(_db, _db.workingHandles);
  $$HandlesCanonicalTableTableManager get handlesCanonical =>
      $$HandlesCanonicalTableTableManager(_db, _db.handlesCanonical);
  $$WorkingParticipantsTableTableManager get workingParticipants =>
      $$WorkingParticipantsTableTableManager(_db, _db.workingParticipants);
  $$HandleToParticipantTableTableManager get handleToParticipant =>
      $$HandleToParticipantTableTableManager(_db, _db.handleToParticipant);
  $$HandlesCanonicalToAliasTableTableManager get handlesCanonicalToAlias =>
      $$HandlesCanonicalToAliasTableTableManager(
        _db,
        _db.handlesCanonicalToAlias,
      );
  $$WorkingChatsTableTableManager get workingChats =>
      $$WorkingChatsTableTableManager(_db, _db.workingChats);
  $$ChatToHandleTableTableManager get chatToHandle =>
      $$ChatToHandleTableTableManager(_db, _db.chatToHandle);
  $$WorkingMessagesTableTableManager get workingMessages =>
      $$WorkingMessagesTableTableManager(_db, _db.workingMessages);
  $$GlobalMessageIndexTableTableManager get globalMessageIndex =>
      $$GlobalMessageIndexTableTableManager(_db, _db.globalMessageIndex);
  $$MessageIndexTableTableManager get messageIndex =>
      $$MessageIndexTableTableManager(_db, _db.messageIndex);
  $$ContactMessageIndexTableTableManager get contactMessageIndex =>
      $$ContactMessageIndexTableTableManager(_db, _db.contactMessageIndex);
  $$WorkingAttachmentsTableTableManager get workingAttachments =>
      $$WorkingAttachmentsTableTableManager(_db, _db.workingAttachments);
  $$WorkingReactionsTableTableManager get workingReactions =>
      $$WorkingReactionsTableTableManager(_db, _db.workingReactions);
  $$ReactionCountsTableTableManager get reactionCounts =>
      $$ReactionCountsTableTableManager(_db, _db.reactionCounts);
  $$ReadStateTableTableManager get readState =>
      $$ReadStateTableTableManager(_db, _db.readState);
  $$MessageReadMarksTableTableManager get messageReadMarks =>
      $$MessageReadMarksTableTableManager(_db, _db.messageReadMarks);
  $$SupabaseSyncStateTableTableManager get supabaseSyncState =>
      $$SupabaseSyncStateTableTableManager(_db, _db.supabaseSyncState);
  $$SupabaseSyncLogsTableTableManager get supabaseSyncLogs =>
      $$SupabaseSyncLogsTableTableManager(_db, _db.supabaseSyncLogs);
}
