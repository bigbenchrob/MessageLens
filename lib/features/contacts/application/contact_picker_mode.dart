import '../../../constants/domain/contact_constants.dart';

// NEW: contact picker mode helper
class ContactPickerConfig {
  const ContactPickerConfig({required this.mode, required this.contactCount});

  final ContactPickerMode mode;
  final int contactCount;
}

// NEW: contact picker mode helper
ContactPickerConfig resolveContactPickerConfig(int contactCount) {
  final mode = contactCount >= kContactPickerGroupingThreshold
      ? ContactPickerMode.grouped
      : ContactPickerMode.flat;

  return ContactPickerConfig(mode: mode, contactCount: contactCount);
}
