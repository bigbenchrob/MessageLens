import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme.dart';
import '../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';

/// Update the current contacts cassette and rebuild any downstream cascade.
void updateContactSelection({
  required WidgetRef ref,
  required ContactsCassetteSpec currentSpec,
  required int? nextContactId,
}) {
  final updatedSpec = currentSpec.map(
    contactsFlatMenu: (_) =>
        ContactsCassetteSpec.contactsFlatMenu(chosenContactId: nextContactId),
    contactsEnhancedPicker: (_) => ContactsCassetteSpec.contactsEnhancedPicker(
      chosenContactId: nextContactId,
    ),
    contactHeroSummary: (_) => nextContactId == null
        ? const ContactsCassetteSpec.contactsEnhancedPicker()
        : ContactsCassetteSpec.contactHeroSummary(
            chosenContactId: nextContactId,
          ),
  );

  ref
      .read(cassetteRackStateProvider.notifier)
      .updateSpecAndChild(
        CassetteSpec.contacts(currentSpec),
        CassetteSpec.contacts(updatedSpec),
      );
}

/// Find a contact in a pool by participant identifier.
ContactSummary? findContact({
  required List<ContactSummary> contacts,
  required int? participantId,
}) {
  if (participantId == null) {
    return null;
  }
  for (final contact in contacts) {
    if (contact.participantId == participantId) {
      return contact;
    }
  }
  return null;
}

class SelectedContactSummary extends StatelessWidget {
  const SelectedContactSummary({required this.contact, super.key});

  final ContactSummary contact;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final bbc = AppTheme.bbc(context);
    final mutedColor = bbc.bbcSubheadText;

    final backgroundColor = MacosDynamicColor.resolve(
      MacosColors.controlBackgroundColor,
      context,
    );
    final borderColor = MacosDynamicColor.resolve(
      MacosColors.quaternaryLabelColor,
      context,
    );
    final accentColor = MacosTheme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.person_crop_circle,
                size: 20,
                color: MacosDynamicColor.resolve(accentColor, context),
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

class ContactCassetteError extends StatelessWidget {
  const ContactCassetteError({
    required this.onRetry,
    required this.message,
    super.key,
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final bbc = AppTheme.bbc(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: MacosColors.systemRedColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load contacts',
                style: typography.caption1.copyWith(
                  color: MacosColors.systemRedColor,
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
          style: typography.caption2.copyWith(color: bbc.bbcSubheadText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
