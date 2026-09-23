import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../infrastructure/repositories/overlay_attachment_archive_settings_store.dart';
import 'attachment_archive_settings_store.dart';

part 'attachment_archive_settings_store_provider.g.dart';

@riverpod
Future<AttachmentArchiveSettingsStore> attachmentArchiveSettingsStore(
  Ref ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayAttachmentArchiveSettingsStore(overlayDb: overlayDb);
}
