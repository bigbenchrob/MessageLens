import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/constants/domain/contact_constants.dart';
import 'package:remember_this_text/features/contacts/application/contact_picker_mode.dart';

void main() {
  group('resolveContactPickerConfig', () {
    test('returns flat when below threshold', () {
      final config = resolveContactPickerConfig(
        kContactPickerGroupingThreshold - 1,
      );

      expect(config.mode, ContactPickerMode.flat);
      expect(config.contactCount, kContactPickerGroupingThreshold - 1);
    });

    test('returns grouped when at threshold', () {
      final config = resolveContactPickerConfig(
        kContactPickerGroupingThreshold,
      );

      expect(config.mode, ContactPickerMode.grouped);
    });
  });
}
