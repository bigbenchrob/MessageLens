// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reaction _$ReactionFromJson(Map<String, dynamic> json) => _Reaction(
  id: const ReactionIdConverter().fromJson(json['id'] as String),
  messageId: const MessageIdConverter().fromJson(json['messageId'] as String),
  authorId: const ContactIdConverter().fromJson(json['authorId'] as String),
  kind: $enumDecode(_$ReactionKindEnumMap, json['kind']),
  customText: json['customText'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  removedAt: json['removedAt'] == null
      ? null
      : DateTime.parse(json['removedAt'] as String),
  z: json['z'],
);

Map<String, dynamic> _$ReactionToJson(_Reaction instance) => <String, dynamic>{
  'id': const ReactionIdConverter().toJson(instance.id),
  'messageId': const MessageIdConverter().toJson(instance.messageId),
  'authorId': const ContactIdConverter().toJson(instance.authorId),
  'kind': _$ReactionKindEnumMap[instance.kind]!,
  'customText': instance.customText,
  'createdAt': instance.createdAt.toIso8601String(),
  'removedAt': instance.removedAt?.toIso8601String(),
  'z': instance.z,
};

const _$ReactionKindEnumMap = {
  ReactionKind.love: 'love',
  ReactionKind.like: 'like',
  ReactionKind.dislike: 'dislike',
  ReactionKind.laugh: 'laugh',
  ReactionKind.emphasize: 'emphasize',
  ReactionKind.question: 'question',
  ReactionKind.custom: 'custom',
};
