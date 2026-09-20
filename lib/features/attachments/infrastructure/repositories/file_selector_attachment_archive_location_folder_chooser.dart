import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import '../../application/attachment_archive_location_folder_chooser.dart';

final class FileSelectorAttachmentArchiveLocationFolderChooser
    implements AttachmentArchiveLocationFolderChooser {
  const FileSelectorAttachmentArchiveLocationFolderChooser();

  @override
  Future<String?> chooseArchiveDirectory() {
    // FileDialogOptions exposes confirmation text but no title or instruction.
    // Settings supplies the instruction to select attachment_archive itself.
    return FileSelectorPlatform.instance.getDirectoryPathWithOptions(
      const FileDialogOptions(
        confirmButtonText: 'Select This Archive',
        canCreateDirectories: false,
      ),
    );
  }
}
