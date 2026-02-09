import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_cassette_spec.freezed.dart';

/// Filter for the stray handles review cassette.
enum StrayHandleFilter {
  phones,
  emails,
}

/// Specification for the handles-related cassette types.
///
/// This file resides in the `features` folder to align with the directory
/// structure described in the essentials/sidebar domain. It mirrors the
/// existing `contacts_cassette_spec.dart` at the root but places it where
/// `cassette_spec.dart` expects to find it. The generated `.freezed.dart`
/// will live alongside this file after running build_runner.
///
/// INFO CARDS: Handles info cards are now defined in `handles_info_cassette_spec.dart`
/// following the cross-surface spec pattern. Use `HandlesInfoCassetteSpec.infoCard()`
/// instead of inline message strings.
@freezed
abstract class HandlesCassetteSpec with _$HandlesCassetteSpec {
  /// A simple list of unmatched handles.
  const factory HandlesCassetteSpec.unmatchedHandlesList({
    int? chosenContactId,
  }) = _HandlesListUnmatchedSpec;

  /// A list of phone numbers not matched to any contact.
  const factory HandlesCassetteSpec.strayPhoneNumbers() =
      _HandlesStrayPhoneNumbersSpec;

  /// A list of email addresses not matched to any contact.
  const factory HandlesCassetteSpec.strayEmails() = _HandlesStrayEmailsSpec;

  /// Unified stray handles review — filtered by phone or email.
  const factory HandlesCassetteSpec.strayHandlesReview({
    required StrayHandleFilter filter,
  }) = _HandlesStrayReviewSpec;
}
