import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../essentials/sidebar/domain/entities/features/contacts_settings_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import 'application/cassette_builders/contact_short_names_cassette_builder_provider.dart';
import 'application/use_cases/contact_chooser_view_builder_provider.dart';
import 'presentation/cassettes/contact_hero_summary_cassette.dart';

export 'application/settings/contact_name_mode_provider.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps [ContactsCassetteSpec] to cassette widgets.
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {}

  CassetteCardView buildForSpec(Ref ref, ContactsCassetteSpec spec) {
    return spec.map(
      recentContacts: (recent) => CassetteCardView(
        title: '',
        subtitle: null,
        child: contactChooserViewBuilder(ref, recent),
      ),
      contactChooser: (chooser) => CassetteCardView(
        title: '',
        subtitle: null,
        child: contactChooserViewBuilder(ref, chooser),
      ),
      contactHeroSummary: (hero) => CassetteCardView(
        title: '',
        subtitle: null,
        shouldExpand: false,
        child: ContactHeroSummaryCassette(spec: hero),
      ),
      settings: (settings) => ref
          .read(contactsSettingsCassetteCoordinatorProvider.notifier)
          .buildForSpec(settings.spec),
    );
  }
}

/// Coordinator that maps [ContactsSettingsSpec] to cassette widgets.
///
/// This separates the "Settings" concerns from the main operational views
/// of the Contacts feature.
@riverpod
class ContactsSettingsCassetteCoordinator
    extends _$ContactsSettingsCassetteCoordinator {
  @override
  void build() {}

  CassetteCardView buildForSpec(ContactsSettingsSpec spec) {
    return spec.when(
      shortNames: () => ref.read(contactShortNamesCassetteBuilderProvider),
    );
  }
}
