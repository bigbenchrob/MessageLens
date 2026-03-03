import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';

/// Segmented control that toggles the contact picker between
/// showing all contacts and showing only favourites.
class PickerFilterToggle extends ConsumerWidget {
  const PickerFilterToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(pickerFilterProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<PickerFilterMode>(
          groupValue: mode,
          children: const {
            PickerFilterMode.all: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('All'),
            ),
            PickerFilterMode.favouritesOnly: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Favourites'),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              ref.read(pickerFilterProvider.notifier).setMode(value);
            }
          },
        ),
      ),
    );
  }
}
