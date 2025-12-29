import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_cassette_spec.freezed.dart';

/// Specification for the contacts-related cassette types.
///
/// This file resides in the `features` folder to align with the directory
/// structure described in the essentials/sidebar domain. It mirrors the
/// existing `contacts_cassette_spec.dart` at the root but places it where
/// `cassette_spec.dart` expects to find it. The generated `.freezed.dart`
/// will live alongside this file after running build_runner.
@freezed
abstract class ContactsCassetteSpec with _$ContactsCassetteSpec {
  /// Shows recently accessed contacts with "More..." button to open full chooser.
  /// Displays up to 10 contacts ordered by last access time.
  const factory ContactsCassetteSpec.recentContacts({int? chosenContactId}) =
      _RecentContactsSpec;

  /// A contact chooser that adapts its UI based on contact count.
  /// The contacts feature decides whether to show a flat list or grouped
  /// picker based on the number of contacts.
  const factory ContactsCassetteSpec.contactChooser({int? chosenContactId}) =
      _ContactChooserSpec;

  /// A detailed summary view for a selected contact.
  const factory ContactsCassetteSpec.contactHeroSummary({
    required int chosenContactId,
  }) = _ContactHeroSummarySpec;
}
