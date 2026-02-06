import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../../infrastructure/repositories/recent_contacts_repository.dart';

/// Widget builder for the flat contact list display.
///
/// This widget builder assembles a simple scrollable list of contacts
/// for use when the contact count is below the grouping threshold.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
/// - Never make branching decisions about which UI to show
class ContactFlatListWidget extends ConsumerWidget {
  const ContactFlatListWidget({
    super.key,
    required this.chosenContactId,
    required this.cassetteIndex,
  });

  /// Currently selected contact ID, if any.
  final int? chosenContactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Widget may reactively watch data
    final contactsAsync = ref.watch(
      contactsListRepositoryProvider(
        spec: const ContactsListSpec.alphabetical(),
      ),
    );

    return contactsAsync.when(
      data: (contacts) {
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
              final isSelected = contact.participantId == chosenContactId;

              return _ContactRow(
                displayName: contact.displayName,
                isSelected: isSelected,
                onTap: () =>
                    _handleContactSelection(ref, contact.participantId),
                colors: colors,
                typography: typography,
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => Center(
        child: Text(
          'Error loading contacts: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _handleContactSelection(WidgetRef ref, int contactId) async {
    // Construct spec on user interaction (output, not interpretation)
    // Emit selection control which cascades to hero summary
    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactSelectionControl(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);

    // Track contact as recently accessed (persists to overlay.db)
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.trackContactAccess(contactId);
    ref.invalidate(recentContactsProvider);
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.displayName,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  final String displayName;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;
  final ThemeTypography typography;

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
                displayName,
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
