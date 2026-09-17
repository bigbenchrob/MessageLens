import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../../application/attachment_archive_relocation_file_system.dart';

typedef _RenameExclusiveNative =
    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Uint32);
typedef _RenameExclusiveDart = int Function(Pointer<Utf8>, Pointer<Utf8>, int);

final class DarwinExclusiveDirectoryFinalizer
    implements AttachmentArchiveExclusiveDirectoryFinalizer {
  const DarwinExclusiveDirectoryFinalizer();

  static const int _renameExclusive = 0x00000004;
  static final _rename = DynamicLibrary.process()
      .lookupFunction<_RenameExclusiveNative, _RenameExclusiveDart>(
        'renamex_np',
      );

  @override
  Future<void> finalize({
    required String stagingRootPath,
    required String finalRootPath,
  }) async {
    if (!Platform.isMacOS) {
      throw UnsupportedError(
        'Exclusive attachment relocation finalization supports macOS only.',
      );
    }
    if (FileSystemEntity.typeSync(finalRootPath, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw FileSystemException(
        'Attachment relocation final destination already exists.',
        finalRootPath,
      );
    }
    final sourcePointer = stagingRootPath.toNativeUtf8();
    final destinationPointer = finalRootPath.toNativeUtf8();
    try {
      if (_rename(sourcePointer, destinationPointer, _renameExclusive) != 0) {
        throw FileSystemException(
          'Exclusive attachment relocation finalization failed.',
          finalRootPath,
        );
      }
    } finally {
      calloc.free(sourcePointer);
      calloc.free(destinationPointer);
    }
  }
}
