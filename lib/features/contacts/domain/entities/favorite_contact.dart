import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_contact.freezed.dart';

/// Overlay-scoped favorite contact preference.
@freezed
abstract class FavoriteContact with _$FavoriteContact {
  const factory FavoriteContact({
    required int participantId,
    required int sortOrder,
    required bool isFavorited,
    required DateTime pinnedAt,
    DateTime? lastInteractionAt,
    required DateTime updatedAt,
  }) = _FavoriteContact;

  const FavoriteContact._();
}
