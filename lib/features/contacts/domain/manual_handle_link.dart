import 'package:freezed_annotation/freezed_annotation.dart';

part 'manual_handle_link.freezed.dart';

/// Domain entity representing a manual handle-to-participant link
@freezed
abstract class ManualHandleLink with _$ManualHandleLink {
  const ManualHandleLink._();

  const factory ManualHandleLink({
    required int handleId,
    required String handleIdentifier,
    required int participantId,
    required String participantName,
    required DateTime createdAt,
  }) = _ManualHandleLink;

  /// Create from database row (overlay.handle_to_participant_overrides joined with working data)
  factory ManualHandleLink.fromDatabaseRow({
    required int handleId,
    required String handleIdentifier,
    required int participantId,
    required String participantName,
    required String createdAtUtc,
  }) {
    return ManualHandleLink(
      handleId: handleId,
      handleIdentifier: handleIdentifier,
      participantId: participantId,
      participantName: participantName,
      createdAt: DateTime.parse(createdAtUtc).toLocal(),
    );
  }
}
