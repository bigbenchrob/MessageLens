import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/stray_emails_cassette.dart';

part 'stray_emails_cassette_builder_provider.g.dart';

/// Builds the cassette view model for stray emails.
///
/// This builder is responsible for gathering data and applying any
/// conditional logic before constructing the cassette widget.
@riverpod
SidebarCassetteCardViewModel strayEmailsCassetteBuilder(Ref ref) {
  // TODO: Add data fetching and conditional logic as needed
  return const SidebarCassetteCardViewModel(
    title: 'Stray emails',
    subtitle: 'Email addresses not linked to any contact in your address book.',
    child: StrayEmailsCassette(),
  );
}
