import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_cassette_spec.freezed.dart';

/// Specification for the handles-related cassette types.
///
/// This file resides in the `features` folder to align with the directory
/// structure described in the essentials/sidebar domain. It mirrors the
/// existing `contacts_cassette_spec.dart` at the root but places it where
/// `cassette_spec.dart` expects to find it. The generated `.freezed.dart`
/// will live alongside this file after running build_runner.
@freezed
abstract class HandlesCassetteSpec with _$HandlesCassetteSpec {
  /// A simple list of unmatched handles.
  const factory HandlesCassetteSpec.unmatchedHandlesList({
    int? chosenContactId,
  }) = _HandlesListUnmatchedSpec;

  /// An info card that displays explanatory text.
  /// Info cards always have a child card specified by [childVariant].
  ///
  /// Optional [title] renders as a bold heading above the message.
  /// Optional [footnote] renders as de-emphasized italic text below.
  const factory HandlesCassetteSpec.infoCard({
    String? title,
    required String message,
    String? footnote,
    required HandlesCassetteChildVariant childVariant,
  }) = _HandlesInfoCardSpec;

  /// A list of phone numbers not matched to any contact.
  const factory HandlesCassetteSpec.strayPhoneNumbers() =
      _HandlesStrayPhoneNumbersSpec;

  /// A list of email addresses not matched to any contact.
  const factory HandlesCassetteSpec.strayEmails() = _HandlesStrayEmailsSpec;
}

/// Variants for child cassettes that can follow an info card.
enum HandlesCassetteChildVariant {
  /// List of stray phone numbers
  strayPhoneNumbers,

  /// List of stray emails
  strayEmails,
}
