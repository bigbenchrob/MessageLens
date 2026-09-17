// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_relocation_enablement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveRelocationExecutionEnabledHash() =>
    r'3b002a29986184568d4659778d3b6760d5ce16ce';

/// Exact, fail-closed execution gate for the authorized development rehearsal.
///
/// The admitted authority is the only input. Production, FDA experiments,
/// tests, other development roots, and other archive instances remain denied.
///
/// Copied from [attachmentArchiveRelocationExecutionEnabled].
@ProviderFor(attachmentArchiveRelocationExecutionEnabled)
final attachmentArchiveRelocationExecutionEnabledProvider =
    AutoDisposeProvider<bool>.internal(
      attachmentArchiveRelocationExecutionEnabled,
      name: r'attachmentArchiveRelocationExecutionEnabledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveRelocationExecutionEnabledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveRelocationExecutionEnabledRef =
    AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
