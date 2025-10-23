import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_list_spec.freezed.dart';

/// Filter mode for phone number handles
enum PhoneFilterMode { all, spamCandidates }

@freezed
abstract class HandlesListSpec with _$HandlesListSpec {
  /// Display unmatched phone numbers with optional spam filtering
  const factory HandlesListSpec.phones({required PhoneFilterMode filterMode}) =
      HandlesListSpecPhones;

  /// Display unmatched email addresses
  const factory HandlesListSpec.emails() = HandlesListSpecEmails;
}
