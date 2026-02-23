import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/unmatched_handles_cassette.dart';

part 'unmatched_handles_resolver.g.dart';

/// Resolver for the unmatched handles list cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class UnmatchedHandlesResolver extends _$UnmatchedHandlesResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve() async {
    // TODO: Add data fetching and conditional logic as needed
    return const SidebarCassetteCardViewModel(
      title: 'Unmatched phone numbers & emails',
      subtitle: 'Link stray handles to contacts to keep conversations organized.',
      shouldExpand: true,
      child: UnmatchedHandlesCassette(),
    );
  }
}
