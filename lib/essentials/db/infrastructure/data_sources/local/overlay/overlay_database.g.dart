// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overlay_database.dart';

// ignore_for_file: type=lint
class $ParticipantOverridesTable extends ParticipantOverrides
    with TableInfo<$ParticipantOverridesTable, ParticipantOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameModeMeta = const VerificationMeta(
    'nameMode',
  );
  @override
  late final GeneratedColumn<int> nameMode = GeneratedColumn<int>(
    'name_mode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameOverrideMeta =
      const VerificationMeta('displayNameOverride');
  @override
  late final GeneratedColumn<String> displayNameOverride =
      GeneratedColumn<String>(
        'display_name_override',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    participantId,
    nameMode,
    nickname,
    displayNameOverride,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participant_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParticipantOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    }
    if (data.containsKey('name_mode')) {
      context.handle(
        _nameModeMeta,
        nameMode.isAcceptableOrUnknown(data['name_mode']!, _nameModeMeta),
      );
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('display_name_override')) {
      context.handle(
        _displayNameOverrideMeta,
        displayNameOverride.isAcceptableOrUnknown(
          data['display_name_override']!,
          _displayNameOverrideMeta,
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {participantId};
  @override
  ParticipantOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantOverride(
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      nameMode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}name_mode'],
      ),
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      displayNameOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name_override'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ParticipantOverridesTable createAlias(String alias) {
    return $ParticipantOverridesTable(attachedDatabase, alias);
  }
}

class ParticipantOverride extends DataClass
    implements Insertable<ParticipantOverride> {
  /// Matches working.participants.id
  final int participantId;

  /// Nullable: when null, this participant inherits global default.
  ///
  /// Stored values map to ParticipantNameMode.dbValue (except we recommend
  /// storing null for inherit).
  final int? nameMode;

  /// User's nickname, e.g. "Westy"
  final String? nickname;

  /// User's custom display name override, e.g. "Dad (Mobile)"
  final String? displayNameOverride;
  final String createdAtUtc;
  final String updatedAtUtc;
  const ParticipantOverride({
    required this.participantId,
    this.nameMode,
    this.nickname,
    this.displayNameOverride,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['participant_id'] = Variable<int>(participantId);
    if (!nullToAbsent || nameMode != null) {
      map['name_mode'] = Variable<int>(nameMode);
    }
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || displayNameOverride != null) {
      map['display_name_override'] = Variable<String>(displayNameOverride);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  ParticipantOverridesCompanion toCompanion(bool nullToAbsent) {
    return ParticipantOverridesCompanion(
      participantId: Value(participantId),
      nameMode: nameMode == null && nullToAbsent
          ? const Value.absent()
          : Value(nameMode),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      displayNameOverride: displayNameOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(displayNameOverride),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ParticipantOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParticipantOverride(
      participantId: serializer.fromJson<int>(json['participantId']),
      nameMode: serializer.fromJson<int?>(json['nameMode']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      displayNameOverride: serializer.fromJson<String?>(
        json['displayNameOverride'],
      ),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'participantId': serializer.toJson<int>(participantId),
      'nameMode': serializer.toJson<int?>(nameMode),
      'nickname': serializer.toJson<String?>(nickname),
      'displayNameOverride': serializer.toJson<String?>(displayNameOverride),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  ParticipantOverride copyWith({
    int? participantId,
    Value<int?> nameMode = const Value.absent(),
    Value<String?> nickname = const Value.absent(),
    Value<String?> displayNameOverride = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => ParticipantOverride(
    participantId: participantId ?? this.participantId,
    nameMode: nameMode.present ? nameMode.value : this.nameMode,
    nickname: nickname.present ? nickname.value : this.nickname,
    displayNameOverride: displayNameOverride.present
        ? displayNameOverride.value
        : this.displayNameOverride,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ParticipantOverride copyWithCompanion(ParticipantOverridesCompanion data) {
    return ParticipantOverride(
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      nameMode: data.nameMode.present ? data.nameMode.value : this.nameMode,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      displayNameOverride: data.displayNameOverride.present
          ? data.displayNameOverride.value
          : this.displayNameOverride,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantOverride(')
          ..write('participantId: $participantId, ')
          ..write('nameMode: $nameMode, ')
          ..write('nickname: $nickname, ')
          ..write('displayNameOverride: $displayNameOverride, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    participantId,
    nameMode,
    nickname,
    displayNameOverride,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantOverride &&
          other.participantId == this.participantId &&
          other.nameMode == this.nameMode &&
          other.nickname == this.nickname &&
          other.displayNameOverride == this.displayNameOverride &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ParticipantOverridesCompanion
    extends UpdateCompanion<ParticipantOverride> {
  final Value<int> participantId;
  final Value<int?> nameMode;
  final Value<String?> nickname;
  final Value<String?> displayNameOverride;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const ParticipantOverridesCompanion({
    this.participantId = const Value.absent(),
    this.nameMode = const Value.absent(),
    this.nickname = const Value.absent(),
    this.displayNameOverride = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  ParticipantOverridesCompanion.insert({
    this.participantId = const Value.absent(),
    this.nameMode = const Value.absent(),
    this.nickname = const Value.absent(),
    this.displayNameOverride = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ParticipantOverride> custom({
    Expression<int>? participantId,
    Expression<int>? nameMode,
    Expression<String>? nickname,
    Expression<String>? displayNameOverride,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (participantId != null) 'participant_id': participantId,
      if (nameMode != null) 'name_mode': nameMode,
      if (nickname != null) 'nickname': nickname,
      if (displayNameOverride != null)
        'display_name_override': displayNameOverride,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  ParticipantOverridesCompanion copyWith({
    Value<int>? participantId,
    Value<int?>? nameMode,
    Value<String?>? nickname,
    Value<String?>? displayNameOverride,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return ParticipantOverridesCompanion(
      participantId: participantId ?? this.participantId,
      nameMode: nameMode ?? this.nameMode,
      nickname: nickname ?? this.nickname,
      displayNameOverride: displayNameOverride ?? this.displayNameOverride,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (nameMode.present) {
      map['name_mode'] = Variable<int>(nameMode.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (displayNameOverride.present) {
      map['display_name_override'] = Variable<String>(
        displayNameOverride.value,
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantOverridesCompanion(')
          ..write('participantId: $participantId, ')
          ..write('nameMode: $nameMode, ')
          ..write('nickname: $nickname, ')
          ..write('displayNameOverride: $displayNameOverride, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ChatOverridesTable extends ChatOverrides
    with TableInfo<$ChatOverridesTable, ChatOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customColorMeta = const VerificationMeta(
    'customColor',
  );
  @override
  late final GeneratedColumn<String> customColor = GeneratedColumn<String>(
    'custom_color',
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
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chatId,
    customName,
    customColor,
    notes,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatOverride> instance, {
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
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('custom_color')) {
      context.handle(
        _customColorMeta,
        customColor.isAcceptableOrUnknown(
          data['custom_color']!,
          _customColorMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  ChatOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatOverride(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      customColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_color'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ChatOverridesTable createAlias(String alias) {
    return $ChatOverridesTable(attachedDatabase, alias);
  }
}

class ChatOverride extends DataClass implements Insertable<ChatOverride> {
  /// Matches working.chats.id
  final int chatId;

  /// User's custom name for this chat (overrides derived title)
  final String? customName;

  /// User's custom color/theme for this chat
  final String? customColor;

  /// User's notes about this chat
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
  const ChatOverride({
    required this.chatId,
    this.customName,
    this.customColor,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || customColor != null) {
      map['custom_color'] = Variable<String>(customColor);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  ChatOverridesCompanion toCompanion(bool nullToAbsent) {
    return ChatOverridesCompanion(
      chatId: Value(chatId),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      customColor: customColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customColor),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ChatOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatOverride(
      chatId: serializer.fromJson<int>(json['chatId']),
      customName: serializer.fromJson<String?>(json['customName']),
      customColor: serializer.fromJson<String?>(json['customColor']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'customName': serializer.toJson<String?>(customName),
      'customColor': serializer.toJson<String?>(customColor),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  ChatOverride copyWith({
    int? chatId,
    Value<String?> customName = const Value.absent(),
    Value<String?> customColor = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => ChatOverride(
    chatId: chatId ?? this.chatId,
    customName: customName.present ? customName.value : this.customName,
    customColor: customColor.present ? customColor.value : this.customColor,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ChatOverride copyWithCompanion(ChatOverridesCompanion data) {
    return ChatOverride(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      customColor: data.customColor.present
          ? data.customColor.value
          : this.customColor,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatOverride(')
          ..write('chatId: $chatId, ')
          ..write('customName: $customName, ')
          ..write('customColor: $customColor, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chatId,
    customName,
    customColor,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatOverride &&
          other.chatId == this.chatId &&
          other.customName == this.customName &&
          other.customColor == this.customColor &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ChatOverridesCompanion extends UpdateCompanion<ChatOverride> {
  final Value<int> chatId;
  final Value<String?> customName;
  final Value<String?> customColor;
  final Value<String?> notes;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const ChatOverridesCompanion({
    this.chatId = const Value.absent(),
    this.customName = const Value.absent(),
    this.customColor = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  ChatOverridesCompanion.insert({
    this.chatId = const Value.absent(),
    this.customName = const Value.absent(),
    this.customColor = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ChatOverride> custom({
    Expression<int>? chatId,
    Expression<String>? customName,
    Expression<String>? customColor,
    Expression<String>? notes,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (customName != null) 'custom_name': customName,
      if (customColor != null) 'custom_color': customColor,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  ChatOverridesCompanion copyWith({
    Value<int>? chatId,
    Value<String?>? customName,
    Value<String?>? customColor,
    Value<String?>? notes,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return ChatOverridesCompanion(
      chatId: chatId ?? this.chatId,
      customName: customName ?? this.customName,
      customColor: customColor ?? this.customColor,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (customColor.present) {
      map['custom_color'] = Variable<String>(customColor.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatOverridesCompanion(')
          ..write('chatId: $chatId, ')
          ..write('customName: $customName, ')
          ..write('customColor: $customColor, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $MessageAnnotationsTable extends MessageAnnotations
    with TableInfo<$MessageAnnotationsTable, MessageAnnotation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageAnnotationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
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
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userNotesMeta = const VerificationMeta(
    'userNotes',
  );
  @override
  late final GeneratedColumn<String> userNotes = GeneratedColumn<String>(
    'user_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<String> remindAt = GeneratedColumn<String>(
    'remind_at',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    tags,
    isStarred,
    isArchived,
    userNotes,
    priority,
    remindAt,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_annotations';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageAnnotation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('user_notes')) {
      context.handle(
        _userNotesMeta,
        userNotes.isAcceptableOrUnknown(data['user_notes']!, _userNotesMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  MessageAnnotation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageAnnotation(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      userNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_notes'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      ),
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remind_at'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $MessageAnnotationsTable createAlias(String alias) {
    return $MessageAnnotationsTable(attachedDatabase, alias);
  }
}

class MessageAnnotation extends DataClass
    implements Insertable<MessageAnnotation> {
  /// Matches working.messages.id
  final int messageId;

  /// User-defined tags as JSON array: '["receipt","important","todo"]'
  final String? tags;

  /// Whether user has starred this message
  final bool isStarred;

  /// Whether user has archived this message
  final bool isArchived;

  /// User's personal notes about this message
  final String? userNotes;

  /// Priority level (1-5, where 5 is highest)
  final int? priority;

  /// ISO8601 timestamp for reminder
  final String? remindAt;
  final String createdAtUtc;
  final String updatedAtUtc;
  const MessageAnnotation({
    required this.messageId,
    this.tags,
    required this.isStarred,
    required this.isArchived,
    this.userNotes,
    this.priority,
    this.remindAt,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || userNotes != null) {
      map['user_notes'] = Variable<String>(userNotes);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<int>(priority);
    }
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<String>(remindAt);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  MessageAnnotationsCompanion toCompanion(bool nullToAbsent) {
    return MessageAnnotationsCompanion(
      messageId: Value(messageId),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      isStarred: Value(isStarred),
      isArchived: Value(isArchived),
      userNotes: userNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(userNotes),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory MessageAnnotation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageAnnotation(
      messageId: serializer.fromJson<int>(json['messageId']),
      tags: serializer.fromJson<String?>(json['tags']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      userNotes: serializer.fromJson<String?>(json['userNotes']),
      priority: serializer.fromJson<int?>(json['priority']),
      remindAt: serializer.fromJson<String?>(json['remindAt']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'tags': serializer.toJson<String?>(tags),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isArchived': serializer.toJson<bool>(isArchived),
      'userNotes': serializer.toJson<String?>(userNotes),
      'priority': serializer.toJson<int?>(priority),
      'remindAt': serializer.toJson<String?>(remindAt),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  MessageAnnotation copyWith({
    int? messageId,
    Value<String?> tags = const Value.absent(),
    bool? isStarred,
    bool? isArchived,
    Value<String?> userNotes = const Value.absent(),
    Value<int?> priority = const Value.absent(),
    Value<String?> remindAt = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => MessageAnnotation(
    messageId: messageId ?? this.messageId,
    tags: tags.present ? tags.value : this.tags,
    isStarred: isStarred ?? this.isStarred,
    isArchived: isArchived ?? this.isArchived,
    userNotes: userNotes.present ? userNotes.value : this.userNotes,
    priority: priority.present ? priority.value : this.priority,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  MessageAnnotation copyWithCompanion(MessageAnnotationsCompanion data) {
    return MessageAnnotation(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      tags: data.tags.present ? data.tags.value : this.tags,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      userNotes: data.userNotes.present ? data.userNotes.value : this.userNotes,
      priority: data.priority.present ? data.priority.value : this.priority,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageAnnotation(')
          ..write('messageId: $messageId, ')
          ..write('tags: $tags, ')
          ..write('isStarred: $isStarred, ')
          ..write('isArchived: $isArchived, ')
          ..write('userNotes: $userNotes, ')
          ..write('priority: $priority, ')
          ..write('remindAt: $remindAt, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    tags,
    isStarred,
    isArchived,
    userNotes,
    priority,
    remindAt,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageAnnotation &&
          other.messageId == this.messageId &&
          other.tags == this.tags &&
          other.isStarred == this.isStarred &&
          other.isArchived == this.isArchived &&
          other.userNotes == this.userNotes &&
          other.priority == this.priority &&
          other.remindAt == this.remindAt &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class MessageAnnotationsCompanion extends UpdateCompanion<MessageAnnotation> {
  final Value<int> messageId;
  final Value<String?> tags;
  final Value<bool> isStarred;
  final Value<bool> isArchived;
  final Value<String?> userNotes;
  final Value<int?> priority;
  final Value<String?> remindAt;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const MessageAnnotationsCompanion({
    this.messageId = const Value.absent(),
    this.tags = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.userNotes = const Value.absent(),
    this.priority = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  MessageAnnotationsCompanion.insert({
    this.messageId = const Value.absent(),
    this.tags = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.userNotes = const Value.absent(),
    this.priority = const Value.absent(),
    this.remindAt = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<MessageAnnotation> custom({
    Expression<int>? messageId,
    Expression<String>? tags,
    Expression<bool>? isStarred,
    Expression<bool>? isArchived,
    Expression<String>? userNotes,
    Expression<int>? priority,
    Expression<String>? remindAt,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (tags != null) 'tags': tags,
      if (isStarred != null) 'is_starred': isStarred,
      if (isArchived != null) 'is_archived': isArchived,
      if (userNotes != null) 'user_notes': userNotes,
      if (priority != null) 'priority': priority,
      if (remindAt != null) 'remind_at': remindAt,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  MessageAnnotationsCompanion copyWith({
    Value<int>? messageId,
    Value<String?>? tags,
    Value<bool>? isStarred,
    Value<bool>? isArchived,
    Value<String?>? userNotes,
    Value<int?>? priority,
    Value<String?>? remindAt,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return MessageAnnotationsCompanion(
      messageId: messageId ?? this.messageId,
      tags: tags ?? this.tags,
      isStarred: isStarred ?? this.isStarred,
      isArchived: isArchived ?? this.isArchived,
      userNotes: userNotes ?? this.userNotes,
      priority: priority ?? this.priority,
      remindAt: remindAt ?? this.remindAt,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (userNotes.present) {
      map['user_notes'] = Variable<String>(userNotes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<String>(remindAt.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageAnnotationsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('tags: $tags, ')
          ..write('isStarred: $isStarred, ')
          ..write('isArchived: $isArchived, ')
          ..write('userNotes: $userNotes, ')
          ..write('priority: $priority, ')
          ..write('remindAt: $remindAt, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $HandleToParticipantOverridesTable extends HandleToParticipantOverrides
    with
        TableInfo<
          $HandleToParticipantOverridesTable,
          HandleToParticipantOverride
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandleToParticipantOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _handleIdMeta = const VerificationMeta(
    'handleId',
  );
  @override
  late final GeneratedColumn<int> handleId = GeneratedColumn<int>(
    'handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _virtualParticipantIdMeta =
      const VerificationMeta('virtualParticipantId');
  @override
  late final GeneratedColumn<int> virtualParticipantId = GeneratedColumn<int>(
    'virtual_participant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<String> reviewedAt = GeneratedColumn<String>(
    'reviewed_at',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    handleId,
    participantId,
    virtualParticipantId,
    reviewedAt,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handle_to_participant_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<HandleToParticipantOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('handle_id')) {
      context.handle(
        _handleIdMeta,
        handleId.isAcceptableOrUnknown(data['handle_id']!, _handleIdMeta),
      );
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    }
    if (data.containsKey('virtual_participant_id')) {
      context.handle(
        _virtualParticipantIdMeta,
        virtualParticipantId.isAcceptableOrUnknown(
          data['virtual_participant_id']!,
          _virtualParticipantIdMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {handleId};
  @override
  HandleToParticipantOverride map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandleToParticipantOverride(
      handleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handle_id'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      ),
      virtualParticipantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}virtual_participant_id'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_at'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $HandleToParticipantOverridesTable createAlias(String alias) {
    return $HandleToParticipantOverridesTable(attachedDatabase, alias);
  }
}

class HandleToParticipantOverride extends DataClass
    implements Insertable<HandleToParticipantOverride> {
  /// Matches working.handles_canonical.id
  final int handleId;

  /// Matches working.participants.id (null when linking to a virtual participant
  /// or when the handle is dismissed).
  final int? participantId;

  /// Matches overlay virtual_participants.id (null when linking to a real
  /// participant or when the handle is dismissed).
  final int? virtualParticipantId;

  /// ISO 8601 timestamp of when the user last reviewed this handle in the
  /// Handle Lens. Auto-set on review; semantics may be refined later.
  final String? reviewedAt;
  final String createdAtUtc;
  final String updatedAtUtc;
  const HandleToParticipantOverride({
    required this.handleId,
    this.participantId,
    this.virtualParticipantId,
    this.reviewedAt,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['handle_id'] = Variable<int>(handleId);
    if (!nullToAbsent || participantId != null) {
      map['participant_id'] = Variable<int>(participantId);
    }
    if (!nullToAbsent || virtualParticipantId != null) {
      map['virtual_participant_id'] = Variable<int>(virtualParticipantId);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<String>(reviewedAt);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  HandleToParticipantOverridesCompanion toCompanion(bool nullToAbsent) {
    return HandleToParticipantOverridesCompanion(
      handleId: Value(handleId),
      participantId: participantId == null && nullToAbsent
          ? const Value.absent()
          : Value(participantId),
      virtualParticipantId: virtualParticipantId == null && nullToAbsent
          ? const Value.absent()
          : Value(virtualParticipantId),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory HandleToParticipantOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandleToParticipantOverride(
      handleId: serializer.fromJson<int>(json['handleId']),
      participantId: serializer.fromJson<int?>(json['participantId']),
      virtualParticipantId: serializer.fromJson<int?>(
        json['virtualParticipantId'],
      ),
      reviewedAt: serializer.fromJson<String?>(json['reviewedAt']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'handleId': serializer.toJson<int>(handleId),
      'participantId': serializer.toJson<int?>(participantId),
      'virtualParticipantId': serializer.toJson<int?>(virtualParticipantId),
      'reviewedAt': serializer.toJson<String?>(reviewedAt),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  HandleToParticipantOverride copyWith({
    int? handleId,
    Value<int?> participantId = const Value.absent(),
    Value<int?> virtualParticipantId = const Value.absent(),
    Value<String?> reviewedAt = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => HandleToParticipantOverride(
    handleId: handleId ?? this.handleId,
    participantId: participantId.present
        ? participantId.value
        : this.participantId,
    virtualParticipantId: virtualParticipantId.present
        ? virtualParticipantId.value
        : this.virtualParticipantId,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  HandleToParticipantOverride copyWithCompanion(
    HandleToParticipantOverridesCompanion data,
  ) {
    return HandleToParticipantOverride(
      handleId: data.handleId.present ? data.handleId.value : this.handleId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      virtualParticipantId: data.virtualParticipantId.present
          ? data.virtualParticipantId.value
          : this.virtualParticipantId,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandleToParticipantOverride(')
          ..write('handleId: $handleId, ')
          ..write('participantId: $participantId, ')
          ..write('virtualParticipantId: $virtualParticipantId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    handleId,
    participantId,
    virtualParticipantId,
    reviewedAt,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandleToParticipantOverride &&
          other.handleId == this.handleId &&
          other.participantId == this.participantId &&
          other.virtualParticipantId == this.virtualParticipantId &&
          other.reviewedAt == this.reviewedAt &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class HandleToParticipantOverridesCompanion
    extends UpdateCompanion<HandleToParticipantOverride> {
  final Value<int> handleId;
  final Value<int?> participantId;
  final Value<int?> virtualParticipantId;
  final Value<String?> reviewedAt;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const HandleToParticipantOverridesCompanion({
    this.handleId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.virtualParticipantId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  HandleToParticipantOverridesCompanion.insert({
    this.handleId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.virtualParticipantId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<HandleToParticipantOverride> custom({
    Expression<int>? handleId,
    Expression<int>? participantId,
    Expression<int>? virtualParticipantId,
    Expression<String>? reviewedAt,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (handleId != null) 'handle_id': handleId,
      if (participantId != null) 'participant_id': participantId,
      if (virtualParticipantId != null)
        'virtual_participant_id': virtualParticipantId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  HandleToParticipantOverridesCompanion copyWith({
    Value<int>? handleId,
    Value<int?>? participantId,
    Value<int?>? virtualParticipantId,
    Value<String?>? reviewedAt,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return HandleToParticipantOverridesCompanion(
      handleId: handleId ?? this.handleId,
      participantId: participantId ?? this.participantId,
      virtualParticipantId: virtualParticipantId ?? this.virtualParticipantId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (handleId.present) {
      map['handle_id'] = Variable<int>(handleId.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (virtualParticipantId.present) {
      map['virtual_participant_id'] = Variable<int>(virtualParticipantId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<String>(reviewedAt.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandleToParticipantOverridesCompanion(')
          ..write('handleId: $handleId, ')
          ..write('participantId: $participantId, ')
          ..write('virtualParticipantId: $virtualParticipantId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $VirtualParticipantsTable extends VirtualParticipants
    with TableInfo<$VirtualParticipantsTable, VirtualParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VirtualParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    shortName,
    notes,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'virtual_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<VirtualParticipant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VirtualParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VirtualParticipant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $VirtualParticipantsTable createAlias(String alias) {
    return $VirtualParticipantsTable(attachedDatabase, alias);
  }
}

class VirtualParticipant extends DataClass
    implements Insertable<VirtualParticipant> {
  final int id;
  final String displayName;
  final String shortName;
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
  const VirtualParticipant({
    required this.id,
    required this.displayName,
    required this.shortName,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['short_name'] = Variable<String>(shortName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  VirtualParticipantsCompanion toCompanion(bool nullToAbsent) {
    return VirtualParticipantsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      shortName: Value(shortName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory VirtualParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VirtualParticipant(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      shortName: serializer.fromJson<String>(json['shortName']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'shortName': serializer.toJson<String>(shortName),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  VirtualParticipant copyWith({
    int? id,
    String? displayName,
    String? shortName,
    Value<String?> notes = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => VirtualParticipant(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    shortName: shortName ?? this.shortName,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  VirtualParticipant copyWithCompanion(VirtualParticipantsCompanion data) {
    return VirtualParticipant(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VirtualParticipant(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('shortName: $shortName, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    shortName,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VirtualParticipant &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.shortName == this.shortName &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class VirtualParticipantsCompanion extends UpdateCompanion<VirtualParticipant> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> shortName;
  final Value<String?> notes;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const VirtualParticipantsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.shortName = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  VirtualParticipantsCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required String shortName,
    this.notes = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : displayName = Value(displayName),
       shortName = Value(shortName),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<VirtualParticipant> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? shortName,
    Expression<String>? notes,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (shortName != null) 'short_name': shortName,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  VirtualParticipantsCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String>? shortName,
    Value<String?>? notes,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return VirtualParticipantsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      shortName: shortName ?? this.shortName,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VirtualParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('shortName: $shortName, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $OverlaySettingsTable extends OverlaySettings
    with TableInfo<$OverlaySettingsTable, OverlaySetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OverlaySettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'overlay_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<OverlaySetting> instance, {
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
  OverlaySetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverlaySetting(
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
  $OverlaySettingsTable createAlias(String alias) {
    return $OverlaySettingsTable(attachedDatabase, alias);
  }
}

class OverlaySetting extends DataClass implements Insertable<OverlaySetting> {
  final String key;
  final String value;
  const OverlaySetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  OverlaySettingsCompanion toCompanion(bool nullToAbsent) {
    return OverlaySettingsCompanion(key: Value(key), value: Value(value));
  }

  factory OverlaySetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverlaySetting(
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

  OverlaySetting copyWith({String? key, String? value}) =>
      OverlaySetting(key: key ?? this.key, value: value ?? this.value);
  OverlaySetting copyWithCompanion(OverlaySettingsCompanion data) {
    return OverlaySetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverlaySetting(')
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
      (other is OverlaySetting &&
          other.key == this.key &&
          other.value == this.value);
}

class OverlaySettingsCompanion extends UpdateCompanion<OverlaySetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const OverlaySettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OverlaySettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<OverlaySetting> custom({
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

  OverlaySettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return OverlaySettingsCompanion(
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
    return (StringBuffer('OverlaySettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteContactsTable extends FavoriteContacts
    with TableInfo<$FavoriteContactsTable, FavoriteContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastInteractionUtcMeta =
      const VerificationMeta('lastInteractionUtc');
  @override
  late final GeneratedColumn<String> lastInteractionUtc =
      GeneratedColumn<String>(
        'last_interaction_utc',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isFavoritedMeta = const VerificationMeta(
    'isFavorited',
  );
  @override
  late final GeneratedColumn<bool> isFavorited = GeneratedColumn<bool>(
    'is_favorited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorited" IN (0, 1))',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1970-01-01T00:00:00Z'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    participantId,
    sortOrder,
    createdAtUtc,
    lastInteractionUtc,
    isFavorited,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('last_interaction_utc')) {
      context.handle(
        _lastInteractionUtcMeta,
        lastInteractionUtc.isAcceptableOrUnknown(
          data['last_interaction_utc']!,
          _lastInteractionUtcMeta,
        ),
      );
    }
    if (data.containsKey('is_favorited')) {
      context.handle(
        _isFavoritedMeta,
        isFavorited.isAcceptableOrUnknown(
          data['is_favorited']!,
          _isFavoritedMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {participantId};
  @override
  FavoriteContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteContact(
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      lastInteractionUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_interaction_utc'],
      ),
      isFavorited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorited'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $FavoriteContactsTable createAlias(String alias) {
    return $FavoriteContactsTable(attachedDatabase, alias);
  }
}

class FavoriteContact extends DataClass implements Insertable<FavoriteContact> {
  /// Matches working.participants.id
  final int participantId;

  /// Order position (lower = higher priority, auto-managed)
  final int sortOrder;

  /// ISO8601 timestamp when contact was pinned/created
  final String createdAtUtc;

  /// ISO8601 timestamp of last user interaction (for auto-sorting)
  final String? lastInteractionUtc;

  /// Whether this contact has been explicitly favorited by the user.
  /// Rows exist for both favorites (true) and mere recents (false).
  final bool isFavorited;

  /// ISO8601 timestamp of the last mutation for bookkeeping
  final String updatedAtUtc;
  const FavoriteContact({
    required this.participantId,
    required this.sortOrder,
    required this.createdAtUtc,
    this.lastInteractionUtc,
    required this.isFavorited,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['participant_id'] = Variable<int>(participantId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    if (!nullToAbsent || lastInteractionUtc != null) {
      map['last_interaction_utc'] = Variable<String>(lastInteractionUtc);
    }
    map['is_favorited'] = Variable<bool>(isFavorited);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  FavoriteContactsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteContactsCompanion(
      participantId: Value(participantId),
      sortOrder: Value(sortOrder),
      createdAtUtc: Value(createdAtUtc),
      lastInteractionUtc: lastInteractionUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractionUtc),
      isFavorited: Value(isFavorited),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory FavoriteContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteContact(
      participantId: serializer.fromJson<int>(json['participantId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      lastInteractionUtc: serializer.fromJson<String?>(
        json['lastInteractionUtc'],
      ),
      isFavorited: serializer.fromJson<bool>(json['isFavorited']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'participantId': serializer.toJson<int>(participantId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'lastInteractionUtc': serializer.toJson<String?>(lastInteractionUtc),
      'isFavorited': serializer.toJson<bool>(isFavorited),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  FavoriteContact copyWith({
    int? participantId,
    int? sortOrder,
    String? createdAtUtc,
    Value<String?> lastInteractionUtc = const Value.absent(),
    bool? isFavorited,
    String? updatedAtUtc,
  }) => FavoriteContact(
    participantId: participantId ?? this.participantId,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    lastInteractionUtc: lastInteractionUtc.present
        ? lastInteractionUtc.value
        : this.lastInteractionUtc,
    isFavorited: isFavorited ?? this.isFavorited,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  FavoriteContact copyWithCompanion(FavoriteContactsCompanion data) {
    return FavoriteContact(
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      lastInteractionUtc: data.lastInteractionUtc.present
          ? data.lastInteractionUtc.value
          : this.lastInteractionUtc,
      isFavorited: data.isFavorited.present
          ? data.isFavorited.value
          : this.isFavorited,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteContact(')
          ..write('participantId: $participantId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('lastInteractionUtc: $lastInteractionUtc, ')
          ..write('isFavorited: $isFavorited, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    participantId,
    sortOrder,
    createdAtUtc,
    lastInteractionUtc,
    isFavorited,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteContact &&
          other.participantId == this.participantId &&
          other.sortOrder == this.sortOrder &&
          other.createdAtUtc == this.createdAtUtc &&
          other.lastInteractionUtc == this.lastInteractionUtc &&
          other.isFavorited == this.isFavorited &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class FavoriteContactsCompanion extends UpdateCompanion<FavoriteContact> {
  final Value<int> participantId;
  final Value<int> sortOrder;
  final Value<String> createdAtUtc;
  final Value<String?> lastInteractionUtc;
  final Value<bool> isFavorited;
  final Value<String> updatedAtUtc;
  const FavoriteContactsCompanion({
    this.participantId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.lastInteractionUtc = const Value.absent(),
    this.isFavorited = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  FavoriteContactsCompanion.insert({
    this.participantId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required String createdAtUtc,
    this.lastInteractionUtc = const Value.absent(),
    this.isFavorited = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  }) : createdAtUtc = Value(createdAtUtc);
  static Insertable<FavoriteContact> custom({
    Expression<int>? participantId,
    Expression<int>? sortOrder,
    Expression<String>? createdAtUtc,
    Expression<String>? lastInteractionUtc,
    Expression<bool>? isFavorited,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (participantId != null) 'participant_id': participantId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (lastInteractionUtc != null)
        'last_interaction_utc': lastInteractionUtc,
      if (isFavorited != null) 'is_favorited': isFavorited,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  FavoriteContactsCompanion copyWith({
    Value<int>? participantId,
    Value<int>? sortOrder,
    Value<String>? createdAtUtc,
    Value<String?>? lastInteractionUtc,
    Value<bool>? isFavorited,
    Value<String>? updatedAtUtc,
  }) {
    return FavoriteContactsCompanion(
      participantId: participantId ?? this.participantId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      lastInteractionUtc: lastInteractionUtc ?? this.lastInteractionUtc,
      isFavorited: isFavorited ?? this.isFavorited,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (lastInteractionUtc.present) {
      map['last_interaction_utc'] = Variable<String>(lastInteractionUtc.value);
    }
    if (isFavorited.present) {
      map['is_favorited'] = Variable<bool>(isFavorited.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteContactsCompanion(')
          ..write('participantId: $participantId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('lastInteractionUtc: $lastInteractionUtc, ')
          ..write('isFavorited: $isFavorited, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $DismissedHandlesTable extends DismissedHandles
    with TableInfo<$DismissedHandlesTable, DismissedHandle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DismissedHandlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedHandleMeta = const VerificationMeta(
    'normalizedHandle',
  );
  @override
  late final GeneratedColumn<String> normalizedHandle = GeneratedColumn<String>(
    'normalized_handle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedAtUtcMeta = const VerificationMeta(
    'dismissedAtUtc',
  );
  @override
  late final GeneratedColumn<String> dismissedAtUtc = GeneratedColumn<String>(
    'dismissed_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [normalizedHandle, dismissedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dismissed_handles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DismissedHandle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_handle')) {
      context.handle(
        _normalizedHandleMeta,
        normalizedHandle.isAcceptableOrUnknown(
          data['normalized_handle']!,
          _normalizedHandleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedHandleMeta);
    }
    if (data.containsKey('dismissed_at_utc')) {
      context.handle(
        _dismissedAtUtcMeta,
        dismissedAtUtc.isAcceptableOrUnknown(
          data['dismissed_at_utc']!,
          _dismissedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dismissedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {normalizedHandle};
  @override
  DismissedHandle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DismissedHandle(
      normalizedHandle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_handle'],
      )!,
      dismissedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dismissed_at_utc'],
      )!,
    );
  }

  @override
  $DismissedHandlesTable createAlias(String alias) {
    return $DismissedHandlesTable(attachedDatabase, alias);
  }
}

class DismissedHandle extends DataClass implements Insertable<DismissedHandle> {
  /// Normalized handle identifier (phone: digits only with optional leading +;
  /// email: lowercase). This is the PRIMARY KEY, not the transient handle ID.
  final String normalizedHandle;

  /// ISO 8601 timestamp of when this handle was dismissed.
  final String dismissedAtUtc;
  const DismissedHandle({
    required this.normalizedHandle,
    required this.dismissedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_handle'] = Variable<String>(normalizedHandle);
    map['dismissed_at_utc'] = Variable<String>(dismissedAtUtc);
    return map;
  }

  DismissedHandlesCompanion toCompanion(bool nullToAbsent) {
    return DismissedHandlesCompanion(
      normalizedHandle: Value(normalizedHandle),
      dismissedAtUtc: Value(dismissedAtUtc),
    );
  }

  factory DismissedHandle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DismissedHandle(
      normalizedHandle: serializer.fromJson<String>(json['normalizedHandle']),
      dismissedAtUtc: serializer.fromJson<String>(json['dismissedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedHandle': serializer.toJson<String>(normalizedHandle),
      'dismissedAtUtc': serializer.toJson<String>(dismissedAtUtc),
    };
  }

  DismissedHandle copyWith({
    String? normalizedHandle,
    String? dismissedAtUtc,
  }) => DismissedHandle(
    normalizedHandle: normalizedHandle ?? this.normalizedHandle,
    dismissedAtUtc: dismissedAtUtc ?? this.dismissedAtUtc,
  );
  DismissedHandle copyWithCompanion(DismissedHandlesCompanion data) {
    return DismissedHandle(
      normalizedHandle: data.normalizedHandle.present
          ? data.normalizedHandle.value
          : this.normalizedHandle,
      dismissedAtUtc: data.dismissedAtUtc.present
          ? data.dismissedAtUtc.value
          : this.dismissedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DismissedHandle(')
          ..write('normalizedHandle: $normalizedHandle, ')
          ..write('dismissedAtUtc: $dismissedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(normalizedHandle, dismissedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DismissedHandle &&
          other.normalizedHandle == this.normalizedHandle &&
          other.dismissedAtUtc == this.dismissedAtUtc);
}

class DismissedHandlesCompanion extends UpdateCompanion<DismissedHandle> {
  final Value<String> normalizedHandle;
  final Value<String> dismissedAtUtc;
  final Value<int> rowid;
  const DismissedHandlesCompanion({
    this.normalizedHandle = const Value.absent(),
    this.dismissedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DismissedHandlesCompanion.insert({
    required String normalizedHandle,
    required String dismissedAtUtc,
    this.rowid = const Value.absent(),
  }) : normalizedHandle = Value(normalizedHandle),
       dismissedAtUtc = Value(dismissedAtUtc);
  static Insertable<DismissedHandle> custom({
    Expression<String>? normalizedHandle,
    Expression<String>? dismissedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedHandle != null) 'normalized_handle': normalizedHandle,
      if (dismissedAtUtc != null) 'dismissed_at_utc': dismissedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DismissedHandlesCompanion copyWith({
    Value<String>? normalizedHandle,
    Value<String>? dismissedAtUtc,
    Value<int>? rowid,
  }) {
    return DismissedHandlesCompanion(
      normalizedHandle: normalizedHandle ?? this.normalizedHandle,
      dismissedAtUtc: dismissedAtUtc ?? this.dismissedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedHandle.present) {
      map['normalized_handle'] = Variable<String>(normalizedHandle.value);
    }
    if (dismissedAtUtc.present) {
      map['dismissed_at_utc'] = Variable<String>(dismissedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DismissedHandlesCompanion(')
          ..write('normalizedHandle: $normalizedHandle, ')
          ..write('dismissedAtUtc: $dismissedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OverlayDatabase extends GeneratedDatabase {
  _$OverlayDatabase(QueryExecutor e) : super(e);
  $OverlayDatabaseManager get managers => $OverlayDatabaseManager(this);
  late final $ParticipantOverridesTable participantOverrides =
      $ParticipantOverridesTable(this);
  late final $ChatOverridesTable chatOverrides = $ChatOverridesTable(this);
  late final $MessageAnnotationsTable messageAnnotations =
      $MessageAnnotationsTable(this);
  late final $HandleToParticipantOverridesTable handleToParticipantOverrides =
      $HandleToParticipantOverridesTable(this);
  late final $VirtualParticipantsTable virtualParticipants =
      $VirtualParticipantsTable(this);
  late final $OverlaySettingsTable overlaySettings = $OverlaySettingsTable(
    this,
  );
  late final $FavoriteContactsTable favoriteContacts = $FavoriteContactsTable(
    this,
  );
  late final $DismissedHandlesTable dismissedHandles = $DismissedHandlesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    participantOverrides,
    chatOverrides,
    messageAnnotations,
    handleToParticipantOverrides,
    virtualParticipants,
    overlaySettings,
    favoriteContacts,
    dismissedHandles,
  ];
}

typedef $$ParticipantOverridesTableCreateCompanionBuilder =
    ParticipantOverridesCompanion Function({
      Value<int> participantId,
      Value<int?> nameMode,
      Value<String?> nickname,
      Value<String?> displayNameOverride,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$ParticipantOverridesTableUpdateCompanionBuilder =
    ParticipantOverridesCompanion Function({
      Value<int> participantId,
      Value<int?> nameMode,
      Value<String?> nickname,
      Value<String?> displayNameOverride,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$ParticipantOverridesTableFilterComposer
    extends Composer<_$OverlayDatabase, $ParticipantOverridesTable> {
  $$ParticipantOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nameMode => $composableBuilder(
    column: $table.nameMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayNameOverride => $composableBuilder(
    column: $table.displayNameOverride,
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
}

class $$ParticipantOverridesTableOrderingComposer
    extends Composer<_$OverlayDatabase, $ParticipantOverridesTable> {
  $$ParticipantOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nameMode => $composableBuilder(
    column: $table.nameMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayNameOverride => $composableBuilder(
    column: $table.displayNameOverride,
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
}

class $$ParticipantOverridesTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $ParticipantOverridesTable> {
  $$ParticipantOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nameMode =>
      $composableBuilder(column: $table.nameMode, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get displayNameOverride => $composableBuilder(
    column: $table.displayNameOverride,
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
}

class $$ParticipantOverridesTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $ParticipantOverridesTable,
          ParticipantOverride,
          $$ParticipantOverridesTableFilterComposer,
          $$ParticipantOverridesTableOrderingComposer,
          $$ParticipantOverridesTableAnnotationComposer,
          $$ParticipantOverridesTableCreateCompanionBuilder,
          $$ParticipantOverridesTableUpdateCompanionBuilder,
          (
            ParticipantOverride,
            BaseReferences<
              _$OverlayDatabase,
              $ParticipantOverridesTable,
              ParticipantOverride
            >,
          ),
          ParticipantOverride,
          PrefetchHooks Function()
        > {
  $$ParticipantOverridesTableTableManager(
    _$OverlayDatabase db,
    $ParticipantOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ParticipantOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<int?> nameMode = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> displayNameOverride = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => ParticipantOverridesCompanion(
                participantId: participantId,
                nameMode: nameMode,
                nickname: nickname,
                displayNameOverride: displayNameOverride,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<int?> nameMode = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> displayNameOverride = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => ParticipantOverridesCompanion.insert(
                participantId: participantId,
                nameMode: nameMode,
                nickname: nickname,
                displayNameOverride: displayNameOverride,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParticipantOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $ParticipantOverridesTable,
      ParticipantOverride,
      $$ParticipantOverridesTableFilterComposer,
      $$ParticipantOverridesTableOrderingComposer,
      $$ParticipantOverridesTableAnnotationComposer,
      $$ParticipantOverridesTableCreateCompanionBuilder,
      $$ParticipantOverridesTableUpdateCompanionBuilder,
      (
        ParticipantOverride,
        BaseReferences<
          _$OverlayDatabase,
          $ParticipantOverridesTable,
          ParticipantOverride
        >,
      ),
      ParticipantOverride,
      PrefetchHooks Function()
    >;
typedef $$ChatOverridesTableCreateCompanionBuilder =
    ChatOverridesCompanion Function({
      Value<int> chatId,
      Value<String?> customName,
      Value<String?> customColor,
      Value<String?> notes,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$ChatOverridesTableUpdateCompanionBuilder =
    ChatOverridesCompanion Function({
      Value<int> chatId,
      Value<String?> customName,
      Value<String?> customColor,
      Value<String?> notes,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$ChatOverridesTableFilterComposer
    extends Composer<_$OverlayDatabase, $ChatOverridesTable> {
  $$ChatOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customColor => $composableBuilder(
    column: $table.customColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$ChatOverridesTableOrderingComposer
    extends Composer<_$OverlayDatabase, $ChatOverridesTable> {
  $$ChatOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customColor => $composableBuilder(
    column: $table.customColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$ChatOverridesTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $ChatOverridesTable> {
  $$ChatOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customColor => $composableBuilder(
    column: $table.customColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$ChatOverridesTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $ChatOverridesTable,
          ChatOverride,
          $$ChatOverridesTableFilterComposer,
          $$ChatOverridesTableOrderingComposer,
          $$ChatOverridesTableAnnotationComposer,
          $$ChatOverridesTableCreateCompanionBuilder,
          $$ChatOverridesTableUpdateCompanionBuilder,
          (
            ChatOverride,
            BaseReferences<
              _$OverlayDatabase,
              $ChatOverridesTable,
              ChatOverride
            >,
          ),
          ChatOverride,
          PrefetchHooks Function()
        > {
  $$ChatOverridesTableTableManager(
    _$OverlayDatabase db,
    $ChatOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customColor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => ChatOverridesCompanion(
                chatId: chatId,
                customName: customName,
                customColor: customColor,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customColor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => ChatOverridesCompanion.insert(
                chatId: chatId,
                customName: customName,
                customColor: customColor,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $ChatOverridesTable,
      ChatOverride,
      $$ChatOverridesTableFilterComposer,
      $$ChatOverridesTableOrderingComposer,
      $$ChatOverridesTableAnnotationComposer,
      $$ChatOverridesTableCreateCompanionBuilder,
      $$ChatOverridesTableUpdateCompanionBuilder,
      (
        ChatOverride,
        BaseReferences<_$OverlayDatabase, $ChatOverridesTable, ChatOverride>,
      ),
      ChatOverride,
      PrefetchHooks Function()
    >;
typedef $$MessageAnnotationsTableCreateCompanionBuilder =
    MessageAnnotationsCompanion Function({
      Value<int> messageId,
      Value<String?> tags,
      Value<bool> isStarred,
      Value<bool> isArchived,
      Value<String?> userNotes,
      Value<int?> priority,
      Value<String?> remindAt,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$MessageAnnotationsTableUpdateCompanionBuilder =
    MessageAnnotationsCompanion Function({
      Value<int> messageId,
      Value<String?> tags,
      Value<bool> isStarred,
      Value<bool> isArchived,
      Value<String?> userNotes,
      Value<int?> priority,
      Value<String?> remindAt,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$MessageAnnotationsTableFilterComposer
    extends Composer<_$OverlayDatabase, $MessageAnnotationsTable> {
  $$MessageAnnotationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userNotes => $composableBuilder(
    column: $table.userNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindAt => $composableBuilder(
    column: $table.remindAt,
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
}

class $$MessageAnnotationsTableOrderingComposer
    extends Composer<_$OverlayDatabase, $MessageAnnotationsTable> {
  $$MessageAnnotationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userNotes => $composableBuilder(
    column: $table.userNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindAt => $composableBuilder(
    column: $table.remindAt,
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
}

class $$MessageAnnotationsTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $MessageAnnotationsTable> {
  $$MessageAnnotationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userNotes =>
      $composableBuilder(column: $table.userNotes, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$MessageAnnotationsTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $MessageAnnotationsTable,
          MessageAnnotation,
          $$MessageAnnotationsTableFilterComposer,
          $$MessageAnnotationsTableOrderingComposer,
          $$MessageAnnotationsTableAnnotationComposer,
          $$MessageAnnotationsTableCreateCompanionBuilder,
          $$MessageAnnotationsTableUpdateCompanionBuilder,
          (
            MessageAnnotation,
            BaseReferences<
              _$OverlayDatabase,
              $MessageAnnotationsTable,
              MessageAnnotation
            >,
          ),
          MessageAnnotation,
          PrefetchHooks Function()
        > {
  $$MessageAnnotationsTableTableManager(
    _$OverlayDatabase db,
    $MessageAnnotationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageAnnotationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageAnnotationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageAnnotationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> messageId = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> userNotes = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<String?> remindAt = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => MessageAnnotationsCompanion(
                messageId: messageId,
                tags: tags,
                isStarred: isStarred,
                isArchived: isArchived,
                userNotes: userNotes,
                priority: priority,
                remindAt: remindAt,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> messageId = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> userNotes = const Value.absent(),
                Value<int?> priority = const Value.absent(),
                Value<String?> remindAt = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => MessageAnnotationsCompanion.insert(
                messageId: messageId,
                tags: tags,
                isStarred: isStarred,
                isArchived: isArchived,
                userNotes: userNotes,
                priority: priority,
                remindAt: remindAt,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageAnnotationsTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $MessageAnnotationsTable,
      MessageAnnotation,
      $$MessageAnnotationsTableFilterComposer,
      $$MessageAnnotationsTableOrderingComposer,
      $$MessageAnnotationsTableAnnotationComposer,
      $$MessageAnnotationsTableCreateCompanionBuilder,
      $$MessageAnnotationsTableUpdateCompanionBuilder,
      (
        MessageAnnotation,
        BaseReferences<
          _$OverlayDatabase,
          $MessageAnnotationsTable,
          MessageAnnotation
        >,
      ),
      MessageAnnotation,
      PrefetchHooks Function()
    >;
typedef $$HandleToParticipantOverridesTableCreateCompanionBuilder =
    HandleToParticipantOverridesCompanion Function({
      Value<int> handleId,
      Value<int?> participantId,
      Value<int?> virtualParticipantId,
      Value<String?> reviewedAt,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$HandleToParticipantOverridesTableUpdateCompanionBuilder =
    HandleToParticipantOverridesCompanion Function({
      Value<int> handleId,
      Value<int?> participantId,
      Value<int?> virtualParticipantId,
      Value<String?> reviewedAt,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$HandleToParticipantOverridesTableFilterComposer
    extends Composer<_$OverlayDatabase, $HandleToParticipantOverridesTable> {
  $$HandleToParticipantOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get handleId => $composableBuilder(
    column: $table.handleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get virtualParticipantId => $composableBuilder(
    column: $table.virtualParticipantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
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
}

class $$HandleToParticipantOverridesTableOrderingComposer
    extends Composer<_$OverlayDatabase, $HandleToParticipantOverridesTable> {
  $$HandleToParticipantOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get handleId => $composableBuilder(
    column: $table.handleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get virtualParticipantId => $composableBuilder(
    column: $table.virtualParticipantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
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
}

class $$HandleToParticipantOverridesTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $HandleToParticipantOverridesTable> {
  $$HandleToParticipantOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get handleId =>
      $composableBuilder(column: $table.handleId, builder: (column) => column);

  GeneratedColumn<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get virtualParticipantId => $composableBuilder(
    column: $table.virtualParticipantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
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
}

class $$HandleToParticipantOverridesTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $HandleToParticipantOverridesTable,
          HandleToParticipantOverride,
          $$HandleToParticipantOverridesTableFilterComposer,
          $$HandleToParticipantOverridesTableOrderingComposer,
          $$HandleToParticipantOverridesTableAnnotationComposer,
          $$HandleToParticipantOverridesTableCreateCompanionBuilder,
          $$HandleToParticipantOverridesTableUpdateCompanionBuilder,
          (
            HandleToParticipantOverride,
            BaseReferences<
              _$OverlayDatabase,
              $HandleToParticipantOverridesTable,
              HandleToParticipantOverride
            >,
          ),
          HandleToParticipantOverride,
          PrefetchHooks Function()
        > {
  $$HandleToParticipantOverridesTableTableManager(
    _$OverlayDatabase db,
    $HandleToParticipantOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandleToParticipantOverridesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HandleToParticipantOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HandleToParticipantOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> handleId = const Value.absent(),
                Value<int?> participantId = const Value.absent(),
                Value<int?> virtualParticipantId = const Value.absent(),
                Value<String?> reviewedAt = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => HandleToParticipantOverridesCompanion(
                handleId: handleId,
                participantId: participantId,
                virtualParticipantId: virtualParticipantId,
                reviewedAt: reviewedAt,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> handleId = const Value.absent(),
                Value<int?> participantId = const Value.absent(),
                Value<int?> virtualParticipantId = const Value.absent(),
                Value<String?> reviewedAt = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => HandleToParticipantOverridesCompanion.insert(
                handleId: handleId,
                participantId: participantId,
                virtualParticipantId: virtualParticipantId,
                reviewedAt: reviewedAt,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HandleToParticipantOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $HandleToParticipantOverridesTable,
      HandleToParticipantOverride,
      $$HandleToParticipantOverridesTableFilterComposer,
      $$HandleToParticipantOverridesTableOrderingComposer,
      $$HandleToParticipantOverridesTableAnnotationComposer,
      $$HandleToParticipantOverridesTableCreateCompanionBuilder,
      $$HandleToParticipantOverridesTableUpdateCompanionBuilder,
      (
        HandleToParticipantOverride,
        BaseReferences<
          _$OverlayDatabase,
          $HandleToParticipantOverridesTable,
          HandleToParticipantOverride
        >,
      ),
      HandleToParticipantOverride,
      PrefetchHooks Function()
    >;
typedef $$VirtualParticipantsTableCreateCompanionBuilder =
    VirtualParticipantsCompanion Function({
      Value<int> id,
      required String displayName,
      required String shortName,
      Value<String?> notes,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$VirtualParticipantsTableUpdateCompanionBuilder =
    VirtualParticipantsCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String> shortName,
      Value<String?> notes,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$VirtualParticipantsTableFilterComposer
    extends Composer<_$OverlayDatabase, $VirtualParticipantsTable> {
  $$VirtualParticipantsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$VirtualParticipantsTableOrderingComposer
    extends Composer<_$OverlayDatabase, $VirtualParticipantsTable> {
  $$VirtualParticipantsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$VirtualParticipantsTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $VirtualParticipantsTable> {
  $$VirtualParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$VirtualParticipantsTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $VirtualParticipantsTable,
          VirtualParticipant,
          $$VirtualParticipantsTableFilterComposer,
          $$VirtualParticipantsTableOrderingComposer,
          $$VirtualParticipantsTableAnnotationComposer,
          $$VirtualParticipantsTableCreateCompanionBuilder,
          $$VirtualParticipantsTableUpdateCompanionBuilder,
          (
            VirtualParticipant,
            BaseReferences<
              _$OverlayDatabase,
              $VirtualParticipantsTable,
              VirtualParticipant
            >,
          ),
          VirtualParticipant,
          PrefetchHooks Function()
        > {
  $$VirtualParticipantsTableTableManager(
    _$OverlayDatabase db,
    $VirtualParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VirtualParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VirtualParticipantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VirtualParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => VirtualParticipantsCompanion(
                id: id,
                displayName: displayName,
                shortName: shortName,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required String shortName,
                Value<String?> notes = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => VirtualParticipantsCompanion.insert(
                id: id,
                displayName: displayName,
                shortName: shortName,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VirtualParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $VirtualParticipantsTable,
      VirtualParticipant,
      $$VirtualParticipantsTableFilterComposer,
      $$VirtualParticipantsTableOrderingComposer,
      $$VirtualParticipantsTableAnnotationComposer,
      $$VirtualParticipantsTableCreateCompanionBuilder,
      $$VirtualParticipantsTableUpdateCompanionBuilder,
      (
        VirtualParticipant,
        BaseReferences<
          _$OverlayDatabase,
          $VirtualParticipantsTable,
          VirtualParticipant
        >,
      ),
      VirtualParticipant,
      PrefetchHooks Function()
    >;
typedef $$OverlaySettingsTableCreateCompanionBuilder =
    OverlaySettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$OverlaySettingsTableUpdateCompanionBuilder =
    OverlaySettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$OverlaySettingsTableFilterComposer
    extends Composer<_$OverlayDatabase, $OverlaySettingsTable> {
  $$OverlaySettingsTableFilterComposer({
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

class $$OverlaySettingsTableOrderingComposer
    extends Composer<_$OverlayDatabase, $OverlaySettingsTable> {
  $$OverlaySettingsTableOrderingComposer({
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

class $$OverlaySettingsTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $OverlaySettingsTable> {
  $$OverlaySettingsTableAnnotationComposer({
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

class $$OverlaySettingsTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $OverlaySettingsTable,
          OverlaySetting,
          $$OverlaySettingsTableFilterComposer,
          $$OverlaySettingsTableOrderingComposer,
          $$OverlaySettingsTableAnnotationComposer,
          $$OverlaySettingsTableCreateCompanionBuilder,
          $$OverlaySettingsTableUpdateCompanionBuilder,
          (
            OverlaySetting,
            BaseReferences<
              _$OverlayDatabase,
              $OverlaySettingsTable,
              OverlaySetting
            >,
          ),
          OverlaySetting,
          PrefetchHooks Function()
        > {
  $$OverlaySettingsTableTableManager(
    _$OverlayDatabase db,
    $OverlaySettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OverlaySettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OverlaySettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OverlaySettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OverlaySettingsCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => OverlaySettingsCompanion.insert(
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

typedef $$OverlaySettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $OverlaySettingsTable,
      OverlaySetting,
      $$OverlaySettingsTableFilterComposer,
      $$OverlaySettingsTableOrderingComposer,
      $$OverlaySettingsTableAnnotationComposer,
      $$OverlaySettingsTableCreateCompanionBuilder,
      $$OverlaySettingsTableUpdateCompanionBuilder,
      (
        OverlaySetting,
        BaseReferences<
          _$OverlayDatabase,
          $OverlaySettingsTable,
          OverlaySetting
        >,
      ),
      OverlaySetting,
      PrefetchHooks Function()
    >;
typedef $$FavoriteContactsTableCreateCompanionBuilder =
    FavoriteContactsCompanion Function({
      Value<int> participantId,
      Value<int> sortOrder,
      required String createdAtUtc,
      Value<String?> lastInteractionUtc,
      Value<bool> isFavorited,
      Value<String> updatedAtUtc,
    });
typedef $$FavoriteContactsTableUpdateCompanionBuilder =
    FavoriteContactsCompanion Function({
      Value<int> participantId,
      Value<int> sortOrder,
      Value<String> createdAtUtc,
      Value<String?> lastInteractionUtc,
      Value<bool> isFavorited,
      Value<String> updatedAtUtc,
    });

class $$FavoriteContactsTableFilterComposer
    extends Composer<_$OverlayDatabase, $FavoriteContactsTable> {
  $$FavoriteContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastInteractionUtc => $composableBuilder(
    column: $table.lastInteractionUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorited => $composableBuilder(
    column: $table.isFavorited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteContactsTableOrderingComposer
    extends Composer<_$OverlayDatabase, $FavoriteContactsTable> {
  $$FavoriteContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastInteractionUtc => $composableBuilder(
    column: $table.lastInteractionUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorited => $composableBuilder(
    column: $table.isFavorited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteContactsTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $FavoriteContactsTable> {
  $$FavoriteContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastInteractionUtc => $composableBuilder(
    column: $table.lastInteractionUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorited => $composableBuilder(
    column: $table.isFavorited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$FavoriteContactsTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $FavoriteContactsTable,
          FavoriteContact,
          $$FavoriteContactsTableFilterComposer,
          $$FavoriteContactsTableOrderingComposer,
          $$FavoriteContactsTableAnnotationComposer,
          $$FavoriteContactsTableCreateCompanionBuilder,
          $$FavoriteContactsTableUpdateCompanionBuilder,
          (
            FavoriteContact,
            BaseReferences<
              _$OverlayDatabase,
              $FavoriteContactsTable,
              FavoriteContact
            >,
          ),
          FavoriteContact,
          PrefetchHooks Function()
        > {
  $$FavoriteContactsTableTableManager(
    _$OverlayDatabase db,
    $FavoriteContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String?> lastInteractionUtc = const Value.absent(),
                Value<bool> isFavorited = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => FavoriteContactsCompanion(
                participantId: participantId,
                sortOrder: sortOrder,
                createdAtUtc: createdAtUtc,
                lastInteractionUtc: lastInteractionUtc,
                isFavorited: isFavorited,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required String createdAtUtc,
                Value<String?> lastInteractionUtc = const Value.absent(),
                Value<bool> isFavorited = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => FavoriteContactsCompanion.insert(
                participantId: participantId,
                sortOrder: sortOrder,
                createdAtUtc: createdAtUtc,
                lastInteractionUtc: lastInteractionUtc,
                isFavorited: isFavorited,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $FavoriteContactsTable,
      FavoriteContact,
      $$FavoriteContactsTableFilterComposer,
      $$FavoriteContactsTableOrderingComposer,
      $$FavoriteContactsTableAnnotationComposer,
      $$FavoriteContactsTableCreateCompanionBuilder,
      $$FavoriteContactsTableUpdateCompanionBuilder,
      (
        FavoriteContact,
        BaseReferences<
          _$OverlayDatabase,
          $FavoriteContactsTable,
          FavoriteContact
        >,
      ),
      FavoriteContact,
      PrefetchHooks Function()
    >;
typedef $$DismissedHandlesTableCreateCompanionBuilder =
    DismissedHandlesCompanion Function({
      required String normalizedHandle,
      required String dismissedAtUtc,
      Value<int> rowid,
    });
typedef $$DismissedHandlesTableUpdateCompanionBuilder =
    DismissedHandlesCompanion Function({
      Value<String> normalizedHandle,
      Value<String> dismissedAtUtc,
      Value<int> rowid,
    });

class $$DismissedHandlesTableFilterComposer
    extends Composer<_$OverlayDatabase, $DismissedHandlesTable> {
  $$DismissedHandlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedHandle => $composableBuilder(
    column: $table.normalizedHandle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dismissedAtUtc => $composableBuilder(
    column: $table.dismissedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DismissedHandlesTableOrderingComposer
    extends Composer<_$OverlayDatabase, $DismissedHandlesTable> {
  $$DismissedHandlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedHandle => $composableBuilder(
    column: $table.normalizedHandle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dismissedAtUtc => $composableBuilder(
    column: $table.dismissedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DismissedHandlesTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $DismissedHandlesTable> {
  $$DismissedHandlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedHandle => $composableBuilder(
    column: $table.normalizedHandle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dismissedAtUtc => $composableBuilder(
    column: $table.dismissedAtUtc,
    builder: (column) => column,
  );
}

class $$DismissedHandlesTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $DismissedHandlesTable,
          DismissedHandle,
          $$DismissedHandlesTableFilterComposer,
          $$DismissedHandlesTableOrderingComposer,
          $$DismissedHandlesTableAnnotationComposer,
          $$DismissedHandlesTableCreateCompanionBuilder,
          $$DismissedHandlesTableUpdateCompanionBuilder,
          (
            DismissedHandle,
            BaseReferences<
              _$OverlayDatabase,
              $DismissedHandlesTable,
              DismissedHandle
            >,
          ),
          DismissedHandle,
          PrefetchHooks Function()
        > {
  $$DismissedHandlesTableTableManager(
    _$OverlayDatabase db,
    $DismissedHandlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DismissedHandlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DismissedHandlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DismissedHandlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> normalizedHandle = const Value.absent(),
                Value<String> dismissedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DismissedHandlesCompanion(
                normalizedHandle: normalizedHandle,
                dismissedAtUtc: dismissedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedHandle,
                required String dismissedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => DismissedHandlesCompanion.insert(
                normalizedHandle: normalizedHandle,
                dismissedAtUtc: dismissedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DismissedHandlesTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $DismissedHandlesTable,
      DismissedHandle,
      $$DismissedHandlesTableFilterComposer,
      $$DismissedHandlesTableOrderingComposer,
      $$DismissedHandlesTableAnnotationComposer,
      $$DismissedHandlesTableCreateCompanionBuilder,
      $$DismissedHandlesTableUpdateCompanionBuilder,
      (
        DismissedHandle,
        BaseReferences<
          _$OverlayDatabase,
          $DismissedHandlesTable,
          DismissedHandle
        >,
      ),
      DismissedHandle,
      PrefetchHooks Function()
    >;

class $OverlayDatabaseManager {
  final _$OverlayDatabase _db;
  $OverlayDatabaseManager(this._db);
  $$ParticipantOverridesTableTableManager get participantOverrides =>
      $$ParticipantOverridesTableTableManager(_db, _db.participantOverrides);
  $$ChatOverridesTableTableManager get chatOverrides =>
      $$ChatOverridesTableTableManager(_db, _db.chatOverrides);
  $$MessageAnnotationsTableTableManager get messageAnnotations =>
      $$MessageAnnotationsTableTableManager(_db, _db.messageAnnotations);
  $$HandleToParticipantOverridesTableTableManager
  get handleToParticipantOverrides =>
      $$HandleToParticipantOverridesTableTableManager(
        _db,
        _db.handleToParticipantOverrides,
      );
  $$VirtualParticipantsTableTableManager get virtualParticipants =>
      $$VirtualParticipantsTableTableManager(_db, _db.virtualParticipants);
  $$OverlaySettingsTableTableManager get overlaySettings =>
      $$OverlaySettingsTableTableManager(_db, _db.overlaySettings);
  $$FavoriteContactsTableTableManager get favoriteContacts =>
      $$FavoriteContactsTableTableManager(_db, _db.favoriteContacts);
  $$DismissedHandlesTableTableManager get dismissedHandles =>
      $$DismissedHandlesTableTableManager(_db, _db.dismissedHandles);
}
