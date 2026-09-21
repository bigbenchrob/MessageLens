// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_showcase_source_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentShowcaseSourceHash() =>
    r'e48cb567cbfc895bec9460cea597bccf1580913f';

/// Bounded, presentation-only sampling source for Attachment Showcase.
///
/// Producers never await this source. The currently displayed item plus at
/// most one latest pending item are retained; intermediate rapid events are
/// deliberately coalesced. No event is persisted or sent off-device.
///
/// Copied from [AttachmentShowcaseSource].
@ProviderFor(AttachmentShowcaseSource)
final attachmentShowcaseSourceProvider =
    NotifierProvider<
      AttachmentShowcaseSource,
      AttachmentShowcaseItem?
    >.internal(
      AttachmentShowcaseSource.new,
      name: r'attachmentShowcaseSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentShowcaseSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttachmentShowcaseSource = Notifier<AttachmentShowcaseItem?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
