import 'attachment_archive_bookmark_adapter.dart';
import 'attachment_archive_relocation_file_system.dart';

export 'attachment_archive_bookmark_adapter.dart';

abstract interface class AttachmentArchiveLocationNativeAdapter
    implements
        AttachmentArchiveBookmarkAdapter,
        AttachmentArchiveDestinationCapacityReader {}
