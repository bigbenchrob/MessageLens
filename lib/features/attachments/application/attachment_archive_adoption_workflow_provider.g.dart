// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_adoption_workflow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveAdoptionFolderChooserHash() =>
    r'49fb7e5cdc18dae9cb9febd2616616192fb9146c';

/// See also [attachmentArchiveAdoptionFolderChooser].
@ProviderFor(attachmentArchiveAdoptionFolderChooser)
final attachmentArchiveAdoptionFolderChooserProvider =
    AutoDisposeProvider<AttachmentArchiveLocationFolderChooser>.internal(
      attachmentArchiveAdoptionFolderChooser,
      name: r'attachmentArchiveAdoptionFolderChooserProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionFolderChooserHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionFolderChooserRef =
    AutoDisposeProviderRef<AttachmentArchiveLocationFolderChooser>;
String _$attachmentArchiveAdoptionBookmarkAdapterHash() =>
    r'ae7d8ec2c0cf4343f33d4802ab7d11a02d5c7cf5';

/// See also [attachmentArchiveAdoptionBookmarkAdapter].
@ProviderFor(attachmentArchiveAdoptionBookmarkAdapter)
final attachmentArchiveAdoptionBookmarkAdapterProvider =
    AutoDisposeProvider<AttachmentArchiveBookmarkAdapter>.internal(
      attachmentArchiveAdoptionBookmarkAdapter,
      name: r'attachmentArchiveAdoptionBookmarkAdapterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionBookmarkAdapterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionBookmarkAdapterRef =
    AutoDisposeProviderRef<AttachmentArchiveBookmarkAdapter>;
String _$attachmentArchiveAdoptionCandidateVerifierHash() =>
    r'2c28d16c3807d1d9631070ff2c2c50a01beeb87c';

/// See also [attachmentArchiveAdoptionCandidateVerifier].
@ProviderFor(attachmentArchiveAdoptionCandidateVerifier)
final attachmentArchiveAdoptionCandidateVerifierProvider =
    AutoDisposeFutureProvider<AttachmentArchiveCandidateVerifier>.internal(
      attachmentArchiveAdoptionCandidateVerifier,
      name: r'attachmentArchiveAdoptionCandidateVerifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionCandidateVerifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionCandidateVerifierRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveCandidateVerifier>;
String _$attachmentArchiveAdoptionExecutorHash() =>
    r'a919756a870c1a095f690e37784ca7b7a9c77f2f';

/// See also [attachmentArchiveAdoptionExecutor].
@ProviderFor(attachmentArchiveAdoptionExecutor)
final attachmentArchiveAdoptionExecutorProvider =
    AutoDisposeFutureProvider<AttachmentArchiveAdoptionExecutor>.internal(
      attachmentArchiveAdoptionExecutor,
      name: r'attachmentArchiveAdoptionExecutorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionExecutorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionExecutorRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveAdoptionExecutor>;
String _$attachmentArchiveAdoptionSourceLocationHash() =>
    r'3e544092d24445023111d0de5ff050980b975444';

/// See also [attachmentArchiveAdoptionSourceLocation].
@ProviderFor(attachmentArchiveAdoptionSourceLocation)
final attachmentArchiveAdoptionSourceLocationProvider =
    AutoDisposeFutureProvider<AttachmentArchiveLocationState>.internal(
      attachmentArchiveAdoptionSourceLocation,
      name: r'attachmentArchiveAdoptionSourceLocationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionSourceLocationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionSourceLocationRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveLocationState>;
String _$attachmentArchiveAdoptionWorkflowHash() =>
    r'bf61058f3bd33ec7050f42dddce8b529b37495a4';

/// Ephemeral Settings workflow for checking and adopting an existing copy.
///
/// The complete result stays private in this notifier. Reconstructing this
/// provider discards it, so stale ready evidence can never become UI authority.
///
/// Copied from [AttachmentArchiveAdoptionWorkflow].
@ProviderFor(AttachmentArchiveAdoptionWorkflow)
final attachmentArchiveAdoptionWorkflowProvider =
    NotifierProvider<
      AttachmentArchiveAdoptionWorkflow,
      AttachmentArchiveAdoptionWorkflowState
    >.internal(
      AttachmentArchiveAdoptionWorkflow.new,
      name: r'attachmentArchiveAdoptionWorkflowProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionWorkflowHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttachmentArchiveAdoptionWorkflow =
    Notifier<AttachmentArchiveAdoptionWorkflowState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
