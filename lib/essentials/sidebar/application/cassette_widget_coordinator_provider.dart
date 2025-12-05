import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/feature_level_providers.dart'
    as contacts_feature;
import '../../../features/handles/feature_level_providers.dart'
    as handles_feature;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities;

/// barrel file import to expose cassette spec and feature cassette spec definitions
import '../feature_level_providers.dart';

/// utility widget to wrap each cassette in a card
import '../presentation/view/widgets/sidebar_cassette_card.dart';

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

    Widget buildForSpec(CassetteSpec spec) {
      return spec.when(
        sidebarUtility: (sidebarSpec) {
          final coordinator = ref.read(
            sidebar_utilities.utilityCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(sidebarSpec);
        },
        contacts: (contactsSpec) {
          final coordinator = ref.read(
            contacts_feature.contactsCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(contactsSpec);
        },
        handles: (handlesSpec) {
          final coordinator = ref.read(
            handles_feature.handlesCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(handlesSpec);
        },
        messages: (messagesSpec) {
          final coordinator = ref.read(
            messages_feature.messagesCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(messagesSpec);
        },
      );
    }

    for (final spec in rack.cassettes) {
      widgets.add(SidebarCassetteCard(child: buildForSpec(spec)));
    }

    var childSpec = rack.cassettes.isNotEmpty
        ? rack.cassettes.last.childSpec()
        : null;

    while (childSpec != null) {
      widgets.add(SidebarCassetteCard(child: buildForSpec(childSpec)));
      childSpec = childSpec.childSpec();
    }
    return widgets;
  }
}
