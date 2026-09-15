import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../domain/entities/attachment_archive_location_state.dart';
import 'attachment_archive_location_controller.dart';
import 'attachment_archive_settings_store_provider.dart';

part 'attachment_archive_location_provider.g.dart';

/// Publishes the active attachment-owned archive location.
///
/// Loading performs one overlay setting read and bounded path derivation only.
/// It does not inspect, create, inventory, or validate the payload directory.
@Riverpod(keepAlive: true)
Future<AttachmentArchiveLocationState> attachmentArchiveLocation(Ref ref) {
  return _loadAttachmentArchiveLocation(ref);
}

Future<AttachmentArchiveLocationState> _loadAttachmentArchiveLocation(
  Ref ref,
) async {
  final archiveAccessAuthority = ref.watch(archiveAccessAuthorityProvider);
  final settingsStore = await ref.watch(
    attachmentArchiveSettingsStoreProvider.future,
  );
  final controller = AttachmentArchiveLocationController(
    archiveAccessAuthority: archiveAccessAuthority,
    settingsStore: settingsStore,
  );
  return controller.load();
}
