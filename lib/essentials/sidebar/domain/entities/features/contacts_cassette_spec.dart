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
  /// A flat menu of contacts.  This variant is used when there are few
  /// contacts and they can be presented as a simple list.
  const factory ContactsCassetteSpec.contactsFlatMenu({int? chosenContactId}) =
      _ContactMenuSpec;

  /// A more elaborate contacts picker.  Use this when there are many
  /// contacts or when a richer UI is needed to select a contact.
  const factory ContactsCassetteSpec.contactPicker({int? chosenContactId}) =
      _ContactPickerSpec;
}
