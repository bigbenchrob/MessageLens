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
import '../../navigation/domain/sidebar_mode.dart';

/// barrel file import to expose cassette spec and feature cassette spec definitions
import '../domain/entities/features/presentation_cassette_spec.dart';
import '../feature_level_providers.dart';

/// utility widgets to wrap each cassette in a card
import '../presentation/sidebar_info_card.dart';
import '../presentation/view/sidebar_cassette_card.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';

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
/// The top chat or settings menu are present by default.  Additional cassette
/// variants (e.g. unmatched handles, all messages) are added depending on user
/// actions and application state.
@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  @override
  List<Widget> build(SidebarMode mode) {
    final rack = ref.watch(cassetteRackStateProvider(mode));
    final widgets = <Widget>[];

    Future<SidebarCassetteCardViewModel> buildViewModelForSpec(
      CassetteSpec spec,
    ) async {
      return spec.when(
        sidebarUtility: (sidebarSpec) {
          final coordinator = ref.read(
            sidebar_utilities.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(sidebarSpec);
        },
        sidebarUtilitySettings: (sidebarSpec) {
          final coordinator = ref.read(
            sidebar_utilities.settingsCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(sidebarSpec);
        },
        presentation: (presentationSpec) {
          return presentationSpec.map(
            themePlayground: (_) {
              return const SidebarCassetteCardViewModel(
                title: 'Theme playground',
                subtitle: 'Verify theme reacts to system appearance changes.',
                child: ThemePlaygroundCassette(),
              );
            },
          );
        },
        contacts: (contactsSpec) {
          final coordinator = ref.read(
            contacts_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(ref, contactsSpec);
        },
        contactsSettings: (settingsSpec) {
          final coordinator = ref.read(
            contacts_feature.settingsCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(settingsSpec);
        },

        contactsInfo: (infoSpec) async {
          final coordinator = ref.read(
            contacts_feature.infoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(infoSpec);
        },
        handles: (handlesSpec) {
          final coordinator = ref.read(
            handles_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(handlesSpec);
        },
        messages: (messagesSpec) {
          final coordinator = ref.read(
            messages_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(messagesSpec);
        },
      );
    }

    void addCassette(CassetteSpec spec) {
      final viewModel = buildViewModelForSpec(spec);

      // Build the appropriate card type based on the view model
      switch (viewModel.cardType) {
        case CassetteCardType.standard:
          widgets.add(
            SidebarCassetteCard(
              title: viewModel.title,
              subtitle: viewModel.subtitle,
              sectionTitle: viewModel.sectionTitle,
              footerText: viewModel.footerText,
              isControl: viewModel.isControl,
              isNaked: viewModel.isNaked,
              shouldExpand: viewModel.shouldExpand,
              child: viewModel.child,
            ),
          );
        case CassetteCardType.info:
          widgets.add(
            SidebarInfoCard(
              title: viewModel.title.isEmpty ? null : viewModel.title,
              body: TextSpan(text: viewModel.infoBodyText ?? ''),
              footnote: viewModel.footerText,
            ),
          );
      }
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
