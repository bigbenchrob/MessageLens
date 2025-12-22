import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/theme.dart';
import '../../../../config/theme/widgets/app_dropdown_menu.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import 'contact_cassette_helpers.dart';

class ContactsFlatDropdownMenuCassette extends ConsumerWidget {
  const ContactsFlatDropdownMenuCassette({
    required this.spec,
    required this.contacts,
    super.key,
  });

  final ContactsCassetteSpec spec;
  final List<ContactSummary> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContactId = spec.when(
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
    );

    final selected = findContact(
      contacts: contacts,
      participantId: selectedContactId,
    );

    if (contacts.isEmpty) {
      return const _EmptyContactsState();
    }

    final bbc = AppTheme.bbc(context);

    return AppDropdownMenu<ContactSummary>(
      options: contacts,
      selectedOption: selected ?? contacts.first,
      equals: (a, b) => a.participantId == b.participantId,
      optionLabelBuilder: (c) => c.displayName,
      leadingLabel: 'Contact',
      onSelected: (contact) {
        updateContactSelection(
          ref: ref,
          currentSpec: spec,
          nextContactId: contact.participantId,
        );
      },
      outerPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      panelMargin: const EdgeInsets.only(top: 6),
      triggerPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      triggerBorderRadius: BorderRadius.circular(10),
      panelBorderRadius: BorderRadius.circular(10),
      animationDuration: const Duration(milliseconds: 140),
      animationCurve: Curves.easeOut,
      expandToWidth: true,
      showDividers: true,
      showSelectionCheckmark: true,
      trailingIconSize: 16,
      closedIcon: CupertinoIcons.chevron_down,
      openIcon: CupertinoIcons.chevron_up,
      chevronColor: bbc.bbcHintText,
      selectedValueWeight: FontWeight.w600,
    );
  }
}

class _EmptyContactsState extends StatelessWidget {
  const _EmptyContactsState();

  @override
  Widget build(BuildContext context) {
    final typography = AppTheme.typography(context);
    final bbc = AppTheme.bbc(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        'No contacts available',
        style: typography.callout.copyWith(color: bbc.bbcSubheadText),
      ),
    );
  }
}
