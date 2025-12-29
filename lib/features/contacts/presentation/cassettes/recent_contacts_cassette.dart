import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';
import '../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../essentials/sidebar/domain/entities/cassette_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application/recent_contacts_provider.dart';
import '../view_model/cassette_view_model.dart';

/// Cassette showing recently accessed contacts with "More..." button.
/// Shows up to 10 contacts ordered by last access time.
class RecentContactsCassette extends ConsumerWidget {
  const RecentContactsCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentContactsProvider);
    final bbc = AppTheme.bbc(context);
    final typography = MacosTheme.of(context).typography;

    // Extract chosenContactId using pattern matching
    final selectedContactId = spec.when(
      recentContacts: (id) => id,
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
    );

    return recentAsync.when(
      data: (recents) {
        if (recents.isEmpty) {
          // No recent contacts - show "More..." button to open full chooser
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _NoRecentsMessage(),
              _MoreButton(
                onTap: () {
                  ref
                      .read(cassetteRackStateProvider.notifier)
                      .updateSpecAndChild(
                        CassetteSpec.contacts(spec),
                        const CassetteSpec.contacts(
                          ContactsCassetteSpec.contactChooser(),
                        ),
                      );
                },
                colors: bbc,
                typography: typography,
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recent contacts list
            ...recents.map((recent) {
              final isSelected = recent.participantId == selectedContactId;

              return _RecentContactRow(
                displayName: recent.displayName,
                participantId: recent.participantId,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(cassetteViewModelProvider.notifier)
                      .updateContactSelection(
                        currentSpec: spec,
                        nextContactId: recent.participantId,
                      );
                },
                typography: typography,
                colors: bbc,
              );
            }),

            // "More..." button to open full contact chooser
            _MoreButton(
              onTap: () {
                // Replace recent contacts with full chooser
                ref
                    .read(cassetteRackStateProvider.notifier)
                    .updateSpecAndChild(
                      CassetteSpec.contacts(spec),
                      const CassetteSpec.contacts(
                        ContactsCassetteSpec.contactChooser(),
                      ),
                    );
              },
              colors: bbc,
              typography: typography,
            ),
          ],
        );
      },
      loading: () => const _LoadingState(),
      error: (_, __) => _ErrorState(
        colors: bbc,
        typography: typography,
        onRetry: () {
          ref
              .read(cassetteRackStateProvider.notifier)
              .updateSpecAndChild(
                CassetteSpec.contacts(spec),
                const CassetteSpec.contacts(
                  ContactsCassetteSpec.contactChooser(),
                ),
              );
        },
      ),
    );
  }
}

class _RecentContactRow extends StatelessWidget {
  const _RecentContactRow({
    required this.displayName,
    required this.participantId,
    required this.isSelected,
    required this.onTap,
    required this.typography,
    required this.colors,
  });

  final String displayName;
  final int participantId;
  final bool isSelected;
  final VoidCallback onTap;
  final MacosTypography typography;
  final BbcColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.bbcPrimaryOne.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: colors.bbcBorderSubtle, width: 0.5),
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
                color: colors.bbcPrimaryOne,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  final VoidCallback onTap;
  final BbcColors colors;
  final MacosTypography typography;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.bbcBorderSubtle, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'All contacts...',
                style: typography.body.copyWith(
                  color: colors.bbcPrimaryOne,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: colors.bbcPrimaryOne,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoRecentsMessage extends StatelessWidget {
  const _NoRecentsMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text('No recent contacts', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProgressCircle(),
          SizedBox(height: 12),
          Text(
            'Loading recent contacts...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.colors,
    required this.typography,
    required this.onRetry,
  });

  final BbcColors colors;
  final MacosTypography typography;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Unable to load recent contacts',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'View all contacts',
              style: typography.body.copyWith(
                color: colors.bbcPrimaryOne,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
