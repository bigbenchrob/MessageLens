// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_relocation_enablement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveRelocationProductionEnabledHash() =>
    r'da53b1eadcd81a94df45630243f80d5f4ee716db';

/// Final production safety gate for the attachment-archive relocation UI.
///
/// Phase Six deliberately ships the reviewed workflow with execution disabled.
/// Tests override this provider only for disposable archives. Enabling a real
/// relocation requires a later explicit code review and authorization.
///
/// Copied from [attachmentArchiveRelocationProductionEnabled].
@ProviderFor(attachmentArchiveRelocationProductionEnabled)
final attachmentArchiveRelocationProductionEnabledProvider =
    AutoDisposeProvider<bool>.internal(
      attachmentArchiveRelocationProductionEnabled,
      name: r'attachmentArchiveRelocationProductionEnabledProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveRelocationProductionEnabledHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveRelocationProductionEnabledRef =
    AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
