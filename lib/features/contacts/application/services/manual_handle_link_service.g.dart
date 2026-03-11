// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_handle_link_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manualHandleLinkServiceHash() =>
    r'5b2b03ded1acd4265a2fc74007768a4b8762d5dd';

/// Service for managing manual handle-to-contact links.
///
/// All writes target the overlay database exclusively. The working database
/// is never modified here — providers merge both databases at read time
/// with overlay winning on conflict (inviolable architectural rule).
///
/// Copied from [ManualHandleLinkService].
@ProviderFor(ManualHandleLinkService)
final manualHandleLinkServiceProvider =
    AutoDisposeNotifierProvider<ManualHandleLinkService, void>.internal(
      ManualHandleLinkService.new,
      name: r'manualHandleLinkServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualHandleLinkServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManualHandleLinkService = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
