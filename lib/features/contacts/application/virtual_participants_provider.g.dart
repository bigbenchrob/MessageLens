// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'virtual_participants_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$virtualParticipantsHash() =>
    r'9313094bbfbe3caa49d6946a7dd673962e0d73ca';

/// Provides the list of virtual contacts stored in user_overlays.db.
///
/// Copied from [virtualParticipants].
@ProviderFor(virtualParticipants)
final virtualParticipantsProvider =
    AutoDisposeFutureProvider<List<OverlayVirtualContact>>.internal(
      virtualParticipants,
      name: r'virtualParticipantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$virtualParticipantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VirtualParticipantsRef =
    AutoDisposeFutureProviderRef<List<OverlayVirtualContact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
