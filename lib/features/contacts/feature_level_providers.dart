import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import 'presentation/cassettes/contacts_chooser.dart';

part 'feature_level_providers.g.dart';

/// Coordinator that maps [ContactsCassetteSpec] to cassette widgets.
@riverpod
class ContactsCassetteCoordinator extends _$ContactsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  Widget buildForSpec(ContactsCassetteSpec spec) {
    return ContactsChooser(spec: spec);
  }
}
