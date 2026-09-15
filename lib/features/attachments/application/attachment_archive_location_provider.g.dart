// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveLocationHash() =>
    r'4e9b15af1fdc822be5db0d08b0831287c1eeed35';

/// Publishes the active attachment-owned archive location.
///
/// Loading performs one overlay setting read and bounded path derivation only.
/// It does not inspect, create, inventory, or validate the payload directory.
///
/// Copied from [attachmentArchiveLocation].
@ProviderFor(attachmentArchiveLocation)
final attachmentArchiveLocationProvider =
    FutureProvider<AttachmentArchiveLocationState>.internal(
      attachmentArchiveLocation,
      name: r'attachmentArchiveLocationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveLocationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveLocationRef =
    FutureProviderRef<AttachmentArchiveLocationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
