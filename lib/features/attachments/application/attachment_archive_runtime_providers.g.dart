// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_runtime_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveFileOperationsHash() =>
    r'989590689db769b726455bada38873845f54a79d';

/// See also [attachmentArchiveFileOperations].
@ProviderFor(attachmentArchiveFileOperations)
final attachmentArchiveFileOperationsProvider =
    AutoDisposeProvider<AttachmentArchiveFileOperations>.internal(
      attachmentArchiveFileOperations,
      name: r'attachmentArchiveFileOperationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveFileOperationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveFileOperationsRef =
    AutoDisposeProviderRef<AttachmentArchiveFileOperations>;
String _$attachmentArchiveStatsReaderHash() =>
    r'490c1c646c36314538e8c609a75f66223486651c';

/// See also [attachmentArchiveStatsReader].
@ProviderFor(attachmentArchiveStatsReader)
final attachmentArchiveStatsReaderProvider =
    AutoDisposeFutureProvider<AttachmentArchiveStatsReader>.internal(
      attachmentArchiveStatsReader,
      name: r'attachmentArchiveStatsReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveStatsReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveStatsReaderRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveStatsReader>;
String _$attachmentArchiveStatisticsHash() =>
    r'cc7b2078f85f7559d48764d63abc2b1f4323bc30';

/// Explicit, potentially recursive archive inventory.
///
/// Ordinary settings, startup, search, and attachment resolution never watch
/// this provider. Callers opt into the scan and receive a root-level
/// unavailable result rather than an exception when a custom volume is gone.
///
/// Copied from [attachmentArchiveStatistics].
@ProviderFor(attachmentArchiveStatistics)
final attachmentArchiveStatisticsProvider =
    AutoDisposeFutureProvider<AttachmentArchiveStatisticsSnapshot>.internal(
      attachmentArchiveStatistics,
      name: r'attachmentArchiveStatisticsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveStatisticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveStatisticsRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveStatisticsSnapshot>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
