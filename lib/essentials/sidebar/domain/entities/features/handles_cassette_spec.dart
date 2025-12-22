import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_cassette_spec.freezed.dart';

/// Specification for the contacts-related cassette types.
///
/// This file resides in the `features` folder to align with the directory
/// structure described in the essentials/sidebar domain. It mirrors the
/// existing `contacts_cassette_spec.dart` at the root but places it where
/// `cassette_spec.dart` expects to find it. The generated `.freezed.dart`
/// will live alongside this file after running build_runner.
@freezed
abstract class HandlesCassetteSpec with _$HandlesCassetteSpec {
  /// A simple list of unmatched hangles.
  const factory HandlesCassetteSpec.unmatchedHandlesList({
    int? chosenContactId,
  }) = _HandlesListUnmatchedSpec;

  /// A list of phone numbers not matched to any contact.
  const factory HandlesCassetteSpec.strayPhoneNumbers() =
      _HandlesStrayPhoneNumbersSpec;

  /// A list of email addresses not matched to any contact.
  const factory HandlesCassetteSpec.strayEmails() = _HandlesStrayEmailsSpec;
}
