import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/repositories/file_selector_attachment_archive_location_folder_chooser.dart';
import '../infrastructure/repositories/method_channel_attachment_archive_location_native_adapter.dart';
import 'attachment_archive_location_folder_chooser.dart';
import 'attachment_archive_location_native_adapter.dart';

part 'attachment_archive_location_dependencies_provider.g.dart';

@riverpod
AttachmentArchiveLocationNativeAdapter attachmentArchiveLocationNativeAdapter(
  Ref ref,
) {
  return const MethodChannelAttachmentArchiveLocationNativeAdapter();
}

@riverpod
AttachmentArchiveLocationFolderChooser attachmentArchiveLocationFolderChooser(
  Ref ref,
) {
  return const FileSelectorAttachmentArchiveLocationFolderChooser();
}
