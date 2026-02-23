import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/stray_emails_cassette.dart';

part 'stray_emails_resolver.g.dart';

/// Resolver for the stray emails cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class StrayEmailsResolver extends _$StrayEmailsResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve() async {
    // TODO: Add data fetching and conditional logic as needed
    return const SidebarCassetteCardViewModel(
      title: 'Stray emails',
      subtitle: 'Email addresses not linked to any contact in your address book.',
      shouldExpand: true,
      child: StrayEmailsCassette(),
    );
  }
}
