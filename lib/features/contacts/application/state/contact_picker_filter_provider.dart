import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contact_picker_filter_provider.g.dart';

/// Filter mode for the contacts picker.
enum ContactPickerFilterMode {
  /// Show only favorited contacts.
  favorites,

  /// Show all contacts.
  all,
}

/// Provides and controls the current contact picker filter mode.
///
/// This is a global state provider that the filter switcher writes to
/// and the contact picker reads from.
@Riverpod(keepAlive: true)
class ContactPickerFilter extends _$ContactPickerFilter {
  @override
  ContactPickerFilterMode build() => ContactPickerFilterMode.all;

  /// Switch to a new filter mode.
  void setMode(ContactPickerFilterMode mode) {
    state = mode;
  }

  /// Toggle between favorites and all.
  void toggle() {
    state = state == ContactPickerFilterMode.favorites
        ? ContactPickerFilterMode.all
        : ContactPickerFilterMode.favorites;
  }
}
