import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../essentials/sidebar/presentation/models/cassette_card_view.dart';
import 'presentation/cassettes/contacts_chooser.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps [ContactsCassetteSpec] to cassette widgets.
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  CassetteCardView buildForSpec(ContactsCassetteSpec spec) {
    return CassetteCardView(
      title: 'Select a contact',
      subtitle:
          'The choice is stored on this cassette so deeper panes can react.',
      child: ContactsChooser(spec: spec),
    );
  }
}
