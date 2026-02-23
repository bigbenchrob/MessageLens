import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/settings/manual_linking_view.dart';

part 'manual_linking_resolver.g.dart';

/// Resolver for the manual handle linking settings cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
@riverpod
class ManualLinkingResolver extends _$ManualLinkingResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve() async {
    return const SidebarCassetteCardViewModel(
      title: 'Manual Linking',
      subtitle: 'Link unknown handles to contacts when automatic matching fails.',
      shouldExpand: true,
      child: ManualLinkingView(),
    );
  }
}
