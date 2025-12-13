import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import '../widgets/flat_contacts_list.dart';
import '../widgets/grouped_contact_selector.dart';

class ContactsChooser extends ConsumerWidget {
  const ContactsChooser({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(
      contactsListProvider(spec: const ContactsListSpec.alphabetical()),
    );

    final selectedContactId = spec.maybeWhen(
      contactsFlatMenu: (chosenContactId) => chosenContactId,
      contactPicker: (chosenContactId) => chosenContactId,
      orElse: () => null,
    );

    ContactSummary? findContact(int? participantId, List<ContactSummary> pool) {
      if (participantId == null) {
        return null;
      }
      for (final contact in pool) {
        if (contact.participantId == participantId) {
          return contact;
        }
      }
      return null;
    }

    void updateSelection(int? contactId) {
      final updatedSpec = spec.copyWith(chosenContactId: contactId);
      ref
          .read(cassetteRackStateProvider.notifier)
          .updateSpecAndChild(
            CassetteSpec.contacts(spec),
            CassetteSpec.contacts(updatedSpec),
          );
    }

    return contactsAsync.when(
      data: (contacts) {
        final selectedContact = findContact(selectedContactId, contacts);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            spec.when(
              contactsFlatMenu: (_) {
                return FlatContactsList(
                  contacts: contacts,
                  selectedParticipantId: selectedContactId,
                  onContactSelected: (contactId) {
                    updateSelection(contactId);
                  },
                );
              },
              contactPicker: (_) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FullContactPicker(
                      selectedParticipantId: selectedContactId,
                      onContactSelected: (contactId) {
                        updateSelection(contactId);
                      },
                      maxHeight: 380,
                    ),
                    if (selectedContact != null) ...[
                      const SizedBox(height: 10),
                      _SelectedContactSummary(contact: selectedContact),
                    ],
                  ],
                );
              },
              chosenContact: (_) {
                if (selectedContact == null) {
                  return const Text('Selected contact not found.');
                }
                return _SelectedContactSummary(contact: selectedContact);
              },
            ),
            if (selectedContactId != null) ...[
              const SizedBox(height: 8),
              PushButton(
                controlSize: ControlSize.small,
                onPressed: () {
                  updateSelection(null);
                },
                child: const Text('Clear selection'),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => _ContactCassetteError(
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

class _SelectedContactSummary extends StatelessWidget {
  const _SelectedContactSummary({required this.contact});

  final ContactSummary contact;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    const mutedColor = MacosColors.secondaryLabelColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MacosColors.quaternaryLabelColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.person_crop_circle,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contact.displayName,
                  style: typography.headline.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            contact.shortName,
            style: typography.caption1.copyWith(color: mutedColor),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${contact.totalMessages} messages',
                style: typography.caption1.copyWith(color: mutedColor),
              ),
              const SizedBox(width: 12),
              Text(
                '${contact.totalChats} chats',
                style: typography.caption1.copyWith(color: mutedColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCassetteError extends StatelessWidget {
  const _ContactCassetteError({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load contacts',
                style: typography.caption1.copyWith(
                  color: CupertinoColors.systemRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PushButton(
              controlSize: ControlSize.small,
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          message,
          style: typography.caption2.copyWith(
            color: MacosColors.secondaryLabelColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
