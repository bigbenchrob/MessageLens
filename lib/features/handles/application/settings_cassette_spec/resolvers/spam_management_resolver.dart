import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/settings/spam_management_view.dart';

part 'spam_management_resolver.g.dart';

/// Resolver for the spam management settings cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class SpamManagementResolver extends _$SpamManagementResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve() async {
    return const SidebarCassetteCardViewModel(
      title: 'Spam Management',
      subtitle: 'Block unwanted handles and manage your blacklist.',
      shouldExpand: true,
      child: SpamManagementView(),
    );
  }
}
