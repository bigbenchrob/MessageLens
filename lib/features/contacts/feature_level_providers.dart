import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import 'application/use_cases/contact_chooser_view_builder_provider.dart';
import 'presentation/cassettes/contact_hero_summary_cassette.dart';

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
    );
  }
}
