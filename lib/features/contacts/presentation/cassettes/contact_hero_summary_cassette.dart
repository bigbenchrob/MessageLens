import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../application_pre_cassette/contact_hero_metrics_provider.dart';
import '../../application_pre_cassette/contacts_list_provider.dart';
import '../widgets/contact_highlight_row.dart';
import 'contact_cassette_helpers.dart';

class ContactHeroSummaryCassette extends ConsumerWidget {
  const ContactHeroSummaryCassette({required this.spec, super.key});

  final ContactsCassetteSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(
      contactsListProvider(spec: const ContactsListSpec.alphabetical()),
    );

    final selectedContactId = spec.maybeWhen(
      contactHeroSummary: (chosenContactId) => chosenContactId,
      orElse: () => null,
    );

    return contactsAsync.when(
      data: (contacts) {
        final selectedContact = findContact(
          contacts: contacts,
          participantId: selectedContactId,
        );

        if (selectedContactId == null || selectedContact == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selected contact not found.'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  updateContactSelection(
                    ref: ref,
                    currentSpec: spec,
                    nextContactId: null,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'change…',
                  style: MacosTheme.of(context).typography.body.copyWith(
                    color: MacosTheme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          );
        }

        final metricsAsync = ref.watch(
          contactHeroMetricsProvider(contactId: selectedContactId),
        );

        String formatMonthYear(DateTime date) {
          const months = <String>[
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          return '${months[date.month - 1]} ${date.year}';
        }

        String formatCount(int value) {
          final s = value.toString();
          final buffer = StringBuffer();
          for (var i = 0; i < s.length; i++) {
            final remaining = s.length - i;
            buffer.write(s[i]);
            if (remaining > 1 && remaining % 3 == 1) {
              buffer.write(',');
            }
          }
          return buffer.toString();
        }

        String buildSummaryLine(ContactHeroMetrics metrics) {
          final first = metrics.firstMessageAtUtc;
          final last = metrics.lastMessageAtUtc;

          final range = (first != null && last != null)
              ? '${formatMonthYear(first.toLocal())} – ${formatMonthYear(last.toLocal())}'
              : 'Message history unavailable';

          final count = '${formatCount(metrics.totalMessages)} messages';

          return '$count · $range';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            metricsAsync.when(
              data: (metrics) => ContactHeroHeaderHighlight(
                displayName: selectedContact.displayName,
                shortName: selectedContact.shortName,
                summaryLine: buildSummaryLine(metrics),
                onChange: () {
                  updateContactSelection(
                    ref: ref,
                    currentSpec: spec,
                    nextContactId: null,
                  );
                },
              ),
              loading: () => ContactHeroHeaderHighlight(
                displayName: selectedContact.displayName,
                shortName: selectedContact.shortName,
                summaryLine: 'Loading…',
                onChange: () {
                  updateContactSelection(
                    ref: ref,
                    currentSpec: spec,
                    nextContactId: null,
                  );
                },
              ),
              error: (error, _) => ContactHeroHeaderHighlight(
                displayName: selectedContact.displayName,
                shortName: selectedContact.shortName,
                summaryLine: 'Unable to load message stats',
                onChange: () {
                  updateContactSelection(
                    ref: ref,
                    currentSpec: spec,
                    nextContactId: null,
                  );
                },
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
