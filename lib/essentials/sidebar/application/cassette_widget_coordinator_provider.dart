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
import '../../../features/sidebar_utilities/presentation/cassettes/theme_playground_cassette.dart';

/// barrel file import to expose cassette spec and feature cassette spec definitions
import '../domain/entities/features/presentation_cassette_spec.dart';
import '../feature_level_providers.dart';

/// utility widget to wrap each cassette in a card
import '../presentation/models/cassette_card_view.dart';
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

    CassetteCardView buildViewForSpec(CassetteSpec spec) {
      return spec.when(
        sidebarUtility: (sidebarSpec) {
          final coordinator = ref.read(
            sidebar_utilities.utilityCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(sidebarSpec);
        },
        presentation: (presentationSpec) {
          return presentationSpec.map(
            themePlayground: (_) {
              return const CassetteCardView(
                title: 'Theme playground',
                subtitle: 'Verify theme reacts to system appearance changes.',
                child: ThemePlaygroundCassette(),
              );
            },
          );
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

    void addCassette(CassetteSpec spec) {
      final view = buildViewForSpec(spec);
      widgets.add(
        SidebarCassetteCard(
          title: view.title,
          subtitle: view.subtitle,
          isControl: view.isControl,
          child: view.child,
        ),
      );
    }

    rack.cassettes.forEach(addCassette);

    var childSpec = rack.cassettes.isNotEmpty
        ? rack.cassettes.last.childSpec()
        : null;

    while (childSpec != null) {
      addCassette(childSpec);
      childSpec = childSpec.childSpec();
    }

    return widgets;
  }
}
