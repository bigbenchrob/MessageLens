// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_adoption_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveAdoptionServiceHash() =>
    r'a9e8f9b8c4a52842b76033e48c775a408c6ff57a';

/// Internal composition for the approval-to-adoption transaction.
///
/// This provider is deliberately not consumed by Settings in Checkpoint Four.
///
/// Copied from [attachmentArchiveAdoptionService].
@ProviderFor(attachmentArchiveAdoptionService)
final attachmentArchiveAdoptionServiceProvider =
    AutoDisposeFutureProvider<AttachmentArchiveAdoptionService>.internal(
      attachmentArchiveAdoptionService,
      name: r'attachmentArchiveAdoptionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionServiceRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveAdoptionService>;
String _$attachmentArchiveAdoptionRecoveryHash() =>
    r'0778e67e24a4a629c68610c5e96a84522b59c57f';

/// Performs the bounded startup rollback check for an interrupted adoption.
///
/// Copied from [attachmentArchiveAdoptionRecovery].
@ProviderFor(attachmentArchiveAdoptionRecovery)
final attachmentArchiveAdoptionRecoveryProvider =
    FutureProvider<AttachmentArchiveAdoptionResult>.internal(
      attachmentArchiveAdoptionRecovery,
      name: r'attachmentArchiveAdoptionRecoveryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionRecoveryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionRecoveryRef =
    FutureProviderRef<AttachmentArchiveAdoptionResult>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
