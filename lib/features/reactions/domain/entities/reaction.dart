// lib/features/reactions/domain/entities/reaction.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain_driven_development/value_transformers.dart';
// Value objects from their feature folders

import '../../../../essentials/contacts/domain/value_objects/contact_id.dart';
import '../../../messages/domain/value_objects/message_id.dart';
import '../constants.dart';
import '../value_objects/reaction_id.dart';

part 'reaction.freezed.dart';
part 'reaction.g.dart';

@freezed
abstract class Reaction with _$Reaction {
  const factory Reaction({
    @ReactionIdConverter() required ReactionId id,
    @MessageIdConverter() required MessageId messageId,
    @ContactIdConverter() required ContactId authorId,
    required ReactionKind kind,
    String? customText,
    required DateTime createdAt,
    DateTime? removedAt,
    z,
  }) = _Reaction;

  const Reaction._();

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);
}
