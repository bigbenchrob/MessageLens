// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_relocation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveRelocationServiceHash() =>
    r'46fdcba4b346693ddcce5abf6760413c80559652';

/// Internal relocation-engine composition.
///
/// Copied from [attachmentArchiveRelocationService].
@ProviderFor(attachmentArchiveRelocationService)
final attachmentArchiveRelocationServiceProvider =
    AutoDisposeFutureProvider<AttachmentArchiveRelocationService>.internal(
      attachmentArchiveRelocationService,
      name: r'attachmentArchiveRelocationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveRelocationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveRelocationServiceRef =
    AutoDisposeFutureProviderRef<AttachmentArchiveRelocationService>;
String _$attachmentArchiveRelocationWorkflowHash() =>
    r'e0ebfc1884f387598ee2ffdc782b2acf0ac1491f';

/// See also [AttachmentArchiveRelocationWorkflow].
@ProviderFor(AttachmentArchiveRelocationWorkflow)
final attachmentArchiveRelocationWorkflowProvider =
    AsyncNotifierProvider<
      AttachmentArchiveRelocationWorkflow,
      AttachmentArchiveRelocationProgress?
    >.internal(
      AttachmentArchiveRelocationWorkflow.new,
      name: r'attachmentArchiveRelocationWorkflowProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveRelocationWorkflowHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttachmentArchiveRelocationWorkflow =
    AsyncNotifier<AttachmentArchiveRelocationProgress?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
