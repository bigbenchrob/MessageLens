import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/unmatched_handles_cassette.dart';

part 'unmatched_handles_cassette_builder_provider.g.dart';

/// Builds the cassette view model for unmatched handles list.
///
/// This builder is responsible for gathering data and applying any
/// conditional logic before constructing the cassette widget.
@riverpod
SidebarCassetteCardViewModel unmatchedHandlesCassetteBuilder(Ref ref) {
  // TODO: Add data fetching and conditional logic as needed
  return const SidebarCassetteCardViewModel(
    title: 'Unmatched phone numbers & emails',
    subtitle: 'Link stray handles to contacts to keep conversations organized.',
    child: UnmatchedHandlesCassette(),
  );
}
