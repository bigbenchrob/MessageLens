import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import 'presentation/cassettes/contact_hero_summary_cassette.dart';
import 'presentation/cassettes/contacts_enhanced_picker_cassette.dart';
import 'presentation/cassettes/contacts_flat_menu_cassette.dart';

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
      contactsFlatMenu: (flat) => CassetteCardView(
        title: 'Quick contacts',
        subtitle: 'Pick from a compact alphabetical list.',
        child: ContactsFlatMenuCassette(spec: flat),
      ),
      contactsEnhancedPicker: (picker) => CassetteCardView(
        title: 'Select a contact',
        subtitle: 'Scroll or jump by letter to find the right person.',
        child: ContactsEnhancedPickerCassette(spec: picker),
      ),
      contactHeroSummary: (hero) => CassetteCardView(
        title: '',
        subtitle: null,
        child: ContactHeroSummaryCassette(spec: hero),
      ),
    );
  }
}
