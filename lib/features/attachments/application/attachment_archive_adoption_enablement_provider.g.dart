// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_adoption_enablement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveAdoptionExecutionEnabledHash() =>
    r'c70fc306f5d36699f3f1c0679651a978a041aad3';

/// Exact, fail-closed gate for the simplified development adoption workflow.
///
/// There is deliberately no runtime flag, preference, environment-variable
/// override, or production identity in this predicate.
///
/// Copied from [attachmentArchiveAdoptionExecutionEnabled].
@ProviderFor(attachmentArchiveAdoptionExecutionEnabled)
final attachmentArchiveAdoptionExecutionEnabledProvider =
    AutoDisposeProvider<bool>.internal(
      attachmentArchiveAdoptionExecutionEnabled,
      name: r'attachmentArchiveAdoptionExecutionEnabledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveAdoptionExecutionEnabledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveAdoptionExecutionEnabledRef =
    AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
