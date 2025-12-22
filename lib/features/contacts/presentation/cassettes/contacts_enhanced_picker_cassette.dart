import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../constants/domain/contact_constants.dart';
import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import '../widgets/flat_contacts_list.dart';
import '../widgets/grouped_contact_selector.dart';
import 'contact_cassette_helpers.dart';

class ContactsEnhancedPickerCassette extends ConsumerWidget {
  const ContactsEnhancedPickerCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(
      contactsListProvider(spec: const ContactsListSpec.alphabetical()),
    );

    // Invariant: this cassette is only shown when no contact is selected.
    // Selection swaps the cassette spec to the hero summary.
    const int? selectedContactId = null;

    return contactsAsync.when(
      data: (contacts) {
        final selectedId = ref.watch(_pendingSelectionProvider);

        if (selectedId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(_pendingSelectionProvider.notifier).state = null;
          });
        }

        // Decide which widget to show based on contact count
        final useFlatPicker = contacts.length < kContactPickerGroupingThreshold;

        if (useFlatPicker) {
          // Simple flat list for few contacts
          return FlatContactsList(
            contacts: contacts,
            selectedParticipantId: selectedContactId,
            onContactSelected: (contactId) async {
              ref.read(_pendingSelectionProvider.notifier).state = contactId;

              await Future<void>.delayed(const Duration(milliseconds: 160));

              updateContactSelection(
                ref: ref,
                currentSpec: spec,
                nextContactId: contactId,
              );
            },
          );
        }

        // Full grouped picker for many contacts
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: selectedId == null
                  ? FullContactPicker(
                      key: const ValueKey('contactsPicker'),
                      selectedParticipantId: selectedContactId,
                      onContactSelected: (contactId) async {
                        ref.read(_pendingSelectionProvider.notifier).state =
                            contactId;

                        await Future<void>.delayed(
                          const Duration(milliseconds: 120),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ref
                            .read(cassetteRackStateProvider.notifier)
                            .updateSpecAndChild(
                              CassetteSpec.contacts(spec),
                              CassetteSpec.contacts(
                                ContactsCassetteSpec.contactHeroSummary(
                                  chosenContactId: contactId,
                                ),
                              ),
                            );
                      },
                      maxHeight: 380,
                    )
                  : Container(
                      key: const ValueKey('contactsPickerPlaceholder'),
                      constraints: const BoxConstraints(minHeight: 44),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => ContactCassetteError(
        onRetry: () {
          ref.invalidate(
            contactsListProvider(spec: const ContactsListSpec.alphabetical()),
          );
        },
        message: '$error',
      ),
    );
  }
}

final _pendingSelectionProvider = StateProvider<int?>((ref) => null);
