import '../../../../../constants/domain/contact_constants.dart';

/// Pure function to determine which contact picker mode to use.
///
/// This is a resolver tool: a shared pure helper function for resolvers.
/// It contains no Riverpod, no widgets, and no routing.
///
/// The decision is based solely on contact count against the threshold
/// defined in [kContactPickerGroupingThreshold].
///
/// Returns [ContactPickerMode.flat] for small contact lists (< 6),
/// otherwise [ContactPickerMode.grouped] for larger lists.
ContactPickerMode determinePickerMode(int contactCount) {
  return contactCount < kContactPickerGroupingThreshold
      ? ContactPickerMode.flat
      : ContactPickerMode.grouped;
}
