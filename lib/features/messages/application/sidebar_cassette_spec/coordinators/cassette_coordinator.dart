import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/entities/features/messages_cassette_spec.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../resolvers/heatmap_resolver.dart';

part 'cassette_coordinator.g.dart';

/// Messages Cassette Coordinator
///
/// Routes [MessagesCassetteSpec] variants to their respective resolvers.
/// This coordinator is the entry point for all messages-related sidebar
/// cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [MessagesCassetteSpec]
/// - Pattern-matches on the spec
/// - Extracts payload parameters
/// - Calls exactly ONE resolver
/// - Returns the resolver's `Future<SidebarCassetteCardViewModel>`
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
/// - Pass specs to resolvers
@riverpod
class MessagesCassetteCoordinator extends _$MessagesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a sidebar cassette view model for the given messages cassette spec.
  Future<SidebarCassetteCardViewModel> buildViewModel(
    MessagesCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    return spec.map(
      heatMap: (heatMap) => ref
          .read(heatmapResolverProvider.notifier)
          .resolve(contactId: heatMap.contactId, cassetteIndex: cassetteIndex),
    );
  }
}
