import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../domain/participant_origin.dart';
import '../infrastructure/repositories/contacts_list_repository.dart';

part 'recent_contacts_provider.g.dart';

/// Recent contact with participant info for display
class RecentContactSummary {
  const RecentContactSummary({
    required this.participantId,
    required this.displayName,
    required this.lastAccessedUtc,
  });

  final int participantId;
  final String displayName;
  final DateTime lastAccessedUtc;
}

/// Provides list of recently accessed contacts (up to 6).
/// Combines overlay DB recent access tracking with working DB participant info.
@riverpod
Future<List<RecentContactSummary>> recentContacts(Ref ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // Get recently accessed participant IDs from overlay DB
  final recentFavorites = await overlayDb.getRecentContacts(limit: 6);

  // If no recent contacts tracked, return empty immediately
  if (recentFavorites.isEmpty) {
    return [];
  }

  // Wait for contacts to load (this properly awaits the async data)
  final allContacts = await ref.watch(
    contactsListRepositoryProvider(
      spec: const ContactsListSpec.alphabetical(),
    ).future,
  );

  // Map recent participant IDs to contact summaries
  final results = <RecentContactSummary>[];
  for (final recent in recentFavorites) {
    final contact = allContacts.firstWhere(
      (c) => c.participantId == recent.participantId,
      orElse: () => ContactSummary(
        participantId: recent.participantId,
        displayName: 'Contact ${recent.participantId}',
        shortName: 'Contact ${recent.participantId}',
        totalChats: 0,
        totalMessages: 0,
        origin: ParticipantOrigin.working,
        handleCount: 0,
      ),
    );

    results.add(
      RecentContactSummary(
        participantId: contact.participantId,
        displayName: contact.displayName,
        lastAccessedUtc: recent.lastInteractionUtc != null
            ? DateTime.parse(recent.lastInteractionUtc!)
            : DateTime.parse(recent.createdAtUtc),
      ),
    );
  }

  return results;
}
