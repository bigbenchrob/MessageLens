import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/grouped_contacts_provider.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';
import '../view_model/cassette_view_model.dart';
import '../widgets/contact_cassette_error.dart';
import '../widgets/grouped_contact_selector.dart';

class ContactsEnhancedPickerCassette extends ConsumerWidget {
  const ContactsEnhancedPickerCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(groupedContactsProvider);
    const listSpec = ContactsListSpec.alphabetical();

    return groupedAsync.when(
      data: (grouped) {
        if (grouped.availableLetters.isEmpty) {
          return const Center(child: Text('No contacts available'));
        }

        return FullContactPicker(
          selectedParticipantId: null,
          onContactSelected: (contactId) {
            ref
                .read(cassetteViewModelProvider.notifier)
                .updateContactSelection(
                  currentSpec: spec,
                  nextContactId: contactId,
                );
          },
          maxHeight: 380,
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => ContactCassetteError(
        onRetry: () {
          ref.invalidate(groupedContactsProvider);
          ref.invalidate(contactsListRepositoryProvider(spec: listSpec));
        },
        message: '$error',
      ),
    );
  }
}
