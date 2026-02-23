import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_cassette_spec.freezed.dart';

/// Filter for the stray handles review cassette - determines which handle type to show.
enum StrayHandleFilter {
  /// Phone numbers (no '@', no 'urn:' prefix)
  phones,

  /// Email addresses (contains '@')
  emails,

  /// Business URNs (starts with 'urn:' - Apple Business Chat, etc.)
  businessUrns,
}

/// Mode for the stray handles review cassette - determines which handles to show.
enum StrayHandleMode {
  /// Show all stray handles (excluding dismissed).
  allStrays,

  /// Show only spam candidates (short codes, one-off messages).
  spamCandidates,

  /// Show dismissed handles (for "undo" / escape hatch access).
  dismissed,
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

  /// Unified stray handles review — filtered by phone or email, with mode selector.
  const factory HandlesCassetteSpec.strayHandlesReview({
    required StrayHandleFilter filter,
    @Default(StrayHandleMode.allStrays) StrayHandleMode mode,
  }) = _HandlesStrayReviewSpec;

  /// Mode switcher control for stray handles triage.
  ///
  /// This is a separate cassette that controls the global mode state,
  /// allowing it to have child cassettes for additional filtering/sorting.
  const factory HandlesCassetteSpec.strayHandlesModeSwitcher({
    required StrayHandleFilter filter,
  }) = _HandlesModeSwitcherSpec;

  /// Type switcher for selecting Phone # / Email / Business URN.
  ///
  /// This sits between the menu selection and the mode switcher,
  /// allowing the user to choose which handle type to review.
  const factory HandlesCassetteSpec.strayHandlesTypeSwitcher({
    @Default(StrayHandleFilter.phones) StrayHandleFilter selectedFilter,
  }) = _HandlesTypeSwitcherSpec;
}
