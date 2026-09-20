import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/file_selector_attachment_archive_location_folder_chooser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final originalPlatform = FileSelectorPlatform.instance;

  tearDown(() {
    FileSelectorPlatform.instance = originalPlatform;
  });

  test(
    'uses the clearest supported native directory-selection wording',
    () async {
      final platform = _RecordingFileSelectorPlatform();
      FileSelectorPlatform.instance = platform;

      final selected =
          await const FileSelectorAttachmentArchiveLocationFolderChooser()
              .chooseArchiveDirectory();

      expect(selected, '/selected/attachment_archive');
      expect(platform.options?.confirmButtonText, 'Select This Archive');
      expect(platform.options?.canCreateDirectories, isFalse);
    },
  );
}

final class _RecordingFileSelectorPlatform extends FileSelectorPlatform {
  FileDialogOptions? options;

  @override
  Future<String?> getDirectoryPathWithOptions(FileDialogOptions options) async {
    this.options = options;
    return '/selected/attachment_archive';
  }
}
