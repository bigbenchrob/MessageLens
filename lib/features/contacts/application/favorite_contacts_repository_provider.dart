import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../infrastructure/repositories/favorite_contacts_repository.dart';

part 'favorite_contacts_repository_provider.g.dart';

@riverpod
Future<FavoriteContactsRepository> favoriteContactsRepository(
  FavoriteContactsRepositoryRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return FavoriteContactsRepository(overlayDb);
}
