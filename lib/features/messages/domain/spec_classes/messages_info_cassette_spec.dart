import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_info_cassette_spec.freezed.dart';

/// Feature-owned spec for Messages "info" cassettes.
///
/// Mirrors the Contacts info-cassette pattern so message-related explanatory
/// cards have a predictable architectural home.
@freezed
abstract class MessagesInfoCassetteSpec with _$MessagesInfoCassetteSpec {
  const MessagesInfoCassetteSpec._();

  /// Request an informational card owned by the Messages feature.
  const factory MessagesInfoCassetteSpec.infoCard({
    required MessagesInfoKey key,
  }) = MessagesInfoCassetteSpecInfoCard;
}

/// Feature-owned keys that identify informational content meaning for Messages.
enum MessagesInfoKey {
  /// Explains the recovered deleted-messages surface.
  recoveredDeletedMessages,

  /// Explains the recovered no-handle outgoing slice.
  recoveredNoHandleMessages,
}