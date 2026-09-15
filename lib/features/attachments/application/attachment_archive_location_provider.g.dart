// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveMutationRootHash() =>
    r'9142df5a00f4e41177d63dbc3b883e41c7b980b6';

/// Grants existing mutation paths access only to the admitted internal root.
///
/// Custom roots remain read/location-only until the later writable-root lease
/// phase, regardless of their physical writability.
///
/// Copied from [attachmentArchiveMutationRoot].
@ProviderFor(attachmentArchiveMutationRoot)
final attachmentArchiveMutationRootProvider =
    FutureProvider<AttachmentArchiveMutationRoot>.internal(
      attachmentArchiveMutationRoot,
      name: r'attachmentArchiveMutationRootProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveMutationRootHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveMutationRootRef =
    FutureProviderRef<AttachmentArchiveMutationRoot>;
String _$attachmentArchiveLocationHash() =>
    r'9356943bfddfd90dceeec84e3242913bc578fab6';

/// Publishes the active attachment-owned archive location.
///
/// Loading performs one overlay setting read and, for custom configuration, a
/// bounded bookmark resolution. It never creates, inventories, or recursively
/// traverses the payload directory.
///
/// Copied from [AttachmentArchiveLocation].
@ProviderFor(AttachmentArchiveLocation)
final attachmentArchiveLocationProvider =
    AsyncNotifierProvider<
      AttachmentArchiveLocation,
      AttachmentArchiveLocationState
    >.internal(
      AttachmentArchiveLocation.new,
      name: r'attachmentArchiveLocationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveLocationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttachmentArchiveLocation =
    AsyncNotifier<AttachmentArchiveLocationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
