import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/stray_phone_numbers_cassette.dart';

part 'stray_phone_numbers_cassette_builder_provider.g.dart';

/// Builds the cassette view model for stray phone numbers.
///
/// This builder is responsible for gathering data and applying any
/// conditional logic before constructing the cassette widget.
@riverpod
SidebarCassetteCardViewModel strayPhoneNumbersCassetteBuilder(Ref ref) {
  // TODO: Add data fetching and conditional logic as needed
  return const SidebarCassetteCardViewModel(
    title: 'Stray phone numbers',
    subtitle: 'Phone numbers not linked to any contact in your address book.',
    shouldExpand: true,
    child: StrayPhoneNumbersCassette(),
  );
}
