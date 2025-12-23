import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../constants/domain/contact_constants.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contact_picker_mode.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';
import '../../presentation/cassettes/contacts_enhanced_picker_cassette.dart';
import '../../presentation/cassettes/contacts_flat_menu_cassette.dart';

part 'contact_chooser_view_builder_provider.g.dart';

/// Debug flag for temporarily forcing the flat chooser.
///
/// Keep `false` for normal behavior.
const bool _forceFlatContactChooser = false;

/// Resolves which contact picker widget to display based on contact count.
///
/// This provider determines whether to show a flat list or grouped picker
/// by checking the total contact count against [kContactPickerGroupingThreshold].
@riverpod
Widget contactChooserViewBuilder(Ref ref, ContactsCassetteSpec spec) {
  final maintenanceLocked = ref.watch(dbMaintenanceLockProvider);
  if (maintenanceLocked) {
    debugPrint('ContactChooser: maintenance lock active (skipping load)');
    return const Center(child: ProgressCircle());
  }

  final asyncContacts = ref.watch(
    contactsListRepositoryProvider(spec: const ContactsListSpec.alphabetical()),
  );

  return asyncContacts.when(
    data: (contacts) {
      final config = resolveContactPickerConfig(contacts.length);

      debugPrint(
        'ContactChooser: ${contacts.length} contacts, mode: ${config.mode}, forcedFlat: $_forceFlatContactChooser',
      );

      if (_forceFlatContactChooser) {
        return ContactsFlatMenuCassette(spec: spec, contacts: contacts);
      }

      // Pass contacts to cassettes to avoid double-loading.
      return switch (config.mode) {
        ContactPickerMode.flat => ContactsFlatMenuCassette(
          spec: spec,
          contacts: contacts,
        ),
        ContactPickerMode.grouped => ContactsEnhancedPickerCassette(spec: spec),
      };
    },
    loading: () {
      debugPrint('ContactChooser: loading...');
      return const Center(child: ProgressCircle());
    },
    error: (error, stack) {
      debugPrint('ContactChooser error: $error');
      return Center(
        child: Text(
          'Error loading contacts: $error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    },
  );
}
