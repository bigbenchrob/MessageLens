// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveWritableRootAdmissionHash() =>
    r'f40c200f586b10e2c61d194670e40797ee45c3ff';

/// Issues the only writable-root authority accepted by archive mutation paths.
///
/// Custom selections remain mutation-ineligible until their configuration is
/// explicitly marked active by a later verified relocation workflow.
///
/// Copied from [attachmentArchiveWritableRootAdmission].
@ProviderFor(attachmentArchiveWritableRootAdmission)
final attachmentArchiveWritableRootAdmissionProvider =
    FutureProvider<AttachmentArchiveWritableRootAdmission>.internal(
      attachmentArchiveWritableRootAdmission,
      name: r'attachmentArchiveWritableRootAdmissionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveWritableRootAdmissionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveWritableRootAdmissionRef =
    FutureProviderRef<AttachmentArchiveWritableRootAdmission>;
String _$attachmentArchiveLocationHash() =>
    r'a1e0821cbddaa5f4a4cfa1659ee2e4a8a33f7065';

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
