import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import '../../application/attachment_archive_location_folder_chooser.dart';

final class FileSelectorAttachmentArchiveLocationFolderChooser
    implements AttachmentArchiveLocationFolderChooser {
  const FileSelectorAttachmentArchiveLocationFolderChooser();

  @override
  Future<String?> chooseArchiveDirectory() {
    return FileSelectorPlatform.instance.getDirectoryPathWithOptions(
      const FileDialogOptions(confirmButtonText: 'Choose Archive Copy'),
    );
  }
}
