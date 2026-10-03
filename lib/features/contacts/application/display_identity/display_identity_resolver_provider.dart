import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show
        driftConversationGraphDatabaseProvider,
        messageDataVersionProvider,
        overlayDatabaseProvider;
import '../../infrastructure/repositories/display_identity_repository.dart';
import 'display_identity.dart';

part 'display_identity_resolver_provider.g.dart';

/// Semantic display-identity boundary.
///
/// This resolver answers "what should the user see?", not "which database row
/// owns this information?". Row ids and handle values are inputs/provenance;
/// the output is an app-facing identity label.
@riverpod
Future<DisplayIdentityResolver> displayIdentityResolver(Ref ref) async {
  ref.watch(messageDataVersionProvider);

  final graphDb = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return SqliteDisplayIdentityRepository(
    graphDatabase: graphDb,
    overlayDatabase: overlayDb,
  ).readResolver();
}
