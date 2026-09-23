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
/// explicitly marked active by a later verified adoption workflow.
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
String _$attachmentArchiveLocationObservationHash() =>
    r'3fff8b0759d41876f67660939b907ec2dd80410e';

/// Passive, presentation-safe observation seam for attachment location.
///
/// Watching this provider never initializes location resolution. The existing
/// Feature 31 owner publishes snapshots after its own legitimate lifecycle
/// work has completed. Publication remains library-private to that owner.
///
/// Copied from [AttachmentArchiveLocationObservation].
@ProviderFor(AttachmentArchiveLocationObservation)
final attachmentArchiveLocationObservationProvider =
    NotifierProvider<
      AttachmentArchiveLocationObservation,
      AttachmentArchiveLocationSnapshot?
    >.internal(
      AttachmentArchiveLocationObservation.new,
      name: r'attachmentArchiveLocationObservationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveLocationObservationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttachmentArchiveLocationObservation =
    Notifier<AttachmentArchiveLocationSnapshot?>;
String _$attachmentArchiveLocationHash() =>
    r'5a26cea8564b8990ba1d8d75c29de0ea00054c15';

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
