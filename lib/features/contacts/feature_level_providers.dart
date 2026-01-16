import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/navigation/domain/entities/features/contacts_spec.dart';
import '../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../essentials/sidebar/domain/entities/features/contacts_settings_spec.dart';
import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'application/cassette_builders/contact_short_names_cassette_builder_provider.dart';
import 'application/use_cases/contact_chooser_view_builder_provider.dart';
import 'presentation/cassettes/contact_hero_summary_cassette.dart';

export 'application/settings/contact_name_mode_provider.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps [ContactsSpec] to rendered widgets for the center panel.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [ContactsSpec].
  Widget buildForSpec(ContactsSpec spec) {
    return spec.when(
      list: () => _buildPlaceholder('Contacts list view coming soon'),
      detail: (contactId) =>
          _buildPlaceholder('Contact detail for $contactId coming soon'),
      search: (query) =>
          _buildPlaceholder('Contact search for "$query" coming soon'),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Coordinator that maps [ContactsCassetteSpec] to cassette widgets.
@riverpod
class FeatureCassetteSpecCoordinator extends _$FeatureCassetteSpecCoordinator {
  @override
  void build() {}

  SidebarCassetteCardViewModel buildForSpec(
    Ref ref,
    ContactsCassetteSpec spec,
  ) {
    return spec.map(
      recentContacts: (recent) => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        child: contactChooserViewBuilder(ref, recent),
      ),
      contactChooser: (chooser) => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        child: contactChooserViewBuilder(ref, chooser),
      ),
      contactHeroSummary: (hero) => SidebarCassetteCardViewModel(
        title: '',
        subtitle: null,
        shouldExpand: false,
        child: ContactHeroSummaryCassette(spec: hero),
      ),
    );
  }
}

/// Coordinator that maps [ContactsSettingsSpec] to cassette widgets.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {}

  SidebarCassetteCardViewModel buildForSpec(ContactsSettingsSpec spec) {
    return spec.when(
      shortNames: () => ref.read(contactShortNamesCassetteBuilderProvider),
    );
  }
}
