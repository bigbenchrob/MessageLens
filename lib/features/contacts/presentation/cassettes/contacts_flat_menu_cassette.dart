import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';
import '../view_model/cassette_view_model.dart';

class ContactsFlatMenuCassette extends ConsumerWidget {
  const ContactsFlatMenuCassette({
    required this.spec,
    required this.contacts,
    super.key,
  });

  final ContactsCassetteSpec spec;
  final List<ContactSummary> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract chosenContactId using pattern matching
    final selectedContactId = spec.when(
      recentContacts: (id) => id,
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
      settings: (_) => null,
    );

    if (contacts.isEmpty) {
      return const _EmptyState();
    }

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: contacts.map((contact) {
          final isSelected = contact.participantId == selectedContactId;

          return _FlatContactRow(
            contact: contact,
            isSelected: isSelected,
            onTap: () {
              ref
                  .read(cassetteViewModelProvider.notifier)
                  .updateContactSelection(
                    currentSpec: spec,
                    nextContactId: contact.participantId,
                  );
            },
            typography: typography,
            colors: colors,
          );
        }).toList(),
      ),
    );
  }
}

class _FlatContactRow extends StatelessWidget {
  const _FlatContactRow({
    required this.contact,
    required this.isSelected,
    required this.onTap,
    required this.typography,
    required this.colors,
  });

  final ContactSummary contact;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeTypography typography;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accents.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: colors.lines.borderSubtle, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                contact.displayName,
                style: typography.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.checkmark_alt,
                size: 14,
                color: colors.accents.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Center(
        child: Text(
          'No contacts available',
          style: typography.body.copyWith(color: colors.content.textTertiary),
        ),
      ),
    );
  }
}
