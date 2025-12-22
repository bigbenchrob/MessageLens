import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import '../cassettes/contact_hero_summary_cassette.dart';
import '../cassettes/contacts_enhanced_picker_cassette.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps [ContactsCassetteSpec] to cassette widgets.
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  CassetteCardView buildForSpec(ContactsCassetteSpec spec) {
    return spec.map(
      contactChooser: (chooser) => CassetteCardView(
        title: '',
        subtitle: null,
        child: ContactsEnhancedPickerCassette(spec: chooser),
      ),
      contactHeroSummary: (hero) => CassetteCardView(
        title: '',
        subtitle: null,
        child: ContactHeroSummaryCassette(spec: hero),
      ),
    );
  }
}
