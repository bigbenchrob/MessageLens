import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import 'favorite_contacts_repository_provider.dart';

part 'favorite_contacts_provider.freezed.dart';
part 'favorite_contacts_provider.g.dart';

/// Favorite contact resolved with display metadata from the working dataset.
@freezed
abstract class FavoriteContactEntry with _$FavoriteContactEntry {
  const factory FavoriteContactEntry({
    required ContactSummary contact,
    required DateTime pinnedAt,
    DateTime? lastInteractionAt,
    required DateTime updatedAt,
  }) = _FavoriteContactEntry;
}

@riverpod
Future<List<FavoriteContactEntry>> favoriteContacts(
  FavoriteContactsRef ref,
) async {
  final repository = await ref.watch(favoriteContactsRepositoryProvider.future);
  final favorites = await repository.getAllFavorites();

  if (favorites.isEmpty) {
    return const [];
  }

  final contacts = await ref.watch(
    contactsListRepositoryProvider(
      spec: const ContactsListSpec.alphabetical(),
    ).future,
  );
  final contactsById = {
    for (final contact in contacts) contact.participantId: contact,
  };

  final resolved = <FavoriteContactEntry>[];
  for (final favorite in favorites) {
    final contact = contactsById[favorite.participantId];
    if (contact == null) {
      continue;
    }

    resolved.add(
      FavoriteContactEntry(
        contact: contact,
        pinnedAt: favorite.pinnedAt,
        lastInteractionAt: favorite.lastInteractionAt,
        updatedAt: favorite.updatedAt,
      ),
    );
  }

  return resolved;
}
