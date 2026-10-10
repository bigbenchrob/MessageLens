import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../messages_source/feature_level_providers.dart'
    show currentMessagesSourceEvidenceReaderProvider;
import '../infrastructure/system/macos_full_disk_access.dart';
import 'full_disk_access.dart';

part 'full_disk_access_provider.g.dart';

@riverpod
FullDiskAccess fullDiskAccess(Ref ref) {
  return MacosFullDiskAccess(
    sourceEvidenceReader: ref.watch(
      currentMessagesSourceEvidenceReaderProvider,
    ),
    onReadFailure: (error, stackTrace) {
      scheduleMicrotask(
        () => ref
            .read(appLoggerProvider.notifier)
            .warn(
              'FullDiskAccess: Messages database exists but could not be read',
              source: 'MacosFullDiskAccess',
              context: <String, Object?>{
                'error': error.toString(),
                'stackTrace': stackTrace.toString(),
              },
            ),
      );
    },
  );
}
