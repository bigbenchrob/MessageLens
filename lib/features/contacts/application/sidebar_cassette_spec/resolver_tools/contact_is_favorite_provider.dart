import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'favorite_contacts_repository_provider.dart';

part 'contact_is_favorite_provider.g.dart';

/// Whether [participantId] is currently in the user's favorites.
///
/// Reactivity is driven by explicit invalidation: after add/remove mutations
/// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
@riverpod
Future<bool> contactIsFavorite(Ref ref, {required int participantId}) async {
  final repository = await ref.watch(favoriteContactsRepositoryProvider.future);
  return repository.isFavorite(participantId);
}
