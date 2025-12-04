import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import the sidebar utilities feature coordinator to build widgets for
// sidebar utility cassette specs.  We import this with an alias to
// clearly scope the coordinator within the sidebar utilities feature.
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities;
import '../feature_level_providers.dart';

part 'cassette_widget_coordinator_provider.g.dart';

/// Coordinates the construction of sidebar utility cassettes.
///
/// This provider reads the current [CassetteRack] from
/// [cassetteRackStateProvider] and transforms each [CassetteSpec] into
/// the corresponding [Widget] via the appropriate builder.  At this stage
/// only the top chat menu cassette is supported; additional cassette types
/// should be handled here as they are implemented.
/// Coordinates the construction of sidebar utility cassettes as a class-based
/// Riverpod notifier.
///
/// This notifier listens to the [cassetteRackStateProvider] and rebuilds
/// whenever the rack changes.  It converts each [CassetteSpec] in the rack
/// into a concrete [Widget] by delegating to the appropriate builder.
/// Currently only the top chat menu is supported.  Additional cassette
/// variants (e.g. unmatched handles, all messages) should be handled here as
/// they are implemented.
@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  @override
  List<Widget> build() {
    final rack = ref.watch(cassetteRackStateProvider);
    final widgets = <Widget>[];
    for (final spec in rack.cassettes) {
      spec.when(
        sidebarUtility: (sidebarSpec) {
          // Delegate building to the sidebar utilities feature coordinator.
          final coordinator = ref.read(
            sidebar_utilities.utilityCassetteCoordinatorProvider.notifier,
          );
          widgets.add(coordinator.buildForSpec(sidebarSpec));
        },
        contacts: (contactsSpec) {
          // Contacts cassette builder not yet implemented.  For now insert
          // an empty placeholder.  Replace this with a real builder once
          // contact cassettes are implemented.
          widgets.add(const SizedBox.shrink());
        },
      );
    }
    return widgets;
  }
}
