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
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMutedMeta = const VerificationMeta(
    'isMuted',
  );
  @override
  late final GeneratedColumn<bool> isMuted = GeneratedColumn<bool>(
    'is_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    participantId,
    shortName,
    isMuted,
    notes,
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
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    }
    if (data.containsKey('is_muted')) {
      context.handle(
        _isMutedMeta,
        isMuted.isAcceptableOrUnknown(data['is_muted']!, _isMutedMeta),
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
  Set<GeneratedColumn> get $primaryKey => {participantId};
  @override
  ParticipantOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantOverride(
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      ),
      isMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_muted'],
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
  $ParticipantOverridesTable createAlias(String alias) {
    return $ParticipantOverridesTable(attachedDatabase, alias);
  }
}

class ParticipantOverride extends DataClass
    implements Insertable<ParticipantOverride> {
  /// Matches working.participants.id
  final int participantId;

  /// User's custom short name for this participant
  final String? shortName;

  /// Whether user has muted this participant
  final bool isMuted;

  /// User's custom notes about this participant
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
  const ParticipantOverride({
    required this.participantId,
    this.shortName,
    required this.isMuted,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['participant_id'] = Variable<int>(participantId);
    if (!nullToAbsent || shortName != null) {
      map['short_name'] = Variable<String>(shortName);
    }
    map['is_muted'] = Variable<bool>(isMuted);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  ParticipantOverridesCompanion toCompanion(bool nullToAbsent) {
    return ParticipantOverridesCompanion(
      participantId: Value(participantId),
      shortName: shortName == null && nullToAbsent
          ? const Value.absent()
          : Value(shortName),
      isMuted: Value(isMuted),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
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
      shortName: serializer.fromJson<String?>(json['shortName']),
      isMuted: serializer.fromJson<bool>(json['isMuted']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'participantId': serializer.toJson<int>(participantId),
      'shortName': serializer.toJson<String?>(shortName),
      'isMuted': serializer.toJson<bool>(isMuted),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  ParticipantOverride copyWith({
    int? participantId,
    Value<String?> shortName = const Value.absent(),
    bool? isMuted,
    Value<String?> notes = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => ParticipantOverride(
    participantId: participantId ?? this.participantId,
    shortName: shortName.present ? shortName.value : this.shortName,
    isMuted: isMuted ?? this.isMuted,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ParticipantOverride copyWithCompanion(ParticipantOverridesCompanion data) {
    return ParticipantOverride(
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      isMuted: data.isMuted.present ? data.isMuted.value : this.isMuted,
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
    return (StringBuffer('ParticipantOverride(')
          ..write('participantId: $participantId, ')
          ..write('shortName: $shortName, ')
          ..write('isMuted: $isMuted, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    participantId,
    shortName,
    isMuted,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantOverride &&
          other.participantId == this.participantId &&
          other.shortName == this.shortName &&
          other.isMuted == this.isMuted &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ParticipantOverridesCompanion
    extends UpdateCompanion<ParticipantOverride> {
  final Value<int> participantId;
  final Value<String?> shortName;
  final Value<bool> isMuted;
  final Value<String?> notes;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const ParticipantOverridesCompanion({
    this.participantId = const Value.absent(),
    this.shortName = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  ParticipantOverridesCompanion.insert({
    this.participantId = const Value.absent(),
    this.shortName = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ParticipantOverride> custom({
    Expression<int>? participantId,
    Expression<String>? shortName,
    Expression<bool>? isMuted,
    Expression<String>? notes,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (participantId != null) 'participant_id': participantId,
      if (shortName != null) 'short_name': shortName,
      if (isMuted != null) 'is_muted': isMuted,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  ParticipantOverridesCompanion copyWith({
    Value<int>? participantId,
    Value<String?>? shortName,
    Value<bool>? isMuted,
    Value<String?>? notes,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return ParticipantOverridesCompanion(
      participantId: participantId ?? this.participantId,
      shortName: shortName ?? this.shortName,
      isMuted: isMuted ?? this.isMuted,
      notes: notes ?? this.notes,
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
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (isMuted.present) {
      map['is_muted'] = Variable<bool>(isMuted.value);
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
    return (StringBuffer('ParticipantOverridesCompanion(')
          ..write('participantId: $participantId, ')
          ..write('shortName: $shortName, ')
          ..write('isMuted: $isMuted, ')
          ..write('notes: $notes, ')
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
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user_manual'),
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
    source,
    confidence,
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
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
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
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
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
  /// Matches working.handles.id
  final int handleId;

  /// Matches working.participants.id
  final int participantId;

  /// Source of the link (always 'user_manual' for manual overrides)
  final String source;

  /// Confidence level (1.0 for user-confirmed manual links)
  final double confidence;
  final String createdAtUtc;
  final String updatedAtUtc;
  const HandleToParticipantOverride({
    required this.handleId,
    required this.participantId,
    required this.source,
    required this.confidence,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['handle_id'] = Variable<int>(handleId);
    map['participant_id'] = Variable<int>(participantId);
    map['source'] = Variable<String>(source);
    map['confidence'] = Variable<double>(confidence);
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  HandleToParticipantOverridesCompanion toCompanion(bool nullToAbsent) {
    return HandleToParticipantOverridesCompanion(
      handleId: Value(handleId),
      participantId: Value(participantId),
      source: Value(source),
      confidence: Value(confidence),
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
      participantId: serializer.fromJson<int>(json['participantId']),
      source: serializer.fromJson<String>(json['source']),
      confidence: serializer.fromJson<double>(json['confidence']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'handleId': serializer.toJson<int>(handleId),
      'participantId': serializer.toJson<int>(participantId),
      'source': serializer.toJson<String>(source),
      'confidence': serializer.toJson<double>(confidence),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  HandleToParticipantOverride copyWith({
    int? handleId,
    int? participantId,
    String? source,
    double? confidence,
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => HandleToParticipantOverride(
    handleId: handleId ?? this.handleId,
    participantId: participantId ?? this.participantId,
    source: source ?? this.source,
    confidence: confidence ?? this.confidence,
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
      source: data.source.present ? data.source.value : this.source,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
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
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    handleId,
    participantId,
    source,
    confidence,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandleToParticipantOverride &&
          other.handleId == this.handleId &&
          other.participantId == this.participantId &&
          other.source == this.source &&
          other.confidence == this.confidence &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class HandleToParticipantOverridesCompanion
    extends UpdateCompanion<HandleToParticipantOverride> {
  final Value<int> handleId;
  final Value<int> participantId;
  final Value<String> source;
  final Value<double> confidence;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const HandleToParticipantOverridesCompanion({
    this.handleId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  HandleToParticipantOverridesCompanion.insert({
    this.handleId = const Value.absent(),
    required int participantId,
    this.source = const Value.absent(),
    this.confidence = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : participantId = Value(participantId),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<HandleToParticipantOverride> custom({
    Expression<int>? handleId,
    Expression<int>? participantId,
    Expression<String>? source,
    Expression<double>? confidence,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (handleId != null) 'handle_id': handleId,
      if (participantId != null) 'participant_id': participantId,
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  HandleToParticipantOverridesCompanion copyWith({
    Value<int>? handleId,
    Value<int>? participantId,
    Value<String>? source,
    Value<double>? confidence,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return HandleToParticipantOverridesCompanion(
      handleId: handleId ?? this.handleId,
      participantId: participantId ?? this.participantId,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
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
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
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
          ..write('source: $source, ')
          ..write('confidence: $confidence, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    participantOverrides,
    chatOverrides,
    messageAnnotations,
    handleToParticipantOverrides,
  ];
}

typedef $$ParticipantOverridesTableCreateCompanionBuilder =
    ParticipantOverridesCompanion Function({
      Value<int> participantId,
      Value<String?> shortName,
      Value<bool> isMuted,
      Value<String?> notes,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$ParticipantOverridesTableUpdateCompanionBuilder =
    ParticipantOverridesCompanion Function({
      Value<int> participantId,
      Value<String?> shortName,
      Value<bool> isMuted,
      Value<String?> notes,
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

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
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

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
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

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => column);

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
                Value<String?> shortName = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => ParticipantOverridesCompanion(
                participantId: participantId,
                shortName: shortName,
                isMuted: isMuted,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<String?> shortName = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => ParticipantOverridesCompanion.insert(
                participantId: participantId,
                shortName: shortName,
                isMuted: isMuted,
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
      required int participantId,
      Value<String> source,
      Value<double> confidence,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$HandleToParticipantOverridesTableUpdateCompanionBuilder =
    HandleToParticipantOverridesCompanion Function({
      Value<int> handleId,
      Value<int> participantId,
      Value<String> source,
      Value<double> confidence,
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

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
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

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
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
                Value<int> participantId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => HandleToParticipantOverridesCompanion(
                handleId: handleId,
                participantId: participantId,
                source: source,
                confidence: confidence,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> handleId = const Value.absent(),
                required int participantId,
                Value<String> source = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => HandleToParticipantOverridesCompanion.insert(
                handleId: handleId,
                participantId: participantId,
                source: source,
                confidence: confidence,
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
}
